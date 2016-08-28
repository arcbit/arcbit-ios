//
//  BreadWalletTests.m
//  ArcBit
//
//  Created by Tim Lee on 3/22/15.
//  Copyright (c) 2015 ArcBit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <CommonCrypto/CommonDigest.h>
#import <CoreBitcoin/BTCKey.h>
#import <CoreBitcoin/BTCOpcode.h>
#import <CoreBitcoin/BTCAddress.h>
#import "BRTransaction.h"
#import "BRKey.h"
#import "BRKey+BIP38.h"
#import "NSMutableData+Bitcoin.h"
#import "NSString+Base58.h"

BOOL isTestnet = NO;

@interface BreadWalletTests : XCTestCase

@end

@implementation BreadWalletTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

#pragma mark - testBase58
/*
- (void)testBase58
{
    // test bad input
    NSString *s = [NSString base58WithData:[@"#&$@*^(*#!^" base58ToData]];
    
    XCTAssertTrue(s.length == 0, @"[NSString base58WithData:]");
    
    s = [NSString base58WithData:[@"123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz" base58ToData]];
    XCTAssertEqualObjects(@"123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz", s,
                          @"[NSString base58WithData:]");
}

#pragma mark - testKey

#if ! BITCOIN_TESTNET
- (void)testKeyWithPrivateKey
{
    XCTAssertFalse([@"S6c56bnXQiBjk9mqSYE7ykVQ7NzrRz" isValidBitcoinPrivateKey:isTestnet],
                   @"[NSString+Base58 isValidBitcoinPrivateKey]");
    
    XCTAssertTrue([@"S6c56bnXQiBjk9mqSYE7ykVQ7NzrRy" isValidBitcoinPrivateKey:isTestnet],
                  @"[NSString+Base58 isValidBitcoinPrivateKey]");
    
    // mini private key format
    BRKey *key = [BRKey keyWithPrivateKey:@"S6c56bnXQiBjk9mqSYE7ykVQ7NzrRy" isTestnet:isTestnet];
    
    NSLog(@"privKey:S6c56bnXQiBjk9mqSYE7ykVQ7NzrRy = %@", key.address);
    XCTAssertEqualObjects(@"1CciesT23BNionJeXrbxmjc7ywfiyM4oLW", key.address, @"[BRKey keyWithPrivateKey:]");
    XCTAssertTrue([@"SzavMBLoXU6kDrqtUVmffv" isValidBitcoinPrivateKey:isTestnet],
                  @"[NSString+Base58 isValidBitcoinPrivateKey]");
    
    // old mini private key format
    key = [BRKey keyWithPrivateKey:@"SzavMBLoXU6kDrqtUVmffv" isTestnet:isTestnet];
    
    NSLog(@"privKey:SzavMBLoXU6kDrqtUVmffv = %@", key.address);
    XCTAssertEqualObjects(@"1CC3X2gu58d6wXUWMffpuzN9JAfTUWu4Kj", key.address, @"[BRKey keyWithPrivateKey:]");
    
    // uncompressed private key
    key = [BRKey keyWithPrivateKey:@"5Kb8kLf9zgWQnogidDA76MzPL6TsZZY36hWXMssSzNydYXYB9KF" isTestnet:isTestnet];
    
    NSLog(@"privKey:5Kb8kLf9zgWQnogidDA76MzPL6TsZZY36hWXMssSzNydYXYB9KF = %@", key.address);
    XCTAssertEqualObjects(@"1CC3X2gu58d6wXUWMffpuzN9JAfTUWu4Kj", key.address, @"[BRKey keyWithPrivateKey:]");
    
    // uncompressed private key export
    NSLog(@"privKey = %@", key.privateKey);
    XCTAssertEqualObjects(@"5Kb8kLf9zgWQnogidDA76MzPL6TsZZY36hWXMssSzNydYXYB9KF", key.privateKey,
                          @"[BRKey privateKey]");
    
    // compressed private key
    key = [BRKey keyWithPrivateKey:@"KyvGbxRUoofdw3TNydWn2Z78dBHSy2odn1d3wXWN2o3SAtccFNJL" isTestnet:isTestnet];
    
    NSLog(@"privKey:KyvGbxRUoofdw3TNydWn2Z78dBHSy2odn1d3wXWN2o3SAtccFNJL = %@", key.address);
    XCTAssertEqualObjects(@"1JMsC6fCtYWkTjPPdDrYX3we2aBrewuEM3", key.address, @"[BRKey keyWithPrivateKey:]");
    
    // compressed private key export
    NSLog(@"privKey = %@", key.privateKey);
    XCTAssertEqualObjects(@"KyvGbxRUoofdw3TNydWn2Z78dBHSy2odn1d3wXWN2o3SAtccFNJL", key.privateKey,
                          @"[BRKey privateKey]");
}
#endif

#pragma mark - testKeyWithBIP38Key

#if ! BITCOIN_TESTNET && ! SKIP_BIP38
- (void)testKeyWithBIP38Key
{
    NSString *intercode, *confcode, *privkey;
    BRKey *key;
    
    // non EC multiplied, uncompressed
    key = [BRKey keyWithBIP38Key:@"6PRVWUbkzzsbcVac2qwfssoUJAN1Xhrg6bNk8J7Nzm5H7kxEbn2Nh2ZoGg"
                   andPassphrase:@"TestingOneTwoThree" isTestnet:isTestnet];
    NSLog(@"privKey = %@", key.privateKey);
    XCTAssertEqualObjects(@"5KN7MzqK5wt2TP1fQCYyHBtDrXdJuXbUzm4A9rKAteGu3Qi5CVR", key.privateKey,
                          @"[BRKey keyWithBIP38Key:andPassphrase:]");
    XCTAssertEqualObjects([key BIP38KeyWithPassphrase:@"TestingOneTwoThree" isTestnet:isTestnet],
                          @"6PRVWUbkzzsbcVac2qwfssoUJAN1Xhrg6bNk8J7Nzm5H7kxEbn2Nh2ZoGg",
                          @"[BRKey BIP38KeyWithPassphrase:]");
    
    key = [BRKey keyWithBIP38Key:@"6PRNFFkZc2NZ6dJqFfhRoFNMR9Lnyj7dYGrzdgXXVMXcxoKTePPX1dWByq"
                   andPassphrase:@"Satoshi" isTestnet:isTestnet];
    NSLog(@"privKey = %@", key.privateKey);
    XCTAssertEqualObjects(@"5HtasZ6ofTHP6HCwTqTkLDuLQisYPah7aUnSKfC7h4hMUVw2gi5", key.privateKey,
                          @"[BRKey keyWithBIP38Key:andPassphrase:]");
    XCTAssertEqualObjects([key BIP38KeyWithPassphrase:@"Satoshi" isTestnet:isTestnet],
                          @"6PRNFFkZc2NZ6dJqFfhRoFNMR9Lnyj7dYGrzdgXXVMXcxoKTePPX1dWByq",
                          @"[BRKey BIP38KeyWithPassphrase:]");
    
    // non EC multiplied, compressed
    key = [BRKey keyWithBIP38Key:@"6PYNKZ1EAgYgmQfmNVamxyXVWHzK5s6DGhwP4J5o44cvXdoY7sRzhtpUeo"
                   andPassphrase:@"TestingOneTwoThree" isTestnet:isTestnet];
    NSLog(@"privKey = %@", key.privateKey);
    XCTAssertEqualObjects(@"L44B5gGEpqEDRS9vVPz7QT35jcBG2r3CZwSwQ4fCewXAhAhqGVpP", key.privateKey,
                          @"[BRKey keyWithBIP38Key:andPassphrase:]");
    XCTAssertEqualObjects([key BIP38KeyWithPassphrase:@"TestingOneTwoThree" isTestnet:isTestnet],
                          @"6PYNKZ1EAgYgmQfmNVamxyXVWHzK5s6DGhwP4J5o44cvXdoY7sRzhtpUeo",
                          @"[BRKey BIP38KeyWithPassphrase:]");
    
    key = [BRKey keyWithBIP38Key:@"6PYLtMnXvfG3oJde97zRyLYFZCYizPU5T3LwgdYJz1fRhh16bU7u6PPmY7"
                   andPassphrase:@"Satoshi" isTestnet:isTestnet];
    NSLog(@"privKey = %@", key.privateKey);
    XCTAssertEqualObjects(@"KwYgW8gcxj1JWJXhPSu4Fqwzfhp5Yfi42mdYmMa4XqK7NJxXUSK7", key.privateKey,
                          @"[BRKey keyWithBIP38Key:andPassphrase:]");
    XCTAssertEqualObjects([key BIP38KeyWithPassphrase:@"Satoshi" isTestnet:isTestnet],
                          @"6PYLtMnXvfG3oJde97zRyLYFZCYizPU5T3LwgdYJz1fRhh16bU7u6PPmY7",
                          @"[BRKey BIP38KeyWithPassphrase:]");
    
    // EC multiplied, uncompressed, no lot/sequence number
    key = [BRKey keyWithBIP38Key:@"6PfQu77ygVyJLZjfvMLyhLMQbYnu5uguoJJ4kMCLqWwPEdfpwANVS76gTX"
                   andPassphrase:@"TestingOneTwoThree" isTestnet:isTestnet];
    NSLog(@"privKey = %@", key.privateKey);
    XCTAssertEqualObjects(@"5K4caxezwjGCGfnoPTZ8tMcJBLB7Jvyjv4xxeacadhq8nLisLR2", key.privateKey,
                          @"[BRKey keyWithBIP38Key:andPassphrase:]");
    intercode = [BRKey BIP38IntermediateCodeWithSalt:0xa50dba6772cb9383ULL andPassphrase:@"TestingOneTwoThree"];
    NSLog(@"intercode = %@", intercode);
    privkey = [BRKey BIP38KeyWithIntermediateCode:intercode
                                            seedb:@"99241d58245c883896f80843d2846672d7312e6195ca1a6c".hexToData compressed:NO
                                 confirmationCode:&confcode isTestnet:isTestnet];
    NSLog(@"confcode = %@", confcode);
    XCTAssertEqualObjects(@"6PfQu77ygVyJLZjfvMLyhLMQbYnu5uguoJJ4kMCLqWwPEdfpwANVS76gTX", privkey,
                          @"[BRKey BIP38KeyWithIntermediateCode:]");
    XCTAssertTrue([BRKey confirmWithBIP38ConfirmationCode:confcode address:@"1PE6TQi6HTVNz5DLwB1LcpMBALubfuN2z2"
                                               passphrase:@"TestingOneTwoThree" isTestnet:isTestnet], @"[BRKey confirmWithBIP38ConfirmationCode:]");
    
    key = [BRKey keyWithBIP38Key:@"6PfLGnQs6VZnrNpmVKfjotbnQuaJK4KZoPFrAjx1JMJUa1Ft8gnf5WxfKd"
                   andPassphrase:@"Satoshi" isTestnet:isTestnet];
    NSLog(@"privKey = %@", key.privateKey);
    XCTAssertEqualObjects(@"5KJ51SgxWaAYR13zd9ReMhJpwrcX47xTJh2D3fGPG9CM8vkv5sH", key.privateKey,
                          @"[BRKey keyWithBIP38Key:andPassphrase:]");
    intercode = [BRKey BIP38IntermediateCodeWithSalt:0x67010a9573418906ULL andPassphrase:@"Satoshi"];
    NSLog(@"intercode = %@", intercode);
    privkey = [BRKey BIP38KeyWithIntermediateCode:intercode
                                            seedb:@"49111e301d94eab339ff9f6822ee99d9f49606db3b47a497".hexToData compressed:NO
                                 confirmationCode:&confcode isTestnet:isTestnet];
    NSLog(@"confcode = %@", confcode);
    XCTAssertEqualObjects(@"6PfLGnQs6VZnrNpmVKfjotbnQuaJK4KZoPFrAjx1JMJUa1Ft8gnf5WxfKd", privkey,
                          @"[BRKey BIP38KeyWithIntermediateCode:]");
    XCTAssertTrue([BRKey confirmWithBIP38ConfirmationCode:confcode address:@"1CqzrtZC6mXSAhoxtFwVjz8LtwLJjDYU3V"
                                               passphrase:@"Satoshi" isTestnet:isTestnet], @"[BRKey confirmWithBIP38ConfirmationCode:]");
    
    // EC multiplied, uncompressed, with lot/sequence number
    key = [BRKey keyWithBIP38Key:@"6PgNBNNzDkKdhkT6uJntUXwwzQV8Rr2tZcbkDcuC9DZRsS6AtHts4Ypo1j"
                   andPassphrase:@"MOLON LABE" isTestnet:isTestnet];
    NSLog(@"privKey = %@", key.privateKey);
    XCTAssertEqualObjects(@"5JLdxTtcTHcfYcmJsNVy1v2PMDx432JPoYcBTVVRHpPaxUrdtf8", key.privateKey,
                          @"[BRKey keyWithBIP38Key:andPassphrase:]");
    intercode = [BRKey BIP38IntermediateCodeWithLot:263183 sequence:1 salt:0x4fca5a97u passphrase:@"MOLON LABE"];
    NSLog(@"intercode = %@", intercode);
    privkey = [BRKey BIP38KeyWithIntermediateCode:intercode
                                            seedb:@"87a13b07858fa753cd3ab3f1c5eafb5f12579b6c33c9a53f".hexToData compressed:NO
                                 confirmationCode:&confcode isTestnet:isTestnet];
    NSLog(@"confcode = %@", confcode);
    XCTAssertEqualObjects(@"6PgNBNNzDkKdhkT6uJntUXwwzQV8Rr2tZcbkDcuC9DZRsS6AtHts4Ypo1j", privkey,
                          @"[BRKey BIP38KeyWithIntermediateCode:]");
    XCTAssertTrue([BRKey confirmWithBIP38ConfirmationCode:confcode address:@"1Jscj8ALrYu2y9TD8NrpvDBugPedmbj4Yh"
                                               passphrase:@"MOLON LABE" isTestnet:isTestnet], @"[BRKey confirmWithBIP38ConfirmationCode:]");
    
    key = [BRKey keyWithBIP38Key:@"6PgGWtx25kUg8QWvwuJAgorN6k9FbE25rv5dMRwu5SKMnfpfVe5mar2ngH"
                   andPassphrase:@"\u039c\u039f\u039b\u03a9\u039d \u039b\u0391\u0392\u0395" isTestnet:isTestnet];
    NSLog(@"privKey = %@", key.privateKey);
    XCTAssertEqualObjects(@"5KMKKuUmAkiNbA3DazMQiLfDq47qs8MAEThm4yL8R2PhV1ov33D", key.privateKey,
                          @"[BRKey keyWithBIP38Key:andPassphrase:]");
    intercode = [BRKey BIP38IntermediateCodeWithLot:806938 sequence:1 salt:0xc40ea76fu
                                         passphrase:@"\u039c\u039f\u039b\u03a9\u039d \u039b\u0391\u0392\u0395"];
    NSLog(@"intercode = %@", intercode);
    privkey = [BRKey BIP38KeyWithIntermediateCode:intercode
                                            seedb:@"03b06a1ea7f9219ae364560d7b985ab1fa27025aaa7e427a".hexToData compressed:NO
                                 confirmationCode:&confcode isTestnet:isTestnet];
    NSLog(@"confcode = %@", confcode);
    XCTAssertEqualObjects(@"6PgGWtx25kUg8QWvwuJAgorN6k9FbE25rv5dMRwu5SKMnfpfVe5mar2ngH", privkey,
                          @"[BRKey BIP38KeyWithIntermediateCode:]");
    XCTAssertTrue([BRKey confirmWithBIP38ConfirmationCode:confcode address:@"1Lurmih3KruL4xDB5FmHof38yawNtP9oGf"
                                               passphrase:@"\u039c\u039f\u039b\u03a9\u039d \u039b\u0391\u0392\u0395" isTestnet:isTestnet],
                  @"[BRKey confirmWithBIP38ConfirmationCode:]");
    
    // password NFC unicode normalization test
    key = [BRKey keyWithBIP38Key:@"6PRW5o9FLp4gJDDVqJQKJFTpMvdsSGJxMYHtHaQBF3ooa8mwD69bapcDQn"
                   andPassphrase:@"\u03D2\u0301\0\U00010400\U0001F4A9" isTestnet:isTestnet];
    NSLog(@"privKey = %@", key.privateKey);
    XCTAssertEqualObjects(@"5Jajm8eQ22H3pGWLEVCXyvND8dQZhiQhoLJNKjYXk9roUFTMSZ4", key.privateKey,
                          @"[BRKey keyWithBIP38Key:andPassphrase:]");
    
    // incorrect password test
    key = [BRKey keyWithBIP38Key:@"6PRW5o9FLp4gJDDVqJQKJFTpMvdsSGJxMYHtHaQBF3ooa8mwD69bapcDQn" andPassphrase:@"foobar" isTestnet:isTestnet];
    NSLog(@"privKey = %@", key.privateKey);
    XCTAssertNil(key, @"[BRKey keyWithBIP38Key:andPassphrase:]");
}
#endif

#pragma mark - testTransaction

- (void)testTransaction
{
    NSMutableData *hash = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH], *script = [NSMutableData data];
    BRKey *k = [BRKey keyWithSecret:@"0000000000000000000000000000000000000000000000000000000000000001".hexToData
                         compressed:YES isTestnet:isTestnet];
    
    [script appendScriptPubKeyForAddress:k.address isTestnet:isTestnet];
    
    BRTransaction *tx = [[BRTransaction alloc] initWithInputHashes:@[hash] inputIndexes:@[@0] inputScripts:@[script]
                                                   outputAddresses:@[k.address, k.address] outputAmounts:@[@100000000, @4900000000] isTestnet:isTestnet];
    
    [tx signWithPrivateKeys:@[k.privateKey] isTestnet:isTestnet];
    
    XCTAssertTrue([tx isSigned], @"[BRTransaction signWithPrivateKeys:]");
    
    NSUInteger height = [tx blockHeightUntilFreeForAmounts:@[@5000000000] withBlockHeights:@[@1]];
    uint64_t priority = [tx priorityForAmounts:@[@5000000000] withAges:@[@(height - 1)]];
    
    NSLog(@"height = %lu", (unsigned long)height);
    NSLog(@"priority = %llu", priority);
    
    XCTAssertTrue(priority >= TX_FREE_MIN_PRIORITY, @"[BRTransaction priorityForAmounts:withAges:]");
    
    NSData *d = tx.data;
    
    tx = [BRTransaction transactionWithMessage:d isTestnet:isTestnet];
    
    XCTAssertEqualObjects(d, tx.data, @"[BRTransaction transactionWithMessage:]");
    
    tx = [[BRTransaction alloc] initWithInputHashes:@[hash, hash, hash, hash, hash, hash, hash, hash, hash, hash]
                                       inputIndexes:@[@0, @0,@0, @0, @0, @0, @0, @0, @0, @0]
                                       inputScripts:@[script, script, script, script, script, script, script, script, script, script]
                                    outputAddresses:@[k.address, k.address, k.address, k.address, k.address, k.address, k.address, k.address,
                                                      k.address, k.address]
                                      outputAmounts:@[@1000000, @1000000, @1000000, @1000000, @1000000, @1000000, @1000000, @1000000, @1000000,
                                                      @1000000] isTestnet:isTestnet];
    
    [tx signWithPrivateKeys:@[k.privateKey] isTestnet:isTestnet];
    
    XCTAssertTrue([tx isSigned], @"[BRTransaction signWithPrivateKeys:]");
    
    height = [tx blockHeightUntilFreeForAmounts:@[@1000000, @1000000, @1000000, @1000000, @1000000, @1000000, @1000000,
                                                  @1000000, @1000000, @1000000]
                               withBlockHeights:@[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10]];
    priority = [tx priorityForAmounts:@[@1000000, @1000000, @1000000, @1000000, @1000000, @1000000, @1000000, @1000000,
                                        @1000000, @1000000]
                             withAges:@[@(height - 1), @(height - 2), @(height - 3), @(height - 4), @(height - 5), @(height - 6),
                                        @(height - 7), @(height - 8), @(height - 9), @(height - 10)]];
    
    NSLog(@"height = %lu", (unsigned long)height);
    NSLog(@"priority = %llu", priority);
    
    XCTAssertTrue(priority >= TX_FREE_MIN_PRIORITY, @"[BRTransaction priorityForAmounts:withAges:]");
    
    d = tx.data;
    tx = [BRTransaction transactionWithMessage:d isTestnet:isTestnet];
    
    XCTAssertEqualObjects(d, tx.data, @"[BRTransaction transactionWithMessage:]");
}
//*/
@end
