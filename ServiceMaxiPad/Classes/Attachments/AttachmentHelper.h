//
//  AttachmentHelper.h
//  ServiceMaxiPad
//
//  Created by Anoop on 10/29/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AttachmentTXModel.h"
#import "AttachmentLocalModel.h"

@interface AttachmentHelper : NSObject

+(NSMutableArray*)getDocAttachmentsLinkedToParentId:(NSString*)parentsfId andOPDocsForRecordId:(NSString*)recordId;

+(NSMutableArray*)getImagesAndVideosAttachmentsLinkedToParentId:(NSString*)parentsfId;

+(NSArray*)getLocalIdsOfDeleteAttachmentsFromModifiedRecordsForParentId:(NSString*)parentId;

+(BOOL)revertDeleteAttachmentsFromModifiedRecordsForParentId:(NSString*)parentId;

+(NSArray*)getImagesAndVideosForUpload;

+(BOOL)revertImagesAndVideosForUpload;

+(NSArray*)getImagesAndVideosForUploadForParentId:(NSString*)parentId;

+(BOOL)revertImagesAndVideosForUploadForParentId:(NSString*)parentId;

+(BOOL)saveLocallyAddedAttachment:(AttachmentTXModel*)attachmentTXModel;

+(BOOL)saveDeleteAttachmentsToModifiedRecords:(NSMutableArray*)modifiedRecordsArray;

+(BOOL)deleteAttachmentsWithLocalIds:(NSArray*)localIds;

+(BOOL)updateSFIdForUploadedAttachmentModel:(AttachmentTXModel*)attachmentModel;

+(BOOL)saveAttachmentLocalModelToDB:(AttachmentLocalModel*)localModel;

+(BOOL)deleteAttachmentLocalModelFromDB:(NSString*)parentLocalId;

+(NSArray*)getAllLocalAttachments;

+(BOOL)updateSFIdInAttachmentForCurrentParentLocalId:(NSString*)parentLocalId toParentId:(NSString*)parentId;

+(void)deleteAttachmentsFromDBDirectoryForParentId:(NSString*)parentId;

@end
