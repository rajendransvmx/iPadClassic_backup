//
//  RestRequest.m
//  ServiceMaxMobile
//
//  Created by Sahana on 27/04/15.
//  Copyright (c) 2015 SivaManne. All rights reserved.
//

#import "RestRequest.h"
#import "SMRestRequest.h"
#import "AFHTTPRequestOperation.h"

NSString * const kSFSessionTokenPrefix   = @"OAuth ";



@interface RestRequest()
@property (atomic, retain)SMRestRequest *smRestRequest;
@end

@implementation RestRequest
- (id)initWithRestRequest:(SMRestRequest *)restRequest
{
    self = [super init];
    
    if (self)
    {
        self.smRestRequest = restRequest;
    }
    return self;
}


+ (RestRequest *)getHelperForRequest:(SMRestRequest *)request
{
    return [[[RestRequest alloc] initWithRestRequest:request] autorelease];
    
}

- (void)dealloc
{
    [self.smRestRequest release]; self.smRestRequest = nil;
    //009382
    // Vipin - 9167
    [super dealloc];
}


- (BOOL)shouldCancelRequest:(SMRestRequest *)request
{
    
    // Vipin - 9167
    @synchronized([self class])
    {
        
       if ([self.smRestRequest shouldCancel])
        {
            // Yes, We have to cancel the request
            return YES;
        }
        
        return NO;
    }
}

-(NSURLRequest *)getUrlRequest
{
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[self getEndPointUrl]];
    
    [urlRequest setHTTPMethod:[self getHttpMethod]];
    
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    
    [urlRequest setValue:@"gzip"      forHTTPHeaderField:@"Accept-Encoding"];
    [urlRequest setTimeoutInterval:[self getTimeOutInterval]];
    
    [self setHeaderParameters:urlRequest];
    
    [self setHttpBodyParameters:urlRequest];
    
    return urlRequest;
}

-(NSString *)getHttpMethod
{
    return self.smRestRequest.method;
}
/*-(NSURL *)getEndPointUrl
{
    NSString *url = [NSString stringWithString:self.smRestRequest.path];
    NSString *reqEndpoint = kSFDefaultDataService;
    if (![url hasPrefix:reqEndpoint])
    {
        url = [NSString stringWithFormat:@"%@%@", reqEndpoint, url];
    }
     NSURL *apiURL = [NSURL URLWithString:url];
    return apiURL;
}*/



-(NSURL*)getEndPointUrl
{
    NSString *attachmentFolder = self.smRestRequest.objectName;
    
   NSString * serverUrl = [self getServerUrl];
    
    NSString *urlStr = [[NSString alloc] initWithFormat:@"%@%@%@/%@/%@",serverUrl, kFileDownloadUrlFromObject, attachmentFolder,  self.smRestRequest.sfId, kFileDownloadUrlBody];
    
    NSURL *apiURL = [NSURL URLWithString:urlStr];

    return apiURL;
}

-(NSUInteger)getTimeOutInterval
{
    NSUInteger requestTimeOut =  60.0;
    if(requestTimeOut < 180)
        requestTimeOut = 180;
    return requestTimeOut;
}

-(void)setHeaderParameters:(NSMutableURLRequest *)urlRequest
{
    NSDictionary *otherHttpHeaders = [self httpHeaderParameters];
    NSArray *allKeys = [otherHttpHeaders allKeys];
    for (NSString *eachKey in allKeys) {
        NSString *eachValue = [otherHttpHeaders objectForKey:eachKey];
        [urlRequest setValue:eachValue forHTTPHeaderField:eachKey];
    }
}


