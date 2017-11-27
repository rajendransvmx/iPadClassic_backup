//
//  FlowNode.m
//  ServiceMaxMobile
//
//  Created by Krishna Shanbhag on 31/05/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import "FlowNode.h"
#import "RequestParamModel.h"
#import "ServerRequestManager.h"
#import "SVMXOperationQueue.h"
#import "ServiceFactory.h"
#import "PlistManager.h"
#import "BaseServiceLayer.h"
#import "RestRequest.h"
#import "PerformanceAnalyser.h"

#import "ResponseCallback.h"
#import "WebserviceResponseStatus.h"
#import "SyncProgressFactory.h"
#import "OAuthService.h"
#import "TaskManager.h"
#import "TimeLogCacheManager.h"
#import "SMInternalErrorUtility.h"
#import "DateUtil.h"
#import "TimeLogModel.h"
#import "TimeLogParser.h"
#import "RequestConstants.h"
#import "ResponseConstants.h"
#import "SVMXSystemUtility.h"
#import "StringUtil.h"
#import "SMAppDelegate.h"
#import "CacheManager.h"
#import "PushNotificationManager.h"
#import "PushNotificationUtility.h"
#import "SuccessiveSyncManager.h"
#import "OauthConnectionHandler.h"
#import "SyncManager.h"

#define MAX_RETRY_COUNT 3
NSString *cocoaErrorString = @"3840";
NSString *heapSizeErrorString = @"System.LimitException"; //{"errorCode":"APEX_ERROR","message":"System.LimitException: Apex heap size too large:
@interface FlowNode()
{
    
}


@property (nonatomic)BOOL isMadeAsHead;
@property (nonatomic)BOOL parallelNodeStarted;

@property (nonatomic, copy)NSString *firstIdentifier;
@property (nonatomic, copy)NSString *lastIdentifier;



@end

@implementation FlowNode

@synthesize isMadeAsHead;
@synthesize parallelNodeStarted;

@synthesize firstIdentifier;
@synthesize lastIdentifier;



- (id)initWithTask:(TaskModel *)taskObject
{
    self = [super self];
    if(self != nil)
    {
        self.nodecategoryType = taskObject.categoryType;
        self.callerDelegate = taskObject.callerDelegate;
        self.requestParam = taskObject.requestParamObj;
        self.flowId = taskObject.taskId;
    }
    
    return self;
}


- (BOOL)isTail
{
    return (self.next == nil);
}

- (BOOL)isParallelNodeStarter
{
    return parallelNodeStarted;
}

- (BOOL)isHead
{
    return isMadeAsHead;
}

- (void)setAsHead:(BOOL)headNode
{
    self.isMadeAsHead = headNode;
}

#pragma mark - Start Flow

- (void)startFlow
{    //PA
    int i = (int) SMLogLogLevel();
    SXLogDebug(@"Log level :%d", (int)i);
    
    if (ApplicationLogLevelWarning == i)
    {
        [PerformanceAnalyser sharedInstance].startedPerformanceAnalyser = YES;
    }
    
    NSString *contextValue = [[ServerRequestManager sharedInstance] getTheContextvalueForCategoryType:self.nodecategoryType];
   [[PerformanceAnalyser sharedInstance] observePerformanceForContext:contextValue subContextName:contextValue operationType:PAOperationTypeTotalTimeLatency andRecordCount:1];
    
    [[SVMXSystemUtility sharedInstance] performSelectorOnMainThread:@selector(startNetworkActivity)
                                                         withObject:nil
                                                      waitUntilDone:NO];
    @synchronized([self class])
    {
        int x = -99;
        if (self.nodecategoryType > self.nodecategoryType)
        {
            x = (int)self.nodecategoryType;
        }
        
        SXLogInfo(@"Req Category - %d", x);
        
        // SECSCAN-260
        if([OAuthService shouldPerformRefreshAccessToken])
        {
            OauthConnectionHandler *service = [[OauthConnectionHandler alloc] init];
            [service refreshAccessTokenWithCompletion:^(BOOL isSuccess, NSString *errorMsg) {
                if (isSuccess)
                {
                    [self makeNextRequesttWithPrevious:nil firstCall:YES];
                }
                else
                {
                    //if (CategoryTypeInitialSync == self.nodecategoryType)
                    {
                        NSError *storedError = [PlistManager lastOAuthErrorMessage];
                        
                        if ( (storedError != nil) && [StringUtil containsString:@"NSURLErrorDomain" inString:storedError.domain])
                        {
                            [self sendProgressStatusFor:RequestTypeNone
                                             syncStatus:SyncStatusFailed
                                              withError:storedError];
                            
                        }
                        else{
                            
                            [self sendProgressStatusFor:RequestTypeRefresTokenFailed
                                             syncStatus:SyncStatusFailed
                                              withError:storedError];
                        }
                        
                        
                        [self flowCompleted];
                        
                    }
                }
            }];
        }
        else
        {
            [self makeNextRequesttWithPrevious:nil firstCall:YES];
        }
    }
}

