//
//  AsyncImageLoader.h
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 12/01/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AsyncImageLoader : NSObject

@property(nonatomic, strong)NSString *oAuthId;

+ (instancetype) alloc  __attribute__((unavailable("alloc not available, call sharedInstance instead")));
- (instancetype) init   __attribute__((unavailable("init not available, call sharedInstance instead")));
+ (instancetype) new    __attribute__((unavailable("new not available, call sharedInstance instead")));


+ (instancetype)sharedInstance;

- (void)loadImageWithURL:(NSString *)urlString target:(id)target success:(SEL)success failure:(SEL)failure;
- (BOOL)isRequestFiredForUrl:(NSString *)urlString userId:(NSString *)userId;

- (void)cancelAllRequests;
- (void)removeRequestObj:(NSString *)urlKey;

- (void)updateOauthId;

@end
