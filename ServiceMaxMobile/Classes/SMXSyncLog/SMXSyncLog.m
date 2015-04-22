//
//  SMXSyncLog.m
//  iService
//
//  Created by Siva Manne on 08/07/13.
//
//

#import "SMXSyncLog.h"
#import "ZKServerSwitchboard.h"
#import "AppDelegate.h"
#import "SBJsonWriter.h"
#include <sqlite3.h>

NSString * const kDBBeginTransaction = @"BEGIN TRANSACTION";
NSString * const kDBEndTransaction = @"END TRANSACTION";
#define kStopPushLogNotification        @"STOP_PUSH_LOG_NOTIFICATION"
#define kNumberOfRecordsToSendPerBatch  @"2000"
@interface SMXSyncLog()
{
    BOOL didEnterBackground;
    BOOL shouldStopSendingLogs;
}

@end
@implementation SMXSyncLog
- (id) init
{
    self = [super init];
    if( !self ) return nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:)
                                                 name:kStopPushLogNotification object:nil];
    didEnterBackground = FALSE;
    shouldStopSendingLogs = FALSE;
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)handleNotification:(NSNotification *)notification
{
    if([[notification name] isEqualToString:UIApplicationDidEnterBackgroundNotification])
    {
        didEnterBackground = TRUE;
    }
    else if([[notification name] isEqualToString:UIApplicationWillEnterForegroundNotification])
    {
        didEnterBackground = FALSE;
    }
    else if([[notification name] isEqualToString:kStopPushLogNotification])
    {
        shouldStopSendingLogs = TRUE;
    }
}

- (void) sendLogsToServer
{
    responseReceived = NO;
    [[ZKServerSwitchboard switchboard] doCheckSession];
    NSString *progressStatus = [appDelegate.wsInterface.tagsDictionary objectForKey:Push_Log_Status_In_Progress];
    NSString *successStatus = [appDelegate.wsInterface.tagsDictionary objectForKey:Push_Log_Status_Success];
    NSString *failedStatus = [appDelegate.wsInterface.tagsDictionary objectForKey:Push_Log_Status_Failed];
    
    [self updateSyncPlistForKey:PUSH_LOG_LABEL withValue:progressStatus];
    [self updateSyncPlistForKey:PUSH_LOG_LABEL_COLOR withValue:@""];
    if([appDelegate.locationPingSettingTimer isValid])
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.locationPingSettingTimer];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    appDelegate.pushLogRunning = TRUE;
    [self syncLogsToServer];
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
        if (![appDelegate isInternetConnectionAvailable] || appDelegate.connection_error)
        {
            [self updateSyncPlistForKey:PUSH_LOG_LABEL withValue:[self getFormattedDate]];
            [self updateSyncPlistForKey:PUSH_LOG_LABEL_COLOR withValue:@"red"];
            break;
        }
        if(responseReceived)
            break;
        if(didEnterBackground)
        {
            [self updateSyncPlistForKey:PUSH_LOG_LABEL withValue:[self getFormattedDate]];
            [self updateSyncPlistForKey:PUSH_LOG_LABEL_COLOR withValue:@"red"];
            break;
        }
        if(shouldStopSendingLogs)
        {
            [self updateSyncPlistForKey:PUSH_LOG_LABEL withValue:[self getFormattedDate]];
            [self updateSyncPlistForKey:PUSH_LOG_LABEL_COLOR withValue:@"red"];
            break;
        }
    }
    appDelegate.pushLogRunning = FALSE;
    [self performSelectorOnMainThread:@selector(scheduletimer) withObject:nil waitUntilDone:NO];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}
- (void) scheduletimer
{
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate startBackgroundThreadForLocationServiceSettings];
}

