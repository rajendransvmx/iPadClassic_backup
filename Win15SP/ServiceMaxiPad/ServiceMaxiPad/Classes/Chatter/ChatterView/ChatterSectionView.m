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

@property(nonatomic, retain)CusTextField *textField;
@property(nonatomic, retain)UIButton *button;
@property(nonatomic, retain)UIView *borderView;

@end

@implementation ChatterSectionView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithHexString:kActionBgColor];
        [self populateUI];
    }
    return self;
}

- (void)populateUI
{
    self.textField = [[CusTextField alloc] initWithFrame:CGRectZero];
    
    self.textField.placeholder = @"New post";
    self.textField.delegate = self;
    
    [self addSubview:self.textField];
    
    self.button = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.button setTitle:[[TagManager sharedInstance] tagByName:kTagSfmChatterShreButton] forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor colorWithHexString:@"#E15001"] forState:UIControlStateNormal];
    [self.button.titleLabel setFont:[UIFont fontWithName:kHelveticaNeueThin size:kFontSize16]];
    
    [self addSubview:self.button];
    
    [self addBoottomBorder];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.frame;
    
    self.textField.frame = CGRectMake(frame.origin.x +10, frame.origin.y + 10, frame.size.width - 120, frame.size.height - 15);
    self.button.frame = CGRectMake(CGRectGetMaxX(self.textField.frame) + 20,
                                   frame.origin.y + 15, 70, 30);
    [self.textField drawPlaceholderInRect:self.textField.frame];
    
    self.borderView.frame = CGRectMake(0.0f, CGRectGetMaxY(frame) - 1, frame.size.width, 1.0f);
}

- (void)addBoottomBorder
{
    self.borderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.borderView.backgroundColor = [UIColor colorWithHexString:@"#CECECE"];
    self.borderView.autoresizingMask = UIViewAutoresizingFlexibleWidth ;
    [self addSubview:self.borderView];
}

@end
