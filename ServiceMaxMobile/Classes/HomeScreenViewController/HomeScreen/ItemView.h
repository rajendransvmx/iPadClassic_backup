//
//  ItemView.h
//  iServiceHomeScreen
//
//  Created by Aparna on 24/01/13.
//  Copyright (c) 2013 Aparna. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ItemViewDelegate <NSObject>

- (void)tappedOnViewAtIndex:(int)index;

@end

@interface ItemView : UIView

@property(nonatomic, assign) int index;
@property(nonatomic, assign) id<ItemViewDelegate> delegate;
@property(nonatomic, retain) UIImageView *iconImageView;
@property(nonatomic, retain) UILabel *titleLable;
@property(nonatomic, retain) UILabel *descriptionLabel;


@end