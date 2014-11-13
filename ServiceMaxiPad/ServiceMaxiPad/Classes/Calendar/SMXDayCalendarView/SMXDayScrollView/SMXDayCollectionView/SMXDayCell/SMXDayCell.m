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



@property (nonatomic, strong) NSMutableDictionary *cAllEventDictionary;
@property (nonatomic, assign) int cCurrentLevel;

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
@synthesize cAllEventDictionary;
@synthesize cCurrentLevel;

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

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSelectedButtonColorAndShowDetailView) name:EVENT_RESCHEDULED_IN_DETAIL_VIEW object:nil];

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
    
    
    int lHour = comp.hour;
    NSString *lAmPm = @"AM";
    
    
    if (lHour>=12) {
        lAmPm = @"PM";
    }
    
    lHour = (lHour>12? lHour - 12 : lHour); //converting to 0-12 hrs standard
    
    [labelRed setText:[NSString stringWithFormat:@"%02d:%02d %@", lHour, comp.minute, lAmPm]];
    
    CGRect lFrame = labelRed.frame;
    lFrame.origin.y = lHourHeight + lMinuteHeight;
    labelRed.frame = lFrame;
    
    BOOL boolIsToday = [NSDate isTheSameDateTheCompA:[NSDate componentsOfCurrentDate] compB:[NSDate componentsOfDate:date]];
    [labelRed setAlpha:boolIsToday];
    
    
    SMXHourAndMinLabel *theLastLineLabel= (SMXHourAndMinLabel *)[self viewWithTag:[[NSString stringWithFormat:@"%d%d", comp.hour, (comp.minute > 30 ? 30 : 0)] intValue]];
    //    [labelWithSameYOfCurrentHour setAlpha:!boolIsToday];  //TODO: if the hour/half-hour line is need to be displayed, set the alpha to 1. or else hide the line near to the current time line by setting alpha as 0.
    
    
    if ((labelRed.frame.origin.y - labelWithSameYOfCurrentHour.frame.origin.y >=20) && boolIsToday) {
        [theLastLineLabel setAlpha:1];
        
    }
    else
    {
        [theLastLineLabel setAlpha:0];
        
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
            labelHourMin.tag = [[NSString stringWithFormat:@"%d%d", hour, min] intValue];
            
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
//    [labelWithSameYOfCurrentHour setAlpha:!boolIsToday];  //TODO: if the hour/half-hour line is need to be displayed, set the alpha to 1. or else hide the line near to the current time line by setting alpha as 0.

    if ((labelRed.frame.origin.y - labelWithSameYOfCurrentHour.frame.origin.y >=20) && boolIsToday) {
        [labelWithSameYOfCurrentHour setAlpha:1];

    }
    else
    {
        [labelWithSameYOfCurrentHour setAlpha:0];
    }
    
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

                //NSLog(@"event.dateTimeBegin : %@", event.dateTimeBegin);
                if (compLabel.hour == compEventBegin.hour && compLabel.minute <= compEventBegin.minute && compEventBegin.minute < compLabel.minute+DAYVIEW_MINUTES_PER_LABEL) {
                    
                    int additonalheight = (compEventBegin.minute > 30 ? compEventBegin.minute - 30 : compEventBegin.minute%30);
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
            
            NSString *eventSubject = (event.cWorkOrderSummaryModel ? (event.cWorkOrderSummaryModel.companyName.length ? event.cWorkOrderSummaryModel.companyName : event.stringCustomerName) : event.stringCustomerName);
            eventSubject = [eventSubject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            _button.eventName.text = eventSubject;
            CGRect frame = _button.eventName.frame;
            frame.size.height = [self dynamicHeightOfLabel:_button.eventName withWidth:_button.eventName.frame.size.width].height;
            if (frame.size.height>39) {
                frame.size.height = 39;
            }
            _button.eventName.frame = frame;

            
            frame = _button.eventAddress.frame;
            frame.origin.y = _button.eventName.frame.origin.y + _button.eventName.frame.size.height;
            _button.eventAddress.frame = frame;
            _button.eventAddress.text = (event.cWorkOrderSummaryModel ? [self getServiceLocation:event]:@"");
            [_button.eventAddress sizeToFit];

            [_button setEvent:event];

            BOOL slaInfo = NO;
            BOOL conflictInfo = NO;
            BOOL priorityInfo = NO;
            
            //========= GETTING SLA & PRIORITY  INFO =========
            
            if ( event.cWorkOrderSummaryModel) {
                slaInfo = event.sla;
                priorityInfo = event.priority;
                
            }

            
            //========= GETTING CONFLICT INFO =========
            if(event.whatId)
            {
                conflictInfo = event.conflict;
            }
            
            int total = conflictInfo + slaInfo + priorityInfo;
            switch (total) {
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
            
            CGRect lEventNameLabelFrame = _button.eventName.frame;
            lEventNameLabelFrame.size.width = lEventNameLabelFrame.size.width - total * _button.firstImageView.frame.size.width;
            _button.eventName.frame = lEventNameLabelFrame;
            
//           cAllEventDictionary = [self compareAndSaveEvents:cAllEventDictionary andButton:_button];
            [self compareAndRepositionEvents:_button withButtonPosition:arrayButtonsEvents.count-1];
            
            UILongPressGestureRecognizer *lLongPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(moveEvent:)];
            
            [_button addGestureRecognizer:lLongPressGesture];
            
            [arrayButtonsEvents addObject:_button];
            [self addSubview:_button];
            
            // if any button inside a cSamePositionAndDurationEvents array is inside cEventInsideALargerEvent, that means all the buttons in the cSamePositionAndDurationEvents have to be concurrent inside a larger event. So all events in cSamePositionAndDurationEvents will be occupy => total_width/2 of space among themselves starting from x = 160;
            
            float lWidth = (self.frame.size.width - EVENT_X_POSITION)/cSamePositionAndDurationEvents.count;

            for ( int i = 0 ; i < cSamePositionAndDurationEvents.count ; i++) {
                
                
                SMXBlueButton *lbutton = [cSamePositionAndDurationEvents objectAtIndex:i];
                CGRect lFirstButtonFrame = lbutton.frame;
                lFirstButtonFrame.size.width = lWidth;
                lFirstButtonFrame.origin.x = EVENT_X_POSITION + i*lWidth;
                lbutton.frame = lFirstButtonFrame;
                
                lFirstButtonFrame = lbutton.eventName.frame;
                lFirstButtonFrame.size.width = lWidth - 10;
                lbutton.eventName.frame = lFirstButtonFrame;
                
                lFirstButtonFrame = lbutton.eventAddress.frame;
                lFirstButtonFrame.size.width = lWidth - 10;
                lbutton.eventAddress.frame = lFirstButtonFrame;
                
                lbutton.firstImageView.hidden = YES;
                lbutton.secondImageView.hidden = YES;
                lbutton.thirdImageView.hidden = YES;
            }
            
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
                lFirstButtonFrame.origin.x += 5;
                lFirstButtonFrame.size.width = lbutton.frame.size.width - 10;
                lFirstButtonFrame.origin.y += 5;
                lFirstButtonFrame.size.height = lbutton.frame.size.height - 10;

                lbutton.eventName.frame = lFirstButtonFrame;
                
                lFirstButtonFrame = lbutton.eventAddress.frame;
                lFirstButtonFrame.size.width = lWidth - 10;
                lbutton.eventAddress.frame = lFirstButtonFrame;
                
                lFirstButtonFrame = lbutton.borderView.frame;
                lFirstButtonFrame.origin.x += 5;
                lbutton.borderView.frame = lFirstButtonFrame;

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

                lbutton.firstImageView.hidden = YES;
                lbutton.secondImageView.hidden = YES;
                lbutton.thirdImageView.hidden = YES;
            }
            
            [cSamePositionAndDurationEvents removeAllObjects];
            [cEventInsideALargerEvent removeAllObjects];
            
            
            if (_button.frame.size.height < _button.eventName.frame.size.height + _button.eventAddress.frame.size.height) {
                _button.eventAddress.hidden = YES;
            }
        }
    }
    
    NSLog(@"cAllEventDictionary:%@", cAllEventDictionary);
}


