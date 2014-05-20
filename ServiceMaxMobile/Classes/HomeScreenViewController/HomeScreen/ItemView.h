//
//  ItemView.h
//  iServiceHomeScreen
//
//  Created by Aparna on 24/01/13.
//  Copyright (c) 2013 Aparna. All rights reserved.
//
/**
 *  @file   ItemView.h
 *  @class  ItemView
 *
 *  @brief  Function prototypes for the console driver.
 *
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

@protocol ItemViewDelegate <NSObject>

/**
 * @name  tappedOnViewAtIndex:(int)index;
 *
 * @author Aparna
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

- (void)tappedOnViewAtIndex:(int)index;

@end

@interface ItemView : UIView

@property(nonatomic) int index;
@property(nonatomic) int menuItemType;

@property(nonatomic, assign) id<ItemViewDelegate> delegate;
@property(nonatomic, strong) UIImageView *iconImageView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *descriptionLabel;



@end