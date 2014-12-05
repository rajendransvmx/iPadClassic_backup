//
//  FileManager.m
//  ServiceMaxMobile
//
//  Created by Naveen Vasu on 20/03/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "FileManager.h"
#import "UnzipUtility.h"

static NSString *const kRootDirectoryName = ORG_NAME_SPACE;
static NSString *const kCoreLibraryDirectoryName = @"CoreLib";
static NSString *const kTroubleshootingDirectoryName = @"Troubleshooting";
static NSString *const kproductManualDirectoryName = @"ProductManual";

@implementation FileManager

+ (NSArray *)getListOfJavascriptFiles
{
    NSArray *javascriptFiles = [NSArray arrayWithObjects:@"OutputDocs.js",
                                       @"CommunicationBridgeJS.js",
                                       @"Utility.js",
                                       @"DataAcessLayer.js",
                                       @"svmx_client_api.js",
                                       @"iOStoJsBridge.js", nil];
    return javascriptFiles;
}


+ (BOOL)createApplicationDirectory
{
    NSLog(@"Create ApplicationDirectory ");

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *rootPath = [FileManager getRootPath];
    
    BOOL isDirectoryExcludedForBackup = NO;
    if ([fileManager fileExistsAtPath:rootPath])
    {
        NSLog(@"Application root directory found");
        isDirectoryExcludedForBackup = YES;
    }
    else
    {
        [fileManager createDirectoryAtPath:rootPath withIntermediateDirectories:YES
                             attributes:nil
                                  error:NULL];
        
        NSURL *urlToExcludeForBackup = [NSURL fileURLWithPath:rootPath];
        BOOL isDirectoryExcludedForBackup = [FileManager excludeItemForBackupAtURL:urlToExcludeForBackup];
        
        if (!isDirectoryExcludedForBackup)
        {
            NSLog(@"Directory not excluded for the backup.");
        }

    }
    return isDirectoryExcludedForBackup;
}


+ (BOOL)createFileAtPath:(NSString *)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (! [fileManager fileExistsAtPath:filePath])
    {
        [fileManager createFileAtPath:filePath contents:NULL attributes:nil];
    }
    return YES;
}


+ (NSString *)getRootPath
{
    NSString * rootPath = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    rootPath = [rootPath stringByAppendingPathComponent:kRootDirectoryName];
   // NSLog(@" path %@",rootPath);
    return rootPath;
}


+ (NSString *)getFilePathForPlist:(NSString *)fileName
{
    NSString *rootPath = [FileManager getRootPath];
    NSString *filePath = [rootPath stringByAppendingPathComponent:fileName];
    return filePath;
}


+ (BOOL)isDirectoryExistsAtPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return ([fileManager fileExistsAtPath:path]);
}


+ (BOOL)copyFileFromPath:(NSString *)sourcePath toPath:(NSString *)targetPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *errorWhileCopying ;
    
   // NSLog(@"Source Path %@", sourcePath);
   // NSLog(@"target Path %@", targetPath);
    
    BOOL isFileCopied = [fileManager copyItemAtPath:sourcePath toPath:targetPath error:&errorWhileCopying];
    
    if (!isFileCopied)
    {
        if (errorWhileCopying != NULL)
        {
            NSLog(@"Error While coping file %@", [errorWhileCopying debugDescription]);
        }
    }
    
 //   NSLog(@"target Path %hhd", isFileCopied);
    return isFileCopied;
}


+ (BOOL)deleteFileAtPath:(NSString *)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *errorWhileDeleting;
    BOOL isFileDeleted = YES;
    
    if ([fileManager fileExistsAtPath:filePath])
    {
        isFileDeleted = [fileManager removeItemAtPath:filePath error:&errorWhileDeleting];
       
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
        NSLog(@"File does not exist at the Path %@", filePath);
    }
    return isFileDeleted;
}


+ (BOOL)moveFileAtPath:(NSString *)sourcePath toPath:(NSString *)targetPath
{
    BOOL isFileMoved = NO;
    NSError *errorWhileMoving;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
 
    if ([fileManager fileExistsAtPath:sourcePath])
    {
        isFileMoved = [fileManager moveItemAtPath:sourcePath toPath:targetPath error:&errorWhileMoving];
        
        if (!isFileMoved)
        {
            if (errorWhileMoving != NULL)
            {
                NSLog(@"Error while moving the file %@", [errorWhileMoving debugDescription]);
            }
        }
    }
    else
    {
        NSLog(@"File does not exist at the Source Path %@.", sourcePath);
    }
    
    return isFileMoved;
}


/**
 * @name  installJavascriptFiles
 *
 * @author Naveen Vasu
 * @author Vipindas Palli
 *
 * @brief Copy JavaScripts file from application bundle and store under application root directory
 *
 * \par
 *     Javascripts files are used as core library or execute engine for calculate some bussiness logic.
 *  These files are mostly used by application feature like GetPrice, OPDocs and Bussiness Rule (biz rule).
 *  If there are any updation on these javascript files it will be bundled and released in next version of app.
 *  Assuming that javascript file never get updated by any web service call.
 *   
 *
 *  Need to copy these file on first time launching of application and application upgrdation time.
 *
 * @return void
 *
 */
