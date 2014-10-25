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

#import "InitialSyncViewController.h"
#import "LaunchViewController.h"
#import "SFMSearchViewController.h"
//HS
#import "CustomTabBar.h"
#import "CalendarHomeViewController.h"
#import "ExploreHomeViewController.h"
#import "TaskHomeViewController.h"
#import "AddOrEditTaskVC.h"
#import "StandAloneCreateHomeController.h"
#import "TroubleshootingHomeViewController.h"
#import "ToolsHomeController.h"
#import "SLAClockViewController.h"
#import "SFMPageChildLayoutViewController.h"
#import "SFMPageHeaderLayoutViewController.h"
#import "SFMDebriefViewController.h"
#import "SMXCalendarViewController.h"
#import "SFMPageShowAllViewController.h"
#import "SFMPageHistoryViewController.h"
#import "RecentHomeViewController.h"
#import "PageLayoutEditViewController.h"
#import "ChildEditViewController.h"
#import "PageEditChildListViewController.h"
#import "PageEditHeaderLayoutViewController.h"
#import "PageEditChildLayoutViewController.h"
#import "TroubleshootingViewController.h"
#import "JobLogViewController.h"
#import "PageEditPickerFieldController.h"
#import "PageEditDateFieldController.h"
#import "PageEditDateTimeFieldController.h"

@interface ViewControllerFactory ()

+ (id)createLoginViewController;
+ (id)createHomeViewController;
+ (id)createCalendarViewController;
+ (id)createMapViewController;
//HS
+ (id)createCustomTabBar;

+ (id)createExploreViewController;
+ (id)createNewItemViewController;
+ (id)createNewlyCreatedViewController;
+ (id)createTaskViewController;
+ (id)createTroubleshootViewController;
+ (id)creatToolsViewController;


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
    UIViewController *viewController = nil;
    switch (context)
    {
        case ViewControllerLaunchScreen:
            return[ViewControllerFactory createApplicationLaunchViewController];
            break;
            
        case 1:
            return[ViewControllerFactory createLoginViewController];
            break;
            
        case 2:
            return[ViewControllerFactory createHomeViewController];
            break;
            
        case 3:
            return[ViewControllerFactory createInitialSyncViewController];
            break;
            
        case 4:
            return[ViewControllerFactory createCustomTabBar];
            break;
            
        case 5:
            return[ViewControllerFactory createCalendarViewController];
            break;
            
        case 6:
            return[ViewControllerFactory createExploreViewController];
            break;
            
        case 7:
            return[ViewControllerFactory createNewItemViewController];
            break;
            
        case 8:
            return[ViewControllerFactory createNewlyCreatedViewController];
            break;
            
        case 9:
            return[ViewControllerFactory createTaskViewController];
            break;
            
        case 10:
            return[ViewControllerFactory createTroubleshootViewController];
            break;
            
        case 11:
            return[ViewControllerFactory creatToolsViewController];
            break;
            
        case ViewControllerMap:
            return[ViewControllerFactory createMapViewController];
            break;
            
        case ViewControllerRecents:
            return [ViewControllerFactory createRecentHomeViewController];
            break;
        case 18:
            viewController = [ViewControllerFactory createPageSLAViewController];
            break;
            
        case 19:
            viewController = [ViewControllerFactory createPageHeaderViewController];
            break;
            
        case 20:
            viewController = [ViewControllerFactory createPagedetailViewController];
            break;
        case 21:
            break;
            
        case 22:
            viewController = [ViewControllerFactory createSFMDebriefViewController];
            break;
            
        case 23:
            viewController = [ViewControllerFactory createPageShowAllViewController];
            break;
        case 24:
            viewController = [ViewControllerFactory createPageHistoryViewController];
            break;

        case ViewControllerSFMEditHeader:
            viewController = [ViewControllerFactory createSFMEditHeaderViewController];
            break;
        
        case ViewControllerSFMEditChildLineList:
            
            viewController = [ViewControllerFactory createSFMEditChildLineListViewController];
            break;
        
        case ViewControllerSFMEditChildLayout:
            viewController = [ViewControllerFactory createSFMEditChildLayoutViewController];
            break;
            
        case ViewControllerSFMEditAttachment:
        
            viewController = [ViewControllerFactory createSFMEditAttachmentViewController];
            break;
        case ViewControllerAddOrEditTask:
            return [self createAddOrEditTaskViewController];
            break;

        case ViewControllerJobLog:
            return [ViewControllerFactory createJobLogViewController];
            break;
        case ViewcontrollerPickerView:
            return [self createPickerFieldViewController];
            break;
        case ViewControllerDateView:
            return [self createDateFieldViewController];
            break;
        case ViewControllerDateTimeView:
            return [self createDateTimeFieldViewController];
            break;
        default:
            break;
    }
    return viewController;
}

#pragma mark - Service Method implementation

/**
 * @name  createInitialSyncViewController
 *
 * @author Damodar
 *
 * @brief Create Login View controller object
 *
 * \par
 *  <Longer description starts here>
 *
 * @return Login View controller object
 *
 */

+ (id)createInitialSyncViewController
{
    return [[InitialSyncViewController alloc] initWithNibName:@"InitialSyncViewController"
                                                      bundle:nil];
}

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
    return [OAuthLoginViewController new];
}


/**
 * @name  createApplicationLaunchViewController
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

+ (id)createApplicationLaunchViewController
{
    return [[LaunchViewController alloc] initWithNibName:@"LaunchViewController"
                                                      bundle:nil];
}



/**
 * @name  createCustomTabBar
 *
 * @author Himanshi Sharma
 *
 * @brief Create Custom Tab Bar object
 *
 * \par
 *  <Longer description starts here>
 *
 * @return Custom Tab Bar object
 *
 */

