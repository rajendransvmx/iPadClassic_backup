//
//  SwitchLayoutManager.h
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 13/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   SwitchLayoutManager.h
 *  @class  SwitchLayoutManager
 *
 *  @brief This class manages last view process for any Object
 *
 *  @author Radha S
 *
 *  @bug No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 **/


#import <Foundation/Foundation.h>

@interface SwitchLayoutManager : NSObject

/**
 * @name  Method name
 *
 * @author Radha S
 *
 * @brief This method is exposed to the caller to get the last view process name for Object
 *
 * \par
 *  <Longer description starts here>
 *
 * @return
 *
 */
+ (NSString *)getLastViewedViewProcess:(NSString *)objectName;

/**
 * @name  Method name
 *
 * @author Radha S
 *
 * @brief This method is exposed to the caller to update the last view process name for Object
 *
 * \par
 *  <Longer description starts here>
 *
 * @return
 *
 */
+ (void)updateViewProcess:(NSString *)objectName processId:(NSString *)processName;

@end
