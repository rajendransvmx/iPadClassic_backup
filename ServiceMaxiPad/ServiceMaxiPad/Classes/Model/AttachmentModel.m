//
//  AttachmentModel.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   AttachmentModel.m
 *  @class  AttachmentModel
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

#import "AttachmentModel.h"

@implementation AttachmentModel 

@synthesize attachmentId;
@synthesize attachmentName;
@synthesize parentId;
@synthesize attachmentBody;

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
	attachmentName = nil;
	parentId = nil;
    attachmentBody = nil;
}

- (void)explainMe
{
    NSLog(@"attachmentId : %@ \n attachmentName : %@ \n parentId : %@ \n attachmentBody : %@ \n ",  attachmentId,attachmentName, parentId, attachmentBody);
}

+ (NSDictionary*)getMappingDictionary {
    
    NSDictionary *mapDictionary = [[NSDictionary alloc] initWithObjectsAndKeys: kAttachmentId, @"attachmentId", kAttachmentName, @"attachmentName", kAttachmentParentId, @"parentId", kAttachmentBody, @"attachmentBody", nil];
    
    return mapDictionary;
}

@end