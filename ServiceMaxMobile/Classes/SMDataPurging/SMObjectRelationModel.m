//
//  SMObjectRelationModel.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 1/29/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import "SMObjectRelationModel.h"

@implementation SMObjectRelationModel

@synthesize parentName, childFieldName, childName;

- (void)dealloc
{
    [parentName release];
    [childName release];
    [childFieldName release];
    [super dealloc];
}


- (BOOL)isChild
{
    if ([self.parentName isEqualToString:self.childFieldName])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

@end
