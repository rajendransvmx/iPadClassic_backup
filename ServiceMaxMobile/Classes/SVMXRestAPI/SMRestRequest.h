//
//  SMRestRequest.h
//  iService
//
//  Created by Vipindas on 11/16/13.
//
//

#import <Foundation/Foundation.h>

extern NSString * const kSFDefaultDataService;

@class SMRestRequest;

@protocol SMRestRequestDelegate <NSObject>

@optional

/**
 * Sent when a request has finished loading
 */
- (void)request:(SMRestRequest *)request didLoadResponse:(id)response;

/**
 * Sent when a request has failed due to an error
 */
- (void)request:(SMRestRequest *)request didFailLoadWithError:(NSError *)error;



/**
 * Sent when request has received data from remote site
 */
- (void)request:(SMRestRequest*)request didReceiveData:(NSInteger)bytesReceived totalBytesReceived:(NSInteger)totalBytesReceived totalBytesExpectedToReceive:(NSInteger)totalBytesExpectedToReceive;

- (NSString *)getFilePath:(SMRestRequest *)request;


@end


//------------------********************************************************---------------------//


@interface SMRestRequest : NSObject
{
   
}

@property (nonatomic,  copy)   NSString *instanceUrlString;
@property (nonatomic,  copy)   NSString *path;
@property (nonatomic,  assign) id<SMRestRequestDelegate> requestDelegate;
@property (nonatomic,  assign) id method;
@property (nonatomic,  retain) NSDictionary *parameters;
@property (nonatomic,  assign) BOOL parseResponse;
@property (nonatomic,  assign) BOOL shouldCancel;
@property (nonatomic,  assign) NSString *objectName;
@property (nonatomic,  assign) NSString *sfId;


/* Constructors */
- (id)initWithInstaceURLString:(NSString *)urlString;

- (id)initWithMethod:(id )methodName path:(NSString *)pathName andParameters:(NSDictionary *)parameters;
- (id)initWithMethod:(id )methodName objectName:(NSString *)objectName andSfId:(NSString *)sfId;


- (void)cancelRequest;

@end


#define kFileDownloadUrlFromObject  @"/services/data/v26.0/sobjects/"
#define kFileDownloadUrlBody       @"Body"
