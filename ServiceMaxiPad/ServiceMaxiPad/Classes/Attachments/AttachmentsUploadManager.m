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


@interface AttachmentsUploadManager()

@property(nonatomic, retain)NSMutableArray *cUploadAttachmentLstArray;
@property(nonatomic, retain) AttachmentTXModel *uploadAttachmentModel;


@end


@implementation AttachmentsUploadManager
@synthesize cUploadAttachmentLstArray;
@synthesize uploadAttachmentModel;

+ (id)sharedManager {
    static AttachmentsUploadManager *sharedAttachmentsUploadManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAttachmentsUploadManager = [[self alloc] init];
    });
    return sharedAttachmentsUploadManager;
}

-(void)startAttachmentFileUploadProcess
{
    self.cUploadAttachmentLstArray = (NSMutableArray *)[AttachmentHelper getImagesAndVideosForUpload];

    if (self.cUploadAttachmentLstArray.count)
    {
        [self uploadFile:[self.cUploadAttachmentLstArray objectAtIndex:0]];
        
    }
    else
    {
        if([self.attachmentCustomDelegate conformsToProtocol:@protocol(AttachmentCustomDelegate)])
        {
            [self.attachmentCustomDelegate didNotInitiateUploadProcess];
        }
    }
}

-(void)uploadFile:(AttachmentTXModel *)model
{
    [[AttachmentsUploadManager sharedManager] setUploadAttachmentModel:model];

    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeAttachmentUpload
                                             requestParam:nil
                                           callerDelegate:self];
    [[TaskManager sharedInstance] addTask:taskModel];
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

-(BOOL)deleteFileFromQueue:(NSString *)local_Id;
{
    AttachmentTXModel *lTempModel;
    for (int i = 0; i<self.cUploadAttachmentLstArray.count; i++) {
        AttachmentTXModel *lModel = [self.cUploadAttachmentLstArray objectAtIndex:i];
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
        if (st.syncStatus == SyncStatusSuccess) {
            switch (st.category) {
                case CategoryTypeAttachmentUpload:
                {
                    [self.cUploadAttachmentLstArray removeObjectAtIndex:0];
                    
                    if (self.cUploadAttachmentLstArray.count)
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
        else if (st.syncStatus == SyncStatusFailed)
        {
            switch (st.category) {
                case CategoryTypeAttachmentUpload:
                {
                    if([self.attachmentCustomDelegate conformsToProtocol:@protocol(AttachmentCustomDelegate)])
                    {
                        [self.attachmentCustomDelegate attachmentUploadStatus:NO forCategory:CategoryTypeAttachmentUpload];
                    }
                }
                break;
                    
                default:
                break;
                    
            }
        }
    }
}

@end

