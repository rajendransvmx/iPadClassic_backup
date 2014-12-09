//
//  BaseModifiedRecords.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   ModifiedRecordModel.m
 *  @class  ModifiedRecordModel
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



#import "ModifiedRecordModel.h"

@implementation ModifiedRecordModel 

@synthesize localId;
@synthesize recordLocalId;
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
@synthesize requestData;
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
	recordLocalId = nil;
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
    requestData = nil;
    requestId = nil;
}

- (void)explainMe
{
    SXLogInfo(@"recordLocalId : %@ \n sfId : %@ \n recordType : %@ \n operation : %@ \n  objectName : %@ \n parentObjectName : %@ \n parentLocalId : %@ \n  recordSent : %@ \n webserviceName : %@ \n className : %@ \n syncType : %@ \n headerLocalId : %@ \n  requestData : %@ \n requestId : %@ \n",  recordLocalId,sfId, recordType,operation,objectName, parentObjectName,parentLocalId,recordSent,webserviceName,className,syncType,headerLocalId,requestData,requestId);
}
@end