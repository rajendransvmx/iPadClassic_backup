//
//  TroubleShootDataLoader.m
//  ServiceMaxMobile
//
//  Created by Chinnababu on 09/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "TroubleshootingDataLoader.h"
#import "DBCriteria.h"
#import "DBRequestSelect.h"
#import "DBRequestConstant.h"
#import "DatabaseConstant.h"
#import "ZKQueryResult.h"
#import "ZKSObject.h"
#import "Base64.h"
#import "ZKServerSwitchboard.h"
#import "TaskModel.h"
#import "TaskGenerator.h"
#import "TaskManager.h"
#import "SyncConstants.h"
#import "CacheManager.h"


@implementation TroubleshootingDataLoader

+ (void)makingRequestForDetailsByProductName:(NSString *)productName
                       withTheCallerDelegate:(id)delegate;
{
    CacheManager *cache = [CacheManager sharedInstance];
    [cache pushToCache:productName byKey:@"docName"];
    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeTroubleShooting
                                             requestParam:nil
                                           callerDelegate:delegate];
    [[TaskManager sharedInstance] addTask:taskModel];
}

+ (void)makingRequestForBodyByDocID:(NSString *)docId
                  andCallerDelegate:(id)delegate;
{
    CacheManager *cache = [CacheManager sharedInstance];
    [cache pushToCache:docId byKey:@"docId"];
    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeTroubleShootingDataDownload
                                             requestParam:nil callerDelegate:delegate];
    [[TaskManager sharedInstance] addTask:taskModel];
    
}

@end
