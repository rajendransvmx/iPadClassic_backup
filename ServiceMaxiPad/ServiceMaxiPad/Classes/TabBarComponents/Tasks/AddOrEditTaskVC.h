//
//  AddOrEditTaskVC.h
//  ServiceMaxMobile
//
//  Created by Pushpak on 02/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFMTaskModel.h"

@class AddOrEditTaskVC;

@protocol AddOrEditTaskVCDelegate <NSObject>

@optional
- (void)addOrEditTaskVC:(AddOrEditTaskVC *)addOrEditTaskVC userPressedSaveForTask:(SFMTaskModel *)task;
- (void)addOrEditTaskVC:(AddOrEditTaskVC *)addOrEditTaskVC userPressedCancelForTask:(SFMTaskModel *)task;
@end

@interface AddOrEditTaskVC : UIViewController

@property (nonatomic, weak) id<AddOrEditTaskVCDelegate> delegate;
@property (nonatomic) BOOL isNewlyCreadedTask;
- (void)showAddNewTaskScreen;
- (void)showEditTaskScreenForTask:(SFMTaskModel *)task;
@end
