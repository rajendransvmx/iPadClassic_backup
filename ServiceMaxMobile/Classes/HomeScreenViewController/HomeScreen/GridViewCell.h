//
//  GridViewCell.h
//  iServiceHomeScreen
//
//  Created by Aparna on 24/01/13.
//  Copyright (c) 2013 Aparna. All rights reserved.
//
/**
 *  @file   GridViewCell.h
 *  @class  GridViewCell
 *
 *  @brief  Function prototypes for the console driver.
 *
 *
 *  This contains the prototypes for the console
 *  driver and eventually any macros, constants,
 *  or global variables you will need.
 *
 *  @author  Aparna
 *  @author  Vipindas Palli
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import <UIKit/UIKit.h>
#import "ItemView.h"



@interface GridViewCell : UITableViewCell

@property(nonatomic, assign) int columnCount;

/**
 * @name  <MethodName. optional>
 *
 * @author Vipindas Palli
 *
 * @brief <A short one line description>
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param  Description of method's or function's input parameter
 * @param  ...
 *
 * @return Description of the return value
 *
 */
- (ItemView *) itemViewAtColumn:(int)column;

@end
