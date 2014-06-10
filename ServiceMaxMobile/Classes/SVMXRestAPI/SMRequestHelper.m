//
//  SMRequestHelper.m
//  iService
//
//  Created by Vipindas on 11/17/13.
//
//

#import "SMRequestHelper.h"
#import "SFJsonUtils.h"
#import "RKRequestSerialization.h"
#import "RKClient.h"
#import "SMSalesForceRestAPI.h"
#import "SMConnectionManager.h"
#import "SVMXSystemConstant.h"


@implementation SMRequestHelper

NSString * const kSFSessionTokenPrefix   = @"OAuth ";

@synthesize smRestRequest;
@synthesize rkRequest;

- (id)initWithRestRequest:(SMRestRequest *)restRequest
{
    self = [super init];
    
    if (self)
    {
         self.smRestRequest = restRequest;
    }
    return self;
}


+ (SMRequestHelper *)getHelperForRequest:(SMRestRequest *)request
{
    return [[[SMRequestHelper alloc] initWithRestRequest:request] autorelease];
    
}


- (void)dealloc
{
    [smRestRequest release]; smRestRequest = nil;
    //009382
    // Vipin - 9167
    [rkRequest release];
    rkRequest = nil;
    [super dealloc];
}


+ (NSObject<RKRequestSerializable>*)formatParamsAsJson:(NSDictionary *)queryParams
{
    if (!([queryParams count] > 0))
        return nil;

    NSData *data = [SFJsonUtils JSONDataRepresentation:queryParams];
    return [RKRequestSerialization serializationWithData:data MIMEType:@"application/json"];
}

//9199
- (NSString *)sessionTokenWithPrefix
{
    // 9167 - vipin
    @synchronized([self class])
    {
        [[SMConnectionManager sharedInstance] refreshConnectionInfo];
        NSString *sessionToken = [[SMConnectionManager sharedInstance] sessionToken];
        
        //NSLog(@" -----  sessionToken   ------  %@", sessionToken);
        if ((nil == sessionToken)
            || (![sessionToken isKindOfClass:[NSString class]]))
        {
            [SMConnectionManager sharedInstance].sessionToken = nil;
             
            [[SMConnectionManager sharedInstance] refreshConnectionInfo];
            sessionToken = [[SMConnectionManager sharedInstance] sessionToken];
        }
       
        return [NSString stringWithFormat:@"%@%@", kSFSessionTokenPrefix, sessionToken];
    }
}

// 9167 - vipin
- (BOOL)shouldCancelRequest:(RKRequest *)request
{

    // Vipin - 9167
    @synchronized([self class])
    {
        if ([self.smRestRequest shouldCancel])
        {
            // Yes, We have to cancel the request
            //[request cancel];
            RKClient *rkClient = [SMSalesForceRestAPI sharedInstance].rkClient;
            [rkClient.requestQueue cancelRequest:request];
            return YES;
        }
    
        return NO;
    }
}

// 9167 - vipin
- (void)sendRequestWithDelegate:(id<SMRestRequestDelegate>)delegate
{

    NSString *url = [NSString stringWithString:self.smRestRequest.path];
    NSString *reqEndpoint = kSFDefaultDataService; 
    
    self.smRestRequest.requestDelegate = delegate;
    
    if (![url hasPrefix:reqEndpoint])
    {
        url = [NSString stringWithFormat:@"%@%@", reqEndpoint, url];
    }
    
    RKClient *rkClient = [SMSalesForceRestAPI sharedInstance].rkClient;
    NSLog(@"  requestQueue  - %d  - %d",[rkClient.requestQueue loadingCount], [rkClient.requestQueue count]);
    rkClient.cachePolicy = RKRequestCachePolicyNone;
    rkClient.timeoutInterval = 60.0;
    
    //make sure we have the latest access token at the moment we send the request
    
    [rkClient setValue:[self sessionTokenWithPrefix] forHTTPHeaderField:@"Authorization"];
    
    //009382
    if (self.smRestRequest.method == RKRequestMethodGET)
    {
        NSLog(@" sendRequestWithDelegate - GET  %@", rkClient);
        self.rkRequest = [rkClient get:url queryParameters:self.smRestRequest.parameters delegate:self];
    }
    else if (self.smRestRequest.method == RKRequestMethodDELETE)
    {
        self.rkRequest = [rkClient delete:url delegate:self];
    }
    else if (self.smRestRequest.method == RKRequestMethodPUT)
    {
        self.rkRequest = [rkClient put:url params:[[self class] formatParamsAsJson:smRestRequest.parameters] delegate:self];
    }
    else if (smRestRequest.method == RKRequestMethodPOST)
    {
        self.rkRequest = [rkClient post:url params:[[self class] formatParamsAsJson:smRestRequest.parameters] delegate:self];
    }
}

