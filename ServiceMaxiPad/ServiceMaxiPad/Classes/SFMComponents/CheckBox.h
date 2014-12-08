//
//  CheckBox.h
//  SampleCheckBox
//
//  Created by Krishna Shanbhag on 10/09/14.
//  Copyright (c) 2014 Krishna Shanbhag. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CheckBoxDelegate;

@interface CheckBox : UIButton
@property(nonatomic, assign) BOOL                 isChecked;
@property(nonatomic, assign) BOOL                 checked;

@property(nonatomic, assign) id<CheckBoxDelegate> delegate;

/**
 * @name  defaultValueForCheckbox
 *
 * @author Krishna Shanbhag
 *
 * @brief
 *
 * \par checked : whether the default value of the checkbox has to be checked or not
 *
 *
 *
 * @return void
 *
 */
- (void)defaultValueForCheckbox:(BOOL)checked;

@end

@protocol CheckBoxDelegate <NSObject>
@optional
- (void)didSelectedCheckBox:(CheckBox *)checkbox checked:(BOOL)isChecked;
@end
