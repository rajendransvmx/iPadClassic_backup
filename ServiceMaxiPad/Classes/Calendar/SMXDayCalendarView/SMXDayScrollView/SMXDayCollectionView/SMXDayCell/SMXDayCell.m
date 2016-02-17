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
#import "ServiceLocationModel.h"
#import "TagManager.h"
#import "AlertMessageHandler.h"
#import "SMXCalendarViewController.h"
#import "CaseObjectModel.h"
#import "SMXDayCalendarView.h"

#define FONT_NAME @"HelveticaNeue-Medium"

#define DAYVIEW_MINUTES_INTERVAL 2.
#define DAYVIEW_HEIGHT_CELL_HOUR 70.
#define DAYVIEW_HEIGHT_CELL_MIN DAYVIEW_HEIGHT_CELL_HOUR/DAYVIEW_MINUTES_INTERVAL
#define DAYVIEW_MINUTES_PER_LABEL 60./DAYVIEW_MINUTES_INTERVAL

#define EVENT_X_POSITION 70.



#define kEventStartTimeDate             @"eventStartTime"
#define kEventDurationLong              @"eventDuration"
#define kEventsArray                    @"eventsArray"
#define kSmallerEventsDictionary        @"smallerEvents"
#define kOtherEventsDictionary          @"otherEvents"

@interface SMXDayCell ()
@property (nonatomic, strong) NSMutableArray *arrayLabelsHourAndMin;
@property (nonatomic, strong) NSMutableArray *arrayButtonsEvents;
@property (nonatomic, strong) SMXBlueButton *cDraggedForReschedulingButton;

@property (nonatomic) CGFloat yCurrent;
@property (nonatomic, strong) UILabel *labelWithSameYOfCurrentHour;
@property (nonatomic, strong) UILabel *labelRed;

@property (nonatomic, assign) CGRect cOriginalFrame;
@property (nonatomic, assign) CGFloat cDifferenceInY;

@property (nonatomic, strong) NSMutableArray *cSamePositionAndDurationEvents;
@property (nonatomic, strong) NSMutableArray *cEventInsideALargerEvent;

@property (nonatomic, strong) NSMutableDictionary *cEventsWhichAccomodateSmallerEvents;



@property (nonatomic, strong) NSMutableDictionary *cAllEventDictionary;
//@property (nonatomic, assign) int cCurrentLevel;

@end

@implementation SMXDayCell

@synthesize protocol;
@synthesize date;
@synthesize arrayLabelsHourAndMin;
@synthesize arrayButtonsEvents;
@synthesize cDraggedForReschedulingButton;
@synthesize yCurrent;
@synthesize labelWithSameYOfCurrentHour;
@synthesize labelRed;
@synthesize cSelectedEventButton;
@synthesize cOriginalFrame;
@synthesize cDifferenceInY;
@synthesize cSamePositionAndDurationEvents;
@synthesize cEventInsideALargerEvent;
@synthesize cEventsWhichAccomodateSmallerEvents;
@synthesize cAllEventDictionary;
//@synthesize cCurrentLevel;
@synthesize CollectionViewDelegate;
@synthesize cellIndex;
@synthesize paintedHeight;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setBackgroundColor:[UIColor whiteColor]];
        
        arrayLabelsHourAndMin = [NSMutableArray new];
        arrayButtonsEvents = [NSMutableArray new];
        
        [self addLines];

        
        
        if (!cAllEventDictionary) {
            cAllEventDictionary = [[NSMutableDictionary alloc] init];
            
            NSDateFormatter *lDateFormatter = [[NSDateFormatter alloc] init];
            [lDateFormatter setDateFormat:@"yyyy-MM-dd"];
            [cAllEventDictionary setObject:[lDateFormatter dateFromString:[lDateFormatter stringFromDate:[NSDate date]]] forKey:kEventStartTimeDate];
            [cAllEventDictionary setObject:[NSNumber numberWithLong:24*60*60] forKey:kEventDurationLong];
            [cAllEventDictionary setObject:@{} forKey:kSmallerEventsDictionary];
            [cAllEventDictionary setObject:@[] forKey:kEventsArray];

        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetTheCurrentTimeLine) name:CURRENT_TIME_LINE_MOVE object:nil];

    }
    return self;
}

