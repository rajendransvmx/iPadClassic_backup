//
//  WeeklyViewEvent.m
//  MultipleDetailViews
//
//  Created by Samman Banerjee on 22/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WeeklyViewEvent.h"
#import "iServiceAppDelegate.h"
#import "iOSInterfaceObject.h"

#import <QuartzCore/QuartzCore.h>
extern void SVMXLog(NSString *format, ...);

@implementation WeeklyViewEvent

@synthesize edit_event;
@synthesize conflictFlag;

@synthesize delegate;
@synthesize didDismissAlertView,continue_reshceduling;
@synthesize time, imageView, label;
@synthesize selfFrame;
@synthesize dayFrame;
@synthesize local_id;

@synthesize eventDetail, eventId, workOrderDetail;

@synthesize processName, processId, recordId, objectName, createdDate, accountId, startDate, endDate, activityDate;

+ (void) addEventRect:(CGRect)rect
{
    if (weeklyEventPositionArray == nil)
        weeklyEventPositionArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    [weeklyEventPositionArray addObject:[NSValue valueWithCGRect:rect]];
}

+ (void) modifyEvent:(NSUInteger)tag WithRect:(CGRect)rect
{
    [weeklyEventPositionArray replaceObjectAtIndex:tag withObject:[NSValue valueWithCGRect:rect]];
}

+ (NSMutableArray *) getEventPositions
{
    return weeklyEventPositionArray;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [text setFont:[UIFont systemFontOfSize:12]];
    
    companyName.text = [workOrderDetail objectForKey:SVMXCACCOUNTNAME];
}

- (void) setEvent:(NSArray *)event Day:(NSUInteger)_day Time:(NSString *)_time Duration:(CGFloat)_duration Color:(UIColor *)color
{
    day = _day;
    time = [self getTimeMultipleFromStringTime:_time];
    duration = _duration;

    imageView.layer.cornerRadius = 5;
    imageView.alpha = 0.75;
    [self setColor:color];
    [self setPosition];
    [WeeklyViewEvent addEventRect:self.view.frame];
}

- (void) setColor:(UIColor *)color
{
    imageView.backgroundColor = color;
}

-(void) setLabelsweeklyview:(NSArray *)event
{
    SMLog(@"%@",event);
    SMLog(@"%@", workOrderName.text);
    subject.text = [event objectAtIndex:0];
    workOrderName.text = [event objectAtIndex:1];
    SMLog(@"%@",subject.text);
    
    
    
    if (self.conflictFlag)
    {
        if(selfFrame.size.height < 40)
        {
            UIImageView *imgView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"red.png"]];
            imgView.frame=CGRectMake(105,0,20, 10);
            [self.view addSubview:imgView];
            [imgView release];
        }
        else
        {
            UIImageView *imgView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"red.png"]];
            imgView.frame=CGRectMake(100,32,20, 18);
            [self.view addSubview:imgView];
            [imgView release];
        }
    }

}
- (CGFloat) getTimeMultipleFromStringTime:(NSString *)_time
{
    NSUInteger hourField;
    NSUInteger minuteField;
    // Retrieve hour and minute fields  
    if (_time != nil && _time != @"")
    {
        hourField = [[_time substringToIndex:2] intValue];
        minuteField = [[_time substringFromIndex:3] intValue];
    }
    
    return hourField * 2 + minuteField / 30;
}

- (void) setPosition
{
    // Landscape Mode
    CGFloat x = [self setXBasedOnDay:day];
    CGFloat y = [self setYBasedOnTime:time];

    //RADHA FIX 19/01/12
    CGFloat height= 0;
    if (duration != 0)
    {
        height = (duration * wEVENTHEIGHT) + ((duration - 1) * kwYGAP) - 10;
    }
    else
    {
        height = 0.0;
    }

    CGRect frame = CGRectMake(x, y, wEVENTWIDTH, height);
    
    self.view.frame = frame;
    selfFrame = frame;
    // label.frame = selfFrame;
    
    // Set the day frame in which it is originally located
    dayFrame = CGRectMake(kwXGAP, kwYGAP, wEVENTWIDTH, kwLOCATIONEND);
}

- (void) restorePositionToRect:(CGRect)rect
{
    [UIView beginAnimations:@"move" context:nil];
    [UIView setAnimationDuration:0.3];
    self.view.frame = rect;
    [UIView commitAnimations];
}

