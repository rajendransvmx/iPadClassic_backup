//
//  StaticResourceDAO.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 26/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//


/**
 *  @file   StaticResourceDAO
 *  @class  StaticResourceDAO
 *
 *  @brief
 *
 *   This is a protocol class
 *
 *  @author Shubha S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import <Foundation/Foundation.h>
#import "CommonServiceDAO.h"

@protocol StaticResourceDAO <CommonServiceDAO>

/**
 * @name (NSArray*)getDistinctStaticResourceIdsToBeDownloaded
 *
 * @author Shubha
 *
 * @brief it gives listof staticresource ids to be downloaded
 * @param None
 * @param
 *
 * @return list of static resource id.
 *
 */

- (NSArray*)getDistinctStaticResourceIdsToBeDownloaded;

@end
