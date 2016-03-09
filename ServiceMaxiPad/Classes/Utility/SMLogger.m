//
//  SMLogger.m
//  ServiceMaxMobile
//
//  Created by Pushpak on 21/05/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//
/**
 *  @file   SMLogger.m
 *  @class  SMLogger
 *
 *  @brief  Function prototypes for the console driver.
 *
 *  This class is replacement for in build NSLog function
 *
 *  @author  Pushpak
 *  @author  Vipindas Palli
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/




#import "SMLogger.h"
#include <time.h>
#include <sys/time.h>
#include <stdio.h>


#include <fcntl.h>
#include <asl.h>
#include <unistd.h>


#import "FactoryDAO.h"
#import "JobLogDAO.h"
#import "CustomerOrgInfo.h"
#import "DateUtil.h"
#import "DBRequestDelete.h"
#import "DBCriteria.h"
#import "DBRequestSelect.h"
#import "DatabaseConfigurationManager.h"
#import "SMLoggerHelper.h"
#import "SMAppDelegate.h"
#import "JobLogViewController.h"

@implementation SMLogger

SMLogBlock SMLogHandler = nil;

#ifdef NDEBUG
NSInteger SMLogLevel = 1;
#else
NSInteger SMLogLevel = 4;
#endif

/**
 * @name   SMLogSetLoggerBlock
 *
 * @author Pushpak
 *
 * @brief Perform initial setup for logging
 *
 *
 *
 *
 * @return void
 *
 */

void SMLogSetLoggerBlock(SMLogBlock handler)
{
    SMLogHandler = [handler copy];
}

/**
 * @name   SMLogSetLogLevel
 *
 * @author Pushpak
 *
 * @brief Set log level
 *
 * @param logLevel desired log level
 *
 *
 * @return void
 *
 */

void SMLogSetLogLevel(NSInteger logLevel)
{
    SMLogLevel = logLevel;
}

/**
 * @name   SMLogSetLogLevel
 *
 * @author Pushpak
 *
 * @brief Set log level
 *
 * @param logLevel desired log level
 *
 *
 * @return void
 *
 */

NSInteger SMLogLogLevel()
{
    return SMLogLevel;
}


/**
 * @name   SMLogPerformInitialSetup
 *
 * @author Pushpak
 *
 * @brief Perform initial setup for logging
 *
 *
 *
 *
 * @return void
 *
 */

void SMLogPerformInitialSetup()
{
    aslclient log_client;
    
    log_client = asl_open("ServiceMax", "The ServiceMax Log Facility", ASL_OPT_STDERR);
    
    SMLogSetLoggerBlock(^(NSUInteger logLevel, NSString *fileName, NSUInteger lineNumber, NSString *methodName, NSString *format, ...) {
        @autoreleasepool {
            va_list args;
            va_start(args, format);
            
            NSString *message = [[NSString alloc]initWithFormat:format arguments:args];
            NSString *methodContext = [methodName stringByAppendingFormat:@":%lu ",(unsigned long)lineNumber];
            
            NSInteger logLevelToBeInserted;
            switch (logLevel) {
                case 0:
                case 1:
                    //Error
                    logLevelToBeInserted = 1;
                    break;
                case 2:
                    //Warning
                    logLevelToBeInserted = 2;
                    break;
                default:
                    //Verbose
                    logLevelToBeInserted = 3;
                    break;
            }
            
            SMLogEnqueueLogMessage(message, methodContext,logLevelToBeInserted);
            
            asl_log(log_client, NULL, ASL_LEVEL_NOTICE, "%s(LogLevel:%d) %s",[methodContext UTF8String],(int)logLevelToBeInserted,[message UTF8String]);
            
            if (EnableFileLogging) {
                time_t ltime; /* calendar time */
                ltime=time(NULL); /* get current cal time */
                
                [SMLoggerHelper writeToFile:[methodContext stringByAppendingFormat:@"\n[ServiceMax %.24s (LogLevel:%d)] %@",asctime(localtime(&ltime) ) ,(int)logLevelToBeInserted,message]];
            }
            va_end(args);
        }
    });
}

/**
 * @name   SMLogEnqueueLogMessage
 *
 * @author Pushpak
 * @author Vipindas Palli
 *
 * @brief Set log level
 *
 * @param message Message for enqueue
 *
 *
 * @return void
 *
 */

