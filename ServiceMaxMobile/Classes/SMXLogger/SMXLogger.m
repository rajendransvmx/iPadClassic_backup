//
//  SMXLogger.m
//  SMXLogger
//
//  Created by Siva Manne on 01/07/13.
//  Copyright (c) 2013 Siva Manne. All rights reserved.
//

#import "SMXLogger.h"
#import "AppDelegate.h"

#define     kPrintLogsInConsole
#define     kMaxNumberOfLogRecordsToKeep    20000
#define     kMethodLength                   255
static NSString * const kDBBeginTransaction = @"BEGIN TRANSACTION";
static NSString * const kDBEndTransaction = @"END TRANSACTION";
static int kTrimLength = 32000;
@implementation SMXLogger
@synthesize isLoggerTableCreated;
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
        self.isLoggerTableCreated = FALSE;
        dateFormatter = [[NSDateFormatter alloc] init];
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
- (void) logSMMessageWithName:(NSString *)methodContext
                 withUserName:(NSString *)userName
                     logLevel:(int)logLevel
                    logContext:(NSString *)logContext
                       format:(NSString *)format
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger applicationLogSettingValue =[defaults integerForKey:@"application_level"];
    NSInteger performanceMonitorSettingValue = [defaults integerForKey:@"performance_level"];
    BOOL kLoggingNeeded = FALSE;
    BOOL isPerformanceLog = logLevel > 3;
    NSString *logCategory = nil;
    if(isPerformanceLog)
    {
        logLevel = logLevel - 4;
        logCategory = @"Performance Level";
    }
    else
    {
        logCategory = @"Application Level";
    }
    
    kLoggingNeeded = (applicationLogSettingValue  || performanceMonitorSettingValue) ? TRUE : FALSE;
    if(!kLoggingNeeded)
        return;
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];

#ifdef kPrintLogsInConsole
    NSString *message = nil;
    if(!userName)
        message = [NSString stringWithFormat:@"[%@]||%d||%@||%@",timeStamp,logLevel,methodContext,format];
    else
        message = [NSString stringWithFormat:@"[%@]||%d||%@||%@||%@",timeStamp,logLevel,methodContext,userName,format];
    NSLog(@"%@",message);
