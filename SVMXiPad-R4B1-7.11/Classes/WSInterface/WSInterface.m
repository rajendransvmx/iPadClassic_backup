//
//  WSInterface.m
//  project
//
//  Created by Developer on 5/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WSInterface.h"
#import "iServiceAppDelegate.h"
extern void SVMXLog(NSString *format, ...);
@implementation WSInterface

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

@synthesize didGetRecordTypeId;

@synthesize isLoggedIn;

#define VALUE 100
- (id) init
{
    self = [super init];
    
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    didGetAccountHistory = NO;
    didGetProductHistory = NO;
    didRescheduleEvent = NO;
    isLoggedIn = NO;
    
    
    if (self)
    {
    }
    
    return self;
}

#pragma mark - ServiceMax Version check method
- (void) getSvmxVersion
{    
    [INTF_WebServicesDefServiceSvc initialize];
    INTF_WebServicesDefServiceSvc_SessionHeader * session = [[[INTF_WebServicesDefServiceSvc_SessionHeader alloc] init] autorelease];
    session.sessionId = [appDelegate.loginResult sessionId];
    
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

    [[ZKServerSwitchboard switchboard] doCheckSession];
    [binding SVMX_GetSvmxVersionAsyncUsingParameters:getVersion
                                       SessionHeader:session
                                         CallOptions:callOptions
                                     DebuggingHeader:debuggingHeader
                          AllowFieldTruncationHeader:allowFieldTruncationHeader
                                            delegate:self];
    
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
    
    [[ZKServerSwitchboard switchboard] doCheckSession];
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
    [[ZKServerSwitchboard switchboard] doCheckSession];
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
    
    [[ZKServerSwitchboard switchboard] doCheckSession];
     binding.logXMLInOut = YES;
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
    
    [[ZKServerSwitchboard switchboard] doCheckSession];
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
    
    [[ZKServerSwitchboard switchboard] doCheckSession];
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
    detailPage.SVMXC__DataType__c = @"reference";
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
    
    [[ZKServerSwitchboard switchboard] doCheckSession];
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
    
    [[ZKServerSwitchboard switchboard] doCheckSession];
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
    
    [[ZKServerSwitchboard switchboard] doCheckSession];
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
    
    [[ZKServerSwitchboard switchboard] doCheckSession];
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
    
    [[ZKServerSwitchboard switchboard] doCheckSession];
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
    NSString * defaultLookupColumn = [namedSearchHdr SVMXC__Default_Lookup_Column__c];
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
    NSMutableDictionary * _dict = [[NSMutableDictionary dictionaryWithObjects:_objects forKeys:_keys] retain];
    
    return _dict;
}

- (void) getAccountHistoryForWorkOrderId:(NSString *)woId
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
    
    [[ZKServerSwitchboard switchboard] doCheckSession];
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
    sessionHeader.sessionId = [appDelegate.loginResult sessionId];
    
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
    
    [[ZKServerSwitchboard switchboard] doCheckSession];
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
    
    [[ZKServerSwitchboard switchboard] doCheckSession];
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

    [[ZKServerSwitchboard switchboard] doCheckSession];
    [binding SFM_SaveTargetRecords_WSAsyncUsingParameters:saveTargetRecords
                                            SessionHeader:sessionHeader
                                              CallOptions:callOptions
                                          DebuggingHeader:debuggingHeader
                               AllowFieldTruncationHeader:allowFieldTruncationHeader
                                                 delegate:self];
}

// Thoons Method
- (void) callSFMEvent:(NSDictionary *)dictionary
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
    sessionHeader.sessionId = [appDelegate.loginResult sessionId];
    
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
    
    [[ZKServerSwitchboard switchboard] doCheckSession];
    [binding INTF_PREQ_GetPrice_WSAsyncUsingParameters:getThoonsEvent
                                         SessionHeader:sessionHeader
                                           CallOptions:callOptions
                                       DebuggingHeader:debuggingHeader
                            AllowFieldTruncationHeader:allowFieldTruncationHeader
                                              delegate:self];
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
   
    [[ZKServerSwitchboard switchboard] doCheckSession];
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

