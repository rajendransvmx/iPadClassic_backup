//
//  SFMSearchSection.m
//  ServiceMaxiPhone
//
//  Created by Damodar on 4/16/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "SFMSearchSection.h"
#import "StyleManager.h"

@implementation SFMSearchSection

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self= [super initWithReuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:self.titleLabel];
        
        float seperatorPadding = 10.0f;
        float seperatorHeight = 1.0f;
        
        /** Seperator for Search section */
        UIView *seperatorView = [[UIView alloc] initWithFrame:CGRectMake(seperatorPadding, self.frame.size.height - seperatorHeight, self.frame.size.width - 2 * (seperatorPadding), seperatorHeight)];
        seperatorView.tag = 101;
        seperatorView.backgroundColor = [UIColor colorWithHexString:kSeperatorLineColorForSearchSection];
        [self addSubview:seperatorView];
        
        /** Accessory image view for Search section */
        self.accessoryImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        self.accessoryImageView.contentMode = UIViewContentModeCenter;
        [self addSubview:self.accessoryImageView];
        
        /** Add tap guesture */
        UITapGestureRecognizer * recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:recognizer];
        
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    [self viewWithTag:101].hidden = NO;
    
    float padding = 10.0f;
    float seperatorHeight = 1.0f;
    float accessoryWidth = 13.0f;
    float titleViewAcessoryPadding = 5.0f;
    
    self.accessoryImageView.frame = CGRectMake(padding, 0, accessoryWidth, self.frame.size.height);
    
    self.titleLabel.frame = CGRectMake((self.accessoryImageView.frame.size.width + (accessoryWidth + titleViewAcessoryPadding)), 0, self.frame.size.width-padding, self.frame.size.height);
    
    [[self viewWithTag:101] setFrame:CGRectMake(padding, self.frame.size.height - seperatorHeight, self.frame.size.width - 2 * (padding), seperatorHeight)];
}

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    [self viewWithTag:101].hidden = YES;
        if ([self.delegate respondsToSelector:@selector(didTapOnSection:)])
        {
            [self.delegate didTapOnSection:(int)self.section];
        }
}

@end
