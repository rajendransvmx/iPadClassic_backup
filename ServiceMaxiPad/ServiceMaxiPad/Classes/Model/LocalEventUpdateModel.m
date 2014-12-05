//
//  BaseLocal_event_update.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//


/**
 *  @file   LocalEventUpdateModel.m
 *  @class  LocalEventUpdateModel
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



#import "LocalEventUpdateModel.h"

@implementation LocalEventUpdateModel 

@synthesize objectName;
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
    localId = nil;
}

- (void)explainMe
{
    SXLogInfo(@"objectName : %@ \n localId : %@ \n ",  objectName,localId);
}

@end