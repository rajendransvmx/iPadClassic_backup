//
//  BaseStaticResource.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   StaticResourceModel.m
 *  @class  StaticResourceModel
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

#import "StaticResourceModel.h"

@implementation StaticResourceModel 

@synthesize Id;
@synthesize Name;

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
    Name = nil;
}

+ (NSDictionary *)getMappingDictionary
{
    NSDictionary *mapDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:kStaticResourceId,@"Id",kStaticResourceName,@"Name",nil];
    
    return mapDictionary;
}

@end