-(void)displayTheEventsForConcurrentEvents:(NSArray *)concurrentEvents
{
    float lWidth = (self.frame.size.width - EVENT_X_POSITION)/cCurrentLevel/concurrentEvents.count;
    
    
    for ( int i = 0 ; i < concurrentEvents.count ; i++) {
        
        SMXBlueButton *lbutton = [concurrentEvents objectAtIndex:i];
        CGRect lFirstButtonFrame = lbutton.frame;
        lFirstButtonFrame.size.width = lWidth;
      
        lFirstButtonFrame.origin.x = (self.frame.size.width - EVENT_X_POSITION)/cCurrentLevel + i*lWidth;

        lbutton.frame = lFirstButtonFrame;
        
        lFirstButtonFrame = lbutton.eventName.frame;
        lFirstButtonFrame.size.width = lWidth - 10;
        lbutton.eventName.frame = lFirstButtonFrame;
        
        lFirstButtonFrame = lbutton.eventAddress.frame;
        lFirstButtonFrame.size.width = lWidth - 10;
        lbutton.eventAddress.frame = lFirstButtonFrame;
        
        lbutton.firstImageView.hidden = YES;
        lbutton.secondImageView.hidden = YES;
        lbutton.thirdImageView.hidden = YES;
    }

}


-(void)displayTheSmallerEvents:(NSArray *)smallerEventArray
{
    float lWidth = (self.frame.size.width - EVENT_X_POSITION)/cCurrentLevel;

    for (int i = 0; i < smallerEventArray.count; i++) {
        
        SMXBlueButton *lbutton = [smallerEventArray objectAtIndex:i];
        
        CGRect lFirstButtonFrame = lbutton.frame;
        lFirstButtonFrame.size.width = lWidth;
        
        lFirstButtonFrame.origin.x = (self.frame.size.width - EVENT_X_POSITION)/cCurrentLevel + i*lWidth;

        
        lbutton.frame = lFirstButtonFrame;
        
        
        lFirstButtonFrame = lbutton.eventName.frame;
        lFirstButtonFrame.origin.x += 5;
        lFirstButtonFrame.size.width = lbutton.frame.size.width - 10;
        lFirstButtonFrame.origin.y += 5;
        lFirstButtonFrame.size.height = lbutton.frame.size.height - 10;
        
        lbutton.eventName.frame = lFirstButtonFrame;
        
        lFirstButtonFrame = lbutton.eventAddress.frame;
        lFirstButtonFrame.size.width = lWidth - 10;
        lbutton.eventAddress.frame = lFirstButtonFrame;
        
        lFirstButtonFrame = lbutton.borderView.frame;
        lFirstButtonFrame.origin.x += 5;
        lbutton.borderView.frame = lFirstButtonFrame;
        
        
        
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
        
        lbutton.firstImageView.hidden = YES;
        lbutton.secondImageView.hidden = YES;
        lbutton.thirdImageView.hidden = YES;
    }

}

