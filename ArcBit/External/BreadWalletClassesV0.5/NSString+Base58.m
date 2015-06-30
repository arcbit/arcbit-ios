//
//  NSString+Base58.mm
//  BreadWallet
//
//  Created by Aaron Voisine on 5/13/13.
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

#import "NSString+Base58.h"
#import "NSData+Hash.h"
#import "NSData+Bitcoin.h"
#import "NSMutableData+Bitcoin.h"
#import "ccMemory.h"
#import <openssl/bn.h>

static const char base58chars[] = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";

static void *secureAllocate(CFIndex allocSize, CFOptionFlags hint, void *info)
{
    void *ptr = CC_XMALLOC(sizeof(CFIndex) + allocSize);
    
    if (ptr) { // we need to keep track of the size of the allocation so it can be cleansed before deallocation
        *(CFIndex *)ptr = allocSize;
        return (CFIndex *)ptr + 1;
    }
    else return NULL;
}

static void secureDeallocate(void *ptr, void *info)
{
    CFIndex size = *((CFIndex *)ptr - 1);

    if (size) {
        CC_XZEROMEM(ptr, size);
        CC_XFREE((CFIndex *)ptr - 1, sizeof(CFIndex) + size);
    }
}

static void *secureReallocate(void *ptr, CFIndex newsize, CFOptionFlags hint, void *info)
{
    // There's no way to tell ahead of time if the original memory will be deallocted even if the new size is smaller
    // than the old size, so just cleanse and deallocate every time.
    void *newptr = secureAllocate(newsize, hint, info);
    CFIndex size = *((CFIndex *)ptr - 1);

    if (newptr && size) {
        CC_XMEMCPY(newptr, ptr, (size < newsize) ? size : newsize);
        secureDeallocate(ptr, info);
    }

    return newptr;
}

// Since iOS does not page memory to storage, all we need to do is cleanse allocated memory prior to deallocation.
CFAllocatorRef SecureAllocator()
{
    static CFAllocatorRef alloc = NULL;
    static dispatch_once_t onceToken = 0;
    
    dispatch_once(&onceToken, ^{
        CFAllocatorContext context;
        
        context.version = 0;
        CFAllocatorGetContext(kCFAllocatorDefault, &context);
        context.allocate = secureAllocate;
        context.reallocate = secureReallocate;
        context.deallocate = secureDeallocate;
        
        alloc = CFAllocatorCreate(kCFAllocatorDefault, &context);
    });
    
    return alloc;
}

@implementation NSString (Base58)

+ (NSString *)base58WithData:(NSData *)d
{
    BN_CTX *ctx = BN_CTX_new();

    BN_CTX_start(ctx);

    NSUInteger i = d.length*138/100 + 2;
    char s[i];
    BIGNUM *base = BN_CTX_get(ctx), *x = BN_CTX_get(ctx), *r = BN_CTX_get(ctx);

    BN_set_word(base, 58);
    BN_bin2bn(d.bytes, (int)d.length, x);
    s[--i] = '\0';

    while (! BN_is_zero(x)) {
        BN_div(x, r, x, base, ctx);
        s[--i] = base58chars[BN_get_word(r)];
    }
    
    for (NSUInteger j = 0; j < d.length && *((const uint8_t *)d.bytes + j) == 0; j++) {
        s[--i] = base58chars[0];
    }

    BN_CTX_end(ctx);
    BN_CTX_free(ctx);
    
    NSString *ret = CFBridgingRelease(CFStringCreateWithCString(SecureAllocator(), &s[i], kCFStringEncodingUTF8));
    
    CC_XZEROMEM(&s[0], d.length*138/100 + 2);
    return ret;
}

+ (NSString *)base58checkWithData:(NSData *)d
{
    NSMutableData *data = [NSMutableData secureDataWithData:d];

    [data appendBytes:d.SHA256_2.bytes length:4];
    
    return [self base58WithData:data];
}

- (NSData *)base58ToData
{
    BN_CTX *ctx = BN_CTX_new();

    BN_CTX_start(ctx);

    NSMutableData *d = [NSMutableData secureDataWithCapacity:self.length + 1];
    unsigned int b;
    BIGNUM *base = BN_CTX_get(ctx), *x = BN_CTX_get(ctx), *y = BN_CTX_get(ctx);

    BN_set_word(base, 58);
    BN_zero(x);
    
    for (NSUInteger i = 0; i < self.length && [self characterAtIndex:i] == base58chars[0]; i++) {
        [d appendBytes:"\0" length:1];
    }
        
    for (NSUInteger i = 0; i < self.length; i++) {
        b = [self characterAtIndex:i];

        switch (b) {
            case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9':
                b -= '1';
                break;
            case 'A': case 'B': case 'C': case 'D': case 'E': case 'F': case 'G': case 'H':
                b += 9 - 'A';
                break;
            case 'J': case 'K': case 'L': case 'M': case 'N':
                b += 17 - 'J';
                break;
            case 'P': case 'Q': case 'R': case 'S': case 'T': case 'U': case 'V': case 'W': case 'X': case 'Y':
            case 'Z':
                b += 22 - 'P';
                break;
            case 'a': case 'b': case 'c': case 'd': case 'e': case 'f': case 'g': case 'h': case 'i': case 'j':
            case 'k':
                b += 33 - 'a';
                break;
            case 'm': case 'n': case 'o': case 'p': case 'q': case 'r': case 's': case 't': case 'u': case 'v':
            case 'w': case 'x': case 'y': case 'z':
                b += 44 - 'm';
                break;
            case ' ':
                continue;
            default:
                goto breakout;
        }
        
        BN_mul(x, x, base, ctx);
        BN_set_word(y, b);
        BN_add(x, x, y);
    }
    
breakout:
    d.length += BN_num_bytes(x);
    BN_bn2bin(x, (unsigned char *)d.mutableBytes + d.length - BN_num_bytes(x));

    CC_XZEROMEM(&b, sizeof(b));
    BN_CTX_end(ctx);
    BN_CTX_free(ctx);
    
    return d;
}

