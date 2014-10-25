//
//  SMXWeekCell.m
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

#import "SMXWeekCell.h"

#import "SMXHourAndMinLabel.h"
#import "SMXBlueButton.h"
#import "StyleManager.h"
#import "SMXEventDetailPopoverController.h"
#import "SMXEditEventPopoverController.h"
#import "SMXImportantFilesForCalendar.h"
#import "SFMPageViewController.h"
#import "SFMViewPageManager.h"
#import "AlertMessageHandler.h"
#import "TagManager.h"
#import "CalenderHelper.h"
#import "TransactionObjectModel.h"


#define WEEKVIEW_HEIGHT_CELL_HOUR 70.

@interface SMXWeekCell () <SMXEventDetailPopoverControllerProtocol, SMXEditEventPopoverControllerProtocol>
@property (nonatomic, strong) NSMutableArray *arrayLabelsHourAndMin;
@property (nonatomic, strong) NSMutableArray *arrayButtonsEvents;
@property (nonatomic, strong) SMXEventDetailPopoverController *popoverControllerDetails;
@property (nonatomic, strong) SMXEditEventPopoverController *popoverControllerEditar;
@property (nonatomic, strong) SMXBlueButton *button;
@property (nonatomic, assign) CGRect cOriginalFrame;
@property (nonatomic, assign) CGFloat cDifferenceInY;
@property (nonatomic, assign) CGFloat cDifferenceInX;
@property (nonatomic, strong) SMXBlueButton *cSelectedEventButton;
@property (nonatomic, assign)  CGFloat zPositionOfSelectedView;
@property (nonatomic, strong) NSMutableArray *eventList;

@end

@implementation SMXWeekCell

@synthesize protocol;
@synthesize date;
@synthesize arrayLabelsHourAndMin;
@synthesize arrayButtonsEvents;
@synthesize popoverControllerDetails;
@synthesize popoverControllerEditar;
@synthesize button;
@synthesize _border;
@synthesize cSelectedEventButton;
@synthesize cOriginalFrame;
@synthesize cDifferenceInY;
@synthesize cDifferenceInX;
@synthesize zPositionOfSelectedView;
@synthesize eventList;
static UIImage *lineImage;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    lineImage=[UIImage imageNamed:@"dotted_line"];
    if (self) {
        // Initialization code
        
        [self setBackgroundColor:[UIColor whiteColor]];
        
        arrayLabelsHourAndMin = [NSMutableArray new];
        arrayButtonsEvents = [NSMutableArray new];
        
       // _border = [CAShapeLayer layer];
      //  _border.strokeColor = [UIColor clearColor].CGColor;
       // _border.fillColor = nil;
       // _border.lineDashPattern = @[@1];
      //  [self addSubview:[self grayDashPatternLine:CGRectMake(1,0,frame.size.width,1)]];
        [self addSubview:[self grayLine:CGRectMake(0,0,1, frame.size.height-CELL_HEIGHT_MARGINE_BOTTOM)]];
        [self addLines];
    }
    return self;
}

-(UIImageView *)grayDashPatternLine:(CGRect )rect{
    UIImageView *grayLine=[[UIImageView alloc] initWithFrame:rect];
    grayLine.backgroundColor=[UIColor colorWithHexString:@"D7D7D7"];
     _border = [CAShapeLayer layer];
      _border.strokeColor = [UIColor colorWithHexString:@"D7D7D7"].CGColor;
     _border.fillColor = nil;
     _border.lineDashPattern = @[@5];
    return grayLine;
}
-(UIImageView *)grayLine:(CGRect )rect{
    UIImageView *grayLine=[[UIImageView alloc] initWithFrame:rect];
    grayLine.backgroundColor=[UIColor colorWithHexString:@"D7D7D7"];
    return grayLine;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    _border.path = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    _border.frame = self.bounds;
}

- (void)showEvents:(NSArray *)array {
    
    [self addButtonsWithArray:array];
}

