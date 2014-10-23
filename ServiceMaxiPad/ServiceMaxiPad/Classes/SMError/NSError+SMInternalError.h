//
//  NSError+SMInternalError.h
//  ServiceMaxErrorHandlingRnD
//
//  Created by pushpak on 04/08/14.
//  Copyright (c) 2014 Service Max Inc. All rights reserved.
//
/**
 *  @file NSError+SMInternalError.h
 *  @class NSError (SMInternalError)
 *
 *  @brief Category on NSError class to enhance the same class for supporting our application. 
 *    All properties in this class gets their values from error info dictionary.
 *    If they don't exist then default values are returned.
 *
 *  @author Pushpak
 *
 *  @bug No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import <Foundation/Foundation.h>
#import "SMErrorConstants.h"

@interface NSError (SMInternalError)

@property (readonly) BOOL shouldNotifyEndUser;
@property (readonly, copy) NSString *errorTitle;
@property (readonly, copy) NSString *errorEndUserMessage;
@property (readonly, copy) NSString *failingQuery;
@property (readonly) NSInteger responseStatusCode;
@property (readonly) id responseData;
@property (readonly, copy) NSString *eventName;
@property (readonly, copy) NSString *eventType;
@property (readonly) BOOL isCustomized;
@property (readonly) SMErrorActionCategory actionCategory;

@end
