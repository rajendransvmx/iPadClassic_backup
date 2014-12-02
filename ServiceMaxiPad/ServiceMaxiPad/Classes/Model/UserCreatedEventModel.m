//
//  BaseUserCreatedEvent.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   UserCreatedEventModel.m
 *  @class  UserCreatedEventModel
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

#import "UserCreatedEventModel.h"

@implementation UserCreatedEventModel 

@synthesize objectName;
@synthesize sfId;
@synthesize localId;

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
    objectName = nil;
    sfId = nil;
    localId = nil;
}


@end