//
//  SMXReschedulePopup.m
//  ServiceMaxiPad
//
//  Created by Service Max on 11/02/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "SMXReschedulePopup.h"
#import "NonTagConstant.h"

@implementation SMXReschedulePopup
@synthesize event;
@synthesize cDatePicker;
@synthesize cPopOverView;
@synthesize cEventClashingWithOtherEventLabel;
@synthesize lTempStartDateTime;
@synthesize lTempEndDateTime;
@synthesize cStartDateTimeButton;
@synthesize cEndDateTimeButton;
@synthesize isDatePickerVisible;
@synthesize multiDayCalculation;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}
-(void)setEventInfo:(SMXEvent *)event_loc{
    event = event_loc;
    [self rescheduleEvent:event];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)rescheduleEvent:(SMXEvent *) _event
{
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.3];
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth ;
    
    cPopOverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024/2, 768/2.5)];
    [cPopOverView setBackgroundColor:[UIColor whiteColor]];
    cPopOverView.center = self.center;
    cPopOverView.autoresizingMask = AR_LEFT_BOTTOM_TOP_RIGHT;
    [self addSubview:cPopOverView];
    
    float buttonWidth = 100;
    UILabel *lReschedulePopoverTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cPopOverView.frame.size.width, 45)];
    lReschedulePopoverTitleLabel.text = [[TagManager sharedInstance]tagByName:kTag_SelectDateTime];
    lReschedulePopoverTitleLabel.textAlignment = NSTextAlignmentCenter;
    lReschedulePopoverTitleLabel.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];
    lReschedulePopoverTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
    
    [cPopOverView addSubview:lReschedulePopoverTitleLabel];
    
    UIColor *customLineLightGrayColor = [UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:1.0];
    
    UIView *lHorizontalLine = [[UIView alloc] initWithFrame:CGRectMake(0, lReschedulePopoverTitleLabel.frame.origin.y + lReschedulePopoverTitleLabel.frame.size.height, cPopOverView.frame.size.width, 1.0)];
    lHorizontalLine.backgroundColor = customLineLightGrayColor;
    [cPopOverView addSubview:lHorizontalLine];
    
    UIButton *lCancelbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    lCancelbutton.frame = CGRectMake(0, 0, buttonWidth, 45);
    [lCancelbutton setTitle:[[TagManager sharedInstance]tagByName:kTagCancelButton] forState:UIControlStateNormal];
    [lCancelbutton addTarget:self action:@selector(cancelRescheduling:) forControlEvents:UIControlEventTouchUpInside];
    [lCancelbutton setTitleColor:[UIColor colorWithRed:225.0/255.0 green:80.0/255.0 blue:1.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    
    [cPopOverView addSubview:lCancelbutton];
    
    UIButton *lSaveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    lSaveButton.frame = CGRectMake(cPopOverView.frame.size.width - buttonWidth, 0, buttonWidth, 45);
    [lSaveButton setTitle:[[TagManager sharedInstance]tagByName:kTagSfmActionButtonSave] forState:UIControlStateNormal];
    [lSaveButton setTitleColor:[UIColor colorWithRed:225.0/255.0 green:80.0/255.0 blue:1.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [lSaveButton addTarget:self action:@selector(saveRescheduledInfo:) forControlEvents:UIControlEventTouchUpInside];
    
    lSaveButton.backgroundColor = [UIColor clearColor];
    [cPopOverView addSubview:lSaveButton];
    
    cEventClashingWithOtherEventLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, lHorizontalLine.frame.origin.y + lHorizontalLine.frame.size.height, cPopOverView.frame.size.width, 40)];
    cEventClashingWithOtherEventLabel.backgroundColor = [UIColor yellowColor];
    cEventClashingWithOtherEventLabel.text = [[TagManager sharedInstance]tagByName:kTag_ThisTimeOverlapsAppointment];
    cEventClashingWithOtherEventLabel.textAlignment = NSTextAlignmentCenter;
    
    cEventClashingWithOtherEventLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cEventClashingWithOtherEventLabel.hidden = YES;
    [cPopOverView addSubview:cEventClashingWithOtherEventLabel];
    
    UIColor *customLightGrayColor = [UIColor colorWithRed:121.0/255.0 green:121.0/255.0 blue:121.0/255.0 alpha:1.0];
    
    
    UILabel *lStartTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, cEventClashingWithOtherEventLabel.frame.origin.y + cEventClashingWithOtherEventLabel.frame.size.height, cPopOverView.frame.size.width - 120, 30)];
    lStartTitleLabel.backgroundColor = [UIColor clearColor];
    lStartTitleLabel.text = [[TagManager sharedInstance]tagByName:kTag_start];
    lStartTitleLabel.textColor = customLightGrayColor;
    lStartTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14];
    
    [cPopOverView addSubview:lStartTitleLabel];
    if (_event.isMultidayEvent) {
        lTempStartDateTime = _event.dateTimeBegin_multi;
        lTempEndDateTime = _event.dateTimeEnd_multi;
    }else{
        lTempStartDateTime = _event.dateTimeBegin;
        lTempEndDateTime = _event.dateTimeEnd;
    }
    
    NSString *lDate = [CalenderHelper getStringValueForTheDate:_event.dateTimeBegin_multi];
    UIImage *lImage = [UIImage imageNamed:@"day_triangle-down.png"];
    
    cStartDateTimeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cStartDateTimeButton.frame = CGRectMake(lStartTitleLabel.frame.origin.x, lStartTitleLabel.frame.origin.y + lStartTitleLabel.frame.size.height, cPopOverView.frame.size.width - lStartTitleLabel.frame.origin.x * 2, 40);
    cStartDateTimeButton.tag = START_DATE_BUTTON_TAG;
    [cStartDateTimeButton setTitle:lDate forState:UIControlStateNormal];
    [cStartDateTimeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cStartDateTimeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    cStartDateTimeButton.layer.borderColor = customLineLightGrayColor.CGColor;
    cStartDateTimeButton.layer.borderWidth = 1.0;
    
    [cStartDateTimeButton addTarget:self action:@selector(showDatePicker:) forControlEvents:UIControlEventTouchUpInside];
    [cStartDateTimeButton setImage:lImage forState:UIControlStateNormal];
    
    cStartDateTimeButton.imageEdgeInsets = UIEdgeInsetsMake(0, cStartDateTimeButton.frame.size.width - lImage.size.width - 5, 0, 0);

    [cPopOverView addSubview:cStartDateTimeButton];
    
    // IPAD-4541 - Verifaya
    cStartDateTimeButton.accessibilityLabel = kVEventStartDateTime;
    cEndDateTimeButton.accessibilityLabel = kVEventEndDateTime;
    
    UILabel *lEndTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(lStartTitleLabel.frame.origin.x, cStartDateTimeButton.frame.origin.y + cStartDateTimeButton.frame.size.height + 15, cPopOverView.frame.size.width, 30)];
    
    lEndTitleLabel.backgroundColor = [UIColor clearColor];
    lEndTitleLabel.text = [[TagManager sharedInstance]tagByName:kTag_end];
    lEndTitleLabel.textColor = customLightGrayColor;
    lEndTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14];
    
    [cPopOverView addSubview:lEndTitleLabel];
    
    
    cEndDateTimeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cEndDateTimeButton.frame = CGRectMake(lEndTitleLabel.frame.origin.x, lEndTitleLabel.frame.origin.y + lEndTitleLabel.frame.size.height, cPopOverView.frame.size.width - lEndTitleLabel.frame.origin.x * 2, 40);
    cEndDateTimeButton.tag = END_DATE_BUTTON_TAG;
    
    cEndDateTimeButton.layer.borderColor = customLineLightGrayColor.CGColor;
    cEndDateTimeButton.layer.borderWidth = 1.0;
    
    lDate = [CalenderHelper getStringValueForTheDate:_event.dateTimeEnd_multi];
    
    [cEndDateTimeButton setTitle:lDate forState:UIControlStateNormal];
    [cEndDateTimeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cEndDateTimeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    [cEndDateTimeButton addTarget:self action:@selector(showDatePicker:) forControlEvents:UIControlEventTouchUpInside];
    [cEndDateTimeButton setImage:lImage forState:UIControlStateNormal];
    
    cEndDateTimeButton.imageEdgeInsets = UIEdgeInsetsMake(0, cEndDateTimeButton.frame.size.width - lImage.size.width - 5, 0, 0);
    
    [cPopOverView addSubview:cEndDateTimeButton];
    
    CGRect frame;
    
    frame.origin = CGPointMake(cEndDateTimeButton.frame.origin.x + 10, cEndDateTimeButton.frame.origin.y + cEndDateTimeButton.frame.size.height + 10);
    frame.size = CGSizeZero;
    
    cDatePicker = [[UIDatePicker alloc] initWithFrame:frame];
    [cDatePicker setDatePickerMode:UIDatePickerModeDateAndTime];
    [cDatePicker addTarget:self action:@selector(onDatePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    cDatePicker.hidden = YES;
    [cPopOverView addSubview:cDatePicker];
    
}
-(void)cancelRescheduling:(id)sender{
    [self removeFromSuperview];
}

-(void)saveRescheduledInfo:(id)sender{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateFormatter *lDF = [[NSDateFormatter alloc] init];
    [lDF setDateFormat:@"yyyy-MM-dd"];
    if ([lTempStartDateTime compare:lTempEndDateTime] == NSOrderedSame) {
        UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:@"" message:[[TagManager sharedInstance]tagByName:kTagEventTimeError] delegate:nil cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] otherButtonTitles: nil];
        
        [lAlert show];
        lAlert = nil;
        return;
        
    }
    else if ([lTempStartDateTime compare:lTempEndDateTime] == NSOrderedDescending)
    {
        UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:@"" message:[[TagManager sharedInstance]tagByName:kTagEventTimeError] delegate:nil cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] otherButtonTitles: nil];
        
        [lAlert show];
        lAlert = nil;
        return;
    }
    if (![event.eventTableName isEqualToString:kSVMXTableName] && [[SMXDateManager sharedManager]numberOfDate:lTempStartDateTime endDate:lTempEndDateTime]>14) {
        UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:@"" message:[[TagManager sharedInstance] tagByName:kTagFourteenDaysEventError] delegate:nil cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] otherButtonTitles: nil];
        
        [lAlert show];
        lAlert = nil;
    }else{
        [self updateEvent:event fromActivityDate:event.ActivityDateDay toActivityDate:[lDF dateFromString:[lDF stringFromDate:lTempStartDateTime]] andStartTime:lTempStartDateTime withEndTime:lTempEndDateTime fromIndex:1 toIndex:0];
    
        NSDateComponents *componentsActivitydate = [cal components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:event.ActivityDateDay];
        NSDateComponents *componentsSelectedDay = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:lTempStartDateTime];
        if (!(componentsActivitydate.day == componentsSelectedDay.day && componentsActivitydate.month == componentsSelectedDay.month && componentsActivitydate.year == componentsSelectedDay.year)) {
        
            [self cancelRescheduling:nil];
            [self removeFromSuperview];
        }else{
            [self cancelRescheduling:nil];
        
        }
        lTempStartDateTime = nil;
        lTempEndDateTime = nil;
    }
}
-(void)updateEvent:(SMXEvent *)event_loc fromActivityDate:(NSDate *)fromActivityDate toActivityDate:(NSDate *)activityDate andStartTime:(NSDate *)startTime withEndTime:(NSDate *)endTim fromIndex:(int)fromIndex toIndex:(int)toIndex{
  //  if (!event.isMultidayEvent) {
   //     [[SMXDateManager sharedManager] setCollectiondelegate:self];
  //      [[SMXDateManager sharedManager] updateEvent:event_loc fromActivityDate:fromActivityDate toActivityDate:activityDate andStartTime:startTime withEndTime:endTim cellIndex:fromIndex toIndex:toIndex];
   //     [CalenderHelper updateEvent:event_loc toActivityDate:fromActivityDate andStartTime:startTime withEndTime:endTim multiDayEvent:[[NSArray alloc] init]];
   // }else{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        multiDayCalculation =[[SMXMultiDayCalculation alloc] init];
        [multiDayCalculation updateMultiDayEvent:event_loc fromActivityDate:fromActivityDate toActivityDate:activityDate andStartTime:startTime withEndTime:endTim cellIndex:fromIndex toIndex:toIndex];
        [CalenderHelper updateEvent:event_loc toActivityDate:fromActivityDate andStartTime:startTime withEndTime:endTim multiDayEvent:multiDayCalculation.eventObjects];

        
        
        
    });
          // }
}

