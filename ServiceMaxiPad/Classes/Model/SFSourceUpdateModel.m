//
//  BaseSFSourceUpdate.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import "SFSourceUpdateModel.h"

@implementation SFSourceUpdateModel 

@synthesize Id;
@synthesize action;
@synthesize configurationType;
@synthesize displayValue;
@synthesize process;
@synthesize settingId;
@synthesize sourceFieldName;
@synthesize targetFieldName;
@synthesize sourceObjectName;
@synthesize targetObjectName;

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
    Id = nil;
    action = nil;
    configurationType = nil;
    displayValue = nil;
    process = nil;
	settingId = nil;
	sourceFieldName = nil;
	targetFieldName = nil;
	sourceObjectName = nil;
	targetObjectName = nil;
}

/**
 * + (NSDictionary *) getMappingDictionary
 *
 * @author Shubha
 *
 * @brief to get mapping dictionary
 *
 *
 *
 * @param
 * @param
 *
 * @return mapdictionary
 *
 */

+ (NSDictionary *) getMappingDictionary {
    
    NSDictionary *mapDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:kSourceUpdateId,@"Id",kSSourceUpdateProcessId,@"process",kSSourceUpdateSettingId,@"settingId",kSSourceUpdateAction,@"action",kSSourceUpdateConfigType,@"configurationType",kSSourceUpdateDisplayValue,@"displayValue",kSSourceUpdateSrcFieldName,@"sourceFieldName",kSSourceUpdatetargetFieldName,@"targetFieldName", nil];
    return mapDictionary;
}
@end