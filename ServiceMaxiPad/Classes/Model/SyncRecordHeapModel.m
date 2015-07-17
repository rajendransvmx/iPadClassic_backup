//
//  BaseSyncRecordsHeap.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SyncRecordHeapModel.m
 *  @class  SyncRecordHeapModel
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

#import "SyncRecordHeapModel.h"

@implementation SyncRecordHeapModel 

@synthesize sfId;
@synthesize localId;
@synthesize objectName;
@synthesize syncType;
@synthesize syncFlag;
@synthesize recordType;
@synthesize parallelSyncType;

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
    sfId = nil;
    localId = nil;
	objectName = nil;
	syncType = nil;
	recordType = nil;
    parallelSyncType = nil;
}


@end