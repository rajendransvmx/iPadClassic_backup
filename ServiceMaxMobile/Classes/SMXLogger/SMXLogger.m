//
//  SMXLogger.m
//  SMXLogger
//
//  Created by Siva Manne on 01/07/13.
//  Copyright (c) 2013 Siva Manne. All rights reserved.
//

#import "SMXLogger.h"
#import "AppDelegate.h"

static NSString * const kDBBeginTransaction = @"BEGIN TRANSACTION";
static NSString * const kDBEndTransaction = @"END TRANSACTION";
static int kTrimLength = 500;
@implementation SMXLogger
static SMXLogger *sharedSMXLogger = nil;

+ (SMXLogger*)sharedInstance
{
    if (sharedSMXLogger == nil)
    {
        @synchronized(self)
        {
            sharedSMXLogger = [[super allocWithZone:NULL] init];
        }
    }
    return sharedSMXLogger;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedInstance] retain];
}

- (id)init
{
    if (self = [super init])
    {
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (oneway void)release {
    // never release
}

- (id)autorelease {
    return self;
}
- (void) logSMMessageWithName:(const char *)methodContext
                 withUserName:(NSString *)userName
                     logLevel:(int)logLevel
                    logContext:(NSString *)logContext
                       format:(NSString *)format
{

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *logLevelSettingValue =[defaults stringForKey:@"enabled_logging"];
    BOOL kLoggingNeeded = FALSE;
    kLoggingNeeded = [logLevelSettingValue boolValue];
    //kLoggingNeeded = ([logLevelSettingValue intValue] >= logLevel) ? TRUE : FALSE;
    if(!kLoggingNeeded)
        return;
    /*
    NSString *message = nil;
    if(!userName)
        message = [NSString stringWithFormat:@"[%@]||%d||%s||%@",[NSDate date],logLevel,methodContext,format];
    else
        message = [NSString stringWithFormat:@"[%@]||%d||%s||%@||%@",[NSDate date],logLevel,methodContext,userName,format];
     */
    NSLog(@"%@",format);
    return;
    BOOL kPerformanceMonitorSettingValue = [defaults boolForKey:@"performance_monitor"];
    if(kPerformanceMonitorSettingValue && ((logLevel == 1) ||(logLevel == 2) ))
    {
        NSString *insertStatement = nil;
        char *error;
        NSString *messageToDB = nil;
        if(format)
        {
            if([format length] >= kTrimLength)
                messageToDB = [format substringToIndex:kTrimLength];
            else
                messageToDB = format;            
            insertStatement = [NSString stringWithFormat:@"INSERT INTO PerformanceMonitor (local_id__c,logTimeStamp__c,logLevel__c,logContext__c,logMessage__c) VALUES (\"%@\", \"%@\",\"%d\",\"%s\",\"%@\")",[AppDelegate GetUUID],[NSDate date],2,methodContext,messageToDB];

        }
        else
        {
            insertStatement = [NSString stringWithFormat:@"INSERT INTO PerformanceMonitor (local_id__c,logTimeStamp__c,logLevel__c,logContext__c,UserInfo__c) VALUES (\"%@\", \"%@\",\"%d\",\"%s\")",[AppDelegate GetUUID],[NSDate date],2,methodContext];

        }
        if(!monitoringDB)
            [self createMonitoringTable];
        synchronized_sqlite3_exec(monitoringDB, [kDBBeginTransaction UTF8String], NULL, NULL, &error);
        synchronized_sqlite3_exec(monitoringDB, [insertStatement UTF8String], NULL, NULL, &error);
        synchronized_sqlite3_exec(monitoringDB, [kDBEndTransaction UTF8String], NULL, NULL, &error);

    }
}
- (void) createMonitoringTable
{
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    
    // Build the path to the database file
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"performanceMonitor.sqlite"]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &monitoringDB) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS PerformanceMonitor (local_id__c TEXT,logTimeStamp__c DATE,logLevel__c int,logContext__c TEXT,logMessage__c TEXT)";
            
            if (synchronized_sqlite3_exec(monitoringDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                [self logSMMessageWithName:__PRETTY_FUNCTION__
                                                    withUserName:nil
                                                        logLevel:1
                                                      logContext:nil
                                                          format:@"Failed to create PerformanceMonitor table"];
            }
        }
        else
        {
            [self logSMMessageWithName:__PRETTY_FUNCTION__
                                                withUserName:nil
                                                    logLevel:1
                                                  logContext:nil
                                                      format:@"Failed to open/create Monitoring database"];
        }
    }
    else
    {
        NSLog(@"DB is available. But it is closed");
        if(!monitoringDB)
        {
            const char *dbpath = [databasePath UTF8String];
            sqlite3_open(dbpath, &monitoringDB);
        }
    }
    [databasePath release];
    [filemgr release];
}
@end
