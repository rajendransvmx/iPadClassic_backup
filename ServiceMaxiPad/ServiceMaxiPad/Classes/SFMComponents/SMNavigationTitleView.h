//
//  SMNavigationTitleView.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 18/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   SMNavigationTitleView.h
 *  @class  SMNavigationTitleView
 *
 *  @brief
 *
 *   This title view used to display navigation title with image if present.
 *
 *  @author Shubha S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import <UIKit/UIKit.h>

@interface SMNavigationTitleView : UIView

/*to set navigation title*/
@property(nonatomic, strong) UILabel *titleLabel;

/*to set image if present*/
@property(nonatomic, strong) UIImageView *titleImageView;

/*Based on this width title label frame will be set*/
@property(nonatomic) CGFloat titleWidth;

/*Based on this flag titleimageview will be shown/hidden */
@property(nonatomic) BOOL isTitleImagePresent;

@end
