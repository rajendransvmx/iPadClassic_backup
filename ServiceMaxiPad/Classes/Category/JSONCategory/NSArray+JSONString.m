//
//  NSArray+JSONString.m
//  MapARC
//
//  Created by Anoop on 9/11/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "NSArray+JSONString.h"

@implementation NSArray (JSONString)

- (NSString*)jsonStringWithPrettyPrint:(BOOL)prettyPrint {
    
    NSError *error;
    NSData *jsonData = nil;
    if ([self count])
        jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                   options:(NSJSONWritingOptions)(prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                     error:&error];
    if (!jsonData) {
        SXLogError(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
}

@end
