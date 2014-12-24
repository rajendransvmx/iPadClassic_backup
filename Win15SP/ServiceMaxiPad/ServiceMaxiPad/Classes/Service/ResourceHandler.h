//
//  ResourceHandler.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 01/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//


/**
 *  @file   ResourceHandler.h
 *  @class  ResourceHandler
 *
 *  @brief
 *
 *   This is class handles all resource download callback and parsing.
 *
 *  @author Shubha S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/


#import <Foundation/Foundation.h>
#import "RequestParamModel.h"
#import "ResponseCallback.h"

@interface ResourceHandler : NSObject

/**
 * @name - (NSArray*)getStaticeResourceRequestParameterForCount:(NSInteger)count
 *
 * @author Shubha
 *
 * @brief It gives requestparameter of static resource for given count.
 *
 *
 *
 * @param count
 * @param 
 *
 * @return requestParameter array
 *
 */

- (NSArray*)getStaticeResourceRequestParameterForCount:(NSInteger)count;

/**
 * @name - (NSArray*)getRequestParamsForDocumentInformation
 *
 * @author Shubha
 *
 * @brief It gives requestparameter of Document Information request
 *
 *
 *
 * @param count
 * @param
 *
 * @return requestParameter array
 *
 */

- (NSArray *)getRequestParamsForDocumentInformation;

/**
 * @name - (NSArray*)getDownloadDocTemplateRequestparameterForCount:(NSInteger)count
 *
 * @author Shubha
 *
 * @brief It gives requestparameter of Download doc template request for given count.
 *
 *
 *
 * @param count
 * @param
 *
 * @return requestParameter array
 *
 */

- (NSArray*)getDownloadDocTemplateRequestparameterForCount:(NSInteger)count;

/**
 * @name - (NSArray*)getDocumentResourceRequestParameterForCount:(NSInteger)count
 *
 * @author Shubha
 *
 * @brief It gives requestparameter of document resource for given count.
 *
 *
 *
 * @param count
 * @param
 *
 * @return requestParameter array
 *
 */

- (NSArray*)getDocumentResourceRequestParameterForCount:(NSInteger)count;

/**
 * @name (ResponseCallback*)getResponceCallBackForDocumentDownloadWithRequestParam:(RequestParamModel*)requestParamModel
 *
 * @author Shubha
 *
 * @brief It gives responce callback for document download request
 *
 *
 *
 * @param requestParam model 
 * @param
 *
 * @return Responce callback object
 *
 */

- (ResponseCallback*)getResponceCallBackForDocumentDownloadWithRequestParam:(RequestParamModel*)requestParamModel;

/**
 * @name (ResponseCallback*)getResponceCallBackForStaticResourceDownloadWithRequestParam:(RequestParamModel*)requestParamModel
 *
 * @author Shubha
 *
 * @brief It gives responce callback for static resource download request
 *
 *
 *
 * @param requestParam model
 * @param
 *
 * @return Responce callback object
 *
 */

- (ResponseCallback*)getResponceCallBackForStaticResourceDownloadWithRequestParam:(RequestParamModel*)requestParamModel;

/**
 * @name (ResponseCallback*)getResponceCallbackForAttachmentDownloadResponceWithRequestParam:(RequestParamModel*)requestParamModel
 *
 * @author Shubha
 *
 * @brief It gives responce callback for attachment download request
 *
 *
 *
 * @param requestParam model
 * @param
 *
 * @return Responce callback object
 *
 */

- (ResponseCallback*)getResponceCallbackForAttachmentDownloadResponceWithRequestParam:(RequestParamModel*)requestParamModel;


- (NSArray*)getTroubleshootingDocumentRequestParameterForCount:(NSInteger)count;

- (NSArray*)getProductManualRequestParameterForCount:(NSInteger)count;


- (NSArray*)getChatterProductImageParameterForCount:(NSInteger)count;

@end
