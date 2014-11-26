//
//  NSNotificationCenter+UniqueNotif.h
//  ServiceMaxiPad
//
//  Created by Pushpak on 20/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNotificationCenter (UniqueNotif)

- (void)addUniqueObserver:(id)observer selector:(SEL)selector name:(NSString *)name object:(id)object;

@end
