//
//  ViewControllerFactory.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 4/14/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   ViewControllerFactory.m
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

#import "ViewControllerFactory.h"
#import "OAuthLoginViewController.h"
#import "HomeScreen.h"
#import "HomeViewController.h"

@interface ViewControllerFactory ()

+ (id)createLoginViewController;
+ (id)createHomeViewController;
+ (id)createCalendarViewController;

@end;

@implementation ViewControllerFactory

#pragma mark - Factory Method implementation

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

+ (id)createViewControllerByContext:(ViewControllerContext)context
{
    if (ViewControllerLogin == context)
    {
        return[ViewControllerFactory createLoginViewController];
    }
    else if (ViewControllerHomeScreen == context)
    {
        return [ViewControllerFactory  createHomeViewController];
    }
    else if (ViewControllerCalendar == context)
    {
        return [ViewControllerFactory  createCalendarViewController];
    }
    
    return nil;
}

#pragma mark - Service Method implementation

/**
 * @name  createLoginViewController
 *
 * @author Vipindas Palli
 *
 * @brief Create Login View controller object
 *
 * \par
 *  <Longer description starts here>
 *
 * @return Login View controller object
 *
 */

+ (id)createLoginViewController
{
    return [[OAuthLoginViewController alloc] initWithNibName:@"OAuthController"
                                               bundle:nil];
}

/**
 * @name  createHomeViewController
 *
 * @author Vipindas Palli
 *
 * @brief Create Home View controller object
 *
 * \par
 *  <Longer description starts here>
 *
 * @return Home View controller object
 *
 */

+ (id)createHomeViewController
{
    return [[HomeViewController alloc] initWithNibName:@"HomeViewController"
                                        bundle:nil];
}

/**
 * @name  createCalendarViewController
 *
 * @author Vipindas Palli
 *
 * @brief Create Calendar View controller object
 *
 * \par
 *  <Longer description starts here>
 *
 * @return Calendar View controller object
 *
 */

+ (id)createCalendarViewController
{
    return nil;
}

@end