- (NSDictionary *) getEventStartEndTime
{
    int timeMultiple = 0;
    
    if (self.view.frame.origin.y != kwYGAP)
        timeMultiple = (self.view.frame.origin.y + 1 - kwYGAP) / (kwTIMEMULTIPLE + 1);
    else
        timeMultiple = 0;
    
    NSString * startTime;
    
    if ((timeMultiple % 2) == 0)
    {
        // Even means no half hour intervals
        int hourField = timeMultiple / 2;
        
        if (hourField < 10)
        {
            startTime = [NSString stringWithFormat:@"0%d:00:00", hourField];
        }
        else
        {
            startTime = [NSString stringWithFormat:@"%d:00:00", hourField];
        }
    }
    else
    {
        // Odd means half hour intervals
        
        int hourField = timeMultiple / 2;
        
        if (hourField < 10)
        {
            startTime = [NSString stringWithFormat:@"0%d:30:00", hourField];
        }
        else
        {
            startTime = [NSString stringWithFormat:@"%d:30:00", hourField];
        }
    }
    
    // End Time
    
    
    NSDateFormatter * format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"HH:mm:ss"];
    NSDate * date = [format dateFromString:startTime];
    
    NSTimeInterval timeZoneOffset = duration/2*60*60;
    NSTimeInterval newTimeInterval = [date timeIntervalSinceReferenceDate] + timeZoneOffset;
    
    NSDate * localDate = [NSDate dateWithTimeIntervalSinceReferenceDate:newTimeInterval];
    
    NSString * endTime = [format stringFromDate:localDate];
    
    // Day
    
    int eventDay = (self.view.frame.origin.x - kwXGAP) / (kwDAYMULTIPLE + kwXCORRECTION);
    
    // Analyser
    [format release];
    
    return [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:startTime, endTime, [NSNumber numberWithInt:eventDay], nil] forKeys:[NSArray arrayWithObjects:STARTTIME, ENDTIME, DAY, nil]];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        continue_reshceduling = FALSE;
        edit_event = FALSE;
    }
    else if(buttonIndex == 1)
    {
        continue_reshceduling = TRUE;
        [delegate setTouchesDisabled];
    }
    else if(buttonIndex == 2)
    {
        edit_event = TRUE;
        continue_reshceduling = FALSE;
    }
    didDismissAlertView = TRUE;
}