#pragma mark - RKRequestDelegate


- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response
{
         // Vipin - 9167
     @synchronized([self class])
    {
            NSError *error = nil;
            
            if ([self shouldCancelRequest:request])
            {
                // Ohh we are cancelling the request
                return;
            }

            // token has expired ?
            if ([response isUnauthorized])
            {
                //NSLog(@"Got unauthorized response");
                
                NSString *potentialErrorCode = kUnauthorizedAccessMsg;
                if (nil != potentialErrorCode)
                {
                    // we have an error
                    error = [NSError errorWithDomain:kSVMXRestAPIErrorDomain code:SMAttachmentRequestErrorCodeUnauthorizedAccess userInfo:[NSDictionary dictionaryWithObject:potentialErrorCode forKey:@"ErrorMessage"]];
                    [self.smRestRequest.requestDelegate request:self.smRestRequest didFailLoadWithError:error];
                    return;
                }
                return;
            }
        
            if (![response isOK])
            {
                NSError *error = [NSError errorWithDomain:kSVMXRestAPIErrorDomain code:SMAttachmentRequestErrorCodeFileNotFound userInfo:[NSDictionary dictionaryWithObject:kFileNotFoundMsg forKey:@"ErrorMessage"]];
                [self.smRestRequest.requestDelegate request:self.smRestRequest didFailLoadWithError:error];
                return;
            }
        
        
        // Some responses (e.g. update responses) do not contain any data.
        id jsonResponse = nil;

        if (response.body != nil && response.body.length > 0)
        {
           if (self.smRestRequest.parseResponse == YES)
            {
                jsonResponse = [SFJsonUtils objectFromJSONData:response.body];
            }
            else if ([[response contentType] hasPrefix:kSFRestAPIContentTypeJSON])
            {
                jsonResponse = [SFJsonUtils objectFromJSONData:response.body];
            }
        }
        
        if ([jsonResponse isKindOfClass:[NSArray class]])
        {
            if ([jsonResponse count] == 1)
            {
                id potentialError = [jsonResponse objectAtIndex:0];
                
                if ([potentialError isKindOfClass:[NSDictionary class]])
                {
                    NSString *potentialErrorCode = kUnknownErrorMsg;
                    
                    if (nil != potentialErrorCode)
                    {
                        // we have an error
                        error = [NSError errorWithDomain:kSVMXRestAPIErrorDomain code:SMAttachmentRequestErrorCodeUnknown userInfo:[NSDictionary dictionaryWithObject:potentialErrorCode forKey:@"ErrorMessage"]];
                        [self.smRestRequest.requestDelegate request:self.smRestRequest didFailLoadWithError:error];
                        return;
                    }
                }
            }
        }
        else if (![response isSuccessful])
        {
            NSInteger respCode = [response statusCode];
            NSDictionary *errorInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [[response request] URL] ,NSURLErrorFailingURLErrorKey,
                                       nil];
            
            error = [NSError errorWithDomain:NSURLErrorDomain code:respCode userInfo:errorInfo];
            [self.smRestRequest.requestDelegate request:self.smRestRequest didFailLoadWithError:error];
        }
        
        if ((nil == error) &&
            ([self.smRestRequest.requestDelegate respondsToSelector:@selector(request:didLoadResponse:)]))
        {
            
            if (self.smRestRequest.parseResponse == YES)
            {
                [self.smRestRequest.requestDelegate request:smRestRequest didLoadResponse:jsonResponse];
            }else
            {
                [self.smRestRequest.requestDelegate request:smRestRequest didLoadResponse:response];
            }
            
            [[SMSalesForceRestAPI sharedInstance] removeCurrentRequestsObject:self];
        }
    }
}


