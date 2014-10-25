//
//  SMInternalErrorUtility.h
//  ServiceMaxErrorHandlingRnD
//
//  Created by pushpak on 04/08/14.
//  Copyright (c) 2014 Service Max Inc. All rights reserved.
//
/**
 *  @file SMInternalErrorUtility.h
 *  @class SMInternalErrorUtility
 *
 *  @brief Class to act as helper to populate the apple default error with additional values that our custom error category uses.
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

@interface SMInternalErrorUtility : NSObject
/**
 * @name checkForErrorInResponse:(id)pparsedResponse 
                  withStatusCode:(NSInteger)pstatusCode
                        andError:(NSError *)perror;
 *
 * @author Pushpak
 *
 * @brief Helper method to scan response for any salesforce/apex/default error returned by NSUrlConnection and return customized error.
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param pparsedResponse :The parsed response object(NSDictionary/NSArray)
 * @param pstatusCode :The response HTTP status code
 * @param perror :The original error returned by NSURLConnection or AFNetworking.
 *
 * @return customized error object if error is found. else nil.
 *
 */
+ (NSError *)checkForErrorInResponse:(id)pparsedResponse
                      withStatusCode:(NSInteger)pstatusCode
                            andError:(NSError *)perror;

/**
 * Used to create customized error.We can create more simple methods from this methods for easy use. Its in Todo list.
 */
/**
 * @name getCustomisedErrorWithDomain:(NSString *)pcustomDomain
                            errorCode:(NSInteger)pcustomErrorCode
                           errorTitle:(NSString *)pcustomErrorTitle
                    customUserMessage:(NSString *)puserMessage
                   responseStatusCode:(NSInteger)pstatusCode
                   parsedResponseData:(id)presponseData
                  shouldNotNotifyUser:(BOOL)dontNotifyUser
                  errorActionCategory:(SMErrorActionCategory)errorActionCategory
                            eventName:(NSString *)peventNameString
                            eventType:(NSString *)peventTypeString
                         failingQuery:(NSString *)pfailingQueryString
                        originalError:(NSError *)poriginalError;

 *
 * @author Pushpak
 *
 * @brief Used to create customized error.
 *        We can create more simple methods from this methods for easy use. Its in Todo list.
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param pcustomDomain :ErrorDomain for the error
 * @param pcustomErrorCode :ErrorCode for the error
 * @param pcustomErrorTitle :The title for error if in case that has to be displayed in AlertView
 * @param puserMessage :Custom message that has to appear in the AlertView.
 * @param pstatusCode :Response HTTP status code, if error cause due to webservice call failure.
 * @param presponseData :Response that is got from server when error occured.
 * @param dontNotifyUser :Flag if set then the shouldnotify flag in error is set to false.
 * @param errorActionCategory :The action with the receiver should take, eg retry
 * @param peventNameString :Event Name of webservice which failed.
 * @param peventTypeString :Event Type of webservcie which failed.
 * @param pfailingQueryString :If its database error then the query for which it failed.
 * @param pOriginalError :The original error with is got before customizing.
 *
 * @return customized error object.
 *
 */
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
                            originalError:(NSError *)poriginalError;
@end
