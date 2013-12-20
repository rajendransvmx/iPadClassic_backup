//
//  ItemView.m
//  iServiceHomeScreen
//
//  Created by Aparna on 24/01/13.
//  Copyright (c) 2013 Aparna. All rights reserved.
//

#import "ItemView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ItemView

@synthesize iconImageView;
@synthesize titleLable;
@synthesize descriptionLabel;
@synthesize delegate;
@synthesize index;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
        index = -1;
        
        // Initialization code
        iconImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        titleLable = [[UILabel alloc]initWithFrame:CGRectZero];
        [titleLable setTextAlignment:NSTextAlignmentCenter];
        [titleLable setBackgroundColor:[UIColor clearColor]];
        [titleLable setFont:[UIFont boldSystemFontOfSize:17.00]];

        
        descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        descriptionLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        descriptionLabel.textAlignment = NSTextAlignmentCenter;
        descriptionLabel.numberOfLines = 3;
        [descriptionLabel setBackgroundColor:[UIColor clearColor]];

        
        [self addSubview:iconImageView];
        [self addSubview:titleLable];
        [self addSubview:descriptionLabel];
        
        CALayer *layer = [self layer];
        layer.borderWidth = 1.00;
        layer.borderColor = [UIColor lightGrayColor].CGColor;
        layer.cornerRadius = 20.00;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestute:)];
        [self addGestureRecognizer:tapGesture];
        [tapGesture release];

        
    }
    return self;
}

- (void)dealloc
{
    self.iconImageView = nil;
    self.titleLable = nil;
    self.descriptionLabel = nil;
    self.delegate = nil;
    [super dealloc];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize viewSize = self.frame.size;
    
    [titleLable setBounds:CGRectMake(0, 0, (viewSize.width*2.00)/3.00, viewSize.height/6.00)];
    [titleLable setCenter:CGPointMake(CGRectGetMidX(self.bounds), titleLable.bounds.size.height/2.00)];
    
    
    [iconImageView setBounds:CGRectMake(0, 0, (viewSize.width/3.00)-10, viewSize.height-10)];
    [iconImageView setCenter:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))];

    [descriptionLabel setBounds:CGRectMake(0, 0,viewSize.width-16, (viewSize.height*3)/4.00)];
    [descriptionLabel setCenter:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMaxY(iconImageView.frame)-30)];

}


- (void)handleTapGestute:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([delegate respondsToSelector:@selector(tappedOnViewAtIndex:)])
    {
        [delegate tappedOnViewAtIndex:self.index];
    }

}

@end
