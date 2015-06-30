//
//  MobileUsageDataLoader.h
//  ServiceMaxiPad
//
//  Created by Madhusudhan.HK on 6/24/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MobileUsageDataLoader : NSObject

+ (void)makingRequestForJSFileDownloadWithId:(NSString *)docId
                  andCallerDelegate:(id)delegate;
+ (void)makingRequestForMobileUsageDataUploadToServer:(id)mobileUsage
                 andCallerDelegate:(id)delegate;

@end