- (void)cancelFlow
{
    @synchronized([self class])
    {
         [self cancelRequestsFromOperationQueue];
         [self cancelAllRequest];
        
        /* Send progress as cancelled */
         [self sendProgressStatusFor:RequestTypeNone syncStatus:SyncStatusInCancelled];
        self.callerDelegate = nil;
        [self flowCompleted];
     }
}


#pragma mark  End -


#pragma mark - Call Request Manager

-(void)makeRequestWithPrevious:(SVMXServerRequest *)previousRequest
              withRequestParam:(RequestParamModel *)requestParam
               withRequestType:(RequestType)requestType
{
    @synchronized([self class])
    {
       // [self getRequestFromRequestManagerWithPrevious:previousRequest withRequestParam:requestParam callBackStatus:callBackStatus];
        
        SVMXServerRequest * request = [self getRequestFromRequestManagerWithPrevious:previousRequest
                                                                    withRequestParam:requestParam
                                                                     withRequestType:requestType];
     
        [request addClientRequestIdentifier:self.flowId];
        
        if(requestType == RequestMasterSyncTimeLog)
        {
            request.shouldIncludeTimeLogs = NO;
        }
        else{
            request.shouldIncludeTimeLogs = [[ServerRequestManager sharedInstance]isTimeLogEnabledForCategoryType:self.nodecategoryType];
        }
        request.categoryType = self.nodecategoryType;
        
        [self addRequestToRequestArray:request];
        [self addRequestToOperationQueue:request];
    }
}

