//
//  BaseSFObjectMappingComponent.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFObjectMappingComponentModel.m
 *  @class  SFObjectMappingComponentModel
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

#import "SFObjectMappingComponentModel.h"
#import "ResponseConstants.h"

@implementation SFObjectMappingComponentModel

@synthesize localId;
@synthesize objectMappingId;
@synthesize sourceFieldName;
@synthesize targetFieldName;
@synthesize mappingValue;
@synthesize mappingComponentType;
@synthesize mappingValueFlag;
@synthesize preference2;
@synthesize preference3;

+ (NSDictionary *) getMappingDictionary {
    
    NSDictionary *mapDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:kObjMapCompId,@"objectMappingId",kObjMapCompSourceFieldName,@"sourceFieldName",kObjMapCompTargetFieldName,@"targetFieldName",kObjMapCompMappingValue,@"mappingValue",kObjMapCompPreference2,@"preference2",kObjMapCompPreference3,@"preference3", nil];
    return mapDictionary;
}

- (void)dealloc
{
    objectMappingId = nil;
    sourceFieldName = nil;
    targetFieldName = nil;
    mappingValue = nil;
    mappingComponentType = nil;
    preference2 = nil;
    preference3 = nil;
}


@end