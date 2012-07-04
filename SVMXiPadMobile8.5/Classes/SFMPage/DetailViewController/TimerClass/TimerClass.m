//
//  TimerClass.m
//  MultipleDetailViews
//
//  Created by Samman Banerjee on 27/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TimerClass.h"
#import "WSIntfGlobals.h"

@implementation TimerClass

@synthesize type, slaTimer;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the font for the clock
    // use the font name here, not the filename
    // UIFont *myCustomFont = [UIFont fontWithName:@"DS-Digital" size:30];
    
    [dayLabel setFont:[UIFont fontWithName:@"DS-Digital" size:38]];
    [hourLabel setFont:[UIFont fontWithName:@"DS-Digital" size:38]];
    [minuteLabel setFont:[UIFont fontWithName:@"DS-Digital" size:38]];
    [secondLabel setFont:[UIFont fontWithName:@"DS-Digital" size:38]];
}

- (void) StartCountdownFromDays:(NSUInteger)_days Hours:(NSUInteger)_hours Minutes:(NSUInteger)_minutes Seconds:(NSUInteger)_seconds;
{
    days = _days>99?99:_days;
    hours = _hours>59?59:_hours;
    minutes = _minutes>59?59:_minutes;
    seconds = _seconds>59?59:_seconds;
    
    if (days < 10)
        dayLabel.text = [NSString stringWithFormat:@"0%d", days];
    else
        dayLabel.text = [NSString stringWithFormat:@"%d", days];
    
    if (hours < 10)
        hourLabel.text = [NSString stringWithFormat:@"0%d", hours];
    else
        hourLabel.text = [NSString stringWithFormat:@"%d", hours];
    
    if (minutes < 10)
        minuteLabel.text = [NSString stringWithFormat:@"0%d", minutes];
    else
        minuteLabel.text = [NSString stringWithFormat:@"%d", minutes];
    
    if (seconds < 10)
        secondLabel.text = [NSString stringWithFormat:@"0%d", seconds];
    else
        secondLabel.text = [NSString stringWithFormat:@"%d", seconds];
    
    isTimerRunning = YES;
    [NSThread detachNewThreadSelector:@selector(startTimerThread) toTarget:self withObject:nil];

    // timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(DecrSec) userInfo:nil repeats:YES];
}

- (void) startTimerThread
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];	
	NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                             target:self					  
                                           selector:@selector(DecrSec)
                                           userInfo:nil
                                            repeats:YES];
    
	[runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    [pool release];
}

- (void) updateTimerLabel:(NSString *) updatedTime
{
    //Update timer label
    if (isTimerRunning)
    {
        [timer invalidate];
        isTimerRunning = NO;
    }
    
    NSArray * components = [updatedTime componentsSeparatedByString:@":"];
    NSInteger days_value = [[components objectAtIndex:0] intValue];
    NSInteger hours_value = [[components objectAtIndex:1] intValue];
    NSInteger minutes_value = [[components objectAtIndex:2] intValue];
    NSInteger seconds_value = [[components objectAtIndex:3] intValue];
    if (days_value < 10)
        dayLabel.text = [NSString stringWithFormat:@"0%d", days_value];
    else
        dayLabel.text = [NSString stringWithFormat:@"%d", days_value];
    
    if (hours_value < 10)
        hourLabel.text = [NSString stringWithFormat:@"0%d", hours_value];
    else
        hourLabel.text = [NSString stringWithFormat:@"%d", hours_value];
    
    if (minutes_value < 10)
        minuteLabel.text = [NSString stringWithFormat:@"0%d", minutes_value];
    else
        minuteLabel.text = [NSString stringWithFormat:@"%d", minutes_value];
    
    if (seconds_value < 10)
        secondLabel.text = [NSString stringWithFormat:@"0%d", seconds_value];
    else
        secondLabel.text = [NSString stringWithFormat:@"%d", seconds_value];
    NSLog(@"Day = %@ Hour = %@ Min = %@ Sec = %@",dayLabel.text,hourLabel.text,minuteLabel.text,secondLabel.text);
}

