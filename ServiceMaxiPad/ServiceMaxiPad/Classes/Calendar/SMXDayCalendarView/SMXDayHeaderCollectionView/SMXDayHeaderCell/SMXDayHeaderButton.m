//
//  SMXDayHeaderButton.m
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


#import "SMXDayHeaderButton.h"

#import "SMXImportantFilesForCalendar.h"

static UIImage *imageCircleOrange;
static UIImage *imageCircleBlack;

@implementation SMXDayHeaderButton

#pragma mark - Synthesize

@synthesize date;

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [[UIImageView appearanceWhenContainedIn:[SMXDayHeaderButton class], nil] setContentMode:UIViewContentModeScaleAspectFit];
        
        [self setBackgroundColor:[UIColor whiteColor]];
        [self setContentMode:UIViewContentModeScaleAspectFit];

        if (!imageCircleBlack)
        {
            imageCircleBlack = [UIImage imageNamed:@"blackCircle"];
            imageCircleOrange = [UIImage imageNamed:@"orangeCircle"];
        }
        
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    }
    return self;
}


#pragma mark - Set Public Property

-(void)setSelected:(BOOL)selected {
    
    UIColor *customNonSelectedColor = [UIColor colorWithRed:121.0/255.0 green:121.0/255.0 blue:121.0/255.0 alpha:1.0];
    
    UIColor *customOrangeColor = [UIColor colorWithRed:225.0/255.0 green:80.0/255.0 blue:1.0/255.0 alpha:1.0];
    if (selected) {
        
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        if ([NSDate isTheSameDateTheCompA:[NSDate componentsOfDate:date] compB:[NSDate componentsOfCurrentDate]])
        {
            [self setBackgroundImage:imageCircleOrange forState:UIControlStateNormal];
        }
        else
        {
            [self setBackgroundImage:imageCircleOrange forState:UIControlStateNormal];
        }
        
    } else {
        if (date.componentsOfDate.weekday == 1 || date.componentsOfDate.weekday == 7) {
        
            if ([NSDate isTheSameDateTheCompA:[NSDate componentsOfDate:date] compB:[NSDate componentsOfCurrentDate]])
                [self setTitleColor:customOrangeColor forState:UIControlStateNormal];
            else
                [self setTitleColor:customNonSelectedColor forState:UIControlStateNormal];
        } else {
            
            if ([NSDate isTheSameDateTheCompA:[NSDate componentsOfDate:date] compB:[NSDate componentsOfCurrentDate]])
                [self setTitleColor:customOrangeColor forState:UIControlStateNormal];
            else
                [self setTitleColor:customNonSelectedColor forState:UIControlStateNormal];
        }
        
        [self setBackgroundImage:nil forState:UIControlStateNormal];
    }
}

@end
