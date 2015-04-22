//
//  AsyncImageLoader.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 12/01/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "AsyncImageLoader.h"
#import "AsyncImageDownload.h"
#import "FileManager.h"
#import "CustomerOrgInfo.h"
#import "SNetworkReachabilityManager.h"
#import "ChatterHelper.h"

@interface  AsyncImageLoader ()

@property(nonatomic, strong)NSMutableDictionary *connections;

@end

@implementation AsyncImageLoader

#pragma mark Singleton Methods

+ (instancetype) sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super alloc] initInstance];
    });
    return sharedInstance;
}

- (instancetype) initInstance {
    self = [super init];
    // Do any other initialisation stuff here
    // ...
    _connections = [NSMutableDictionary new];
    _oAuthId = [[CustomerOrgInfo sharedInstance] accessToken];
    return self;
}

- (void)updateOauthId
{
    if (!self.oAuthId) {
        self.oAuthId = [[CustomerOrgInfo sharedInstance] accessToken];
    }
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

- (void)loadImageWithURL:(NSString *)urlString target:(id)target success:(SEL)success failure:(SEL)failure
{
    
}
- (void)loadImageWithURL:(NSString *)urlString userId:(NSString *)userId
{
    AsyncImageDownload *imageDownload = [[AsyncImageDownload alloc] initWithURL:urlString
                                                                         userId:userId];
    if (!self.connections) {
        self.connections = [NSMutableDictionary new];
    }
    if (imageDownload && urlString) {
        [self.connections setObject:imageDownload forKey:urlString];
        [imageDownload start];
    }
}

- (BOOL)isRequestFiredForUrl:(NSString *)urlString userId:(NSString *)userId
{
    BOOL result = NO;
    
    if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable]) {
        if ([self.connections objectForKey:urlString]) {
            
            result  = NO;
        }
        else if (![ChatterHelper shouldRefreshImage:userId]) {
            
            result = YES;
        }
        else {
            [self updateOauthId];
            [self cancelConnection:urlString];
            [self loadImageWithURL:urlString userId:userId];
        }
    }
    else {
        result = YES;
    }
    return result;
}

- (void)cancelAllRequests
{
    NSArray *allKeys = [self.connections allKeys];
    
    for (NSString *url in allKeys) {
        AsyncImageDownload *connection = [self.connections objectForKey:url];
        [connection cancel];
    }
    self.connections = nil;
    self.oAuthId = nil;
}

- (void)removeRequestObj:(NSString *)urlKey
{
    NSLog(@"%@", urlKey);
    if (urlKey) {
        [self.connections removeObjectForKey:urlKey];
    }
}


- (void)cancelConnection:(NSString *)urlKey
{
    NSLog(@"%@", urlKey);
    if (urlKey && [self.connections count] > 0) {
        AsyncImageDownload *connection = [self.connections objectForKey:urlKey];
        [connection cancel];
        [self.connections removeObjectForKey:urlKey];
    }
}

@end
