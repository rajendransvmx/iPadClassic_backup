//
//  BaseSFRequiredPdf.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFRequiredPdfModel.m
 *  @class  SFRequiredPdfModel.m
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

#import "SFRequiredPdfModel.h"

@implementation SFRequiredPdfModel 

@synthesize processId;
@synthesize recordId;
@synthesize attachmentId;

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
    
	processId = nil;
	recordId = nil;
	attachmentId = nil;
}


@end