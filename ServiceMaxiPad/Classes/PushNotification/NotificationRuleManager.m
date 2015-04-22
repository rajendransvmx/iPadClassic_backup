//
//  NotificationRuleManager.m
//  ServiceMaxiPad
//
//  Created by Krishna Shanbhag on 04/03/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "NotificationRuleManager.h"
#import "SyncManager.h"
#import "WebserviceResponseStatus.h"
#import "TaskManager.h"
#import "SyncConstants.h"

@implementation NotificationRuleManager

#pragma mark Singleton Methods

+ (instancetype) sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super alloc] initInstance];
    });
    return sharedInstance;
}

- (instancetype) initInstance {
    self = [super init];
    // Do any other initialisation stuff here
    // ...
    return self;
}
-(BOOL)shouldprocessNotificationRequest {
    
    NSArray *array = [[TaskManager sharedInstance] currentlyRunningOperations];
    if ([array count] == 0) {
        return YES;
    }
    for (NSNumber *categoryNumber in array) {
        switch ([categoryNumber intValue]) {
            case CategoryTypeConfigSync:
            case CategoryTypeInitialSync:
            case CategoryTypeOneCallRestInitialSync:
            case CategoryTypeIncrementalOneCallMetaSync:
            case CategoryTypeDOD:
            case CategoryTypeOneCallConfigSync:
            case CategoryTypeSFMSearch:
            case CategoryTypeDataPurge:
                return NO;
                break;
                
            default:
                break;
        }
    }
    return YES;
}

@end
