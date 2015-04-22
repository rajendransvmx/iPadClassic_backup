//
//  SFMNonEditableCell.m
//  CollectionSample
//
//  Created by Damodar on 30/09/14.
//  Copyright (c) 2014 itsdamslife. All rights reserved.
//

#import "SFMNonEditableCell.h"
#import "StyleGuideConstants.h"
#import "StyleManager.h"


@interface SFMNonEditableCell (Private)
@property (nonatomic, strong) TextField *valueField;
@end

@implementation SFMNonEditableCell


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.type = CellTypeNonEditableTextField;
        
         
        self.valueField = [[TextField alloc] initWithFrame:frame forType:TextFieldTypeNonEditable andDelegate:self];
        CGRect fr = self.valueField.frame;
        fr.origin.x = 8;
        fr.origin.y = 30;
        self.valueField.frame = fr;
        self.valueField.tag = 101;
        self.valueField.text = @"";
        self.valueField.font = [UIFont fontWithName:kHelveticaNeueRegular size:kFontSize18];
        self.valueField.textColor = [UIColor colorWithHexString:kTextFieldFontColor];
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

- (void)setFieldNameForeText:(NSString *)fieldName
{
    if(fieldName != nil)
    {
         self.valueField.fieldName = fieldName;
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
