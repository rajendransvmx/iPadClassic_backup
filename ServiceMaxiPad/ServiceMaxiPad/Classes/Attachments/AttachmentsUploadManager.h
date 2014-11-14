//
//  AttachmentsServerHelper.h
//  ServiceMaxiPad
//
//  Created by Admin on 10/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AttachmentTXModel.h"
#import "SyncConstants.h"

@protocol AttachmentCustomDelegate <NSObject>

- (void)attachmentUploadStatus:(BOOL)status forCategory:(CategoryType)category;

- (void)didNotInitiateUploadProcess;
@end


@interface AttachmentsUploadManager : NSObject

@property(nonatomic, assign) id <AttachmentCustomDelegate> attachmentCustomDelegate;

+ (id)sharedManager;

-(void)startAttachmentFileUploadProcess;

-(BOOL)isFileUploading:(NSString *)local_Id;
-(BOOL)deleteFileFromQueue:(NSString *)local_Id;
-(AttachmentTXModel *)modelUnderUploadProcess;
@end
