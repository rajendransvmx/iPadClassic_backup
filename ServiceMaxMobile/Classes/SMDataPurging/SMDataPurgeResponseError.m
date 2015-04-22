//
//  SMDataPurgeResponseError.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 1/14/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import "SMDataPurgeResponseError.h"

@implementation SMDataPurgeResponseError

@synthesize errorCode;
@synthesize type;
@synthesize title;
@synthesize message;
@synthesize correctiveAction;
@synthesize userInfoDict;


- (id)initWithTitle:(NSString *)errorTitle
{
    self = [super init];
    if (self)
    {
        self.title = errorTitle;
    }
    return self;
}


- (id)initWithErrorCode:(DPErrorType)code
{
    self = [super init];
    if (self)
    {
        self.errorCode = code;
    }
    return self;
}


- (BOOL)isInternetNotReachableError
{
    if (self.errorCode == DPErrorTypeInternetNotReachableError)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)isDatabaseError
{
    if (self.errorCode == DPErrorTypeDatabaseError)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)isApplicationError
{
    if (self.errorCode == DPErrorTypeApplicationError)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)isSystemError
{
    if (self.errorCode == DPErrorTypeSystemError)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


- (BOOL)isResponseError
{
    if (self.errorCode == DPErrorTypeResponseError)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


- (BOOL)isSoapFault
{
    if (self.errorCode == DPErrorTypeSoapFault)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


- (void)dealloc
{
    [title release];
    [message release];
    [correctiveAction release];
    [type release];
    [userInfoDict release];
    [super dealloc];
    
}
@end
