//
//  BRKey+BIP38.m
//  BreadWallet
//
//  Created by Aaron Voisine on 4/9/14.
//  Copyright (c) 2014 Aaron Voisine <voisine@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "BRKey+BIP38.h"
#import "NSString+Base58.h"
#import "NSData+Hash.h"
#import "NSMutableData+Bitcoin.h"
#import "ccMemory.h"
#import <CommonCrypto/CommonCrypto.h>
#import <openssl/ecdsa.h>
#import <openssl/obj_mac.h>

// BIP38 is a method for encrypting private keys with a passphrase
// https://github.com/bitcoin/bips/blob/master/bip-0038.mediawiki

#define BIP38_SCRYPT_N    16384
#define BIP38_SCRYPT_R    8
#define BIP38_SCRYPT_P    8
#define BIP38_SCRYPT_EC_N 1024
#define BIP38_SCRYPT_EC_R 1
#define BIP38_SCRYPT_EC_P 1

// bitwise left rotation, this will typically be compiled into a single instruction
#define rotl(a, b) (((a) << (b)) | ((a) >> (32 - (b))))

// salsa20/8 stream cypher: http://cr.yp.to/snuffle.html
static void salsa20_8(uint32_t b[16])
{
    uint32_t x00 = b[0], x01 = b[1], x02 = b[2], x03 = b[3], x04 = b[4], x05 = b[5], x06 = b[6], x07 = b[7],
             x08 = b[8], x09 = b[9], x10 = b[10], x11 = b[11], x12 = b[12], x13 = b[13], x14 = b[14], x15 = b[15];

    for (int i = 0; i < 8; i += 2) {
        // operate on columns
        x04 ^= rotl(x00 + x12, 7), x08 ^= rotl(x04 + x00, 9), x12 ^= rotl(x08 + x04, 13), x00 ^= rotl(x12 + x08, 18);
        x09 ^= rotl(x05 + x01, 7), x13 ^= rotl(x09 + x05, 9), x01 ^= rotl(x13 + x09, 13), x05 ^= rotl(x01 + x13, 18);
        x14 ^= rotl(x10 + x06, 7), x02 ^= rotl(x14 + x10, 9), x06 ^= rotl(x02 + x14, 13), x10 ^= rotl(x06 + x02, 18);
        x03 ^= rotl(x15 + x11, 7), x07 ^= rotl(x03 + x15, 9), x11 ^= rotl(x07 + x03, 13), x15 ^= rotl(x11 + x07, 18);

        // operate on rows
        x01 ^= rotl(x00 + x03, 7), x02 ^= rotl(x01 + x00, 9), x03 ^= rotl(x02 + x01, 13), x00 ^= rotl(x03 + x02, 18);
        x06 ^= rotl(x05 + x04, 7), x07 ^= rotl(x06 + x05, 9), x04 ^= rotl(x07 + x06, 13), x05 ^= rotl(x04 + x07, 18);
        x11 ^= rotl(x10 + x09, 7), x08 ^= rotl(x11 + x10, 9), x09 ^= rotl(x08 + x11, 13), x10 ^= rotl(x09 + x08, 18);
        x12 ^= rotl(x15 + x14, 7), x13 ^= rotl(x12 + x15, 9), x14 ^= rotl(x13 + x12, 13), x15 ^= rotl(x14 + x13, 18);
    }

    b[0] += x00, b[1] += x01, b[2] += x02, b[3] += x03, b[4] += x04, b[5] += x05, b[6] += x06, b[7] += x07;
    b[8] += x08, b[9] += x09, b[10] += x10, b[11] += x11, b[12] += x12, b[13] += x13, b[14] += x14, b[15] += x15;
}

static void blockmix_salsa8(uint64_t *dest, const uint64_t *src, uint64_t *b, uint32_t r)
{
    CC_XMEMCPY(b, &src[(2*r - 1)*8], 64);

    for (uint32_t i = 0; i < 2*r; i += 2) {
        for (uint32_t j = 0; j < 8; j++) b[j] ^= src[i*8 + j];
        salsa20_8((uint32_t *)b);
        CC_XMEMCPY(&dest[i*4], b, 64);
        for (uint32_t j = 0; j < 8; j++) b[j] ^= src[i*8 + 8 + j];
        salsa20_8((uint32_t *)b);
        CC_XMEMCPY(&dest[i*4 + r*8], b, 64);
    }
}

