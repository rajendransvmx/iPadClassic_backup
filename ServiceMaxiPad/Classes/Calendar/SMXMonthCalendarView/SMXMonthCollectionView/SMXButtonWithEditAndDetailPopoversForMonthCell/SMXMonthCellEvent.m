//
//  SMXMonthCellEvent.m
//  ServiceMaxiPad
//
//  Created by Service Max on 05/02/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "SMXMonthCellEvent.h"

@implementation SMXMonthCellEvent
static NSArray *occupiedPlaceArray;
static NSMutableDictionary *eventPlace;

+(void)setEventPlace:(NSString *)key value:(NSString *)value{
    if (eventPlace==nil) {
        eventPlace = [[NSMutableDictionary alloc] init];
    }
    [eventPlace setObject:value forKey:key];
}

+(int )getValueForKey:(NSString *)key{
    NSString *value=[eventPlace objectForKey:key];
    if (value){
        return [value intValue];
    }
    return -1;
}
+(void)setEventPlace:(NSMutableDictionary *)locDict{
    eventPlace=locDict;
}
+(void)removeInfoForKey:(NSString *)key{
    [eventPlace removeObjectForKey:key];
}
@end