- (void) moveTo:(CGRect)location
{
    iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
   /* if(![appDelegate isInternetConnectionAvailable])
    {
        [UIView beginAnimations:@"move" context:nil];
        [UIView setAnimationDuration:0.3];
        self.view.frame = selfFrame;
        [UIView commitAnimations];
        [appDelegate displayNoInternetAvailable];
        return;
    }*/

    didDismissAlertView = FALSE;
    continue_reshceduling = FALSE;
    edit_event = FALSE;
    UIAlertView * alertView = nil;
    NSString * version = [appDelegate serverPackageVersion];
	int _stringNumber = [version intValue];
    if(_stringNumber >=  (KMinPkgForScheduleEvents * 100000))
    {
        alertView = [[UIAlertView alloc] initWithTitle:@"" 
                                                         message:[appDelegate.wsInterface.tagsDictionary objectForKey:EVENT_RESCHEDULE_PROMPT] 
                                                        delegate:self 
                                               cancelButtonTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:EVENT_RESCHEDULE_NO] 
                                               otherButtonTitles:[appDelegate.wsInterface.tagsDictionary objectForKey:EVENT_RESCHEDULE_YES],[appDelegate.wsInterface.tagsDictionary objectForKey:EDIT_EVENT], nil];
    }
    else
    {
        alertView = [[UIAlertView alloc] initWithTitle:@""
                                               message:[appDelegate.wsInterface.tagsDictionary objectForKey:EVENT_RESCHEDULE_PROMPT]
                                              delegate:self
                                     cancelButtonTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:EVENT_RESCHEDULE_NO]
                                     otherButtonTitles:[appDelegate.wsInterface.tagsDictionary objectForKey:EVENT_RESCHEDULE_YES], nil];
    }
    [alertView show];
    [alertView release];
    
    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, FALSE))
    { 
        SMLog(@"WeeklyViewEvent moveTo in while loop");
        if ( didDismissAlertView == TRUE )
        {
            didDismissAlertView = FALSE;
            break;
        }
    }

    if(continue_reshceduling)
    {
        [delegate rescheduleEvent:TRUE];
        [delegate EditEvent:FALSE];
    }
    else if(edit_event)
    {
        [UIView beginAnimations:@"move" context:nil];
        [UIView setAnimationDuration:0.3];
        self.view.frame = selfFrame;
        [UIView commitAnimations];
        [delegate rescheduleEvent:FALSE];
        [delegate EditEvent:TRUE];
        return;
    }
    else
    {
        // revert back to original selfRect
        [UIView beginAnimations:@"move" context:nil];
        [UIView setAnimationDuration:0.3];
        self.view.frame = selfFrame;
        [UIView commitAnimations];
        [delegate rescheduleEvent:FALSE];
        [delegate EditEvent:FALSE];
        return;
    }
    
    // Check if location intersects any event
    if ([self isEventInRect:location])
    {
        // Check which point in location intersects
        // if self.left.top intersects
        // if self.left.bottom intersects
        // revert back to original selfRect
        // else
        // find CGRect of self.left.bottom and add on height of self
        // if CGRect intersects with any event
        // revert back to original selfRect
        // else
        // set position
        // else if self.left.bottom intersects - top no longer intersects as top also intersecting is already handled above
        // find CGRect of self.left.top - kGAP - kTIMEMULTIPLE
        // if CGRect intersects with any event
        // revert back to original selfRect
        // else
        // set position
        NSArray * intersectionArray = [self getIntersectedEventsWithLocation:location];
        CGRect topIntersectionRect = [[intersectionArray objectAtIndex:0] CGRectValue];
        CGRect bottomIntersectionRect = [[intersectionArray objectAtIndex:1] CGRectValue];
        if (!CGRectEqualToRect(topIntersectionRect, CGRectZero))
        {
            if (!CGRectEqualToRect(bottomIntersectionRect, CGRectZero))
            {
                // revert back to original selfRect
                [UIView beginAnimations:@"move" context:nil];
                [UIView setAnimationDuration:0.3];
                self.view.frame = selfFrame;
                [UIView commitAnimations];
                
                return;
            }
            else 
            {
                CGRect rectToBeIn = [self bringEventDownFromLocation:location];
                
                CGPoint bottomLeft = CGPointMake(location.origin.x, (location.origin.y + location.size.height) - kwYCORRECTION);
                CGRect rectToBe = [self getRectForLocation:bottomLeft];

                rectToBe.size.height = self.view.frame.size.height;

                if (CGRectEqualToRect(rectToBeIn, CGRectZero) || (rectToBeIn.origin.y > kwTIMEFLOOR))
                {
                    // revert back to original selfRect
                    [UIView beginAnimations:@"move" context:nil];
                    [UIView setAnimationDuration:0.3];
                    self.view.frame = selfFrame;
                    [UIView commitAnimations];
                    
                    return;
                }
                else
                {
                    // Check if rectToBe for bottom is within kwTIMEFLOOR
                    if ((rectToBeIn.origin.y + self.view.frame.size.height) > kwTIMEFLOOR+kwYCORRECTION)
                    {
                        // revert back to original selfRect
                        [UIView beginAnimations:@"move" context:nil];
                        [UIView setAnimationDuration:0.3];
                        self.view.frame = selfFrame;
                        [UIView commitAnimations];
                        
                        return;
                    }
                    else
                    {
                        {
                            selfFrame = rectToBeIn;
                            [UIView beginAnimations:@"move" context:nil];
                            [UIView setAnimationDuration:0.3];
                            self.view.frame = selfFrame;
                            [UIView commitAnimations];
                        }
                    }
                }
            }
        }
        else if (!CGRectEqualToRect(bottomIntersectionRect, CGRectZero))
        {
            CGRect rectToBeIn = [self bringEventUpFromLocation:location];
            
            CGPoint topLeft = CGPointMake(location.origin.x, (location.origin.y - kwYGAP - kwTIMEMULTIPLE) + kwYCORRECTION);
            CGRect rectToBe = [self getRectForLocation:topLeft];

            rectToBe.size.height = self.view.frame.size.height;

            if (CGRectEqualToRect(rectToBeIn, CGRectZero) || (rectToBeIn.origin.y < kwLOCATIONYZERO))
            {
                // revert back to original selfRect
                [UIView beginAnimations:@"move" context:nil];
                [UIView setAnimationDuration:0.3];
                self.view.frame = selfFrame;
                [UIView commitAnimations];
                
                return;
            }
            else
            {
                selfFrame = rectToBeIn;
                [UIView beginAnimations:@"move" context:nil];
                [UIView setAnimationDuration:0.3];
                self.view.frame = selfFrame;
                [UIView commitAnimations];
            }
        }
    }
    else
    {
        UIView * superView = [self.view superview];
        // Check for bottom out of frame condition
        if ((self.view.frame.origin.y + self.view.frame.size.height) > superView.frame.size.height)
        {
            CGPoint topLeft = CGPointMake(location.origin.x, (location.origin.y - kwYGAP - kwTIMEMULTIPLE) + kwYCORRECTION);
            CGRect rectToBe = [self getRectForLocation:topLeft];

            rectToBe.size.height = self.view.frame.size.height;
            if ([self isEventInRect:rectToBe])
            {
                // revert back to original selfRect
                [UIView beginAnimations:@"move" context:nil];
                [UIView setAnimationDuration:0.3];
                self.view.frame = selfFrame;
                [UIView commitAnimations];
                
                return;
            }
            else
            {
                // Check if rectToBe for bottom is within top of weekview frame
                if ((rectToBe.origin.y + rectToBe.size.height) > superView.frame.size.height)
                {
                    // revert back to original selfRect
                    [UIView beginAnimations:@"move" context:nil];
                    [UIView setAnimationDuration:0.3];
                    self.view.frame = selfFrame;
                    [UIView commitAnimations];
                    
                    return;
                }
                else
                {
                    // set position at rectToBe with corrected size
                    selfFrame = CGRectMake(rectToBe.origin.x, rectToBe.origin.y, self.view.frame.size.width, self.view.frame.size.height);
                    [UIView beginAnimations:@"move" context:nil];
                    [UIView setAnimationDuration:0.3];
                    self.view.frame = selfFrame;
                    [UIView commitAnimations];
                }
            }
        }
    }
    selfFrame = self.view.frame;
    [WeeklyViewEvent modifyEvent:self.view.tag WithRect:selfFrame];
    
    [delegate movedEvent:self];
}

