//
//  FileType.m
//  ServiceMaxMobile
//
//  Created by Kirti on 07/11/13.
//  Copyright (c) 2013 SivaManne. All rights reserved.
//

#import "AttachmentUtility.h"
#import "AppDelegate.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "AttachmentDatabase.h"
#import "Utility.h"

#define IS_OPDOC @"isOpdoc"
@implementation AttachmentUtility
+(NSMutableDictionary*)getAttachmentType:(NSString*)extension
{
    NSMutableDictionary *fileTypeInfo=[[NSMutableDictionary alloc]init];
    extension =[extension lowercaseString];
    
    ATTACHMENT_TYPE attachment_type;
    NSArray *imageExtensions=[NSArray arrayWithObjects:@"jpg",@"jpeg",@"bmp",@"png",@"tiff",@"gif",@"dib",@"ico",@"cur",@"xbm", @"tif", nil];
    NSArray *videoExtensions=[NSArray arrayWithObjects:@"mov",@"m4v",@"mp4",@"3gp", nil];

    NSArray *presentationExtension=[NSArray arrayWithObjects:@"ppt", nil];
    NSArray *pdf =[NSArray arrayWithObjects:@"pdf", nil];
    NSArray *document=[NSArray arrayWithObjects:@"doc", @"docx",nil];
    NSArray *spreadsheet=[NSArray arrayWithObjects:@"xls",@"xlsx", nil];

    if([imageExtensions containsObject:extension])
    {
        attachment_type=ATTACHMENT_IMAGE;
    }
    else if([videoExtensions containsObject:extension])
    {
        attachment_type=ATTACHMENT_IMAGE;
    }

    else if([presentationExtension containsObject:extension])
    {
        attachment_type=ATTACHMENT_DOCUMENT;
    }
    else if([pdf containsObject:extension])
    {
        attachment_type=ATTACHMENT_DOCUMENT;
    }
    else if([document containsObject:extension])
    {
        attachment_type=ATTACHMENT_DOCUMENT;
    }
    else if([spreadsheet containsObject:extension])
    {
        attachment_type=ATTACHMENT_DOCUMENT;
    }
    else
    {
        attachment_type=ATTACHMENT_DOCUMENT;

    }
    [fileTypeInfo setObject:[NSString stringWithFormat:@"%d",attachment_type] forKey:@"AttachmentType"];
    return [fileTypeInfo autorelease];
}
+(NSString*)fileExtension:(NSString*)fileName
{
    return [fileName pathExtension];
}
+(NSString*)fileName:(NSString*)name extension:(NSString*)ext
{
    return [NSString stringWithFormat:@"%@.%@",name,ext];
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
    [fileManager release];
    return videoPathtmp;
}
+(NSString*)pathForAttachment
{
    AppDelegate *appdelegate=(AppDelegate*) [[UIApplication sharedApplication] delegate];
    NSError *readingError;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDir = (NSMutableString*)[appdelegate getAppCustomSubDirectory];
    documentsDir=[documentsDir stringByAppendingPathComponent:@"Attachments"];
    if (![fileManager fileExistsAtPath:documentsDir])
        [fileManager createDirectoryAtPath:documentsDir
               withIntermediateDirectories:NO
                                attributes:nil
                                     error:&readingError];
    return documentsDir;
}
+(NSString*)pathToAttachmentfile:(NSString*)localId withExt:(NSString*)ext
{
    AppDelegate *appdelegate=(AppDelegate*) [[UIApplication sharedApplication] delegate];
    NSError *readingError;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableString *documentsDir=(NSMutableString*)[AttachmentUtility pathForAttachment];
    NSString *videoPathtmp = [documentsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", localId,ext]];
    /* Create the file if it doesn't exist already */
    if ([fileManager fileExistsAtPath:videoPathtmp] == NO)
    {
        [fileManager createFileAtPath:videoPathtmp contents:nil attributes:nil];
    }
    else
    {
        [fileManager removeItemAtURL:[NSURL URLWithString:videoPathtmp] error:&readingError];
    }
    [appdelegate addSkipBackupAttributeToItemAtURL:[NSURL URLWithString:videoPathtmp]];
    [appdelegate excludeDocumentsDirFilesFromBackup];

    return videoPathtmp;
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

+(NSMutableArray*)getAttachmentObjectsListofType:(NSString*)AttachmentType dictionaryType:(NSString *)dictionaryType
{
    AppDelegate *appDelegate=(AppDelegate*) [[UIApplication sharedApplication] delegate];

   
    NSMutableDictionary*attachmentDict= [appDelegate.SFMPage objectForKey:ATTACHMENT_DICT];

    NSMutableArray *returnArray=nil;
    if([AttachmentType isEqualToString:DOCUMENT_DICT])
    {
        if([dictionaryType isEqualToString:OBJECT_LIST])
        {
            returnArray= [[attachmentDict objectForKey:DOCUMENT_DICT] objectForKey:OBJECT_LIST];
        }
        else if([dictionaryType isEqualToString:DELETED_IDS])
        {
            returnArray= [[attachmentDict objectForKey:DOCUMENT_DICT] objectForKey:DELETED_IDS];
        }
        else if([dictionaryType isEqualToString:NEW_IDS])
        {
              returnArray= [[attachmentDict objectForKey:DOCUMENT_DICT] objectForKey:NEW_IDS];
        }
    }
    else if([AttachmentType isEqualToString:IMAGES_DICT])
    {
        if([dictionaryType isEqualToString:OBJECT_LIST])
        {
            returnArray= [[attachmentDict objectForKey:IMAGES_DICT] objectForKey:OBJECT_LIST];
        }
        else if([dictionaryType isEqualToString:DELETED_IDS])
        {
            returnArray= [[attachmentDict objectForKey:IMAGES_DICT] objectForKey:DELETED_IDS];
        }
        else if([dictionaryType isEqualToString:NEW_IDS])
        {
            returnArray= [[attachmentDict objectForKey:IMAGES_DICT] objectForKey:NEW_IDS];
        }
    }
    return returnArray;
    
}

+(BOOL)doesFileExists:(NSString *)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *Pathtmp =[AttachmentUtility pathForAttachment];
    NSString * filePath = [NSString stringWithFormat:@"%@/%@",Pathtmp,fileName];
    if ([fileManager fileExistsAtPath:filePath] )
    {
        return YES;
    }
    return NO;
}
+(BOOL)ErrorInDownloading:(NSString *)local_id
{
    AppDelegate *appDelegate=(AppDelegate*) [[UIApplication sharedApplication] delegate];
    return [appDelegate.dataBase ErrorInDownloadingAttachment:local_id];
}
+(BOOL)DownloadInQueue:(NSString *)local_id
{
    AppDelegate *appDelegate=(AppDelegate*) [[UIApplication sharedApplication] delegate];
    return [appDelegate.dataBase DoesAttachmentExistsInQueue:local_id];
}
+(NSString *)getFileType:(NSString *)extension
{
    extension = [extension lowercaseString];
    NSString * type = @"";
    NSArray *imageExtensions=[NSArray arrayWithObjects:@"jpg",@"jpeg",@"bmp",@"png",@"tiff",@"gif",@"dib",@"ico",@"cur",@"xbm", @"tif", nil];
    
    NSArray *videoExtensions=[NSArray arrayWithObjects:@"mov",@"m4v",@"mp4",@"3gp", nil];
    NSArray *presentationExtension=[NSArray arrayWithObjects:@"ppt", nil];
    NSArray *pdf =[NSArray arrayWithObjects:@"pdf", nil];
    NSArray *document=[NSArray arrayWithObjects:@"doc", @"docx",nil];
    NSArray *spreadsheet=[NSArray arrayWithObjects:@"xls",@"xlsx", nil];
    NSArray *html=[NSArray arrayWithObjects:@"html", nil];

    if([imageExtensions containsObject:extension])
    {
        type = IMAGES;
    }
    else if([videoExtensions containsObject:extension])
    {
        type = VEDIO;
    }
    else if ([presentationExtension containsObject:extension])
    {
        type=PRESENTATION;
    }
    else if ([pdf containsObject:extension])
    {
        type = PDF;
    }
    else if([document containsObject:extension])
    {
        type=DOCUMENT;
    }
    else if ([spreadsheet containsObject:extension])
    {
        type =SPREADSHEET;
    }
    else if ([html containsObject:extension])
    {
        type =OPDOC;
    }
    else
    {
        type=UNKNOWNTYPE;
    }
    return type;
}
+(void)attachmentDictonary:(NSMutableDictionary*)attachemntInfo
{
    AppDelegate *appDelegate=(AppDelegate*) [[UIApplication sharedApplication] delegate];
    if([[attachemntInfo objectForKey:@"Operation"] isEqualToString:DELETE_ATTACHMENT])
    {
        NSMutableArray *array=[self getAttachmentObjectsListofType:[attachemntInfo objectForKey:@"AttachmentType"] dictionaryType:OBJECT_LIST];
        NSDictionary *dict=[self getDictnarywithLocalId:[attachemntInfo objectForKey:@"local_id"] AttachmentType:[attachemntInfo objectForKey:@"AttachmentType"]];
        [array removeObject:dict];
        
        NSMutableArray *arraydeletedId = [self getAttachmentObjectsListofType:[attachemntInfo objectForKey:@"AttachmentType"] dictionaryType:DELETED_IDS];
        [arraydeletedId addObject:[attachemntInfo objectForKey:@"local_id"]]; // if added in newids and removed then
        
        NSMutableArray *newIds=[self getAttachmentObjectsListofType:[attachemntInfo objectForKey:@"AttachmentType"] dictionaryType:DELETED_IDS];
        if([newIds containsObject:[attachemntInfo objectForKey:@"local_id"]])
        {
            [newIds removeObject:[attachemntInfo objectForKey:@"local_id"]];
        }

    }
    else if([[attachemntInfo objectForKey:@"Operation"] isEqualToString:NEW_ATTACHMENT])
    {
        NSMutableArray *array=[self getAttachmentObjectsListofType:[attachemntInfo objectForKey:@"AttachmentType"] dictionaryType:OBJECT_LIST];
        
        NSString *objectName = [appDelegate.dataBase getNameFor:appDelegate.sfmPageController.objectName local_id:appDelegate.sfmPageController.recordId];
        
        NSString *name=[self generateAttachmentNamefor:objectName extension:[attachemntInfo objectForKey:@"Extension"]];
        NSMutableDictionary *newAttachmentDict= [self fillDictnarywithfileName:name localId:[attachemntInfo objectForKey:@"local_id"]];
        [array insertObject:newAttachmentDict atIndex:0];
//        [array addObject:newAttachmentDict];
        NSMutableArray *arrayNewId=[self getAttachmentObjectsListofType:[attachemntInfo objectForKey:@"AttachmentType"] dictionaryType:NEW_IDS];
        [arrayNewId addObject:[attachemntInfo objectForKey:@"local_id"]];
        
    }
    
}
 +(NSDictionary*)getDictnarywithLocalId:(NSString*)localId AttachmentType:(NSString*)type
 {
     NSMutableArray *array=[self getAttachmentObjectsListofType:type dictionaryType:OBJECT_LIST];
     int i=0;
     NSDictionary *dict=nil;
     for(dict in array)
     {
         if([[dict objectForKey:K_ATTACHMENT_ID] isEqualToString:localId])
         {
             //NSLog(@"%@",[array objectAtIndex:i]);
             return [array objectAtIndex:i];
         }
         i++;

     }
     return dict;
 }

+(NSMutableDictionary*)fillDictnarywithfileName:(NSString*)name localId:(NSString*)localId
{
    AppDelegate *appDelegate=(AppDelegate*) [[UIApplication sharedApplication] delegate];
   NSString *sf_id = [appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:appDelegate.sfmPageController.objectName local_id:appDelegate.sfmPageController.recordId];
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:DATETIMEFORMAT];
    NSDate * date = [NSDate date];
    [dateFormatter  setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString * dateString = [dateFormatter stringFromDate:date];//.000Z
    
    if(dateString != nil)
    {
        dateString = [iOSInterfaceObject getGMTFromLocalTime:dateString];
        dateString = [dateString  stringByReplacingOccurrencesOfString:@"Z" withString:@".000+0000"];
    }
    NSArray *keysArray=[NSArray arrayWithObjects:K_ACTION,K_ATTACHMENT_ID,K_CONTEN_TYPE,K_DESCRIPTION,K_NAME,K_PRIORITY,K_SECTION,K_SIZE,K_STATUS,K_TYPE,K_PARENT_SFId,K_PERCENTPROGRESS,K_LASTMODIFIEDDATE,K_PARENT_LOCALId,K_ATTACHMENT_SFID, nil];

    NSString *path= [self pathToAttachmentfile:localId withExt:[name pathExtension]];
    int size=[self getSizeforFileAtPath:path];
    NSMutableDictionary *attachTypeDict=[AttachmentUtility getAttachmentType:[name pathExtension]];
    
    NSString *contentType=@"";
    
    if([[name pathExtension] isEqualToString:@"png"])
        contentType = @"image/png";
    else
        contentType = @"video/quicktime";
    NSString *parentLocalId=(appDelegate.sfmPageController.recordId != nil)?appDelegate.sfmPageController.recordId:@"";
    NSArray *valueArray=[NSArray arrayWithObjects:@"UPLOAD",localId,contentType,@"",name,@"0",[attachTypeDict objectForKey:@"AttachmentType"],[NSString stringWithFormat:@"%d",size],@"",[name pathExtension],sf_id,@"",dateString,parentLocalId,@"", nil];

    NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithObjects:valueArray forKeys:keysArray];
    [dateFormatter release];
    
    return  [dict autorelease];
}
+(NSString*)generateAttachmentNamefor:(NSString*)objectName extension:(NSString*)ext
{
    NSString *imageFileName=@"";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
    NSDate *date = [NSDate date];
    NSString *timeStamp = [dateFormatter stringFromDate:date];
    NSString *attachmentType=[self getFileType:ext];
    if([attachmentType isEqualToString:IMAGES])
    {
        if(![objectName isEqualToString:@""])
            imageFileName = [NSString stringWithFormat:@"%@+%@.png",objectName,timeStamp];
        else
            imageFileName = [NSString stringWithFormat:@"image+%@.png",timeStamp];
    }
    if([attachmentType isEqualToString:VEDIO])
    {
        if(![objectName isEqualToString:@""])
            imageFileName = [NSString stringWithFormat:@"%@+%@.mov",objectName,timeStamp];
        else
            imageFileName = [NSString stringWithFormat:@"Capture+%@.mov",timeStamp];
    }
    [dateFormatter release];
    return imageFileName;
}
+(BOOL)canAttachthisfile:(NSData*)attachmentData type:(NSString*)type
{
     AppDelegate *appDelegate =(AppDelegate*) [[UIApplication sharedApplication]delegate];
    NSUInteger size = [attachmentData length];
    float sizeinMB = (1.0 *size)/1048576; //Size in MB

    NSString * error_message = @"";

     NSString * Title = [appDelegate.wsInterface.tagsDictionary objectForKey:alert_application_error];
    if([type isEqualToString:IMAGES_DICT])
    {
         error_message=[appDelegate.wsInterface.tagsDictionary objectForKey:LARGE_IMAGE_WARNING];
    }
    else
    {
        error_message=[appDelegate.wsInterface.tagsDictionary objectForKey:LARGE_VIDEO_WARNING];

    
    }
    if(sizeinMB >5)
    {
        [self alert:Title message:error_message];
        return FALSE;
    }
    return TRUE;

}

