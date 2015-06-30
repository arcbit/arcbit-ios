//
//  BRKey+BIP38.h
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

#import "BRKey.h"

// BIP38 is a method for encrypting private keys with a passphrase
// https://github.com/bitcoin/bips/blob/master/bip-0038.mediawiki

@interface BRKey (BIP38)

// decrypts a BIP38 key using the given passphrase or retuns nil if passphrase is incorrect
+ (instancetype)keyWithBIP38Key:(NSString *)key andPassphrase:(NSString *)passphrase;

// generates an "intermediate code" for an EC multiply mode key, salt should be 64bits of random data
+ (NSString *)BIP38IntermediateCodeWithSalt:(uint64_t)salt andPassphrase:(NSString *)passphrase;

// generates an "intermediate code" for an EC multiply mode key with a lot and sequence number, lot must be less than
// 1048576, sequence must be less than 4096, and salt should be 32bits of random data
+ (NSString *)BIP38IntermediateCodeWithLot:(uint32_t)lot sequence:(uint16_t)sequence salt:(uint32_t)salt
passphrase:(NSString *)passphrase;

// generates a BIP38 key from an "intermediate code" and 24 bytes of cryptographically random data (seedb),
// compressed indicates if compressed pubKey format should be used for the bitcoin address, confcode (optional) will
// be set to the "confirmation code"
+ (NSString *)BIP38KeyWithIntermediateCode:(NSString *)code seedb:(NSData *)seedb compressed:(BOOL)compressed
confirmationCode:(NSString **)confcode;

// returns true if the "confirmation code" confirms that the given bitcoin address depends on the specified passphrase
+ (BOOL)confirmWithBIP38ConfirmationCode:(NSString *)code address:(NSString *)address passphrase:(NSString *)passphrase;

- (instancetype)initWithBIP38Key:(NSString *)key andPassphrase:(NSString *)passphrase;

// encrypts receiver with passphrase and returns BIP38 key
- (NSString *)BIP38KeyWithPassphrase:(NSString *)passphrase;

@end