- (void)showEvents:(NSArray *)array {
    
    [self addButtonsWithArray:array];
}

-(void)resetTheCurrentTimeLine
{
    NSDateComponents *comp =  [NSDate componentsOfDate:[NSDate date]];

    float lHourHeight = comp.hour * DAYVIEW_HEIGHT_CELL_HOUR;
    float lMinuteHeight =  (float)((comp.minute)/60.0) * DAYVIEW_HEIGHT_CELL_HOUR;
    
    
    long lHour = comp.hour;
    NSString *lAmPm = [[TagManager sharedInstance]tagByName:kTag_AM];
    
    
    if (lHour>=12) {
        lAmPm = [[TagManager sharedInstance]tagByName:kTag_PM];
    }
    
    lHour = (lHour>12? lHour - 12 : lHour); //converting to 0-12 hrs standard
    
    [labelRed setText:[NSString stringWithFormat:@"%02ld:%02ld %@", lHour, (long)comp.minute, lAmPm]];
    
    CGRect lFrame = labelRed.frame;
    lFrame.origin.y = lHourHeight + lMinuteHeight;
    labelRed.frame = lFrame;
    
    [self updateTheLineNearestToTheCurrentLine];
}

-(void)updateTheLineNearestToTheCurrentLine
{
    
    BOOL boolIsToday = [NSDate isTheSameDateTheCompA:[NSDate componentsOfCurrentDate] compB:[NSDate componentsOfDate:date]];
    [labelRed setAlpha:boolIsToday];
        
    for (int i = 0 ; i<arrayLabelsHourAndMin.count ; i++)
    {
        if (i%2!=0) {
            continue;
        }
        
        SMXHourAndMinLabel *theHourBeforeLineLabel = [arrayLabelsHourAndMin objectAtIndex:i];
        if (boolIsToday)
        {
            if (fabs(labelRed.frame.origin.y - theHourBeforeLineLabel.frame.origin.y)>=18)
            {
                [theHourBeforeLineLabel showText];
            }
            else
            {
                theHourBeforeLineLabel.text = @"";
                
            }
        }
        else
        {
            [theHourBeforeLineLabel showText];
        }
  
    }

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
            
            labelHourMin.backgroundColor = [UIColor clearColor];
//            labelHourMin.tag = [[NSString stringWithFormat:@"%d%d", hour, min] intValue];
            
            float line_X_Position = 0.0;
            if (min == 0)
            {
                [labelHourMin showText];
//                NSLog(@"labelHourMin:%@", labelHourMin);
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
    
    long lHour = comp.hour;
    NSString *lAmPm = [[TagManager sharedInstance]tagByName:kTag_AM];
    
    
    if (lHour>=12) {
        lAmPm = [[TagManager sharedInstance]tagByName:kTag_PM];
    }
    
    lHour = (lHour>12? lHour - 12 : lHour); //converting to 0-12 hrs standard
    
    [label setText:[NSString stringWithFormat:@"%02ld:%02ld %@", lHour, (long)comp.minute, lAmPm]];
    
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
    
    for (SMXBlueButton *button in arrayButtonsEvents) {
        [button removeFromSuperview];
    }
    [arrayButtonsEvents removeAllObjects];
    
    [self updateTheLineNearestToTheCurrentLine];
    

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
        else
        {
            [cEventsWhichAccomodateSmallerEvents removeAllObjects];
        }
        paintedHeight = 0;
        for (SMXEvent *event in arrayEvents) {

            CGFloat yTimeBegin = 0.;
            CGFloat yTimeEnd = 0.;
            float lHeight = 0.;

            NSDateComponents *compEventBegin = [NSDate componentsOfDate:event.dateTimeBegin];
            NSDateComponents *compEventEnd = [NSDate componentsOfDate:event.dateTimeEnd];

            for (SMXHourAndMinLabel *label in arrayLabelsHourAndMin) {
                NSDateComponents *compLabel = [NSDate componentsOfDate:label.dateHourAndMin];

                //NSLog(@"event.dateTimeBegin : %@", event.dateTimeBegin);
                if (compLabel.hour == compEventBegin.hour && compLabel.minute <= compEventBegin.minute && compEventBegin.minute < compLabel.minute+DAYVIEW_MINUTES_PER_LABEL) {
                    
                    long additonalheight = (compEventBegin.minute > 30 ? compEventBegin.minute - 30 : compEventBegin.minute%30);
                    yTimeBegin = label.frame.origin.y+label.frame.size.height/2. + additonalheight * DAYVIEW_HEIGHT_CELL_HOUR/60;  // 70 pixels = 60 mins. Hence 1 min = 70/60

                }
                 if (compLabel.hour == compEventEnd.hour && compLabel.minute <= compEventEnd.minute && compEventEnd.minute < compLabel.minute+DAYVIEW_MINUTES_PER_LABEL) {
   
                    yTimeEnd = label.frame.origin.y+label.frame.size.height;
                 
                    float lHourHeight = (compEventEnd.hour - compEventBegin.hour) * DAYVIEW_HEIGHT_CELL_HOUR;
                    float lMinuteHeight =  (float)((compEventEnd.minute - compEventBegin.minute)/60.0) * DAYVIEW_HEIGHT_CELL_HOUR;
                    
                    lHeight =  lHourHeight + lMinuteHeight;
                }
            }
            
            SMXBlueButton *_button = [[SMXBlueButton alloc] initWithFrame:CGRectMake(EVENT_X_POSITION, yTimeBegin, self.frame.size.width - EVENT_X_POSITION, lHeight)];
            _button.exclusiveTouch=YES;
            _button.tag = 1001;  // tag will assist in determining if the view is actually an SMXBlueButton or not.
            _button.buttonProtocol = self;
            [_button setEvent:event];
            _button.eventIndex=event.eventIndex;
            [_button setTheEventTitleForNormalState];
            
            
            BOOL slaInfo = NO;
            BOOL conflictInfo = NO;
            BOOL priorityInfo = NO;
            
            //========= GETTING SLA & PRIORITY & CONFLICT INFO =========
            if(event.whatId && event.newData)
            {
                if (event.isWorkOrder) {
                    WorkOrderSummaryModel *model = [[SMXCalendarViewController sharedInstance].cWODetailsDict objectForKey:event.whatId];
                    slaInfo = model.sla;
                    priorityInfo = [model.priority boolValue];
                }
                else if (event.isCaseEvent) {
                    CaseObjectModel *model = [[SMXCalendarViewController sharedInstance].cWODetailsDict objectForKey:event.whatId];
                    slaInfo = model.sla;
                    priorityInfo = model.priority;
                }
            }
            else
            {
                slaInfo = event.sla;
                priorityInfo = event.priority;
            }
            
            conflictInfo = event.conflict;
            int total = conflictInfo + slaInfo + priorityInfo;
            switch (total)
            {
                case 3:
                {
                    _button.firstImageView.image = [UIImage imageNamed:@"sync_Error.png"];
                    _button.secondImageView.image = [UIImage imageNamed:@"sla_Indicator.png"];
                    _button.thirdImageView.image = [UIImage imageNamed:@"priority_Flag.png"];
                    
                }
                    break;
                    case 2:
                {
                    if (conflictInfo)
                    {
                        _button.secondImageView.image = [UIImage imageNamed:@"sync_Error.png"];
                        if (slaInfo)
                        {
                            _button.thirdImageView.image = [UIImage imageNamed:@"sla_Indicator.png"];

                        }
                        else{
                            _button.thirdImageView.image = [UIImage imageNamed:@"priority_Flag.png"];

                        }
                    }
                    else
                    {
                        _button.secondImageView.image = [UIImage imageNamed:@"sla_Indicator.png"];
                        _button.thirdImageView.image = [UIImage imageNamed:@"priority_Flag.png"];
                    }
                    
                }
                    break;
                    case 1:
                {
                    if (conflictInfo)
                    {
                        _button.thirdImageView.image = [UIImage imageNamed:@"sync_Error.png"];

                    }
                    else if (slaInfo)
                    {
                        _button.thirdImageView.image = [UIImage imageNamed:@"sla_Indicator.png"];

                    }
                    else
                    {
                        _button.thirdImageView.image = [UIImage imageNamed:@"priority_Flag.png"];

                    }
                    
                }
                    break;
                default:
                    break;
            }
            

            if(lHeight < _button.thirdImageView.frame.size.height)
            {
                CGRect flagFrame = _button.thirdImageView.frame;
                flagFrame.size.height = lHeight;
                _button.thirdImageView.frame = flagFrame;
                
                flagFrame = _button.secondImageView.frame;
                flagFrame.size.height = lHeight;
                _button.secondImageView.frame = flagFrame;
                
                flagFrame = _button.firstImageView.frame;
                flagFrame.size.height = lHeight;
                _button.firstImageView.frame = flagFrame;

            }
            CGRect lEventNameLabelFrame = _button.eventName.frame;
            lEventNameLabelFrame.size.width = lEventNameLabelFrame.size.width - total * _button.thirdImageView.frame.size.width - total*5; // 5 is the gap between each of the flags
            _button.eventName.frame = lEventNameLabelFrame;
//           cAllEventDictionary = [self compareAndSaveEvents:cAllEventDictionary andButton:_button];
            [self compareAndRepositionEvents:_button withButtonPosition:arrayButtonsEvents.count-1];
            UILongPressGestureRecognizer *lLongPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(moveEvent:)];
            [_button addGestureRecognizer:lLongPressGesture];
            [arrayButtonsEvents addObject:_button];
            [self addSubview:_button];
            long samePositionEventCount = (cSamePositionAndDurationEvents.count>3?3:cSamePositionAndDurationEvents.count);
            double lWidth = (self.frame.size.width - EVENT_X_POSITION)/samePositionEventCount;
            if (arrayButtonsEvents.count >1 && cSamePositionAndDurationEvents.count !=0)
            {
                SMXBlueButton *lbutton = [arrayButtonsEvents objectAtIndex:arrayButtonsEvents.count-2];
//                if (lbutton.frame.size.width != (self.frame.size.width - EVENT_X_POSITION)) {
                if ([lbutton doesHaveBorder])
                {
                    lWidth = (self.frame.size.width - EVENT_X_POSITION)/2/samePositionEventCount;
                }
            }
            //=========== only 3 simultaneous events should be displayed. ===========
            for ( int i = 0 ; i < cSamePositionAndDurationEvents.count; i++)
            {
                SMXBlueButton *lbutton = [cSamePositionAndDurationEvents objectAtIndex:i];
                if (i>=3) {
                    lbutton.hidden= YES;
                    continue;
                }
                else
                {
                    lbutton.hidden= NO;
                }
                
                CGRect lFirstButtonFrame = lbutton.frame;
                lFirstButtonFrame.size.width = lWidth;
                float x_position;// = (lWidth==(self.frame.size.width - EVENT_X_POSITION)/cSamePositionAndDurationEvents.count ? EVENT_X_POSITION + i*lWidth : (self.frame.size.width - EVENT_X_POSITION) + i * lWidth);
                
                if (lWidth==(self.frame.size.width - EVENT_X_POSITION)/samePositionEventCount) {
                    x_position = EVENT_X_POSITION + i*lWidth;
                    lFirstButtonFrame.origin.x =  x_position;
                    lbutton.frame = lFirstButtonFrame;
                    [lbutton removeBorderLayersFromButton];
                }
                else
                {
                    x_position =  EVENT_X_POSITION + (self.frame.size.width - EVENT_X_POSITION)/2 + i * lWidth;
                    lFirstButtonFrame.origin.x =  x_position;
                    lbutton.frame = lFirstButtonFrame;
                    
                    [lbutton setThreeSideLayerForSmallerEvent];
                }
            }
            lWidth = (self.frame.size.width - EVENT_X_POSITION)/2/cEventInsideALargerEvent.count;
            for (int i = 0; i < cEventInsideALargerEvent.count; i++)
            {
                SMXBlueButton *lbutton = [cEventInsideALargerEvent objectAtIndex:i];
                lbutton.hidden= NO;

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
                
                [lbutton setThreeSideLayerForSmallerEvent];
            }
            
            [cSamePositionAndDurationEvents removeAllObjects];
            [cEventInsideALargerEvent removeAllObjects];
            
            
//            if (_button.frame.size.height < _button.eventName.frame.size.height + _button.eventAddress.frame.size.height) {
//                _button.eventAddress.hidden = YES;
//            }
        }
    }
    

