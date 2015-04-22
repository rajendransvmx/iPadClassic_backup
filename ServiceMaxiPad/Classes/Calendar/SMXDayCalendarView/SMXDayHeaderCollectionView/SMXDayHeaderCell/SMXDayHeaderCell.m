//
//  SMXDayHeaderCell.m
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


#import "SMXDayHeaderCell.h"

#import "SMXImportantFilesForCalendar.h"

@implementation SMXDayHeaderCell

@synthesize button;
@synthesize date;
@synthesize dayLabel, monthName,yearLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
//        UIView *myView = [[UIView alloc]initWithFrame:CGRectMake(0., 60.0, 300, 40)];
//        myView.backgroundColor = [UIColor whiteColor];
//        [self addSubview:myView];
        
        button = [[SMXDayHeaderButton alloc] initWithFrame:CGRectMake(0., 35.0, 30.0 + 17.0, 30.0)];
        
//        [button setBackgroundColor:[UIColor redColor]];
        
        
        dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 30.0 + 17.0, 20.0)];
        dayLabel.textColor = [UIColor grayColor];
        dayLabel.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];
        dayLabel.textAlignment = NSTextAlignmentCenter;
        
        [self setBackgroundColor:[UIColor whiteColor]];
//        self.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];

        
        [self addSubview:monthName];
        [self addSubview:yearLabel];
        [self addSubview:button];
        [self addSubview:dayLabel];
        
        [self setAutoresizingMask:AR_LEFT_RIGHT | UIViewAutoresizingFlexibleWidth];
    }
    return self;
}

- (void)setDate:(NSDate *)_date {
    
    date = _date;
    [button setDate:_date];
}





@end
