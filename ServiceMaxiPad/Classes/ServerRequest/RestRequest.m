//
//  RestRequest.m
//  ServiceMaxMobile
//
//  Created by Krishna Shanbhag on 01/06/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "RestRequest.h"
#import "CustomerOrgInfo.h"
#import "AppMetaData.h"
#import "AFHTTPRequestOperation.h"
#import "RequestFactory.h"
#import "TimeLogCacheManager.h"
#import "TimeLogParser.h"
#import "TimeLogModel.h"
#import "DateUtil.h"
#import "ServerRequestManager.h"
#import "StringUtil.h"
#import "PerformanceAnalyser.h"
#import "NSData+DDData.h"
#import "SFMCustomActionWebServiceHelper.h"
#import "CacheManager.h"
#import "CacheConstants.h"
#import "CustomActionAfterBeforeXMLRequestHelper.h"
#import "CustomActionXMLRequestHelper.h"
#import "ProductIQManager.h"
#import "SyncManager.h"
#import "PlistManager.h"

@implementation RestRequest
@synthesize dataDictionary;
@synthesize apiType;

#pragma mark - request lifecycle method
/**
 * @name  init
 *
 * @author Krishna Shanbhag
 *
 * @brief Invoke a REST Object
 *
 *
 *  <Long description goes here>
 *  Call this method to initialize the Request object of type REST
 *
 *
 *
 * @return REST Request Instance
 *
 */

-(id)init
{
    if (self = [super init]) {
        self.apiType = @""; //TODO : set as REST
        if (!dataDictionary) {
            self.dataDictionary = [NSMutableDictionary dictionary];
        }
    }
    return self;
}

/**
 * @name - (id)initWithType:(RequestType)requestType
 *
 * @author Shubha
 *
 * @brief init based on type
 *
 *
 *
 * @param  request type, which is a enum
 * @param
 *
 * @return
 *
 */


- (id)initWithType:(RequestType)requestType
{
    self = [super init];
	if (self != nil)
    {
        self.requestType  = requestType;
        self.requestIdentifier =  [AppManager generateUniqueId];
        
        CustomerOrgInfo *customerOrgInfoInstance = [CustomerOrgInfo sharedInstance];
        
        self.groupId     = [customerOrgInfoInstance userOrgId];
        self.oAuthId     = [customerOrgInfoInstance accessToken];
        self.profileId   = [customerOrgInfoInstance profileId];
        self.userId      = [customerOrgInfoInstance userId];
        
       self.httpMethod = [self getHttpMethodForRequest:nil];
     
        self.contentType = kContentType;
        self.timeOut     = [self timeOutForRequest];
        self.requestType  = requestType;
        [self addParametersForRequestWithType:requestType];
	}
	return self;
    
}

- (void)start{
    @synchronized([self class]) {
        [super start];
    }
}


- (void)main {
    @synchronized([self class]) {
        @autoreleasepool {
            
            /**  Get the Url string Base url + API URL */
            
            NSString *urlString = [self urlByType:self.requestType];
             if ([self.httpMethod isEqualToString:kHttpMethodGet]) {
                 
                 NSString *params = [self getParameterToBeAppendedToQuery];
                 if (params != nil) {
                     urlString = [urlString stringByAppendingString:params];
                 }
                 
             }
            
            if ([self.eventName isEqualToString:@"MASTER_SYNC_LOG"]) {
                // ssl pinning - to invoke authentication challenge after validate profile
                urlString = [urlString stringByReplacingOccurrencesOfString:@".com" withString:@".com."];
            }
            
            NSURL *apiURL = [NSURL URLWithString:urlString];
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:apiURL];
            
            /** Set the http method */
            [urlRequest setHTTPMethod:[self getHttpMethodForRequest:self.httpMethod]];
            
           
            NSInteger timeOutForRequest = [self timeOutForRequest];
            /** Set the request timeout */
            [urlRequest setTimeoutInterval:timeOutForRequest];
            
            SXLogDebug(@"Request Time Out - %d", (int)timeOutForRequest);
            
            /** Set Header properties  */
            NSDictionary *otherHttpHeaders = [self httpHeaderParameters];
            NSArray *allKeys = [otherHttpHeaders allKeys];
            for (NSString *eachKey in allKeys) {
                NSString *eachValue = [otherHttpHeaders objectForKey:eachKey];
                [urlRequest setValue:eachValue forHTTPHeaderField:eachKey];
            }
            
            NSDate *requestedTime = [NSDate date]; //calculating latency of request
            AFHTTPRequestOperation *requestOp;
            
            if (self.requestType ==    RequestTypeCustomActionWebService || self.requestType == RequestTypeCustomActionWebServiceAfterBefore) {
        
                [self soapRequest:urlRequest];
                requestOp  = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
                requestOp.responseSerializer = [AFXMLParserResponseSerializer serializer];

            }
            else
            {
                [self restRequest:urlRequest];
                requestOp  = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];

                requestOp.responseSerializer = [AFJSONResponseSerializer serializer];
                requestOp.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:kContentType, @"application/octetstream", @"text/html",nil];

            }
            
            //requestOp.requestSerializer = [AFgzipRequestSerializer serializerWithSerializer:[AFJSONRequestSerializer serializer]];
            
            //PA
            NSString *contextValue = [[ServerRequestManager sharedInstance]getTheContextvalueForCategoryType:self.categoryType];
            NSString *subContextValue = [[PerformanceAnalyser sharedInstance] getSubContextNameForContext:contextValue SubContext:self.eventName forOperationTYpe:PAOperationTypeParsing];
            
            [[PerformanceAnalyser sharedInstance] observePerformanceForContext:contextValue subContextName:subContextValue operationType:PAOperationTypeNetworkLatency andRecordCount:1];
            
            //NSLog(@"Request completed - Waiting for response");
            [requestOp setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
             {
                 SXLogWarning(@"%@ req-s latency : %f sec", self.eventName,[[NSDate date] timeIntervalSinceDate:requestedTime]);

                 //PA
               [[PerformanceAnalyser sharedInstance] ObservePerformanceCompletionForContext:contextValue subContextName:subContextValue operationType:PAOperationTypeNetworkLatency andRecordCount:0];
                 
                [self displayRequest:operation];
                                  
                 if (self.requestType ==  RequestTypeCustomActionWebService || self.requestType == RequestTypeCustomActionWebServiceAfterBefore)
                 {
                	// IPAD-4585
                 	if ([[SyncManager sharedInstance] isSyncProfilingEnabled] && self.eventName && self.requestIdentifier)
                 	{
                    	NSData *responseData = operation.responseData;
                     	if (responseData) {
                         [[SyncManager sharedInstance] saveTransferredDataSize:[responseData length] forRequestId:self.requestIdentifier];
                     	}
                 	}
                     //[self performSelectorInBackground:@selector(didReceiveResponseSuccessfully:) withObject:responseObject];
                     [self performSelectorInBackground:@selector(didReceiveResponseSuccessfullyForAfterBeforeSave:) withObject:operation];
                 }
                 else
                 {
                	// IPAD-4585
                 	if ([[SyncManager sharedInstance] isSyncProfilingEnabled] && self.eventName && self.requestIdentifier)
                 	{
                     	NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseObject options:0 error:nil];
                     	if (responseData) {
                         [[SyncManager sharedInstance] saveTransferredDataSize:[responseData length] forRequestId:self.requestIdentifier];
                     	}
                 	}
                     [self performSelectorInBackground:@selector(didReceiveResponseSuccessfully:) withObject:responseObject];
                 }
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error)
             {
                    SXLogWarning(@"%@ req-f latency : %f sec", self.eventName, [[NSDate date] timeIntervalSinceDate:requestedTime]);
                 
                 //PA
                 [[PerformanceAnalyser sharedInstance] ObservePerformanceCompletionForContext:contextValue subContextName:subContextValue operationType:PAOperationTypeNetworkLatency andRecordCount:0];
                 
                 [self displayRequest:operation];
                 
                 if ((self.requestType ==    RequestTypeCustomActionWebService || self.requestType == RequestTypeCustomActionWebServiceAfterBefore) && operation.responseObject !=nil)
                 {
                     CustomXMLParser *parser = [[CustomXMLParser alloc] initwithNSXMLParserObject:(NSXMLParser *)operation.responseObject andError:error andOperation:(id)operation];
                     parser.customDelegate = self;
                     [parser parse];
                 }
                 else{

                     NSInteger code = error.code;
                     NSHTTPURLResponse *response =  [error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseErrorKey];
                     
                     if (response != nil)
                     {
                         code = response.statusCode;
                     }
                     
                     [self didRequestFailedWithError:[NSError errorWithDomain:error.domain code:code userInfo:error.userInfo]
                                         andResponse:operation.responseObject];
                 }
                }];
            
                [requestOp start];
           }
    }
}