-(void)displayTheEventsForOtherEvents:(NSDictionary *)eventDictionary
{
    long theDuration = [[eventDictionary objectForKey:kEventDurationLong] longValue];
    
    if (theDuration==24*60*60) {
        eventDictionary = [eventDictionary objectForKey:kSmallerEventsDictionary];
    }
    
}

-(void)displayTheEventsForSmallerEvents:(NSDictionary *)smallerEventDictionary
{
    cCurrentLevel++;
    [self displayTheEventsForConcurrentEvents:[smallerEventDictionary objectForKey:kEventsArray]];
    [self displayTheEventsForOtherEvents:[smallerEventDictionary objectForKey:kOtherEventsDictionary]];
    [self displayTheEventsForSmallerEvents:[smallerEventDictionary objectForKey:kSmallerEventsDictionary]];
    cCurrentLevel--;

}


-(NSMutableDictionary *)compareAndSaveEvents:(NSMutableDictionary *)eventDictionary andButton:(SMXBlueButton *)theButton
{
    //TODO: Work on this. The Dictionary striucture is in the note book.
    
    NSDate *lStartTime = [eventDictionary objectForKey:kEventStartTimeDate];
    long duration = [[eventDictionary objectForKey:kEventDurationLong] longValue];
    NSDate *lEndTime = [lStartTime dateByAddingTimeInterval:duration];
    SMXEvent *event = theButton.event;
    
    NSDate *lStartDateTime = event.dateTimeBegin;
    NSDate *lEndDateTime = event.dateTimeEnd;
    
    NSTimeInterval differenceInSeconds = [lEndDateTime timeIntervalSinceDate: lStartDateTime];

    if ([lStartDateTime compare:lStartTime] == NSOrderedSame && duration == differenceInSeconds) {
        NSMutableArray *lConcurrentArray = [[NSMutableArray alloc]initWithArray:[eventDictionary objectForKey:kEventsArray]];
        [lConcurrentArray addObject:theButton];
        [eventDictionary setObject:lConcurrentArray forKey:kEventsArray];
        [eventDictionary setObject:event.dateTimeBegin forKey:@"event"];
        
    }
    else if (([lStartTime compare:lStartDateTime] == NSOrderedAscending || [lStartTime compare:lStartDateTime] == NSOrderedSame)&& ([lEndDateTime compare:lEndTime] == NSOrderedAscending || [lEndDateTime compare:lEndTime] == NSOrderedSame)) {
        
        NSMutableDictionary *lSmallerEventsDictionary = [[NSMutableDictionary alloc] initWithDictionary:[eventDictionary objectForKey:kSmallerEventsDictionary]];
        if (lSmallerEventsDictionary.count==0) {

            [lSmallerEventsDictionary setObject:lStartDateTime forKey:kEventStartTimeDate];
            [lSmallerEventsDictionary setObject:[NSNumber numberWithLong:differenceInSeconds] forKey:kEventDurationLong];
            [lSmallerEventsDictionary setObject:@[theButton] forKey:kEventsArray];
            [lSmallerEventsDictionary setObject:event.dateTimeBegin forKey:@"event"];

            [eventDictionary setObject:lSmallerEventsDictionary forKey:kSmallerEventsDictionary];
            
        }
        else
        {
           lSmallerEventsDictionary = [self compareAndSaveEvents:lSmallerEventsDictionary andButton:theButton];
            [eventDictionary setObject:lSmallerEventsDictionary forKey:kSmallerEventsDictionary];
            
        }

    }
    else
    {
        
        NSMutableDictionary *lOtherEventsDictionary = [[NSMutableDictionary alloc] initWithDictionary:[eventDictionary objectForKey:kOtherEventsDictionary]];
        if (lOtherEventsDictionary.count==0) {
            
            [lOtherEventsDictionary setObject:lStartDateTime forKey:kEventStartTimeDate];
            [lOtherEventsDictionary setObject:[NSNumber numberWithLong:differenceInSeconds] forKey:kEventDurationLong];
            [lOtherEventsDictionary setObject:@[theButton] forKey:kEventsArray];
            [lOtherEventsDictionary setObject:event.dateTimeBegin forKey:@"event"];

            [eventDictionary setObject:lOtherEventsDictionary forKey:kOtherEventsDictionary];
            
        }
        else
        {
            lOtherEventsDictionary = [self compareAndSaveEvents:lOtherEventsDictionary andButton:theButton];
            [eventDictionary setObject:lOtherEventsDictionary forKey:kOtherEventsDictionary];
            
            
        }

    }
    
    return eventDictionary;
}