+ (NSString *)hexWithData:(NSData *)d
{
    const uint8_t *bytes = d.bytes;
    NSMutableString *hex = CFBridgingRelease(CFStringCreateMutable(SecureAllocator(), d.length*2));
    
    for (NSUInteger i = 0; i < d.length; i++) {
        [hex appendFormat:@"%02x", bytes[i]];
    }
    
    return hex;
}

// NOTE: It's important here to be permissive with scriptSig (spends) and strict with scriptPubKey (receives). If we
// miss a receive transaction, only that transaction's funds are missed, however if we accept a receive transaction that
// we are unable to correctly sign later, then the entire wallet balance after that point would become stuck with the
// current coin selection code
+ (NSString *)addressWithScriptPubKey:(NSData *)script
{
    if (script == (id)[NSNull null]) return nil;

    NSArray *elem = [script scriptElements];
    NSUInteger l = elem.count;
    NSMutableData *d = [NSMutableData data];
    uint8_t v = BITCOIN_PUBKEY_ADDRESS;

#if BITCOIN_TESTNET
    v = BITCOIN_PUBKEY_ADDRESS_TEST;
#endif

    if (l == 5 && [elem[0] intValue] == OP_DUP && [elem[1] intValue] == OP_HASH160 && [elem[2] intValue] == 20 &&
        [elem[3] intValue] == OP_EQUALVERIFY && [elem[4] intValue] == OP_CHECKSIG) {
        // pay-to-pubkey-hash scriptPubKey
        [d appendBytes:&v length:1];
        [d appendData:elem[2]];
    }
    else if (l == 3 && [elem[0] intValue] == OP_HASH160 && [elem[1] intValue] == 20 && [elem[2] intValue] == OP_EQUAL) {
        // pay-to-script-hash scriptPubKey
        v = BITCOIN_SCRIPT_ADDRESS;
#if BITCOIN_TESTNET
        v = BITCOIN_SCRIPT_ADDRESS_TEST;
#endif
        [d appendBytes:&v length:1];
        [d appendData:elem[1]];
    }
    else if (l == 2 && ([elem[0] intValue] == 65 || [elem[0] intValue] == 33) && [elem[1] intValue] == OP_CHECKSIG) {
        // pay-to-pubkey scriptPubKey
        [d appendBytes:&v length:1];
        [d appendData:[elem[0] hash160]];
    }
    else return nil; // unknown script type

    return [self base58checkWithData:d];
}

+ (NSString *)addressWithScriptSig:(NSData *)script
{
    if (script == (id)[NSNull null]) return nil;

    NSArray *elem = [script scriptElements];
    NSUInteger l = elem.count;
    NSMutableData *d = [NSMutableData data];
    uint8_t v = BITCOIN_PUBKEY_ADDRESS;

#if BITCOIN_TESTNET
    v = BITCOIN_PUBKEY_ADDRESS_TEST;
#endif

    if (l >= 2 && [elem[l - 2] intValue] <= OP_PUSHDATA4 && [elem[l - 2] intValue] > 0 &&
        ([elem[l - 1] intValue] == 65 || [elem[l - 1] intValue] == 33)) { // pay-to-pubkey-hash scriptSig
        [d appendBytes:&v length:1];
        [d appendData:[elem[l - 1] hash160]];
    }
    else if (l >= 2 && [elem[l - 2] intValue] <= OP_PUSHDATA4 && [elem[l - 2] intValue] > 0 &&
             [elem[l - 1] intValue] <= OP_PUSHDATA4 && [elem[l - 1] intValue] > 0) { // pay-to-script-hash scriptSig
        v = BITCOIN_SCRIPT_ADDRESS;
#if BITCOIN_TESTNET
        v = BITCOIN_SCRIPT_ADDRESS_TEST;
#endif
        [d appendBytes:&v length:1];
        [d appendData:[elem[l - 1] hash160]];
    }
    else if (l >= 1 && [elem[l - 1] intValue] <= OP_PUSHDATA4 && [elem[l - 1] intValue] > 0) {// pay-to-pubkey scriptSig
        //TODO: implement Peter Wullie's pubKey recovery from signature
        return nil;
    }
    else return nil; // unknown script type
    
    return [self base58checkWithData:d];
}

