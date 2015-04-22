//
//  SMRestRequest.h
//  iService
//
//  Created by Vipindas on 11/16/13.
//
//

#import <Foundation/Foundation.h>
#import "RKClient.h"

extern NSString * const kSFDefaultDataService;

@class SMRestRequest;

@protocol SMRestRequestDelegate <NSObject>

@optional

/**
 * Sent when a request has finished loading
 */
- (void)request:(SMRestRequest *)request didLoadResponse:(RKResponse *)response;

/**
 * Sent when a request has failed due to an error
 */
- (void)request:(SMRestRequest *)request didFailLoadWithError:(NSError *)error;

/**
 * Sent when a request has started loading
 */
- (void)requestDidStartLoad:(SMRestRequest *)request;

/**
 * Sent when a request has uploaded data to the remote site
 */
- (void)request:(SMRestRequest *)request didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite;

/**
 * Sent when request has received data from remote site
 */
- (void)request:(SMRestRequest*)request didReceiveData:(NSInteger)bytesReceived totalBytesReceived:(NSInteger)totalBytesReceived totalBytesExpectedToReceive:(NSInteger)totalBytesExpectedToReceive;

/**
 * Sent to the delegate when a request was cancelled
 */
- (void)requestDidCancelLoad:(SMRestRequest *)request;

/**
 * Sent to the delegate when a request has timed out. This is sent when a
 * backgrounded request expired before completion.
 */
- (void)requestDidTimeout:(SMRestRequest *)request;

@end


//------------------********************************************************---------------------//


@interface SMRestRequest : NSObject
{
   
}

@property (nonatomic,  copy)   NSString *instanceUrlString;
@property (nonatomic,  copy)   NSString *path;
@property (nonatomic,  assign) id<SMRestRequestDelegate> requestDelegate;
@property (nonatomic,  assign) RKRequestMethod method;
@property (nonatomic,  retain) NSDictionary *parameters;
@property (nonatomic,  assign) BOOL parseResponse;
@property (nonatomic,  assign) BOOL shouldCancel;


/* Constructors */
- (id)initWithInstaceURLString:(NSString *)urlString;

- (id)initWithMethod:(RKRequestMethod )methodName path:(NSString *)pathName andParameters:(NSDictionary *)parameters;

- (void)cancelRequest;

@end
