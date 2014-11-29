//
//  BaseOn_demand_download.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   DODRecordsModel.m
 *  @class  DODRecordsModel
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

#import "DODRecordsModel.h"

@implementation DODRecordsModel 

@synthesize objectName;
@synthesize sfId;
@synthesize recordType;
@synthesize timeStamp;

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
	recordType = nil;
}

- (void)explainMe
{
    NSLog(@"objectName : %@ \n sfId : %@ \n recordType : %@ \n  timeStamp : %@ \n ",  objectName,sfId, recordType, timeStamp);
}

@end