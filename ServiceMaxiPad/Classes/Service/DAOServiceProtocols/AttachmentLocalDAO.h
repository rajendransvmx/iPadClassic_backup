//
//  AttachmentLocalDAO.h
//  ServiceMaxMobile
//
//  Created by Anoop on 03/13/2015.
//  Copyright (c) 2015 Servicemax. All rights reserved.
//

/**
 *  @file   AttachmentLocalDAO.h
 *  @class  AttachmentLocalDAO
 *
 *  @brief  This protocol class for AttachmentLocalService
 *
 *
 *
 *  @author  Anoopsaai Ramani
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2015 ServiceMax, Inc. All rights reserved.
 *
 **/


#import <Foundation/Foundation.h>
#import "CommonServiceDAO.h"
#import "AttachmentLocalModel.h"

@protocol AttachmentLocalDAO <CommonServiceDAO>

-(NSArray*)fetchAllRecordsFromLocalAttachment;
-(NSArray*)fetchRecordsFromLocalAttachmentFields:(NSArray*)fields
                                    andCriterias:(NSArray*)criterias;
-(BOOL)saveAttachmentLocalModel:(AttachmentLocalModel*)attachmentLocalModel;
-(BOOL)saveAttachmentLocalModels:(NSMutableArray*)attachmentLocalModels;
-(BOOL)deleteRecordsWithParentLocalIds:(NSArray *)parentLocalIds;
-(BOOL)deleteRecordWithParentLocalId:(NSString *)parentLocalId;

@end
