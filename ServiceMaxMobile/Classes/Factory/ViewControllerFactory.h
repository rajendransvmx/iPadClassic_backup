//
//  ViewControllerFactory.h
//  ServiceMaxMobile
//
//  Created by Vipindas on 4/14/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   ViewControllerFactory.h
 *  @class  ViewControllerFactory
 *
 *  @brief  Factory class to generate view controller by context name
 *
 *  @author Vipindas Palli
 *
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import <Foundation/Foundation.h>

typedef enum ViewControllerContext : NSUInteger
{
    ViewControllerCalendar = 1,    /**  Calendar view screen  */
    ViewControllerHelp = 2,        /**  Help view screen  */
    ViewControllerHomeScreen = 3,  /**  Home screen  */
    ViewControllerLogin = 4,       /**  Login screen  */
    ViewControllerMap = 5,         /**  Map view screen  */
    ViewControllerRecents = 6,     /**  Show recents created objects view screen */
    ViewControllerReport = 7,      /**  Service report screen  */
    ViewControllerSearch = 8,      /**  Service Flow Manage (SFM) search screen  */
    ViewControllerStandaloneProcessGenerator = 9, /**  Stand alone process generator view screen  */
    ViewControllerTask = 10,        /**  Stand alone process generator view screen  */
}
ViewControllerContext;

@interface ViewControllerFactory : NSObject
{

}

/**
 * @name  createViewControllerByContext:
 *
 * @author Vipindas Palli
 *
 * @brief Factory method to generate View controller object by context
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param  context Context of the view controller
 *
 * @return View controller object
 *
 */

+ (id)createViewControllerByContext:(ViewControllerContext)context;

@end