//    NSLog(@"cAllEventDictionary:%@", cAllEventDictionary);
    
    if([[SMXDateManager sharedManager] selectedEvent])  //This is required when the data sync finishes and the collectionview invalidates.
    {
        SMXEvent *selectedEvent = [[SMXDateManager sharedManager] selectedEvent];
        for (SMXBlueButton *button in arrayButtonsEvents) {
            [button setEventSubjectLabelPosition];
            if ([button.event.localID isEqualToString:selectedEvent.localID]) {
                cSelectedEventButton = button;
                [[SMXDateManager sharedManager] setSelectedEvent:button.event];
//                [self changeButtonColorForSelected:button];
                [self changeSelectedButtonColorAndShowDetailView];
//                break;
                
            }
        }
    }
    else{
        
        for (SMXBlueButton *button in arrayButtonsEvents) {
            [button setEventSubjectLabelPosition];

        }

    }
}

-(void)compareAndRepositionEvents: (SMXBlueButton *)_button withButtonPosition:(long)buttonIndex
{
    if (arrayButtonsEvents.count <= buttonIndex || buttonIndex < 0) {
        if (paintedHeight<(_button.frame.origin.y +_button.frame.size.height)) {
            paintedHeight = (_button.frame.origin.y +_button.frame.size.height);
        }
        return;
    }
     SMXBlueButton *lOldButton = [arrayButtonsEvents objectAtIndex:buttonIndex];
     if (paintedHeight<(_button.frame.origin.y))
    {
        paintedHeight = (_button.frame.origin.y +_button.frame.size.height);
    }
    else if ([self isEventOverlapping:lOldButton newEvent:_button])
    {
        _button.intOverLapWith = buttonIndex;
        _button.wDivision = lOldButton.wDivision+1;
        _button.xPosition = lOldButton.xPosition + 1;
        _button.frame = [self updateFrame:_button];
        [_button setSubViewFramw];
        [self rearrangeEvent:_button arrayOfTheEvents:arrayButtonsEvents];
    }
    else
    {
        if (lOldButton.wDivision >= 1)
        {
            _button.frame = CGRectMake(lOldButton.frame.origin.x, _button.frame.origin.y, lOldButton.frame.size.width,_button.frame.size.height);
            [_button setSubViewFramw];
        }
        else
        {
            
        }
    }
    if (paintedHeight<(_button.frame.origin.y +_button.frame.size.height)) {
        paintedHeight = (_button.frame.origin.y +_button.frame.size.height);
    }
    
    for (SMXBlueButton *lTempButton in cSamePositionAndDurationEvents) {
        [cEventInsideALargerEvent removeObject:lTempButton];
        
    }
}