-(BOOL)makeNextRequesttWithPrevious:(SVMXServerRequest *)previousRequest
                          firstCall:(BOOL)isFirstCall
{
    RequestType  nextRequestType = [self nextRequestTypeWithPreviousRequest:previousRequest];
    
    [self saveRequestIdForSyncTimeLogs:previousRequest andNextRequestType:nextRequestType]; // IPAD-4764
    
    // IPAD-4510
    if ((previousRequest.categoryType == CategoryTypeDataSync || previousRequest.categoryType == CategoryTypeOneCallDataSync) && previousRequest.requestType == RequestTXFetch) {
        if ([[SuccessiveSyncManager sharedSuccessiveSyncManager] whatIdsToDelete].count > 0) {
            nextRequestType = RequestTypePurgeRecords;
        }
        else {
            nextRequestType = RequestCleanUp;
        }
    }
    
    if (nextRequestType == RequestCleanUp) {
        [[SuccessiveSyncManager sharedSuccessiveSyncManager] setWhatIdsToDelete:nil];
    }
    
    if(nextRequestType == RequestTypeNone)
    {
        return  NO;
    }
    
    NSInteger   concurrencyCount  = [self  concurrencyCountForNextRequestType:nextRequestType];
    
    NSArray * requestparams = [self getRequestParamsForNextRequestType:nextRequestType forConcurrencyCount:concurrencyCount];
    BOOL isReqParamsMandatory = NO;
    
    if (!isFirstCall && isReqParamsMandatory && [requestparams count] <= 0 ) {
      
        [self sendProgressStatusFor:nextRequestType syncStatus:SyncStatusInProgress];
            
        SVMXServerRequest * req =  [[ServerRequestManager sharedInstance] requestForType:nextRequestType withCategory:self.nodecategoryType andPreviousRequest:previousRequest];
        
        [self sendProgressStatusFor:req.requestType syncStatus:SyncStatusInProgress];

        BOOL returnFlag = [self makeNextRequesttWithPrevious:req firstCall:NO];
        return returnFlag;
    }
    
    if (isFirstCall && self.requestParam != nil) //  1st call and  is not concurrent call
    {
        [self makeRequestWithPrevious:previousRequest withRequestParam:self.requestParam withRequestType:nextRequestType];
    }
    else if(concurrencyCount > 1) // For  concurrent calls
    {
        for (int i = 0 ; i < [requestparams count]; i++)
        {
            [self makeRequestWithPrevious:previousRequest
                         withRequestParam:[requestparams objectAtIndex:i]
                          withRequestType:nextRequestType];
        }
    }
    else  // For BOth non concurrent calls and no Request Parameter calls
    {
         RequestParamModel * requestParam = nil;
        if([requestparams count] > 0)
        {
           requestParam =  [requestparams objectAtIndex:0];
        }
        
        [self makeRequestWithPrevious:previousRequest
                     withRequestParam:requestParam
                      withRequestType:nextRequestType];
    }
    
    return YES;
}

-(NSArray *)getRequestParamsForNextRequestType:(RequestType)nxtRequestType forConcurrencyCount:(NSInteger)concurrencyCount
{
   NSArray * requestParams = nil;
    
    // call Service layer to get reuest params
   BaseServiceLayer *serviceLayer = (BaseServiceLayer *)[ServiceFactory serviceLayerWithCategoryType:_nodecategoryType requestType:nxtRequestType];
    serviceLayer.requestIdentifier = self.flowId;
   requestParams =  [serviceLayer getRequestParametersWithRequestCount:concurrencyCount];
    
    return requestParams;
    
}


-(NSInteger)concurrencyCountForNextRequestType:(RequestType)nextRequestType
{
    NSInteger concurrencyCount = [[ServerRequestManager sharedInstance] getConcurrencyCountForRequestType:nextRequestType
                                                                                          andCategoryType:self.nodecategoryType];
    return concurrencyCount;
}

-(RequestType)nextRequestTypeWithPreviousRequest:(SVMXServerRequest *)prevRequest
{
    RequestType nextRequestType = [[ServerRequestManager sharedInstance] getNextRequestTypeForCategoryType:self.nodecategoryType withPreviousRequest:prevRequest];

    return nextRequestType;
}

-(SVMXServerRequest *)getRequestFromRequestManagerWithPrevious:(SVMXServerRequest *)previousRequest
                    withRequestParam:(RequestParamModel *)requestParam
                    withRequestType:(RequestType)requestType
{
    @synchronized([self class]){
        
        SVMXServerRequest * request = [[ServerRequestManager sharedInstance] requestForType:requestType withCategory:self.nodecategoryType  andPreviousRequest:previousRequest];
        request.serverRequestdelegate = self;
        [request addRequestParametersForRequest:requestParam];
        return request;
    }
}




#pragma mark  End -


-(void)addRequestToRequestArray:(SVMXServerRequest *)request
{
     @synchronized([self class]){
        if(request != nil)
        {
            if(self.requestDict == nil){
                self.requestDict = [[NSMutableDictionary alloc] init];
            }
            
            [self.requestDict   setObject:request forKey:request.requestIdentifier];
        }
    }
}


