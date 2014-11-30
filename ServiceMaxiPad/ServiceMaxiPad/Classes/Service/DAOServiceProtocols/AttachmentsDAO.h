//
//  AttachmentsDAO.h
//  ServiceMaxMobile
//
//  Created by Anoop on 8/21/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   AttachmentsDAO.h
 *  @class  AttachmentsDAO
 *
 *  @brief  This protocol class for AttachmentsService
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
#import "AttachmentModel.h"

@protocol AttachmentsDAO <CommonServiceDAO>

- (NSArray*)getAttachmentIdsToBeDownloaded;

-(void)updateAttachmentTableWithModelArray:(NSArray*)modelArray;


@end
