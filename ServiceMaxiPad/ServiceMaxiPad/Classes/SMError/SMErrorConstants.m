//
//  SMErrorConstants.m
//  ServiceMaxErrorHandlingRnD
//
//  Created by pushpak on 04/08/14.
//  Copyright (c) 2014 Service Max Inc. All rights reserved.
//

#import "SMErrorConstants.h"

NSString *const SMNetworkErrorDomain = @"com.servicemax.networkdomain";
NSString *const SMDatabaseErrorDomain = @"com.servicemax.databaseerrordomain";
NSString *const SMApplicationErrorDomain = @"com.servicemax.applicationerrordomain";
NSString *const ParserErrorDomain = @"com.servicemax.parsererrordomain";


NSString *const SMErrorFailingQueryKey = @"SMErrorFailingQueryKey";
NSString *const SMErrorIsErrorCustomizedKey = @"SMErrorIsErrorCustomizedKey";
NSString *const SMErrorIsErrorCustomizedValue = @"This is customized error. Use NSUnderlyingErrorKey to know actual error.";
NSString *const SMErrorEventNameKey = @"SMErrorEventNameKey";
NSString *const SMErrorEventTypeKey = @"SMErrorEventTypeKey";
NSString *const SMErrorResponseStatusCodeKey = @"SMErrorResponseStatusCodeKey";
NSString *const SMErrorUserMessageKey = @"SMErrorUserMessageKey";
NSString *const SMErrorShouldNotifyUserKey = @"SMErrorShouldNotifyUserKey";
NSString *const SMErrorTitleKey = @"SMErrorTitleKey";
NSString *const SMErrorCategoryKey = @"SMErrorCategoryKey";
NSString *const SMResponseDataKey = @"SMResponseDataKey";


