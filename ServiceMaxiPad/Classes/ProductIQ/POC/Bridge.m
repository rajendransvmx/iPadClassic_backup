//
//  Bridge.m
//  ProductIQ
//
//  Created by Indresh M S on 4/18/15.
//  Copyright (c) 2015 ServiceMax. All rights reserved.
//

#import "Bridge.h"
#import "StringUtil.h"

@implementation Bridge

- (void)invoke:(NSString *)input {
    if ([StringUtil containsString:@"SELECT" inString:input]) {
        SXLogDebug(@"input:%@",input);
        SXLogDebug(@"Testing");
    }
    input = [input substringFromIndex:[@"native-call://" length]];
    NSRange r1 = [input rangeOfString:@"/"];
    
    NSString *className = [input substringToIndex:r1.location];
    NSLog(@"!!!%@!!!", className);
    
    input = [input substringFromIndex:[className length] + 1];
    NSRange r2 = [input rangeOfString:@"/"];
    
    NSString *methodName = [input substringToIndex:r2.location];
    NSLog(@"--- %@ ---", methodName);
    
    input = [input substringFromIndex:[methodName length] + 1];
    input = [input stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    input = [input stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    id target = [[NSClassFromString(className) alloc] init];
    SEL selector = NSSelectorFromString([methodName stringByAppendingString:@":"]); // single parameter
    IMP imp = [target methodForSelector:selector];
    void (*func)(id, SEL, NSString*) = (void *)imp;
    func(target, selector, input);
}

@end
