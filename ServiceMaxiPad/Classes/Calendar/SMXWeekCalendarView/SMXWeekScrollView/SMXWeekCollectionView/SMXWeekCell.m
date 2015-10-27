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
#import "SFMPageViewManager.h"
#import "AlertMessageHandler.h"
#import "TagManager.h"
#import "CalenderHelper.h"
#import "TransactionObjectModel.h"
#import "SMXDateManager.h"
#import "SMXCalendarViewController.h"
#import "CaseObjectModel.h"

#define WEEKVIEW_HEIGHT_CELL_HOUR 70.
#define EVENT_X_POSITION 0.

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
@property (nonatomic, assign)  CGFloat zPositionCell;
@property (nonatomic, strong) NSMutableArray *eventList;
@property (nonatomic, strong) NSMutableArray *cSamePositionAndDurationEvents;
@property (nonatomic, strong) NSMutableArray *cEventInsideALargerEvent;
@property (nonatomic, strong) NSMutableDictionary *cEventsWhichAccomodateSmallerEvents;
@property (nonatomic, strong) UIView *celBottombaar;
//@property (nonatomic, assign)CGFloat xMargine;


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
@synthesize cSamePositionAndDurationEvents;
@synthesize cEventInsideALargerEvent;
@synthesize cEventsWhichAccomodateSmallerEvents;
@synthesize celBottombaar;
@synthesize zPositionCell;
@synthesize CollectionViewDelegate;
@synthesize cellIndex;
@synthesize weekCalendarDelegate;
@synthesize paintedHeight;
//@synthesize xMargine;
static UIImage *lineImage;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    //lineImage=[[UIImage alloc] initWithContentsOfFile:@"dotted_line"];
    if (!lineImage) {
        //lineImage=[UIImage imageNamed:@"dotted_line.png"];
    }
    
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
-(void)grayBottomLine:(CGRect )rect{
    if (!celBottombaar) {
        celBottombaar=[[UIImageView alloc] initWithFrame:rect];
        celBottombaar.backgroundColor=[UIColor colorWithHexString:@"D7D7D7"];
        [self addSubview:celBottombaar];
    }else{
        celBottombaar.frame=rect;
    }
    //return celBottombaar;
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
            if (min == 0)
            {
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width+1, 1.)];//cell line separeter
               // [view.layer setBorderColor:[[UIColor colorWithPatternImage:lineImage] CGColor]];
                [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
                view.backgroundColor=[UIColor colorWithHexString:@"D7D7D7"];
                [labelHourMin setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
                [labelHourMin addSubview:view];
                [self addSubview:labelHourMin];

            }
            
            [arrayLabelsHourAndMin addObject:labelHourMin];

            y += HEIGHT_CELL_MIN;
        }
    }
    [self grayBottomLine:CGRectMake(0,y,self.frame.size.width+1,1)];
}

/*-(UIView *)graydashLine:(CGRect )rect{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width+1, 1.)];//cell line separeter
    [view.layer setBorderWidth:5.0];
   // [view.layer setBorderColor:[[UIColor colorWithPatternImage:lineImage] CGColor]];
    [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    view.backgroundColor=[UIColor redColor];;
    return view;
}*/
- (void)clean {
    
     [arrayButtonsEvents removeAllObjects];
    
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[SMXBlueButton class]]) {
            [subview removeFromSuperview];
        }
    }
    [self grayBottomLine:CGRectMake(0,celBottombaar.frame.origin.y,self.frame.size.width+1,1)];
}

