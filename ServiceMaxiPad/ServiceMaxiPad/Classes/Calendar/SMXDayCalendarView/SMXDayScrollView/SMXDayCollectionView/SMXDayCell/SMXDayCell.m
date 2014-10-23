//
//  SMXDayCell.m
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


#import "SMXDayCell.h"

#import "SMXHourAndMinLabel.h"
#import "SMXBlueButton.h"
#import "SMXImportantFilesForCalendar.h"
#import "CalenderHelper.h"

#define FONT_NAME @"HelveticaNeue-Medium"

#define DAYVIEW_MINUTES_INTERVAL 2.
#define DAYVIEW_HEIGHT_CELL_HOUR 70.
#define DAYVIEW_HEIGHT_CELL_MIN DAYVIEW_HEIGHT_CELL_HOUR/DAYVIEW_MINUTES_INTERVAL
#define DAYVIEW_MINUTES_PER_LABEL 60./DAYVIEW_MINUTES_INTERVAL

#define EVENT_X_POSITION 70.


@interface SMXDayCell ()
@property (nonatomic, strong) NSMutableArray *arrayLabelsHourAndMin;
@property (nonatomic, strong) NSMutableArray *arrayButtonsEvents;
@property (nonatomic, strong) SMXBlueButton *button;
@property (nonatomic, strong) SMXBlueButton *cSelectedEventButton;

@property (nonatomic) CGFloat yCurrent;
@property (nonatomic, strong) UILabel *labelWithSameYOfCurrentHour;
@property (nonatomic, strong) UILabel *labelRed;

@property (nonatomic, assign) CGRect cOriginalFrame;
@property (nonatomic, assign) CGFloat cDifferenceInY;

@property (nonatomic, strong) NSMutableArray *cSamePositionAndDurationEvents;
@property (nonatomic, strong) NSMutableArray *cEventInsideALargerEvent;

@property (nonatomic, strong) NSMutableDictionary *cEventsWhichAccomodateSmallerEvents;

@end

@implementation SMXDayCell

@synthesize protocol;
@synthesize date;
@synthesize arrayLabelsHourAndMin;
@synthesize arrayButtonsEvents;
@synthesize button;
@synthesize yCurrent;
@synthesize labelWithSameYOfCurrentHour;
@synthesize labelRed;
@synthesize cSelectedEventButton;
@synthesize cOriginalFrame;
@synthesize cDifferenceInY;
@synthesize cSamePositionAndDurationEvents;
@synthesize cEventInsideALargerEvent;
@synthesize cEventsWhichAccomodateSmallerEvents;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dayEventSelected:) name:EVENT_CLICKED object:nil];

        [self setBackgroundColor:[UIColor whiteColor]];
        
        arrayLabelsHourAndMin = [NSMutableArray new];
        arrayButtonsEvents = [NSMutableArray new];
        
        [self addLines];


    }
    return self;
}

- (void)showEvents:(NSArray *)array {
    
    [self addButtonsWithArray:array];
}

- (void)addLines {
    
    CGFloat y = 0;
    
    NSDateComponents *compNow = [NSDate componentsOfCurrentDate];
    
    for (int hour=0; hour<=23; hour++) {
        
        for (int min=0; min<=30; min=min+DAYVIEW_MINUTES_PER_LABEL) {
            
            SMXHourAndMinLabel *labelHourMin = [[SMXHourAndMinLabel alloc] initWithFrame:CGRectMake(0, y, self.frame.size.width, DAYVIEW_HEIGHT_CELL_MIN) date:[NSDate dateWithHour:hour min:min]];
            
            [labelHourMin setTextColor:[UIColor colorWithRed:67.0/255.0 green:67.0/255.0 blue:67.0/255.0 alpha:1.0]];
            labelHourMin.font = [UIFont fontWithName:FONT_NAME size:14];
            labelHourMin.topInset = 15.0;
            labelHourMin.leftInset = 5.0;
            
            labelHourMin.backgroundColor = [UIColor clearColor]; //testing
            
            
            float line_X_Position = 0.0;
            if (min == 0)
            {
                [labelHourMin showText];
            }
            else
            {
                line_X_Position = 35;

            }
        
            
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(line_X_Position, DAYVIEW_HEIGHT_CELL_MIN/2., self.frame.size.width, 1.)];

            
            [view setAutoresizingMask:AR_WIDTH_HEIGHT];
            [view setBackgroundColor:[UIColor lightGrayCustom]];
            [labelHourMin addSubview:view];
            
            
            
            
            [self addSubview:labelHourMin];
            [arrayLabelsHourAndMin addObject:labelHourMin];
            
            NSDateComponents *compLabel = [NSDate componentsWithHour:hour min:min];
            if (compLabel.hour == compNow.hour && min <= compNow.minute && compNow.minute < min+DAYVIEW_MINUTES_PER_LABEL)
            
            {
                
                labelRed = [self labelWithCurrentHourWithWidth:labelHourMin.frame.size.width yCurrent:labelHourMin.frame.origin.y + (compNow.minute - min )* DAYVIEW_HEIGHT_CELL_MIN/30];
                labelRed.layer.zPosition = 1.0;
                [self addSubview:labelRed];
                [labelRed setAlpha:0];
                labelWithSameYOfCurrentHour = labelHourMin;
            }
            
            
            y += DAYVIEW_HEIGHT_CELL_MIN;
        }
    }
}