- (CGRect) bringEventDownFromLocation:(CGRect)location
{
    // run a while loop and bring location down by half hour slots
    // if left.top intersects
    // if bottom intersects
    // return CGRectZero - this means that event cannot be shifted, and has to revert back to original position
    // else
    // continue loop
    // else
    // if bottom intersects
    // return CGRectZero
    // else
    // return obtained CGRect
    // SMLog(@"%f", self.view.frame.size.height);
    CGRect bottomLocation = CGRectMake(location.origin.x, location.origin.y + self.view.frame.size.height, location.size.width, location.size.height);
    int iteration = 0;
    while (1)
    {
        location.origin = CGPointMake(location.origin.x, location.origin.y + wEVENTHEIGHT + kwYGAP);
        bottomLocation.origin = CGPointMake(bottomLocation.origin.x, bottomLocation.origin.y + wEVENTHEIGHT + kwYGAP);
        if ([self isEventInRect:location])
        {
            // if ([self isEventInRect:bottomLocation])
            CGRect bottomIntersection = [self getIntersectedEventWithLocation:bottomLocation.origin];
            if (!CGRectEqualToRect(bottomIntersection, CGRectZero))
                return CGRectZero;
            else
                if (iteration > 0)
                    return CGRectZero;

        }
        else
        {
            CGRect bottomIntersection = [self getIntersectedEventWithLocation:bottomLocation.origin];
            if (!CGRectEqualToRect(bottomIntersection, CGRectZero))
                return CGRectZero;
            else
                return location;
        }
        iteration++;
    }
}

- (CGRect) bringEventUpFromLocation:(CGRect)location
{
    // run a while loop and bring location up by half hour slots
    // if location top intersects any event 
    // if bottom point intersects
    // return CGRectZero - this means that event cannot be shifted, and has to revert back to original position
    // else
    // continue loop
    // else
    // if top intersects
    // return CGRectZero
    // else
    // return obtained CGRect
    // SMLog(@"%f", self.view.frame.size.height);
    CGRect bottomLocation = CGRectMake(location.origin.x, location.origin.y + self.view.frame.size.height, location.size.width, location.size.height);
    int iteration = 0;
    while (1)
    {
        location.origin = CGPointMake(location.origin.x, location.origin.y - wEVENTHEIGHT - kwYGAP);
        bottomLocation.origin = CGPointMake(bottomLocation.origin.x, bottomLocation.origin.y - wEVENTHEIGHT - kwYGAP);
        
        CGRect topIntersection = [self getIntersectedEventWithLocation:location.origin];
        if (!CGRectEqualToRect(topIntersection, CGRectZero))
        {
            CGRect bottomIntersection = [self getIntersectedEventWithLocation:bottomLocation.origin];
            if (!CGRectEqualToRect(bottomIntersection, CGRectZero))
                return CGRectZero;
            else
                if (iteration > 0)
                    return CGRectZero;
        }
        else
        {
            CGRect bottomIntersection = [self getIntersectedEventWithLocation:bottomLocation.origin];
            if (CGRectEqualToRect(bottomIntersection, CGRectZero))
                return location;
        }
        iteration++;
    }
}