- (void) ResetTimer
{
    if (isTimerRunning)
    {
        [timer invalidate];
        isTimerRunning = NO;
    }
    dayLabel.text = hourLabel.text = minuteLabel.text = secondLabel.text = @"00";
}

- (void) FlasherFadeIn:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    // [UIView beginAnimations:@"flasher" context:nil];
    // [UIView setAnimationDuration:0.5];
    flasher1.alpha = 1.0;
    flasher2.alpha = 1.0;
    // [UIView commitAnimations];
}

- (void) FlasherFadeOut:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    // [UIView beginAnimations:@"flasher" context:nil];
    // [UIView setAnimationDuration:0.5];
    flasher1.alpha = 0.0;
    flasher2.alpha = 0.0;
    // [UIView commitAnimations];
}

- (void) DecrSec
{
/*
    if (flasher1.alpha == 1.0)
    {
        [UIView beginAnimations:@"flasher" context:nil];
        [UIView setAnimationDuration:0.5];
        // [UIView setAnimationDelegate:self];
        // [UIView setAnimationDidStopSelector:@selector(FlasherFadeIn:finished:context:)];
        flasher1.alpha = 0.0;
        flasher2.alpha = 0.0;
        [UIView commitAnimations];
    }
    else
    {
        [UIView beginAnimations:@"flasher" context:nil];
        [UIView setAnimationDuration:0.5];
        // [UIView setAnimationDelegate:self];
        // [UIView setAnimationDidStopSelector:@selector(FlasherFadeOut:finished:context:)];
        flasher1.alpha = 1.0;
        flasher2.alpha = 1.0;
        [UIView commitAnimations];
    }
*/
    if (seconds == 0)
    {
        if ((minutes == 0) && (hours == 0) && (days == 0))
        {
            [timer invalidate];
            isTimerRunning = NO;
        }
        else
        {
            seconds = 59;
            [self DecrMin];
        }
    }
    else
        --seconds;
    
    if (seconds < 10)
        secondLabel.text = [NSString stringWithFormat:@"0%d", seconds];
    else
        secondLabel.text = [NSString stringWithFormat:@"%d", seconds];
    
    NSString * updatedTime = [NSString stringWithFormat:@"%@:%@:%@:%@", dayLabel.text, hourLabel.text, minuteLabel.text, secondLabel.text];
    
    if (type == TimerClassTypeResolution)
    {
        [slaTimer setValue:updatedTime forKey:RESOLUTIONTIME];
    }
    else if (type == TimerClassTypeRestoration)
    {
        [slaTimer setValue:updatedTime forKey:RESTORATIONTIME];
    }
}

- (void) DecrMin
{
    if (minutes == 0)
    {
        minutes = 59;
        [self DecrHrs];
    }
    else
        --minutes;
    
    if (minutes < 10)
        minuteLabel.text = [NSString stringWithFormat:@"0%d", minutes];
    else
        minuteLabel.text = [NSString stringWithFormat:@"%d", minutes];
}

- (void) DecrHrs
{
    if (hours == 00)
    {
        hours = 59;
        [self DecrDay];
    }
    else
        --hours;

    
    if (hours < 10)
        hourLabel.text = [NSString stringWithFormat:@"0%d", hours];
    else
        hourLabel.text = [NSString stringWithFormat:@"%d", hours];
}

- (void) DecrDay
{
    if (days == 0)
    {
        // Stop timer as countdown has ended
        [timer invalidate];
        isTimerRunning = NO;
    }
    else
        --days;
    
    if (days < 10)
        dayLabel.text = [NSString stringWithFormat:@"0%d", days];
    else
        dayLabel.text = [NSString stringWithFormat:@"%d", days];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [dayLabel release];
    dayLabel = nil;
    [hourLabel release];
    hourLabel = nil;
    [minuteLabel release];
    minuteLabel = nil;
    [secondLabel release];
    secondLabel = nil;
    [flasher1 release];
    flasher1 = nil;
    [flasher2 release];
    flasher2 = nil;

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
    [timer invalidate];
    
    [dayLabel release];
    [hourLabel release];
    [minuteLabel release];
    [secondLabel release];
    
    [flasher1 release];
    [flasher2 release];
    
    [super dealloc];
}


@end
