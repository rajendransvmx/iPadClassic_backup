//
//  ProductManualDataLoader.m
//  ServiceMaxiPad
//
//  Created by Chinnababu on 06/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ProductManualDataLoader.h"
#import "TaskModel.h"
#import "TaskGenerator.h"
#import "TaskManager.h"
#import "SyncConstants.h"
#import "CacheManager.h"

@implementation ProductManualDataLoader

+ (void)makingRequestForDetailsByProductId:(NSString *)productID
                     withTheCallerDelegate:(id)delegate
{
    CacheManager *cache = [CacheManager sharedInstance];
    [cache pushToCache:productID byKey:@"pMId"];
    
    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeProductManual
                                             requestParam:nil
                                           callerDelegate:delegate];
    [[TaskManager sharedInstance] addTask:taskModel];
}

+ (void)makingRequestForProductManualBodyWithTheDelegate:(id)delegate;
{
    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeProductManualDownlaod
                                             requestParam:nil callerDelegate:delegate];
    [[TaskManager sharedInstance] addTask:taskModel];
    
}



@end