+ (void)installJavascriptFiles
{
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSArray  *javascriptFiles = [FileManager getListOfJavascriptFiles];
    
    for (NSInteger i = 0; i < [javascriptFiles count]; i++)
    {
        NSString *filePath = [FileManager getCoreLibSubDirectoryPath];
        filePath = [filePath stringByAppendingPathComponent: [javascriptFiles objectAtIndex:i]];
        
        //NSLog(@"File Path %@", filePath);
        
        // Lets remove all existing file at path
        BOOL isDeleted = [FileManager deleteFileAtPath:filePath];
        
        //NSLog(@"is Deleted %hhd", isDeleted);
        if (! isDeleted)
        {
            NSLog(@"Error while deleting javascript files at path %@", [javascriptFiles objectAtIndex:i]);
        }
        
        [FileManager copyFileFromPath:[resourcePath stringByAppendingPathComponent:[javascriptFiles objectAtIndex:i]] toPath:filePath];
    }
}

/**
 * @name  installCoreLibrary
 *
 * @author Damodar Shenoy
 *
 * @brief Copy bundled core library files from application bundle and store under application root directory
 *
 * \par
 *     Javascripts files are used as core library or execute engine for calculate some bussiness logic.
 *  These files are mostly used by application feature like GetPrice, OPDocs and Bussiness Rule (biz rule).
 *  If there are any updation on these javascript files it will be bundled and released in next version of app.
 *  Assuming that javascript file never get updated by any web service call.
 *
 *
 *  Need to copy these file on first time launching of application and application upgrdation time.
 *
 * @return void
 *
 */
+ (void)installCoreLibrary
{
    NSArray *array = [UnzipUtility getListOfCoreLibraries];
    NSString *pathToCheck = [FileManager getCoreLibSubDirectoryPath];
    
    if(array.count)
    {
        pathToCheck = [pathToCheck stringByAppendingPathComponent:array[0]];
        if(![[NSFileManager defaultManager] fileExistsAtPath:pathToCheck]) // If core library already exists then DONOT unzip
        {
            [UnzipUtility unzipBundledStaticResourceAtPath:[FileManager getCoreLibSubDirectoryPath]];
        }
        else
        {
            NSLog(@"Core library exists!");
        }
    }
    else
    {
        NSLog(@"No bundled core library found!");
    }
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

/** Adding a sub folder under svmx for storing core libraries**/
+ (NSString*)getCoreLibSubDirectoryPath
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString * rootPath = [self getRootPath];
    rootPath = [rootPath stringByAppendingPathComponent:kCoreLibraryDirectoryName];
    if(![fm fileExistsAtPath:rootPath])
    {
        [fm createDirectoryAtPath:rootPath
      withIntermediateDirectories:YES
                       attributes:nil error:NULL];
        
        NSURL *itmURL = [NSURL fileURLWithPath:rootPath];
        [self excludeItemForBackupAtURL:itmURL];
    }
    
    return rootPath;
}

+ (NSString *)getTroubleshootingSubDirectoryPath
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString * rootPath = [self getRootPath];
    rootPath = [rootPath stringByAppendingPathComponent:kTroubleshootingDirectoryName];
    if(![fm fileExistsAtPath:rootPath])
    {
        [fm createDirectoryAtPath:rootPath
      withIntermediateDirectories:YES
                       attributes:nil error:NULL];
        
        NSURL *itmURL = [NSURL fileURLWithPath:rootPath];
        [self excludeItemForBackupAtURL:itmURL];
    }
    
    return rootPath;
}

+ (NSString *)getProductManualSubDirectoryPath
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString * rootPath = [self getRootPath];
    rootPath = [rootPath stringByAppendingPathComponent:kproductManualDirectoryName];
    if(![fm fileExistsAtPath:rootPath])
    {
        [fm createDirectoryAtPath:rootPath
      withIntermediateDirectories:YES
                       attributes:nil error:NULL];
        
        NSURL *itmURL = [NSURL fileURLWithPath:rootPath];
        [self excludeItemForBackupAtURL:itmURL];
    }
    
    return rootPath;
}



/** Adding a sub folder under svmx for storing attachments**/
+ (NSString*)getAttachmentsSubDirectoryPath
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString * rootPath = [self getRootPath];
    BOOL isSuccess = YES;
    rootPath = [rootPath stringByAppendingPathComponent:@"Attachments"];
    if (![fm fileExistsAtPath:rootPath]) {
        isSuccess = [fm createDirectoryAtPath:rootPath
                  withIntermediateDirectories:YES
                                   attributes:nil error:NULL];
    }
    if (!isSuccess) {
        return nil;
    }
    
    return rootPath;
}


@end
