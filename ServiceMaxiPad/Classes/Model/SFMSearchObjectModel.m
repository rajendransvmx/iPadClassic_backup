//
//  BaseSFM_SearchObjects.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFMSearchObjectModel.m
 *  @class  SFMSearchObjectModel
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

#import "SFMSearchObjectModel.h"
#import "ResponseConstants.h"
@implementation SFMSearchObjectModel 

@synthesize moduleId;
@synthesize name;
//@synthesize searchProcessSfId;
@synthesize searchProcessUniqueId;
@synthesize targetObjectName;
@synthesize advancedExpression;
@synthesize parentObjectCriteria;
@synthesize objectId;
@synthesize searchFields;
@synthesize displayFields;
@synthesize sortFields;
@synthesize sequence;
- (void)dealloc
{
    moduleId = nil;
    name = nil;
    //searchProcessSfId = nil;
    searchProcessUniqueId = nil;
    targetObjectName = nil;
    advancedExpression = nil;
    parentObjectCriteria = nil;
    objectId = nil;
    searchFields = nil;
    displayFields = nil;
    sortFields = nil;
}
+ (NSDictionary *) getMappingDictionary {
    
    NSDictionary *mapDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:kSfmSearchObjId,@"objectId",kSfmSearchObjProcessID,@"searchProcessUniqueId",kSfmSearchObjTargetObjName,@"targetObjectName", kSfmSearchObjModule,@"moduleId",kSfmSearchObjAdvExpr,@"advancedExpression",kSfmSearchObjParentObjCriteria,@"parentObjectCriteria",kSfmSearchObjName,@"name",kSearchCriteriaSequence,@"sequence", nil];
    
    return mapDictionary;
}


@end