-(void) onDatePickerValueChanged:(UIDatePicker *)datePicker
{
    NSString *selectionString = [CalenderHelper getStringValueForTheDate:[datePicker date]];
    if (datePicker.tag == START_DATE_BUTTON_TAG){
        [cStartDateTimeButton setTitle:selectionString forState:UIControlStateNormal];
        lTempStartDateTime = [datePicker date];
    }
    else{
        [cEndDateTimeButton setTitle:selectionString forState:UIControlStateNormal];
        lTempEndDateTime = [datePicker date];
        
    }
    
    //Just for checking before running the loop.
    if ([lTempStartDateTime compare:lTempEndDateTime]==NSOrderedSame || [lTempStartDateTime compare:lTempEndDateTime]==NSOrderedDescending) {
        cEventClashingWithOtherEventLabel.hidden = YES;
        return;
    }
    
    NSDateFormatter *lDF = [[NSDateFormatter alloc] init];
    [lDF setDateFormat:@"yyyy-MM-dd"];
}
-(void)showDatePicker:(id)sender
{
    static int theTag;
    if (!isDatePickerVisible)
    {
        CGRect frame =  cPopOverView.frame;
        frame.size.height += 150;
        cPopOverView.frame = frame;
        
        isDatePickerVisible = YES;
    }
    else
    {
        if (theTag == [sender tag]) {
            CGRect frame =  cPopOverView.frame;
            frame.size.height -= 150;
            cPopOverView.frame = frame;
            cDatePicker.hidden = YES;
            isDatePickerVisible = NO;
            [cStartDateTimeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [cEndDateTimeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self repositionReschedulePopoverView];
            return;
        }
    }
    cDatePicker.tag = [sender tag];
    cDatePicker.hidden = NO;
    
    
    NSDateFormatter *lDF = [[NSDateFormatter alloc] init];
    [lDF setDateFormat:@"EEE MMM d, yyyy hh:mm a"];
    
    NSDate *lDate;
    if ([sender tag] == START_DATE_BUTTON_TAG) {
        theTag = START_DATE_BUTTON_TAG;
        lDate = lTempStartDateTime; //[lDF dateFromString:cStartDateTimeButton.currentTitle];
        [cStartDateTimeButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [cEndDateTimeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }else
    {
        theTag = END_DATE_BUTTON_TAG;
        lDate =  lTempEndDateTime; // [lDF dateFromString:cEndDateTimeButton.currentTitle];
        [cEndDateTimeButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [cStartDateTimeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    cDatePicker.date = lDate;
    [self repositionReschedulePopoverView];
}
-(void)repositionReschedulePopoverView
{
    [UIView animateWithDuration:ANIMATION_SPEED
                     animations:^{
                         cPopOverView.center = self.center;
                     }];
    
}
-(void)dealloc{
    
}
@end
