//
//  LocationPingManager.m
//  ServiceMaxiPad
//
//  Created by Pushpak on 17/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "LocationPingManager.h"

@implementation LocationPingManager

#pragma mark Singleton Methods
+ (instancetype) sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super alloc] initInstance];
    });
    return sharedInstance;
}

- (instancetype) initInstance {
    self = [super init];
    // Do any other initialisation stuff here
    // ...
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}


@end