-(BOOL)isEventOverlapping:(SMXBlueButton *)oldEvent newEvent:(SMXBlueButton *)event
{
    //changing from float/double to long as the comparision was giving issues with the 3rd & 4th position decimal numbers.
    long oldbuttonHeight = (oldEvent.frame.origin.y + oldEvent.frame.size.height);
    //long newButtonHeight = (event.frame.origin.y + event.frame.size.height);
    if ((oldbuttonHeight >= event.frame.origin.y) && (oldEvent.frame.origin.y <=  event.frame.origin.y))
    {
        return YES;
    }
    return NO;
}
-(CGRect )updateFrame:(SMXBlueButton *)event
{
    long cellwidth = self.frame.size.width-EVENT_X_POSITION;
    return CGRectMake(EVENT_X_POSITION+((cellwidth/event.wDivision)*(event.xPosition-1)), event.frame.origin.y,cellwidth/event.wDivision,event.frame.size.height);
}
-(void)rearrangeEvent:(SMXBlueButton *)event arrayOfTheEvents:(NSArray *)array
{
    if (event.intOverLapWith !=-1)
    {
        if (array.count > event.intOverLapWith)
        {
            SMXBlueButton *oldEvent = [array objectAtIndex:event.intOverLapWith];
            long cellwidth = self.frame.size.width-EVENT_X_POSITION;
            if (oldEvent.xPosition-1 == 0)
            {
                oldEvent.wDivision = oldEvent.wDivision+1;
                oldEvent.frame = CGRectMake(EVENT_X_POSITION, oldEvent.frame.origin.y,cellwidth/oldEvent.wDivision,oldEvent.frame.size.height);
            }
            else
            {
                oldEvent.wDivision = oldEvent.wDivision+1;
                oldEvent.frame = CGRectMake(EVENT_X_POSITION+((cellwidth/oldEvent.wDivision)*(oldEvent.xPosition-1)), oldEvent.frame.origin.y,cellwidth/oldEvent.wDivision,oldEvent.frame.size.height);
            }
            [oldEvent setSubViewFramw];
            [self rearrangeEvent:oldEvent arrayOfTheEvents:array];
        }
    }
    else
    {
        
    }
}

