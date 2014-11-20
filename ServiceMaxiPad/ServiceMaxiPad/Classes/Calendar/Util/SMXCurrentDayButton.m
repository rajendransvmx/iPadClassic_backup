//
//  SMXCurrentDayButton.m
//  ServiceMaxiPad
//
//  Created by Niraj Kumar on 11/20/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "SMXCurrentDayButton.h"
#import "SMXDateManager.h"
#import "StyleManager.h"
#import "StyleGuideConstants.h"
#import "NSDate+SMXDaysCount.h"
#import "SMXConstants.h"
#import "CalendarPopupContent.h"

@implementation SMXCurrentDayButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)initialsetup:(UIView *)parent{
    [self setTitle:@"Today" forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    self.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:18.0];
    [self addTarget:self action:@selector(loadCurrentWeek:) forControlEvents:UIControlEventTouchUpInside];
    self.titleLabel.textAlignment=NSTextAlignmentRight;
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.center=CGPointMake(parent.frame.size.width/2.,parent.frame.size.height-25.);
    self.backgroundColor=[UIColor colorWithHexString:kOrangeColor];
}
-(void)buttonBorder:(UIButton *)button{
    button.layer.borderWidth=0.0f;
    button.layer.borderColor=[UIColor colorWithHexString:kOrangeColor].CGColor;
    button.layer.cornerRadius = 2.f;
}
-(void)loadCurrentWeek:(id)sender{
    NSDate *date=[NSDate dateWithYear:[NSDate componentsOfCurrentDate].year
                                month:[NSDate componentsOfCurrentDate].month
                                  day:[NSDate componentsOfCurrentDate].day];
    [[SMXDateManager sharedManager] setCurrentDate:date];
    if ([CalendarPopupContent getDayPopup]) {
        
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:DATE_MONTH_TEXT_NOTIFICATION object:date];
    }
    [delegate removeCalender];
}
- (void) setDelegate:(id)newDelegate{
    delegate = newDelegate;
}

@end
