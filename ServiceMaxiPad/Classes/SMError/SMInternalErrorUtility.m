//
//  SMInternalErrorUtility.m
//  ServiceMaxErrorHandlingRnD
//
//  Created by pushpak on 04/08/14.
//  Copyright (c) 2014 Service Max Inc. All rights reserved.
//

#import "SMInternalErrorUtility.h"
#import "NSError+SMInternalError.h"
#import "StringUtil.h"
#import "TagManager.h"
#import "AppManager.h"
#import "PlistManager.h"

// salesforce error related
NSString * const SMErrorCodeKeyInResponse = @"errorCode";
NSString * const SMErrorMessageKeyInResponse = @"message";

NSString * const SMInvalidSessionID = @"INVALID_SESSION_ID";
// apex error related
NSString * const SMErrorsKeyInResponse = @"errors";
NSString * const SMErrorMessageTypeKeyInResponse = @"messageType";

@implementation SMInternalErrorUtility

#pragma mark -Methods to create new error/wrap old error.

+ (NSMutableDictionary *)getFilledDictionaryWithErrorTitle:(NSString *)pcustomErrorTitle
                                              failingQuery:(NSString *)pfailingQueryString
                                                 eventName:(NSString *)peventNameString
                                                 eventType:(NSString *)peventTypeString
                                        parsedResponseData:(id)presponseData
                                                statusCode:(NSInteger)pstatusCode
                                         customUserMessage:(NSString *)puserMessage
                                             originalError:(NSError *)poriginalError
                                       errorActionCategory:(SMErrorActionCategory)perrorActionCategory
                                          shouldNotifyUser:(BOOL)pshouldNotifyUser {
    
    NSMutableDictionary *customUserInfoDic = [NSMutableDictionary dictionary];
    /** Populating the custom user info dictionary */
    [customUserInfoDic setObject:SMErrorIsErrorCustomizedValue forKey:SMErrorIsErrorCustomizedKey];
    if (pcustomErrorTitle) {
        [customUserInfoDic setObject:pcustomErrorTitle forKey:SMErrorTitleKey];
    }
    if (pfailingQueryString) {
        [customUserInfoDic setObject:pfailingQueryString forKey:SMErrorFailingQueryKey];
    }
    if (peventNameString) {
        [customUserInfoDic setObject:peventNameString forKey:SMErrorEventNameKey];
    }
    if (peventTypeString) {
        [customUserInfoDic setObject:peventTypeString forKey:SMErrorEventTypeKey];
    }
    if (presponseData) {
        [customUserInfoDic setObject:presponseData forKey:SMResponseDataKey];
    }
    [customUserInfoDic setObject:[NSNumber numberWithInteger:pstatusCode] forKey:SMErrorResponseStatusCodeKey];
    if (puserMessage) {
        [customUserInfoDic setObject:puserMessage forKey:SMErrorUserMessageKey];
    }
    if (poriginalError) {
        [customUserInfoDic setObject:poriginalError forKey:NSUnderlyingErrorKey];
    }
    [customUserInfoDic setObject:[NSNumber numberWithInteger:perrorActionCategory] forKey:SMErrorCategoryKey];
    [customUserInfoDic setObject:[NSNumber numberWithBool:pshouldNotifyUser] forKey:SMErrorShouldNotifyUserKey];
    
    return customUserInfoDic;
}

+ (NSError *)getCustomisedErrorWithDomain:(NSString *)pcustomDomain
                                errorCode:(NSInteger)pcustomErrorCode
                               errorTitle:(NSString *)pcustomErrorTitle
                        customUserMessage:(NSString *)puserMessage
                       responseStatusCode:(NSInteger)pstatusCode
                       parsedResponseData:(id)presponseData
                      shouldNotNotifyUser:(BOOL)pnotifyUser
                      errorActionCategory:(SMErrorActionCategory)errorActionCategory
                                eventName:(NSString *)peventNameString
                                eventType:(NSString *)peventTypeString
                             failingQuery:(NSString *)pfailingQueryString
                            originalError:(NSError *)poriginalError {
    
    if ([poriginalError isCustomized]) {
        /**
         Since the original error is already customized, we'll just return the same error without any customization.
         */
        return poriginalError;
    }
    /** Carry on the customization logic here. */
    NSError *ourCustomizedError = nil;
    BOOL shouldNotifyUser = YES;
    if (pnotifyUser == NO)
    {
        shouldNotifyUser = NO;
    }
    NSDictionary *custUserInfo = [SMInternalErrorUtility getFilledDictionaryWithErrorTitle:pcustomErrorTitle
                                                                              failingQuery:pfailingQueryString
                                                                                 eventName:peventNameString
                                                                                 eventType:peventTypeString
                                                                        parsedResponseData:presponseData
                                                                                statusCode:pstatusCode
                                                                         customUserMessage:puserMessage
                                                                             originalError:poriginalError
                                                                       errorActionCategory:errorActionCategory
                                                                          shouldNotifyUser:shouldNotifyUser];
    ourCustomizedError = [NSError errorWithDomain:pcustomDomain
                                             code:pcustomErrorCode
                                         userInfo:custUserInfo];
    return ourCustomizedError;
}

