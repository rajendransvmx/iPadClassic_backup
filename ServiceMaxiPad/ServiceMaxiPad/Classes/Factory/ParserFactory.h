//
//  ParserFactory.h
//  ServiceMaxMobile
//
//  Created by Anoop on 8/19/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   ParserFactory.h
 *  @class  ParserFactory
 *
 *  @brief  This class acts as factory to create
 *          specific intance of parser based on requesttype
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
#import "RequestConstants.h"

@interface ParserFactory : NSObject

/**
 * @name   parserWithRequestType:(RequestType)requestType
 *
 * @author Anoopsaai Ramani
 *
 * @brief  This method returns parser instance of specific requesttype
 *
 *
 * @param  enum requestType
 *
 * @return instancetype of parser
 *
 */
+(instancetype)parserWithRequestType:(RequestType)requestType;

@end