+(void)alert:(NSString*)title message:(NSString*)msg
{
    AppDelegate *appDelegate=(AppDelegate*) [[UIApplication sharedApplication] delegate];
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK] otherButtonTitles:nil, nil];
    [alertView show];
    [alertView release];
}
+(UIImage *) getThumbnailImageForFile:(NSString *) videoFile
{
    UIImage *theImage = nil;
    NSURL *url = [[NSURL alloc] initFileURLWithPath:videoFile];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    [url release];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    NSError *err = NULL;
    CMTime time = CMTimeMake(1, 60);
    CGImageRef imgRef = [generator copyCGImageAtTime:time actualTime:NULL error:&err];
    
    theImage = [[UIImage alloc] initWithCGImage:imgRef] ;
    CGImageRelease(imgRef);
    return [theImage autorelease];
 }

+(void)deleteIdsFromAttachmentlist:(NSArray *)deleteList  forType:(NSString *)type
{
    //pass the type use it as the variable
//    if([type isEqualToString:IMAGES_DICT])
//    {
        NSMutableArray * imagesArry = [AttachmentUtility getAttachmentObjectsListofType:type dictionaryType: OBJECT_LIST];
        NSMutableArray * removObjects = [[NSMutableArray alloc]initWithCapacity:0];
        NSMutableArray * deletedIdsArry = [AttachmentUtility getAttachmentObjectsListofType:type dictionaryType:DELETED_IDS];
        NSMutableArray *newIdsArray = [AttachmentUtility getAttachmentObjectsListofType:type dictionaryType:NEW_IDS];
        for ( NSDictionary * dict in imagesArry)
        {
            NSString * attachmentId = [dict objectForKey:K_ATTACHMENT_ID];
            if([deleteList containsObject:attachmentId])
            {
              /*  [imagesArry removeObject:dict];*/
                 // remove file at path
                NSString *fileName=[self fileName:[dict objectForKey:K_ATTACHMENT_ID] extension:[dict objectForKey:K_TYPE]];
                NSString *path=[self getFullPath:fileName];
                [self removeFileAtPath:path];
               
                [removObjects addObject:dict];
                [deletedIdsArry addObject:attachmentId];
                
                [AttachmentUtility deletefromattachmentqueue:attachmentId]; //Fix for defect #9219
            }
        }
        
        for(NSDictionary * dict in removObjects)
        {
            [imagesArry removeObject:dict];
        }
        //remove from newids
        for (int i=0; i<[newIdsArray count]; i++) {
            if([deleteList containsObject:[newIdsArray objectAtIndex:i]])
            {
                [newIdsArray removeObject:[newIdsArray objectAtIndex:i]];
            }
        }
        
        
//    }
    
}