void SMLogEnqueueLogMessage( NSString *message, NSString *methodContext, NSInteger logLevel)
{
    // PumpLogIntoDatabase(message, methodContext, logLevel, @"Application Level");
    //use this method to write output to file or database depending on your requirement.
    
    JobLogViewController *joblogViewController = [[JobLogViewController alloc]init];
    SMAppDelegate *appDelegate = (SMAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    if ([joblogViewController isLogSettingsON]) {
        PumpLogIntoDatabase(message, methodContext, logLevel, @"Application Level");
        if (appDelegate.syncReportingType)
        {
            setDataForSyncError(message, methodContext, logLevel, @"Application level");
            
        }
    }
    else
    {
        setDataForSyncError(message, methodContext, logLevel, @"Application level");
        
    }
    
    //use this method to write output to file or database depending on your requirement.
    
    
    
}


#pragma mark - application support methods

void ConfigureLoggerAccordingToSettings()
{
    NSString *stringValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"application_level"];
    if (!stringValue) {
        //Since its nil , we'll try to fetch default value from the settings bundle.
        NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
        if (settingsBundle != nil)
        {
            NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
            NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
            
            for (NSDictionary *preferenceSpecification in preferences)
            {
                /** Must use 'Key' to get the key-value */
                NSString *key = [preferenceSpecification objectForKey:@"Key"];
                
                if (key != nil && [key isEqualToString:@"application_level"])
                {
                    stringValue = [preferenceSpecification objectForKey:@"DefaultValue"];
                    break;
                }
            }
        }
    }
    
    NSInteger applicationLogSettingValue = 0;
    if (stringValue) {
        applicationLogSettingValue = stringValue.integerValue;
    }
    //Since performance monitoring is not yet done.
    //
    //NSInteger performanceMonitorSettingValue = [[NSUserDefaults standardUserDefaults] integerForKey:@"performance_level"];
    switch (applicationLogSettingValue) {
        case ApplicationLogLevelOff:
            SMLogSetLogLevel(-1);
            break;
        case ApplicationLogLevelError:
            SMLogSetLogLevel(1);
            /*
             * SXError and SXFatal
             */
            break;
        case ApplicationLogLevelWarning:
            SMLogSetLogLevel(2);
            /*
             * SXWarning, SXError and SXFatal
             */
            break;
        case ApplicationLogLevelVerbose:
            SMLogSetLogLevel(4);
            /*
             * SXLogDebug, SXLogInfo, SXWarning, SXError and SXFatal
             */
            break;
        default:
            break;
    }
}



void PumpLogIntoDatabase(NSString *message, NSString *methodContext, NSInteger logLevel, NSString *category)
{
    if([methodContext length] > kMaxLogMethodLength) {
        methodContext = [methodContext substringToIndex:kMaxLogMethodLength];
    }
    message = [message stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
    if ([message length] > kMaxLogMesssageLength) {
        
        message = [message substringToIndex:kMaxLogMesssageLength];
    }
    
    // Need to verify JobLogs are created on database
    if (![[DatabaseConfigurationManager sharedInstance] isLogsEnabled])
    {
        NSLog(@"job : table not exist");
        return;
    }
    
    JobLogModel *logModel = [[JobLogModel alloc]init];
    logModel.profileId = [CustomerOrgInfo sharedInstance].currentUserId;
    logModel.groupId = @"";
    logModel.type = @"iPad";
    logModel.category = category;
    logModel.message = message;
    logModel.operation = methodContext;
    logModel.level = logLevel;
    
    logModel.timeStamp = [DateUtil getDatabaseStringForDate:[NSDate date]];
    
    id jobLogService = [FactoryDAO serviceByServiceType:ServiceTypeJobLog];
    
    if ([jobLogService conformsToProtocol:@protocol(JobLogDAO)]) {
        [jobLogService saveRecordModel:logModel];
        [jobLogService deleteJobLogsIfRecordCountCrossedLimit];
    }
}


//HS 29Feb SyncError
void setDataForSyncError(NSString *message, NSString *methodContext, NSInteger logLevel, NSString *category)
{
    SMAppDelegate *appDelegate = (SMAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    if([methodContext length] > kMaxLogMethodLength) {
        methodContext = [methodContext substringToIndex:kMaxLogMethodLength];
    }
    message = [message stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
    if ([message length] > kMaxLogMesssageLength) {
        
        message = [message substringToIndex:kMaxLogMesssageLength];
    }
    JobLogModel *logModel = [[JobLogModel alloc]init];
    logModel.profileId = [CustomerOrgInfo sharedInstance].currentUserId;
    logModel.groupId = @"";
    logModel.type = @"iPad";
    logModel.category = category;
    logModel.message = message;
    logModel.operation = methodContext;
    logModel.level = logLevel;
    
    logModel.timeStamp = [DateUtil getDatabaseStringForDate:[NSDate date]];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:[CustomerOrgInfo sharedInstance].currentUserId forKey:@"profileId"];
    [dict setObject:@"" forKey:@"groupId"];
    [dict setObject:@"iPad" forKey:@"type"];
    [dict setObject:category forKey:@"category"];
    [dict setObject:message forKey:@"message"];
    [dict setObject:methodContext forKey:@"operation"];
    [dict setObject:[NSString stringWithFormat:@"%ld",(long)logLevel] forKey:@"level"];
    
    @autoreleasepool {
        if ([appDelegate.syncReportingType isEqualToString:@"always"])
        {
            //NSString *dataStr = [[NSString alloc]initWithFormat:@"%@",dict];
            
            //[appDelegate.syncDataArray appendString:message];
            
            [appDelegate.syncDataArray addObject:dict];
            
        }
        else if([appDelegate.syncReportingType isEqualToString:@"error"])
        {
            [appDelegate.syncErrorDataArray addObject:dict];
            
        }
        
    }
   
    
}

@end
