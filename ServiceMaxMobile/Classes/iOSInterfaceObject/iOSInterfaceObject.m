//
//  iOSInterfaceObject.m
//  iService
//
//  Created by Samman Banerjee on 14/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "iOSInterfaceObject.h"
#import "AppDelegate.h"
#import "ModalViewController.h"
#import "Utility.h"
#import "SMXMonitor.h"
void SMXLog(int level,const char *methodContext,int lineNumber,NSString *message);

@implementation iOSInterfaceObject

@synthesize delegate;
@synthesize caller;
@synthesize topLevelId, workOrderId, accountId, caseId;

@synthesize eventDetails;

+ (NSString *) getLocalTimeFromGMT:(NSString *)gmtDate
{
    if ([gmtDate isEqualToString:@""])
        return gmtDate;
    
    if ([gmtDate length] > 19)
    {
        gmtDate = [gmtDate substringToIndex:19];
        gmtDate = [NSString stringWithFormat:@"%@Z", gmtDate];
    }
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString * tmpDate = [gmtDate substringToIndex:[gmtDate length]-0];
    tmpDate = [tmpDate stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    tmpDate = [tmpDate stringByReplacingOccurrencesOfString:@"Z" withString:@""];
    tmpDate = [tmpDate stringByDeletingPathExtension];
    
    NSDate * originalDate = [dateFormatter dateFromString:tmpDate];
    
    NSTimeInterval timeZoneOffset = [[NSTimeZone systemTimeZone] secondsFromGMT];
    
    NSTimeInterval gmtTimeInterval = [originalDate timeIntervalSinceReferenceDate] + timeZoneOffset;
    
    NSDate * localDate = [NSDate dateWithTimeIntervalSinceReferenceDate:gmtTimeInterval];
    
    // Convert localDate back into string using dateFormatter
    NSString * newDate = [dateFormatter stringFromDate:localDate];
    newDate = [newDate stringByReplacingOccurrencesOfString:@" " withString:@"T"];
    newDate = [NSString stringWithFormat:@"%@Z", newDate];
    
    [dateFormatter release];
    
    return newDate;
}

//Krishna : fix for defect 12534
+ (NSString *)getGMTFromLocalTime:(NSString *)localTime
{
    if ([localTime isEqualToString:@""])
    {
        return localTime;
    }
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    //10312
    [dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
    //To Test need to remove
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [dateFormatter setCalendar:cal];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString * tmpDate = [localTime substringToIndex:[localTime length]- 0];
    tmpDate = [tmpDate stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    tmpDate = [tmpDate stringByReplacingOccurrencesOfString:@"Z" withString:@""];
    tmpDate = [tmpDate stringByDeletingPathExtension];
    
    // Local DateTime object from local date-time string
    NSDate * originalDate = [dateFormatter dateFromString:tmpDate];
    
    // From Gregorian calendar collecting date and time components baed on GMT
    [cal setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSDateComponents *date_comp = [cal components: NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:originalDate];
    
    // Formating date into database compatible format
    NSString *someDateString = [iOSInterfaceObject getLocalizedString:date_comp];
    [cal release];
    
    someDateString = [someDateString stringByReplacingOccurrencesOfString:@" " withString:@"T"];
    someDateString = [NSString stringWithFormat:@"%@Z", someDateString];
    
    [dateFormatter release];
    
    return someDateString;
}



//+ (NSString *) getGMTFromLocalTime:(NSString *)localTime
//{
//    if ([localTime isEqualToString:@""])
//        return localTime;
//    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
//
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//
//    NSString * tmpDate = [localTime substringToIndex:[localTime length]-0];
//    tmpDate = [tmpDate stringByReplacingOccurrencesOfString:@"T" withString:@" "];
//    tmpDate = [tmpDate stringByReplacingOccurrencesOfString:@"Z" withString:@""];
//    tmpDate = [tmpDate stringByDeletingPathExtension];
//
//    NSDate * originalDate = [dateFormatter dateFromString:tmpDate];
//
//    NSTimeInterval timeZoneOffset = [[NSTimeZone systemTimeZone] secondsFromGMT];
//
//    NSTimeInterval gmtTimeInterval = [originalDate timeIntervalSinceReferenceDate] - timeZoneOffset;
//
//    NSDate * localDate = [NSDate dateWithTimeIntervalSinceReferenceDate:gmtTimeInterval];
//
//    // Convert localDate back into string using dateFormatter
//    NSString * newDate = [dateFormatter stringFromDate:localDate];
//    newDate = [newDate stringByReplacingOccurrencesOfString:@" " withString:@"T"];
//    newDate = [NSString stringWithFormat:@"%@Z", newDate];
//
//    [dateFormatter release];
//
//    return newDate;
//}

//pavaman 1st Jan 2011
//  Unused Methods
//+ (NSString *) adjustDateWrapAround:(NSString *)startTime:(NSString *)endTime;
//{
//    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//	
//    NSString * tmpDate = [startTime substringToIndex:[startTime length]-1];
//    tmpDate = [tmpDate stringByReplacingOccurrencesOfString:@"T" withString:@" "];
//	NSDate * startDateTime = [dateFormatter dateFromString:tmpDate];
//    
//    tmpDate = [endTime substringToIndex:[endTime length]-1];
//    tmpDate = [tmpDate stringByReplacingOccurrencesOfString:@"T" withString:@" "];
//	NSDate * endDateTime = [dateFormatter dateFromString:tmpDate];
//	
//	if ([endDateTime compare:startDateTime] == NSOrderedAscending)
//	{
//		NSTimeInterval oneday = 3600*24;
//		endDateTime = [endDateTime addTimeInterval:oneday];		
//	}
//	
//	NSString * newDate = [dateFormatter stringFromDate:endDateTime];
//    newDate = [newDate stringByReplacingOccurrencesOfString:@" " withString:@"T"];
//    newDate = [NSString stringWithFormat:@"%@Z", newDate];
//
//    [dateFormatter release];
//
//    return newDate;
//}

- (void) queryTasksForDate:(NSString *)date
{
    NSString * _query = [[NSString stringWithFormat:@"SELECT Priority, ActivityDate, Subject, OwnerId, IsRecurrence, Id, Description, Status  FROM Task WHERE ActivityDate = %@ AND Status != 'Completed' AND IsRecurrence = false AND OwnerId = '%@'", date, appDelegate.loggedInUserId] retain];
    
    [[ZKServerSwitchboard switchboard] query:_query target:caller selector:@selector(didQueryTasksForDate:error:context:) context:nil];
    
    [_query release];
}

- (id) init
{
    self = [super init];
    if (self)
    {
        appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        zip = [[ZipArchive alloc] init];
    }
    return self;
}

- (id) initWithCaller:(id)_caller
{
    self = [super init];
    if (self)
    {
        caller = _caller;
        delegate = _caller;
        appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        zip = [[ZipArchive alloc] init];
    }
    return self;
}

- (void) create:(NSArray *)objects;
{
    [[ZKServerSwitchboard switchboard] create:objects target:caller selector:@selector(didCreateObjects:error:context:) context:nil];
}

- (void) update:(NSArray *)objects;
{
    [[ZKServerSwitchboard switchboard] update:objects target:caller selector:@selector(didUpdateObjects:error:context:) context:nil];
}

- (void) delete:(NSArray *)objects;
{
    [[ZKServerSwitchboard switchboard] delete:objects target:caller selector:@selector(didDeleteObjects:error:context:) context:nil];
}

#pragma mark - Chatter Methods
- (void) getProductPictureForId:(NSString *)_productId;
{
    NSString * _query = [[NSString stringWithFormat:@"SELECT Body FROM Attachment Where ParentId = '%@' AND Name LIKE '%%PICTURE%%' LIMIT 1", _productId] retain];
    
    [[ZKServerSwitchboard switchboard] query:_query target:caller selector:@selector(didGetProductPictureForId:error:context:) context:nil];
    
    [_query release];
}

- (void) getUserNameFromId:(NSArray *)userIdArray
{
    //sahana 17th Aug
    NSMutableString * _query = [[NSMutableString stringWithFormat:@"SELECT  Username, Id, Name, Email, FullPhotoUrl, SmallPhotoUrl FROM User WHERE Id = '%@'", [userIdArray objectAtIndex:0]] retain];
    
    for (int i = 1; i < [userIdArray count]; i++)
    {
        [_query appendFormat:@" OR Id = '%@'", [userIdArray objectAtIndex:i]];
    }
    
    [[ZKServerSwitchboard switchboard] query:_query target:caller selector:@selector(didGetUserNameFromId:error:context:) context:nil];
    
    [_query release];
}

- (void) queryChatterForProductId:(NSString *)_productId;
{
    NSString * chatterThreads = ([appDelegate.settingsDict objectForKey:@"Chatter Threads"]) != nil?[appDelegate.settingsDict objectForKey:@"Chatter Threads"]:@"";
    
    if ([chatterThreads isEqualToString:@""])
        chatterThreads = @"50";
    
    NSString * _query = [[NSString stringWithFormat:@"SELECT Type, CreatedById, ParentId, Id, FeedPost.Body, FeedPostId, CreatedDate, (Select CreatedById, CreatedDate, FeedItemId, CommentBody From FeedComments ORDER BY CreatedDate) FROM Product2Feed WHERE Type != 'TrackedChange' AND  ParentId = '%@' ORDER BY CreatedDate DESC LIMIT %@", _productId, chatterThreads] retain];
    
    [[ZKServerSwitchboard switchboard] query:_query target:caller selector:@selector(didQueryChatterForProductId:error:context:) context:nil];
    
    [_query release];
}

- (void) queryTroubleshootingForProductName:(NSString *)productName
{
    NSString * _query = [[NSString stringWithFormat:@"SELECT Id, Name, Keywords from Document WHERE Keywords LIKE '%%%@%%'", productName] retain];
    
    [[ZKServerSwitchboard switchboard] query:_query target:caller selector:@selector(didQueryTroubleshootingForProductName:error:context:) context:nil];
    
    [_query release];
}

- (NSURLConnection *) queryTroubleshootingBodyForDocument:(NSDictionary *)dict
{
    NSString * _query = [[NSString stringWithFormat:@"SELECT Body from Document WHERE Id='%@'", [dict objectForKey:FILEID]] retain];
    
    NSURLConnection * connection = [[ZKServerSwitchboard switchboard] query:_query target:caller selector:@selector(didQueryTroubleshootingBodyForDocument:error:context:) context:dict];
    
    [_query release];
    
    return connection;
}

- (NSString *) dayByComparingTodayWithDate:(NSString *)date
{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    if ([date length] > 10)
        date = [date substringToIndex:10];
    
    NSDate * today = [NSDate date];
    date = [date substringToIndex:10];
    
    NSDate * prevDate = [dateFormatter dateFromString:date];
    
    NSTimeInterval interval = [today timeIntervalSince1970] - [prevDate timeIntervalSince1970];
    
    NSString * day;
    if ((interval > 0) && (interval < 86400))
        day = [NSString stringWithString:[appDelegate.wsInterface.tagsDictionary objectForKey:CHATTER_TODAY]];
    else
        if ((interval > 86400) && (interval < 172800))
            day = [NSString stringWithString:[appDelegate.wsInterface.tagsDictionary objectForKey:CHATTER_YESTERDAY]];
        else
            if ((interval > 172800) && (interval < 259200))
                day = [NSString stringWithString:[appDelegate.wsInterface.tagsDictionary objectForKey:CHATTER_DAY_BEFORE_YESTERDAY]];
            else
            {   
                NSDate * _date = [dateFormatter dateFromString:date];
                [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
                day = [dateFormatter stringFromDate:_date];
            }
    [dateFormatter release];
    return day;
}
//  Unused Methods
//- (void) getImagesForIds:(NSArray *)idArray
//{
//    // [idArray retain];
//    NSMutableString * _query = [[NSMutableString stringWithFormat:@"SELECT Username, Id FROM User WHERE Id = '%@'", [idArray objectAtIndex:0]] retain];
//    
//    for (int i = 1; i < [idArray count]; i++)
//    {
//        [_query appendFormat:@" OR Id = '%@'", [idArray objectAtIndex:i]];
//    }
//    
//    [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didGetUserNamesForIds:error:context:) context:nil];
//    
//    [_query release];
//}
//  Unused Methods
//- (void) didGetUserNamesForIds:(ZKQueryResult *)result error:(NSError *)error context:(id)context;
//{
//    NSArray * nameArray = [result records];
//    
//    NSMutableString * _query = [[NSMutableString stringWithFormat:@"SELECT Name, Body FROM Document WHERE Name = '%@'", [[[nameArray objectAtIndex:0] fields] objectForKey:@"Username"]] retain];
//    
//    for (int i = 1; i < [nameArray count]; i++)
//    {
//        [_query appendFormat:@" OR Name = '%@'", [[[nameArray objectAtIndex:i] fields] objectForKey:@"Username"]];
//    }
//    
//    [[ZKServerSwitchboard switchboard] query:_query target:caller selector:@selector(didGetImagesForIds:error:context:) context:nameArray];
//    
//    [_query release];
//}

#pragma Product Manual
- (void) queryManualForProductName:(NSString *)productName
{
    NSString * _query = [[NSString stringWithFormat:@"SELECT Id, Name FROM Attachment WHERE ParentId = '%@' AND Name LIKE '%%MANUAL%%'", productName] retain];
    
    [[ZKServerSwitchboard switchboard] query:_query target:caller selector:@selector(didQueryManualForProductName:error:context:) context:nil];
    
    [_query release];
}

- (NSURLConnection *) queryManualBodyForDocument:(NSString *)productName ManId:(NSString *)ManId
{
    NSString * _query = [[NSString stringWithFormat:@"SELECT Body FROM Attachment WHERE ParentId = '%@' AND Name LIKE '%%MANUAL%%' and id='%@'", productName,ManId] retain];
    
    NSURLConnection * connection = [[ZKServerSwitchboard switchboard] query:_query target:caller selector:@selector(didQueryBodyProductName:error:context:) context:nil];
    
    [_query release];
    
    return connection;
}

- (void) queryServiceReportForWorkOrderId:(NSString *)woId serviceReport:(NSString *)serviceReport
{
    NSString * _query = [[NSString stringWithFormat:@"SELECT Name, Body FROM Attachment WHERE Name = '%@' ORDER BY LastModifiedDate DESC", serviceReport] retain];
    
    [[ZKServerSwitchboard switchboard] query:_query target:caller selector:@selector(didQueryAttachmentForServiceReport:error:context:) context:nil];
    
    [_query release];
}
//krishnasign
#pragma mark - Signature Capture
- (BOOL) isSignatureForOPDOC:(NSString *)sfId andUniqueId:(NSString *)uniqueId {
    
    
    //since sig-id will be updated by sfid
    NSString *sqlQuery = [NSString  stringWithFormat:@"select COUNT(*) from SFSignatureData where sig_Id = '%@' and signature_type_id = '%@'  and sign_type = 'OPDOC'",sfId,uniqueId];
    
    sqlite3_stmt *selectStmt = nil;
    int count = 0;
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [sqlQuery UTF8String], -1, &selectStmt, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(selectStmt) == SQLITE_ROW)
        {
            count = synchronized_sqlite3_column_int(selectStmt, 0);
        }
    }
    
    synchronized_sqlite3_finalize(selectStmt);
    if (count > 0)
        return TRUE;
    else
        return FALSE;
}
//krishnasign
- (NSString *)nameForFile:(NSString *)sfid andSignatureId:(NSString *)sigUniqueId {
    
    NSString * signatureString = @"";
    NSString * sigId = @"";
    NSString * selectQuery = [NSString stringWithFormat:@"Select WorkOrderNumber from SFSignatureData Where sig_Id = '%@' and sign_type = 'OPDOC' and signature_type_id = '%@'", sfid,sigUniqueId];
    sqlite3_stmt * stmt;

    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char *field = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_1);
            if ( field != nil )
                signatureString = [NSString stringWithUTF8String:field];
            
            char *field1 = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_2);
            if ( field1 != nil )
                sigId = [NSString stringWithUTF8String:field1];
        }
    }
    synchronized_sqlite3_finalize(stmt);
    NSString *file = [NSString stringWithFormat:@"%@_%@.png",signatureString,sigUniqueId];
    return file;
}
- (void) setSignImageData:(NSData *)imageData WithId:(NSString *)SFId WithRecordId:(NSString *)recordId andSignId:(NSString *)sign
{
    // Cut the workOrderId to 15 chars from left
    NSString * fileName = SFId;
    if ([fileName length] > 15){
        fileName = [SFId substringToIndex:15];
    }
    
    
    fileName = [NSString stringWithFormat:@"%@_sign.png", fileName];
    
    //krishnasign
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    NSString *saveDirectory = [appDelegate getAppCustomSubDirectory]; // [paths objectAtIndex:0];

    BOOL isOpdoc = [self isSignatureForOPDOC:SFId andUniqueId:sign];
    NSString *opdocTypeId = @"";
    if(isOpdoc) {
        
        NSArray *itemsInDocDir = [fileManager contentsOfDirectoryAtPath:saveDirectory error:NULL];
        for (NSString *itm in itemsInDocDir)
        {
            if([Utility containsString:sign inString:itm])
            {
                if([appDelegate.dataBase isSignatureFinalized:itm])
                    fileName = itm;
            }
        }
        
        if(![fileName isEqualToString:@""] || fileName != nil)
        {
            //second half consists of opdoc_signature_id
            opdocTypeId = [fileName stringByDeletingPathExtension];
        }
    }
    SMLog(kLogLevelVerbose,@"%@", fileName);
    
    didRemovePreviousSignature = NO;
    
    if(!isOpdoc)
    {
        SMXMonitor *monitor = [[[SMXMonitor alloc] init] autorelease];
        [monitor monitorSMMessageWithName:@"[iOSInterfaceObject setSignedImageData]"
                             withUserName:appDelegate.currentUserName
                                 logLevel:kPerformanceLevelWarning
                               logContext:@"Start"
                             timeInterval:kWSExecutionDuration];
        [self removePreviousSignature:fileName];
        
        while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
        {
            SMLog(kLogLevelVerbose,@"setSignedImageData in while loop");
            if (![appDelegate isInternetConnectionAvailable])
            {
                break;
            }
            if(didRemovePreviousSignature == YES)
            {
                break;
            }
            if (appDelegate.connection_error)
            {
                break;
            }
        }
        [monitor monitorSMMessageWithName:@"[iOSInterfaceObject setSignedImageData]"
                             withUserName:appDelegate.currentUserName
                                 logLevel:kPerformanceLevelWarning
                               logContext:@"Stop"
                             timeInterval:kWSExecutionDuration];

    }
    
    NSData *newData = nil;
    if(isOpdoc)
    {
        NSString *uploadingFilePath = [saveDirectory stringByAppendingPathComponent:fileName];
        if([fileManager fileExistsAtPath:uploadingFilePath])
            newData = [NSData dataWithContentsOfFile:uploadingFilePath];
        
        if((newData != nil) && [newData length])
            imageData = newData;
    }
    
    
    // Upload signature to attachments
    ZKSObject * obj = [[ZKSObject alloc] initWithType:@"Attachment"];
    [obj setFieldValue:fileName field:@"Name"];
    NSString * fileString = (imageData != nil) ? [Base64 encode:imageData] : @"";
//	[obj setFieldValue:appDelegate.current_userId field:@"OwnerId"];
    [obj setFieldValue:fileString field:@"Body"];
    [obj setFieldValue:SFId field:@"ParentId"];
    [obj setFieldValue:@"False" field:@"isPrivate"];
    NSArray * array = [[NSArray alloc] initWithObjects:obj, nil];
    
    NSNumber *isSignatureForOpDoc = [NSNumber numberWithBool:isOpdoc];
    
    NSMutableDictionary *contextDict = [NSMutableDictionary dictionary];
    [contextDict setObject:sign forKey:@"signid"];
    [contextDict setObject:fileName forKey:@"fileName"]; /* OPDoc New impln for Sum'13 : Added */
    [contextDict setObject:isSignatureForOpDoc forKey:@"isopdoc"];
    
    if(isOpdoc)// Dam - signature sum'13
    {
        SMLog(kLogLevelVerbose,@"check for finalized : %@",fileName);
        if(![appDelegate.dataBase isSignatureFinalized:fileName])
        {
            return;
        }
    }
    
    [[ZKServerSwitchboard switchboard] create:array target:self selector:@selector(didAttachSignature:error:context:) context:contextDict];
    
    attachNewSignature = NO;
    SMXMonitor *monitor = [[[SMXMonitor alloc] init] autorelease];
    [monitor monitorSMMessageWithName:@"[iOSInterfaceObject setSignedImageData]"
                         withUserName:appDelegate.currentUserName
                             logLevel:kPerformanceLevelWarning
                           logContext:@"Start"
                         timeInterval:kWSExecutionDuration];
   while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
        SMLog(kLogLevelVerbose,@"setSignedImageData in while loop");
        if (![appDelegate isInternetConnectionAvailable])
        {
            break;
        }
        if(attachNewSignature == YES)
        {
            break;
        }
        if (appDelegate.connection_error)
        {
            break;
        }
    }
    [monitor monitorSMMessageWithName:@"[iOSInterfaceObject setSignedImageData]"
                         withUserName:appDelegate.currentUserName
                             logLevel:kPerformanceLevelWarning
                           logContext:@"Stop"
                         timeInterval:kWSExecutionDuration];

    if (attachNewSignature)
    {
        NSString * query = @"";
        //008559
        if(!isOpdoc) {
            query = [NSString stringWithFormat:@"DELETE FROM SFSignatureData WHERE sig_id = '%@' and sign_type != 'OPDOC'", SFId];
            char * err;
            if (synchronized_sqlite3_exec(appDelegate.db, [query UTF8String], NULL, NULL, &err) != SQLITE_OK)
            {
                SMLog(kLogLevelError,@"Failed To delete");
                SMLog(kLogLevelError,@"%@", query);
                SMLog(kLogLevelError,@"METHOD:deleteRecordsFromEventLocalIds");
                SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
                [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:query type:DELETEQUERY];
                
            }
        }
    }
    
    // Analyser
    [array release];
    [obj release];
}


