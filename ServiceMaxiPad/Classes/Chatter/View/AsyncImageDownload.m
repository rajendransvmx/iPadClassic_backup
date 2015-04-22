//
//  AsyncImageDownload.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 12/01/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "AsyncImageDownload.h"
#import "StringUtil.h"
#import "AsyncImageLoader.h"
#import "FileManager.h"
#import "UserImageModel.h"
#import "ChatterHelper.h"

@implementation AsyncImageConnection

@end

@interface AsyncImageDownload () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property(nonatomic, strong)AsyncImageConnection *connection;
@property(nonatomic, strong)NSMutableData *data;


@end

@implementation AsyncImageDownload

- (instancetype )initWithURL:(NSString *)URL userId:(NSString *)userId
{
    if ((self = [self init])) {
        self.urlString = URL;
        self.userId = userId;
    }
    return self;
}

- (void)start
{
    NSString * fullPhotoUrlRequest = [NSString stringWithFormat:@"%@?oauth_token=%@", self.urlString,
                                      [AsyncImageLoader sharedInstance].oAuthId];
    
    NSURL *url = [NSURL URLWithString:fullPhotoUrlRequest];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:[self timeOutForRequest]];
    
    self.connection = [[AsyncImageConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    self.connection.userId = self.userId;
    self.connection.photoUrl = self.urlString;
    [self.connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [self.connection start];
}

- (NSInteger)timeOutForRequest
{
    NSInteger requestTimeOutInSec = 180;
    NSString *stringValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"reqTimeout_Setting"];
    NSInteger requestTimeOut = 0;
    if ([StringUtil isStringEmpty:stringValue])
    {
        requestTimeOut = [stringValue integerValue];
        requestTimeOutInSec = requestTimeOut * 60;
    }
    return requestTimeOutInSec;
}

- (void)cancel
{
    [self.connection cancel];
    self.connection = nil;
}

- (BOOL)writeData:(NSData *)data toFilePath:(NSString *)filePath {
    return   [data writeToFile:filePath atomically:YES];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
{
    self.data = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
{
    [self.data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
{
    AsyncImageConnection *asyncImage = (AsyncImageConnection *)connection;
    
    [[AsyncImageLoader sharedInstance] removeRequestObj:asyncImage.photoUrl];
    
    if ([self isValidData:self.data]) {
        //[self writeData:self.data toFilePath:[FileManager getChatterRelatedFilePath:asyncImage.userId]];
        [self updateImageToDataBase:self.data userId:asyncImage.userId];
    }
    [self performSelectorOnMainThread:@selector(postNotification) withObject:nil waitUntilDone:YES];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    AsyncImageConnection *asyncImage = (AsyncImageConnection *)connection;
    
    [[AsyncImageLoader sharedInstance] removeRequestObj:asyncImage.photoUrl];
    
    [self performSelectorOnMainThread:@selector(postNotification) withObject:nil waitUntilDone:YES];
}

- (BOOL)isValidData:(NSData *)data
{
    BOOL result = NO;
    
    if (self.data) {
        
        if ([UIImage imageWithData:self.data] != nil) {
            result = YES;
        }
    }
    return result;
}

- (void)postNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ImageDownloaded"
                                                        object:nil
                                                      userInfo:nil];
}

- (void)updateImageToDataBase:(NSData *)data userId:(NSString *)userId
{
    if (data) {
        UserImageModel *model = [[UserImageModel alloc] init];
        model.Id = userId;
        model.userimage = data;
        model.shouldRefresh = FALSE;

        [ChatterHelper updateUserImage:model];
    }
}

@end
