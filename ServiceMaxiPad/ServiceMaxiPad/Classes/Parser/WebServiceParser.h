//
//  WebServiceParser.h
//  ServiceMaxMobile
//
//  Created by Pushpak on 19/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//
/**
 *  @file WebServiceParserProtocol.h
 *  @class WebServiceParserProtocol
 *
 *  @brief Base class for all web service related parsers.
 *
 *  @author Pushpak
 *
 *  @bug No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import <Foundation/Foundation.h>
#import "ResponseCallback.h"
#import "RequestConstants.h"
#import "SyncConstants.h"

@protocol WebServiceParserProtocol <NSObject>


/**
 * @name -(ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
 responseData:(id)responseData;
 *
 * @author Pushpak
 *
 * @brief Protocol method through which one can interact with the parsers. Please implement this method in all parsers.
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param requestObject This is request parameters model.
 * @param responseData Used to accept the response from web service.
 *
 * @return ResponseCallback Holds necessary information for next requests in case.
 *
 */
-(ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                     responseData:(id)responseData;

@end

@interface WebServiceParser : NSObject <WebServiceParserProtocol>

@property(nonatomic,strong)NSString *clientRequestIdentifier;
@property (nonatomic, assign) CategoryType categoryType;


@end
