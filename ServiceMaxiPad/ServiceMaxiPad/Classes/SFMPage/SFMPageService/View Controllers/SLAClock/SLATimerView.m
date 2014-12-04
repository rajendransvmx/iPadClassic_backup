//
//  SLATimerView.m
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 09/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SLATimerView.h"

@implementation SLATimerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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

- (void)updateTimerLabel
{
    NSString *value = @"";
    
    if (self.days < 10)
        value = [value stringByAppendingString:[NSString stringWithFormat:@"0%d",self.days]];
    else
        value = [value stringByAppendingString:[NSString stringWithFormat:@"%d",self.days]];
    
    if (self.hours < 10)
        value = [value stringByAppendingString:[NSString stringWithFormat:@":0%d",self.hours]];
    else
        value = [value stringByAppendingString:[NSString stringWithFormat:@":%d",self.hours]];
    
    if (self.minutes < 10)
        value = [value stringByAppendingString:[NSString stringWithFormat:@":0%d",self.minutes]];
    else
        value = [value stringByAppendingString:[NSString stringWithFormat:@":%d",self.minutes]];
    
    if (self.second < 10)
        value = [value stringByAppendingString:[NSString stringWithFormat:@":0%d",self.second]];
    else
        value = [value stringByAppendingString:[NSString stringWithFormat:@":%d",self.second]];
    
    self.timerLabel.text = [NSString stringWithFormat:@"(%@ remain)", value];
}

- (void)startTimer
{
    [self invalidateTimer];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                  target:self
                                                selector:@selector(DecrSec)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void) DecrSec
{
    if (self.second == 0)
    {
        if ((self.minutes == 0) && (self.hours == 0) && (self.days == 0))
        {
            [self invalidateTimer];
        }
        else
        {
            self.second = 59;
            [self DecrMin];
        }
    }
    else
        --self.second;
    
    [self updateTimerLabel];
}

- (void) DecrMin
{
    if (self.minutes == 0)
    {
        self.minutes = 59;
        [self DecrHrs];
    }
    else
        --self.minutes;
    
    [self updateTimerLabel];
}

- (void) DecrHrs
{
    if (self.hours == 00)
    {
        self.hours = 59;
        [self DecrDay];
    }
    else
        --self.hours;
    
    
    [self updateTimerLabel];
}

- (void) DecrDay
{
    if (self.days == 0)
    {
        // Stop timer as countdown has ended
        [self invalidateTimer];
    }
    else
        --self.days;
    
    [self updateTimerLabel];
}

- (void)invalidateTimer
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
}

- (void)updateSLATimeValue:(NSString *)timevalue
                timeFormat:(NSString *)format
{
    if ([timevalue length] > 0){
        self.time.text = timevalue;
    }
    else {
        self.time.text = @"00:00";
    }
    
    if ([format length] > 0){
        self.timeFormat.text = format;
    }
    else{
        CGRect frame = self.timerLabel.frame;
        frame.origin.x = 182 - self.timeFormat.frame.size.width - 5;
        self.timerLabel.frame = frame;
    }
    
}


- (void)dealloc {
    [super dealloc];
}
@end
