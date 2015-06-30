//
//  MobileUsageManager.h
//  ServiceMaxiPad
//
//  Created by Madhusudhan.HK on 6/27/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlowNode.h"
#import "FlowDelegate.h"

@interface MobileUsageManager : NSObject <FlowDelegate>

+ (instancetype) sharedInstance;
+ (instancetype) alloc  __attribute__((unavailable("alloc not available, call sharedInstance instead")));
- (instancetype) init   __attribute__((unavailable("init not available, call sharedInstance instead")));
+ (instancetype) new    __attribute__((unavailable("new not available, call sharedInstance instead")));


- (void) startMobileUsageDataSyncProcess;
- (void) makeRequestForJSFileDownload;
- (void) triggerMobileUsageWebservicesForCategoryType:(CategoryType)type;

@property (readonly)BOOL isMobileUsageDataUploadRequestRunning;
@property (nonatomic)BOOL isApplicationInBackground;

@end
