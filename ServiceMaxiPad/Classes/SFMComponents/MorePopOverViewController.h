//
//  MorePopOverViewController.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 17/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   MorePopOverViewController.h
 *  @class  MorePopOverViewController
 *
 *  @brief
 *
 *   This is a controller which is used to display the popover on tapping more button.
 *
 *  @author Shubha S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import <UIKit/UIKit.h>
#import "EditMenuLabel.h"

@interface MorePopOverViewController : UIViewController

@property(nonatomic, strong) EditMenuLabel *fieldNameLabel;
@property(nonatomic, strong) UITextView *fieldValueTextView;

@end
