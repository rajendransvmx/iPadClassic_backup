//
//  SwitchLayoutManager.m
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 13/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SwitchLayoutManager.h"
#import "PlistManager.h"

@implementation SwitchLayoutManager


+ (NSString *)getLastViewedViewProcess:(NSString *)objectName
{
    NSString *viewProcess = nil;

    NSMutableDictionary * layoutDict = [PlistManager getSwitchLayoutDict];
    if (layoutDict != nil){
        viewProcess = [layoutDict objectForKey:objectName];
    }
    return viewProcess;
}

+ (void)updateViewProcess:(NSString *)objectName processId:(NSString *)processName
{
    NSMutableDictionary * layoutDict = [PlistManager getSwitchLayoutDict];
    if (layoutDict == nil){
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:0];
        layoutDict = dict;
        //[dict release];
    }
    [layoutDict setObject:processName forKey:objectName];
    [PlistManager updateSwitchLayoutDictionary:layoutDict];
}

@end
