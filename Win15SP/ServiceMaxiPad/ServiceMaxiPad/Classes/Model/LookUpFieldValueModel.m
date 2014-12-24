//
//  BaseLookUpFieldValue.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//


/**
 *  @file   LookUpFieldValueModel.m
 *  @class  LookUpFieldValueModel
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



#import "LookUpFieldValueModel.h"

@implementation LookUpFieldValueModel 

@synthesize localId;
@synthesize objectApiName;
@synthesize Id;
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
    objectApiName = nil;
    Id = nil;
    value = nil;
}

- (void)explainMe
{
    SXLogInfo(@"objectApiName : %@ \n Id : %@ \n value : %@ \n ",  objectApiName,Id, value);
}
@end