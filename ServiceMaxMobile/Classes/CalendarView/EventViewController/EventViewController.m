//
//  EventViewController.m
//  MultipleDetailViews
//
//  Created by Samman Banerjee on 22/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EventViewController.h"
#import "AppDelegate.h"
#import "iOSInterfaceObject.h"

#import <QuartzCore/QuartzCore.h>
//extern void NSLog(NSString *format, ...);


@implementation EventViewController

@synthesize local_id;
@synthesize conflictFlag;

@synthesize delegate;

@synthesize time, imageView, label;
@synthesize selfFrame;

@synthesize eventDetail, eventId, workOrderDetail;

@synthesize companyName;
@synthesize subject;

//sahana 12th september
@synthesize Continue_rescheduling,didDismissalertview;
//sahana 13th Dec
@synthesize edit_event;

@synthesize processName, processId, recordId, objectName, activityDate, accountId, startDate, endDate;

//Radha 4th April 2011
- (void) setLabelWorkorder:(NSString *)name Subject:(NSString *)_name
{
    NSLog(@"%@ %@", name, _name);
    label.text = name;
//    if (self.view.frame.size.height < 42)
//        subject1.text = _name;
//    else
        subject.text = _name;
    
    if (self.conflictFlag)
    {
                
//        if(selfFrame.size.height > 40)
//        {
//           UIImageView *imgView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"red.png"]];
//            imgView.frame=CGRectMake(340,10, 30, 30);
//            [self.view addSubview:imgView];
//        }
//        else
        {
            UIImageView *imgView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"red.png"]];
            imgView.frame=CGRectMake(370, 0, 20, 18);
            [self.view addSubview:imgView];
            [imgView release];
        }
    }

    
    NSLog(@"%@ %@", label.text, subject.text);
}

+ (void) addEventRect:(CGRect)rect
{
    if (eventPositionArray == nil)
        eventPositionArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    [eventPositionArray addObject:[NSValue valueWithCGRect:rect]];
}

+ (void) modifyEvent:(NSUInteger)tag WithRect:(CGRect)rect
{
    [eventPositionArray replaceObjectAtIndex:tag withObject:[NSValue valueWithCGRect:rect]];
}

+ (NSMutableArray *) getEventPositions
{
    return eventPositionArray;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    companyName.text = [workOrderDetail objectForKey:SVMXCACCOUNTNAME];
}

- (void) setEvent:(NSString *)event Time:(NSString *)_time Duration:(CGFloat)_duration Color:(UIColor *)color
{
    time = [self getTimeMultipleFromStringTime:_time];
    duration = _duration;
    label.text = event;
    NSLog(@"label = %@  duration = %f, time = %f", label.text, duration, time );
    
    imageView.layer.cornerRadius = 10;
    imageView.alpha = 0.75;
    [self setEventColor:color];
    [self setPosition];
    [EventViewController addEventRect:self.view.frame];
}

- (void) setEventColor:(UIColor *)Color
{
    imageView.backgroundColor = Color;
}
 
- (CGFloat) getTimeMultipleFromStringTime:(NSString *)_time
{
    // Retrieve hour and minute fields
    NSUInteger hourField = [[_time substringToIndex:2] intValue];
    NSUInteger minuteField = [[_time substringFromIndex:3] intValue];
    
    return hourField * 2 + minuteField / 30;
}

- (void) setPosition
{
    // Landscape Mode
    // Width = 393
    // X = 77
    // Height = duration * 27 + duration * kGAP
    CGFloat y = [self setYBasedOnTime:time];
    // NSLog(@"Y Coord = %f", y);
    CGFloat durationFactor = (duration<1.0)?1.0:(duration/0.5);
    CGFloat height = (duration * kTIMEMULTIPLE * 2) + ((durationFactor - 1) * kGAP);
    // NSLog(@"Height = %f", height);
    CGRect frame = CGRectMake(EVENTX, y, EVENTWIDTH, height);
    
    self.view.frame = frame;
    selfFrame = frame;
}

