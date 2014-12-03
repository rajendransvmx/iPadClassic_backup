//
//  CheckBox.m
//  SampleCheckBox
//
//  Created by Krishna Shanbhag on 10/09/14.
//  Copyright (c) 2014 Krishna Shanbhag. All rights reserved.
//

#import "CheckBox.h"

@implementation CheckBox
@synthesize isChecked;
@synthesize delegate;

/**
 * @name  doInitialSetup
 *
 * @author Krishna Shanbhag
 *
 * @brief Sets the image for selected and non selected state
 *
 * \par
 *
 *
 *
 * @return void
 *
 */
- (void) doInitialSetup {
    self.exclusiveTouch = YES;
    [self setImage:[UIImage imageNamed:@"checkbox-active-unchecked.png"] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"checkbox-active-checked.png"] forState:UIControlStateSelected];
    [self addTarget:self action:@selector(checkboxBtnChecked) forControlEvents:UIControlEventTouchUpInside];

}
/**
 * @name  initWithFrame:(CGRect)frame
 *
 * @author Krishna Shanbhag
 *
 * @brief When Check box is initiated by code. call this method
 *
 * \par
 *
 *
 *
 * @return self
 *
 */
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self doInitialSetup];
    }
    return self;
}

/**
 * @name  awakeFromNib
 *
 * @author Krishna Shanbhag
 *
 * @brief When Check box is initiated by story board or nib. call this method
 *
 * \par
 *
 *
 *
 * @return void
 *
 */

- (void) awakeFromNib {
    [self doInitialSetup];
}
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
- (void)defaultValueForCheckbox:(BOOL)checked {
    if (self.isChecked == checked) {
        return;
    }
    self.isChecked = checked;
    self.selected = checked;
    
//    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedCheckBox:checked:)]) {
//        [self.delegate didSelectedCheckBox:self checked:self.selected];
//    }
}
/**
 * @name  checkboxBtnChecked
 *
 * @author Krishna Shanbhag
 *
 * @brief Private methods which checks/unchecks the checkbox.
 *
 * \par
 *
 *
 *
 * @return void
 *
 */
- (void)checkboxBtnChecked {
    self.selected = !self.selected;
    self.isChecked = self.selected;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedCheckBox:checked:)]) {
        [self.delegate didSelectedCheckBox:self checked:self.selected];
    }
}

@end
