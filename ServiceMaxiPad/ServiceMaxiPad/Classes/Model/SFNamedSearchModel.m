//
//  BaseSFNamedSearch.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFNamedSearchModel.m
 *  @class  SFNamedSearchModel
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

#import "SFNamedSearchModel.h"
#import "ResponseConstants.h"

@implementation SFNamedSearchModel

@synthesize namedSearchId;
@synthesize searchSfid;
@synthesize searchName;
@synthesize objectName;
@synthesize searchType;
@synthesize noOfLookupRecords;
@synthesize defaultLookupColumn;
@synthesize isDefault;
@synthesize isStandard;

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
    namedSearchId = nil;
    searchSfid = nil;
    searchName = nil;
    objectName = nil;
    searchType = nil;
    noOfLookupRecords = nil;
	defaultLookupColumn = nil;
}

- (void)explainMe {
    
    NSLog(@"namedSearchId : %@ \n searchSfid : %@ \n searchName : %@ \n objectName : %@ \n searchType : %@ \n noOfLookupRecords : %@ \n defaultLookupColumn : %@ \n isDefault : %d \n isStandard : %d \n", namedSearchId, searchSfid, searchName, objectName, searchType, noOfLookupRecords, defaultLookupColumn, isDefault, isStandard);
}

+ (NSDictionary*)getMappingDictionary {
    
    NSDictionary *mapDictionary = [[NSDictionary alloc] initWithObjectsAndKeys: kNamedSearchId, @"namedSearchId", kNamedSearchProcessID, @"searchSfid", kNamedSearchName, @"searchName", kNamedSearchSourceObjName, @"objectName", kNamedSearchRuleType, @"searchType", kNamedSearchNoOfLookupRecs, @"noOfLookupRecords", kNamedSearchLookupColumn, @"defaultLookupColumn", kNamedSearchIsDefault, @"isDefault", kNamedSearchIsStandard, @"isStandard", nil];
    
    return mapDictionary;
}

@end