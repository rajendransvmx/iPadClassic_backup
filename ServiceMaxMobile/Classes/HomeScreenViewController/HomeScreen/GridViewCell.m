//
//  TableViewCell.m
//  iServiceHomeScreen
//
//  Created by Aparna on 24/01/13.
//  Copyright (c) 2013 Aparna. All rights reserved.
//
/**
 *  @file   GridViewCell.m
 *  @class  GridViewCell
 *
 *  @brief  Function prototypes for the console driver.
 *
 *
 *  This contains the prototypes for the console
 *  driver and eventually any macros, constants,
 *  or global variables you will need.
 *
 *  @author  Aparna
 *  @author  Vipindas Palli
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/


#import "GridViewCell.h"

static const float kCellSpacing  = 20.00f;

@interface GridViewCell()
{
    BOOL isNotIOS7;
}
@end


@implementation GridViewCell

@synthesize columnCount;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        self.columnCount = 1;
        isNotIOS7 = floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1;
    }
    
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

/**
 * @name  <MethodName. optional>
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

- (void)setColumnCount:(int)aColumnCount
{
    columnCount = aColumnCount;
    
    NSArray *allSubviews = nil;
    UIView  *scrollView = nil;
    
    allSubviews = [self subviews];
    scrollView  = [[self subviews] objectAtIndex:0] ;
    allSubviews = [scrollView subviews];
    
    /**  First remove all the subviews added to the parent view */
    for (UIView *view in allSubviews)
    {
        if ([view isKindOfClass:[ItemView class]])
        {
            [view removeFromSuperview];
        }
    }
    
    /** Add the subviews as specified as column count */
    for (int i = 0; i < self.columnCount ; i++)
    {
        ItemView *itemView = [[ItemView alloc] initWithFrame:CGRectZero];
        [scrollView addSubview:itemView];
        [itemView release];
    }
}

/**
 * @name  <MethodName. optional>
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize cellSize = self.frame.size;
    
    NSArray *subviews = nil;
    subviews = [[[self subviews] objectAtIndex:0] subviews];
    ItemView *itemView = nil;
    
    float lastItemViewOriginX = 0.0;
    
    for (int i = 0; i < [subviews count]; i++)
    {
        if([ [subviews objectAtIndex:i] isKindOfClass:[ItemView class]])
        {
            itemView = [subviews objectAtIndex:i];
            [itemView setFrame:CGRectMake(lastItemViewOriginX+kCellSpacing,
                                          kCellSpacing,
                                          (cellSize.width-(4*kCellSpacing))/3.00,
                                          cellSize.height-kCellSpacing)];
            
            lastItemViewOriginX = CGRectGetMaxX(itemView.frame);
        }
    }
}

/**
 * @name  <MethodName. optional>
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

- (ItemView *)itemViewAtColumn:(int)column
{
    UIView *scrollView = [[self subviews] objectAtIndex:0];
    NSArray *allSubviews = [scrollView subviews];
    
    if (isNotIOS7)
    {
        return [allSubviews objectAtIndex:column];
    }
    else
    {
        return [allSubviews objectAtIndex:(column + 1)];
    }
}

@end