+ (id)createCustomTabBar
{
    return [[CustomTabBar alloc]init];
}


/**
 * @name  createCalendarViewController
 *
 * @author Himanshi Sharma
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
    return [SMXCalendarViewController new];
    //return [[CalendarHomeViewController alloc]init];
}

/**
 * @name  createMapViewController
 *
 * @author Anoopsaai Ramani
 *
 * @brief Create MapViewController object
 *
 * \par
 *  <Longer description starts here>
 *
 * @return MapViewController object
 *
 */

+ (id)createMapViewController
{
    UIStoryboard *mapStoryBoard = [UIStoryboard storyboardWithName:@"Map" bundle:[NSBundle mainBundle]];
    return [mapStoryBoard instantiateViewControllerWithIdentifier:@"MapViewController"];
}

/**
 * @name  createExploreViewController
 *
 * @author Himanshi Sharma
 *
 * @brief Create Explore View controller object
 *
 * \par
 *  <Longer description starts here>
 *
 * @return Explore View controller object
 *
 *
 * @author Krishna changed the explore controller to SFMSearchViewController
 *
 */

+ (id)createExploreViewController
{
    return [[SFMSearchViewController alloc]init];
}


/**
 * @name  createNewItemViewController
 *
 * @author Himanshi Sharma

 *
 * @brief Create New Item controller object
 *
 * \par
 *  <Longer description starts here>
 *
 * @return New Item controller object
 *
 */

+ (id)createNewItemViewController
{
    return [[StandAloneCreateHomeController alloc]init];
}







/**
 * @name  createTaskViewController
 *
 * @author Himanshi Sharma
 *
 * @brief Create Task View controller object
 *
 * \par
 *  <Longer description starts here>
 *
 * @return Task View controller object
 *
 */

+ (id)createTaskViewController
{
    return [[TaskHomeViewController alloc]initWithNibName:@"TaskHomeViewController" bundle:[NSBundle mainBundle]];
}
/**
 * @name createAddOrEditTaskViewController
 *
 * @author Pushpak
 *
 * @brief Viewcontroller which is shown from task screen when user wants to create new task or edit task
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param
 *
 * @return AddOrEditTaskVC
 *
 */

+ (id)createAddOrEditTaskViewController
{
    return [[AddOrEditTaskVC alloc]initWithNibName:@"AddOrEditTaskVC" bundle:[NSBundle mainBundle]];
}

/**
 * @name  createTroubleshootViewController
 *
 * @author Himanshi Sharma
 *
 * @brief Create Troubleshoot View controller object
 *
 * \par
 *  <Longer description starts here>
 *
 * @return Troubleshoot View controller object
 *
 */

+ (id)createTroubleshootViewController
{
    return [[TroubleshootingViewController alloc]init];
}


/**
 * @name  creatToolsViewController
 *
 * @author Himanshi Sharma
 *
 * @brief Create Tools View controller object
 *
 * \par
 *  <Longer description starts here>
 *
 * @return Tools View controller object
 *
 */

+ (id)creatToolsViewController
{
    return [[ToolsHomeController alloc]init];
}


+ (id)createPageSLAViewController
{
    return [[SLAClockViewController alloc] initWithNibName:@"SLAClockViewController" bundle:nil];
}

+ (id)createPageHeaderViewController
{
    return [[SFMPageHeaderLayoutViewController alloc] init];
}

+ (id)createPagedetailViewController
{
    return [[SFMPageChildLayoutViewController alloc] init];
}

+ (id)createSFMDebriefViewController
{
    return [[SFMDebriefViewController alloc] initWithNibName:@"SFMDebriefViewController"
                                                       bundle:nil];
}

+ (id)createPageShowAllViewController
{
    return [[SFMPageShowAllViewController alloc] initWithNibName:@"SFMPageShowAllViewController"
                                                      bundle:nil];
}

+ (id)createPageHistoryViewController
{
    return [[SFMPageHistoryViewController alloc] initWithNibName:@"SFMPageHistoryViewController"
                                                          bundle:nil];
}

+ (id)createRecentHomeViewController
{
    return [[RecentHomeViewController alloc] initWithNibName:nil
                                                      bundle:nil];
}


+ (id)createJobLogViewController
{
    return [[JobLogViewController alloc] initWithNibName:@"JobLogViewController"
                                                      bundle:nil];
}

//Krishna SFM Edit
//TODO : Update ChildEditViewController to required VC.

+ (id)createSFMEditHeaderViewController
{
    return [[PageEditHeaderLayoutViewController alloc] initWithNibName:@"PageLayoutEditViewController" bundle:nil];
}
+ (id)createSFMEditChildLineListViewController
{
    return [[PageEditChildListViewController alloc] initWithNibName:@"PageEditChildListViewController" bundle:nil];

}
+ (id)createSFMEditAttachmentViewController
{
    return [[ChildEditViewController alloc] init];
}

+ (id) createSFMEditChildLayoutViewController
{
    return [[PageEditChildLayoutViewController alloc] initWithNibName:@"PageLayoutEditViewController" bundle:nil];
}

//Custom Controls
+ (id)createPickerFieldViewController
{
    return  [[PageEditPickerFieldController alloc] init];
}

+ (id)createDateFieldViewController
{
    return [[PageEditDateFieldController alloc] init];
}

+ (id)createDateTimeFieldViewController
{
    return [[PageEditDateTimeFieldController alloc] init];

}


@end
