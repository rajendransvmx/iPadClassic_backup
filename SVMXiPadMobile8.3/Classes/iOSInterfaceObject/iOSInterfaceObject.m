//
//  iOSInterfaceObject.m
//  iService
//
//  Created by Samman Banerjee on 14/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "iOSInterfaceObject.h"
#import "iServiceAppDelegate.h"
#import "ModalViewController.h"

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
    
    NSString * tmpDate = [gmtDate substringToIndex:[gmtDate length]-1];
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

+ (NSString *) getGMTFromLocalTime:(NSString *)localTime
{
    if ([localTime isEqualToString:@""])
        return localTime;
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString * tmpDate = [localTime substringToIndex:[localTime length]-1];
    tmpDate = [tmpDate stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    tmpDate = [tmpDate stringByReplacingOccurrencesOfString:@"Z" withString:@""];
    tmpDate = [tmpDate stringByDeletingPathExtension];
    
    NSDate * originalDate = [dateFormatter dateFromString:tmpDate];
    
    NSTimeInterval timeZoneOffset = [[NSTimeZone systemTimeZone] secondsFromGMT];
    
    NSTimeInterval gmtTimeInterval = [originalDate timeIntervalSinceReferenceDate] - timeZoneOffset;
    
    NSDate * localDate = [NSDate dateWithTimeIntervalSinceReferenceDate:gmtTimeInterval];
    
    // Convert localDate back into string using dateFormatter
    NSString * newDate = [dateFormatter stringFromDate:localDate];
    newDate = [newDate stringByReplacingOccurrencesOfString:@" " withString:@"T"];
    newDate = [NSString stringWithFormat:@"%@Z", newDate];
    
    [dateFormatter release];
    
    return newDate;
}

//pavaman 1st Jan 2011
+ (NSString *) adjustDateWrapAround:(NSString *)startTime:(NSString *)endTime;
{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
    NSString * tmpDate = [startTime substringToIndex:[startTime length]-1];
    tmpDate = [tmpDate stringByReplacingOccurrencesOfString:@"T" withString:@" "];
	NSDate * startDateTime = [dateFormatter dateFromString:tmpDate];
    
    tmpDate = [endTime substringToIndex:[endTime length]-1];
    tmpDate = [tmpDate stringByReplacingOccurrencesOfString:@"T" withString:@" "];
	NSDate * endDateTime = [dateFormatter dateFromString:tmpDate];
	
	if ([endDateTime compare:startDateTime] == NSOrderedAscending)
	{
		NSTimeInterval oneday = 3600*24;
		endDateTime = [endDateTime addTimeInterval:oneday];		
	}
	
	NSString * newDate = [dateFormatter stringFromDate:endDateTime];
    newDate = [newDate stringByReplacingOccurrencesOfString:@" " withString:@"T"];
    newDate = [NSString stringWithFormat:@"%@Z", newDate];

    [dateFormatter release];

    return newDate;
}

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
        appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
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
        appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
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

- (void) getImagesForIds:(NSArray *)idArray
{
    // [idArray retain];
    NSMutableString * _query = [[NSMutableString stringWithFormat:@"SELECT Username, Id FROM User WHERE Id = '%@'", [idArray objectAtIndex:0]] retain];
    
    for (int i = 1; i < [idArray count]; i++)
    {
        [_query appendFormat:@" OR Id = '%@'", [idArray objectAtIndex:i]];
    }
    
    [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didGetUserNamesForIds:error:context:) context:nil];
    
    [_query release];
}

- (void) didGetUserNamesForIds:(ZKQueryResult *)result error:(NSError *)error context:(id)context;
{
    NSArray * nameArray = [result records];
    
    NSMutableString * _query = [[NSMutableString stringWithFormat:@"SELECT Name, Body FROM Document WHERE Name = '%@'", [[[nameArray objectAtIndex:0] fields] objectForKey:@"Username"]] retain];
    
    for (int i = 1; i < [nameArray count]; i++)
    {
        [_query appendFormat:@" OR Name = '%@'", [[[nameArray objectAtIndex:i] fields] objectForKey:@"Username"]];
    }
    
    [[ZKServerSwitchboard switchboard] query:_query target:caller selector:@selector(didGetImagesForIds:error:context:) context:nameArray];
    
    [_query release];
}

#pragma Product Manual
- (void) queryManualForProductName:(NSString *)productName
{
    NSString * _query = [[NSString stringWithFormat:@"SELECT Id, Name FROM Attachment WHERE ParentId = '%@' AND Name LIKE '%%MANUAL%%'", productName] retain];
    
    [[ZKServerSwitchboard switchboard] query:_query target:caller selector:@selector(didQueryManualForProductName:error:context:) context:nil];
    
    [_query release];
}

- (NSURLConnection *) queryManualBodyForDocument:(NSString *)productName
{
    NSString * _query = [[NSString stringWithFormat:@"SELECT Body FROM Attachment WHERE ParentId = '%@' AND Name LIKE '%%MANUAL%%'", productName] retain];
    
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

#pragma mark - Signature Capture
- (void) setSignImageData:(NSData *)imageData WithId:(NSString *)SFId WithImageName:(NSString *)imageName
{
    // Cut the workOrderId to 15 chars from left
    NSString * fileName = SFId;
    if ([fileName length] > 15){
        fileName = [SFId substringToIndex:15];
    }
    
    fileName = [NSString stringWithFormat:@"%@_sign.png", fileName];
    NSLog(@"%@", fileName);
    
    didRemovePreviousSignature = NO;
    [self removePreviousSignature:fileName];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1, FALSE))
    {
        NSLog(@"setSignedImageData in while loop");
        if (!appDelegate.isInternetConnectionAvailable)
        {
            break;
        }
        if(didRemovePreviousSignature == YES)
        {
            break;
        }
    }
    
    // Upload signature to attachments
    ZKSObject * obj = [[ZKSObject alloc] initWithType:@"Attachment"];
    [obj setFieldValue:fileName field:@"Name"];
    NSString * fileString = [Base64 encode:imageData];
    [obj setFieldValue:fileString field:@"Body"];
    [obj setFieldValue:SFId field:@"ParentId"];
    [obj setFieldValue:@"False" field:@"isPrivate"];
    NSArray * array = [[NSArray alloc] initWithObjects:obj, nil];
    [[ZKServerSwitchboard switchboard] create:array target:self selector:@selector(didAttachSignature:error:context:) context:nil];
    
    attachNewSignature = NO;
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1, FALSE))
    {
        NSLog(@"setSignedImageData in while loop");
        if (!appDelegate.isInternetConnectionAvailable)
        {
            break;
        }
        if(attachNewSignature == YES)
        {
            break;
        }
    }
    
    if (attachNewSignature)
    {
        NSString * query = [NSString stringWithFormat:@"DELETE FROM SFSignatureData WHERE sig_id = '%@'", SFId];
        
        char * err;
        if (synchronized_sqlite3_exec(appDelegate.db, [query UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
            NSLog(@"Failed To delete");
        }
    }
    
    // Analyser
    [array release];
    [obj release];
}

- (void) didAttachSignature:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    attachNewSignature = YES;    
}

- (void) removePreviousSignature:(NSString *)signatureName
{
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

@end