/*
 
 Date: 16-September
 MethodName - dayEventSelected:
 Arguments - id button.
 Description - Its a delegate method called from SMXBlueButton. Whenever an event is selected/clicked from left panel, this method getting triggered.
 Purpose - to reset the BG color and the label text colors of the other events in the left panel to default status colors.

*/

//-(void)dayEventSelected:(NSNotification *)pNotification
-(void)dayEventSelected:(id)button
{
    SMXBlueButton *tempbutton = (SMXBlueButton *)button;
    
    for (UIView *subview in self.subviews) {
        if ( subview.tag == 1001){
         
            SMXBlueButton *lbutton = (SMXBlueButton *)subview;

            if(![lbutton isEqual:tempbutton])
            {
                
                [lbutton setTheButtonForNormalState];

            }
            else
            {
                if (protocol != nil && [protocol respondsToSelector:@selector(showViewDetailsWithEvent:cell:)]) {
                    
                    [[SMXDateManager sharedManager] setSelectedEvent:tempbutton.event];
                    cSelectedEventButton = tempbutton;
                    [self changeSelectedButtonColorAndShowDetailView];
                    [[SMXCalendarViewController sharedInstance] dayEventSelected:tempbutton];

                }
            }
        }
    }
}

-(void)changeSelectedButtonColorAndShowDetailView
{
        [self changeButtonColorForSelected:cSelectedEventButton];
        [protocol showViewDetailsWithEvent:cSelectedEventButton cell:self];
}