-(void)removeRequestFromRequestArray:(SVMXServerRequest *)request
{
    @synchronized([self class]){
        if(request != nil)
        {
            [self.requestDict removeObjectForKey:request.requestIdentifier];
        }
    }
}

-(void)cancelAllRequest
{
    NSArray * allRequests = [self.requestDict allValues];
    
    for (SVMXServerRequest * requestObj in  allRequests) {
        [requestObj cancel];
        requestObj.serverRequestdelegate = nil;
    }
    
    
}

#pragma mark - Service Layer

-(void)callServiceLayerWithRequestObject:(SVMXServerRequest *)requestObject withResponseObject:(id)responseObject

{
    //PA
    NSString *contextValue = @"";
    NSString *subContextValue = @"";
    
    if (![requestObject.apiType isEqualToString:@"ZKS"]) {
    
        RestRequest *request = (RestRequest *)requestObject;
        contextValue = [[ServerRequestManager sharedInstance]getTheContextvalueForCategoryType:self.nodecategoryType];
        subContextValue = [[PerformanceAnalyser sharedInstance] getSubContextNameForContext:contextValue SubContext:request.eventName forOperationTYpe:PAOperationTypeParsing];
        
        [[PerformanceAnalyser sharedInstance] observePerformanceForContext:contextValue subContextName:subContextValue operationType:PAOperationTypeParsing andRecordCount:1];

    }
    
    // IPAD-4585
    if(requestObject.requestType == RequestTypeSyncProfiling)
    {
        [[SyncManager sharedInstance] syncProfilingDidRecieveResponse:responseObject];
    }

    [self removeRequestFromRequestArray:requestObject];
    
    TimeLogParser *parser = [[TimeLogParser alloc] init];
    TimeLogModel *model = [parser parseTimeLogIdForResponse:responseObject];
    
    if (requestObject.requestType == RequestSyncTimeLogs) {
        [parser parseAndDeleteLogIdFromCache:responseObject];
    }
    else {
        
        if (model != nil) {
            model.timeT4 = [DateUtil gmtStringFromDate:[NSDate date] inFormat:kDateFormatType1];
            //[DateUtil stringFromDate:[NSDate date] inFormat:kDateFormatType1];
            model.syncRequestStatus = kTimeLogSucess;
        }

    }
    
    BaseServiceLayer *serviceLayer = (BaseServiceLayer *)[ServiceFactory serviceLayerWithCategoryType:self.nodecategoryType
                                                               requestType:requestObject.requestType];
    serviceLayer.requestIdentifier = self.flowId;
    if ([serviceLayer conformsToProtocol:@protocol(ServiceLayerProtocol)])
    {
        ResponseCallback *callBackObject = [serviceLayer processResponseWithRequestParam:requestObject.requestParameter
                                                                  responseData:responseObject];
        if (requestObject.requestType == RequestSyncTimeLogs) {
            [parser parseAndDeleteLogIdFromCache:responseObject];
        }
        else {
            if (model != nil) {
                model.timeT5 = [DateUtil gmtStringFromDate:[NSDate date] inFormat:kDateFormatType1];
                //[DateUtil stringFromDate:[NSDate date] inFormat:kDateFormatType1];
                [[TimeLogCacheManager sharedInstance] logEntryForSyncResponceTime:model forCategoryType:self.nodecategoryType];
            }
        }
        //PA
        [[PerformanceAnalyser sharedInstance] ObservePerformanceCompletionForContext:contextValue subContextName:subContextValue operationType:PAOperationTypeParsing andRecordCount:0];
        
        if (callBackObject.errorInParsing != nil) {
            
            [self  request:requestObject failedWithError:callBackObject.errorInParsing andResponse:nil];
        }
        else if(callBackObject.callBack )
        {
            [self makeRequestWithPrevious:requestObject
                         withRequestParam:callBackObject.callBackData
                          withRequestType:requestObject.requestType];
        }
        else if( [self.requestDict count] <= 0)
        {
           BOOL continueFlow = [self  makeNextRequesttWithPrevious:requestObject firstCall:NO];
            if(!continueFlow){
                [self sendProgressStatusFor:requestObject.requestType syncStatus:SyncStatusSuccess];

                [self flowCompleted];
            }
            else
            {
                [self sendProgressStatusFor:requestObject.requestType syncStatus:SyncStatusInProgress];

            }
        }
    }
}
/**
 * @name  <isCocoaErrorRetryCompletedForRequest>
 *
 * @author Krishna Shanbhag
 *
 * @brief <If cocoa error is thrown, handle it by retrying the request , reinvoking the request>
 *
 *
 * @param  RequestObject
 * The request which is previously initiated.
 * @param  Error : to confirm it is an cocoa error
 *
 * @return Description of the return value
 *
 */
