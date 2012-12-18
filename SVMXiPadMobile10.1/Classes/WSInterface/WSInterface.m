 //
//  WSInterface.m
//  project
//
//  Created by Developer on 5/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WSInterface.h"
#import "iServiceAppDelegate.h"
#import "LoginController.h"
extern void SVMXLog(NSString *format, ...);

//sahana Note 
//write an incremental Sync Method to clean up all data related to incremental Sync 
//ex : temp_trailer , sync_heap table,Incremental_sync, temp_incremental_sync  otherwise it would affect rest of the functionality.

@implementation WSInterface
@synthesize didCompleteAfterSaveEventCalls;
@synthesize AfterSaveEventsCalls;
@synthesize webservice_call;
//sahana dc sync
@synthesize refreshProgressBarUIDelegate;
@synthesize dcobjects_incrementalSync;
@synthesize insert_dc_last_sync_time,update_dc_last_sync_time,delete_dc_last_sync_time;
@synthesize get_dc_records_request_id;
//RADHA
@synthesize MyPopoverDelegate;
@synthesize FisrtTime_response;
@synthesize objectDefinitions; 
@synthesize object; 
@synthesize picklistObject;
@synthesize  picklistField; 
@synthesize picklistValues;
@synthesize pageUiHistory; 


@synthesize refreshSyncStatusUIButton;
@synthesize refreshModalStatusButton;
@synthesize refreshSyncButton;
@synthesize updateSyncStatus;
@synthesize manualDataSyncUIDelegate;
@synthesize request_time;
@synthesize insert_last_sync_time;
@synthesize delete_last_sync_time;
@synthesize update_last_sync_time;
@synthesize delegate;
@synthesize processArray;

@synthesize tagsDictionary;
@synthesize responseError;
//sahana 16th Sept
@synthesize didGetProcessId;
@synthesize startDate, endDate;
@synthesize currentDateRange;
@synthesize eventArray;
@synthesize viewDictionary;
@synthesize createProcessArray;
@synthesize viewLayoutsArray;
@synthesize productHistory;
@synthesize detail_addRecordItems;
@synthesize add_WS;
@synthesize SFM_SAVE;
@synthesize detailDelegate;
@synthesize errorLoadingSFM;
@synthesize sfm_response;
@synthesize section_for_createObjects;
@synthesize objectNames_array;
@synthesize tasks;
@synthesize obj_array;
@synthesize didGetObjectName;
@synthesize rescheduleEvent;
@synthesize didRescheduleEvent;
@synthesize didGetWorkOder;
@synthesize getPrice;
@synthesize didGetAccountHistory;
@synthesize didGetProductHistory;

@synthesize didGetRecordTypeId;

@synthesize isLoggedIn;
@synthesize didWriteSignature;
@synthesize didWritePDF;

//Radha
@synthesize didGetAllMetaData;
@synthesize didGetObjectDef;
@synthesize didGetPageData;
@synthesize didGetPicklistValues;
@synthesize didGetWizards;
@synthesize didGetPageDataDb;


@synthesize didOpComplete;
@synthesize didOpSFMSearchComplete;
@synthesize didGetPicklistValueDb;
@synthesize processDictionary;
@synthesize childObject;
@synthesize accountHistory;
#define VALUE 100

- (id) init
{
    self = [super init];
    
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    didGetAccountHistory = NO;
    didGetProductHistory = NO;
    didRescheduleEvent = NO;
    didOpComplete = FALSE;
    isLoggedIn = NO;
    
    
    if (self)
    {
    }
    picklistObject = [[NSMutableArray alloc] initWithCapacity:0];
    picklistField = [[NSMutableArray alloc] initWithCapacity:0];
    picklistValues = [[NSMutableArray alloc] initWithCapacity:0];
    pageUiHistory = [[NSMutableArray alloc] initWithCapacity:0];
    processDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    return self;
}
#define REQUEST  @"request"
#define RESPONSE @"response"

-(NSString *)get_SYNCHISTORYTime_ForKey:(NSString *)forkey
{
    NSString * rootpath_SYNHIST = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * plistPath_SYNHIST = [rootpath_SYNHIST stringByAppendingPathComponent:SYNC_HISTORY];
    
    NSString * value = @"";
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath_SYNHIST];
    NSArray * allkeys= [dict allKeys];
    for(NSString * str in allkeys)
    {
        if([str isEqualToString:forkey])
        {
            value =  [[dict objectForKey:forkey]retain] ;
        }
    }
    [dict release];  //AvoidMemoryLeak-Sahana
    return value;
}

#define START_TIME   @"start_time"
#define END_TIME     @"end_time"

-(NSString *)getSyncTimeStampWithTheIntervalof15days:(NSString *)time
{
    if ([appDelegate.settingsDict count] == 0)
        appDelegate.settingsDict = [appDelegate.dataBase getSettingsDictionary];
    
    int no_of_days ;
    
    NSString * timeInterval = @"";
    
    if([time isEqualToString:START_TIME])
        timeInterval = ([appDelegate.settingsDict objectForKey:@"Synchronization To Remove Events"]) != nil?[appDelegate.settingsDict objectForKey:@"Synchronization To Remove Events"]:@"";
    else
        timeInterval = ([appDelegate.settingsDict objectForKey:@"Synchronization To Get Events"]) != nil?[appDelegate.settingsDict objectForKey:@"Synchronization To Get Events"]:@"";
        
    if([timeInterval isEqualToString:@""])
    {
        no_of_days = 15;    
    }
    else
    {
        no_of_days = [timeInterval intValue]; 
    }
    
    
    NSTimeInterval secondsPerDay = no_of_days * 24 * 60 * 60;
    
    NSDate * today = [NSDate date];
    NSDate * tomorrow, *yesterday;

    
    NSDateFormatter * format = [[NSDateFormatter alloc] init];
    [format setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"IST"]];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString * date_ = [format stringFromDate:today];
     date_ = [date_ stringByReplacingCharactersInRange:NSMakeRange(11, 8) withString:@"00:00:00"];
    NSDate * localDate = [format dateFromString:date_];
   
    
    [format release];
    
    if([time isEqualToString:START_TIME])
    {
        tomorrow = [localDate dateByAddingTimeInterval:-secondsPerDay];
        NSString * current_gmt_time = [self getGmtDateAndTime:tomorrow];
        return current_gmt_time;
    }
    else
    {
        yesterday = [localDate dateByAddingTimeInterval: secondsPerDay];
        NSString * current_gmt_time = [self getGmtDateAndTime:yesterday];
        return current_gmt_time;
    }
    
}


- (NSString *) getGmtDateAndTime:(NSDate *)localDate
{
    NSDateFormatter * datetimeFormatter = [[[NSDateFormatter alloc]init]autorelease];
    [datetimeFormatter  setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone * gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [datetimeFormatter setTimeZone:gmt];
    
    NSString  * gmtDate = [datetimeFormatter stringFromDate:localDate];    
    return gmtDate;
    
}

//sahana 26/feb
-(void)setSyncReqId:(NSString *)req_id
{
    NSString * rootpath_SYNHIST = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * plistPath_SYNHIST = [rootpath_SYNHIST stringByAppendingPathComponent:SYNC_HISTORY];
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath_SYNHIST];
    NSArray * allkeys= [dict allKeys];
    
    for(NSString *  str in allkeys)
    {   
        if ([str isEqualToString:REQUEST_ID])
        {
            [dict setObject:req_id forKey:REQUEST_ID];
        }
    }
    [dict writeToFile:plistPath_SYNHIST atomically:YES];
}

-(BOOL)getSyncStatusForRequestId
{
    NSString * rootpath_SYNHIST = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * plistPath_SYNHIST = [rootpath_SYNHIST stringByAppendingPathComponent:SYNC_HISTORY];
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath_SYNHIST];
    NSArray * allkeys= [dict allKeys];
    
    
    for(NSString *  str in allkeys)
    {   
        if ([str isEqualToString:INSERT_SUCCESS])
        {
            NSString * value = [dict objectForKey:INSERT_SUCCESS];
            if([value isEqualToString:@"true"])
            {
                return YES;
            }
            else
            {
                return NO;
            }
        }
    }
    
    return NO;
    
}

-(void)setsyncHistoryForSyncType:(NSString *)sync_type requestOrResponse:(NSString *)operation_type  request_id:(NSString *)request_id 
last_sync_time:(NSString *)last_sync_time
{
    NSString * rootpath_SYNHIST = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * plistPath_SYNHIST = [rootpath_SYNHIST stringByAppendingPathComponent:SYNC_HISTORY];
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath_SYNHIST];
    NSArray * allkeys= [dict allKeys];
    
           
    NSString * current_gmt_time = [self requestSnapShot] ;//[dateFormatter stringFromDate:current_dateTime];

    
    if([sync_type isEqualToString:INSERT] && [operation_type isEqualToString:REQUEST])
    {
        for(NSString *  str in allkeys)
        {
            SMLog(@"%@" ,current_gmt_time);
            if([str isEqualToString:LAST_INSERT_REQUEST_TIME])
            {
                [dict setObject:current_gmt_time forKey:LAST_INSERT_REQUEST_TIME];
            }
            else if ([str isEqualToString:REQUEST_ID])
            {
                [dict setObject:request_id forKey:REQUEST_ID];
            }
            else if ([str isEqualToString:INSERT_SUCCESS])
            {
                [dict setObject:@"false" forKey:INSERT_SUCCESS];
            }
        }
    }
    else if([sync_type isEqualToString:INSERT] && [operation_type isEqualToString:RESPONSE])
    {
        for(NSString *  str in allkeys)
        {
            if([str isEqualToString:LAST_INSERT_RESONSE_TIME])
            {
                [dict setObject:last_sync_time forKey:LAST_INSERT_RESONSE_TIME];
            }
           
        }
    }
    else if([sync_type isEqualToString:UPDATE] && [operation_type isEqualToString:REQUEST])
    {
        for(NSString *  str in allkeys)
        {
            if([str isEqualToString:LAST_UPDATE_REQUEST_TIME])
            {
                [dict setObject:current_gmt_time forKey:LAST_UPDATE_REQUEST_TIME];
            }
            else if ([str isEqualToString:UPDATE_SUCCESS])
            {
                [dict setObject:@"false" forKey:UPDATE_SUCCESS];
            }
        }
    }
    else if([sync_type isEqualToString:UPDATE] && [operation_type isEqualToString:RESPONSE])
    {
        for(NSString *  str in allkeys)
        {
            if([str isEqualToString:LAST_UPDATE_RESONSE_TIME])
            {
                [dict setObject:last_sync_time forKey:LAST_UPDATE_RESONSE_TIME];
            }
           
        }
    }
    else if([sync_type isEqualToString:DELETE] && [operation_type isEqualToString:REQUEST])
    {
        for(NSString *  str in allkeys)
        {
            if([str isEqualToString:LAST_DELETE_REQUEST_TIME])
            {
                [dict setObject:current_gmt_time forKey:LAST_DELETE_REQUEST_TIME];
            }
           
        }
    }
    else if([sync_type isEqualToString:DELETE] && [operation_type isEqualToString:RESPONSE])
    {
        for(NSString *  str in allkeys)
        {
            if([str isEqualToString:LAST_DELETE_RESPONSE_TIME])
            {
                [dict setObject:last_sync_time forKey:LAST_DELETE_RESPONSE_TIME];
            }
           
        }
    }
      
    [dict writeToFile:plistPath_SYNHIST atomically:YES];
    [dict release];                    //sahana30April
}

-(void)DoSpecialIncrementalSync
{
    if (![appDelegate isInternetConnectionAvailable])
    {
        appDelegate.isSpecialSyncDone = TRUE;
        return;
    }
    
    NSAutoreleasePool * autoreleasePool = [[NSAutoreleasePool alloc] init];
    appDelegate.speacialSyncIsGoingOn  = TRUE;
    
    [appDelegate goOnlineIfRequired];
    
    Insert_requestId = [self  get_SYNCHISTORYTime_ForKey:REQUEST_ID];
    Insert_requestId = [ Insert_requestId stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if(Insert_requestId == nil || [Insert_requestId isEqualToString:@""] )                                     
        Insert_requestId = [iServiceAppDelegate GetUUID];     
    
//  [self getAllRecordsForOperationTypeFromSYNCCONFLICT:PUT_INSERT OverRideFlag:NONE];
	[self getAllRecordsForOperationTypeFromSYNCCONFLICT:PUT_INSERT OverRideFlag:RETRY];  //change for new implementation.
    
    [self Put:PUT_INSERT];
    
    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(@"WSinterface.m : DoSplIncSync: PUT_INSERT");
#endif

        if (![appDelegate isInternetConnectionAvailable])
        {
            return;
        }
        
        if(appDelegate.Incremental_sync_status == PUT_INSERT_DONE || appDelegate.incrementalSync_Failed == TRUE)
        {
            break;
        }
        if (appDelegate.connection_error)
        {
            break;
        }

    }

	//put all deletes 
	[self getAllRecordsForOperationTypeFromSYNCCONFLICT:PUT_DELETE OverRideFlag:RETRY];
	[self Put:PUT_DELETE];
	
	while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(@"WSinterface.m : DoSplIncSync: PUT_DELETE");
#endif

        if (![appDelegate isInternetConnectionAvailable])
        {
            return;
        }
        
        if(appDelegate.Incremental_sync_status == PUT_DELETE_DONE || appDelegate.incrementalSync_Failed == TRUE)
        {
            break;
        }
        
        if (appDelegate.connection_error)
        {
            break;
        }
    }
    [self getAllRecordsForOperationTypeFromSYNCCONFLICT:PUT_UPDATE OverRideFlag:CLIENT_OVERRIDE];
    [self Put:PUT_UPDATE];
    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(@"WSinterface.m : DoSplIncSync: PUT_UPDATE");
#endif

        if (![appDelegate isInternetConnectionAvailable])
        {
            return;
        }
        
        if(appDelegate.Incremental_sync_status == PUT_UPDATE_DONE || appDelegate.incrementalSync_Failed == TRUE)
        {
            break;
        }
        if (appDelegate.connection_error)
        {
            break;
        }

    }
    
    [appDelegate.databaseInterface PutconflictRecordsIntoHeapFor:PUT_UPDATE override_flag:SERVER_OVERRIDE];
    [appDelegate.databaseInterface PutconflictRecordsIntoHeapFor:PUT_DELETE override_flag:SERVER_OVERRIDE];
    
    [self PutAllTheRecordsForIds];
    
    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(@"WSinterface.m : DoSplIncSync: TX_FETCH");
#endif

        if(appDelegate.Incremental_sync_status == PUT_RECORDS_DONE || appDelegate.incrementalSync_Failed == TRUE)
        {
            break;
        }
        if (![appDelegate isInternetConnectionAvailable])
        {
            break;
        }
        if(appDelegate.connection_error)
            break;
        

    }
    
    [appDelegate.databaseInterface  updateSyncRecordsIntoLocalDatabase];
    
    [appDelegate.databaseInterface cleartable:SYNC_RECORD_HEAP];
    appDelegate.speacialSyncIsGoingOn  = FALSE;
    BOOL conflict_exists = [appDelegate.databaseInterface getConflictsStatus];
    if(conflict_exists)
    {
		[appDelegate setSyncStatus:SYNC_RED];
		[updateSyncStatus refreshSyncStatus];
    }
    else
    {        
        [self cleanUpForRequestId:Insert_requestId forEventName:@"CLEAN_UP"];
        while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO))
        {
#ifdef kPrintLogsDuringWebServiceCall
            SMLog(@"WSinterface.m : DoSplIncSync: CLEAN_UP");
#endif

            if(appDelegate.Incremental_sync_status == CLEANUP_DONE)
                break;
            
            if (![appDelegate isInternetConnectionAvailable])
            {
                break;
            }
            if(appDelegate.connection_error)
                break;

        }
        [self setSyncReqId:@""];
        
//        NSString * message = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_completed];
//        NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_status_button1];
//        NSString * cancel = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
//
//        UIAlertView *av = [[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:cancel otherButtonTitles: nil];
//        [av show];
//        [av release];
        
        [appDelegate setSyncStatus:SYNC_GREEN];
        [updateSyncStatus refreshSyncStatus];
    }
    
    appDelegate.isSpecialSyncDone = TRUE;
    [autoreleasePool release];
}


-(void)getAllRecordsForOperationTypeFromSYNCCONFLICT:(NSString *)operationType OverRideFlag:(NSString *)overrideFlag; 
{
    NSMutableArray * object_array = [[appDelegate.databaseInterface getAllRecordsFromConflictTableForOperationType:operationType overrideFlag:overrideFlag] retain];
    
	if(appDelegate.dataSync_dict != nil)
	{
		appDelegate.dataSync_dict = nil;
	}
	
    if( appDelegate.dataSync_dict == nil)
        appDelegate.dataSync_dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    NSArray * keys_all =  [NSArray arrayWithObjects:@"local_id" ,@"object_name" , @"record_type" ,@"sf_id", @"override_flag",nil];
    
    for(int i = 0 ; i < [object_array count] ; i++)
    {
        NSDictionary * dict = [object_array objectAtIndex:i];
        NSArray * keys = [dict allKeys];
        NSString * local_id = @"";
        NSString * object_name = @"";
        NSString * record_type = @"";
        NSString * sf_id = @"";
        NSString * override_flag = @"";
        
        for (int j = 0; j < [keys count]; j++)
        {
            NSString * key = [keys objectAtIndex:j];
            
            if([key isEqualToString:@"object_name"])
            {
                object_name = [dict objectForKey:key];
            }
            if([key isEqualToString:@"local_id"])
            {
                local_id = [dict objectForKey:key];
            }
            if([key isEqualToString:@"record_type"])
            {
                record_type = [dict objectForKey:key];
            }
            if([key isEqualToString:@"sf_id"])
            {
                sf_id = [dict objectForKey:key];
            }
            if([key isEqualToString:@"override_flag"])
            {
                override_flag = [dict objectForKey:key];
            }
        }
        
        NSArray * object_names_array = [appDelegate.dataSync_dict allKeys];
        BOOL  flag  = FALSE;
        for (NSString * obj in object_names_array) 
        {
            if([obj isEqualToString:object_name])
            {
                flag = TRUE;
            }
        }
        if(flag)
        {
            NSMutableArray * array = [appDelegate.dataSync_dict objectForKey:object_name];
            NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id,object_name,record_type,sf_id,override_flag, nil] forKeys:keys_all];
            [array addObject:dict];
        }
        else
        {
            NSMutableArray  * array = [[NSMutableArray alloc] initWithCapacity:0];
            NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id,object_name,record_type,sf_id,override_flag, nil] forKeys:keys_all];
            [array addObject:dict];
            [appDelegate.dataSync_dict  setValue:array forKey:object_name];
        }
        
    }

}


#pragma mark - CheckForProfile
- (void) checkIfProfileExistsWithEventName:(NSString *)eventName type:(NSString *)eventType
{
    [INTF_WebServicesDefServiceSvc initialize];
    
    INTF_WebServicesDefServiceSvc_SessionHeader * session = [[[INTF_WebServicesDefServiceSvc_SessionHeader alloc] init] autorelease];
    session.sessionId = [[ZKServerSwitchboard switchboard] sessionId];
    
    INTF_WebServicesDefServiceSvc_CallOptions * callOptions = [[[INTF_WebServicesDefServiceSvc_CallOptions alloc] init] autorelease];
    callOptions.client = nil;
    
    INTF_WebServicesDefServiceSvc_DebuggingHeader * debuggingHeader = [[[INTF_WebServicesDefServiceSvc_DebuggingHeader alloc] init] autorelease];
    debuggingHeader.debugLevel = 0;
    
    INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader * allowFieldTruncationHeader = [[[INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader alloc] init] autorelease];
    allowFieldTruncationHeader.allowFieldTruncation = NO;
    
    INTF_WebServicesDefBinding * binding = [INTF_WebServicesDefServiceSvc INTF_WebServicesDefBindingWithServer:appDelegate.currentServerUrl];
    binding.logXMLInOut = YES;
    
    INTF_WebServicesDefServiceSvc_INTF_MetaSync_WS * profileCheck = [[[INTF_WebServicesDefServiceSvc_INTF_MetaSync_WS alloc] init] autorelease];
    
    INTF_WebServicesDefServiceSvc_INTF_SFMRequest * sfmRequest = [[[INTF_WebServicesDefServiceSvc_INTF_SFMRequest alloc] init] autorelease];
    
    sfmRequest.eventName = eventName;
    sfmRequest.eventType = eventType;
    sfmRequest.userId = [appDelegate.loginResult userId];
    sfmRequest.groupId = [[appDelegate.loginResult userInfo] organizationId];
    sfmRequest.profileId = [[appDelegate.loginResult userInfo] profileId];
    sfmRequest.name = @"";

        
    [profileCheck setRequest:sfmRequest];  
    
    //[[ZKServerSwitchboard switchboard] doCheckSession];
    [binding INTF_MetaSync_WSAsyncUsingParameters:profileCheck 
                                    SessionHeader:session 
                                      CallOptions:callOptions 
                                  DebuggingHeader:debuggingHeader 
                       AllowFieldTruncationHeader:allowFieldTruncationHeader 
                                         delegate:self];
    

}

#pragma mark - End
#pragma mark - Client Version
- (NSString *) getClientVersionString
{
    NSString *iPadVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];

    NSArray *components = [iPadVersion componentsSeparatedByString:@"."];
    NSString *finalString = [[[NSString alloc] init] autorelease];
    NSString *finalString2 = [[[NSString alloc] init] autorelease];
    if([components count] <= 2)
    {
        NSString *secondString = [components objectAtIndex:1];
        int buffer = 4 - [secondString length];
        for(int k=0; k<buffer; k++)
            secondString = [secondString stringByAppendingString:@"0"];
        finalString2 = [finalString2 stringByAppendingFormat:@"%@%@",[components objectAtIndex:0],secondString];
    }
    else
    {
        int count  = 0;
        for(NSString *obj in components)
        {
            finalString  = [finalString stringByAppendingString:obj];
            if(count == 0)
                finalString  = [finalString stringByAppendingString:@"."];
            count ++;
        }
        components = nil;
        components = [finalString componentsSeparatedByString:@"."];
        if([components count] == 2)
        {
            NSString *secondString = [components objectAtIndex:1];
            int buffer = 4 - [secondString length];
            for(int k=0; k<buffer; k++)
                secondString = [secondString stringByAppendingString:@"0"];
            finalString2 = [finalString2 stringByAppendingFormat:@"%@%@",[components objectAtIndex:0],secondString];
        }
    }
    return finalString2;
}

#pragma mark - incremental Data Sync
-(void) PutAllTheRecordsForIds
{
    [INTF_WebServicesDefServiceSvc initialize];
    
    INTF_WebServicesDefServiceSvc_SessionHeader * sessionHeader = [[[INTF_WebServicesDefServiceSvc_SessionHeader alloc] init] autorelease];
    sessionHeader.sessionId = [[ZKServerSwitchboard switchboard] sessionId];
    
    INTF_WebServicesDefServiceSvc_CallOptions * callOptions = [[[INTF_WebServicesDefServiceSvc_CallOptions alloc] init] autorelease];
    callOptions.client = nil;
    
    INTF_WebServicesDefServiceSvc_DebuggingHeader * debuggingHeader = [[[INTF_WebServicesDefServiceSvc_DebuggingHeader alloc] init] autorelease];
    debuggingHeader.debugLevel = 0;
    
    INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader * allowFieldTruncationHeader = [[[INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader alloc] init] autorelease];
    allowFieldTruncationHeader.allowFieldTruncation = NO;
    

    INTF_WebServicesDefBinding * binding = [INTF_WebServicesDefServiceSvc INTF_WebServicesDefBindingWithServer:appDelegate.currentServerUrl];
    binding.logXMLInOut = YES;
     
    INTF_WebServicesDefServiceSvc_INTF_DataSync_WS  * datasync = [[[INTF_WebServicesDefServiceSvc_INTF_DataSync_WS alloc] init]   autorelease];
    
    INTF_WebServicesDefServiceSvc_INTF_SFMRequest * sfmRequest = [[[INTF_WebServicesDefServiceSvc_INTF_SFMRequest alloc] init] autorelease];
    sfmRequest.eventName = @"TX_FETCH";
    sfmRequest.eventType = @"SYNC";
     
    sfmRequest.userId = [appDelegate.loginResult userId];
    sfmRequest.groupId = [[appDelegate.loginResult userInfo] organizationId];
    sfmRequest.profileId = [[appDelegate.loginResult userInfo] profileId];
    
    
    NSMutableDictionary * dict = [appDelegate.databaseInterface getAllRecordsFromRecordsHeap];
    NSArray * allKeys = [dict allKeys];
    
    //If no records exists dont send the response
    if([allKeys count] == 0)
    {
        SMLog(@"NO getRecords ");
        //update all the records in the heap table to 
        appDelegate.Incremental_sync_status = PUT_RECORDS_DONE;
        return;
    }
    for(int i = 0 ; i < [allKeys count] ; i++)
    {
        NSString * object_api_name = [allKeys objectAtIndex:i];
        
        if([object_api_name length] != 0 && ![object_api_name isEqualToString:@""])
        {
            INTF_WebServicesDefServiceSvc_SVMXMap  * svmxcmap = [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
            svmxcmap.key = @"TX_OBJECT" ;
            svmxcmap.value = object_api_name; //object  api name
            NSMutableArray * array_of_record_ids = [dict  objectForKey:object_api_name];
            
            for(NSString * record_id in array_of_record_ids)
            {
                NSString * record_id_str = (NSString *)record_id;
                
                if(appDelegate.speacialSyncIsGoingOn)
                {
                    [appDelegate.databaseInterface DeleterecordFromTableWithSf_Id:SYNC_ERROR_CONFLICT sf_id:record_id_str withColumn:@"sf_id"];
                }
                
                [svmxcmap.values addObject:record_id_str];
            }
            [sfmRequest.valueMap addObject:svmxcmap];
            [svmxcmap release];
        }
    }
    
    [dict release];
    //ADD SVMXClient
    INTF_WebServicesDefServiceSvc_SVMXClient  * svmxc_client = [[[INTF_WebServicesDefServiceSvc_SVMXClient alloc] init] autorelease];
    
    svmxc_client.clientType = @"iPad";
    [svmxc_client.clientInfo addObject:@"OS:iPadOS"];
    [svmxc_client.clientInfo addObject:@"R4B2"];
    
    [sfmRequest addClientInfo:svmxc_client];
    [datasync setRequest:sfmRequest];
    
    
    SMLog(@"SAMMAN TX_FETCH Request Sent: %@", [NSDate date]);
    //[[ZKServerSwitchboard switchboard] doCheckSession];
    [binding INTF_DataSync_WSAsyncUsingParameters:datasync 
                                    SessionHeader:sessionHeader 
                                      CallOptions:callOptions
                                  DebuggingHeader:debuggingHeader
                       AllowFieldTruncationHeader:allowFieldTruncationHeader delegate:self]; 
    
}

-(NSString *)requestSnapShot
{
    if(request_time != nil)
    {
        return request_time;
    }
    NSDate * current_dateTime = [NSDate date];
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString * current_gmt_time = [dateFormatter stringFromDate:current_dateTime];
    
    request_time = current_gmt_time;
    
    return request_time;
    
}
-(void)resetSyncLastindexAndObjectName
{
    appDelegate.initial_Sync_last_index = 0;
    appDelegate.initital_sync_object_name = @"";
}

//DATA SYNC METHOD
-(void)DoIncrementalDataSync
{
    
    //RADHA 2012june12
    if (appDelegate.metaSyncRunning)
        return;
    
    if( appDelegate.eventSyncRunning )
    {
        //return this function if event sync is running and queue it
        appDelegate.dataSyncRunning = NO;
        appDelegate.queue_object = appDelegate;
        appDelegate.queue_selector = @selector(callDataSync);
        return;
    }
    
    NSString * data_sync = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_data_sync];
    
    if (![appDelegate isInternetConnectionAvailable])
    {
        return;
    }
   
    BOOL retVal;
    NSAutoreleasePool * autoreleasePool = [[NSAutoreleasePool alloc] init];
    
    //shrinivas
    retVal = [appDelegate goOnlineIfRequired];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    appDelegate.currentServerUrl = [userDefaults objectForKey:SERVERURL];

    SMLog(@"%@, %d",appDelegate.currentServerUrl, [appDelegate.currentServerUrl length] );
	
	
	
	if ([appDelegate.currentServerUrl Contains:@"null"] || [appDelegate.currentServerUrl length] == 0 || appDelegate.currentServerUrl == nil)
	{
		NSUserDefaults * userdefaults = [NSUserDefaults standardUserDefaults];
		
		appDelegate.currentServerUrl = [userdefaults objectForKey:SERVERURL];
	}
		
    
    if(retVal == NO || [appDelegate.currentServerUrl Contains:@"null"])
    {
        appDelegate.SyncStatus = SYNC_GREEN;
        [appDelegate setSyncStatus:SYNC_GREEN];
        return;
    }

	[appDelegate updateSyncFailedFlag:STRUE];
    appDelegate.dataSyncRunning = YES;
    appDelegate.connection_error = FALSE;
    
    [appDelegate goOnlineIfRequired];
    appDelegate.Incremental_sync = FALSE;
    appDelegate.SyncStatus = SYNC_ORANGE;
	
    [updateSyncStatus refreshSyncStatus];
    [appDelegate setSyncStatus:SYNC_ORANGE];
    
    appDelegate.incrementalSync_Failed  = FALSE;
    
    request_time = nil;  
    
    
    //getCurrentSyncTime
    NSDate * current_dateTime = [NSDate date];
    
    //get the last sync status
    
    
    [appDelegate.databaseInterface cleartable:SYNC_RECORD_HEAP];
   
    [self resetSyncLastindexAndObjectName];  //sahana
    
    [self generateRequestId];
    
    if(dcobjects_incrementalSync != nil)
    {
    //[dcobjects_incrementalSync release];
        dcobjects_incrementalSync = nil;
    }
  
    dcobjects_incrementalSync = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    [self GetDelete];

    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(@"WSinterface.m : DOINC_DATA_SYNC: GET_DELETE");
#endif

        if (![appDelegate isInternetConnectionAvailable])
        {
             appDelegate.dataSyncRunning = NO;
            [self internetConnectivityHandling:data_sync];
            break;
        }

        if (![appDelegate isInternetConnectionAvailable] || appDelegate.Incremental_sync_status == GET_DELETE_DONE || appDelegate.incrementalSync_Failed == TRUE)
        {
            break;
        }
        if(appDelegate.connection_error)
        {
             appDelegate.dataSyncRunning = NO;
            appDelegate.SyncStatus = SYNC_GREEN;
            [self internetConnectivityHandling:data_sync];
            return;
        }
		
    }
	
    if(appDelegate.incrementalSync_Failed == TRUE || [appDelegate isInternetConnectionAvailable] == FALSE)
    {
        if ([appDelegate isInternetConnectionAvailable])
            [appDelegate setSyncStatus:SYNC_GREEN];
		
		appDelegate.dataSyncRunning = NO;
        return;
    }
    
    [self GETDownloadCriteriaRecordsFor:GET_DELETE_DOWNLOAD_CRITERIA];
    
    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(@"WSinterface.m : DOINC_DATA_SYNC: GET_DELETE_DWN_CRIT");
#endif

        if (![appDelegate isInternetConnectionAvailable])
        {
             appDelegate.dataSyncRunning = NO;
            [self internetConnectivityHandling:data_sync];        
            break;
        }
        if(appDelegate.Incremental_sync_status == GET_DELETE_DC_DONE || appDelegate.incrementalSync_Failed == TRUE || [appDelegate isInternetConnectionAvailable] == FALSE)
        {
            break;
        }
        if(appDelegate.connection_error)
        {
            appDelegate.dataSyncRunning = NO;
            appDelegate.connection_error = TRUE;
            [self internetConnectivityHandling:data_sync];
            return;
        }
    }
    if(appDelegate.incrementalSync_Failed == TRUE || [appDelegate isInternetConnectionAvailable] == FALSE)
    {
		if ([appDelegate isInternetConnectionAvailable])
			appDelegate.SyncStatus = SYNC_GREEN;
        
		appDelegate.dataSyncRunning = NO;
        return;
    }    
    
    [self cleanUpForRequestId:Insert_requestId forEventName:@"CLEAN_UP_SELECT"];
    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(@"WSinterface.m : DOINC_DATA_SYNC: CLEAN_UP_SELECT 1");
#endif

        if (![appDelegate isInternetConnectionAvailable])
        {
            appDelegate.dataSyncRunning = NO;
            [self internetConnectivityHandling:data_sync];            
            break;
        }

        if(appDelegate.Incremental_sync_status == CLEANUP_DONE)
            break;
        
        if(appDelegate.connection_error)
        {
            appDelegate.dataSyncRunning = NO;
            [self internetConnectivityHandling:data_sync];
            return;
        }
        
    }
    if (![appDelegate isInternetConnectionAvailable])
    {
		appDelegate.dataSyncRunning = NO;
        return;
    }
    
    
    [self copyTrailertoTempTrailer:DELETE];
    
    [self getAllRecordsForOperationType:DELETE];
    
    [self Put:PUT_DELETE];
    
    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(@"WSinterface.m : DOINC_DATA_SYNC: PUT_DELETE");
#endif

        if (![appDelegate isInternetConnectionAvailable])
        {
            appDelegate.dataSyncRunning = NO;
            break;
        }
        if(appDelegate.Incremental_sync_status == PUT_DELETE_DONE || appDelegate.incrementalSync_Failed == TRUE || [appDelegate isInternetConnectionAvailable] == FALSE)
        {
            break;
        }
        if(appDelegate.connection_error)
        {
            appDelegate.dataSyncRunning = NO;
            appDelegate.SyncStatus = SYNC_GREEN;
            [self internetConnectivityHandling:data_sync];
            return;
        }
    }
    if (![appDelegate isInternetConnectionAvailable])
    {
        [self internetConnectivityHandling:data_sync];        
    }

    if(appDelegate.incrementalSync_Failed == TRUE || [appDelegate isInternetConnectionAvailable] == FALSE)
    {
        if ([appDelegate isInternetConnectionAvailable])
            [appDelegate setSyncStatus:SYNC_GREEN];
        
		appDelegate.dataSyncRunning = NO;
		[updateSyncStatus refreshSyncStatus];
        return;
    }
    
    [appDelegate.databaseInterface deleteAll_GET_DELETES_And_PUT_DELETE_From_HeapAndObject_tables:GET_DELETE];
    [appDelegate.databaseInterface deleteAll_GET_DELETES_And_PUT_DELETE_From_HeapAndObject_tables:PUT_DELETE];
    
    //clean up all delete operations from object tables , Heap table and  from  trailer table .
    
    [self copyTrailertoTempTrailer:INSERT];                           //This is the 1st method called in 
   
    [self  getAllRecordsForOperationType:INSERT];
    
    [self Put:PUT_INSERT];   //call incremental insert
    
    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(@"WSinterface.m : DOINC_DATA_SYNC: PUT_INSERT");
#endif

        if (![appDelegate isInternetConnectionAvailable])
        {
            [self internetConnectivityHandling:data_sync];
            appDelegate.dataSyncRunning = NO;
            break;
        }

        if(appDelegate.Incremental_sync_status == PUT_INSERT_DONE || appDelegate.incrementalSync_Failed == TRUE  || [appDelegate isInternetConnectionAvailable] == FALSE)
        {
            break;
        }
        if(appDelegate.connection_error)
        {
            appDelegate.dataSyncRunning = NO;
            appDelegate.SyncStatus = SYNC_GREEN;
            [self internetConnectivityHandling:data_sync];
            return;
        }
    }
    if(appDelegate.incrementalSync_Failed == TRUE || [appDelegate isInternetConnectionAvailable] == FALSE)
    {
        if ([appDelegate isInternetConnectionAvailable])
            appDelegate.SyncStatus = SYNC_GREEN;

		appDelegate.dataSyncRunning = NO;
        return;
    }
    
    [self resetSyncLastindexAndObjectName];  //sahana
    [self GetInsert];                        //once all insertion is over call call reverse insert  method 
    
    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(@"WSinterface.m : DOINC_DATA_SYNC: GET_INSERT");
#endif

        if (![appDelegate isInternetConnectionAvailable])
        {
            appDelegate.dataSyncRunning = NO;
            [self internetConnectivityHandling:data_sync];
            break;
        }

        if(appDelegate.Incremental_sync_status == GET_INSERT_DONE ||  appDelegate.incrementalSync_Failed == TRUE || [appDelegate isInternetConnectionAvailable] == FALSE)
        {
            break;
        }
        if(appDelegate.connection_error)
        {
            appDelegate.dataSyncRunning = NO;
            appDelegate.SyncStatus = SYNC_GREEN;
            [self internetConnectivityHandling:data_sync];
            return;
        }
    }  
    if(appDelegate.incrementalSync_Failed == TRUE || [appDelegate isInternetConnectionAvailable] == FALSE)
    {
        if ([appDelegate isInternetConnectionAvailable])
            [appDelegate setSyncStatus:SYNC_GREEN];
	
		appDelegate.dataSyncRunning = NO;
        return;
    }                                                             //call delete
                                                                        //call Update
    

    [self GETDownloadCriteriaRecordsFor:GET_INSERT_DOWNLOAD_CRITERIA];
    
    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(@"WSinterface.m : DOINC_DATA_SYNC: GET_INSERT_DWN_CRIT");
#endif

        if (![appDelegate isInternetConnectionAvailable])
        {
            appDelegate.dataSyncRunning = NO;
            [self internetConnectivityHandling:data_sync];            
            break;
        }
        if(appDelegate.Incremental_sync_status == GET_INSERT_DC_DONE || appDelegate.incrementalSync_Failed == TRUE || [appDelegate isInternetConnectionAvailable] == FALSE)
        {
            break;
        }
        if(appDelegate.connection_error)
        {
            appDelegate.dataSyncRunning = NO;
            appDelegate.SyncStatus = SYNC_GREEN;
            [self internetConnectivityHandling:data_sync];
            return;
        }
    }
    if(appDelegate.incrementalSync_Failed == TRUE || [appDelegate isInternetConnectionAvailable] == FALSE)
    {
        if ([appDelegate isInternetConnectionAvailable])
            [appDelegate setSyncStatus:SYNC_GREEN];
	
		appDelegate.dataSyncRunning = NO;	
        return;
    }    
    
    [self cleanUpForRequestId:Insert_requestId forEventName:@"CLEAN_UP_SELECT"];
    
    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(@"WSinterface.m : DOINC_DATA_SYNC: CLEAN_UP_SELECT 2");
#endif

        if (![appDelegate isInternetConnectionAvailable])
        {
            appDelegate.dataSyncRunning = NO;
            [self internetConnectivityHandling:data_sync];
            break;
        }
        
        if(appDelegate.Incremental_sync_status == CLEANUP_DONE)
            break;
        if(appDelegate.connection_error)
        {
            appDelegate.dataSyncRunning = NO;
            appDelegate.SyncStatus = SYNC_GREEN;
            [self internetConnectivityHandling:data_sync];
            return;
        }
    }
    if (![appDelegate isInternetConnectionAvailable])
    {
		appDelegate.dataSyncRunning = NO;
        return;
    }
    
    
    didWriteSignature = NO;
    [appDelegate.calDataBase getAllLocalIdsForSignature:SIG_BEFOREUPDATE];
    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO))
    {
        SMLog(@"Signature to SFDC");
        if (didWriteSignature == YES)
            break;
        if (![appDelegate isInternetConnectionAvailable])
        {
            break;
        }
        if(appDelegate.connection_error)
            break;
    }
    
    
    //call update
    [self copyTrailertoTempTrailer:UPDATE];
    [self  getAllRecordsForOperationType:UPDATE];
    
    [self Put:PUT_UPDATE];
    
    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(@"WSinterface.m : DOINC_DATA_SYNC: PUT_UPDATE");
#endif

        if (![appDelegate isInternetConnectionAvailable])
        {
            appDelegate.dataSyncRunning = NO;
            [self internetConnectivityHandling:data_sync];
             
            break;
        }
        if(appDelegate.Incremental_sync_status == PUT_UPDATE_DONE  || appDelegate.incrementalSync_Failed == TRUE || [appDelegate isInternetConnectionAvailable] == FALSE)
        {
            break;
        }
        if(appDelegate.connection_error)
        {
            appDelegate.dataSyncRunning = NO;
            appDelegate.SyncStatus = SYNC_GREEN;
            [self internetConnectivityHandling:data_sync];
             
            return;
        }
    }
    if(appDelegate.incrementalSync_Failed == TRUE || [appDelegate isInternetConnectionAvailable] == FALSE)
    {
        if ([appDelegate isInternetConnectionAvailable])
            [appDelegate setSyncStatus:SYNC_GREEN];

		appDelegate.dataSyncRunning = NO;
        return;
    }
    
   
    [self resetSyncLastindexAndObjectName];  //sahana
    
    
    didWriteSignature = NO;
    [appDelegate.calDataBase getAllLocalIdsForSignature:SIG_AFTERUPDATE];
    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO))
    {
        SMLog(@"Signature to SFDC");
        if (didWriteSignature == YES)
            break;
    }
    
    
    [self GetUpdate];
    
    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(@"WSinterface.m : DOINC_DATA_SYNC: GET_UPDATE");
#endif

        if (![appDelegate isInternetConnectionAvailable])
        {
            appDelegate.dataSyncRunning = NO;
            [self internetConnectivityHandling:data_sync];
             
            break;
        }
        if(appDelegate.Incremental_sync_status == GET_UPDATE_DONE || appDelegate.incrementalSync_Failed == TRUE || [appDelegate isInternetConnectionAvailable] == FALSE)
        {
            break;
        }
        if(appDelegate.connection_error)
        {
            appDelegate.dataSyncRunning = NO;
            appDelegate.SyncStatus = SYNC_GREEN;
            [self internetConnectivityHandling:data_sync];
             
            return;
        }
    }
    
    if(appDelegate.incrementalSync_Failed == TRUE || [appDelegate isInternetConnectionAvailable] == FALSE)
    {
        if ([appDelegate isInternetConnectionAvailable])
            [appDelegate setSyncStatus:SYNC_GREEN];
        
		appDelegate.dataSyncRunning = NO;
        return;
    }
    
    [self GETDownloadCriteriaRecordsFor:GET_UPDATE_DOWNLOAD_CRITERIA];
    
    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(@"WSinterface.m : DOINC_DATA_SYNC: GET_UPDATE_DWN_CRIT");
#endif

        if (![appDelegate isInternetConnectionAvailable])
        {
            appDelegate.dataSyncRunning = NO;
            [self internetConnectivityHandling:data_sync];
             
            
            break;
        }
        if(appDelegate.Incremental_sync_status == GET_UPDATE_DC_DONE || appDelegate.incrementalSync_Failed == TRUE || [appDelegate isInternetConnectionAvailable] == FALSE)
        {
            break;
        }
        if(appDelegate.connection_error)
        {
            appDelegate.dataSyncRunning = NO;
            appDelegate.SyncStatus = SYNC_GREEN;
            [self internetConnectivityHandling:data_sync];
             
            return;
        }
    }
    if(appDelegate.incrementalSync_Failed == TRUE || [appDelegate isInternetConnectionAvailable] == FALSE)
    {
        if ([appDelegate isInternetConnectionAvailable])
            [appDelegate setSyncStatus:SYNC_GREEN];
    
		appDelegate.dataSyncRunning = NO;
        return;
    }
    
    [self cleanUpForRequestId:Insert_requestId forEventName:@"CLEAN_UP_SELECT"];
    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(@"WSinterface.m : DOINC_DATA_SYNC: CLN_UP_SELECT 3");
#endif

        if ( ![appDelegate isInternetConnectionAvailable])
        {
            appDelegate.dataSyncRunning = NO;
            [self internetConnectivityHandling:data_sync];
             
            break;
        }
        
        if(appDelegate.Incremental_sync_status == CLEANUP_DONE)
            break;
        
        if(appDelegate.connection_error)
        {
            appDelegate.dataSyncRunning = NO;
            appDelegate.SyncStatus = SYNC_GREEN;
            [self internetConnectivityHandling:data_sync];
             
            return;
        }
    }
    if ( ![appDelegate isInternetConnectionAvailable])
    {
		appDelegate.dataSyncRunning = NO;
        return;
    }
    [appDelegate.databaseInterface deleteAllConflictedRecordsFrom:SYNC_RECORD_HEAP];
    [self PutAllTheRecordsForIds];                                    //After update or delere ,insert are done  ,call getallrecords
    //After Insert Claer the trailer_temp table
    
    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(@"WSinterface.m : DOINC_DATA_SYNC: TX_FETCH");
#endif

        if (![appDelegate isInternetConnectionAvailable])
        {
            appDelegate.dataSyncRunning = NO;
            [self internetConnectivityHandling:data_sync];
             
            break;
        }
        if(appDelegate.Incremental_sync_status == PUT_RECORDS_DONE || appDelegate.incrementalSync_Failed == TRUE || [appDelegate isInternetConnectionAvailable] == FALSE)
        {
            break;
        }
        if(appDelegate.connection_error)
        {
            appDelegate.dataSyncRunning = NO;
            appDelegate.SyncStatus = SYNC_GREEN;
            [self internetConnectivityHandling:data_sync];
            
            return;
        }
    }
    
    if(appDelegate.incrementalSync_Failed == TRUE || [appDelegate isInternetConnectionAvailable] == FALSE)
    {
        if ([appDelegate isInternetConnectionAvailable])
            [appDelegate setSyncStatus:SYNC_GREEN];
        
		appDelegate.dataSyncRunning = NO;
        return;
    }
    if([appDelegate enableGPS_SFMSearch])
    {
        [appDelegate.dataBase createUserGPSTable];
        [appDelegate.dataBase updateTechnicianLocation];
        while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
        {
            if (appDelegate.dataBase.didTechnicianLocationUpdated == TRUE)
                break;   
            if (![appDelegate isInternetConnectionAvailable])
            {
                break;
            }
            if (appDelegate.connection_error)
            {
                break;
            }
            
            SMLog(@"Technician Location Updated");
        }

        [appDelegate.dataBase updateUserGPSLocation];
    }
    [appDelegate.databaseInterface  updateSyncRecordsIntoLocalDatabase];
    //check download criteria match
/*******************************************************DOWNLOAD_CRITERIA_CHANGE*************************************************************************/
    
    
    NSDictionary * get_old_criteria = [self getdownloadCriteriaObjects];
  
    NSArray * old_criteria_objects = [get_old_criteria allKeys];
    
    NSArray * new_criteria_objects = [dcobjects_incrementalSync allKeys];
    
    NSMutableArray * deletedObjects = [[NSMutableArray alloc] initWithCapacity:0];
 
    for(NSString * str in old_criteria_objects)
    {
        if(![new_criteria_objects containsObject:str])
        {
            [deletedObjects addObject:str];
        }
    }
    
    [appDelegate.databaseInterface deleteDownloadCriteriaObjects:deletedObjects];
    
    [deletedObjects release];
    //if([dcobjects_incrementalSync count] > 0)
    {
        [self downloadcriteriaplist:dcobjects_incrementalSync];
    }
/*******************************************************DOWNLOAD_CRITERIA_CHANGE*************************************************************************/
   

//Radha Purging 
    NSMutableArray * recordIds = [appDelegate.dataBase getAllTheNewEventsFromSynCRecordHeap];
    
    appDelegate.newEventMappinArray = [appDelegate.dataBase checkForTheObjectWithRecordId:recordIds];
    
    //Include the below commented method once the webservice is available
   // [appDelegate.dataBase removeIdExistsInIntialEventMappingArray];
    
    NSString * settingValue = [appDelegate.settingsDict objectForKey:@"Synchronization To Remove Events"];
    
    NSTimeInterval value = [settingValue integerValue];
    
    NSString * date = [appDelegate.dataBase getDateToDeleteEventsAndTaskOlder:value];
    
    
    [appDelegate.dataBase purgingDataOnSyncSettings:date tableName:@"Event" Action:@"LESSTHAN"];
    
    [appDelegate.dataBase purgingDataOnSyncSettings:date tableName:@"Task" Action:@"LESSTHAN"];
    
    //july 3
    settingValue = @"";
    
    settingValue = [appDelegate.settingsDict objectForKey:@"Synchronization To Get Events"];
    
    value = [settingValue integerValue];
    
    date = [appDelegate.dataBase getDateToDeleteEventsAndTaskForNext:value];
    
    
    [appDelegate.dataBase purgingDataOnSyncSettings:date tableName:@"Event" Action:@"GRETERTHAN"];
    
    [appDelegate.dataBase purgingDataOnSyncSettings:date tableName:@"Task" Action:@"GRETERTHAN"];
    
    
    

    //Radha Purging End
    
    [appDelegate.databaseInterface deleteAllConflictedRecordsFrom:SFDATATRAILER];
    
    
    [self setLastSyncTime];   // update the plist to last sync time
	
	//Radha updatesyncflag
	[appDelegate updateSyncFailedFlag:SFALSE];
    
    [appDelegate.databaseInterface cleartable:SYNC_RECORD_HEAP];

    BOOL conflict_exists = [appDelegate.databaseInterface getConflictsStatus];
    if(conflict_exists)
    {
        appDelegate.SyncStatus = SYNC_RED;
        [updateSyncStatus refreshSyncStatus];
        
        [appDelegate setSyncStatus:SYNC_RED];

    }
    else
    {
        //sahana
        [self cleanUpForRequestId:Insert_requestId forEventName:@"CLEAN_UP"];
        while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO))
        {
#ifdef kPrintLogsDuringWebServiceCall
            SMLog(@"WSinterface.m : DOINC_DATA_SYNC: CLEAN_UP");
#endif

            if ( ![appDelegate isInternetConnectionAvailable])
            {
                [appDelegate setSyncStatus:SYNC_GREEN];
            }
            if(appDelegate.Incremental_sync_status == CLEANUP_DONE)
                break;
            if(appDelegate.connection_error)
                break;

        }
        
        [self setSyncReqId:@""];
    }
    
    [appDelegate.dataBase updateRecentsPlist];
    

    //Shrinivas 
    //Sync signature to server
    didWriteSignature = NO;
    [appDelegate.calDataBase getAllLocalIdsForSignature:SIG_AFTERSYNC];
    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO))
    {
        SMLog(@"Signature to SFDC");
        if (didWriteSignature == YES)
            break;
        if (![appDelegate isInternetConnectionAvailable])
        {
            break;
        }
        if(appDelegate.connection_error)
            break;
    }
    
    //Sync PDF to SFDC
    didWritePDF = NO;
    [appDelegate.calDataBase getAllLocalIdsForPDF];
    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO))
    {
        SMLog(@"PDF to SFDC");
        if (didWritePDF == YES)
            break;
        if (![appDelegate isInternetConnectionAvailable])
        {
            break;
        }
        if(appDelegate.connection_error)
            break;

    }
    if(conflict_exists)
    {
        appDelegate.SyncStatus = SYNC_RED;
        [updateSyncStatus refreshSyncStatus];
        
        [appDelegate setSyncStatus:SYNC_RED];
        
    }
    else 
    {
        appDelegate.SyncStatus = SYNC_GREEN;
        [updateSyncStatus refreshSyncStatus];
    }
    
    

    AfterSaveEventsCalls = TRUE;
    
    NSArray * alleventsTime = [appDelegate.allpagelevelEventsWithTimestamp allKeys];
    NSMutableArray * timesNeedtobeDeleted = [[NSMutableArray alloc] initWithCapacity:0];
    
    for(int j = 0; j < [alleventsTime count] ; j++)
    {
        NSDate * timeStamp = [alleventsTime objectAtIndex:j];
        NSDictionary * aftersavePagelevelEvent = [appDelegate.allpagelevelEventsWithTimestamp objectForKey:timeStamp];
    
        if( [current_dateTime compare:timeStamp] == NSOrderedDescending)
        {
            [timesNeedtobeDeleted addObject:timeStamp];
            
            INTF_WebServicesDefServiceSvc_INTF_PREQ_GetPrice_WS *  request =  [aftersavePagelevelEvent objectForKey:AFTERSAVEPAGELEVELEVENT];
            INTF_WebServicesDefBinding * binding = [aftersavePagelevelEvent objectForKey:AFTERSAVEPAQGELEVELBINDING];
            didCompleteAfterSaveEventCalls = NO;
            [self callsfMEventForAfterSaveOrupdateEvents:request binding:binding];
            while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO))
            {
                SMLog(@"pagelevel events");
                if (didCompleteAfterSaveEventCalls == YES)
                    break;
                if (![appDelegate isInternetConnectionAvailable])
                {
                    break;
                }
                if(appDelegate.connection_error)
                    break;

            }
        }
    }
    
    for(NSString * Id_ in timesNeedtobeDeleted)
    {
        [appDelegate.allpagelevelEventsWithTimestamp removeObjectForKey:Id_];
    }
   
    AfterSaveEventsCalls = FALSE;
    [autoreleasePool release];
    
    //sahana starts june 8
    //check the database for false entries
    //if entries still exist in the db, that means, the user has entered fresh data
    //so, incremental datasync needs to continue on the "SAME THREAD"
    if([appDelegate.databaseInterface ContinueIncrementalDataSync] && !conflict_exists)
    {
        [self DoIncrementalDataSync];
    }
    //sahana ends june 8
    
    
    if( appDelegate.queue_object != nil )
    {
        appDelegate.dataSyncRunning = NO;
        [appDelegate.queue_object performSelectorOnMainThread:appDelegate.queue_selector withObject:nil waitUntilDone:NO];
    }
    
    appDelegate.dataSyncRunning = NO;
    
}

-(void)setSyncStatus
{
    appDelegate.SyncStatus = SYNC_GREEN;
    [appDelegate setSyncStatus:SYNC_GREEN];
}

-(void)internetConnectivityHandling:(NSString *)data_sync
{
	if (![appDelegate isInternetConnectionAvailable])
	{
		appDelegate.SyncStatus = SYNC_RED;
		[updateSyncStatus refreshSyncStatus];
		[appDelegate setSyncStatus:SYNC_RED];
		[appDelegate.calDataBase insertIntoConflictInternetErrorWithSyncType:data_sync];
		appDelegate.internet_Conflicts = [appDelegate.calDataBase getInternetConflicts];
		[appDelegate.reloadTable ReloadSyncTable];
	}
}

-(void)callsfMEventForAfterSaveOrupdateEvents:(INTF_WebServicesDefServiceSvc_INTF_PREQ_GetPrice_WS *) getThoonsEvent binding:(INTF_WebServicesDefBinding *)binding 
{
    
    INTF_WebServicesDefServiceSvc_SessionHeader * sessionHeader = [[[INTF_WebServicesDefServiceSvc_SessionHeader alloc] init] autorelease];
    sessionHeader.sessionId = [[ZKServerSwitchboard switchboard] sessionId];
    
    INTF_WebServicesDefServiceSvc_CallOptions * callOptions = [[[INTF_WebServicesDefServiceSvc_CallOptions alloc] init] autorelease];
    callOptions.client = nil;
    
    INTF_WebServicesDefServiceSvc_DebuggingHeader * debuggingHeader = [[[INTF_WebServicesDefServiceSvc_DebuggingHeader alloc] init] autorelease];
    debuggingHeader.debugLevel = 0;
    
    INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader * allowFieldTruncationHeader = [[[INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader alloc] init] autorelease];
    allowFieldTruncationHeader.allowFieldTruncation = NO;
    [binding INTF_PREQ_GetPrice_WSAsyncUsingParameters:getThoonsEvent
                                         SessionHeader:sessionHeader
                                           CallOptions:callOptions
                                       DebuggingHeader:debuggingHeader
                            AllowFieldTruncationHeader:allowFieldTruncationHeader
                                              delegate:self];
    
}

-(void)generateRequestId
{
    Insert_requestId = [self  get_SYNCHISTORYTime_ForKey:REQUEST_ID];
    Insert_requestId = [ Insert_requestId stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if(Insert_requestId == nil || [Insert_requestId isEqualToString:@""])                                     
        Insert_requestId = [iServiceAppDelegate GetUUID];     //GEnerate the request_Id
    else
    {
        [self cleanUpForRequestId:Insert_requestId forEventName:@"CLEAN_UP_SELECT"];
        while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO))
        {
#ifdef kPrintLogsDuringWebServiceCall
            SMLog(@"WSinterface.m : generateRequestId: CLEAN_UP_SELECT");
#endif

            if(appDelegate.Incremental_sync_status == CLEANUP_DONE)
                break;
            if (![appDelegate isInternetConnectionAvailable])
            {
                return;
            }
            if (appDelegate.connection_error)
            {
                break;
            }

        }
    }
    
    
    [self setSyncReqId:Insert_requestId];
}

-(void)copyTrailertoTempTrailer:(NSString *)operation_type
{
    [appDelegate.databaseInterface cleartable:SFDATATRAILER_TEMP];   //clear trailer temp
    
    [appDelegate.databaseInterface copyTrailerTableToTempTrailerForOperationType:operation_type];    
    
    [self setsyncHistoryForSyncType:operation_type requestOrResponse:REQUEST request_id:Insert_requestId last_sync_time:@""];  //Take time snap for insert and set it for last_insert request
       
}

#pragma mark incremental Data SYNC
-(void)getAllRecordsForOperationType:(NSString *)OpearationType
{

    //get the whole data from database 
    //get all the master records
    //recordType  can be MASETR  Or Detail
    appDelegate.dataSync_dict = nil;
    NSMutableArray * object_array = [[appDelegate.databaseInterface getAllInsertRecords:OpearationType] retain];
    
    if( appDelegate.dataSync_dict == nil)
        appDelegate.dataSync_dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    NSArray * keys_all = [NSArray arrayWithObjects:@"local_id" , @"parent_object_name", @"parent_local_id",@"time_stamp",@"record_type" ,nil];
    
    for(int i = 0 ; i < [object_array count] ; i++)
    {
        NSDictionary * dict = [object_array objectAtIndex:i];
        NSArray * keys = [dict allKeys];
        NSString * local_id = @"";
        NSString * object_name = @"";
        NSString * parent_object_name = @"";
        NSString * parent_local_id = @"";
        NSString * time_stamp = @"";
        NSString * record_type = @"";
        
        for (int j = 0; j < [keys count]; j++)
        {
            NSString * key = [keys objectAtIndex:j];
            
            if([key isEqualToString:@"object_name"])
            {
                object_name = [dict objectForKey:key];
            }
            if([key isEqualToString:@"local_id"])
            {
                local_id = [dict objectForKey:key];
            }
            if([key isEqualToString:@"parent_object_name"])
            {
                parent_object_name = [dict objectForKey:@"parent_object_name"];
            }
            if([key isEqualToString:@"parent_local_id"])
            {
                parent_local_id = [dict objectForKey:@"parent_local_id"];
            }
            if([key isEqualToString:@"time_stamp"])
            {
                time_stamp = [dict objectForKey:@"time_stamp"];
            }
            if([key isEqualToString:@"record_type"])
            {
                record_type = [dict objectForKey:@"record_type"];
            }
        }
        
        NSArray * object_names_array = [appDelegate.dataSync_dict allKeys];
        BOOL  flag  = FALSE;
        for (NSString * obj in object_names_array) 
        {
            if([obj isEqualToString:object_name])
            {
                flag = TRUE;
            }
        }
        if(flag)
        {
            NSMutableArray * array = [appDelegate.dataSync_dict objectForKey:object_name];
            NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id,parent_object_name,parent_local_id,time_stamp,record_type, nil] forKeys:keys_all];
            [array addObject:dict];
        }
        else
        {
            NSMutableArray  * array = [[NSMutableArray alloc] initWithCapacity:0];
            NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id,parent_object_name,parent_local_id,time_stamp,record_type, nil] forKeys:keys_all];
            [array addObject:dict];
            [appDelegate.dataSync_dict setValue:array forKey:object_name];
        }
    }
}

-(void)getOnDemandRecords:(NSString*)objectName record_id:(NSString*)record_id
{
    [INTF_WebServicesDefServiceSvc initialize];
    
    INTF_WebServicesDefServiceSvc_SessionHeader * sessionHeader = [[[INTF_WebServicesDefServiceSvc_SessionHeader alloc] init] autorelease];
    sessionHeader.sessionId = [[ZKServerSwitchboard switchboard] sessionId];
    
    INTF_WebServicesDefServiceSvc_CallOptions * callOptions = [[[INTF_WebServicesDefServiceSvc_CallOptions alloc] init] autorelease];
    callOptions.client = nil;
    
    INTF_WebServicesDefServiceSvc_DebuggingHeader * debuggingHeader = [[[INTF_WebServicesDefServiceSvc_DebuggingHeader alloc] init] autorelease];
    debuggingHeader.debugLevel = 0;
    
    INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader * allowFieldTruncationHeader = [[[INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader alloc] init] autorelease];
    allowFieldTruncationHeader.allowFieldTruncation = NO;
    
    INTF_WebServicesDefBinding * binding = [INTF_WebServicesDefServiceSvc INTF_WebServicesDefBindingWithServer:appDelegate.currentServerUrl];
    binding.logXMLInOut = YES;
    
    
    INTF_WebServicesDefServiceSvc_INTF_DataSync_WS  * datasync = [[[INTF_WebServicesDefServiceSvc_INTF_DataSync_WS alloc] init] autorelease];
    
    INTF_WebServicesDefServiceSvc_INTF_SFMRequest * sfmRequest = [[[INTF_WebServicesDefServiceSvc_INTF_SFMRequest alloc] init] autorelease];
    sfmRequest.eventName = @"DATA_ON_DEMAND";
    sfmRequest.eventType = @"GET_DATA";
    sfmRequest.userId = [appDelegate.loginResult userId];
    sfmRequest.groupId = [[appDelegate.loginResult userInfo] organizationId];
    sfmRequest.profileId = [[appDelegate.loginResult userInfo] profileId];
    
    //ADD SVMXClient
    INTF_WebServicesDefServiceSvc_SVMXClient  * svmxc_client = [[[INTF_WebServicesDefServiceSvc_SVMXClient alloc] init] autorelease];
    
    svmxc_client.clientType = @"iPad";
    [svmxc_client.clientInfo addObject:@"OS:iPadOS"];
    [svmxc_client.clientInfo addObject:@"R4B2"];
    
    //find out whether the object is MASTER/DETAIL
    NSDictionary *dict_child=[appDelegate.databaseInterface getAllChildRelationShipForObject:objectName];
    BOOL IsParent = TRUE ;
    if(IsParent)
    {
  
        
        INTF_WebServicesDefServiceSvc_SVMXMap *valueMapforObject=[[[INTF_WebServicesDefServiceSvc_SVMXMap alloc]init]autorelease];
        
        valueMapforObject.key=@"Object_Name";
        valueMapforObject.value=objectName;
        
        INTF_WebServicesDefServiceSvc_SVMXMap *valueMapId=[[[INTF_WebServicesDefServiceSvc_SVMXMap alloc]init]autorelease];
        valueMapId.key=@"Id";
        valueMapId.value = record_id;
        
        NSDictionary * fields_dict = [appDelegate.databaseInterface getAllObjectFields:objectName tableName:SFOBJECTFIELD];
        NSArray * fields_array ;
        fields_array = [fields_dict allKeys];
        
        NSString * field_string = @"";
        for(int i = 0 ; i< [fields_array count]; i++)
        {
            NSString * field = [fields_array objectAtIndex:i];
            if (i == 0)
                field_string = [field_string stringByAppendingFormat:@"%@",field];
            else
                field_string = [field_string stringByAppendingFormat:@",%@",field];
        }

        
        INTF_WebServicesDefServiceSvc_SVMXMap *valueMapFields=[[[INTF_WebServicesDefServiceSvc_SVMXMap alloc]init]autorelease];
        valueMapFields.key=@"Fields";
        valueMapFields.value = field_string;
        
        
        INTF_WebServicesDefServiceSvc_SVMXMap *valueMapParentField_for_parent=[[[INTF_WebServicesDefServiceSvc_SVMXMap alloc]init]autorelease];
        valueMapParentField_for_parent.key =@"Parent_Reference_Field";
        valueMapParentField_for_parent.value = nil;

        
        [valueMapforObject.valueMap addObject:valueMapParentField_for_parent];
        [valueMapforObject.valueMap addObject:valueMapId];
        [valueMapforObject.valueMap addObject:valueMapFields];
        
        [sfmRequest.valueMap addObject:valueMapforObject];
        
        
        
        NSMutableArray * FinalChild = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
        NSArray * allChildObject = [dict_child allKeys];
        
        for(NSString * str in allChildObject)
        {
            BOOL ifExists = [appDelegate.databaseInterface isSFObject:str];
            if(![str isEqualToString:@"Event"]  && ![str isEqualToString:@"Task"]  && ifExists)
            {
                 [FinalChild addObject:str];
            }
        }
        
        for (int i = 0 ; i < [FinalChild count]; i++)
        {
            
            NSString * child_object = [FinalChild objectAtIndex:i];
            INTF_WebServicesDefServiceSvc_SVMXMap *valueMapChildObject=[[[INTF_WebServicesDefServiceSvc_SVMXMap alloc]init]autorelease];
            
            valueMapChildObject.key=@"Object_Name";
            valueMapChildObject.value=child_object;
            
            INTF_WebServicesDefServiceSvc_SVMXMap *valueMapChildId=[[[INTF_WebServicesDefServiceSvc_SVMXMap alloc]init]autorelease];
            valueMapChildId.key=@"Id";
            valueMapChildId.value = record_id;
            NSDictionary * fields_child_dict = [appDelegate.databaseInterface getAllObjectFields:child_object tableName:SFOBJECTFIELD];
            NSArray * fields_child_array ;
            fields_child_array = [fields_child_dict allKeys];
            
            NSString * field_child_string = @"";
            for(int i = 0 ; i< [fields_child_array count]; i++)
            {
                NSString * field = [fields_child_array objectAtIndex:i];
                if (i == 0)
                    field_child_string = [field_child_string stringByAppendingFormat:@"%@",field];
                else
                    field_child_string = [field_child_string stringByAppendingFormat:@",%@",field];
            }
            

            INTF_WebServicesDefServiceSvc_SVMXMap *valueMapchildFields=[[[INTF_WebServicesDefServiceSvc_SVMXMap alloc]init]autorelease];
            valueMapchildFields.key=@"Fields";
            valueMapchildFields.value = field_child_string;
            
            INTF_WebServicesDefServiceSvc_SVMXMap *valueMapParentField=[[[INTF_WebServicesDefServiceSvc_SVMXMap alloc]init]autorelease];
            valueMapParentField.key =@"Parent_Reference_Field";
            valueMapParentField.value = [dict_child objectForKey:child_object];
            
            [valueMapChildObject.valueMap addObject:valueMapChildId];
            [valueMapChildObject.valueMap addObject:valueMapchildFields];
            [valueMapChildObject.valueMap addObject:valueMapParentField];
            [sfmRequest.valueMap addObject:valueMapChildObject];

        }
        

    }
    else
    {
        
//        INTF_WebServicesDefServiceSvc_SVMXMap *valueMapforParent=[[[INTF_WebServicesDefServiceSvc_SVMXMap alloc]init]autorelease];
//        
//        INTF_WebServicesDefServiceSvc_SVMXMap *valueMapforObject=[[[INTF_WebServicesDefServiceSvc_SVMXMap alloc]init]autorelease];
//        
//        valueMapforObject.key=@"Object_Name";
//        valueMapforObject.value=objectName;
//        
//        INTF_WebServicesDefServiceSvc_SVMXMap *valueMapId=[[[INTF_WebServicesDefServiceSvc_SVMXMap init]alloc]autorelease];
//        valueMapId.key=@"Id";
//        valueMapId.value = record_id;
//        INTF_WebServicesDefServiceSvc_SVMXMap *valueMapFields=[[[INTF_WebServicesDefServiceSvc_SVMXMap init]alloc]autorelease];
//        valueMapFields.key=@"fields";
//        valueMapFields.value = @"";
//        [valueMapforObject.valueMap addObject:valueMapId];
//        [valueMapforObject.valueMap addObject:valueMapFields];
//        
//        [sfmRequest.valueMap addObject:valueMapforObject];
    }
       
    [sfmRequest addClientInfo:svmxc_client];
    [datasync setRequest:sfmRequest];
    
    
    binding.logXMLInOut = YES;
    [binding INTF_DataSync_WSAsyncUsingParameters:datasync
                                    SessionHeader:sessionHeader
                                      CallOptions:callOptions
                                  DebuggingHeader:debuggingHeader
                       AllowFieldTruncationHeader:allowFieldTruncationHeader delegate:self];
}
-(void)GetInsert
{
    [INTF_WebServicesDefServiceSvc initialize];
    
    INTF_WebServicesDefServiceSvc_SessionHeader * sessionHeader = [[[INTF_WebServicesDefServiceSvc_SessionHeader alloc] init] autorelease];
    sessionHeader.sessionId = [[ZKServerSwitchboard switchboard] sessionId];    
    
    INTF_WebServicesDefServiceSvc_CallOptions * callOptions = [[[INTF_WebServicesDefServiceSvc_CallOptions alloc] init] autorelease];
    callOptions.client = nil;
    
    INTF_WebServicesDefServiceSvc_DebuggingHeader * debuggingHeader = [[[INTF_WebServicesDefServiceSvc_DebuggingHeader alloc] init] autorelease];
    debuggingHeader.debugLevel = 0;
    
    INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader * allowFieldTruncationHeader = [[[INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader alloc] init] autorelease];
    allowFieldTruncationHeader.allowFieldTruncation = NO;
    
    
    INTF_WebServicesDefBinding * binding = [INTF_WebServicesDefServiceSvc INTF_WebServicesDefBindingWithServer:appDelegate.currentServerUrl];
    binding.logXMLInOut = YES;
    
    
    INTF_WebServicesDefServiceSvc_INTF_DataSync_WS  * datasync = [[[INTF_WebServicesDefServiceSvc_INTF_DataSync_WS alloc] init] autorelease];
    
    INTF_WebServicesDefServiceSvc_INTF_SFMRequest * sfmRequest = [[[INTF_WebServicesDefServiceSvc_INTF_SFMRequest alloc] init] autorelease];
    sfmRequest.eventName = @"GET_INSERT";
    sfmRequest.eventType = @"SYNC";
    sfmRequest.userId = [appDelegate.loginResult userId];
    sfmRequest.groupId = [[appDelegate.loginResult userInfo] organizationId];
    sfmRequest.profileId = [[appDelegate.loginResult userInfo] profileId];
    sfmRequest.value = Insert_requestId;
    
    INTF_WebServicesDefServiceSvc_SVMXMap * SVMXCMap_lastModified =  [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
    SVMXCMap_lastModified.key = @"LAST_SYNC_TIME";
    SVMXCMap_lastModified.value = [self get_SYNCHISTORYTime_ForKey:LAST_INSERT_RESONSE_TIME] == nil ?@"":[self get_SYNCHISTORYTime_ForKey:LAST_INSERT_RESONSE_TIME];
    
    INTF_WebServicesDefServiceSvc_SVMXMap * SVMXCMap_startTime =  [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
    SVMXCMap_startTime.key  = @"RANGE_START";
    SVMXCMap_startTime.value = [self getSyncTimeStampWithTheIntervalof15days:START_TIME] == nil ? @"" :[self getSyncTimeStampWithTheIntervalof15days:START_TIME];
    
    INTF_WebServicesDefServiceSvc_SVMXMap * SVMXCMap_endTime =  [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
    SVMXCMap_endTime.key  = @"RANGE_END";
    SVMXCMap_endTime.value = [self getSyncTimeStampWithTheIntervalof15days:END_TIME]== nil ? @"" :[self getSyncTimeStampWithTheIntervalof15days:END_TIME];
    
    [sfmRequest.valueMap addObject:SVMXCMap_lastModified];
    [sfmRequest.valueMap addObject:SVMXCMap_startTime];
    [sfmRequest.valueMap addObject:SVMXCMap_endTime];

    //ADD SVMXClient
    INTF_WebServicesDefServiceSvc_SVMXClient  * svmxc_client = [[[INTF_WebServicesDefServiceSvc_SVMXClient alloc] init]  autorelease];
    
    svmxc_client.clientType = @"iPad";
    [svmxc_client.clientInfo addObject:@"OS:iPadOS"];
    [svmxc_client.clientInfo addObject:@"R4B2"];
    //[client_listMap.valueList addObject:svmxc_client];
    
    [sfmRequest addClientInfo:svmxc_client];
    [datasync setRequest:sfmRequest];
    
    
    binding.logXMLInOut = YES;
    //[[ZKServerSwitchboard switchboard] doCheckSession];
    [binding INTF_DataSync_WSAsyncUsingParameters:datasync 
                                    SessionHeader:sessionHeader 
                                      CallOptions:callOptions
                                  DebuggingHeader:debuggingHeader
                       AllowFieldTruncationHeader:allowFieldTruncationHeader delegate:self]; 
}

-(void)GetUpdate
{
    [INTF_WebServicesDefServiceSvc initialize];
    
    INTF_WebServicesDefServiceSvc_SessionHeader * sessionHeader = [[[INTF_WebServicesDefServiceSvc_SessionHeader alloc] init] autorelease];
    sessionHeader.sessionId = [[ZKServerSwitchboard switchboard] sessionId];
    
    INTF_WebServicesDefServiceSvc_CallOptions * callOptions = [[[INTF_WebServicesDefServiceSvc_CallOptions alloc] init] autorelease];
    callOptions.client = nil;
    
    INTF_WebServicesDefServiceSvc_DebuggingHeader * debuggingHeader = [[[INTF_WebServicesDefServiceSvc_DebuggingHeader alloc] init] autorelease];
    debuggingHeader.debugLevel = 0;
    
    INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader * allowFieldTruncationHeader = [[[INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader alloc] init] autorelease];
    allowFieldTruncationHeader.allowFieldTruncation = NO;
    
    INTF_WebServicesDefBinding * binding = [INTF_WebServicesDefServiceSvc INTF_WebServicesDefBindingWithServer:appDelegate.currentServerUrl];
    binding.logXMLInOut = YES;
    
    
    INTF_WebServicesDefServiceSvc_INTF_DataSync_WS  * datasync = [[[INTF_WebServicesDefServiceSvc_INTF_DataSync_WS alloc] init] autorelease];
    
    INTF_WebServicesDefServiceSvc_INTF_SFMRequest * sfmRequest = [[[INTF_WebServicesDefServiceSvc_INTF_SFMRequest alloc] init] autorelease];
    sfmRequest.eventName = @"GET_UPDATE";
    sfmRequest.eventType = @"SYNC";
    sfmRequest.userId = [appDelegate.loginResult userId];
    sfmRequest.groupId = [[appDelegate.loginResult userInfo] organizationId];
    sfmRequest.profileId = [[appDelegate.loginResult userInfo] profileId];
    sfmRequest.value = Insert_requestId;
    
    INTF_WebServicesDefServiceSvc_SVMXMap * SVMXCMap_lastModified =  [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
    SVMXCMap_lastModified.key = @"LAST_SYNC_TIME";
    SVMXCMap_lastModified.value = [self get_SYNCHISTORYTime_ForKey:LAST_UPDATE_RESONSE_TIME] == nil ?@"":[self get_SYNCHISTORYTime_ForKey:LAST_UPDATE_RESONSE_TIME];
    
    INTF_WebServicesDefServiceSvc_SVMXMap * SVMXCMap_startTime =  [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
    SVMXCMap_startTime.key  = @"RANGE_START";
    SVMXCMap_startTime.value = [self getSyncTimeStampWithTheIntervalof15days:START_TIME] == nil ? @"" :[self getSyncTimeStampWithTheIntervalof15days:START_TIME];
    
    INTF_WebServicesDefServiceSvc_SVMXMap * SVMXCMap_endTime =  [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
    SVMXCMap_endTime.key  = @"RANGE_END";
    SVMXCMap_endTime.value = [self getSyncTimeStampWithTheIntervalof15days:END_TIME]== nil ? @"" :[self getSyncTimeStampWithTheIntervalof15days:END_TIME];
    
    [sfmRequest.valueMap addObject:SVMXCMap_lastModified];
    [sfmRequest.valueMap addObject:SVMXCMap_startTime];
    [sfmRequest.valueMap addObject:SVMXCMap_endTime];
    
    //ADD SVMXClient
    INTF_WebServicesDefServiceSvc_SVMXClient  * svmxc_client = [[INTF_WebServicesDefServiceSvc_SVMXClient alloc] init];
    
    svmxc_client.clientType = @"iPad";
    [svmxc_client.clientInfo addObject:@"OS:iPadOS"];
    [svmxc_client.clientInfo addObject:@"R4B2"];
    //[client_listMap.valueList addObject:svmxc_client];
    
    [sfmRequest addClientInfo:svmxc_client];
    [datasync setRequest:sfmRequest];
    
    
    binding.logXMLInOut = YES;
    //[[ZKServerSwitchboard switchboard] doCheckSession];
    [binding INTF_DataSync_WSAsyncUsingParameters:datasync 
                                    SessionHeader:sessionHeader 
                                      CallOptions:callOptions
                                  DebuggingHeader:debuggingHeader
                       AllowFieldTruncationHeader:allowFieldTruncationHeader delegate:self]; 
}

-(void)GetDelete
{
    [INTF_WebServicesDefServiceSvc initialize];
    
    INTF_WebServicesDefServiceSvc_SessionHeader * sessionHeader = [[[INTF_WebServicesDefServiceSvc_SessionHeader alloc] init] autorelease];
    sessionHeader.sessionId = [[ZKServerSwitchboard switchboard] sessionId];
    
    INTF_WebServicesDefServiceSvc_CallOptions * callOptions = [[[INTF_WebServicesDefServiceSvc_CallOptions alloc] init] autorelease];
    callOptions.client = nil;
    
    INTF_WebServicesDefServiceSvc_DebuggingHeader * debuggingHeader = [[[INTF_WebServicesDefServiceSvc_DebuggingHeader alloc] init] autorelease];
    debuggingHeader.debugLevel = 0;
    
    INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader * allowFieldTruncationHeader = [[[INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader alloc] init] autorelease];
    allowFieldTruncationHeader.allowFieldTruncation = NO;
    
    INTF_WebServicesDefBinding * binding = [INTF_WebServicesDefServiceSvc INTF_WebServicesDefBindingWithServer:appDelegate.currentServerUrl];
    binding.logXMLInOut = YES;
    
    
    INTF_WebServicesDefServiceSvc_INTF_DataSync_WS  * datasync = [[[INTF_WebServicesDefServiceSvc_INTF_DataSync_WS alloc] init] autorelease];
    
    INTF_WebServicesDefServiceSvc_INTF_SFMRequest * sfmRequest = [[[INTF_WebServicesDefServiceSvc_INTF_SFMRequest alloc] init] autorelease];
    sfmRequest.eventName = @"GET_DELETE";
    sfmRequest.eventType = @"SYNC";
    sfmRequest.userId = [appDelegate.loginResult userId];
    sfmRequest.groupId = [[appDelegate.loginResult userInfo] organizationId];
    sfmRequest.profileId = [[appDelegate.loginResult userInfo] profileId];
    sfmRequest.value = Insert_requestId;
    
    INTF_WebServicesDefServiceSvc_SVMXMap * SVMXCMap_lastModified =  [[[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init] autorelease];
    SVMXCMap_lastModified.key = @"LAST_SYNC_TIME";
    SVMXCMap_lastModified.value = [self get_SYNCHISTORYTime_ForKey:LAST_DELETE_RESPONSE_TIME] == nil ?@"":[self get_SYNCHISTORYTime_ForKey:LAST_DELETE_RESPONSE_TIME];
    
    INTF_WebServicesDefServiceSvc_SVMXMap * SVMXCMap_startTime =  [[[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init] autorelease];
    SVMXCMap_startTime.key  = @"RANGE_START";
    SVMXCMap_startTime.value = [self getSyncTimeStampWithTheIntervalof15days:START_TIME] == nil ? @"" :[self getSyncTimeStampWithTheIntervalof15days:START_TIME];
    
    INTF_WebServicesDefServiceSvc_SVMXMap * SVMXCMap_endTime =  [[[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init] autorelease];
    SVMXCMap_endTime.key  = @"RANGE_END";
    SVMXCMap_endTime.value = [self getSyncTimeStampWithTheIntervalof15days:END_TIME]== nil ? @"" :[self getSyncTimeStampWithTheIntervalof15days:END_TIME];
    
    [sfmRequest.valueMap addObject:SVMXCMap_lastModified];
    [sfmRequest.valueMap addObject:SVMXCMap_startTime];
    [sfmRequest.valueMap addObject:SVMXCMap_endTime];
    
    //ADD SVMXClient
    INTF_WebServicesDefServiceSvc_SVMXClient  * svmxc_client = [[[INTF_WebServicesDefServiceSvc_SVMXClient alloc] init] autorelease];
    
    svmxc_client.clientType = @"iPad";
    [svmxc_client.clientInfo addObject:@"OS:iPadOS"];
    [svmxc_client.clientInfo addObject:@"R4B2"];
    //[client_listMap.valueList addObject:svmxc_client];
    
    [sfmRequest addClientInfo:svmxc_client];
    [datasync setRequest:sfmRequest];
    
    
    binding.logXMLInOut = YES;
    //[[ZKServerSwitchboard switchboard] doCheckSession];
    [binding INTF_DataSync_WSAsyncUsingParameters:datasync 
                                    SessionHeader:sessionHeader 
                                      CallOptions:callOptions
                                  DebuggingHeader:debuggingHeader
                       AllowFieldTruncationHeader:allowFieldTruncationHeader delegate:self];
}

-(void)cleanUpForRequestId:(NSString *)requestId  forEventName:(NSString *)eventName
{
    [INTF_WebServicesDefServiceSvc initialize];
    
    INTF_WebServicesDefServiceSvc_SessionHeader * sessionHeader = [[[INTF_WebServicesDefServiceSvc_SessionHeader alloc] init] autorelease];
    sessionHeader.sessionId = [[ZKServerSwitchboard switchboard] sessionId];
    
    INTF_WebServicesDefServiceSvc_CallOptions * callOptions = [[[INTF_WebServicesDefServiceSvc_CallOptions alloc] init] autorelease];
    callOptions.client = nil;
    
    INTF_WebServicesDefServiceSvc_DebuggingHeader * debuggingHeader = [[[INTF_WebServicesDefServiceSvc_DebuggingHeader alloc] init] autorelease];
    debuggingHeader.debugLevel = 0;
    
    INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader * allowFieldTruncationHeader = [[[INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader alloc] init] autorelease];
    allowFieldTruncationHeader.allowFieldTruncation = NO;
    
    INTF_WebServicesDefBinding * binding = [INTF_WebServicesDefServiceSvc INTF_WebServicesDefBindingWithServer:appDelegate.currentServerUrl];
    binding.logXMLInOut = YES;
    
    
    INTF_WebServicesDefServiceSvc_INTF_DataSync_WS  * datasync = [[[INTF_WebServicesDefServiceSvc_INTF_DataSync_WS alloc] init] autorelease];
    
    INTF_WebServicesDefServiceSvc_INTF_SFMRequest * sfmRequest = [[[INTF_WebServicesDefServiceSvc_INTF_SFMRequest alloc] init] autorelease];
    sfmRequest.eventName = eventName;
    sfmRequest.eventType = @"SYNC";
    sfmRequest.userId = [appDelegate.loginResult userId];
    sfmRequest.groupId = [[appDelegate.loginResult userInfo] organizationId];
    sfmRequest.profileId = [[appDelegate.loginResult userInfo] profileId];
    sfmRequest.value = requestId;
    
    //ADD SVMXClient
    INTF_WebServicesDefServiceSvc_SVMXClient  * svmxc_client = [[[INTF_WebServicesDefServiceSvc_SVMXClient alloc] init] autorelease];
    
    svmxc_client.clientType = @"iPad";
    [svmxc_client.clientInfo addObject:@"OS:iPadOS"];
    [svmxc_client.clientInfo addObject:@"R4B2"];
    //[client_listMap.valueList addObject:svmxc_client];
    
    [sfmRequest addClientInfo:svmxc_client];
    [datasync setRequest:sfmRequest];
    
    
    binding.logXMLInOut = YES;
    //[[ZKServerSwitchboard switchboard] doCheckSession];
    [binding INTF_DataSync_WSAsyncUsingParameters:datasync 
                                    SessionHeader:sessionHeader 
                                      CallOptions:callOptions
                                  DebuggingHeader:debuggingHeader
                       AllowFieldTruncationHeader:allowFieldTruncationHeader delegate:self];


}

//sahana  -Download criteria sync
-(void)GETDownloadCriteriaRecordsFor:(NSString *)event_name
{
    [INTF_WebServicesDefServiceSvc initialize];
    
    INTF_WebServicesDefServiceSvc_SessionHeader * sessionHeader = [[[INTF_WebServicesDefServiceSvc_SessionHeader alloc] init] autorelease];
    sessionHeader.sessionId = [[ZKServerSwitchboard switchboard] sessionId];
    
    INTF_WebServicesDefServiceSvc_CallOptions * callOptions = [[[INTF_WebServicesDefServiceSvc_CallOptions alloc] init] autorelease];
    callOptions.client = nil;
    
    INTF_WebServicesDefServiceSvc_DebuggingHeader * debuggingHeader = [[[INTF_WebServicesDefServiceSvc_DebuggingHeader alloc] init] autorelease];
    debuggingHeader.debugLevel = 0;
    
    INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader * allowFieldTruncationHeader = [[[INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader alloc] init] autorelease];
    allowFieldTruncationHeader.allowFieldTruncation = NO;
    
    INTF_WebServicesDefBinding * binding = [INTF_WebServicesDefServiceSvc INTF_WebServicesDefBindingWithServer:appDelegate.currentServerUrl];
    binding.logXMLInOut = YES;
    
    
    INTF_WebServicesDefServiceSvc_INTF_DataSync_WS  * datasync = [[[INTF_WebServicesDefServiceSvc_INTF_DataSync_WS alloc] init] autorelease];
    
    INTF_WebServicesDefServiceSvc_INTF_SFMRequest * sfmRequest = [[[INTF_WebServicesDefServiceSvc_INTF_SFMRequest alloc] init] autorelease];
    sfmRequest.eventName = event_name;
    sfmRequest.eventType = @"SYNC";
    sfmRequest.userId = [appDelegate.loginResult userId];
    sfmRequest.groupId = [[appDelegate.loginResult userInfo] organizationId];
    sfmRequest.profileId = [[appDelegate.loginResult userInfo] profileId];
    sfmRequest.value = Insert_requestId;
    
 
    INTF_WebServicesDefServiceSvc_SVMXMap * SVMXCMap_lastModified =  [[[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init] autorelease];
    SVMXCMap_lastModified.key = @"LAST_SYNC_TIME";
    
    if([event_name isEqualToString:GET_DELETE_DOWNLOAD_CRITERIA])
    {
        SVMXCMap_lastModified.value = [self get_SYNCHISTORYTime_ForKey:LAST_DELETE_RESPONSE_TIME] == nil ?@"":[self get_SYNCHISTORYTime_ForKey:LAST_DELETE_RESPONSE_TIME];
    }
    else if ([event_name isEqualToString:GET_INSERT_DOWNLOAD_CRITERIA])
    {
        SVMXCMap_lastModified.value = [self get_SYNCHISTORYTime_ForKey:LAST_INSERT_RESONSE_TIME] == nil ?@"":[self get_SYNCHISTORYTime_ForKey:LAST_INSERT_RESONSE_TIME];
    }
    else if ([event_name isEqualToString:GET_UPDATE_DOWNLOAD_CRITERIA])
    {
        SVMXCMap_lastModified.value = [self get_SYNCHISTORYTime_ForKey:LAST_UPDATE_RESONSE_TIME] == nil ?@"":[self get_SYNCHISTORYTime_ForKey:LAST_UPDATE_RESONSE_TIME];
    }
    
    INTF_WebServicesDefServiceSvc_SVMXMap * SVMXCMap_startTime =  [[[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init] autorelease];
    SVMXCMap_startTime.key  = @"RANGE_START";
    SVMXCMap_startTime.value = [self getSyncTimeStampWithTheIntervalof15days:START_TIME] == nil ? @"" :[self getSyncTimeStampWithTheIntervalof15days:START_TIME];
    
    INTF_WebServicesDefServiceSvc_SVMXMap * SVMXCMap_endTime =  [[[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init] autorelease];
    SVMXCMap_endTime.key  = @"RANGE_END";
    SVMXCMap_endTime.value = [self getSyncTimeStampWithTheIntervalof15days:END_TIME]== nil ? @"" :[self getSyncTimeStampWithTheIntervalof15days:END_TIME];
    
    INTF_WebServicesDefServiceSvc_SVMXMap * SVMXCMap_last_index =  [[[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init] autorelease];
    SVMXCMap_last_index.key  = @"LAST_INDEX";
    SVMXCMap_last_index.value = appDelegate.initial_Sync_last_index;
    [sfmRequest.valueMap addObject:SVMXCMap_last_index];
  
    //SEND DOwnload Criteria Objects 
    
    INTF_WebServicesDefServiceSvc_SVMXMap * SVMXCMap_dc_objects =  [[[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init] autorelease];
    SVMXCMap_dc_objects.key  = DOWNLOAD_CRITERIA_OBJECTS;
    NSDictionary * dict = [self getdownloadCriteriaObjects];
   /* NSAutoreleasePool * autoreleasePool = [[NSAutoreleasePool alloc] init];
    SBJsonWriter * writer = [[[SBJsonWriter alloc] init] autorelease];
    NSString * jsonstring = [[writer  stringWithObject:dict] retain];
    SVMXCMap_dc_objects.value = jsonstring;
    [autoreleasePool release];*/

    
    NSString * temp_event_name = @"";
    
    if ([event_name isEqualToString:GET_INSERT_DOWNLOAD_CRITERIA] || [event_name isEqualToString:GET_INSERT])
    {
        temp_event_name = GET_INSERT;
    }
    else if ([event_name isEqualToString:GET_UPDATE_DOWNLOAD_CRITERIA] || [event_name isEqualToString:GET_UPDATE])
    {
        temp_event_name = GET_UPDATE;
    }
    else if ([event_name isEqualToString:GET_DELETE_DOWNLOAD_CRITERIA] || [event_name isEqualToString:GET_DELETE])
    {
        temp_event_name = GET_DELETE;
    }
    
    if(appDelegate.initial_Sync_last_index > 0)
    {
        NSArray * all_records = [appDelegate.databaseInterface getAllIdsFromDatabase:temp_event_name forObjectName:appDelegate.initital_sync_object_name];
        
        for(NSString * str in all_records)
        {
            [sfmRequest.values addObject:str];
        }
    }
    
   
    NSArray * allobjects = [dict allKeys];
    for(NSString * object_name in allobjects)
    {
        INTF_WebServicesDefServiceSvc_SVMXMap * SVMXCMap_Object =  [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
        SVMXCMap_Object.key = object_name;
        SVMXCMap_Object.value = [dict objectForKey:object_name];
        [SVMXCMap_dc_objects.valueMap addObject:SVMXCMap_Object];
        [SVMXCMap_Object release];
    }
  
    
    [sfmRequest.valueMap addObject:SVMXCMap_lastModified];
    [sfmRequest.valueMap addObject:SVMXCMap_startTime];
    [sfmRequest.valueMap addObject:SVMXCMap_endTime];
    [sfmRequest.valueMap addObject:SVMXCMap_dc_objects];
    
    //ADD SVMXClient
    INTF_WebServicesDefServiceSvc_SVMXClient  * svmxc_client = [[[INTF_WebServicesDefServiceSvc_SVMXClient alloc] init] autorelease];
    
    svmxc_client.clientType = @"iPad";
    [svmxc_client.clientInfo addObject:@"OS:iPadOS"];
    [svmxc_client.clientInfo addObject:@"R4B2"];
    //[client_listMap.valueList addObject:svmxc_client];
    
    [sfmRequest addClientInfo:svmxc_client];
    [datasync setRequest:sfmRequest];
    
    
    binding.logXMLInOut = YES;
    //[[ZKServerSwitchboard switchboard] doCheckSession];
    [binding INTF_DataSync_WSAsyncUsingParameters:datasync 
                                    SessionHeader:sessionHeader 
                                      CallOptions:callOptions
                                  DebuggingHeader:debuggingHeader
                       AllowFieldTruncationHeader:allowFieldTruncationHeader delegate:self];
}

-(void)setLastSyncTime
{
    if(insert_last_sync_time !=  nil)
        [self setsyncHistoryForSyncType:INSERT requestOrResponse:RESPONSE request_id:@"" last_sync_time:insert_last_sync_time];
    
    if(update_last_sync_time != nil)
        [self setsyncHistoryForSyncType:UPDATE requestOrResponse:RESPONSE request_id:@"" last_sync_time:update_last_sync_time];
    
    if(delete_last_sync_time != nil)
         [self setsyncHistoryForSyncType:DELETE  requestOrResponse:RESPONSE request_id:@"" last_sync_time:delete_last_sync_time];
   
    
    //set the last sync time 
    [self  setLastSyncOccured];
}


-(void)setLastSyncOccured
{
    NSString * rootpath_SYNHIST = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * plistPath_SYNHIST = [rootpath_SYNHIST stringByAppendingPathComponent:SYNC_HISTORY];
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath_SYNHIST];
    NSArray * allkeys= [dict allKeys];
    
    //get the current datetime from client side 
    NSDate * current_dateTime = [NSDate date];
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
  /*  NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:gmt];*/
    
    for(NSString *  str in allkeys)
    {
        if([str isEqualToString:LAST_INITIAL_SYNC_IME])
        {
            NSString * last_sync_time = [dateFormatter stringFromDate:current_dateTime];
            [dict  setObject:last_sync_time forKey:LAST_INITIAL_SYNC_IME];
        }
    }
    [dict writeToFile:plistPath_SYNHIST atomically:YES];

}

-(void) Put:(NSString *)event_name
{
    NSString * event_type = @"SYNC";
    [INTF_WebServicesDefServiceSvc initialize];
    
    INTF_WebServicesDefServiceSvc_SessionHeader * sessionHeader = [[[INTF_WebServicesDefServiceSvc_SessionHeader alloc] init] autorelease];
    sessionHeader.sessionId = [[ZKServerSwitchboard switchboard] sessionId];
    
    INTF_WebServicesDefServiceSvc_CallOptions * callOptions = [[[INTF_WebServicesDefServiceSvc_CallOptions alloc] init] autorelease];
    callOptions.client = nil;
    
    INTF_WebServicesDefServiceSvc_DebuggingHeader * debuggingHeader = [[[INTF_WebServicesDefServiceSvc_DebuggingHeader alloc] init] autorelease];
    debuggingHeader.debugLevel = 0;
    
    INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader * allowFieldTruncationHeader = [[[INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader alloc] init] autorelease];
    allowFieldTruncationHeader.allowFieldTruncation = NO;
    
    INTF_WebServicesDefBinding * binding = [INTF_WebServicesDefServiceSvc INTF_WebServicesDefBindingWithServer:appDelegate.currentServerUrl];

    binding.logXMLInOut = YES;
    
    
    INTF_WebServicesDefServiceSvc_INTF_DataSync_WS  * datasync = [[[INTF_WebServicesDefServiceSvc_INTF_DataSync_WS alloc] init] autorelease];
    
    INTF_WebServicesDefServiceSvc_INTF_SFMRequest * sfmRequest = [[[INTF_WebServicesDefServiceSvc_INTF_SFMRequest alloc] init] autorelease];
    sfmRequest.eventName = event_name;
    sfmRequest.eventType = event_type;// @"TX_DATA";
    sfmRequest.userId = [appDelegate.loginResult userId];
    sfmRequest.groupId = [[appDelegate.loginResult userInfo] organizationId];
    sfmRequest.profileId = [[appDelegate.loginResult userInfo] profileId];
    sfmRequest.value = Insert_requestId;
   // event_name = @"PUT_INSERT";
    if([event_name isEqualToString:@"PUT_UPDATE"] && [event_type isEqualToString:@"SYNC"])//PUT_UPSATE
    {
        
      INTF_WebServicesDefServiceSvc_SVMXMap * SVMXCMap_lastModified =  [[[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init]  autorelease];
        SVMXCMap_lastModified.key = @"SYNC_TIME_STAMP";
        SVMXCMap_lastModified.value = [self get_SYNCHISTORYTime_ForKey:LAST_UPDATE_RESONSE_TIME] == nil ?@"":[self get_SYNCHISTORYTime_ForKey:LAST_UPDATE_RESONSE_TIME];
        
        [sfmRequest.valueMap addObject:SVMXCMap_lastModified];
        
        NSArray * all_objects = [appDelegate.dataSync_dict allKeys];
        NSMutableArray * record_id_list = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
        
        for(int i = 0 ; i < [all_objects count]; i++)
        {
            
            NSString * object_name = [all_objects objectAtIndex:i] ;
            //find the type of the object name 
            
            // BOOL MasterObject = FALSE ;
            
            INTF_WebServicesDefServiceSvc_SVMXMap  * svmxcmap = [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
            
           // NSString * Master_or_parent = @"";
           // svmxcmap.key = @"object_name" ;
           
            
            NSMutableArray * info_dict = [appDelegate.dataSync_dict objectForKey:object_name];
            
            // get all the fields from the table 
            // query object for the id put in in list map
            
            NSDictionary * fields_dict = [appDelegate.databaseInterface getAllObjectFields:object_name tableName:SFOBJECTFIELD];
            NSArray * fields_array ; 
            fields_array = [fields_dict allKeys];

            NSString * field_string = @"";
            for(int i = 0 ; i< [fields_array count]; i++)
            {
                NSString * field = [fields_array objectAtIndex:i];
                if (i == 0)
                    field_string = [field_string stringByAppendingFormat:@"%@",field];
                else
                    field_string = [field_string stringByAppendingFormat:@",%@",field];
            }
            
    
            // ADD   FIELDS  method
            INTF_WebServicesDefServiceSvc_SVMXMap  * record_svmxc  = [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
            
            record_svmxc.key = @"Fields";
            record_svmxc.value = field_string;
            
            BOOL value_map_count = 0;

            for (NSDictionary * dict in info_dict) 
            {
                NSArray * keys = [dict allKeys];
                
                NSString * local_id = @"";
                NSString * parent_object_name = @"";
                NSString * parent_local_id = @"";
                NSString * time_stamp = @"";
                NSString * record_type = @"";
                NSString * sf_id = @"";
                NSString * override_flag = @"";
                for (int j = 0; j < [keys count]; j++)
                {
                    NSString * key = [keys objectAtIndex:j];
                    
                    if([key isEqualToString:@"local_id"])
                    {
                        local_id = [dict objectForKey:key];
                    }
                    if([key isEqualToString:@"parent_object_name"])
                    {
                        parent_object_name = [dict objectForKey:@"parent_object_name"];
                    }
                    if([key isEqualToString:@"parent_local_id"])
                    {
                        parent_local_id = [dict objectForKey:@"parent_local_id"];
                    }
                    if([key isEqualToString:@"time_stamp"])
                    {
                        time_stamp = [dict objectForKey:@"time_stamp"];
                    }
                    if([key isEqualToString:@"record_type"])
                    {
                        record_type = [dict objectForKey:@"record_type"];
                       // Master_or_parent = record_type;
                    }
                    if([key isEqualToString:@"sf_id"])
                    {
                        sf_id = [dict objectForKey:@"sf_id"];
                    }
                    if([key isEqualToString:@"override_flag"])
                    {
                        override_flag = [dict objectForKey:@"override_flag"];
                    }
                    
                }
               
                
                INTF_WebServicesDefServiceSvc_SVMXMap * testSVMXCMap =  [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
                
                if([record_type isEqualToString:DETAIL] || [record_type isEqualToString:MASTER])
                {
                    
                    if(appDelegate.speacialSyncIsGoingOn)
                    {
                        if([sf_id length] == 0)
                        {
                            
                            continue;
                        }
                    }
                    else
                    {
                        //check for id 
                        NSString * child_sf_id  = [appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:object_name local_id:local_id];
                        
                        if([child_sf_id length] == 0)
                        {
                            [appDelegate.databaseInterface DeleterecordFromTable:SFDATATRAILER Forlocal_id:local_id];
                            continue;
                        }
                    }
                }
                
                if(appDelegate.speacialSyncIsGoingOn)
                {
                    if([local_id length] == 0)
                        local_id =  [appDelegate.databaseInterface getLocalIdFromSFId:sf_id  tableName:object_name];
                }
                        
                NSMutableDictionary * each_record = [appDelegate.databaseInterface getRecordsForRecordId:local_id  ForObjectName:object_name fields:field_string];        
                if([record_type isEqualToString:DETAIL])
                {
                    NSString * parent_SF_Id = @"";
                    NSString * parent_column_name = @"";
  
                    if(appDelegate.speacialSyncIsGoingOn)
                    {
                        parent_object_name = [appDelegate.databaseInterface getchildInfoFromChildRelationShip:SFCHILDRELATIONSHIP ForChild:object_name field_name:@"parent_name"];
                        
                        NSString * parent_column_name = [appDelegate.databaseInterface getchildInfoFromChildRelationShip:SFCHILDRELATIONSHIP ForChild:object_name field_name:@"parent_column_name"];
                        
                        parent_local_id = [appDelegate.databaseInterface getParentIdFrom:object_name WithId:local_id andParentColumnName:parent_column_name id_type:@"local_id"];
                    }
                    parent_column_name = [appDelegate.databaseInterface  getParentColumnNameFormChildInfoTable:SFChildRelationShip childApiName:object_name parentApiName:parent_object_name];
                    //update the parent local id to the child record
                    //Get  SF_id From parent object for the local_id  search in heap table and  alson search in  
                    
                    NSString * Parent_SF_ID_from_object_table = @"" ,* Parent_SF_ID_from_heap_table = @"";
                    Parent_SF_ID_from_object_table = [appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:parent_object_name local_id:parent_local_id];
                    
                    Parent_SF_ID_from_heap_table = [appDelegate.databaseInterface getSfid_For_LocalId_FROM_SfHeapTable:parent_local_id];
                    if(![Parent_SF_ID_from_object_table isEqualToString:@""])
                    {
                        parent_SF_Id = Parent_SF_ID_from_object_table;
                    }
                    else if (![Parent_SF_ID_from_heap_table isEqualToString:@""] && [ parent_SF_Id isEqualToString:@""])
                    {
                        parent_SF_Id = Parent_SF_ID_from_heap_table;
                    }
                    
                    NSArray * all_keys = [each_record allKeys];
                    
                    SMLog(@"parent local id %@  parent sf id %@ " , parent_local_id , parent_SF_Id);
                    for(NSString * str in all_keys)
                    {
                        if([str isEqualToString:parent_column_name])
                        {
                            [each_record setValue:parent_SF_Id  forKey:parent_column_name];
                        }
                    }
                }
                
                
                //check for the local_id in the record_list 
                
                BOOL check_id_exists = FALSE;
                
                if(appDelegate.speacialSyncIsGoingOn)
                {
                    for(NSString * id_ in record_id_list)
                    {
                        if([id_ isEqualToString:sf_id])
                        {
                            check_id_exists = TRUE;
                        }
                    }
                }
                else
                {
                    for(NSString * id_ in record_id_list)
                    {
                        if([id_ isEqualToString:local_id])
                        {
                            check_id_exists = TRUE;
                        }
                    }
                }
                
                if(!check_id_exists)
                {
                   
                    jsonWriter = [[SBJsonWriter alloc] init];
                    
                    NSString * json_record= [ jsonWriter stringWithObject:each_record ];
                    if([override_flag isEqualToString:CLIENT_OVERRIDE])
                    {
                        testSVMXCMap.key = @"CLIENT_OVERRIDE";
                    }
                    else 
                    {
                        testSVMXCMap.key = time_stamp;
                    }
                    
                    testSVMXCMap.value = json_record;
                    
                    if(appDelegate.speacialSyncIsGoingOn)
                    {
                        [record_id_list addObject:sf_id];
                    }
                    else
                    {
                        [record_id_list addObject:local_id];
                    }
                    
                    [record_svmxc.valueMap addObject:testSVMXCMap];
                    value_map_count++;
                    
                }
                
                if(appDelegate.speacialSyncIsGoingOn)
                {
                    [appDelegate.databaseInterface deleterecordsFromConflictTableForOperationType:PUT_UPDATE overrideFlag:override_flag table_name:SYNC_ERROR_CONFLICT id_value:sf_id field_name:@"sf_id"];
                }
                
            }
            
          /* // code to differentiate b/w the parent and child 
           
           if([Master_or_parent isEqualToString:MASTER])
            {
                svmxcmap.key = @"Parent_Object";
            }
            else if([Master_or_parent isEqualToString:DETAIL])
            {
                svmxcmap.key = @"Child_Object";
            }

            //assign key is whether master or detail
            svmxcmap.value = object_name; //object  api name */
            
            
             svmxcmap.key = @"Object_Name";
             svmxcmap.value = object_name;
            
            //ISCALLBACK   method
            INTF_WebServicesDefServiceSvc_SVMXMap  * iscallBack = [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
            iscallBack.key = @"IS_CALLBACK";
            iscallBack.value = @"YES";
            
            //SYNC_TIMESTAMP  
            INTF_WebServicesDefServiceSvc_SVMXMap * timestap = [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
            timestap.key = @"SYNC_TIMESTAMP";
            timestap.value = @"";
            
            if(value_map_count !=0)
            {
                [svmxcmap.valueMap addObject:record_svmxc];
                [svmxcmap.valueMap addObject:iscallBack];
                [sfmRequest.valueMap addObject:svmxcmap];
            }
            [record_svmxc release];
            [iscallBack release];
            [svmxcmap release];
            
        }
        
    }

   else if([event_name isEqualToString:@"PUT_INSERT"] && [event_type isEqualToString:@"SYNC"])
   {
        
        NSArray * masterObjects = [appDelegate.databaseInterface getAllObjectsForRecordType:MASTER  forOperation:INSERT];
        NSArray * detailObjects = [appDelegate.databaseInterface getAllObjectsForRecordType:DETAIL forOperation:INSERT];
        NSMutableArray * masterDetailArray = [[NSMutableArray alloc] initWithObjects:masterObjects,detailObjects, nil];
        
        //put all the parent information  "Parent_Object"
        NSArray * all_objects = [appDelegate.dataSync_dict allKeys];
        
        NSInteger count = 0;
        
        INTF_WebServicesDefServiceSvc_SVMXMap * SVMXCMap_lastModified =  [[[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init] autorelease];         //sahana30April
        SVMXCMap_lastModified.key = @"SYNC_TIME_STAMP";
        SVMXCMap_lastModified.value = [self get_SYNCHISTORYTime_ForKey:LAST_INSERT_RESONSE_TIME] == nil ?@"":[self get_SYNCHISTORYTime_ForKey:LAST_INSERT_RESONSE_TIME];
        
        INTF_WebServicesDefServiceSvc_SVMXMap * SVMXCMap_startTime =  [[[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init] autorelease];            //sahana30April
        SVMXCMap_startTime.key  = @"RANGE_START";
        SVMXCMap_startTime.value = [self getSyncTimeStampWithTheIntervalof15days:START_TIME] == nil ? @"" :[self getSyncTimeStampWithTheIntervalof15days:START_TIME];
        
        INTF_WebServicesDefServiceSvc_SVMXMap * SVMXCMap_endTime =  [[[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init] autorelease];               //sahana30April
        SVMXCMap_endTime.key  = @"RANGE_END";
        SVMXCMap_endTime.value = [self getSyncTimeStampWithTheIntervalof15days:END_TIME]== nil ? @"" :[self getSyncTimeStampWithTheIntervalof15days:END_TIME];
        
        [sfmRequest.valueMap addObject:SVMXCMap_lastModified];
        
        for(int temp = 0; temp < 2 && count < CHUNCKING_LIMIT ; temp ++)
        {
            NSArray * tempArray = [masterDetailArray objectAtIndex:temp];
            
            NSString * key = @"";
            if(temp == 0)
            {
                key = @"Parent_Object";
            }
            else
            {
                key = @"Child_Object";
            }
            for(int x = 0 ; x < [tempArray count] && count < CHUNCKING_LIMIT ;x++)
            {
                
                NSString * tempMasterOrDetail = [tempArray objectAtIndex:x];
                for(int i = 0 ; i < [all_objects count] && count < CHUNCKING_LIMIT ; i++)
                {
                    NSString * object_name = [all_objects objectAtIndex:i] ;
                    //find the type of the object name 
                    
                    // BOOL MasterObject = FALSE ;
                    if([tempMasterOrDetail isEqualToString:object_name])
                    {
                        INTF_WebServicesDefServiceSvc_SVMXMap  * svmxcmap = [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
                        
                        svmxcmap.key = key ;
                        svmxcmap.value = object_name; //object  api name 
                        
                        NSMutableArray *  info_dict = [appDelegate.dataSync_dict objectForKey:object_name];
                        
                        // get all the fields from the table 
                        // query object for the id put in in list map
                        
                        NSDictionary * fields_dict = [appDelegate.databaseInterface getAllObjectFields:object_name tableName:SFOBJECTFIELD];
                        NSArray * fields_array ; 
                                                fields_array = [fields_dict allKeys];
                        NSString * field_string = @"";
                        for(int i = 0 ; i< [fields_array count]; i++)
                        {
                            NSString * field = [fields_array objectAtIndex:i];
                            if (i == 0)
                                field_string = [field_string stringByAppendingFormat:@"%@",field];
                            else
                                field_string = [field_string stringByAppendingFormat:@",%@",field];
                        }
                        
                        // ADD   FIELDS  method
                        INTF_WebServicesDefServiceSvc_SVMXMap  * record_svmxc  = [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
                        
                        record_svmxc.key = @"Fields";
                        record_svmxc.value = field_string;
                        
                        for (NSDictionary * dict in info_dict) 
                        {
                            if(count > CHUNCKING_LIMIT)
                            {
                                break;
                            }
                            
                            NSArray * keys = [dict allKeys];
                            
                            NSString * local_id = @"";
                            NSString * parent_object_name = @"";
                            NSString * parent_local_id = @"";
                            for (int j = 0; j < [keys count]; j++)
                            {
                                NSString * key = [keys objectAtIndex:j];
                                
                                if([key isEqualToString:@"local_id"])
                                {
                                    local_id = [dict objectForKey:key];
                                }
                                if([key isEqualToString:@"parent_object_name"])
                                {
                                    parent_object_name = [dict objectForKey:@"parent_object_name"];
                                }
                                if([key isEqualToString:@"parent_local_id"])
                                {
                                    parent_local_id = [dict objectForKey:@"parent_local_id"];
                                }
                            }
                            
                            INTF_WebServicesDefServiceSvc_SVMXMap * testSVMXCMap =  [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
                            
                            NSMutableDictionary * each_record = [appDelegate.databaseInterface getRecordsForRecordId:local_id  ForObjectName:object_name fields:field_string];
                            
                            if([key isEqualToString:@"Child_Object"])
                            {
                                if(appDelegate.speacialSyncIsGoingOn)
                                {
                                    parent_object_name = [appDelegate.databaseInterface getchildInfoFromChildRelationShip:SFCHILDRELATIONSHIP ForChild:object_name field_name:@"parent_name"];
                                    
                                    NSString * parent_column_name = [appDelegate.databaseInterface getchildInfoFromChildRelationShip:SFCHILDRELATIONSHIP ForChild:object_name field_name:@"parent_column_name"];
                                    
                                    parent_local_id = [appDelegate.databaseInterface getParentIdFrom:object_name WithId:local_id andParentColumnName:parent_column_name id_type:@"local_id"];
                                }
                                    
                                NSString *  Parent_SF_ID_from_object_table = [appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:parent_object_name local_id:parent_local_id];
                                if([Parent_SF_ID_from_object_table isEqualToString:@""])
                                {
                                    Parent_SF_ID_from_object_table = parent_local_id;
                                }
                                
                                NSString * parent_column_name = @"";
                                parent_column_name = [appDelegate.databaseInterface  getParentColumnNameFormChildInfoTable:SFChildRelationShip childApiName:object_name parentApiName:parent_object_name];
                                
                                NSArray * allKeys_child = [each_record allKeys];
                                
                                //find parent column Name 
                                for(NSString * parent_key in allKeys_child)
                                {
                                    if([parent_key isEqualToString:parent_column_name])
                                    {
                                        [each_record setValue:Parent_SF_ID_from_object_table forKey:parent_column_name];
                                    }
                                }
                                
                            }
                            
                            jsonWriter = [[SBJsonWriter alloc] init];
                            
                            NSString * json_record = [jsonWriter stringWithObject:each_record];
                            testSVMXCMap.key = local_id;
                            testSVMXCMap.value = json_record;
                            
                            [record_svmxc.valueMap addObject:testSVMXCMap];
                            
                            count ++;
                            
                            //update record is being sent 
                            [appDelegate.databaseInterface updateDataTrailer_RecordSentForlocalId:local_id operation_type:INSERT];
                            
                            if(appDelegate.speacialSyncIsGoingOn)
                            {
                                [appDelegate.databaseInterface deleterecordsFromConflictTableForOperationType:PUT_INSERT overrideFlag:RETRY table_name:SYNC_ERROR_CONFLICT id_value:local_id field_name:@"local_id"];
                            }
                            
                        }
                        
                        //ISCALLBACK   method
                        INTF_WebServicesDefServiceSvc_SVMXMap  * iscallBack = [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
                        iscallBack.key = @"IS_CALLBACK";
                        iscallBack.value = @"YES";
                        
                        //SYNC_TIMESTAMP  
                        INTF_WebServicesDefServiceSvc_SVMXMap * timestap = [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
                        timestap.key = @"SYNC_TIMESTAMP";
                        timestap.value = @"";
                        
                        [svmxcmap.valueMap addObject:record_svmxc];
                        [svmxcmap.valueMap addObject:iscallBack];
                        
                        [sfmRequest.valueMap addObject:svmxcmap];
                        
                        [record_svmxc release];  //sahana30April
                        [timestap release];      //sahana30April
                        [svmxcmap release];        //sahana30April
                        break;
                    }
                    
                }
                
            }
        }
        
        [masterDetailArray release];    //sahana30April
    }
    else if ([event_name isEqualToString:@"PUT_DELETE"] && [event_type isEqualToString:@"SYNC"])
    {
        INTF_WebServicesDefServiceSvc_SVMXMap * SVMXCMap_lastModified =  [[[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init] autorelease];
        SVMXCMap_lastModified.key = @"SYNC_TIME_STAMP";
        SVMXCMap_lastModified.value = [self get_SYNCHISTORYTime_ForKey:LAST_DELETE_RESPONSE_TIME] == nil ?@"":[self get_SYNCHISTORYTime_ForKey:LAST_DELETE_RESPONSE_TIME];
        [sfmRequest.valueMap addObject:SVMXCMap_lastModified];
        
        
        NSArray * all_objects = [appDelegate.dataSync_dict allKeys];
        
        for(int i = 0 ; i < [all_objects count]; i++)
        {
            
            NSString * object_name = [all_objects objectAtIndex:i] ;
            //find the type of the object name 
            
            // BOOL MasterObject = FALSE ;
            
            INTF_WebServicesDefServiceSvc_SVMXMap  * svmxcmap = [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
            
            // NSString * Master_or_parent = @"";
            svmxcmap.key = @"object_name" ;
            svmxcmap.value = object_name;
            
            NSMutableArray *  info_dict = [appDelegate.dataSync_dict objectForKey:object_name];
            
            
            // get all the fields from the table 
            // query object for the id put in in list map
            
            // ADD   FIELDS  method
            INTF_WebServicesDefServiceSvc_SVMXMap  * record_svmxc  = [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
            
            record_svmxc.key = @"Fields";
            record_svmxc.value = @"";
            
            for (NSDictionary * dict in info_dict) 
            {
                NSArray * keys = [dict allKeys];
                
                NSString * local_id = @"";
                NSString * parent_object_name = @"";
                NSString * parent_local_id = @"";
                NSString * time_stamp = @"";
                NSString * record_type = @"";
                for (int j = 0; j < [keys count]; j++)
                {
                    NSString * key = [keys objectAtIndex:j];
                    
                    if([key isEqualToString:@"local_id"])
                    {
                        local_id = [dict objectForKey:key];
                    }
                    if([key isEqualToString:@"parent_object_name"])
                    {
                        parent_object_name = [dict objectForKey:@"parent_object_name"];
                    }
                    if([key isEqualToString:@"parent_local_id"])
                    {
                        parent_local_id = [dict objectForKey:@"parent_local_id"];
                    }
                    if([key isEqualToString:@"time_stamp"])
                    {
                        time_stamp = [dict objectForKey:@"time_stamp"];
                    }
                    if([key isEqualToString:@"record_type"])
                    {
                        record_type = [dict objectForKey:@"record_type"];
                        // Master_or_parent = record_type;
                    }
                }
                
                
                INTF_WebServicesDefServiceSvc_SVMXMap * testSVMXCMap =  [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
                
                testSVMXCMap.key = @"";
                NSString * sf_id = [appDelegate.databaseInterface getSfid_For_LocalId_From_TrailerForlocal_id:local_id];
				//Check the change
				if ( sf_id == nil || [sf_id isEqualToString:@""])
				{
					sf_id = [[info_dict objectAtIndex:0] valueForKey:@"sf_id"];
				}
                testSVMXCMap.value = sf_id;
				
                [record_svmxc.valueMap addObject:testSVMXCMap];
                [testSVMXCMap release];
                
                if(appDelegate.speacialSyncIsGoingOn)
                {
                    [appDelegate.databaseInterface deleterecordsFromConflictTableForOperationType:PUT_DELETE overrideFlag:RETRY table_name:SYNC_ERROR_CONFLICT id_value:sf_id field_name:@"sf_id"];
                }
                
            }
            
            
            svmxcmap.key = @"Object_Name";
            svmxcmap.value = object_name;
            
            //ISCALLBACK   method
            INTF_WebServicesDefServiceSvc_SVMXMap  * iscallBack = [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
            iscallBack.key = @"IS_CALLBACK";
            iscallBack.value = @"YES";
            
            //SYNC_TIMESTAMP  
            INTF_WebServicesDefServiceSvc_SVMXMap * timestap = [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
            timestap.key = @"SYNC_TIMESTAMP";
            timestap.value = @"";
            
            [svmxcmap.valueMap addObject:record_svmxc];
            [svmxcmap.valueMap addObject:iscallBack];
            
            
            [sfmRequest.valueMap addObject:svmxcmap];
            
            
            [svmxcmap release];
            [record_svmxc release];
            [iscallBack release];
        }
        
    }
        //ADD SVMXClient
   INTF_WebServicesDefServiceSvc_SVMXClient  * svmxc_client = [[[INTF_WebServicesDefServiceSvc_SVMXClient alloc] init]  autorelease];
    
    svmxc_client.clientType = @"iPad";
    [svmxc_client.clientInfo addObject:@"OS:iPadOS"];
    [svmxc_client.clientInfo addObject:@"R4B2"];
    //[client_listMap.valueList addObject:svmxc_client];
    
    [sfmRequest addClientInfo:svmxc_client];
    [datasync setRequest:sfmRequest];
    
    
    binding.logXMLInOut = YES;
    
    //[[ZKServerSwitchboard switchboard] doCheckSession];
    
    [binding INTF_DataSync_WSAsyncUsingParameters:datasync 
                                    SessionHeader:sessionHeader 
                                      CallOptions:callOptions
                                  DebuggingHeader:debuggingHeader
                       AllowFieldTruncationHeader:allowFieldTruncationHeader delegate:self]; 
}

#pragma mark - ServiceMax Version check method
- (void) getSvmxVersion
{    
    [INTF_WebServicesDefServiceSvc initialize];
    INTF_WebServicesDefServiceSvc_SessionHeader * session = [[[INTF_WebServicesDefServiceSvc_SessionHeader alloc] init] autorelease];
    session.sessionId = [[ZKServerSwitchboard switchboard] sessionId];
    
    INTF_WebServicesDefServiceSvc_CallOptions * callOptions = [[[INTF_WebServicesDefServiceSvc_CallOptions alloc] init] autorelease];
    callOptions.client = nil;
    
    INTF_WebServicesDefServiceSvc_DebuggingHeader * debuggingHeader = [[[INTF_WebServicesDefServiceSvc_DebuggingHeader alloc] init] autorelease];
    debuggingHeader.debugLevel = 0;
    
    INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader * allowFieldTruncationHeader = [[[INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader alloc] init] autorelease];
    allowFieldTruncationHeader.allowFieldTruncation = NO;
    
    INTF_WebServicesDefServiceSvc_SVMX_GetSvmxVersion * getVersion = [[[INTF_WebServicesDefServiceSvc_SVMX_GetSvmxVersion alloc] init] autorelease];
    //getVersion.prequest = 
    
    INTF_WebServicesDefBinding * binding = [INTF_WebServicesDefServiceSvc 
                                                            INTF_WebServicesDefBindingWithServer:appDelegate.currentServerUrl];
    
    KeyValue_KeyValue * keyvalue = [[[KeyValue_KeyValue alloc] init] autorelease];
    keyvalue.value = nil;
    keyvalue.name = nil;
    [getVersion.prequest addObject:keyvalue];
    
    binding.logXMLInOut = YES;

    //[[ZKServerSwitchboard switchboard] doCheckSession];
    [binding SVMX_GetSvmxVersionAsyncUsingParameters:getVersion
                                       SessionHeader:session
                                         CallOptions:callOptions
                                     DebuggingHeader:debuggingHeader
                          AllowFieldTruncationHeader:allowFieldTruncationHeader
                                            delegate:self];
    
}


#pragma mark - Metasync

- (void) metaSyncWithEventName:(NSString *)eventName eventType:(NSString *)eventType values:(NSMutableArray *)values
{
    
    [INTF_WebServicesDefServiceSvc initialize];
    
    INTF_WebServicesDefServiceSvc_SessionHeader * session = [[[INTF_WebServicesDefServiceSvc_SessionHeader alloc] init] autorelease];
    session.sessionId = [[ZKServerSwitchboard switchboard] sessionId];
    
    INTF_WebServicesDefServiceSvc_CallOptions * callOptions = [[[INTF_WebServicesDefServiceSvc_CallOptions alloc] init] autorelease];
    callOptions.client = nil;
    
    INTF_WebServicesDefServiceSvc_DebuggingHeader * debuggingHeader = [[[INTF_WebServicesDefServiceSvc_DebuggingHeader alloc] init] autorelease];
    debuggingHeader.debugLevel = 0;
    
    INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader * allowFieldTruncationHeader = [[[INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader alloc] init] autorelease];
    allowFieldTruncationHeader.allowFieldTruncation = NO;
    
    INTF_WebServicesDefBinding * binding = [INTF_WebServicesDefServiceSvc INTF_WebServicesDefBindingWithServer:appDelegate.currentServerUrl];
    binding.logXMLInOut = YES;
    
    INTF_WebServicesDefServiceSvc_INTF_MetaSync_WS * metaSync = [[[INTF_WebServicesDefServiceSvc_INTF_MetaSync_WS alloc] init] autorelease];
    
    INTF_WebServicesDefServiceSvc_INTF_SFMRequest * sfmRequest = [[[INTF_WebServicesDefServiceSvc_INTF_SFMRequest alloc] init] autorelease];
    
    
    INTF_WebServicesDefServiceSvc_SVMXMap * svmxMap = [[[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init] autorelease];
    svmxMap = NULL;
    
    INTF_WebServicesDefServiceSvc_SVMXClient * client = [[[INTF_WebServicesDefServiceSvc_SVMXClient alloc] init] autorelease];
    
    
    if ([eventName isEqualToString:SFM_METADATA] && [eventType isEqualToString:SYNC])
    {
        sfmRequest.value = [values objectAtIndex:0];
        [sfmRequest.values addObjectsFromArray:nil];
    }
    
    else if ([eventName isEqualToString:MOBILE_DEVICE_TAGS] || [eventName isEqualToString:MOBILE_DEVICE_SETTINGS])
    {
        client = NULL;
        sfmRequest.value = @"";
        [sfmRequest.values addObjectsFromArray:values];
    }
    
    else
    {
        client.clientType = @"iPad";
        [client.clientInfo addObject:@"OS:iPadOS"];
        [client.clientInfo addObject:@"R4B2"];
        sfmRequest.value = @"";
        [sfmRequest.values addObjectsFromArray:values];
    }
    
    
    
    sfmRequest.eventName = eventName;
    sfmRequest.eventType = eventType;
    sfmRequest.userId = [appDelegate.loginResult userId];
    sfmRequest.groupId = [[appDelegate.loginResult userInfo] organizationId];
    sfmRequest.profileId = [[appDelegate.loginResult userInfo] profileId];
    sfmRequest.name = @"";
    [sfmRequest addValueMap:svmxMap];
    

    [sfmRequest addClientInfo:client];
    if ([eventName isEqualToString:SFW_METADATA]) 
    {
        INTF_WebServicesDefServiceSvc_SVMXClient * client_iPad_Version = [[[INTF_WebServicesDefServiceSvc_SVMXClient alloc] init] autorelease];
        client_iPad_Version.clientType = @"iPad_Version";
        NSString *iPadVersion = [[self getClientVersionString] retain];
        [client_iPad_Version.clientInfo addObject:iPadVersion];
        [sfmRequest addClientInfo:client_iPad_Version];
        [iPadVersion release];
    }

    [metaSync setRequest:sfmRequest];  
    
    //[[ZKServerSwitchboard switchboard] doCheckSession];
    [binding INTF_MetaSync_WSAsyncUsingParameters:metaSync 
                                    SessionHeader:session 
                                      CallOptions:callOptions 
                                  DebuggingHeader:debuggingHeader 
                       AllowFieldTruncationHeader:allowFieldTruncationHeader 
                                         delegate:self];
    
}

#pragma mark DataSync
- (void) dataSyncWithEventName:(NSString *)eventName eventType:(NSString *)eventType values:(NSMutableArray *)values
{
    [INTF_WebServicesDefServiceSvc initialize];
    
    INTF_WebServicesDefServiceSvc_SessionHeader * sessionHeader = [[[INTF_WebServicesDefServiceSvc_SessionHeader alloc] init] autorelease];
    sessionHeader.sessionId = [[ZKServerSwitchboard switchboard] sessionId];
    
    INTF_WebServicesDefServiceSvc_CallOptions * callOptions = [[[INTF_WebServicesDefServiceSvc_CallOptions alloc] init] autorelease];
    callOptions.client = nil;
    
    INTF_WebServicesDefServiceSvc_DebuggingHeader * debuggingHeader = [[[INTF_WebServicesDefServiceSvc_DebuggingHeader alloc] init] autorelease];
    debuggingHeader.debugLevel = 0;
    
    INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader * allowFieldTruncationHeader = [[[INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader alloc] init] autorelease];
    allowFieldTruncationHeader.allowFieldTruncation = NO;
    
    INTF_WebServicesDefBinding * binding = [INTF_WebServicesDefServiceSvc INTF_WebServicesDefBindingWithServer:appDelegate.currentServerUrl];
    binding.logXMLInOut = YES;
    
    
    INTF_WebServicesDefServiceSvc_INTF_DataSync_WS * dataSync = [[[INTF_WebServicesDefServiceSvc_INTF_DataSync_WS alloc] init] 
                                                                 autorelease];
    
    INTF_WebServicesDefServiceSvc_INTF_SFMRequest * sfmRequest = [[[INTF_WebServicesDefServiceSvc_INTF_SFMRequest alloc] init] 
                                                                  autorelease];
    
    INTF_WebServicesDefServiceSvc_SVMXClient * client = [[[INTF_WebServicesDefServiceSvc_SVMXClient alloc] init] autorelease];
    
    INTF_WebServicesDefServiceSvc_SVMXMap * SVMXCMap_startTime =  [[[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init] autorelease];
    SVMXCMap_startTime.key  = @"RANGE_START";
    SVMXCMap_startTime.value = [self getSyncTimeStampWithTheIntervalof15days:START_TIME] == nil?@"":[self getSyncTimeStampWithTheIntervalof15days:START_TIME];
    
    INTF_WebServicesDefServiceSvc_SVMXMap * SVMXCMap_endTime =  [[[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init] autorelease];
    SVMXCMap_endTime.key  = @"RANGE_END";
    SVMXCMap_endTime.value = [self getSyncTimeStampWithTheIntervalof15days:END_TIME]== nil?@"":[self getSyncTimeStampWithTheIntervalof15days:END_TIME];
    
    [sfmRequest.valueMap addObject:SVMXCMap_startTime];
    [sfmRequest.valueMap addObject:SVMXCMap_endTime];
    
    client.clientType = @"iPad";
    [client.clientInfo addObject:@"OS:iPadOS"];
    [client.clientInfo addObject:@"R4B2"];
    
    sfmRequest.eventName = eventName;
    sfmRequest.eventType = eventType;
    
    sfmRequest.userId = [appDelegate.loginResult userId];
    sfmRequest.groupId = [[appDelegate.loginResult userInfo] organizationId];
    sfmRequest.profileId = [[appDelegate.loginResult userInfo] profileId];
    
    [sfmRequest addClientInfo:client];
    //SFM Search
    if([eventName isEqualToString:@"SFM_SEARCH"] && [eventType isEqualToString:@"SEARCH_RESULTS"])
    {
        INTF_WebServicesDefServiceSvc_SVMXMap * svmxcProcessID =  [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
        svmxcProcessID.key  = @"SearchProcessId";
        if([values objectAtIndex:0] != nil)
            svmxcProcessID.value = [values objectAtIndex:0];
        else
            svmxcProcessID.value = @"";
        [sfmRequest.valueMap addObject:svmxcProcessID];
        [svmxcProcessID release];
        
        INTF_WebServicesDefServiceSvc_SVMXMap * svmxcCrtieria =  [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
        svmxcCrtieria.key  = @"SEARCH_OPERATOR";
        if([values objectAtIndex:3] != nil)
            svmxcCrtieria.value = [values objectAtIndex:3];
        else
            svmxcCrtieria.value = @"";
        [sfmRequest.valueMap addObject:svmxcCrtieria];
        [svmxcCrtieria release];
        
        INTF_WebServicesDefServiceSvc_SVMXMap * svmxcUserFilterString =  [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
        svmxcUserFilterString.key  = @"KeyWord";
        if([values objectAtIndex:4] != nil)
            svmxcUserFilterString.value = [values objectAtIndex:4];
        else
            svmxcUserFilterString.value = @"";
        [sfmRequest.valueMap addObject:svmxcUserFilterString];
        [svmxcUserFilterString release];
        
        NSArray *objectList = [values objectAtIndex:1];
        for(int i=0; i<[objectList count]; i++)
        {
            INTF_WebServicesDefServiceSvc_SVMXMap * svmxcObject =  [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
            
            svmxcObject.key  = @"ObjectId";
            svmxcObject.value = [objectList objectAtIndex:i];
            /*
            for(int j=0; j< [resultsArray count]; j++)
            {
                [svmxcObject addValues:[resultsArray objectAtIndex:j]];
            }
             */
            [sfmRequest.valueMap addObject:svmxcObject];            
            [svmxcObject release];
        }
         
        NSString *limit = [values objectAtIndex:2];
        INTF_WebServicesDefServiceSvc_SVMXMap * svmxcLimitObject =  [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
        
        svmxcLimitObject.key  = @"RecordLimit";
        svmxcLimitObject.value = limit;
        [sfmRequest.valueMap addObject:svmxcLimitObject];
        [svmxcLimitObject release];
        
    }
    if([eventName isEqualToString:@"TECH_LOCATION_UPDATE"] && [eventType isEqualToString:SYNC])
    {
        INTF_WebServicesDefServiceSvc_SVMXMap * svmxcField =  [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
        svmxcField.key=@"Fields";
        svmxcField.value=@"";
        INTF_WebServicesDefServiceSvc_SVMXMap * svmxcLatitude =  [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
        svmxcLatitude.key  = @"SVMXC__Latitude__c";
        if([values objectAtIndex:0] != nil)
            svmxcLatitude.value = [values objectAtIndex:0];
        else
            svmxcLatitude.value = @"";
        [svmxcField.valueMap addObject:svmxcLatitude];
        [svmxcLatitude release];
        
        INTF_WebServicesDefServiceSvc_SVMXMap * svmxcLongitude =  [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
        svmxcLongitude.key  = @"SVMXC__Longitude__c";
        if([values objectAtIndex:1] != nil)
            svmxcLongitude.value = [values objectAtIndex:1];
        else
            svmxcLongitude.value = @"";
        [svmxcField.valueMap addObject:svmxcLongitude];
        [svmxcLongitude release];
        [sfmRequest.valueMap addObject:svmxcField];
        [svmxcField release];
        [appDelegate.dataBase setDidTechnicianLocationUpdated:TRUE];

    }
    else if([eventName isEqualToString:@"LOCATION_HISTORY"] && [eventType isEqualToString:SYNC])
    {
        [[ZKServerSwitchboard switchboard] setLogXMLInOut:YES];
        for(NSDictionary *dict in values)
        {
            INTF_WebServicesDefServiceSvc_SVMXMap * svmxcField =  [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
            svmxcField.key=@"Record";
            svmxcField.value=@"";
            INTF_WebServicesDefServiceSvc_SVMXMap * svmxcLocalID =  [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
            svmxcLocalID.key  = @"localId";
            svmxcLocalID.value = [dict objectForKey:@"localId"];
            [svmxcField.valueMap addObject:svmxcLocalID];
            [svmxcLocalID release];

            INTF_WebServicesDefServiceSvc_SVMXMap * svmxcLatitude =  [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
            svmxcLatitude.key  = @"SVMXC__Latitude__c";
            NSString *latitude = [dict objectForKey:@"SVMXC__Latitude__c"];
            if(latitude != nil)
                svmxcLatitude.value = latitude;
            else
                svmxcLatitude.value = @"";

            [svmxcField.valueMap addObject:svmxcLatitude];
            [svmxcLatitude release];
            
            INTF_WebServicesDefServiceSvc_SVMXMap * svmxcLongitude =  [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
            svmxcLongitude.key  = @"SVMXC__Longitude__c";
            NSString *longitude = [dict objectForKey:@"SVMXC__Longitude__c"];
            if(longitude != nil)
                svmxcLongitude.value = longitude;
            else
                svmxcLongitude.value = @"";
            [svmxcField.valueMap addObject:svmxcLongitude];
            [svmxcLongitude release];

            INTF_WebServicesDefServiceSvc_SVMXMap * svmxcStatus =  [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
            svmxcStatus.key  = @"SVMXC__Status__c";
            svmxcStatus.value = [dict objectForKey:@"SVMXC__Status__c"];
            [svmxcField.valueMap addObject:svmxcStatus];
            [svmxcStatus release];

            INTF_WebServicesDefServiceSvc_SVMXMap * svmxcUser =  [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
            svmxcUser.key  = @"SVMXC__User__c";
            svmxcUser.value = [dict objectForKey:@"SVMXC__User__c"];
            [svmxcField.valueMap addObject:svmxcUser];
            [svmxcUser release];
            
            INTF_WebServicesDefServiceSvc_SVMXMap * svmxcDeviceType =  [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
            svmxcDeviceType.key  = @"SVMXC__Device_Type__c";
            svmxcDeviceType.value = [dict objectForKey:@"SVMXC__Device_Type__c"];
            [svmxcField.valueMap addObject:svmxcDeviceType];
            [svmxcDeviceType release];
            
            INTF_WebServicesDefServiceSvc_SVMXMap * svmxcAdditionalInfo =  [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
            svmxcAdditionalInfo.key  = @"SVMXC__Additional_Info__c";
            svmxcAdditionalInfo.value = [dict objectForKey:@"SVMXC__Additional_Info__c"];
            [svmxcField.valueMap addObject:svmxcAdditionalInfo];
            [svmxcAdditionalInfo release];
            
            INTF_WebServicesDefServiceSvc_SVMXMap * svmxcTimeRecorded =  [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
            svmxcTimeRecorded.key  = @"SVMXC__Time_Recorded__c";
            svmxcTimeRecorded.value = [dict objectForKey:@"SVMXC__Time_Recorded__c"];
            [svmxcField.valueMap addObject:svmxcTimeRecorded];
            [svmxcTimeRecorded release];


            [sfmRequest.valueMap addObject:svmxcField];
            [svmxcField release];
        }
        
    }
    [dataSync setRequest:sfmRequest];
    //SFM Search End
    //[[ZKServerSwitchboard switchboard] doCheckSession];
    [binding INTF_DataSync_WSAsyncUsingParameters:dataSync 
                                    SessionHeader:sessionHeader 
                                      CallOptions:callOptions
                                  DebuggingHeader:debuggingHeader
                       AllowFieldTruncationHeader:allowFieldTruncationHeader delegate:self];
}

- (void) dataSyncWithEventName:(NSString *)eventName eventType:(NSString *)eventType requestId:(NSString *)requestId
{
    
    [INTF_WebServicesDefServiceSvc initialize];
    
    INTF_WebServicesDefServiceSvc_SessionHeader * sessionHeader = [[[INTF_WebServicesDefServiceSvc_SessionHeader alloc] init] autorelease];
    sessionHeader.sessionId = [[ZKServerSwitchboard switchboard] sessionId];
    
    INTF_WebServicesDefServiceSvc_CallOptions * callOptions = [[[INTF_WebServicesDefServiceSvc_CallOptions alloc] init] autorelease];
    callOptions.client = nil;
    
    INTF_WebServicesDefServiceSvc_DebuggingHeader * debuggingHeader = [[[INTF_WebServicesDefServiceSvc_DebuggingHeader alloc] init] autorelease];
    debuggingHeader.debugLevel = 0;
    
    INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader * allowFieldTruncationHeader = [[[INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader alloc] init]  autorelease];
    allowFieldTruncationHeader.allowFieldTruncation = NO;
    
    INTF_WebServicesDefBinding * binding = [INTF_WebServicesDefServiceSvc INTF_WebServicesDefBindingWithServer:appDelegate.currentServerUrl];
    binding.logXMLInOut = YES;
    
    INTF_WebServicesDefServiceSvc_INTF_DataSync_WS * dataSync = [[[INTF_WebServicesDefServiceSvc_INTF_DataSync_WS alloc] init] autorelease];
    
    INTF_WebServicesDefServiceSvc_INTF_SFMRequest * sfmRequest = [[[INTF_WebServicesDefServiceSvc_INTF_SFMRequest alloc] init] 
                                                                  autorelease];

    INTF_WebServicesDefServiceSvc_SVMXClient * client = [[[INTF_WebServicesDefServiceSvc_SVMXClient alloc] init] autorelease];
    
    INTF_WebServicesDefServiceSvc_SVMXMap * SVMXCMap_startTime =  [[[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init] autorelease];
    SVMXCMap_startTime.key  = @"RANGE_START";
    SVMXCMap_startTime.value = [self getSyncTimeStampWithTheIntervalof15days:START_TIME] == nil?@"":[self getSyncTimeStampWithTheIntervalof15days:START_TIME];
    
    INTF_WebServicesDefServiceSvc_SVMXMap * SVMXCMap_endTime =  [[[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init] autorelease];
    SVMXCMap_endTime.key  = @"RANGE_END";
    SVMXCMap_endTime.value = [self getSyncTimeStampWithTheIntervalof15days:END_TIME]== nil?@"":[self getSyncTimeStampWithTheIntervalof15days:END_TIME];
    
    
    [sfmRequest.valueMap addObject:SVMXCMap_startTime];
    [sfmRequest.valueMap addObject:SVMXCMap_endTime];
    
    SMLog(@"SAMMAN Incremental DataSync request looping  starts: %@", [NSDate date]);
    if([eventName isEqualToString:DOWNLOAD_CREITERIA_SYNC])
    {
        INTF_WebServicesDefServiceSvc_SVMXMap * SVMXCMap_last_index =  [[[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init] autorelease];
        SVMXCMap_last_index.key  = @"LAST_INDEX";
        SVMXCMap_last_index.value = appDelegate.initial_Sync_last_index;
        [sfmRequest.valueMap addObject:SVMXCMap_last_index];
        
        if(appDelegate.initial_Sync_last_index > 0)
        {
            NSArray * all_records = [appDelegate.databaseInterface getAllIdsFromDatabase:@"DATA_SYNC" forObjectName:appDelegate.initital_sync_object_name];
            
            for(NSString * str in all_records)
            {
                [sfmRequest.values addObject:str];
            }
        }
    }
    SMLog(@"SAMMAN Incremental DataSync request looping  ends: %@", [NSDate date]);
    client.clientType = @"iPad";
    [client.clientInfo addObject:@"OS:iPadOS"];
    [client.clientInfo addObject:@"R4B2"];
    
    sfmRequest.eventName = eventName;
    sfmRequest.eventType = eventType;
    
    sfmRequest.userId = [appDelegate.loginResult userId];
    sfmRequest.groupId = [[appDelegate.loginResult userInfo] organizationId];
    sfmRequest.profileId = [[appDelegate.loginResult userInfo] profileId];
    
    //sahana 
    sfmRequest.value = requestId;
    
    
    [sfmRequest addClientInfo:client];
    [dataSync setRequest:sfmRequest];
    
    //[[ZKServerSwitchboard switchboard] doCheckSession];
    SMLog(@"SAMMAN Incremental DataSync Request sent: %@", [NSDate date]);
    
  
    [binding INTF_DataSync_WSAsyncUsingParameters:dataSync 
                                    SessionHeader:sessionHeader 
                                      CallOptions:callOptions
                                  DebuggingHeader:debuggingHeader
                       AllowFieldTruncationHeader:allowFieldTruncationHeader delegate:self];
    
}

#pragma mark WSInterface Layer

- (void) getTags
{
    // Essentials
    
    [INTF_WebServicesDefServiceSvc initialize];
    
    INTF_WebServicesDefServiceSvc_SessionHeader * session = [[[INTF_WebServicesDefServiceSvc_SessionHeader alloc] init] autorelease];
    session.sessionId = [appDelegate.loginResult sessionId];
    
    INTF_WebServicesDefServiceSvc_CallOptions * callOptions = [[[INTF_WebServicesDefServiceSvc_CallOptions alloc] init] autorelease];
    callOptions.client = nil;
    
    INTF_WebServicesDefServiceSvc_DebuggingHeader * debuggingHeader = [[[INTF_WebServicesDefServiceSvc_DebuggingHeader alloc] init] autorelease];
    debuggingHeader.debugLevel = 0;
    
    INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader * allowFieldTruncationHeader = [[[INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader alloc] init] autorelease];
    allowFieldTruncationHeader.allowFieldTruncation = NO;
    
    INTF_WebServicesDefServiceSvc_INTF_StringMap * stringMap1 = [[[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init] autorelease];
    stringMap1.key = TAG_KEY;
    stringMap1.value = @"IPAD";
    
    INTF_WebServicesDefServiceSvc_INTF_StringMap * stringMap2 = [[[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init] autorelease];
    stringMap2.key = ISSUBMODULE_KEY;
    stringMap2.value = @"FALSE";
    
    INTF_WebServicesDefServiceSvc_INTF_Request_For_Tags * requestForTags = [[[INTF_WebServicesDefServiceSvc_INTF_Request_For_Tags alloc] init] autorelease];
    
    [requestForTags addTagReqInfo:stringMap1];
    [requestForTags addTagReqInfo:stringMap2];
    
    INTF_WebServicesDefServiceSvc_INTF_Get_Tags_WS * getTags = [[[INTF_WebServicesDefServiceSvc_INTF_Get_Tags_WS alloc] init] autorelease];
    getTags.tagsReq = requestForTags;
    
    INTF_WebServicesDefBinding * binding = [INTF_WebServicesDefServiceSvc INTF_WebServicesDefBindingWithServer:appDelegate.currentServerUrl];
    binding.logXMLInOut = YES;
    
    //[[ZKServerSwitchboard switchboard] doCheckSession];
    [binding INTF_Get_Tags_WSAsyncUsingParameters:getTags
                                    SessionHeader:session
                                      CallOptions:callOptions
                                  DebuggingHeader:debuggingHeader
                       AllowFieldTruncationHeader:allowFieldTruncationHeader
                                         delegate:self];
}

- (void) getCreateProcesses
{
    // Essentials
    
    [INTF_WebServicesDefServiceSvc initialize];
    
    INTF_WebServicesDefBinding * binding = [INTF_WebServicesDefServiceSvc INTF_WebServicesDefBindingWithServer:appDelegate.currentServerUrl];
    binding.logXMLInOut = YES;
    
    INTF_WebServicesDefServiceSvc_SessionHeader * sessionHeader = [[[INTF_WebServicesDefServiceSvc_SessionHeader alloc] init] autorelease];
    sessionHeader.sessionId = [appDelegate.loginResult sessionId];
    
    INTF_WebServicesDefServiceSvc_CallOptions * callOptions = [[[INTF_WebServicesDefServiceSvc_CallOptions alloc] init] autorelease];
    callOptions.client = nil;
    
    INTF_WebServicesDefServiceSvc_DebuggingHeader * debuggingHeader = [[[INTF_WebServicesDefServiceSvc_DebuggingHeader alloc] init] autorelease];
    debuggingHeader.debugLevel = 0;
    
    INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader * allowFieldTruncationHeader = [[[INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader alloc] init] autorelease];
    allowFieldTruncationHeader.allowFieldTruncation = NO;
    
    INTF_WebServicesDefServiceSvc_INTF_Get_StandaloneCreate_Layouts * getCreateProcesses = [[[INTF_WebServicesDefServiceSvc_INTF_Get_StandaloneCreate_Layouts alloc] init] autorelease];
    
    // Get Standalone create processes
    //[[ZKServerSwitchboard switchboard] doCheckSession];
    [binding INTF_Get_StandaloneCreate_LayoutsAsyncUsingParameters:getCreateProcesses 
                                                     SessionHeader:sessionHeader
                                                       CallOptions:callOptions
                                                   DebuggingHeader:debuggingHeader
                                        AllowFieldTruncationHeader:allowFieldTruncationHeader
                                                          delegate:self];
}


- (void) getViewLayouts
{
    // Essentials
    
    [INTF_WebServicesDefServiceSvc initialize];
    
    INTF_WebServicesDefBinding * binding = [INTF_WebServicesDefServiceSvc INTF_WebServicesDefBindingWithServer:appDelegate.currentServerUrl];
    binding.logXMLInOut = YES;
    
    INTF_WebServicesDefServiceSvc_SessionHeader * sessionHeader = [[[INTF_WebServicesDefServiceSvc_SessionHeader alloc] init] autorelease];
    sessionHeader.sessionId = [appDelegate.loginResult sessionId];
    
    INTF_WebServicesDefServiceSvc_CallOptions * callOptions = [[[INTF_WebServicesDefServiceSvc_CallOptions alloc] init] autorelease];
    callOptions.client = nil;
    
    INTF_WebServicesDefServiceSvc_DebuggingHeader * debuggingHeader = [[[INTF_WebServicesDefServiceSvc_DebuggingHeader alloc] init]autorelease];
    debuggingHeader.debugLevel = 0;
    
    INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader * allowFieldTruncationHeader = [[[INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader alloc] init] autorelease];
    allowFieldTruncationHeader.allowFieldTruncation = NO;
    
    INTF_WebServicesDefServiceSvc_INTF_Get_View_Layouts_WS * getViewLayouts = [[[INTF_WebServicesDefServiceSvc_INTF_Get_View_Layouts_WS alloc] init] autorelease];
    
    //[[ZKServerSwitchboard switchboard] doCheckSession];
    [binding INTF_Get_View_Layouts_WSAsyncUsingParameters:getViewLayouts
                                            SessionHeader:sessionHeader 
                                              CallOptions:callOptions
                                          DebuggingHeader:debuggingHeader
                               AllowFieldTruncationHeader:allowFieldTruncationHeader
                                                 delegate:self];
        
}

- (void) getTasksForStartDate:(NSString *)_startDate EndDate:(NSString *)_endDate
{
    // Essentials
    
    [INTF_WebServicesDefServiceSvc initialize];
    
    INTF_WebServicesDefBinding * binding = [INTF_WebServicesDefServiceSvc INTF_WebServicesDefBindingWithServer:appDelegate.currentServerUrl];
    binding.logXMLInOut = YES;
    
    INTF_WebServicesDefServiceSvc_SessionHeader * sessionHeader = [[[INTF_WebServicesDefServiceSvc_SessionHeader alloc] init] autorelease];
    sessionHeader.sessionId = [appDelegate.loginResult sessionId];
    
    INTF_WebServicesDefServiceSvc_CallOptions * callOptions = [[[INTF_WebServicesDefServiceSvc_CallOptions alloc] init] autorelease];
    callOptions.client = nil;
    
    INTF_WebServicesDefServiceSvc_DebuggingHeader * debuggingHeader = [[[INTF_WebServicesDefServiceSvc_DebuggingHeader alloc] init] autorelease];
    debuggingHeader.debugLevel = 0;
    
    INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader * allowFieldTruncationHeader = [[[INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader alloc] init] autorelease];
    allowFieldTruncationHeader.allowFieldTruncation = NO;
    
    // Get Tasks for date
    INTF_WebServicesDefServiceSvc_INTF_Get_Tasks_WS * getTasks = [[[INTF_WebServicesDefServiceSvc_INTF_Get_Tasks_WS alloc] init] autorelease];
    INTF_WebServicesDefServiceSvc_INTF_Request_For_Tasks * requestForTasks = [[[INTF_WebServicesDefServiceSvc_INTF_Request_For_Tasks alloc] init] autorelease];
    
    INTF_WebServicesDefServiceSvc_INTF_StringMap * objStrMap = nil;
    
    objStrMap = [[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init];
    objStrMap.key = CALENDAR_START_DATE;
    objStrMap.value = _startDate; // @"2011-04-24";
    [requestForTasks addTaskReqInfo:objStrMap];
    [objStrMap release];
    
    objStrMap = [[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init];
    objStrMap.key = CALENDAR_END_DATE;
    objStrMap.value = @"2011-07-02";
    [requestForTasks addTaskReqInfo:objStrMap];
    [objStrMap release];
    
    objStrMap = [[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init];
    objStrMap.key = USERID;
    objStrMap.value = [appDelegate.loginResult userId];
    [requestForTasks addTaskReqInfo:objStrMap];
    [objStrMap release];

    [getTasks setIPadReqTask:requestForTasks];
    
    //[[ZKServerSwitchboard switchboard] doCheckSession];
    [binding INTF_Get_Tasks_WSAsyncUsingParameters:getTasks
                                     SessionHeader:sessionHeader
                                       CallOptions:callOptions
                                   DebuggingHeader:debuggingHeader
                        AllowFieldTruncationHeader:allowFieldTruncationHeader
                                          delegate:self];
}

- (void) getPageLayoutWithProcessId:(NSString *)processId RecordId:(NSString *)recordId
{
    // Essentials
    
    [INTF_WebServicesDefServiceSvc initialize];
    
    INTF_WebServicesDefServiceSvc_SessionHeader * session = [[[INTF_WebServicesDefServiceSvc_SessionHeader alloc] init] autorelease];
    session.sessionId = [appDelegate.loginResult sessionId];
    
    INTF_WebServicesDefServiceSvc_CallOptions * callOptions = [[[INTF_WebServicesDefServiceSvc_CallOptions alloc] init] autorelease];
    callOptions.client = nil;
    
    INTF_WebServicesDefServiceSvc_DebuggingHeader * debuggingHeader = [[[INTF_WebServicesDefServiceSvc_DebuggingHeader alloc] init] autorelease];
    debuggingHeader.debugLevel = 0;
    
    INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader * allowFieldTruncationHeader = [[[INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader alloc] init] autorelease];
    allowFieldTruncationHeader.allowFieldTruncation = NO;
    
    INTF_WebServicesDefServiceSvc_INTF_getPageLayout_WS * getPageLayout = [[INTF_WebServicesDefServiceSvc_INTF_getPageLayout_WS alloc] autorelease];
    
    INTF_WebServicesDefServiceSvc_INTF_Request_PageUI * reqPageUI = [[[INTF_WebServicesDefServiceSvc_INTF_Request_PageUI alloc] init] autorelease];
    INTF_WebServicesDefServiceSvc_INTF_Request * request = [[[INTF_WebServicesDefServiceSvc_INTF_Request alloc] init] autorelease];
    
    INTF_WebServicesDefServiceSvc_INTF_StringMap * stringMap = [[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init];
    
    stringMap.key = PAGEID;
    stringMap.value = @"";
    [request.stringMap addObject:stringMap];
    
    [stringMap release];
    stringMap = [[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init];
    
    stringMap.key = RECORDID;
    // if (currentRecordId == nil)
    //    currentRecordId = @"a0oA0000004lDTg";
    stringMap.value = recordId;
        
    [request.stringMap addObject:stringMap];
    
    [stringMap release];
    stringMap = [[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init];
    
    stringMap.key = PROCESSID;
    // if (currentProcessId == nil)
    //    currentProcessId = @"TDM016";
    stringMap.value = processId;
    
    [request.stringMap addObject:stringMap];
    
    [stringMap release];
    
    reqPageUI.request = request;
    getPageLayout.PmaxReqPageUI = reqPageUI;
    
    INTF_WebServicesDefBinding * binding = [INTF_WebServicesDefServiceSvc INTF_WebServicesDefBindingWithServer:appDelegate.currentServerUrl];
    binding.logXMLInOut = YES;
    
    //[[ZKServerSwitchboard switchboard] doCheckSession];
    [binding INTF_getPageLayout_WSAsyncUsingParameters:getPageLayout
                                         SessionHeader:session
                                           CallOptions:callOptions
                                       DebuggingHeader:debuggingHeader
                            AllowFieldTruncationHeader:allowFieldTruncationHeader
                                              delegate:self];
    
    // Also make calls to retreive Product History and Account History
}

- (void) savePageLayout
{
    // Essentials
    
    [INTF_WebServicesDefServiceSvc initialize];
    
    INTF_WebServicesDefBinding * binding = [INTF_WebServicesDefServiceSvc INTF_WebServicesDefBindingWithServer:appDelegate.currentServerUrl];
    binding.logXMLInOut = YES;
    
    INTF_WebServicesDefServiceSvc_SessionHeader * sessionHeader = [[[INTF_WebServicesDefServiceSvc_SessionHeader alloc] init] autorelease];
    sessionHeader.sessionId = [appDelegate.loginResult sessionId];
    
    INTF_WebServicesDefServiceSvc_CallOptions * callOptions = [[[INTF_WebServicesDefServiceSvc_CallOptions alloc] init] autorelease];
    callOptions.client = nil;
    
    INTF_WebServicesDefServiceSvc_DebuggingHeader * debuggingHeader = [[[INTF_WebServicesDefServiceSvc_DebuggingHeader alloc] init] autorelease];
    debuggingHeader.debugLevel = 0;
    
    INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader * allowFieldTruncationHeader = [[[INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader alloc] init] autorelease];
    allowFieldTruncationHeader.allowFieldTruncation = NO;
    
    // Save PageLayout
    
    INTF_WebServicesDefServiceSvc_INTF_Request_PageUI * objPageUI = [[[INTF_WebServicesDefServiceSvc_INTF_Request_PageUI alloc] init] autorelease];
    
    INTF_WebServicesDefServiceSvc_SVMXC__Page_Layout_Detail__c * detailPage = [[[INTF_WebServicesDefServiceSvc_SVMXC__Page_Layout_Detail__c alloc] init] autorelease];
    
    detailPage.SVMXC__Detail_Type__c = @"Field";
    detailPage.SVMXC__Field_API_Name__c = @"AccountId";
    detailPage.SVMXC__DataType__c
    = @"reference";
    detailPage.SVMXC__Related_Object_Name__c = @"Account";
    detailPage.SVMXC__Related_Object_Name_Field__c = @"Name";
    detailPage.SVMXC__Named_Search__c = @"a0VA0000001AEp0MAG";
    detailPage.SVMXC__Display_Row__c = [NSNumber numberWithInt:1];
    detailPage.SVMXC__Display_Column__c = [NSNumber numberWithInt:1];
    detailPage.SVMXC__Required__c = NO;
    detailPage.SVMXC__Readonly__c = NO;
    detailPage.SVMXC__Sequence__c = [NSNumber numberWithInt:1];
    detailPage.SVMXC__Override_Related_Lookup__c = NO;
    
    INTF_WebServicesDefServiceSvc_INTF_UIField * uiField = [[[INTF_WebServicesDefServiceSvc_INTF_UIField alloc] init] autorelease];
    [uiField setFieldDetail:detailPage];
    
    INTF_WebServicesDefServiceSvc_INTF_UISection * uiSection = [[[INTF_WebServicesDefServiceSvc_INTF_UISection alloc] init] autorelease];
    [uiSection.fields addObject:uiField];
    
    INTF_WebServicesDefServiceSvc_INTF_PageHeader * pageHeader = [[[INTF_WebServicesDefServiceSvc_INTF_PageHeader alloc] init] autorelease];
    [pageHeader.pageEvents addObject:uiSection];
    
    INTF_WebServicesDefServiceSvc_INTF_PageUI * pageUI = [[[INTF_WebServicesDefServiceSvc_INTF_PageUI alloc] init] autorelease];
    
    INTF_WebServicesDefServiceSvc_INTF_SavePageLayout_WS * savePageLayout = [[[INTF_WebServicesDefServiceSvc_INTF_SavePageLayout_WS alloc] init] autorelease];
    
    INTF_WebServicesDefServiceSvc_SVMXC__Page_Layout__c * objPageHeaderLayout = [[[INTF_WebServicesDefServiceSvc_SVMXC__Page_Layout__c alloc] init] autorelease];
    objPageHeaderLayout.SVMXC__Name__c = @"Created from the custom Webservice";
    objPageHeaderLayout.SVMXC__Object_Name__c = @"Case";
    objPageHeaderLayout.SVMXC__Page_Layout_ID__c = @"CustFromWEBService";
    objPageHeaderLayout.SVMXC__Type__c = @"Header";
    
    pageHeader.headerLayout = objPageHeaderLayout;
    pageUI.header = pageHeader;
    
    objPageUI.request = [[[INTF_WebServicesDefServiceSvc_INTF_Request alloc] init] autorelease];
    
    INTF_WebServicesDefServiceSvc_INTF_StringMap * strMap = [[[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init] autorelease];
    strMap.key = SAVETYPE;
    strMap.value = @"SAVE";
    
    [objPageUI.request.stringMap addObject:strMap];
    
    INTF_WebServicesDefServiceSvc_INTF_Request_PageUI * savePageReq = [[[INTF_WebServicesDefServiceSvc_INTF_Request_PageUI alloc] init] autorelease];
    
    [savePageReq setPage:objPageUI.page];
    
    [savePageLayout setPmaxReqPageUI:savePageReq];
    
    //[[ZKServerSwitchboard switchboard] doCheckSession];
    [binding INTF_SavePageLayout_WSAsyncUsingParameters:savePageLayout
                                          SessionHeader:sessionHeader
                                            CallOptions:callOptions
                                        DebuggingHeader:debuggingHeader
                             AllowFieldTruncationHeader:allowFieldTruncationHeader
                                               delegate:self];
    
}

- (void) getEventsForStartDate:(NSString *)_startDate EndDate:(NSString *)_endDate
{
    if (startDate)
    {
        [startDate release];
        startDate = nil;
    }
    startDate = [_startDate retain];
    
    if (endDate)
    {
        [endDate release];
        endDate = nil;
    }
    endDate = [_endDate retain];
    // Essentials
    
    [INTF_WebServicesDefServiceSvc initialize];
    
    INTF_WebServicesDefBinding * binding = [INTF_WebServicesDefServiceSvc INTF_WebServicesDefBindingWithServer:appDelegate.currentServerUrl];
    binding.logXMLInOut = YES;
    
    INTF_WebServicesDefServiceSvc_SessionHeader * sessionHeader = [[[INTF_WebServicesDefServiceSvc_SessionHeader alloc] init] autorelease];
    sessionHeader.sessionId = [appDelegate.loginResult sessionId];
    
    INTF_WebServicesDefServiceSvc_CallOptions * callOptions = [[[INTF_WebServicesDefServiceSvc_CallOptions alloc] init] autorelease];
    callOptions.client = nil;
    
    INTF_WebServicesDefServiceSvc_DebuggingHeader * debuggingHeader = [[[INTF_WebServicesDefServiceSvc_DebuggingHeader alloc] init] autorelease];
    debuggingHeader.debugLevel = 0;
    
    INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader * allowFieldTruncationHeader = [[[INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader alloc] init] autorelease];
    allowFieldTruncationHeader.allowFieldTruncation = NO;
    
    // Get Events
    
    INTF_WebServicesDefServiceSvc_INTF_Get_Events_WS * getEvents = [[[INTF_WebServicesDefServiceSvc_INTF_Get_Events_WS alloc] init] autorelease];
    
    INTF_WebServicesDefServiceSvc_INTF_Request_For_Events * reqEvents = [[[INTF_WebServicesDefServiceSvc_INTF_Request_For_Events alloc] init] autorelease];
    
    INTF_WebServicesDefServiceSvc_INTF_StringMap * objStrMap = nil;
    
    objStrMap = [[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init];
    objStrMap.key = CALENDAR_START_DATE;
    objStrMap.value = _startDate; // @"2011-04-24";
    [reqEvents addEventReqInfo:objStrMap];
    [objStrMap release];
    
    objStrMap = [[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init];
    objStrMap.key = CALENDAR_END_DATE;
    objStrMap.value = _endDate; // @"2011-05-06";
    [reqEvents addEventReqInfo:objStrMap];
    [objStrMap release];
    
    objStrMap = [[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init];
    objStrMap.key = USERID;
    objStrMap.value = [appDelegate.loginResult userId];
    [reqEvents addEventReqInfo:objStrMap];
    [objStrMap release];
    
    [getEvents setIPadReqEvent:reqEvents];
    
    //[[ZKServerSwitchboard switchboard] doCheckSession];
    [binding INTF_Get_Events_WSAsyncUsingParameters:(INTF_WebServicesDefServiceSvc_INTF_Get_Events_WS *)getEvents 
                                      SessionHeader:sessionHeader
                                        CallOptions:callOptions
                                    DebuggingHeader:debuggingHeader
                         AllowFieldTruncationHeader:allowFieldTruncationHeader
                                           delegate:self];
}

- (void) getUpdateEventsForStartDate:(NSString *)_startDate EndDate:(NSString *)_endDate recordID:(NSString *)_recordID
{
    //Essentials
    
    [INTF_WebServicesDefServiceSvc initialize];
    
    INTF_WebServicesDefBinding * binding = [INTF_WebServicesDefServiceSvc INTF_WebServicesDefBindingWithServer:appDelegate.currentServerUrl];
    binding.logXMLInOut = YES;
    
    INTF_WebServicesDefServiceSvc_SessionHeader * sessionHeader = [[[INTF_WebServicesDefServiceSvc_SessionHeader alloc] init] autorelease];
    sessionHeader.sessionId = [appDelegate.loginResult sessionId];
    
    INTF_WebServicesDefServiceSvc_CallOptions * callOptions = [[[INTF_WebServicesDefServiceSvc_CallOptions alloc] init] autorelease];
    callOptions.client = nil;
    
    INTF_WebServicesDefServiceSvc_DebuggingHeader * debuggingHeader = [[[INTF_WebServicesDefServiceSvc_DebuggingHeader alloc] init] autorelease];
    debuggingHeader.debugLevel = 0;
    
    INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader * allowFieldTruncationHeader = [[[INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader alloc] init] autorelease];
    allowFieldTruncationHeader.allowFieldTruncation = NO;
    
    
    // Update Events
    INTF_WebServicesDefServiceSvc_INTF_Update_Events_WS * getUpdateEvents = [[[INTF_WebServicesDefServiceSvc_INTF_Update_Events_WS alloc] init] autorelease];
    
    INTF_WebServicesDefServiceSvc_INTF_Event_WP * eventWP = [[[INTF_WebServicesDefServiceSvc_INTF_Event_WP alloc] init] autorelease];
    
    // Compare _startDate and _endDate for validity before updating
    BOOL isStartEndValid = [self checkValidStartDate:_startDate EndDate:_endDate];
    
    if (!isStartEndValid)
    {
        didRescheduleEvent = TRUE;
        return;
    }
    
    [eventWP setId_:_recordID];
    [eventWP setStartDateTime:_startDate];
    [eventWP setEndDateTime:_endDate];
    
    [getUpdateEvents.request addObject:eventWP];
    
    //[[ZKServerSwitchboard switchboard] doCheckSession];
    [binding INTF_Update_Events_WSAsyncUsingParameters:(INTF_WebServicesDefServiceSvc_INTF_Update_Events_WS *) getUpdateEvents
                                         SessionHeader:(INTF_WebServicesDefServiceSvc_SessionHeader *)sessionHeader 
                                           CallOptions: (INTF_WebServicesDefServiceSvc_CallOptions *)callOptions 
                                       DebuggingHeader:(INTF_WebServicesDefServiceSvc_DebuggingHeader *)debuggingHeader AllowFieldTruncationHeader:(INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader *)allowFieldTruncationHeader delegate:self];    
}

- (BOOL) checkValidStartDate:(NSString *)_startDate EndDate:(NSString *)_endDate
{
    NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    if (!(([_startDate length] > 0) && ([_endDate length] > 0)))
        return NO;
    
    NSDate * start_Date = [dateFormatter dateFromString:_startDate];
    NSDate * end_Date = [dateFormatter dateFromString:_endDate];
    
    NSTimeInterval startTimeInterval = [start_Date timeIntervalSince1970];
    NSTimeInterval endTimeInterval = [end_Date timeIntervalSince1970];
    
    if (startTimeInterval < endTimeInterval)
        return YES;
    
    return NO;
}

//WorkOrderMapView

- (void) getWorkOrderMapViewForWorkOrderId:(NSString *)workOrderId
{
    //Essentials
    [INTF_WebServicesDefServiceSvc initialize];
    
    INTF_WebServicesDefBinding * binding = [INTF_WebServicesDefServiceSvc INTF_WebServicesDefBindingWithServer:appDelegate.currentServerUrl];
    binding.logXMLInOut = YES;
    
    INTF_WebServicesDefServiceSvc_CallOptions * callOptions = [[[INTF_WebServicesDefServiceSvc_CallOptions alloc] init] autorelease];
    callOptions.client = nil;
    
    INTF_WebServicesDefServiceSvc_DebuggingHeader * debuggingHeader = [[[INTF_WebServicesDefServiceSvc_DebuggingHeader alloc] init] autorelease];
    debuggingHeader.debugLevel = 0;
    
    INTF_WebServicesDefServiceSvc_SessionHeader * sessionHeader = [[[INTF_WebServicesDefServiceSvc_SessionHeader alloc] init] autorelease];
    sessionHeader.sessionId = [appDelegate.loginResult sessionId];
    
    INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader * allowFieldTruncationHeader = [[[INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader alloc] init] autorelease];
    allowFieldTruncationHeader.allowFieldTruncation = NO;
    
    //Get MapView Details
    
    INTF_WebServicesDefServiceSvc_INTF_Get_WorkOrderMapView_WS * getWordOrderMapView = [[[INTF_WebServicesDefServiceSvc_INTF_Get_WorkOrderMapView_WS alloc] init] autorelease];
    
    INTF_WebServicesDefServiceSvc_INTF_Request * request = [[[INTF_WebServicesDefServiceSvc_INTF_Request alloc] init] autorelease];
    
    INTF_WebServicesDefServiceSvc_INTF_StringMap * stringMap = [[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init];
    
    stringMap.key = @"WORKORDERID";
    stringMap.value = workOrderId;
    
    [request addStringMap:stringMap];
    
    [stringMap release];
    
    [getWordOrderMapView setRequest:request];
    
    //[[ZKServerSwitchboard switchboard] doCheckSession];
    [binding INTF_Get_WorkOrderMapView_WSAsyncUsingParameters:getWordOrderMapView
                                                SessionHeader:sessionHeader
                                                  CallOptions:callOptions
                                              DebuggingHeader:debuggingHeader
                                   AllowFieldTruncationHeader:allowFieldTruncationHeader
                                                     delegate:self];
    
}
                               
- (void) getLookUpFieldsWithKeyword:(NSString *)keyword forObject:(NSString *)objectName returnTo:(id)caller setting:(BOOL)idAvailable overrideRelatedLookup:(NSNumber *)Override_Related_Lookup lookupContext:(NSString *)Lookup_Context lookupQuery:(NSString *)Lookup_Query_Field
{
    lookupCaller = caller;
    // Essentials
    
    [INTF_WebServicesDefServiceSvc initialize];
    
    INTF_WebServicesDefBinding * binding = [INTF_WebServicesDefServiceSvc INTF_WebServicesDefBindingWithServer:appDelegate.currentServerUrl];
    binding.logXMLInOut = YES;
    
    INTF_WebServicesDefServiceSvc_SessionHeader * sessionHeader = [[[INTF_WebServicesDefServiceSvc_SessionHeader alloc] init] autorelease];
    sessionHeader.sessionId = [appDelegate.loginResult sessionId];
    
    INTF_WebServicesDefServiceSvc_CallOptions * callOptions = [[[INTF_WebServicesDefServiceSvc_CallOptions alloc] init] autorelease];
    callOptions.client = nil;
    
    INTF_WebServicesDefServiceSvc_DebuggingHeader * debuggingHeader = [[[INTF_WebServicesDefServiceSvc_DebuggingHeader alloc] init] autorelease];
    debuggingHeader.debugLevel = 0;
    
    INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader * allowFieldTruncationHeader = [[[INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader alloc] init] autorelease];
    allowFieldTruncationHeader.allowFieldTruncation = NO;
    
    // Get LookUp Fields
    
    INTF_WebServicesDefServiceSvc_INTF_getLookUpConfigWithData_WS * getLookUpData = [[[INTF_WebServicesDefServiceSvc_INTF_getLookUpConfigWithData_WS alloc] init] autorelease];
    
    INTF_WebServicesDefServiceSvc_INTF_Request * lookUpReq = [[[INTF_WebServicesDefServiceSvc_INTF_Request alloc] init] autorelease];
    
    INTF_WebServicesDefServiceSvc_INTF_StringMap * strMap = nil;
    
    strMap = [[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init];
    if (idAvailable == false)
    {
        strMap.key = OBJECTNAME;
        strMap.value = objectName; //@"SVMXC__Service_Order__c";
    }
    else
    {
        strMap.key = RECORDID;
        strMap.value = objectName;
    }
    
    [lookUpReq addStringMap:strMap];
    [strMap release];
    
    // Additional Filters
    if (Override_Related_Lookup)
    {
        if (
            ((Lookup_Context != nil) && ![Lookup_Context isEqualToString:@""])
            &&
            ((Lookup_Query_Field != nil) && ![Lookup_Query_Field isEqualToString:@""])
            )
        {
            strMap = [[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init];
            strMap.key = CONTEXTVALUE;
            strMap.value = Lookup_Context;
            
            [lookUpReq addStringMap:strMap];
            
            [strMap release];
            
            strMap = [[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init];
            strMap.key = FIELDNAME;
            strMap.value = Lookup_Query_Field;
            
            [lookUpReq addStringMap:strMap];
            
            [strMap release];
        }
    }
    
    strMap = [[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init];
    strMap.key = @"KEYWORD";
    // strMap.value = @"IB";
    strMap.value = keyword;
    [lookUpReq addStringMap:strMap];
    [strMap release];
    
    getLookUpData.prequest = lookUpReq;
    
    //[[ZKServerSwitchboard switchboard] doCheckSession];
    [binding INTF_getLookUpConfigWithData_WSAsyncUsingParameters:getLookUpData
                                                   SessionHeader:sessionHeader
                                                     CallOptions:callOptions
                                                 DebuggingHeader:debuggingHeader
                                      AllowFieldTruncationHeader:allowFieldTruncationHeader
                                                        delegate:self];
}

- (NSMutableDictionary *) getLookUpFromResponse:(INTF_WebServicesDefBindingResponse *)response
{
    NSMutableArray * lookUpResult = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    NSMutableArray * keys = [NSMutableArray arrayWithObjects:@"key", @"value", nil];
    
    NSMutableArray * bodyParts = [[[response bodyParts] mutableCopy] autorelease];
    
    if (bodyParts == nil)
        return nil;
    INTF_WebServicesDefServiceSvc_INTF_getLookUpConfigWithData_WSResponse * wsResponse = [bodyParts objectAtIndex:0];
    INTF_WebServicesDefServiceSvc_INTF_LookUpConfigData * result = [wsResponse result];
    if (result == nil)
        return nil;
    
    // retrieve namesearchinfo first
    INTF_WebServicesDefServiceSvc_INTF_Response_NamedSearchInfo * namesearchinfo = [result namesearchinfo];
    NSMutableArray * namedSearch = [namesearchinfo namedSearch];
    if ([namedSearch count] == 0)
        return nil;
    INTF_WebServicesDefServiceSvc_INTF_NamedSearchInfo * namedSearchInfo = [namedSearch objectAtIndex:0];
    NSMutableArray * namedSearchDetails = [namedSearchInfo namedSearchDetails];
    if ([namedSearchDetails count] == 0)
        return nil;
    
    INTF_WebServicesDefServiceSvc_SVMXC__ServiceMax_Processes__c * namedSearchHdr = [namedSearchInfo namedSearchHdr];
    NSString * defaultLookupColumn = [namedSearchHdr SVMXCX1__Default_Lookup_Column__c];
    if ((defaultLookupColumn == nil) || (![defaultLookupColumn isKindOfClass:[NSString class]]))
        defaultLookupColumn = @"";
    INTF_WebServicesDefServiceSvc_INTF_NamedSearchInfoDetail * namedSearchInfoDetail = [namedSearchDetails objectAtIndex:0];
    if (namedSearchInfoDetail == nil)
        return nil;

    NSMutableArray * fields = [namedSearchInfoDetail fields];
    if ([fields count] == 0)
        return nil;
    
    NSMutableArray * sequenceArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    for (int j = 0; j < [fields count]; j++)
    {
        INTF_WebServicesDefServiceSvc_SVMXC__ServiceMax_Config_Data__c * data = [fields objectAtIndex:j];
        NSString * family;
        NSNumber * sequence;
        NSString * type = data.SVMXC__Search_Object_Field_Type__c;
        
        if ([type isEqualToString:@"Result"])
        {
            family = data.SVMXC__Field_Name__c;
            sequence = data.SVMXC__Sequence__c;
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObject:family forKey:sequence];
            [sequenceArray addObject:dict];
        }
    }
    
    // Sort sequenceArray according to sequence number
    for (int s = 0; s < [sequenceArray count]; s++)
    {
        NSMutableDictionary * d1 = [sequenceArray objectAtIndex:s];
        for (int s1 = s+1; s1 < [sequenceArray count]; s1++)
        {
            NSMutableDictionary * d2 = [sequenceArray objectAtIndex:s1];
            if ([[d1 allKeys] objectAtIndex:0] < [[d2 allKeys] objectAtIndex:0])
            {
                [sequenceArray exchangeObjectAtIndex:s withObjectAtIndex:s1];
            }
        }
    }
    
    // retrieve data
    NSMutableArray * array = [result data];
    if ([array count] == 0)
        return nil;
    for (int j = 0; j < [array count]; j++)
    {
        INTF_WebServicesDefServiceSvc_bubble_wp * bubble = [array objectAtIndex:j];
        NSMutableArray * fieldMap = [bubble FieldMap];
        NSMutableArray * fieldMapArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
        for (int k = 0; k < [fieldMap count]; k++)
        {
            INTF_WebServicesDefServiceSvc_INTF_StringFieldMap * stringFieldMap = [fieldMap objectAtIndex:k];
            if ([stringFieldMap.ftype isEqualToString:@"Result"])
            {
                NSMutableArray * objects = [NSMutableArray arrayWithObjects:
                                     (stringFieldMap.key != nil)?stringFieldMap.key:@"",
                                     (stringFieldMap.value != nil)?stringFieldMap.value:@"",
                                     nil];
                NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:objects forKeys:keys];
                [fieldMapArray addObject:dict];
            }
        }
        [lookUpResult addObject:fieldMapArray];
    }
    
    NSMutableArray * _keys = [NSMutableArray arrayWithObjects:@"SEQUENCE", @"DATA", DEFAULT_LOOKUP_COLUMN, nil];
    NSMutableArray * _objects = [NSMutableArray arrayWithObjects:sequenceArray, lookUpResult, defaultLookupColumn, nil];
    NSMutableDictionary * _dict = [NSMutableDictionary dictionaryWithObjects:_objects forKeys:_keys];
    
    return _dict;
}

- (void) getAccountHistoryForWorkOrderId:(NSString *)woId
{
    // Essentials
    
    [INTF_WebServicesDefServiceSvc initialize];
    
    INTF_WebServicesDefBinding * binding = [INTF_WebServicesDefServiceSvc INTF_WebServicesDefBindingWithServer:appDelegate.currentServerUrl];
    binding.logXMLInOut = YES;
    
    INTF_WebServicesDefServiceSvc_SessionHeader * sessionHeader = [[[INTF_WebServicesDefServiceSvc_SessionHeader alloc] init] autorelease];
    sessionHeader.sessionId = [[ZKServerSwitchboard switchboard] sessionId];
    
    INTF_WebServicesDefServiceSvc_CallOptions * callOptions = [[[INTF_WebServicesDefServiceSvc_CallOptions alloc] init] autorelease];
    callOptions.client = nil;
    
    INTF_WebServicesDefServiceSvc_DebuggingHeader * debuggingHeader = [[[INTF_WebServicesDefServiceSvc_DebuggingHeader alloc] init] autorelease];
    debuggingHeader.debugLevel = 0;
    
    INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader * allowFieldTruncationHeader = [[[INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader alloc] init] autorelease];
    allowFieldTruncationHeader.allowFieldTruncation = NO;
    
    // Get Product and History
    
    INTF_WebServicesDefServiceSvc_INTF_StringMap * strMap = nil;
    
    INTF_WebServicesDefServiceSvc_INTF_Get_Account_History_WS * getAccountHistory = [[[INTF_WebServicesDefServiceSvc_INTF_Get_Account_History_WS alloc] init] autorelease];
    
    INTF_WebServicesDefServiceSvc_INTF_Request_For_History * reqAccountHistory = [[[INTF_WebServicesDefServiceSvc_INTF_Request_For_History alloc] init] autorelease];
    
    strMap = [[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init];
    strMap.key = @"CurrentWrkOrderId";
    strMap.value = woId;
    [[reqAccountHistory historyReqInfo] addObject:strMap];
    [strMap release];
    
    [getAccountHistory setAccHistoryRequest:reqAccountHistory];
    
    //[[ZKServerSwitchboard switchboard] doCheckSession];
    [binding INTF_Get_Account_History_WSAsyncUsingParameters:getAccountHistory
                                               SessionHeader:sessionHeader
                                                 CallOptions:callOptions
                                             DebuggingHeader:debuggingHeader
                                  AllowFieldTruncationHeader:allowFieldTruncationHeader
                                                    delegate:self];
}

- (void) getProductHistoryForWorkOrderId:(NSString *)woId
{
    // Essentials
    
    [INTF_WebServicesDefServiceSvc initialize];
    
    INTF_WebServicesDefBinding * binding = [INTF_WebServicesDefServiceSvc INTF_WebServicesDefBindingWithServer:appDelegate.currentServerUrl];
    binding.logXMLInOut = YES;
    
    INTF_WebServicesDefServiceSvc_SessionHeader * sessionHeader = [[INTF_WebServicesDefServiceSvc_SessionHeader alloc] init];
    sessionHeader.sessionId = [[ZKServerSwitchboard switchboard] sessionId];
    
    INTF_WebServicesDefServiceSvc_CallOptions * callOptions = [[INTF_WebServicesDefServiceSvc_CallOptions alloc] init];
    callOptions.client = nil;
    
    INTF_WebServicesDefServiceSvc_DebuggingHeader * debuggingHeader = [[INTF_WebServicesDefServiceSvc_DebuggingHeader alloc] init];
    debuggingHeader.debugLevel = 0;
    
    INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader * allowFieldTruncationHeader = [[INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader alloc] init];
    allowFieldTruncationHeader.allowFieldTruncation = NO;
    
    // Get Product and History
    
    INTF_WebServicesDefServiceSvc_INTF_StringMap * strMap = nil;
    
    INTF_WebServicesDefServiceSvc_INTF_Get_Product_History_WS * getProductHistory = [[INTF_WebServicesDefServiceSvc_INTF_Get_Product_History_WS alloc] init];
    
    INTF_WebServicesDefServiceSvc_INTF_Request_For_History * reqProductHistory = [[INTF_WebServicesDefServiceSvc_INTF_Request_For_History alloc] init];

    strMap = [[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init];
    strMap.key = @"CurrentWrkOrderId";
    // strMap.value = @"a0oA0000004lDTi";
    strMap.value = woId;
    [[reqProductHistory historyReqInfo] addObject:strMap];
    [strMap release];
    
    [getProductHistory setProdHistoryRequest:reqProductHistory];
    
    //[[ZKServerSwitchboard switchboard] doCheckSession];
    [binding INTF_Get_Product_History_WSAsyncUsingParameters:getProductHistory
                                               SessionHeader:sessionHeader
                                                 CallOptions:callOptions
                                             DebuggingHeader:debuggingHeader
                                  AllowFieldTruncationHeader:allowFieldTruncationHeader
                                                    delegate:self];
    
    [reqProductHistory release];
    [getProductHistory release];
    [sessionHeader release];
    [callOptions release];
    [debuggingHeader release];
    [allowFieldTruncationHeader release];
}

- (void) saveTargetRecords:(id)sender
{
    // Essentials
    
    [INTF_WebServicesDefServiceSvc initialize];
    
    INTF_WebServicesDefBinding * binding = [INTF_WebServicesDefServiceSvc INTF_WebServicesDefBindingWithServer:appDelegate.currentServerUrl];
    binding.logXMLInOut = YES;
    
    INTF_WebServicesDefServiceSvc_SessionHeader * sessionHeader = [[[INTF_WebServicesDefServiceSvc_SessionHeader alloc] init] autorelease];
    sessionHeader.sessionId = [appDelegate.loginResult sessionId];
    
    INTF_WebServicesDefServiceSvc_CallOptions * callOptions = [[[INTF_WebServicesDefServiceSvc_CallOptions alloc] init] autorelease];
    callOptions.client = nil;
    
    INTF_WebServicesDefServiceSvc_DebuggingHeader * debuggingHeader = [[[INTF_WebServicesDefServiceSvc_DebuggingHeader alloc] init] autorelease];
    debuggingHeader.debugLevel = 0;
    
    INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader * allowFieldTruncationHeader = [[[INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader alloc] init] autorelease];
    allowFieldTruncationHeader.allowFieldTruncation = NO;
    
    // Save Target Records

    INTF_WebServicesDefServiceSvc_SFM_SaveTargetRecords_WS * saveTargetRecords = [[[INTF_WebServicesDefServiceSvc_SFM_SaveTargetRecords_WS alloc] init] autorelease];
    
    INTF_WebServicesDefServiceSvc_INTF_TargetRecord * targetRecord = [[[INTF_WebServicesDefServiceSvc_INTF_TargetRecord alloc] init] autorelease];
    
    INTF_WebServicesDefServiceSvc_INTF_TargetRecordObject * targetRecordObject = [[[INTF_WebServicesDefServiceSvc_INTF_TargetRecordObject alloc] init] autorelease];
    [targetRecord addDetailRecords:targetRecordObject];
    
    [[targetRecord detailRecords] addObject:@""];
    
    INTF_WebServicesDefServiceSvc_INTF_TargetRecordObject * headerRecord = [[[INTF_WebServicesDefServiceSvc_INTF_TargetRecordObject alloc] init] autorelease];
    [headerRecord addDeleteRecID:@""];
    INTF_WebServicesDefServiceSvc_INTF_Record * record = [[[INTF_WebServicesDefServiceSvc_INTF_Record alloc] init] autorelease];
    INTF_WebServicesDefServiceSvc_INTF_StringMap * keyMap = [[[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init] autorelease];
    keyMap.key = @""; // API Name
    keyMap.value = @""; // Actual Value
    [record addTargetRecordAsKeyValue:keyMap];
    [headerRecord addRecords:record];
    [headerRecord setAliasName:@""];
    [headerRecord setObjName:@""];
    [headerRecord setPageLayoutId:@""];
    [headerRecord setParentColumnName:@""];
    [targetRecord setHeaderRecord:headerRecord];
    [targetRecord setSfmProcessId:@"CREATEWO"];
    
    //[[ZKServerSwitchboard switchboard] doCheckSession];
    [binding SFM_SaveTargetRecords_WSAsyncUsingParameters:saveTargetRecords
                                            SessionHeader:sessionHeader
                                              CallOptions:callOptions
                                          DebuggingHeader:debuggingHeader
                               AllowFieldTruncationHeader:allowFieldTruncationHeader
                                                 delegate:self];
}

//pavaman
-(void) SaveSFMData:(NSDictionary *)sfmpage
{
    // Essentials
    
    [INTF_WebServicesDefServiceSvc initialize];
    
    INTF_WebServicesDefBinding * binding = [INTF_WebServicesDefServiceSvc INTF_WebServicesDefBindingWithServer:appDelegate.currentServerUrl];
    binding.logXMLInOut = YES;
    
    INTF_WebServicesDefServiceSvc_SessionHeader * sessionHeader = [[[INTF_WebServicesDefServiceSvc_SessionHeader alloc] init] autorelease];
    sessionHeader.sessionId = [appDelegate.loginResult sessionId];
    
    INTF_WebServicesDefServiceSvc_CallOptions * callOptions = [[[INTF_WebServicesDefServiceSvc_CallOptions alloc] init] autorelease];
    callOptions.client = nil;
    
    INTF_WebServicesDefServiceSvc_DebuggingHeader * debuggingHeader = [[[INTF_WebServicesDefServiceSvc_DebuggingHeader alloc] init] autorelease];
    debuggingHeader.debugLevel = 0;
    
    INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader * allowFieldTruncationHeader = [[[INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader alloc] init] autorelease];
    allowFieldTruncationHeader.allowFieldTruncation = NO;
    
    // Save Target Records

    INTF_WebServicesDefServiceSvc_SFM_SaveTargetRecords_WS * saveTargetRecords = [[[INTF_WebServicesDefServiceSvc_SFM_SaveTargetRecords_WS alloc] init] autorelease];
    
    INTF_WebServicesDefServiceSvc_INTF_TargetRecord * targetRecord = [self getTargetRecordsFromSFMPage:sfmpage];

    [saveTargetRecords setRequest:targetRecord];

    //[[ZKServerSwitchboard switchboard] doCheckSession];
    [binding SFM_SaveTargetRecords_WSAsyncUsingParameters:saveTargetRecords
                                            SessionHeader:sessionHeader
                                              CallOptions:callOptions
                                          DebuggingHeader:debuggingHeader
                               AllowFieldTruncationHeader:allowFieldTruncationHeader
                                                 delegate:self];
}
- (void) callCustomSFMAction:(NSDictionary *)dictionary  withData:(NSDictionary *)webServiceDict
{   
    // Pre - Essentials
    
    
    NSString * webServiceClass = nil;
    NSString * sfmMethodName = nil;
    
    sfmMethodName = [webServiceDict objectForKey:@"method_name"];
    webServiceClass = [webServiceDict objectForKey:@"class_name"];
    
    
//    sfmMethodName = [webServiceName pathExtension];
//    webServiceClass = [webServiceName stringByDeletingPathExtension];
    
    NSString *serverURL = nil;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (userDefaults)
    {
      serverURL = [userDefaults objectForKey:@"serverurl"];
    }
    
    SMLog(@"Server URL = %@",serverURL);
    
    // Essentials
    
    [INTF_WebServicesDefServiceSvc initialize];
    
    INTF_WebServicesDefBinding * binding = [INTF_WebServicesDefServiceSvc INTF_WebServicesDefBindingWithServer:serverURL webService:webServiceClass];
    
    binding.logXMLInOut = YES;
    
    INTF_WebServicesDefServiceSvc_SessionHeader * sessionHeader = [[[INTF_WebServicesDefServiceSvc_SessionHeader alloc] init] autorelease];
    sessionHeader.sessionId = [[ZKServerSwitchboard switchboard] sessionId];
    
    INTF_WebServicesDefServiceSvc_CallOptions * callOptions = [[[INTF_WebServicesDefServiceSvc_CallOptions alloc] init] autorelease];
    callOptions.client = nil;
    
    INTF_WebServicesDefServiceSvc_DebuggingHeader * debuggingHeader = [[[INTF_WebServicesDefServiceSvc_DebuggingHeader alloc] init] autorelease];
    debuggingHeader.debugLevel = 0;
    
    INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader * allowFieldTruncationHeader = [[[INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader alloc] init] autorelease];
    allowFieldTruncationHeader.allowFieldTruncation = NO;
    
    // Thoons Event
    
    
    INTF_WebServicesDefServiceSvc_INTF_PREQ_GetPrice_WS * getThoonsEvent = [[[INTF_WebServicesDefServiceSvc_INTF_PREQ_GetPrice_WS alloc] init] autorelease];
    getThoonsEvent.callEventName = sfmMethodName;
    getThoonsEvent.webServiceName = webServiceClass;
    
    INTF_WebServicesDefServiceSvc_INTF_TargetRecord * targetRecord = [self getTargetRecordsFromSFMPage:dictionary];
    
    [getThoonsEvent setRequest:targetRecord];
    
    
    //[[ZKServerSwitchboard switchboard] doCheckSession];
    
    [binding INTF_PREQ_GetPrice_WSAsyncUsingParameters:getThoonsEvent
                                         SessionHeader:sessionHeader
                                           CallOptions:callOptions
                                       DebuggingHeader:debuggingHeader
                            AllowFieldTruncationHeader:allowFieldTruncationHeader
                                              delegate:self];
}

// Thoons Method
- (void) callSFMEvent:(NSDictionary *)dictionary  event_name:(NSString *)event_name
{   
    // Pre - Essentials
    
    NSString * webServiceName = [dictionary objectForKey:WEBSERVICE_NAME];

    NSString * webServiceClass = nil;
    NSString * sfmMethodName = nil;

    sfmMethodName = [webServiceName pathExtension];
    webServiceClass = [webServiceName stringByDeletingPathExtension];

    // Essentials
    
    [INTF_WebServicesDefServiceSvc initialize];
    
    INTF_WebServicesDefBinding * binding = [INTF_WebServicesDefServiceSvc INTF_WebServicesDefBindingWithServer:appDelegate.currentServerUrl webService:webServiceClass];
       
    binding.logXMLInOut = YES;
    
    INTF_WebServicesDefServiceSvc_SessionHeader * sessionHeader = [[[INTF_WebServicesDefServiceSvc_SessionHeader alloc] init] autorelease];
    sessionHeader.sessionId = [[ZKServerSwitchboard switchboard] sessionId];
    
    INTF_WebServicesDefServiceSvc_CallOptions * callOptions = [[[INTF_WebServicesDefServiceSvc_CallOptions alloc] init] autorelease];
    callOptions.client = nil;
    
    INTF_WebServicesDefServiceSvc_DebuggingHeader * debuggingHeader = [[[INTF_WebServicesDefServiceSvc_DebuggingHeader alloc] init] autorelease];
    debuggingHeader.debugLevel = 0;
    
    INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader * allowFieldTruncationHeader = [[[INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader alloc] init] autorelease];
    allowFieldTruncationHeader.allowFieldTruncation = NO;
    
    // Thoons Event

    NSDictionary * sfmDictionary = [dictionary objectForKey:SFM_DICTIONARY];
    
    INTF_WebServicesDefServiceSvc_INTF_PREQ_GetPrice_WS * getThoonsEvent = [[[INTF_WebServicesDefServiceSvc_INTF_PREQ_GetPrice_WS alloc] init] autorelease];
    getThoonsEvent.callEventName = sfmMethodName;
    getThoonsEvent.webServiceName = webServiceClass;
    
    INTF_WebServicesDefServiceSvc_INTF_TargetRecord * targetRecord = [self getTargetRecordsFromSFMPage:sfmDictionary];

    [getThoonsEvent setRequest:targetRecord];
    
    
    //[[ZKServerSwitchboard switchboard] doCheckSession];
    
    if([event_name isEqualToString:ONLOAD] || [event_name isEqualToString:GETPRICE])
    {
        [binding INTF_PREQ_GetPrice_WSAsyncUsingParameters:getThoonsEvent
                                             SessionHeader:sessionHeader
                                            CallOptions:callOptions
                                            DebuggingHeader:debuggingHeader
                                            AllowFieldTruncationHeader:allowFieldTruncationHeader
                                            delegate:self];
    }
    else if([event_name isEqualToString:BEFORESAVE] || [event_name isEqualToString:AFTERSAVE])
    {
        
        if(appDelegate.allpagelevelEventsWithTimestamp == nil)
        {
           appDelegate.allpagelevelEventsWithTimestamp = [[NSMutableDictionary alloc] initWithCapacity:0];
        }
        if (appDelegate.sfmPageController.recordId == nil)
            appDelegate.sfmPageController.recordId = @"";
        
        
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:0];
        [dict setObject:getThoonsEvent forKey:AFTERSAVEPAGELEVELEVENT];
        [dict setObject:binding forKey:AFTERSAVEPAQGELEVELBINDING];
        
        NSDate * current_dateTime = [NSDate date];
        
        
        [appDelegate.allpagelevelEventsWithTimestamp setObject:dict forKey:current_dateTime];
        

        [dict release];
       // SMLog(@" count %d", [appDelegate.afterSavePageLevelEvents count]);
        appDelegate.wsInterface.getPrice = TRUE;
    }
}


#pragma mark - ADD RECORD FOR SFM DATA
-(void) AddRecordForLines:(NSString*) process_id ForDetailLayoutId:(NSString*) layout_id
{
    // Essentials
    
    [INTF_WebServicesDefServiceSvc initialize];
    
    INTF_WebServicesDefBinding * binding = [INTF_WebServicesDefServiceSvc INTF_WebServicesDefBindingWithServer:appDelegate.currentServerUrl];
    binding.logXMLInOut = YES;
    
    INTF_WebServicesDefServiceSvc_SessionHeader * sessionHeader = [[[INTF_WebServicesDefServiceSvc_SessionHeader alloc] init] autorelease];
    sessionHeader.sessionId = [appDelegate.loginResult sessionId];
    
    INTF_WebServicesDefServiceSvc_CallOptions * callOptions = [[[INTF_WebServicesDefServiceSvc_CallOptions alloc] init] autorelease];
    callOptions.client = nil;
    
    INTF_WebServicesDefServiceSvc_DebuggingHeader * debuggingHeader = [[[INTF_WebServicesDefServiceSvc_DebuggingHeader alloc] init] autorelease];
    debuggingHeader.debugLevel = 0;
    
    INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader * allowFieldTruncationHeader = [[[INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader alloc] init] autorelease];
    allowFieldTruncationHeader.allowFieldTruncation = NO;
    
    //Add row
    INTF_WebServicesDefServiceSvc_INTF_AddRecords_WS *AddRecordWS = [[[INTF_WebServicesDefServiceSvc_INTF_AddRecords_WS alloc] init] autorelease];
    INTF_WebServicesDefServiceSvc_INTF_Request * request = [[[INTF_WebServicesDefServiceSvc_INTF_Request alloc] init] autorelease];
    
    NSMutableArray * stringMap = [request stringMap];
 
    INTF_WebServicesDefServiceSvc_INTF_StringMap * keyMap1 = [[[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init] autorelease];
    [keyMap1 setKey:@"PROCESSID"];
    [keyMap1 setValue:process_id];
     
    [stringMap addObject:keyMap1]; 
  
    INTF_WebServicesDefServiceSvc_INTF_StringMap * keyMap2 = [[[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init] autorelease];
    [keyMap2 setKey:@"ALIAS"];
    [keyMap2 setValue:layout_id];
    
    [stringMap addObject:keyMap2];
    
    INTF_WebServicesDefServiceSvc_INTF_StringMap * keyMap3 = [[[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init] autorelease];
    [keyMap3 setKey:@"ipad"];
    [keyMap3 setValue:@""];
    
    [stringMap addObject:keyMap3];
    
    [AddRecordWS setPrequest:request];
   
    //[[ZKServerSwitchboard switchboard] doCheckSession];
    [binding INTF_AddRecords_WSAsyncUsingParameters:AddRecordWS
                                            SessionHeader:sessionHeader
                                              CallOptions:callOptions
                                          DebuggingHeader:debuggingHeader
                               AllowFieldTruncationHeader:allowFieldTruncationHeader
                                                 delegate:self];
}

-(NSMutableDictionary *)getAddRecordsFields:(INTF_WebServicesDefBindingResponse *)response
{
    if (response == nil)
        return nil;
    
    INTF_WebServicesDefServiceSvc_INTF_AddRecords_WSResponse * wsresponse = [response.bodyParts objectAtIndex:0];
    if (wsresponse == nil)
        return nil;
    
    NSMutableArray * result;
    
    NSMutableDictionary * result_dict = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
    result=  wsresponse.result;
    INTF_WebServicesDefServiceSvc_INTF_PageDataSet * r = [result objectAtIndex:0];
    if (r == nil)
        return nil;
    
    NSMutableArray * defaultValues = [r defaultObjectValue];
    if ([defaultValues count] == 0)
        return nil;
    for(int i = 0;i<[defaultValues count];i++)
    {
        INTF_WebServicesDefServiceSvc_INTF_StringMap * obj = [defaultValues objectAtIndex:i];
         NSString * key = obj.key;
         NSString * value= obj.value;
        if(key != nil && value != nil)
            [result_dict setValue:value forKey:key];
    }
    add_WS = TRUE;  
    return result_dict;
}
-(void)downloadcriteriaplist:(NSMutableDictionary *)dict
{
    
    //NSFileManager * fileManager = [NSFileManager defaultManager];
    //create SYNC_HISTORY PLIST 
    NSString * rootpath_SYNHIST = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * plistPath_SYNHIST = [rootpath_SYNHIST stringByAppendingPathComponent:DOWNLOAD_CRITERIA_PLIST];
    
   // if (![fileManager fileExistsAtPath:plistPath_SYNHIST])
    {
        [dict writeToFile:plistPath_SYNHIST atomically:YES];
    }
   // [dict release];                       
}
-(NSDictionary *)getdownloadCriteriaObjects
{
    //create SYNC_HISTORY PLIST 
    NSString * rootpath_SYNHIST = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * plistPath_SYNHIST = [rootpath_SYNHIST stringByAppendingPathComponent:DOWNLOAD_CRITERIA_PLIST];
    NSDictionary * dict = [[[NSDictionary alloc] initWithContentsOfFile:plistPath_SYNHIST] autorelease];
    return dict;
}

-(void)checkdownloadcriteria
{
    [INTF_WebServicesDefServiceSvc initialize];
    
    INTF_WebServicesDefServiceSvc_SessionHeader * sessionHeader = [[[INTF_WebServicesDefServiceSvc_SessionHeader alloc] init] autorelease];
    sessionHeader.sessionId = [[ZKServerSwitchboard switchboard] sessionId];    
    
    INTF_WebServicesDefServiceSvc_CallOptions * callOptions = [[[INTF_WebServicesDefServiceSvc_CallOptions alloc] init] autorelease];
    callOptions.client = nil;
    
    INTF_WebServicesDefServiceSvc_DebuggingHeader * debuggingHeader = [[[INTF_WebServicesDefServiceSvc_DebuggingHeader alloc] init] autorelease];
    debuggingHeader.debugLevel = 0;
    
    INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader * allowFieldTruncationHeader = [[[INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader alloc] init] autorelease];
    allowFieldTruncationHeader.allowFieldTruncation = NO;
    
    
    INTF_WebServicesDefBinding * binding = [INTF_WebServicesDefServiceSvc INTF_WebServicesDefBindingWithServer:appDelegate.currentServerUrl];
    binding.logXMLInOut = YES;
    
    INTF_WebServicesDefServiceSvc_INTF_DataSync_WS  * datasync = [[[INTF_WebServicesDefServiceSvc_INTF_DataSync_WS alloc] init] autorelease];
    
    INTF_WebServicesDefServiceSvc_INTF_SFMRequest * sfmRequest = [[[INTF_WebServicesDefServiceSvc_INTF_SFMRequest alloc] init] autorelease];
    sfmRequest.eventName = DOWNLOAD_CRITERIA_CHANGE;
    sfmRequest.eventType = @"SYNC";
    sfmRequest.userId = [appDelegate.loginResult userId];
    sfmRequest.groupId = [[appDelegate.loginResult userInfo] organizationId];
    sfmRequest.profileId = [[appDelegate.loginResult userInfo] profileId];
    
    sfmRequest.value = Insert_requestId;
    NSDictionary * dict = [self getdownloadCriteriaObjects];
    NSArray * allobjects = [dict allKeys];
    for(NSString * object_name in allobjects)
    {
        INTF_WebServicesDefServiceSvc_SVMXMap * SVMXCMap_dcObject =  [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
        SVMXCMap_dcObject.key = object_name;
        SVMXCMap_dcObject.value = [dict objectForKey:object_name];
        [sfmRequest.valueMap addObject:SVMXCMap_dcObject];
        [SVMXCMap_dcObject release];
    }
    
    //ADD SVMXClient
    INTF_WebServicesDefServiceSvc_SVMXClient  * svmxc_client = [[[INTF_WebServicesDefServiceSvc_SVMXClient alloc] init]  autorelease];
    
    svmxc_client.clientType = @"iPad";
    [svmxc_client.clientInfo addObject:@"OS:iPadOS"];
    [svmxc_client.clientInfo addObject:@"R4B2"];
    
    [sfmRequest addClientInfo:svmxc_client];
    [datasync setRequest:sfmRequest];
    
    //[[ZKServerSwitchboard switchboard] doCheckSession];
    [binding INTF_DataSync_WSAsyncUsingParameters:datasync 
                                    SessionHeader:sessionHeader 
                                      CallOptions:callOptions
                                  DebuggingHeader:debuggingHeader
                       AllowFieldTruncationHeader:allowFieldTruncationHeader delegate:self];
}

#pragma mark - INTF_WebServicesDefBindingOperation Delegate Method
- (void) operation:(INTF_WebServicesDefBindingOperation *)operation completedWithResponse:(INTF_WebServicesDefBindingResponse *)response
{
    int ret;
    SMLog(@"OPERATION COMPLETED RESPONSE");
    
    if (response.error != nil)
    {
       didCompleteAfterSaveEventCalls = YES;
       appDelegate.connection_error = TRUE;
       return;
    }
    else
    {
        appDelegate.connection_error = FALSE;
    }
    if(AfterSaveEventsCalls)
    {
        didCompleteAfterSaveEventCalls = YES;
        return;
    }
    ret = [[response.bodyParts objectAtIndex:0] isKindOfClass:[SOAPFault class]];
    if (ret)
    {
        didCompleteAfterSaveEventCalls = YES;
        appDelegate.incrementalSync_Failed = TRUE;
        SOAPFault * sFault = [response.bodyParts objectAtIndex:0];
        SMLog(@"%@", sFault.faultcode);
        SMLog(@"%@", sFault.faultstring);
        
        NSString * faultString = sFault.faultstring;
        if ([faultString Contains:@"SVMX_GetSvmxVersion"])
        {
            appDelegate.didGetVersion = YES;
            return;
        }

        if (!tagsDictionary)
        {
            tagsDictionary = [[self getDefaultTags] retain];
            SMLog (@"%@", tagsDictionary);
        }
        
        //Radha
        didOpComplete = TRUE;
        appDelegate.didincrementalmetasyncdone = TRUE;
        appDelegate.Incremental_sync_status = PUT_RECORDS_DONE;
        
        appDelegate.wsInterface.getPrice = TRUE;
        appDelegate.sfmSave = TRUE;

        appDelegate.didGetVersion = TRUE;
        didRescheduleEvent = TRUE;
        appDelegate.wsInterface.sfm_response = TRUE;
        appDelegate.wsInterface.errorLoadingSFM = TRUE;
        didGetAccountHistory = YES;
        didGetProductHistory = YES;
        appDelegate.wsInterface.getPrice = TRUE;
        add_WS = TRUE;
        didGetObjectDef = TRUE;
        didGetObjectDef = TRUE;
        didGetPageData = TRUE;
        didGetPicklistValues = TRUE;
        didGetPicklistValueDb = TRUE;
        didGetWorkOder = TRUE;
        didGetAddtionalObjDef = TRUE;
        didOpSFMSearchComplete = TRUE;
        appDelegate.didFinishWithError = TRUE;
        
        appDelegate.isSpecialSyncDone = TRUE;
        [appDelegate.dataBase setDidUserGPSLocationUpdated:YES];
    
        if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
        {
            if ([appDelegate.syncThread isExecuting])
                SMLog(@"Data Sync");
            else
                [MyPopoverDelegate performSelector:@selector(throwException)]; 
            
        }
        
        appDelegate.connection_error = TRUE;
        responseError = 1;
        [self didFinishGetEventsWithFault:sFault];
        return;
    }

    if ([response.error isKindOfClass:[NSURLErrorDomain class]])
    {
        //[appDelegate isInternetConnectionAvailable] = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:kInternetConnectionChanged object:[NSNumber numberWithInt:0] userInfo:nil];
    }

    if ([operation isKindOfClass:[INTF_WebServicesDefBinding_INTF_MetaSync_WS class]])
    {
        INTF_WebServicesDefServiceSvc_INTF_MetaSync_WSResponse * wsResponse = [response.bodyParts objectAtIndex:0];
               
        if ([wsResponse.result.eventName isEqualToString:SFM_SEARCH] && [wsResponse.result.eventType isEqualToString:SYNC])
        {
            didOpSFMSearchComplete = TRUE;
           // SMLog(@" MetaSync SFM_SEARCH received, processing starts: %@", [NSDate date]);
             [appDelegate.dataBase createTablesForSFMSearch];
            
            NSArray * array = [wsResponse.result valueMap];
             NSMutableArray *sfmProcessData = [[NSMutableArray alloc] init];
             for (int  i = 0; i < [array count]; i+=2)
             {
                 //Process Information
                 INTF_WebServicesDefServiceSvc_SVMXMap * svmxMapForProcess = [array objectAtIndex:i];
                 NSArray *processInfo = [svmxMapForProcess valueMap];
                 NSMutableDictionary *processInfoDict    = [[NSMutableDictionary alloc] init];
                 for(int j=0; j<[processInfo count]; j++)
                 {
                    INTF_WebServicesDefServiceSvc_SVMXMap * svmxMapForProcessInfo = [processInfo objectAtIndex:j]; 
                     [processInfoDict setObject:svmxMapForProcessInfo.value forKey:svmxMapForProcessInfo.key];                        
                 }
                
                 //Objects Information of above Process
                 INTF_WebServicesDefServiceSvc_SVMXMap * svmxMapForObject = [array objectAtIndex:i+1];
                 NSArray *objectInfo = [svmxMapForObject valueMap];
                 NSMutableArray *sfmObjectData = [[NSMutableArray alloc] init];
                 
                 for(int k=0; k<[objectInfo count]; k++) //4 objects
                 {
                     INTF_WebServicesDefServiceSvc_SVMXMap * svmxMapForObjectInfo = [objectInfo objectAtIndex:k]; 
                     NSArray *detailsArray = [svmxMapForObjectInfo valueMap];
                     
                     for(int l=0; l< [detailsArray count]; l+=2)// 2 maps // object map, config data
                     {
                         NSMutableDictionary *objectInfoDict    = [[NSMutableDictionary alloc] init];
                         //1st for Object Info 
                         INTF_WebServicesDefServiceSvc_SVMXMap * mapObjectInfo = [detailsArray objectAtIndex:l];
                         INTF_WebServicesDefServiceSvc_SVMXMap * objectInfoMap =  [[mapObjectInfo valueMap] objectAtIndex:0];
                         NSArray *objectInfoArray = [objectInfoMap valueMap];
                          
                         for(int m=0; m<[objectInfoArray count]; m++)
                         {
                            INTF_WebServicesDefServiceSvc_SVMXMap * objectInfo = [objectInfoArray objectAtIndex:m];
                             [objectInfoDict setObject:objectInfo.value forKey:objectInfo.key];
                         }
                         //2nd for Config Data. save this in array of dicts
                         INTF_WebServicesDefServiceSvc_SVMXMap * mapObjectConfig = [detailsArray objectAtIndex:l+1];
                         NSArray *configMapArray = [mapObjectConfig valueMap];
                        // SMLog(@"Count = %d",[configMapArray count]);
                         NSMutableArray *configMutableArray = [[NSMutableArray alloc] init];
                         for(int n=0; n<[configMapArray count]; n++)
                         {
                             INTF_WebServicesDefServiceSvc_SVMXMap * configDataMap = [configMapArray objectAtIndex:n];
                             NSArray *configDataArray = [configDataMap valueMap];
                             NSMutableDictionary *configDataDict = [[NSMutableDictionary alloc] init];
                             for(int p =0; p< [configDataArray count]; p++)
                             {
                                 INTF_WebServicesDefServiceSvc_SVMXMap * cnfgMap = [configDataArray objectAtIndex:p];
                                 [configDataDict setObject:cnfgMap.value forKey:cnfgMap.key];
                             }
                             [configMutableArray addObject:configDataDict];
                             [configDataDict release];
                         }
                         [objectInfoDict setObject:configMutableArray forKey:@"ConfigData"];
                         [sfmObjectData addObject:objectInfoDict];
                         [configMutableArray release];
                         [objectInfoDict release];
                     }                          
                 }
              //   SMLog(@"Object Data = %@",sfmObjectData);
                 [processInfoDict setObject:sfmObjectData forKey:@"Objects"];
                 [sfmProcessData addObject:processInfoDict];
                 [processInfoDict release];
             }
         //   SMLog(@" MetaSync SFM_SEARCH processing End: %@", [NSDate date]);
            //Call Data Base with data to store the info in table
            [appDelegate.dataBase insertValuesintoSFMProcessTable:sfmProcessData];
           // SMLog(@"SFM Search Configuration = %@",sfmProcessData);
            [sfmProcessData release];
             
        }
        
        if ([wsResponse.result.eventName isEqualToString:VALIDATE_PROFILE])
        {
            if ([wsResponse.result.values count] > 0)
                appDelegate.userProfileId = [wsResponse.result.values objectAtIndex:0];
            
            appDelegate.didCheckProfile = TRUE;
        }
            
        
        if ([wsResponse.result.eventName isEqualToString:SFM_METADATA])
        {            
            //SMLog(@"SAMMAN MetaSync SFM_METADATA received, processing starts: %@", [NSDate date]);
            NSMutableArray * keys = [[NSMutableArray alloc] initWithCapacity:0];
            NSMutableArray * values = [[NSMutableArray alloc] initWithCapacity:0];
            NSMutableArray * arr = [[NSMutableArray alloc] initWithCapacity:0];
            
            NSMutableArray * _keys = [[NSMutableArray alloc] initWithCapacity:0];
            NSMutableArray * _values = [[NSMutableArray alloc] initWithCapacity:0];
            
            NSString * keyValue = nil;
            
            NSMutableArray * array = [wsResponse.result valueMap];  
            
            for (int  i = 0; i < [array count]; i++)
            {
                INTF_WebServicesDefServiceSvc_SVMXMap * svmxMap = [array objectAtIndex:i];
                
                NSMutableArray * svmxValues = [svmxMap valueMap];
                
                for (int k = 0; k < [svmxValues count]; k++)
                {
                    INTF_WebServicesDefServiceSvc_SVMXMap * mapValue = [svmxValues objectAtIndex:k];
                    
                    NSMutableArray * processValues = [mapValue valueMap];
                    
                    
                    for (int m = 0; m < [processValues count]; m++)
                    {
                        INTF_WebServicesDefServiceSvc_SVMXMap * processSvmx = [processValues objectAtIndex:m];
                        
                        if (!([processSvmx.key isEqualToString:nil] && [processSvmx.key isEqualToString:@""]))
                        {
                            keyValue = processSvmx.key;
                        }
                        NSMutableArray * svmxMapValue = [processSvmx valueMap];
                        
                        for (int s = 0; s < [svmxMapValue count]; s++)
                        {
                            INTF_WebServicesDefServiceSvc_SVMXMap * mapSvmx = [svmxMapValue objectAtIndex:s];
                            
                            NSString * key = (mapSvmx.key) != nil? mapSvmx.key:@"";
                            NSString * value = (mapSvmx.value) != nil? mapSvmx.value:@"";
                            
                            if (![key isEqualToString:@""])
                            {
                                if (keyValue == nil)
                                    keyValue = key;
                            }
                            NSMutableArray * valuesMaps = [mapSvmx valueMap];
                            
                            for (int temp = 0; temp < [valuesMaps count]; temp++)
                            {
                                INTF_WebServicesDefServiceSvc_SVMXMap * value_map = [valuesMaps objectAtIndex:temp];
                                
                                key = (value_map.key) != nil? value_map.key:@"";
                                value = (value_map.value) != nil? value_map.value:@"";
                                
                                if (![key isEqualToString:@""])
                                {
                                    [keys addObject:key];
                                    [values addObject:value];
                                }
                                
                                NSMutableArray * value_map_array = [value_map valueMap];
                                
                                for (int r = 0; r < [value_map_array count]; r++)
                                {
                                    INTF_WebServicesDefServiceSvc_SVMXMap * _SVMXMap = [value_map_array objectAtIndex:r];
                                    
                                    key = (_SVMXMap.key) != nil? _SVMXMap.key:@"";
                                    value = (_SVMXMap.value) != nil? _SVMXMap.value:@"";
                                    
                                    if (![key isEqualToString:@""])
                                    {
                                        [_keys addObject:key];
                                        [_values addObject:value];
                                    }
                                }
                                if ([_keys count] > 0)
                                {
                                    NSDictionary * dict = [NSDictionary dictionaryWithObjects:_values forKeys:_keys];
                                    [arr addObject:dict];
                                    [_keys removeAllObjects];
                                    if ([_values count] > 0)
                                        [_values removeAllObjects];
                                }
                            }
                            if ([keys count] > 0)
                            {
                                NSDictionary * dict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
                                [arr addObject:dict];
                                [keys removeAllObjects];
                                [values removeAllObjects];
                            }
                            else if ([arr count] > 0)
                            {
                                NSMutableArray * valueArray = [NSMutableArray arrayWithArray:arr];
                                
                                NSArray * allkeys_ = [processDictionary allKeys];
                                BOOL key_exists= FALSE;
                                
                                for(NSString * str in allkeys_)
                                {
                                    if([str isEqualToString:keyValue])
                                    {
                                        key_exists = TRUE;
                                        break;
                                    }
                                }
                                
                                if(key_exists)
                                {
                                    NSMutableArray * new_arr = [processDictionary objectForKey:keyValue];
                                    for (NSDictionary * dict in valueArray)
                                    {
                                        [new_arr addObject:dict];
                                    }

                                }
                                else
                                {
                                     [processDictionary setValue:valueArray forKey:keyValue];
                                }
                             /*   NSArray * getValues = [processDictionary objectForKey:keyValue];
                                
                                NSMutableArray * getValues_mutable = [NSMutableArray arrayWithArray:getValues];
                                
                                if ([getValues_mutable count] > 0)
                                {
                                    for (NSDictionary * dict in valueArray)
                                    {
                                        [getValues_mutable addObject:dict];
                                    }
                                    [processDictionary setValue:getValues forKey:keyValue];
                                }
                                else
                                    [processDictionary setValue:valueArray forKey:keyValue];*/
                                
                                
                                keyValue = nil;
                                [arr removeAllObjects];
                            }
                            
                        }
                        if ([arr count] > 0)
                        {
                           /* NSArray * valueArray = [NSArray arrayWithArray:arr];
                            
                        
                            NSArray * getValues = [processDictionary objectForKey:keyValue];
                            
                            NSMutableArray * getValues_mutable = [NSMutableArray arrayWithArray:getValues];
                            
                            if ([getValues_mutable count] > 0)
                            {
                                for (NSDictionary * dict in valueArray)
                                {
                                    [getValues_mutable addObject:dict];
                                }
                                [processDictionary setValue:getValues forKey:keyValue];
                            }
                            else
                                [processDictionary setValue:valueArray forKey:keyValue];
                            keyValue = nil;
                            [arr removeAllObjects];*/
                            
                            NSMutableArray * valueArray = [NSMutableArray arrayWithArray:arr];
                            
                            NSArray * allkeys_ = [processDictionary allKeys];
                            BOOL key_exists= FALSE;
                            
                            for(NSString * str in allkeys_)
                            {
                                if([str isEqualToString:keyValue])
                                {
                                    key_exists = TRUE;
                                    break;
                                }
                            }
                            
                            if(key_exists)
                            {
                                NSMutableArray * new_arr = [processDictionary objectForKey:keyValue];
                                for (NSDictionary * dict in valueArray)
                                {
                                    [new_arr addObject:dict];
                                }
                                
                            }
                            else
                            {
                                [processDictionary setValue:valueArray forKey:keyValue];
                            }
                            /*   NSArray * getValues = [processDictionary objectForKey:keyValue];
                             
                             NSMutableArray * getValues_mutable = [NSMutableArray arrayWithArray:getValues];
                             
                             if ([getValues_mutable count] > 0)
                             {
                             for (NSDictionary * dict in valueArray)
                             {
                             [getValues_mutable addObject:dict];
                             }
                             [processDictionary setValue:getValues forKey:keyValue];
                             }
                             else
                             [processDictionary setValue:valueArray forKey:keyValue];*/
                            
                            
                            keyValue = nil;
                            [arr removeAllObjects];
                        }
                    }
                }
            } 
            
            NSArray * value = wsResponse.result.values;
            
            NSString * processValue = @"";
            
            if ((value != nil) && [value count] > 0)
                processValue = ([value objectAtIndex:0] != nil)?[value objectAtIndex:0]:@"";
            
            if (![processValue isEqualToString:@""])
            {
                appDelegate.initial_sync_status = SYNC_SFM_METADATA;
                appDelegate.Sync_check_in = FALSE;
                [self metaSyncWithEventName:SFM_METADATA eventType:SYNC values:(NSMutableArray *)value];
            }
            else
            {
                appDelegate.initial_sync_status = SYNC_SFM_METADATA_DONE;
                appDelegate.Sync_check_in = FALSE;
                
                appDelegate.initial_sync_status = SYNC_SFM_PAGEDATA;
                appDelegate.Sync_check_in = FALSE;
                
                NSMutableArray * pageId = [self getAllPageLauoutId];
                
                [self metaSyncWithEventName:SFM_PAGEDATA eventType:SYNC values:pageId];

                didGetPageData = FALSE;
            }
        }
        else if ([wsResponse.result.eventName isEqualToString:SFM_PAGEDATA])    
        {
            didGetPageData = TRUE;
            
            NSMutableDictionary * headerDataDict = nil;
            
            NSMutableDictionary * hdrData = [[NSMutableDictionary alloc] initWithCapacity:0];
            
            
            NSMutableArray * pageArray = [wsResponse.result pageUI];
            
            for (int i = 0; i < [pageArray count]; i++)
            {
                INTF_WebServicesDefServiceSvc_INTF_Response_PageUI * pageUI =  [pageArray objectAtIndex:i];
                
                INTF_WebServicesDefServiceSvc_INTF_PageUI * page = [pageUI page];
                
                NSMutableArray * details = [page details];
                NSMutableArray * detailDataArray = [[NSMutableArray alloc] initWithCapacity:0];
                for ( int j = 0; j < [details count]; j++)
                {
                    NSMutableArray * fieldDetailArray = [[NSMutableArray alloc] initWithCapacity:0];

                    INTF_WebServicesDefServiceSvc_INTF_PageDetail * pageDetail = [details objectAtIndex:j];
                    
                    
                    for (int k = 0; k < [pageDetail.fields count]; k++)
                    {
                        INTF_WebServicesDefServiceSvc_INTF_UIField * detailUiField = [pageDetail.fields objectAtIndex:k];
                        
                        NSMutableArray * detailFieldKeys = [NSMutableArray arrayWithObjects:
                                                            gFIELD_API_NAME,
                                                            gFIELD_DISPLAY_COLUMN,
                                                            gFIELD_DISPLAY_ROW,
                                                            gFIELD_READ_ONLY,
                                                            gFIELD_REQUIRED,
                                                            gFIELD_LOOKUP_CONTEXT,
                                                            gFIELD_LOOKUP_QUERY,
                                                            gFIELD_SEQUENCE,
                                                            gFIELD_RELATED_OBJECT_SEARCH_ID,
                                                            gFIELD_RELATED_OBJECT_NAME,
                                                            gFIELD_DATA_TYPE,
                                                            gFIELD_LABEL,
                                                            gFIELD_VALUE_KEY,
                                                            gFIELD_VALUE_VALUE,
                                                            gFIELD_OVERRIDE_RELATED_LOOKUP,
                                                            nil];
                        
                        
                        NSMutableArray * detailFieldObjects = [NSMutableArray arrayWithObjects:
                                                               (detailUiField.fieldDetail.SVMXC__Field_API_Name__c != nil)?detailUiField.fieldDetail.SVMXC__Field_API_Name__c:@"",
                                                               (detailUiField.fieldDetail.SVMXC__Display_Column__c != nil)?detailUiField.fieldDetail.SVMXC__Display_Column__c:@"",
                                                               (detailUiField.fieldDetail.SVMXC__Display_Row__c != nil)?detailUiField.fieldDetail.SVMXC__Display_Row__c:@"",
                                                               [NSNumber numberWithBool:detailUiField.fieldDetail.SVMXC__Readonly__c.boolValue],
                                                               [NSNumber numberWithBool:detailUiField.fieldDetail.SVMXC__Required__c.boolValue],
                                                               (detailUiField.fieldDetail.SVMXC__Lookup_Context__c != nil)?detailUiField.fieldDetail.SVMXC__Lookup_Context__c:@"",
                                                               (detailUiField.fieldDetail.SVMXC__Lookup_Query_Field__c != nil)?detailUiField.fieldDetail.SVMXC__Lookup_Query_Field__c:@"",
                                                               (detailUiField.fieldDetail.SVMXC__Sequence__c != nil)?detailUiField.fieldDetail.SVMXC__Sequence__c:@"",
                                                               (detailUiField.fieldDetail.SVMXC__Named_Search__c != nil)?detailUiField.fieldDetail.SVMXC__Named_Search__c:@"",
                                                               (detailUiField.fieldDetail.SVMXC__Related_Object_Name__c != nil)?detailUiField.fieldDetail.SVMXC__Related_Object_Name__c:@"",
                                                               (detailUiField.fieldDetail.SVMXC__DataType__c != nil)?detailUiField.fieldDetail.SVMXC__DataType__c:@"",
                                                               @"",
                                                               @"",
                                                               @"",
                                                               [NSNumber numberWithInt:detailUiField.fieldDetail.SVMXC__Override_Related_Lookup__c.boolValue], 
                                                               nil];
                        
                        NSMutableDictionary * fieldDetailDict = [NSMutableDictionary dictionaryWithObjects:detailFieldObjects forKeys:detailFieldKeys];
                        
                        
                        [fieldDetailArray addObject:fieldDetailDict];
                        
                    }
                    //sort the array according to the sequence no
                    if([fieldDetailArray count] > 1)
                    {
                        for(int x = 0; x < [fieldDetailArray count]; x++)
                        {
                            for(int y = 0; y < [fieldDetailArray count]-1; y++)
                            {
                                NSDictionary * dict = [fieldDetailArray objectAtIndex:y];
                                NSString * sequence=[dict objectForKey:gFIELD_SEQUENCE];
                                NSInteger sequence_no = [sequence integerValue];
                                NSDictionary *dict_nxt = [fieldDetailArray objectAtIndex:y+1];
                                NSString * sequence_nxt=[dict_nxt objectForKey:gFIELD_SEQUENCE];
                                NSInteger sequence_no_nxt = [sequence_nxt integerValue];
                                if(sequence_no > sequence_no_nxt)
                                    [fieldDetailArray exchangeObjectAtIndex:y withObjectAtIndex:y+1];
                            }
                            
                        }
                    }
                    
                    NSMutableArray * detailsValuesArray = [[NSMutableArray alloc] initWithCapacity:0];
                    NSMutableArray * detailValuesId = [[NSMutableArray alloc] initWithCapacity:0];
                    NSMutableArray * detail_deleted_rec = [[NSMutableArray alloc] initWithCapacity:0];
                    
                    NSString * detail_header_info = pageDetail.DetailLayout.SVMXC__Header_Reference_Field__c;
                    NSString * detail_object_name = pageDetail.DetailLayout.SVMXC__Object_Name__c;
                    NSString * detail_object_alias_name = pageDetail.DetailLayout.SVMXC__Name__c;
                    NSString * detail_multi_add_config = pageDetail.DetailLayout.SVMXC__Multi_Add_Configuration__c;
                    NSString * detail_multi_add_search_field = pageDetail.DetailLayout.SVMXC__Multi_Add_Search_Field__c;
                    NSString * detail_mutlti_add_search_object = pageDetail.DetailLayout.SVMXC__Multi_Add_Search_Object__c;
                    
                    NSMutableArray * detailKeys = [NSMutableArray arrayWithObjects:
                                                   gDETAILS_FIELDS_ARRAY,
                                                   gDETAILS_VALUES_ARRAY,
                                                   gDETAILS_LAYOUT_ID,
                                                   gDETAILS_ALLOW_NEW_LINES,
                                                   gDETAILS_ALLOW_DELETE_LINES,
                                                   gDETAILS_NUMBER_OF_COLUMNS,
                                                   gDETAILS_OBJECT_LABEL,
                                                   gDETAIL_VALUES_RECORD_ID,
                                                   gDETAIL_HEADER_REFERENCE_FIELD,
                                                   gDETAIL_OBJECT_NAME,
                                                   gDETAIL_SEQUENCE_NO,
                                                   gDETAIL_OBJECT_ALIAS_NAME,
                                                   gDETAIL_DELETED_RECORDS,
                                                   gDetail_MULTIADD_CONFIG,
                                                   gDETAIL_MULTIADD_SEARCH,
                                                   gDETAIL_MULTIADD_SEARCH_OBJECT,
                                                   nil];
                    
                    NSMutableArray * detailObjects = [NSMutableArray arrayWithObjects:
                                                      fieldDetailArray,
                                                      detailsValuesArray,
                                                      (pageDetail.dtlLayoutId != nil)?pageDetail.dtlLayoutId:@"",
                                                      [NSNumber numberWithBool:pageDetail.DetailLayout.SVMXC__Allow_New_Lines__c.boolValue],
                                                      [NSNumber numberWithBool:pageDetail.DetailLayout.SVMXC__Allow_Delete_Lines__c.boolValue],
                                                      (pageDetail.noOfColumns != nil)?pageDetail.noOfColumns:@"",
                                                      (pageDetail.DetailLayout.SVMXC__Name__c != nil)?pageDetail.DetailLayout.SVMXC__Name__c:@"",
                                                      detailValuesId,
                                                      (detail_header_info != nil)?detail_header_info:@"",
                                                      (detail_object_name != nil)?detail_object_name:@"",
                                                      (pageDetail.DetailLayout.SVMXC__Sequence__c != nil) ? pageDetail.DetailLayout.SVMXC__Sequence__c:@"",
                                                      (detail_object_alias_name != nil)?detail_object_alias_name:@"",
                                                      detail_deleted_rec,
                                                      (detail_multi_add_config != nil)?detail_multi_add_config:@"",
                                                      (detail_multi_add_search_field!= nil)?detail_multi_add_search_field:@"",
                                                      (detail_mutlti_add_search_object!= nil)?detail_mutlti_add_search_object:@"",      
                                                      nil];
                    
                    NSMutableDictionary * detailsDataDict = [[NSMutableDictionary dictionaryWithObjects:detailObjects forKeys:detailKeys] retain];
                    
                    [detailDataArray addObject:detailsDataDict];
                    [fieldDetailArray release];
                }
                if([detailDataArray count] >1)
                {
                    for(int x = 0; x < [detailDataArray count]; x++)
                    {
                        for(int y = 0; y < [detailDataArray count]-1; y++)
                        {
                            NSDictionary * dict = [detailDataArray objectAtIndex:y];
                            NSString * sequence = [dict objectForKey:gDETAIL_SEQUENCE_NO];
                            NSInteger sequence_no = [sequence integerValue];
                            NSDictionary *dict_nxt = [detailDataArray objectAtIndex:y+1];
                            NSString * sequence_nxt=[dict_nxt objectForKey:gDETAIL_SEQUENCE_NO];
                            NSInteger sequence_no_nxt = [sequence_nxt integerValue];
                            if(sequence_no > sequence_no_nxt)
                                [detailDataArray exchangeObjectAtIndex:y withObjectAtIndex:y+1];
                        }
                    }
                }
                
                INTF_WebServicesDefServiceSvc_INTF_PageHeader * header = [page header];
                NSMutableArray * hdrSections = [[NSMutableArray alloc] initWithCapacity:0];
                NSMutableArray * buttons_array = [[NSMutableArray alloc] initWithCapacity:0];
                NSMutableArray * hdrButtons = nil;  
                
                //Get Price Radha
                for ( INTF_WebServicesDefServiceSvc_INTF_UIButton * button in header.buttons)
                {
                    NSMutableArray * buttonEventsArray = nil;
                    
                    for (int be = 0; be < [button.buttonEvents count]; be++)
                    {
                        INTF_WebServicesDefServiceSvc_SVMXC__SFM_Event__c * bEvent = [button.buttonEvents objectAtIndex:be];
                        
                        NSMutableArray * beKeys = [NSMutableArray arrayWithObjects:
                                                   gBUTTON_EVENT_TARGET_CALL,
                                                   gBUTTON_EVENT_CALL_TYPE,
                                                   gBUTTON_EVENT_TYPE,
                                                   nil];
                        NSMutableArray * beObjects = [NSMutableArray arrayWithObjects:
                                                      (bEvent.SVMXC__Target_Call__c != nil)?bEvent.SVMXC__Target_Call__c:@"",
                                                      (bEvent.SVMXC__Event_Call_Type__c != nil)?bEvent.SVMXC__Event_Call_Type__c:@"",
                                                      (bEvent.SVMXC__Event_Type__c != nil)?bEvent.SVMXC__Event_Type__c:@"",
                                                      nil];
                        NSMutableDictionary * dict = [[NSMutableDictionary dictionaryWithObjects:beObjects forKeys:beKeys] retain];
                        
                        if (buttonEventsArray == nil)
                            buttonEventsArray = [[NSMutableArray alloc] initWithCapacity:0];
                        
                        [buttonEventsArray addObject:dict];
                    }
                    
                    
                    NSMutableArray * buttonKeys = [NSMutableArray arrayWithObjects:
                                                   gBUTTON_TITLE,
                                                   gBUTTON_EVENTS,
                                                   gBUTTON_EVENT_ENABLE,
                                                   nil];
                    
                    NSMutableArray * buttonObjects = [NSMutableArray arrayWithObjects:
                                                      (button.buttonDetail.SVMXC__Title__c != nil)?button.buttonDetail.SVMXC__Title__c:@"",
                                                      (buttonEventsArray != nil)?buttonEventsArray:[[NSMutableArray alloc] initWithCapacity:0], 
                                                      (button.enable != nil)?[NSNumber numberWithBool:button.enable.boolValue]:[NSNumber numberWithInt:1], nil];
                    
                    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:buttonObjects forKeys:buttonKeys];
                    
                    
                    [buttons_array addObject:dict];
                    
                    hdrButtons = [NSMutableArray arrayWithArray:buttons_array];
                    
                   // SMLog(@"buttons");
                }

                
                for (int i = 0; i < [header.sections count]; i++)
                {
                    NSMutableArray * hdrSectionFields = nil;
                    INTF_WebServicesDefServiceSvc_INTF_UISection * section = [header.sections objectAtIndex:i];
                    
                    NSMutableArray * fields = [section fields];
                    
                    for (int j = 0; j < [fields count]; j++)
                    {
                        INTF_WebServicesDefServiceSvc_INTF_UIField * uiField = [fields objectAtIndex:j];
                        NSMutableArray * hdrSectionFieldKeys = [NSMutableArray arrayWithObjects:
                                                                @"Name",
                                                                gFIELD_API_NAME,
                                                                gFIELD_DISPLAY_COLUMN,
                                                                gFIELD_DISPLAY_ROW,
                                                                gFIELD_READ_ONLY,
                                                                gFIELD_REQUIRED,
                                                                gFIELD_LOOKUP_CONTEXT,
                                                                gFIELD_LOOKUP_QUERY,
                                                                gFIELD_SEQUENCE,
                                                                gFIELD_RELATED_OBJECT_SEARCH_ID,
                                                                gFIELD_RELATED_OBJECT_NAME,
                                                                gFIELD_DATA_TYPE,
                                                                gFIELD_LABEL,
                                                                gFIELD_VALUE_KEY,
                                                                gFIELD_VALUE_VALUE,
                                                                gSLA_CLOCK,
                                                                gFIELD_OVERRIDE_RELATED_LOOKUP,
                                                                nil];
                        
                        NSMutableArray * hdrSectionFieldValues = [NSMutableArray arrayWithObjects:
                                                                  (uiField.fieldDetail.Name != nil)?uiField.fieldDetail.Name:@"",
                                                                  (uiField.fieldDetail.SVMXC__Field_API_Name__c != nil)?uiField.fieldDetail.SVMXC__Field_API_Name__c:@"",
                                                                  (uiField.fieldDetail.SVMXC__Display_Column__c != nil)?uiField.fieldDetail.SVMXC__Display_Column__c:@"",
                                                                  (uiField.fieldDetail.SVMXC__Display_Row__c != nil)?uiField.fieldDetail.SVMXC__Display_Row__c:@"",
                                                                  [NSNumber numberWithBool:uiField.fieldDetail.SVMXC__Readonly__c.boolValue],
                                                                  [NSNumber numberWithBool:uiField.fieldDetail.SVMXC__Required__c.boolValue],
                                                                  (uiField.fieldDetail.SVMXC__Lookup_Context__c != nil)?uiField.fieldDetail.SVMXC__Lookup_Context__c:@"",
                                                                  (uiField.fieldDetail.SVMXC__Lookup_Query_Field__c != nil)?uiField.fieldDetail.SVMXC__Lookup_Query_Field__c:@"",
                                                                  (uiField.fieldDetail.SVMXC__Sequence__c != nil)?uiField.fieldDetail.SVMXC__Sequence__c:@"",
                                                                  (uiField.fieldDetail.SVMXC__Named_Search__c != nil) ? uiField.fieldDetail.SVMXC__Named_Search__c :@"", 
                                                                  (uiField.fieldDetail.SVMXC__Related_Object_Name__c != nil)?uiField.fieldDetail.SVMXC__Related_Object_Name__c:@"",
                                                                  (uiField.fieldDetail.SVMXC__DataType__c != nil)?uiField.fieldDetail.SVMXC__DataType__c:@"",
                                                                  @"",
                                                                  @"",
                                                                  @"",
                                                                  [NSNumber numberWithBool:uiField.fieldDetail.SVMXC__Use_For_SLA_Clock__c.boolValue],
                                                                  [NSNumber numberWithInt:uiField.fieldDetail.SVMXC__Override_Related_Lookup__c.boolValue],
                                                                  nil];
                        
                        if (hdrSectionFields == nil)
                            hdrSectionFields = [[NSMutableArray alloc] initWithCapacity:0];
                        
                        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:hdrSectionFieldValues forKeys:hdrSectionFieldKeys];
                        
                        [hdrSectionFields addObject:dict];
                    }
                    
                    NSMutableArray * hdrSectionKeys = [NSMutableArray arrayWithObjects:
                                                       gSECTION_NUMBER_OF_COLUMNS,
                                                       gSECTION_TITLE,
                                                       gSECTION_SEQUENCE,
                                                       gSECTION_FIELDS,
                                                       gSLA_CLOCK,
                                                       nil];
                    NSMutableArray * hdrSectionValues = [NSMutableArray arrayWithObjects:
                                                         (section.sectionDetail.SVMXC__No_Of_Columns__c != nil)?section.sectionDetail.SVMXC__No_Of_Columns__c:@"",
                                                         (section.sectionDetail.SVMXC__Title__c != nil)?section.sectionDetail.SVMXC__Title__c:@"",
                                                         (section.sectionDetail.SVMXC__Sequence__c != nil)?section.sectionDetail.SVMXC__Sequence__c:@"",
                                                         (hdrSectionFields != nil)?hdrSectionFields:[[NSMutableArray alloc] initWithCapacity:0],
                                                         [NSNumber numberWithBool:section.sectionDetail.SVMXC__Use_For_SLA_Clock__c.boolValue],      
                                                         nil];
                    
                    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:hdrSectionValues forKeys:hdrSectionKeys];
                    
                    [hdrSections addObject:dict];
                }
                
                //sahana   sfm  page leevents
                NSMutableArray * pageLevelEvents = header.pageEvents;
                NSMutableArray * sfmPageEvents = [[NSMutableArray alloc] initWithCapacity:0];
                for(int i = 0 ;i< [pageLevelEvents count]; i++)
                {
                    INTF_WebServicesDefServiceSvc_SVMXC__SFM_Event__c * eventDetail = [pageLevelEvents objectAtIndex:i];
                    NSMutableDictionary * eventsDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
                    [eventsDictionary setObject:((eventDetail.Name != nil)?eventDetail.Name:@"") forKey:gEVENT_NAME];
                    [eventsDictionary setObject:((eventDetail.SVMXC__Event_Type__c != nil)?eventDetail.SVMXC__Event_Type__c:@"") forKey:gEVENT_TYPE];
                    [eventsDictionary setObject:((eventDetail.SVMXC__Target_Call__c != nil)?eventDetail.SVMXC__Target_Call__c:@"") forKey:gEVENT_TARGET_CALL];
                    [eventsDictionary setObject:((eventDetail.SVMXC__Event_Id__c != nil)?eventDetail.SVMXC__Event_Id__c:@"") forKey:gEVENT_ID];
                    [eventsDictionary setObject:((eventDetail.SVMXC__Page_Layout__c != nil)?eventDetail.SVMXC__Page_Layout__c:@"") forKey:gEVENT_LAYOUT_ID];
                    [sfmPageEvents addObject:eventsDictionary];
                    [eventsDictionary release];
                }

                NSMutableArray * hdrLayoutKeys = [NSMutableArray arrayWithObjects:
                                                  gSVMXCX1__Page_Layout_ID__c,
                                                  gSVMXCX1__Name__c,
                                                  gHEADER_OBJECT_NAME,
                                                  gHEADER_ALLOW_NEW_LINES,
                                                  gHEADER_ALLOW_DELETE_LINES,
                                                  gHEADER_IS_STANDARD,
                                                  gHEADER_ACTION_ON_ZERO_LINES,
                                                  gHEADER_SECTIONS,
                                                  gHEADER_BUTTONS,
                                                  gHEADER_HEADER_LAYOUT_ID,
                                                  gHEADER_EVENTS,
                                                  gHEADER_NAME,
                                                  gHEADER_OWNER_ID,
                                                  gHEADER_ENABLE_ATTACHMENTS,
                                                  gENABLE_CHATTER,
                                                  gENABLE_TROUBLESHOOTING,
                                                  gENABLE_SUMMARY,
                                                  gENABLE_SUMMURY_GENERATION,
                                                  gHEADER_SHOW_ALL_SECTIONS_BY_DEFAULT,
                                                  gHEADER_SHOW_PRODUCT_HISTORY,
                                                  gHEADER_SHOW_ACCOUNT_HISTORY,
                                                  gHEADER_OBJECT_LABEL,
                                                  gHEADER_ID,
                                                  gSVMXC__Resolution_Customer_By__c,
                                                  gSVMXC__Restoration_Customer_By__c,
                                                  gHEADER_SHOW_HIDE_QUICK_SAVE,
                                                  gHEADER_SHOW_HIDE_SAVE,
                                                  gHEADER_DATA,
                                                  gPAGELEVEL_EVENTS,
                                                  nil];
                
                NSString * resolution = [hdrData objectForKey:gSVMXC__Resolution_Customer_By__c];
                if ((resolution == nil) || [resolution isKindOfClass:[NSNull class]])
                    resolution = @"";
                NSString * restoration = [hdrData objectForKey:gSVMXC__Restoration_Customer_By__c];
                if ((restoration == nil) || [restoration isKindOfClass:[NSNull class]])
                    restoration = @"";
                
                NSMutableArray * hdrLayoutObjects = [NSMutableArray arrayWithObjects:
                                                     (header.headerLayout.SVMXC__Page_Layout_ID__c != nil)?header.headerLayout.SVMXC__Page_Layout_ID__c:@"",
                                                     (header.headerLayout.SVMXC__Name__c != nil)?header.headerLayout.SVMXC__Name__c
                                                                                    :@"",
                                                     (header.headerLayout.SVMXC__Object_Name__c != nil)?header.headerLayout.SVMXC__Object_Name__c:@"",
                                                     [NSNumber numberWithBool:header.headerLayout.SVMXC__Allow_New_Lines__c.boolValue],
                                                     [NSNumber numberWithBool:header.headerLayout.SVMXC__Allow_Delete_Lines__c.boolValue],
                                                     [NSNumber numberWithBool:header.headerLayout.SVMXC__IsStandard__c.boolValue],
                                                     (header.headerLayout.SVMXC__Action_On_Zero_Lines__c != nil)?header.headerLayout.SVMXC__Action_On_Zero_Lines__c:@"",
                                                     hdrSections,
                                                     (hdrButtons != nil)?hdrButtons:[[NSMutableArray alloc] initWithCapacity:0],
                                                     (header.hdrLayoutId != nil)?header.hdrLayoutId:@"",
                                                     //(header.pageEvents != nil)?header.pageEvents:[[NSMutableArray alloc] initWithCapacity:0],
                                                     @"",
                                                     (header.headerLayout.Name != nil)?header.headerLayout.Name:@"",
                                                     (header.headerLayout.OwnerId != nil)?header.headerLayout.OwnerId:@"",
                                                     [NSNumber numberWithBool:header.headerLayout.SVMXC__Enable_Attachments__c.boolValue],
                                                     [NSNumber numberWithBool:header.headerLayout.SVMXC__Enable_Chatter__c.boolValue],
                                                     [NSNumber numberWithBool:header.headerLayout.SVMXC__Enable_Troubleshooting__c.boolValue],
                                                     [NSNumber numberWithBool:header.headerLayout.SVMXC__Enable_Service_Report_View__c.boolValue],
                                                     [NSNumber numberWithBool:header.headerLayout.SVMXC__Enable_Service_Report_Generation__c.boolValue],
                                                     [NSNumber numberWithBool:header.headerLayout.SVMXC__Show_All_Sections_By_Default__c.boolValue],
                                                     [NSNumber numberWithBool:header.headerLayout.SVMXC__Show_Product_History__c.boolValue],
                                                     [NSNumber numberWithBool:header.headerLayout.SVMXC__Show_Account_History__c.boolValue],
                                                     @"",
                                                     @"",
                                                     resolution,
                                                     restoration,
                                                     [NSNumber numberWithBool:header.headerLayout.SVMXC__Hide_Quick_Save__c.boolValue],
                                                     [NSNumber numberWithBool:header.headerLayout.SVMXC__Hide_Save__c.boolValue],
                                                     hdrData,
                                                     sfmPageEvents,
                                                     nil];
                
                headerDataDict = [NSMutableDictionary dictionaryWithObjects:hdrLayoutObjects forKeys:hdrLayoutKeys];

                NSMutableArray * keys = [NSMutableArray arrayWithObjects:gPROCESS_TITLE, gHEADER, gDETAILS,gPROCESSTYPE, nil];
                NSMutableArray * objects = [NSMutableArray arrayWithObjects:(page.processTitle != nil)?page.processTitle:@"",
                                            headerDataDict,
                                            detailDataArray,
                                            @"",       
                                            nil];
                
                NSMutableDictionary * pageDict = [NSMutableDictionary dictionaryWithObjects:objects forKeys:keys];
                
                [pageUiHistory addObject:pageDict];
                    
             /*   if (keys != nil)
                    [keys release];
                if (objects != nil)
                    [objects release];
                                
                if (headerDataDict != nil)
                    [headerDataDict release];
                if (detailDataArray != nil)
                    [detailDataArray release];
                if (hdrSections != nil)
                    [hdrSections release]; 
                
            
                NSArray * arr1 = [NSArray arrayWithObject:pageDict];
                
                [pageUiHistory addObjectsFromArray:arr1];
                if ([arr1 count]> 0)
                    [arr1 release];
                if (pageDict)
                    [pageDict release]; */
            }
            
            //   if(hdrSections != nil)
            //      [hdrSections release];
            /*  if (hdrData != nil)
                [hdrData release];
            if (hdrButtons != nil)
                [hdrButtons release];*/
            NSMutableArray * resultValues = [wsResponse.result values];
            if ([resultValues count] > 0)
            {
                didGetPageData = FALSE;
                [self metaSyncWithEventName:SFM_PAGEDATA eventType:SYNC values:resultValues];

            }
            else
            {
                didGetPageDataDb = FALSE;
                [appDelegate.dataBase insertValuesToProcessTable:processDictionary page:pageUiHistory];
            
                appDelegate.initial_sync_status = SYNC_SFMOBJECT_DEFINITIONS;
                appDelegate.Sync_check_in = FALSE;

                NSMutableArray * _values = [self getAllProcessId];
                
                [self metaSyncWithEventName:SFM_OBJECT_DEFINITIONS eventType:SYNC values:_values]; 
            }
        }
        
        else if ([wsResponse.result.eventName isEqualToString:SFM_PICKLIST_DEFINITIONS])
        {
           
            FisrtTime_response = FALSE;
            //SMLog(@"SAMMAN MetaSync SFM_PICKLIST_DEFINITIONS received, processing starts: %@", [NSDate date]);
            didGetPicklistValues = TRUE;
            NSMutableArray * arr;
            NSMutableArray * Fields = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
            
            
            NSMutableDictionary * picklistDict;
            
            NSMutableArray * array = [wsResponse.result valueMap];
            
            for (int i = 0; i < [array count]; i++)
            {
                INTF_WebServicesDefServiceSvc_SVMXMap * svmxMap = [array objectAtIndex:i];
                
                NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObject:(svmxMap.value != nil)?(svmxMap.value):@"" forKey:(svmxMap.key != nil)?(svmxMap.key):@""];
                NSString * objectkey = (svmxMap.value != nil)?(svmxMap.value):@"";
                
                [picklistObject addObject:dict];
                NSMutableArray * valueMap = [svmxMap valueMap];
                NSMutableArray * array1 = [[NSMutableArray alloc] initWithCapacity:0];
                
                for (int j = 0; j < [valueMap count]; j++)
                {
                    INTF_WebServicesDefServiceSvc_SVMXMap * svmxMapValue = [valueMap objectAtIndex:j];
                    NSString * fieldValue = (svmxMapValue.value != nil)?(svmxMapValue.value):@"";
                    NSMutableDictionary * dict1 = [NSMutableDictionary dictionaryWithObject:(svmxMapValue.value != nil)?(svmxMapValue.value):@"" forKey:(svmxMapValue.key != nil)?(svmxMapValue.key):@""];
                    [Fields addObject:dict1];
                    
                    
                    NSMutableArray * keys = [[NSMutableArray alloc] initWithCapacity:0];
                    NSMutableArray * values = [[NSMutableArray alloc] initWithCapacity:0];
                    
                    
                    NSMutableArray * valueMapArray = [svmxMapValue valueMap];
                    
                    for (int k = 0; k < [valueMapArray count]; k++)
                    {
                        INTF_WebServicesDefServiceSvc_SVMXMap * mapValues = [valueMapArray objectAtIndex:k];
                        [keys addObject:(mapValues.key != nil)?(mapValues.key):@""];
                        [values addObject:(mapValues.value != nil)?(mapValues.value):@""];
                    }   
                    NSMutableArray * keyvalueArr;
                    if (([keys count] > 0) && ([values count] > 0))
                        keyvalueArr = [NSMutableArray arrayWithObjects:keys, values, nil];
                    
                    
                    if (keys)
                        [keys release];
                    if (values)
                        [values release];
                    NSDictionary * dictionary;
                    dictionary= [NSDictionary dictionaryWithObject:keyvalueArr forKey:fieldValue];
                    [array1 addObject:dictionary];
                }
                arr = [NSMutableArray arrayWithArray:array1];
                
                picklistDict = [NSMutableDictionary dictionaryWithObject:arr forKey:objectkey]; 
                [picklistValues addObject:picklistDict];
                
                if (array1)
                    [array1 release];
                arr = [NSMutableArray arrayWithArray:Fields];
                picklistDict = [NSMutableDictionary dictionaryWithObject:arr forKey:objectkey];
                [picklistField addObject:picklistDict];
                if ([Fields count] > 0)
                    [Fields removeAllObjects];
            }
            NSMutableArray * resultValues = [wsResponse.result values];
            if ([resultValues count] > 0)
            {
                didGetPicklistValues = FALSE;
                [self metaSyncWithEventName:SFM_PICKLIST_DEFINITIONS eventType:SYNC values:resultValues];
            }
            else
            {
                didGetPicklistValues = FALSE;
                [appDelegate.dataBase insertvaluesToPicklist:picklistObject fields:picklistField value:picklistValues];

                NSMutableArray * allObjects = [[NSMutableArray alloc] initWithCapacity:0];
                for (NSDictionary * objectDict in object)
                {
                    NSString * objectName = ([objectDict valueForKey:OBJECT] != nil)?[objectDict valueForKey:OBJECT]:@"";
                    
                    if (![objectName isEqualToString:@""])
                        [allObjects addObject:objectName];
                }
                
                               
                //SMLog(@"SAMMAN MetaSync SFM_PICKLIST_DEFINITIONS received, processing ends: %@", [NSDate date]);
                if([allObjects count] > 0)
                {
                    appDelegate.initial_sync_status =  SYNC_RT_DP_PICKLIST_INFO;
                    appDelegate.Sync_check_in = FALSE;

                    [self getRecordTypeDictForObjects:allObjects];
                }
            }
             
        } 
        
        else if ([wsResponse.result.eventName isEqualToString:SFM_OBJECT_DEFINITIONS])
        {
           
           // SMLog(@"SAMMAN MetaSync SFM_OBJECT_DEFINITIONS received, processing starts: %@", [NSDate date]);
            int m = 0;
            NSMutableArray * arr = [[[NSMutableArray alloc] initWithCapacity:0] retain];
            NSMutableArray * object_array = [[[NSMutableArray alloc] initWithCapacity:0] retain];
            NSMutableArray * array1;
            
            NSMutableArray * keys = [[NSMutableArray alloc] initWithCapacity:0];
            NSMutableArray * values = [[NSMutableArray alloc] initWithCapacity:0];
            
            NSMutableDictionary * objectDict;
            
            objectDefinitions = [[NSMutableArray alloc] initWithCapacity:0];
            object = [[NSMutableArray alloc] initWithCapacity:0];
            
            
            NSMutableArray * array = [wsResponse.result valueMap];
            for (int i = 0; i < [array count]; i++)
            {
                NSMutableDictionary * dict;
                INTF_WebServicesDefServiceSvc_SVMXMap * svmxMap = [array objectAtIndex:i];
                dict = [NSMutableDictionary dictionaryWithObject:(svmxMap.value != nil)?(svmxMap.value):@"" forKey:(svmxMap.key != nil)?(svmxMap.key):@""];
                NSString * key = (svmxMap.value != nil)?(svmxMap.value):@"";
                
                if (![key isEqualToString:@""] && (![((svmxMap.value != nil)?(svmxMap.value):@"") isEqualToString:@""]))
                    [object addObject:dict];
                
                NSMutableArray * valueMap = [svmxMap valueMap];
                NSMutableDictionary * valueMapDict;
                NSString * objectProperty = @"";
                for (int j = 0; j < [valueMap count]; j++)
                {
                    INTF_WebServicesDefServiceSvc_SVMXMap * valueSvmxMap = [valueMap objectAtIndex:j];
                    objectProperty = (valueSvmxMap.key != nil)?(valueSvmxMap.key):@"";
                    
                    NSMutableArray * valueMapArray = [valueSvmxMap valueMap];
                    
                    for (int k = 0; k < [valueMapArray count]; k++)
                    {
                        INTF_WebServicesDefServiceSvc_SVMXMap * mapValues = [valueMapArray objectAtIndex:k];
                        NSString * object_key = (mapValues.key != nil)?(mapValues.key):@"";
                        [keys addObject:(mapValues.key != nil)?(mapValues.key):@""];
                        [values addObject:(mapValues.value != nil)?(mapValues.value):@""];
                        
                        NSMutableArray * mapValuesArray =  [mapValues valueMap];
                        
                        for (int g = 0 ; g < [mapValuesArray count]; g++)
                        {
                            INTF_WebServicesDefServiceSvc_SVMXMap * svmxMap = [mapValuesArray objectAtIndex:g];
                            [keys addObject:(svmxMap.key != nil)?(svmxMap.key):@""];
                            
                            //To store the MasterDetails
                       //     if ([(svmxMap.key != nil)?(svmxMap.key):@"" isEqualToString:@"MASTERDETAILS"])
                          //  {
                                NSMutableArray * detailArray = svmxMap.valueMap;  
                                
                                if ([detailArray count] > 0)
                                {
                                    NSMutableArray * detailkey = [[NSMutableArray alloc] initWithCapacity:0];
                                    NSMutableArray * detailValue = [[NSMutableArray alloc] initWithCapacity:0];
                                    for (int val = 0; val < [detailArray count]; val++)
                                    {
                                        INTF_WebServicesDefServiceSvc_SVMXMap * masterDetailMap = [detailArray objectAtIndex:val];
                                        
                                        if (![(masterDetailMap.key != nil)?masterDetailMap.key:@"" isEqualToString:@""])
                                        {
                                            [detailkey addObject:masterDetailMap.key];
                                            [detailValue addObject:(masterDetailMap.value != nil)?masterDetailMap.value:@""];
                                        }
                                        else
                                            [values addObject:(svmxMap.value != nil)?(svmxMap.value):@""];
                                        
                                  }
                               
                                    if ([detailkey count] > 0)
                                    {
                                        NSMutableDictionary * detailKeyValue = [NSMutableDictionary dictionaryWithObjects:detailValue forKeys:detailkey];

                                        [values addObject:detailKeyValue];
                                    }
                                    if ([detailkey count] > 0)
                                        [detailkey release];
                                    if ([detailValue count] > 0)
                                        [detailValue release];
                                    
                                }
                                else
                                    [values addObject:(svmxMap.value != nil)?(svmxMap.value):@""];
                                
                        }
                        
                        valueMapDict = [NSMutableDictionary dictionaryWithObjects:values forKeys:keys];
                        objectDict = [NSMutableDictionary dictionaryWithObject:valueMapDict forKey:object_key];
                        [object_array addObject:objectDict]; 
                        if (keys)
                            [keys removeAllObjects];
                        if (values)
                            [values removeAllObjects];
                    }   
                    array1 = [NSMutableArray arrayWithArray:object_array];
                    objectDict = [NSMutableDictionary dictionaryWithObject:array1 forKey:objectProperty];
                    [arr addObject:objectDict];
                    if (object_array)
                        [object_array removeAllObjects];
                    
                }
                array1 = [NSMutableArray arrayWithArray:arr];
                objectDict = [NSMutableDictionary dictionaryWithObject:array1 forKey:key]; 
                [objectDefinitions insertObject:objectDict atIndex:m++];
                if (arr)
                    [arr removeAllObjects];
            }

            
            appDelegate.initial_sync_status = SYNC_SFM_BATCH_OBJECT_DEFINITIONS;
            appDelegate.Sync_check_in = FALSE;
            
            NSMutableArray * getAllObject = [wsResponse.result values];
            if ([getAllObject count] == 0)
            {
                getAllObject = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
            }
            
            didGetAddtionalObjDef = FALSE;
            NSMutableArray * objects = [NSMutableArray  arrayWithObjects:@"Task", @"Event", @"User",nil];
            [getAllObject addObjectsFromArray:(NSArray *)objects];
            [appDelegate.wsInterface metaSyncWithEventName:SFM_BATCH_OBJECT_DEFINITIONS eventType:SYNC values:getAllObject]; 

        }
        else if ([wsResponse.result.eventName isEqualToString:SFM_BATCH_OBJECT_DEFINITIONS])
        {

            //SMLog(@"SAMMAN MetaSync SFM_BATCH_OBJECT_DEFINITIONS received, processing starts: %@", [NSDate date]);
            NSMutableArray * arr = [[[NSMutableArray alloc] initWithCapacity:0] retain];
            NSMutableArray * object_array = [[[NSMutableArray alloc] initWithCapacity:0] retain];
            NSMutableArray * array1;
            
            NSMutableArray * keys = [[NSMutableArray alloc] initWithCapacity:0];
            NSMutableArray * values = [[NSMutableArray alloc] initWithCapacity:0];
            
            NSMutableDictionary * objectDict;
            
            NSMutableArray * array = [wsResponse.result valueMap];
            for (int i = 0; i < [array count]; i++)
            {
                NSMutableDictionary * dict;
                INTF_WebServicesDefServiceSvc_SVMXMap * svmxMap = [array objectAtIndex:i];
                dict = [NSMutableDictionary dictionaryWithObject:(svmxMap.value != nil)?(svmxMap.value):@"" forKey:(svmxMap.key != nil)?(svmxMap.key):@""];
                NSString * key = (svmxMap.value != nil)?(svmxMap.value):@"";
                
                [object addObject:dict];
                
                NSMutableArray * valueMap = [svmxMap valueMap];
                NSMutableDictionary * valueMapDict;
                NSString * objectProperty = @"";
                for (int j = 0; j < [valueMap count]; j++)
                {
                    INTF_WebServicesDefServiceSvc_SVMXMap * valueSvmxMap = [valueMap objectAtIndex:j];
                    objectProperty = (valueSvmxMap.key != nil)?(valueSvmxMap.key):@"";
                    
                    NSMutableArray * valueMapArray = [valueSvmxMap valueMap];
                    
                    for (int k = 0; k < [valueMapArray count]; k++)
                    {
                        INTF_WebServicesDefServiceSvc_SVMXMap * mapValues = [valueMapArray objectAtIndex:k];
                        NSString * object_key = (mapValues.key != nil)?(mapValues.key):@"";
                        [keys addObject:(mapValues.key != nil)?(mapValues.key):@""];
                        [values addObject:(mapValues.value != nil)?(mapValues.value):@""];
                        
                        NSMutableArray * mapValuesArray =  [mapValues valueMap];
                        
                        for (int g = 0 ; g < [mapValuesArray count]; g++)
                        {
                            INTF_WebServicesDefServiceSvc_SVMXMap * svmxMap = [mapValuesArray objectAtIndex:g];
                            [keys addObject:(svmxMap.key != nil)?(svmxMap.key):@""];
                            
                            //To store the MasterDetails
                            //     if ([(svmxMap.key != nil)?(svmxMap.key):@"" isEqualToString:@"MASTERDETAILS"])
                            //  {
                            NSMutableArray * detailArray = svmxMap.valueMap;  
                            
                            if ([detailArray count] > 0)
                            {
                                NSMutableArray * detailkey = [[NSMutableArray alloc] initWithCapacity:0];
                                NSMutableArray * detailValue = [[NSMutableArray alloc] initWithCapacity:0];
                                for (int val = 0; val < [detailArray count]; val++)
                                {
                                    INTF_WebServicesDefServiceSvc_SVMXMap * masterDetailMap = [detailArray objectAtIndex:val];
                                    
                                    if (![(masterDetailMap.key != nil)?masterDetailMap.key:@"" isEqualToString:@""])
                                    {
                                        [detailkey addObject:masterDetailMap.key];
                                        [detailValue addObject:(masterDetailMap.value != nil)?masterDetailMap.value:@""];
                                    }
                                    else
                                        [values addObject:(svmxMap.value != nil)?(svmxMap.value):@""];
                                    
                                }
                                if ([detailkey count] > 0)
                                {
                                    NSMutableDictionary * detailKeyValue = [NSMutableDictionary dictionaryWithObjects:detailValue forKeys:detailkey];
                                    
                                    [values addObject:detailKeyValue];
                                }
                                if ([detailkey count] > 0)
                                    [detailkey release];
                                if ([detailValue count] > 0)
                                    [detailValue release];
                                
                            }
                            else
                                [values addObject:(svmxMap.value != nil)?(svmxMap.value):@""];
                            

                            
                        }
                        
                        valueMapDict = [NSMutableDictionary dictionaryWithObjects:values forKeys:keys];
                        objectDict = [NSMutableDictionary dictionaryWithObject:valueMapDict forKey:object_key];
                        [object_array addObject:objectDict]; 
                        if (keys)
                            [keys removeAllObjects];
                        if (values)
                            [values removeAllObjects];
                    }   
                    array1 = [NSMutableArray arrayWithArray:object_array];
                    objectDict = [NSMutableDictionary dictionaryWithObject:array1 forKey:objectProperty];
                    [arr addObject:objectDict];
                    if (object_array)
                        [object_array removeAllObjects];
                    
                }
                array1 = [NSMutableArray arrayWithArray:arr];
                objectDict = [NSMutableDictionary dictionaryWithObject:array1 forKey:key]; 
                [objectDefinitions addObject:objectDict];
                if (arr)
                    [arr removeAllObjects];
            }
            
            
            NSArray * getAllObject = nil;
            
            getAllObject = [wsResponse.result values];
            
            if ([getAllObject count] > 0)
            {
                [self metaSyncWithEventName:SFM_BATCH_OBJECT_DEFINITIONS eventType:SYNC  values:(NSMutableArray *)getAllObject];
            }
            else 
            {
                didGetAddtionalObjDef = TRUE;
                
                [appDelegate.dataBase insertValuesInToOBjDefTableWithObject:object definition:objectDefinitions]; 
                
                NSMutableArray * pickListObj = [self collectPickListObject];

	            //sahana Aug 16th
    	        [appDelegate.dataBase getRecordTypeValuesForObject:pickListObj];
                
                // SMLog(@"SAMMAN MetaSync SFM_OBJECT_DEFINITIONS received, processing ends: %@", [NSDate date]);
                
                appDelegate.initial_sync_status = SYNC_SFM_PICKLIST_DEFINITIONS;
                appDelegate.Sync_check_in = FALSE;
                
                [self metaSyncWithEventName:SFM_PICKLIST_DEFINITIONS eventType:SYNC values:pickListObj];   
            }
        }

        else if ([wsResponse.result.eventName isEqualToString:SFW_METADATA])
        {
           
           // SMLog(@"SAMMAN MetaSync SFW_METADATA received, processing starts: %@", [NSDate date]);
            wizardDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
            
            NSMutableArray * array = [wsResponse.result valueMap];
            NSMutableArray * keys = [[NSMutableArray alloc] initWithCapacity:0];
            NSMutableArray * values = [[NSMutableArray alloc] initWithCapacity:0];
            NSMutableArray * arr = [[NSMutableArray alloc] initWithCapacity:0];
            NSArray * array1 = nil;
            NSDictionary * dict = nil;
            
            NSString * keyValue = @"";
            
            for (int i = 0; i < [array count]; i++)
            {
                INTF_WebServicesDefServiceSvc_SVMXMap * svmxMap = [array objectAtIndex:i];
                if (!([svmxMap.key isEqualToString:nil] && [svmxMap.key isEqualToString:@""]))
                {
                    keyValue = svmxMap.key;
                }
                
                NSMutableArray * valueMap = [svmxMap valueMap];
                
                for (int j = 0; j < [valueMap count]; j++)
                {
                    INTF_WebServicesDefServiceSvc_SVMXMap * valueSvmxMap = [valueMap objectAtIndex:j];
                    
                    NSMutableArray * valueMapArray = [valueSvmxMap valueMap];
                    for (int k = 0; k < [valueMapArray count]; k++)
                    {
                        NSString * key = @"";
                        NSString * value = @"";
                        INTF_WebServicesDefServiceSvc_SVMXMap * map = [valueMapArray objectAtIndex:k];
                        key = (map.key != nil)?(map.key):@"";
                        if (![key isEqualToString:@""])
                        {
                            [keys addObject:key];
                            [values addObject:map.value];
                        }                                                
                        NSMutableArray * mapArray = [map valueMap];
                        
                        for ( int m = 0; m < [mapArray count]; m++)
                        {
                            INTF_WebServicesDefServiceSvc_SVMXMap * svmxMap = [mapArray objectAtIndex:m];
                            
                            NSMutableArray * expArray = [svmxMap valueMap];
                            
                            for (int h = 0; h < [expArray count]; h++)
                            {
                                INTF_WebServicesDefServiceSvc_SVMXMap * svmxMap1 = [expArray objectAtIndex:h];
                                key = (svmxMap1.key != nil)?(svmxMap1.key):@"";;
                                if (![key isEqualToString:@""])
                                {
                                    [keys addObject:key];
                                    [values addObject:value];
                                }
                            }
                        }
                    }
                    if ([keys count] > 0)
                    {
                        dict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
                        [arr addObject:dict];
                        [keys removeAllObjects];
                        if ([values count] > 0)
                            [values removeAllObjects];
                    }
                }
                array1 = [NSArray arrayWithArray:arr];
                [wizardDictionary setValue:array1 forKey:keyValue];
                keyValue = nil;
                if ([arr count] > 0)
                    [arr removeAllObjects]; 
                
            }
                  
            [appDelegate.dataBase insertValuesInToSFWizardsTable:wizardDictionary];
             
      }
      else if ([wsResponse.result.eventName isEqualToString:MOBILE_DEVICE_TAGS])
      {
          
         // SMLog(@"SAMMAN MetaSync MOBILE_DEVICE_TAGS processing starts: %@", [NSDate date]);
          mobileDeviceTagsDict = [[NSMutableDictionary alloc] initWithCapacity:0];
          NSMutableArray * array = [wsResponse.result valueMap];
        
          for (int i = 0; i < [array count]; i++)
          {
              INTF_WebServicesDefServiceSvc_SVMXMap * svmxMap = [array objectAtIndex:i];
            
              NSString * key = (svmxMap.key!=nil)?(svmxMap.key):@"";
            
              if (![key isEqualToString:@""])
                  [mobileDeviceTagsDict setValue:(svmxMap.value!=nil)?(svmxMap.value):@"" forKey:(svmxMap.key!=nil)?svmxMap.key:@""];
          }
          if(!appDelegate.firstTimeCallForTags)
          {
              [appDelegate.dataBase insertValuesInToTagsTable:mobileDeviceTagsDict];
          }
          else
          {
              NSMutableDictionary * temp_dict = [[self fillEmptyTags:mobileDeviceTagsDict] retain];
              appDelegate.wsInterface.tagsDictionary = [temp_dict retain];
              appDelegate.download_tags_done = TRUE;;
          }
        }
        else if ([wsResponse.result.eventName isEqualToString:MOBILE_DEVICE_SETTINGS])
        {
            mobileDeviceSettingsDict = [[NSMutableDictionary alloc] initWithCapacity:0];
            NSMutableArray * array = [wsResponse.result valueMap];
                        
            for (int i = 0; i < [array count]; i++)
            {
                INTF_WebServicesDefServiceSvc_SVMXMap * svmxMap = [array objectAtIndex:i];
                
                NSString * key = (svmxMap.key)!=nil?(svmxMap.key):@"";
                if (![key isEqualToString:@""])
                    [mobileDeviceSettingsDict setValue:(svmxMap.value!=nil)?(svmxMap.value):@"" forKey:(svmxMap.key!=nil)?(svmxMap.key):@""];
            }          
           
            [appDelegate.dataBase insertValuesInToSettingsTable:mobileDeviceSettingsDict];

        }
    }
    
    if ([operation isKindOfClass:[INTF_WebServicesDefBinding_INTF_DataSync_WS class]])
    {
        INTF_WebServicesDefServiceSvc_INTF_DataSync_WSResponse * wsResponse = [response.bodyParts objectAtIndex:0];
        if(wsResponse.result.eventName == nil && wsResponse.result.eventType == nil )
        {
            appDelegate.connection_error = TRUE;
        }

		if ([wsResponse.result.eventName isEqualToString:@"LOCATION_HISTORY"] && [wsResponse.result.eventType isEqualToString:SYNC]
            )
        {
            [appDelegate.dataBase setDidUserGPSLocationUpdated:YES];
            SMLog(@"Sent GPS Logs to Server");
            NSMutableArray * array = [wsResponse.result valueMap]; 
            for(int i=0;i<[array count];i++)
            {
                INTF_WebServicesDefServiceSvc_SVMXMap * mapForObjectId = [array objectAtIndex:i];
                if([mapForObjectId.value length] > 0 )
                {
                    NSString *localId = mapForObjectId.key;
                    [appDelegate.dataBase deleteRecordFromUserGPSTable:localId];
                }
                //get the local_id and sfid 
                //if sfid is there delete the record from gps table 
            }
        }
        
		if ([wsResponse.result.eventName isEqualToString:@"SFM_SEARCH"] && [wsResponse.result.eventType isEqualToString:@"SEARCH_RESULTS"]
            )
        {
           
            didOpComplete = YES;         
            SMLog(@"SFM Search Results Got");
            NSArray *tableField=appDelegate.sfmSearchTableArray;
            NSArray *fieldsForTableHeader=[[[NSArray alloc]init ]autorelease];
            SMLog(@"%@",tableField);
            NSDictionary *filedForObjectID=[[NSDictionary alloc]initWithObjects:[tableField valueForKey:@"TableHeader"] forKeys:[tableField valueForKey:@"ObjectId"]];
            SMLog(@"%@",filedForObjectID);
            NSMutableArray * array = [wsResponse.result valueMap]; 
            NSMutableArray *resultsArray = [[[NSMutableArray alloc] init] autorelease];
            for(int i=0;i<[array count];i++)
            {
                INTF_WebServicesDefServiceSvc_SVMXMap * mapForObjectId = [array objectAtIndex:i];
                
                NSArray *resultMap = [mapForObjectId valueMap];
                NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
                [resultDict setObject:mapForObjectId.key forKey:@"SearchObjectId"];
				NSString * idValue = (mapForObjectId.value != nil)?mapForObjectId.value:@"";
                for(int j=0; j<[resultMap count]; j++)
                {
                    fieldsForTableHeader=[filedForObjectID objectForKey:mapForObjectId.key];
                    INTF_WebServicesDefServiceSvc_SVMXMap * mapForResult = [resultMap objectAtIndex:j];
                    [resultDict setObject:mapForResult.value forKey:[fieldsForTableHeader objectAtIndex:j]];
                    if(j ==0)
                    {
                        NSArray *resultIDMapArray = [mapForResult valueMap];                    
                        INTF_WebServicesDefServiceSvc_SVMXMap * mapForID = [resultIDMapArray objectAtIndex:0];
                        [resultDict setObject:idValue forKey:@"Id"];
                    }
                }
                [resultsArray addObject:resultDict];
                [resultDict release];
            }
            SMLog(@"Results = %@",resultsArray);
            [appDelegate setOnlineDataArray:resultsArray];
        }
        else if ([wsResponse.result.eventName isEqualToString:EVENT_SYNC] || [wsResponse.result.eventName isEqualToString:DOWNLOAD_CREITERIA_SYNC])
        {
            //[self  calculateMemory];
            
            NSAutoreleasePool * autoreleasePool = [[NSAutoreleasePool alloc] init];
            appDelegate.data_sync_chunking = RESPONSE_RECIEVED; //sahana IMP 
            SMLog(@"SAMMAN Incremental DataSync response recieved: %@", [NSDate date]);
            
           // NSString * event_name = wsResponse.result.eventName;
    
            NSString * event_name_temp = @"DATA_SYNC";
            NSMutableDictionary * record_dict = [[NSMutableDictionary alloc] initWithCapacity:0];
            NSMutableArray * array = [wsResponse.result valueMap]; 
            BOOL call_Back  = FALSE;
            
            NSArray * keys_ =[[NSArray alloc] initWithObjects:@"LOCAL_ID",@"JSON_RECORD",@"SF_ID", @"SYNC_TYPE", @"RECORD_TYPE", nil];
            
            SMLog(@"SAMMAN Incremental DataSync response parsing starts: %@", [NSDate date]);
            for (int i = 0; i < [array count]; i++)
            {
                INTF_WebServicesDefServiceSvc_SVMXMap * svmxMap = [array objectAtIndex:i];
                NSString * key = (svmxMap.key != nil)?(svmxMap.key):@"";
                
                NSString * objectApiName = @"" , * record_type = @"";
                
                if([key isEqualToString:@"LAST_SYNC"])
                {
                    appDelegate.last_initial_data_sync_time  =  (svmxMap.value != nil)?svmxMap.value:@"";
                }
                else if ([key isEqualToString:@"CALL_BACK"])
                {
                    call_Back = [svmxMap.value boolValue];
                }
                else if([key isEqualToString:@"LAST_INDEX"]) 
                {
                    appDelegate.initial_Sync_last_index = (svmxMap.value != nil)?svmxMap.value:@"";
                }
                else if([key isEqualToString:DOWNLOAD_CRITERIA_OBJECTS])
                {
                    NSMutableDictionary * dcobjects = [[NSMutableDictionary alloc] initWithCapacity:0];
                    NSMutableArray * dc_objects = svmxMap.values;
                    for(NSString  * str in dc_objects)
                    {
                       NSArray * arr = [str componentsSeparatedByString:@","];
                        if([arr count] <= 2)
                        {
                            NSString * objectName =[arr objectAtIndex:0];
                            NSString * whereclause = [arr objectAtIndex:1];
                            [dcobjects setObject:whereclause forKey:objectName];
                        }
                    }
                    [self downloadcriteriaplist:dcobjects];
                }
                else if ([key isEqualToString:@"PARTIAL_EXECUTED_OBJECT"])
                {
                    appDelegate.initital_sync_object_name = (svmxMap.value != nil)?svmxMap.value:@"";
                }
                else if ([key isEqualToString:@"Child_Object"] || [key isEqualToString:@"Parent_Object"])
                {
                    if ([key isEqualToString:@"Child_Object"])
                    {
                        record_type = DETAIL;
                    }
                    else if ([key isEqualToString:@"Parent_Object"])
                    {
                        record_type = MASTER;
                    }
                    
                    if (![key isEqualToString:@""])
                        objectApiName = (svmxMap.value != nil)?svmxMap.value:@"";
                    
                    NSMutableArray * valueMap = [svmxMap valueMap];
                    
                    for (int j = 0; j < [valueMap count]; j++)
                    {
                        
                        INTF_WebServicesDefServiceSvc_SVMXMap * fieldSvmxMap = [valueMap objectAtIndex:j];
                                            
                        NSString * fieldValue = (fieldSvmxMap.value != nil)?fieldSvmxMap.value:@"";
                        
                        NSMutableArray * values =  [self getIdsFromJsonString:fieldValue];
                        
                        for (int k = 0; k < [values count]; k++)
                        {
                            NSString * sf_id = [values objectAtIndex:k];
                             
                            NSArray * allkeys = [record_dict allKeys];
                            BOOL flag = FALSE;
                            
                            for( NSString * temp in allkeys )
                            {
                                if([temp isEqualToString:objectApiName])
                                {
                                    flag = TRUE;
                                    break;
                                }
                            }
                            if(flag)
                            {
                            
                                NSArray * objects = [[NSArray alloc] initWithObjects:@"", @"",sf_id,event_name_temp,record_type, nil];
                                NSDictionary * dict = [[NSDictionary alloc] initWithObjects:objects forKeys:keys_];
                                NSMutableArray * array1 = [record_dict objectForKey:objectApiName];
                                [array1 addObject:dict];
                                [dict release];
                            }
                            else
                            {
                                NSArray * objects = [[NSArray alloc] initWithObjects:@"", @"",sf_id,event_name_temp,record_type, nil];
                                NSDictionary * dict = [[NSDictionary alloc] initWithObjects:objects forKeys:keys_];
                                NSMutableArray * array1 = [[NSMutableArray alloc] initWithCapacity:0];
                                [array1 addObject:dict];
                                [record_dict setObject:array1 forKey:objectApiName];
                                [array1 release];
                                [dict release];
                            }
                        }
                        [values release];
                    }
                    
                    SMLog(@"valueMap %d",[valueMap retainCount]);
                }
            }
            [keys_ release];
            
            SMLog(@"array %d",[array retainCount]);
            
            SMLog(@"SAMMAN Incremental DataSync response parsing starts: %@", [NSDate date]);
            [appDelegate.databaseInterface insertRecordIdsIntosyncRecordHeap:record_dict];
           
            SMLog(@"record_dict %d" , [record_dict retainCount]);
            [record_dict release]; 

            if(call_Back)
            {
                SMLog(@"NxtCallDC");
                 appDelegate.wsInterface.didOpComplete = FALSE;
                [appDelegate.wsInterface dataSyncWithEventName:DOWNLOAD_CREITERIA_SYNC eventType:@"SYNC" requestId:appDelegate.initial_dataSync_reqid];
                appDelegate.data_sync_chunking = REQUEST_SENT;  // sahana imp 
               
            }
            else
            {
                SMLog(@"NxtCallDC1");
                appDelegate.wsInterface.didOpComplete = TRUE;
                SMLog(@"IComeOUTHere wsinterface");
            }
            
            [autoreleasePool release];
            
        }
        //sahana incremental Data sync 
        else if ([wsResponse.result.eventName isEqualToString:@"TX_FETCH"])
        {
          
            NSAutoreleasePool * autoreleasePool = [[NSAutoreleasePool alloc] init];
            SMLog(@"SAMMAN TX_FETCH Response recived: %@", [NSDate date]);
            SMLog(@"SAMMAN TX_FETCH Processing starts: %@", [NSDate date]);
            NSMutableDictionary * record_dict = [[NSMutableDictionary alloc] initWithCapacity:0];
            NSMutableArray * array = [wsResponse.result valueMap];
            
            NSArray * keys_ = [[NSArray alloc] initWithObjects:@"LOCAL_ID",@"JSON_RECORD",@"SF_ID", nil];
            for (int i = 0; i < [array count]; i++)
            {
                INTF_WebServicesDefServiceSvc_SVMXMap * svmxMap = [array objectAtIndex:i];
                NSString * object_name = (svmxMap.value != nil)?(svmxMap.value):@"";
                
                NSMutableArray * valueMap = [svmxMap valueMap];
                
                for (int j = 0; j < [valueMap count]; j++)
                {
                    INTF_WebServicesDefServiceSvc_SVMXMap * record_map = [valueMap objectAtIndex:j];
                    NSString * key = (record_map.key!= nil) ?record_map.key:@"";//local_id
                    NSString * json_record = record_map.value;
                    
                  //  NSString * temp_json_string = [[NSString alloc] initWithString:json_record];
                    
                    NSMutableString * temp_json_string = [[NSMutableString alloc] initWithString:json_record];
                    //fetch id from the record 
                    NSString * SF_id = [self getIdFromJsonString:temp_json_string];
                    
                    ;
                 // temp_json_string = [self escapeSIngleQute:temp_json_string];
                    NSInteger val =  [temp_json_string replaceOccurrencesOfString:@"'" withString:@"''" options:NSCaseInsensitiveSearch range: NSMakeRange(0, [temp_json_string length])];
                    SMLog(@"%d" , val);
                    
                    NSArray * allkeys = [record_dict allKeys];
                    BOOL flag = FALSE;
                    
                     
                    for( NSString * temp in allkeys )
                    {
                        if([temp isEqualToString:object_name])
                        {
                            flag = TRUE;
                        }
                    }
                    if(flag)
                    {
                        NSArray * objects = [[NSArray alloc] initWithObjects:key, temp_json_string,SF_id, nil];
                        NSDictionary * dict = [[NSDictionary alloc] initWithObjects:objects forKeys:keys_];
                        NSMutableArray * array1 = [record_dict objectForKey:object_name];
                        [array1 addObject:dict];
                        [dict release];
                        [objects release];
                    }
                    else
                    {
                        NSArray * objects = [[NSArray alloc] initWithObjects:key, temp_json_string,SF_id, nil];
                        NSDictionary * dict = [[NSDictionary alloc] initWithObjects:objects forKeys:keys_];
                        NSMutableArray * array1 = [[NSMutableArray alloc] initWithCapacity:0];
                        [array1 addObject:dict];
                        [record_dict setObject:array1 forKey:object_name];
                        [array1 release];
                        [dict release];
                        [objects release];
                    }
                    [SF_id release];
                    [temp_json_string release];
                }
            }
            
            [keys_ release];
            SMLog(@"SAMMAN TX_FETCH Processing ends: %@", [NSDate date]);
            
            [appDelegate.databaseInterface updateAllRecordsToSyncRecordsHeap:record_dict];
            [record_dict release];
            
            [self PutAllTheRecordsForIds];        //sahana tesing    uncomment this line 
            
            [autoreleasePool drain];
            
        }
        else if ([wsResponse.result.eventName isEqualToString:@"PUT_INSERT"] )//INSERT
        {
            SMLog(@"SAMMAN GET_INSERT/PUT_INSERT Processing starts: %@", [NSDate date]);
            NSString * event_name = wsResponse.result.eventName;
            NSMutableDictionary * record_dict = [[NSMutableDictionary alloc] initWithCapacity:0];
            NSMutableDictionary * conflict_dict = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
            NSMutableArray * array = [wsResponse.result valueMap];
            
            for (int i = 0; i < [array count]; i++)
            {
                INTF_WebServicesDefServiceSvc_SVMXMap * svmxMap = [array objectAtIndex:i];
                
                NSString * key = (svmxMap.key != nil)?(svmxMap.key):@"";
                NSString * object_name = (svmxMap.value != nil)?(svmxMap.value):@"";
                
                if([key isEqualToString:@"LAST_SYNC"])
                {
                    insert_last_sync_time = object_name ;
                }
                else  if([key isEqualToString:@"Parent_Object"] || [key isEqualToString:@"Child_Object"])
                {
                    NSString * record_type = @"";
                    if([key isEqualToString:@"Parent_Object"])
                    {
                        record_type = MASTER;
                    }
                    else if ([key isEqualToString:@"Child_Object"])//Child_Object
                    {
                        record_type = DETAIL;
                    }
                    
                    NSMutableArray * valueMap = [svmxMap valueMap];
                    if([wsResponse.result.eventName isEqualToString:@"GET_INSERT"])
                    {
                        for (int j = 0; j < [valueMap count]; j++)
                        {
                            INTF_WebServicesDefServiceSvc_SVMXMap * record_map = [valueMap objectAtIndex:j];
                            NSString * field = (record_map.key!= nil) ?record_map.key:@"";//local_id
                            NSString * fieldValue    = (record_map.value != nil) ? record_map.value:@"";
                            
                            if([field isEqualToString:@"Fields"])
                            {
                                NSMutableArray * values =  [[self getIdsFromJsonString:fieldValue] retain];
                                
                                for (int k = 0; k < [values count]; k++)
                                {
                                    
                                    NSString * local_id = @"";
                                    NSString * sf_id    = [values objectAtIndex:k];
                                    
                                    NSArray * allkeys = [record_dict allKeys];
                                    BOOL flag = FALSE;
                                    
                                    for( NSString * temp in allkeys )
                                    {
                                        if([temp isEqualToString:object_name])
                                        {
                                            flag = TRUE;
                                            break;
                                        }
                                    }
                                    if(flag)
                                    {
                                        NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id, @"",sf_id,event_name,record_type,nil] forKeys:[NSArray arrayWithObjects:@"LOCAL_ID",@"JSON_RECORD",@"SF_ID",@"SYNC_TYPE", @"RECORD_TYPE",nil]];
                                        NSMutableArray * array = [record_dict objectForKey:object_name];
                                        [array addObject:dict];
                                    }
                                    else
                                    {
                                        NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id, @"",sf_id,event_name,record_type,nil] forKeys:[NSArray arrayWithObjects:@"LOCAL_ID",@"JSON_RECORD",@"SF_ID", @"SYNC_TYPE", @"RECORD_TYPE",nil]];
                                        NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:0];
                                        [array addObject:dict];
                                        [record_dict setObject:array forKey:object_name];
                                    }
                                    
                                }
                                [values release];

                            }
                            
                        }
                    }
                    else
                    {
                        for (int j = 0; j < [valueMap count]; j++)
                        {
                            INTF_WebServicesDefServiceSvc_SVMXMap * record_map = [valueMap objectAtIndex:j];
                            NSString * local_id = (record_map.key!= nil) ?record_map.key:@"";//local_id
                            NSString * sf_id    = (record_map.value != nil) ? record_map.value:@"";
                            
                            NSArray * allkeys = [record_dict allKeys];
                            BOOL flag = FALSE;
                            
                            for( NSString * temp in allkeys )
                            {
                                if([temp isEqualToString:object_name])
                                {
                                    flag = TRUE;
                                    break;
                                }
                            }
                            if(flag)
                            {
                                NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id, @"",sf_id,event_name,record_type,nil] forKeys:[NSArray arrayWithObjects:@"LOCAL_ID",@"JSON_RECORD",@"SF_ID",@"SYNC_TYPE", @"RECORD_TYPE",nil]];
                                NSMutableArray * array = [record_dict objectForKey:object_name];
                                [array addObject:dict];
                            }
                            else
                            {
                                NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id, @"",sf_id,event_name,record_type,nil] forKeys:[NSArray arrayWithObjects:@"LOCAL_ID",@"JSON_RECORD",@"SF_ID", @"SYNC_TYPE", @"RECORD_TYPE",nil]];
                                NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:0];
                                [array addObject:dict];
                                [record_dict setObject:array forKey:object_name];
                            }
                            
                        }
                    }
                    
                }
                else if ( [key isEqualToString:@"ERROR"])
                {
                    NSMutableArray * valueMap = [svmxMap valueMap];
                    for (int j = 0; j < [valueMap count]; j++)
                    {
                        INTF_WebServicesDefServiceSvc_SVMXMap * record_map = [valueMap objectAtIndex:j];
                        
                        NSString * record_type = @"";
                        NSString * object_name  = (record_map.key!= nil) ?record_map.key:@"";//local_id
                        NSString * sf_id = @""  , * local_id = @"";
                        
                        NSString * error_message =  (record_map.value != nil) ? record_map.value:@"";
                        
                        NSMutableArray *  errorvaluemap  = record_map.valueMap;
                        
                        for(int w = 0 ; w < [errorvaluemap count]; w++)
                        {
                            INTF_WebServicesDefServiceSvc_SVMXMap * error_svmxc_map = [errorvaluemap objectAtIndex:w];
                            local_id = (error_svmxc_map.key!= nil )?error_svmxc_map.key:@"";
                            sf_id    = (error_svmxc_map.value != nil)? error_svmxc_map.value:@"";
                        }
                        
                        
                        BOOL isChild = [appDelegate.databaseInterface  IsChildObject:object_name];
                        if(isChild)
                        {
                            record_type = DETAIL;
                        }
                        else                   //Child_Object
                        {
                            record_type = MASTER;
                        }
                        
                        NSArray * allkeys = [conflict_dict allKeys];
                        BOOL flag = FALSE;
                        
                        for( NSString * temp in allkeys)
                        {
                            if([temp isEqualToString:object_name])
                            {
                                flag = TRUE;
                                break;
                            }
                        }
                        if(flag)
                        {
                            NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id ,sf_id,event_name,record_type,error_message,key,nil] forKeys:[NSArray arrayWithObjects:@"LOCAL_ID",@"SF_ID",@"SYNC_TYPE", @"RECORD_TYPE",@"ERROR_MSG",@"ERROR_TYPE",nil]];
                            NSMutableArray * array = [conflict_dict objectForKey:object_name];
                            [array addObject:dict];
                        }
                        else
                        {
                            NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id ,sf_id,event_name,record_type,error_message,key,nil] forKeys:[NSArray arrayWithObjects:@"LOCAL_ID",@"SF_ID",@"SYNC_TYPE", @"RECORD_TYPE",@"ERROR_MSG",@"ERROR_TYPE",nil]];
                            NSMutableArray * array = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
                            [array addObject:dict];
                            [conflict_dict setObject:array forKey:object_name];
                        }
                    }
                }
            }
            SMLog(@"SAMMAN GET_INSERT/PUT_INSERT Processing ends: %@", [NSDate date]);
            [appDelegate.databaseInterface insertRecordIdsIntosyncRecordHeap:record_dict];
            [appDelegate.databaseInterface insertSyncConflictsIntoSYNC_CONFLICT:conflict_dict];
            
            [self getAllRecordsForOperationType:INSERT];
            
            if([appDelegate.dataSync_dict count] > 0)
            {
                [self Put:@"PUT_INSERT"];
            }
            else
            {
                appDelegate.Incremental_sync_status = PUT_INSERT_DONE;
            }
            
            if ([wsResponse.result.eventName isEqualToString:@"GET_INSERT"])
            {
                appDelegate.Incremental_sync_status = GET_INSERT_DONE;
            }
            
        }
        else if ( [wsResponse.result.eventName isEqualToString:@"PUT_UPDATE"] )//INSERT
        {
            
            NSString * event_name = wsResponse.result.eventName;
            NSMutableDictionary * record_dict = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
            NSMutableDictionary * conflict_dict = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
            NSMutableArray * array = [wsResponse.result valueMap];
            
            for (int i = 0; i < [array count]; i++)
            {
                INTF_WebServicesDefServiceSvc_SVMXMap * svmxMap = [array objectAtIndex:i];
                
                NSString * key = (svmxMap.key != nil)?(svmxMap.key):@"";
                NSString * object_name = (svmxMap.value != nil)?(svmxMap.value):@"";
                
                if([key isEqualToString:@"LAST_SYNC"] || [key isEqualToString:@"SYNC_TIME_STAMP"])
                {
                    update_last_sync_time = object_name;
                }
                else if([key isEqualToString:@"Object_Name"] ||[key isEqualToString:@"Parent_Object"] || [key isEqualToString:@"Child_Object"])
                {
                    NSString * record_type = @"";
                    BOOL isChild = [appDelegate.databaseInterface  IsChildObject:object_name];
                    if(isChild)
                    {
                        record_type = DETAIL;
                    }
                    else                   //Child_Object
                    {
                        record_type = MASTER;
                    }
                    
                    NSMutableArray * valueMap = [svmxMap valueMap];
                    if ([wsResponse.result.eventName isEqualToString:@"GET_UPDATE"])
                    {
                        
                        for (int j = 0; j < [valueMap count]; j++)
                        {
                            INTF_WebServicesDefServiceSvc_SVMXMap * record_map = [valueMap objectAtIndex:j];
                            NSString * field = (record_map.key!= nil) ?record_map.key:@"";//local_id
                            NSString * fieldValue    = (record_map.value != nil) ? record_map.value:@"";
                            
                            if([field isEqualToString:@"Fields"])
                            {
                                NSMutableArray * values =  [[self getIdsFromJsonString:fieldValue] retain];
                                
                                for (int k = 0; k < [values count]; k++)
                                {
                                    
                                    NSString * local_id = @"";
                                    NSString * sf_id    = [values objectAtIndex:k];
                                    
                                    NSArray * allkeys = [record_dict allKeys];
                                    BOOL flag = FALSE;
                                    
                                    for( NSString * temp in allkeys )
                                    {
                                        if([temp isEqualToString:object_name])
                                        {
                                            flag = TRUE;
                                            break;
                                        }
                                    }
                                    //NSString * sync_type = 
                                    if(flag)
                                    {
                                        NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id, @"",sf_id,event_name,record_type,nil] forKeys:[NSArray arrayWithObjects:@"LOCAL_ID",@"JSON_RECORD",@"SF_ID",@"SYNC_TYPE", @"RECORD_TYPE",nil]];
                                        NSMutableArray * array = [record_dict objectForKey:object_name];
                                        [array addObject:dict];
                                    }
                                    else
                                    {
                                        NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id, @"",sf_id,event_name,record_type,nil] forKeys:[NSArray arrayWithObjects:@"LOCAL_ID",@"JSON_RECORD",@"SF_ID", @"SYNC_TYPE", @"RECORD_TYPE",nil]];
                                        NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:0];
                                        [array addObject:dict];
                                        [record_dict setObject:array forKey:object_name];
                                    }
                                    
                                }
                                [values release];
                                
                            }
                            
                        }

                    }
                    else
                    {
                        for (int j = 0; j < [valueMap count]; j++)
                        {
                            INTF_WebServicesDefServiceSvc_SVMXMap * record_map = [valueMap objectAtIndex:j];
                            NSString * local_id = (record_map.key!= nil) ?record_map.key:@"";//local_id
                            NSString * sf_id    = (record_map.value != nil) ? record_map.value:@"";
                            
                            NSArray * allkeys = [record_dict allKeys];
                            BOOL flag = FALSE;
                            
                            for( NSString * temp in allkeys )
                            {
                                if([temp isEqualToString:object_name])
                                {
                                    flag = TRUE;
                                    break;
                                }
                            }
                            //NSString * sync_type = 
                            if(flag)
                            {
                                NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id, @"",sf_id,event_name,record_type,nil] forKeys:[NSArray arrayWithObjects:@"LOCAL_ID",@"JSON_RECORD",@"SF_ID",@"SYNC_TYPE", @"RECORD_TYPE",nil]];
                                NSMutableArray * array = [record_dict objectForKey:object_name];
                                [array addObject:dict];
                            }
                            else
                            {
                                NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id, @"",sf_id,event_name,record_type,nil] forKeys:[NSArray arrayWithObjects:@"LOCAL_ID",@"JSON_RECORD",@"SF_ID", @"SYNC_TYPE", @"RECORD_TYPE",nil]];
                                NSMutableArray * array = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
                                [array addObject:dict];
                                [record_dict setObject:array forKey:object_name];
                            }
                        }
                    }
                }
                else if ([key isEqualToString:@"CONFLICT"] || [key isEqualToString:@"ERROR"])
                {
                    NSMutableArray * valueMap = [svmxMap valueMap];
                    for (int j = 0; j < [valueMap count]; j++)
                    {
                        INTF_WebServicesDefServiceSvc_SVMXMap * record_map = [valueMap objectAtIndex:j];
                        
                        NSString * record_type = @"";
                        NSString * object_name  = (record_map.key!= nil) ?record_map.key:@"";//local_id
                        NSString * sf_id = @""  , * local_id = @"";
                        
                        NSString * error_message =  (record_map.value != nil) ? record_map.value:@"";
                        
                        NSMutableArray *  errorvaluemap  = record_map.valueMap;
                        
                        for(int w = 0 ; w < [errorvaluemap count]; w++)
                        {
                            INTF_WebServicesDefServiceSvc_SVMXMap * error_svmxc_map = [errorvaluemap objectAtIndex:w];
                            local_id = (error_svmxc_map.key!= nil )?error_svmxc_map.key:@"";
                            sf_id    = (error_svmxc_map.value != nil)? error_svmxc_map.value:@"";
                        }
                        
                        
                        BOOL isChild = [appDelegate.databaseInterface  IsChildObject:object_name];
                        if(isChild)
                        {
                            record_type = DETAIL;
                        }
                        else                   //Child_Object
                        {
                            record_type = MASTER;
                        }
                        
                        /* NSMutableArray * errors = record_map.values;//object at index 0 will have the Error String  
                         
                         if([errors count] >0)
                         {
                         error_message = [errors objectAtIndex:0];
                         }*/
                        
                        NSArray * allkeys = [conflict_dict allKeys];
                        BOOL flag = FALSE;
                        
                        for( NSString * temp in allkeys)
                        {
                            if([temp isEqualToString:object_name])
                            {
                                flag = TRUE;
                                break;
                            }
                        }
                        if(flag)
                        {
                            NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id ,sf_id,event_name,record_type,error_message,key,nil] forKeys:[NSArray arrayWithObjects:@"LOCAL_ID",@"SF_ID",@"SYNC_TYPE", @"RECORD_TYPE",@"ERROR_MSG",@"ERROR_TYPE",nil]];
                            NSMutableArray * array = [conflict_dict objectForKey:object_name];
                            [array addObject:dict];
                        }
                        else
                        {
                            NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id,sf_id,event_name,record_type,error_message,key,nil] forKeys:[NSArray arrayWithObjects:@"LOCAL_ID",@"SF_ID",@"SYNC_TYPE", @"RECORD_TYPE",@"ERROR_MSG",@"ERROR_TYPE",nil]];
                            NSMutableArray * array = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
                            [array addObject:dict];
                            [conflict_dict setObject:array forKey:object_name];
                        }
                        
                    }
                }
            }
            
            SMLog(@"UPDATE %@", record_dict);
            [appDelegate.databaseInterface  insertRecordIdsIntosyncRecordHeap:record_dict];
            [appDelegate.databaseInterface  insertSyncConflictsIntoSYNC_CONFLICT:conflict_dict];
            if([wsResponse.result.eventName isEqualToString:@"GET_UPDATE"])
            {
                appDelegate.Incremental_sync_status = GET_UPDATE_DONE;
            }
            else if ([wsResponse.result.eventName isEqualToString:@"PUT_UPDATE"])
            {
                appDelegate.Incremental_sync_status = PUT_UPDATE_DONE;
            }
        }
        else if ([wsResponse.result.eventName isEqualToString:@"PUT_DELETE"] )
        {
            NSString * event_name = wsResponse.result.eventName;
            NSMutableDictionary * record_dict = [[NSMutableDictionary alloc] initWithCapacity:0];
            NSMutableDictionary * conflict_dict = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
            
            NSMutableArray * array = [wsResponse.result valueMap];
            
            for (int i = 0; i < [array count]; i++)
            {
                INTF_WebServicesDefServiceSvc_SVMXMap * svmxMap = [array objectAtIndex:i];
                
                NSString * key = (svmxMap.key != nil)?(svmxMap.key):@"";
                NSString * object_name = (svmxMap.value != nil)?(svmxMap.value):@"";
                
                if([key isEqualToString:@"LAST_SYNC"] || [key isEqualToString:@"SYNC_TIME_STAMP"])
                {
                    delete_last_sync_time = object_name;
                }
                else  if([key isEqualToString:@"Object_Name"] ||[key isEqualToString:@"Parent_Object"] || [key isEqualToString:@"Child_Object"])
                {
                    NSString * record_type = DETAIL;
                    
                    NSMutableArray * valueMap = [svmxMap valueMap];
                    
                    if ([wsResponse.result.eventName isEqualToString:@"GET_DELETE"])
                    {
                        for (int j = 0; j < [valueMap count]; j++)
                        {
                            INTF_WebServicesDefServiceSvc_SVMXMap * record_map = [valueMap objectAtIndex:j];
                            NSString * field = (record_map.key!= nil) ?record_map.key:@"";//local_id
                            NSString * fieldValue    = (record_map.value != nil) ? record_map.value:@"";
                            
                            if([field isEqualToString:@"Fields"])
                            {
                                NSMutableArray * values =  [[self getIdsFromJsonString:fieldValue] retain];
                                
                                for (int k = 0; k < [values count]; k++)
                                {
                                    
                                    NSString * local_id = @"";
                                    NSString * sf_id    = [values objectAtIndex:k];
                                    
                                    NSArray * allkeys = [record_dict allKeys];
                                    BOOL flag = FALSE;
                                    
                                    for( NSString * temp in allkeys )
                                    {
                                        if([temp isEqualToString:object_name])
                                        {
                                            flag = TRUE;
                                            break;
                                        }
                                    }
                                    //NSString * sync_type = 
                                    if(flag)
                                    {
                                        NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id, @"",sf_id,event_name,record_type,nil] forKeys:[NSArray arrayWithObjects:@"LOCAL_ID",@"JSON_RECORD",@"SF_ID",@"SYNC_TYPE", @"RECORD_TYPE",nil]];
                                        NSMutableArray * array = [record_dict objectForKey:object_name];
                                        [array addObject:dict];
                                    }
                                    else
                                    {
                                        NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id, @"",sf_id,event_name,record_type,nil] forKeys:[NSArray arrayWithObjects:@"LOCAL_ID",@"JSON_RECORD",@"SF_ID", @"SYNC_TYPE", @"RECORD_TYPE",nil]];
                                        NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:0];
                                        [array addObject:dict];
                                        [record_dict setObject:array forKey:object_name];
                                    }
                                    
                                }
                                [values release];
                                
                            }
                            
                        }

                    }
                    else
                    {
                        for (int j = 0; j < [valueMap count]; j++)
                        {
                            INTF_WebServicesDefServiceSvc_SVMXMap * record_map = [valueMap objectAtIndex:j];
                            NSString * local_id = (record_map.key!= nil) ?record_map.key:@"";//local_id
                            NSString * sf_id    = (record_map.value != nil) ? record_map.value:@"";
                            
                            NSArray * allkeys = [record_dict allKeys];
                            BOOL flag = FALSE;
                            
                            for( NSString * temp in allkeys )
                            {
                                if([temp isEqualToString:object_name])
                                {
                                    flag = TRUE;
                                }
                            }
                            
                            if(flag)
                            {
                                NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id, @"",sf_id,event_name,record_type,nil] forKeys:[NSArray arrayWithObjects:@"LOCAL_ID",@"JSON_RECORD",@"SF_ID",@"SYNC_TYPE", @"RECORD_TYPE",nil]];
                                NSMutableArray * array = [record_dict objectForKey:object_name];
                                [array addObject:dict];
                            }
                            else
                            {
                                NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id, @"",sf_id,event_name,record_type,nil] forKeys:[NSArray arrayWithObjects:@"LOCAL_ID",@"JSON_RECORD",@"SF_ID", @"SYNC_TYPE", @"RECORD_TYPE",nil]];
                                NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:0];
                                [array addObject:dict];
                                [record_dict setObject:array forKey:object_name];
                            }
                        }
                    }
                }
                else if ([key isEqualToString:@"CONFLICT"] || [key isEqualToString:@"ERROR"])
                {
                    NSMutableArray * valueMap = [svmxMap valueMap];
                    for (int j = 0; j < [valueMap count]; j++)
                    {
                        INTF_WebServicesDefServiceSvc_SVMXMap * record_map = [valueMap objectAtIndex:j];
                        
                        NSString * record_type = @"";
                        NSString * object_name  = (record_map.key!= nil) ?record_map.key:@"";//local_id
                        NSString * sf_id = @""  , * local_id = @"";
                        
                        NSString * error_message =  (record_map.value != nil) ? record_map.value:@"";
                        
                        NSMutableArray *  errorvaluemap  = record_map.valueMap;
                        
                        for(int w = 0 ; w < [errorvaluemap count]; w++)
                        {
                            INTF_WebServicesDefServiceSvc_SVMXMap * error_svmxc_map = [errorvaluemap objectAtIndex:w];
                            local_id = (error_svmxc_map.key!= nil )?error_svmxc_map.key:@"";
                            sf_id    = (error_svmxc_map.value != nil)? error_svmxc_map.value:@"";
                        }
                        
                        
                        BOOL isChild = [appDelegate.databaseInterface  IsChildObject:object_name];
                        if(isChild)
                        {
                            record_type = DETAIL;
                        }
                        else                   //Child_Object
                        {
                            record_type = MASTER;
                        }
                        
                        /* NSMutableArray * errors = record_map.values;//object at index 0 will have the Error String  
                         
                         if([errors count] >0)
                         {
                         error_message = [errors objectAtIndex:0];
                         }*/
                        
                        NSArray * allkeys = [conflict_dict allKeys];
                        BOOL flag = FALSE;
                        
                        for( NSString * temp in allkeys)
                        {
                            if([temp isEqualToString:object_name])
                            {
                                flag = TRUE;
                                break;
                            }
                        }
                        if(flag)
                        {
                            NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id ,sf_id,event_name,record_type,error_message,key,nil] forKeys:[NSArray arrayWithObjects:@"LOCAL_ID",@"SF_ID",@"SYNC_TYPE", @"RECORD_TYPE",@"ERROR_MSG",@"ERROR_TYPE",nil]];
                            NSMutableArray * array = [conflict_dict objectForKey:object_name];
                            [array addObject:dict];
                        }
                        else
                        {
                            NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id ,sf_id,event_name,record_type,error_message,key,nil] forKeys:[NSArray arrayWithObjects:@"LOCAL_ID",@"SF_ID",@"SYNC_TYPE", @"RECORD_TYPE",@"ERROR_MSG",@"ERROR_TYPE",nil]];
                            NSMutableArray * array = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
                            [array addObject:dict];
                            [conflict_dict setObject:array forKey:object_name];
                        }
                    }
                }
            }
            
            [appDelegate.databaseInterface  insertRecordIdsIntosyncRecordHeap:record_dict];
            [appDelegate.databaseInterface  insertSyncConflictsIntoSYNC_CONFLICT:conflict_dict];
            if([wsResponse.result.eventName isEqualToString:@"GET_DELETE"])
            {
                appDelegate.Incremental_sync_status = GET_DELETE_DONE;
            }
            else if ([wsResponse.result.eventName isEqualToString:@"PUT_DELETE"])
            {
                appDelegate.Incremental_sync_status = PUT_DELETE_DONE;
            }
        }
        else if([wsResponse.result.eventName isEqualToString:GET_DELETE]|| [wsResponse.result.eventName isEqualToString:GET_UPDATE] || [wsResponse.result.eventName isEqualToString:GET_INSERT] || [wsResponse.result.eventName isEqualToString:GET_INSERT_DOWNLOAD_CRITERIA] || [wsResponse.result.eventName isEqualToString:GET_UPDATE_DOWNLOAD_CRITERIA] || [wsResponse.result.eventName isEqualToString:GET_DELETE_DOWNLOAD_CRITERIA])
        {
            
            NSString * event_name = wsResponse.result.eventName;
            NSString * temp_event_name = @"";
            
            if ([wsResponse.result.eventName isEqualToString:GET_INSERT_DOWNLOAD_CRITERIA] || [event_name isEqualToString:GET_INSERT])
            {
                temp_event_name = GET_INSERT;
            }
            else if ([wsResponse.result.eventName isEqualToString:GET_UPDATE_DOWNLOAD_CRITERIA] || [event_name isEqualToString:GET_UPDATE])
            {
                 temp_event_name = GET_UPDATE;
            }
            else if ([wsResponse.result.eventName isEqualToString:GET_DELETE_DOWNLOAD_CRITERIA] || [event_name isEqualToString:GET_DELETE])
            {
                 temp_event_name = GET_DELETE;
            }
            
            NSMutableDictionary * record_dict = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
            NSMutableArray * array = [wsResponse.result valueMap];
            BOOL call_Back = FALSE;
            for (int i = 0; i < [array count]; i++)
            {
                INTF_WebServicesDefServiceSvc_SVMXMap * svmxMap = [array objectAtIndex:i];
                
                NSString * key = (svmxMap.key != nil)?(svmxMap.key):@"";
                NSString * object_name = (svmxMap.value != nil)?(svmxMap.value):@"";
                
                if([key isEqualToString:@"LAST_SYNC"] || [key isEqualToString:@"SYNC_TIME_STAMP"])
                {
                    if([wsResponse.result.eventName isEqualToString:GET_INSERT])
                    {
                        insert_last_sync_time = object_name;
                    }
                    else if([wsResponse.result.eventName isEqualToString:GET_UPDATE])
                    {
                        update_last_sync_time = object_name;
                    }
                    else if ([wsResponse.result.eventName isEqualToString:GET_DELETE])
                    {
                        delete_last_sync_time = object_name;
                    }
                }
                else if ([key isEqualToString:@"CALL_BACK"])
                {
                    call_Back = [svmxMap.value boolValue];
                }
                else if ([key isEqualToString:@"PARTIAL_EXECUTED_OBJECT"])
                {
                    appDelegate.initital_sync_object_name = (svmxMap.value != nil)?svmxMap.value:@"";
                }
                else if([key isEqualToString:@"LAST_INDEX"])
                {
                    appDelegate.initial_Sync_last_index = (svmxMap.value != nil)?svmxMap.value:@"";
                }
                else if([key isEqualToString:DOWNLOAD_CRITERIA_OBJECTS])
                {
                  //  NSMutableDictionary * dcobjects = [[NSMutableDictionary alloc] initWithCapacity:0];
                    NSMutableArray * dc_objects = svmxMap.values;
                    for(NSString  * str in dc_objects)
                    {
                        NSArray * arr = [str componentsSeparatedByString:@","];
                        if([arr count] <= 2)
                        {
                            NSString * objectName =[arr objectAtIndex:0];
                            NSString * whereclause = [arr objectAtIndex:1];
                            SMLog(@"class - %@" ,[dcobjects_incrementalSync class]);
                            [dcobjects_incrementalSync setObject:whereclause forKey:objectName];
                        }
                    }
                    
                   /* NSAutoreleasePool * autoreleasePool = [[NSAutoreleasePool alloc]init];
                    SBJsonParser * parser = [[[SBJsonParser alloc] init] autorelease];
                    NSDictionary * dict = [[parser objectWithString:svmxMap.value] retain];
                    SMLog(@"%@",dict);
                    [self downloadcriteriaplist:dict];
                    [autoreleasePool release];*/

                   // [self downloadcriteriaplist:dcobjects_incrementalSync];
                  
                }
                else if([key isEqualToString:@"Object_Name"] ||[key isEqualToString:@"Parent_Object"] || [key isEqualToString:@"Child_Object"])
                {
                    NSString * record_type = @"";
                    BOOL isChild = [appDelegate.databaseInterface  IsChildObject:object_name];
                    if(isChild)
                    {
                        record_type = DETAIL;
                    }
                    else                   //Child_Object
                    {
                        record_type = MASTER;
                    }
                    
                    NSMutableArray * valueMap = [svmxMap valueMap];
                    if ([event_name isEqualToString:GET_UPDATE] || [event_name isEqualToString:GET_INSERT] || [event_name isEqualToString:GET_DELETE] || [wsResponse.result.eventName isEqualToString:GET_INSERT_DOWNLOAD_CRITERIA] ||[wsResponse.result.eventName isEqualToString:GET_UPDATE_DOWNLOAD_CRITERIA]||[wsResponse.result.eventName isEqualToString:GET_DELETE_DOWNLOAD_CRITERIA])
                    {
                        for (int j = 0; j < [valueMap count]; j++)
                        {
                            INTF_WebServicesDefServiceSvc_SVMXMap * record_map = [valueMap objectAtIndex:j];
                            NSString * field = (record_map.key!= nil) ?record_map.key:@"";//local_id
                            NSString * fieldValue    = (record_map.value != nil) ? record_map.value:@"";
                            
                            if([field isEqualToString:@"Fields"])
                            {
                                NSMutableArray * values =  [[self getIdsFromJsonString:fieldValue] retain];
                                
                                for (int k = 0; k < [values count]; k++)
                                {
                                    
                                    NSString * local_id = @"";
                                    NSString * sf_id    = [values objectAtIndex:k];
                                    
                                    NSArray * allkeys = [record_dict allKeys];
                                    BOOL flag = FALSE;
                                    
                                    for( NSString * temp in allkeys )
                                    {
                                        if([temp isEqualToString:object_name])
                                        {
                                            flag = TRUE;
                                            break;
                                        }
                                    }
                                    //NSString * sync_type = 
                                    if(flag)
                                    {
                                        NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id, @"",sf_id,temp_event_name,record_type,nil] forKeys:[NSArray arrayWithObjects:@"LOCAL_ID",@"JSON_RECORD",@"SF_ID",@"SYNC_TYPE", @"RECORD_TYPE",nil]];
                                        NSMutableArray * array = [record_dict objectForKey:object_name];
                                        [array addObject:dict];
                                    }
                                    else
                                    {
                                        NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id, @"",sf_id,temp_event_name,record_type,nil] forKeys:[NSArray arrayWithObjects:@"LOCAL_ID",@"JSON_RECORD",@"SF_ID", @"SYNC_TYPE", @"RECORD_TYPE",nil]];
                                        NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:0];
                                        [array addObject:dict];
                                        [record_dict setObject:array forKey:object_name];
                                    }
                                    
                                }
                                [values release];
                                
                            }
                            
                        }
                        
                    }
                    
                }
            }
            
            SMLog(@"UPDATE %@", record_dict);
            [appDelegate.databaseInterface  insertRecordIdsIntosyncRecordHeap:record_dict];
            if([event_name isEqualToString:GET_UPDATE])
            {
                appDelegate.Incremental_sync_status = GET_UPDATE_DONE;
            }
            else if ([event_name isEqualToString:GET_INSERT])
            {
                appDelegate.Incremental_sync_status = GET_INSERT_DONE;
            }
            else if ([event_name isEqualToString:GET_DELETE])
            {
                appDelegate.Incremental_sync_status = GET_DELETE_DONE;
            }
            
            if(call_Back)
            {
                [self  GETDownloadCriteriaRecordsFor:wsResponse.result.eventName];
            }
            else
            {
                if ([wsResponse.result.eventName isEqualToString:GET_INSERT_DOWNLOAD_CRITERIA])
                {
                    appDelegate.Incremental_sync_status = GET_INSERT_DC_DONE;
                }
                else if ([wsResponse.result.eventName isEqualToString:GET_UPDATE_DOWNLOAD_CRITERIA])
                {
                    appDelegate.Incremental_sync_status = GET_UPDATE_DC_DONE;
                }
                else if ([wsResponse.result.eventName isEqualToString:GET_DELETE_DOWNLOAD_CRITERIA])
                {
                    appDelegate.Incremental_sync_status = GET_DELETE_DC_DONE;
                }
            }
        }
        else if([wsResponse.result.eventName isEqualToString:@"CLEAN_UP_SELECT"] || [wsResponse.result.eventName isEqualToString:@"CLEAN_UP"])
        {
            appDelegate.Incremental_sync_status = CLEANUP_DONE;
        }
        else if ([wsResponse.result.eventName isEqualToString:@"DATA_ON_DEMAND"] || [wsResponse.result.eventName isEqualToString:@"GET_DATA"])
        {
            appDelegate.dod_status = RETRIEVING_DATA;
            appDelegate.Sync_check_in = FALSE;
            
            NSMutableDictionary * record_dict = [[NSMutableDictionary alloc] initWithCapacity:0];
            NSMutableArray * array = [wsResponse.result valueMap];
            for(int i = 0 ;i< [array count]; i++)
            {
                INTF_WebServicesDefServiceSvc_SVMXMap * svmxMap = [array objectAtIndex:i];
                
              //  NSString * key = (svmxMap.key != nil)?(svmxMap.key):@"";
                NSString * object_name = (svmxMap.value != nil)?(svmxMap.value):@"";
                
                            
                NSArray * records = svmxMap.valueMap;
                
                for(int j = 0 ; j < [records count]; j++)
                {
                    INTF_WebServicesDefServiceSvc_SVMXMap * recordLevel_map = [records objectAtIndex:j];
                    NSString * master_or_detail = recordLevel_map.key;
                    NSString * json_record = recordLevel_map.value;
                    
                    if([master_or_detail isEqualToString:@"Parent_Record"])
                    {
                        NSMutableDictionary * Tempdict = [[NSMutableDictionary alloc] initWithCapacity:0];
                        NSMutableArray * tempArray  = [[NSMutableArray alloc] initWithCapacity:0];
                        [tempArray addObject:json_record];
                        [Tempdict setObject:tempArray forKey:object_name];
                        [record_dict setObject:Tempdict forKey:MASTER];
                        [Tempdict release];
                        [tempArray release];
                    }
                    else if([master_or_detail isEqualToString:@"Child_Record"])
                    {
                        NSArray * all_keys = [record_dict allKeys];
                        BOOL does_key_exist = FALSE;
                       if( [all_keys containsObject:DETAIL])
                       {
                           does_key_exist = TRUE;
                       }
                        if(does_key_exist)
                        {
                            NSMutableDictionary * tempDict = [record_dict objectForKey:DETAIL];
                            NSMutableArray * temparray= [ tempDict objectForKey:object_name];
                            [temparray addObject:json_record];
                        }
                        else
                        {
                            NSMutableDictionary * Tempdict = [[NSMutableDictionary alloc] initWithCapacity:0];
                            NSMutableArray * Temp_array = [[NSMutableArray alloc] initWithCapacity:0];
                            [Temp_array addObject:json_record];
                            [Tempdict setObject:Temp_array forKey:object_name];
                            [record_dict setObject:Tempdict forKey:DETAIL];
                            [Temp_array release];
                            [Tempdict release];
                        }
                    }
                    
                }
                
                
            }
          
            
            SMLog(@"record_dict %@",record_dict);
            [appDelegate.databaseInterface insertOndemandRecords:record_dict];
            
            appDelegate.dod_status = SAVING_DATA;
            appDelegate.Sync_check_in = FALSE;
            
            [record_dict release];
            appDelegate.dod_req_response_ststus = DOD_RESPONSE_RECIEVED;
        }
             
        
        
        SMLog(@"DataSync End: %@", [NSDate date]);
    }
    
    if([operation isKindOfClass:[INTF_WebServicesDefBinding_SVMX_GetSvmxVersion class]])
    {
        
        INTF_WebServicesDefServiceSvc_SVMX_GetSvmxVersionResponse * wsResponse = [response.bodyParts objectAtIndex:0];
        NSMutableArray * result = wsResponse.result;
        if([result count] > 0)
        {
            KeyValue_KeyValue * value = [result objectAtIndex:0];
            appDelegate.SVMX_Version = value.value;
        }
        appDelegate.didGetVersion = TRUE;
       // [self metaSync];
        
        
        SMLog( @"getVersion");
    }
    // for addrecode_ws
    if([operation isKindOfClass:[INTF_WebServicesDefBinding_INTF_Update_Events_WS class]])
    {
        SMLog(@"Update_Events");
        INTF_WebServicesDefServiceSvc_INTF_Update_Events_WSResponse * wsResponse = [response.bodyParts objectAtIndex:0];
        
        if (rescheduleEvent != nil)
        {
            [rescheduleEvent release];
            rescheduleEvent = nil;
        }
        
        rescheduleEvent = (wsResponse.result != nil)?(wsResponse.result):@"";
        [rescheduleEvent retain];
        didRescheduleEvent = TRUE;
    }
    
    if([operation isKindOfClass:[INTF_WebServicesDefBinding_INTF_AddRecords_WS class]])
    {
        SMLog(@"%@",response);
        if (detail_addRecordItems != nil)
        {
            [detail_addRecordItems release];
            detail_addRecordItems = nil;
        }
        detail_addRecordItems = [[self getAddRecordsFields:response] retain];
        
    }
    if([operation isKindOfClass:[INTF_WebServicesDefBinding_SFM_SaveTargetRecords_WS class]])
    {
        NSArray * bodyParts = response.bodyParts;
        if ([bodyParts count] == 0)
            return;
        INTF_WebServicesDefServiceSvc_SFM_SaveTargetRecords_WSResponse * obj ;
        USBoolean * success;
        BOOL success_save;
        if([bodyParts count] != 0)
        {
            obj = [bodyParts objectAtIndex:0];
            INTF_WebServicesDefServiceSvc_INTF_Response *  result_response = obj.result;
            if (result_response == nil)
                return;
            success = result_response.success;
            NSString * response_message = result_response.message;
            success_save = success.boolValue;
            [detailDelegate didFinshSave:response_message];
            if(success_save)
            {
                appDelegate.sfmSaveError = FALSE; 
            }
            else
            {
                appDelegate.sfmSaveError = TRUE;
            }
        }

        if ([[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"STANDALONECREATE"])
        {
            //sahana 16th Sept
            didGetProcessId = FALSE;
            
            
            appDelegate.createObjectContext = [self getSaveTargetRecords:response];
            
            while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO))
            {
                SMLog(@"WSInterface operation in while loop");
                /*if (![appDelegate isInternetConnectionAvailable])
                {
                    didGetProcessId = TRUE;
                    appDelegate.sfmSave = TRUE;
                    [appDelegate displayNoInternetAvailable];
                    
                    if (appDelegate.SFMPage != nil)
                    {
                        [appDelegate.SFMPage release];
                        appDelegate.SFMPage = nil;
                    }
                    
                    return;
                }*/
                SMLog(@"SaveResponse");
                if (didGetProcessId)
                {
                    didGetProcessId = FALSE;
                    break;
                }
            }

            [appDelegate.createObjectContext setValue:appDelegate.currentProcessID forKey:PROCESSID];
            SMLog(@"%@", appDelegate.createObjectContext); 
        }
        
        if ([[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"SOURCETOTARGET"])
        {
           //sahana 16th Sept
            didGetProcessId = FALSE;
            // Sahana - 5th Aug, 2011
            
            appDelegate.createObjectContext = [self getSaveTargetRecords:response];
            while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO))
            {
                SMLog(@"WSInterface operation in while loop");
                /*if (![appDelegate isInternetConnectionAvailable])
                {
                    didGetProcessId = TRUE;
                    appDelegate.sfmSave = TRUE;
                    [appDelegate displayNoInternetAvailable];
                    
                    if (appDelegate.SFMPage != nil)
                    {
                        [appDelegate.SFMPage release];
                        appDelegate.SFMPage = nil;
                    }
                    
                    return;
                }*/
                SMLog(@"SaveResponse");
                if (didGetProcessId)
                {
                    didGetProcessId = FALSE;
                    break;
                }
            }
            [appDelegate.createObjectContext setValue:appDelegate.currentProcessID forKey:PROCESSID];
            SMLog(@"%@", appDelegate.createObjectContext); 

        }
        // sahana 14th sept
        appDelegate.sfmSave = TRUE;
        return;
    }
    
    // Obtain Tags 
    // Radha 29 April 2011
    // checks for the response is of type get_tags
    if ( [operation isKindOfClass:[INTF_WebServicesDefBinding_INTF_Get_Tags_WS class]] )
    {
        tagsDictionary = [[self getTagsdisplay:response] retain];
        responseError = 0;
        //   SMLog(@"%@", appDelegate.tagsDictionary);
        [self getCreateProcesses];
    }
    
    if ([operation isKindOfClass:[INTF_WebServicesDefBinding_INTF_Get_Tasks_WS class]])
    {
        // Do something
        tasks = [self getTasksFromResponse:response];
    }

    if ([operation isKindOfClass:[INTF_WebServicesDefBinding_INTF_Get_View_Layouts_WS class]])
    {
        viewLayoutsArray = [self getViewLayoutArray:response];
        SMLog(@"%@", viewLayoutsArray);
        [viewLayoutsArray retain];
        NSDate *date = [NSDate date];
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString * dateString = [dateFormatter stringFromDate:date];
        [self getWeekdates:dateString];
        [self getEventsForStartDate:startDate EndDate:endDate];
    } 
    
    if ([operation isKindOfClass:[INTF_WebServicesDefBinding_INTF_Get_WorkOrderMapView_WS class]])
    {
        SMLog(@"Mapview");
        NSMutableDictionary * dict = [self getWorkOrderDetails:response];
        [appDelegate.workOrderInfo addObject:dict];
    }
        
    if ( [operation isKindOfClass:[INTF_WebServicesDefBinding_INTF_Get_StandaloneCreate_Layouts class]] )
    {
        createProcessArray = [self getCreateProcessesDictionaryArray:response];
        [createProcessArray retain];
        [self getViewLayouts];
    }
    
    if ([operation isKindOfClass:[INTF_WebServicesDefBinding_INTF_Get_Events_WS class]])
    {
        SMLog(@"Get Events Completed");
        //Radha 30th April 2011
        responseError = 0;
        eventArray = [self getEventdisplay:response];
        [eventArray retain];
        didRescheduleEvent = TRUE;
        [self didFinishGetEventsWithFault:nil];
    }
    
    if ([operation isKindOfClass:[INTF_WebServicesDefBinding_INTF_getPageLayout_WS class]])
    {
        INTF_WebServicesDefBindingResponse  * operaton_response = operation.response; 
        if (operaton_response == nil)
            return;
        NSArray * operation_bodyparts =operaton_response.bodyParts;
        if ([operation_bodyparts count] == 0)
            return;
        USBoolean * success_msg;
        BOOL success;
        INTF_WebServicesDefServiceSvc_INTF_getPageLayout_WSResponse * operation_wsresponse = [operation_bodyparts objectAtIndex:0];
        if (operation_wsresponse == nil)
            return;
        INTF_WebServicesDefServiceSvc_INTF_Response_PageUI * operation_result = operation_wsresponse.result;
        INTF_WebServicesDefServiceSvc_INTF_Response * operation_result_response = operation_result.response;
        if (operation_result_response == nil)
            return;
        NSString * operation_message = operation_result_response.message;
        success_msg = operation_result_response.success;
        success = success_msg.boolValue;

        if(!success)
        {
            appDelegate.wsInterface.errorLoadingSFM = TRUE;
            appDelegate.wsInterface.sfm_response = TRUE;
            [detailDelegate didFinishWithSuccess:operation_message]; 
            return;
        }
        
       appDelegate.wsInterface.sfm_response = TRUE;
        
        NSMutableArray * bodyParts = [[response bodyParts] mutableCopy];
        if ([bodyParts count] == 0)
            return;
        INTF_WebServicesDefServiceSvc_INTF_getPageLayout_WSResponse * wsResponse = nil;
        INTF_WebServicesDefServiceSvc_INTF_Response_PageUI * result = nil;
        INTF_WebServicesDefServiceSvc_INTF_PageUI * page = nil;

        INTF_WebServicesDefServiceSvc_INTF_Response *response = nil;
        NSString * process_type = @"";
        
        INTF_WebServicesDefServiceSvc_INTF_PageHeader * header = nil;
        NSMutableArray * details = nil;
        
        // NSMutableArray * keys = [NSMutableArray arrayWithObjects:gWSRESPONSE, gRESULT, gPAGE, gHEADER, gDETAILS, nil];
        NSMutableArray * keys = [NSMutableArray arrayWithObjects:gPAGE, gHEADER, gDETAILS, gPROCESSTYPE, gRESPONSE, nil];
        
        for (int i = 0; i < [bodyParts count]; i++)
        {
            wsResponse = [bodyParts objectAtIndex:i];
            if ([wsResponse isKindOfClass:[SOAPFault class]])
            {
                [self getWrapperDictionary:nil];
                return;
            }
            result = [wsResponse result];
            page = [result page];
            header = [page header];
            details = [page details];
            response = [result response];

            NSArray * stringmaps = [response stringMap];
            for (int i=0;i<[stringmaps count];i++)
            {
                INTF_WebServicesDefServiceSvc_INTF_StringMap *stringmap = [stringmaps objectAtIndex:i];
                if ([stringmap.key isEqualToString:gPROCESSTYPE])
                    process_type = stringmap.value;
            }

            if (bodyParts == nil)
                bodyParts = [[NSMutableArray alloc] initWithCapacity:0];
            
            NSMutableArray * objects = [NSMutableArray arrayWithObjects:page, header, details, process_type, response, nil];
            NSMutableDictionary * dict = [[NSMutableDictionary dictionaryWithObjects:objects forKeys:keys] retain];
            
            [self getWrapperDictionary:dict];
        }
    }
    
    if ([operation isKindOfClass:[INTF_WebServicesDefBinding_INTF_SavePageLayout_WS class]])
    {
        // Do something
    }
    
    if ([operation isKindOfClass:[INTF_WebServicesDefBinding_INTF_getLookUpConfigWithData_WS class]])
    {
        // Do something
        [self describeObjectFromResponse:response];
    }
    
    if ([operation isKindOfClass:[INTF_WebServicesDefBinding_INTF_Get_Account_History_WS class]])
    {
        // Do something
        if (accountHistory != nil)
        {
            [accountHistory release];
            accountHistory = nil;
        }
        accountHistory = [[self getAccountHistoryFromResponse:response] retain];
        SMLog(@"%@", accountHistory);
        didGetAccountHistory = YES;
    }
    
    if ([operation isKindOfClass:[INTF_WebServicesDefBinding_INTF_Get_Product_History_WS class]])
    {
        // Do something
        if (productHistory != nil)
        {
            [productHistory release];
            productHistory = nil;
        }
        productHistory = [[self getProductHistoryFromResponse:response] retain];
        SMLog(@"%@", productHistory);
        didGetProductHistory = YES;
    }
    
    if ([operation isKindOfClass:[INTF_WebServicesDefBinding_INTF_PREQ_GetPrice_WS class]])
    {        

        if(AfterSaveEventsCalls)
        {
            didCompleteAfterSaveEventCalls = NO;
            return;
        }
        /*
        else if (appDelegate.wsInterface.webservice_call == TRUE)
        {
            appDelegate.wsInterface.getPrice = TRUE;
            appDelegate.wsInterface.webservice_call = FALSE;
            return;
        }
         */
        // Do something
        NSArray * bodyParts = [response bodyParts];
        if ([bodyParts count] == 0)
            return;
        INTF_WebServicesDefServiceSvc_INTF_PREQ_GetPrice_WSResponse * getEventResponse = [bodyParts objectAtIndex:0];
        INTF_WebServicesDefServiceSvc_INTF_PageData * pageData = [getEventResponse result];
        
        NSMutableArray * detailDataSetArray = [pageData detailDataSet];
        NSString * escape_string = @"$#@";
        for (int i = 0; i < [detailDataSetArray count]; i++)
        {
            INTF_WebServicesDefServiceSvc_INTF_DetailDataSet * detailDataSet = [detailDataSetArray objectAtIndex:i];
            NSString * aliasName = [detailDataSet aliasName];
            NSMutableArray * details = [appDelegate.SFMPage objectForKey:gDETAILS]; //as many as number of lines sections
            //sahana 
            NSMutableArray * event_Record_id_set = [[NSMutableArray alloc] initWithCapacity:0];
            NSArray * record_key = [NSArray arrayWithObjects:@"RecordId",@"RecordNum",nil];
            
            // NSMutableArray * temp_details_record_id = nil;
            NSInteger index_detailValueArray ;
            //NSString * detail_alias_name = @"";
            //Siva Manne
            NSMutableArray * pageDataSet = [detailDataSet pageDataSet];
            for(int j= 0 ;j< [pageDataSet count];j++)
            {
                INTF_WebServicesDefServiceSvc_INTF_PageDataSet * uiField = [pageDataSet objectAtIndex:j];
                NSMutableArray  * bubbleInfo = uiField.bubbleInfo;
                
                NSString * Record_Id = nil;
                //sahana 30th July
                NSInteger recordNO = 99999;
                NSMutableDictionary * bubbleInfoDict = [[NSMutableDictionary alloc] initWithCapacity:0];
                for (int k = 0; k < [bubbleInfo count]; k++)
                {
                    INTF_WebServicesDefServiceSvc_INTF_BubbleWrapper * bubbleWrapper = [bubbleInfo objectAtIndex:k];
                    NSString * field_api_name = bubbleWrapper.fieldapiname ; 
                    SMLog(@"Field API Name = %@",field_api_name);
                    INTF_WebServicesDefServiceSvc_INTF_StringMap * stringMap = bubbleWrapper.fieldvalue;
                    NSString * key = stringMap.key;
                    NSString * value = stringMap.value;
                    NSString * value1 = stringMap.value1;
                    //get the detail object from the SFM dictionary
                    if([field_api_name isEqualToString:@"_Id"])
                    {
                        Record_Id = key;
                    }
                    //sahana 30th July
                    else if([field_api_name isEqualToString:@"SequenceNo_for_Record"])
                    {
                        SMLog(@" key %@  loopValue %d",key,k);
                        if(key == nil)
                        {
                            recordNO = 99999;
                        }
                        else
                        {
                            recordNO = [key integerValue];
                        }
                    }
                    
                    SMLog(@" key %@  loopValue %@",key,value);
                    
                    NSMutableArray  * arr = [[NSMutableArray alloc] initWithCapacity:0];
                    
                    NSDictionary * dict = [NSDictionary dictionaryWithObject:(key != nil)?key:@"" forKey:@"key"];
                    NSDictionary * dict1 ;
                    NSString * final_value = @"";
                    if(value1 != nil)
                    {
                        final_value = value1;
                    }
                    else if (value != nil && value1 == nil)
                    {
                        final_value = value;
                    }
                    else 
                    {
                        final_value = @"";
                    }
                    
                    dict1 = [NSDictionary dictionaryWithObject:final_value forKey:@"value"];
                    
                    [arr addObject:dict];
                    [arr addObject:dict1];
                    
                    [bubbleInfoDict setValue:arr forKey:field_api_name];
                    [arr release];
                }
                
                
                SMLog(@"   NUm  %d" ,recordNO);
                NSString * str_record_num = [NSString stringWithFormat:@"%d" , recordNO];
                NSString * str_record_id = @"";
                if(Record_Id != nil)
                {
                    str_record_id = Record_Id;
                }
                
                NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:str_record_id,str_record_num, nil] forKeys:record_key];
                [event_Record_id_set addObject:dict];
                
                SMLog(@" event_Record_id_set :%@", event_Record_id_set);
                
                //sahana 30th July
                if(Record_Id == nil)
                {
                    for (int i=0;i<[details count];i++) //parts, labor, expense for instance
                    {
                        NSMutableDictionary * detail = [details objectAtIndex:i];
                        NSString * DictaliasName = [detail objectForKey:gDETAIL_OBJECT_ALIAS_NAME]; 
                        if([DictaliasName isEqualToString:aliasName])
                        {
                            index_detailValueArray = i;
                            NSMutableArray * detail_values_array = [detail objectForKey:gDETAILS_VALUES_ARRAY];
                            NSMutableArray * details_record_ids = [detail objectForKey:gDETAIL_VALUES_RECORD_ID];
                         //   NSMutableArray * detail_sobject = [detail objectForKey:gDETAIL_SOBJECT_ARRAY];
                            NSInteger emptyRecId_count = 0;
                            
                            for(int p = 0; p < [details_record_ids count];p++)
                            {
                                NSString * rec_id = [details_record_ids objectAtIndex:p];
                                if([rec_id isEqualToString:@""])
                                {
                                    
                                    SMLog(@"  Record_Id --> %d  rec_id --> %d",emptyRecId_count , recordNO);
                                    if (emptyRecId_count == recordNO)
                                    {
                                        NSMutableArray * detailValuesArray = [detail_values_array objectAtIndex:p];
                                        NSArray * allkeys = [bubbleInfoDict allKeys];
                                        SMLog(@"%@", bubbleInfoDict);
                                        for(int q = 0 ; q < [allkeys count]; q++)
                                        {
                                            BOOL flag = FALSE;
                                            NSString * bubbleInfoDictKey = [allkeys objectAtIndex:q];
                                            NSMutableDictionary * keyValueDict = nil;
                                            
                                          
                                            for(int q = 0; q < [detailValuesArray count]; q++)
                                            {
                                                keyValueDict =[detailValuesArray objectAtIndex:q];
                                                NSString * api_name = [keyValueDict objectForKey:gVALUE_FIELD_API_NAME];
                                                //collect all keys from bubbleinfo dict 
                                                SMLog(@"%@ %@",bubbleInfoDictKey , api_name);
                                                if([bubbleInfoDictKey isEqualToString:api_name])
                                                {
                                                    flag = TRUE;
                                                    break;
                                                } 
                                            }
                                            
                                            if(flag)
                                            {
                                                NSMutableArray * strmap =[bubbleInfoDict objectForKey:bubbleInfoDictKey];
                                                if([strmap count] > 0)
                                                {
                                                    //retrieving key from dict 
                                                    NSMutableDictionary * key_dict = [strmap objectAtIndex:0];
                                                    NSString * key = [key_dict objectForKey:@"key"];
                                                    //retrieving value from dict
                                                    NSMutableDictionary * key_dict1 = [strmap objectAtIndex:1];
                                                    NSString * value = [key_dict1 objectForKey:@"value"];
                                                    
                                                    SMLog(@"present  bubbleInfoDictKey %@ key %@ value %@", bubbleInfoDictKey,key,value);
                                                    [keyValueDict setValue:key forKey:gVALUE_FIELD_VALUE_KEY];
                                                    [keyValueDict setValue:value forKey:gVALUE_FIELD_VALUE_VALUE];
                                                }
                                            }
                                            
                                            if(!flag)
                                            {
                                                
                                                NSMutableArray * strmap =[bubbleInfoDict objectForKey:bubbleInfoDictKey];
                                                if([strmap count] > 0)
                                                {
                                                    //retrieving key from dict 
                                                    NSMutableDictionary * key_dict = [strmap objectAtIndex:0];
                                                    NSString * key = [key_dict objectForKey:@"key"];
                                                    //retrieving value from dict
                                                    NSMutableDictionary * key_dict1 = [strmap objectAtIndex:1];
                                                    NSString * value = [key_dict1 objectForKey:@"value"];
                                                    
                                                    NSMutableArray * keys = [NSMutableArray arrayWithObjects:
                                                                             gVALUE_FIELD_API_NAME,
                                                                             gVALUE_FIELD_VALUE_KEY,
                                                                             gVALUE_FIELD_VALUE_VALUE,
                                                                             nil];
                                                    SMLog(@"bubbleInfoDictKey %@ key %@ value %@", bubbleInfoDictKey,key,value);
                                                    
                                                    NSMutableArray * objects = [NSMutableArray arrayWithObjects:bubbleInfoDictKey, key, value, nil];
                                                    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:objects forKeys:keys];
                                                    [detailValuesArray addObject:dict];
                                                }
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                    emptyRecId_count++; 
                                }
                            }
                            if(recordNO == 99999)
                            {
                                NSArray * allkeys = [bubbleInfoDict allKeys];
                                NSMutableArray * detailValuesArray = [[NSMutableArray alloc] initWithCapacity:0]; 
                                for(int q = 0 ; q < [allkeys count]; q++)
                                {
                                    NSString * bubbleInfoDictKey = [allkeys objectAtIndex:q];
                                    
                                    NSMutableArray * strmap =[bubbleInfoDict objectForKey:bubbleInfoDictKey];
                                    if([strmap count] > 0)
                                    {
                                        //retrieving key from dict 
                                        NSMutableDictionary * key_dict = [strmap objectAtIndex:0];
                                        NSString * key = [key_dict objectForKey:@"key"];
                                        //retrieving value from dict
                                        NSMutableDictionary * key_dict1 = [strmap objectAtIndex:1];
                                        NSString * value = [key_dict1 objectForKey:@"value"];
                                        
                                        NSMutableArray * keys = [NSMutableArray arrayWithObjects:
                                                                 gVALUE_FIELD_API_NAME,
                                                                 gVALUE_FIELD_VALUE_KEY,
                                                                 gVALUE_FIELD_VALUE_VALUE,
                                                                 nil];
                                        
                                        NSMutableArray * objects = [NSMutableArray arrayWithObjects:bubbleInfoDictKey, key, value, nil];
                                        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:objects forKeys:keys];
                                        [detailValuesArray addObject:dict];
                                    }
                                }
                                if([detailValuesArray count] >  0)
                                {
                                    //sahana 20th August 2011
                                    NSMutableArray * keys = [NSMutableArray arrayWithObjects:
                                                             gVALUE_FIELD_API_NAME,
                                                             gVALUE_FIELD_VALUE_KEY,
                                                             gVALUE_FIELD_VALUE_VALUE,
                                                             nil];
                                    NSMutableArray * objects = [NSMutableArray arrayWithObjects:gDETAIL_SAVED_RECORD,[NSNumber numberWithInt:1],[NSNumber numberWithInt:1], nil];
                                    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:objects forKeys:keys];
                                    [detailValuesArray addObject:dict];
                                    
                                    [detail_values_array addObject:detailValuesArray];
                                    [details_record_ids addObject:escape_string];
                                    //[detail_sobject addObject:@""];
                                }
                            }
                            
                            SMLog(@"valuearray%@", detail_values_array);
                            SMLog(@" record_id ---%@",details_record_ids);
                        }
                        
                    }
                    
                }
                else
                {
                    for (int i=0;i<[details count];i++) //parts, labor, expense for instance
                    {
                        NSMutableDictionary * detail = [details objectAtIndex:i];
                        NSString * DictaliasName = [detail objectForKey:gDETAIL_OBJECT_ALIAS_NAME]; 
                         NSString * detail_object_name = [detail objectForKey:gDETAIL_OBJECT_NAME];
                        if([DictaliasName isEqualToString:aliasName])
                        {
                            
                            NSMutableArray * detail_values_array = [detail objectForKey:gDETAILS_VALUES_ARRAY];
                            NSMutableArray * details_record_ids = [detail objectForKey:gDETAIL_VALUES_RECORD_ID];
                           // NSMutableArray * detail_sobject = [detail objectForKey:gDETAIL_SOBJECT_ARRAY];
                            
                            NSString * local_id = [appDelegate.databaseInterface  getLocalIdFromSFId:Record_Id tableName:detail_object_name];
                            if ([local_id isEqualToString:@""] || [local_id length] == 0)
                            {
                                local_id = nil;
                            }
                            
                            BOOL record_exist = FALSE;
                            for(int p = 0; p < [details_record_ids count];p++)
                            {
                                NSString * rec_id = [details_record_ids objectAtIndex:p];
                                if((local_id != nil) && (rec_id != nil))
                                {
                                    
                                    SMLog(@"  Record_Id --> %@  rec_id --> %@",Record_Id , rec_id);
                                    if([local_id isEqualToString:rec_id])
                                    {
                                        NSMutableArray * detailValuesArray = [detail_values_array objectAtIndex:p];
                                        NSArray * allkeys = [bubbleInfoDict allKeys];
                                        
                                        NSMutableArray * Bubble_uniq_keys = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
                                
                                        for(int q = 0 ; q < [allkeys count]; q++)
                                        {
                                            BOOL flag = FALSE;
                                            NSString * bubbleInfoDictKey = [allkeys objectAtIndex:q];
                                            if([Bubble_uniq_keys containsObject:bubbleInfoDictKey])
                                            {
                                                continue;
                                            }
                                            else
                                            {
                                                [Bubble_uniq_keys addObject:bubbleInfoDictKey];
                                            }
                                            NSMutableDictionary * keyValueDict = nil;
                                            for(int q = 0; q < [detailValuesArray count]; q++)
                                            {
                                                keyValueDict =[detailValuesArray objectAtIndex:q];
                                                NSString * api_name = [keyValueDict objectForKey:gVALUE_FIELD_API_NAME];
                                                //collect all keys from bubbleinfo dict 
                                                SMLog(@"Idbubble info dict key %@ api_name %@ ", bubbleInfoDictKey , api_name);
                                                if([bubbleInfoDictKey isEqualToString:api_name])
                                                {
                                                    flag = TRUE;
                                                    break;
                                                } 
                                            }
                                            if(!flag)
                                            {
                                                NSMutableArray * strmap =[bubbleInfoDict objectForKey:bubbleInfoDictKey];
                                                if([strmap count] > 0)
                                                {
                                                    //retrieving key from dict 
                                                    NSMutableDictionary * key_dict = [strmap objectAtIndex:0];
                                                    NSString * key = [key_dict objectForKey:@"key"];
                                                    //retrieving value from dict
                                                    NSMutableDictionary * key_dict1 = [strmap objectAtIndex:1];
                                                    NSString * value = [key_dict1 objectForKey:@"value"];
                                                    
                                                    NSMutableArray * keys = [NSMutableArray arrayWithObjects:
                                                                             gVALUE_FIELD_API_NAME,
                                                                             gVALUE_FIELD_VALUE_KEY,
                                                                             gVALUE_FIELD_VALUE_VALUE,
                                                                             nil];
                                                    
                                                    NSMutableArray * objects = [NSMutableArray arrayWithObjects:bubbleInfoDictKey, key, value, nil];
                                                    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:objects forKeys:keys];
                                                    [detailValuesArray addObject:dict];
                                                }
                                            }
                                            else
                                            {
                                                NSMutableArray * strmap =[bubbleInfoDict objectForKey:bubbleInfoDictKey];
                                                if([strmap count] > 0)
                                                {
                                                    
                                                    
                                                    NSMutableDictionary * key_dict = [strmap objectAtIndex:0];
                                                    NSString * key = [key_dict objectForKey:@"key"];
                                                    //retrieving value from dict
                                                    NSMutableDictionary * key_dict1 = [strmap objectAtIndex:1];
                                                    NSString * value = [key_dict1 objectForKey:@"value"];

                                                    //retrieving key from dict 
                                                    NSString * data_type = [appDelegate.databaseInterface  getFieldDataType:detail_object_name filedName:bubbleInfoDictKey];
                                                    if([data_type isEqualToString:@"reference"])
                                                    {
                                                        if([key isEqualToString:value])
                                                        {
                                                            if([Bubble_uniq_keys containsObject: bubbleInfoDictKey])
                                                                [Bubble_uniq_keys  removeObject:bubbleInfoDictKey];
                                                           
                                                        }
                                                        else
                                                        {
                                                            
                                                            [keyValueDict setValue:key forKey:gVALUE_FIELD_VALUE_KEY];
                                                            [keyValueDict setValue:value forKey:gVALUE_FIELD_VALUE_VALUE];
                                                            
                                                        }
                                                    }
                                                    else
                                                    {
                                                        [keyValueDict setValue:key forKey:gVALUE_FIELD_VALUE_KEY];
                                                        [keyValueDict setValue:value forKey:gVALUE_FIELD_VALUE_VALUE];
                                                    }
                                                }

                                            }
                                            
                                        }
                                        
                                        record_exist = TRUE;
                                    }
                                }
                            }
                            
                            if(!record_exist)
                            {
                                
                                NSArray * allkeys = [bubbleInfoDict allKeys];
                                NSMutableArray * detailValuesArray = [[NSMutableArray alloc] initWithCapacity:0]; 
                                for(int q = 0 ; q < [allkeys count]; q++)
                                {
                                    NSString * bubbleInfoDictKey = [allkeys objectAtIndex:q];
                                    
                                    NSMutableArray * strmap =[bubbleInfoDict objectForKey:bubbleInfoDictKey];
                                    if([strmap count] > 0)
                                    {
                                        //retrieving key from dict 
                                        NSMutableDictionary * key_dict = [strmap objectAtIndex:0];
                                        NSString * key = [key_dict objectForKey:@"key"];
                                        //retrieving value from dict
                                        NSMutableDictionary * key_dict1 = [strmap objectAtIndex:1];
                                        NSString * value = [key_dict1 objectForKey:@"value"];
                                        
                                        NSMutableArray * keys = [NSMutableArray arrayWithObjects:
                                                                 gVALUE_FIELD_API_NAME,
                                                                 gVALUE_FIELD_VALUE_KEY,
                                                                 gVALUE_FIELD_VALUE_VALUE,
                                                                 nil];
                                        
                                        NSMutableArray * objects = [NSMutableArray arrayWithObjects:bubbleInfoDictKey, key, value, nil];
                                        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:objects forKeys:keys];
                                        [detailValuesArray addObject:dict];
                                    }
                                }
                                
                                
                                if([detailValuesArray count] >  0)
                                {
                                    //sahana 20th August 2011
                                    NSMutableArray * keys = [NSMutableArray arrayWithObjects:
                                                             gVALUE_FIELD_API_NAME,
                                                             gVALUE_FIELD_VALUE_KEY,
                                                             gVALUE_FIELD_VALUE_VALUE,
                                                             nil];
                                    NSMutableArray * objects = [NSMutableArray arrayWithObjects:gDETAIL_SAVED_RECORD,[NSNumber numberWithInt:1],[NSNumber numberWithInt:1], nil];
                                    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:objects forKeys:keys];
                                    [detailValuesArray addObject:dict];
                                    
                                    NSString * detail_local_id = [iServiceAppDelegate GetUUID];
                                    [detail_values_array addObject:detailValuesArray];
                                    [details_record_ids addObject:detail_local_id];
                                   // [detail_sobject addObject:@""];
                                }
                                
                            }
                            
                            SMLog(@"valuearray%@", detail_values_array);
                            SMLog(@" record_id ---%@",details_record_ids);
                        }
                    } 
                    
                }
                [bubbleInfoDict release];
            }
            
            NSMutableArray * detail_values_array = nil;
            NSMutableArray * details_record_ids = nil;
            NSMutableArray * deleted_details_array = nil;
            NSString * detail_object_name = @"";
          //  NSMutableArray * detail_sobject = nil;
            
            for (int x=0;x<[details count];x++) //parts, labor, expense for instance
            {
                NSMutableDictionary * detail = [details objectAtIndex:x];
                NSString * DictaliasName = [detail objectForKey:gDETAIL_OBJECT_ALIAS_NAME]; 
                if([DictaliasName isEqualToString:aliasName])
                {
                    detail_object_name = [detail objectForKey:gDETAIL_OBJECT_NAME];
                    detail_values_array = [detail objectForKey:gDETAILS_VALUES_ARRAY];
                    details_record_ids = [detail objectForKey:gDETAIL_VALUES_RECORD_ID];
                    deleted_details_array = [detail objectForKey:gDETAIL_DELETED_RECORDS];
                  //  detail_sobject = [detail objectForKey:gDETAIL_SOBJECT_ARRAY];
                }
            }
            
            NSMutableArray * records_to_be_deleted = [[NSMutableArray alloc] initWithCapacity:0];
            
            for(int y = 0 ; y < [details_record_ids count]; y++)
            {
                NSString * id_ = [details_record_ids objectAtIndex:y];
                NSString * sf_id = [ appDelegate.databaseInterface  getSfid_For_LocalId_From_Object_table:detail_object_name local_id:id_];
                if([id_ length] != 0 && ![id_ isEqualToString:escape_string])
                {
                    BOOL isrecord_exist = FALSE;
                    for(int p = 0 ; p < [event_Record_id_set count]; p++)
                    {
                        NSDictionary * dict = [event_Record_id_set objectAtIndex:p];
                        if([dict count] != 0)
                        {
                            NSString * value = [dict objectForKey:@"RecordId"];
                            SMLog(@"value %@  record id %@", value , id_);
                            if([value isEqualToString:sf_id])
                            {
                                isrecord_exist = TRUE;                        
                            }
                            
                            
                        }
                    }
                    
                    if(!isrecord_exist)
                    {                        
                        [records_to_be_deleted addObject:id_];
                    }
                    SMLog(@"after deleting each item  %@", details_record_ids);
                }
            }
            
            //delete all the records which are not the part of resonse 
            for(int m = 0 ; m < [records_to_be_deleted count]; m++)
            {
                NSString * record = [records_to_be_deleted objectAtIndex:m];
                for(int y = 0 ; y < [details_record_ids count]; y++)
                {
                    NSString * id_ = [details_record_ids objectAtIndex:y];
                    if([id_ isEqualToString:record])
                    {
                        [deleted_details_array  addObject:id_];
                        [detail_values_array removeObjectAtIndex:y];
                        [details_record_ids removeObjectAtIndex:y];
                      //  [detail_sobject removeObjectAtIndex:y];
                    }
                }
            }
            
            NSMutableArray * local_deletedRecord_array = [[NSMutableArray alloc] initWithCapacity:0];
            
            SMLog(@"details record id --------%@",deleted_details_array);
            for(int q = 0; q < [detail_values_array count]; q++)
            {
                NSMutableArray * detailValuesArray = [detail_values_array objectAtIndex:q];
                
                BOOL flag = FALSE;
                BOOL apiNmae_exist = FALSE;
                
                
                for(int k = 0 ; k < [detailValuesArray count]; k++)
                {
                    NSMutableDictionary * keyValueDict = [detailValuesArray objectAtIndex:k];
                    NSString * api_name = [keyValueDict objectForKey:gVALUE_FIELD_API_NAME];
                    NSString * key = [keyValueDict objectForKey:gVALUE_FIELD_VALUE_KEY];
                    
                    if([api_name isEqualToString:gDETAIL_SEQUENCENO_GETPRICE])
                    {
                        
                        apiNmae_exist = TRUE;
                        if([key length ]!= 0 )
                        {
                            for( int p = 0 ; p < [event_Record_id_set count]; p++)
                            {
                                NSDictionary * dict = [event_Record_id_set objectAtIndex:p];
                                if([dict count] != 0)
                                {
                                    NSString * recordNum_value = [dict objectForKey:@"RecordNum"];
                                    if([recordNum_value isEqualToString:key])
                                    {
                                        flag = TRUE;
                                        break;
                                        
                                    }
                                }
                                
                            }
                            
                            
                        }
                        if(apiNmae_exist)
                        {
                            if(flag)
                            {
                                SMLog(@"present");
                                
                            }
                            else
                            {
                                [local_deletedRecord_array addObject:key];
                               
                            }
                        }
                        
                    } 
                    
                }
            }
            
            SMLog(@"local_deletedRecord_array --------%@",local_deletedRecord_array);
            
            
            for(int m = 0 ; m < [local_deletedRecord_array count]; m++)
            {
                NSString * record = [local_deletedRecord_array objectAtIndex:m];
                
                for(int q = 0; q < [detail_values_array count]; q++)
                {
                    NSMutableArray * detailValuesArray = [detail_values_array objectAtIndex:q];
                    
                    for(int k = 0 ; k < [detailValuesArray count]; k++)
                    {
                        NSMutableDictionary * keyValueDict = [detailValuesArray objectAtIndex:k];
                        NSString * api_name = [keyValueDict objectForKey:gVALUE_FIELD_API_NAME];
                        NSString * key = [keyValueDict objectForKey:gVALUE_FIELD_VALUE_KEY];
                        
                        if([api_name isEqualToString:gDETAIL_SEQUENCENO_GETPRICE])
                        {
                            if([key isEqualToString:record])
                            {
                                [detail_values_array removeObjectAtIndex:q];
                                [details_record_ids removeObjectAtIndex:q];
                              //  [detail_sobject removeObjectAtIndex:q];
                            }
                            
                        }
                    }
                }
                
            }
            
            
            SMLog(@"details record id --------%@",deleted_details_array);
            
            
            for(int y = 0 ; y< [details_record_ids count]; y++)
            {
                NSMutableString * id_ = [details_record_ids objectAtIndex:y];
                if([id_ isEqualToString:escape_string])
                {
                    [details_record_ids  replaceObjectAtIndex:y withObject:@""];
                    //id_ = [id_ stringByReplacingOccurrencesOfString:escape_string withString:@""];
                    //[id_ stringByReplacingOccurrencesOfString:<#(NSString *)#> withString:<#(NSString *)#>
                }
            }
            
            SMLog(@"final  record_id array : %@ ",details_record_ids);
            SMLog(@" event_Record_id_set :%@", event_Record_id_set);
            
        }
        
        //for header Data
        INTF_WebServicesDefServiceSvc_INTF_PageDataSet * pageDataSet = [pageData pageDataSet];
        if (pageDataSet == nil)
            return;
        NSMutableArray * header_infoList = pageDataSet.bubbleInfo;
        NSString * Record_Id = nil;
        NSMutableDictionary * bubbleInfoDict_hdr = [[NSMutableDictionary alloc] initWithCapacity:0];
        
        for (int k = 0; k < [header_infoList count]; k++)
        {
            INTF_WebServicesDefServiceSvc_INTF_BubbleWrapper * bubbleWrapper = [header_infoList objectAtIndex:k];
            NSString * field_api_name = bubbleWrapper.fieldapiname ; 
            INTF_WebServicesDefServiceSvc_INTF_StringMap * stringMap1 = bubbleWrapper.fieldvalue;
            NSString * key = stringMap1.key;
            NSString * value = stringMap1.value;
            NSString * value1 = stringMap1.value1;
            
            //get the detail object from the SFM dictionary
            if([field_api_name isEqualToString:@"_Id"])
            {
                Record_Id = key;
            }
            else
            {
                NSMutableArray  * arr = [[NSMutableArray alloc] initWithCapacity:0];
                if(key != nil && value != nil)
                {
                    NSDictionary * dict = [NSDictionary dictionaryWithObject:key forKey:@"key"];
                    NSDictionary * dict1;
                    if(value1 == nil)
                        dict1 = [NSDictionary dictionaryWithObject:value forKey:@"value"];
                    else 
                        dict1 = [NSDictionary dictionaryWithObject:value1 forKey:@"value"];
                    [arr addObject:dict];
                    [arr addObject:dict1];
                }
                [bubbleInfoDict_hdr setValue:arr forKey:field_api_name];
                [arr release];
            }
        }
        
        NSMutableDictionary *hdr_object = [appDelegate.SFMPage objectForKey:gHEADER];
        NSMutableDictionary * header_data = [hdr_object objectForKey:gHEADER_DATA];
        NSMutableArray *header_sections = [hdr_object objectForKey:gHEADER_SECTIONS];
        
        
        SMLog(@"BEFORE HDRE_DATA %@", header_data);
        NSArray * allkeys = [bubbleInfoDict_hdr allKeys];
        
        for(NSString * str in allkeys)
        {
            
            BOOL flag = FALSE;
            for (int i=0;i<[header_sections count];i++)
            {
                NSMutableDictionary * section = [header_sections objectAtIndex:i];
                NSMutableArray *section_fields = [section objectForKey:gSECTION_FIELDS];
                for (int j=0;j<[section_fields count];j++)
                {
                    NSMutableDictionary *section_field = [section_fields objectAtIndex:j];
                    NSString * api_name = [section_field objectForKey:gFIELD_API_NAME];
                    
                    if([str isEqualToString:api_name])
                    {
                        flag = TRUE;
                        break;
                    }
                }
            }
            if(!flag)
            {
                NSString * temp_value = [header_data objectForKey:str];
                NSMutableArray * strmap =[bubbleInfoDict_hdr  objectForKey:str];
                if([strmap count] > 0)
                {
                    //retrieving key from dict 
                    NSMutableDictionary * key_dict = [strmap objectAtIndex:0];
                    NSString * key = [key_dict objectForKey:@"key"];
                    [header_data  setObject:key forKey:str];
                    //retrieving value from dict
                    
                    SMLog(@"BEFOREEVENT %@  AFTEREVENT %@",temp_value,key);
                }
                
            }
            
        }
        
        SMLog(@"AFTER HDRE_DATA %@", header_data);
        
        
        for (int i=0;i<[header_sections count];i++)
        {
            NSMutableDictionary * section = [header_sections objectAtIndex:i];
            NSMutableArray *section_fields = [section objectForKey:gSECTION_FIELDS];
            for (int j=0;j<[section_fields count];j++)
            {
                NSMutableDictionary *section_field = [section_fields objectAtIndex:j];
                NSString * api_name = [section_field objectForKey:gFIELD_API_NAME];
                NSArray * allkeys = [bubbleInfoDict_hdr allKeys];
                BOOL flag = FALSE;
                for(NSString * str in allkeys)
                {
                    if([str isEqualToString:api_name])
                    {
                        flag = TRUE;
                        break;
                    }
                }
                if(flag)
                {
                    NSMutableArray * strmap =[bubbleInfoDict_hdr  objectForKey:api_name];
                    if([strmap count] > 0)
                    {
                        //retrieving key from dict 
                        NSMutableDictionary * key_dict = [strmap objectAtIndex:0];
                        NSString * key = [key_dict objectForKey:@"key"];
                        //retrieving value from dict
                        NSMutableDictionary * key_dict1 = [strmap objectAtIndex:1];
                        NSString * value = [key_dict1 objectForKey:@"value"];
                        [section_field setValue:key forKey:gFIELD_VALUE_KEY];
                        [section_field setValue:value forKey:gFIELD_VALUE_VALUE];
                    }
                }
            }
        }
        [bubbleInfoDict_hdr release];
        appDelegate.wsInterface.getPrice = TRUE;
       }
}



-(NSString *)getIdFromJsonString:(NSString *)jsonString
{
    NSString * SF_id = @"";
    NSAutoreleasePool * autoReleasePool = [[NSAutoreleasePool alloc] init];
    SBJsonParser * jsonParser_ = [[[SBJsonParser alloc] init] autorelease];
    
    NSDictionary * jsonDict = [jsonParser_ objectWithString:jsonString];
    NSArray * all_json_keys = [jsonDict allKeys];
    for(NSString * field in all_json_keys)
    {
        if([field isEqualToString:@"Id"])
        {
            SF_id = [[jsonDict objectForKey:@"Id"] retain];
            break;
        }
    }
    [autoReleasePool drain];
    return SF_id;
}

-(NSString *)escapeSIngleQute:(NSString *)jsonString
{
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"'"  withString:@"''"];
    return jsonString;
}

-(NSMutableArray *)getIdsFromJsonString:(NSString *)jsonstrings
{
    //NSArray * records_array = [jsonstrings componentsSeparatedByString:@"}"","];
    jsonstrings = [jsonstrings stringByReplacingOccurrencesOfString:@"[" withString:@""];
    jsonstrings = [jsonstrings stringByReplacingOccurrencesOfString:@"]" withString:@""];
    jsonstrings = [jsonstrings stringByReplacingOccurrencesOfString:@"},{" withString:@"}$,${"];
    NSArray * records_array = [jsonstrings componentsSeparatedByString:@"$,$"];
   
    NSMutableArray * records_list = [[NSMutableArray alloc] initWithCapacity:0] ;
    for(NSString * jsonString in records_array)
    {
        NSAutoreleasePool * autoReleasePool = [[NSAutoreleasePool alloc] init];
        SBJsonParser * jsonParser_ = [[[SBJsonParser alloc] init] autorelease];
        NSDictionary * jsonDict = [jsonParser_ objectWithString:jsonString];
        NSArray * allkeys = [jsonDict allKeys];
        for(id  temp in allkeys)
        {
            if([temp isKindOfClass:[NSString class]])
            {
                NSString * final_id = (NSString *)temp;
                if([final_id isEqualToString:@"Id"])
                {
                   NSString * value =  [jsonDict  objectForKey:final_id];
                    [records_list addObject:value];
                    value = nil;
                }
            }
        }
        allkeys = nil;
        [autoReleasePool drain];
      //  jsonDict = nil;
    }
    jsonstrings = nil;
    records_array = nil;
    
    return records_list;
}
#pragma mark CollectPlistValues
- (NSMutableArray *) collectPickListObject
{
    NSMutableArray * result = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    for (int i = 0; i < [object count]; i++)
    {
        NSDictionary * dict = [object objectAtIndex:i];
        NSString * str = [dict objectForKey:@"OBJECT"];
        //RADHA
        if ([str length] > 0)
        {
            if (![result containsObject:str])
                [result addObject:str];
        }
        
    }
    return result;
}


#pragma mark CollectAllPageId And ProcessId
- (NSMutableArray *) getAllPageLauoutId
{
    NSMutableArray * pageId = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    processType_dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    NSArray * array = [processDictionary objectForKey:@"SFMProcess"];
    
    for (int i = 0; i < [array count]; i++)
    {
        NSDictionary * dict = [array objectAtIndex:i];
        
        NSString * str = ([dict objectForKey:@"page_layout_id"]) != nil?[dict objectForKey:@"page_layout_id"]:@"";
               
        if (![str isEqualToString:@""])
        {
            [pageId addObject:str];        
        }
    }
    return pageId;
}
    
- (NSMutableArray *) getAllProcessId
{
    NSMutableArray * processId = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    NSArray * sfm_processComp = [processDictionary objectForKey:@"SFProcess_component"];
    
    for (int i = 0; i < [sfm_processComp count]; i++)
    {
        NSDictionary * dict = [sfm_processComp objectAtIndex:i];
        
        NSString * str = ([dict objectForKey:@"process_id"]) != nil?[dict objectForKey:@"process_id"]:@"";
        
        if (![str isEqualToString:@""])
        {
            [processId addObject:str];        
        }
    }
    return processId;
}

#pragma mark - RT Dependent picklist
- (void) getRecordTypeDictForObjects:(NSArray *)objects
{
    didDescribeLayoutReceived = NO;
    
    if( tempObjects == nil && objects.count )
    {
        tempObjects = [[NSMutableArray arrayWithArray:objects] retain];
        tempObjects2 = [[NSMutableArray arrayWithArray:objects] retain];
    }
    

    if( recordTypeDict == nil )
    {
        recordTypeDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
//    for(id objName in objects)
//    {
    if( tempObjects.count != 0 )
    {
        id objName = [tempObjects objectAtIndex:0];
        RecordTypePickList = [[NSMutableArray alloc] init];
        recordTypeObjName = objName;
        [[ZKServerSwitchboard switchboard] describeLayout:objName target:self selector:@selector(didDescribeSObjectLayoutForObject:error:context:) context:nil];
        [tempObjects removeObjectAtIndex:0];
        if( !tempObjects.count )
        {
            [tempObjects release];
            tempObjects = nil;
        }
        return;
    }
    
       
    [appDelegate.dataBase insertValuesInToRTPicklistTableForObject:tempObjects2 Values:recordTypeDict];
    
    [tempObjects2 release];
    tempObjects2 = nil;
    
    return;
}

- (void) didDescribeSObjectLayoutForObject:(ZKDescribeLayoutResult *)result error:(NSError *)error context:(id)context
{
    NSMutableArray * RecordTypePickListForObject = [[NSMutableArray alloc] init];
    NSArray * recordTypeMappings = [result recordTypeMappings];
    
    for(ZKRecordTypeMapping *recordType in recordTypeMappings)
    {
        //RADHA 23/06/2012
        BOOL availabe = [recordType available];
        
        if (availabe)
        {
            NSMutableDictionary *sub_dict =[[NSMutableDictionary alloc] init];
             
            [sub_dict setObject:[recordType name] forKey:@"RecorTypeName"];
            [sub_dict setObject:[recordType layoutId] forKey:@"RecorTypeLayoutId"];
            [sub_dict setObject:[recordType recordTypeId] forKey:@"RecorTypeId"];
            
            
            NSArray *pickLists = [recordType picklistsForRecordType];
            NSMutableArray *pickList_Main_Array = [[NSMutableArray alloc] init];
            
            
            for(ZKPicklistForRecordType *pickList in pickLists)
            {            
                NSArray *pickListValueArray = [pickList picklistValues];
                NSMutableArray *pickListValue_array = [[NSMutableArray alloc] init];
                NSMutableDictionary *pickListValue_dict = [[NSMutableDictionary alloc] init];
                NSString *defaultLabel = @"";
                NSString *defaultValue = @"";
                for(ZKPicklistEntry *pickListValue in pickListValueArray)
                {
                    NSMutableDictionary *pickList_value_Dict = [[NSMutableDictionary alloc] init];                   
                    [pickList_value_Dict setObject:[pickListValue label] forKey:@"label"];
                    [pickList_value_Dict setObject:[pickListValue value] forKey:@"value"]; 
                    if([pickListValue defaultValue])
                    {
                        defaultLabel = [pickListValue label];
                        defaultValue = [pickListValue value];   
                    }
                    [pickListValue_array addObject:pickList_value_Dict];
                    [pickList_value_Dict release];
                }            
                [pickListValue_dict setObject:[pickList picklistName] forKey:@"PickListName"];
                [pickListValue_dict setObject:pickListValue_array forKey:@"PickListValue"];
                [pickListValue_dict setObject:defaultLabel forKey:@"PickListDefaultLabel"];
                [pickListValue_dict setObject:defaultValue forKey:@"PickListDefaultValue"];
                [pickListValue_array release];
                [pickList_Main_Array addObject:pickListValue_dict];
                [pickListValue_dict release];
            }
            
            [sub_dict setObject:pickList_Main_Array forKey:@"PickLists"];
            [pickList_Main_Array release]; 
            [RecordTypePickListForObject addObject:sub_dict];
            [sub_dict release];
            
        }
    }
    if ([RecordTypePickListForObject count] > 0)
        [recordTypeDict setObject:RecordTypePickListForObject forKey:recordTypeObjName];
    [RecordTypePickListForObject release];     
    didDescribeLayoutReceived = YES;
    
    [self getRecordTypeDictForObjects:tempObjects];
}

#pragma mark - GetAdditional object definitions
- (void) getAdditionalObjectdefinition
{
    
}

#pragma mark WSInterface Layer Helper Methods

- (void) getWrapperDictionary:(NSMutableDictionary *)bodyParts
{
    // Obtain describeObjects
    [self getDescribeObjects:bodyParts];
}

- (NSMutableArray *) getTasksFromResponse:(INTF_WebServicesDefBindingResponse *)response
{
    NSMutableArray * _tasks = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    NSMutableArray * bodyParts = [[[response bodyParts] mutableCopy] autorelease];
    if ([bodyParts count] == 0)
        return nil;
    
    for (int i = 0; i < [bodyParts count]; i++)
    {
        INTF_WebServicesDefServiceSvc_INTF_Get_Tasks_WSResponse * getTasksResponse = [bodyParts objectAtIndex:i];
        INTF_WebServicesDefServiceSvc_INTF_Response_For_Tasks * responseForTasks = [getTasksResponse result];
        NSMutableArray * taskInfo = [responseForTasks taskInfo];
        
        for (int j = 0; j < [taskInfo count]; j++)
        {
            INTF_WebServicesDefServiceSvc_Task * task = [taskInfo objectAtIndex:j];
            NSString * priority = [task Priority];
            NSString * subject = [task Subject];
            
            NSMutableArray * taskObject = [NSMutableArray arrayWithObjects:
                                           (priority != nil)?priority:@"",
                                           (subject != nil)?subject:@"",
                          nil];
            [_tasks addObject:taskObject];
        }
    }
    
    return _tasks;
}

- (NSMutableArray *) getProductHistoryFromResponse:(INTF_WebServicesDefBindingResponse *)response
{
    NSMutableArray * productHistoryArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    NSMutableArray * keys = [NSMutableArray arrayWithObjects:
                      @"CreatedDate",
                      @"SVMXC__Problem_Description__c",
                   //   @"Id",
                   //   @"Name",
                   //   @"OwnerId",
                   //   @"SVMXC__Top_Level__c",
                      nil];
    
    NSMutableArray * bodyParts = [[[response bodyParts] mutableCopy] autorelease];
    for (int i = 0; i < [bodyParts count]; i++)
    {
        INTF_WebServicesDefServiceSvc_INTF_Get_Product_History_WSResponse * response = [bodyParts objectAtIndex:i];
        INTF_WebServicesDefServiceSvc_INTF_Response_For_History * result = [response result];
        NSMutableArray * historyInfo = [result historyInfo];
        
        for (int j = 0; j < [historyInfo count]; j++)
        {
            INTF_WebServicesDefServiceSvc_SVMXC__Service_Order__c * serviceOrder = [historyInfo objectAtIndex:j];
            NSMutableArray * objects = [NSMutableArray arrayWithObjects:
                                        (serviceOrder.CreatedDate != nil)?serviceOrder.CreatedDate:@"",
                                        (serviceOrder.SVMXC__Problem_Description__c != nil)?serviceOrder.SVMXC__Problem_Description__c:@"",
                                   //     (serviceOrder.Id_ != nil)?serviceOrder.Id_:@"",
                                   //     (serviceOrder.Name != nil)?serviceOrder.Name:@"",
                                   //     (serviceOrder.OwnerId != nil)?serviceOrder.OwnerId:@"",
                                   //     (serviceOrder.SVMXC__Top_Level__c != nil)?serviceOrder.SVMXC__Top_Level__c:@"",
                                        nil];
            
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:objects forKeys:keys];
            
            [productHistoryArray addObject:dict];
        }
    }
    
    return productHistoryArray;
}

- (NSMutableArray *) getAccountHistoryFromResponse:(INTF_WebServicesDefBindingResponse *)response
{
    NSMutableArray * accountHistoryArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    NSArray * keys = [NSArray arrayWithObjects:
                     // @"Id",
                      @"CreatedDate",
                     // @"Name",
                      @"SVMXC__Problem_Description__c",
                      nil];
    
    NSArray * bodyParts = [response bodyParts];
    if ([bodyParts count] == 0)
        return nil;
    INTF_WebServicesDefServiceSvc_INTF_Get_Account_History_WSResponse * wsResponse = [bodyParts objectAtIndex:0];
    if (wsResponse == nil)
        return nil;
    INTF_WebServicesDefServiceSvc_INTF_Response_For_History * responseForHistory = [wsResponse result];
    if (responseForHistory == nil)
        return nil;
    
    NSMutableArray * historyInfo = [responseForHistory historyInfo];
    
    for (int i = 0; i < [historyInfo count]; i++)
    {
        INTF_WebServicesDefServiceSvc_SVMXC__Service_Order__c * serviceOrder = [historyInfo objectAtIndex:i];
        
        NSMutableArray * objects = [NSMutableArray arrayWithObjects:
                               //     (serviceOrder.Id_ != nil)?serviceOrder.Id_:@"",
                                    (serviceOrder.CreatedDate != nil)?serviceOrder.CreatedDate:@"",
                              //      (serviceOrder.Name != nil)?serviceOrder.Name:@"",
                                    (serviceOrder.SVMXC__Problem_Description__c != nil)?serviceOrder.SVMXC__Problem_Description__c:@"",
                                    nil];
        
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:objects forKeys:keys];
        
        [accountHistoryArray addObject:dict];
    }
    
    return accountHistoryArray;
}

- (void) describeObjectFromResponse:(INTF_WebServicesDefBindingResponse *)response
{
    // Describe the lookup objectname
    NSMutableArray * bodyParts = [[[response bodyParts] mutableCopy] autorelease];
    
    INTF_WebServicesDefServiceSvc_INTF_getLookUpConfigWithData_WSResponse * wsResponse = [bodyParts objectAtIndex:0];
    INTF_WebServicesDefServiceSvc_INTF_LookUpConfigData * result = [wsResponse result];
    
    // retrieve namesearchinfo first
    INTF_WebServicesDefServiceSvc_INTF_Response_NamedSearchInfo * namesearchinfo = [result namesearchinfo];
    NSMutableArray * namedSearch = [namesearchinfo namedSearch];
    if ([namedSearch count] == 0)
    {
        [[ZKServerSwitchboard switchboard] describeSObject:@"" target:self selector:@selector(didDescribeSObject:error:context:) context:response];
        return;
    }
    INTF_WebServicesDefServiceSvc_INTF_NamedSearchInfo * namedSearchInfo = [namedSearch objectAtIndex:0];
    INTF_WebServicesDefServiceSvc_SVMXC__ServiceMax_Processes__c * namedSearchHdr = [namedSearchInfo namedSearchHdr];
    NSString * sourceObject = [namedSearchHdr SVMXC__Source_Object_Name__c];
    
    [[ZKServerSwitchboard switchboard] describeSObject:sourceObject target:self selector:@selector(didDescribeSObject:error:context:) context:response];
}

- (NSMutableDictionary *) getDescribeObjects:(NSMutableDictionary *)bodyParts
{
    NSMutableArray * describeObjectsArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    INTF_WebServicesDefServiceSvc_INTF_PageHeader * hdr = nil;
    INTF_WebServicesDefServiceSvc_SVMXC__Page_Layout__c * headerLayout = nil; 
    NSString * objectName = nil;
    
    
    if (bodyParts != nil)
        hdr = [bodyParts objectForKey:gHEADER];
    
    if (hdr != nil)
        headerLayout = hdr.headerLayout;
    
    if (headerLayout != nil)
        objectName = headerLayout.SVMXC__Object_Name__c;
    else
        objectName = @"";
    
    if (objectName == nil)
        objectName = @"";
    
    [describeObjectsArray addObject:objectName];
    
    // Add reference fields from Header
    NSMutableArray * hdrSections = hdr.sections;
    for (int h = 0; h < [hdrSections count]; h++)
    {
        INTF_WebServicesDefServiceSvc_INTF_UISection * section = [hdrSections objectAtIndex:h];
        NSMutableArray * fields = [section fields];
        for (int f = 0; f < [fields count]; f++)
        {
            INTF_WebServicesDefServiceSvc_INTF_UIField * field = [fields objectAtIndex:f];
            INTF_WebServicesDefServiceSvc_SVMXC__Page_Layout_Detail__c * fieldDetail = field.fieldDetail;
            if ([fieldDetail.SVMXC__DataType__c isEqualToString:@"reference"])
                [describeObjectsArray addObject:fieldDetail.SVMXC__Related_Object_Name__c];
        }
    }
    // Add reference fields from Lines section
    NSMutableArray * dtl = [bodyParts objectForKey:gDETAILS];
    for (int d = 0; d < [dtl count]; d++)
    {
        INTF_WebServicesDefServiceSvc_INTF_PageDetail * pageDetail = [dtl objectAtIndex:d];
        NSString * objName = pageDetail.DetailLayout.SVMXC__Object_Name__c;
        BOOL flag = YES;
        for (int i = 0; i < [describeObjectsArray count]; i++)
        {
            if ([objName isEqualToString:[describeObjectsArray objectAtIndex:i]])
            {
                flag = NO;
                break;
            }
        }
        if (flag)
            [describeObjectsArray addObject:objName];
        
        // Also, search for ALL Lookups
        NSArray * fields = [pageDetail fields];
        for (int i = 0; i < [fields count]; i++)
        {
            INTF_WebServicesDefServiceSvc_INTF_UIField * field = [fields objectAtIndex:i];
            INTF_WebServicesDefServiceSvc_SVMXC__Page_Layout_Detail__c * fieldDetail = [field fieldDetail];
            if ([fieldDetail.SVMXC__DataType__c isEqualToString:@"reference"])
            {
                [describeObjectsArray addObject:fieldDetail.SVMXC__Related_Object_Name__c];
            }
        }
    }
    
    [[ZKServerSwitchboard switchboard] describeSObjects:describeObjectsArray target:self selector:@selector(didDescribeSObjects:error:context:) context:bodyParts];
    
    return nil;
}

- (void) didDescribeSObject:(ZKDescribeSObject *)describeObject error:(NSError *)error context:(id)context
{
    INTF_WebServicesDefBindingResponse * response = (INTF_WebServicesDefBindingResponse *) context;
    NSMutableDictionary * lookupDetails = [self getLookUpFromResponse:response];
    SMLog(@"%@", lookupDetails);
    if (lookupDetails == nil)
    {
        if ([lookupCaller respondsToSelector:@selector(setLookupData:)])
            [lookupCaller performSelector:@selector(setLookupData:) withObject:nil];
        return;
    }
    NSMutableArray * keys = [NSMutableArray arrayWithObjects:gLOOKUP_DETAILS, gLOOKUP_DESCRIBEOBJECT, nil];
    NSMutableArray * objects = [NSMutableArray arrayWithObjects:lookupDetails, describeObject, nil];
    NSMutableDictionary * lookupDictionary = [NSMutableDictionary dictionaryWithObjects:objects forKeys:keys];
    if ([lookupCaller respondsToSelector:@selector(setLookupData:)])
        [lookupCaller performSelector:@selector(setLookupData:) withObject:lookupDictionary];
}

- (void) didDescribeSObjects:(NSMutableArray *)result error:(NSError *)error context:(id)context
{
    [result retain];
    SMLog(@"%@", result);
    
    [self getDictionaryFromPageLayout:context withDescribedObjects:result];
}

- (NSMutableDictionary *) GetHeaderSectionForSequenceNumber:(NSInteger)sequence
{
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
	sequence += 1;
	NSMutableDictionary *header = [appDelegate.SFMPage objectForKey:gHEADER];
	NSMutableArray *sections = [header objectForKey:gHEADER_SECTIONS];
	for (int i=0;i<[sections count];i++)
	{
		NSMutableDictionary *section = [sections objectAtIndex:i];
        NSInteger _seq = [[section objectForKey:gSECTION_SEQUENCE] intValue];
		if (_seq == sequence)
			return section;
	}
	
	return nil;
    
    
    //sahana need to change this code
    
    /*appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
	sequence += 1;
	NSMutableDictionary *header = [appDelegate.SFMPage objectForKey:gHEADER];
	NSMutableArray *sections = [header objectForKey:gHEADER_SECTIONS];
    NSMutableDictionary *section = nil;
	for (int i=0;i<[sections count];i++)
	{
		section = [sections objectAtIndex:i];
        NSInteger _seq = [[section objectForKey:gSECTION_SEQUENCE] intValue];
		if (sequence == i)
			return section;
	}
	
	return nil;	*/
}

- (void) getDictionaryFromPageLayout:(NSMutableDictionary *)bodyParts withDescribedObjects:(NSMutableArray *)describeObjects
{
    NSMutableDictionary * headerDataDict = nil, * detailsDataDict = nil;
    NSString * process_type = [bodyParts objectForKey:gPROCESSTYPE];
    
    INTF_WebServicesDefServiceSvc_INTF_PageUI * page = [bodyParts objectForKey:gPAGE];
    INTF_WebServicesDefServiceSvc_INTF_PageHeader * hdr = [bodyParts objectForKey:gHEADER];
    INTF_WebServicesDefServiceSvc_INTF_Response * response = [bodyParts objectForKey:gRESPONSE];
    NSMutableArray * dtl = [bodyParts objectForKey:gDETAILS];

    NSMutableDictionary * hdrData = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSMutableArray * hdrButtons = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray * hdrSections = [[NSMutableArray alloc] initWithCapacity:0];
    
    INTF_WebServicesDefServiceSvc_sObject * _hdrData = [hdr hdrData];

    for (ZKDescribeSObject * describeObj in describeObjects)
    {
        NSString * describeObjName = [describeObj name];
        NSString * hdrObjectPrefix = [_hdrData nsPrefix];
        NSString * newObjName = [NSString stringWithFormat:@"%@_%@", hdrObjectPrefix, describeObjName];

        Class class = NSClassFromString(newObjName);
        if ([_hdrData isKindOfClass:[class class]])
        {
            NSArray * fields = [describeObj fields];
            for (ZKDescribeField * descfield in fields)
            {
                NSString * key = [descfield name];
                @try
                {
                    NSString * str = [_hdrData valueForKey:key];

                    [hdrData setObject:str forKey:key];
                }
                @catch (...)
                {
                    // Keep going
                }
            }
            break;
        }
    }
    
    NSString * header_id = @"";
    
    for (int allFieldIndex = 0;  allFieldIndex < [hdr.allfields count]; allFieldIndex++)
    {
        INTF_WebServicesDefServiceSvc_INTF_UIField * uiField = [hdr.allfields objectAtIndex:allFieldIndex];
        INTF_WebServicesDefServiceSvc_INTF_BubbleWrapper * bubbleInfo = [uiField bubbleinfo];
        
        NSString * key = bubbleInfo.fieldapiname;
        key = [key capitalizedString];
        [hdrData setValue:bubbleInfo.fieldvalue.key forKey:key];
        
        if ([key isEqualToString:@"Id"] || [key isEqualToString:@"id"])
        {
            header_id = bubbleInfo.fieldvalue.key;
        }
    }
    
    for (int b = 0; b < [hdr.buttons count]; b++)
    {
        INTF_WebServicesDefServiceSvc_INTF_UIButton * button = [hdr.buttons objectAtIndex:b];
        
        NSMutableArray * buttonEventArray = nil;
        
        for (int be = 0; be < [button.buttonEvents count]; be++)
        {
            INTF_WebServicesDefServiceSvc_SVMXC__SFM_Event__c * bEvent = [button.buttonEvents objectAtIndex:be];
            
            NSMutableArray * beKeys = [NSMutableArray arrayWithObjects:
                                gBUTTON_EVENT_TARGET_CALL,
                                gBUTTON_EVENT_CALL_TYPE,
                                gBUTTON_EVENT_TYPE,
                                nil];
            NSMutableArray * beObjects = [NSMutableArray arrayWithObjects:
                                   (bEvent.SVMXC__Target_Call__c != nil)?bEvent.SVMXC__Target_Call__c:@"",
                                   (bEvent.SVMXC__Event_Call_Type__c != nil)?bEvent.SVMXC__Event_Call_Type__c:@"",
                                   (bEvent.SVMXC__Event_Type__c != nil)?bEvent.SVMXC__Event_Type__c:@"",
                                   nil];
            NSMutableDictionary * dict = [[NSMutableDictionary dictionaryWithObjects:beObjects forKeys:beKeys] retain];
            
            if (buttonEventArray == nil)
                buttonEventArray = [[NSMutableArray alloc] initWithCapacity:0];
            
            [buttonEventArray addObject:dict];
        }
        
        NSMutableArray * buttonKeys = [NSMutableArray arrayWithObjects:
                                gBUTTON_TITLE,
                                gBUTTON_EVENTS,
                                gBUTTON_EVENT_ENABLE,
                                nil];
        
        NSMutableArray * buttonValues = [NSMutableArray arrayWithObjects:
                                  (button.buttonDetail.SVMXC__Title__c != nil)?button.buttonDetail.SVMXC__Title__c:@"",
                                  (buttonEventArray != nil)?buttonEventArray:[[NSMutableArray alloc] initWithCapacity:0],
                                  (button.enable != nil)?[NSNumber numberWithBool:button.enable.boolValue]:[NSNumber numberWithInt:1],
                                  nil];
        
        NSMutableDictionary * dict = [[NSMutableDictionary dictionaryWithObjects:buttonValues forKeys:buttonKeys] retain];
        
        [hdrButtons addObject:dict];
    }
    
    ZKDescribeSObject * sObj = nil;
    
    // Extract HEADER's describeObject
    for (int itr = 0; itr < [describeObjects count]; itr++)
    {
        sObj = [describeObjects objectAtIndex:itr];
        if ([[sObj name] isEqualToString:hdr.headerLayout.SVMXC__Object_Name__c])
            break;
    }
    
    //Radha - get the 'name' field and the object label here from describe results
    NSArray * fields = [sObj fields];
    
    if (appDelegate.createObjectContext == nil)
        appDelegate.createObjectContext = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    [appDelegate.createObjectContext setObject:([sObj label] != nil)?[sObj label]:@"" forKey:OBJECT_LABEL];
   
    [appDelegate.createObjectContext setObject:([sObj name] != nil)?[sObj name]:@"" forKey:OBJECT_NAME];

    appDelegate.cur_Field_label = ([sObj label] != nil)?[sObj label]:@"";
    for (int i=0; i < [fields count];i++)
    {
        ZKDescribeField * field = [fields objectAtIndex:i];
        if ([field nameField] == YES)
        {
            [appDelegate.createObjectContext setObject:([field name] != nil)?[field name]:@"" forKey:NAME_FIELD];
            break;
        }
    }    
    
    for (int i = 0; i < [hdr.sections count]; i++)
    {
        NSMutableArray * hdrSectionFields = nil;
        
        INTF_WebServicesDefServiceSvc_INTF_UISection * section = [hdr.sections objectAtIndex:i];
        
        NSMutableArray * fields = [section fields];
        
        for (int j = 0; j < [fields count]; j++)
        {
            INTF_WebServicesDefServiceSvc_INTF_UIField * uiField = [fields objectAtIndex:j];
            NSMutableArray * hdrSectionFieldKeys = [NSMutableArray arrayWithObjects:
                                             gFIELD_API_NAME,
                                             gFIELD_DISPLAY_COLUMN,
                                             gFIELD_DISPLAY_ROW,
                                             gFIELD_READ_ONLY,
                                             gFIELD_REQUIRED,
                                             gFIELD_LOOKUP_CONTEXT,
                                             gFIELD_LOOKUP_QUERY,
                                             gFIELD_SEQUENCE,
                                             gFIELD_RELATED_OBJECT_SEARCH_ID,
                                             gFIELD_RELATED_OBJECT_NAME,
                                             gFIELD_DATA_TYPE,
                                             gFIELD_LABEL,
                                             gFIELD_VALUE_KEY,
                                             gFIELD_VALUE_VALUE,
                                             gSLA_CLOCK,
                                             gFIELD_OVERRIDE_RELATED_LOOKUP,
                                             nil];
            
            NSMutableArray * hdrSectionFieldValues = [NSMutableArray arrayWithObjects:
                                               (uiField.fieldDetail.SVMXC__Field_API_Name__c != nil)?uiField.fieldDetail.SVMXC__Field_API_Name__c:@"",
                                               (uiField.fieldDetail.SVMXC__Display_Column__c != nil)?uiField.fieldDetail.SVMXC__Display_Column__c:@"",
                                               (uiField.fieldDetail.SVMXC__Display_Row__c != nil)?uiField.fieldDetail.SVMXC__Display_Row__c:@"",
                                               [NSNumber numberWithBool:uiField.fieldDetail.SVMXC__Readonly__c.boolValue],
                                               [NSNumber numberWithBool:uiField.fieldDetail.SVMXC__Required__c.boolValue],
                                               (uiField.fieldDetail.SVMXC__Lookup_Context__c != nil)?uiField.fieldDetail.SVMXC__Lookup_Context__c:@"",
                                               (uiField.fieldDetail.SVMXC__Lookup_Query_Field__c != nil)?uiField.fieldDetail.SVMXC__Lookup_Query_Field__c:@"",
                                               (uiField.fieldDetail.SVMXC__Sequence__c != nil)?uiField.fieldDetail.SVMXC__Sequence__c:@"",
                                                (uiField.fieldDetail.SVMXC__Named_Search__c != nil) ? uiField.fieldDetail.SVMXC__Named_Search__c :@"", 
                                               (uiField.fieldDetail.SVMXC__Related_Object_Name__c != nil)?uiField.fieldDetail.SVMXC__Related_Object_Name__c:@"",
                                               (uiField.fieldDetail.SVMXC__DataType__c != nil)?uiField.fieldDetail.SVMXC__DataType__c:@"",
                                               //########## FILL DESCRIBE FIELD LABEL HERE
                                               ([[sObj fieldWithName:uiField.fieldDetail.SVMXC__Field_API_Name__c] label] != nil)?[[sObj fieldWithName:uiField.fieldDetail.SVMXC__Field_API_Name__c] label]:@"",
                                               (uiField.bubbleinfo.fieldvalue.key != nil)?uiField.bubbleinfo.fieldvalue.key:@"",
                                               (uiField.bubbleinfo.fieldvalue.value != nil)?uiField.bubbleinfo.fieldvalue.value:@"",
                                               [NSNumber numberWithBool:uiField.fieldDetail.SVMXC__Use_For_SLA_Clock__c.boolValue],
                                               [NSNumber numberWithInt:uiField.fieldDetail.SVMXC__Override_Related_Lookup__c.boolValue],
                                               nil];
            
            if (hdrSectionFields == nil)
                hdrSectionFields = [[NSMutableArray alloc] initWithCapacity:0];
            
            NSMutableDictionary * dict = [[NSMutableDictionary dictionaryWithObjects:hdrSectionFieldValues forKeys:hdrSectionFieldKeys] retain];
            
            [hdrSectionFields addObject:dict];
        }
        
        NSMutableArray * hdrSectionKeys = [NSMutableArray arrayWithObjects:
                                    gSECTION_NUMBER_OF_COLUMNS,
                                    gSECTION_TITLE,
                                    gSECTION_SEQUENCE,
                                    gSECTION_FIELDS,
                                    gSLA_CLOCK,
                                    nil];
        NSMutableArray * hdrSectionValues = [NSMutableArray arrayWithObjects:
                                      (section.sectionDetail.SVMXC__No_Of_Columns__c != nil)?section.sectionDetail.SVMXC__No_Of_Columns__c:@"",
                                      (section.sectionDetail.SVMXC__Title__c != nil)?section.sectionDetail.SVMXC__Title__c:@"",
                                      (section.sectionDetail.SVMXC__Sequence__c != nil)?section.sectionDetail.SVMXC__Sequence__c:@"",
                                      (hdrSectionFields != nil)?hdrSectionFields:[[NSMutableArray alloc] initWithCapacity:0],
                                      [NSNumber numberWithBool:section.sectionDetail.SVMXC__Use_For_SLA_Clock__c.boolValue],      
                                      nil];
        
        NSMutableDictionary * dict = [[NSMutableDictionary dictionaryWithObjects:hdrSectionValues forKeys:hdrSectionKeys] retain];
        
        [hdrSections addObject:dict];
    }
    
    //sahana   sfm  page leevents
    NSMutableArray * pageLevelEvents = hdr.pageEvents;
    NSMutableArray * sfmPageEvents = [[NSMutableArray alloc] initWithCapacity:0];
    for(int i = 0 ;i< [pageLevelEvents count]; i++)
    {
        INTF_WebServicesDefServiceSvc_SVMXC__SFM_Event__c * eventDetail = [pageLevelEvents objectAtIndex:i];
        NSMutableDictionary * eventsDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
        [eventsDictionary setObject:((eventDetail.Name != nil)?eventDetail.Name:@"") forKey:gEVENT_NAME];
        [eventsDictionary setObject:((eventDetail.SVMXC__Event_Type__c != nil)?eventDetail.SVMXC__Event_Type__c:@"") forKey:gEVENT_TYPE];
        [eventsDictionary setObject:((eventDetail.SVMXC__Target_Call__c != nil)?eventDetail.SVMXC__Target_Call__c:@"") forKey:gEVENT_TARGET_CALL];
        [eventsDictionary setObject:((eventDetail.SVMXC__Event_Id__c != nil)?eventDetail.SVMXC__Event_Id__c:@"") forKey:gEVENT_ID];
        [eventsDictionary setObject:((eventDetail.SVMXC__Page_Layout__c != nil)?eventDetail.SVMXC__Page_Layout__c:@"") forKey:gEVENT_LAYOUT_ID];
        [sfmPageEvents addObject:eventsDictionary];
        [eventsDictionary release];
    }
    
    // Sections without title should be attached to previous section with title
    
    NSMutableArray * hdrLayoutKeys = [NSMutableArray arrayWithObjects:
                                      gHEADER_OBJECT_NAME,
                                      gHEADER_ALLOW_NEW_LINES,
                                      gHEADER_ALLOW_DELETE_LINES,
                                      gHEADER_IS_STANDARD,
                                      gHEADER_ACTION_ON_ZERO_LINES,
                                      gHEADER_SECTIONS,
                                      gHEADER_BUTTONS,
                                      gPAGELEVEL_EVENTS,
                                      gHEADER_DATA,
                                      gHEADER_HEADER_LAYOUT_ID,
                                      gHEADER_EVENTS,
                                      gHEADER_NAME,
                                      gHEADER_OWNER_ID,
                                      gHEADER_ENABLE_ATTACHMENTS,
                                      gENABLE_CHATTER,
                                      gENABLE_TROUBLESHOOTING,
                                      gENABLE_SUMMARY,
                                      gENABLE_SUMMURY_GENERATION,
                                      gHEADER_SHOW_ALL_SECTIONS_BY_DEFAULT,
                                      gHEADER_SHOW_PRODUCT_HISTORY,
                                      gHEADER_SHOW_ACCOUNT_HISTORY,
                                      gHEADER_OBJECT_LABEL,
                                      gHEADER_ID,
                                      gSVMXC__Resolution_Customer_By__c,
                                      gSVMXC__Restoration_Customer_By__c,
                                      nil];
    
    NSString * resolution = [hdrData objectForKey:gSVMXC__Resolution_Customer_By__c];
    if ((resolution == nil) || [resolution isKindOfClass:[NSNull class]])
        resolution = @"";
    NSString * restoration = [hdrData objectForKey:gSVMXC__Restoration_Customer_By__c];
    if ((restoration == nil) || [restoration isKindOfClass:[NSNull class]])
        restoration = @"";
    
    NSMutableArray * hdrLayoutObjects = [NSMutableArray arrayWithObjects:
                                         (hdr.headerLayout.SVMXC__Object_Name__c != nil)?hdr.headerLayout.SVMXC__Object_Name__c:@"",
                                         [NSNumber numberWithBool:hdr.headerLayout.SVMXC__Allow_New_Lines__c.boolValue],
                                         [NSNumber numberWithBool:hdr.headerLayout.SVMXC__Allow_Delete_Lines__c.boolValue],
                                         [NSNumber numberWithBool:hdr.headerLayout.SVMXC__IsStandard__c.boolValue],
                                         (hdr.headerLayout.SVMXC__Action_On_Zero_Lines__c != nil)?hdr.headerLayout.SVMXC__Action_On_Zero_Lines__c:@"",
                                         hdrSections,
                                         hdrButtons,
                                         sfmPageEvents,
                                         hdrData, // (hdr.hdrData.Id_ != nil)?hdr.hdrData.Id_:@"",
                                         (hdr.hdrLayoutId != nil)?hdr.hdrLayoutId:@"",
                                         (hdr.pageEvents != nil)?hdr.pageEvents:[[NSMutableArray alloc] initWithCapacity:0],
                                         (hdr.headerLayout.Name != nil)?hdr.headerLayout.Name:@"",
                                         (hdr.headerLayout.OwnerId != nil)?hdr.headerLayout.OwnerId:@"",
                                         [NSNumber numberWithBool:hdr.headerLayout.SVMXC__Enable_Attachments__c.boolValue],
                                         [NSNumber numberWithBool:hdr.headerLayout.SVMXC__Enable_Chatter__c.boolValue],
                                         [NSNumber numberWithBool:hdr.headerLayout.SVMXC__Enable_Troubleshooting__c.boolValue],
                                         [NSNumber numberWithBool:hdr.headerLayout.SVMXC__Enable_Service_Report_View__c.boolValue],
                                         [NSNumber numberWithBool:hdr.headerLayout.SVMXC__Enable_Service_Report_Generation__c.boolValue],
                                         [NSNumber numberWithBool:hdr.headerLayout.SVMXC__Show_All_Sections_By_Default__c.boolValue],
                                         [NSNumber numberWithBool:hdr.headerLayout.SVMXC__Show_Product_History__c.boolValue],
                                         [NSNumber numberWithBool:hdr.headerLayout.SVMXC__Show_Account_History__c.boolValue],
                                         ([sObj label] != nil)?[sObj label]:@"",
                                         header_id,
                                         (resolution != nil)?resolution:@"",
                                         (restoration != nil)?restoration:@"",
                                         nil];
    
    headerDataDict = [[NSMutableDictionary dictionaryWithObjects:hdrLayoutObjects forKeys:hdrLayoutKeys] retain];
    
    
    // Set describeObject to nil
    sObj = nil;
   
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    NSMutableArray * detailDataArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (int d = 0; d < [dtl count]; d++)
    {
        INTF_WebServicesDefServiceSvc_INTF_PageDetail * pageDetail = [dtl objectAtIndex:d];
        
        // Extract DETAIL's describeObject
        for (int itr = 0; itr < [describeObjects count]; itr++)
        {
            sObj = [describeObjects objectAtIndex:itr];
            if ([[sObj name] isEqualToString:pageDetail.DetailLayout.SVMXC__Object_Name__c])
                break;   
        }
               
        // Retrieve Fields Array
        NSMutableArray * fieldsArray = [[NSMutableArray alloc] initWithCapacity:0];;
        for (int f = 0; f < [pageDetail.fields count]; f++)
        {
            INTF_WebServicesDefServiceSvc_INTF_UIField * field = [pageDetail.fields objectAtIndex:f];
            NSMutableArray * detailFieldKeys = [NSMutableArray arrayWithObjects:
                                         gFIELD_API_NAME,
                                         gFIELD_DISPLAY_COLUMN,
                                         gFIELD_DISPLAY_ROW,
                                         gFIELD_READ_ONLY,
                                         gFIELD_REQUIRED,
                                         gFIELD_LOOKUP_CONTEXT,
                                         gFIELD_LOOKUP_QUERY,
                                         gFIELD_SEQUENCE,
                                         gFIELD_RELATED_OBJECT_SEARCH_ID,
                                         gFIELD_RELATED_OBJECT_NAME,
                                         gFIELD_DATA_TYPE,
                                         gFIELD_LABEL,
                                         gFIELD_VALUE_KEY,
                                         gFIELD_VALUE_VALUE,
                                         gFIELD_OVERRIDE_RELATED_LOOKUP,
                                         nil];
            
            NSMutableArray * detailFieldObjects = [NSMutableArray arrayWithObjects:
                                            (field.fieldDetail.SVMXC__Field_API_Name__c != nil)?field.fieldDetail.SVMXC__Field_API_Name__c:@"",
                                            (field.fieldDetail.SVMXC__Display_Column__c != nil)?field.fieldDetail.SVMXC__Display_Column__c:@"",
                                            (field.fieldDetail.SVMXC__Display_Row__c != nil)?field.fieldDetail.SVMXC__Display_Row__c:@"",
                                            [NSNumber numberWithBool:field.fieldDetail.SVMXC__Readonly__c.boolValue],
                                            [NSNumber numberWithBool:field.fieldDetail.SVMXC__Required__c.boolValue],
                                            (field.fieldDetail.SVMXC__Lookup_Context__c != nil)?field.fieldDetail.SVMXC__Lookup_Context__c:@"",
                                            (field.fieldDetail.SVMXC__Lookup_Query_Field__c != nil)?field.fieldDetail.SVMXC__Lookup_Query_Field__c:@"",
                                            (field.fieldDetail.SVMXC__Sequence__c != nil)?field.fieldDetail.SVMXC__Sequence__c:@"",
                                            (field.fieldDetail.SVMXC__Named_Search__c != nil) ? field.fieldDetail.SVMXC__Named_Search__c:@"",
                                            (field.fieldDetail.SVMXC__Related_Object_Name__c != nil)?field.fieldDetail.SVMXC__Related_Object_Name__c:@"",
                                            (field.fieldDetail.SVMXC__DataType__c != nil)?field.fieldDetail.SVMXC__DataType__c:@"",
                                            ([[sObj fieldWithName:field.fieldDetail.SVMXC__Field_API_Name__c] label] != nil)?[[sObj fieldWithName:field.fieldDetail.SVMXC__Field_API_Name__c] label]:@"",
                                            (field.bubbleinfo.fieldvalue.key != nil)?field.bubbleinfo.fieldvalue.key:@"",
                                            (field.bubbleinfo.fieldvalue.value != nil)?field.bubbleinfo.fieldvalue.value:@"",
                                            [NSNumber numberWithInt:field.fieldDetail.SVMXC__Override_Related_Lookup__c.boolValue],
                                            nil];
            
            NSMutableDictionary * dict = [[NSMutableDictionary dictionaryWithObjects:detailFieldObjects forKeys:detailFieldKeys] retain];
            
            [fieldsArray addObject:dict];
        }
        
        
        
        //sort the array according to the sequence no
        if([fieldsArray count] > 1)
        {
            for(int x=0; x<[fieldsArray count]; x++)
            {
                for(int y=0; y<[fieldsArray count]-1; y++)
                {
                    NSDictionary *dict = [fieldsArray objectAtIndex:y];
                    NSString * sequence=[dict objectForKey:gFIELD_SEQUENCE];
                    NSInteger sequence_no = [sequence integerValue];
                    NSDictionary *dict_nxt = [fieldsArray objectAtIndex:y+1];
                    NSString * sequence_nxt=[dict_nxt objectForKey:gFIELD_SEQUENCE];
                    NSInteger sequence_no_nxt = [sequence_nxt integerValue];
                    if(sequence_no > sequence_no_nxt)
                    {
                        [fieldsArray exchangeObjectAtIndex:y withObjectAtIndex:y+1];
                    }
                }
                
            }
        }
        
        /*********************************************************************************
        THIS CODE CAUSED A REGRESSION, BY NOT MAKING THE LABELS AVAILABLE TO LINE ITEMS
        (CODE TO OBTAIN LINE ITEM LABELS PRESENT ABOVE)
        // Extract DETAIL's describeObject
        for (int itr = 0; itr < [describeObjects count]; itr++)
        {
            sObj = [describeObjects objectAtIndex:itr];
            if ([[sObj name] isEqualToString:pageDetail.DetailLayout.SVMXC__Object_Name__c])
                break;
        }
        **********************************************************************************/
        
        // Retrieve Values (BubbleInfo) Array
        NSMutableArray * detailsValuesArray = [[NSMutableArray alloc] initWithCapacity:0];
        NSMutableArray * detailValuesId = [[NSMutableArray alloc] initWithCapacity:0];
        NSMutableArray * detail_deleted_rec = [[NSMutableArray alloc] initWithCapacity:0];
        NSMutableArray * detailsValuesArray_temp = [[NSMutableArray alloc] initWithCapacity:0];
        NSMutableArray * detailValuesId_temp = [[NSMutableArray alloc] initWithCapacity:0];
        NSMutableArray * detailSObjectDataArray = [[NSMutableArray alloc] initWithCapacity:0];
        
        NSString  * detail_values_id = nil;
        
        for (int v = 0; v < [pageDetail.bubbleinfolist count]; v++)
        {
            INTF_WebServicesDefServiceSvc_INTF_DetailBubbleWrapper * detail = [pageDetail.bubbleinfolist objectAtIndex:v];
            INTF_WebServicesDefServiceSvc_sObject * detail_sobject = detail.sobjectinfo;
            
            NSMutableDictionary * detailSObjectData = [[NSMutableDictionary alloc] initWithCapacity:0];

            NSMutableArray * detailKeys = [NSMutableArray arrayWithObjects:
                                    gVALUE_FIELD_API_NAME,
                                    gVALUE_FIELD_VALUE_KEY,
                                    gVALUE_FIELD_VALUE_VALUE,
                                    nil];
            
            NSMutableArray * valuesArray = nil;
            for (int i = 0; i < [detail.bubbleinfolist count]; i++)
            {
                INTF_WebServicesDefServiceSvc_INTF_BubbleWrapper * bubble = [detail.bubbleinfolist objectAtIndex:i];
                NSMutableArray * detailObjects = [NSMutableArray arrayWithObjects:
                                           (bubble.fieldapiname != nil)?bubble.fieldapiname:@"",
                                           (bubble.fieldvalue.key != nil)?bubble.fieldvalue.key:@"",
                                           (bubble.fieldvalue.value != nil)?bubble.fieldvalue.value:@"",
                                           nil];
                NSMutableDictionary * dict = [[NSMutableDictionary dictionaryWithObjects:detailObjects forKeys:detailKeys] retain];
                
                if (valuesArray == nil)
                    valuesArray = [[NSMutableArray alloc] initWithCapacity:0];
                
                NSString * bubble_api_name  = bubble.fieldapiname;
                NSString * value = bubble.fieldvalue.key;
                if ([bubble_api_name isEqualToString:@"Id"])
                {
                    detail_values_id = bubble.fieldvalue.key;
                    continue;
                }
                BOOL flag = FALSE;
                //sahana 28th Aug 2011
                for(int i= 0 ;i<[fieldsArray count];i++)
                {
                    NSDictionary * dict = [fieldsArray objectAtIndex:i];
                    NSString * field_api=[dict objectForKey:gFIELD_API_NAME];
                    if([field_api isEqualToString:bubble_api_name])
                    {
                        flag = TRUE;
                        break;
                    }
                   
                }
                if(flag == TRUE)
                {
                    [valuesArray addObject:dict];
                }
                else
                {
                    [detailSObjectData setObject:(value != nil)?value:@"" forKey:bubble_api_name];
                }
            }
            //sahana 28th Aug 2011
            [detailSObjectDataArray addObject:detailSObjectData];
            
            
            NSMutableArray * value_array_actual = nil;
            if(valuesArray != nil)
            {
                for(int i= 0 ;i<[fieldsArray count];i++)
                {
                    NSDictionary * dict = [fieldsArray objectAtIndex:i];
                    NSString * field_api=[dict objectForKey:gFIELD_API_NAME];
                    for(int k = 0 ; k<[valuesArray count]; k++)
                    {
                        NSDictionary * dict =  [valuesArray objectAtIndex:k];
                        NSString * detail_Api = [dict objectForKey:gVALUE_FIELD_API_NAME];
                        if([field_api isEqualToString:detail_Api])
                        {
                            if(value_array_actual == nil)
                                value_array_actual = [[NSMutableArray alloc] initWithCapacity:0];
                            [value_array_actual addObject:dict];
                            break;
                        }
                    }
                }
                
                //sahana 20th August 2011 - code starts
                // Following code takes care to delete those line items which have been added, but when the user clicks on 
                // the Back button instead of the Save
                NSMutableArray * detailObjects = [NSMutableArray arrayWithObjects:gDETAIL_SAVED_RECORD,
                                                  [NSNumber numberWithInt:1], [NSNumber numberWithInt:1],
                                                  nil];
                NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:detailObjects forKeys:detailKeys];
                [value_array_actual addObject:dict];
                
                //ends
            }
            
            // detail_sobject.  
            if(value_array_actual != nil)
            {
                [detailsValuesArray addObject:value_array_actual];
            }
            //sahana 29th 
            if(detail_values_id == nil)
            {
                [detailValuesId addObject:@""];
            }
            else
            {
                [detailValuesId addObject:detail_values_id];
            }
        }

        
        //sahana - Modification in  details  added hedere reference , detail object name , row id's 
        NSString * detail_header_info = pageDetail.DetailLayout.SVMXC__Header_Reference_Field__c;
        NSString * detail_object_name = pageDetail.DetailLayout.SVMXC__Object_Name__c;
        NSString * detail_object_alias_name = pageDetail.DetailLayout.SVMXC__Name__c;
        NSString * detail_multi_add_config = pageDetail.DetailLayout.SVMXC__Multi_Add_Configuration__c;
        NSString * detail_multi_add_search_field = pageDetail.DetailLayout.SVMXC__Multi_Add_Search_Field__c;
        NSString * detail_mutlti_add_search_object  =pageDetail.DetailLayout.SVMXC__Multi_Add_Search_Object__c;
        NSMutableArray * detailKeys = [NSMutableArray arrayWithObjects:
                                gDETAILS_FIELDS_ARRAY,
                                gDETAILS_VALUES_ARRAY,
                                gDETAIL_SOBJECT_ARRAY,
                                gDETAILS_LAYOUT_ID,
                                gDETAILS_ALLOW_NEW_LINES,
                                gDETAILS_ALLOW_DELETE_LINES,
                                gDETAILS_NUMBER_OF_COLUMNS,
                                gDETAILS_OBJECT_LABEL,
                                gDETAIL_VALUES_RECORD_ID,
                                gDETAIL_HEADER_REFERENCE_FIELD,
                                gDETAIL_OBJECT_NAME,
                                gDETAIL_SEQUENCE_NO,
                                gDETAIL_OBJECT_ALIAS_NAME,
                                gDETAIL_DELETED_RECORDS,
                                gDetail_MULTIADD_CONFIG,
                                gDETAIL_MULTIADD_SEARCH,
                                gDETAIL_MULTIADD_SEARCH_OBJECT,
                                nil];
        
        NSMutableArray * detailObjects = [NSMutableArray arrayWithObjects:
                                          fieldsArray,
                                          detailsValuesArray,
                                          detailSObjectDataArray,
                                          (pageDetail.dtlLayoutId != nil)?pageDetail.dtlLayoutId:@"",
                                          [NSNumber numberWithBool:pageDetail.DetailLayout.SVMXC__Allow_New_Lines__c.boolValue],
                                          [NSNumber numberWithBool:pageDetail.DetailLayout.SVMXC__Allow_Delete_Lines__c.boolValue],
                                          (pageDetail.noOfColumns != nil)?pageDetail.noOfColumns:@"",
                                          (pageDetail.DetailLayout.SVMXC__Name__c != nil)?pageDetail.DetailLayout.SVMXC__Name__c:@"",
                                          detailValuesId,
                                          detail_header_info,
                                          detail_object_name,
                                          (pageDetail.DetailLayout.SVMXC__Sequence__c != nil) ? pageDetail.DetailLayout.SVMXC__Sequence__c:@"",
                                          detail_object_alias_name,
                                          detail_deleted_rec,
                                          (detail_multi_add_config != nil)?detail_multi_add_config:@"",
                                          (detail_multi_add_search_field!= nil)?detail_multi_add_search_field:@"",
                                          (detail_mutlti_add_search_object!= nil)?detail_mutlti_add_search_object:@"",      
                                          nil];
        
        detailsDataDict = [[NSMutableDictionary dictionaryWithObjects:detailObjects forKeys:detailKeys] retain];
        
        [detailDataArray addObject:detailsDataDict];
    }
    if([detailDataArray count] >1)
    {
        for(int x=0; x<[detailDataArray count]; x++)
        {
            for(int y=0; y < [detailDataArray count]-1; y++)
            {
                NSDictionary * dict = [detailDataArray objectAtIndex:y];
                NSString * sequence = [dict objectForKey:gDETAIL_SEQUENCE_NO];
                NSInteger sequence_no = [sequence integerValue];
                NSDictionary *dict_nxt = [detailDataArray objectAtIndex:y+1];
                NSString * sequence_nxt=[dict_nxt objectForKey:gDETAIL_SEQUENCE_NO];
                NSInteger sequence_no_nxt = [sequence_nxt integerValue];
                if(sequence_no > sequence_no_nxt)
                {
                    [detailDataArray exchangeObjectAtIndex:y withObjectAtIndex:y+1];
                }
                
            }
            
        }
    }
    
    NSMutableArray * keys = [NSMutableArray arrayWithObjects:gPROCESS_TITLE, gHEADER, gDETAILS,gPROCESSTYPE, nil];
    NSMutableArray * objects = [NSMutableArray arrayWithObjects:(page.processTitle != nil)?page.processTitle:@"",
                         headerDataDict,
                         detailDataArray,
                        (process_type != nil)?process_type:@"",       
                         nil];
    
    NSMutableDictionary * pageLayout = [[NSMutableDictionary dictionaryWithObjects:objects forKeys:keys] retain];
    SMLog(@"%@", pageLayout);
    
    // SLA Clock Values
    NSMutableArray * mapStringMap = [response MapStringMap];
    NSMutableDictionary * slaTimerDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
    for (INTF_WebServicesDefServiceSvc_INTF_MapStringMap * msm in mapStringMap)
    {
        NSString * key = [msm key];
        if ([key isEqualToString:SLATIMER])
        {
            NSMutableArray * valueMap = [msm valueMap];
            for (INTF_WebServicesDefServiceSvc_INTF_StringMap * strMap in valueMap)
            {
                NSString * _key = [strMap key];
                if ([_key isEqualToString:RESTORATIONTIME])
                {
                    [slaTimerDictionary setValue:[strMap value] forKey:RESTORATIONTIME];
                }
                if ([_key isEqualToString:RESOLUTIONTIME])
                {
                    [slaTimerDictionary setValue:[strMap value] forKey:RESOLUTIONTIME];
                }
            }
        }
    }
    
    [pageLayout setValue:slaTimerDictionary forKey:SLATIMER];
    
    didGetProductHistory = didGetAccountHistory = NO;
    
    // If object is a work order then retrieve product and account history
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString * sfmPageObjectName = [appDelegate.sfmPageController.objectName uppercaseString];
    if ([sfmPageObjectName isEqualToString:@"SVMXCX1__SERVICE_ORDER__C"])
    {
        [self getProductHistoryForWorkOrderId:appDelegate.sfmPageController.recordId];
        [self getAccountHistoryForWorkOrderId:appDelegate.sfmPageController.recordId];
        
        while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO))
        {
            if (![appDelegate isInternetConnectionAvailable])
                return;
            SMLog(@"WSInterface getDictionaryFromPageLayout in while loop");
            SMLog(@"Hello");
            if ((didGetAccountHistory == YES) && (didGetProductHistory == YES))
                break;
        }
        
        // Add product history and account history to sfmpage
        [pageLayout setValue:productHistory forKey:PRODUCTHISTORY];
        [pageLayout setValue:accountHistory forKey:ACCOUNTHISTORY];
    }
     
    // Call this method ONLY after Product and Account History have been retrieved
    if ([self.delegate respondsToSelector:@selector(didReceivePageLayout:withDescribeObjects:)])
        [self.delegate didReceivePageLayout:pageLayout withDescribeObjects:describeObjects];
}

-(NSString *) getAllFieldsForObjectName:(NSString *)hdr_object_name
{
    NSDictionary * fields_dict = [appDelegate.databaseInterface getAllObjectFields:hdr_object_name tableName:SFOBJECTFIELD];
    NSArray * fields_array ; 
    fields_array = [fields_dict allKeys];
    NSString * field_string = @"";
    for(int i = 0 ; i< [fields_array count]; i++)
    {
        NSString * field = [fields_array objectAtIndex:i];
        if (i == 0)
            field_string = [field_string stringByAppendingFormat:@"%@",field];
        else
            field_string = [field_string stringByAppendingFormat:@",%@",field];
    }
    
    return field_string;

}


- (INTF_WebServicesDefServiceSvc_INTF_TargetRecord *) getTargetRecordsFromSFMPage:(NSDictionary *)sfmpage
{
    INTF_WebServicesDefServiceSvc_INTF_TargetRecord * targetRecord = [[[INTF_WebServicesDefServiceSvc_INTF_TargetRecord alloc] init] autorelease];
    
    // [targetRecord setSfmProcessId: (Process ID required here)  ];
    // hardcoding for now - don't we have process id anywhere in the response?? 
    [targetRecord setSfmProcessId:appDelegate.sfmPageController.processId];
    
    //header record object 
    INTF_WebServicesDefServiceSvc_INTF_TargetRecordObject * targetRecordObjectHeader = [[[INTF_WebServicesDefServiceSvc_INTF_TargetRecordObject alloc] init] autorelease];    
    NSDictionary * hdr_object = [sfmpage objectForKey:gHEADER];
    NSString * hdr_object_name = [hdr_object objectForKey:gHEADER_OBJECT_NAME]; // @"hdr_Object_Name"
    [targetRecordObjectHeader setObjName:hdr_object_name];
    //sahana 4th Aug 2011
    NSMutableDictionary * hdrData = [hdr_object objectForKey:gHEADER_DATA];
    
    
    //get ALL records For  record_id 
    NSString *  header_sf_id = [appDelegate.databaseInterface  getSfid_For_LocalId_From_Object_table:hdr_object_name local_id:appDelegate.sfmPageController.recordId];
    
    NSString * field_string = [self getAllFieldsForObjectName:hdr_object_name];
    
    NSMutableDictionary * header_all_fields = [appDelegate.databaseInterface getRecordsForRecordId:appDelegate.sfmPageController.recordId ForObjectName:hdr_object_name fields:field_string];
    
    NSArray *   header_All_fields_keys = [header_all_fields allKeys];
    NSArray * headerData_keys = [hdrData allKeys];
    
    for(NSString * key in header_All_fields_keys)
    {
         NSString * value = [header_all_fields objectForKey:key];
        
        if(![headerData_keys containsObject:key])
        {
            [hdrData  setObject:value forKey:key];
        }
    }
        
    NSArray * allkeys_HeaderData = [hdrData allKeys];
    //Layout id
    NSString * layout_id = [hdr_object objectForKey:gHEADER_HEADER_LAYOUT_ID];
    [targetRecordObjectHeader  setPageLayoutId:layout_id];
     
    INTF_WebServicesDefServiceSvc_INTF_Record * recordHeader = [[[INTF_WebServicesDefServiceSvc_INTF_Record alloc] init] autorelease];
    [recordHeader setTargetRecordId:[hdr_object objectForKey:gHEADER_ID]];
    
    NSArray *header_sections = [hdr_object objectForKey:gHEADER_SECTIONS];
    NSMutableArray * targetRecordAsKeyValue = [recordHeader targetRecordAsKeyValue];
    for (int i=0;i<[header_sections count];i++)
    {
        NSDictionary * section = [header_sections objectAtIndex:i];
        NSArray *section_fields = [section objectForKey:gSECTION_FIELDS]; // @"section_Fields"
        for (int j=0;j<[section_fields count];j++)
        {
            NSDictionary *section_field = [section_fields objectAtIndex:j];
            
            NSString * key = [section_field objectForKey:gFIELD_VALUE_KEY];
            NSString * value = [section_field objectForKey:gFIELD_VALUE_VALUE];
            
            NSString * field_data_type = [appDelegate.databaseInterface getFieldDataType:hdr_object_name filedName:[section_field objectForKey:gFIELD_API_NAME]];
            
            if([field_data_type isEqualToString:@"boolean"])
            {
                if ([value isEqualToString:@"1"] || [value isEqualToString:@"true"] || [value isEqualToString:@"True"])
                {
                    value = @"true";
                }
                else
                {
                    value = @"false";
                }
            }
            
            
            INTF_WebServicesDefServiceSvc_INTF_StringMap * keyMap = [[[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init] autorelease];
            [keyMap setKey:[section_field objectForKey:gFIELD_API_NAME]]; // @"Field_API_Name"
            [keyMap setValue:key]; // @"Field_Value_Key"
            [keyMap setValue1:value]; // @"Field_Value_Value"
            [targetRecordAsKeyValue addObject:keyMap];
            //sahana 4th Aug 2011
            NSString * sectionFieldAPI = [section_field objectForKey:gFIELD_API_NAME];
            //sahana 30th Aug 2011
            for (NSString * key in allkeys_HeaderData)
            {
                NSString * uppercaseKey = [key uppercaseString];
                NSString * uppercaseFieldAPI = [sectionFieldAPI uppercaseString];
                if([uppercaseKey isEqualToString:uppercaseFieldAPI]) // @"Field_API_Name"
                {
                    // @"Field_API_Name"
                    [hdrData removeObjectForKey:key];
                    allkeys_HeaderData = [hdrData allKeys];
                }
            }
        }
    }
    
    // SAMMAN - 27 July, 2011, Adding hdrData objects obtained dynamically from sfmPage
    //NSDictionary * hdrData = [hdr_object objectForKey:gHEADER_DATA];
    NSArray * allKeys = [hdrData allKeys];
    for (NSString * key in allKeys)
    {
        NSString * value = [hdrData objectForKey:key];
        INTF_WebServicesDefServiceSvc_INTF_StringMap * keyMap = [[[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init] autorelease];
        [keyMap setKey:key];
        [keyMap setValue:value];
        [targetRecordAsKeyValue addObject:keyMap];
    }
    
    //separately add a key-value map for record id - as per Bala's instructions on 10th June 2011 - pavaman
    NSString * hdr_id = header_sf_id;    //[hdr_object objectForKey:gHEADER_ID];
    if (hdr_id != nil && ![hdr_id isKindOfClass:[NSNull class]] && ![hdr_id isEqualToString:@""])
    {
        INTF_WebServicesDefServiceSvc_INTF_StringMap * keyMap = [[[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init] autorelease];
        [keyMap setKey:@"id"];
        [keyMap setValue:hdr_id];
        [targetRecordAsKeyValue addObject:keyMap];
    }
    
    
    [[targetRecordObjectHeader records] addObject:recordHeader];
    [targetRecord setHeaderRecord:targetRecordObjectHeader];
    
    //child records
    
    NSArray * details = [sfmpage objectForKey:gDETAILS]; //as many as number of lines sections
    for (int i = 0; i < [details count]; i++) //parts, labor, expense for instance
    {
        NSDictionary *detail = [details objectAtIndex:i];
        INTF_WebServicesDefServiceSvc_INTF_TargetRecordObject * targetRecordObjectDetails = [[[INTF_WebServicesDefServiceSvc_INTF_TargetRecordObject alloc] init] autorelease];  
        
        NSString * detail_object_name = [detail objectForKey:gDETAIL_OBJECT_NAME];
        NSString * detail_layout_id = [detail objectForKey:gDETAILS_LAYOUT_ID];
         NSString *parent_column_name = [detail objectForKey:gDETAIL_HEADER_REFERENCE_FIELD];
        
        
        [targetRecordObjectDetails setObjName:[detail objectForKey:gDETAIL_OBJECT_NAME]];
        //sahana for get price
        [targetRecordObjectDetails setPageLayoutId:[detail objectForKey:gDETAILS_LAYOUT_ID]];
        [targetRecordObjectDetails setParentColumnName:[detail objectForKey:gDETAIL_HEADER_REFERENCE_FIELD]];
        [targetRecordObjectDetails setAliasName:[detail objectForKey:gDETAIL_OBJECT_ALIAS_NAME]]; 

        NSMutableArray * details_values = [detail objectForKey:gDETAILS_VALUES_ARRAY];
        NSMutableArray * details_record_ids = [detail objectForKey:gDETAIL_VALUES_RECORD_ID];
        
            
        NSMutableArray * details_deleted_records = [detail objectForKey:gDETAIL_DELETED_RECORDS];
        NSMutableArray * detailSObjectDataArray = [detail objectForKey:gDETAIL_SOBJECT_ARRAY];
        
        NSArray * detailSobjectKeys = nil;
         //sahana 30th July
        NSInteger count = 0 ;
        
        //Before binding detail with the response ,detail need to have all the hidden fields also so below method to fill all the hidden fields 
        
        for (int j=0;j<[details_values count];j++) //parts for instance
        {
            INTF_WebServicesDefServiceSvc_INTF_Record * recordChild = [[[INTF_WebServicesDefServiceSvc_INTF_Record alloc] init] autorelease];
            NSString * details_record_id = nil;
              NSString * local_id  = @"";
            if(j < [details_record_ids count])
            {
                local_id = [details_record_ids objectAtIndex:j];
                NSString * sfid = [appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:[detail objectForKey:gDETAIL_OBJECT_NAME] local_id:local_id];
                details_record_id = sfid;
                if ([details_record_id isEqualToString:@""])
                    details_record_id = nil;
                [recordChild setTargetRecordId:sfid];
            }
            
            if([detailSObjectDataArray  objectAtIndex:j] != @"")
            {
                detailSobjectKeys = [[detailSObjectDataArray  objectAtIndex:j] allKeys];
            }
            else
                detailSobjectKeys = nil;
            
            NSMutableArray *child_record_fields = [details_values objectAtIndex:j];
            
            NSString * field_string = [self getAllFieldsForObjectName:detail_object_name];
            
            NSMutableDictionary * detail_all_fields = nil;
            if(![local_id isEqualToString:@""])
            {
                detail_all_fields = [appDelegate.databaseInterface getRecordsForRecordId:local_id ForObjectName:detail_object_name fields:field_string];
            }
            else
            {
                NSMutableDictionary * process_components = [appDelegate.databaseInterface  getProcessComponentsForComponentType:TARGETCHILD process_id:appDelegate.sfmPageController.processId layoutId:detail_layout_id objectName:detail_object_name];
                detail_all_fields = [appDelegate.databaseInterface getObjectMappingForMappingId:process_components mappingType:VALUE_MAPPING];
            }
            
            NSMutableArray * all_ApiNames_detail = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
            for (int k=0;k<[child_record_fields count];k++) //fields of one part for instance
            {
                NSDictionary *field = [child_record_fields objectAtIndex:k];
                NSString * field_api_name = [field objectForKey:gVALUE_FIELD_API_NAME];
                [all_ApiNames_detail addObject:field_api_name];
            }
            
            NSArray * detailAllRecords = [detail_all_fields  allKeys];
            
            for(NSString * detailRecordField in detailAllRecords)
            {
                if(![all_ApiNames_detail containsObject:detailRecordField])
                {
                    NSString * key = [detail_all_fields   objectForKey:detailRecordField];
                    
                    NSDictionary * _dict = [NSMutableDictionary  dictionaryWithObjects:[NSArray arrayWithObjects:detailRecordField, key,key,nil] forKeys:[NSArray arrayWithObjects:gVALUE_FIELD_API_NAME,gVALUE_FIELD_VALUE_KEY, gVALUE_FIELD_VALUE_VALUE,nil]];
                    [child_record_fields addObject:_dict];
                }
                
            }
            
        }
          
               
        for (int j=0;j<[details_values count];j++) //parts for instance
        {
            INTF_WebServicesDefServiceSvc_INTF_Record * recordChild = [[[INTF_WebServicesDefServiceSvc_INTF_Record alloc] init] autorelease];
            NSString * details_record_id = nil;
            if(j < [details_record_ids count])
            {
                NSString * local_id = [details_record_ids objectAtIndex:j];
                NSString * sfid = [appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:[detail objectForKey:gDETAIL_OBJECT_NAME] local_id:local_id];
                details_record_id = sfid;
                if ([details_record_id isEqualToString:@""])
                    details_record_id = nil;
                [recordChild setTargetRecordId:sfid];
            }
            
            // Sahana - 5th Aug, 2011 - Cross Referencing Error
            //sahana 9th sept 2011
            if([detailSObjectDataArray  objectAtIndex:j] != @"")
            {
                detailSobjectKeys = [[detailSObjectDataArray  objectAtIndex:j] allKeys];
            }
            else
                detailSobjectKeys = nil;
            NSArray *child_record_fields = [details_values objectAtIndex:j];
            NSMutableArray * targetRecordAsKeyValue = [recordChild targetRecordAsKeyValue];
            for (int k=0;k<[child_record_fields count];k++) //fields of one part for instance
            {
                NSDictionary *field = [child_record_fields objectAtIndex:k];
                INTF_WebServicesDefServiceSvc_INTF_StringMap * keyMap = [[[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init] autorelease];
                NSString * key1 = [field objectForKey:gVALUE_FIELD_VALUE_KEY];
                NSString * value1 = [field objectForKey:gVALUE_FIELD_VALUE_VALUE];
                
                NSString * field_data_type = [appDelegate.databaseInterface getFieldDataType:[detail objectForKey:gDETAIL_OBJECT_NAME] filedName:[field objectForKey:gVALUE_FIELD_API_NAME]];
                
                if([field_data_type isEqualToString:@"boolean"])
                {
                    if ([value1 isEqualToString:@"1"] || [value1 isEqualToString:@"true"] || [value1 isEqualToString:@"True"])
                    {
                        key1 = @"True";
                        value1 = @"True";
                    }
                    else
                    {
                        key1 = @"False";
                        value1 = @"False";
                    }
                }
                
                [keyMap setKey:[field objectForKey:gVALUE_FIELD_API_NAME]];
                [keyMap setValue:key1];
                [keyMap setValue1:value1];
                [targetRecordAsKeyValue addObject:keyMap];
                // Sahana - 5th Aug, 2011 - Cross Referencing Error
                NSString * detailFieldApiName = [field objectForKey:gVALUE_FIELD_API_NAME];
                if(detailSobjectKeys != nil)
                {
                    NSMutableDictionary * detailSObjectDictionary = [detailSObjectDataArray objectAtIndex:j];
                   // NSArray * allKeys = [detailSObjectDictionary allKeys];
                    //sahana 30th Aug 2011
                    for(int i= 0 ; i<[detailSobjectKeys count] ; i++)
                    {
                        NSString * uppercaseString = [[detailSobjectKeys objectAtIndex:i] uppercaseString];
                        NSString * uppercastringDetailApi = [detailFieldApiName uppercaseString];
                        if([uppercaseString  isEqualToString:uppercastringDetailApi])
                        {
                            [detailSObjectDictionary removeObjectForKey:[detailSobjectKeys objectAtIndex:i]];
                            detailSobjectKeys = [[detailSObjectDataArray  objectAtIndex:j] allKeys];
                            break;
                        }
                    }
                }
            }

            if(details_record_id != nil)
            {
                INTF_WebServicesDefServiceSvc_INTF_StringMap * keyMap = [[[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init] autorelease];
                [keyMap setKey:@"_Id"];
                [keyMap setValue:details_record_id];
                [targetRecordAsKeyValue addObject:keyMap];
                
                //sahana 9th sept 2011
               /* // Sahana - 5th Aug, 2011 - Cross Referencing Error
                // Iterate thru gDETAIL_SOBJECT_ARRAY based on current iteration index
                NSDictionary * detailSObjectDictionary = [detailSObjectDataArray objectAtIndex:j];
                NSArray * allKeys = [detailSObjectDictionary allKeys];
                for (NSString * key in allKeys)
                {
                    NSString * value = [detailSObjectDictionary objectForKey:key];
                    INTF_WebServicesDefServiceSvc_INTF_StringMap * keyMap = [[[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init] autorelease];
                    [keyMap setKey:key];
                    [keyMap setValue:value];
                    [targetRecordAsKeyValue addObject:keyMap];
                }*/
            }
            
            //sahana 9th sept 2011
            if([detailSObjectDataArray objectAtIndex:j] != @"")
            {
                // Sahana - 5th Aug, 2011 - Cross Referencing Error
                // Iterate thru gDETAIL_SOBJECT_ARRAY based on current iteration index
                NSDictionary * detailSObjectDictionary = [detailSObjectDataArray objectAtIndex:j];
                NSArray * allKeys = [detailSObjectDictionary allKeys];
                for (NSString * key in allKeys)
                {
                    NSString * value = [detailSObjectDictionary objectForKey:key];
                    INTF_WebServicesDefServiceSvc_INTF_StringMap * keyMap = [[[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init] autorelease];
                    [keyMap setKey:key];
                    [keyMap setValue:value];
                    [targetRecordAsKeyValue addObject:keyMap];
                }
                
            }
            

            //sahana 30th July
           // if([details_record_id  isEqualToString:@""])
            if(details_record_id == nil )
            {
                INTF_WebServicesDefServiceSvc_INTF_StringMap * keyMap = [[[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init] autorelease];
                [keyMap setKey:gDETAIL_SEQUENCE_NO];
                [keyMap setValue:[detail objectForKey:gDETAIL_SEQUENCE_NO]];
                [targetRecordAsKeyValue addObject:keyMap];
                //sahana 30th July
                INTF_WebServicesDefServiceSvc_INTF_StringMap * keyMap1 = [[[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init] autorelease];
                [keyMap1 setKey:gDETAIL_SEQUENCENO_GETPRICE];
                NSString *string = [NSString stringWithFormat:@"%d", count];
                [keyMap1 setValue:string];
                [targetRecordAsKeyValue addObject:keyMap1];
                count++;

            }
            [[targetRecordObjectDetails records] addObject:recordChild];
        }

        NSMutableArray * deleted_records = [targetRecordObjectDetails deleteRecID];

        for (int k=0;k < [details_deleted_records count]; k++ ) // sahana means deleted_detail_records
        {
            [deleted_records addObject:[details_deleted_records objectAtIndex:k]];
        }

        [[targetRecord detailRecords] addObject:targetRecordObjectDetails];
    }
    
    return targetRecord;
}



/*- (INTF_WebServicesDefServiceSvc_INTF_TargetRecord *) getTargetRecordsFromSFMPage:(NSDictionary *)sfmpage
{
    INTF_WebServicesDefServiceSvc_INTF_TargetRecord * targetRecord = [[[INTF_WebServicesDefServiceSvc_INTF_TargetRecord alloc] init] autorelease];
    
    // [targetRecord setSfmProcessId: (Process ID required here)  ];
    // hardcoding for now - don't we have process id anywhere in the response?? 
    [targetRecord setSfmProcessId:appDelegate.currentProcessID];
    
    //header record object 
    INTF_WebServicesDefServiceSvc_INTF_TargetRecordObject * targetRecordObjectHeader = [[[INTF_WebServicesDefServiceSvc_INTF_TargetRecordObject alloc] init] autorelease];    
    NSDictionary * hdr_object = [sfmpage objectForKey:gHEADER];
    NSString * hdr_object_name = [hdr_object objectForKey:gHEADER_OBJECT_NAME]; // @"hdr_Object_Name"
    [targetRecordObjectHeader setObjName:hdr_object_name];
    //sahana 4th Aug 2011
    NSMutableDictionary * hdrData = [hdr_object objectForKey:gHEADER_DATA];
    NSArray * allkeys_HeaderData = [hdrData allKeys];
    //Layout id
    NSString * layout_id = [hdr_object objectForKey:gHEADER_HEADER_LAYOUT_ID];
    [targetRecordObjectHeader  setPageLayoutId:layout_id];
    
    INTF_WebServicesDefServiceSvc_INTF_Record * recordHeader = [[[INTF_WebServicesDefServiceSvc_INTF_Record alloc] init] autorelease];
    [recordHeader setTargetRecordId:[hdr_object objectForKey:gHEADER_ID]];
    
    NSArray *header_sections = [hdr_object objectForKey:gHEADER_SECTIONS];
    NSMutableArray * targetRecordAsKeyValue = [recordHeader targetRecordAsKeyValue];
    for (int i=0;i<[header_sections count];i++)
    {
        NSDictionary * section = [header_sections objectAtIndex:i];
        NSArray *section_fields = [section objectForKey:gSECTION_FIELDS]; // @"section_Fields"
        for (int j=0;j<[section_fields count];j++)
        {
            NSDictionary *section_field = [section_fields objectAtIndex:j];
            INTF_WebServicesDefServiceSvc_INTF_StringMap * keyMap = [[[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init] autorelease];
            [keyMap setKey:[section_field objectForKey:gFIELD_API_NAME]]; // @"Field_API_Name"
            [keyMap setValue:[section_field objectForKey:gFIELD_VALUE_KEY]]; // @"Field_Value_Key"
            [keyMap setValue1:[section_field objectForKey:gFIELD_VALUE_VALUE]]; // @"Field_Value_Value"
            [targetRecordAsKeyValue addObject:keyMap];
            //sahana 4th Aug 2011
            NSString * sectionFieldAPI = [section_field objectForKey:gFIELD_API_NAME];
            //sahana 30th Aug 2011
            for (NSString * key in allkeys_HeaderData)
            {
                NSString * uppercaseKey = [key uppercaseString];
                NSString * uppercaseFieldAPI = [sectionFieldAPI uppercaseString];
                if([uppercaseKey isEqualToString:uppercaseFieldAPI]) // @"Field_API_Name"
                {
                    // @"Field_API_Name"
                    [hdrData removeObjectForKey:key];
                    allkeys_HeaderData = [hdrData allKeys];
                }
            }
        }
    }
    
    // SAMMAN - 27 July, 2011, Adding hdrData objects obtained dynamically from sfmPage
    //NSDictionary * hdrData = [hdr_object objectForKey:gHEADER_DATA];
    NSArray * allKeys = [hdrData allKeys];
    for (NSString * key in allKeys)
    {
        NSString * value = [hdrData objectForKey:key];
        INTF_WebServicesDefServiceSvc_INTF_StringMap * keyMap = [[[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init] autorelease];
        [keyMap setKey:key];
        [keyMap setValue:value];
        [targetRecordAsKeyValue addObject:keyMap];
    }
    
    //separately add a key-value map for record id - as per Bala's instructions on 10th June 2011 - pavaman
    NSString * hdr_id = [hdr_object objectForKey:gHEADER_ID];
    if (hdr_id != nil && ![hdr_id isKindOfClass:[NSNull class]] && ![hdr_id isEqualToString:@""])
    {
        INTF_WebServicesDefServiceSvc_INTF_StringMap * keyMap = [[[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init] autorelease];
        [keyMap setKey:@"id"];
        [keyMap setValue:hdr_id];
        [targetRecordAsKeyValue addObject:keyMap];
    }
    
    
    [[targetRecordObjectHeader records] addObject:recordHeader];
    [targetRecord setHeaderRecord:targetRecordObjectHeader];
    
    //child records
    
    NSArray * details = [sfmpage objectForKey:gDETAILS]; //as many as number of lines sections
    for (int i = 0; i < [details count]; i++) //parts, labor, expense for instance
    {
        NSDictionary *detail = [details objectAtIndex:i];
        INTF_WebServicesDefServiceSvc_INTF_TargetRecordObject * targetRecordObjectDetails = [[[INTF_WebServicesDefServiceSvc_INTF_TargetRecordObject alloc] init] autorelease];  
        
        [targetRecordObjectDetails setObjName:[detail objectForKey:gDETAIL_OBJECT_NAME]];
        //sahana for get price
        [targetRecordObjectDetails setPageLayoutId:[detail objectForKey:gDETAILS_LAYOUT_ID]];
        [targetRecordObjectDetails setParentColumnName:[detail objectForKey:gDETAIL_HEADER_REFERENCE_FIELD]];
        [targetRecordObjectDetails setAliasName:[detail objectForKey:gDETAIL_OBJECT_ALIAS_NAME]]; 
        
        NSMutableArray * details_values = [detail objectForKey:gDETAILS_VALUES_ARRAY];
        NSMutableArray * details_record_ids = [detail objectForKey:gDETAIL_VALUES_RECORD_ID];
        NSMutableArray * details_deleted_records = [detail objectForKey:gDETAIL_DELETED_RECORDS];
        NSMutableArray * detailSObjectDataArray = [detail objectForKey:gDETAIL_SOBJECT_ARRAY];
        // Sahana - 5th Aug, 2011 - Cross Referencing Error
        NSArray * detailSobjectKeys = nil;
        //sahana 30th July
        NSInteger count = 0 ;
        
        for (int j=0;j<[details_values count];j++) //parts for instance
        {
            INTF_WebServicesDefServiceSvc_INTF_Record * recordChild = [[[INTF_WebServicesDefServiceSvc_INTF_Record alloc] init] autorelease];
            NSString * details_record_id = nil;
            if(j < [details_record_ids count])
            {
                details_record_id = [details_record_ids objectAtIndex:j];
                if ([details_record_id isEqualToString:@""])
                    details_record_id = nil;
                [recordChild setTargetRecordId:details_record_id];
            }
            
            // Sahana - 5th Aug, 2011 - Cross Referencing Error
            //sahana 9th sept 2011
            if([detailSObjectDataArray  objectAtIndex:j] != @"")
            {
                detailSobjectKeys = [[detailSObjectDataArray  objectAtIndex:j] allKeys];
            }
            else
                detailSobjectKeys = nil;
            NSArray *child_record_fields = [details_values objectAtIndex:j];
            NSMutableArray * targetRecordAsKeyValue = [recordChild targetRecordAsKeyValue];
            for (int k=0;k<[child_record_fields count];k++) //fields of one part for instance
            {
                NSDictionary *field = [child_record_fields objectAtIndex:k];
                INTF_WebServicesDefServiceSvc_INTF_StringMap * keyMap = [[[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init] autorelease];
                [keyMap setKey:[field objectForKey:gVALUE_FIELD_API_NAME]];
                [keyMap setValue:[field objectForKey:gVALUE_FIELD_VALUE_KEY]];
                [keyMap setValue1:[field objectForKey:gVALUE_FIELD_VALUE_VALUE]];
                [targetRecordAsKeyValue addObject:keyMap];
                // Sahana - 5th Aug, 2011 - Cross Referencing Error
                NSString * detailFieldApiName = [field objectForKey:gVALUE_FIELD_API_NAME];
                if(detailSobjectKeys != nil)
                {
                    NSMutableDictionary * detailSObjectDictionary = [detailSObjectDataArray objectAtIndex:j];
                    // NSArray * allKeys = [detailSObjectDictionary allKeys];
                    //sahana 30th Aug 2011
                    for(int i= 0 ; i<[detailSobjectKeys count] ; i++)
                    {
                        NSString * uppercaseString = [[detailSobjectKeys objectAtIndex:i] uppercaseString];
                        NSString * uppercastringDetailApi = [detailFieldApiName uppercaseString];
                        if([uppercaseString  isEqualToString:uppercastringDetailApi])
                        {
                            [detailSObjectDictionary removeObjectForKey:[detailSobjectKeys objectAtIndex:i]];
                            detailSobjectKeys = [[detailSObjectDataArray  objectAtIndex:j] allKeys];
                            break;
                        }
                    }
                }
            }
            
            if(details_record_id != nil)
            {
                INTF_WebServicesDefServiceSvc_INTF_StringMap * keyMap = [[[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init] autorelease];
                [keyMap setKey:@"_Id"];
                [keyMap setValue:details_record_id];
                [targetRecordAsKeyValue addObject:keyMap];
                
                //sahana 9th sept 2011
                /* // Sahana - 5th Aug, 2011 - Cross Referencing Error
                 // Iterate thru gDETAIL_SOBJECT_ARRAY based on current iteration index
                 NSDictionary * detailSObjectDictionary = [detailSObjectDataArray objectAtIndex:j];
                 NSArray * allKeys = [detailSObjectDictionary allKeys];
                 for (NSString * key in allKeys)
                 {
                 NSString * value = [detailSObjectDictionary objectForKey:key];
                 INTF_WebServicesDefServiceSvc_INTF_StringMap * keyMap = [[[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init] autorelease];
                 [keyMap setKey:key];
                 [keyMap setValue:value];
                 [targetRecordAsKeyValue addObject:keyMap];
                 }
            }
            
            //sahana 9th sept 2011
            if([detailSObjectDataArray objectAtIndex:j] != @"")
            {
                // Sahana - 5th Aug, 2011 - Cross Referencing Error
                // Iterate thru gDETAIL_SOBJECT_ARRAY based on current iteration index
                NSDictionary * detailSObjectDictionary = [detailSObjectDataArray objectAtIndex:j];
                NSArray * allKeys = [detailSObjectDictionary allKeys];
                for (NSString * key in allKeys)
                {
                    NSString * value = [detailSObjectDictionary objectForKey:key];
                    INTF_WebServicesDefServiceSvc_INTF_StringMap * keyMap = [[[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init] autorelease];
                    [keyMap setKey:key];
                    [keyMap setValue:value];
                    [targetRecordAsKeyValue addObject:keyMap];
                }
                
            }
            
            
            //sahana 30th July
            // if([details_record_id  isEqualToString:@""])
            if(details_record_id == nil )
            {
                INTF_WebServicesDefServiceSvc_INTF_StringMap * keyMap = [[[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init] autorelease];
                [keyMap setKey:gDETAIL_SEQUENCE_NO];
                [keyMap setValue:[detail objectForKey:gDETAIL_SEQUENCE_NO]];
                [targetRecordAsKeyValue addObject:keyMap];
                //sahana 30th July
                INTF_WebServicesDefServiceSvc_INTF_StringMap * keyMap1 = [[[INTF_WebServicesDefServiceSvc_INTF_StringMap alloc] init] autorelease];
                [keyMap1 setKey:gDETAIL_SEQUENCENO_GETPRICE];
                NSString *string = [NSString stringWithFormat:@"%d", count];
                [keyMap1 setValue:string];
                [targetRecordAsKeyValue addObject:keyMap1];
                count++;
                
            }
            [[targetRecordObjectDetails records] addObject:recordChild];
        }
        
        NSMutableArray * deleted_records = [targetRecordObjectDetails deleteRecID];
        
        for (int k=0;k < [details_deleted_records count]; k++ ) // sahana means deleted_detail_records
        {
            [deleted_records addObject:[details_deleted_records objectAtIndex:k]];
        }
        
        [[targetRecord detailRecords] addObject:targetRecordObjectDetails];
    }
    
    return targetRecord;
}*/


#pragma mark - INTF_WebServicesDefBindingOperation Delegate Method
- (NSMutableDictionary *) getTagsdisplay:(INTF_WebServicesDefBindingResponse *)response
{
    NSMutableDictionary * _tagsDictionary = nil;
    NSMutableArray * array = nil;
    int ret;
        
    for ( int i = 0; i < [response.bodyParts count]; i++ )
    {
        ret = [[response.bodyParts objectAtIndex:i] isKindOfClass:[SOAPFault class]];
        if ( ret )
        {
            SMLog(@"ERROR: IN THE RESPONSE RECEIVED");
            break;
        }
        else
        {
            @try
            {
                array = [[[response.bodyParts objectAtIndex:i] result] tagInfo];
            }
            @catch (...)
            {
            }
            if ( array == nil ) 
                array = [[[NSMutableArray alloc] init] autorelease];
            break;
        }
    }
    SMLog(@"%d", [response.bodyParts count]);
    SMLog(@"%@", array);
    
    if ([array count] == 0)
    {
        _tagsDictionary = [self getDefaultTags];
        return _tagsDictionary;
    }
    else
    {
        _tagsDictionary = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
        for ( int  i = 0; i < [array count]; i++)
        {
            [_tagsDictionary setValue:([[array objectAtIndex:i] value] != nil)?[[array objectAtIndex:i] value]:@"" forKey:[[array objectAtIndex:i] key]];
        }
    }
    
    SMLog(@"%@", _tagsDictionary);
    // Samman
    _tagsDictionary = [self fillEmptyTags:_tagsDictionary];
    return _tagsDictionary;
}

// Radha 14th July 2011
// To fill empty tags with temporary values when webservice fails
-(NSMutableDictionary *) fillEmptyTags:(NSMutableDictionary *)_tagsDictionary
{
    NSArray * keys = [_tagsDictionary allKeys];

    NSMutableDictionary * defaultTags = [self getDefaultTags];
    NSArray * default_keys = [defaultTags allKeys];
    
    for (int i = 0; i < [keys count]; i++)
    {
        NSString * key = [keys objectAtIndex:i];
        if (([_tagsDictionary objectForKey:key] == nil) || 
            [[_tagsDictionary objectForKey:key] isEqualToString:@""] || 
            ([[_tagsDictionary objectForKey:key] length] == 0))
        {
            NSString * defaultValue = [defaultTags objectForKey:key];
            [_tagsDictionary setValue:defaultValue forKey:key];
        }
    }
    
    for(int j = 0 ; j < [default_keys count];j++)
    {
        NSString * key = [default_keys objectAtIndex:j];    
        if(![keys containsObject:key])
        {
            NSString * defaultValue = [defaultTags objectForKey:key];
            [_tagsDictionary setValue:defaultValue forKey:key];
        }
    }
    
    return _tagsDictionary;
}

-(NSMutableDictionary *) getDefaultTags
{
    NSString * path = [[NSBundle mainBundle] bundlePath];
    NSString *plistPath = [path stringByAppendingPathComponent:@"LocalizationDefaults.plist"];
    NSMutableDictionary * defaultTags = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    return defaultTags;
}

//Radha 29th April 2011
-(NSMutableArray *) getEventdisplay:(INTF_WebServicesDefBindingResponse *)response
{    
    INTF_WebServicesDefServiceSvc_INTF_Get_Events_WSResponse * wsResponse = [response.bodyParts objectAtIndex:0];
    NSMutableArray * _eventArray = wsResponse.result.eventInfo;
    NSMutableArray * arr = nil;
    NSMutableDictionary * dict;
    
    //Radha 30th April 2011
    for ( int i = 0; i < [_eventArray count]; i++ ) 
    {
        INTF_WebServicesDefServiceSvc_INTF_Event * event = [_eventArray objectAtIndex:i];
        
        NSMutableArray * eventKeys = [NSMutableArray arrayWithObjects:
                               OBJECTAPINAME,                                 
                               OBJECTLABEL,                                           
                               ADDITIONALINFO,          
                               COLORCODE,              
                               ACTIVITYDATE,            
                               ACTIVITYDTIME,          
                               ATTACHMENTS,            
                               CREATEDDATE,            
                               DESCRIPTION,             
                               DURATIONINMIN,          
                               ENDDATETIME,            
                               ISALLEVENT,             
                               ISARCHIVED,             
                               ISCHILD,                
                               ISGROUPED,              
                               ISPRIVATE,              
                               ISREMINDERSET,         
                               LOCATION,               
                               STARTDATETIME,          
                               SUBJECT,                
                               TNAME,                   
                               WHATID,
                               EVENTID,       
                               STREET,
                               CITY,
                               STATE,
                               COUNTRY,
                               ZIP,
                               LATITUDE,
                               LONGITUDE,
                               nil];
      
        
        NSMutableArray * eventDisplay = event.eventDisplay;
        
        NSString * apiNameStrMap = nil;
        NSString * objLabel = nil;
        NSString * addInfo=nil ;
        NSString * colorCode =nil;
        if([eventDisplay count]>0)
            apiNameStrMap = [[eventDisplay objectAtIndex:0] value];
        if([eventDisplay count] >1)
            objLabel = [[eventDisplay objectAtIndex:1] value];
        if([eventDisplay count ] > 2)
            addInfo = [[eventDisplay objectAtIndex:2] value] ;
        if([eventDisplay count] > 3)
            colorCode = [[eventDisplay objectAtIndex:3] value];
        
        INTF_WebServicesDefServiceSvc_Event * eventInfo = event.eventInfo;
        
        NSArray * locationInfo = event.locationInfo;
        
        NSString * street = nil, * city = nil, * state = nil, * country = nil, * zip = nil, * latitude = nil, * longitude = nil;
        
        for (int i = 0; i < [locationInfo count]; i++)
        {
            INTF_WebServicesDefServiceSvc_INTF_StringMap * strMap = [locationInfo objectAtIndex:i];
            NSString * key = strMap.key;
            if ([key isEqualToString:STREET])
                street = strMap.value;
            else if ([key isEqualToString:CITY])
                city = strMap.value;
            else if ([key isEqualToString:STATE])
                state = strMap.value;
            else if ([key isEqualToString:COUNTRY])
                country = strMap.value;
            else if ([key isEqualToString:ZIP])
                zip = strMap.value;
            else if ([key isEqualToString:LATITUDE])
                latitude = strMap.value;
            else if ([key isEqualToString:LONGITUDE])
                longitude = strMap.value;

        }
        NSMutableArray * eventObjects = [NSMutableArray arrayWithObjects:
                                  (apiNameStrMap != nil)?apiNameStrMap:@"",
                                  (objLabel != nil)?objLabel:@"",
                                  (addInfo != nil)?addInfo:@"",
                                  (colorCode != nil)?colorCode:@"",
                                  (eventInfo.ActivityDate != nil)?eventInfo.ActivityDate:@"",
                                  (eventInfo.ActivityDateTime != nil)? eventInfo.ActivityDateTime:@"",
                                  (eventInfo.Attachments != nil)?eventInfo.Attachments:@"",
                                  (eventInfo.CreatedDate != nil)?eventInfo.CreatedDate:@"",
                                  (eventInfo.Description != nil)?eventInfo.Description:@"",
                                  (eventInfo.DurationInMinutes != nil)?eventInfo.DurationInMinutes:@"",
                                  (eventInfo.EndDateTime != nil)?eventInfo.EndDateTime:@"",
                                  (eventInfo.IsAllDayEvent != nil)?eventInfo.IsAllDayEvent:@"",
                                  (eventInfo.IsArchived != nil)?eventInfo.IsArchived:@"",
                                  (eventInfo.IsChild != nil)?eventInfo.IsChild:@"",
                                  (eventInfo.IsGroupEvent != nil)?eventInfo.IsGroupEvent:@"",
                                  (eventInfo.IsPrivate != nil)?eventInfo.IsPrivate:@"",
                                  (eventInfo.IsReminderSet != nil)?eventInfo.IsReminderSet:@"",
                                  (eventInfo.Location != nil)?eventInfo.Location:@"",
                                  (eventInfo.StartDateTime != nil)?eventInfo.StartDateTime:@"",
                                  (eventInfo.Subject != nil)?eventInfo.Subject:@"",
                                  (eventInfo.Type != nil)?eventInfo.Type:@"",
                                  (eventInfo.WhatId != nil)?eventInfo.WhatId:@"",
                                  (eventInfo.Id_ != nil)?eventInfo.Id_:@"",       
                                  (street != nil)?street:@"",
                                  (city != nil)?city:@"",
                                  (state != nil)?state:@"",
                                  (country != nil)?country:@"",
                                  (zip != nil)?zip:@"",
                                  (latitude != nil)?latitude:@"",
                                  (longitude != nil)?longitude:@"",
                                  nil]; 
        
        dict = [NSMutableDictionary  dictionaryWithObjects:eventObjects forKeys:eventKeys];
        
        
        if (arr == nil)
            arr = [[[NSMutableArray alloc] initWithCapacity:[_eventArray count]] autorelease];
        
        [arr addObject:dict];
    }
    SMLog(@"arr = %@", arr); 
    return arr;
}

- (NSArray *) getCreateProcessesDictionaryArray:(INTF_WebServicesDefBindingResponse *)response
{
    NSDictionary * dict;
    NSMutableArray * array = nil;
    
    // appDelegate.StandAloneCreateProcess = nil;
    // return array;
    
    INTF_WebServicesDefServiceSvc_INTF_Get_StandaloneCreate_LayoutsResponse * viewWsResponse = [response.bodyParts objectAtIndex:0];
    NSArray * create_processes = viewWsResponse.result.layoutsInfo; 
    for ( int i = 0; i < [create_processes count]; i++ )
    {
        INTF_WebServicesDefServiceSvc_SVMXC__ServiceMax_Processes__c * create_process = [create_processes objectAtIndex:i];
        
        NSArray * createInfokeys = [NSArray arrayWithObjects:
                                  SVMXC_Name, 
                                  SVMXC_ProcessID,
                                  SVMXC_Description,
                                  SVMXC_OBJECT_NAME,
                                  nil];
        
        NSArray * createInfoObjects = [NSArray arrayWithObjects:
                                     (create_process.SVMXC__Name__c != nil)?create_process.SVMXC__Name__c:@"",
                                     (create_process.SVMXC__ProcessID__c != nil)?create_process.SVMXC__ProcessID__c:@"",
                                     (create_process.SVMXC__Description__c != nil) ? create_process.SVMXC__Description__c:@"",
                                     (create_process.SVMXC__Source_Object_Name__c != nil)? create_process.SVMXC__Source_Object_Name__c:@"",
                                     nil];
        
        dict = [NSDictionary dictionaryWithObjects:createInfoObjects forKeys:createInfokeys];
        
        if (array == nil)
            array = [[[NSMutableArray alloc] initWithCapacity:[create_processes count]] autorelease];
        
        [array addObject:dict];
    }
    
    //sahana 7th July
    //testing code 
    
    //collect all the object names in an array arrange it in the alpha order 
    objectNames_array = [[NSMutableArray alloc] initWithCapacity:0];
    for(int i = 0 ;i<[array count]; i++)
    {
        NSDictionary * dict = [array objectAtIndex:i];
        NSString * str = [dict objectForKey:SVMXC_OBJECT_NAME];  
        
        if(i  == 0)
        {
            [objectNames_array  addObject:str];
            continue;
        }
        NSInteger count=0;
        for(int j = 0; j < [objectNames_array count];j++)
        {
            if([str isEqualToString:[objectNames_array objectAtIndex:j]])
            {
                count ++;
            }
        }
        if(count == 0)
        {
            [objectNames_array  addObject:str];
        }
        
    }
    SMLog(@ "appdelegate---objectNames_array %@",objectNames_array);

    [[ZKServerSwitchboard switchboard] describeSObjects:objectNames_array target:self selector:@selector(didGetNameFields:error:context:) context:nil];
    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, FALSE))
    {
        SMLog(@"WSInterface getCreateProcessDictionaryArray in while loop");
        if ( didGetObjectName == TRUE )
            break;
    }

    SMLog(@"appdelegate---objectNames_array %@",appDelegate.objectLabel_array);
    
    section_for_createObjects = [[NSMutableArray alloc] initWithCapacity:0];
    for(int i=0 ;i< [objectNames_array count]; i++)
    {
        NSString * objectName = [objectNames_array objectAtIndex:i];
        NSMutableArray * createobjects = [[NSMutableArray alloc] initWithCapacity:0];
        for(int j=0;j<[array count];j++)
        {
            NSDictionary * dict = [array objectAtIndex:j];
            NSString * str = [dict objectForKey:SVMXC_OBJECT_NAME];
            if([str isEqualToString:objectName])
            {
                [createobjects addObject:dict];
            }
        }
        
        [section_for_createObjects addObject:createobjects];
        [createobjects release];
    }
    //create a
    appDelegate.StandAloneCreateProcess = [section_for_createObjects retain];
    appDelegate.objectNames_array = [objectNames_array retain];
     //  SMLog(@"viewLayouts = %@", dict);
    SMLog(@"viewLayouts= %@", array);
    //SMLog(@"%@" , objectNames_array);
    //SMLog(@"%@" ,section_for_createObjects);
    SMLog(@ "appdelegate--- %@",appDelegate.StandAloneCreateProcess);
    SMLog(@"apdelegate-----%@",appDelegate.objectNames_array);
    SMLog(@"%@", appDelegate.objectLabel_array);
    
    
    //Radha for sorting 
    if (appDelegate.objectLabelName_array == nil)
        appDelegate.objectLabelName_array = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    NSMutableDictionary * _dict = nil;
    for (int i = 0; i < [appDelegate.objectNames_array count]; i++)
    {
        if (_dict == nil)
            _dict = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
        //[_dict setValue:[appDelegate.objectNames_array objectAtIndex:i] forKey:[appDelegate.objectLabel_array objectAtIndex:i]];
        [_dict setValue:[appDelegate.objectLabel_array objectAtIndex:i] forKey:[appDelegate.objectNames_array objectAtIndex:i]];
        [appDelegate.objectLabelName_array addObject:_dict];
        _dict = nil;
    }
    
    SMLog(@"%@", appDelegate.objectLabelName_array);
    
    if ( [appDelegate.objectLabelName_array count] > 1 )
    {
        int i = 0;
        for (i = 0; i < [appDelegate.objectLabelName_array count] - 1; i++)
        {
            
            for (int j = 0; j < ([appDelegate.objectLabelName_array count] - (i +1)); j++)
            {
                NSDictionary * dict = [appDelegate.objectLabelName_array objectAtIndex:j];
                NSArray * arr = [dict allValues];
                NSString * label = [arr objectAtIndex:0];
                NSString * label1;
                              NSDictionary * _dict = [appDelegate.objectLabelName_array objectAtIndex:j+1];
                NSArray * arr1 = [_dict allValues];
                label1 = [arr1 objectAtIndex:0];
                if (strcmp([label UTF8String], [label1 UTF8String]) > 0)
                {
                    [appDelegate.objectLabelName_array exchangeObjectAtIndex:j withObjectAtIndex:j+1];
                }
            }
        }
    }
    
    SMLog(@"%@", appDelegate.objectLabelName_array);

    SMLog(@"appdelegate---objectNames_array %@",appDelegate.objectLabel_array);

    section_for_createObjects = [[NSMutableArray alloc] initWithCapacity:0];
    for(int i=0 ;i< [objectNames_array count]; i++)
    {
       
        NSDictionary * dict =  [appDelegate.objectLabelName_array objectAtIndex:i];
        NSString * objectName = [[dict allKeys] objectAtIndex:0];
        NSMutableArray * createobjects = [[NSMutableArray alloc] initWithCapacity:0];
        for(int j=0;j<[array count];j++)
        {
            NSDictionary * dict = [array objectAtIndex:j];
            NSString * str = [dict objectForKey:SVMXC_OBJECT_NAME];
            if([str isEqualToString:objectName])
            {
                [createobjects addObject:dict];
            }
        }
        
        [section_for_createObjects addObject:createobjects];
        [createobjects release];
    }
    appDelegate.StandAloneCreateProcess = [section_for_createObjects retain];

    return array;
}

- (NSArray *) getViewLayoutArray:(INTF_WebServicesDefBindingResponse *)response
{
    NSDictionary * dict;
    
    NSMutableArray * array = nil;
    
    // return array;
    
    INTF_WebServicesDefServiceSvc_INTF_Get_View_Layouts_WSResponse * viewLayouts = [response.bodyParts objectAtIndex:0];
    
    NSArray * viewLayoutsInfo = viewLayouts.result.layoutsInfo;
    
    if (array == nil)
        array = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    NSMutableArray * arr = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    for (int i = 0; i < [viewLayoutsInfo count]; i++)
    {
        NSString * objectName = [[viewLayoutsInfo objectAtIndex:i] objectName];
        
        NSArray * layoutsInfo = [[viewLayoutsInfo objectAtIndex:i] layoutsInfo];
        [arr addObject:objectName];
        
        for (int j = 0; j < [layoutsInfo count]; j++)
        {
            INTF_WebServicesDefServiceSvc_SVMXC__ServiceMax_Processes__c * viewInfo = [layoutsInfo objectAtIndex:j];
            NSArray * viewInfokeys = [NSArray arrayWithObjects:
                                      VIEW_OBJECTNAME,
                                      VIEW_SVMXC_Name, 
                                      VIEW_SVMXC_ProcessID, 
                                      nil];
            
            NSArray * viewInfoObjects = [NSArray arrayWithObjects:
                                         (objectName != nil)?objectName:@"",
                                         (viewInfo.SVMXC__Name__c != nil)?viewInfo.SVMXC__Name__c:@"",
                                         (viewInfo.SVMXC__ProcessID__c != nil)?viewInfo.SVMXC__ProcessID__c:@"",
                                         nil];
            dict = [NSDictionary dictionaryWithObjects:viewInfoObjects forKeys:viewInfokeys];
            
            SMLog(@"%@", dict);
            [array addObject:dict];
        }
    }
    SMLog(@"%@", array);
    return array;
}


-(void)didGetNameFields:(NSMutableArray *) describeObjects error:(NSError *) error context:(id)context;
{
    NSMutableArray * objectNames = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    ZKDescribeSObject * sobj=nil;
    for (int itr = 0; itr < [describeObjects count]; itr++)
    {
        sobj = [describeObjects objectAtIndex:itr];
        for(int j= 0 ;j< [obj_array count]; j++)
        {
            if ([[sobj name] isEqualToString:[objectNames_array  objectAtIndex:j]])
                  break;
        }

        NSString * label = [sobj label];
        [objectNames addObject:label];
    }
    appDelegate.objectLabel_array = objectNames;

    didGetObjectName = TRUE;
      
}

-(NSMutableDictionary *) getSaveTargetRecords:(INTF_WebServicesDefBindingResponse *)response
{
    NSMutableDictionary * dict = nil;
    
    if (appDelegate.createObjectContext == nil)
        appDelegate.createObjectContext = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
    
    NSString * resultId = nil;
    
    for (int i = 0; i < [response.bodyParts count]; i++)
    {
        INTF_WebServicesDefServiceSvc_SFM_SaveTargetRecords_WSResponse * saveResponse = [response.bodyParts objectAtIndex:i]; 
        
        INTF_WebServicesDefServiceSvc_INTF_Response * saveResult = saveResponse.result;
        
        for (int i = 0; i < [saveResult.resultIds count]; i++)
        {
            resultId = [saveResult.resultIds objectAtIndex:i];
            [appDelegate.createObjectContext setObject:resultId forKey:RESULTID];
        }
        if (resultId == nil)
            resultId = @"";
        if ([saveResult.resultIds count] == 0)
            resultId = @""; 
        
        NSArray * keys = [NSArray arrayWithObjects:
                          RESULTID,
                          SUCCESS,
                          nil];
        NSArray * objects = [NSArray arrayWithObjects:
                             resultId,   
                             (saveResult.success != nil)?saveResult.success:@"", 
                             nil]; 
        dict = [NSMutableDictionary dictionaryWithObjects:objects forKeys:keys];
    }
    
    [self getNameFieldForCreateProcess:resultId];
    //sahana
    appDelegate.newRecordId = resultId;
    
    return appDelegate.createObjectContext;
}

- (void) getNameFieldForCreateProcess:(NSString *)ID
{
    //Radha 16th Sep
    didGetNameField = FALSE;
    NSString * name = [appDelegate.createObjectContext objectForKey:NAME_FIELD];
    NSString * objname = [appDelegate.createObjectContext objectForKey:OBJ_NAME];
    NSString * _query = [NSString stringWithFormat:@"SELECT %@ From %@ WHERE ID = '%@'",name, objname, ID]; 
    [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didGetNameField:error:context:) context:nil];
    
    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, FALSE))
    {
        //shrinivas
        if (appDelegate.isForeGround == TRUE)
        {
            LoginController * loginController = [[LoginController alloc] init];
            appDelegate.didFinishWithError = FALSE;
            [loginController.activity stopAnimating];
            [loginController enableControls];
            
            [loginController release];
            return;
        }

        
        SMLog(@"WSInterface getNameFieldForCreateProcess in while loop");
        if (![appDelegate isInternetConnectionAvailable])
        {
            didGetProcessId = TRUE;
            didGetNameField = TRUE;
            //[appDelegate displayNoInternetAvailable];
            break;
        }
        if ( didGetNameField == TRUE )
        {
            didGetNameField = FALSE;
            break;
        }
    }
}

- (void) didGetNameField:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    NSArray * array = [result records];
    NSDictionary * dict = nil ;       
    NSString * str = nil ;
    
    SMLog(@"%@", array);
    
    if ([array count] > 0)
    {
        ZKSObject * obj = [array objectAtIndex:0];
        dict = [obj fields]; 
        str = [dict valueForKey:@"Name"];
        SMLog(@"%@", dict);
        SMLog(@"%@",str);
    }
    
    [appDelegate.createObjectContext setObject:(str != nil)?str:@"" forKey:NAME_FIELD];
    SMLog(@"%@", appDelegate.createObjectContext);
    
    NSString * objectName = [appDelegate.createObjectContext objectForKey:OBJECT_NAME];
    for (int j = 0; j < [appDelegate.wsInterface.viewLayoutsArray count]; j++)
    {
        NSDictionary * viewLayoutDict = [appDelegate.wsInterface.viewLayoutsArray objectAtIndex:j];
        NSString * objName = [viewLayoutDict objectForKey:VIEW_OBJECTNAME];
        if ([objName isEqualToString:objectName])
        {
            [appDelegate.createObjectContext setValue:[viewLayoutDict objectForKey:@"SVMXC__ProcessID__c"] forKey:PROCESSID];
            appDelegate.newProcessId = [viewLayoutDict objectForKey:@"SVMXC__ProcessID__c"];
            break;
        }
    }
    
    //sahana today
    NSDate * date = [NSDate date];
    NSDateFormatter * frm =[ [NSDateFormatter alloc] init];
    [frm setDateFormat:DATETIMEFORMAT];
    NSString * date_str = [frm stringFromDate:date];
    [appDelegate.createObjectContext setValue:date_str forKey:gDATE_TODAY];
    [frm release];
    [self saveDictionaryToPList:appDelegate.createObjectContext];
    
    //sahana 16th sept 2011
    didGetProcessId = TRUE;
    didGetNameField = TRUE;
}

- (void) saveDictionaryToPList:(NSMutableDictionary *)dictionary 
{
    NSString *error;
    
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *plistPath = [rootPath stringByAppendingPathComponent:OBJECT_HISTORY_PLIST];
    
    NSData * plistData = [NSPropertyListSerialization dataFromPropertyList:dictionary format:NSPropertyListXMLFormat_v1_0
                                                          errorDescription:&error];
    
    NSMutableArray * array = nil;
    
    if (appDelegate.recentObject == nil)
        appDelegate.recentObject = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    if(plistData)
    {
        array = [[[NSMutableArray alloc] initWithContentsOfFile:plistPath] autorelease];
        
        if (array == nil)
            array = [[NSMutableArray alloc] initWithCapacity:0];
        SMLog(@"%@", array);
        
        int count = [array count];
        
        SMLog(@"%d", count);
        
        if (count > VALUE) 
        {
            [array removeObjectAtIndex:0];
        }
    
        // [array addObject:dictionary];
        [array insertObject:dictionary atIndex:0];
        [array writeToFile:plistPath atomically:YES];
        [appDelegate.recentObject removeAllObjects];
//        [appDelegate.recentObject addObjectsFromArray:array];
    }
    else 
    {
        SMLog(@"%@",error);
        [error release];
    }
}

- (void) saveSwitchView:(NSString *)currentProcessId forObject:(NSString *)objectAPIName
{
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    // SWITCH_VIEW_LAYOUTS_PLIST
    NSString * rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * plistPath = [rootPath stringByAppendingPathComponent:SWITCH_VIEW_LAYOUTS_PLIST];
    
    if (appDelegate.switchViewLayouts == nil)
        appDelegate.switchViewLayouts = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
    
    if (![currentProcessId isKindOfClass:[NSString class]] && ![objectAPIName isKindOfClass:[NSString class]])
        return;
    
    [appDelegate.switchViewLayouts setValue:currentProcessId forKey:objectAPIName];

    [appDelegate.switchViewLayouts writeToFile:plistPath atomically:YES];
}

- (NSMutableDictionary *) getWorkOrderDetails:(INTF_WebServicesDefBindingResponse *)response
{
    NSMutableDictionary * dictionary;
    
    INTF_WebServicesDefServiceSvc_INTF_Get_WorkOrderMapView_WSResponse * wsResponse = [[response bodyParts] objectAtIndex:0];
    
    INTF_WebServicesDefServiceSvc_INTF_Response * workOrderResponse = [wsResponse result];
    
    NSMutableArray * array = [workOrderResponse MapStringMap];
    
    dictionary = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
    for (int i = 0; i < [array count]; i++)
    {
        INTF_WebServicesDefServiceSvc_INTF_MapStringMap * mapStringMap = [array objectAtIndex:i];
        
        NSMutableArray * valueMap = [mapStringMap valueMap];
        [dictionary setValue:mapStringMap.key forKey:KEY];
        for (int j = 0; j < [valueMap count]; j++)
        {
            [dictionary setValue:([[valueMap objectAtIndex:j] value] != nil)?[[valueMap objectAtIndex:j] value]:@"" forKey:[[valueMap objectAtIndex:j] key]];
        }
    }
    SMLog(@"%@", dictionary);
    didGetWorkOder = TRUE;
    return dictionary;
}

- (void) getWeekdates:(NSString *)date
{
//    NSMutableArray *bounds = [NSMutableArray arrayWithCapacity:2];
	NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    if ([date length] > 10)
        date = [date substringToIndex:10];
    NSDate * today = [dateFormatter dateFromString:date];
	
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	
	// Get the weekday component of the current date
	NSDateComponents *weekdayComponents = [gregorian components:NSWeekdayCalendarUnit fromDate:today];
	NSUInteger weekday =  [weekdayComponents weekday]-1;
	if (weekday < 1)
		weekday = 7; //Sunday is the last day in our scheme

	NSDateComponents *componentsToSubtract = [[[NSDateComponents alloc] init] autorelease];
	[componentsToSubtract setDay: 0 - (weekday - 2)];
	
	NSDate *beginningOfWeek = [gregorian dateByAddingComponents:componentsToSubtract toDate:today options:0];
	
	[componentsToSubtract setDay:8-weekday];
	NSDate *endOfWeek = [gregorian dateByAddingComponents:componentsToSubtract toDate:today options:0];
	
	NSDateComponents *minus_onesec = [[[NSDateComponents alloc] init] autorelease];
	[minus_onesec setSecond:-1];
	endOfWeek = [gregorian dateByAddingComponents:minus_onesec toDate:endOfWeek options:0];
    
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    startDate = [[dateFormatter stringFromDate:beginningOfWeek] retain];
//	[bounds insertObject:startDate atIndex:0];
    endDate = [[dateFormatter stringFromDate:endOfWeek] retain];
//	[bounds insertObject:endDate atIndex:1];

//    SMLog(@"%@", bounds);

    if (currentDateRange != nil)
        [currentDateRange release];
    currentDateRange = [[NSMutableArray arrayWithObjects:startDate, endDate, nil] retain];
}

- (void) didFinishGetEventsWithFault:(SOAPFault *)sFault
{
    if ([delegate respondsToSelector:@selector(didFinishGetEvents)])
        [delegate didFinishGetEvents];
    if (sFault != nil)
        [delegate didFinishWithError:sFault];
}

@end

@implementation NSString (Helper)
- (BOOL)Contains:(NSString *)string
{
	NSRange range = [self rangeOfString:string];
	if( NSEqualRanges(range, NSMakeRange(NSNotFound, 0)) )
	{
		return NO;
	}
	return YES;
}
@end


@implementation ZKServerSwitchboard (Private1)

- (void)doCheckSession
{
	NSLog(@"Session Expiry : %@", sessionExpiry);
    if ([sessionExpiry timeIntervalSinceNow] < 5)
    {
        didSessionResume = NO;
        iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
        [self loginWithUsername:appDelegate.username password:appDelegate.password target:self selector:@selector(sessionDidResume:error:)];
        while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, FALSE))
        {
            SMLog(@"WSInterface doCheckSession in while loop");
            if (didSessionResume)
                break;
        }
    }
    else    //shrinivas
    {
        isSessionInavalid = NO;
    }
}

- (void)sessionDidResume:(ZKLoginResult *)loginResult error:(NSError *)error
{
    iServiceAppDelegate * appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
    NSString * serverUrl = [loginResult serverUrl];
    NSArray * array = [serverUrl pathComponents];
    NSString * server = [NSString stringWithFormat:@"%@//%@", [array objectAtIndex:0], [array objectAtIndex:1]];
    if (error)
    {
        SMLog(@"There was an error resuming the session: %@", error);
		NSUserDefaults * userdefaults = [NSUserDefaults standardUserDefaults];
		NSString * url = [userdefaults objectForKey:SERVERURL];
		if (![url Contains:@"null"])
			appDelegate.currentServerUrl = server;
        didSessionResume = YES;
        isSessionInavalid = YES;
    }
    else {
        SMLog(@"Session Resumed Successfully!");
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		if (![server Contains:@"null"])
		{
			[userDefaults setObject:server forKey:SERVERURL];
			appDelegate.currentServerUrl = server;
			[userDefaults synchronize];
		}
        didSessionResume = YES;
        isSessionInavalid = NO;
    }
}

// Implementing this method requires the method to be called from the following ZKSForce method
// - (void) connection: (NSURLConnection *)connection didFailWithError: (NSError *)error
- (void) internetConnectionFailed
{
//    iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
//    [appDelegate isInternetConnectionAvailable] = NO;
}

@end

@implementation INTF_WebServicesDefBinding (WSInterface)

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    iServiceAppDelegate * appDelegate_ = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
    //appDelegate_.isInternetConnectionAvailable = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:kInternetConnectionChanged object:[NSNumber numberWithInt:0] userInfo:nil];
}

@end

@implementation INTF_WebServicesDefBindingResponse (WSInterface)

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    iServiceAppDelegate * appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
    //[appDelegate isInternetConnectionAvailable] = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:kInternetConnectionChanged object:[NSNumber numberWithInt:0] userInfo:nil];
}


@end
