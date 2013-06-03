//
//  TableViewCell.m
//  iServiceHomeScreen
//
//  Created by Aparna on 24/01/13.
//  Copyright (c) 2013 Aparna. All rights reserved.
//

#import "GridViewCell.h"

#define CELL_SPACING 20.00

@implementation GridViewCell

@synthesize columnCount;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        self.columnCount = 1;
        
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
    
    NSArray *allSubviews = [self subviews];
    
    //First remove all the subviews added to the 
    for (UIView *view in allSubviews)
    {
        [view removeFromSuperview];
        
    }
    
    //Add the subviews as specified as column count
    for (int i=0;i<self.columnCount;i++)
    {
        ItemView *itemView = [[ItemView alloc] initWithFrame:CGRectZero];
        [self addSubview:itemView];
        [itemView release];
    }
}

- (void)layoutSubviews
{
     NSLog(@"layoutSubviews");
     
     [super layoutSubviews];
 
     CGSize cellSize = self.frame.size;
 
     NSArray *subviews = [self subviews];
     
     ItemView *itemView = nil;
     
     float lastItemViewOriginX = 0.0;
     
     for (int i=1;i<=self.columnCount;i++)
     {
         itemView = [subviews objectAtIndex:i-1];
         [itemView setFrame:CGRectMake(lastItemViewOriginX+CELL_SPACING,CELL_SPACING,(cellSize.width-(4*CELL_SPACING))/3.00, cellSize.height-CELL_SPACING)];

         lastItemViewOriginX = CGRectGetMaxX(itemView.frame);
     }
      
}

- (ItemView *) itemViewAtColumn:(int)column;
{
    return [[self subviews] objectAtIndex:column];
}

@end
