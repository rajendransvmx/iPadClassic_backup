//
//  BaseSyncErrorConflict.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SyncErrorConflictModel.m
 *  @class  SyncErrorConflictModel
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

#import "SyncErrorConflictModel.h"

@implementation SyncErrorConflictModel 

@synthesize sfId;
@synthesize localId;
@synthesize objectName;
@synthesize recordType;
@synthesize syncType;
@synthesize errorMessage;
@synthesize operationType;
@synthesize errorType;
@synthesize overrideFlag;
@synthesize className;
@synthesize methodName;
@synthesize customWsError;
@synthesize requestId;

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
	recordType = nil;
    syncType = nil;
    errorMessage = nil;
    operationType = nil;
    errorType = nil;
    overrideFlag = nil;
    className = nil;
    methodName = nil;
    customWsError = nil;
    requestId = nil;
}


@end