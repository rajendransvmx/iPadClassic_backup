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

//#import "SFMetaDataModel.h"

@implementation RestRequest
@synthesize dataDictionary;

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
    if (self == [super init]) {
        self.apiType = @""; //TODO : set as REST
        if (!dataDictionary) {
            self.dataDictionary = [[NSMutableDictionary alloc] init];
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
        self.timeOut     = 180;
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
            
            NSURL *apiURL = [NSURL URLWithString:urlString];
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:apiURL];
            
            /** Set the http method */
            [urlRequest setHTTPMethod:[self getHttpMethodForRequest:self.httpMethod]];
            
           
            /** Set the request timeout */
            //TODO : hardcoded to 3 minutes.
            [urlRequest setTimeoutInterval:[self timeOutForRequest]];
            
            /** Content type */
            [urlRequest setValue:kContentType forHTTPHeaderField:@"content-type"];
            
           
            /** Set Header properties  */
            NSDictionary *otherHttpHeaders = [self httpHeaderParameters];
            NSArray *allKeys = [otherHttpHeaders allKeys];
            for (NSString *eachKey in allKeys) {
                NSString *eachValue = [otherHttpHeaders objectForKey:eachKey];
                [urlRequest setValue:eachValue forHTTPHeaderField:eachKey];
            }
            
            if ([self.httpMethod isEqualToString:kHttpMethodGet]) {
                
                /** Content type */
                [urlRequest setValue:@"JSON" forHTTPHeaderField:@"Accept"];
            }
            else {
                /** Set body parameters */
                NSDictionary *httpPostDictionary = [self httpPostBodyParameters];
                SXLogDebug(@"httpPostBodyParameters = %@",httpPostDictionary);
                if (httpPostDictionary != nil) {
                    
                    NSData *someData = [NSJSONSerialization dataWithJSONObject:httpPostDictionary options:0 error:nil];
                    [urlRequest setHTTPBody:someData];
                }
            }
            
            NSDate *requestedTime = [NSDate date]; //calculating latency of request
            AFHTTPRequestOperation *requestOp = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
            requestOp.responseSerializer = [AFJSONResponseSerializer serializer];
            requestOp.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:kContentType, @"application/octetstream",@"text/html",nil];
            
            [requestOp setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
             {
                 SXLogDebug(@" %@ req-s latency : %f sec", self.eventName,[[NSDate date] timeIntervalSinceDate:requestedTime]);
                 
                 NSLog(@" %@ req-s latency : %f sec", self.eventName,[[NSDate date] timeIntervalSinceDate:requestedTime]);
                 [self didReceiveResponseSuccessfully:responseObject];
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error)
             {
                 SXLogDebug(@" %@ req-f latency : %f sec", self.eventName,[[NSDate date] timeIntervalSinceDate:requestedTime]);
                 
                 NSLog(@" %@ req-f latency : %f sec", self.eventName,[[NSDate date] timeIntervalSinceDate:requestedTime]);
                 
                 NSInteger code = error.code;
                 NSHTTPURLResponse *response =  [error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseErrorKey];
                 if (response != nil)
                 {
                     code = response.statusCode;
                 }
        
                 [self didRequestFailedWithError:[NSError errorWithDomain:error.domain code:code userInfo:error.userInfo]
                                     andResponse:operation.responseObject];
             }];
            [requestOp start];
        }
    }
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
        case RequestSFMMetaDataSync:
        case RequestSFMPageData:
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
        case RequestAdvancedDownLoadCriteria:
        case RequestGetDelete:
        case RequestgetDeleteDownloadCriteria:
        case RequestCleanUpSelect:
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
        case RequestUserTrunk:
        case RequestSFMObjectDefinition:
        case RequestDependantPickListRest:
        
        case RequestStaticResourceLibrary:
            eventType = kSync;
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
        case RequestDataOnDemandGetPriceInfo:
            eventType = kOnDemandGetPriceInfo;
            break;
        case RequestOneCallMetaSync:
        case RequestObjectDefinition:
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
            eventType = kSync;
            break ;

        case RequestTypeOPDocHTMLAndSignatureSubmit:
        case RequestTypeOPDocGeneratePDF:
            eventType = kSync;
            
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
            url = [self getUrlWithStringApppended:kMetaSyncUrlLink];
            break;
            
        case RequestEvents:
        case RequestDownloadCriteria:
        case RequestGetPriceDataTypeZero:
        case RequestGetPriceDataTypeOne:
        case RequestGetPriceDataTypeTwo:
        case RequestGetPriceDataTypeThree:
        case RequestTXFetch:
        case RequestAdvancedDownLoadCriteria:
        case RequestCleanUpSelect:
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
        case RequestSubmitDocument:
        case RequestTypeOPDocHTMLAndSignatureSubmit:
        case RequestTypeOPDocGeneratePDF:
        case RequestSyncTimeLogs:
        case RequestLogs:
        case RequestDataPurge:
        case RequestSFMSearch:
            url =   [self getUrlWithStringApppended:kDataSyncUrlLink];
            break;
        case RequestDocumentInfoFetch:
        case RequestTroubleshooting:
        case RequestRecordType:
        case RequestTroubleShootDocInfoFetch:
        case RequestProductManualDownload:
        case RequestProductManual:
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
            /******** dataPurge ********** */
        case RequestDataPurgeAdvancedDownLoadCriteria:
        case RequestDatPurgeDownloadCriteria:
        case RequestDataPurgeGetPriceDataTypeZero:
        case RequestDataPurgeGetPriceDataTypeOne:
        case RequestDataPurgeGetPriceDataTypeTwo:
        case RequestDataPurgeGetPriceDataTypeThree:
            url =  [self getUrlWithStringApppended:kDataSyncUrlLink];
            break;
        case RequestDataPurgeFrequency:
            url = [self getUrlWithStringApppended:kMetaSyncUrlLink];
            break;
            /****************    ************** */
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
    {
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
        case RequestUserTrunk:
            self.eventName = kUserTrunk;
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
            /******************************************************/
            

        default:
            break;
            
    }
    
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
    CustomerOrgInfo *customerOrgInfoInstance = [CustomerOrgInfo sharedInstance];
   // [customerOrgInfoInstance explainMe];
    
   return  [[NSString alloc] initWithFormat:@"%@%@%@",[customerOrgInfoInstance instanceURL],kRestUrl,stringToAppend];
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
    
    if (self.requestType == RequestDependantPickListRest || self.requestType == RequestDocumentInfoFetch || self.requestType    == RequestRecordType || self.requestType == RequestTroubleshooting || self.requestType == RequestTroubleShootDocInfoFetch || self.requestType == RequestTechnicianDetails || self.requestType == RequestTechnicianAddress || self.requestType == RequestTypeSFMAttachmentsDownload || self.requestType == RequestProductManualDownload || self.requestType == RequestProductManual) {
        
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

- (NSInteger) timeOutForRequest
{
    //Hard coded TODO : change it later
    return 180;
    
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
            
            NSDictionary *clientDictionary = [[AppMetaData sharedInstance] getApplicationMetaInfo];
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
    if (self.shouldIncludeTimeLogs && self.requestType != RequestSyncTimeLogs) {
        
        NSMutableArray *valueMapArray = [NSMutableArray arrayWithArray:self.requestParameter.valueMap];
        NSArray *finalarray = [[TimeLogCacheManager sharedInstance] getRequestParameterForLogging];
        if ([finalarray count] > 0) {
            [valueMapArray addObjectsFromArray:finalarray];
            
            [self.dataDictionary setObject:valueMapArray forKey:kSVMXRequestSVMXMap];
        }
        
    }
}


- (RequestParamModel *)getRequestParameters {
    return self.requestParameter;
}

- (NSString *)getParameterToBeAppendedToQuery {
    
    if (self.requestType == RequestDocumentInfoFetch || self.requestType    == RequestRecordType || self.requestType == RequestTroubleshooting || self.requestType == RequestTroubleShootDocInfoFetch || self.requestType == RequestTechnicianAddress || self.requestType == RequestTechnicianDetails || self.requestType == RequestProductManualDownload || self.requestType == RequestProductManual) {
        
        if (self.requestParameter.value != nil) {
            
            NSString *requestString = [[NSString alloc] initWithFormat:@"?q=%@",self.requestParameter.value];
            requestString = [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            return requestString;
        }
    }
    
    return nil;
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
    _apiType= nil;
}

#pragma mark - delegate

- (void)didReceiveResponseSuccessfully:(id)responseObject
{
//    SXLogDebug(@"-------------------------------------------");
//    SXLogDebug(@"response = %@",responseObject);
//    SXLogDebug(@"-------------------------------------------");
    [self.serverRequestdelegate didReceiveResponseSuccessfully:responseObject andRequestObject:self];
}

- (void)didRequestFailedWithError:(id)error andResponse:(id)someResponseObj
{
//    SXLogDebug(@"-------------------------------------------");
//    SXLogDebug(@"response = %@",someResponseObj);
//    SXLogDebug(@"-------------------------------------------");
    [self.serverRequestdelegate didRequestFailedWithError:error Response:someResponseObj andRequestObject:self];
}

@end
