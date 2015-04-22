//
//  SMObjectRelationModel.m
//  ServiceMaxiPad
//
//  Created by Pushpak on 16/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "SMObjectRelationModel.h"

@implementation SMObjectRelationModel

- (void)dealloc
{
    _parentName = nil;
    _childName = nil;
    _childFieldName = nil;
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
