//
//  BaseInternet_conflicts.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   InternetConflictModel.m
 *  @class  InternetConflictModel
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



#import "InternetConflictModel.h"

@implementation InternetConflictModel 

@synthesize syncType;
@synthesize errorMessage;
@synthesize operationType;
@synthesize errorType;

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
    syncType = nil;
    errorMessage = nil;
    operationType = nil;
    errorType = nil;
}

- (void)explainMe
{
    NSLog(@"syncType : %@ \n errorMessage : %@ \n operationType : %@ \n errorType : %@ \n ",  syncType,errorMessage,operationType, errorType);
}


@end