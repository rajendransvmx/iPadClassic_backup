//
//  TableViewCell.m
//  iServiceHomeScreen
//
//  Created by Aparna on 24/01/13.
//  Copyright (c) 2013 Aparna. All rights reserved.
//

#import "GridViewCell.h"

#define CELL_SPACING 20.00
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
     //   isNotIOS7 = floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1;
        //iOS 8 crash fix
        
        isNotIOS7 = ([[[UIDevice currentDevice] systemVersion] integerValue] < 7 || [[[UIDevice currentDevice] systemVersion] integerValue] >= 8);
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setColumnCount:(int)aColumnCount
{
    columnCount = aColumnCount;
    
    NSArray *allSubviews = nil;
    UIView *scrollView = nil;
    
    allSubviews = [self subviews];
    scrollView  = [[self subviews] objectAtIndex:0] ;
    allSubviews = [scrollView subviews];
    //First remove all the subviews added to the
    for (UIView *view in allSubviews)
    {
        if([view isKindOfClass:[ItemView class]])
        {
            [view removeFromSuperview];
        }
    }
    
    //Add the subviews as specified as column count
    for (int i=0;i<self.columnCount;i++)
    {
        ItemView *itemView = [[ItemView alloc] initWithFrame:CGRectZero];
        [scrollView addSubview:itemView];
        [itemView release];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize cellSize = self.frame.size;
    
    NSArray *subviews = nil;
    subviews = [[[self subviews] objectAtIndex:0] subviews];
    ItemView *itemView = nil;
    
    float lastItemViewOriginX = 0.0;
    for (int i=0;i<[subviews count];i++)
    {
        if([ [subviews objectAtIndex:i] isKindOfClass:[ItemView class]])
        {
            itemView = [subviews objectAtIndex:i];
            [itemView setFrame:CGRectMake(lastItemViewOriginX+CELL_SPACING,CELL_SPACING,(cellSize.width-(4*CELL_SPACING))/3.00, cellSize.height-CELL_SPACING)];
            
            lastItemViewOriginX = CGRectGetMaxX(itemView.frame);
        }
    }
}

- (ItemView *) itemViewAtColumn:(int)column;
{
    UIView *scrollView = [[self subviews] objectAtIndex:0] ;
    NSArray *allSubviews = [scrollView subviews];
    if(isNotIOS7)
        return [allSubviews objectAtIndex:column];
    else
        return [allSubviews objectAtIndex:(column + 1)];
}

@end
