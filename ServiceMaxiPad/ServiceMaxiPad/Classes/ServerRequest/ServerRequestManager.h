//
//  ServerRequestManager.h
//  ServiceMaxMobile
//
//  Created by Vipindas on 5/31/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   ServerRequestManager.h
 *  @class  ServerRequestManager
 *
 *  @brief  This class will provides request based on request type, decides the next request based on the current request and sync version.
 *
 *
 *
 *  @author  Vipindas Palli and Shravya Shridhar
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import <Foundation/Foundation.h>
#import "SVMXServerRequest.h"
#import "SyncConstants.h"
#import "RequestParamModel.h"

@interface ServerRequestManager : NSObject

// ...

+ (instancetype) sharedInstance;

+ (instancetype) alloc  __attribute__((unavailable("alloc not available, call sharedInstance instead")));
- (instancetype) init   __attribute__((unavailable("init not available, call sharedInstance instead")));
+ (instancetype) new    __attribute__((unavailable("new not available, call sharedInstance instead")));

// ...


- (RequestType )getNextRequestTypeForCategoryType:(CategoryType)categoryType
                              withPreviousRequest:(SVMXServerRequest *)previousRequest;
- (NSInteger)getConcurrencyCountForRequestType:(RequestType)requestType andCategoryType:(CategoryType)categoryType;

- (SVMXServerRequest*)requestForType:(RequestType)requestType
                        withCategory:(CategoryType)categoryType
                  andPreviousRequest:(SVMXServerRequest *)previousRequest;

- (BOOL)isOptionalRequest:(RequestType)type;
- (BOOL) isTimeLogEnabledForCategoryType :(CategoryType) categoryType;

@end
