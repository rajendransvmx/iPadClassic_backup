//
//  SFMNonEditableTextViewCell.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 30/01/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "SFMNonEditableTextViewCell.h"
#import "StyleGuideConstants.h"
#import "StyleManager.h"


@interface SFMNonEditableTextViewCell (Private) <UITextViewDelegate>
@property (nonatomic, strong) UITextView *valueField;
@end

@implementation SFMNonEditableTextViewCell


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.type = CellTypeNonEditableTextViewField;
        
        
        UITextView *textView = [[UITextView alloc] initWithFrame:frame];
        
        textView.delegate = self;
        
        CGRect fr = textView.frame;
        fr.origin.x = 8;
        fr.origin.y = 30;
        fr.size.width = frame.size.width - 16;
        fr.size.height = frame.size.height - fr.origin.y - 8;
        textView.frame = fr;
        
        textView.userInteractionEnabled = YES;
        textView.backgroundColor = [UIColor lightGrayColor];
        textView.tag = 101;
        textView.text = @"";
        textView.font = [UIFont fontWithName:kHelveticaNeueRegular size:kFontSize18];
        textView.textColor = [UIColor darkGrayColor];
        textView.textColor = [UIColor colorFromHexString:kTextFieldFontColor];
        textView.layer.borderColor = [[UIColor colorFromHexString:kSeperatorLineColor] CGColor];
        textView.layer.cornerRadius = 4;
        textView.layer.borderWidth = 1;
        textView.editable = NO;
        textView.selectable = YES;
        
        
        self.valueField  = textView;
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

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return NO;
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


@end
