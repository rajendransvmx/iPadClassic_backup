//
//  BaseMetaSyncDue.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   MetaSyncDueModel.m
 *  @class  MetaSyncDueModel
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



#import "MetaSyncDueModel.h"

@implementation MetaSyncDueModel 

@synthesize localId;
@synthesize description;

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
    
	description = nil;
}

- (void)explainMe
{
    NSLog(@"localId : %d \n description : %@ \n ",  localId,description);
}

@end