-(void)compareAndRepositionEvents: (SMXBlueButton *)_button withButtonPosition:(int)buttonIndex
{
    
    
    if (arrayButtonsEvents.count <= buttonIndex || buttonIndex < 0) {
        return;
    }
    
    SMXBlueButton *lOldButton = [arrayButtonsEvents objectAtIndex:buttonIndex];

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
                    
                   
                    
                        [cEventsWhichAccomodateSmallerEvents setObject:lOldButton forKey:_button.event.localID];
                    }
                }
            }
            else
            {
                // _button is inside the lAddedButton
                
                
                if(![cEventInsideALargerEvent containsObject:_button])
                {
                    [cEventInsideALargerEvent addObject:_button];
                    
                [cEventsWhichAccomodateSmallerEvents setObject:lOldButton forKey:_button.event.localID];
                
                }
            }
        }
    else
    {
        // The case wherein the previous button is inside a larger event
        
        NSArray *lAllValues = [cEventsWhichAccomodateSmallerEvents allValues];
        for (SMXBlueButton *lTempButton in lAllValues) {
            if ((lTempButton.frame.origin.y + lTempButton.frame.size.height) >= (_button.frame.origin.y + _button.frame.size.height))
            {
                [cEventInsideALargerEvent addObject:_button];
                break;
            }
        }
        
        
        /*
         
         Present working code.
         
        SMXBlueButton *lTempButton = [cEventsWhichAccomodateSmallerEvents objectForKey:lOldButton.event.localID];
        
        if ((lTempButton.frame.origin.y + lTempButton.frame.size.height) >= (_button.frame.origin.y + _button.frame.size.height))
        {
            [cEventInsideALargerEvent addObject:_button];
        }
         
         */
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

            if(![subview isEqual:pNotification.object])
            {
                lbutton.eventName.textColor = [UIColor blackColor];
                lbutton.eventAddress.textColor = [UIColor grayColor];
                [lbutton setBackgroundColor:[UIColor colorWithRed:228.0/255. green:228.0/255. blue:228.0/255. alpha:1.0]];
                lbutton.borderView.backgroundColor = [UIColor colorWithRed:121.0/255.0 green:121.0/255.0 blue:121.0/255.0 alpha:1.0];
            }
            
            
            else
            {
                if (protocol != nil && [protocol respondsToSelector:@selector(showViewDetailsWithEvent:cell:)]) {
                    
                    cSelectedEventButton = lbutton;
                    [self changeSelectedButtonColorAndShowDetailView];
                }
            }
        }
    }
}


