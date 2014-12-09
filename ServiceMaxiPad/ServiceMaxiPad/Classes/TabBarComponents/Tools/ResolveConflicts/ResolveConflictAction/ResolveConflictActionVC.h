//
//  ResolveConflictActionVC.h
//  ServiceMaxiPad
//
//  Created by Pushpak on 06/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SyncErrorConflictModel.h"
@class ResolveConflictActionVC;
/*
 * Protocol to inform the caller when user taps apply or cancel with the conflict.
 */
@protocol ResolveConflictActionDelegate <NSObject>

@optional
- (void)resolveConflictActionVC:(ResolveConflictActionVC *)resolveConflictActionVC userPressedApplyForConflict:(SyncErrorConflictModel *)conflict;

- (void)resolveConflictActionVC:(ResolveConflictActionVC *)resolveConflictActionVC userPressedCancelForConflict:(SyncErrorConflictModel *)conflict;

- (void)resolveConflictActionVC:(ResolveConflictActionVC *)resolveConflictActionVC userPressedNavigateForConflict:(SyncErrorConflictModel *)conflict;

@end

@interface ResolveConflictActionVC : UIViewController

/*
 * Ensure that the caller is setting the delegate.
 */
@property (nonatomic, weak) id<ResolveConflictActionDelegate> delegate;

/*
 * Method to configure resolutions available for given conflict and present the viewcontroller.
 */
- (void)configureAndShowActionsForConflict:(SyncErrorConflictModel *)conflict;

@end
