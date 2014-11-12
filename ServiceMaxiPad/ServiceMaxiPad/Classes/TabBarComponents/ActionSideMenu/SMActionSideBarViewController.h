//
//  SMActionSideBarViewController.h
//  iPadRedesignActionMenuComponent
//
//  Created by pushpak on 14/09/14.
//  Copyright (c) 2014 Service Max Inc. All rights reserved.
//
/**
 *  @file SMActionSideBarViewController.h
 *  @class iPadRedesignActionMenuComponent
 *
 *  @brief Reusable component for the new action side bar menu. I have commented usage code for our application in the same class so that it can reduce your valuable time.
 *
 *  @author Pushpak
 *
 *  @bug No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import <UIKit/UIKit.h>

@class SMActionSideBarViewController;
/**
 * @name @protocol SMActionSideBarViewControllerDelegate
 *
 * @author Pushpak
 *
 * @brief A protocol to inform the did/will appear/disappear of our action side menu.
 *
 * \par
 *  <Longer description starts here>
 *
 */

@protocol SMActionSideBarViewControllerDelegate <NSObject>
@optional
- (void)sideBar:(SMActionSideBarViewController *)sideBar didAppear:(BOOL)animated;
- (void)sideBar:(SMActionSideBarViewController *)sideBar willAppear:(BOOL)animated;
- (void)sideBar:(SMActionSideBarViewController *)sideBar didDisappear:(BOOL)animated;
- (void)sideBar:(SMActionSideBarViewController *)sideBar willDisappear:(BOOL)animated;
@end

@interface SMActionSideBarViewController : UIViewController <UIGestureRecognizerDelegate>

@property (nonatomic, assign) CGFloat sideBarWidth;
@property (nonatomic, assign) CGFloat animationDuration;
@property (assign) BOOL hasShownSideBar;
@property (assign) BOOL showSideBarFromRight;
@property BOOL isCurrentPanGestureTarget;
@property NSInteger tag;

@property (nonatomic, weak) id <SMActionSideBarViewControllerDelegate> delegate;

/**
 * @name init
 *
 * @author Pushpak
 *
 * @brief init method to use the action menu bar from left. If you want the side bar from right, then make use the init method with direction.
 *
 * \par
 *  <Longer description starts here>
 *
 * @return SMActionSideBarViewController class instance.
 *
 */
- (instancetype)init;

/**
 * @name initWithDirectionFromRight:(BOOL)showFromRight;
 *
 * @author Pushpak
 *
 * @brief init method to use the action menu bar from left. If you want the side bar from right, then make use the init method with direction.
 *
 * \par
 *  <Longer description starts here>
 *
 * @par showFromRight : this is the flag to set if you need the menu from right.
 *
 * @return SMActionSideBarViewController class instance.
 *
 */
- (instancetype)initWithDirectionFromRight:(BOOL)showFromRight;

/**
 * @name showAnimated:(BOOL)animated
 *
 * @author Pushpak
 *
 * @brief This method slides the action menu.
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param animated :Use this flag to set animated/nonanimated appearance.
 *
 */
- (void)showAnimated:(BOOL)animated;

/**
 * @name showInViewController:(UIViewController *)controller animated:(BOOL)animated
 *
 * @author Pushpak
 *
 * @brief Use this method if you want to show the action menu within a specific view controller. If you don't use this method then by default the menu will be added as child view controller to the window rootviewcontroller.
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param controller :The controller within which you want to show the menu.
 *
 * @param animated  :Use this flag to set animated/nonanimated appearance.
 *
 */
- (void)showInViewController:(UIViewController *)controller animated:(BOOL)animated;
/**
 * @name dismissAnimated:(BOOL)animated
 *
 * @author Pushpak
 *
 * @brief This method dismisses the action menu.
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param animated  :Use this flag to set animated/nonanimated appearance.
 *
 *
 */
- (void)dismissAnimated:(BOOL)animated;
/**
 * @name handlePanGestureToShow:(UIPanGestureRecognizer *)recognizer inView:(UIView *)parentView;
 *
 * @author Pushpak
 *
 * @brief Use this method to pass the pan gesture recognizer instance which you have put on your view so that the pan works in sync with the menu.
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param recognizer :PanGestureRecognizer that you configure on your view.
 *
 * @param parentView :The view in which the pan gesture recognizer is applied on.
 *
 */
- (void)handlePanGestureToShow:(UIPanGestureRecognizer *)recognizer inView:(UIView *)parentView;
/**
 * @name setContentViewInSideBar:(UIView *)contentView;
 *
 * @author Pushpak
 *
 * @brief This method is used to set the view which has to appear in the side menu. If you want the view controller view to be added then make sure to add it as child view controller so as to get the appearance and orientation methods to the view controller.
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param contentView :The view which has to appear within the side menu.
 *
 *
 */
- (void)setContentViewInSideBar:(UIView *)contentView;

- (void)removeContentViewInSideBar:(UIView *)contentView;


/*
 * Sample code for our application
 - (void)viewDidLoad
 {
 [super viewDidLoad];
 UIBarButtonItem *rightNavButton = [[UIBarButtonItem alloc]init];
 rightNavButton.title = @"Actions";
 rightNavButton.action = @selector(showMenu:);
 rightNavButton.target = self;
 self.navigationItem.rightBarButtonItem = rightNavButton;
 
 
 
 SMDemoTableViewController *temp = [SMDemoTableViewController new];
 self.mySideBar = [[SMActionSideBarViewController alloc]initWithDirectionFromRight:YES];
 self.mySideBar.sideBarWidth = 320;
 self.mySideBar.delegate = self;
 [self.mySideBar addChildViewController:temp];
 temp.sideMenu = self.mySideBar;
 [self.mySideBar setContentViewInSideBar:temp.view];
 [temp willMoveToParentViewController:self.mySideBar];
 }
 
 - (void)showMenu:(id)sender {
 
 if (self.mySideBar.hasShownSideBar) {
 [self.mySideBar dismissAnimated:YES];
 }
 [self.mySideBar showInViewController:self animated:YES];
 }

 */
@end