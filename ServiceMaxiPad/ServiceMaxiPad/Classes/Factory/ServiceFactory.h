//
//  ServiceFactory.h
//  ServiceMaxMobile
//
//  Created by Anoop on 8/12/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

/**
 *  @file   ServiceFactory.h
 *  @class  ServiceFactory
 *
 *  @brief  This class acts as a factory 
 *          to create instance of unique service layers
 *          based on Category type.
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
#import "BaseServiceLayer.h"

@interface ServiceFactory : NSObject

/**
 * @name   serviceLayerWithCategoryType:(CategoryType)categoryType
                            requestType:(RequestType)requestType
 *
 * @author Anoopsaai Ramani
 *
 * @brief  Class Method to create specific service layer based on category type
 *
 *
 * @param  enum NS_Integer categoryType, requestType
 *
 * @return instancetype of specific servicelayer
 *
 */

+(instancetype)serviceLayerWithCategoryType:(CategoryType)categoryType
                                requestType:(RequestType)requestType;

@end
