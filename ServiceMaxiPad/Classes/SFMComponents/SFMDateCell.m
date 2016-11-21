//
//  SFMDateCell.m
//  CollectionSample
//
//  Created by Damodar on 30/09/14.
//  Copyright (c) 2014 itsdamslife. All rights reserved.
//

#import "SFMDateCell.h"
#import "StyleManager.h"
#import "StyleGuideConstants.h"
#import "StringUtil.h"


@interface SFMDateCell (Private)
@property (nonatomic, strong) TextField *valueField;
@end

@implementation SFMDateCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.type = CellTypeDateField;
        
         
        self.valueField = [[TextField alloc]  initWithFrame:frame forType:TextFieldTypeDateField andDelegate:self];
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
    [self addRightImageOfTextFieldForValue:value];
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

- (void)clearButtonTapped:(id)sender
{
    self.valueField.text = @"";
    [self addRightImageOfTextFieldForValue:@""];
    [self.delegate clearFieldAtIndexPath:self.indexPath andSender:sender];
}

- (void)addRightImageOfTextFieldForValue:(id)value
{
    UIImageView *imageView = self.valueField.innerImageView; //(UIImageView*)[self.valueField viewWithTag:111];
    UIImage *image = [UIImage imageNamed:@"triangle-down.png"];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]init];
    imageView.userInteractionEnabled = YES;
    
    if (![StringUtil isStringEmpty:(NSString*)value]) {
        
        image = [UIImage imageNamed:@"clear.png"];
        [tapGesture addTarget:self action:@selector(clearButtonTapped:)];
        
    }else {
        image = [UIImage imageNamed:@"triangle-down.png"];
        [tapGesture addTarget:self action:@selector(textFieldDidTap:)];
    }
    [imageView addGestureRecognizer:tapGesture];
    imageView.image = image;
    imageView.frame = CGRectMake(self.valueField.frame.size.width - image.size.width - 8 , (self.valueField.frame.size.height - image.size.height) / 2, image.size.width, image.size.height);
    self.valueField.innerImageView = imageView;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