- (void) didAttachSignature:(NSArray *)result error:(NSError *)error context:(id)context
{
    attachNewSignature = YES;
    
    NSString *attachmentId = @"";
    if([result count] > 0) {
    id resultRecord = [result objectAtIndex:0];
        attachmentId = [resultRecord id];
    }
    
    BOOL isOPDocSignature = [[context objectForKey:@"isopdoc"] boolValue];
    //008559
    if(isOPDocSignature && ([attachmentId length] > 0)) {
        
        [appDelegate.dataBase removeSignatureNameFromFinalizedPlist:[context objectForKey:@"fileName"]];
        
        //008559
        [appDelegate.calDataBase deleteOPDocSignatureForName:[[context objectForKey:@"fileName"] stringByDeletingPathExtension]];
        [appDelegate.dataBase insertIntoRequiredSignature:attachmentId andSignatureId:[context objectForKey:@"fileName"]]; /* OPDoc New impln for Sum'13 */
    }
}

- (void) removePreviousSignature:(NSString *)signatureName
{
//    NSString * _query = [NSString stringWithFormat:@"SELECT Id FROM Attachment WHERE Name = '%@' and OwnerId = '%@'", signatureName,appDelegate.current_userId];
    NSString * _query = [NSString stringWithFormat:@"SELECT Id FROM Attachment WHERE Name = '%@'", signatureName];

    [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didGetSignatureList:error:context:) context:_query];
}