#pragma mark - webservice error methods.

+ (NSError *)checkForErrorInResponse:(id)pparsedResponse
                      withStatusCode:(NSInteger)pstatusCode
                            andError:(NSError *)perror {
    
    NSError *combinedError;
    BOOL isSalesForceError = FALSE;
    BOOL isApexError = FALSE;
    
    if (perror) {
        
        //SalesForceError Scaning
        if (pparsedResponse && [pparsedResponse isKindOfClass:[NSArray class]]) {
            if ([pparsedResponse count] == 1) {
                id potentialError = [pparsedResponse objectAtIndex:0];
                if ([potentialError isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *errorDictionary = (NSDictionary *)potentialError;
                    NSString *potentialErrorCode = errorDictionary[SMErrorCodeKeyInResponse];
                    NSString *potentialErrorMessage  = errorDictionary[SMErrorMessageKeyInResponse];
                    
                    if ([potentialErrorCode isEqualToString:SMInvalidSessionID])
                    {
                        [PlistManager deleteAccessTokenGeneratedTimeEntry];
                        [[AppManager sharedInstance] setApplicationStatus:ApplicationStatusAccessTokenExpired];
                    }
                    
                    if (nil != potentialErrorCode && nil != potentialErrorMessage) {
                        NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey : potentialErrorMessage,
                                                          NSLocalizedFailureReasonErrorKey : potentialErrorCode};
                        combinedError = [NSError errorWithDomain:perror.domain code:perror.code userInfo:errorDictionary];
                        isSalesForceError = TRUE;
                        
                    }
                }
            }
        }
        
        
        
    } else {
        
        //Apex error scanning
        if (pparsedResponse && [pparsedResponse isKindOfClass:[NSDictionary class]]) {
            NSArray *errors = [pparsedResponse objectForKey:SMErrorsKeyInResponse];
            id msgType = [pparsedResponse objectForKey:SMErrorMessageTypeKeyInResponse];
            NSString *messageType;
            if (msgType != nil && msgType != [NSNull null]) {
                messageType = msgType;
            }
            //respError.eventName = self.eventName;
            //respError.errorDomain = SMResponseErrorCodeApex;
            if([errors count] >0)
            {
                NSDictionary * subDict = [errors objectAtIndex:0];
                NSString * errorDescription = [subDict objectForKey:@"correctiveAction"];
                
                
                NSString * errorMsg =  [subDict objectForKey:@"errorTitle"];
                
                if ([StringUtil isStringEmpty:errorMsg]) {
                    errorMsg =  [subDict objectForKey:@"errorMsg"];
                }

                
                NSString * errorType = [subDict objectForKey:@"errorType"];
                
                errorMsg = [errorType stringByAppendingString:errorMsg];
                
                isApexError = YES;
                NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey : errorMsg,
                                                  NSLocalizedRecoverySuggestionErrorKey : errorDescription};
                combinedError = [NSError errorWithDomain:@"" code:0 userInfo: errorDictionary];
                
            }
            else if([messageType isEqualToString:@"ERROR"])
            {
                NSString * errorMsg = [pparsedResponse objectForKey:@"message"];
                combinedError = [NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey: errorMsg}];
                isApexError = YES;
            }
            
        }
        
    }
    
    
    if (combinedError)
    {
        /** Populate the error accordingly */
        if (isSalesForceError)
        {
            if ([SMInternalErrorUtility isSessionTimeOutError:combinedError])
            {
                NSError *resultingError = [SMInternalErrorUtility getCustomisedErrorWithDomain:SMNetworkErrorDomain
                                                                                     errorCode:SMNetworkOuathRefreshTokenError
                                                                                    errorTitle:[[TagManager sharedInstance]tagByName:kTagSyncErrorMessage]
                                                                             customUserMessage:[[TagManager sharedInstance]tagByName:kTag_SessionExpireMsg]
                                                                            responseStatusCode:pstatusCode
                                                                            parsedResponseData:pparsedResponse
                                                                           shouldNotNotifyUser:NO
                                                                           errorActionCategory:SMErrorActionCategoryAuthenticationReopenSession
                                                                                     eventName:nil
                                                                                     eventType:nil
                                                                                  failingQuery:nil
                                                                                 originalError:combinedError];
               // NSLog(@"session invalid error identified");
                return resultingError;
            }else
            {
                NSError *resultingError = [SMInternalErrorUtility getCustomisedErrorWithDomain:SMNetworkErrorDomain
                                                                                     errorCode:SMNetworkSalesforceError
                                                                                    errorTitle:[[TagManager sharedInstance]tagByName:kTagSyncErrorMessage]
                                                                             customUserMessage:combinedError.localizedDescription
                                                                            responseStatusCode:pstatusCode
                                                                            parsedResponseData:pparsedResponse
                                                                           shouldNotNotifyUser:YES
                                                                           errorActionCategory:SMErrorActionCategoryServer
                                                                                     eventName:nil
                                                                                     eventType:nil
                                                                                  failingQuery:nil
                                                                                 originalError:combinedError];
                //NSLog(@"Some error from server. SalesforceError");
                return resultingError;
                
            }
            
        } else if (isApexError) {
            
            NSError *resultingError = [SMInternalErrorUtility getCustomisedErrorWithDomain:SMNetworkErrorDomain
                                                                                 errorCode:SMNetworkApexError
                                                                                errorTitle:[[TagManager sharedInstance]tagByName:kTagSyncErrorMessage]
                                                                         customUserMessage:combinedError.localizedDescription
                                                                        responseStatusCode:pstatusCode
                                                                        parsedResponseData:pparsedResponse
                                                                       shouldNotNotifyUser:YES
                                                                       errorActionCategory:SMErrorActionCategoryServer
                                                                                 eventName:nil
                                                                                 eventType:nil
                                                                              failingQuery:nil
                                                                             originalError:combinedError];
            //NSLog(@"Some error from server. Apex Error");
            return resultingError;
            
        }
        
        return combinedError;
    }
    else if (perror)
    {
        
        if ([SMInternalErrorUtility isSessionTimeOutError:perror])
        {
            NSError *resultingError = [SMInternalErrorUtility getCustomisedErrorWithDomain:SMNetworkErrorDomain
                                                                                 errorCode:SMNetworkOuathRefreshTokenError
                                                                                errorTitle:[[TagManager sharedInstance]tagByName:kTagSyncErrorMessage]
                                                                         customUserMessage:[[TagManager sharedInstance]tagByName:kTag_SessionExpireMsg]
                                                                        responseStatusCode:pstatusCode
                                                                        parsedResponseData:pparsedResponse
                                                                       shouldNotNotifyUser:NO
                                                                       errorActionCategory:SMErrorActionCategoryAuthenticationReopenSession
                                                                                 eventName:nil
                                                                                 eventType:nil
                                                                              failingQuery:nil
                                                                             originalError:perror];
            // NSLog(@"session invalid error identified");
            return resultingError;
        }
        
        NSError *resultingError;
        //Checking for NSURLErrorDomain error.
        resultingError = [SMInternalErrorUtility checkAndGetCustomizedErrorIfGivenErrorIsOfTypeNSURLErrorDomain:perror];
        if (resultingError == nil)
        {
            //Didn't find NSURLErrorDomain.
            resultingError = [SMInternalErrorUtility getCustomisedErrorWithDomain:SMNetworkErrorDomain
                                                                        errorCode:SMNetworkUnknownError
                                                                       errorTitle:[[TagManager sharedInstance]tagByName:kTagSyncErrorMessage]
                                                                customUserMessage:[perror localizedDescription]
                                                               responseStatusCode:pstatusCode
                                                               parsedResponseData:pparsedResponse
                                                              shouldNotNotifyUser:YES
                                                              errorActionCategory:SMErrorActionCategoryServer
                                                                        eventName:nil
                                                                        eventType:nil
                                                                     failingQuery:nil
                                                                    originalError:perror];
            
        }
        return resultingError;
    }
    return nil;
}