// scrypt key derivation: http://www.tarsnap.com/scrypt.html
static NSData *scrypt(NSData *password, NSData *salt, int64_t n, uint32_t r, uint32_t p, NSUInteger length)
{
    NSMutableData *d = [NSMutableData secureDataWithLength:length];
    uint8_t b[128*r*p];
    uint64_t x[16*r], y[16*r], z[8], *v = CC_XMALLOC(128*r*(int)n), m;

    CCKeyDerivationPBKDF(kCCPBKDF2, password.bytes, password.length, salt.bytes, salt.length, kCCPRFHmacAlgSHA256, 1,
                         b, sizeof(b));

    for (uint32_t i = 0; i < p; i++) {
        for (uint32_t j = 0; j < 32*r; j++) {
            ((uint32_t *)x)[j] = CFSwapInt32LittleToHost(*(uint32_t *)&b[i*128*r + j*4]);
        }

        for (uint64_t j = 0; j < n; j += 2) {
            CC_XMEMCPY(&v[j*(16*r)], x, 128*r);
            blockmix_salsa8(y, x, z, r);
            CC_XMEMCPY(&v[(j + 1)*(16*r)], y, 128*r);
            blockmix_salsa8(x, y, z, r);
        }

        for (uint64_t j = 0; j < n; j += 2) {
            m = CFSwapInt64LittleToHost(x[(2*r - 1)*8]) & (n - 1);
            for (uint32_t k = 0; k < 16*r; k++) x[k] ^= v[m*(16*r) + k];
            blockmix_salsa8(y, x, z, r);
            m = CFSwapInt64LittleToHost(y[(2*r - 1)*8]) & (n - 1);
            for (uint32_t k = 0; k < 16*r; k++) y[k] ^= v[m*(16*r) + k];
            blockmix_salsa8(x, y, z, r);
        }

        for (uint32_t j = 0; j < 32*r; j++) {
            *(uint32_t *)&b[i*128*r + j*4] = CFSwapInt32HostToLittle(((uint32_t *)x)[j]);
        }
    }

    CCKeyDerivationPBKDF(kCCPBKDF2, password.bytes, password.length, b, sizeof(b), kCCPRFHmacAlgSHA256, 1,
                         d.mutableBytes, d.length);

    CC_XZEROMEM(b, sizeof(b));
    CC_XZEROMEM(x, sizeof(x));
    CC_XZEROMEM(y, sizeof(y));
    CC_XZEROMEM(z, sizeof(z));
    CC_XZEROMEM(v, 128*r*(int)n);
    CC_XFREE(v, 128*r*(int)n);
    CC_XZEROMEM(&m, sizeof(m));
    return d;
}

static NSData *normalize_passphrase(NSString *passphrase)
{
    NSData *password;
    CFMutableStringRef pw = CFStringCreateMutableCopy(SecureAllocator(), passphrase.length, (CFStringRef)passphrase);

    CFStringNormalize(pw, kCFStringNormalizationFormC);
    password = CFBridgingRelease(CFStringCreateExternalRepresentation(SecureAllocator(), pw, kCFStringEncodingUTF8, 0));
    CFRelease(pw);
    return password;
}

static void derive_passfactor(BIGNUM *passfactor, uint8_t flag, uint64_t entropy, NSString *passphrase)
{
    NSData *password = normalize_passphrase(passphrase);
    NSData *salt = [NSData dataWithBytesNoCopy:&entropy length:(flag & BIP38_LOTSEQUENCE_FLAG) ? 4 : 8 freeWhenDone:NO];
    NSData *prefactor = scrypt(password, salt, BIP38_SCRYPT_N, BIP38_SCRYPT_R, BIP38_SCRYPT_P, 32);
    NSMutableData *d;

    if (flag & BIP38_LOTSEQUENCE_FLAG) { // passfactor = SHA256(SHA256(prefactor + entropy))
        d = [NSMutableData secureDataWithData:prefactor];
        [d appendBytes:&entropy length:sizeof(entropy)];
        BN_bin2bn(d.SHA256_2.bytes, CC_SHA256_DIGEST_LENGTH, passfactor);
    }
    else BN_bin2bn(prefactor.bytes, (int)prefactor.length, passfactor); // passfactor = prefactor
}

