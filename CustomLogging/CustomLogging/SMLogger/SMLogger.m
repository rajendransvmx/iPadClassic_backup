//
//  SMLogger.m
//  CustomLogging
//
//  Created by Siva Manne on 15/05/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import "SMLogger.h"

@implementation SMLogger
static SMLogger * sharedSingleton_ = nil;
+ (SMLogger*) sharedInstance
{
    if (sharedSingleton_ == nil) {
        //sharedSingleton_ = [[super allocWithZone:NULL] init];
        sharedSingleton_ = [NSAllocateObject([self class], 0, NULL) init];
    }
    return sharedSingleton_; 
}
- (NSString *) getLogLevelStringForLevel:(int) level
{
    NSString *logLevelString = @"LOG_DEBUG";
    switch (level) {
        case LOG_ERROR:     logLevelString = @"ERROR";  break;
        case LOG_WARN:      logLevelString = @"WARN";   break;
        case LOG_INFO:      logLevelString = @"INFO";   break;
        case LOG_DEBUG:     logLevelString = @"DEBUG";  break;
        case LOG_FINE:      logLevelString = @"FINE";   break;
        case LOG_FINER:     logLevelString = @"FINER";  break;
        case LOG_FINEST:    logLevelString = @"FINEST"; break;            
        default:
            break;
    }
    return logLevelString;
}
- (void) logMessageWithLevel:(int) level 
                  onFunction:(const char *)functionName
                  lineNumber:(int)line
                 withMessage:(NSString *)format,...
{
    
    //get the settings from the bundle
    //if logging is enabled go to next step else return
    //get the log level
    //if the settinglevel is greater than member variable level value log it else return
    va_list args;
    va_start(args, format);        
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];    
    va_end(args);
   
    NSString *dataBuffer = [NSString stringWithFormat:@"%@ %s [Line %d][%@]  %@\n",[NSDate date], functionName, line,[self getLogLevelStringForLevel:level], message];
    [message release];
    
     NSFileManager *filemgr;
     NSString *dataFile;
     NSString *docsDir;
     NSArray *dirPaths;
     
     filemgr = [NSFileManager defaultManager];
     
     // Identify the documents directory
     dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
     
     docsDir = [dirPaths objectAtIndex:0];
     
     // Build the path to the data file
     dataFile = [docsDir stringByAppendingPathComponent: @"SMLogFile1.txt"];
     
     if ([filemgr fileExistsAtPath: dataFile])
     {
         NSError *error = nil;
         NSDictionary *fileAttributes = [filemgr attributesOfItemAtPath:dataFile error:&error];
         if(error != nil)
         {
             NSLog(@"Error Occured while getting the attributes of the file %@ with error %@",dataFile,[error userInfo]);
             return;
         }
         unsigned long int fileSize = [fileAttributes fileSize];
         NSLog(@"File Size = %ld",fileSize);
         float settingSize = 0.5; 
         unsigned long int setLongSize = settingSize * 1024 * 1024; //in bytes
         //unsigned long int setLongSize = 1024; //in bytes
         if(fileSize <= setLongSize)
         {
             NSData *databuffer;
             databuffer = [filemgr contentsAtPath: dataFile];
             
             NSMutableString *datastring = [[NSMutableString alloc] initWithData: databuffer 
                                                                        encoding:NSUTF8StringEncoding];
             
             
             [datastring appendString:dataBuffer];
             [filemgr createFileAtPath: dataFile 
                              contents: [datastring dataUsingEncoding:NSUTF8StringEncoding] 
                            attributes:nil];
             [datastring release];
         }
         else 
         {
             NSString *dataFile2 = [docsDir stringByAppendingPathComponent: @"SMLogFile2.txt"];

             if ([filemgr fileExistsAtPath: dataFile2])
             {
                 error = nil;
                 NSDictionary *fileAttributes = [filemgr attributesOfItemAtPath:dataFile2 error:&error];
                 if(error != nil)
                 {
                     NSLog(@"%s Error Occured while getting the attributes of the file %@",__PRETTY_FUNCTION__,dataFile2);
                     return;
                 }
                 unsigned long int fileSize = [fileAttributes fileSize];

                 if(fileSize < setLongSize)
                 {
                     NSData *databuffer;
                     databuffer = [filemgr contentsAtPath: dataFile2];                     
                     NSMutableString *datastring = [[NSMutableString alloc] initWithData: databuffer 
                                                                                encoding:NSUTF8StringEncoding];
                     [datastring appendString:dataBuffer];
                     [filemgr createFileAtPath: dataFile2 
                                      contents: [datastring dataUsingEncoding:NSUTF8StringEncoding] 
                                    attributes:nil];
                     [datastring release];
                 }
                 else 
                 {
                     [filemgr removeItemAtPath:dataFile error:&error];
                     if(error != nil)
                     {
                         NSLog(@"%s Error happened while removing the file %@",__PRETTY_FUNCTION__, dataFile);
                         return;
                     }
                     error = nil;
                     if(![filemgr moveItemAtPath:dataFile2 toPath:dataFile error:&error])
                     {
                         NSLog(@"%s Error happened while copying the file %@ to %@",__PRETTY_FUNCTION__, dataFile2,dataFile);
                         return;                         
                     }
                     [filemgr createFileAtPath: dataFile2 
                                      contents: [dataBuffer dataUsingEncoding:NSUTF8StringEncoding] 
                                    attributes:nil];
                 }
                 
             }
             else 
             {
                 NSData *databuffer;
                 databuffer = [filemgr contentsAtPath: dataFile2];
                 
                 NSMutableString *datastring = [[NSMutableString alloc] initWithData: databuffer 
                                                                            encoding:NSUTF8StringEncoding];                 
                 [datastring appendString:dataBuffer];
                 [filemgr createFileAtPath: dataFile2 
                                  contents: [datastring dataUsingEncoding:NSUTF8StringEncoding] 
                                attributes:nil];
                 [datastring release];

             }
         }
     }
     else 
     {
         [filemgr createFileAtPath: dataFile 
                          contents: [dataBuffer dataUsingEncoding:NSUTF8StringEncoding] 
                        attributes:nil];
     }
     
     [filemgr release];
     
    
    /*
     NSFileManager *filemgr;
     NSData *databuffer;
     NSString *dataFile;
     NSString *docsDir;
     NSArray *dirPaths;
     
     filemgr = [NSFileManager defaultManager];
     
     dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
     
     docsDir = [dirPaths objectAtIndex:0];
     
     dataFile = [docsDir stringByAppendingPathComponent: @"datafile.dat"];
     
     databuffer = [textBox.text dataUsingEncoding: NSASCIIStringEncoding];
     
     [filemgr createFileAtPath: dataFile contents: databuffer attributes:nil];
     
     [filemgr release];
     */
}
+ (id) allocWithZone:(NSZone *)zone 
{
    return [[self sharedInstance] retain]; 
}
- (id) copyWithZone:(NSZone*)zone 
{
    return self;
}
- (id) retain
{
    return self;
}
- (NSUInteger) retainCount 
{
    return NSUIntegerMax; // denotes an object that cannot be released 
}
- (oneway void) release 
{
    // do nothing
    
}
- (id) autorelease 
{
    return self;
}
@end