+ (BOOL)isSessionTimeOutError:(NSError *)perror {
    if (nil == perror) {
        return NO;
    }
    //Check for INVALID_SESSION
    id obj = [[perror userInfo] objectForKey:SMErrorCodeKeyInResponse];
    if(obj) {
        if ([SMInvalidSessionID isEqualToString:obj] || [obj rangeOfString:SMInvalidSessionID].length > 0) {
            return YES;
        }
    }
    if (perror.code == 401 || perror.code == kCFURLErrorUserCancelledAuthentication) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSError *)checkAndGetCustomizedErrorIfGivenErrorIsOfTypeNSURLErrorDomain:(NSError *)perror {
    if (perror == nil || ![perror.domain isEqualToString:NSURLErrorDomain]) {
        return nil;
    }
    SMErrorActionCategory category = SMErrorActionCategoryNSURLErrorDomain;
    NSString *userMessage = [perror localizedDescription];
    SMNetworkErrorCode errorCode = SMNetworkNSURLError;
    
    switch ([perror code])
    {
        case NSURLErrorUnknown: //-1,
            break;
        case NSURLErrorCancelled: //-999,
            break;
        case NSURLErrorBadURL: //-1000,
            break;
        case NSURLErrorTimedOut: //-1001,
            category = SMErrorActionCategoryRetry;
            break;
        case NSURLErrorUnsupportedURL: //-1002,
            break;
        case NSURLErrorCannotFindHost: //-1003,
            break;
        case NSURLErrorCannotConnectToHost: //-1004,
            break;
        case NSURLErrorDataLengthExceedsMaximum: //-1103,
            break;
        case NSURLErrorNetworkConnectionLost: //-1005,
            category = SMErrorActionCategoryRetry;
            errorCode = SMNetworkInternetConnectivityError;
            
            break;
        case NSURLErrorDNSLookupFailed: //-1006,
            break;
        case NSURLErrorHTTPTooManyRedirects: //-1007,
            break;
        case NSURLErrorResourceUnavailable: //-1008,
            break;
        case NSURLErrorNotConnectedToInternet: //-1009,
            break;
        case NSURLErrorRedirectToNonExistentLocation: //-1010,
            break;
        case NSURLErrorBadServerResponse: //-1011,
            break;
      //  case NSURLErrorUserCancelledAuthentication: //-1012, Taken care in session error
            break;
        case NSURLErrorUserAuthenticationRequired: //-1013,
            break;
        case NSURLErrorZeroByteResource: //-1014,
            break;
        case NSURLErrorCannotDecodeRawData: //-1015,
            break;
        case NSURLErrorCannotDecodeContentData: //-1016,
            break;
        case NSURLErrorCannotParseResponse: //-1017,
            break;
        case NSURLErrorInternationalRoamingOff: //-1018,
            break;
        case NSURLErrorCallIsActive: //-1019,
            break;
        case NSURLErrorDataNotAllowed: //-1020,
            break;
        case NSURLErrorRequestBodyStreamExhausted: //-1021,
            break;
        case NSURLErrorFileDoesNotExist: //-1100,
            break;
        case NSURLErrorFileIsDirectory: //-1101,
            break;
        case NSURLErrorNoPermissionsToReadFile: //-1102,
            break;
        case NSURLErrorSecureConnectionFailed: //-1200,
            break;
        case NSURLErrorServerCertificateHasBadDate: //-1201,
            break;
        case NSURLErrorServerCertificateUntrusted: //-1202,
            break;
        case NSURLErrorServerCertificateHasUnknownRoot: //-1203,
            break;
        case NSURLErrorServerCertificateNotYetValid: //-1204,
            break;
        case NSURLErrorClientCertificateRejected: //-1205,
            break;
        case NSURLErrorClientCertificateRequired: //-1206,
            break;
        case NSURLErrorCannotLoadFromNetwork: //-2000,
            break;
        case NSURLErrorCannotCreateFile: //-3000,
            break;
        case NSURLErrorCannotOpenFile: //-3001,
            break;
        case NSURLErrorCannotCloseFile: //-3002,
            break;
        case NSURLErrorCannotWriteToFile: //-3003,
            break;
        case NSURLErrorCannotRemoveFile: //-3004,
            break;
        case NSURLErrorCannotMoveFile: //-3005,
            break;
        case NSURLErrorDownloadDecodingFailedMidStream: //-3006,
            break;
        case NSURLErrorDownloadDecodingFailedToComplete: //-3007
            break;
        default:
            break;
    }
    NSError *resultingError = [SMInternalErrorUtility getCustomisedErrorWithDomain:SMNetworkErrorDomain
                                                                         errorCode:errorCode
                                                                        errorTitle:@"NSURL Error"
                                                                 customUserMessage:userMessage
                                                                responseStatusCode:0
                                                                parsedResponseData:nil
                                                               shouldNotNotifyUser:YES
                                                               errorActionCategory:category
                                                                         eventName:nil
                                                                         eventType:nil
                                                                      failingQuery:nil
                                                                     originalError:perror];
    
    return resultingError;
}