- (void) didGetSignatureList:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0; i < [[result records] count]; i++)
    {
        [array addObject:[[[[result records] objectAtIndex:i] fields] objectForKey:@"Id"]];
    }
    if ([array count] > 0)
    {
        [[ZKServerSwitchboard switchboard] delete:array target:self selector:@selector(didRemoveSignature:error:context:) context:nil];
    }
    else
        [self didRemoveSignature:nil error:nil context:nil];
    
    // Analyser
    [array release];
}

- (void) didRemoveSignature:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    didRemovePreviousSignature = YES;
}

- (void) dealloc
{
    [caller release];
    [workOrderId release];
    
    [workOrderIdArrayString release];
    
    if (workOrderIdArray != nil)
        [workOrderIdArray release];
    
    [topLevelId release];
    [accountId release];
    [caseId release];
    
    [currentDate release];
    [previousDate release];
    
    if (eventArray != nil)
        [eventArray release];
    if (taskArray != nil)
        [taskArray release];
    
    [super dealloc];
}

#pragma mark- Date creation using calendar
/*8945*/
/* Get the local date and time from GMT using calendar component .*/

+ (NSString *) localTimeFromGMT:(NSString *)gmtDate
{
    if ([gmtDate isEqualToString:@""])
    return gmtDate;
    
    if ([gmtDate length] > 19)
    {
        gmtDate = [gmtDate substringToIndex:19];
        gmtDate = [NSString stringWithFormat:@"%@Z", gmtDate];
    }
    //for Gregorian Calendar
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setCalendar:cal];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString * tmpDate = [gmtDate substringToIndex:[gmtDate length]-0];
    
    tmpDate = [tmpDate stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    tmpDate = [tmpDate stringByReplacingOccurrencesOfString:@"Z" withString:@""];
    tmpDate = [tmpDate stringByDeletingPathExtension];
    
    NSDate * originalDate = [dateFormatter dateFromString:tmpDate];
    [cal setTimeZone:[NSTimeZone systemTimeZone]];
    
    NSDateComponents *date_comp = [cal components: NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:originalDate];
    
    NSString *someDateString = [iOSInterfaceObject getLocalizedString:date_comp];
    [cal release];
    
    someDateString = [someDateString stringByReplacingOccurrencesOfString:@" " withString:@"T"];
    someDateString = [NSString stringWithFormat:@"%@Z", someDateString];
    
    [dateFormatter release];
    
    return someDateString;
}

