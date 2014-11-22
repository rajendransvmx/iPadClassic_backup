//
//  BaseSFRTPicklist.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFRTPicklistModel.m
 *  @class  SFRTPicklistModel
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

#import "SFRTPicklistModel.h"

@implementation SFRTPicklistModel 

@synthesize localId;
@synthesize objectAPIName;
@synthesize recordTypeName;
@synthesize recordTypeLayoutID;
@synthesize recordTypeID;
@synthesize fieldAPIName;
@synthesize label;
@synthesize value;
@synthesize defaultLabel;
@synthesize defaultValue;

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
    objectAPIName = nil;
    recordTypeName = nil;
    recordTypeLayoutID = nil;
    recordTypeID = nil;
    fieldAPIName = nil;
    label = nil;
    value = nil;
    defaultLabel = nil;
    defaultValue = nil;
}


@end