/*
+(BOOL)conformationforDelete:(id)delegate
{
    NSString *message = [appDelegate.wsInterface.tagsDictionary objectForKey:DOC_DELETE_CONFIRMATION];
    NSString *delete = [appDelegate.wsInterface.tagsDictionary objectForKey:DELETE_ACTION];
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"" message:message delegate:delegate cancelButtonTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:CANCEL_BUTTON_TITLE] otherButtonTitles:delete, nil];
	[alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    [alert release];
    return YES;
}
*/


+(BOOL)conformationforDelete:(id)delegate
{
    // Vipin - 9088
    NSString *message = [appDelegate.wsInterface.tagsDictionary objectForKey:DOC_DELETE_CONFIRMATION];

    NSString *delete = [appDelegate.wsInterface.tagsDictionary objectForKey:DELETE_BUTTON_TITLE];
    NSString *message1 = [appDelegate.wsInterface.tagsDictionary objectForKey:DELETE_LOCALLY_ACTION];
    
    NSString * alertMesage = [NSString stringWithFormat:@"%@\n\n%@", message, message1];
    
  
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@""
                                                  message:alertMesage
                                                 delegate:delegate
                                        cancelButtonTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:CANCEL_BUTTON_TITLE] otherButtonTitles:delete, nil];
	
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    [alert release];
    return YES;
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