-(void)setSelectedButtonColor:(NSNotification *)pNotification
{
    [self changeButtonColorForSelected:cSelectedEventButton];
}

-(void)changeButtonColorForSelected:(SMXBlueButton *)button
{
    [button setTheButtonForSelectedState];
    

}

-(void)changeButtonColorForDragging:(SMXBlueButton *)button
{
    [button setTheButtonForDraggingState];

}

-(void)changeButtonColorForNormalButton:(SMXBlueButton *)button
{
    [button setTheButtonForNormalState];
    


}

-(void)compareWithSelectedButtonAndChangeColorForDraggedButton
{
    if (cSelectedEventButton) {
        if ([cSelectedEventButton.event.localID isEqualToString: cDraggedForReschedulingButton.event.localID]) {
            [self changeButtonColorForSelected:cDraggedForReschedulingButton];
        }
        else
        {
            [self compareWithSelectedButtonAndChangeColorForStationaryButtonAfterDragFinished];
        }
    }
    else
    {
        [self compareWithSelectedButtonAndChangeColorForStationaryButtonAfterDragFinished];

    }
}

-(void)compareWithSelectedButtonAndChangeColorForStationaryButtonAfterDragFinished
{
    if (cSelectedEventButton) {
        if ([cSelectedEventButton.event.localID isEqualToString: cDraggedForReschedulingButton.event.localID]) {
            [self changeButtonColorForSelected:cDraggedForReschedulingButton];
        }
        else
        {
            [self changeButtonColorForNormalButton:cDraggedForReschedulingButton];
        }
    }
    else
    {
        [self changeButtonColorForNormalButton:cDraggedForReschedulingButton];
        
    }
}

