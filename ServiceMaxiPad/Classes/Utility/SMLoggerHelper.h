//
//  SMLoggerHelper.h
//  LogSaver
//
//  Created by Pushpak on 14/01/15.
//  Copyright (c) 2015 Organization Name. All rights reserved.
//

#import <Foundation/Foundation.h>
#define LOGFILEMAXSIZE 1024*1024*10

@interface SMLoggerHelper : NSObject

#pragma mark - Redirecting stderr to file .
/**
 * @name redirectConsoleLogToLogFile
 *
 * @author Pushpak
 *
 * @brief Redirect the stderr to the log file path,
 * If simulator or console is connected we won't redirect the log.
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param
 *
 * @return
 *
 */
+ (void)redirectConsoleLogToLogFile;
+ (void)saveDefaultConsoleFileNumber;

+ (void)revertBackToConsole;
/**
 * @name getLogFilePath
 *
 * @author Pushpak
 *
 * @brief used to get log file path where it checks whether log file exceeds the file size limit.
 * If it exceeds the limit then we create new file and return the path.
 *
 * \par
 *  <Longer description starts here>
 *
 * @return NSString logFilePath;
 *
 */
+ (NSString *)getLogFilePath;

#pragma mark - End.
#pragma mark - Manual writting to file.
+ (void)writeToFile:(NSString *)message;
#pragma mark - End.

+ (void)deleteAllLogFiles;
@end
