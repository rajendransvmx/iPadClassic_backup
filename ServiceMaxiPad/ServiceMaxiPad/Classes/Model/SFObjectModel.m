//
//  BaseSFObject.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFObjectModel.m
 *  @class  SFObjectModel
 *
 *  @brief
 *
 *   This is a modle class which holds all the info.
 *
 *  @author Shravya Shridhar
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "SFObjectModel.h"

@implementation SFObjectModel 

@synthesize objectName;
@synthesize keyPrefix;
@synthesize label;
@synthesize isQueryable;
@synthesize labelPlural;

- (id)init
{
	self = [super init];
	if (self != nil)
    {
		//Initialization 
	}
	return self;
}



@end