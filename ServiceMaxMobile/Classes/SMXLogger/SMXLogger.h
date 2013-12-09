//
//  SMXLogger.h
//  SMXLogger
//
//  Created by Siva Manne on 01/07/13.
//  Copyright (c) 2013 Siva Manne. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sqlite3.h>
@interface SMXLogger : NSObject
{
    sqlite3 * monitoringDB;
}
+ (id)sharedInstance;
- (void) logSMMessageWithName:(const char *)methodContext
                 withUserName:(NSString *)userName
                    logLevel:(int)logLevel
                    logContext:(NSString *)logContext
                       format:(NSString *)format;
- (void) createMonitoringTable;
@end
