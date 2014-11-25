//
//  SMXRedAndWhiteButton.m
/**
 *  @file   FILE_NAME.m
 *  @class  CLASS_NAME
 *
 *  @brief  This class will provide .....
 *
 *
 *
 *  @author  AUTHOR_NAME
 *
 *  @bug     No known bugs
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "SMXRedAndWhiteButton.h"

#import "SMXImportantFilesForCalendar.h"

@implementation SMXRedAndWhiteButton

- (id)initWithFrame:(CGRect)frame
{
    self = [UIButton buttonWithType:UIButtonTypeCustom];
    if (self) {
        // Initialization code
        
        [self setFrame:frame];
        
        [self setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        
        [self setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageWithColor:[UIColor redColor]] forState:UIControlStateSelected];
        
        [self.layer setBorderColor:[UIColor redColor].CGColor];
        [self.layer setBorderWidth:1.];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setSelected:(BOOL)_selected {

    self.selected = _selected;
    
    if(_selected) {
        [self.layer setBorderColor:[UIColor whiteColor].CGColor];
    } else {
        [self.layer setBorderColor:[UIColor redColor].CGColor];
    }
}

@end