static NSData *derive_key(NSData *passpoint, uint32_t addresshash, uint64_t entropy)
{
    NSMutableData *salt = [NSMutableData secureData];

    [salt appendBytes:&addresshash length:sizeof(addresshash)];
    [salt appendBytes:&entropy length:sizeof(entropy)]; // salt = addresshash + entropy

    return scrypt(passpoint, salt, BIP38_SCRYPT_EC_N, BIP38_SCRYPT_EC_R, BIP38_SCRYPT_EC_P, 64);
}

static NSData *point_multiply(NSData *point, const BIGNUM *factor, BOOL compressed, BN_CTX *ctx)
{
    NSMutableData *d = [NSMutableData secureData];
    EC_GROUP *group = EC_GROUP_new_by_curve_name(NID_secp256k1);
    EC_POINT *r = EC_POINT_new(group), *p;
    point_conversion_form_t form = (compressed) ? POINT_CONVERSION_COMPRESSED : POINT_CONVERSION_UNCOMPRESSED;

    if (point) {
        p = EC_POINT_new(group);
        EC_POINT_oct2point(group, p, point.bytes, point.length, ctx);
        EC_POINT_mul(group, r, NULL, p, factor, ctx); // r = point*factor
        EC_POINT_clear_free(p);
    }
    else EC_POINT_mul(group, r, factor, NULL, NULL, ctx); // r = G*factor

    d.length = EC_POINT_point2oct(group, r, form, NULL, 0, ctx);
    EC_POINT_point2oct(group, r, form, d.mutableBytes, d.length, ctx);
    EC_POINT_clear_free(r);
    EC_GROUP_free(group);
    return d;
}

@implementation BRKey (BIP38)

// decrypts a BIP38 key using the given passphrase or retuns nil if passphrase is incorrect
+ (instancetype)keyWithBIP38Key:(NSString *)key andPassphrase:(NSString *)passphrase
{
    return [[self alloc] initWithBIP38Key:key andPassphrase:passphrase];
}

// generates an "intermediate code" for an EC multiply mode key, salt should be 64bits of random data
+ (NSString *)BIP38IntermediateCodeWithSalt:(uint64_t)salt andPassphrase:(NSString *)passphrase;
{
    if (! passphrase) return nil;
    salt = CFSwapInt64HostToBig(salt);

    BN_CTX *ctx = BN_CTX_new();

    BN_CTX_start(ctx);

    NSMutableData *code = [NSMutableData secureData];
    BIGNUM *passfactor = BN_CTX_get(ctx);

    derive_passfactor(passfactor, 0, salt, passphrase);

    [code appendBytes:"\x2C\xE9\xB3\xE1\xFF\x39\xE2\x53" length:8];
    [code appendBytes:&salt length:sizeof(salt)];
    [code appendData:point_multiply(nil, passfactor, YES, ctx)]; // passpoint = G*passfactor

    BN_CTX_end(ctx);
    BN_CTX_free(ctx);

    return [NSString base58checkWithData:code];
}

// generates an "intermediate code" for an EC multiply mode key with a lot and sequence number, lot must be less than
// 1048576, sequence must be less than 4096, and salt should be 32bits of random data
+ (NSString *)BIP38IntermediateCodeWithLot:(uint32_t)lot sequence:(uint16_t)sequence salt:(uint32_t)salt
passphrase:(NSString *)passphrase
{
    if (lot >= 0x100000 || sequence >= 0x1000 || ! passphrase) return nil;
    salt = CFSwapInt32HostToBig(salt);

    BN_CTX *ctx = BN_CTX_new();

    BN_CTX_start(ctx);

    uint32_t lotsequence = CFSwapInt32HostToBig(lot*0x1000 + sequence);
    NSMutableData *entropy = [NSMutableData secureData], *code = [NSMutableData secureData];
    BIGNUM *passfactor = BN_CTX_get(ctx);

    [entropy appendBytes:&salt length:sizeof(salt)];
    [entropy appendBytes:&lotsequence length:sizeof(lotsequence)];

    derive_passfactor(passfactor, BIP38_LOTSEQUENCE_FLAG, *(const uint64_t *)entropy.bytes, passphrase);

    [code appendBytes:"\x2C\xE9\xB3\xE1\xFF\x39\xE2\x51" length:8];
    [code appendData:entropy];
    [code appendData:point_multiply(nil, passfactor, YES, ctx)]; // passpoint = G*passfactor

    BN_CTX_end(ctx);
    BN_CTX_free(ctx);

    return [NSString base58checkWithData:code];
}

