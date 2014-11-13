//
//  SMErrorConstants.h
//  ServiceMaxErrorHandlingRnD
//
//  Created by pushpak on 04/08/14.
//  Copyright (c) 2014 Service Max Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 Custom error domain, Network related errors has to come under this domain;
 */
extern NSString *const SMNetworkErrorDomain;
/**
 Custom error domain, database related errors has to come under this domain;
 */
extern NSString *const SMDatabaseErrorDomain;
/**
 Custom error domain, application related errors has to come under this domain;
 example validation errors, UI errors etc.
 */
extern NSString *const SMApplicationErrorDomain;
/**
 Custom error domain, response parsing related errors has to come under this domain;
 */
extern NSString *const SMParserErrorDomain;


/**
 Useful custom keys used inside error user info dictionary.
 */
/**
 used to hold the event name of request of failing request.
 */
extern NSString *const SMErrorEventNameKey;
/**
 used to hold the event type of request of failing request.
 */
extern NSString *const SMErrorEventTypeKey;
/**
 used to hold the response status code.
 */
extern NSString *const SMErrorResponseStatusCodeKey;
/**
 Used to hold the failing sql query.
 */
extern NSString *const SMErrorFailingQueryKey;
/**
 Used to know whether the error is already customized.
 */
extern NSString *const SMErrorIsErrorCustomizedKey;
/**
 Dummy value to the SMErrorIsErrorCustomizedKey.
 */
extern NSString *const SMErrorIsErrorCustomizedValue;
/**
 Used to hold the custom error message.
 */
extern NSString *const SMErrorUserMessageKey;
/**
 Used to hold the flag whether to notify user.
 */
extern NSString *const SMErrorShouldNotifyUserKey;
/**
 Used to hold the title which the alert for error should hold.
 */
extern NSString *const SMErrorTitleKey;
/**
 Used to store the custom category of error.
 */
extern NSString *const SMErrorCategoryKey;
/**
 Used to hold the response data.
*/
extern NSString *const SMResponseDataKey;

/**
 Custom error codes underlying for database error domain is listed in the following enum,
 please update/revise periodically as and when there is a need.
 */
typedef NS_ENUM(NSInteger, SMDatabaseErrorCode)
{
    SMDatabaseNotOpenError = 0,
    SMDatabaseNotFoundError,
    SMDatabaseFaultyQueryError,
    SMDatabaseInvalidSchemaError,
    SMDatabaseCorruptionError,
    /** Add as per need */
};

/**
 Custom error codes underlying for application error domain is listed in the following enum,
 please update/revise periodically as and when there is a need.
 */
typedef NS_ENUM(NSInteger, SMApplicationErrorCode)
{
    SMApplicationValidationError = 0,
    SMApplicationUndefinedError,
    SMApplicationUncaughtExceptionError,
    SMApplicationCrashError,
    SMApplicationCocoaError,
    /** Add as per need */
};

/**
 Custom error codes underlying for Salesforce error domain is listed in the following enum,
 please update/revise periodically as and when there is a need.
 */
typedef NS_ENUM(NSInteger, SMNetworkErrorCode)
{
    SMNetworkSalesforceNamespaceError = 0,
    SMNetworkSalesforceLimitExceedError,
    SMNetworkSalesforceHeapSizeExceedError,
    SMNetworkApexError,
    SMNetworkSalesforceError,
    SMNetworkNSURLError,
    
    SMNetworkInternetConnectivityError,
    
    SMNetworkOuathRequestError,
    SMNetworkOuathRefreshTokenError,
    SMNetworkOuathRevokedError,
    
    SMNetworkUnknownError,
    /** Add as per need */
};

/**
 Custom error codes underlying for parser error domain is listed in the following enum,
 please update/revise periodically as and when there is a need.
 */
typedef NS_ENUM(NSInteger, SMParserErrorCode)
{
    SMParserInvalidJSONError = 0,
    SMParserInvalidDataError,
    /** Add as per need */
};

/**
 The following enum specifies what action needs to be taken for the error.
 */
typedef NS_ENUM(NSInteger, SMErrorActionCategory) {
    
    //Invalid Better to notify user.
    SMErrorActionCategoryInvalid = 0,
    //Retry silently but handle scenario where if retry also fails then don't go to loop.
    SMErrorActionCategoryRetry = 1,
    //Silently get latest access token and retry silently.
    SMErrorActionCategoryAuthenticationReopenSession = 2,
    //Some permission issues. Display to user so that he can configure proerly.
    SMErrorActionCategoryPermissions = 3,
    //Server issue display to user.
    SMErrorActionCategoryServer = 4,
    //Failed due to user action. abort the action and notify user that it was result due to his action.
    SMErrorActionCategoryUserCancelled = 5,
    //Failed due to NSURLErrorDomain error.
    SMErrorActionCategoryNSURLErrorDomain = 6,
    //Have kept this for any unknown action type. Although Invalid category is there. This is in case its unknown.
    SMErrorActionCategoryServiceMaxOther = -1,
};
