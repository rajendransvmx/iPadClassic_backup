//
//  SMXMonitor.h
//  SMXLogger
//
//  Created by Siva Manne on 01/07/13.
//  Copyright (c) 2013 Siva Manne. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface SMXMonitor : NSObject
@property (nonatomic, assign) dispatch_queue_t queue;
@property (nonatomic, assign) BOOL isMethodEnded;
- (void) monitorSMMessageWithName:(const char *)methodContext
                 withUserName:(NSString *)userName
                     logLevel:(int)logLevel
                   logContext:(NSString *)logContext
                 timeInterval:(NSTimeInterval)duration;

@end
