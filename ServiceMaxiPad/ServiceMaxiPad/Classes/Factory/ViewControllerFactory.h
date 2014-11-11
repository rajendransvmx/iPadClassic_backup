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
    ViewControllerLaunchScreen = 0,  /**  Application Launch Screen */
    ViewControllerLogin = 1,         /**  Login screen  */
    ViewControllerHomeScreen = 2,    /**  Home screen  */
    ViewControllerInitialSync = 3,   /**  Initial sync screen with tips and showing the progress of the sync */
    ViewControllerCustomTabBar = 4,  /**  Initial sync screen with tips and showing the progress of the sync */

    ViewControllerCalendar = 5,      /**  Help view screen  */
    ViewControllerExplore = 6,       /**  Initial sync screen with tips and showing the progress of the sync */
   
    ViewControllerNewItem = 7,       /**  Initial sync screen with tips and showing the progress of the sync */
    ViewControllerNewlyCreated = 8,  /**  Initial sync screen with tips and showing the progress of the sync */
    ViewControllerTasks = 9,         /**  Initial sync screen with tips and showing the progress of the sync */
    ViewControllerTroubleshooting = 10,  /**  Initial sync screen with tips and showing the progress of the sync */
    ViewControllerTools = 11,       /**  Initial sync screen with tips and showing the progress of the sync */

    ViewControllerMap = 12,         /**  Map view screen  */
    ViewControllerRecents = 13,     /**  Show recents created objects view screen */
    ViewControllerReport = 14,      /**  Service report screen  */
    ViewControllerSearch = 15,      /**  Service Flow Manage (SFM) search screen  */
    ViewControllerStandaloneProcessGenerator = 16, /**  Stand alone process generator view screen  */
    ViewControllerTask = 17,        /**  Stand alone process generator view screen  */
    
    ViewControllerPageViewSLAClock = 18,
    ViewControllerPageViewHeader = 19,
    ViewControllerPageViewDetail = 20,
    ViewControllerPageViewHistory = 21,
    ViewControllerSFMDebrief = 22,
    ViewControllerPageViewShowAll = 23,
    ViewControllerSFMHistory = 24,
    
    ViewControllerSFMEditHeader = 25,
    ViewControllerSFMEditChildLineList = 26,
    ViewControllerSFMEditAttachment = 27,
    ViewControllerSFMEditChildLayout = 28,
    ViewControllerAddOrEditTask,     /** Adding new task or editing new task screen */
    ViewControllerJobLog,            /** Used for JobLog/PushLog */
    ViewcontrollerPickerView,
    ViewControllerDateView,
    ViewControllerDateTimeView,
    ViewControllerAttachmentDocuments,
    ViewControllerAttachmentImagesAndVideos,
    
    // Tools Controllers
    ViewControllerToolsMaster ,
    ViewControllerSyncStatusDetail,
    ViewControllerResolveConflictsDetail,
    ViewControllerPurgeDataDetail,
    ViewControllerNotificationHistoryDetail,
    ViewControllerTextSizeDetail,
    ViewControllerAboutView,
    ViewControllerResetAppDetail,
    ViewControllerSignOutDetail,
    viewControllerProductManual
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
