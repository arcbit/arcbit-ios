//
//  TLCloudDocumentSyncWrapper.m
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

#import "TLCloudDocumentSyncWrapper.h"

static NSString* WALLET_JSON_CLOUD_BACKUP_FILE_EXTENSION = @"backup";

@implementation TLCloudDocumentSyncWrapper

+ (TLCloudDocumentSyncWrapper *)instance {
    static id _instance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _instance = [[self alloc] init];
    });
    
    return _instance;
}

- (id)init {
    self = [super init];
    if (self) {
        [[iCloud sharedCloud] setDelegate:self];
        [[iCloud sharedCloud] setVerboseLogging:YES];
        [[iCloud sharedCloud] setupiCloudDocumentSyncWithUbiquityContainer:nil];
    }
    
    return self;
}

- (BOOL)checkCloudAvailability {
    BOOL cloudIsAvailable = [[iCloud sharedCloud] checkCloudAvailability];
    return cloudIsAvailable;
}

- (void)saveFileToCloud:(NSString*)fileName content:(NSString*)content completion:(void (^)(UIDocument *cloudDocument, NSData *documentData, NSError *error))completion {
    NSData* data = [content dataUsingEncoding:NSUTF8StringEncoding];
    [[iCloud sharedCloud] saveAndCloseDocumentWithName:fileName withContent:data completion:^(UIDocument *cloudDocument, NSData *documentData, NSError *error) {
        completion(cloudDocument, documentData, error);
    }];
}

- (void)getFileFromCloud:(NSString*)fileName completion:(void (^)(UIDocument *cloudDocument, NSData *documentData, NSError *error))completion {
    [[iCloud sharedCloud] retrieveCloudDocumentWithName:fileName completion:^(UIDocument *cloudDocument, NSData *documentData, NSError *error) {
        completion(cloudDocument, documentData, error);
    }];
}

#pragma mark - iCloud Methods

- (void)iCloudDidFinishInitializingWitUbiquityToken:(id)cloudToken withUbiquityContainer:(NSURL *)ubiquityContainer {
    NSLog(@"Ubiquity container initialized. You may proceed to perform document operations.");
}

- (void)iCloudAvailabilityDidChangeToState:(BOOL)cloudIsAvailable withUbiquityToken:(id)ubiquityToken withUbiquityContainer:(NSURL *)ubiquityContainer {
    if (!cloudIsAvailable) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iCloud Unavailable" message:@"iCloud is no longer available. Make sure that you are signed into a valid iCloud account." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)iCloudFilesDidChange:(NSMutableArray *)files withNewFileNames:(NSMutableArray *)fileNames {
}

- (NSString *)iCloudQueryLimitedToFileExtension {
    return WALLET_JSON_CLOUD_BACKUP_FILE_EXTENSION;
}

- (void)iCloudFileConflictBetweenCloudFile:(NSDictionary *)cloudFile andLocalFile:(NSDictionary *)localFile {
}

- (void)iCloudFileUpdateDidBegin {
}

- (void)iCloudFileUpdateDidEnd {
}

- (void)refreshCloudList {
    [[iCloud sharedCloud] updateFiles];
}

- (void)refreshCloudListAfterSetup {
    [[iCloud sharedCloud] setDelegate:self];
    [[iCloud sharedCloud] updateFiles];
}

@end
