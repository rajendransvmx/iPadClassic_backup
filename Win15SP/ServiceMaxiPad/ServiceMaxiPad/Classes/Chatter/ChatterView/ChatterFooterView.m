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

@interface ChatterFooterView ()

@property(nonatomic, retain)CusTextField *textField;
@property(nonatomic, retain)UIView *borderView;

@end

@implementation ChatterFooterView

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self == [super initWithReuseIdentifier:reuseIdentifier]) {
        
        self.contentView.backgroundColor = [UIColor colorWithHexString:kActionBgColor];
        [self populateUI];
    }
    return self;
}

- (void)populateUI
{
    self.textField = [[CusTextField alloc] initWithFrame:CGRectZero];
    self.textField.placeholder = @"Reply";
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
    self.borderView.backgroundColor = [UIColor colorWithHexString:@"#CECECE"];
    self.borderView.autoresizingMask = UIViewAutoresizingFlexibleWidth ;
    [self.contentView addSubview:self.borderView];
}

#pragma mark - TextField Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}


#pragma mark - End
@end