-(void)changeSelectedButtonColorAndShowDetailView
{
    cSelectedEventButton.backgroundColor = [UIColor colorWithRed:67.0/255.0 green:67.0/255.0 blue:67.0/255.0 alpha:1.0];
    cSelectedEventButton.borderView.backgroundColor=[UIColor colorWithRed:67.0/255.0 green:67.0/255.0 blue:67.0/255.0 alpha:1.0];
    cSelectedEventButton.eventName.textColor = [UIColor whiteColor];
    cSelectedEventButton.eventAddress.textColor = [UIColor whiteColor];
    
    
    [protocol showViewDetailsWithEvent:cSelectedEventButton.event cell:self];
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
            
            AlertMessageHandler *alertHandler = [AlertMessageHandler sharedInstance];
            NSString * buttonLOC = [[TagManager sharedInstance] tagByName:kTagNo];
            
            [alertHandler showCustomMessage:nil withDelegate:self title:[[TagManager sharedInstance] tagByName:kTagEventReschedulePrompt] cancelButtonTitle:[[TagManager sharedInstance] tagByName:kTagYes] andOtherButtonTitles:[[NSArray alloc] initWithObjects:buttonLOC, nil]];


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


-(NSString *)getServiceLocation:(SMXEvent *)event
{
    CalenderHelper *helper = [[CalenderHelper alloc] init];
    ServiceLocationModel *model = [helper getTransactionModel:event.whatId];
    NSString *cityAndState;
    
    if ([model.city length]) {
        cityAndState = [NSString stringWithFormat:@"%@", model.city];
    }
    
    if ([model.state length]) {
        if ([cityAndState length]) {
            cityAndState = [NSString stringWithFormat:@"%@, %@", cityAndState, model.state];

        }
        else
        {
            cityAndState = [NSString stringWithFormat:@"%@", model.state];

        }
    }
    
    return cityAndState;
}

-(CGSize )dynamicHeightOfLabel:(UILabel *)label withWidth:(float)width
{
    CGSize maximumLabelSize = CGSizeMake(width, FLT_MAX);
    
    CGRect expectedLabelRect = [label.text boundingRectWithSize:maximumLabelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@
                                {NSFontAttributeName: label.font} context:nil];
    
    return expectedLabelRect.size;
    
}

@end