- (void)addButtonsWithArray:(NSArray *)array {
    eventList =[[NSMutableArray alloc] init];
    if (array) {
        [self initializeArray];
        
//        NSSortDescriptor *eventStartDateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateTimeBegin" ascending:YES];
//        NSSortDescriptor *eventDurationSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"duration" ascending:NO];
//        
//        NSArray *arrayEvents = [array sortedArrayUsingDescriptors:[NSArray arrayWithObjects:eventStartDateSortDescriptor, eventDurationSortDescriptor, nil]];
//        
        
        NSArray *arrayEvents = array;
        
        for (SMXEvent *event in arrayEvents) {
            
            CGFloat yTimeBegin=0.;
            CGFloat yTimeEnd=0.;
            float lHeight = 0.;
            NSDateComponents *compEventBegin = [NSDate componentsOfDate:event.dateTimeBegin];
            NSDateComponents *compEventEnd = [NSDate componentsOfDate:event.dateTimeEnd];
            
            for (SMXHourAndMinLabel *label in arrayLabelsHourAndMin) {
                NSDateComponents *compLabel = [NSDate componentsOfDate:label.dateHourAndMin];

                
                if (compLabel.hour == compEventBegin.hour && compLabel.minute <= compEventBegin.minute && compEventBegin.minute < compLabel.minute+MINUTES_PER_LABEL) {
                    
                    /*This change for event time problem*/
                    long additonalheight = (compEventBegin.minute > 30 ? compEventBegin.minute-30 : compEventBegin.minute%30);
                    yTimeBegin = label.frame.origin.y+ additonalheight * WEEKVIEW_HEIGHT_CELL_HOUR/60;
                }
                if (compLabel.hour == compEventEnd.hour && compLabel.minute <= compEventEnd.minute && compEventEnd.minute < compLabel.minute+MINUTES_PER_LABEL) {
                    yTimeEnd = label.frame.origin.y;
                    float lHourHeight = (compEventEnd.hour - compEventBegin.hour) * WEEKVIEW_HEIGHT_CELL_HOUR;
                    float lMinuteHeight =  (float)((compEventEnd.minute - compEventBegin.minute)/60.0) * WEEKVIEW_HEIGHT_CELL_HOUR;
                    
                    lHeight =  lHourHeight + lMinuteHeight;
                }
            }
            SMXBlueButton *_button = [[SMXBlueButton alloc] initWithFrame:CGRectMake(0, yTimeBegin, self.frame.size.width-EVENT_SPACE_FROM_CELL_RIGHT, lHeight)];
            _button.exclusiveTouch=YES;
            _button.eventIndex=event.eventIndex;
            _button._IsWeekEvent=TRUE;
            _button.event=event;
            [_button setTheEventTitleForNormalState];
            
            CGRect frame = _button.eventName.frame;
            
            
            BOOL isPriority = NO;
            
            if(event.whatId && event.newData)
            {
                if (event.isWorkOrder) {
                    WorkOrderSummaryModel *model = [[SMXCalendarViewController sharedInstance].cWODetailsDict objectForKey:event.whatId];
                    isPriority = [model.priority boolValue];
                    
                }
                else if (event.isCaseEvent) {
                    CaseObjectModel *model = [[SMXCalendarViewController sharedInstance].cWODetailsDict objectForKey:event.whatId];
                    isPriority = model.priority;
                }
                
            }
            else
            {
                isPriority = event.priority;
            }
            
            if(isPriority)
            {
                _button.thirdImageView.image = [UIImage imageNamed:@"priority_Flag.png"];
                CGRect iconRect=_button.thirdImageView.frame;
                iconRect.origin.y=iconRect.origin.y-5;
                
                if (lHeight<iconRect.size.height) {
                    iconRect.size.height = lHeight;
                }
                
                
                _button.thirdImageView.frame=iconRect;
                frame.size.width=frame.size.width-20.;
                
                frame.size.width -= _button.thirdImageView.frame.size.width - 5;
                _button.eventName.frame = frame;
            }
            
            /*
            NSString *eventSubject = nil;
            if (event.isWorkOrder) {
                WorkOrderSummaryModel *model = [[SMXCalendarViewController sharedInstance].cWODetailsDict objectForKey:event.whatId];
                
                eventSubject = (model.companyName.length ? model.companyName : event.stringCustomerName);
            }
            else{
                eventSubject = event.stringCustomerName;
                
            }
            
            
            eventSubject = [eventSubject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            _button.eventName.text = eventSubject;
            frame.size.height = [self dynamicHeightOfLabel:_button.eventName withWidth:_button.eventName.frame.size.width].height;
            if (frame.size.height > 39) {
                frame.size.height = 39;  //For 2 lines.
            }
            
            if (frame.size.height > lHeight) {
                frame.size.height = lHeight;
            }
            _button.eventName.frame = frame;
            
            frame = _button.eventAddress.frame;
            frame.origin.y = _button.eventName.frame.origin.y + _button.eventName.frame.size.height;
            _button.eventAddress.frame = frame;
            _button.eventAddress.text = (event.isWorkOrder ? [CalenderHelper getServiceLocation:event.whatId]:@"");
            [_button.eventAddress sizeToFit];
            
            if (_button.eventName.frame.size.height + _button.eventAddress.frame.size.height > lHeight) {
                _button.eventAddress.hidden = YES;
            }
            
            */

            
            [self compareAndRepositionEvents:_button withButtonPosition:arrayButtonsEvents.count-1];

            UILongPressGestureRecognizer *lLongPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(moveEvent:)];
            [_button addGestureRecognizer:lLongPressGesture];
            [arrayButtonsEvents addObject:_button];
            _button.cuncurrentIndex=0;
            [self addSubview:_button];
            
            
//            float lWidth = (self.frame.size.width - EVENT_X_POSITION)/cSamePositionAndDurationEvents.count;

            long samePositionEventCount = (cSamePositionAndDurationEvents.count>3?3:cSamePositionAndDurationEvents.count);

            
            double lWidth = (self.frame.size.width - EVENT_X_POSITION)/samePositionEventCount;
            
            if (arrayButtonsEvents.count >1 && cSamePositionAndDurationEvents.count !=0) {
                SMXBlueButton *lbutton = [arrayButtonsEvents objectAtIndex:arrayButtonsEvents.count-2];
                
                //                if (lbutton.frame.size.width != (self.frame.size.width - EVENT_X_POSITION)) {
                if ([lbutton doesHaveBorder]) {
                    
                    lWidth = (self.frame.size.width - EVENT_X_POSITION)/2/samePositionEventCount;
                }
            }
            
            for ( int i = 0 ; i < cSamePositionAndDurationEvents.count ; i++) {
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
                
                /*
                lbutton.frame = lFirstButtonFrame;
                
                CGRect topBorderFrame = lbutton.cTopBorder.frame;
                topBorderFrame.size.width = lFirstButtonFrame.size.width;
                lbutton.cTopBorder.frame = topBorderFrame;

                
                lFirstButtonFrame = lbutton.eventName.frame;
                lFirstButtonFrame.size.width = lWidth - 5;
                lbutton.eventName.frame = lFirstButtonFrame;
                
                
                lFirstButtonFrame = lbutton.eventAddress.frame;
                lFirstButtonFrame.size.width = lWidth - 5;
                lbutton.eventAddress.frame = lFirstButtonFrame;
                
                lbutton.firstImageView.hidden = YES;
                lbutton.secondImageView.hidden = YES;
                lbutton.thirdImageView.hidden = YES;
                 */
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
                [lbutton setThreeSideLayerForSmallerEvent];

                /*
                CGRect topBorderFrame = lbutton.cTopBorder.frame;
                topBorderFrame.size.width = lFirstButtonFrame.size.width;
                lbutton.cTopBorder.frame = topBorderFrame;

                
                lFirstButtonFrame = lbutton.eventName.frame;
                lFirstButtonFrame.origin.x += 5;
                lFirstButtonFrame.size.width = lbutton.frame.size.width - 10;
                lbutton.eventName.frame = lFirstButtonFrame;
                
                lFirstButtonFrame = lbutton.eventAddress.frame;
                lFirstButtonFrame.size.width = lWidth - 5;
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
                 */
                
            }
            
            [cEventInsideALargerEvent removeAllObjects];
           // [self addEventOverCell:_button];
        }
    }
    
    [cEventsWhichAccomodateSmallerEvents removeAllObjects];
    
    for (SMXBlueButton *lButton in arrayButtonsEvents) {
        [lButton setEventSubjectLabelPosition];
        
    }
}