+ (NSString *)getLocalizedString:(NSDateComponents *)date_comp {
    NSString *monthStr = nil,*dayStr = nil,*hourStr = nil,*minutesStr = nil,*secondsStr = nil;
    
    NSInteger year = [date_comp year];
    
    NSInteger month = [date_comp month];
    monthStr = [iOSInterfaceObject getTwoDigitString:month];
    
    NSInteger day = [date_comp day];
    dayStr = [iOSInterfaceObject getTwoDigitString:day];
    
    NSInteger hour = [date_comp  hour];
    hourStr = [iOSInterfaceObject getTwoDigitString:hour];
    
    NSInteger minutes = [date_comp  minute];
    minutesStr = [iOSInterfaceObject getTwoDigitString:minutes];
    
    NSInteger seconds = [date_comp second];
    secondsStr = [iOSInterfaceObject getTwoDigitString:seconds];
    
    NSString *someDateString = [NSString stringWithFormat:@"%d-%@-%@ %@:%@:%@",year,monthStr,dayStr,hourStr,minutesStr,secondsStr];
    return someDateString;
}
+ (NSString *)getTwoDigitString:(NSInteger )dateInt {
    NSString *someString = nil;
    if (dateInt > 9) {
        someString = [NSString stringWithFormat:@"%d",dateInt];
    }
    else {
        someString = [NSString stringWithFormat:@"0%d",dateInt];
    }
    return someString;
}


@end
