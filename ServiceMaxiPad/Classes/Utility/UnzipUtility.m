//
//  UnzipUtility.m
//  ServiceMaxMobile
//
//  Created by Krishna Shanbhag on 01/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "UnzipUtility.h"
#import "SSZipArchive.h"
#import "FileManager.h"
@implementation UnzipUtility

+ (NSArray *) getListOfCoreLibraries {
    
    NSArray *listOfLibs = [NSArray arrayWithObjects:@"com.servicemax.client.mvc",
                           @"com.servicemax.client.lib",
                           @"com.servicemax.client.runtime",
                           @"com.servicemax.client.sal.sfmconsole.model",
                           @"com.servicemax.client.sfmbizrules",
                           @"com.servicemax.client.sfmconsole.ui.web",
                           @"com.servicemax.client.sfmconsole",
                           @"com.servicemax.client.sfmopdocdelivery.model",
                           @"com.servicemax.client.sfmopdocdelivery",
                           @"com.servicemax.client.tablet.sal.sfmopdoc.model",
                           @"com.servicemax.client",
                           @"com.servicemax.client.installigence.admin",
                           @"com.servicemax.client.installigence.native",
                           @"com.servicemax.client.installigence.offline.model",
                           @"com.servicemax.client.installigence.sync",
                           @"com.servicemax.client.installigence.ui.components",
                           @"com.servicemax.client.installigence.utils",
                           @"com.servicemax.client.installigence",
                           @"com.servicemax.client.sal",
                           @"com.servicemax.client.testframework",
                           @"com.servicemax.client.native.laptop",
                           @"com.servicemax.client.offline.sal.model",
                           @"com.servicemax.client.usage",
                           nil];
    return listOfLibs;
}
/**
 * @name  unzipBundledStaticResourceAtPath
 *
 * @author Krishna Shanbhag
 *
 * @brief Bundled static resource has to me unzipped and moved to the core library folder
 *
 * \par
 * if path is nil : by default it will assume that path is corelibrary
 * path can be specified string which depicts the path to the folder.
 *
 *
 * @return void
 *
 */
+ (void) unzipBundledStaticResourceAtPath:(NSString *)path {

    @autoreleasepool {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (path == nil || [path isEqualToString:@""]) {
            path = [FileManager getCoreLibSubDirectoryPath];
        }
        NSArray *listOflibraries = [self getListOfCoreLibraries];
        BOOL isAppWithSameVersion = [UnzipUtility isAppWithSameVersion:@"SVMXappVersion_Each"];
        for(NSString *fileName in listOflibraries)
        {
            NSString *filepath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"zip"];
            
            if ([fileName isEqualToString:@"com.servicemax.client.lib"]) {
                NSString *clientLibPath = [path stringByDeletingLastPathComponent];
                
                if (!isAppWithSameVersion){
                    [self unzipFileAtPath:filepath toFolder:clientLibPath];
                }else{
                    if([fileManager fileExistsAtPath:[clientLibPath stringByAppendingPathComponent:[[filepath lastPathComponent] stringByDeletingPathExtension]]])
                        continue;
                    [self unzipFileAtPath:filepath toFolder:clientLibPath];
                }
            }
            else {
                if (!isAppWithSameVersion){
                    [self unzipFileAtPath:filepath toFolder:path];
                }else{
                    if([fileManager fileExistsAtPath:[path stringByAppendingPathComponent:[[filepath lastPathComponent] stringByDeletingPathExtension]]])
                        continue;
                    [self unzipFileAtPath:filepath toFolder:path];
                }
            }
        }
        [fileManager removeItemAtPath:[path stringByAppendingPathComponent:@"__MACOSX"] error:NULL];
        
    }
}

/* This function return true for same version and false for New App version */
+ (BOOL)isAppWithSameVersion:(NSString *)versionKey{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentAppVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *previousVersion = [defaults objectForKey:versionKey];
    if (!previousVersion) {
        // first launch
        
        [defaults setObject:currentAppVersion forKey:versionKey];
        [defaults synchronize];
    } else if ([previousVersion isEqualToString:currentAppVersion]) {
        // same version
        
        return TRUE;
    } else {
        // other version
        
        [defaults setObject:currentAppVersion forKey:versionKey];
        [defaults synchronize];
    }
    return FALSE;
}


/**
 * @name  unzipFileAtPath
 *
 * @author Krishna Shanbhag
 *
 * @brief Unzip API which unzips file from source path to destination folder
 *
 * \par
 * filepath : SOurce path
 * destinationFolder : place where the files has to be unzipped
 *
 *
 * @return void
 *
 */
+ (void) unzipFileAtPath:(NSString *)filepath toFolder:(NSString *)destinationFolder {
    BOOL didUnzip = [SSZipArchive unzipFileAtPath:filepath toDestination:destinationFolder];
    if(didUnzip) {
        
        NSError *error = nil;
        if(error != nil)
        {
            SXLogError(@"Static Resource : Error in deleting file at path :\n%@",[error description]);
        }
    }
    else {
        SXLogError(@"Copy CoreLib : Error in unzipping :\n%@",filepath);
    }
    [[NSFileManager defaultManager] removeItemAtPath:[destinationFolder stringByAppendingPathComponent:@"__MACOSX"] error:NULL];
}



// 27690
+ (void) unzipAndReplaceBundledStaticResourceAtPath:(NSString *)path {
    @autoreleasepool {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (path == nil || [path isEqualToString:@""]) {
            path = [FileManager getCoreLibSubDirectoryPath];
        }
        NSArray *listOflibraries = [self getListOfCoreLibraries];
        
        for(NSString *fileName in listOflibraries) {
            NSString *filepath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"zip"];
            
            if ([fileName isEqualToString:@"com.servicemax.client.lib"]) {
                NSString *clientLibPath = [path stringByDeletingLastPathComponent];
                [self unzipFileAtPath:filepath toFolder:clientLibPath];
            }
            else {
                [self unzipFileAtPath:filepath toFolder:path];
            }
        }
        [fileManager removeItemAtPath:[path stringByAppendingPathComponent:@"__MACOSX"] error:NULL];
    }
}


@end
