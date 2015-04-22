//
//  SMXMonitor.m
//  SMXLogger
//
//  Created by Siva Manne on 01/07/13.
//  Copyright (c) 2013 Siva Manne. All rights reserved.
//

#import "SMXMonitor.h"
#import "SMXLogger.h"
#define kPerformanceMonitor @"PerformanceMonitor"

@implementation SMXMonitor
@synthesize queue;
@synthesize isMethodEnded;
- (void) monitorSMMessageWithName:(NSString *)methodContext
                     withUserName:(NSString *)userName
                         logLevel:(int)logLevel
                       logContext:(NSString *)logContext
                     timeInterval:(NSTimeInterval)duration
{
    SMXLogger *logger = [SMXLogger sharedInstance];
    if([logContext caseInsensitiveCompare:@"start"] == NSOrderedSame)
    {
        [logger logSMMessageWithName:methodContext
                        withUserName:userName
                            logLevel:kPerformanceLevelVerbose
                          logContext:@"PerformanceMonitor"
                              format:@"Start"];
        dispatch_time_t methodExecutionTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC));
        dispatch_after(methodExecutionTime, queue, ^(void){
            if(!isMethodEnded)
            {
                [logger logSMMessageWithName:methodContext
                                withUserName:userName
                                    logLevel:kPerformanceLevelWarning
                                  logContext:kPerformanceMonitor
                                      format:[NSString stringWithFormat:@"Execution did not complete in %f secs", duration]];
         
            }
        });
    }
    else
    {
        [logger logSMMessageWithName:methodContext
                                withUserName:userName
                                    logLevel:kPerformanceLevelVerbose
                                  logContext:kPerformanceMonitor
                                      format:@"Stop"];
        isMethodEnded = YES;
    }
    
}
@end
