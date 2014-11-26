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

@interface AttachmentsUploadManager()

@property(nonatomic, strong) NSMutableArray *cUploadAttachmentLstArray;
@property(nonatomic, strong) AttachmentTXModel *uploadAttachmentModel;

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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didInternetConnectionChange) name:kNetworkConnectionChanged object:nil];
    }
    return self;
}

//TODO: Check for datasync
- (void)didInternetConnectionChange
{
    if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable] && [self.cUploadAttachmentLstArray count] && self.uploadAttachmentModel == nil)
    {
        [self startAttachmentFileUploadProcess];
    }
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
            if (![self.cUploadAttachmentLstArray containsObject:model]) {
                [self.cUploadAttachmentLstArray addObject:model];
            }
        }
        
    }
    
    if ([self.cUploadAttachmentLstArray count] > 0)
    {
        [self uploadFile:[self.cUploadAttachmentLstArray objectAtIndex:0]];
        
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
                    
                    if ([self.cUploadAttachmentLstArray count] > 0)
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
                    [self.cUploadAttachmentLstArray removeObjectAtIndex:0];
                    
                    if ([self.cUploadAttachmentLstArray count] > 0)
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
                            [self.attachmentCustomDelegate attachmentUploadStatus:NO forCategory:CategoryTypeAttachmentUpload];
                        }
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

