//
//  BaseSFPickList.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFPicklistModel.m
 *  @class  SFPicklistModel
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

#import "SFPicklistModel.h"

@implementation SFPicklistModel 

@synthesize localId;
@synthesize objectName;
@synthesize fieldName;
@synthesize label;
@synthesize value;
@synthesize defaultValue;
@synthesize validFor;
@synthesize indexValue;

- (id)init
{
	self = [super init];
	if (self != nil)
    {
		//Initialization 
	}
	return self;
}




@end