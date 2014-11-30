//
//  SMNavigationTitleView.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 18/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   SMNavigationTitleView.m
 *  @class  SMNavigationTitleView
 *
 *  @brief
 *
 *   This title view used to display navigation title with image if present.
 *
 *  @author Shubha S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "SMNavigationTitleView.h"
#import "StyleGuideConstants.h"

@implementation SMNavigationTitleView

#pragma mark - lyfecycle method

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize16];
        _titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:_titleLabel];
        
        _titleImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        [self addSubview:_titleImageView];
        
        self.isTitleImagePresent = NO;
        
    }
    return self;
}

- (void)layoutSubviews
{
    _titleLabel.frame = CGRectMake(0, 0,self.titleWidth+5 ,45);
    _titleLabel.backgroundColor = [UIColor clearColor];
    
    //Change the size based on image  size
    CGSize imageSize = CGSizeMake(50, 45);
    CGRect imageViewRect = CGRectMake(_titleLabel.frame.size.width,CGRectGetMidY(self.titleLabel.bounds) - imageSize.height/2, imageSize.width, imageSize.height);
    self.titleImageView.frame = imageViewRect;
    if (!self.isTitleImagePresent) {
        self.titleImageView.hidden = YES;
    }else{
        self.titleImageView.hidden = NO;
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
