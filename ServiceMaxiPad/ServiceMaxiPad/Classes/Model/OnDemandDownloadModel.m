//
//  BaseOn_demand_download.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   OnDemandDownloadModel.m
 *  @class  OnDemandDownloadModel
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

#import "OnDemandDownloadModel.h"

@implementation OnDemandDownloadModel 

@synthesize objectName;
@synthesize sfId;
@synthesize localId;
@synthesize recordType;
@synthesize jsonRecord;

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
    localId = nil;
	recordType = nil;
	jsonRecord = nil;
}

- (void)explainMe
{
    NSLog(@"objectName : %@ \n sfId : %@ \n localId : %@ \n recordType : %@ \n  jsonRecord : %@ \n ",  objectName,sfId, localId, recordType,jsonRecord);
}

@end