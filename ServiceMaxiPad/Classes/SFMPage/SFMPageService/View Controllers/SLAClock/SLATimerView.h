//
//  SLATimerView.h
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 09/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SLATimerView : UIView


@property(strong, nonatomic) IBOutlet UILabel *timerLabel;
@property(strong, nonatomic) IBOutlet UILabel *timeLabel;
@property(strong, nonatomic) IBOutlet UILabel *time;
@property(strong, nonatomic) IBOutlet UILabel *timeFormat;

@property(nonatomic,assign) NSInteger days;
@property(nonatomic,assign) NSInteger hours;
@property(nonatomic,assign) NSInteger minutes;
@property(nonatomic,assign) NSInteger second;

@property(nonatomic, strong)NSTimer *timer;

- (void)updateTimerLabel;
- (void)startTimer;
- (void)invalidateTimer;
- (void)updateSLATimeValue:(NSString *)timevalue
                timeFormat:(NSString *)format;

@end
