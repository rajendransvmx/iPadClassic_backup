//
//  AttachmentsServerHelper.m
//  ServiceMaxiPad
//
//  Created by Admin on 10/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "AttachmentsUploadManager.h"
#import "TaskModel.h"
#import "TaskGenerator.h"
#import "TaskManager.h"
#import "WebserviceResponseStatus.h"
#import "AttachmentHelper.h"
#import "SNetworkReachabilityManager.h"
#import "TagManager.h"
#import "TagConstant.h"
#import "AlertMessageHandler.h"
#import "AppManager.h"
#import "SyncManager.h"
#import "AttachmentLocalModel.h"
#import "SFMPageHelper.h"
#import "StringUtil.h"

@interface AttachmentsUploadManager()

@property(nonatomic, strong) NSMutableArray *cUploadAttachmentLstArray;
@property(nonatomic, strong) AttachmentTXModel *uploadAttachmentModel;
@property(nonatomic, strong) UIAlertView *tokenAlert;

@end

@implementation AttachmentsUploadManager
@synthesize cUploadAttachmentLstArray;
@synthesize uploadAttachmentModel;

+ (id)sharedManager
{
    static AttachmentsUploadManager *sharedAttachmentsUploadManager = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedAttachmentsUploadManager = [[AttachmentsUploadManager alloc] init];
    });
    return sharedAttachmentsUploadManager;
}

- (id)init {
    
    self = [super init];
    
    if (self != nil)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataSyncFinished:) name:kDataSyncStatusNotification object:nil];
    }
    return self;
}

- (void)startAttachmentFileUploadProcess
{
    NSArray *lTempArray = [AttachmentHelper getImagesAndVideosForUpload];
    
    if (!self.cUploadAttachmentLstArray) {
        self.cUploadAttachmentLstArray =[[NSMutableArray alloc] initWithArray:lTempArray];

    }
    else
    {
        for (AttachmentTXModel *model in lTempArray) {

            BOOL isDuplicate = NO;
            for (AttachmentTXModel *uploadModel in self.cUploadAttachmentLstArray)
            {
                if ([uploadModel.localId isEqualToString:model.localId]) {
                    isDuplicate = YES;
                    break;
                }
            }
            if(!isDuplicate)
              [self.cUploadAttachmentLstArray addObject:model];
        }
        
    }
    
    if ([self.cUploadAttachmentLstArray count] && [[SNetworkReachabilityManager sharedInstance] isNetworkReachable])
    {
        [self uploadFile:[self.cUploadAttachmentLstArray objectAtIndex:0]];
        
        
    }
    
}

-(void)uploadFile:(AttachmentTXModel *)model
{
    if (![self isFileUploading:model.localId])
    {
        if ([[AppManager sharedInstance] hasTokenRevoked])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (![self.tokenAlert isVisible])
                {
                    self.tokenAlert = [[UIAlertView alloc] initWithTitle:[[TagManager sharedInstance]tagByName:kTagSyncErrorMessage] message:[[TagManager sharedInstance] tagByName:kTag_RemoteAccessRevokedMsg] delegate:self cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] otherButtonTitles:nil];
                    [self.tokenAlert show];
                }
                
            });
        }
        else
        {
            [[AttachmentsUploadManager sharedManager] setUploadAttachmentModel:model];
            
            TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeAttachmentUpload
                                                     requestParam:nil
                                                   callerDelegate:self];
            [[TaskManager sharedInstance] addTask:taskModel];
        }
    }
}