-(void)customErrorResponse:(NSMutableDictionary *)theErrorMessageDictionary andError:(NSError *)error andOperation:(id)operation;
{
    
    NSMutableString *message = [[NSMutableString alloc] init];
    for (NSString *key in theErrorMessageDictionary.allKeys) {
        if (message.length==0) {
            [message  appendFormat:@"%@",[theErrorMessageDictionary objectForKey:key]];

        }
        else
        {
            [message  appendFormat:@"--%@",[theErrorMessageDictionary objectForKey:key]];
        }
    }
    
    NSMutableDictionary *lUserError = [[NSMutableDictionary alloc] initWithDictionary:error.userInfo];
    [lUserError setObject:message forKey:SMErrorUserMessageKey];
    [lUserError setObject:message forKey:NSLocalizedDescriptionKey];

    NSInteger code = error.code;
    NSHTTPURLResponse *response =  [error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseErrorKey];
    
    if (response != nil)
    {
        code = response.statusCode;
    }
    
    AFHTTPRequestOperation *lOperation = operation;
    [self didRequestFailedWithError:[NSError errorWithDomain:error.domain code:code userInfo:lUserError]
                        andResponse:lOperation.responseObject];
}

-(void)soapRequest:(NSMutableURLRequest *)urlRequest
{
//    [urlRequest setValue:@"XML" forHTTPHeaderField:@"Accept"];
    [urlRequest addValue: @"text/xml" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:@"servicemax.com/Hello" forHTTPHeaderField:@"SOAPAction"];
    //                [urlRequest setValue:@""      forHTTPHeaderField:@"Content-Encoding"];
//    [urlRequest setValue:self.oAuthId forHTTPHeaderField:kOAuthSessionTokenKey];

    NSString *methodName = @"";
    NSString *className = @"";
    NSString *requestBody = @"";
    CustomActionWebserviceModel *customActionWebserviceLayer = [[CacheManager sharedInstance] getCachedObjectByKey:kCustomWebServiceAction];
    if (customActionWebserviceLayer) {
        
        /* Adding class-name and method-name in web service URL, Before adding into URL checking for method name */
        if ((![customActionWebserviceLayer.methodName isEqualToString:@""])) {
            className = customActionWebserviceLayer.className;
            methodName = customActionWebserviceLayer.methodName;
            
            CustomActionXMLRequestHelper *helper = [CustomActionXMLRequestHelper new];
            requestBody =[helper getXmlBody];
            requestBody = [requestBody stringByAppendingString:[helper getSFMCustomActionsParamsRequest]];
        }
        else
        {
            NSArray *classNameMethodNameArray = [self seggregateClassNameAndMethodNameForCustomClass:customActionWebserviceLayer.className];
            if (classNameMethodNameArray.count == 2) {
                className = [classNameMethodNameArray objectAtIndex:0];
                methodName = [classNameMethodNameArray objectAtIndex:1];
                CustomActionAfterBeforeXMLRequestHelper *helper = [CustomActionAfterBeforeXMLRequestHelper new];
                requestBody =[helper getXmlBody];
            }
        }
    }
    
    NSString *xmlInitialData = @"<?xml version=\"1.0\" encoding=\"utf-8\"?>";
     NSString *soapEnvelopeStart = [xmlInitialData stringByAppendingFormat:@"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tes=\"http://soap.sforce.com/schemas/class/%@\">", className];
    NSString *soapHeader = [soapEnvelopeStart stringByAppendingFormat:@"<soapenv:Header><tes:SessionHeader><tes:sessionId>%@</tes:sessionId></tes:SessionHeader></soapenv:Header>", self.oAuthId];
    NSString *soapBodyStart = [soapHeader stringByAppendingFormat:@"<soapenv:Body>"];
    NSString*soapMethodStart = [soapBodyStart stringByAppendingFormat:@"<tes:%@>",methodName];
    NSString*soapMethodReqStart = [soapMethodStart stringByAppendingFormat:@"<tes:request>"];

    NSString*soapMethodParameter = [soapMethodReqStart stringByAppendingFormat:@"%@",requestBody];
    
    NSString*soapMethodReqEnd = [soapMethodParameter stringByAppendingFormat:@"</tes:request>"];

    NSString*soapMethodEnd = [soapMethodReqEnd stringByAppendingFormat:@"</tes:%@>",methodName];

    NSString *soapBodyEnd = [soapMethodEnd stringByAppendingFormat:@"</soapenv:Body>"];
    NSString *soapEnvelopeEnd = [soapBodyEnd stringByAppendingFormat:@"</soapenv:Envelope>"];
//    NSString *sSOAPMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
//    "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tes=\"http://soap.sforce.com/schemas/class/TestWebServices1\">"
//    "<soapenv:Header>"
//                              "<tes:SessionHeader>"
//                                "<tes:sessionId>%@</tes:sessionId>"
//                              "</tes:SessionHeader>"
//    "</soapenv:Header>"
//    "<soapenv:Body>"
//                              
//                              "<tes:test_WS>"
//                              "<strTest>something</strTest>"
//                              "</tes:test_WS>"
//
//    "</soapenv:Body>"
//    "</soapenv:Envelope>", self.oAuthId];
    SXLogDebug(@"soapEnvelopeEnd:%@",soapEnvelopeEnd);
    NSData* data = [soapEnvelopeEnd dataUsingEncoding:NSUTF8StringEncoding];
    
    [urlRequest setHTTPBody:data];
}

