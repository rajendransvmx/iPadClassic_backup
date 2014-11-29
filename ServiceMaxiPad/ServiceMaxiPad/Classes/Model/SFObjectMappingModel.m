//
//  BaseSFObjectMapping.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFObjectMappingModel.m
 *  @class  SFObjectMappingModel
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

#import "SFObjectMappingModel.h"
#import "ResponseConstants.h"
@implementation SFObjectMappingModel 

@synthesize localId;
@synthesize objectMappingId;
@synthesize sourceObjectName;
@synthesize targetObjectName;

+ (NSDictionary *) getMappingDictionary {

    NSDictionary *mapDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:kObjMapId,@"objectMappingId",kObjMapSourceObjectName,@"sourceObjectName",kObjMaptargetObjectName,@"targetObjectName", nil];
    return mapDictionary;
}


- (void)dealloc
{
	objectMappingId = nil;
	sourceObjectName = nil;
	targetObjectName = nil;
}


@end