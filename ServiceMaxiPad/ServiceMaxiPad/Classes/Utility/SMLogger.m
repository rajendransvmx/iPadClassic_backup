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

#import "FactoryDAO.h"
#import "JobLogDAO.h"
#import "CustomerOrgInfo.h"
#import "DateUtil.h"
#import "DBRequestDelete.h"
#import "DBCriteria.h"
#import "DBRequestSelect.h"
#import "DatabaseConfigurationManager.h"

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
    SMLogSetLoggerBlock(^(NSUInteger logLevel, NSString *fileName, NSUInteger lineNumber, NSString *methodName, NSString *format, ...) {
    
    va_list args;
    va_start(args, format);
        
        struct timeval tp;
        gettimeofday(&tp, NULL);
        time_t curtime = tp.tv_sec;
        struct tm  tstruct;
        char       buf[25];
        tstruct = *localtime(&curtime);
        strftime(buf, sizeof(buf), "%Y-%m-%d %X", &tstruct);
        NSString *message = [[NSString alloc]initWithFormat:format arguments:args];
        NSString *methodContext = [methodName stringByAppendingFormat:@":%lu ",(unsigned long)lineNumber];
        //NSString *metaInfo = [NSString stringWithFormat:@"%s.%03d %@ ",buf,tp.tv_usec/1000,fileName];
        
        SMLogEnqueueLogMessage(message, methodContext,logLevel);
        //NSString *formattedMessage = [[metaInfo stringByAppendingString:methodContext] stringByAppendingString:message];
        //puts([formattedMessage UTF8String]);
        //printf("%s",[formattedMessage UTF8String]);
        //fprintf(stderr, "%s\n", [formattedMessage UTF8String]);
        /*
         * shifting back to nslog as only nslog is printing into device console.
         */
        NSLog(@"%@",message);
    va_end(args);
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
    PumpLogIntoDatabase(message, methodContext, logLevel, @"Application Level");
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
            break;
        case ApplicationLogLevelWarning:
            SMLogSetLogLevel(2);
            break;
        case ApplicationLogLevelVerbose:
            SMLogSetLogLevel(4);
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
    if ([message length] > kMaxLogMesssageLength) {
        message = [message stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
        message = [message substringToIndex:kMaxLogMesssageLength];
    }
    message = [message stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
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
    logModel.level = logLevelToBeInserted;
    
    logModel.timeStamp = [DateUtil getDatabaseStringForDate:[NSDate date]];
    
    id jobLogService = [FactoryDAO serviceByServiceType:ServiceTypeJobLog];
    
    if ([jobLogService conformsToProtocol:@protocol(JobLogDAO)]) {
        [jobLogService saveRecordModel:logModel];
        [jobLogService deleteJobLogsIfRecordCountCrossedLimit];
    }
}
@end
