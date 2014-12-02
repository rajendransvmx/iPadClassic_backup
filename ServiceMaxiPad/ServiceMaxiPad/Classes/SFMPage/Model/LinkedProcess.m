//
//  LinkedProcess.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 08/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "LinkedProcess.h"

@implementation LinkedProcess

- (id)initWithProcessId:(NSString *)processSfId name:(NSString *)processName type:(NSString *)processType
{
    if (self = [super init]) {
        _processId = processSfId;
        _processName = processName;
        _processType = processType;
    }
    return self;
}

@end