-(void)initializeArray{
    if (!cSamePositionAndDurationEvents) {
        cSamePositionAndDurationEvents = [[NSMutableArray alloc] init];
    }
    
    if (!cEventInsideALargerEvent) {
        cEventInsideALargerEvent = [[NSMutableArray alloc] init];
    }
    
    if (!cEventsWhichAccomodateSmallerEvents) {
        cEventsWhichAccomodateSmallerEvents = [[NSMutableDictionary alloc] init];
    }
}

-(void)compareAndRepositionEvents: (SMXBlueButton *)_button withButtonPosition:(long)buttonIndex{
    
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
        }
        else
        {
            
        }
    }
    if (paintedHeight<(_button.frame.origin.y +_button.frame.size.height)) {
        paintedHeight = (_button.frame.origin.y +_button.frame.size.height);
    }
//    if (arrayButtonsEvents.count <= buttonIndex || buttonIndex < 0) {
//        return;
//    }
//    
//    SMXBlueButton *lOldButton = [arrayButtonsEvents objectAtIndex:buttonIndex];
////    CGRect lOldButtonFrame = lOldButton.frame;
////    CGRect lButtonFrame = _button.frame;
//    
//    //changing from float/double to long as the comparision was giving issues with the 3rd & 4th position decimal numbers.
//
//    long oldbuttonHeight = (lOldButton.frame.origin.y + lOldButton.frame.size.height);
//    long newButtonHeight = (_button.frame.origin.y + _button.frame.size.height);
//    
//    if (oldbuttonHeight >= newButtonHeight)
//    {
//        if (lOldButton.frame.origin.y == _button.frame.origin.y)
//        {
//            if (lOldButton.frame.size.height == _button.frame.size.height)
//            {
//                if(![cEventInsideALargerEvent containsObject:_button])
//                {
//                    if (![cSamePositionAndDurationEvents containsObject:_button])
//                    {
//                        [cSamePositionAndDurationEvents addObject:_button];
//                    }
//                    [cSamePositionAndDurationEvents addObject:lOldButton];
//                }
//                else
//                {
//                    [cEventInsideALargerEvent addObject:lOldButton];
//                }
//                
//                [self compareAndRepositionEvents:lOldButton withButtonPosition:buttonIndex-1];
//            }
//            else
//            {
//                // Both events same starting time.
//
//                if(![cEventInsideALargerEvent containsObject:_button])
//                {
//                    [cEventInsideALargerEvent addObject:_button];
//                    [cEventsWhichAccomodateSmallerEvents setObject:lOldButton forKey:_button.event.localID];
//                }
//            }
//        }
//        else
//        {
//            if(![cEventInsideALargerEvent containsObject:_button])
//            {
//                [cEventInsideALargerEvent addObject:_button];
//                [cEventsWhichAccomodateSmallerEvents setObject:lOldButton forKey:_button.event.localID];
//            }
//        }
//    }
//    else
//    {
//        NSArray *lAllValues = [cEventsWhichAccomodateSmallerEvents allValues];
//        for (SMXBlueButton *lTempButton in lAllValues) {
//            if ((lTempButton.frame.origin.y + lTempButton.frame.size.height) >= (_button.frame.origin.y + _button.frame.size.height))
//            {
//                [cEventInsideALargerEvent addObject:_button];
//                break;
//            }
//        }
//
//    }
    
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