- (UILabel *)labelWithCurrentHourWithWidth:(CGFloat)_width yCurrent:(CGFloat)_yCurrent {
    
    SMXHourAndMinLabel *label = [[SMXHourAndMinLabel alloc] initWithFrame:CGRectMake(.0, _yCurrent, _width, DAYVIEW_HEIGHT_CELL_MIN) date:[NSDate date]];
//    [label showText];
    
    UIColor *customColor = [UIColor colorWithRed:225.0/255.0 green:80.0/255.0 blue:1.0/255.0 alpha:1.0];
    
    NSDateComponents *comp =  [NSDate componentsOfDate:[NSDate date]];
    
    int lHour = comp.hour;
    NSString *lAmPm = @"AM";
    
    
    if (lHour>=12) {
        lAmPm = @"PM";
    }
    
    lHour = (lHour>12? lHour - 12 : lHour); //converting to 0-12 hrs standard
    
    
    [label setText:[NSString stringWithFormat:@"%02d:%02d %@", lHour, comp.minute, lAmPm]];
    
    
    label.font = [UIFont fontWithName:FONT_NAME size:11.0];
    
    [label setTextColor:customColor];
    CGFloat width = [label widthThatWouldFit];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(label.frame.origin.x+width+10., DAYVIEW_HEIGHT_CELL_MIN/2., _width-label.frame.origin.x-width, 1.)];
    [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [view setBackgroundColor:customColor];
    [label addSubview:view];
    
    return label;
}

