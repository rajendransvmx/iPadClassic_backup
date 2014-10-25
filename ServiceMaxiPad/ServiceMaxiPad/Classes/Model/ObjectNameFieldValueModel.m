//
//  BaseObjectNameFieldValue.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   ObjectNameFieldValueModel.m
 *  @class  ObjectNameFieldValueModel
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

#import "ObjectNameFieldValueModel.h"

@implementation ObjectNameFieldValueModel 

//@synthesize objectName;
@synthesize Id;
@synthesize value;

- (id)init {
    
	self = [super init];
	if (self != nil)
    {
		//Initialization
	}
	return self;
}

- (void)dealloc
{
	//objectName = nil;
    Id = nil;
    value = nil;
	
}

- (void)explainMe
{
   // NSLog(@"objectName : %@ \n Id : %@ \n value : %@ \n",  objectName,Id, value);
    NSLog(@"Id : %@ \n value : %@ \n",Id, value);
}


@end