//
//  BaseServiceLayer.h
//  ServiceMaxMobile
//
//  Created by Anoop on 8/12/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//
/**
 *  @file   BaseServiceLayer.h
 *  @class  BaseServiceLayer
 *
 *  @brief  Parent class for all service layers
 *          holds categorytype and requestype of servicelayer
 *
 *
 *  @author  Anoopsaai Ramani
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/


#import <Foundation/Foundation.h>
#import "SyncConstants.h"
#import "RequestConstants.h"
#import "ResponseCallback.h"
#import "RequestParamModel.h"
#import "WebServiceParser.h"



@protocol ServiceLayerProtocol <NSObject>

/**
 * @name   processResponseWithRequestParam:(RequestParamModel*)requestParamModel
 *         responseData:(id)responseData
 *
 * @author Anoopsaai Ramani
 *
 * @brief  This method will interact with parser factory 
 *         and passes data to respective parser, then gets responsecallback
 *
 *
 * @param  Model RequestParamModel, id responseData
 *
 * @return ResponseCallback
 *
 */
- (ResponseCallback*)processResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                      responseData:(id)responseData;

@optional
- (NSArray*)getRequestParametersWithRequestCount:(NSInteger)requestCount;

@end



@interface BaseServiceLayer : NSObject<ServiceLayerProtocol>

@property (nonatomic, assign) CategoryType categoryType;
@property (nonatomic, assign) RequestType    requestType;
@property (nonatomic, strong) NSString      *requestIdentifier;

/**
 * @name   initWithCategoryType:(CategoryType)categoryType
 *         requestType:(RequestType)requestType
 *
 * @author Anoopsaai Ramani
 *
 * @brief  This method with intialize service layer and
 *         assigns categorytype and request type for specific service layer
 *         
 *
 *
 * @param  enum NS_Integer categoryType, requestType
 *
 * @return instancetype
 *
 */

- (instancetype)initWithCategoryType:(CategoryType)categoryType
                         requestType:(RequestType)requestType;


@end

