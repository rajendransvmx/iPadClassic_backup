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

@interface GetPriceManager ()
@property(nonatomic, assign) BOOL isGetPriceProgress;
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
                if (wsResponseStatus.requestType == RequestGetPriceDataTypeThree || wsResponseStatus.syncStatus != SyncStatusSuccess)
                {
                    self.isGetPriceProgress = NO;
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
        [[TaskManager sharedInstance] addTask:taskModel];
    }
}

- (void)dealloc
{
   // Should never be called, but just here for clarity really.
}


@end
