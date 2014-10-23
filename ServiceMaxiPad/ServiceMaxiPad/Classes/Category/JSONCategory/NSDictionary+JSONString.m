//
//  NSDictionary+JSONString.m
//  MapARC
//
//  Created by Anoop on 9/11/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "NSDictionary+JSONString.h"

@implementation NSDictionary (JSONString)

- (NSString*)jsonStringWithPrettyPrint:(BOOL)prettyPrint {
    
    NSError *error = nil;
    NSData *jsonData = nil;
    if ([self allKeys])
        jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                   options:(NSJSONWritingOptions)(prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                     error:&error];
    if (!jsonData) {
        NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
}

@end
