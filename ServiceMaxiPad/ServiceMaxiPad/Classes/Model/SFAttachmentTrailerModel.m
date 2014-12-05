//
//  BaseSFAttachmentTrailer.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFAttachmentTrailerModel.h
 *  @class  SFAttachmentTrailerModel
 *
 *  @brief
 *
 *   This is a modle class which holds all the info.
 *
 *  @author Shubha S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "SFAttachmentTrailerModel.h"

@implementation SFAttachmentTrailerModel 

@synthesize localId;
@synthesize priority;
@synthesize attachment_id;
@synthesize objectName;
@synthesize parent_localid;
@synthesize parent_sfid;
@synthesize file_name;
@synthesize type;
@synthesize size;
@synthesize status;
@synthesize action;

- (id)init
{
	self = [super init];
	if (self != nil)
    {
		//Initialization
	}
	return self;
}

- (void)dealloc
{
    attachment_id = nil;
    objectName = nil;
    parent_localid = nil;
    parent_sfid = nil;
    file_name = nil;
    type = nil;
	status = nil;
	action = nil;
}

- (void)explainMe
{
    SXLogInfo(@"attachment_id : %@ \n objectName : %@ \n parent_localid : %@ \n parent_sfid : %@ \n  file_name : %@ \n type : %@ \n status : %@ \n  action : %@ \n ",  attachment_id,objectName, parent_localid, parent_sfid,file_name,type,status,action);
}

@end