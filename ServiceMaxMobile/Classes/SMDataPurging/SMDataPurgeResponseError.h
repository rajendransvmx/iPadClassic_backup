//
//  SMDataPurgeResponseError.h
//  ServiceMaxMobile
//
//  Created by Vipindas on 1/14/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum DPErrorType
{
    DPErrorTypeUnknownError = -1,
    DPErrorTypeInternetNotReachableError = 1,
    DPErrorTypeDatabaseError = 2,
    DPErrorTypeApplicationError = 3,
    DPErrorTypeSystemError = 4,
    DPErrorTypeResponseError = 5,
    DPErrorTypeSoapFault = 6,
}DPErrorType;


@interface SMDataPurgeResponseError : NSObject

@property (nonatomic, assign)DPErrorType     errorCode;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *correctiveAction;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, retain) NSMutableDictionary *userInfoDict;

- (id)initWithTitle:(NSString *)errorTitle;
- (id)initWithErrorCode:(DPErrorType)code;

- (BOOL)isInternetNotReachableError;
- (BOOL)isDatabaseError;
- (BOOL)isApplicationError;
- (BOOL)isSystemError;
- (BOOL)isResponseError;
- (BOOL)isSoapFault;

@end
