//
//  GetPriceManager.m
//  ServiceMaxMobile
//
//  Created by Anoop on 4/13/15.
//  Copyright (c) 2015 ServiceMax, Inc. All rights reserved.
//

#import "GetPriceManager.h"
#import "TaskManager.h"
#import "TaskModel.h"
#import "TaskGenerator.h"
#import "WebserviceResponseStatus.h"
#import "RequestConstants.h"
#import "TimeLogCacheManager.h"

@interface GetPriceManager ()

@property(nonatomic, assign) BOOL isGetPriceProgress;
@property(nonatomic, copy) NSString *getPriceTaskId;

@end

@implementation GetPriceManager

-(BOOL)isGetPriceInProgress
{
    return self.isGetPriceProgress;
}

#pragma mark Singleton Methods

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[super alloc] initInstance];
    
    });
    
    return sharedInstance;
}


- (instancetype)initInstance
{
    self = [super init];
    return self;
}


- (void)flowStatus:(id)status
{
    if ([status isKindOfClass:[WebserviceResponseStatus class]])
    {
        WebserviceResponseStatus *wsResponseStatus = (WebserviceResponseStatus*)status;
        if (wsResponseStatus.category == CategoryTypeGetPriceData)
        {
            if(wsResponseStatus.syncStatus == SyncStatusInQueue ||
               wsResponseStatus.syncStatus == SyncStatusInProgress)
            {
                self.isGetPriceProgress = YES;
            }
            else
            {
                if (wsResponseStatus.requestType == RequestCleanUp//RequestSyncTimeLogs
                    || wsResponseStatus.syncStatus != SyncStatusSuccess)
                {
                    [[TimeLogCacheManager sharedInstance] clearAllFailureListforCategoryType:CategoryTypeGetPriceData];
                    [[TimeLogCacheManager sharedInstance] clearAllLogEntryForCategoryType:CategoryTypeGetPriceData];
                    self.isGetPriceProgress = NO;
                    self.getPriceTaskId = nil;
                }
            }
        }
    }
}


- (void)intiateGetPriceSync
{
    if (!self.isGetPriceInProgress)
    {
        self.isGetPriceProgress = YES;
        TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeGetPriceData
                                                 requestParam:nil
                                               callerDelegate:self];
        self.getPriceTaskId = taskModel.taskId;
        [[TaskManager sharedInstance] addTask:taskModel];
    }
}


-(void)cancelGetPriceSync
{
    if (self.getPriceTaskId != nil)
    {
        [[TaskManager  sharedInstance] cancelFlowNodeWithId:self.getPriceTaskId];
        [[TaskManager  sharedInstance] removeFlowNodeWithId:self.getPriceTaskId];
    }
}


/*TODO : Check for LAST_SYNC key */
/** storing in userdefaults */
/*
NSString *lastSyncKey  =  [objectDict objectForKey:kSVMXRequestKey];
if (![StringUtil isStringEmpty:lastSyncKey] && [lastSyncKey isEqualToString:kLastSync]) {
    [self updateLastSyncTime:objectDict];
    continue;
}
- (void)updateLastSyncTime:(NSDictionary *)lastSyncDictionary{
    NSString *lastDate = [lastSyncDictionary objectForKey:kSVMXRequestValue];
    if (![StringUtil isStringEmpty:lastDate]) {
        [PlistManager storeOneCallSyncTime:lastDate];
        [PlistManager storeInitiaSyncSyncTimeForDP:lastDate];
    }
}
*/

- (void)dealloc
{
   // Should never be called, but just here for clarity really.
}


@end
