//
//  NSData+Bitcoin.m
//  BreadWallet
//
//  Created by Aaron Voisine on 10/9/13.
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

#import "NSData+Bitcoin.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSData (Bitcoin)

- (uint8_t)UInt8AtOffset:(NSUInteger)offset
{
    if (self.length < offset + sizeof(uint8_t)) return 0;
    return *((const uint8_t *)self.bytes + offset);
}

- (uint16_t)UInt16AtOffset:(NSUInteger)offset
{
    if (self.length < offset + sizeof(uint16_t)) return 0;
    return CFSwapInt16LittleToHost(*(const uint16_t *)((const uint8_t *)self.bytes + offset));
}

- (uint32_t)UInt32AtOffset:(NSUInteger)offset
{
    if (self.length < offset + sizeof(uint32_t)) return 0;
    return CFSwapInt32LittleToHost(*(const uint32_t *)((const uint8_t *)self.bytes + offset));
}

- (uint64_t)UInt64AtOffset:(NSUInteger)offset
{
    if (self.length < offset + sizeof(uint64_t)) return 0;
    return CFSwapInt64LittleToHost(*(const uint64_t *)((const uint8_t *)self.bytes + offset));
}

- (uint64_t)varIntAtOffset:(NSUInteger)offset length:(NSUInteger *)length
{
    uint8_t h = [self UInt8AtOffset:offset];

    switch (h) {
        case VAR_INT16_HEADER:
            if (length) *length = sizeof(h) + sizeof(uint16_t);
            return [self UInt16AtOffset:offset + 1];
            
        case VAR_INT32_HEADER:
            if (length) *length = sizeof(h) + sizeof(uint32_t);
            return [self UInt32AtOffset:offset + 1];
            
        case VAR_INT64_HEADER:
            if (length) *length = sizeof(h) + sizeof(uint64_t);
            return [self UInt64AtOffset:offset + 1];
            
        default:
            if (length) *length = sizeof(h);
            return h;
    }
}

- (NSData *)hashAtOffset:(NSUInteger)offset
{
    if (self.length < offset + CC_SHA256_DIGEST_LENGTH) return nil;
    return [self subdataWithRange:NSMakeRange(offset, CC_SHA256_DIGEST_LENGTH)];
}

- (NSString *)stringAtOffset:(NSUInteger)offset length:(NSUInteger *)length
{
    NSUInteger ll, l = (NSUInteger)[self varIntAtOffset:offset length:&ll];
    
    if (length) *length = ll + l;
    if (ll == 0 || self.length < offset + ll + l) return nil;
    return [[NSString alloc] initWithBytes:(const char *)self.bytes + offset + ll length:l
            encoding:NSUTF8StringEncoding];
}

- (NSData *)dataAtOffset:(NSUInteger)offset length:(NSUInteger *)length
{
    NSUInteger ll, l = (NSUInteger)[self varIntAtOffset:offset length:&ll];
    
    if (length) *length = ll + l;
    if (ll == 0 || self.length < offset + ll + l) return nil;
    return [self subdataWithRange:NSMakeRange(offset + ll, l)];
}

// an array of NSNumber and NSData objects representing each script element
- (NSArray *)scriptElements
{
    NSMutableArray *a = [NSMutableArray array];
    const uint8_t *b = (const uint8_t *)self.bytes;
    NSUInteger l, length = self.length;
    
    for (NSUInteger i = 0; i < length; i++) {
        if (b[i] > OP_PUSHDATA4) {
            [a addObject:@(b[i])];
            continue;
        }
        
        switch (b[i]) {
            case 0:
                [a addObject:@(0)];
                continue;

            case OP_PUSHDATA1:
                i++;
                if (i + sizeof(uint8_t) > length) return a;
                l = b[i];
                i += sizeof(uint8_t);
                break;

            case OP_PUSHDATA2:
                i++;
                if (i + sizeof(uint16_t) > length) return a;
                l = CFSwapInt16LittleToHost(*(uint16_t *)&b[i]);
                i += sizeof(uint16_t);
                break;

            case OP_PUSHDATA4:
                i++;
                if (i + sizeof(uint32_t) > length) return a;
                l = CFSwapInt32LittleToHost(*(uint32_t *)&b[i]);
                i += sizeof(uint32_t);
                break;

            default:
                l = b[i];
                i++;
                break;
        }
        
        if (i + l > length) return a;
        [a addObject:[NSData dataWithBytes:&b[i] length:l]];
        i += l - 1;
    }
    
    return a;
}

// returns the opcode used to store the receiver in a script (i.e. OP_PUSHDATA1)
- (int)intValue
{
    if (self.length < OP_PUSHDATA1) return (int)self.length;
    else if (self.length <= UINT8_MAX) return OP_PUSHDATA1;
    else if (self.length <= UINT16_MAX) return OP_PUSHDATA2;
    else return OP_PUSHDATA4;
}

@end
