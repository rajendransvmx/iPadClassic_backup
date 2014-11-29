//
//  NSNotificationCenter+UniqueNotif.m
//  ServiceMaxiPad
//
//  Created by Pushpak on 20/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "NSNotificationCenter+UniqueNotif.h"
@implementation NSNotificationCenter (UniqueNotif)

- (void)addUniqueObserver:(id)observer selector:(SEL)selector name:(NSString *)name object:(id)object {
    
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:name object:object];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:name object:object];
    
}

@end