- (BOOL)isCocoaErrorRetryCompletedForRequest:(SVMXServerRequest *)requestObject withError:(NSError *)error
{
    [[CacheManager sharedInstance]clearCacheByKey:@"PageIds"];

    BOOL returnValue = YES;
    
    //check retry count > 0 and < max retry count.
    NSLog(@"\n\n\n error desc : %@, domain : %@, userinfo : %@ code %ld\n\n\n",[error description],[error domain],[error userInfo],(long)[error code]);
    
    
    //---------------------------------------------
 

    BOOL isHeapSizeError = [StringUtil containsStringinErrorMsg:heapSizeErrorString inString:[error description]];
    BOOL isCocoaError = [StringUtil containsStringinErrorMsg:cocoaErrorString inString:[error description]];
    
    if (requestObject.requestType == RequestProductIQObjectDescribe) {
        // this request returns single json string - don't retry if it fails because of 3840 error.
    }
    
    else if (requestObject.requestType == RequestObjectDefinition && isHeapSizeError && requestObject.requestParameter.heapSizeRetryCount > 0 && requestObject.requestParameter.heapSizeRetryCount <= MAX_RETRY_COUNT) {
        
        NSLog(@"Heap size error retry count : %ld\n\n",(long)requestObject.requestParameter.heapSizeRetryCount);
        
        NSLog(@"\n\n\nerror desc : %@\n, domain : %@\n, userinfo : %@\n code %ld\n\n\n",[error description],[error domain],[error userInfo],(long)[error code]);
        
        requestObject.requestParameter.heapSizeRetryCount++;
        
        NSMutableArray *values = [NSMutableArray arrayWithArray:requestObject.requestParameter.values];
        
        if ([values count] > 1) {
            
            NSInteger length = [values count]*70/100;
            NSInteger loc = [values count] - length;
            loc = (loc == 0)?1:loc;
            
            if ([values count] > loc) {
                NSArray *removedObjects = [values subarrayWithRange:NSMakeRange(loc, length)];
                [values removeObjectsInRange:NSMakeRange(loc, length)];
                NSMutableArray *cachedObjs = [[CacheManager sharedInstance]getCachedObjectByKey:kOBJdefList];
                if (cachedObjs) {
                    [cachedObjs addObjectsFromArray:removedObjects];
                }
                else {
                    cachedObjs = [NSMutableArray arrayWithArray:removedObjects];
                }
                [[CacheManager sharedInstance] pushToCache:cachedObjs byKey:kOBJdefList];
            }
            
            requestObject.requestParameter.values = values;
        }
        
        
        [self makeRequestWithPrevious:requestObject
                     withRequestParam:requestObject.requestParameter
                      withRequestType:requestObject.requestType];
        
        returnValue = NO;
        
    }
    
    //----------------------------------------------
    
    
    else if (isCocoaError && requestObject.requestParameter.retryCount > 0 && requestObject.requestParameter.retryCount <= MAX_RETRY_COUNT) {
        
        NSLog(@"\n\n[cocoaERROR]requestObject.requestParameter.retryCount : %ld\n\n",(long)requestObject.requestParameter.retryCount);
        
        NSLog(@"\n\n\nerror desc : %@\n, domain : %@\n, userinfo : %@\n code %ld\n\n\n",[error description],[error domain],[error userInfo],(long)[error code]);
        
        requestObject.requestParameter.retryCount++;
        [self makeRequestWithPrevious:requestObject
                     withRequestParam:requestObject.requestParameter
                      withRequestType:requestObject.requestType];
        
        returnValue = NO;
    }
    return returnValue;
}