// generates a BIP38 key from an "intermediate code" and 24 bytes of cryptographically random data (seedb),
// compressed indicates if compressed pubKey format should be used for the bitcoin address, confcode (optional) will
// be set to the "confirmation code"
+ (NSString *)BIP38KeyWithIntermediateCode:(NSString *)code seedb:(NSData *)seedb compressed:(BOOL)compressed
confirmationCode:(NSString **)confcode;
{
    NSData *d = code.base58checkToData; // d = 0x2C 0xE9 0xB3 0xE1 0xFF 0x39 0xE2 0x51|0x53 + entropy + passpoint

    if (d.length != 49 || seedb.length != 24) return nil;

    BN_CTX *ctx = BN_CTX_new();

    BN_CTX_start(ctx);

    NSData *passpoint = [NSData dataWithBytesNoCopy:(uint8_t *)d.bytes + 16 length:33 freeWhenDone:NO], *pubKey;
    BIGNUM *factorb = BN_CTX_get(ctx);

    BN_bin2bn(seedb.SHA256_2.bytes, CC_SHA256_DIGEST_LENGTH, factorb); // factorb = SHA256(SHA256(seedb))
    pubKey = point_multiply(passpoint, factorb, compressed, ctx); // pubKey = passpoint*factorb

    uint16_t prefix = CFSwapInt16HostToBig(BIP38_EC_PREFIX);
    uint8_t flag = (compressed) ? BIP38_COMPRESSED_FLAG : 0;
    NSData *address = [[[BRKey keyWithPublicKey:pubKey] address] dataUsingEncoding:NSUTF8StringEncoding];
    uint32_t addresshash = (address) ? *(uint32_t *)address.SHA256_2.bytes : 0;
    uint64_t entropy = *(const uint64_t *)((const uint8_t *)d.bytes + 8);
    NSData *derived = derive_key(passpoint, addresshash, entropy);
    const uint64_t *derived1 = (const uint64_t *)derived.bytes, *derived2 = &derived1[4];
    NSMutableData *key = [NSMutableData secureData], *encrypted1, *encrypted2;
    NSMutableData *x = [NSMutableData secureDataWithLength:16];
    size_t l;

    if (((const uint8_t *)d.bytes)[7] == 0x51) flag |= BIP38_LOTSEQUENCE_FLAG;

    // enctryped1 = AES256Encrypt(seedb[0...15] xor derived1[0...15], derived2)
    ((uint64_t *)x.mutableBytes)[0] = ((const uint64_t *)seedb.bytes)[0] ^ derived1[0];
    ((uint64_t *)x.mutableBytes)[1] = ((const uint64_t *)seedb.bytes)[1] ^ derived1[1];
    encrypted1 = [NSMutableData secureDataWithLength:16];
    CCCrypt(kCCEncrypt, kCCAlgorithmAES, kCCOptionECBMode, derived2, 32, NULL, x.bytes, x.length,
            encrypted1.mutableBytes, encrypted1.length, &l);

    // encrypted2 = AES256Encrypt((encrypted1[8...15] + seedb[16...23]) xor derived1[16...31], derived2)
    ((uint64_t *)x.mutableBytes)[0] = ((const uint64_t *)encrypted1.bytes)[1] ^ derived1[2];
    ((uint64_t *)x.mutableBytes)[1] = ((const uint64_t *)seedb.bytes)[2] ^ derived1[3];
    encrypted2 = [NSMutableData secureDataWithLength:16];
    CCCrypt(kCCEncrypt, kCCAlgorithmAES, kCCOptionECBMode, derived2, 32, NULL, x.bytes, x.length,
            encrypted2.mutableBytes, encrypted2.length, &l);

    [key appendBytes:&prefix length:sizeof(prefix)];
    [key appendBytes:&flag length:sizeof(flag)];
    [key appendBytes:&addresshash length:sizeof(addresshash)];
    [key appendBytes:&entropy length:sizeof(entropy)];
    [key appendBytes:(const uint8_t *)encrypted1.bytes length:8];
    [key appendData:encrypted2];

    if (confcode) {
        NSData *pointb = point_multiply(nil, factorb, YES, ctx); // pointb = G*factorb
        NSMutableData *c = [NSMutableData secureData], *pointbx1, *pointbx2;
        uint8_t pointbprefix = ((const uint8_t *)pointb.bytes)[0] ^ (((const uint8_t *)derived2)[31] & 0x01);

        // pointbx1 = AES256Encrypt(pointb[1...16] xor derived1[0...15], derived2)
        ((uint64_t *)x.mutableBytes)[0] = ((const uint64_t *)((const uint8_t *)pointb.bytes + 1))[0] ^ derived1[0];
        ((uint64_t *)x.mutableBytes)[1] = ((const uint64_t *)((const uint8_t *)pointb.bytes + 1))[1] ^ derived1[1];
        pointbx1 = [NSMutableData secureDataWithLength:16];
        CCCrypt(kCCEncrypt, kCCAlgorithmAES, kCCOptionECBMode, derived2, 32, NULL, x.bytes, x.length,
                pointbx1.mutableBytes, pointbx1.length, &l);

        // pointbx2 = AES256Encrypt(pointb[17...32] xor derived1[16...31], derived2)
        ((uint64_t *)x.mutableBytes)[0] = ((const uint64_t *)((const uint8_t *)pointb.bytes + 1))[2] ^ derived1[2];
        ((uint64_t *)x.mutableBytes)[1] = ((const uint64_t *)((const uint8_t *)pointb.bytes + 1))[3] ^ derived1[3];
        pointbx2 = [NSMutableData secureDataWithLength:16];
        CCCrypt(kCCEncrypt, kCCAlgorithmAES, kCCOptionECBMode, derived2, 32, NULL, x.bytes, x.length,
                pointbx2.mutableBytes, pointbx2.length, &l);

        [c appendBytes:"\x64\x3B\xF6\xA8\x9A" length:5];
        [c appendBytes:&flag length:sizeof(flag)];
        [c appendBytes:&addresshash length:sizeof(addresshash)];
        [c appendBytes:&entropy length:sizeof(entropy)];
        [c appendBytes:&pointbprefix length:sizeof(pointbprefix)];
        [c appendData:pointbx1];
        [c appendData:pointbx2];
        *confcode = [NSString base58checkWithData:c];
    }

    BN_CTX_end(ctx);
    BN_CTX_free(ctx);

    return [NSString base58checkWithData:key];
}