- (void)addLines {
    
    CGFloat y = 0;
    
    for (int hour=0; hour<=23; hour++) {
        
        for (int min=0; min<=45; min=min+MINUTES_PER_LABEL) {
            
            SMXHourAndMinLabel *labelHourMin = [[SMXHourAndMinLabel alloc] initWithFrame:CGRectMake(0, y, self.frame.size.width+1, HEIGHT_CELL_MIN) date:[NSDate dateWithHour:hour min:min]];
            [labelHourMin setTextColor:[UIColor grayColor]];
            if (min == 0) {
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width+1, 1.)];//cell line separeter
                [view.layer setBorderWidth:5.0];
                [view.layer setBorderColor:[[UIColor colorWithPatternImage:lineImage] CGColor]];
                [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
                [labelHourMin setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
                [labelHourMin addSubview:view];
            }
            [self addSubview:labelHourMin];
            [arrayLabelsHourAndMin addObject:labelHourMin];
            
            y += HEIGHT_CELL_MIN;
        }
    }
    [self addSubview:[self grayLine:CGRectMake(0,y,self.frame.size.width+1,1)]];
}
-(UIView *)graydashLine:(CGRect )rect{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width+1, 1.)];//cell line separeter
    [view.layer setBorderWidth:5.0];
    [view.layer setBorderColor:[[UIColor colorWithPatternImage:lineImage] CGColor]];
    [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    //[labelHourMin setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    //[labelHourMin addSubview:view];
    return view;
}
- (void)clean {
    
     [arrayButtonsEvents removeAllObjects];
    
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[SMXBlueButton class]]) {
            [subview removeFromSuperview];
        }
    }
}