- (NSDictionary *) getEventStartEndTime
{
    int timeMultiple = (self.view.frame.origin.y - kLOCATIONZERO)/(kTIMEMULTIPLE + kGAP);
    
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
    
    NSTimeInterval timeZoneOffset = duration*60*60;
    NSTimeInterval newTimeInterval = [date timeIntervalSinceReferenceDate] + timeZoneOffset;
    
    NSDate * localDate = [NSDate dateWithTimeIntervalSinceReferenceDate:newTimeInterval];
    
    NSString * endTime = [format stringFromDate:localDate];
    
    // Analyser
    [format release];

    return [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:startTime, endTime, nil] forKeys:[NSArray arrayWithObjects:STARTTIME, ENDTIME, nil]];
}
//sahana 12th sept 2011
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if(buttonIndex == 0) //cancel
    {
        Continue_rescheduling = FALSE;
        edit_event = FALSE;
    }
    else if(buttonIndex == 1) //reschedule Event
    {
        Continue_rescheduling = TRUE;
        edit_event = FALSE;
    }
    else if(buttonIndex == 2) //Edit Event
    {
        Continue_rescheduling = FALSE;
        edit_event = TRUE;
    }
    
}
- (void)alertViewCancel:(UIAlertView *)alertView;
{
    Continue_rescheduling = FALSE;
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;
{
    didDismissalertview = TRUE;
}

- (void) restorePositionToRect:(CGRect)rect
{
    [UIView beginAnimations:@"move" context:nil];
    [UIView setAnimationDuration:0.3];
    self.view.frame = rect;
    [UIView commitAnimations];
}

- (void) moveTo:(CGRect)location
{
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
   /* if (![appDelegate isInternetConnectionAvailable])
    {
        [self restorePositionToRect:selfFrame];
        [appDelegate displayNoInternetAvailable];
        
        return;
    }*/
    
    didDismissalertview = FALSE;
    Continue_rescheduling = FALSE;
    edit_event = FALSE;
    
    NSString * version = [appDelegate serverPackageVersion];
	int _stringNumber = [version intValue];
    UIAlertView * alertView = nil;
    
    if(_stringNumber >=  (KMinPkgForScheduleEvents * 100000))
    {
        alertView  = [[UIAlertView alloc] initWithTitle:@"" 
                                        message:[appDelegate.wsInterface.tagsDictionary objectForKey:EVENT_RESCHEDULE_PROMPT]
                                                            delegate:self 
                                                   cancelButtonTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:EVENT_RESCHEDULE_NO] 
                                                   otherButtonTitles:[appDelegate.wsInterface.tagsDictionary objectForKey:EVENT_RESCHEDULE_YES],[appDelegate.wsInterface.tagsDictionary objectForKey:EDIT_EVENT], nil];
       
    }
    else
    { 
        alertView  = [[UIAlertView alloc] initWithTitle:@""
                                                message:[appDelegate.wsInterface.tagsDictionary objectForKey:EVENT_RESCHEDULE_PROMPT]
                                               delegate:self
                                      cancelButtonTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:EVENT_RESCHEDULE_NO]
                                      otherButtonTitles:[appDelegate.wsInterface.tagsDictionary objectForKey:EVENT_RESCHEDULE_YES], nil];
    }
    [alertView show];
    [alertView release];
    
    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, FALSE))
    {
        NSLog(@"EventViewController moveTo in while loop");
        if (didDismissalertview == TRUE)
        {
            didDismissalertview = FALSE;
            break;
        }
    }
    
    if(Continue_rescheduling)
    {
        [delegate Continuetherescheduling:TRUE];
        [delegate EditEvent:FALSE];
    }
    else if(edit_event)
    {
        [UIView beginAnimations:@"move" context:nil];
        [UIView setAnimationDuration:0.3];
        self.view.frame = selfFrame;
        [UIView commitAnimations];
        [delegate EditEvent:TRUE];
        [delegate Continuetherescheduling:FALSE];
        return;
    }
    else 
    {
        // revert back to original selfRect
        [UIView beginAnimations:@"move" context:nil];
        [UIView setAnimationDuration:0.3];
        self.view.frame = selfFrame;
        [UIView commitAnimations];
        [delegate Continuetherescheduling:FALSE];
        [delegate EditEvent:FALSE];
        return;
    }
 
    
    // Check if location intersects any event
    //6482: Comment to fix the issue
    /*if ([self isEventInRect:location])
    {
        // Check which point in location intersects
        // if self.left.top intersects
            // if self.left.bottom intersects
                // revert back to original selfRect
            // else -> Bring down self.left.top by half hour slots and check if top and bottom intersects
                // find CGRect of self.left.bottom and add height of self
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
                CGPoint bottomLeft = CGPointMake(location.origin.x, (location.origin.y + location.size.height));
                CGRect rectToBe = [self getRectForLocation:bottomLeft];
                rectToBe.size.height = self.view.frame.size.height;

                if (CGRectEqualToRect(rectToBeIn, CGRectZero) || ((rectToBeIn.origin.y + rectToBeIn.size.height) > kTIMEFLOOR))
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
                    // set position
                    selfFrame = rectToBeIn;
                    [UIView beginAnimations:@"move" context:nil];
                    [UIView setAnimationDuration:0.3];
                    self.view.frame = selfFrame;
                    [UIView commitAnimations];
                }
            }
        }
        else if (!CGRectEqualToRect(bottomIntersectionRect, CGRectZero))
        {
            CGRect rectToBeIn = [self bringEventUpFromLocation:location];
                                 
            CGPoint topLeft = CGPointMake(location.origin.x, (location.origin.y - kGAP - kTIMEMULTIPLE));
            CGRect rectToBe = [self getRectForLocation:topLeft];
            rectToBe.size.height = self.view.frame.size.height;
            
            // if ([self isEventInRect:rectToBe])
            if (CGRectEqualToRect(rectToBeIn, CGRectZero) || (rectToBeIn.origin.y < kLOCATIONZERO))
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
                selfFrame = rectToBeIn;
                [UIView beginAnimations:@"move" context:nil];
                [UIView setAnimationDuration:0.3];
                self.view.frame = selfFrame;
                [UIView commitAnimations];
            }
        }
    }*/
    selfFrame = self.view.frame;
    [EventViewController modifyEvent:self.view.tag WithRect:selfFrame];
    
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
    CGRect bottomLocation = CGRectMake(location.origin.x, location.origin.y + self.view.frame.size.height, location.size.width, location.size.height);
    while (1)
    {
        location.origin = CGPointMake(location.origin.x, location.origin.y + kTIMEMULTIPLE + kGAP);
        bottomLocation.origin = CGPointMake(bottomLocation.origin.x, bottomLocation.origin.y + kTIMEMULTIPLE + kGAP);
        if ([self isEventInRect:location])
        {
            if ([self isEventInRect:bottomLocation])
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
    CGRect bottomLocation = CGRectMake(location.origin.x, location.origin.y + self.view.frame.size.height, location.size.width, location.size.height);
    while (1)
    {
        location.origin = CGPointMake(location.origin.x, location.origin.y - kTIMEMULTIPLE - kGAP);
        bottomLocation.origin = CGPointMake(bottomLocation.origin.x, bottomLocation.origin.y - kTIMEMULTIPLE - kGAP);
        
        CGRect topIntersection = [self getIntersectedEventWithLocation:location.origin];
        if (!CGRectEqualToRect(topIntersection, CGRectZero))
        {
            CGRect bottomIntersection = [self getIntersectedEventWithLocation:bottomLocation.origin];
            if (!CGRectEqualToRect(bottomIntersection, CGRectZero))
                return CGRectZero;
        }
        else
        {
            CGRect bottomIntersection = [self getIntersectedEventWithLocation:bottomLocation.origin];
            if (CGRectEqualToRect(bottomIntersection, CGRectZero))
                return location;
        }
        
    }
}

- (NSArray *) getIntersectedEventsWithLocation:(CGRect)location
{
    // Check for top left corner point
    CGRect topIntersectionRect = [self getIntersectedEventWithLocation:location.origin];
    // Check for bottom left corner point
    CGRect bottomIntersectionRect = [self getIntersectedEventWithLocation:CGPointMake(location.origin.x, (location.origin.y + location.size.height - kGAP))];
    NSArray * ret = [[[NSArray alloc] initWithObjects:[NSValue valueWithCGRect:topIntersectionRect], [NSValue valueWithCGRect:bottomIntersectionRect], nil] autorelease];
    return ret;
}

- (CGRect) getIntersectedEventWithLocation:(CGPoint)point
{
    CGRect rect = CGRectZero;
    
    // Calculate all rects which are used up
    NSMutableArray * eventPositions = [EventViewController getEventPositions];
    
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
    
    return rect;
}

- (BOOL) isEventInRect:(CGRect)_rect
{
    BOOL flag = NO;
    
    // Calculate all rects which are used up
    NSMutableArray * eventPositions = [EventViewController getEventPositions];
    
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
    
    return flag;
}

- (CGRect) getRectForLocation:(CGPoint)point
{
    CGRect rect = CGRectZero;
    
    for (int i = 0; i < kTOTALRECTS; i++)
    {
        NSUInteger y = kLOCATIONZERO + (i * kTIMEMULTIPLE) + (i * kGAP);
        rect = CGRectMake(EVENTX, y, EVENTWIDTH, EVENTHEIGHT);
        
        if (CGRectContainsPoint(rect, point) || (point.y == rect.origin.y) || (point.y == (rect.origin.y + rect.size.height)))
            break;
        else
            rect = CGRectZero;
    }
    
    return rect;
}

- (BOOL) canMoveToLocation
{
    BOOL flag = YES;
    
    // Calculate all rects which are used up
    NSMutableArray * eventPositions = [EventViewController getEventPositions];

    NSUInteger selfTag = self.view.tag;
    CGRect selfRect = self.view.frame;
    
    for (int i = 0; i < [eventPositions count]; i++)
    {
        if (i == selfTag)
            continue;
        CGRect rect = [[eventPositions objectAtIndex:i] CGRectValue];
        if (CGRectIntersectsRect(rect, selfRect))
        {
            flag = NO;
            break;
        }
    }
    return flag;
}

- (void) setPositionAtY:(CGFloat)y
{
    CGRect frame = CGRectMake(EVENTX, y, EVENTWIDTH, self.view.frame.size.height);
    
    [UIView beginAnimations:@"AnimateMove" context:nil];
    [UIView setAnimationDuration:0.3];
    self.view.frame = frame;
    selfFrame = frame;
    [UIView commitAnimations];
}

- (NSUInteger) getYFromIndex:(int)position
{
    return ((position * kTIMEMULTIPLE) + kLOCATIONZERO + ((position-1) * kGAP));
}

- (CGFloat) setYBasedOnTime:(NSUInteger)_time
{
    return (_time * kTIMEMULTIPLE) + kLOCATIONZERO + (_time * kGAP);
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

//  Unused methods
//- (CGFloat) getPortraitHeight
//{
//    return duration * EVENTPORTRAITHEIGHT * 2 + (duration - 1) * kGAP;
//}

//  Unused methods
//- (CGFloat) getPortraitWidth
//{
//    return EVENTPORTRAITWIDTH;
//}

- (CGFloat) getLandscapeHeight
{
    return duration * EVENTHEIGHT * 2 + duration * kGAP;
}

- (CGFloat) getLandscapeWidth
{
    return EVENTWIDTH;
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
    [companyName release];
    companyName = nil;
    [subject release];
    subject = nil;
    [subject1 release];
    subject1 = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
    [subject release];
    [subject1 release];
    [super dealloc];
}


@end