//old logic for concurrent event rendring
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
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        cSelectedEventButton = (SMXBlueButton *)[gesture view];
        zPositionOfSelectedView=[cSelectedEventButton superview].layer.zPosition;
        [self bringSubviewToFront:[cSelectedEventButton superview]];
        zPositionCell=cSelectedEventButton.layer.zPosition;
        cOriginalFrame = gesture.view.frame;
        
        cDifferenceInY = loc.y - cOriginalFrame.origin.y;
        cDifferenceInX = loc.x -cOriginalFrame.origin.x;
//        cSelectedEventButton.eventName.textColor = [UIColor whiteColor];
//        cSelectedEventButton.eventAddress.textColor = [UIColor whiteColor];
//        [cSelectedEventButton setBackgroundColor:[UIColor colorWithRed:255.0/255. green:102.0/255. blue:51.0/255. alpha:1.0]];
        [cSelectedEventButton setTheButtonForDraggingState];
        
        if (cSelectedEventButton.event.isMultidayEvent || cSelectedEventButton.event.isAllDay) {
            UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Message" message:[[TagManager sharedInstance]tagByName: kTagDragAndDropNotAllowedMessage] delegate:self cancelButtonTitle:[[TagManager sharedInstance]tagByName: kTagYes] otherButtonTitles:[[TagManager sharedInstance]tagByName: kTagNo], nil];
            [lAlertView show];
            lAlertView = nil;
            return;
        }
    }
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
        [cSelectedEventButton superview].layer.zPosition=199298.0f;
        cSelectedEventButton.layer.zPosition=1988.0f;
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
        
        [cSelectedEventButton setTheButtonForNormalState];

        cSelectedEventButton.eventName.textColor = [UIColor colorWithRed:67.0/255.0 green:67.0/255.0 blue:67.0/255.0 alpha:1.0];
