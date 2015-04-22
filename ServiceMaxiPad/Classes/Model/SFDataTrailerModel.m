//
//  BaseSFDataTrailer_Temp.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFDataTrailerModel.m
 *  @class  SFDataTrailerModel
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

#import "SFDataTrailerModel.h"

@implementation SFDataTrailerModel 

@synthesize localId;
@synthesize sfId;
@synthesize recordType;
@synthesize operation;
@synthesize objectName;
@synthesize syncFlag;
@synthesize parentObjectName;
@synthesize parentLocalId;
@synthesize recordSent;
@synthesize webserviceName;
@synthesize className;
@synthesize syncType;
@synthesize headerLocalId;

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
    recordType = nil;
    operation = nil;
    objectName = nil;
    parentObjectName = nil;
    parentLocalId = nil;
    recordSent = nil;
    webserviceName = nil;
    className = nil;
    syncType = nil;
    headerLocalId = nil;
}


@end