- (void)addButtonsWithArray:(NSArray *)array {
    
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[SMXBlueButton class]]) {
            [subview removeFromSuperview];
        }
    }
    [arrayButtonsEvents removeAllObjects];
    
    BOOL boolIsToday = [NSDate isTheSameDateTheCompA:[NSDate componentsOfCurrentDate] compB:[NSDate componentsOfDate:date]];
    [labelRed setAlpha:boolIsToday];
    [labelWithSameYOfCurrentHour setAlpha:!boolIsToday];  //TODO: if the hour/half-hour line is need to be displayed, set the alpha to 1. or else hide the line near to the current time line by setting alpha as 0.
    
    
    NSArray *arrayEvents = array;
    
    if (arrayEvents) {
        
        if (!cSamePositionAndDurationEvents) {
            cSamePositionAndDurationEvents = [[NSMutableArray alloc] init];
        }
        
        if (!cEventInsideALargerEvent) {
            cEventInsideALargerEvent = [[NSMutableArray alloc] init];
        }
        
        if (!cEventsWhichAccomodateSmallerEvents) {
            cEventsWhichAccomodateSmallerEvents = [[NSMutableDictionary alloc] init];
        }
        for (SMXEvent *event in arrayEvents) {
            
            CGFloat yTimeBegin = 0.;
            CGFloat yTimeEnd = 0.;
            float lHeight = 0.;
            for (SMXHourAndMinLabel *label in arrayLabelsHourAndMin) {
                NSDateComponents *compLabel = [NSDate componentsOfDate:label.dateHourAndMin];
                NSDateComponents *compEventBegin = [NSDate componentsOfDate:event.dateTimeBegin];
                NSDateComponents *compEventEnd = [NSDate componentsOfDate:event.dateTimeEnd];

                
                if (compLabel.hour == compEventBegin.hour && compLabel.minute <= compEventBegin.minute && compEventBegin.minute < compLabel.minute+DAYVIEW_MINUTES_PER_LABEL) {
                    yTimeBegin = label.frame.origin.y+label.frame.size.height/2.;

                }
                if (compLabel.hour == compEventEnd.hour && compLabel.minute <= compEventEnd.minute && compEventEnd.minute < compLabel.minute+DAYVIEW_MINUTES_PER_LABEL) {
   
                    yTimeEnd = label.frame.origin.y+label.frame.size.height;
                 
                    float lHourHeight = (compEventEnd.hour - compEventBegin.hour) * DAYVIEW_HEIGHT_CELL_HOUR;
                    float lMinuteHeight =  (float)((compEventEnd.minute - compEventBegin.minute)/60.0) * DAYVIEW_HEIGHT_CELL_HOUR;
                    
                    lHeight =  lHourHeight + lMinuteHeight;
                }
            }
            
            
            SMXBlueButton *_button = [[SMXBlueButton alloc] initWithFrame:CGRectMake(EVENT_X_POSITION, yTimeBegin, self.frame.size.width - EVENT_X_POSITION, lHeight)];

            _button.tag = 1001;  // tag will assist in determining if the view is actually an SMXBlueButton or not.
            _button.eventName.text = event.stringCustomerName;
            
            [_button setEvent:event];


            
            [self compareAndRepositionEvents:_button withButtonPosition:arrayButtonsEvents.count-1];
            
            
            NSLog(@"localid: %@", event.localID);
            
            UILongPressGestureRecognizer *lLongPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(moveEvent:)];
            
            [_button addGestureRecognizer:lLongPressGesture];
            
            [arrayButtonsEvents addObject:_button];
            [self addSubview:_button];
            
           float lWidth = (self.frame.size.width - EVENT_X_POSITION)/cSamePositionAndDurationEvents.count;

            for ( int i = 0 ; i < cSamePositionAndDurationEvents.count ; i++) {
                
                
                SMXBlueButton *lbutton = [cSamePositionAndDurationEvents objectAtIndex:i];
                CGRect lFirstButtonFrame = lbutton.frame;
                lFirstButtonFrame.size.width = lWidth;
                if (i==0) {
                    lFirstButtonFrame.origin.x = EVENT_X_POSITION;
                }
                else
                {
                    lFirstButtonFrame.origin.x = EVENT_X_POSITION + i*lWidth;

                }
                lbutton.frame = lFirstButtonFrame;
                
                lFirstButtonFrame = lbutton.eventName.frame;
                lFirstButtonFrame.size.width = lWidth - 5;
                lbutton.eventName.frame = lFirstButtonFrame;
                
                
                lFirstButtonFrame = lbutton.eventAddress.frame;
                lFirstButtonFrame.size.width = lWidth - 5;
                lbutton.eventAddress.frame = lFirstButtonFrame;
            }
            
            [cSamePositionAndDurationEvents removeAllObjects];
            
            lWidth = (self.frame.size.width - EVENT_X_POSITION)/2/cEventInsideALargerEvent.count;

            for (int i = 0; i < cEventInsideALargerEvent.count; i++) {
                
                SMXBlueButton *lbutton = [cEventInsideALargerEvent objectAtIndex:i];
                
                CGRect lFirstButtonFrame = lbutton.frame;
                lFirstButtonFrame.size.width = lWidth;
                
                if (i==0) {
                    lFirstButtonFrame.origin.x = lbutton.superview.frame.size.width - lFirstButtonFrame.size.width;

                }
                else
                {
                    lFirstButtonFrame.origin.x = (self.frame.size.width - EVENT_X_POSITION)/2 + i*lWidth;

                }
                
                lbutton.frame = lFirstButtonFrame;
                
                
                lFirstButtonFrame = lbutton.eventName.frame;
                lFirstButtonFrame.size.width = lbutton.frame.size.width;
                lbutton.eventName.frame = lFirstButtonFrame;
                
                
                lbutton.borderView.backgroundColor = [UIColor clearColor];

                float borderWidth = 5.0;
                
                UIColor *borderColor  = [UIColor whiteColor];
                UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, borderWidth, lbutton.frame.size.height)];
                UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, lbutton.frame.size.width, borderWidth)];
                UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, lbutton.frame.size.height - borderWidth, lbutton.frame.size.width, borderWidth)];

                leftView.opaque = YES;
                topView.opaque = YES;
                bottomView.opaque = YES;

                leftView.backgroundColor = borderColor;
                topView.backgroundColor = borderColor;
                bottomView.backgroundColor = borderColor;

                // for bonus points, set the views' autoresizing mask so they'll stay with the edges:
                leftView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
                topView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
                bottomView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;

                [lbutton addSubview:leftView];
                [lbutton addSubview:topView];
                [lbutton addSubview:bottomView];

            }
            
            [cEventInsideALargerEvent removeAllObjects];
            
        }
    }
}