-(void)setHttpBodyParameters:(NSMutableURLRequest *)urlRequest
{
  /*  NSDictionary *httpPostDictionary = [self httpPostBodyParameters];
    if (httpPostDictionary != nil) {
        SBJsonWriter  *parser = [[SBJsonWriter alloc] init];
        NSData *someData =  [parser dataWithObject:httpPostDictionary];
        [urlRequest setValue:@"gzip"      forHTTPHeaderField:@"Content-Encoding"];
        NSData *compressedData = [someData gzipDeflate];
        [urlRequest setHTTPBody:compressedData];
    }*/
    
}
- (void)sendRequestWithDelegate:(id<SMRestRequestDelegate>)delegate
{
 
    self.smRestRequest.requestDelegate = delegate;

    
   NSURLRequest *urlRequest =   [self getUrlRequest];
    
    AFHTTPRequestOperation *requestOp = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    requestOp.responseSerializer = [AFJSONResponseSerializer serializer];
    requestOp.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/octetstream",@"application/json",nil];
    
    
    
    __unsafe_unretained typeof(requestOp) weakRequestOp = requestOp;
    
    requestOp.outputStream = [NSOutputStream outputStreamToFileAtPath:[self fileDownloadPath] append:NO];
    [requestOp setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        
        if ([self shouldCancelRequest:self.smRestRequest]) {
            [weakRequestOp cancel];
        }
        else {
            [self setDownloadProgessWithBytesRead:bytesRead andTotalBytesRead:totalBytesRead andtotalBytesExpectedToRead:totalBytesExpectedToRead];
        }
    }];
    
    [requestOp setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"REQUEST FINISHED FOR: %@", self);
        [self performSelectorInBackground:@selector(didReceiveResponseSuccessfully:) withObject:responseObject];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSInteger code = error.code;
        NSHTTPURLResponse *response =  [error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseErrorKey];
        if (response != nil) {
            code = response.statusCode;
        }
        if(error.code == NSURLErrorCancelled){
            
            [self didRequestCancelError:error andResponse:nil];
        }
        else
        {
            NSLog(@"REQUEST FAILED FOR: %@", self);
            [self didRequestFailedWithError:[NSError errorWithDomain:error.domain code:code userInfo:error.userInfo] andResponse:operation.responseObject];
        }
        
        //if(error.domain isEqualToString:NSURLErrorCancelled)
        
       
    }];
    
   
    [requestOp setShouldExecuteAsBackgroundTaskWithExpirationHandler:^{
        }];
    
    [requestOp start];
    
    
    //make sure we have the latest access token at the moment we send the request
    
 }

-(NSString *)fileDownloadPath
{
     if (self.smRestRequest.requestDelegate != nil && [self.smRestRequest.requestDelegate conformsToProtocol:@protocol(SMRestRequestDelegate)]) {
      
        return  [self.smRestRequest.requestDelegate  getFilePath:self.smRestRequest];
     }
    return nil;
}

- (NSDictionary *)httpHeaderParameters {
    
    @synchronized([self class]){
        
        NSString *oAuthToken = [self getOAuthSessionToken];
        if (oAuthToken != nil) {
            return [NSDictionary dictionaryWithObjectsAndKeys:oAuthToken,@"Authorization",nil];
        }
    }
    return nil;
}

-(NSString *)getOAuthSessionToken{
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * sessionID = [userDefaults objectForKey:ACCESS_TOKEN];

    return [NSString stringWithFormat:@"%@%@", kSFSessionTokenPrefix, sessionID];
}

-(NSString *)getServerUrl{
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *serverUrl =  [userDefaults objectForKey:SERVERURL];
    return serverUrl;
}

-(void)setDownloadProgessWithBytesRead:(NSUInteger)bytesRead andTotalBytesRead:(long long)totalBytesRead andtotalBytesExpectedToRead:(long long)totalBytesExpectedToRead {
    @synchronized([self class]){
        if (self.smRestRequest.requestDelegate != nil && [self.smRestRequest.requestDelegate conformsToProtocol:@protocol(SMRestRequestDelegate)]) {
            [self.smRestRequest.requestDelegate request:self.smRestRequest didReceiveData:bytesRead totalBytesReceived:totalBytesRead totalBytesExpectedToReceive:totalBytesExpectedToRead];
        }
    }
}

#pragma mark -
- (void)didReceiveResponseSuccessfully:(id)responseObject {
    @synchronized([self class]){
        if (self.smRestRequest.requestDelegate != nil && [self.smRestRequest.requestDelegate conformsToProtocol:@protocol(SMRestRequestDelegate)]) {
            [self.smRestRequest.requestDelegate request:self.smRestRequest didLoadResponse:responseObject];
        }
    }
}

- (void)didRequestFailedWithError:(NSError *)error andResponse:(id)someResponseObj {
    @synchronized([self class]){
        if (self.smRestRequest.requestDelegate != nil && [self.smRestRequest.requestDelegate conformsToProtocol:@protocol(SMRestRequestDelegate)]) {
            [self.smRestRequest.requestDelegate request:self.smRestRequest didFailLoadWithError:error];
        }
    }
}
- (void)didRequestCancelError:(NSError *)error andResponse:(id)someResponseObj
{
    @synchronized([self class]){
        if (self.smRestRequest.requestDelegate != nil && [self.smRestRequest.requestDelegate conformsToProtocol:@protocol(SMRestRequestDelegate)]) {
            [self.smRestRequest.requestDelegate requestDidCancelLoad:self.smRestRequest];
        }
    }
}


@end
