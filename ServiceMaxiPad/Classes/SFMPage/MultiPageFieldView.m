//
//  MultiPageFieldView.m
//  ServiceMaxiPad
//
//  Created by Shubha S on 08/05/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "MultiPageFieldView.h"
#import "StyleGuideConstants.h"
#import "StyleManager.h"

@implementation MultiPageFieldView

- (id)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame]) {
        
        [self configureCell];
    }
    return self;
}

- (void)configureCell
{
    CGFloat width = self.bounds.size.width/2 -20;
    
    self.fieldLabelOne = [[UILabel alloc]initWithFrame:CGRectMake(0, 0,width, 20)];
    width = self.fieldLabelOne.frame.size.width;
    self.fieldValueOne = [[UILabel alloc]initWithFrame:CGRectMake(0, 20,width, 20)];
    self.fieldLabelTwo = [[UILabel alloc]initWithFrame:CGRectMake(width+20, 0,width, 20)];
    self.fieldValueTwo = [[UILabel alloc]initWithFrame:CGRectMake(width+10, 20,width, 20)];
    
    self.fieldLabelOne.textColor = [UIColor getUIColorFromHexValue:kTextFieldFontColor];
    self.fieldLabelOne.font = [UIFont fontWithName:kHelveticaNeueRegular size:kFontSize14];
    
    self.fieldValueOne.textColor = [UIColor getUIColorFromHexValue:kEditableTextFieldColor];
    self.fieldValueOne.font = [UIFont fontWithName:kHelveticaNeueRegular size:kFontSize16];
    
    self.fieldLabelTwo.textColor = [UIColor getUIColorFromHexValue:kTextFieldFontColor];
    self.fieldLabelTwo.font = [UIFont fontWithName:kHelveticaNeueRegular size:kFontSize14];
    
    self.fieldValueTwo.textColor = [UIColor getUIColorFromHexValue:kEditableTextFieldColor];
    self.fieldValueTwo.font = [UIFont fontWithName:kHelveticaNeueRegular size:kFontSize16];
    
//    self.fieldLabelOne.backgroundColor = [UIColor yellowColor];
//    self.fieldLabelTwo.backgroundColor = [UIColor grayColor];
//    self.fieldValueOne.backgroundColor = [UIColor blueColor];
//    self.fieldValueTwo.backgroundColor = [UIColor purpleColor];
//    self.titleLabel.backgroundColor = [UIColor purpleColor];
    
    [self addSubview:self.fieldLabelOne];
    [self addSubview:self.fieldLabelTwo];
    [self addSubview:self.fieldValueOne];
    [self addSubview:self.fieldValueTwo];
}

- (void)layoutSubviews{
    
    CGFloat width = self.bounds.size.width/2;
    self.fieldLabelOne.frame = CGRectMake(0, 0,width-10, 30);
    self.fieldLabelTwo.frame = CGRectMake(width, 0,width-10, 30);
    self.fieldValueOne.frame = CGRectMake(0,20,width-10, 30);
    self.fieldValueTwo.frame = CGRectMake(width,20,width-10, 30);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
