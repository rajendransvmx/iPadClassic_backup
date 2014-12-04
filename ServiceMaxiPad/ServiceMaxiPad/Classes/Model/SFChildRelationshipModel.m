//
//  BaseSFChildRelationship.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//


/**
 *  @file   SFChildRelationshipModel.m
 *  @class  SFChildRelationshipModel
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

#import "SFChildRelationshipModel.h"
#import "RequestConstants.h"
#import "StringUtil.h"

@implementation SFChildRelationshipModel 

@synthesize localId;
@synthesize objectNameParent;
@synthesize objectNameChild;
@synthesize fieldName;

- (id)init
{
	self = [super init];
	if (self != nil)
    {
		//Initialization
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary *)jsonDictionary {
    self = [super init];
	if (self != nil)
    {
        
		//Initialization
        NSString *key = [jsonDictionary objectForKey:kSVMXRequestKey];
        if ([StringUtil isStringEmpty:key]) {
            key = @"";
        }
        self.objectNameChild = key;
        
        NSString *value = [jsonDictionary objectForKey:kSVMXRequestValue];
        if ([StringUtil isStringEmpty:value]) {
            value = @"";
        }
        self.fieldName = value;
        
	}
	return self;
}



@end