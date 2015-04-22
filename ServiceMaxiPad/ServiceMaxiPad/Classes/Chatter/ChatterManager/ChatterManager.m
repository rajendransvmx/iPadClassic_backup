//
//  ChatterManager.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 19/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ChatterManager.h"
#import "TaskGenerator.h"
#import "TaskModel.h"
#import "TaskManager.h"
#import "FlowDelegate.h"
#import "WebserviceResponseStatus.h"
#import "AlertMessageHandler.h"
#import "ChatterHelper.h"
#import "NonTagConstant.h"
#import "FileManager.h"
#import "RequestParamModel.h"
#import "SNetworkReachabilityManager.h"
#import "TagManager.h"
#import "AlertMessageHandler.h"
#import "NSString+StringUtility.h"

NSString *kChatterDataModified = @"ChatterDataModified";

@interface ChatterManager () <FlowDelegate>

@property(nonatomic, strong)NSMutableArray *dataArray;
@property(nonatomic, strong)NSMutableDictionary *requestParmDict;
@property(nonatomic, strong)NSMutableArray *requestIdArray;
@property(nonatomic, strong)NSString *productId;
@property BOOL firstTimeload;

@end

@implementation ChatterManager

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

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

- (void)setFirstTimeloadflag:(BOOL)value
{
    self.firstTimeload = value;
}

- (BOOL)getFirstTimeLoad
{
    return self.firstTimeload;
}

- (NSString *)getProductId
{
    return self.productId;
}

- (void)setProductId:(NSString *)productId
{
    _productId = productId;
}

- (void)fetchChatterDetails
{
    if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable]) {
        [self updateUserImagesToRefresh];
        [self performSelectorInBackground:@selector(initaiteChatterRequest) withObject:nil];
    }
    else {
        [self fetchChatterDetailsFromDatabase];
    }
}

- (void)fetchChatterDetailsFromDatabase
{
    
    [self sendNotification:ResponseStatusProductImage];
    
    NSMutableArray *reultSet = [ChatterHelper fetchChatterFeedsForProductId:self.productId];
    
    [self updateChatterData:reultSet];
    [self sendNotification:ResponseStatusChatterData];
}

- (void)initaiteChatterRequest
{
    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeChatter
                                             requestParam:nil
                                           callerDelegate:self];
    
    [[TaskManager sharedInstance] addTask:taskModel];
    
    [self addTaskIds:taskModel.taskId];
}

- (void)fetchChatterPosts
{
    @synchronized([self class]) {
        [[ChatterManager sharedInstance] setFirstTimeloadflag:NO];
        TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeChatterPosts
                                                 requestParam:nil
                                               callerDelegate:self];
        
        [[TaskManager sharedInstance] addTask:taskModel];
        
        [self addTaskIds:taskModel.taskId];

    }
}

- (void)addTaskIds:(NSString *)taskId
{
    if (self.requestIdArray == nil) {
        self.requestIdArray = [NSMutableArray new];
    }
    [self.requestIdArray addObject:taskId];
}

- (void)flowStatus:(id)status
{
    if([status isKindOfClass:[WebserviceResponseStatus class]])
    {
        WebserviceResponseStatus *st = (WebserviceResponseStatus*)status;
        switch (st.category)
        {
            case CategoryTypeChatter:
            case CategoryTypeChatterPosts:
            case CategoryTypeChatterFeedInsert:
            case CategoryTypeChatterFeedUpdate:
            {
                if  (st.syncStatus == SyncStatusSuccess
                     || st.syncStatus == SyncStatusInProgress) {
                    [self updateChatterViewOnSucess:st];
                }
                else if (st.syncStatus == SyncStatusFailed) {
                    [self updateChatterViewOnSucess:st];
                    if (st.category == CategoryTypeChatter
                        || st.category == CategoryTypeChatterPosts) {
                        [self requestFialedWithError:st.syncError shouldShow:NO];
                    }
                }
                else if (st.syncStatus == SyncStatusNetworkError
                         || st.syncStatus == SyncStatusRefreshTokenFailedWithError) {
                    [self requestFialedWithError:st.syncError shouldShow:YES];
                }
        
                else if (st.syncStatus == SyncStatusInCancelled) {
                    
                }
                break;
            }
            default:
                break;
        }
    }
}

- (void)updateChatterViewOnSucess:(WebserviceResponseStatus *)status
{
    switch (status.syncProgressState) {
        case ChatterStatusProductImageDownloaded:
            [self sendNotification:ResponseStatusProductImage];
            break;
        case ChattetStautusCompleted:
            [self sendNotification:ResponseStatusChatterData];
            break;
        case ChatterFeedPostStatusCompleted:
            [self sendNotification:ResponseStatusChatterFeed];
            break;
        default:
            if (status.syncStatus == SyncStatusFailed) {
                [self sendNotification:ResponseStatusFailed];
            }
            break;
    }
}

