//
//  BRKey.m
//  BreadWallet
//
//  Created by Aaron Voisine on 5/22/13.
//  Copyright (c) 2013 Aaron Voisine <voisine@gmail.com>
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

#import "BRKey.h"
#import "NSString+Base58.h"
#import "NSData+Hash.h"
#import "NSMutableData+Bitcoin.h"
#import <CommonCrypto/CommonHMAC.h>
#import <openssl/ecdsa.h>
#import <openssl/obj_mac.h>

// HMAC-SHA256 DRBG, using no prediction resistance or personalization string and outputing 256bits
static NSData *hmac_drbg(NSData *entropy, NSData *nonce)
{
    NSMutableData *V = [NSMutableData
                        secureDataWithCapacity:CC_SHA256_DIGEST_LENGTH + 1 + entropy.length + nonce.length],
                  *K = [NSMutableData secureDataWithCapacity:CC_SHA256_DIGEST_LENGTH],
                  *T = [NSMutableData secureDataWithLength:CC_SHA256_DIGEST_LENGTH];

    V.length = CC_SHA256_DIGEST_LENGTH;
    memset(V.mutableBytes, 0x01, V.length); // V = 0x01 0x01 0x01 ... 0x01
    K.length = CC_SHA256_DIGEST_LENGTH;     // K = 0x00 0x00 0x00 ... 0x00
    [V appendBytes:"\0" length:1];
    [V appendBytes:entropy.bytes length:entropy.length];
    [V appendBytes:nonce.bytes length:nonce.length];
    CCHmac(kCCHmacAlgSHA256, K.bytes, K.length, V.bytes, V.length, K.mutableBytes); // K = HMAC_K(V || 0x00 || seed)
    V.length = CC_SHA256_DIGEST_LENGTH;
    CCHmac(kCCHmacAlgSHA256, K.bytes, K.length, V.bytes, V.length, V.mutableBytes); // V = HMAC_K(V)
    [V appendBytes:"\x01" length:1];
    [V appendBytes:entropy.bytes length:entropy.length];
    [V appendBytes:nonce.bytes length:nonce.length];
    CCHmac(kCCHmacAlgSHA256, K.bytes, K.length, V.bytes, V.length, K.mutableBytes); // K = HMAC_K(V || 0x01 || seed)
    V.length = CC_SHA256_DIGEST_LENGTH;
    CCHmac(kCCHmacAlgSHA256, K.bytes, K.length, V.bytes, V.length, V.mutableBytes); // V = HMAC_K(V)
    CCHmac(kCCHmacAlgSHA256, K.bytes, K.length, V.bytes, V.length, T.mutableBytes); // T = HMAC_K(V)
    return T;
}

@interface BRKey ()

@property (nonatomic, assign) EC_KEY *key;

@end

@implementation BRKey

+ (instancetype)keyWithPrivateKey:(NSString *)privateKey
{
    return [[self alloc] initWithPrivateKey:privateKey];
}

+ (instancetype)keyWithSecret:(NSData *)secret compressed:(BOOL)compressed
{
    return [[self alloc] initWithSecret:secret compressed:compressed];
}

+ (instancetype)keyWithPublicKey:(NSData *)publicKey
{
    return [[self alloc] initWithPublicKey:publicKey];
}

- (instancetype)init
{
    if (! (self = [super init])) return nil;
    
    _key = EC_KEY_new_by_curve_name(NID_secp256k1);
    
    return _key ? self : nil;
}

- (void)dealloc
{
    if (_key) EC_KEY_free(_key);
}

- (instancetype)initWithSecret:(NSData *)secret compressed:(BOOL)compressed
{
    if (secret.length != 32) return nil;

    if (! (self = [self init])) return nil;

    [self setSecret:secret compressed:compressed];
    
    return (EC_KEY_check_key(_key)) ? self : nil;
}

- (instancetype)initWithPrivateKey:(NSString *)privateKey
{
    if (! (self = [self init])) return nil;
    
    self.privateKey = privateKey;
    
    return (EC_KEY_check_key(_key)) ? self : nil;
}

- (instancetype)initWithPublicKey:(NSData *)publicKey
{
    if (! (self = [self init])) return nil;
    
    self.publicKey = publicKey;
    
    return (EC_KEY_check_key(_key)) ? self : nil;
}

- (void)setSecret:(NSData *)secret compressed:(BOOL)compressed
{
    if (secret.length != 32 || ! _key) return;
    
    BN_CTX *ctx = BN_CTX_new();

    if (! ctx) return;
    BN_CTX_start(ctx);

    BIGNUM *priv = BN_CTX_get(ctx);
    const EC_GROUP *group = EC_KEY_get0_group(_key);
    EC_POINT *pub = EC_POINT_new(group);

    if (pub) {
        BN_bin2bn(secret.bytes, 32, priv);
        
        if (EC_POINT_mul(group, pub, priv, NULL, NULL, ctx)) {
            EC_KEY_set_private_key(_key, priv);
            EC_KEY_set_public_key(_key, pub);
            EC_KEY_set_conv_form(_key, compressed ? POINT_CONVERSION_COMPRESSED : POINT_CONVERSION_UNCOMPRESSED);
        }

        EC_POINT_free(pub);
    }

    BN_CTX_end(ctx);
    BN_CTX_free(ctx);
}