/**
 * @name   requeset:(SVMXServerRequest *)requestObject failedWithError:(NSError *)error andResponse:(id)responseObject
 *
 * @author Vipindas Palli
 *
 * @brief   Handle response call back error
 *
 * \par
 *  <Longer description starts here>
 *
 * @return String value
 *
 */

- (void)request:(SVMXServerRequest *)requestObject failedWithError:(NSError *)error andResponse:(id)responseObject
{
    // IPAD-4585
    if(requestObject.requestType == RequestTypeSyncProfiling)
    {
        [[SyncManager sharedInstance] syncProfilingDidRequestFailedWithError:error andResponse:responseObject];
    }
    
    if ([self isCocoaErrorRetryCompletedForRequest:requestObject withError:error]) {
        
        BOOL optionalRequest = [[ServerRequestManager sharedInstance] isOptionalRequest:requestObject.requestType];
        
        TimeLogParser *parser = [[TimeLogParser alloc] init];
        TimeLogModel *model = [parser parseTimeLogIdForResponse:responseObject];
        if (model != nil) {
            model.timeT4 = [DateUtil gmtStringFromDate:[NSDate date] inFormat:kDateFormatType1];
            //[DateUtil getDatabaseStringForDate:[NSDate date]];
            model.syncRequestStatus = kTimeLogFailure;
        }
        
        if (requestObject.requestType == RequestObjectDefinition) {
            [[CacheManager sharedInstance] clearCacheByKey:kOBJdefList];
        }
        
        if (optionalRequest)
        {
            [self callServiceLayerWithRequestObject:requestObject withResponseObject:responseObject];
        }
        else
        {
            [[TimeLogCacheManager sharedInstance] addEntryToFailureList:requestObject.clientRequestIdentifier forCategoryType:self.nodecategoryType];
            //Shravya/Vipin To do: Send NSError to the delegate
            [self sendProgressStatusFor:requestObject.requestType syncStatus:SyncStatusFailed withError:error];
            [self flowCompleted];
        }
        
        if (model != nil) {
            model.timeT5 = [DateUtil gmtStringFromDate:[NSDate date] inFormat:kDateFormatType1];
            //[DateUtil getDatabaseStringForDate:[NSDate date]];
        }
    }
    else {
        [self removeRequestFromRequestArray:requestObject];
        return;
    }
}


- (void)sendProgressStatusFor:(RequestType)requestType syncStatus:(SyncStatus)status
{
    [self sendProgressStatusFor:requestType syncStatus:status withError:nil];
}
                 
- (void)sendProgressStatusFor:(RequestType)requestType syncStatus:(SyncStatus)status withError:(NSError *)error
{
    WebserviceResponseStatus * responseStatus = [[WebserviceResponseStatus alloc] init];
    
    if (status == SyncStatusSuccess)
    {
       responseStatus.syncProgressState = SyncStatusCompleted;
    }
    else if(status == SyncStatusFailed)
    {
        if (requestType == RequestTypeRefresTokenFailed)
        {
            responseStatus.syncProgressState = SyncStatusFailedWithRevokeTokenFlag;
        }
        else
        {
            responseStatus.syncProgressState = SyncStatusFailedWithError;
        }
        
        responseStatus.syncError = error;
    }
    else if(status == SyncStatusNetworkError)
    {
        responseStatus.syncProgressState = SyncStatusNetworkError;
    }
    else
    {
        responseStatus.syncProgressState = [SyncProgressFactory getSyncProcessStatusforRequestType:requestType];
    }
    if (requestType == RequestTypeChatterPostDetails
        || requestType == RequestTypeChatterFeedInsert
        || requestType == RequestTypeChatterFeedCommnetInsert) {
        responseStatus.syncProgressState = [SyncProgressFactory getSyncProcessStatusforRequestType:requestType];
    }
    responseStatus.requestType = requestType;
    responseStatus.category = self.nodecategoryType;
    responseStatus.syncStatus = status;
    
    if([self.callerDelegate conformsToProtocol:@protocol(FlowDelegate)])
    {
        [self.callerDelegate flowStatus:responseStatus];
    }
}