- (NSArray *) getIntersectedEventsWithLocation:(CGRect)location
{
    // Check for top left corner point
    CGRect topIntersectionRect = [self getIntersectedEventWithLocation:location.origin];
    // Check for bottom left corner point
    CGRect bottomIntersectionRect = [self getIntersectedEventWithLocation:CGPointMake(location.origin.x, (location.origin.y + location.size.height)-1)];
    NSArray * ret = [[[NSArray alloc] initWithObjects:[NSValue valueWithCGRect:topIntersectionRect], [NSValue valueWithCGRect:bottomIntersectionRect], nil] autorelease];
    return ret;
}

- (CGRect) getIntersectedEventWithLocation:(CGPoint)point
{
    CGRect rect = CGRectZero;
   @try
    { 
    // Calculate all rects which are used up
    NSMutableArray * eventPositions = [WeeklyViewEvent getEventPositions];
    
    NSUInteger selfTag = self.view.tag;
    
    for (int i = 0; i < [eventPositions count]; i++)
    {
        if (i == selfTag)
            continue;
        
        rect = [[eventPositions objectAtIndex:i] CGRectValue];
        if (CGRectContainsPoint(rect, point))
            break;
        else
            rect = CGRectZero;
    }
}@catch (NSException *exp) {
        SMLog(@"Exception Name WeeklyViewEvent :getIntersectedEventWithLocation %@",exp.name);
        SMLog(@"Exception Reason WeeklyViewEvent :getIntersectedEventWithLocation %@",exp.reason);

    }
    
    return rect;
}

- (NSUInteger)getGapMultipleFromTime:(NSUInteger)_time
{
    NSUInteger retVal = 0;
    switch (_time)
    {
        case 930:
            retVal = 0;
            break;
        case 1000:
            retVal = 1;
            break;
        case 1030:
            retVal = 2;
            break;
        case 1100:
            retVal = 3;
            break;
        case 1130:
            retVal = 4;
            break;
        case 1200:
            retVal = 5;
            break;
        case 1230:
            retVal = 6;
            break;
        case 1300:
            retVal = 7;
            break;
        case 1330:
            retVal = 8;
            break;
        case 1400:
            retVal = 9;
            break;
        case 1430:
            retVal = 10;
            break;
        case 1500:
            retVal = 11;
            break;
        case 1530:
            retVal = 12;
            break;
        case 1600:
            retVal = 13;
            break;
        case 1630:
            retVal = 14;
            break;
        case 1700:
            retVal = 15;
            break;
        case 1730:
            retVal = 16;
            break;
        case 1800:
            retVal = 17;
            break;
        case 1830:
            retVal = 18;
            break;
        case 1900:
            retVal = 19;
            break;
    }
    return retVal;
}

- (CGRect) getRectForLocation:(CGPoint)point
{
    CGRect rect = CGRectZero;
    BOOL foundRect = NO;
    
    NSUInteger y = 0, x = 0;
    
    for (int i = 0; i < kwTOTALTIMEINTERVALS; i++)
    {
        for (int j = 0; j < kwTOTALDAYINTERVALS; j++)
        {
            if (i == 0)
                y = kwYGAP;
            else
                y = ((i * kwTIMEMULTIPLE) + kwYGAP + (i - 1));
            
            x = (j * (kwDAYMULTIPLE + kwXCORRECTION)) + kwXGAP;
            rect = CGRectMake(x, y, wEVENTWIDTH, wEVENTHEIGHT);
            
            if (CGRectContainsPoint(rect, point))
            {
                foundRect = YES;
                break;
            }
            else
                rect = CGRectZero;
        }
        if (foundRect)
            break;
    }
    
    // SMLog(@"Rect = %d, %d, %d, %d", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    // SMLog(@"(X, Y) = %d, %d", x, y);
    
    return rect;
}