-(void)compareAndRepositionEvents: (SMXBlueButton *)_button withButtonPosition:(int)buttonIndex
{
    
    
    if (arrayButtonsEvents.count <= buttonIndex || buttonIndex < 0) {
        return;
    }
    
    SMXBlueButton *lOldButton = [arrayButtonsEvents objectAtIndex:buttonIndex];
    
    NSLog(@"lOldButton : %@", lOldButton.eventName.text);
    NSLog(@"_button : %@", _button.eventName.text);

    CGRect lOldButtonFrame = lOldButton.frame;
    CGRect lButtonFrame = _button.frame;

    NSLog(@"lOldButton : %@", NSStringFromCGRect(lOldButtonFrame));
    NSLog(@"_button : %@", NSStringFromCGRect(lButtonFrame));

    if ((lOldButton.frame.origin.y + lOldButton.frame.size.height) >= (_button.frame.origin.y + _button.frame.size.height))
    {

            if (lOldButton.frame.origin.y == _button.frame.origin.y)
            {
                if (lOldButton.frame.size.height == _button.frame.size.height)
                {
                    
                    if(![cEventInsideALargerEvent containsObject:_button])
                    {
                        if (![cSamePositionAndDurationEvents containsObject:_button])
                        {
                            [cSamePositionAndDurationEvents addObject:_button];
                        }
                        [cSamePositionAndDurationEvents addObject:lOldButton];
                    }
                    
                    else
                    {
                        [cEventInsideALargerEvent addObject:lOldButton];
                    }
                    
                    
                    [self compareAndRepositionEvents:lOldButton withButtonPosition:buttonIndex-1];

                    
                }
                else
                {
                    // Both events same starting time.

                    
                    if(![cEventInsideALargerEvent containsObject:_button])
                    {
                        [cEventInsideALargerEvent addObject:_button];
                    
                   
                    
                        [cEventsWhichAccomodateSmallerEvents setObject:lOldButton forKey:_button.eventName.text];
                    }
                }
            }
            else
            {
                // _button is inside the lAddedButton
                
                
                if(![cEventInsideALargerEvent containsObject:_button])
                {
                    [cEventInsideALargerEvent addObject:_button];
                
               
                
                [cEventsWhichAccomodateSmallerEvents setObject:lOldButton forKey:_button.eventName.text];
                
                }
            }
        }
    else
    {
        // The case wherein the previous button is inside a larger event
        
        SMXBlueButton *lTempButton = [cEventsWhichAccomodateSmallerEvents objectForKey:lOldButton.eventName.text];

        NSLog(@"lTempButton : %@", NSStringFromCGRect(lTempButton.frame));

        NSLog(@"_button : %@", NSStringFromCGRect(_button.frame));
        
        if ((lTempButton.frame.origin.y + lTempButton.frame.size.height) >= (_button.frame.origin.y + _button.frame.size.height))
        {
            [cEventInsideALargerEvent addObject:_button];
        }
    }
    

}


#pragma mark - Button Action

- (IBAction)buttonAction:(id)sender {
    
    button = (SMXBlueButton *)sender;
    
    if (protocol != nil && [protocol respondsToSelector:@selector(showViewDetailsWithEvent:cell:)]) {
        [protocol showViewDetailsWithEvent:button.event cell:self];
    }
}

/*
 
 Date: 16-September
 MethodName - dayEventSelected:
 Arguments - pNotification
 Description - Its a post notification method called from SMXBlueButton. Whenever an event is selected/clicked from left panel, this method getting triggered.
 Purpose - to reset the BG color and the label text colors of the other events in the left panel to default status colors.

*/

