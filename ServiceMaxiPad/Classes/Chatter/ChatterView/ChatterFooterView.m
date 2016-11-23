//
//  ChatterFooterView.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 16/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ChatterFooterView.h"
#import "StyleManager.h"
#import "CusTextField.h"
#import "TagManager.h"

@interface ChatterFooterView ()

@property(nonatomic, strong)CusTextField *textField;
@property(nonatomic, strong)UIView *borderView;
@property(nonatomic, strong)NSString *textFieldText;
@end

@implementation ChatterFooterView

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.contentView.backgroundColor = [UIColor getUIColorFromHexValue:kActionBgColor];
        [self populateUI];
    }
    return self;
}

- (void)populateUI
{
    self.textFieldText = @"";
    self.textField = [[CusTextField alloc] initWithFrame:CGRectZero];
    self.textField.placeholder = [[TagManager sharedInstance]tagByName:kTag_Reply];
    self.textField.delegate = self;
    [self.contentView addSubview:self.textField];
    
    [self addBoottomBorder];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.bounds;
    self.textField.frame = CGRectMake(frame.origin.x +10, frame.origin.y + 5,frame.size.width - 20, frame.size.height - 10);
    self.borderView.frame = CGRectMake(0.0f, CGRectGetMaxY(frame) - 1, frame.size.width, 1.0f);
}

- (void)addBoottomBorder
{
    self.borderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.borderView.backgroundColor = [UIColor getUIColorFromHexValue:@"#CECECE"];
    self.borderView.autoresizingMask = UIViewAutoresizingFlexibleWidth ;
    [self.contentView addSubview:self.borderView];
}

-(void)prepareForReuse
{
    self.textField.text = @"";
}

- (void)setTextFieldValue:(NSString *)text
{
    self.textField.text = text;
}

#pragma mark - TextField Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.textField.section = self.section;
    if ([self.footerTextFieldDelegate respondsToSelector:@selector(textEditingBegan:)]) {
        [self.footerTextFieldDelegate textEditingBegan:self.textField];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self.footerTextFieldDelegate respondsToSelector:@selector(textFieldReturned)]) {
        [self.footerTextFieldDelegate textFieldReturned];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.returnKeyType == UIReturnKeyDefault) {
        [textField resignFirstResponder];
        if ([self.footerTextFieldDelegate respondsToSelector:@selector(textEditingDone)]) {
            [self.footerTextFieldDelegate textEditingDone];
        }
    }
    return YES;
}
#pragma mark - End
@end
