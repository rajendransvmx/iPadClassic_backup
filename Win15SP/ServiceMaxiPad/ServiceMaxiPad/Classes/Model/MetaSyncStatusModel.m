//
//  BaseMetaSyncStatus.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   MetaSyncStatusModel.m
 *  @class  MetaSyncStatusModel
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



#import "MetaSyncStatusModel.h"

@implementation MetaSyncStatusModel 

@synthesize syncStatus;

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
    syncStatus = nil;
}

- (void)explainMe
{
    SXLogInfo(@"syncStatus : %@ \n ",  syncStatus);
}


@end