-(void)moveEvent:(UILongPressGestureRecognizer *)gesture
{
    CGPoint loc = [gesture locationInView:self];
//    NSLog(@"loc : %@", NSStringFromCGPoint(loc));
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        cDraggedForReschedulingButton = (SMXBlueButton *)[gesture view];
        
        cDraggedForReschedulingButton.layer.zPosition = 100;
//        [self bringSubviewToFront:cDraggedForReschedulingButton];
        cOriginalFrame = gesture.view.frame;
        
        cDifferenceInY = loc.y - cOriginalFrame.origin.y;
        [self changeButtonColorForDragging:cDraggedForReschedulingButton];
        if (cDraggedForReschedulingButton.event.isMultidayEvent || cDraggedForReschedulingButton.event.isAllDay) {
            UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Message" message:[[TagManager sharedInstance]tagByName: kTagDragAndDropNotAllowedMessage] delegate:self cancelButtonTitle:[[TagManager sharedInstance]tagByName: kTagYes] otherButtonTitles:[[TagManager sharedInstance]tagByName: kTagNo], nil];
            [lAlertView show];
            lAlertView = nil;
            return;
        }
    }
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
        
        CGRect lFrame = cDraggedForReschedulingButton.frame;
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
        cDraggedForReschedulingButton.frame = lFrame;
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        
        
        [self compareWithSelectedButtonAndChangeColorForDraggedButton];
      
        if(CGRectEqualToRect(cOriginalFrame, cDraggedForReschedulingButton.frame))
        {
            // if the event has not moved, then dont do anything.
            cDraggedForReschedulingButton.layer.zPosition = 0;

            return;
        }
            
        if (cDraggedForReschedulingButton) {
            
            AlertMessageHandler *alertHandler = [AlertMessageHandler sharedInstance];
            NSString * buttonLOC = [[TagManager sharedInstance] tagByName:kTagNo];
            
            [alertHandler showCustomMessage:nil withDelegate:self title:[[TagManager sharedInstance] tagByName:kTagEventReschedulePrompt] cancelButtonTitle:[[TagManager sharedInstance] tagByName:kTagYes] andOtherButtonTitles:[[NSArray alloc] initWithObjects:buttonLOC, nil]];


        }
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (cDraggedForReschedulingButton.event.isMultidayEvent || cDraggedForReschedulingButton.event.isAllDay) {
        if (buttonIndex == 0) {
                        
            SMXDayCalendarView *lDayView = (SMXDayCalendarView *)self.superview.superview.superview;
            if (cDraggedForReschedulingButton.event.isMultidayEvent)
                [lDayView addReshudlingWindow:cDraggedForReschedulingButton.event];
            else
                 [lDayView addReshudlingWindow:cDraggedForReschedulingButton.event];
                //[lDayView rescheduleEvent:cDraggedForReschedulingButton.event];
        }else{

        }
        cDraggedForReschedulingButton.layer.zPosition = 0;

        [self compareWithSelectedButtonAndChangeColorForStationaryButtonAfterDragFinished];

    }else{
        if (buttonIndex == 0) {
            
            //TODO: Update the relevant table to update event listing in the DB.
            
            float lDifferenceInPosition = cOriginalFrame.origin.y - cDraggedForReschedulingButton.frame.origin.y ;
            
            int min = fabs (lDifferenceInPosition * 60 / DAYVIEW_HEIGHT_CELL_HOUR);

            if (lDifferenceInPosition > 0)
            {
                [self updateEvent:cDraggedForReschedulingButton.event  fromActivityDate:cDraggedForReschedulingButton.event.ActivityDateDay toActivityDate:cDraggedForReschedulingButton.event.ActivityDateDay  andStartTime:[cDraggedForReschedulingButton.event.dateTimeBegin dateByAddingTimeInterval:-60*min] withEndTime:[cDraggedForReschedulingButton.event.dateTimeEnd dateByAddingTimeInterval:-60*min] fromIndex:cellIndex toIndex:cellIndex];
            }
            else
            {
                [self updateEvent:cDraggedForReschedulingButton.event  fromActivityDate:cDraggedForReschedulingButton.event.ActivityDateDay toActivityDate:cDraggedForReschedulingButton.event.ActivityDateDay andStartTime:[cDraggedForReschedulingButton.event.dateTimeBegin dateByAddingTimeInterval:+60*min] withEndTime:[cDraggedForReschedulingButton.event.dateTimeEnd dateByAddingTimeInterval:+60*min] fromIndex:cellIndex toIndex:cellIndex];
            }
            //[[NSNotificationCenter defaultCenter] postNotificationName:EVENT_DISPLAY_RESET object:nil];
        }
        else
        {
            [UIView animateWithDuration:1.0
                             animations:^{
                                 cDraggedForReschedulingButton.frame = cOriginalFrame;
                                 cDraggedForReschedulingButton.layer.zPosition = 0;

                             }];
            [self compareWithSelectedButtonAndChangeColorForStationaryButtonAfterDragFinished];
        }
    }
}