#pragma mark - End

-(void)flowCompleted
{
    //PA
    NSString *contextValue = [[ServerRequestManager sharedInstance]getTheContextvalueForCategoryType:self.nodecategoryType];
    [[PerformanceAnalyser sharedInstance] ObservePerformanceCompletionForContext:contextValue subContextName:contextValue operationType:PAOperationTypeTotalTimeLatency andRecordCount:0];
     
    [[SVMXSystemUtility sharedInstance] performSelectorOnMainThread:@selector(stopNetworkActivity)
                                                         withObject:nil
                                                      waitUntilDone:NO];
    
    [[TaskManager sharedInstance] removeFlowNodeWithId:self.flowId];
    
   /***** Pulse app changes: once flow is completed trigger notification *******/
    CategoryType categoryType = self.nodecategoryType;

    if([PushNotificationUtility shouldInitiatePushNotification:categoryType])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:PushNotificationProcessRequest  object:nil];
    }
    
}

#pragma mark - Operation queue Methods

- (void)addRequestToOperationQueue:(SVMXServerRequest *)request
{
    /*
     * Disabling idle timer, due to some reason its getting reset. so to ensure that during webservice we disable idle timer.
     *
     */
//    SMAppDelegate *appDelegate = (SMAppDelegate *)[[UIApplication sharedApplication] delegate];
//    [appDelegate disableIdleTimerForApplication];
    [[SVMXOperationQueue sharedSVMXOperationQueObject] addOperationToQue:request];
}

-(void)cancelRequestsFromOperationQueue
{
    [[SVMXOperationQueue sharedSVMXOperationQueObject] cancelAllOperationsForCategoryType:self.nodecategoryType];
}

#pragma mark - END


#pragma mark - SVMXRequestDelegate methods

- (void)didReceiveResponseSuccessfully:(id)responseObject andRequestObject:(id)request
{
    NSError *serverError = [SMInternalErrorUtility checkForErrorInResponse:responseObject withStatusCode:200 andError:nil];
    if (serverError != nil) {
        /**
         * We found error. You can figure out what action to take using error action category.
         */
        [self request:request failedWithError:serverError andResponse:responseObject];
    } else {
        /**
         * No error wow, we are good to continue parsing.
         */
         [self callServiceLayerWithRequestObject:request withResponseObject:responseObject];
    }
}

- (void)didRequestFailedWithError:(NSError *)error Response:(id)responseObject andRequestObject:(id)request
{
    [[CacheManager sharedInstance]clearCacheByKey:@"PageIds"];
    if (error !=nil)
    {
    [FlowNode reportErrorToAWS:error withResponseObject:responseObject withRequestObject:request];

    }

    NSLog(@"Request failed with error %@ %@ Request : %@",[error description],[responseObject description],[request description]);
    NSError *serverError = [SMInternalErrorUtility checkForErrorInResponse:responseObject withStatusCode:-999 andError:error];
    if (serverError != nil)
    {
        /** Lets parse and see what error it is. */
        [self  request:request failedWithError:serverError andResponse:responseObject];
    } else {
        /** Ideally this shouldn't happen, but if we fail to get error from utility then we can pass the error as is.
         */
        [self  request:request failedWithError:error andResponse:responseObject];
    }
}