- (void)addButtonsWithArray:(NSArray *)array {
    eventList =[[NSMutableArray alloc] init];
    NSLog(@"Event name >>>>>>>>>>=======>>>>>>>>>");
    if (array) {
        
        for (SMXEvent *event in array) {
            
            CGFloat yTimeBegin;
            CGFloat yTimeEnd;
            
            for (SMXHourAndMinLabel *label in arrayLabelsHourAndMin) {
                NSDateComponents *compLabel = [NSDate componentsOfDate:label.dateHourAndMin];
                NSDateComponents *compEventBegin = [NSDate componentsOfDate:event.dateTimeBegin];
                NSDateComponents *compEventEnd = [NSDate componentsOfDate:event.dateTimeEnd];
                
                if (compLabel.hour == compEventBegin.hour && compLabel.minute <= compEventBegin.minute && compEventBegin.minute < compLabel.minute+MINUTES_PER_LABEL) {
                    yTimeBegin = label.frame.origin.y;//+label.frame.size.height/2.;//Event changes, its for event alingment, start point
                }
                if (compLabel.hour == compEventEnd.hour && compLabel.minute <= compEventEnd.minute && compEventEnd.minute < compLabel.minute+MINUTES_PER_LABEL) {
                    yTimeEnd = label.frame.origin.y;//+label.frame.size.height;//Event changes, its for event alingment, end poing
                }
            }
            SMXBlueButton *_button = [[SMXBlueButton alloc] initWithFrame:CGRectMake(0, yTimeBegin, self.frame.size.width-EVENT_SPACE_FROM_CELL_RIGHT, yTimeEnd-yTimeBegin)];
            _button.eventName.text = event.stringCustomerName;
            NSLog(@"Event name %@ event count %d",event.stringCustomerName,[eventList count]);
            _button._IsWeekEvent=TRUE;
            _button.event=event;
            UILongPressGestureRecognizer *lLongPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(moveEvent:)];
            [_button addGestureRecognizer:lLongPressGesture];
            [arrayButtonsEvents addObject:_button];
            _button.cuncurrentIndex=0;
            [self addSubview:_button];
            [self addEventOverCell:_button];
        }
    }
}
-(void)addEventOverCell:(SMXBlueButton *)eventView{
    if ([eventList count]>=1) {
        for(int i=0;i<[eventList count];i++){
            SMXBlueButton *oldView=[eventList objectAtIndex:i];
            int numberOfEventInCell=self.frame.size.width/oldView.frame.size.width;
            CGFloat cellWidth=self.frame.size.width/(numberOfEventInCell+1);
            if ([self isRectOverlaping:oldView.frame newEvent:eventView.frame]) {
                oldView.frame=CGRectMake(cellWidth*eventView.cuncurrentIndex, oldView.frame.origin.y, cellWidth, oldView.frame.size.height);
                [oldView restContentFrames:cellWidth-10.0f];
                eventView.frame=CGRectMake(numberOfEventInCell*cellWidth, eventView.frame.origin.y, cellWidth, eventView.frame.size.height);
                [eventView restContentFrames:cellWidth-10.0f];
                eventView.cuncurrentIndex=eventView.cuncurrentIndex+1;
            }
        }
    }
    [eventList addObject:eventView];
}
-(BOOL)isRectOverlaping:(CGRect )oldEvent newEvent:(CGRect )newEvent{
    if ((oldEvent.origin.y<=newEvent.origin.y) && ((oldEvent.origin.y+oldEvent.size.height)>=newEvent.origin.y)) {
        return TRUE;
    }
    return FALSE;
}
-(void)moveEvent:(UILongPressGestureRecognizer *)gesture
{
    CGPoint loc = [gesture locationInView:self];
    NSLog(@"loc : %@", NSStringFromCGPoint(loc));
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        cSelectedEventButton = (SMXBlueButton *)[gesture view];
        zPositionOfSelectedView=[cSelectedEventButton superview].layer.zPosition;
        cOriginalFrame = gesture.view.frame;
        
        cDifferenceInY = loc.y - cOriginalFrame.origin.y;
        cDifferenceInX = loc.x -cOriginalFrame.origin.x;
        
        cSelectedEventButton.eventName.textColor = [UIColor whiteColor];
        cSelectedEventButton.eventAddress.textColor = [UIColor whiteColor];
        [cSelectedEventButton setBackgroundColor:[UIColor colorWithRed:255.0/255. green:102.0/255. blue:51.0/255. alpha:1.0]];
    }
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
        [cSelectedEventButton superview].layer.zPosition=100298.0f;
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
        
        float lX_Axis = lFrame.origin.x;
        
        if (loc.x > lX_Axis) {
            lFrame.origin.x += (loc.x - lX_Axis) - cDifferenceInX;
        }
        else if (loc.x < lX_Axis)
        {
            lFrame.origin.x -= (lX_Axis - loc.x) - cDifferenceInX;
            
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
       // [cSelectedEventButton superview].layer.zPosition=zPositionOfSelectedView;
        if (cSelectedEventButton) {
            /*int yourDOW = [[[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit
                                                           fromDate:[self newEventActivityDate:cSelectedEventButton.event.ActivityDateDay]] weekday];*/
            /*if (yourDOW == 1 || yourDOW == 7) {
                [UIView animateWithDuration:0.50
                                      delay:0.0
                                    options: UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     cSelectedEventButton.eventName.textColor = [UIColor blackColor];
                                     cSelectedEventButton.eventAddress.textColor = [UIColor grayColor];
                                     [cSelectedEventButton setBackgroundColor:[UIColor colorWithRed:228.0/255. green:228.0/255. blue:228.0/255. alpha:1.0]];
                                     cSelectedEventButton.frame = cOriginalFrame;
                                 }
                                 completion:^(BOOL finished){
                                     [cSelectedEventButton superview].layer.zPosition=zPositionOfSelectedView;
                                 }];
            }else{
                UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Do you wish to reschedule the event?" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
                [lAlertView show];
                lAlertView = nil;
            }*/
            UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Do you wish to reschedule the event?" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
            [lAlertView show];
            lAlertView = nil;
        }else{
            
        }
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (buttonIndex == 0) {
        
        //TODO: Update the relevant table to update event listing in the DB.
        
        float lDifferenceInPosition = cOriginalFrame.origin.y - cSelectedEventButton.frame.origin.y ;
        int min = abs (lDifferenceInPosition * 60 / HEIGHT_CELL_HOUR);
        NSLog(@"cSelectedEventButton: %@", cSelectedEventButton);
        NSLog(@"cSelectedEventButton.event : %@", cSelectedEventButton.event);
        NSLog(@"eventName.starttime : %@", cSelectedEventButton.event.dateTimeBegin);
        [cSelectedEventButton.event explainMe];
        NSDate *datePlusOneMinute = [cSelectedEventButton.event.dateTimeBegin dateByAddingTimeInterval:60*min];
        NSLog(@"datePlusOneMinute:%@", datePlusOneMinute);
        if (lDifferenceInPosition > 0)
        {
            NSLog(@"event is pre-poned by %d", min);
            [CalenderHelper updateEvent:cSelectedEventButton.event toActivityDate:[self newEventActivityDate:cSelectedEventButton.event.ActivityDateDay] andStartTime:[cSelectedEventButton.event.dateTimeBegin dateByAddingTimeInterval:-60*min] withEndTime:[cSelectedEventButton.event.dateTimeEnd dateByAddingTimeInterval:-60*min]];
        }
        else
        {
            NSLog(@"event is postponed by %d", min);
            
            [CalenderHelper updateEvent:cSelectedEventButton.event toActivityDate:[self newEventActivityDate:cSelectedEventButton.event.ActivityDateDay] andStartTime:[cSelectedEventButton.event.dateTimeBegin dateByAddingTimeInterval:+60*min] withEndTime:[cSelectedEventButton.event.dateTimeEnd dateByAddingTimeInterval:+60*min]];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_RESCHEDULED object:nil];
    }
    else
    {
        [UIView animateWithDuration:0.50
                              delay:0.0
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             cSelectedEventButton.eventName.textColor = [UIColor blackColor];
                             cSelectedEventButton.eventAddress.textColor = [UIColor grayColor];
                             [cSelectedEventButton setBackgroundColor:[UIColor colorWithRed:228.0/255. green:228.0/255. blue:228.0/255. alpha:1.0]];
                             cSelectedEventButton.frame = cOriginalFrame;
                         }
                         completion:^(BOOL finished){
                             [cSelectedEventButton superview].layer.zPosition=zPositionOfSelectedView;
                         }];
    }
}
-(int)numberOfDayCahnged{
    int XMargine=cSelectedEventButton.frame.origin.x-cOriginalFrame.origin.x;
    int i=(XMargine/self.frame.size.width);
    if (i<0) {
        NSLog(@"number of day reduce:  %d",i);
    }else{
        NSLog(@"number of day:  %d",i+1);
    }
    return i;
}
-(NSDate *)newEventActivityDate:(NSDate *)CurrentDate{
    int days=[self numberOfDayCahnged];
    NSDate *now = CurrentDate;
    NSDate *sevenDaysAgo = [now dateByAddingTimeInterval:days*24*60*60];
    NSLog(@"7 days ago: %@", sevenDaysAgo);
    return sevenDaysAgo;
}
-(NSString *)resuduleDuration{
    int XMargine=cSelectedEventButton.frame.origin.x-cOriginalFrame.origin.x;
    int YMargine=cSelectedEventButton.frame.origin.y-cOriginalFrame.origin.y;
    int i=(XMargine/self.frame.size.width);
    if (i<0) {
        NSLog(@"number of day reduce:  %d",i-1);
    }else{
        NSLog(@"number of day:  %d",i);
    }
    i=(YMargine/self.frame.size.height);
    if (i<0) {
        NSLog(@"number of hour reduce:  %d",i-1);
    }else{
        NSLog(@"number of hour:  %d",i);
    }
    int cellHight=70;
    float min=(float)(YMargine%cellHight);
    i=min/(cellHight/60.0f);
    if (i<0) {
        NSLog(@"number of Min reduce:  %d",i-1);
    }else{
        NSLog(@"number of Min:  %d",i);
    }
    return @"";
}
#pragma mark - Button Action