// returns true if the "confirmation code" confirms that the given bitcoin address depends on the specified passphrase
+ (BOOL)confirmWithBIP38ConfirmationCode:(NSString *)code address:(NSString *)address passphrase:(NSString *)passphrase
{
    NSData *d = code.base58checkToData;

    if (d.length != 51 || ! address || ! passphrase) return NO;

    uint8_t flag = ((const uint8_t *)d.bytes)[5];
    uint32_t addresshash = *(const uint32_t *)((const uint8_t *)d.bytes + 6);

    if (*(const uint32_t *)[address dataUsingEncoding:NSUTF8StringEncoding].SHA256_2.bytes != addresshash) return NO;

    BN_CTX *ctx = BN_CTX_new();

    BN_CTX_start(ctx);

    uint64_t entropy = *(const uint64_t *)((const uint8_t *)d.bytes + 10);
    uint8_t pointprefix = ((const uint8_t *)d.bytes)[18];
    const uint8_t *pointbx1 = (const uint8_t *)d.bytes + 19, *pointbx2 = (const uint8_t *)d.bytes + 35;
    BIGNUM *passfactor = BN_CTX_get(ctx);

    derive_passfactor(passfactor, flag, entropy, passphrase);

    NSData *passpoint = point_multiply(nil, passfactor, YES, ctx); // passpoint = G*passfactor
    NSData *derived = derive_key(passpoint, addresshash, entropy), *pubKey;
    const uint64_t *derived1 = (const uint64_t *)derived.bytes, *derived2 = &derived1[4];
    NSMutableData *pointb = [NSMutableData secureDataWithLength:33];
    size_t l;

    ((uint8_t *)pointb.mutableBytes)[0] = pointprefix ^ (((const uint8_t *)derived2)[31] & 0x01);

    CCCrypt(kCCDecrypt, kCCAlgorithmAES, kCCOptionECBMode, derived2, 32, NULL, pointbx1, 16,
            (uint8_t *)pointb.mutableBytes + 1, 16, &l); // pointb[1...16] xor derived1[0...15]
    ((uint64_t *)((uint8_t *)pointb.mutableBytes + 1))[0] ^= derived1[0];
    ((uint64_t *)((uint8_t *)pointb.mutableBytes + 1))[1] ^= derived1[1];
    
    CCCrypt(kCCDecrypt, kCCAlgorithmAES, kCCOptionECBMode, derived2, 32, NULL, pointbx2, 16,
            (uint8_t *)pointb.mutableBytes + 17, 16, &l); // pointb[17...32] xor derived1[16...31]
    ((uint64_t *)((uint8_t *)pointb.mutableBytes + 1))[2] ^= derived1[2];
    ((uint64_t *)((uint8_t *)pointb.mutableBytes + 1))[3] ^= derived1[3];

    pubKey = point_multiply(pointb, passfactor, flag & BIP38_COMPRESSED_FLAG, ctx); // pubKey = pointb*passfactor
    BN_CTX_end(ctx);
    BN_CTX_free(ctx);

    return ([[[BRKey keyWithPublicKey:pubKey] address] isEqual:address]) ? YES : NO;
}