-(void)dayEventSelected:(NSNotification *)pNotification
{
//    NSLog(@"eventSelected");
    
//    cSelectedEventButton = (SMXBlueButton *)pNotification.object;
    
    for (UIView *subview in self.subviews) {
        if ( subview.tag == 1001){
         
            SMXBlueButton *lbutton = (SMXBlueButton *)subview;

            if(![subview isEqual:pNotification.object]) {
            lbutton.eventName.textColor = [UIColor blackColor];
            lbutton.eventAddress.textColor = [UIColor grayColor];
            [lbutton setBackgroundColor:[UIColor colorWithRed:228.0/255. green:228.0/255. blue:228.0/255. alpha:1.0]];
            lbutton.borderView.backgroundColor = [UIColor colorWithRed:121.0/255.0 green:121.0/255.0 blue:121.0/255.0 alpha:1.0];
            }
            
            
            else
            {
                if (protocol != nil && [protocol respondsToSelector:@selector(showViewDetailsWithEvent:cell:)]) {
                    [protocol showViewDetailsWithEvent:lbutton.event cell:self];
                }
            }
        }
    }
}


-(void)moveEvent:(UILongPressGestureRecognizer *)gesture
{
    CGPoint loc = [gesture locationInView:self];
    NSLog(@"loc : %@", NSStringFromCGPoint(loc));
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        cSelectedEventButton = (SMXBlueButton *)[gesture view];
        
        cOriginalFrame = gesture.view.frame;
        
        cDifferenceInY = loc.y - cOriginalFrame.origin.y;
        
        cSelectedEventButton.eventName.textColor = [UIColor whiteColor];
        cSelectedEventButton.eventAddress.textColor = [UIColor whiteColor];
        [cSelectedEventButton setBackgroundColor:[UIColor colorWithRed:255.0/255. green:102.0/255. blue:51.0/255. alpha:1.0]];
    }
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
        
        CGRect lFrame = cSelectedEventButton.frame;
        float lY_Axis = lFrame.origin.y;
        
        if (loc.y > lY_Axis) {
            lFrame.origin.y += (loc.y - lY_Axis) - cDifferenceInY;
        }
        else if (loc.y < lY_Axis)
        {
            lFrame.origin.y -= (lY_Axis - loc.y) - cDifferenceInY;

        }
        else
        {
            //Do nothing if by some mistake the delegate responds to being in the same position
        }
        cSelectedEventButton.frame = lFrame;
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        
        
        cSelectedEventButton.eventName.textColor = [UIColor blackColor];
        cSelectedEventButton.eventAddress.textColor = [UIColor grayColor];
        [cSelectedEventButton setBackgroundColor:[UIColor colorWithRed:228.0/255. green:228.0/255. blue:228.0/255. alpha:1.0]];
        
      
        if (cSelectedEventButton) {
            
            UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Do you wish to reschedule the event?" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
            [lAlertView show];
            lAlertView = nil;
        }
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (buttonIndex == 0) {
        
        //TODO: Update the relevant table to update event listing in the DB.
        
        float lDifferenceInPosition = cOriginalFrame.origin.y - cSelectedEventButton.frame.origin.y ;
        
        int min = abs (lDifferenceInPosition * 60 / DAYVIEW_HEIGHT_CELL_HOUR);
        

        
        [cSelectedEventButton.event explainMe];
        

        if (lDifferenceInPosition > 0)
        {
            NSLog(@"event is pre-poned by %d", min);
            [CalenderHelper updateEvent:cSelectedEventButton.event toActivityDate:cSelectedEventButton.event.ActivityDateDay andStartTime:[cSelectedEventButton.event.dateTimeBegin dateByAddingTimeInterval:-60*min] withEndTime:[cSelectedEventButton.event.dateTimeEnd dateByAddingTimeInterval:-60*min]];
        }
        else
        {
            NSLog(@"event is postponed by %d", min);
            
             [CalenderHelper updateEvent:cSelectedEventButton.event toActivityDate:cSelectedEventButton.event.ActivityDateDay andStartTime:[cSelectedEventButton.event.dateTimeBegin dateByAddingTimeInterval:+60*min] withEndTime:[cSelectedEventButton.event.dateTimeEnd dateByAddingTimeInterval:+60*min]];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_RESCHEDULED object:nil];
        
    }
    else
    {
        [UIView animateWithDuration:1.0
                         animations:^{
                             cSelectedEventButton.frame = cOriginalFrame;
                         }];
    }
}

@end
