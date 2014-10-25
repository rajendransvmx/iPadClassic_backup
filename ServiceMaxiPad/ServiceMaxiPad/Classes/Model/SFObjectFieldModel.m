//
//  BaseSFObjectField.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFObjectFieldModel.m
 *  @class  SFObjectFieldModel
 *
 *  @brief
 *
 *   This is a modle class which holds all the info.
 *
 *  @author Shravya Shridhar
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "SFObjectFieldModel.h"

@implementation SFObjectFieldModel 

@synthesize localId;
@synthesize unique;
@synthesize restrictedPicklist;
@synthesize calculated;
@synthesize defaultedOnCreate;
@synthesize fieldName;
@synthesize type;
@synthesize objectName;
@synthesize label;
@synthesize relationName;
@synthesize referenceTo;
@synthesize controlerField;
@synthesize nameField;
@synthesize dependentPicklist;
@synthesize precision;
@synthesize length;
@synthesize isNillable;

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