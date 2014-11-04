//
//  SMXWeekHeaderCell.m
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

#import "SMXWeekHeaderCell.h"
#import "SMXImportantFilesForCalendar.h"

@implementation SMXWeekHeaderCell

@synthesize label,dateLabel;
@synthesize imageView;
@synthesize date;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0., 0., self.frame.size.width, self.frame.size.height)];
        [imageView setAutoresizingMask:AR_LEFT_RIGHT];
        [imageView setContentMode:UIViewContentModeCenter];
        [self addSubview:imageView];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(0., 10., self.frame.size.width-3, self.frame.size.height-6)];
        [label setAutoresizingMask:AR_LEFT_RIGHT];
        [label setTextAlignment:NSTextAlignmentRight];
        [self addSubview:label];
        
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(3+self.frame.size.width, 10+0.,3-self.frame.size.width, self.frame.size.height-10)];
        [dateLabel setAutoresizingMask:AR_LEFT_RIGHT];
        [dateLabel setTextAlignment:NSTextAlignmentLeft];
        dateLabel.font = [UIFont systemFontOfSize:28];
        self.backgroundColor=[UIColor clearColor];
       // [self addSubview:dateLabel];
    }
    return self;
}

- (void)cleanCell {
    
    [imageView setImage:nil];
    [label setText:@""];
    [label setTextColor:[UIColor blackColor]];
    label.frame=CGRectMake(0., 10., self.frame.size.width-3, self.frame.size.height-6);
    
    [dateLabel setText:@""];
    [dateLabel setTextColor:[UIColor blackColor]];
    dateLabel.frame=CGRectMake(3+self.frame.size.width, 10+0., 3+self.frame.size.width/2, self.frame.size.height-10);
    date = nil;
    
    
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