- (IBAction)buttonAction:(id)sender {
    
    button = (SMXBlueButton *)sender;
    
    popoverControllerDetails = [[SMXEventDetailPopoverController alloc] initWithEvent:button.event];
    [popoverControllerDetails setProtocol:self];
    
    [popoverControllerDetails presentPopoverFromRect:button.frame
                                              inView:self
                            permittedArrowDirections:UIPopoverArrowDirectionAny
                                            animated:YES];
}

#pragma mark - SMXEventDetailPopoverController Protocol

- (void)showPopoverEditWithEvent:(SMXEvent *)_event {
    
    popoverControllerEditar = [[SMXEditEventPopoverController alloc] initWithEvent:_event];
    [popoverControllerEditar setProtocol:self];
    
    [popoverControllerEditar presentPopoverFromRect:button.frame
                                             inView:self
                           permittedArrowDirections:UIPopoverArrowDirectionAny
                                           animated:YES];
}

#pragma mark - SMXEditEventPopoverController Protocol

- (void)saveEditedEvent:(SMXEvent *)eventNew {
    
    if (protocol != nil && [protocol respondsToSelector:@selector(saveEditedEvent:ofCell:atIndex:)]) {
        [protocol saveEditedEvent:eventNew ofCell:self atIndex:[arrayButtonsEvents indexOfObject:button]];
    }
}

- (void)deleteEvent {
    
    if (protocol != nil && [protocol respondsToSelector:@selector(deleteEventOfCell:atIndex:)]) {
        [protocol deleteEventOfCell:self atIndex:[arrayButtonsEvents indexOfObject:button]];
    }
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
