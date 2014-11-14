//
//  NSDictionary+Merge.m
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 22/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "NSDictionary+Merge.h"

@implementation NSDictionary (Merge)

- (NSDictionary *)dictionaryByMergingWithDictionary:(NSDictionary *)dictionary
{
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:self];
    [result addEntriesFromDictionary:dictionary];
    return [NSDictionary dictionaryWithDictionary:result];
}

@end