- (void)setPrivateKey:(NSString *)privateKey
{
    // mini private key format
    if ((privateKey.length == 30 || privateKey.length == 22) && [privateKey characterAtIndex:0] == 'S') {
        if (! [privateKey isValidBitcoinPrivateKey]) return;
        
        [self setSecret:[CFBridgingRelease(CFStringCreateExternalRepresentation(SecureAllocator(),
                         (CFStringRef)privateKey, kCFStringEncodingUTF8, 0)) SHA256] compressed:NO];
        return;
    }

    NSData *d = privateKey.base58checkToData;
    uint8_t version = BITCOIN_PRIVKEY;

#if BITCOIN_TESTNET
    version = BITCOIN_PRIVKEY_TEST;
#endif

    if (! d || d.length == 28) d = privateKey.base58ToData;
    if (d.length < 32 || d.length > 34) d = privateKey.hexToData;

    if ((d.length == 33 || d.length == 34) && *(const unsigned char *)d.bytes == version) {
        [self setSecret:[NSData dataWithBytesNoCopy:(unsigned char *)d.bytes + 1 length:32 freeWhenDone:NO]
         compressed:(d.length == 34) ? YES : NO];
    }
    else if (d.length == 32) [self setSecret:d compressed:NO];
}

- (NSString *)privateKey
{
    if (! EC_KEY_check_key(_key)) return nil;
    
    const BIGNUM *priv = EC_KEY_get0_private_key(_key);
    NSMutableData *d = [NSMutableData secureDataWithCapacity:34];
    uint8_t version = BITCOIN_PRIVKEY;

#if BITCOIN_TESTNET
    version = BITCOIN_PRIVKEY_TEST;
#endif

    [d appendBytes:&version length:1];
    d.length = 33;
    BN_bn2bin(priv, (unsigned char *)d.mutableBytes + d.length - BN_num_bytes(priv));
    if (EC_KEY_get_conv_form(_key) == POINT_CONVERSION_COMPRESSED) [d appendBytes:"\x01" length:1];

    return [NSString base58checkWithData:d];
}

- (void)setPublicKey:(NSData *)publicKey
{
    const unsigned char *bytes = publicKey.bytes;

    o2i_ECPublicKey(&_key, &bytes, publicKey.length);
}

- (NSData *)publicKey
{
    if (! EC_KEY_check_key(_key)) return nil;

    size_t l = i2o_ECPublicKey(_key, NULL);
    NSMutableData *pubKey = [NSMutableData secureDataWithLength:l];
    unsigned char *bytes = pubKey.mutableBytes;
    
    if (i2o_ECPublicKey(_key, &bytes) != l) return nil;
    
    return pubKey;
}

- (NSData *)hash160
{
    return [[self publicKey] hash160];
}

- (NSString *)address
{
    NSData *hash = [self hash160];
    
    if (! hash.length) return nil;

    NSMutableData *d = [NSMutableData secureDataWithCapacity:hash.length + 1];
    uint8_t version = BITCOIN_PUBKEY_ADDRESS;

#if BITCOIN_TESTNET
    version = BITCOIN_PUBKEY_ADDRESS_TEST;
#endif
    
    [d appendBytes:&version length:1];
    [d appendData:hash];

    return [NSString base58checkWithData:d];
}

- (NSData *)sign:(NSData *)d
{
    if (d.length != CC_SHA256_DIGEST_LENGTH) {
        NSLog(@"%s:%d: %s: Only 256 bit hashes can be signed", __FILE__, __LINE__,  __func__);
        return nil;
    }

    BN_CTX *ctx = BN_CTX_new();

    BN_CTX_start(ctx);

    BIGNUM *order = BN_CTX_get(ctx), *halforder = BN_CTX_get(ctx), *k = BN_CTX_get(ctx), *r = BN_CTX_get(ctx);
    const BIGNUM *priv = EC_KEY_get0_private_key(_key);
    const EC_GROUP *group = EC_KEY_get0_group(_key);
    EC_POINT *p = EC_POINT_new(group);
    NSMutableData *sig = nil, *entropy = [NSMutableData secureDataWithLength:32];
    unsigned char *b;

    EC_GROUP_get_order(group, order, ctx);
    BN_rshift1(halforder, order);

    // generate k deterministicly per RFC6979: https://tools.ietf.org/html/rfc6979
    BN_bn2bin(priv, (unsigned char *)entropy.mutableBytes + entropy.length - BN_num_bytes(priv));
    BN_bin2bn(hmac_drbg(entropy, d).bytes, CC_SHA256_DIGEST_LENGTH, k);

    EC_POINT_mul(group, p, k, NULL, NULL, ctx); // compute r, the x-coordinate of generator*k
    EC_POINT_get_affine_coordinates_GFp(group, p, r, NULL, ctx);
    EC_POINT_clear_free(p);
    
    BN_mod_inverse(k, k, order, ctx); // compute the inverse of k

    ECDSA_SIG *s = ECDSA_do_sign_ex(d.bytes, (int)d.length, k, r, _key);

    if (s) {
        // enforce low s values, negate the value (modulo the order) if above order/2.
        if (BN_cmp(s->s, halforder) > 0) BN_sub(s->s, order, s->s);

        sig = [NSMutableData dataWithLength:ECDSA_size(_key)];
        b = sig.mutableBytes;
        sig.length = i2d_ECDSA_SIG(s, &b);
        ECDSA_SIG_free(s);
    }

    BN_CTX_end(ctx);
    BN_CTX_free(ctx);

    return sig;
}

- (BOOL)verify:(NSData *)d signature:(NSData *)sig
{
    // -1 = error, 0 = bad sig, 1 = good
    return (ECDSA_verify(0, d.bytes, (int)d.length, sig.bytes, (int)sig.length, _key) == 1) ? YES : NO;
}

@end