//        cSelectedEventButton.eventAddress.textColor = [UIColor grayColor];
//        [cSelectedEventButton setBackgroundColor:[UIColor colorWithRed:228.0/255. green:228.0/255. blue:228.0/255. alpha:1.0]];
       // [cSelectedEventButton superview].layer.zPosition=zPositionOfSelectedView;
        
        if(CGRectEqualToRect(cOriginalFrame, cSelectedEventButton.frame))
        {
            // if the event has to moved, then dont do anything.
            return;
        }
        
        if (cSelectedEventButton) {
            
            UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:[[TagManager sharedInstance] tagByName:kTagEventReschedulePrompt] message:nil delegate:self cancelButtonTitle:[[TagManager sharedInstance]tagByName: kTagYes] otherButtonTitles:[[TagManager sharedInstance]tagByName: kTagNo], nil];
            [lAlertView show];
            lAlertView = nil;
        }else{
            
        }
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (cSelectedEventButton.event.isMultidayEvent || cSelectedEventButton.event.isAllDay) {
        if (buttonIndex == 0) {
           
            [weekCalendarDelegate addReshudlingWindow:cSelectedEventButton.event];
        }else{
            
        }
        [cSelectedEventButton setTheButtonForNormalState];
//        cSelectedEventButton.eventName.textColor = [UIColor colorWithRed:67.0/255.0 green:67.0/255.0 blue:67.0/255.0 alpha:1.0];
//        cSelectedEventButton.eventAddress.textColor = [UIColor grayColor];
//        [cSelectedEventButton setBackgroundColor:[UIColor colorWithRed:228.0/255. green:228.0/255. blue:228.0/255. alpha:1.0]];
    }else{
        if (buttonIndex == 0) {
            
            //TODO: Update the relevant table to update event listing in the DB.
            
            float lDifferenceInPosition = cOriginalFrame.origin.y - cSelectedEventButton.frame.origin.y ;
            int min = fabs (lDifferenceInPosition * 60 / HEIGHT_CELL_HOUR);
            [cSelectedEventButton.event explainMe];

            int numberOfDayChange=[self numberOfDayCahnged];
            if (lDifferenceInPosition > 0)
            {
                 [self updateEvent:cSelectedEventButton.event fromActivityDate:cSelectedEventButton.event.ActivityDateDay  toActivityDate:[self newEventActivityDate:cSelectedEventButton.event.ActivityDateDay numberOfDay:numberOfDayChange] andStartTime:[self newEventActivityDate:[cSelectedEventButton.event.dateTimeBegin dateByAddingTimeInterval:-60*min] numberOfDay:numberOfDayChange] withEndTime:[self newEventActivityDate:[cSelectedEventButton.event.dateTimeEnd dateByAddingTimeInterval:-60*min] numberOfDay:numberOfDayChange] fromIndex:cellIndex toIndex:cellIndex+numberOfDayChange];
            }
            else
            {
                [self updateEvent:cSelectedEventButton.event fromActivityDate:cSelectedEventButton.event.ActivityDateDay toActivityDate:[self newEventActivityDate:cSelectedEventButton.event.ActivityDateDay numberOfDay:numberOfDayChange] andStartTime: [self newEventActivityDate:[cSelectedEventButton.event.dateTimeBegin dateByAddingTimeInterval:+60*min] numberOfDay:numberOfDayChange] withEndTime:[self newEventActivityDate:[cSelectedEventButton.event.dateTimeEnd dateByAddingTimeInterval:+60*min] numberOfDay:numberOfDayChange] fromIndex:cellIndex toIndex:cellIndex+numberOfDayChange];
                
            }
            
            /* commenting this line for local change, here we are refreshing with local date*/
            //[[NSNotificationCenter defaultCenter] postNotificationName:EVENT_DISPLAY_RESET object:nil];
            [cSelectedEventButton superview].layer.zPosition=zPositionOfSelectedView;
            cSelectedEventButton.layer.zPosition=zPositionCell;
        }
        else
        {
            [UIView animateWithDuration:0.50
                                  delay:0.0
                                options: UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 cSelectedEventButton.eventName.textColor = [UIColor colorWithRed:67.0/255.0 green:67.0/255.0 blue:67.0/255.0 alpha:1.0];
                                 cSelectedEventButton.eventAddress.textColor = [UIColor grayColor];
                                 [cSelectedEventButton setBackgroundColor:[UIColor colorWithRed:228.0/255. green:228.0/255. blue:228.0/255. alpha:1.0]];
                                 cSelectedEventButton.frame = cOriginalFrame;
                             }
                             completion:^(BOOL finished){
                                 [cSelectedEventButton superview].layer.zPosition=zPositionOfSelectedView;
                                 cSelectedEventButton.layer.zPosition=zPositionCell;
                             }];
        }
    }
}
-(int)numberOfDayCahnged{
    //this change for rescheduling cuncurrent event, calculation was wrong for that, now its fixed
    int XMargine=cSelectedEventButton.frame.origin.x;//-cOriginalFrame.origin.x;
    int i=(XMargine/self.frame.size.width);
    if (XMargine<0) {
        i=i-1;
    }else{
    }
    return i;
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

//This function responsible for changing date from existing date to new date
-(NSDate *)newEventActivityDate:(NSDate *)CurrentDate numberOfDay:(int )numberOfDayChange{
    NSDate *sevenDaysAgo = [CurrentDate dateByAddingTimeInterval:numberOfDayChange*24*60*60];
    return sevenDaysAgo;
}
//-(NSDate *)startDateChange:(NSData *)currentDate{
//    
//}
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


-(CGSize )dynamicHeightOfLabel:(UILabel *)label withWidth:(float)width
{
    CGSize maximumLabelSize = CGSizeMake(width, FLT_MAX);
    
    CGRect expectedLabelRect = [label.text boundingRectWithSize:maximumLabelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@
                                {NSFontAttributeName: label.font} context:nil];
    
    return expectedLabelRect.size;
    
}
- (void)setCollectionViewDelegate:(id)CollectionViewDelegate1{
    CollectionViewDelegate=CollectionViewDelegate1;
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
