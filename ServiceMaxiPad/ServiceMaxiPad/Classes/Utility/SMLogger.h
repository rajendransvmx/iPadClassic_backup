//
//  SMLogger.h
//  ServiceMaxMobile
//
//  Created by Pushpak on 21/05/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SMLogger.h
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
static NSInteger kMaxNumberOfLogRecordsToKeep = 20000;
static NSInteger kMaxLogMethodLength          = 255;
static NSInteger kMaxLogMesssageLength        = 32000;
static NSInteger kNumberOfRecordsToSendPerBatch = 500;
NS_ENUM(NSInteger, ApplicationLogSettings)
{
    ApplicationLogLevelOff = 0,
    ApplicationLogLevelError,
    ApplicationLogLevelWarning,
    ApplicationLogLevelVerbose
};

NS_ENUM(NSInteger, PerformanceLogSettings)
{
    kPerformanceLevelOff = 0,
    kPerformanceLevelWarning,
    kPerformanceLevelVerbose
};

#import <Foundation/Foundation.h>

/** 
 helper to get the current source file name as NSString
 */
#define SMLogSourceFileName [[NSString stringWithUTF8String:__FILE__] lastPathComponent]

/**
 helper to get current method name
 */
#define SMLogSourceMethodName NSStringFromSelector(_cmd)

/**
 helper to get current line number
 */
#define SMLogSourceLineNumber __LINE__

/**
 macro that gets called by individual level macros
 */
#define SMLogCallHandlerIfLevel(minLevel, format, ...) \
if (SMLogHandler && SMLogLevel>=minLevel) SMLogHandler(minLevel, SMLogSourceFileName, SMLogSourceLineNumber, SMLogSourceMethodName, format, ##__VA_ARGS__);

/**
 block signature called for each log statement
 */
typedef void (^SMLogBlock)(NSUInteger logLevel, NSString *fileName, NSUInteger lineNumber, NSString *methodName, NSString *format, ...);

/**
 log macro for fatal level (0)
 */
#define SXLogFatal(format, ...) SMLogCallHandlerIfLevel(0, format, ##__VA_ARGS__);

/**
 log macro for error level (1)
 */
#define SXLogError(format, ...) SMLogCallHandlerIfLevel(1, format, ##__VA_ARGS__);

/**
 log macro for Warning level (2)
 */
#define SXLogWarning(format, ...) SMLogCallHandlerIfLevel(2, format, ##__VA_ARGS__);

/**
 log macro for info level (3)
 */
#define SXLogInfo(format, ...) SMLogCallHandlerIfLevel(3, format, ##__VA_ARGS__);

/**
 log macro for debug level (7)
 */
#define SXLogDebug(format, ...) SMLogCallHandlerIfLevel(4, format, ##__VA_ARGS__);

@interface SMLogger : NSObject

extern SMLogBlock SMLogHandler;
extern NSInteger SMLogLevel;

/**
 Uncomment following code if you want to override the default block at any point.
 */
// void SMLogSetLoggerBlock(SMLogBlock handler);

/**
 Using this method we can alter the logLevel to desired value.
 */
void SMLogSetLogLevel(NSInteger logLevel);

/**
 Call this method once at the start of your application to initialise block, most recommended in application:didFinishLaunchingWithOptions:
 */
void SMLogPerformInitialSetup();

void ConfigureLoggerAccordingToSettings();
@end
