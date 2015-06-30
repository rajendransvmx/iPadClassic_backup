//
//  MobileUsageDataLoader.m
//  ServiceMaxiPad
//
//  Created by Madhusudhan.HK on 6/24/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "MobileUsageDataLoader.h"
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

@implementation MobileUsageDataLoader


+ (void)makingRequestForJSFileDownloadWithId:(NSString *)docId
                 andCallerDelegate:(id)delegate
{
   // TODO: Change to JavaScript file ID, As of now we are using product ID from  TroubleShooting model...
    
    CacheManager *cache = [CacheManager sharedInstance];
    [cache pushToCache:@"015K0000001ax1tIAA" byKey:@"docId"];
    
    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeMobileUsageFileDownload
                                             requestParam:nil callerDelegate:delegate];
    [[TaskManager sharedInstance] addTask:taskModel];
    
}


+ (void)makingRequestForMobileUsageDataUploadToServer:(id)mobileUsage
                         andCallerDelegate:(id)delegate
{
    //TODO: Change to MobileUsage from LocationPing, As of now using LocationPing APIs for initial development...
    
    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeLocationPing
                                             requestParam:nil
                                           callerDelegate:delegate];
    [[TaskManager sharedInstance] addTask:taskModel];
    
}
@end