- (instancetype)initWithBIP38Key:(NSString *)key andPassphrase:(NSString *)passphrase
{
    NSData *d = key.base58checkToData;

    if (d.length != 39 || ! passphrase) return nil;

    uint16_t prefix = CFSwapInt16BigToHost(*(const uint16_t *)d.bytes);
    uint8_t flag = ((const uint8_t *)d.bytes)[2];
    uint32_t addresshash = *(const uint32_t *)((const uint8_t *)d.bytes + 3);
    NSMutableData *secret = [NSMutableData secureDataWithLength:32];
    size_t l;

    if (prefix == BIP38_NOEC_PREFIX) { // non EC multiplied key
        // d = prefix + flag + addresshash + encrypted1 + encrypted2
        NSData *password = normalize_passphrase(passphrase);
        NSData *salt = [NSData dataWithBytesNoCopy:&addresshash length:sizeof(addresshash) freeWhenDone:NO];
        const uint8_t *encrypted1 = (const uint8_t *)d.bytes + 7, *encrypted2 = (const uint8_t *)d.bytes + 23;
        NSData *derived = scrypt(password, salt, BIP38_SCRYPT_N, BIP38_SCRYPT_R, BIP38_SCRYPT_P, 64);
        const uint64_t *derived1 = (const uint64_t *)derived.bytes, *derived2 = &((const uint64_t *)derived.bytes)[4];

        CCCrypt(kCCDecrypt, kCCAlgorithmAES, kCCOptionECBMode, derived2, 32, NULL, encrypted1, 16,
                secret.mutableBytes, 16, &l);
        CCCrypt(kCCDecrypt, kCCAlgorithmAES, kCCOptionECBMode, derived2, 32, NULL, encrypted2, 16,
                (uint8_t *)secret.mutableBytes + 16, 16, &l);

        for (size_t i = 0; i < secret.length/sizeof(uint64_t); i++) {
            ((uint64_t *)secret.mutableBytes)[i] ^= derived1[i];
        }
    }
    else if (prefix == BIP38_EC_PREFIX) { // EC multipled key
        BN_CTX *ctx = BN_CTX_new();

        BN_CTX_start(ctx);

        // d = prefix + flag + addresshash + entropy + encrypted1[0...7] + encrypted2
        uint64_t entropy = *(const uint64_t *)((const uint8_t *)d.bytes + 7);
        NSMutableData *encrypted1 = [NSMutableData secureData];
        const uint8_t *encrypted2 = (const uint8_t *)d.bytes + 23;
        BIGNUM *passfactor = BN_CTX_get(ctx), *factorb = BN_CTX_get(ctx), *priv = BN_CTX_get(ctx),
               *order = BN_CTX_get(ctx);

        derive_passfactor(passfactor, flag, entropy, passphrase);

        NSData *passpoint = point_multiply(nil, passfactor, YES, ctx); // passpoint = G*passfactor
        NSData *derived = derive_key(passpoint, addresshash, entropy);
        const uint64_t *derived1 = (const uint64_t *)derived.bytes, *derived2 = &derived1[4];
        NSMutableData *seedb = [NSMutableData secureDataWithLength:24], *o = [NSMutableData secureDataWithLength:16];
        EC_GROUP *group = EC_GROUP_new_by_curve_name(NID_secp256k1);

        [encrypted1 appendBytes:(const uint8_t *)d.bytes + 15 length:8];
        encrypted1.length = 16;
        
        CCCrypt(kCCDecrypt, kCCAlgorithmAES, kCCOptionECBMode, derived2, 32, NULL, encrypted2, 16,
                o.mutableBytes, o.length, &l); // o = (encrypted1[8...15] + seedb[16...23]) xor derived1[16...31]
        ((uint64_t *)encrypted1.mutableBytes)[1] = ((const uint64_t *)o.bytes)[0] ^ derived1[2];
        ((uint64_t *)seedb.mutableBytes)[2] = ((const uint64_t *)o.bytes)[1] ^ derived1[3];

        CCCrypt(kCCDecrypt, kCCAlgorithmAES, kCCOptionECBMode, derived2, 32, NULL, encrypted1.bytes, encrypted1.length,
                o.mutableBytes, o.length, &l); // o = seedb[0...15] xor derived1[0...15]
        ((uint64_t *)seedb.mutableBytes)[0] = ((const uint64_t *)o.bytes)[0] ^ derived1[0];
        ((uint64_t *)seedb.mutableBytes)[1] = ((const uint64_t *)o.bytes)[1] ^ derived1[1];

        EC_GROUP_get_order(group, order, ctx);
        BN_bin2bn(seedb.SHA256_2.bytes, CC_SHA256_DIGEST_LENGTH, factorb); // factorb = SHA256(SHA256(seedb))
        BN_mod_mul(priv, passfactor, factorb, order, ctx); // secret = passfactor*factorb mod N
        BN_bn2bin(priv, (unsigned char *)secret.mutableBytes + secret.length - BN_num_bytes(priv));

        EC_GROUP_free(group);
        BN_CTX_end(ctx);
        BN_CTX_free(ctx);
    }

    if (! (self = [self initWithSecret:secret compressed:flag & BIP38_COMPRESSED_FLAG])) return nil;

    NSData *address = [self.address dataUsingEncoding:NSUTF8StringEncoding];

    if (! address || *(const uint32_t *)address.SHA256_2.bytes != addresshash) {
        NSLog(@"BIP38 bad passphrase");
        return nil;
    }

    return self;
}

