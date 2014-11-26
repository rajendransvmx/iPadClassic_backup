//
//  AttachmentHelper.h
//  ServiceMaxiPad
//
//  Created by Anoop on 10/29/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AttachmentTXModel.h"

@interface AttachmentHelper : NSObject

+(NSMutableArray*)getDocAttachmentsLinkedToParentId:(NSString*)parentsfId andOPDocsForRecordId:(NSString*)recordId;

+(NSMutableArray*)getImagesAndVideosAttachmentsLinkedToParentId:(NSString*)parentsfId;

+(NSArray*)getImagesAndVideosForUpload;

+(BOOL)revertImagesAndVideosForUpload;

+(BOOL)saveLocallyAddedAttachment:(AttachmentTXModel*)attachmentTXModel;

+(BOOL)saveDeleteAttachmentsToModifiedRecords:(NSMutableArray*)modifiedRecordsArray;

+(BOOL)deleteAttachmentsWithLocalIds:(NSArray*)localIds;

+(BOOL)updateSFIdForUploadedAttachmentModel:(AttachmentTXModel*)attachmentModel;

@end
