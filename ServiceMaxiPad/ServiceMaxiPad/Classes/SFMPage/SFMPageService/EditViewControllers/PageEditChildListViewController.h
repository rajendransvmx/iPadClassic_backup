//
//  PageEditChildListViewController.h
//  ServiceMaxMobile
//
//  Created by Aparna on 06/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "ChildEditViewController.h"
#import "PageEditControlDelegate.h"
#import "LinkedProcessViewController.h"
/**
 *  @file   PageEditChildListViewController.h
 *  @class  PageEditChildListViewController
 *
 *  @brief  List all the child line items.
 *
 *  @author  Aparna
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

@interface PageEditChildListViewController : ChildEditViewController<ChildEditViewControllerDelegate, PageEditControlDelegate, LinkedProcessDelegate>

@end
