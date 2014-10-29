//
//  SMXMonthHeaderView.m
/**
 *  @file   FILE_NAME.m
 *  @class  CLASS_NAME
 *
 *  @brief  This class will provide .....
 *
 *
 *
 *  @author  AUTHOR_NAME
 *
 *  @bug     No known bugs
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "SMXMonthHeaderView.h"

#import "SMXImportantFilesForCalendar.h"

@implementation SMXMonthHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        NSArray *arrayColor = @[[UIColor grayColor], [UIColor blackColor], [UIColor blackColor], [UIColor blackColor], [UIColor blackColor], [UIColor blackColor], [UIColor grayColor]];
        CGFloat width = (self.frame.size.width-6*SPACE_COLLECTIONVIEW_CELL)/7.;
        
        for (int i = 0; i < [arrayWeekAbrevWithThreeChars count]; i++) {

            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i*(width+SPACE_COLLECTIONVIEW_CELL), 10., width-5., self.frame.size.height-10)];
            [label setTextAlignment:NSTextAlignmentRight];
            [label setText:[arrayWeekAbrevWithThreeChars objectAtIndex:i]];
            [label setTextColor:[arrayColor objectAtIndex:i]];
            [label setFont:[UIFont boldSystemFontOfSize:label.font.pointSize]];
            [label setFont:[UIFont fontWithName:@"Helvetica Neue" size:20]];
            [label setAutoresizingMask:AR_LEFT_RIGHT | UIViewAutoresizingFlexibleWidth];
            [self addSubview:label];
        }

    }
    return self;
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