+ (NSError *)checkAndGetCustomizedErrorIfGivenErrorIsOfTypeNSCocoaErrorDomain:(NSError *)perror {
    if (perror == nil || ![perror.domain isEqualToString:NSCocoaErrorDomain]) {
        return nil;
    }
    SMErrorActionCategory category = SMErrorActionCategoryServiceMaxOther;
    
    NSString *userMessage = [perror localizedDescription];
    SMApplicationErrorCode errorCode = SMApplicationCocoaError;
    
    switch ([perror code])
    {
            
            case NSFileNoSuchFileError://4,
            break;
            case NSFileLockingError://255,
            break;
            case NSFileReadUnknownError://256,
            break;
            case NSFileReadNoPermissionError://257,
            break;
            case NSFileReadInvalidFileNameError://258,
            break;
            case NSFileReadCorruptFileError://259,
            break;
            case NSFileReadNoSuchFileError://260,
            break;
            case NSFileReadInapplicableStringEncodingError://261,
            break;
            case NSFileReadUnsupportedSchemeError://262,
            break;
            case NSFileReadTooLargeError://263,
            break;
            case NSFileReadUnknownStringEncodingError://264,
            break;
            case NSFileWriteUnknownError://512,
            break;
            case NSFileWriteNoPermissionError://513,
            break;
            case NSFileWriteInvalidFileNameError://514,
            break;
            case NSFileWriteFileExistsError://516,
            break;
            case NSFileWriteInapplicableStringEncodingError://517,
            break;
            case NSFileWriteUnsupportedSchemeError://518,
            break;
            case NSFileWriteOutOfSpaceError://640,
            break;
            case NSFileWriteVolumeReadOnlyError://642,
            break;
            case NSKeyValueValidationError://1024,
            break;
            case NSFormattingError://2048,
            break;
            case NSUserCancelledError://3072,
            break;
            
            case NSFileErrorMinimum://0,
            break;
            case NSFileErrorMaximum://1023,
            break;
            //case NSValidationErrorMinimum://1024,
            //break;
            case NSValidationErrorMaximum://2047,
            break;
            //case NSFormattingErrorMinimum://2048,
            //break;
            case NSFormattingErrorMaximum://2559,
            break;
            
            case NSPropertyListReadCorruptError://3840,
            break;
            case NSPropertyListReadUnknownVersionError://3841,
            break;
            case NSPropertyListReadStreamError://3842,
            break;
            case NSPropertyListWriteStreamError://3851,
            break;
            //case NSPropertyListErrorMinimum://3840,
            //break;
            case NSPropertyListErrorMaximum://4095
            break;
            
            case NSExecutableErrorMinimum://3584,
            break;
            //case NSExecutableNotLoadableError://3584,
            //break;
            case NSExecutableArchitectureMismatchError://3585,
            break;
            case NSExecutableRuntimeMismatchError://3586,
            break;
            case NSExecutableLoadError://3587,
            break;
            case NSExecutableLinkError://3588,
            break;
            case NSExecutableErrorMaximum://3839,
            break;
        default:
            break;
            
    }
    NSError *resultingError = [SMInternalErrorUtility getCustomisedErrorWithDomain:SMApplicationErrorDomain
                                                                         errorCode:errorCode
                                                                        errorTitle:@"Application Error"
                                                                 customUserMessage:userMessage
                                                                responseStatusCode:0
                                                                parsedResponseData:nil
                                                               shouldNotNotifyUser:YES
                                                               errorActionCategory:category
                                                                         eventName:nil
                                                                         eventType:nil
                                                                      failingQuery:nil
                                                                     originalError:perror];
    
    return resultingError;
    
}
@end
