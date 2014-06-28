//
//  SMDataPurgeCallBackData.m
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 24/01/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import "SMDataPurgeCallBackData.h"

@implementation SMDataPurgeCallBackData

@synthesize partialExecutedObject;
@synthesize lastIndex;
@synthesize values;
@synthesize partialExecutedObjData;

- (id) init
{
    self = [super init];
    if (self)
    {
        partialExecutedObject = nil;
        lastIndex = @"0";
        values = nil;
        partialExecutedObject = nil;
    }
    return self;
}

- (void) dealloc
{
    [partialExecutedObjData release];
    [lastIndex release];
    [values release];
    [partialExecutedObject release];
    [super dealloc];
}


@end
