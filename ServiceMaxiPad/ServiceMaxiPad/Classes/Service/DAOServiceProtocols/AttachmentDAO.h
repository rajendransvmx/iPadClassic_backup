//
//  AttachmentDAO.h
//  ServiceMaxMobile
//
//  Created by Anoop on 8/21/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   AttachmentDAO.h
 *  @class  AttachmentDAO
 *
 *  @brief  This protocol class for AttachmentService
 *
 *
 *
 *  @author  Anoopsaai Ramani
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/


#import <Foundation/Foundation.h>
#import "CommonServiceDAO.h"
#import "AttachmentTXModel.h"

@protocol AttachmentDAO <CommonServiceDAO>

-(void)updateAttachmentTableWithModelArray:(NSArray*)modelArray;
-(NSArray*)fetchRecordsByFields:(NSArray *)fieldNames andCriteria:(DBCriteria *)criteria withDistinctFlag:(BOOL)isDistinct;

@end
