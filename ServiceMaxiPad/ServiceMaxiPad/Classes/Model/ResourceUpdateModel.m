//
//  BaseSOURCE_UPDATE.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   ResourceUpdateModel.m
 *  @class  ResourceUpdateModel
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

#import "ResourceUpdateModel.h"

@implementation ResourceUpdateModel 

@synthesize Id;
@synthesize action;
@synthesize configurationType;
@synthesize display_value;
@synthesize process;
@synthesize settingId;
@synthesize source_fieldName;
@synthesize target_fieldName;
@synthesize sourceObjectName;
@synthesize targetObjectName;

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
    Id = nil;
    action = nil;
    configurationType = nil;
	display_value = nil;
    process = nil;
	settingId = nil;
	source_fieldName = nil;
	target_fieldName = nil;
	sourceObjectName = nil;
	targetObjectName = nil;
}


@end