-(void)updateEvent:(SMXEvent *)event fromActivityDate:(NSDate *)fromActivityDate toActivityDate:(NSDate *) activityDate andStartTime:(NSDate *)startTime withEndTime:(NSDate *)endTim fromIndex:(int)fromIndex toIndex:(int)toIndex{
    
    NSDateComponents *comp = [NSDate componentsOfDate:event.dateTimeBegin];
    fromActivityDate = [NSDate dateWithYear:comp.year month:comp.month day:comp.day];
    
    comp = [NSDate componentsOfDate:startTime];
    activityDate = [NSDate dateWithYear:comp.year month:comp.month day:comp.day];
    
    
    [[SMXDateManager sharedManager] setCollectiondelegate:CollectionViewDelegate];
    [[SMXDateManager sharedManager] updateEvent:event fromActivityDate:fromActivityDate toActivityDate:activityDate andStartTime:startTime withEndTime:endTim cellIndex:fromIndex toIndex:toIndex];
    [CalenderHelper updateEvent:event toActivityDate:activityDate andStartTime:startTime withEndTime:endTim multiDayEvent:[[NSArray alloc] init]];
}

- (void)setCollectionViewDelegate:(id)CollectionViewDelegates{
    CollectionViewDelegate=CollectionViewDelegates;
}

-(CGSize )dynamicHeightOfLabel:(UILabel *)label withWidth:(float)width
{
    CGSize maximumLabelSize = CGSizeMake(width, FLT_MAX);
    
    CGRect expectedLabelRect = [label.text boundingRectWithSize:maximumLabelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@
                                {NSFontAttributeName: label.font} context:nil];
    
    return expectedLabelRect.size;
    
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)cellRefreshedChangeSelectedButtontoHighlight:(SMXEvent *)lEvent
{

    if ([lEvent.localID isEqualToString:[[[SMXDateManager sharedManager] selectedEvent] localID]]) {
        for (SMXBlueButton *lButton in arrayButtonsEvents) {
            if ([lButton.event.localID isEqualToString:lEvent.localID]) {
                
                [protocol showViewDetailsWithEvent:lButton cell:self];

                break;
            }
        }
    }
   
}

-(void)methodForChangeTheSelectedButtonColor:(SMXEvent *)lEvent
{
    for (SMXBlueButton *lButton in arrayButtonsEvents) {
        if ([lButton.event.localID isEqualToString:lEvent.localID]) {
            
            [self changeButtonColorForSelected:lButton];

            break;
        }
    }
}
@end
