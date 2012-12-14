//
//  SMLogger.h
//  CustomLogging
//
//  Created by Siva Manne on 15/05/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>
enum
{
    LOG_ERROR = 1,
    LOG_WARN, 
    LOG_INFO,
    LOG_DEBUG, 
    LOG_FINE, 
    LOG_FINER, 
    LOG_FINEST
}LOG_LEVEL;

@interface SMLogger : NSObject
+ (SMLogger*) sharedInstance;
- (void) logMessageWithLevel:(int) level 
                  onFunction:(const char *)functionName
                  lineNumber:(int)line
                 withMessage:(NSString *)message,...;

- (NSString *) getLogLevelStringForLevel:(int) level;
@end