// encrypts receiver with passphrase and returns BIP38 key
- (NSString *)BIP38KeyWithPassphrase:(NSString *)passphrase
{
    NSData *priv = self.privateKey.base58checkToData;

    if (priv.length < 33 || ! passphrase) return nil;

    uint16_t prefix = CFSwapInt16HostToBig(BIP38_NOEC_PREFIX);
    uint8_t flag = BIP38_NOEC_FLAG;
    NSData *password = normalize_passphrase(passphrase);
    NSData *address = [self.address dataUsingEncoding:NSUTF8StringEncoding];
    NSData *salt = [address.SHA256_2 subdataWithRange:NSMakeRange(0, 4)];
    NSData *derived = scrypt(password, salt, BIP38_SCRYPT_N, BIP38_SCRYPT_R, BIP38_SCRYPT_P, 64);
    const uint64_t *derived1 = (const uint64_t *)derived.bytes, *derived2 = &derived1[4];
    NSMutableData *secret = [NSMutableData secureDataWithLength:32], *encrypted1, *encrypted2, *key;
    size_t l;

    if (priv.length > 33) flag |= BIP38_COMPRESSED_FLAG;

    for (size_t i = 0; i < secret.length/sizeof(uint64_t); i++) {
        ((uint64_t *)secret.mutableBytes)[i] = ((const uint64_t *)((const uint8_t *)priv.bytes + 1))[i] ^ derived1[i];
    }

    // enctryped1 = AES256Encrypt(privkey[0...15] xor derived1[0...15], derived2)
    encrypted1 = [NSMutableData secureDataWithLength:16];
    CCCrypt(kCCEncrypt, kCCAlgorithmAES, kCCOptionECBMode, derived2, 32, NULL, secret.bytes, 16,
            encrypted1.mutableBytes, encrypted1.length, &l);

    // encrypted2 = AES256Encrypt(privkey[16...31] xor derived1[16...31], derived2)
    encrypted2 = [NSMutableData secureDataWithLength:16];
    CCCrypt(kCCEncrypt, kCCAlgorithmAES, kCCOptionECBMode, derived2, 32, NULL, (const uint8_t *)secret.bytes + 16, 16,
            encrypted2.mutableBytes, encrypted2.length, &l);

    key = [NSMutableData secureData];
    [key appendBytes:&prefix length:sizeof(prefix)];
    [key appendBytes:&flag length:sizeof(flag)];
    [key appendData:salt];
    [key appendData:encrypted1];
    [key appendData:encrypted2];

    return [NSString base58checkWithData:key];
}

@end