- (void)requestFialedWithError:(NSError *)error shouldShow:(BOOL)shouldShow
{
    if (shouldShow) {
        [self performSelectorOnMainThread:@selector(showAlert:) withObject:error waitUntilDone:NO];
    }
    else {
        if ([error actionCategory] == SMErrorActionCategoryAuthenticationReopenSession) {
            [self performSelectorOnMainThread:@selector(showAlert:) withObject:error waitUntilDone:NO];
        } else if ([[error errorEndUserMessage] custContainsString:@"request timed out"]) {
            [self performSelectorOnMainThread:@selector(showAlert:) withObject:error waitUntilDone:NO];
        }
    }
}

- (void)showAlert:(NSError *)error
{
    if (error ) {
        [[AlertMessageHandler sharedInstance] showCustomMessage:[error errorEndUserMessage]
                                                   withDelegate:nil
                                                            tag:0
                                                          title:[[TagManager sharedInstance] tagByName:kTagSyncErrorMessage]
                                              cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk]
                                           andOtherButtonTitles:nil];
    }
}

- (void)refreshData
{
    if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable]){
        [self updateUserImagesToRefresh];
        [self performSelectorInBackground:@selector(fetchChatterPosts) withObject:nil];
    }
}

- (void)sendNotification:(ChatterResponseStatus)staus
{
    [self performSelectorOnMainThread:@selector(postNotification:)
                           withObject:@{@"Status":[NSNumber numberWithInt:staus]}
                        waitUntilDone:YES];
}

- (void)postNotification:(NSDictionary *)notificationDict
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kChatterDataModified
                                                        object:self
                                                      userInfo:notificationDict];
}

- (void)updateChatterData:(NSMutableArray *)array;
{
    self.dataArray = array;
}

- (UIImage *)chatterProductImage
{
    NSString *attachmentId = [self getAttachmentId];
    
    return [UIImage imageWithContentsOfFile:[FileManager getChatterRelatedFilePath:attachmentId]];
}

- (NSString *)getAttachmentId
{
    if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable]) {
        return [ChatterHelper getdatFromChache:kChatterAttachmentId];
    }
    return [ChatterHelper getAttachmentIdForProduct:self.productId];
}

- (NSMutableArray *)ChatterDataDetails
{
    return self.dataArray;
}

- (void)postNewFeed:(ChatterFeedPost *)feed
{
    NSDictionary *dict = @{@"ParentId":feed.parentId, @"Body":feed.commentBody};

    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeChatterFeedInsert
                                             requestParam:nil
                                           callerDelegate:self];
    
    [self addRecordToRequestParam:dict taskId:taskModel.taskId];
    
    [self addTaskIds:taskModel.taskId];
    
    [[TaskManager sharedInstance] addTask:taskModel];
    
}

- (void)postFeedComment:(ChatterFeedComments *)comments
{
    NSDictionary *dict = @{@"FeedItemId":comments.feedItemId, @"CommentBody":comments.commentBody};
    
    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeChatterFeedUpdate
                                             requestParam:nil
                                           callerDelegate:self];

    [self addRecordToRequestParam:dict taskId:taskModel.taskId];
    
    [self addTaskIds:taskModel.taskId];
    
    [[TaskManager sharedInstance] addTask:taskModel];    
}


- (void)addRecordToRequestParam:(NSDictionary *)requestDict
                                   taskId:(NSString *)taskId
{
    if (self.requestParmDict == nil) {
        self.requestParmDict = [NSMutableDictionary new];
    }
    [self.requestParmDict setObject:requestDict forKey:taskId];
}

- (void)deleteParamDictForkey:(NSString *)key
{
    if ([key length] > 0) {
        [self.requestParmDict removeObjectForKey:key];
        [self.requestIdArray removeObject:key];
    }
}

- (NSDictionary *)paramDictForkey:(NSString *)key
{
    if ([key length] > 0) {
        return [self.requestParmDict objectForKey:key];
    }
    return nil;
}

- (void)cancelAllOPeration
{
    @synchronized([self class]){
        for (NSString *taskId in self.requestIdArray) {
            [[TaskManager  sharedInstance] cancelFlowNodeWithId:taskId];
        }
    }
}

- (void)clearCache
{
    self.dataArray = nil;
    self.requestParmDict = nil;
    self.productId = nil;
    self.requestIdArray = nil;
    
    [ChatterHelper clearCacheByKey:kChatterAttachmentId];
    [ChatterHelper clearCacheByKey:kChatterUserData];
}

- (void)removeUserPhotos
{
    [ChatterHelper removeAllUserImagesFromDocuments:self.productId];
}

- (void)updateUserImagesToRefresh
{
    [ChatterHelper updateUserImageToRefresh:self.productId];
}

- (void)stopAllTasks
{
    [self cancelAllOPeration];
}

@end
