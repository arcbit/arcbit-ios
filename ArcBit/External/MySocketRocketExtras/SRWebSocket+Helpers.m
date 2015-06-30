//
//  SRWebSocket+Helpers.m
//  ArcBit
//
//  Created by Timothy Lee on 3/14/15.
//  Copyright (c) 2015 Timothy Lee <stequald01@gmail.com>
//
//   This library is free software; you can redistribute it and/or
//   modify it under the terms of the GNU Lesser General Public
//   License as published by the Free Software Foundation; either
//   version 2.1 of the License, or (at your option) any later version.
//
//   This library is distributed in the hope that it will be useful,
//   but WITHOUT ANY WARRANTY; without even the implied warranty of
//   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//   Lesser General Public License for more details.
//
//   You should have received a copy of the GNU Lesser General Public
//   License along with this library; if not, write to the Free Software
//   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
//   MA 02110-1301  USA

#import "SRWebSocket+Helpers.h"

@implementation SRWebSocket (Helpers)

+ (NSMutableURLRequest*)createURLRequest:(NSString*)urlString withPinnedCert:(NSData*)certData  {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    if (certData != nil) {
        CFDataRef certDataRef = (__bridge CFDataRef)certData;
        SecCertificateRef certRef = SecCertificateCreateWithData(NULL, certDataRef);
        id certificate = (__bridge id)certRef;
        [request setSR_SSLPinnedCertificates:@[certificate]];        
    }
    return request;
}

@end