+(void)reportErrorToAWS:(NSError*)error withResponseObject:(id)responseObject withRequestObject:(id)requestObject
{
    NSMutableDictionary *errorDict = [NSMutableDictionary dictionaryWithCapacity:1];
    
    SMAppDelegate *appDelegate = (SMAppDelegate *)[[UIApplication sharedApplication]delegate];
    //appDelegate.syncReportingType = @"error";
    if([appDelegate.syncReportingType isEqualToString:@"error"] ||[appDelegate.syncReportingType isEqualToString:@"always"])
    {
        //errorDict = responseObject
        RestRequest *requestObjectDict = (RestRequest *)requestObject;
        if(([responseObject isKindOfClass:[NSArray class]]) && (([[[responseObject objectAtIndex:0]allKeys]containsObject:@"errorCode"]) || [[[responseObject objectAtIndex:0]allKeys]containsObject:@"errors"]))
        {
            [errorDict setObject:responseObject forKey:@"Response"];
            
            
            if ([requestObjectDict dataDictionary])
            {
                [errorDict setObject:[requestObjectDict dataDictionary] forKey:@"dataDictionary"];

            }
            if ([requestObjectDict eventName])
            {
                [errorDict setObject:[requestObjectDict eventName] forKey:@"eventName"];
                
            }
            if ([requestObjectDict eventType])
            {
                [errorDict setObject:[requestObjectDict eventType] forKey:@"eventType"];
                
            }
            if ([requestObjectDict profileId])
            {
                [errorDict setObject:[requestObjectDict profileId] forKey:@"profileId"];
                
            }
            if ([requestObjectDict userId])
            {
                [errorDict setObject:[requestObjectDict userId] forKey:@"userId"];
                
            }
            if ([requestObjectDict apiType])
            {
                [errorDict setObject:[requestObjectDict apiType] forKey:@"apiType"];
                
            }
            
            
            if (errorDict != nil)
            {
                if (appDelegate.syncErrorDataArray == nil)
                {
                    NSMutableArray *arr = [[NSMutableArray alloc]init];
                    appDelegate.syncErrorDataArray = arr;
                }
                [appDelegate.syncErrorDataArray addObject:errorDict];
                
            }

        }
        
    
        
        
    }
    
}

// IPAD-4764
-(void)saveRequestIdForSyncTimeLogs:(SVMXServerRequest *)previousRequest andNextRequestType:(RequestType)nextRequestType {
    
    switch (self.nodecategoryType) {
        case CategoryTypeResetApp:
        case CategoryTypeInitialSync:
        case CategoryTypeOneCallDataSync:
        case CategoryTypeDataSync:
        case CategoryTypeConfigSync:
        case CategoryTypeDataPurge:
        case CategoryTypeIncrementalOneCallMetaSync:
        case CategoryTypeOneCallRestInitialSync:
        {
            if (previousRequest == nil) {
                NSMutableArray *syncTLRequestIds = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:kSTLMetaDataSyncIdKey]];
                [syncTLRequestIds addObject:self.flowId];
                [[NSUserDefaults standardUserDefaults] setObject:syncTLRequestIds forKey:kSTLMetaDataSyncIdKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            if (nextRequestType == RequestTypeNone) {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSTLMetaDataSyncIdKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
            break;
        case CategoryTypeGetPriceData:
        {
            if (previousRequest == nil) {
                NSMutableArray *syncTLRequestIds = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:kSTLGetPriceSyncIdKey]];
                [syncTLRequestIds addObject:self.flowId];
                [[NSUserDefaults standardUserDefaults] setObject:syncTLRequestIds forKey:kSTLGetPriceSyncIdKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            if (nextRequestType == RequestTypeNone) {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSTLGetPriceSyncIdKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
            break;
        default:
            break;
    }
}
@end
