//
//  BaseSFProcess.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFProcessModel.m
 *  @class  SFProcessModel
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

#import "SFProcessModel.h"
#import "ResponseConstants.h"
@implementation SFProcessModel 


@synthesize localId;
@synthesize processId;
@synthesize objectApiName;
@synthesize processType;
@synthesize processName;
@synthesize processDescription;
@synthesize pageLayoutId;
@synthesize processInfo;
@synthesize sfID;
@synthesize docTemplateId;

- (id)init
{
	self = [super init];
	if (self != nil)
    {
		//Initialization
	}
	return self;
}
+ (NSDictionary *) getMappingDictionary {
        
    NSDictionary *mapDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:kProcessUniqueId,@"processId",kProcessSFID,@"sfID",kProcessType,@"processType", kProcessName, @"processName",kProcessDesc,@"processDescription",kPageLayoutId,@"pageLayoutId", kObjectApiName,@"objectApiName",kDocTemplate,@"docTemplateId", nil];
    
    return mapDictionary;
}




- (void)dealloc
{
    processId = nil;
    objectApiName = nil;
    processType = nil;
    processName = nil;
	processDescription = nil;
    pageLayoutId = nil;
    processInfo = nil;
    sfID = nil;
	docTemplateId = nil;
}


@end