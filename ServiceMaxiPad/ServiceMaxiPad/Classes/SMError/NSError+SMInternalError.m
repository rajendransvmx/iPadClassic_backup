//
//  NSError+SMInternalError.m
//  ServiceMaxErrorHandlingRnD
//
//  Created by pushpak on 04/08/14.
//  Copyright (c) 2014 Service Max Inc. All rights reserved.
//
/**
 *  @file NSError+SMInternalError.m
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

#import "NSError+SMInternalError.h"
#import "SMErrorConstants.h"
@implementation NSError (SMInternalError)

- (BOOL)shouldNotifyEndUser {
    
    BOOL notifyUser = YES;
    if ([self isOriginalErrorAlreadyCustomised:self]) {
        NSDictionary *perrorUserInfo = [self userInfo];
        if (perrorUserInfo) {
            if ([perrorUserInfo objectForKey:SMErrorShouldNotifyUserKey]) {
                NSNumber *temp = [perrorUserInfo objectForKey:SMErrorShouldNotifyUserKey];
                notifyUser = temp.boolValue;
            }
        }
    }
    return notifyUser;
}

- (NSString *)errorTitle {
    
    NSString *title = @"Error";
    if ([self isOriginalErrorAlreadyCustomised:self]) {
        NSDictionary *perrorUserInfo = [self userInfo];
        if (perrorUserInfo) {
            if ([perrorUserInfo objectForKey:SMErrorTitleKey]) {
                title = [perrorUserInfo objectForKey:SMErrorTitleKey];
            }
        }
    }
    return title;
}

- (NSString *)errorEndUserMessage {
    
    NSString *userMessage = [self localizedDescription];
    if ([self isOriginalErrorAlreadyCustomised:self]) {
        NSDictionary *perrorUserInfo = [self userInfo];
        if (perrorUserInfo) {
            if ([perrorUserInfo objectForKey:SMErrorUserMessageKey]) {
                userMessage = [perrorUserInfo objectForKey:SMErrorUserMessageKey];
            }
        }
    }
    return userMessage;
}

- (NSInteger)responseStatusCode {
    return 0;
}

- (NSString *)failingQuery {
    
    NSString *failingQuery = @"";
    if ([self isOriginalErrorAlreadyCustomised:self]) {
        NSDictionary *perrorUserInfo = [self userInfo];
        if (perrorUserInfo) {
            if ([perrorUserInfo objectForKey:SMErrorFailingQueryKey]) {
                failingQuery = [perrorUserInfo objectForKey:SMErrorFailingQueryKey];
            }
        }
    }
    return failingQuery;
}

- (instancetype)responseData {
    
    id respData = nil;
    if ([self isOriginalErrorAlreadyCustomised:self]) {
        NSDictionary *perrorUserInfo = [self userInfo];
        if (perrorUserInfo) {
            if ([perrorUserInfo objectForKey:SMResponseDataKey]) {
                respData = [perrorUserInfo objectForKey:SMResponseDataKey];
            }
        }
    }
    return respData;
}

- (NSString *)eventName {
    
    NSString *eventName = @"";
    if ([self isOriginalErrorAlreadyCustomised:self]) {
        NSDictionary *perrorUserInfo = [self userInfo];
        if (perrorUserInfo) {
            if ([perrorUserInfo objectForKey:SMErrorEventNameKey]) {
                eventName = [perrorUserInfo objectForKey:SMErrorEventNameKey];
            }
        }
    }
    return eventName;
}

- (NSString *)eventType {
    
    NSString *eventType = @"";
    if ([self isOriginalErrorAlreadyCustomised:self]) {
        NSDictionary *perrorUserInfo = [self userInfo];
        if (perrorUserInfo) {
            if ([perrorUserInfo objectForKey:SMErrorEventTypeKey]) {
                eventType = [perrorUserInfo objectForKey:SMErrorEventTypeKey];
            }
        }
    }
    return eventType;
}

- (SMErrorActionCategory)actionCategory {
    
    SMErrorActionCategory category = SMErrorActionCategoryInvalid;
    if ([self isOriginalErrorAlreadyCustomised:self]) {
        NSDictionary *perrorUserInfo = [self userInfo];
        if (perrorUserInfo) {
            if ([perrorUserInfo objectForKey:SMErrorCategoryKey]) {
                NSNumber *temp = [perrorUserInfo objectForKey:SMErrorCategoryKey];
                category = temp.integerValue;
            }
        }
    }
    return category;
}

- (BOOL)isCustomized {
    return [self isOriginalErrorAlreadyCustomised:self];
}

- (BOOL)isOriginalErrorAlreadyCustomised:(NSError *)poriginalError
{
    BOOL isCustomised = NO;
    if (!poriginalError) {
        return isCustomised;
    }
    NSDictionary *infoDict = [poriginalError userInfo];
    //Checking whether the customizedKey is set. If its set then we are sure that the error is already customized.
    if ([infoDict objectForKey:SMErrorIsErrorCustomizedKey])
    {
        if ([[infoDict objectForKey:SMErrorIsErrorCustomizedKey] isEqualToString:SMErrorIsErrorCustomizedValue]) {
            isCustomised = YES;
        }
    }
    return isCustomised;
}

@end