-(BOOL)isFileUploading:(NSString *)local_Id;
{
    if ([self.uploadAttachmentModel.localId isEqualToString:local_Id]) {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)hasAttachmentInQueue:(NSString*)local_Id {
    
    for (AttachmentTXModel *lModel in self.cUploadAttachmentLstArray)
    {
        if ([lModel.localId isEqualToString:local_Id])
        {
            return YES;
            break;
        }
    }
    return NO;
}

-(BOOL)deleteFileFromQueue:(NSString *)local_Id;
{
    AttachmentTXModel *lTempModel;
    for (AttachmentTXModel *lModel in self.cUploadAttachmentLstArray) {
        if ([lModel.localId isEqualToString:local_Id]) {
            lTempModel = lModel;
            break;
        }
    }
    if ([self isFileUploading:lTempModel.localId]) {
        return NO;
    }
    else
    {
        [self.cUploadAttachmentLstArray removeObject:lTempModel];
        return YES;
    }
}

-(AttachmentTXModel *)modelUnderUploadProcess;
{
    return self.uploadAttachmentModel;
}

- (void)flowStatus:(id)status;
{
    if([status isKindOfClass:[WebserviceResponseStatus class]])
    {
        WebserviceResponseStatus *st = (WebserviceResponseStatus*)status;
        if (st.syncStatus == SyncStatusSuccess)
        {
            switch (st.category)
            {
                case CategoryTypeAttachmentUpload:
                {
                    [self.cUploadAttachmentLstArray removeObjectAtIndex:0];
                    
                    if ([self.cUploadAttachmentLstArray count])
                    {
                        [self uploadFile:[self.cUploadAttachmentLstArray objectAtIndex:0]];
                    }
                    else
                    {
                        //Free-up the memory allocated
                        [[AttachmentsUploadManager sharedManager] setUploadAttachmentModel:nil];
                        [[AttachmentsUploadManager sharedManager] setCUploadAttachmentLstArray:nil];

                        //Call the
                        if([self.attachmentCustomDelegate conformsToProtocol:@protocol(AttachmentCustomDelegate)])
                        {
                            [self.attachmentCustomDelegate attachmentUploadStatus:YES forCategory:CategoryTypeAttachmentUpload];
                        }
                    }
                }
                    break;
                    
                default:
                    break;
            }
        }
        else if (st.syncStatus == SyncStatusFailed || st.syncStatus == SyncStatusConflict || st.syncStatus == SyncStatusNetworkError || st.syncStatus == SyncStatusRefreshTokenFailedWithError)
        {
            switch (st.category) {
                case CategoryTypeAttachmentUpload:
                {
                    [self.cUploadAttachmentLstArray removeObjectAtIndex:0];
                    
                    if ([self.cUploadAttachmentLstArray count])
                    {
                        [self uploadFile:[self.cUploadAttachmentLstArray objectAtIndex:0]];
                    }
                    else
                    {
                        //Free-up the memory allocated
                        [[AttachmentsUploadManager sharedManager] setUploadAttachmentModel:nil];
                        [[AttachmentsUploadManager sharedManager] setCUploadAttachmentLstArray:nil];
                    }
                    //Call the
                    if([self.attachmentCustomDelegate conformsToProtocol:@protocol(AttachmentCustomDelegate)])
                    {
                        [self.attachmentCustomDelegate attachmentUploadStatus:NO forCategory:CategoryTypeAttachmentUpload];
                    }
                    [[AlertMessageHandler sharedInstance] showCustomMessage:[st.syncError errorEndUserMessage] withDelegate:self tag:1 title:[[TagManager sharedInstance]tagByName:kTagSyncErrorMessage] cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] andOtherButtonTitles:nil];
                    SXLogError(@"Attachment images and videos upload failed with info:%@",st.syncError.localizedDescription);

                }
                break;
                    
                default:
                break;
                    
            }
        }
    }
}

-(void)dataSyncFinished:(NSNotification *)pNotification
{
        
    SyncManager *lSyncManager = (SyncManager *) pNotification.object;
    SyncStatus syncStatus = [lSyncManager getSyncStatusFor:SyncTypeData];
    
    if(syncStatus == SyncStatusSuccess)
    {
        NSArray *allLocalAttachments = [AttachmentHelper getAllLocalAttachments];
        for (AttachmentLocalModel *attachmentLocalModel in allLocalAttachments)
        {
            NSString *parentId = [SFMPageHelper getSfIdForLocalId:attachmentLocalModel.parentLocalId objectName:attachmentLocalModel.parentObjectName];
            if (![StringUtil isStringEmpty:parentId])
            {
               BOOL isUpdated = [AttachmentHelper updateSFIdInAttachmentForCurrentParentLocalId:attachmentLocalModel.parentLocalId toParentId:parentId];
                
                if (isUpdated)
                {
                    [AttachmentHelper deleteAttachmentLocalModelFromDB:attachmentLocalModel.parentLocalId];
                }
            }
            
        }
        [self startAttachmentFileUploadProcess];
    }
}

- (void)dealloc
{
   [[NSNotificationCenter defaultCenter] removeObserver:self name:kDataSyncStatusNotification object:nil];
   cUploadAttachmentLstArray = nil;
   uploadAttachmentModel = nil;
   _tokenAlert = nil;
    
}

@end

