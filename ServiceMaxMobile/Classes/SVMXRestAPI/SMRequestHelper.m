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
    [super dealloc];
}


+ (NSObject<RKRequestSerializable>*)formatParamsAsJson:(NSDictionary *)queryParams
{
    if (!([queryParams count] > 0))
        return nil;

    NSData *data = [SFJsonUtils JSONDataRepresentation:queryParams];
    return [RKRequestSerialization serializationWithData:data MIMEType:@"application/json"];
}


- (NSString *)sessionTokenWithPrefix
{
    NSString *sessionToken = [[SMConnectionManager sharedInstance] sessionToken];
    
    NSLog(@" -----  sessionToken   ------  %@", sessionToken);
    if ((nil == sessionToken)
        || (![sessionToken isKindOfClass:[NSString class]]))
    {
        [SMConnectionManager sharedInstance].sessionToken = nil;
         
        [[SMConnectionManager sharedInstance] refreshConnectionInfo];
        sessionToken = [[SMConnectionManager sharedInstance] sessionToken];
    }
    
    return [NSString stringWithFormat:@"%@%@", kSFSessionTokenPrefix, sessionToken];
}


- (BOOL)shouldCancelRequest:(RKRequest *)request
{
    if ([self.smRestRequest shouldCancel])
    {
        // Yes, We have to cancel the request
        
        [request cancel];
        request.delegate = nil;
        return YES;
    }
    
    return NO;
}

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
    
    //make sure we have the latest access token at the moment we send the request

    [rkClient setValue:[self sessionTokenWithPrefix] forHTTPHeaderField:@"Authorization"];
    
    if (self.smRestRequest.method == RKRequestMethodGET)
    {
        [rkClient get:url queryParameters:self.smRestRequest.parameters delegate:self];
    }
    else if (self.smRestRequest.method == RKRequestMethodDELETE)
    {
        [rkClient delete:url delegate:self];
    }
    else if (self.smRestRequest.method == RKRequestMethodPUT)
    {
        [rkClient put:url params:[[self class] formatParamsAsJson:smRestRequest.parameters] delegate:self];
    }
    else if (smRestRequest.method == RKRequestMethodPOST)
    {
        [rkClient post:url params:[[self class] formatParamsAsJson:smRestRequest.parameters] delegate:self];
    }
}

#pragma mark - RKRequestDelegate


- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response
{
    
    NSError *error = nil;
    
    if ([self shouldCancelRequest:request])
    {
        // Ohh we are cancelling the request
        return;
    }
    
     NSLog(@" All Response status Code   -- %d ", [response statusCode]);
     NSLog(@" All Response content Type  -- %@ ", [response contentType]);
     NSLog(@" All Response Error   -- %@ ", [[response failureError] description]);
    
    // token has expired ?
    if ([response isUnauthorized])
    {
        NSLog(@"Got unauthorized response");
        
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
            
            NSLog(@" Response status Code   -- %d ", [response statusCode]);
            NSLog(@" JSON response parsing  -- %@ ", jsonResponse);
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
    }
    [[SMSalesForceRestAPI sharedInstance] removeCurrentRequestsObject:self];
}


- (void)request:(RKRequest*)request didFailLoadWithError:(NSError*)error
{
    // let's see if we have an expired session
    NSLog(@"error: %@", error);
    if ([self.smRestRequest.requestDelegate respondsToSelector:@selector(request:didFailLoadWithError:)])
    {
        [self.smRestRequest.requestDelegate request:smRestRequest didFailLoadWithError:error];
    }
    [[SMSalesForceRestAPI sharedInstance] removeCurrentRequestsObject:self];
}


- (void)requestDidCancelLoad:(RKRequest*)request
{
    if ([self.smRestRequest.requestDelegate respondsToSelector:@selector(requestDidCancelLoad:)])
    {
        [self.smRestRequest.requestDelegate requestDidCancelLoad:smRestRequest];
    }
    [[SMSalesForceRestAPI sharedInstance] removeCurrentRequestsObject:self];
}


- (void)requestDidTimeout:(RKRequest*)request
{
    if ([self.smRestRequest.requestDelegate respondsToSelector:@selector(requestDidTimeout:)])
    {
        [self.smRestRequest.requestDelegate requestDidTimeout:request];
    }
    [[SMSalesForceRestAPI sharedInstance] removeCurrentRequestsObject:self];
}


/**
 * Sent when a request has uploaded data to the remote site
 */


- (void)request:(RKRequest *)request didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    
    if ([self shouldCancelRequest:request])
    {
        // Ohh we are cancelling the request
        return;
    }
    
    NSLog(@"didSendBodyData - bytesWritten = %d, totalBytesWritten = %d",bytesWritten,totalBytesWritten);
    
    if ([self.smRestRequest.requestDelegate respondsToSelector:@selector(request:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:)])
    {
        [self.smRestRequest.requestDelegate request:self.smRestRequest
                                    didSendBodyData:bytesWritten
                                  totalBytesWritten:totalBytesWritten
                          totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}


/**
 * Sent when request has received data from remote site
 */

- (void)request:(RKRequest*)request didReceiveData:(NSInteger)bytesReceived totalBytesReceived:(NSInteger)totalBytesReceived totalBytesExpectedToReceive:(NSInteger)totalBytesExpectedToReceive
{
    /*
    long long int  x = (bytesReceived/1);
    long long int  y = (totalBytesReceived/1);
    long long int  z = (totalBytesExpectedToReceive/1);
    */
   // NSLog(@"didReceiveData -    %lld - %lld - %lld", x, y, z);
    
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


- (void)requestDidStartLoad:(RKRequest *)request
{
    NSLog(@"--------------- requestDidStartLoad Request Delegate----------------------");
    
    NSData *dat =  [request HTTPBody];
    NSString *bodyString =  [request HTTPBodyString];
    
    
    NSLog(@" Request Path          %@",request.resourcePath);
    
    NSLog(@" Request Body data   : %@ ", [[NSString alloc] initWithData:dat
                                                               encoding:NSUTF8StringEncoding]);
    NSLog(@" Request Body String : %@ ", bodyString);
    NSLog(@" Request HTTPHeaders : %@ ", [[request additionalHTTPHeaders] description]);
    NSLog(@" Request method      : %@ ", [request HTTPMethod]);
}

@end
