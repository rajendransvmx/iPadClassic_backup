//
//  BaseMobileDeviceTags.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   MobileDeviceTagModel.m
 *  @class  MobileDeviceTagModel
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


#import "MobileDeviceTagModel.h"

@implementation MobileDeviceTagModel 

@synthesize localId;
@synthesize tagId;
@synthesize value;

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
	tagId = nil;
	value = nil;
}

- (void)explainMe
{
    SXLogInfo(@"tagId : %@ \n value : %@ \n ",  tagId,value);
}


@end