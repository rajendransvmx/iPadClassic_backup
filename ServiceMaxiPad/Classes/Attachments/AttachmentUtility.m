//
//  AttachmentUtility.m
//  ServiceMaxiPad
//
//  Created by Anoop on 10/29/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "AttachmentUtility.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "TagManager.h"
#import "TagConstant.h"
#import "Base64.h"
#import "SVMXSystemConstant.h"
#import "AlertMessageHandler.h"

@implementation AttachmentUtility

+(NSDictionary*)imageTypesDict {
    
    NSMutableDictionary *imagesDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    [imagesDict setObject:@"jpg" forKey:@".jpg"];
    [imagesDict setObject:@"jpeg" forKey:@".jpeg"];
    [imagesDict setObject:@"bmp" forKey:@".bmp"];
    [imagesDict setObject:@"png" forKey:@".png"];
    [imagesDict setObject:@"tiff" forKey:@".tiff"];
    [imagesDict setObject:@"gif" forKey:@".gif"];
    [imagesDict setObject:@"dib" forKey:@".dib"];
    [imagesDict setObject:@"ico" forKey:@".ico"];
    [imagesDict setObject:@"cur" forKey:@".cur"];
    [imagesDict setObject:@"xbm" forKey:@".xbm"];
    [imagesDict setObject:@"tif" forKey:@".tif"];
    return imagesDict;
    
}

+(NSDictionary*)videoTypesDict {
    
    NSMutableDictionary *videoDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    [videoDict setObject:@"mov" forKey:@".mov"];
    [videoDict setObject:@"m4v" forKey:@".m4v"];
    [videoDict setObject:@"mp4" forKey:@".mp4"];
    [videoDict setObject:@"3gp" forKey:@".3gp"];
    [videoDict setObject:@"3gpp" forKey:@".3gpp"];
    [videoDict setObject:@"3gp2" forKey:@".3gp2"];
    [videoDict setObject:@"3g2" forKey:@".3g2"];
    [videoDict setObject:@"qt" forKey:@".qt"];
    return videoDict;
    
}

+(NSDictionary*)documentTypesDict {
    
    //values with imagename for loading tableviewcell
    NSMutableDictionary *docDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    [docDict setObject:@"Attachment-Powerpoint" forKey:@".ppt"];
    [docDict setObject:@"Attachment-Powerpoint" forKey:@".pptx"];
    [docDict setObject:@"Attachment-PDF" forKey:@".pdf"];
    [docDict setObject:@"Attachment-Word" forKey:@".doc"];
    [docDict setObject:@"Attachment-Word" forKey:@".docx"];
    [docDict setObject:@"Attachment-Excel" forKey:@".xls"];
    [docDict setObject:@"Attachment-Excel" forKey:@".xlsx"];
    [docDict setObject:@"Attachment-SmartDoc" forKey:@".html"];
    //[docDict setObject:@"Attachment-Word" forKey:@".txt"];
    return docDict;
    
}

+ (void)showAlertViewWithTitle:(NSString *)titl msg:(NSString *)msg
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:titl message:msg delegate:self cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] otherButtonTitles:nil];
        [alertView show];
    });
}

+ (NSString *)trimWhitespace:(NSString *)text
{
    NSMutableString *str = [[NSMutableString alloc] initWithString:text];
    CFStringTrimWhitespace((__bridge CFMutableStringRef)str);
    return str;
}


+ (float)getFileSizeInSizeUnit:(unsigned long long)lengthOfContent
{
    float returnLengthOfContent = (float)lengthOfContent;
    
    if(lengthOfContent >= pow(1024, 3)) {
        returnLengthOfContent = (float) (lengthOfContent / (float)pow(1024, 3));
    }
    else if(lengthOfContent >= pow(1024, 2)) {
        returnLengthOfContent = (float) (lengthOfContent / (float)pow(1024, 2));
    }
    else if(lengthOfContent >= 1024) {
        returnLengthOfContent = (float) (lengthOfContent / (float)1024);
    }
    
    return returnLengthOfContent;
}

