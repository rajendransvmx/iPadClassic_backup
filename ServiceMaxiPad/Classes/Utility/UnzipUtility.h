//
//  UnzipUtility.h
//  ServiceMaxMobile
//
//  Created by Krishna Shanbhag on 01/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UnzipUtility : NSObject
+ (NSArray *) getListOfCoreLibraries;
+ (void) unzipBundledStaticResourceAtPath:(NSString *)path;
+ (void) unzipFileAtPath:(NSString *)filepath toFolder:(NSString *)destinationFolder;
+ (BOOL) isAppWithSameVersion:(NSString *)versionKey;
+ (BOOL) isFileIsUnZipping;
+ (void) setLockforUnzippingfile:(BOOL)isZipping;
+ (void) unzipAndReplaceBundledStaticResourceAtPath:(NSString *)path; // 27690
@end
