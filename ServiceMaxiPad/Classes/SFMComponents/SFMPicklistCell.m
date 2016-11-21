//
//  SFMPicklistCell.m
//  CollectionSample
//
//  Created by Damodar on 30/09/14.
//  Copyright (c) 2014 itsdamslife. All rights reserved.
//

#import "SFMPicklistCell.h"
#import "StyleGuideConstants.h"
#import "StyleManager.h"


@interface SFMPicklistCell (Private)
@property (nonatomic, strong) TextField *valueField;
@end


@implementation SFMPicklistCell


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.type = CellTypePicklist;
        
         
        self.valueField = [[TextField alloc]  initWithFrame:frame forType:TextFieldTypePicklist andDelegate:self];
        
        CGRect fr = self.valueField.frame;
        fr.origin.x = 8;
        fr.origin.y = 30;
        self.valueField.frame = fr;

        self.valueField.userInteractionEnabled = YES;
        self.valueField.backgroundColor = [UIColor whiteColor];
        self.valueField.borderStyle = UITextBorderStyleRoundedRect | UITextBorderStyleLine;
        self.valueField.tag = 101;
        self.valueField.text = @"";
        self.valueField.font = [UIFont fontWithName:kHelveticaNeueRegular size:kFontSize18];
        self.valueField.textColor = [UIColor getUIColorFromHexValue:kEditableTextFieldColor];
        [self addSubview:self.valueField];

    }
    return self;
}

- (id)value
{
    return self.valueField.text;
}

- (void)setValue:(id)value
{
    self.valueField.text = (NSString*)value;
}

- (void)textFieldDidChange:(TextField *)textField
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellValue:didChangeForIndexpath:)])
    {
        [self.delegate cellValue:self.value didChangeForIndexpath:self.indexPath];
    }
}

- (void)textFieldDidTap:(TextField *)textField
{
   
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellDidTapForIndexPath:andSender:)])
    {
        [self.delegate cellDidTapForIndexPath:self.indexPath andSender:self];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self resetFrame];
    
}
- (void)resetFrame {
    CGRect frame =  self.valueField.frame ;
   frame.size.width = self.frame.size.width - 16;
    self.valueField.frame = frame;
    [self.valueField setNeedsLayout];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