- (void)request:(RKRequest*)request didFailLoadWithError:(NSError*)error
{
    // Vipin - 9167
    [request retain];
    @synchronized([self class])
    {
        // let's see if we have an expired session
        NSLog(@"error: %@", error);
        if ([self.smRestRequest.requestDelegate respondsToSelector:@selector(request:didFailLoadWithError:)])
        {
            [self.smRestRequest.requestDelegate request:smRestRequest didFailLoadWithError:error];
        }
        
        //009382
//        if ([request isEqual:rkRequest]) {
//            [rkRequest autorelease];
//            rkRequest = nil;
//        }
       
       [[SMSalesForceRestAPI sharedInstance] removeCurrentRequestsObject:self];
    }

    [request release];
}


- (void)requestDidCancelLoad:(RKRequest*)request
{
     // Vipin - 9167
    [request retain];
    @synchronized([self class])
    {
        if ([self.smRestRequest.requestDelegate respondsToSelector:@selector(requestDidCancelLoad:)])
        {
            [self.smRestRequest.requestDelegate requestDidCancelLoad:self.smRestRequest];
        }
        
        [[SMSalesForceRestAPI sharedInstance] removeCurrentRequestsObject:self];
    }
    [request release];
}


- (void)requestDidTimeout:(RKRequest*)request
{
    // Vipin - 9167
    [request retain];
    @synchronized([self class])
    {
        if ([self.smRestRequest.requestDelegate respondsToSelector:@selector(requestDidTimeout:)])
        {
            [self.smRestRequest.requestDelegate requestDidTimeout:self.smRestRequest];
        }
        [[SMSalesForceRestAPI sharedInstance] removeCurrentRequestsObject:self];
     }
    [request release];
}


/**
 * Sent when a request has uploaded data to the remote site
 */


- (void)request:(RKRequest *)request didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
         // Vipin - 9167
    @synchronized([self class])
    {
        if ([self shouldCancelRequest:request])
        {
            // Ohh we are cancelling the request
            return;
        }
    
        if ([self.smRestRequest.requestDelegate respondsToSelector:@selector(request:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:)])
        {
            [self.smRestRequest.requestDelegate request:self.smRestRequest
                                        didSendBodyData:bytesWritten
                                      totalBytesWritten:totalBytesWritten
                              totalBytesExpectedToWrite:totalBytesExpectedToWrite];
        }
     }
}


/**
 * Sent when request has received data from remote site
 */

- (void)request:(RKRequest*)request didReceiveData:(NSInteger)bytesReceived totalBytesReceived:(NSInteger)totalBytesReceived totalBytesExpectedToReceive:(NSInteger)totalBytesExpectedToReceive
{
         // Vipin - 9167
    @synchronized([self class])
    {
        if ([self shouldCancelRequest:request])
        {
            // Ohh we are cancelling the request
            return;
        }

        if ([self.smRestRequest.requestDelegate respondsToSelector:@selector(request:didReceiveData:totalBytesReceived:totalBytesExpectedToReceive:)])
        {
            [self.smRestRequest.requestDelegate request:self.smRestRequest
                                        didReceiveData:bytesReceived
                                      totalBytesReceived:totalBytesReceived
                              totalBytesExpectedToReceive:totalBytesExpectedToReceive];
        }
     }
}


- (void)requestDidStartLoad:(RKRequest *)request
{
    NSLog(@" requestDidStartLoad - Helper %@", request);
}

@end
