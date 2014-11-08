//
//  AttachmentUtility.h
//  ServiceMaxiPad
//
//  Created by Anoop on 10/29/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#define kAlertTitle @"Attachment Downloads"

#import "FileManager.h"
#import <Foundation/Foundation.h>
#import "AttachmentTXModel.h"

@interface AttachmentUtility : NSObject

+(NSDictionary*)imageTypesDict;

+(NSDictionary*)videoTypesDict;

+(NSDictionary*)documentTypesDict;

/**A method to show any occurred error.
 @param NSString* title for alertview
 @param NSString* messages for alertview
 */
+ (void)showAlertViewWithTitle:(NSString *)titl msg:(NSString *)msg;

/**A method to for deleting all white space characters from provided a string.
 @param NSString* from which we need to remove white space characters.
 @return new string by deleting white space characters
 */
+ (NSString *)trimWhitespace:(NSString *)text;

/**A method for getting unit filesize.
 @param (unsigned long long)contentLength size in bytes.
 @return size in units.
 */
+ (float)calculateFileSizeInUnit:(unsigned long long)contentLength;

/**A method for getting unit.
 @param (unsigned long long)contentLength size in bytes.
 @return units of size e.g MB, KB, GB.
 */
+ (NSString *)calculateUnit:(unsigned long long)contentLength;

+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSString *)docDirectoryPath;

/**A method for getting free disk space.
 @return free disk space.
 */
+ (uint64_t)getFreeDiskspace;

+ (NSArray*)downloadedAttachments;

+ (BOOL)deleteAttachment:(AttachmentTXModel *)attachmentModel;

+ (NSString*)filePathForAttachment:(AttachmentTXModel*)attachmentModel;

+ (NSString*)fileNameForAttachment:(AttachmentTXModel*)attachmentModel;

+ (NSData *)getEncodedDataForExistingAttachment:(AttachmentTXModel*)attachmentModel;

+ (NSURL *)getUrlForAttachment:(AttachmentTXModel*)attachmentModel;

#pragma mark - Attachment Sharing
+(NSString*)fileExtension:(NSString*)fileName;

+(NSString*)fileName:(NSString*)name extension:(NSString*)ext;

+(NSString*)getFullPath:(NSString*)fileName;

+(NSString*)getImageForLocalId:(NSString*)fileName;

+(NSString*)pathForAttachment;

+(NSString*)pathToAttachmentfile:(NSString*)localId withExt:(NSString*)ext;

+(void)removeFileAtPath:(NSString*)path;

+(NSString*)writeAttachmentToDocumentDirectory:(NSData*)imageData localId:(NSString*)localId withExt:(NSString*)ext;

+(BOOL)doesFileExists:(NSString *)fileName;

+(BOOL)canAttachthisfile:(NSData*)attachmentData type:(NSString*)extensionName;

+ (UIImage *)getThumbnailImageForFilePath:(NSString *)videoFilePath;

+(BOOL)conformationforDelete:(id)delegate;

+(UIImage *)scaleImage:(NSString *)imagePath toSize:(CGSize)newSize;

+(NSInteger)getSizeforFileAtPath:(NSString*)path;

+(NSString *)getEncodedBlobDataForLocalId:(NSString *)attachmentLocalId attachmentName:(NSString *)attachmentFileName;

+(NSString *)getAttachmentAPIErrorMessage:(int)restApiErrorCode;

+(NSURL *)getUrlForFilename:(NSString *)fileName;

+(NSData *)getEncodedDataForExistingFile:(NSString *)attachmentLocalId attachmentName:(NSString *)attachmentFileName;

+(BOOL)saveDuplicateAttachmentData:(NSData *)attachmentData inFileName:(NSString *)fileName;

+(BOOL)deleteDuplicateFileCreated:(NSString *)fileName;


@end
