//
//  BaseExistsSyncHistory.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SyncHistoryModel.m
 *  @class  SyncHistoryModel
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


#import "SyncHistoryModel.h"

@implementation SyncHistoryModel 

@synthesize syncType;
@synthesize requestId;
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
    syncType = nil;
	requestId = nil;
}

- (void)explainMe
{
    NSLog(@"syncType : %@ \n requestId : %@ \n ",  syncType,requestId);
}

@end