- (NSString *)hexToBase58
{
    return [[self class] base58WithData:self.hexToData];
}

- (NSString *)base58ToHex
{
    return [NSString hexWithData:self.base58ToData];
}

- (NSData *)base58checkToData
{
    NSData *d = self.base58ToData;
    
    if (d.length < 4) return nil;

    NSData *data = CFBridgingRelease(CFDataCreate(SecureAllocator(), d.bytes, d.length - 4));

    // verify checksum
    if (*(uint32_t *)((const uint8_t *)d.bytes + d.length - 4) != *(uint32_t *)data.SHA256_2.bytes) return nil;
    
    return data;
}

- (NSString *)hexToBase58check
{
    return [NSString base58checkWithData:self.hexToData];
}

- (NSString *)base58checkToHex
{
    return [NSString hexWithData:self.base58checkToData];
}

- (NSData *)hexToData
{
    if (self.length % 2) return nil;
    
    NSMutableData *d = [NSMutableData secureDataWithCapacity:self.length/2];
    uint8_t b = 0;
    
    for (NSUInteger i = 0; i < self.length; i++) {
        unichar c = [self characterAtIndex:i];
        
        switch (c) {
            case '0': case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9':
                b += c - '0';
                break;
            case 'A': case 'B': case 'C': case 'D': case 'E': case 'F':
                b += c + 10 - 'A';
                break;
            case 'a': case 'b': case 'c': case 'd': case 'e': case 'f':
                b += c + 10 - 'a';
                break;
            default:
                return d;
        }
        
        if (i % 2) {
            [d appendBytes:&b length:1];
            b = 0;
        }
        else b *= 16;
    }
    
    return d;
}

- (NSData *)addressToHash160
{
    NSData *d = self.base58checkToData;

    return (d.length == 160/8 + 1) ? [d subdataWithRange:NSMakeRange(1, d.length - 1)] : nil;
}

- (BOOL)isValidBitcoinAddress
{
    NSData *d = self.base58checkToData;
    
    if (d.length != 21) return NO;
    
    uint8_t version = *(const uint8_t *)d.bytes;
        
#if BITCOIN_TESTNET
    return (version == BITCOIN_PUBKEY_ADDRESS_TEST || version == BITCOIN_SCRIPT_ADDRESS_TEST) ? YES : NO;
#endif

    return (version == BITCOIN_PUBKEY_ADDRESS || version == BITCOIN_SCRIPT_ADDRESS) ? YES : NO;
}

- (BOOL)isValidBitcoinPrivateKey
{
    NSData *d = self.base58checkToData;
    
    if (d.length == 33 || d.length == 34) { // wallet import format: https://en.bitcoin.it/wiki/Wallet_import_format
#if BITCOIN_TESNET
        return (*(const uint8_t *)d.bytes == BITCOIN_PRIVKEY_TEST) ? YES : NO;
#else
        return (*(const uint8_t *)d.bytes == BITCOIN_PRIVKEY) ? YES : NO;
#endif
    }
    else if ((self.length == 30 || self.length == 22) && [self characterAtIndex:0] == 'S') { // mini private key format
        NSMutableData *d = [NSMutableData secureDataWithCapacity:self.length + 1];

        d.length = self.length;
        [self getBytes:d.mutableBytes maxLength:d.length usedLength:NULL encoding:NSUTF8StringEncoding options:0
         range:NSMakeRange(0, self.length) remainingRange:NULL];
        [d appendBytes:"?" length:1];
        return (*(const uint8_t *)d.SHA256.bytes == 0) ? YES : NO;
    }
    else return (self.hexToData.length == 32) ? YES : NO; // hex encoded key
}

// BIP38 encrypted keys: https://github.com/bitcoin/bips/blob/master/bip-0038.mediawiki
- (BOOL)isValidBitcoinBIP38Key
{
    NSData *d = self.base58checkToData;

    if (d.length != 39) return NO; // invalid length

    uint16_t prefix = CFSwapInt16BigToHost(*(const uint16_t *)d.bytes);
    uint8_t flag = ((const uint8_t *)d.bytes)[2];

    if (prefix == BIP38_NOEC_PREFIX) { // non EC multiplied key
        return ((flag & BIP38_NOEC_FLAG) == BIP38_NOEC_FLAG && (flag & BIP38_LOTSEQUENCE_FLAG) == 0 &&
                (flag & BIP38_INVALID_FLAG) == 0) ? YES : NO;
    }
    else if (prefix == BIP38_EC_PREFIX) { // EC multiplied key
        return ((flag & BIP38_NOEC_FLAG) == 0 && (flag & BIP38_INVALID_FLAG) == 0) ? YES : NO;
    }
    else return NO; // invalid prefix
}

@end
