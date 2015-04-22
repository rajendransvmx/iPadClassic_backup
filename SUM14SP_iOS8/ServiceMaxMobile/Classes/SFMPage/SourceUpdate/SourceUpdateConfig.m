//
//  SourceUpdateConfig.m
//  ServiceMaxMobile
//
//  Created by Shravya shridhar on 1/1/14.
//  Copyright (c) 2014 SivaManne. All rights reserved.
//

#import "SourceUpdateConfig.h"

@implementation SourceUpdateConfig

@synthesize identifier;
@synthesize sourceObjectName;
@synthesize targetObjectName;
@synthesize sourceFieldName;
@synthesize targetFieldname;
@synthesize actionType;
@synthesize displayValue;
@synthesize settingId;
@synthesize processId;

- (void)dealloc {
    [identifier release];
    [sourceObjectName release];
    [targetObjectName release];
    [sourceFieldName release];
    [targetFieldname release];
    [actionType release];
    [displayValue release];
    [settingId release];
    [processId release];
    [super dealloc];
}

@end
