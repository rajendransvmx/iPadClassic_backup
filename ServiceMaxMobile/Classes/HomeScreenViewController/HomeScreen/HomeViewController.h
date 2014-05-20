//
//  HomeViewController.h
//  ServiceMaxMobile
//
//  Created by AnilKumar on 5/8/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//
/**
 *  @file   HomeViewController.h
 *  @class  HomeViewController
 *
 *  @brief  This will display application home view.
 *
 *
 *  This contains the prototypes for the console
 *  driver and eventually any macros, constants,
 *  or global variables you will need.
 *
 *  @author  Vipindas Palli
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/


#import <UIKit/UIKit.h>
#import "ItemView.h"
#import "CalendarController.h"
@class CalendarController;

CalendarController * calendar;

@interface HomeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ItemViewDelegate>





@end