+ (NSString *)getFileSizeUnit:(unsigned long long)lengthOfContent
{
    NSString *returnString = @"Bytes";
    
    if(lengthOfContent >= pow(1024, 3)) {
        returnString = @"GB";
    }
    else if(lengthOfContent >= pow(1024, 2)){
        returnString = @"MB";
    }
    else if(lengthOfContent >= 1024) {
        returnString = @"KB";
    }
    
    return returnString;
}

+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSString *)docDirectoryPath
{
    NSURL *URL = [NSURL fileURLWithPath:docDirectoryPath];
    if([[NSFileManager defaultManager] fileExistsAtPath:[URL path]])
    {
        NSError *error = nil;
        BOOL success = [URL setResourceValue:[NSNumber numberWithBool:YES] forKey: NSURLIsExcludedFromBackupKey error: &error];
        if(!success)
        {
            SXLogError(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
        }
        return success;
    }
    return NO;
}

+ (uint64_t)getFreeDiskspace
{
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        SXLogError(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {
        SXLogError(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    
    return totalFreeSpace;
}

+ (NSArray*)downloadedAttachments
{
    NSError *error;
    NSArray *downloadedFilesArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[FileManager getAttachmentsSubDirectoryPath] error:&error];
    return downloadedFilesArray;
}

+ (BOOL)deleteAttachment:(AttachmentTXModel *)attachmentModel
{
    BOOL isSuccess = NO;

    NSString *filePath = [self filePathForAttachment:attachmentModel];
    NSError *error = nil;
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    isSuccess = [fileManager removeItemAtPath:filePath error:&error];
    [self deleteDuplicateAttachmentCreated:attachmentModel];
    return isSuccess;
}

+ (NSString*)filePathForAttachment:(AttachmentTXModel*)attachmentModel
{
    NSString *fileDocDirectoryPath = [NSString stringWithFormat:@"%@/%@",[FileManager getAttachmentsSubDirectoryPath],[self fileNameForAttachment:attachmentModel]];
    return fileDocDirectoryPath;
}

+ (NSString*)fileNameForAttachment:(AttachmentTXModel*)attachmentModel
{
    NSString *fileName = [NSString stringWithFormat:@"%@%@",attachmentModel.localId, attachmentModel.extensionName];
    return fileName;
}

+ (NSData *)getEncodedDataForExistingAttachment:(AttachmentTXModel*)attachmentModel
{
    NSData *fileContents = nil;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if([fileManager fileExistsAtPath:[AttachmentUtility filePathForAttachment:attachmentModel]])
    {
        fileContents = [NSData dataWithContentsOfFile:[AttachmentUtility filePathForAttachment:attachmentModel]];
    }
    return fileContents;
}

+ (NSURL *)getUrlForAttachment:(AttachmentTXModel*)attachmentModel
{
    NSString *fullFilePath = nil;
    
    if (attachmentModel.isOutputdoc)
    {
        fullFilePath = [[FileManager getCoreLibSubDirectoryPath] stringByAppendingPathComponent:attachmentModel.name];
    }
    else
    {
        fullFilePath = [AttachmentUtility filePathForAttachment:attachmentModel];
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if([fileManager fileExistsAtPath:fullFilePath])
    {
        return [NSURL fileURLWithPath:fullFilePath];
    }
    return nil;
}

//////

#pragma mark - Attachment Sharing

+(NSString*)fileExtension:(NSString*)fileName
{
    return [fileName pathExtension];
}

+(NSString*)getFullPath:(NSString*)fileName
{
    NSString *Pathtmp =[AttachmentUtility pathForAttachment];
    NSString * FullPath = [NSString stringWithFormat:@"%@/%@",Pathtmp,fileName];
    return FullPath;
}

+(NSString*)getImageForLocalId:(NSString*)fileName
{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *videoPathtmp =[AttachmentUtility pathForAttachment];
    /* Create the file if it doesn't exist already */
    if ([fileManager fileExistsAtPath:videoPathtmp] == NO)
    {
        [fileManager createFileAtPath:videoPathtmp contents:nil attributes:nil];
    }
    return videoPathtmp;
}

+(NSString*)pathForAttachment
{
    NSError *readingError;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDir = [FileManager getAttachmentsSubDirectoryPath];
    if (![fileManager fileExistsAtPath:documentsDir])
        [fileManager createDirectoryAtPath:documentsDir
               withIntermediateDirectories:NO
                                attributes:nil
                                     error:&readingError];
    return documentsDir;
}

+(NSString*)pathToAttachmentfile:(NSString*)localId withExt:(NSString*)ext
{
    NSError *readingError;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableString *documentsDir = (NSMutableString*)[AttachmentUtility pathForAttachment];
    NSString *videoPathtmp = [documentsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", localId,ext]];
    /* Create the file if it doesn't exist already */
    if ([fileManager fileExistsAtPath:videoPathtmp] == NO)
    {
        [fileManager createFileAtPath:videoPathtmp contents:nil attributes:nil];
    }
    else
    {
        [fileManager removeItemAtURL:[NSURL URLWithString:videoPathtmp] error:&readingError];
        [fileManager createFileAtPath:videoPathtmp contents:nil attributes:nil];
    }
    [self addSkipBackupAttributeToItemAtURL:videoPathtmp];
    [self excludeDocumentsDirFilesFromBackup];
    
    return videoPathtmp;
}

+ (void)excludeDocumentsDirFilesFromBackup
{
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSString *documentDirectoryPath = [FileManager getRootPath];
    NSArray *itemsInDocDir = [filemanager contentsOfDirectoryAtPath:documentDirectoryPath error:NULL];
    
    for (NSString *itm in itemsInDocDir)
    {
        [self addSkipBackupAttributeToItemAtURL:[documentDirectoryPath stringByAppendingPathComponent:itm]];
    }
    
}

+(void)removeFileAtPath:(NSString*)path
{
    NSError *readingError;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:path error:&readingError];
}

+(NSString*)writeAttachmentToDocumentDirectory:(NSData*)imageData localId:(NSString*)localId withExt:(NSString*)ext
{
    NSString *videoPathtmp=[AttachmentUtility pathToAttachmentfile:localId withExt:ext];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:videoPathtmp];
    [fileHandle writeData:imageData];
    return videoPathtmp;
    
}

+(NSString*)generateAttachmentNamefor:(NSString*)objectName extension:(NSString*)ext
{
    NSString *imageFileName=@"";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
    NSDate *date = [NSDate date];
    NSString *timeStamp = [dateFormatter stringFromDate:date];
    if([[AttachmentUtility imageTypesDict] valueForKey:ext])
    {
        if(![objectName isEqualToString:@""])
            imageFileName = [NSString stringWithFormat:@"%@+%@%@",objectName,timeStamp, ext];
        else
            imageFileName = [NSString stringWithFormat:@"image+%@%@",timeStamp, ext];
    }
    if([[AttachmentUtility videoTypesDict] valueForKey:ext])
    {
        if(![objectName isEqualToString:@""])
            imageFileName = [NSString stringWithFormat:@"%@+%@%@",objectName,timeStamp, ext];
        else
            imageFileName = [NSString stringWithFormat:@"Capture+%@%@",timeStamp, ext];
    }
    return imageFileName;
}

+(BOOL)doesFileExists:(NSString *)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString * filePath = [AttachmentUtility getFullPath:fileName];
    if ([fileManager fileExistsAtPath:filePath] )
    {
        return YES;
    }
    return NO;
}

+(BOOL)canAttachthisfile:(NSData*)attachmentData type:(NSString*)extensionName
{
    NSUInteger size = [attachmentData length];
    float sizeinMB = (1.0 *size)/1048576; //Size in MB
    NSString * error_message = @"";
    NSString * title = [[TagManager sharedInstance] tagByName:kTagAlertApplicationError];
    
    if([[self imageTypesDict] valueForKey:extensionName])
    {
        error_message = [[TagManager sharedInstance] tagByName:kTagLargeImageWarnig];
    }
    else
    {
        error_message = [[TagManager sharedInstance] tagByName:kTagLargeVideoWarning];
    }
    /** Pushpak defect 10742
     * Salesforce limit is increased from 5mb to 25mb.
     */
    if(sizeinMB > 25)
    {
        [self showAlertViewWithTitle:title msg:error_message];
        return FALSE;
    }
    return TRUE;
}

+ (UIImage *)getThumbnailImageForFilePath:(NSString *)videoFilePath
{
    UIImage *theImage = nil;
    NSURL *url = [[NSURL alloc] initFileURLWithPath:videoFilePath];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    Float64 durationSeconds = CMTimeGetSeconds([asset duration]);
    CMTime midpoint = CMTimeMakeWithSeconds(durationSeconds/2.0, 600);
    NSError *error;
    CMTime actualTime;
    
    CGImageRef halfWayImage = [imageGenerator copyCGImageAtTime:midpoint actualTime:&actualTime error:&error];
    
    if (halfWayImage != NULL) {
        
        NSString *actualTimeString = (NSString *)CFBridgingRelease(CMTimeCopyDescription(NULL, actualTime));
        NSString *requestedTimeString = (NSString *)CFBridgingRelease(CMTimeCopyDescription(NULL, midpoint));
        SXLogInfo(@"Got halfWayImage: Asked for %@, got %@", requestedTimeString, actualTimeString);
        theImage = [[UIImage alloc] initWithCGImage:halfWayImage] ;
        CGImageRelease(halfWayImage);
    }
    return theImage;
}

+(UIImage *)scaleImage:(NSString *)imagePath toSize:(CGSize)newSize
{
    UIImage *image=[UIImage imageWithContentsOfFile:imagePath];
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+(NSInteger)getSizeforFileAtPath:(NSString*)path
{
    NSData *myData = [NSData dataWithContentsOfFile:path];
    return [myData length];
}

+(NSString *)getEncodedBlobDataForAttachment:(AttachmentTXModel*)attachmentModel
{
    NSURL *fullFilePathURL = [AttachmentUtility getUrlForAttachment:attachmentModel];
    NSString *baseString = nil;
    
    if(fullFilePathURL != nil)
    {
        NSData *data = [NSData dataWithContentsOfURL:fullFilePathURL];
        
        if (data != nil && ![data isKindOfClass:[NSNull class]])
        {
            baseString = [Base64 encode:data];
        }
    }
    return baseString;
}

+(NSString *)restAPIErrorMessageByErrorCode:(int)errorcode
{
    
    if (errorcode == NSURLErrorNetworkConnectionLost || errorcode ==
        NSURLErrorNotConnectedToInternet)
    {
        return kNetworkFailureMsg;
    }
    
    if (errorcode == NSURLErrorBadServerResponse || errorcode == NSURLErrorCannotDecodeRawData ||errorcode == NSURLErrorCannotDecodeContentData || errorcode == NSURLErrorCannotParseResponse)
    {
        return kDataCorruptionMsg;
    }
    
    if (errorcode == NSURLErrorFileDoesNotExist || errorcode == NSURLErrorFileIsDirectory)
    {
        return kFileNotFoundMsg;
    }
    
    if (errorcode == NSURLErrorResourceUnavailable)
    {
        return kFileNotSavedMsg;
    }
    
    if (errorcode == NSURLErrorNoPermissionsToReadFile)
    {
        return kUnauthorizedAccessMsg;
    }
    
    if (errorcode  == NSURLErrorCancelled)
    {
        return kRequestCancelledMsg;
    }
    
    if (errorcode == NSURLErrorTimedOut || errorcode == NSURLErrorCannotFindHost || errorcode ==NSURLErrorCannotConnectToHost)
    {
        return kRequestTimeOutMsg;
    }
    
    if (errorcode ==  NSURLErrorUnknown)
    {
        return kUnknownErrorMsg;
    }
    
    return kUnknownErrorMsg;
}


+ (NSString *)getAttachmentAPIErrorMessage:(int)errorcode
{
    if (errorcode == NSURLErrorBadServerResponse || errorcode ==  NSURLErrorCannotDecodeRawData || errorcode == NSURLErrorCannotDecodeContentData || errorcode ==  NSURLErrorCannotParseResponse)
    {
        return [[TagManager sharedInstance] tagByName:kTagDataCorruptionError];
    }
    
    if (errorcode == NSURLErrorFileDoesNotExist || errorcode ==  NSURLErrorFileIsDirectory)
    {
        return [[TagManager sharedInstance] tagByName:kTagFileNotFoundError];
    }
    
    if (errorcode == NSURLErrorResourceUnavailable)
    {
        
        return [[TagManager sharedInstance] tagByName:kTagFileLocallyNotFound];
    }
    
    if (errorcode == NSURLErrorNoPermissionsToReadFile)
    {
        
        return [[TagManager sharedInstance] tagByName:kTagUnauthorisedAccess];
    }
    
    if (errorcode == NSURLErrorTimedOut || errorcode ==  NSURLErrorCannotFindHost || errorcode ==  NSURLErrorCannotConnectToHost)
    {
        
        return [[TagManager sharedInstance] tagByName:kTagNetworkConnectionTimeOut];
    }
    
    if (errorcode == NSURLErrorUnknown)
    {
        return [[TagManager sharedInstance] tagByName:kTagUnknownError];
    }
    
    return [[TagManager sharedInstance] tagByName:kTagUnknownError];
}

#pragma mark - Attachment Sharing
//D-00003728 //Defect 11338
+(NSURL *)getDuplicateAttachmentURL:(AttachmentTXModel *)attachmentModel
{
    NSString *rootPath = [self pathForAttachment];
    NSString *filePath = [rootPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@%@",attachmentModel.nameWithoutExtension, attachmentModel.localId, attachmentModel.extensionName]];
    NSURL *url = nil;
    
    if (filePath != nil)
    {
        return url = [NSURL fileURLWithPath:filePath];
    }
    return url;
}

//Saving duplicate file //Defect 11338
+(BOOL)saveDuplicateAttachmentData:(NSData *)attachmentData forAttachment:(AttachmentTXModel*)attachmentModel
{
    BOOL isSuccess = NO;
    NSString *rootPath = [self pathForAttachment];
    
    if (rootPath == nil)
    {
        return isSuccess;
    }
    
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:[rootPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@%@",attachmentModel.nameWithoutExtension, attachmentModel.localId, attachmentModel.extensionName]] error:&error];
    isSuccess = [attachmentData writeToFile:[rootPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@%@",attachmentModel.nameWithoutExtension, attachmentModel.localId, attachmentModel.extensionName]] atomically:YES];
    return isSuccess;
}

//Defect 11338
+(BOOL)deleteDuplicateAttachmentCreated:(AttachmentTXModel*)attachmentModel
{
    BOOL isSuccess = NO;
    NSString *rootPath = [self pathForAttachment];
    
    if (rootPath == nil)
    {
        return isSuccess;
    }
    NSString *filePath = [rootPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@%@",attachmentModel.nameWithoutExtension, attachmentModel.localId, attachmentModel.extensionName]];
    NSError *error = nil;
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    isSuccess = [fileManager removeItemAtPath:filePath error:&error];
    return isSuccess;
}

+(void)showNewWorkErrorAlert:(AttachmentTXModel*)model
{
    [[AlertMessageHandler sharedInstance] showCustomMessage:[[TagManager sharedInstance] tagByName:KTagAlertInrnetNotAvailableError]
                                               withDelegate:nil
                                                        tag:0
                                                      title:model.name
                                          cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk]
                                       andOtherButtonTitles:nil];
}

@end