+(NSString *)getDate:(NSString *)dateStr withFormat:(NSString *)format
{
    NSString * locatDateStr = [iOSInterfaceObject getLocalTimeFromGMT:dateStr];
    locatDateStr = [locatDateStr stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    locatDateStr = [locatDateStr stringByReplacingOccurrencesOfString:@"Z" withString:@""];
    NSDateFormatter * frm = [[[NSDateFormatter alloc] init] autorelease];
    [frm setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSDate * date = [frm dateFromString:locatDateStr];
    [frm  setDateFormat:format];
    NSString * finaldate = [frm stringFromDate:date];
    return finaldate;
}

+(IMAGE_CELL_TYPE)getImageType:(NSDictionary *)dictionary
{
    NSString *documentName = [AttachmentUtility getDocumentFileName:dictionary];
    NSString * attachmentId = [dictionary objectForKey:K_ATTACHMENT_ID];
    
    if([AttachmentUtility doesFileExists:documentName])
    {
        return IMAGE_EXISTS;
    }
    else if(![AttachmentUtility ErrorInDownloading:attachmentId])
    {
        return DOWNLOAD_IMAGE;
    }
    else if([AttachmentUtility ErrorInDownloading:attachmentId])
    {
        return ERROR_IN_DOWNLOAD;
    }
    return DEFAULT;
}

//9128
+(ATTACHMENT_STATUS)getAttachmentStaus:(NSDictionary *)dictionary
{
    NSString *isOpDoc = [dictionary objectForKey:IS_OPDOC];
    if ([isOpDoc isEqualToString:@"true"]) {
        return ATTACHMENT_STATUS_EXISTS;
    }
    NSString *documentName = [AttachmentUtility getDocumentFileName:dictionary];
    NSString * attachmentId = [dictionary objectForKey:K_ATTACHMENT_ID];
    
    if([AttachmentUtility doesFileExists:documentName])
    {
        return ATTACHMENT_STATUS_EXISTS;
    }
    else if([AttachmentUtility ErrorInDownloading:attachmentId])
    {
        
        return ATTACHMENT_STATUS_ERROR_IN_DOWNLOAD;
    }
    else
    {
        
        ATTACHMENT_STATUS status = [appDelegate.dataBase getAttachmentsStatus:attachmentId];
        if (status != ATTACHMENT_STATUS_UNKNOWN) {
            return status;
        }
        else{
            return ATTACHMENT_STATUS_YET_TO_DOWNLOAD;
        }
    }
    return ATTACHMENT_STATUS_UNKNOWN;
}

+(NSString *)getDocumentFileName:(NSDictionary *)dict
{
     AppDelegate *appDelegate =(AppDelegate*) [[UIApplication sharedApplication]delegate];
    NSString * attachmentId = [dict objectForKey:K_ATTACHMENT_ID];
    NSString * fileName = [dict objectForKey:K_NAME];
    NSString * extension = [AttachmentUtility fileExtension:fileName];
    NSString *objectName=@"";
    objectName=appDelegate.sfmPageController.objectName;
    NSString * documentName = [AttachmentUtility fileName:attachmentId extension:extension];
    return documentName;
}

+(NSString*)getOPDocPath:(NSString*)fileName
{
     AppDelegate *appDelegate =(AppDelegate*) [[UIApplication sharedApplication]delegate];
    NSString *Pathtmp =[appDelegate getAppCustomSubDirectory];
    NSString * FullPath = [NSString stringWithFormat:@"%@/%@",Pathtmp,fileName];
    return FullPath;
}

+(void)insertIntoAttachmentTrailer:(NSDictionary *)dict;
{
    AppDelegate *appDelegate =(AppDelegate*) [[UIApplication sharedApplication]delegate];
    //call  insertIntoSFAttachmentTrailer AttachmentDatabase.m method
    [appDelegate.attachmentDataBase insertIntoSFAttachmentTrailer:dict];
//    [appDelegate.attachmentDataBase startQueue];
}

+(void)insertIntoAttachmentTrailerForDownload:(NSDictionary *)dict forFileName:(NSString *)fName;
{
    AppDelegate *appDelegate =(AppDelegate*) [[UIApplication sharedApplication]delegate];
    //call  insertIntoSFAttachmentTrailer AttachmentDatabase.m method
    [appDelegate.attachmentDataBase insertIntoSFAttachmentTrailerForDownload:dict withFileName:fName];
    
}

+(void)deleteFromAttachmentTrailerForDownload:(NSString *)attachmentId;
{
    
    AppDelegate *appDelegate =(AppDelegate*) [[UIApplication sharedApplication]delegate];
    //call  insertIntoSFAttachmentTrailer AttachmentDatabase.m method
    [appDelegate.attachmentDataBase deleteFromAttachmentTrailerTable:attachmentId];
}
+(int)getSizeforFileAtPath:(NSString*)path
{
    NSData *myData = [NSData dataWithContentsOfFile:path];
    return [myData length];
}
+(NSString *)getEncodedBlobDataForLocalId:(NSString *)attachmentLocalId attachmentName:(NSString *)attachmentFileName
{
    NSString * encodedData = nil;
    // handling if data not exist in Attachment table
    NSString *filePath = [AttachmentUtility fileName:attachmentLocalId
                                               extension:[attachmentFileName pathExtension]];
    
    NSString *fullFilePath = [AttachmentUtility getFullPath:filePath] ;
    NSFileManager *fileManager    = [NSFileManager defaultManager];
   
    //NSError *error = nil;
    if([fileManager fileExistsAtPath:fullFilePath])
    {
        NSData *fileContents = [NSData dataWithContentsOfFile:fullFilePath];
        
        if (fileContents!=nil)
        {
            encodedData = [Base64 encode:fileContents];
        }
    }
    return encodedData;
}

+(void)handleAttachmentError
{
   NSMutableArray * errorList = [appDelegate.attachmentDataBase getErrorInAttachmentObject];

    for (int counter = 0; counter < [errorList count];counter++)
    {
        NSDictionary * errordict = [errorList objectAtIndex:counter];
        NSString * syncFlag = [errordict objectForKey:kSyncFlag];
        NSString * attachmentId = [errordict objectForKey:kAttachmentTrailerId];
        NSString * action = [errordict objectForKey:kActon];
        if([syncFlag isEqualToString:@"Retry"])
        {
            //insert record into SFAttachmentTrailer
            //delete entry from attachmentError table
            
            if([action isEqualToString:@"DOWNLOAD"])
            {
                NSString * fileSize = [appDelegate.attachmentDataBase getSizeForAttachmentId:[errordict objectForKey:kAttachmentTrailerId]];
                NSArray *keyAttachment = [NSArray arrayWithObjects:@"Action",@"Status",@"Priority",@"Size",@"per_Progress",@"parent_sfid",@"type",@"file_name",K_ATTACHMENT_ID,@"parent_localid", nil];
                NSArray *valueAttachment = [NSArray arrayWithObjects:action,@"",@"",fileSize,@"",[errordict objectForKey:K_PARENT_SFId],@"",[errordict objectForKey:kFileName],[errordict objectForKey:kAttachmentTrailerId],[errordict objectForKey:K_PARENT_LOCALId],nil];
                
                NSDictionary * attachmentDict = [NSDictionary dictionaryWithObjects:valueAttachment forKeys:keyAttachment];
                [appDelegate.attachmentDataBase insertIntoSFAttachmentTrailerForDownload:attachmentDict withFileName:[errordict objectForKey:kFileName]];
            }
            else if ([action isEqualToString:@"UPLOAD"])
            {
                NSString * fileSize = [appDelegate.attachmentDataBase getSizeForAttachmentId:[errordict objectForKey:kAttachmentTrailerId]];
                NSArray *keyAttachment = [NSArray arrayWithObjects:@"Action",@"Status",@"Priority",@"Size",@"per_Progress",K_PARENT_SFId,@"type",K_NAME,K_ATTACHMENT_ID,K_PARENT_LOCALId, nil];
                NSArray *valueAttachment = [NSArray arrayWithObjects:action,@"",@"",fileSize,@"",[errordict objectForKey:K_PARENT_SFId],@"",[errordict objectForKey:kFileName],[errordict objectForKey:kAttachmentTrailerId],[errordict objectForKey:K_PARENT_LOCALId],nil];
                
                NSDictionary * attachmentDict = [NSDictionary dictionaryWithObjects:valueAttachment forKeys:keyAttachment];
                [appDelegate.attachmentDataBase insertIntoSFAttachmentTrailer:attachmentDict];
            }
            [appDelegate.attachmentDataBase deleteFromAttachmentErrorTable:attachmentId];
        }
        else if([syncFlag isEqualToString:@"Remove"])
        {
             //delete entry from attachmentError table
            [appDelegate.attachmentDataBase deleteFromAttachmentErrorTable:attachmentId];
        }
    }
}
+ (NSString *)getFormattedSize:(NSString *)sizeString {
    
    NSString *finalString = sizeString;
    NSArray *subStrings = [sizeString componentsSeparatedByString:@"."];
    if ([subStrings count] > 1) {
        NSString *firstString = [subStrings objectAtIndex:0];
        NSString *secondString = [subStrings objectAtIndex:1];
        if ([secondString length] > 2) {
            secondString = [secondString substringToIndex:2];
        }
        if (![Utility isStringEmpty:secondString]) {
            finalString = [NSString stringWithFormat:@"%@.%@",firstString,secondString];
        }
    }
    return finalString;
}


+ (void)removeSelectedAttachmentFiles:(NSArray *)files
{
    NSString *pathtmp =[AttachmentUtility pathForAttachment];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtPath:pathtmp];
    
    NSMutableDictionary *fileDictionary = [[NSMutableDictionary alloc] init];
    // Lets creat map
    for (NSString *fileLocalId in files)
    {
        [fileDictionary setObject:fileLocalId forKey:fileLocalId];
    }
    
    
    NSString *file = nil;
    NSMutableArray *newlyCreatedIds = [[NSMutableArray alloc]init];
    
    while ((file = [dirEnum nextObject])) {
        
        if (file!= nil)
        {
            NSString *filePathWithoutExtention = [file stringByDeletingPathExtension];
            
            if ([fileDictionary objectForKey:filePathWithoutExtention] != nil)
            {
                NSString *sfid = [appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:@"Attachment" local_id:filePathWithoutExtention];
                NSString *localId = filePathWithoutExtention;
                
                BOOL shouldRemoveAttachment  =  NO;
                
                if (sfid.length < 3)
                {
                    // Ohhh We have Attachment which is not synced with Server
                    shouldRemoveAttachment = YES;
                    //filePathWithoutExtention is localId
                    [newlyCreatedIds addObject:filePathWithoutExtention];
                }
                
                NSString *completeFilePath = [pathtmp stringByAppendingPathComponent:file];
                [fileDictionary setObject:completeFilePath forKey:filePathWithoutExtention];
                
                if ([fileManager  fileExistsAtPath:completeFilePath])
                {
                    if ([fileManager  isDeletableFileAtPath:completeFilePath])
                    {
                        
                        NSError *readingError;
                        
                        BOOL isDeleted = [fileManager removeItemAtPath:completeFilePath error:&readingError];
                        
                        
                        if (!isDeleted)
                        {
                            //NSLog(@" Deleted Not success");
                            
                            if (nil != readingError)
                            {
                                //NSLog(@" readingError  %@", [readingError description]);
                            }
                            else
                            {
                                if (shouldRemoveAttachment)
                                {
                                    BOOL recordDeleted =  [appDelegate.databaseInterface DeleterecordFromTable:@"Attachment" Forlocal_id:localId];
                                    
                                    if (recordDeleted)
                                    {
                                        //NSLog(@" Deleted successfully record and file");
                                    }else
                                    {
                                        //NSLog(@" Deleted successfully  file");
                                    }
                                }
                            }
                        }else
                        {
                            if (shouldRemoveAttachment)
                            {
                                
                                BOOL recordDeleted =  [appDelegate.databaseInterface DeleterecordFromTable:@"Attachment"Forlocal_id:localId];
                                if (recordDeleted)
                                {
                                    //NSLog(@" Deleted successfully record and file");
                                }else
                                {
                                    //NSLog(@" Deleted successfully  file");
                                }
                            }
                            else
                            {
                                //NSLog(@" Deletion file action is success");
                            }
                        }
                    }
                    else
                    {
                        //NSLog(@"  File is not DELETABLE file at path :%@", completeFilePath);
                    }
                }else
                {
                    //NSLog(@"  File is not EXIST in Path :%@", completeFilePath);
                }
            }
        }
    }
    
    //NSLog(@"  fileDictionary :%@", [fileDictionary description]);
    
    if ([newlyCreatedIds count] > 0) {
        [AttachmentUtility deleteIdsfromDictnary:newlyCreatedIds];
    }
    
    //fix for defect #9219
    for(NSString * newId in newlyCreatedIds)
    {
        [AttachmentUtility deleteFromAttachmentTrailerForDownload:newId];
    }
    // Fix For Defect 9219
    [[SMAttachmentRequestManager sharedInstance] cancelRequestForIds:files];

    
    [newlyCreatedIds release];
    newlyCreatedIds = nil;
    
    [fileDictionary removeAllObjects];
    [fileDictionary release];
    fileDictionary = nil;
}
/*{
    NSString *pathtmp =[AttachmentUtility pathForAttachment];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtPath:pathtmp];
    
    NSMutableDictionary *fileDictionary = [[NSMutableDictionary alloc] init];
    // Lets creat map
    for (NSString *fileLocalId in files)
    {
        [fileDictionary setObject:fileLocalId forKey:fileLocalId];
    }
    
   
    NSString *file = nil;

    while ((file = [dirEnum nextObject])) {
        
        if (file!= nil)
        {
            NSString *filePathWithoutExtention = [file stringByDeletingPathExtension];
            
           if ([fileDictionary objectForKey:filePathWithoutExtention] != nil)
           {
               NSString *sfid = [appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:@"Attachment" local_id:filePathWithoutExtention];
               NSString *localId = filePathWithoutExtention;

               BOOL shouldRemoveAttachment  =  NO;
               
               if (sfid == nil)
               {
                   // Ohhh We have Attachment which is not synced with Server
                   shouldRemoveAttachment = YES;
               }
               
               NSString *completeFilePath = [pathtmp stringByAppendingPathComponent:file];
               [fileDictionary setObject:completeFilePath forKey:filePathWithoutExtention];
               
               if ([fileManager  fileExistsAtPath:completeFilePath])
               {
                   if ([fileManager  isDeletableFileAtPath:completeFilePath])
                   {

                      NSError *readingError;
                       
                      BOOL isDeleted = [fileManager removeItemAtPath:completeFilePath error:&readingError];
                      
                       
                       if (!isDeleted)
                       {
                           NSLog(@" Deleted Not success");

                           if (nil != readingError)
                           {
                               NSLog(@" readingError  %@", [readingError description]);
                           }
                           else
                           {
                               if (shouldRemoveAttachment)
                               {
                                   BOOL recordDeleted =  [appDelegate.databaseInterface DeleterecordFromTable:@"Attachment"Forlocal_id:localId];
                                   
                                   if (recordDeleted)
                                   {
                                       NSLog(@" Deleted successfully record and file");
                                   }else
                                   {
                                        NSLog(@" Deleted successfully  file");
                                   }
                               }
                           }
                       }else
                       {
                           if (shouldRemoveAttachment)
                           {
                              
                              BOOL recordDeleted =  [appDelegate.databaseInterface DeleterecordFromTable:@"Attachment"Forlocal_id:localId];
                               if (recordDeleted)
                               {
                                   NSLog(@" Deleted successfully record and file");
                               }else
                               {
                                   NSLog(@" Deleted successfully  file");
                               }
                           }
                           else
                           {
                               NSLog(@" Deletion file action is success");
                           }
                       }
                   }
                   else
                   {
                       NSLog(@"  File is not DELETABLE file at path :%@", completeFilePath);
                   }
               }else
               {
                   NSLog(@"  File is not EXIST in Path :%@", completeFilePath);
               }
           }
        }
    }

    [fileDictionary removeAllObjects];
    [fileDictionary release];
    fileDictionary = nil;
}
*/

+(void)deleteIdsfromDictnary:(NSArray*)deletedList
{
        NSMutableArray * imagesArry = [AttachmentUtility getAttachmentObjectsListofType:IMAGES_DICT dictionaryType: OBJECT_LIST];
        NSMutableArray * removObjects = [[NSMutableArray alloc]initWithCapacity:0];
        NSMutableArray *newIdsArray = [AttachmentUtility getAttachmentObjectsListofType:IMAGES_DICT dictionaryType:NEW_IDS];
        for ( NSDictionary * dict in imagesArry)
        {
            NSString * attachmentId = [dict objectForKey:K_ATTACHMENT_ID];
            if([deletedList containsObject:attachmentId])
            {
                // remove file at path
                [removObjects addObject:dict];
            }
        }
        
        for(NSDictionary * dict in removObjects)
        {
            [imagesArry removeObject:dict];
        }
        //remove from newids
        for (int i=0; i<[newIdsArray count]; i++) {
            if([deletedList containsObject:[newIdsArray objectAtIndex:i]])
            {
                [newIdsArray removeObject:[newIdsArray objectAtIndex:i]];
            }
        }
        
        
    
}
//9212
+ (NSString *)getAttachmentAPIErrorMessage:(int)restApiErrorCode
{
    NSString *errorMessage = nil;
    switch (restApiErrorCode)
    {
        case SMAttachmentRequestErrorCodeDataCorruption:
        {
            errorMessage = [appDelegate.wsInterface.tagsDictionary objectForKey:DATA_CORRUPTION_ERROR];
        }
            break;
            
        case SMAttachmentRequestErrorCodeFileNotFound:
        {
            errorMessage = [appDelegate.wsInterface.tagsDictionary objectForKey:FILE_NOT_FOUND_ERROR];
        }
            break;
            
        case SMAttachmentRequestErrorCodeFileNotSaved:
        {
            
            errorMessage = [appDelegate.wsInterface.tagsDictionary objectForKey:FILE_NOT_FOUND_LOCALLY];
        }
            
            break;
            
        case SMAttachmentRequestErrorCodeUnauthorizedAccess:
        {
            
            errorMessage = [appDelegate.wsInterface.tagsDictionary objectForKey:UNAUTHORIZED_ACCESS];
        }
            break;
            
        case SMAttachmentRequestErrorCodeRequestTimeOut:
        {
            
            errorMessage = [appDelegate.wsInterface.tagsDictionary objectForKey:NETWORK_CONNECTION_TIMEOUT];
        }
            break;
            
        case SMAttachmentRequestErrorCodeUnknown:
        {
            
            errorMessage = [appDelegate.wsInterface.tagsDictionary objectForKey:UNKNOWN_ERROR];
        }
            break;
            
        default:
            //errorMessage = [SVMXSystemConstant restAPIErrorMessageByErrorCode:restApiErrorCode];
            errorMessage = [appDelegate.wsInterface.tagsDictionary objectForKey:UNKNOWN_ERROR];//9237
            break;
    }
    
    
    return errorMessage;
    
}

 //fix for defect #9219
+(void)deletefromattachmentqueue:(NSString *)attachmentId
{
    NSString *sfid = [appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:@"Attachment" local_id:attachmentId];
    if (sfid.length < 3)
    {
        //fix for defect #9219
        [AttachmentUtility deleteFromAttachmentTrailerForDownload:attachmentId];
         BOOL recordDeleted =  [appDelegate.databaseInterface DeleterecordFromTable:@"Attachment" Forlocal_id:attachmentId];
        if(!recordDeleted)
        {
            NSLog(@"deletefromattachmentqueue failed to delete attachmentId:%@",attachmentId);
        }
        // Fix For Defect 9219
        [[SMAttachmentRequestManager sharedInstance] cancelRequestForIds:[NSArray arrayWithObject:attachmentId]];
    }
    else
    {
        return;
    }
}

//Data Purge
+ (void)deleteAttachmentRecordsFromRelatedTable:(NSMutableArray *)purgeableRecords
{
    @autoreleasepool
    {
        if (purgeableRecords != nil)
        {
            NSString * idSeparetedByComas = nil;
            
            [self removeSelectedAttachmentFiles:(NSArray *)purgeableRecords];
            
            if ([purgeableRecords count] > 1)
            {
                NSString *baseString = [purgeableRecords componentsJoinedByString:@"','"];
                idSeparetedByComas = [NSString stringWithFormat:@"'%@'", baseString];
            }
            else
            {
                idSeparetedByComas = [NSString stringWithFormat:@"'%@'", [purgeableRecords objectAtIndex:0]];
            }
            [appDelegate.attachmentDataBase deleteEntriesFromAttachmentErrorAndTrailerTable:idSeparetedByComas Name:ATTACHMENT_ERROR];
           // 10339 Defect Fix
            [appDelegate.attachmentDataBase deleteEntriesFromAttachmentErrorAndTrailerTable:idSeparetedByComas Name:ATTACHMENT_TRAILER];
            
            //Repainting - 10289
            [appDelegate.reloadTable ReloadSyncTable];
            
        }
    }
}

#pragma mark - Attachment Sharing
//D-00003728
+ (NSURL *)getUrlForFilename:(NSString *)fileName attchmentId:(NSString *)Id
{
    NSString * documetName = nil;
    NSString * filePath = nil;
    NSURL * url = nil;
    
    NSString * extension = [AttachmentUtility fileExtension:fileName];
    
    documetName = [AttachmentUtility fileName:[fileName stringByDeletingPathExtension] extension:extension];
    filePath = [AttachmentUtility getFullPath:documetName];
    
    if (filePath != nil)
    {
        return url = [NSURL fileURLWithPath:filePath];
    }
    return url;
}

//Fetching the data to create duplicate file for sharing //Defect 11338
+ (NSData *)getEncodedDataForExistingFile:(NSString *)attachmentLocalId attachmentName:(NSString *)attachmentFileName
{
    NSData *fileContents = nil;
    NSString *filePath = [AttachmentUtility fileName:attachmentLocalId
                                           extension:[attachmentFileName pathExtension]];
    
    NSString *fullFilePath = [AttachmentUtility getFullPath:filePath] ;
    NSFileManager *fileManager    = [NSFileManager defaultManager];
    
    if([fileManager fileExistsAtPath:fullFilePath])
    {
        fileContents = [NSData dataWithContentsOfFile:fullFilePath];
    }
    return fileContents;
}

//Saving duplicate file //Defect 11338
+ (BOOL)saveDuplicateAttachmentData:(NSData *)attachmentData inFileName:(NSString *)fileName
{
    BOOL isSuccess = NO;
    NSString *rootPath = [self pathForAttachment];
    
    if (rootPath == nil)
    {
        return isSuccess;
    }
    
    NSString *filePath = [rootPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",fileName]];
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    isSuccess = [attachmentData writeToFile:filePath atomically:YES];
    return isSuccess;
}

//Defect 11338 
+ (BOOL)deleteDuplicateFileCreated:(NSString *)fileName
{
    BOOL isSuccess = NO;
    NSString *rootPath = [self pathForAttachment];
    
    if (rootPath == nil)
    {
        return isSuccess;
    }
    NSString *filePath = [rootPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",fileName]];
    NSError *error = nil;
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath])
    {
       isSuccess = [fileManager removeItemAtPath:filePath error:&error];
    }
    return isSuccess;
}
#pragma mark - END
@end