#endif
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    if(![appDelegate doesServerSupportsModule:kMinPkgForSVMXJobLogs])
        return;
    NSString *groupID = @"";
    NSString *profileID = appDelegate.current_userId;
    BOOL insertLog = FALSE;
    if(isPerformanceLog)
    {
       insertLog = (performanceMonitorSettingValue  >= logLevel) ? TRUE : FALSE;
    }
    else if(applicationLogSettingValue)
    {
        insertLog = (applicationLogSettingValue  >= logLevel) ? TRUE : FALSE;
    }
    
    if(insertLog)
    {
        NSString *insertStatement = nil;
        char *error;
        NSString *messageToDB = nil;
        if(format)
        {
            format = [format stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
            if([format length] >= kTrimLength)
            {
                messageToDB = [format substringFromIndex:([format length] - kTrimLength)];
            }
            else
                messageToDB = format;
            if([methodContext length] > kMethodLength)
                methodContext = [methodContext substringToIndex:kMethodLength];
            if(logContext)
            {
                insertStatement = [NSString stringWithFormat:@"INSERT INTO SVMXC__SVMX_Job_Logs__c (SVMXC__Log_Timestamp__c,SVMXC__Log_level__c,SVMXC__Log_Context__c,SVMXC__Message__c,SVMXC__Type__c,SVMXC__Group_Id__c,SVMXC__Profile_Id__c,SVMXC__Log_Category__c,SVMXC__Operation__c) VALUES (\"%@\",\"%d\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",timeStamp,logLevel,logContext,messageToDB,@"iPad",groupID,profileID,logCategory,methodContext];
            }
            else
            {
                insertStatement = [NSString stringWithFormat:@"INSERT INTO SVMXC__SVMX_Job_Logs__c (SVMXC__Log_Timestamp__c,SVMXC__Log_level__c,SVMXC__Message__c,SVMXC__Type__c,SVMXC__Group_Id__c,SVMXC__Profile_Id__c,SVMXC__Log_Category__c,SVMXC__Operation__c) VALUES (\"%@\",\"%d\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",timeStamp,logLevel,messageToDB,@"iPad",groupID,profileID,logCategory,methodContext];
            }

        }
        else
        {
            if(logContext)
            {
                insertStatement = [NSString stringWithFormat:@"INSERT INTO SVMXC__SVMX_Job_Logs__c (SVMXC__Log_Timestamp__c,SVMXC__Log_level__c,SVMXC__Log_Context__c,UserInfo__c,SVMXC__Type__c,SVMXC__Group_Id__c,SVMXC__Profile_Id__c,SVMXC__Log_Category__c,SVMXC__Operation__c) VALUES (\"%@\",\"%d\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",timeStamp,logLevel,logContext,@"iPad",groupID,profileID,logCategory,methodContext];
            }
            else
            {
                insertStatement = [NSString stringWithFormat:@"INSERT INTO SVMXC__SVMX_Job_Logs__c (SVMXC__Log_Timestamp__c,SVMXC__Log_level__c,UserInfo__c,SVMXC__Type__c,SVMXC__Group_Id__c,SVMXC__Profile_Id__c,SVMXC__Log_Category__c,SVMXC__Operation__c) VALUES (\"%@\",\"%d\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",timeStamp,logLevel,@"iPad",groupID,profileID,logCategory,methodContext];
            }

        }
        //if(!isLoggerTableCreated)
        [self createLoggerTable];
        
       // synchronized_sqlite3_exec(appDelegate.db, [kDBBeginTransaction UTF8String], NULL, NULL, &error);
       // synchronized_sqlite3_exec(appDelegate.db, [insertStatement UTF8String], NULL, NULL, &error);
       // synchronized_sqlite3_exec(appDelegate.db, [kDBEndTransaction UTF8String], NULL, NULL, &error);
       
         // Mem_leak_fix - Vipindas 9493 Jan 18
        [appDelegate.dataBase beginTransaction];
        synchronized_sqlite3_exec(appDelegate.db, [insertStatement UTF8String], NULL, NULL, &error);
        [appDelegate.dataBase endTransaction];
        
        int existingLogsCount = [appDelegate.dataBase getRecordCountFromTable:@"SVMXC__SVMX_Job_Logs__c"];
        
        if(existingLogsCount > kMaxNumberOfLogRecordsToKeep)
        {
                  int logsCountToDelete = existingLogsCount - kMaxNumberOfLogRecordsToKeep;
                 [appDelegate.dataBase deleteRecordFromTable:@"SVMXC__SVMX_Job_Logs__c"
                                     numberOfRecordsToDelete:logsCountToDelete
                                                orderByField:@"local_id"];
        }
        
       
        /*if([appDelegate.dataBase getRecordCountFromTable:@"SVMXC__SVMX_Job_Logs__c"] > kMaxNumberOfLogRecordsToKeep)
        {
            int logsCountToDelete = [appDelegate.dataBase getRecordCountFromTable:@"SVMXC__SVMX_Job_Logs__c"] - kMaxNumberOfLogRecordsToKeep;
            [appDelegate.dataBase deleteRecordFromTable:@"SVMXC__SVMX_Job_Logs__c" numberOfRecordsToDelete:logsCountToDelete orderByField:@"local_id"];
        }
        */
    }
}
- (void) createLoggerTable
{
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if (appDelegate.dataBase)
    {
         NSString * query  = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SVMXC__SVMX_Job_Logs__c (local_id INTEGER PRIMARY KEY  AUTOINCREMENT NOT NULL UNIQUE DEFAULT (0),SVMXC__Log_Timestamp__c DATE,SVMXC__Log_level__c int,SVMXC__Log_Context__c TEXT,SVMXC__Message__c TEXT,SVMXC__Type__c TEXT,SVMXC__Group_Id__c TEXT,SVMXC__Profile_Id__c TEXT,SVMXC__Log_Category__c TEXT,SVMXC__Operation__c TEXT)"];
        char * err;
        if (synchronized_sqlite3_exec(appDelegate.db, [query UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
            isLoggerTableCreated = FALSE;
            NSLog(@" ERROR IN createTable \n  stetement: %@ \n %s", query, err);
            NSLog(@" ERROR in detail  : %@",[NSString stringWithUTF8String:sqlite3_errmsg(appDelegate.db)]);
        }
        else
            isLoggerTableCreated = TRUE;

    }
    else
    {
        isLoggerTableCreated = FALSE;
    }
}
@end
