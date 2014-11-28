//
//  SMSplitViewController.h
//  POCReskin
//
//  Created by Pushpak on 13/08/14.
//  Copyright (c) 2014 pushpak. All rights reserved.
//
/**
 *  @file SMSplitViewController.h
 *  @class SMSplitViewController
 *
 *  @brief Custom Split view component similiar to apple UISplitViewController
 *
 *  @author Pushpak
 *
 *  @bug No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import <UIKit/UIKit.h>
/**
 *  @file SMSplitViewController.h
 *  @class SMSplitPopover
 *
 *  @brief Simple subclass of NSObject to handle only one method to dismiss the master(Popover).
 *
 *  @author Pushpak
 *
 *  @bug No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/
@interface SMSplitPopover : NSObject
/**
 * @name dismissPopoverAnimated:(BOOL)animated;
 *
 * @author Pushpak
 *
 * @brief Method used to dismiss the popover.
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param animated :To specify whether the popover should dismiss with/without animation.
 *
 * @return 
 *
 */
- (void)dismissPopoverAnimated:(BOOL)animated;
@end

#pragma mark - SMSplitViewControllerDelegate
@class SMSplitViewController;

/**
 * Protocol to inform the will/did show/hide method to the
 * confirming instance.
 */
@protocol SMSplitViewControllerDelegate <NSObject>

@optional
/**
 * @name splitViewController:(SMSplitViewController *)splitViewController willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem popover:(SMSplitPopover *)popover;
 *
 * @author Pushpak
 *
 * @brief Method called before hiding the master.
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param splitViewController :Passing self as instance.
 * @param aViewController :The viewController which hides.
 * @param barButtonItem :UIBarButtonItem preloaded with action and target. Just place it/copy the action target to show or hide master in portrait.
 *
 *
 */

- (void)splitViewController:(SMSplitViewController *)splitViewController willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem popover:(SMSplitPopover *)popover;

/**
 * @name splitViewController:(SMSplitViewController *)splitViewController didHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem popover:(SMSplitPopover *)popover;
 *
 * @author Pushpak
 *
 * @brief Method called after hiding the master.
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param splitViewController :Passing self as instance.
 * @param aViewController :The viewController which hides.
 * @param barButtonItem :UIBarButtonItem preloaded with action and target. Just place it/copy the action target to show or hide master in portrait.
 *
 *
 */
- (void)splitViewController:(SMSplitViewController *)splitViewController didHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem popover:(SMSplitPopover *)popover;
/**
 * @name splitViewController:(SMSplitViewController *)splitViewController willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem;
 *
 * @author Pushpak
 *
 * @brief Method called before showing the master.
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param splitViewController :Passing self as instance.
 * @param aViewController :The viewController which is about to show.
 * @param barButtonItem :UIBarButtonItem preloaded with action and target. Just place it/copy the action target to show or hide master in portrait.
 *
 */
- (void)splitViewController:(SMSplitViewController *)splitViewController willShowViewController:(UIViewController *)aViewController barButtonItem:(UIBarButtonItem *)barButtonItem;
/**
 * @name splitViewController:(SMSplitViewController *)splitViewController willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem;
 *
 * @author Pushpak
 *
 * @brief Method called after showing the master.
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param splitViewController :Passing self as instance.
 * @param aViewController :The viewController which is about to show.
 * @param barButtonItem :UIBarButtonItem preloaded with action and target. Just place it/copy the action target to show or hide master in portrait.
 *
 */
- (void)splitViewController:(SMSplitViewController *)splitViewController didShowViewController:(UIViewController *)aViewController barButtonItem:(UIBarButtonItem *)barButtonItem;
/**
 * @name splitViewController:(SMSplitViewController *)splitViewController shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation;
 *
 * @author Pushpak
 *
 * @brief The default apple style method to know whether to hide master for given orientation.
 *
 * \par
 *  <Longer description starts here>
 *
 * @param splitViewController :Passing self as instance.
 * @param vc :The viewcontroller which has to be hidden.
 * @param orientation :UIInterfaceOrientation the device gets into.
 * @return bool value according to which the master would be hidden/not.
 *
 */
- (BOOL)splitViewController:(SMSplitViewController *)splitViewController shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation;

@end

@interface SMSplitViewController : UIViewController

@property (nonatomic, weak) id<SMSplitViewControllerDelegate> delegate;

/**
 * This array should exactly have two viewControllers. T
 * The first will be the 'master' and the second will be the 'detail'.
 * Set the viewControllers will layout the two controllers' views. 
 * An assert is written to assure there are exactly two diffrent viewControllers.
 */
@property (nonatomic, copy) NSArray *viewControllers;

/** 
 * The split line's width between the 'master' and 'detail'. 
 * The default value is 1.0. 
 * Values less than 1.0 are interpreted as 1.0.
 */
@property (nonatomic, assign) CGFloat splitLineWidth;

/**
 * The master's width.
 * NOTICE that the 'splitLineWidth' is not calculated in the master's width.
 * The default value is 320.0. Values less than 0.0 are interpreted as 320.0.
 */
@property (nonatomic, assign) CGFloat masterWidth;

/**
 * The color of the split line.
 */
@property (nonatomic, strong) UIColor *splitLineColor;

/**
 * Check whether the master is visible.
 */
@property (nonatomic, assign, readonly) BOOL isMasterVisible;

/**
 * @name masterViewController
 *
 * @author Pushpak
 *
 * @brief Helper method.
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param
 *
 * @return the first viewController of the splitViewController.
 *
 */
- (UIViewController *)masterViewController;

/**
 * @name detailViewController
 *
 * @author Pushpak
 *
 * @brief Helper method.
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param
 *
 * @return the second viewController of the splitViewController.
 *
 */
- (UIViewController *)detailViewController;

@end
