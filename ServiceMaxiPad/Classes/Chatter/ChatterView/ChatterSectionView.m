//
//  ChatterSectionView.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 16/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ChatterSectionView.h"
#import "StyleManager.h"
#import "TagManager.h"
#import "StyleGuideConstants.h"
#import "CusTextField.h"

@interface ChatterSectionView ()

@property(weak, nonatomic)IBOutlet CusTextField *textField;
@property(weak, nonatomic)IBOutlet UIButton *button;
@property(weak, nonatomic)IBOutlet UIView *borderView;

@end

@implementation ChatterSectionView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        //Do something
    }
    return self;
}

 - (void)awakeFromNib
{
    [super awakeFromNib];
    [self populateUI];
    
}

- (void)populateUI
{
    self.backgroundColor = [UIColor getUIColorFromHexValue:kActionBgColor];
    
    self.textField.placeholder = [[TagManager sharedInstance] tagByName:kTag_NewPost];
    self.textField.delegate = self;
    
    [self.button setTitle:[[TagManager sharedInstance] tagByName:kTagSfmChatterShreButton] forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor getUIColorFromHexValue:@"#E15001"] forState:UIControlStateNormal];
    [self.button.titleLabel setFont:[UIFont fontWithName:kHelveticaNeueThin size:kFontSize16]];
    [self.button addTarget:self action:@selector(shareButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self addBoottomBorder];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)addBoottomBorder
{
    self.borderView.backgroundColor = [UIColor getUIColorFromHexValue:@"#CECECE"];
    self.borderView.autoresizingMask = UIViewAutoresizingFlexibleWidth ;
}

- (void)shareButtonClicked
{
    if ([self.sectionTextFieldDelegate respondsToSelector:@selector(sectiontextEditingDone:)]) {
        [self.sectionTextFieldDelegate sectiontextEditingDone:self.textField];
    }
}

#pragma mark - TextField Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([self.sectionTextFieldDelegate respondsToSelector:@selector(textEditingBegan:)]) {
        [self.sectionTextFieldDelegate textEditingBegan:self.textField];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.returnKeyType == UIReturnKeyDefault) {
        [textField resignFirstResponder];
    }
    
    return YES;
}
#pragma mark - End

@end
