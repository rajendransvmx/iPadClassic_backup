//
//  FileType.h
//  ServiceMaxMobile
//
//  Created by Kirti on 07/11/13.
//  Copyright (c) 2013 SivaManne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "SMAttachmentRequestManager.h"


@interface AttachmentUtility : NSObject<UIAlertViewDelegate>
{
//    ATTACHMENT_TYPE attachment_type;
}
+(NSMutableDictionary*)getAttachmentType:(NSString*)extension;
+(NSString*)pathForAttachment;
+(NSString*)fileName:(NSString*)name extension:(NSString*)ext;
+(NSString*)pathToAttachmentfile:(NSString*)localId withExt:(NSString*)ext;
+(NSMutableArray*)getAttachmentObjectsListofType:(NSString*)AttachmentType dictionaryType:(NSString *)dictionaryType;
+(NSString*)fileExtension:(NSString*)fileName;
+(BOOL)doesFileExists:(NSString *)fileName;
+(NSString*)getFullPath:(NSString*)fileName;
+(BOOL)ErrorInDownloading:(NSString *)local_id;
+(BOOL)DownloadInQueue:(NSString *)local_id;
+(NSString *)getFileType:(NSString *)extention;
+(NSMutableDictionary*)fillDictnarywithfileName:(NSString*)name localId:(NSString*)localId;
+(NSString*)generateAttachmentNamefor:(NSString*)objectName extension:(NSString*)ext;
+(void)attachmentDictonary:(NSMutableDictionary*)attachemntInfo;
+(BOOL)canAttachthisfile:(NSData*)attachmentData type:(NSString*)type;
+(NSString*)writeAttachmentToDocumentDirectory:(NSData*)imageData localId:(NSString*)localId withExt:(NSString*)ext;
+(UIImage *) getThumbnailImageForFile:(NSString *) videoFile;
+(void)deleteIdsFromAttachmentlist:(NSArray *)deleteList  forType:(NSString *)type;
+(BOOL)conformationforDelete:(id)delegate;
+(UIImage *)scaleImage:(NSString *)imagePath toSize:(CGSize)newSize;
+(void)removeFileAtPath:(NSString*)path;
+(void)alert:(NSString*)title message:(NSString*)msg;
+(NSString *)getDate:(NSString *)dateStr withFormat:(NSString *)format;
+(IMAGE_CELL_TYPE)getImageType:(NSDictionary *)dictionary;
+(NSString*)getOPDocPath:(NSString*)fileName;
+(void)insertIntoAttachmentTrailer:(NSDictionary *)dict;
+(ATTACHMENT_STATUS)getAttachmentStaus:(NSDictionary *)dictionary;

+(void)insertIntoAttachmentTrailerForDownload:(NSDictionary *)dict forFileName:(NSString *)fName;
+(void)deleteFromAttachmentTrailerForDownload:(NSString *)attachmentId;

+(NSString *)getEncodedBlobDataForLocalId:(NSString *)attachmentLocalId
                           attachmentName:(NSString *)attachmentFileName;
+(NSDictionary*)getDictnarywithLocalId:(NSString*)localId AttachmentType:(NSString*)type;


+(void)handleAttachmentError;
+ (NSString *)getFormattedSize:(NSString *)sizeString;

+ (void)removeSelectedAttachmentFiles:(NSArray *)files;
+ (NSString *)getAttachmentAPIErrorMessage:(int)restApiErrorCode;//9212
+ (void)deletefromattachmentqueue:(NSString *)attachmentId;  //fix for defect #9219
//Data Purge
+ (void)deleteAttachmentRecordsFromRelatedTable:(NSMutableArray *)purgeableRecords;

@end