- (BOOL) isEventInRect:(CGRect)_rect
{
    BOOL flag = NO;
    @try
    {
    // Calculate all rects which are used up
    NSMutableArray * eventPositions = [WeeklyViewEvent getEventPositions];
    
    NSUInteger selfTag = self.view.tag;
    
    for (int i = 0; i < [eventPositions count]; i++)
    {
        if (i == selfTag)
            continue;
        
        CGRect rect = [[eventPositions objectAtIndex:i] CGRectValue];
        if (CGRectIntersectsRect(rect, _rect))
        {
            flag = YES;
            break;
        }
    }
}@catch (NSException *exp) {
        SMLog(@"Exception Name WeeklyViewEvent :isEventInRect %@",exp.name);
        SMLog(@"Exception Reason WeeklyViewEvent :isEventInRect %@",exp.reason);

    }
    
    return flag;
}

- (BOOL) canMoveToLocation
{
    BOOL flag = YES;
    @try
    {
    // Calculate all rects which are used up
    NSMutableArray * eventPositions = [WeeklyViewEvent getEventPositions];
    
    NSUInteger selfTag = self.view.tag;
    
    for (int i = 0; i < [eventPositions count]; i++)
    {
        if (i == selfTag)
            continue;
        CGRect rect = [[eventPositions objectAtIndex:i] CGRectValue];
        CGRect selfRect = self.view.frame;
        if (CGRectIntersectsRect(rect, selfRect))
        {
            flag = NO;
            break;
        }
    }
 }@catch (NSException *exp) {
        SMLog(@"Exception Name WeeklyViewEvent :canMoveToLocation %@",exp.name);
        SMLog(@"Exception Reason WeeklyViewEvent :canMoveToLocation %@",exp.reason);

    }   
    // SMLog(@"Can Move = %@", flag?@"YES":@"NO");
    return flag;
}

- (void) setPositionAtY:(CGFloat)y
{
    CGRect frame = CGRectMake(self.view.frame.origin.x, y, self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView beginAnimations:@"AnimateMove" context:nil];
    [UIView setAnimationDuration:0.3];
    self.view.frame = frame;
    selfFrame = frame;
    [UIView commitAnimations];
}

- (NSUInteger) getYFromIndex:(int)position
{
    return (position * kwTIMEMULTIPLE) + kwYGAP;
}

- (CGFloat) setXBasedOnDay:(NSUInteger)_day
{
    return (_day * (kwDAYMULTIPLE + kwXCORRECTION)) + kwXGAP;
}

- (CGFloat) setYBasedOnTime:(NSUInteger)_time
{
    if (_time == 0)
        return kwYGAP;
    else
    {
        return ((_time * kwTIMEMULTIPLE) + kwYGAP + (_time - 1));
    }
}

- (UIImage *) getImageForColorIndex:(NSUInteger)colorIndex
{
    switch (colorIndex) {
        case cBLUE:
            // return [UIImage imageNamed:@"blue-event-highlighter.png"];
            return [UIImage imageNamed:@"event-blue.png"];
        case cBROWN:
            // return [UIImage imageNamed:@"brown-event-highlighter.png"];
            return [UIImage imageNamed:@"event-brown.png"];
        case cGREEN:
            // return [UIImage imageNamed:@"green-event-highlighter.png"];
            return [UIImage imageNamed:@"event-green.png"];
        case cORANGE:
            // return [UIImage imageNamed:@"orange-event-highlighter.png"];
            return [UIImage imageNamed:@"event-orange.png"];
        case cPINK:
            // return [UIImage imageNamed:@"pink-event-highlighter.png"];
            return [UIImage imageNamed:@"event-violet.png"];
        case cPURPLE:
            // return [UIImage imageNamed:@"purple-event-highlighter.png"];
            return [UIImage imageNamed:@"event-violet.png"];
        case cRED:
            // return [UIImage imageNamed:@"red-event-highlighter.png"];
            return [UIImage imageNamed:@"event-red.png"];
        case cYELLOW:
            // return [UIImage imageNamed:@""];
            return [UIImage imageNamed:@"event-lightbrown.png"];
        default:
            break;
    }
    return nil;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [imageView release];
    imageView = nil;
    [label release];
    label = nil;
    [text release];
    text = nil;
    [workOrderNumber release];
    workOrderNumber = nil;
    [workOrderType release];
    workOrderType = nil;
    [companyName release];
    companyName = nil;
    [workOrderName release];
    workOrderName = nil;
    [subject release];
    subject = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [subject release];
    [super dealloc];
}


@end