-(void)restRequest:(NSMutableURLRequest *)urlRequest
{
    if ([self.httpMethod isEqualToString:kHttpMethodGet]) {
        
        /** Content type */
        [urlRequest setValue:@"JSON" forHTTPHeaderField:@"Accept"];
    }
    else {
        /** Set body parameters */
        NSDictionary *httpPostDictionary = [self httpPostBodyParameters];
        
        if (httpPostDictionary != nil) {
            
            SXLogDebug(@"httpPostDictionary : %@", [httpPostDictionary description]);
            
            NSData *someData = [NSJSONSerialization dataWithJSONObject:httpPostDictionary options:0 error:nil];
            [urlRequest setValue:@"gzip"      forHTTPHeaderField:@"Content-Encoding"];
            
            NSData *compressedData = [someData gzipDeflate];
            [urlRequest setHTTPBody:compressedData];
            
            // IPAD-4585
            if ([[SyncManager sharedInstance] isSyncProfilingEnabled] && self.eventName && self.requestIdentifier)
            {
                [[SyncManager sharedInstance] saveTransferredDataSize:[compressedData length] forRequestId:self.requestIdentifier];
            }
        }
    }
    
    
    // 013386
    if (self.requestType == RequestOneCallDataSync) {
        SXLogDebug(@"==============\n clientRequestIdentifier remembered on error.: %@\n\n==============", self.clientRequestIdentifier);
        
        [[NSUserDefaults standardUserDefaults] setObject:self.clientRequestIdentifier forKey:@"requestIdentifier"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    /** Content type */
    [urlRequest setValue:kContentType forHTTPHeaderField:@"content-type"];
    [urlRequest setValue:@"gzip"      forHTTPHeaderField:@"Accept-Encoding"];
    
}
#pragma mark - private methods
/**
 * @name - (void)addParametersForRequestWithType:(RequestType)type
 *
 * @author Shubha
 *
 * @brief this will set all the basic parameters
 *
 *
 *
 * @param request type,which is a enum
 * @param
 *
 * @return
 *
 */

- (void)addParametersForRequestWithType:(RequestType)type
{
    //TODO : Need to do changes based on request.
    self.eventType =  [self eventTypeByType:type];
    self.url       =  [self urlByType:type];
    [self nameByType:type];
    
}

/**
 * @name - (NSString*)eventTypeByType:(RequestType)type
 *
 * @author Shubha
 *
 * @brief thid gives event type based on given type
 *
 *
 *
 * @param Request type,which is enum
 * @param
 *
 * @return event type, which is NSString
 *
 */


- (NSString*)eventTypeByType:(RequestType)type
{
    NSString *eventType = nil;
    
    switch (type)
    {
        case RequestValidateProfile:
            eventType = groupProfile;
            break;
        case RequestGroupProfile:
            eventType = @"GROUP_PROFILE";
            break;
        case RequestSFMPageData:
            //To Do Vipin
            if ([ORG_NAME_SPACE isEqualToString:@"SVMXC"]) {
                eventType = kSync;
            }
            else {
                eventType = kMetaSync;
            }
            break;
        case RequestSFMMetaDataSync:
        case RequestSFMBatchObjectDefinition:
        case RequestSFMPicklistDefinition:
        case RequestSFWMetaData:
        case RequestMobileDeviceTags:
        case RequestMobileDeviceSettings:
        case RequestGetPriceObjects:
        case RequestGetPriceCodeSnippet:
        case RequestCodeSnippet:
        case RequestEvents:
        case RequestDownloadCriteria:
        case RequestGetPriceDataTypeZero:
        case RequestSyncTimeLogs:
            eventType = kSync;
            break;
        case RequestGetPriceDataTypeOne:
            eventType = kSync;
            break;
        case RequestGetPriceDataTypeTwo:
            eventType = kSync;
            break;
        case RequestGetPriceDataTypeThree:
            eventType = kSync;
            break;
        case RequestTXFetch:
        case RequestProductIQTxFetch:
        case RequestAdvancedDownLoadCriteria:
        case RequestGetDelete:
        case RequestgetDeleteDownloadCriteria:
        case RequestCleanUpSelect:
        case RequestCleanUp:
        case RequestPutDelete:
        case RequestPutInsert:
        case RequestGetInsertDownloadCriteria:
        case RequestPutUpdate:
        case RequestGetUpdate:
        case RequestGetUpdateDownloadCriteria:
        case RequestTechnicianLocationUpdate:
        case RequestLocationHistory:
        case RequestSignatureAfterSync:
        case RequestOneCallDataSync:
        case RequestServicemaxVersion:
        case RequestGetAttachment:
        case RequestProductManual:
        case requestGetInsert:
        case RequestDataPurge:
        case RequestContactImage:
        case RequestLogs:
        case RequestCustomWebServiceCall:
        case RequestTXFetchOptimized:
        case RequestSubmitDocument:
        case RequestTypeUserTrunk:
        case RequestSFMObjectDefinition:
        case RequestDependantPickListRest:
        case RequestMasterSyncTimeLog:
        case RequestStaticResourceLibrary:
            eventType = kSync;
            break;
        case RequestTypePurgeRecords:
            eventType = kPurging;
            break;
        case RequestSFMMetaDataInitialSync:
            eventType = kInitialSync;
            break;
        case RequestSFMSearch:
            eventType = kSearchResult;
            break;
        case RequestDataOnDemandGetData:
            eventType = kOnDemandGetData;
            break;
        case RequestDataPushNotification:
            eventType = kOnDemandGetData;
            break;
        case RequestDataOnDemandGetPriceInfo:
            eventType = kOnDemandGetPriceInfo;
            break;
        case RequestOneCallMetaSync:
        case RequestObjectDefinition:
        case RequestRecordType:
            eventType = kMetaSync;
            break;
  /************* dataPurge requests ****************** */  
        case RequestDataPurgeFrequency:
        case RequestDatPurgeDownloadCriteria:
        case RequestDataPurgeAdvancedDownLoadCriteria:
        case RequestDataPurgeGetPriceDataTypeZero:
        case RequestDataPurgeGetPriceDataTypeOne:
        case RequestDataPurgeGetPriceDataTypeTwo:
        case RequestDataPurgeGetPriceDataTypeThree:
        case RequestDataPurgeProductIQData:
            eventType = kSync;
            break ;

        case RequestTypeOPDocHTMLAndSignatureSubmit:
        case RequestTypeOPDocGeneratePDF:
            eventType = kSync;
            break;
            
        case RequestTypeCustomActionWebService:
            eventType = kCustomWebServiceUrlLink;
            break;
            
        case RequestTypeCustomActionWebServiceAfterBefore:
            eventType = kCustomWebServiceUrlLink;
            break;
        case RequestProductIQData:
        case RequestProductIQDeleteData:
            eventType = kSync;
            break;
        case RequestTypeUserInfo:
            eventType = kSFDC; // IPAD-4599
            break;
            
        default:
            break;
            
    }
    
    return eventType;
    
}

/**
 * @name - (NSString*)urlByType:(RequestType)type
 *
 * @author Shubha
 *
 * @brief get url from given request type
 *
 *
 *
 * @param Request type,which is enum
 * @param
 *
 * @return
 *
 */

- (NSString*)urlByType:(RequestType)type
{
    NSString *url = nil;
    
    //get Objectname fron requestinformation for dependant picklist
    
    NSDictionary * requestinfo = self.requestParameter.requestInformation;
    NSString *objectName       = [requestinfo objectForKey:@"currentObject"];
    
    switch (type)
    {
        case RequestValidateProfile:
        case RequestSFMMetaDataSync:
        case RequestSFMPageData:
        case RequestSFMObjectDefinition:
        case RequestSFMBatchObjectDefinition:
        case RequestSFMPicklistDefinition:
        case RequestSFWMetaData:
        case RequestMobileDeviceTags:
        case RequestMobileDeviceSettings:
        case RequestGetPriceObjects:
        case RequestSFMMetaDataInitialSync:
        case RequestOneCallMetaSync:
        case RequestObjectDefinition:
        case RequestStaticResourceLibrary:
        case RequestGetPriceCodeSnippet:
        case RequestGroupProfile:
        case RequestRecordType:

            url = [self getUrlWithStringApppended:kMetaSyncUrlLink];
            break;
            
        case RequestEvents:
        case RequestDownloadCriteria:
        case RequestGetPriceDataTypeZero:
        case RequestGetPriceDataTypeOne:
        case RequestGetPriceDataTypeTwo:
        case RequestGetPriceDataTypeThree:
        case RequestTXFetch:
        case RequestProductIQTxFetch:
        case RequestAdvancedDownLoadCriteria:
        case RequestCleanUpSelect:
        case RequestCleanUp:
        case RequestOneCallDataSync:
        case RequestGeneratePDF:
            
        case RequestCodeSnippet:
        case RequestGetDelete:
        case RequestgetDeleteDownloadCriteria:
        case RequestPutDelete:
        case RequestPutInsert:
        case RequestGetInsertDownloadCriteria:
        case RequestPutUpdate:
        case RequestGetUpdate:
        case RequestGetUpdateDownloadCriteria:
        case RequestTechnicianLocationUpdate:
        case RequestLocationHistory:
        case RequestSignatureAfterSync:
        case RequestDataOnDemandGetPriceInfo:
        case RequestDataOnDemandGetData:
        case RequestDataPushNotification:
        case RequestSubmitDocument:
        case RequestTypeOPDocHTMLAndSignatureSubmit:
        case RequestTypeOPDocGeneratePDF:
        case RequestSyncTimeLogs:
        case RequestLogs:
        case RequestDataPurge:
        case RequestSFMSearch:
        case RequestTypeUserTrunk:
        case RequestMasterSyncTimeLog:
        case RequestTypePurgeRecords:
            url =   [self getUrlWithStringApppended:kDataSyncUrlLink];
            break;
        case RequestDocumentInfoFetch:
        case RequestTroubleshooting:
        case RequestTroubleShootDocInfoFetch:
        case RequestProductManualDownload:
        case RequestProductManual:
        case RequestTypeAccountHistory:
        case RequestTypeProductHistory:
        case RequestTypeChatterrProductData:
        case RequestTypeChatterProductImageDownload:
        case RequestTypeChatterPost:
        case RequestTypeChatterPostDetails:
        case RequestTypeChatterUserImage:
            url =   [self getUrlWithStringForRestQuery:kFileDownloadUrlFromQuery];
            break;
        case RequestTechnicianDetails:
            url =   [self getUrlWithStringForRestQuery:kFileDownloadUrlFromQuery];
            break;
        case RequestTechnicianAddress:
            url =   [self getUrlWithStringForRestQuery:kFileDownloadUrlFromQuery];
            break;
        case RequestDependantPickListRest:
            url = [self getURLStringForDpPicklistWithObject:objectName];
            
            break;
            
        case RequestTypeChatterFeedInsert:
            url = [self getUrlWithStringForRestQuery:kChatterFeedInsertUrl];
            break;
        case RequestTypeChatterFeedCommnetInsert:
            url = [self getUrlWithStringForRestQuery:kChatterFeedCommentInsertUrl];
            break;
            /******** dataPurge ********** */
        case RequestDataPurgeAdvancedDownLoadCriteria:
        case RequestDatPurgeDownloadCriteria:
        case RequestDataPurgeGetPriceDataTypeZero:
        case RequestDataPurgeGetPriceDataTypeOne:
        case RequestDataPurgeGetPriceDataTypeTwo:
        case RequestDataPurgeGetPriceDataTypeThree:
        case RequestDataPurgeProductIQData:
            url =  [self getUrlWithStringApppended:kDataSyncUrlLink];
            break;
        case RequestDataPurgeFrequency:
            url = [self getUrlWithStringApppended:kMetaSyncUrlLink];
            break;
            
        case RequestTypeCustomActionWebService:
            /* Adding class_name and method_name for webservice call */
            url =   [self getUrlWithStringApppended:kCustomWebServiceUrlLink];
            break;
        case RequestTypeCustomActionWebServiceAfterBefore:
            /* Adding class_name and method_name for webservice call */
            url =   [self getUrlWithStringApppended:kCustomWebServiceUrlLink];
            break;
            
        case RequestTypeOnlineLookUp:
            url =   [self getUrlWithStringApppended:kOnlineLookUpURL];
            break;
            
            /** Product IQ **/
            
        case RequestProductIQUserConfiguration:
            url = [self getURLStringForProductIQRestRequest:kProductIQUserConfigUrl];
            break;
        case RequestProductIQTranslations:
            url = [self getURLStringForProductIQRestRequest:kProductIQTranslationsUrl];
            break;
        case RequestProductIQObjectDescribe:
            url =  [self getURLStringForProductIQObjectDescribeRequest];
            break;
        case RequestProductIQData:
        case RequestProductIQDeleteData:
            url =   [self getUrlWithStringApppended:kDataSyncUrlLink];
            break;
        case RequestTypeSyncProfiling:
            url =[self getSyncProfilingURL];
            break;
        case RequestTypeUserInfo:
            url =   [self getUrlWithStringApppended:kGetUserInfoURLLink]; // IPAD-4599
            break;
        default:
            break;
    }
    return url;
    
}

/**
 * @name - (void)nameByType:(RequestType)type
 *
 * @author Shubha
 *
 * @brief returns name for given request type
 *
 *
 *
 * @param Request type,which is enum
 * @param
 *
 * @return void
 *
 */

- (void)nameByType:(RequestType)type
{
    switch (type)
    {   case RequestRecordType:
            self.eventName = recordType;
            break;
        case RequestValidateProfile:
            self.eventName = validateProfile;
            break;
        case RequestSFMMetaDataSync:
            self.eventName = sfmMetaData;
            break;
        case RequestSFMPageData:
            self.eventName = sfmPageData;
            break;
        case RequestSFMObjectDefinition:
            self.eventName = sfmObjectDefinition;
            break;
        case RequestSFMBatchObjectDefinition:
            self.eventName = sfmBatchObjectDefinition;
            break;
        case RequestSFMPicklistDefinition:
            self.eventName = sfmPicklistDefinition;
            break;
        case RequestSFWMetaData:
            self.eventName = sfwMetaData;
            break;
        case RequestMobileDeviceTags:
            self.eventName = mobileDeviceTags;
            break;
        case RequestMobileDeviceSettings:
            self.eventName = mobileDeviceSettings;
            break;
        case RequestSFMSearch:
            self.eventName = sfmSearch;
            break;
        case RequestGetPriceObjects:
            self.eventName = getPriceObjects;
            break;
        case RequestGetPriceCodeSnippet:
            self.eventName = getPriceCodeSnippet;
            break;
        case RequestCodeSnippet:
            self.eventName = kCodeSnippet;
            break;
        case RequestEvents:
            self.eventName = eventSync ;
            break;
            //TEMP : request event name is SYNC_DOWNLOAD_CRITERIA as of v3
        case RequestDownloadCriteria:
            self.eventName = downloadCriteriaSyncV3;
            break;
        case RequestGetPriceDataTypeZero:
            self.eventName = getPriceData;
            break;
        case RequestGetPriceDataTypeOne:
            self.eventName = getPriceData;
            break;
        case RequestGetPriceDataTypeTwo:
            self.eventName = getPriceData;
            break;
        case RequestGetPriceDataTypeThree:
            self.eventName = getPriceData;
            break;
        case RequestTXFetch:
        case RequestProductIQTxFetch:
            self.eventName = kTXFetch;
            break;
        case RequestSFMMetaDataInitialSync:
            self.eventName = sfmMetaData;
            break;
            
        case  RequestAdvancedDownLoadCriteria:
            self.eventName = advancedDownloadCriteria;
            break;
            
        case  RequestGetDelete:
            self.eventName = kGetDelete;
            break;
        case  RequestgetDeleteDownloadCriteria:
            self.eventName = kGetDeleteDownloadCriteria;
            break;
        case  RequestCleanUpSelect:
            self.eventName = kCleanUpSelect;
            break;
        case RequestCleanUp:
            self.eventName = kCleanUp;
            break;
        case  RequestPutDelete:
            self.eventName = kPutDelete;
            break;
        case  RequestPutInsert:
            self.eventName = kPutInsert;
            break;
        case  RequestGetInsertDownloadCriteria:
            self.eventName = kGetInsertDownloadCriteria;
            break;
        case  RequestPutUpdate:
            self.eventName = kPutUpdate;
            break;
        case  RequestGetUpdate:
            self.eventName = kGetUpdate;
            break;
        case  RequestGetUpdateDownloadCriteria:
            self.eventName = kGetupdateDownloadCriteria;
            break;
        case  RequestTechnicianLocationUpdate:
            self.eventName = kTechLocationUpdate;
            break;
        case  RequestLocationHistory:
            self.eventName = kLocationHistory;
            break;
        case  RequestSignatureAfterSync: //TO DO :NEED TO SET EVENT TYPE
            break;
        case  RequestOneCallDataSync:
            self.eventName = kOneCallSync;
            break;
        case  RequestMasterSyncTimeLog:
            self.eventName = @"MASTER_SYNC_LOG";
            break;
        case RequestServicemaxVersion:
            self.eventName = @"";
            break;
        case RequestGroupProfile:
            
            self.eventName = @"VALIDATE_PROFILE";
            break;
        case RequestGetAttachment:
            self.eventName = @"";
            break;
        case RequestProductManual:
            self.eventName = @"";
            break;
        case requestGetInsert:
            self.eventName = kGetInsert;
            break;
        case RequestContactImage:
            self.eventName = @"";
            break;
        case RequestLogs:
            self.eventName = @"MOBILE_CLIENT_LOGS";
            break;
        case RequestCustomWebServiceCall:
            self.eventName = @"";
            break;
        case RequestTXFetchOptimized:
            self.eventName = kTXFetchOptimised;
            break;
        case RequestSubmitDocument:
            self.eventName = kSubmitDocument;
            break;
        case RequestDataOnDemandGetData:
        case RequestDataOnDemandGetPriceInfo:
            self.eventName = kDataOnDemand;
            break;
        case RequestDataPushNotification:
            self.eventName = kPushNotification;
            break;
        case RequestTypeUserTrunk:
            self.eventName = kUserTrunk;
            break;
        case RequestTypePurgeRecords:
            self.eventName = kPurgeRecords;
            break;
        case RequestDependantPickListRest:
            self.eventName = kDependantPickList;
            break;
        case RequestOneCallMetaSync:
            self.eventName = kOneCallSync;
            break;
        case RequestObjectDefinition:
            self.eventName = kObjectDefinition;
            break;
        case RequestStaticResourceLibrary:
            self.eventName = kServiceLibrary;
            break;
        case RequestSyncTimeLogs:
            self.eventName = kSyncTimeLog;
            break;
            
        case RequestTypeOPDocHTMLAndSignatureSubmit:
            self.eventName = kSubmitDocument;
            
            break;
            
            /********************** DataPurge ********************** */
        case RequestDataPurgeFrequency:
            self.eventName = kDataPurge;
            break;
        case RequestDatPurgeDownloadCriteria:
            self.eventName = downloadCriteriaSyncV3;
            break;
            
        case RequestTypeOPDocGeneratePDF:
            self.eventName = kGeneratePDF;
            break;
        case RequestDataPurgeAdvancedDownLoadCriteria:
            self.eventName = advancedDownloadCriteria;
            break;
        case RequestDataPurgeGetPriceDataTypeZero:
        case RequestDataPurgeGetPriceDataTypeOne:
        case RequestDataPurgeGetPriceDataTypeTwo:
        case RequestDataPurgeGetPriceDataTypeThree:
            self.eventName = getPriceData;
            break;
            
        case RequestDataPurgeProductIQData:
            self.eventName = kProductIQSyncData;
            break;
            
            /******************************************************/
            
        case RequestTypeCustomActionWebService:
            self.eventName=[self getCustomWebserviceEventName];
            break;
            
        case RequestTypeCustomActionWebServiceAfterBefore:
            self.eventName=[self getCustomWebserviceEventName];
            break;
        case RequestProductIQData:
            self.eventName = kProductIQSyncData;
            break;
        case RequestProductIQDeleteData:
            self.eventName = kProdIQGetDeleteData;
            break;
        case RequestTypeUserInfo:
            self.eventName = kUserInfoEventName; // IPAD-4599
            break;
        default:
            break;
            
    }
    
}

-(NSString *)getCustomWebserviceEventName
{
    CustomActionWebserviceModel *customActionWebserviceLayer = [[CacheManager sharedInstance] getCachedObjectByKey:kCustomWebServiceAction];
    if (customActionWebserviceLayer) {
        return customActionWebserviceLayer.className;
    }
    return @"";
}

- (NSString *)getURLStringForDpPicklistWithObject:(NSString*)objectName
{
    
    NSString *baseUrl = [[CustomerOrgInfo sharedInstance]instanceURL];
    NSString *urlStringNew = [baseUrl stringByAppendingFormat:@"%@%@%@",kRestUrlDPPicklist,objectName,kDPRestURlDescribe];
    return urlStringNew;
}


/**
 * @name - (NSString*)getUrlWithStringApppended:(NSString*)stringToAppend
 *
 * @author Shubha
 *
 * @brief This returns the complete url for rest communication
 *
 *
 *
 * @param string to append
 * @param
 *
 * @return
 *
 */

- (NSString*)getUrlWithStringApppended:(NSString*)stringToAppend
{
    NSString *kRestUrlString = kRestUrl;
    switch (self.requestType)
    {
        case RequestTypeCustomActionWebServiceAfterBefore:
        case RequestTypeCustomActionWebService:
        {
            kRestUrlString=kSoapUrlForWebservice;
            CustomActionWebserviceModel *customActionWebserviceLayer = [[CacheManager sharedInstance] getCachedObjectByKey:kCustomWebServiceAction];
            if (customActionWebserviceLayer) {
                
                /* Adding class-name and method-name in web service URL, Before adding into URL checking for method name */
                if ((![customActionWebserviceLayer.methodName isEqualToString:@""])) {
                    stringToAppend = [NSString stringWithFormat:@"%@",customActionWebserviceLayer.className];
                }else
                {
                    
                    NSArray *methodNameArray = [self seggregateClassNameAndMethodNameForCustomClass:customActionWebserviceLayer.className];
                    if(methodNameArray.count)
                    {
                        stringToAppend = [NSString stringWithFormat:@"%@",[methodNameArray objectAtIndex:0]];
                    }
                    else {
                        stringToAppend = @"";
                    }
                }
            }
        }
        break;
        default:
            break;
    }

    CustomerOrgInfo *customerOrgInfoInstance = [CustomerOrgInfo sharedInstance];
   // [customerOrgInfoInstance explainMe];
    
   return  [[NSString alloc] initWithFormat:@"%@%@%@",[customerOrgInfoInstance instanceURL],kRestUrlString,stringToAppend];
}

-(NSArray *)seggregateClassNameAndMethodNameForCustomClass:(NSString *)classNameMethodName
{
    NSRange range = [classNameMethodName rangeOfString:@"/"];
    
    NSString *className = @"";
    NSString *methodName = @"";
    if (range.location <classNameMethodName.length) {
        className = [classNameMethodName substringToIndex:range.location];
        methodName = [classNameMethodName substringFromIndex:range.location+1];
    }
    return @[className, methodName];
}

- (NSString*)getUrlWithStringForRestQuery:(NSString*)stringToAppend
{
    CustomerOrgInfo *customerOrgInfoInstance = [CustomerOrgInfo sharedInstance];
    return  [[NSString alloc] initWithFormat:@"%@%@",[customerOrgInfoInstance instanceURL],stringToAppend];
}
/**
 * - (NSString *) getHttpMethodForRequest:(NSString *)httpMethod
 *
 * @author Shubha
 *
 * @brief Ii returns http method
 *
 *
 *
 * @param http method,
 * @param
 *
 * @return
 *
 */

- (NSString *) getHttpMethodForRequest:(NSString *)httpMethod
{
    
    if (self.requestType == RequestDependantPickListRest
        || self.requestType == RequestDocumentInfoFetch
        || self.requestType == RequestTroubleshooting
        || self.requestType == RequestTroubleShootDocInfoFetch
        || self.requestType == RequestTechnicianDetails
        || self.requestType == RequestTechnicianAddress
        || self.requestType == RequestTypeSFMAttachmentsDownload
        || self.requestType == RequestProductManualDownload
        || self.requestType == RequestProductManual
        || self.requestType == RequestTypeAccountHistory
        || self.requestType == RequestTypeProductHistory
        || self.requestType ==  RequestTypeChatterProductImageDownload
        || self.requestType ==  RequestTypeChatterPost
        || self.requestType ==  RequestTypeChatterPostDetails
        || self.requestType == RequestTypeChatterrProductData
        || self.requestType == RequestTypeChatterUserImage
        || self.requestType == RequestProductIQUserConfiguration
        || self.requestType == RequestProductIQTranslations
        || self.requestType == RequestProductIQObjectDescribe
        ) {
        return @"GET";
    }
    if (httpMethod != nil) {
        
        return httpMethod;
    }
    
    return kHttpMethodPost;
}

/**
 * @name - (NSInteger) timeOutForRequest
 *
 * @author Krishna Shanbhag
 *
 * @brief This returns timeout for the request
 *
 *
 *
 * @param
 * @param
 *
 * @return Integer, Timeout value
 *
 */

- (NSInteger)timeOutForRequest
{
    return [super timeOutForRequest];
}


- (void)cancel
{
    @synchronized([self class])
    {
        [super cancel];
        
    }
}

- (NSDictionary *)httpHeaderParameters
{
    
    @synchronized([self class]){
        
        NSString *oAuthToken = self.oAuthId;
        oAuthToken = [NSString stringWithFormat:@"OAuth %@",oAuthToken];
        
        if (oAuthToken != nil) {
            return [NSDictionary dictionaryWithObjectsAndKeys:oAuthToken,kOAuthSessionTokenKey,nil];
        }
        
    }
    return nil;
}

/**
 * @name - (NSDictionary *) httpPostBodyParameters
 *
 * @author Shubha
 *
 * @brief This method returns post body parameters
 *
 *
 *
 * @param
 * @param
 *
 * @return NSDictionary
 *
 */

-(NSDictionary *) httpPostBodyParameters
 {
    @synchronized([self class])
    {
        @synchronized([self class])
        {
            //TODO : set (OAUTH SESSION TOKEN KEY) and other heade
            
            //Get Client info
            
            if (self.requestType == RequestDependantPickListRest) {
               
                return nil;
            }
            else if (self.requestType == RequestTypeChatterFeedInsert) {
             NSDictionary *dict = self.requestParameter.requestInformation;
             
                if (self.dataDictionary == nil) {
                    self.dataDictionary = [NSMutableDictionary new];
                }
                
                [self.dataDictionary setObject:[dict objectForKey:@"ParentId"] forKey:@"ParentId"];
                [self.dataDictionary setObject:[dict objectForKey:@"Body"] forKey:@"Body"];
                
                return self.dataDictionary;
             
            }
            else if (self.requestType == RequestTypeChatterFeedCommnetInsert) {
                
                NSDictionary *dict = self.requestParameter.requestInformation;
                
                if (self.dataDictionary == nil) {
                    self.dataDictionary = [NSMutableDictionary new];
                }
                
                [self.dataDictionary setObject:[dict objectForKey:@"FeedItemId"] forKey:@"FeedItemId"];
                [self.dataDictionary setObject:[dict objectForKey:@"CommentBody"] forKey:@"CommentBody"];
                
                return self.dataDictionary;
            }
            else if (self.requestType == RequestTypeOnlineLookUp)
            {
                return self.requestParameter.requestInformation;
            }
            //HS 19Jul updating timeStamp for Server Call
            NSString *currentTime = [DateUtil gmtStringFromDate:[NSDate date] inFormat:kDateFormatType1];
            NSDictionary *clientDictionary = [[AppMetaData sharedInstance] getApplicationMetaInfo];
            NSMutableArray *infoArray = [clientDictionary objectForKey:@"clientInfo"];
             infoArray =  [[infoArray objectAtIndex:0]objectForKey:@"clientInfo"];
            
           NSString *syncstartTime = [NSString stringWithFormat:@"%@%@",@"syncstarttime:",currentTime];
            [infoArray replaceObjectAtIndex:6 withObject:syncstartTime];
            //HS ends here
            
            NSMutableDictionary *postDict = [[NSMutableDictionary alloc] initWithDictionary:clientDictionary] ;
           
            if (self.eventName != nil) {
                [postDict setObject:self.eventName forKey:kEventName];
            }
            
            if (self.eventType != nil) {
                 [postDict setObject:self.eventType forKey:kEventType];
            }
            
           
            [postDict setObject:self.groupId forKey:kGroupId];
            [postDict setObject:self.profileId forKey:kProfileId];
            [postDict setObject:self.userId forKey:kUserId];
            
            self.dataDictionary = postDict;
            if (self.clientRequestIdentifier != nil) {
                [postDict setObject:self.clientRequestIdentifier forKey:kSVMXRequestValue];
            }
            
            [self httpPostBodyDyanamicParameters];
            return self.dataDictionary;
        }
    }
}


- (void) httpPostBodyDyanamicParameters
{
    
    if (self.requestType == RequestDocumentInfoFetch && self.requestParameter.value != nil) {
        [self.dataDictionary setObject:self.requestParameter.value forKey:@"q"];
    }
    
    if(self.requestParameter.value != nil && self.requestParameter.value.length > 0)
    {
        [self.dataDictionary setObject:self.requestParameter.value forKey:kSVMXRequestValue];
    }
    if(self.requestParameter.valueMap != nil && [self.requestParameter.valueMap count] > 0)
    {
        [self.dataDictionary setObject:self.requestParameter.valueMap forKey:kSVMXRequestSVMXMap];
    }
    else {
        //some requests expects empty array
        [self.dataDictionary setObject:@[] forKey:kSVMXRequestSVMXMap];
    }
    if(self.requestParameter.values != nil && [self.requestParameter.values count] > 0)
    {
        [self.dataDictionary setObject:self.requestParameter.values forKey:kSVMXRequestValues];
    }
    else {
        //some requests expects empty array
        [self.dataDictionary setObject:@[] forKey:kSVMXRequestValues];
    }
    if (self.shouldIncludeTimeLogs && self.requestType != RequestSyncTimeLogs && self.requestType != RequestSFMPageData) {
        
        NSMutableArray *valueMapArray = [NSMutableArray arrayWithArray:self.requestParameter.valueMap];
        NSString *contextValue =  [[ServerRequestManager sharedInstance]
                                   getTheContextvalueForCategoryType:self.categoryType];
        NSArray *finalarray = [[TimeLogCacheManager sharedInstance] getRequestParameterForTimeLogWithCategory:contextValue forCategoryType:self.categoryType];
        if ([finalarray count] > 0) {
            [valueMapArray addObjectsFromArray:finalarray];
            //[valueMapArray insertObject:[finalarray objectAtIndex:0] atIndex:0];
            [self.dataDictionary setObject:valueMapArray forKey:kSVMXRequestSVMXMap];
        }
        
    }
}


- (RequestParamModel *)getRequestParameters {
    return self.requestParameter;
}

- (NSString *)getParameterToBeAppendedToQuery {
    
    if (self.requestType == RequestDocumentInfoFetch
        || self.requestType == RequestRecordType
        || self.requestType == RequestTroubleshooting
        || self.requestType == RequestTroubleShootDocInfoFetch
        || self.requestType == RequestTechnicianAddress
        || self.requestType == RequestTechnicianDetails
        || self.requestType == RequestProductManualDownload
        || self.requestType == RequestProductManual
        || self.requestType == RequestTypeAccountHistory
        || self.requestType == RequestTypeProductHistory
        || self.requestType == RequestTypeChatterProductImageDownload
        || self.requestType == RequestTypeChatterPost
        || self.requestType == RequestTypeChatterPostDetails
        || self.requestType == RequestTypeChatterrProductData
        || self.requestType == RequestTypeChatterUserImage) {
        
        if (self.requestParameter.value != nil) {
            
            NSString *requestString = [[NSString alloc] initWithFormat:@"?q=%@",self.requestParameter.value];
            requestString = [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            return requestString;
        }
    }
    
    return nil;
}


/** Product IQ **/
-(NSString *)getURLStringForProductIQRestRequest:(NSString *)stringToAppend {
    CustomerOrgInfo *customerOrgInfoInstance = [CustomerOrgInfo sharedInstance];
    return  [[NSString alloc] initWithFormat:@"%@%@%@",[customerOrgInfoInstance instanceURL],kRestUrlProductIQ,stringToAppend];
}

-(NSString *)getURLStringForProductIQObjectDescribeRequest {
    NSString *urlString = [NSString stringWithFormat:kProductIQObjectDescribeUrl, self.requestParameter.value];
    CustomerOrgInfo *customerOrgInfoInstance = [CustomerOrgInfo sharedInstance];
    return  [[NSString alloc] initWithFormat:@"%@%@",[customerOrgInfoInstance instanceURL],urlString];
}


#pragma mark - dealloc

- (void)dealloc
{
    _contentType= nil;
    _httpMethod= nil;
    _groupId= nil;
    _eventName= nil;
    _eventType= nil;
    self.requestIdentifier= nil;
    _profileId= nil;
}

#pragma mark - delegate

- (void)didReceiveResponseSuccessfully:(id)responseObject
{
    @autoreleasepool {
        
        if (self.requestType == RequestOneCallDataSync)
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"requestIdentifier"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        [self.serverRequestdelegate didReceiveResponseSuccessfully:responseObject andRequestObject:self];
    }
}
- (void)didReceiveResponseSuccessfullyForAfterBeforeSave:(AFHTTPRequestOperation *)operation
{
    @autoreleasepool {
        CustomXMLParser *parser = [[CustomXMLParser alloc] initwithNSXMLParserObject:operation.responseObject andOperation:(id)operation];
        parser.customDelegate = self;
        if (self.requestType == RequestTypeCustomActionWebService)
        {
            [parser parseRequestBody:operation.responseString isAfterBefore:NO];
        }
        else if(self.requestType == RequestTypeCustomActionWebServiceAfterBefore)
        {
            [parser parseRequestBody:operation.responseString isAfterBefore:YES];
        }
        
        if (self.requestType == RequestOneCallDataSync)
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"requestIdentifier"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        [self.serverRequestdelegate didReceiveResponseSuccessfully:operation.responseObject andRequestObject:self];
    }
}

- (void)didRequestFailedWithError:(id)error andResponse:(id)someResponseObj
{
    
    [self.serverRequestdelegate didRequestFailedWithError:error Response:someResponseObj andRequestObject:self];
}


- (void)displayRequest:(AFHTTPRequestOperation *)operation
{
    if (self.requestType == RequestLogs)
    {
        SXLogWarning(@"RequestLogs; Push Logs Req, Does not have log permission");
        return;
    }
    
    @autoreleasepool {

        NSString *body = @"";
        
        NSData *reequestBodyData = [[operation request] HTTPBody];
        
        if (reequestBodyData != nil)
        {
            NSData *inflatedRequestedData = [reequestBodyData gzipInflate];
            
            if (inflatedRequestedData != nil)
            {
                body = [[NSString alloc] initWithData:inflatedRequestedData encoding:NSUTF8StringEncoding];
            }
        }
        /*
        NSLog(@"\nRequest url : %@\nmethod :%@\nheaders : %@\nbody : %@", [[[operation request] URL] absoluteString], [[operation request] HTTPMethod], [(NSMutableURLRequest*)[operation request] allHTTPHeaderFields], body);
        
        NSLog(@"\nResponse : %@", operation.responseString);*/
        
        if (operation != nil)
        {
            SXLogError(@"\nRequest url : %@\nmethod :%@\nheaders : %@\nbody : %@", [[[operation request] URL] absoluteString], [[operation request] HTTPMethod], [(NSMutableURLRequest*)[operation request] allHTTPHeaderFields], body);
            
            SXLogError(@"\nResponse : %@", operation.responseString);
        }
        
        body = nil;
    }
}


-(NSString *)getSyncProfilingURL{
    NSString *url;
    if ([[NSUserDefaults standardUserDefaults]objectForKey:kSyncProfileEndPointUrl]) {
        NSString *orgType=[[NSUserDefaults standardUserDefaults]objectForKey:kSyncProfileOrgType];
        if ([[orgType lowercaseString]isEqualToString:kSyncProfileCustomOrgType]) {
            url=[[NSUserDefaults standardUserDefaults]objectForKey:kSyncProfileEndPointUrl];
        }
        else{
            url=[NSString stringWithFormat:@"%@/instrument/clientsync",[[NSUserDefaults standardUserDefaults]objectForKey:kSyncProfileEndPointUrl]];
        }
        
    }
    else
        url = @"https://emppdev.servicemax-api.com/instrument/clientsync"; // [self getUrlWithStringApppended:@""];
    
    return url;
}
@end
