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
{
    @synchronized([self class])
    {
        if ([OAuthService validateAndRefreshAccessToken])
        {
            [self makeNextRequesttWithPrevious:nil firstCall:YES];
        }
        else
        {
            if (CategoryTypeInitialSync == self.nodecategoryType)
            {
                //[self sendProgressStatusFor:self.nodecategoryType
                               //  syncStatus:<#(SyncStatus)#>
                //-(void)sendProgressStatusFor:(RequestType)requestType syncStatus:(SyncStatus)status
                
                NSError *storedError = [PlistManager lastOAuthErrorMessage];
                
                [self sendProgressStatusFor:RequestTypeRefresTokenFailed syncStatus:SyncStatusFailed withError:storedError];
            }
        }
    }
}

-(void)cancelFlow
{
    @synchronized([self class])
    {
         [self cancelRequestsFromOperationQueue];
         [self cancelAllRequest];
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
        
        SVMXServerRequest * request = [self getRequestFromRequestManagerWithPrevious:previousRequest withRequestParam:requestParam withRequestType:requestType];
     
        [request addClientRequestIdentifier:self.flowId];
        request.shouldIncludeTimeLogs = [[ServerRequestManager sharedInstance]isTimeLogEnabledForCategoryType:self.nodecategoryType];
        
        [self addRequestToRequestArray:request];
        [self addRequestToOperationQueue:request];
    }
}

-(BOOL)makeNextRequesttWithPrevious:(SVMXServerRequest *)previousRequest
                          firstCall:(BOOL)isFirstCall
{
    RequestType  nextRequestType = [self nextRequestTypeWIthPreviousRequest:previousRequest];
    
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

-(RequestType)nextRequestTypeWIthPreviousRequest:(SVMXServerRequest *)prevRequest
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
    
    for (NSOperation * requestObj in  allRequests) {
        [requestObj cancel];
    }
}

#pragma mark - Service Layer

-(void)callServiceLayerWithRequestObject:(SVMXServerRequest *)requestObject withResponseObject:(id)responseObject
{
    [self removeRequestFromRequestArray:requestObject];
    
    TimeLogParser *parser = [[TimeLogParser alloc] init];
    TimeLogModel *model = [parser parseTimeLogIdForResponse:responseObject];
    if (model != nil) {
        model.timeT4 = [DateUtil getDatabaseStringForDate:[NSDate date]];
        model.syncRequestStatus = kTimeLogSucess;
    }
    
    if (requestObject.requestType == RequestSyncTimeLogs) {
        [parser parseAndDeleteLogIdFromCache:responseObject];
    }
    
    BaseServiceLayer *serviceLayer = (BaseServiceLayer *)[ServiceFactory serviceLayerWithCategoryType:self.nodecategoryType
                                                               requestType:requestObject.requestType];
    serviceLayer.requestIdentifier = self.flowId;
    if ([serviceLayer conformsToProtocol:@protocol(ServiceLayerProtocol)])
    {
        ResponseCallback *callBackObject = [serviceLayer processResponseWithRequestParam:requestObject.requestParameter
                                                                  responseData:responseObject];
        
        if (model != nil) {
            model.timeT5 = [DateUtil getDatabaseStringForDate:[NSDate date]];
            [[TimeLogCacheManager sharedInstance] logEntryForSyncResponceTime:model];
        }

        if (requestObject.requestType == RequestSyncTimeLogs) {
            [parser parseAndDeleteLogIdFromCache:responseObject];
        }

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
    BOOL optionalRequest = [[ServerRequestManager sharedInstance] isOptionalRequest:requestObject.requestType];
    
    TimeLogParser *parser = [[TimeLogParser alloc] init];
    TimeLogModel *model = [parser parseTimeLogIdForResponse:responseObject];
    if (model != nil) {
        model.timeT4 = [DateUtil getDatabaseStringForDate:[NSDate date]];
        model.syncRequestStatus = kTimeLogFailure;
    }
    if (optionalRequest)
    {
        [self callServiceLayerWithRequestObject:requestObject withResponseObject:responseObject];
    }
    else
    {
        //Shravya/Vipin To do: Send NSError to the delegate
         [self sendProgressStatusFor:requestObject.requestType syncStatus:SyncStatusFailed withError:error];
         [self flowCompleted];
    }
    if (model != nil) {
        model.timeT5 =[DateUtil getDatabaseStringForDate:[NSDate date]];
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
            responseStatus.syncProgressState = SyncStatusRefreshTokenFailedWithError;
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
    [[TaskManager sharedInstance] removeFlowNodeWithId:self.flowId];
}

#pragma mark - Operation queue Methods

- (void)addRequestToOperationQueue:(SVMXServerRequest *)request
{
    [[SVMXOperationQueue sharedSVMXOperationQueObject] addOperationToQue:request];
}

-(void)cancelRequestsFromOperationQueue
{
    [[SVMXOperationQueue sharedSVMXOperationQueObject] cancelAllOperations];
}

#pragma mark - END


#pragma mark - SVMXRequestDelegate methods

- (void)didReceiveResponseSuccessfully:(id)responseObject andRequestObject:(id)request
{
    NSError *serverError = [SMInternalErrorUtility checkForErrorInResponse:responseObject withStatusCode:-999 andError:nil];
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
    
    NSLog(@"Request failed with error %@ %@ Request : %@",[error description],[responseObject description],[request description]);
    NSError *serverError = [SMInternalErrorUtility checkForErrorInResponse:responseObject withStatusCode:200 andError:error];
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

@end
