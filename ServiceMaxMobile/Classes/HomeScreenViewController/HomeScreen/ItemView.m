//
//  ItemView.m
//  iServiceHomeScreen
//
//  Created by Aparna on 24/01/13.
//  Copyright (c) 2013 Aparna. All rights reserved.
//

/**
 *  @file   ItemView.m
 *  @class  ItemView
 *
 *  @brief  Function prototypes for the console driver.
 *
 *
 *  @author  Aparna
 *  @author  Vipindas Palli
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "ItemView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ItemView

@synthesize menuItemType;
@synthesize iconImageView;
@synthesize titleLabel;
@synthesize descriptionLabel;
@synthesize delegate;
@synthesize index;


/**
 * @name  initWithFrame:
 *
 * @author Aparna
 *
 * @brief <A short one line description>
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param  Description of method's or function's input parameter
 * @param  ...
 *
 * @return Description of the return value
 *
 */

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
        index = -1;
        
        /**  Icon view initialization */
        iconImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        /**  Title label initialization */
        titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:17.00]];

        /**  Description label initialization  */
        descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        descriptionLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        descriptionLabel.textAlignment = NSTextAlignmentCenter;
        descriptionLabel.numberOfLines = 3;
        [descriptionLabel setBackgroundColor:[UIColor clearColor]];

        
        [self addSubview:iconImageView];
        [self addSubview:titleLabel];
        [self addSubview:descriptionLabel];
        
        CALayer *layer = [self layer];
        layer.borderWidth = 1.00;
        layer.borderColor = [UIColor lightGrayColor].CGColor;
        layer.cornerRadius = 20.00;
        
        /** Adding tap gesture recognization to view */
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestute:)];
        [self addGestureRecognizer:tapGesture];
        [tapGesture release];
    }
    return self;
}


- (void)dealloc
{
    self.iconImageView = nil;
    self.titleLabel = nil;
    self.descriptionLabel = nil;
    self.delegate = nil;
    [super dealloc];
}

/**
 * @name  layoutSubviews
 *
 * @author Aparna
 *
 * @brief <A short one line description>
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param  Description of method's or function's input parameter
 * @param  ...
 *
 * @return void
 *
 */

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize viewSize = self.frame.size;
    
    [titleLabel setBounds:CGRectMake(0, 0, (viewSize.width*2.00)/3.00, viewSize.height/6.00)];
    [titleLabel setCenter:CGPointMake(CGRectGetMidX(self.bounds), titleLabel.bounds.size.height/2.00)];
    
    [iconImageView setBounds:CGRectMake(0, 0, (viewSize.width/3.00)-10.0, viewSize.height-10.0)];
    [iconImageView setCenter:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))];

    [descriptionLabel setBounds:CGRectMake(0, 0,viewSize.width-16, (viewSize.height*3)/4.00)];
    [descriptionLabel setCenter:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMaxY(iconImageView.frame)-30)];
}

/**
 * @name  handleTapGestute:
 *
 * @author Aparna
 *
 * @brief <A short one line description>
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param  Description of method's or function's input parameter
 * @param  ...
 *
 * @return Description of the return value
 *
 */

- (void)handleTapGestute:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([delegate respondsToSelector:@selector(tappedOnViewAtIndex:)])
    {
        [delegate tappedOnViewAtIndex:self.menuItemType];
    }
}

@end
