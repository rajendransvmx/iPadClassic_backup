//
//  SMLoggerHelper.m
//  LogSaver
//
//  Created by Pushpak on 14/01/15.
//  Copyright (c) 2015 Organization Name. All rights reserved.
//

#import "SMLoggerHelper.h"

static int stdErrorFileNumber = -99999;
@implementation SMLoggerHelper

#pragma mark - Redirecting stderr to file
+ (void)redirectConsoleLogToLogFile {
    /*
     * We'll disable file writing when using simulator.
     */
#if TARGET_IPHONE_SIMULATOR == 0
    /*
     * Let's check whether the console is connected, if YES then we write to console
     * else we write to file :)
     */
    if (isatty(STDERR_FILENO)) {
        FILE *newStderr;
        newStderr = freopen([[[self class] getLogFilePath] fileSystemRepresentation],"a+",stderr);
    }
#endif
}

+ (void)saveDefaultConsoleFileNumber {
    
    if (stdErrorFileNumber == -99999) {
        // Save stderr so it can be restored.
        stdErrorFileNumber = dup(STDERR_FILENO);
    }
}

+ (void)revertBackToConsole {
    
    if (stdErrorFileNumber != -99999) {
        // Flush before restoring stderr
        fflush(stderr);
        // Now restore stderr, so new output goes to console.
        dup2(stdErrorFileNumber, STDERR_FILENO);
        close(stdErrorFileNumber);
    }
}

#pragma mark - End
#pragma mark - Manual Writting to file.
+ (NSString *)getLogFilePath
{
    @synchronized([self class]) {
        
        NSFileManager *fileManager = [NSFileManager new];
        
        NSString *basePath = [self baseLogDirectoryPath];
        
        /*
         * Lets retrieve the file name from user defaults.
         */
        NSString *fileName = [[NSUserDefaults standardUserDefaults] objectForKey:@"SMLogFileName"];
        
        if (fileName.length) {
            /*
             * File name found, lets check whether file exist/not and if exists then check for its size.
             */
            NSString *tempPath = [basePath stringByAppendingPathComponent:fileName];
            if([fileManager fileExistsAtPath:tempPath]){
                
                /*
                 * File exists so lets check file size.
                 */
                long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:tempPath error:nil][NSFileSize] longLongValue];
                
                if (fileSize > LOGFILEMAXSIZE) {
                    
                    /*
                     * File size exceeds our limit so lets put some new file name to append.
                     */
                    NSArray *stringParts = [fileName componentsSeparatedByString:@"__"];
                    if ([stringParts count] > 1) {
                        NSInteger counter = ((NSString *)[stringParts objectAtIndex:1]).integerValue;
                        counter ++;
                        fileName = [NSString stringWithFormat:@"%@__%ld__%@",[stringParts firstObject],(long)counter,[stringParts lastObject]];
                        [[NSUserDefaults standardUserDefaults] setObject:fileName forKey:@"SMLogFileName"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                }
            }
            
        } else {
            
            /*
             * User defaults doesn't contain the file name so lets add one and create file as well.
             */
            fileName = @"LogFile__1__.log";
            [[NSUserDefaults standardUserDefaults] setObject:fileName forKey:@"SMLogFileName"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        return [basePath stringByAppendingPathComponent:fileName];
    }
}

+ (NSString *)baseLogDirectoryPath {
    
    NSString * rootPath = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    rootPath = [rootPath stringByAppendingPathComponent:@"ServiceMaxLogs"];
    NSFileManager *fileManager = [NSFileManager new];
    
    if(![fileManager fileExistsAtPath:rootPath])
    {
        [fileManager createDirectoryAtPath:rootPath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:NULL];
        
        NSURL *itmURL = [NSURL fileURLWithPath:rootPath];
        [self excludeItemForBackupAtURL:itmURL];
    }
    return rootPath;
}

+ (BOOL)excludeItemForBackupAtURL:(NSURL *)urlToExcludeForBackup
{
    NSError *error = nil;
    BOOL success = [urlToExcludeForBackup setResourceValue: [NSNumber numberWithBool: YES]
                                                    forKey: NSURLIsExcludedFromBackupKey error: &error];
    if (! success)
    {
        NSLog(@"Error excluding %@ from backup %@", [urlToExcludeForBackup lastPathComponent], error);
    }
    return success;
}

+ (void)writeToFile:(NSString *)message {
    @autoreleasepool {
        /*
         * Lets get the log file path.
         */
        NSString *logPath = [SMLoggerHelper getLogFilePath];
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        if(![fileManager fileExistsAtPath:logPath]){
            
            /*
             * File doesn't exists so lets create one.
             */
            NSData *data = [[NSData alloc]initWithBase64EncodedString:@""
                                                              options:NSDataBase64DecodingIgnoreUnknownCharacters];
            [fileManager createFileAtPath:logPath
                                 contents:data
                               attributes:nil];
        }
        /*
         * We are good to open log file and append the desired log message :)
         */
        FILE *pFile = fopen([logPath UTF8String], "a+");
        if(pFile != NULL) {
            fprintf(pFile,"%s",[message UTF8String]);
        }
        fclose(pFile);
    }
}
#pragma mark - End.

+ (void)deleteAllLogFiles {
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SMLogFileName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *errorWhileDeleting;
    BOOL isFileDeleted = YES;
    
    if ([fileManager fileExistsAtPath:[self baseLogDirectoryPath]])
    {
        isFileDeleted = [fileManager removeItemAtPath:[self baseLogDirectoryPath] error:&errorWhileDeleting];
        
        if (! isFileDeleted)
        {
            if (errorWhileDeleting != NULL)
            {
                NSLog(@"Error while deleting file %@", [errorWhileDeleting debugDescription]);
            }
        }
    }
    else
    {
        NSLog(@"File does not exist at the Path %@", [self baseLogDirectoryPath]);
    }

}
@end
