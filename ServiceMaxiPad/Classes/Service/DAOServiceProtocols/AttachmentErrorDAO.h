//
//  AttachmentErrorDAO.h
//  ServiceMaxiPad
//
//  Created by Vincent Sagar on 8/18/16.
//  Copyright © 2016 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonServiceDAO.h"
#import "AttachmentTXModel.h"

@protocol AttachmentErrorDAO <CommonServiceDAO>

-(NSArray*)fetchAttachmentsErrorRecordsByFields:(NSArray *)fieldNames andCriteria:(DBCriteria *)criteria withDistinctFlag:(BOOL)isDistinct;
-(BOOL)insertAttachmentErrorTableWithModel:(AttachmentTXModel *)model;
-(BOOL)updateAttachmentErrorTableWithModel:(AttachmentTXModel *)attachmentModel;
- (BOOL)deleteAttachmentsFromDBDirectoryForParentId:(NSString*)parentId;

@end