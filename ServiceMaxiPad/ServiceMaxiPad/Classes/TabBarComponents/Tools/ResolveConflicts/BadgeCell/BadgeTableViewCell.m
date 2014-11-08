//
//  BadgeTableViewCell.m
//
//  Created by Pushpak on 28/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "BadgeTableViewCell.h"
#import "BadgeLabel.h"

@interface CustomTextField: UITextField

@end

@implementation CustomTextField

- (CGRect)rightViewRectForBounds:(CGRect)bounds{
    
    CGRect rightBounds = [super rightViewRectForBounds:bounds];
    NSInteger errorMargin = 3;
    rightBounds.origin.y -= CGRectGetHeight(bounds)/2 - errorMargin;
    return rightBounds ;
}

@end

@interface BadgeTableViewCell ()
@property (nonatomic) CustomTextField *textField;
@end

@implementation BadgeTableViewCell

@synthesize badge;

- (void)layoutBadge
{
    if (badge == nil || badge.hidden || [badge.text length] == 0) return;
    [badge sizeToFit];
    [self.textField sizeToFit];
    
    CGRect currentFrame = self.textField.frame;
    currentFrame.origin = CGPointMake(self.indentationWidth+5,
                                      CGRectGetHeight(self.frame)/2 - CGRectGetHeight(self.textField.frame)/2);
    
    if (CGRectGetWidth(self.textField.frame) > CGRectGetWidth(self.contentView.frame)) {
        
        currentFrame.size.width = CGRectGetWidth(self.contentView.frame) - CGRectGetWidth(badge.frame);
    }
    
    self.textField.frame = currentFrame;
}

- (void)createBadge
{
    self.textField = [CustomTextField new];
    self.textField.clipsToBounds = NO;
    self.textField.userInteractionEnabled = NO;
    self.textField.text = self.textLabel.text;
    self.textLabel.text = @"";
    self.textField.font = self.textLabel.font;
    self.badge = [[BadgeLabel alloc] init];
    self.textField.rightView = self.badge;
    self.textField.rightViewMode = UITextFieldViewModeAlways;
    [self.contentView addSubview:self.textField];
}

- (NSInteger)badgeNumber
{
    if (badge && !badge.hidden) {
        return [badge.text integerValue];
    }
    return 0;
}

- (void)setBadgeNumber:(NSInteger)badgeNumber
{
    if (badgeNumber == 0) {
        badge.hidden = YES;
        return;
    }

    if (!badge) {
        [self createBadge];
    }

    badge.text = [NSString stringWithFormat:@"%ld", (long)badgeNumber];
    badge.hidden = NO;
    [self layoutBadge];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutBadge];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected) {
        
        self.badge.textColor = self.textLabel.textColor;
        self.badge.layer.backgroundColor = [UIColor whiteColor].CGColor;
        self.textField.textColor = [UIColor whiteColor];;
        
    } else {
        
        self.badge.textColor = [UIColor whiteColor];
        self.badge.layer.backgroundColor = self.textLabel.textColor.CGColor;
        self.textField.textColor = self.textLabel.textColor;
    }
    
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.textField removeFromSuperview];
}
@end
