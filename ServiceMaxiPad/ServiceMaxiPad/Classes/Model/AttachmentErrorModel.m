//
//  AttachmentErrorModel.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   AttachmentErrorModel.m
 *  @class  AttachmentErrorModel
 *
 *  @brief This model holds the attachment info
 *
 *   This is a modle class whicg holds all the info.
 *
 *  @author Shubha S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/


#import "AttachmentErrorModel.h"

@implementation AttachmentErrorModel

@synthesize attachmentId;
@synthesize errorMessage;
@synthesize fileName;
@synthesize syncFlag;
@synthesize type;
@synthesize parentLocalId;
@synthesize status;
@synthesize action;
@synthesize parentSfId;

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
    attachmentId = nil;
    errorMessage = nil;
    fileName = nil;
	syncFlag = nil;
    type  = nil;
	parentLocalId = nil;
    status = nil;
    action = nil;
    parentSfId = nil;
}

- (void)explainMe
{
       NSLog(@"attachmentId : %@ \n errorMessage : %@ \n fileName : %@ \n syncFlag : %@ \n type : %@ \n parentLocalId : %@ \n status : %@ \n action : %@ \n parentSfId : %@ \n ",  attachmentId,errorMessage, fileName, syncFlag, type, parentLocalId, status, action, parentSfId);
}

@end