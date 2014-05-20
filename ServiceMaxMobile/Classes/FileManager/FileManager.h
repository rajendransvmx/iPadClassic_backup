//
//  FileManager.h
//  ServiceMaxMobile
//
//  Created by Naveen Vasu on 20/03/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManager : NSObject


+ (NSString *)getRootPath;
+ (NSString *)getFilePathForPlist:(NSString *)fileName;

+ (BOOL)createApplicationDirectory;
+ (BOOL)createFileAtPath:(NSString *)filePath;
+ (BOOL)isDirectoryExistsAtPath:(NSString *)path;
+ (BOOL)deleteFileAtPath:(NSString *)filePath;
+ (BOOL)copyFileFromPath:(NSString *)sourcePath toPath:(NSString *)targetPath;
+ (BOOL)moveFileAtPath:(NSString *)sourcePath toPath:(NSString *)targetPath;
+ (BOOL)excludeItemForBackupAtURL:(NSURL *)urlToExcludeForBackup;

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
+ (void)installJavascriptFiles;

@end