- (void) syncLogsToServer
{
    @try
    {
        [INTF_WebServicesDefServiceSvc initialize];
        AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        INTF_WebServicesDefServiceSvc_SessionHeader * sessionHeader = [[[INTF_WebServicesDefServiceSvc_SessionHeader alloc] init] autorelease];
        sessionHeader.sessionId = appDelegate.session_Id;
        
        INTF_WebServicesDefServiceSvc_CallOptions * callOptions = [[[INTF_WebServicesDefServiceSvc_CallOptions alloc] init] autorelease];
        callOptions.client = nil;
        
        INTF_WebServicesDefServiceSvc_DebuggingHeader * debuggingHeader = [[[INTF_WebServicesDefServiceSvc_DebuggingHeader alloc] init] autorelease];
        debuggingHeader.debugLevel = 0;
        
        INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader * allowFieldTruncationHeader = [[[INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader alloc] init] autorelease];
        allowFieldTruncationHeader.allowFieldTruncation = NO;
        
        INTF_WebServicesDefBinding * binding = [INTF_WebServicesDefServiceSvc INTF_WebServicesDefBindingWithServer:appDelegate.currentServerUrl];
        
        INTF_WebServicesDefServiceSvc_INTF_DataSync_WS  * datasync = [[[INTF_WebServicesDefServiceSvc_INTF_DataSync_WS alloc] init] autorelease];
        
        INTF_WebServicesDefServiceSvc_INTF_SFMRequest * sfmRequest = [[[INTF_WebServicesDefServiceSvc_INTF_SFMRequest alloc] init] autorelease];
        sfmRequest.eventName = @"MOBILE_CLIENT_LOGS";
        sfmRequest.eventType = @"SYNC";
        sfmRequest.userId = [appDelegate.loginResult userId];
        sfmRequest.groupId = [[appDelegate.loginResult userInfo] organizationId];
        sfmRequest.profileId = [[appDelegate.loginResult userInfo] profileId];
        sfmRequest.value = [AppDelegate GetUUID];
        
        INTF_WebServicesDefServiceSvc_SVMXMap  * SVMXCmap = [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
        
        SVMXCmap.key = @"LOGS" ;

        SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
        NSArray *logRecords = [self getLogRecords];
        if([logRecords count] == 0)
        {
            responseReceived = YES;
            [self updateSyncPlistForKey:PUSH_LOG_LABEL withValue:[self getFormattedDate]];
            //Fix Defect 009041: The tapping on Push Logs when there are no records in the db renders the Status in black color.
            [self updateSyncPlistForKey:PUSH_LOG_LABEL_COLOR withValue:@"green"];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            return;
        }
        NSMutableArray *mLogsArray = [[NSMutableArray alloc] init];
        NSDictionary *typeDict = [NSDictionary dictionaryWithObject:@"SVMXC__SVMX_Job_Logs__c" forKey:@"type"];
        for(NSDictionary *dict in logRecords)
        {
            NSArray *keys = [dict allKeys];
            NSMutableDictionary *mLogDict = [[NSMutableDictionary alloc] init];
            [mLogDict setObject:typeDict forKey:@"attributes"];
            for(NSString *key in keys)
                [mLogDict setObject:[dict objectForKey:key] forKey:key];
            [mLogsArray addObject:mLogDict];
            [mLogDict release];
            
        }
        NSString * json_record= [ jsonWriter stringWithObject:mLogsArray];
        [mLogsArray release];
        [jsonWriter release];
        SVMXCmap.value = json_record;
        [sfmRequest.valueMap addObject:SVMXCmap];
        [SVMXCmap release];      

        INTF_WebServicesDefServiceSvc_SVMXClient  * SVMXC_client =  [appDelegate getSVMXClientObject];
        [sfmRequest addClientInfo:SVMXC_client];
        [datasync setRequest:sfmRequest];
        
        
        binding.logXMLInOut = [appDelegate enableLogs];
        
        [binding INTF_DataSync_WSAsyncUsingParameters:datasync
                                        SessionHeader:sessionHeader
                                          CallOptions:callOptions
                                      DebuggingHeader:debuggingHeader
                           AllowFieldTruncationHeader:allowFieldTruncationHeader delegate:self];

        
    }
    @catch (NSException *exp)
    {
        NSLog(@"Exception Name WSInterface :dataSyncWithEventName %@",exp.name);
        NSLog(@"Exception Reason WSInterface :dataSyncWithEventName %@",exp.reason);
    }
}
- (void) updateSyncPlistForKey:(NSString *)key withValue:(NSString *)value
{
    @try
    {
        NSString * rootpath_SYNHIST = [appDelegate getAppCustomSubDirectory];
        NSString * plistPath_SYNHIST = [rootpath_SYNHIST stringByAppendingPathComponent:SYNC_HISTORY];
        
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath_SYNHIST];
        NSArray * allkeys= [dict allKeys];
        
        for(NSString *  str in allkeys)
        {
            if([str isEqualToString:key])
            {
                [dict  setObject:value forKey:key];
                break;
            }
        }
        [dict writeToFile:plistPath_SYNHIST atomically:YES];
    }
    @catch (NSException *exp)
    {
        SMLog(kLogLevelError,@"Exception Name SMXSyncLog :updateSyncPlist %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason SMXSyncLog :updateSyncPlist %@",exp.reason);
    }
}
- (NSArray *) getLogRecords
{
    NSArray *columns = [NSArray arrayWithObjects:@"SVMXC__Log_Timestamp__c",@"SVMXC__Log_level__c",@"SVMXC__Log_Context__c",@"SVMXC__Message__c",@"SVMXC__Type__c",@"SVMXC__Profile_Id__c",@"SVMXC__Group_Id__c",@"SVMXC__Log_Category__c",@"SVMXC__Operation__c", nil];
    NSArray *logsArray = [appDelegate.dataBase getAllRecordsFromTable:@"SVMXC__SVMX_Job_Logs__c"
                                                           forColumns:columns
                                                       filterCriteria:@"local_id > 0 order by local_id asc"
                                                                limit:kNumberOfRecordsToSendPerBatch];

    return logsArray;
}
#pragma - INTF delegate Method
- (void) operation:(INTF_WebServicesDefBindingOperation *)operation completedWithResponse:(INTF_WebServicesDefBindingResponse *)response
{
    
    NSException* myException;
    ALERT_VIEW_ERROR var=APPLICATION_ERROR;
    @try {
        if (response.error != nil)
        {
            NSLog(@"Failed to Send the Logs to Server");
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [self updateSyncPlistForKey:PUSH_LOG_LABEL_COLOR withValue:@"red"];
            [self updateSyncPlistForKey:PUSH_LOG_LABEL withValue:[self getFormattedDate]];
            var=SOAP_ERROR;
            appDelegate.connection_error = TRUE;
            NSError *error=response.error;
            NSString *type=error.domain;
            responseReceived = YES;
            if([type Contains:@"NSURLErrorDomain"])
            {
                return;
            }
            NSDictionary *userinfo=error.userInfo;
            NSMutableDictionary *correctiveAction=[[[NSMutableDictionary alloc]init]autorelease];
            [correctiveAction setObject:userinfo forKey:@"userInfo"];
            NSString *des=[error localizedDescription];
            
            myException = [NSException
                           exceptionWithName:type
                           reason:des
                           userInfo:correctiveAction];
            
            var=SOAP_ERROR;
            @throw myException;
            return;
        }
        INTF_WebServicesDefServiceSvc_INTF_DataSync_WSResponse * wsResponse = [response.bodyParts objectAtIndex:0];
        BOOL status = [[wsResponse.result.success stringValue] boolValue];
        if(status)
        {
            NSLog(@"Successfully Sent the Logs to the Server");
            NSString *jobLogTableName = @"SVMXC__SVMX_Job_Logs__c";
            AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            int count = [appDelegate.dataBase getRecordCountFromTable:jobLogTableName];
            if(count > [kNumberOfRecordsToSendPerBatch intValue])
                count = [kNumberOfRecordsToSendPerBatch intValue];
            [appDelegate.dataBase deleteRecordFromTable:jobLogTableName
                                numberOfRecordsToDelete:count
                                           orderByField:@"local_id"];
            count = [appDelegate.dataBase getRecordCountFromTable:jobLogTableName];
            if(count > 0)
            {
                responseReceived = NO;
                [self syncLogsToServer];
            }
            else
            {
                responseReceived = YES;
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                [self updateSyncPlistForKey:PUSH_LOG_LABEL withValue:[self getFormattedDate]];
                [self updateSyncPlistForKey:PUSH_LOG_LABEL_COLOR withValue:@"green"];
            }
        }
        else
        {
            responseReceived = YES;
            NSLog(@"Failed to Send the Logs to Server");
            NSMutableDictionary *Errordict=[[NSMutableDictionary alloc]init];
            NSString *messageType = wsResponse.result.messageType;
            NSString *message = wsResponse.result.message;
            if(message && messageType)
            {
                [Errordict setObject:messageType forKey:@"ExpName"];
                [Errordict setObject:message forKey:@"ExpReason"];
                [Errordict setObject:[NSDictionary dictionaryWithObject:@"" forKey:@"userInfo"] forKey:@"userInfo"];
                [appDelegate CustomizeAletView:nil alertType:var Dict:Errordict exception:nil];
            }
            [Errordict release];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [self updateSyncPlistForKey:PUSH_LOG_LABEL withValue:[self getFormattedDate]];
            [self updateSyncPlistForKey:PUSH_LOG_LABEL_COLOR withValue:@"red"];
        }
    }
    @catch (NSException *exp)
    {
        NSMutableDictionary *Errordict=[[NSMutableDictionary alloc]init];
        [Errordict setObject:exp.name forKey:@"ExpName"];
        [Errordict setObject:exp.reason forKey:@"ExpReason"];
		
		//Code for session handling.
		if ( [exp.reason Contains:@"INVALID_SESSION_ID"] && appDelegate.do_meta_data_sync == ALLOW_META_AND_DATA_SYNC)
		{
			appDelegate.connection_error = FALSE;
			/*Check weather session expiry is due to invalidating the user.  ----> Shrini Fix for defect #7189*/
			if ( ![appDelegate.oauthClient refreshAccessToken:appDelegate.refresh_token isInvokeByBackgroundProcess:NO] )
			{
				appDelegate.isUserInactive = TRUE;
				appDelegate.connection_error = TRUE;
				
				return;
			}
		}
		else
		{
			appDelegate.connection_error = TRUE;
		}
		
        if(exp.userInfo == nil)
        {
            [Errordict setObject:exp forKey:@"userInfo"];
        }
        else
        {
            [Errordict setObject:exp.userInfo forKey:@"userInfo"];
        }
        [appDelegate CustomizeAletView:nil alertType:var Dict:Errordict exception:nil];
        SMLog(kLogLevelError,@"Exception Name WSInterface :operation:completesWithResponse %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason WSInterface :operation:completesWithResponse %@",exp.reason);
    }
    return;
}
- (NSString *) getFormattedDate
{
    NSDate * current_dateTime = [NSDate date];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE, dd MMM yyyy hh:mm:ss a"];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSTimeZoneCalendarUnit;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents * todayDateComponents = [gregorian components:unitFlags fromDate:[NSDate date]];
    [dateFormatter setTimeZone:[todayDateComponents timeZone]];
    NSString * timeStamp = [dateFormatter stringFromDate:current_dateTime];
    [dateFormatter release];
    return timeStamp;
}
@end
