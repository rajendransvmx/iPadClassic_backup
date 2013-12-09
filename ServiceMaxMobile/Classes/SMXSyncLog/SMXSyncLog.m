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

@implementation SMXSyncLog
- (void) sendLogsToServer
{
    responseReceived = NO;
    [self syncLogsToServer];
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
        if (![appDelegate isInternetConnectionAvailable] || appDelegate.connection_error)
            break;
        if(responseReceived)
            break;
    }
}
- (void) syncLogsToServer
{
    @try
    {
        [INTF_WebServicesDefServiceSvc initialize];
        AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
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
        sfmRequest.eventName = @"PUT_INSERT";
        sfmRequest.eventType = @"SYNC";// @"TX_DATA";
        sfmRequest.userId = [appDelegate.loginResult userId];
        sfmRequest.groupId = [[appDelegate.loginResult userInfo] organizationId];
        sfmRequest.profileId = [[appDelegate.loginResult userInfo] profileId];
        sfmRequest.value = [AppDelegate GetUUID];
        
        INTF_WebServicesDefServiceSvc_SVMXMap * SVMXCMap_lastModified =  [[[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init] autorelease];         //sahana30April
        SVMXCMap_lastModified.key = @"SYNC_TIME_STAMP";
        SVMXCMap_lastModified.value = [appDelegate.wsInterface get_SYNCHISTORYTime_ForKey:LAST_INSERT_RESONSE_TIME] == nil ?@"":[appDelegate.wsInterface get_SYNCHISTORYTime_ForKey:LAST_INSERT_RESONSE_TIME];
                
        [sfmRequest.valueMap addObject:SVMXCMap_lastModified];
        
        INTF_WebServicesDefServiceSvc_SVMXMap  * iscallBack = [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
        iscallBack.key = @"IS_CALLBACK";
        iscallBack.value = @"YES";
        
        INTF_WebServicesDefServiceSvc_SVMXMap  * svmxcmap = [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
        
        svmxcmap.key = @"Parent_Object" ;
        svmxcmap.value = @"iPadLog__c";
        INTF_WebServicesDefServiceSvc_SVMXMap  * record_svmxc  = [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
        
        record_svmxc.key = @"Fields";
        record_svmxc.value = @"logTimeStamp__c,logLevel__c,message__c,methodContext__c,NameSpace__c,UserName__c,Client_Information__c";
        SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
        NSArray *records = [self getLogRecords];
        if([records count] == 0)
        {
            SMLog(@"Sync Logs Completed");
            [jsonWriter release];
            [record_svmxc release];
            [iscallBack release];
            [svmxcmap release];
            return;
        }
        for(NSMutableDictionary *dict in records)
        {
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            INTF_WebServicesDefServiceSvc_SVMXMap * testSVMXCMap =  [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
            testSVMXCMap.key = [dict objectForKey:@"local_id__c"];            
            NSString * json_record= [ jsonWriter stringWithObject:dict];
            testSVMXCMap.value = json_record;
            [record_svmxc.valueMap addObject:testSVMXCMap];
            [testSVMXCMap release];
            [pool drain];
        }
        [jsonWriter release];
        [svmxcmap.valueMap addObject:record_svmxc];
        [record_svmxc release];
        [svmxcmap.valueMap addObject:iscallBack];
        [iscallBack release];
        [sfmRequest.valueMap addObject:svmxcmap];        
        [svmxcmap release];      

        INTF_WebServicesDefServiceSvc_SVMXClient  * svmxc_client =  [appDelegate getSVMXClientObject];
        [sfmRequest addClientInfo:svmxc_client];
        [datasync setRequest:sfmRequest];
        
        
        binding.logXMLInOut = YES;
        //binding.logXMLInOut = NO;
        
        [binding INTF_DataSync_WSAsyncUsingParameters:datasync
                                        SessionHeader:sessionHeader
                                          CallOptions:callOptions
                                      DebuggingHeader:debuggingHeader
                           AllowFieldTruncationHeader:allowFieldTruncationHeader delegate:self];

        
    }
    @catch (NSException *exp)
    {
        SMLog(@"Exception Name WSInterface :dataSyncWithEventName %@",exp.name);
        SMLog(@"Exception Reason WSInterface :dataSyncWithEventName %@",exp.reason);
    }
}
- (NSArray *) getLogRecords
{
    sqlite3 * monitoringDB;
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [appDelegate getAppCustomSubDirectory]; // [dirPaths objectAtIndex:0];
    
    // Build the path to the database file
    NSString *databasePath = [[[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"performanceMonitor.sqlite"]] autorelease];
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: databasePath ] == YES)
    {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &monitoringDB) != SQLITE_OK)
        {
            SMLog(@"Unable to Open the Performance Table");
            return nil;
        }
    }
    
    NSArray *columnsArray = [NSArray arrayWithObjects:@"local_id__c",@"logTimeStamp__c",@"logLevel__c",@"logMessage__c",@"logContext__c", nil];
    NSString *columns = [columnsArray componentsJoinedByString:@","];
    
    NSString *query = nil;
    query = [NSString stringWithFormat:@"SELECT %@ FROM %@ LIMIT 1000",columns,@"PerformanceMonitor"];
    //getClientInfoDict
    sqlite3_stmt * statement;
    NSString *clientInfo = [[appDelegate getClientInfoDict] description];
    NSString *groupID = [[appDelegate.loginResult userInfo] organizationId];
    NSString *profileID = [[appDelegate.loginResult userInfo] profileId];
    NSString *userID = [appDelegate.loginResult userId];
    
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:0];
    if (synchronized_sqlite3_prepare_v2(monitoringDB, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            NSMutableDictionary *recordDict = [[NSMutableDictionary alloc] init];
            
            for(int i=0; i<[columnsArray count]; i++)
            {
                char * value = (char *) synchronized_sqlite3_column_text(statement, i);
                if(value != nil)
                {
                    NSString *columnValue = [NSString stringWithUTF8String:value];
                    if(columnValue != nil)
                        [recordDict setObject:columnValue forKey:[columnsArray objectAtIndex:i]];
                    else
                        [recordDict setObject:@"" forKey:[columnsArray objectAtIndex:i]];
                }
                else
                {
                    [recordDict setObject:@"" forKey:[columnsArray objectAtIndex:i]];
                }
            }
            [recordDict setObject:clientInfo forKey:@"Client_Information__c"];
            [recordDict setObject:groupID forKey:@"GroupID__c"];
            [recordDict setObject:profileID forKey:@"ProfileID__c"];
            [recordDict setObject:userID forKey:@"UserID__c"];
            
            [result addObject:recordDict];
            [recordDict release];
            [pool drain];
        }
    }
    synchronized_sqlite3_finalize(statement);
    sqlite3_close(monitoringDB);
    return [result autorelease];
}
#pragma - INTF delegate Method
- (void) operation:(INTF_WebServicesDefBindingOperation *)operation completedWithResponse:(INTF_WebServicesDefBindingResponse *)response
{
    responseReceived = YES;
    INTF_WebServicesDefServiceSvc_INTF_DataSync_WSResponse * wsResponse = [response.bodyParts objectAtIndex:0];
    NSArray * array = [[[wsResponse.result valueMap] objectAtIndex:1] valueMap];
    NSMutableArray *records = [[NSMutableArray alloc] init];
    for(INTF_WebServicesDefServiceSvc_SVMXMap * svmxMap in array)
    {
        [records addObject:svmxMap.key];
    }
    [self deleteRecords:records];
    [records release];
}

- (void) deleteRecords:(NSArray *)records
{
    sqlite3 * monitoringDB;
    NSString *docsDir;
    NSArray *dirPaths;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [appDelegate getAppCustomSubDirectory]; // [dirPaths objectAtIndex:0];
    NSString *databasePath = [[[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"performanceMonitor.sqlite"]] autorelease];
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: databasePath ] == YES)
    {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &monitoringDB) != SQLITE_OK)
        {
            SMLog(@"Unable to Open the Performance Table");
            return;
        }
    }
    
    NSString *query = nil;
    char *error;
    synchronized_sqlite3_exec(monitoringDB, [kDBBeginTransaction UTF8String], NULL, NULL, &error);
    for(NSString *localID in records)
    {
        query = [NSString stringWithFormat:@"DELETE FROM PerformanceMonitor where local_id__c = '%@'",localID];
        synchronized_sqlite3_exec(monitoringDB, [query UTF8String], NULL, NULL, &error);
    }
    synchronized_sqlite3_exec(monitoringDB, [kDBEndTransaction UTF8String], NULL, NULL, &error);
    sqlite3_close(monitoringDB);
    [self sendLogsToServer];
}
@end
