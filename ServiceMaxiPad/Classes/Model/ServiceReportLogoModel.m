//
//  BaseServicereprtLogo.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   ServiceReportLogoModel.m
 *  @class  ServiceReportLogoModel
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

#import "ServiceReportLogoModel.h"

@implementation ServiceReportLogoModel 

@synthesize logo;

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
    logo = nil;
}

- (void)explainMe
{
    SXLogInfo(@"logo : %@ \n ",  logo);
}


@end