//
//  TimerClass.h
//  MultipleDetailViews
//
//  Created by Samman Banerjee on 27/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    TimerClassTypeResolution, 
    TimerClassTypeRestoration
}TimerClassType;

@interface TimerClass : UIViewController
{
    NSTimer * timer;
    NSUInteger days, hours, minutes, seconds;
    
    IBOutlet UILabel * dayLabel, * hourLabel, * minuteLabel, * secondLabel;
    IBOutlet UILabel * flasher1, * flasher2;
    
    NSMutableDictionary * slaTimer;
    
    TimerClassType type;
    
    BOOL isTimerRunning;
}

@property TimerClassType type;
@property (nonatomic, retain) NSMutableDictionary * slaTimer;

- (void) StartCountdownFromDays:(NSUInteger)_days Hours:(NSUInteger)_hours Minutes:(NSUInteger)_minutes Seconds:(NSUInteger)_seconds;
- (void) ResetTimer;

- (void) DecrSec;
- (void) DecrMin;
- (void) DecrHrs;
- (void) DecrDay;
- (void) updateTimerLabel:(NSString *) updatedTime;
@end