#pragma mark - INTF_WebServicesDefBindingOperation Delegate Method
- (void) operation:(INTF_WebServicesDefBindingOperation *)operation completedWithResponse:(INTF_WebServicesDefBindingResponse *)response;
{
    int ret;
    SMLog( @"OPERATION COMPLETED RESPONSE");
    
    if (!appDelegate.isInternetConnectionAvailable)
    {
        if (appDelegate.SFMPage != nil)
        {
            [appDelegate.SFMPage release];
            appDelegate.SFMPage = nil;
        }
        return;
    }
    
    ret = [[response.bodyParts objectAtIndex:0] isKindOfClass:[SOAPFault class]];
    if (ret)
    {
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
            SMLog (@"tagsDictionary %@", tagsDictionary);
        }
        
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

        responseError = 1;
//        if (isLoggedIn)
            [self didFinishGetEventsWithFault:sFault];
        return;
    }

    if ([response.error isKindOfClass:[NSURLErrorDomain class]])
    {
//        appDelegate.isInternetConnectionAvailable = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:kInternetConnectionChanged object:[NSNumber numberWithInt:0] userInfo:nil];
    }

    SMLog(@"response %@",response);
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
        SMLog(@"INTF_WebServicesDefBinding_INTF_AddRecords_WS %@",response);
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
            
            if (!appDelegate.isInternetConnectionAvailable)
            {
                [appDelegate displayNoInternetAvailable];
                return;
            }
            
            appDelegate.createObjectContext = [self getSaveTargetRecords:response];
            
            while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, 1, NO))
            {
                SMLog(@"WSInterface operation in while loop");
                if (!appDelegate.isInternetConnectionAvailable)
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
                }
                SMLog(@"SaveResponse");
                if (didGetProcessId)
                {
                    didGetProcessId = FALSE;
                    break;
                }
            }

            [appDelegate.createObjectContext setValue:appDelegate.currentProcessID forKey:PROCESSID];
            SMLog(@"appDelegate.createObjectContext %@", appDelegate.createObjectContext); 
        }
        
        if ([[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"SOURCETOTARGET"])
        {
           //sahana 16th Sept
            didGetProcessId = FALSE;
            // Sahana - 5th Aug, 2011
            
            appDelegate.createObjectContext = [self getSaveTargetRecords:response];
            while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, 1, NO))
            {
                SMLog(@"WSInterface operation in while loop");
                if (!appDelegate.isInternetConnectionAvailable)
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
                }
                SMLog(@"SaveResponse");
                if (didGetProcessId)
                {
                    didGetProcessId = FALSE;
                    break;
                }
            }
            [appDelegate.createObjectContext setValue:appDelegate.currentProcessID forKey:PROCESSID];
            SMLog(@"appDelegate.createObjectContext %@", appDelegate.createObjectContext); 

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
        SMLog(@"INTF_WebServicesDefBinding_INTF_Get_View_Layouts_WS %@", viewLayoutsArray);
        [viewLayoutsArray retain];
        NSDate *date = [NSDate date];
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
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
        NSString * HideSave = @"";
        NSString * HideQuickSave = @"";
        
        INTF_WebServicesDefServiceSvc_INTF_PageHeader * header = nil;
        NSMutableArray * details = nil;
        
        // NSMutableArray * keys = [NSMutableArray arrayWithObjects:gWSRESPONSE, gRESULT, gPAGE, gHEADER, gDETAILS, nil];
        NSMutableArray * keys = [NSMutableArray arrayWithObjects:gPAGE, gHEADER, gDETAILS, gPROCESSTYPE, gRESPONSE,gHideSave,gHideQuickSave, nil];
        
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
            NSMutableArray * mapstring = [response MapStringMap];
            for(int j = 0 ; j<[mapstring count];j++)
            {
                INTF_WebServicesDefServiceSvc_INTF_MapStringMap * map = [mapstring objectAtIndex:j];
                NSMutableArray * valueMap = map.valueMap;
                for(int k = 0 ; k< [valueMap count]; k++)
                {
                    INTF_WebServicesDefServiceSvc_INTF_StringMap * strmap =[valueMap objectAtIndex:k];
                    NSString * key = strmap.key;
                    SMLog(@"strmap %@", strmap.key);
                    NSString * value = strmap.value;
                    SMLog(@"strmap %@", strmap.value);
                    if([key isEqualToString:@"HideSave"])
                    {
                        HideSave = value;
                    }
                    if([key isEqualToString:@"HideQuickSave"])
                    {
                        HideQuickSave = value;
                    }
                }
            }
            SMLog(@"Save = %@ Quick Save = %@",HideSave,HideQuickSave);
            for (int i=0;i<[stringmaps count];i++)
            {
                INTF_WebServicesDefServiceSvc_INTF_StringMap *stringmap = [stringmaps objectAtIndex:i];
                if ([stringmap.key isEqualToString:gPROCESSTYPE])
                    process_type = stringmap.value;
            }

            if (bodyParts == nil)
                bodyParts = [[NSMutableArray alloc] initWithCapacity:0];
            
            NSMutableArray * objects = [NSMutableArray arrayWithObjects:page, header, details, process_type, response,HideSave,HideQuickSave, nil];
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
        SMLog(@"accountHistory %@", accountHistory);
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
        SMLog(@"productHistory %@", productHistory);
        didGetProductHistory = YES;
    }
    
    if ([operation isKindOfClass:[INTF_WebServicesDefBinding_INTF_PREQ_GetPrice_WS class]])
    {
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
                            NSMutableArray * detail_sobject = [detail objectForKey:gDETAIL_SOBJECT_ARRAY];
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
                                        [detail_sobject addObject:@""];
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
                        if([DictaliasName isEqualToString:aliasName])
                        {
                        
                            NSMutableArray * detail_values_array = [detail objectForKey:gDETAILS_VALUES_ARRAY];
                            NSMutableArray * details_record_ids = [detail objectForKey:gDETAIL_VALUES_RECORD_ID];
                            NSMutableArray * detail_sobject = [detail objectForKey:gDETAIL_SOBJECT_ARRAY];
                            
                            BOOL record_exist = FALSE;
                            for(int p = 0; p < [details_record_ids count];p++)
                            {
                                NSString * rec_id = [details_record_ids objectAtIndex:p];
                                if((Record_Id != nil) && (rec_id != nil))
                                {
                                    
                                    SMLog(@"  Record_Id --> %@  rec_id --> %@",Record_Id , rec_id);
                                    if([Record_Id isEqualToString:rec_id])
                                    {
                                        NSMutableArray * detailValuesArray = [detail_values_array objectAtIndex:p];
                                                                               NSArray * allkeys = [bubbleInfoDict allKeys];
                                        for(int q = 0 ; q < [allkeys count]; q++)
                                        {
                                            BOOL flag = FALSE;
                                            NSString * bubbleInfoDictKey = [allkeys objectAtIndex:q];
                                            
                                            
                                            for(int q = 0; q < [detailValuesArray count]; q++)
                                            {
                                                NSMutableDictionary * keyValueDict =[detailValuesArray objectAtIndex:q];
                                                NSString * api_name = [keyValueDict objectForKey:gVALUE_FIELD_API_NAME];
                                                //collect all keys from bubbleinfo dict 
                                                SMLog(@"bubble info dict key %@ api_name %@ ", bubbleInfoDictKey , api_name);
                                                if([bubbleInfoDictKey isEqualToString:api_name])
                                                {
                                                    flag = TRUE;
                                                    
                                                    NSMutableArray * strmap =[bubbleInfoDict objectForKey:bubbleInfoDictKey];
                                                    if([strmap count] > 0)
                                                    {
                                                        //retrieving key from dict 
                                                        NSMutableDictionary * key_dict = [strmap objectAtIndex:0];
                                                        NSString * key = [key_dict objectForKey:@"key"];
                                                        //retrieving value from dict
                                                        NSMutableDictionary * key_dict1 = [strmap objectAtIndex:1];
                                                        NSString * value = [key_dict1 objectForKey:@"value"];
                                                        
                                                        [keyValueDict setValue:key forKey:gVALUE_FIELD_VALUE_KEY];
                                                        [keyValueDict setValue:value forKey:gVALUE_FIELD_VALUE_VALUE];
                                                    }

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
                                    
                                    [detail_values_array addObject:detailValuesArray];
                                    [details_record_ids addObject:Record_Id];
                                    [detail_sobject addObject:@""];
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
            NSMutableArray * detail_sobject = nil;
            
            for (int x=0;x<[details count];x++) //parts, labor, expense for instance
            {
                NSMutableDictionary * detail = [details objectAtIndex:x];
                NSString * DictaliasName = [detail objectForKey:gDETAIL_OBJECT_ALIAS_NAME]; 
                if([DictaliasName isEqualToString:aliasName])
                {
                    detail_values_array = [detail objectForKey:gDETAILS_VALUES_ARRAY];
                    details_record_ids = [detail objectForKey:gDETAIL_VALUES_RECORD_ID];
                    deleted_details_array = [detail objectForKey:gDETAIL_DELETED_RECORDS];
                    detail_sobject = [detail objectForKey:gDETAIL_SOBJECT_ARRAY];
                }
            }
            
            NSMutableArray * records_to_be_deleted = [[NSMutableArray alloc] initWithCapacity:0];
            
            for(int y = 0 ; y < [details_record_ids count]; y++)
            {
                NSString * id_ = [details_record_ids objectAtIndex:y];
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
                            if([value isEqualToString:id_])
                            {
                                isrecord_exist = TRUE;                        
                            }
                        
                            
                        }
                    }
                    
                    if(!isrecord_exist)
                    {
                        /*[deleted_details_array  addObject:id_];
                        [detail_values_array removeObjectAtIndex:y];
                        [details_record_ids removeObjectAtIndex:y];
                        [detail_sobject removeObjectAtIndex:y];*/
                        
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
                        [detail_sobject removeObjectAtIndex:y];
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
                                /* [detail_values_array removeObjectAtIndex:q];
                                 [details_record_ids removeObjectAtIndex:q];
                                 [detail_sobject removeObjectAtIndex:q];*/
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
                                [detail_sobject removeObjectAtIndex:q];
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
                      @"Id",
                      @"CreatedDate",
                      @"Name",
                      @"OwnerId",
                      @"SVMXC__Problem_Description__c",
                      @"SVMXC__Top_Level__c",
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
                                        (serviceOrder.Id_ != nil)?serviceOrder.Id_:@"",
                                        (serviceOrder.CreatedDate != nil)?serviceOrder.CreatedDate:@"",
                                        (serviceOrder.Name != nil)?serviceOrder.Name:@"",
                                        (serviceOrder.OwnerId != nil)?serviceOrder.OwnerId:@"",
                                        (serviceOrder.SVMXC__Problem_Description__c != nil)?serviceOrder.SVMXC__Problem_Description__c:@"",
                                        (serviceOrder.SVMXC__Top_Level__c != nil)?serviceOrder.SVMXC__Top_Level__c:@"",
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
                      @"Id",
                      @"CreatedDate",
                      @"Name",
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
                                    (serviceOrder.Id_ != nil)?serviceOrder.Id_:@"",
                                    (serviceOrder.CreatedDate != nil)?serviceOrder.CreatedDate:@"",
                                    (serviceOrder.Name != nil)?serviceOrder.Name:@"",
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
    SMLog(@"lookupDetails %@", lookupDetails);
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
    SMLog(@"result %@", result);
    
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
}

- (void) getDictionaryFromPageLayout:(NSMutableDictionary *)bodyParts withDescribedObjects:(NSMutableArray *)describeObjects
{
    NSMutableDictionary * headerDataDict = nil, * detailsDataDict = nil;
    NSString * process_type = [bodyParts objectForKey:gPROCESSTYPE];
    
    NSString * hideSave = [bodyParts objectForKey:gHideSave];
    NSString * hidequickSave = [bodyParts objectForKey:gHideQuickSave];
    INTF_WebServicesDefServiceSvc_INTF_MapStringMap * hide_save = [bodyParts objectForKey:@"MapStringMap"];
   // NSString * HideQuickSave = [bodyParts objectForKey:@"HideQuickSave"];
    SMLog(@"hide_save %@ ",hide_save );
    
    
    INTF_WebServicesDefServiceSvc_INTF_PageUI * page = [bodyParts objectForKey:gPAGE];
    INTF_WebServicesDefServiceSvc_INTF_PageHeader * hdr = [bodyParts objectForKey:gHEADER];
    INTF_WebServicesDefServiceSvc_INTF_Response * response = [bodyParts objectForKey:gRESPONSE];
    NSMutableArray * dtl = [bodyParts objectForKey:gDETAILS];

    NSMutableDictionary * hdrData = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSMutableArray * hdrButtons = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray * hdrSections = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray * allFields = [[NSMutableArray alloc] initWithCapacity:0];
    
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
                                         resolution,
                                         restoration,
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
                                          (detail_header_info!=nil)?detail_header_info:@"",
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
            for(int y=0; y<[detailDataArray count]-1; y++)
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
    
    NSMutableArray * keys = [NSMutableArray arrayWithObjects:gPROCESS_TITLE, gHEADER, gDETAILS,gPROCESSTYPE,gHideSave,gHideQuickSave, nil];
    NSMutableArray * objects = [NSMutableArray arrayWithObjects:(page.processTitle != nil)?page.processTitle:@"",
                         headerDataDict,
                         detailDataArray,
                        (process_type != nil)?process_type:@"",
                        hideSave,
                                hidequickSave,
                         nil];
    
    NSMutableDictionary * pageLayout = [[NSMutableDictionary dictionaryWithObjects:objects forKeys:keys] retain];
    SMLog(@"pageLayout %@", pageLayout);
    
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
    if ([sfmPageObjectName isEqualToString:@"SVMXC__SERVICE_ORDER__C"])
    {
        [self getProductHistoryForWorkOrderId:appDelegate.sfmPageController.recordId];
        [self getAccountHistoryForWorkOrderId:appDelegate.sfmPageController.recordId];
        
        while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, 1, NO))
        {
            if (!appDelegate.isInternetConnectionAvailable)
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

- (INTF_WebServicesDefServiceSvc_INTF_TargetRecord *) getTargetRecordsFromSFMPage:(NSDictionary *)sfmpage
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
            NSMutableArray *child_record_fields = [details_values objectAtIndex:j];
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
                
                //sahana  adding sequesnce number to the detail_value_array
                
                NSMutableArray * keys = [NSMutableArray arrayWithObjects:
                                         gVALUE_FIELD_API_NAME,
                                         gVALUE_FIELD_VALUE_KEY,
                                         gVALUE_FIELD_VALUE_VALUE,
                                         nil];
                
                NSMutableArray * objects = [NSMutableArray arrayWithObjects:gDETAIL_SEQUENCENO_GETPRICE, string, string, nil];
                NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:objects forKeys:keys];
                
                [child_record_fields addObject:dict];
                
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
    SMLog(@"array %@", array);
    
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
    
    SMLog(@"_tagsDictionary %@", _tagsDictionary);
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
    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, 1, FALSE))
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
    SMLog(@"appDelegate.objectLabel_array %@", appDelegate.objectLabel_array);
    
    
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
    
    SMLog(@"appDelegate.objectLabelName_array %@", appDelegate.objectLabelName_array);
    
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
    
    SMLog(@"appDelegate.objectLabelName_array %@", appDelegate.objectLabelName_array);

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
            
            SMLog(@"getViewLayoutArray dict = %@", dict);
            [array addObject:dict];
        }
    }
    SMLog(@"getViewLayoutArray array %@", array);
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
    appDelegate.objectLabel_array = [objectNames retain];

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
    
    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, 1, FALSE))
    {
        SMLog(@"WSInterface getNameFieldForCreateProcess in while loop");
        if (!appDelegate.isInternetConnectionAvailable)
        {
            didGetProcessId = TRUE;
            didGetNameField = TRUE;
            [appDelegate displayNoInternetAvailable];
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
    
    SMLog(@"array %@", array);
    
    if ([array count] > 0)
    {
        ZKSObject * obj = [array objectAtIndex:0];
        dict = [obj fields]; 
        str = [dict valueForKey:@"Name"];
        SMLog(@"dict= %@", dict);
        SMLog(@"str %@",str);
    }
    
    [appDelegate.createObjectContext setObject:(str != nil)?str:@"" forKey:NAME_FIELD];
    SMLog(@"appDelegate.createObjectContext= %@", appDelegate.createObjectContext);
    
    appDelegate.newProcessId = nil;
    
    NSString * objectName = [appDelegate.createObjectContext objectForKey:OBJECT_NAME];
    for (int j = 0; j < [appDelegate.wsInterface.viewLayoutsArray count]; j++)
    {
        NSDictionary * viewLayoutDict = [appDelegate.wsInterface.viewLayoutsArray objectAtIndex:j];
        NSString * objName = [viewLayoutDict objectForKey:VIEW_OBJECTNAME];
        if ([objName isEqualToString:objectName])
        {
            [appDelegate.createObjectContext setValue:[viewLayoutDict objectForKey:@"SVMXC__ProcessID__c"] forKey:PROCESSID];
            appDelegate.newProcessId = [viewLayoutDict objectForKey:@"SVMXC__ProcessID__c"];
            SMLog(@"[didGetNameField] newProcessID = %@",appDelegate.newProcessId);
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
        SMLog(@"array= %@", array);
        
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
    SMLog(@"dictionary= %@", dictionary);
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
    if ([sessionExpiry timeIntervalSinceNow] < 5)
    {
        didSessionResume = NO;
        [self loginWithUsername:_username password:_password target:self selector:@selector(sessionDidResume:error:)];
        while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, 1, FALSE))
        {
            SMLog(@"WSInterface doCheckSession in while loop");
            if (didSessionResume)
                break;
        }
    }
}

- (void)sessionDidResume:(ZKLoginResult *)loginResult error:(NSError *)error
{
    if (error)
    {
        SMLog(@"There was an error resuming the session: %@", error);
        didSessionResume = YES;
    }
    else {
        SMLog(@"Session Resumed Successfully!");
        didSessionResume = YES;
    }
}

// Implementing this method requires the method to be called from the following ZKSForce method
// - (void) connection: (NSURLConnection *)connection didFailWithError: (NSError *)error
- (void) internetConnectionFailed
{
    iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
//    appDelegate.isInternetConnectionAvailable = NO;
}

@end

@implementation INTF_WebServicesDefBinding (WSInterface)

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    iServiceAppDelegate * appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
//    appDelegate.isInternetConnectionAvailable = NO;
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
//    appDelegate.isInternetConnectionAvailable = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:kInternetConnectionChanged object:[NSNumber numberWithInt:0] userInfo:nil];
}

@end
