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
@synthesize timeStamp;
@synthesize fieldsModified;
@synthesize overrideFlag;
@synthesize Pending;
@synthesize customActionFlag;
- (id)init
{
	self = [super init];
	if (self != nil)
    {
		//Initialization
	}
	return self;
}
-(void)addValuefromDictionary:(NSDictionary *)dict
{
    
    if ([dict objectForKey:@"localId"]) {
        localId = [[dict valueForKey:@"localId"] integerValue];
    }
    if ([dict objectForKey:@"recordLocalId"]) {
        recordLocalId = [dict valueForKey:@"recordLocalId"];
    }
    if ([dict objectForKey:@"sfId"]) {
        sfId = [dict valueForKey:@"sfId"];
    }
    if ([dict objectForKey:@"recordType"]) {
        recordType = [dict valueForKey:@"recordType"];
    }
    if ([dict objectForKey:@"operation"]) {
        operation = [dict valueForKey:@"operation"];
    }
    if ([dict objectForKey:@"objectName"]) {
        objectName = [dict valueForKey:@"objectName"];
    }
    if ([dict objectForKey:@"syncFlag"]) {
        syncFlag = [[dict valueForKey:@"syncFlag"] boolValue];
    }
    if ([dict objectForKey:@"parentObjectName"]) {
        parentObjectName = [dict valueForKey:@"parentObjectName"];
    }
    if ([dict objectForKey:@"parentLocalId"]) {
        parentLocalId = [dict valueForKey:@"parentLocalId"];
    }
    if ([dict objectForKey:@"recordSent"]) {
        recordSent = [dict valueForKey:@"recordSent"];
    }
    if ([dict objectForKey:@"webserviceName"]) {
        webserviceName = [dict valueForKey:@"webserviceName"];
    }
    if ([dict objectForKey:@"className"]) {
        className = [dict valueForKey:@"className"];
    }
    if ([dict objectForKey:@"syncType"]) {
        syncType = [dict valueForKey:@"syncType"];
    }
    if ([dict objectForKey:@"headerLocalId"]) {
        headerLocalId = [dict valueForKey:@"headerLocalId"];
    }
    if ([dict objectForKey:@"requestData"]) {
        requestData = [dict valueForKey:@"requestData"];
    }
    if ([dict objectForKey:@"requestId"]) {
        requestId = [dict valueForKey:@"requestId"];
    }
    if ([dict objectForKey:@"timeStamp"]) {
        timeStamp = [dict valueForKey:@"timeStamp"];
    }
    if ([dict objectForKey:@"fieldsModified"]) {
        fieldsModified = [dict valueForKey:@"fieldsModified"];
    }
    if ([dict objectForKey:@"overrideFlag"]) {
        overrideFlag = [dict valueForKey:@"overrideFlag"];
    }
    if ([dict objectForKey:@"Pending"]) {
        Pending = [dict valueForKey:@"Pending"];
    }
    if ([dict objectForKey:@"overrideFlag"]) {
        overrideFlag = [dict valueForKey:@"overrideFlag"];
    }
    if ([dict objectForKey:@"customActionFlag"]) {
        customActionFlag = [[dict valueForKey:@"customActionFlag"]boolValue];
    }
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
    timeStamp = nil;
    fieldsModified = nil;
    Pending = nil;
}

- (void)explainMe
{
    SXLogInfo(@"recordLocalId : %@ \n sfId : %@ \n recordType : %@ \n operation : %@ \n  objectName : %@ \n parentObjectName : %@ \n parentLocalId : %@ \n  recordSent : %@ \n webserviceName : %@ \n className : %@ \n syncType : %@ \n headerLocalId : %@ \n  requestData : %@ \n requestId : %@ \n timeStamp : %@,fieldsModified = %@",  recordLocalId,sfId, recordType,operation,objectName, parentObjectName,parentLocalId,recordSent,webserviceName,className,syncType,headerLocalId,requestData,requestId,timeStamp,fieldsModified);
}
@end
