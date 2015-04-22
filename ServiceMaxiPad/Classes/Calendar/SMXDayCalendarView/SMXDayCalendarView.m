//
//  SMXDayCalendarView.m
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


#import "SMXDayCalendarView.h"
#import "SMXCalendarViewController.h"
#import "SMXDayHeaderCollectionView.h"
#import "CaseObjectModel.h"

#import "SMXImportantFilesForCalendar.h"
#import "SMXConstants.h"
#import "SMXLable.h"
#import "CalendarMonthViewController.h"
#import "CalendarPopupContent.h"
#import "StyleManager.h"
#import "CalenderHelper.h"
#import "TagManager.h"
#import "NonTagConstant.h"
#import "SMXBlueButton.h"
#import "SMXCurrentDayButton.h"
#import <QuartzCore/QuartzCore.h>
#import "SMXCalendarViewController.h"
#import "CalenderHelper.h"

#define ANIMATION_SPEED 0.25
#define START_DATE_BUTTON_TAG 1001
#define END_DATE_BUTTON_TAG 1002

@interface SMXDayCalendarView () <SMXDayCellProtocol, SMXEventDetailViewProtocol, SMXDayHeaderCollectionViewProtocol, SMXDayCollectionViewProtocol, UIGestureRecognizerDelegate>
@property (nonatomic, strong) SMXDayHeaderCollectionView *collectionViewHeaderDay;
@property (nonatomic, strong) UILabel *cNoEventSelectedLabel;
@property (nonatomic) BOOL boolAnimate;
@property (nonatomic) BOOL cBoolOrientationChange;
@property (nonatomic) BOOL isLeftPanelVisible;
@property (nonatomic, strong) UIButton *cMonthButton;

@property (nonatomic, strong) UIView *cBGView;
@property (nonatomic, strong) UIView *cPopOverView;
@property (nonatomic, strong) UIButton *cStartDateTimeButton;
@property (nonatomic, strong) UIButton *cEndDateTimeButton;
@property (nonatomic, strong) UIDatePicker *cDatePicker;
@property (nonatomic) BOOL isDatePickerVisible;
@property (nonatomic,strong) CalendarMonthViewController *monthCalender;
@property (nonatomic,strong) UIButton *grayCalenderBkView;
@property (nonatomic, strong) SMXEvent *lTempEvent;
@property (nonatomic, strong) UILabel *cEventClashingWithOtherEventLabel;
@property (nonatomic,strong)SMXCurrentDayButton *CurrentDayButton;
@property (nonatomic, strong) NSDate *lTempStartDateTime;
@property (nonatomic, strong) NSDate *lTempEndDateTime;

@end


@implementation SMXDayCalendarView

#pragma mark - Synthesize

@synthesize dictEvents;
@synthesize collectionViewHeaderDay;
@synthesize dayContainerScroll;
@synthesize viewDetail;
@synthesize cNoEventSelectedLabel;
@synthesize protocol;
@synthesize boolAnimate;
@synthesize cBoolOrientationChange;
@synthesize isLeftPanelVisible;
@synthesize cMonthButton;
@synthesize monthCalender;
@synthesize cBGView;
@synthesize cPopOverView;
@synthesize cDatePicker;
@synthesize cStartDateTimeButton;
@synthesize cEndDateTimeButton;
@synthesize isDatePickerVisible;
@synthesize grayCalenderBkView;
@synthesize lTempEvent;
@synthesize cEventClashingWithOtherEventLabel;
@synthesize  CurrentDayButton;
@synthesize lTempStartDateTime;
@synthesize lTempEndDateTime;
@synthesize sMXReschedulePopup;
@synthesize multiDayCalculation;

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dateChanged:) name:DATE_MANAGER_DATE_CHANGED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeCalender) name:CALENDER_DAY_VIEW_REMOVE object:nil];
        
        [self setBackgroundColor:[UIColor whiteColor]];
        boolAnimate = NO;
        
        [self setAutoresizingMask: AR_WIDTH_HEIGHT];
    
    }
    
    return self;
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)setDictEvents:(NSMutableDictionary *)_dictEvents {
    
    dictEvents = _dictEvents;
    
    float gap = 0;
    if (!dayContainerScroll) {
        
        cMonthButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cMonthButton.frame = CGRectMake(0.0, 0.0, 320.0, 40.0);
        [cMonthButton addTarget:self action:@selector(changeMonth:) forControlEvents:UIControlEventTouchUpInside];
        cMonthButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0];
        [cMonthButton setImage:[UIImage imageNamed:@"day_triangle-down.png"] forState:UIControlStateNormal];
        cMonthButton.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];
        [self addSubview:cMonthButton];
        
        collectionViewHeaderDay = [[SMXDayHeaderCollectionView alloc] initWithFrame:CGRectMake(0., cMonthButton.frame.origin.y + cMonthButton.frame.size.height + gap, 320, HEADER_HEIGHT_SCROLL)];//anish
        [collectionViewHeaderDay setProtocol:self];
        [collectionViewHeaderDay scrollToDate:[[SMXDateManager sharedManager] currentDate]];
        [self addSubview:collectionViewHeaderDay];

        dayContainerScroll = [[SMXDayScrollView alloc] initWithFrame:CGRectMake(0, collectionViewHeaderDay.frame.origin.y + collectionViewHeaderDay.frame.size.height + gap, collectionViewHeaderDay.frame.size.width, self.frame.size.height-collectionViewHeaderDay.frame.size.height - cMonthButton.frame.size.height - gap)];//anish
        
        [self addSubview:dayContainerScroll];
        dayContainerScroll.backgroundColor = [UIColor whiteColor];
        
        cNoEventSelectedLabel = [[UILabel alloc] initWithFrame:CGRectMake(320, 0, self.frame.size.width - dayContainerScroll.frame.size.width, self.frame.size.height)];
        cNoEventSelectedLabel.text = [[TagManager sharedInstance]tagByName:kTag_PleaseSelectAppointment];
        cNoEventSelectedLabel.numberOfLines = 0;
        cNoEventSelectedLabel.font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:16.0];
        cNoEventSelectedLabel.textColor = [UIColor colorWithRed:121.0/255.0 green:121.0/255.0 blue:121.0/255.0 alpha:1.0];
        cNoEventSelectedLabel.backgroundColor = [UIColor clearColor];
        cNoEventSelectedLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:cNoEventSelectedLabel];

    }
    [dayContainerScroll setDictEvents:dictEvents];
    [dayContainerScroll.collectionViewDay setProtocol:self];
    
    [self checkOrientationAndReset];
    [self setMonthAndYear];
        
}

-(void)changeMonth:(id)sender
{
    /* UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Implementation Pending" delegate:nil cancelButtonTitle:@"NO" otherButtonTitles: nil];
     [lAlert show];
     lAlert = nil;*/
    
    [self dayCalendarPopup];
    
}



-(void)dayCalendarPopup{
    if (grayCalenderBkView==nil) {
        
        [CalendarPopupContent setColor:[UIColor colorWithHexString:@"F2F2F2"]];
        [CalendarPopupContent setdayPopup:TRUE];
        [CalendarPopupContent setWidth:100];
        [CalendarPopupContent setHight:100];
        [CalendarPopupContent setCalendarTopBarHeight:100];
        [CalendarPopupContent setTileWidth:45.0f];
        [CalendarPopupContent setTileHeightAdjustment:28.0f];
        [CalendarPopupContent setCalendarViewHeight:366.0f];
        [CalendarPopupContent setCalendarTopBarHeight:100.0f];
        [CalendarPopupContent setNotificationKey:CALENDER_DAY_VIEW_REMOVE];
        
        monthCalender=[[CalendarMonthViewController alloc] initWithSunday:YES];
        monthCalender.view.frame=CGRectMake(0, -366, 322, 416);
        monthCalender.view.backgroundColor=[UIColor colorWithHexString:@"F2F2F2"];
        [self calenderButton];
        [self currentDayButtonCall:monthCalender.view];
        [grayCalenderBkView addSubview:monthCalender.view];
        monthCalender.view.layer.shadowOpacity=0.50f;
        monthCalender.view.layer.shadowColor=[UIColor grayColor].CGColor;
        monthCalender.view.layer.masksToBounds = NO;
        monthCalender.view.layer.cornerRadius = 00.f;
        monthCalender.view.layer.shadowOffset = CGSizeMake(1.0f,7.5f);
        monthCalender.view.layer.shadowRadius = 1.5f;
        [monthCalender.view addSubview:[self grayLine:CGRectMake(15, 80, 300, 1)]];
        [monthCalender.view addSubview:[self grayLine:CGRectMake(15, 366, 300, 1)]];
        [UIView animateWithDuration:ANIMATION_SPEED

                         animations:^{
                             monthCalender.view.frame=CGRectMake(0, 0, 322, 416);
                         }
                         completion:nil];
    }else{
        [monthCalender.view removeFromSuperview];
        monthCalender=nil;
        [grayCalenderBkView removeFromSuperview];
        grayCalenderBkView=nil;
    }
}
-(void)currentDayButtonCall:(UIView *)parent{
    CurrentDayButton = [[SMXCurrentDayButton alloc] initWithFrame:CGRectMake(0., 0., 120., 30.)];
    [CurrentDayButton initialsetup:parent];
    [CurrentDayButton setDelegate:self];
    [parent addSubview:CurrentDayButton];
}

-(UIImageView *)grayLine:(CGRect)rect{
    UIImageView *grayLine=[[UIImageView alloc] initWithFrame:rect];
    grayLine.backgroundColor=[UIColor colorWithHexString:@"D7D7D7"];
    return grayLine;
}
-(void)calenderButton{
    grayCalenderBkView = [UIButton buttonWithType:UIButtonTypeCustom];
    grayCalenderBkView.frame = CGRectMake(0,0, self.frame.size.width,self.frame.size.height-0);
    [grayCalenderBkView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [grayCalenderBkView addTarget:self action:@selector(hideCalender:) forControlEvents:UIControlEventTouchUpInside];
    grayCalenderBkView.backgroundColor=[UIColor clearColor];
    [self addSubview:grayCalenderBkView];
}
-(void)hideCalender:(id)sender{
    [monthCalender.view removeFromSuperview];
    monthCalender=nil;
    [grayCalenderBkView removeFromSuperview];
    grayCalenderBkView=nil;
}
#pragma mark - Invalidate Layout

- (void)invalidateLayout {
    
    cBoolOrientationChange = YES;
    
    
    [collectionViewHeaderDay.collectionViewLayout invalidateLayout];
    [dayContainerScroll.collectionViewDay.collectionViewLayout invalidateLayout];
    
    if (viewDetail) {
        
        [self showViewDetailsWithEvent:nil cell:nil];
    }
    [self checkOrientationAndReset];
    
}

#pragma mark - SMXDateManager Notification


- (void)dateChanged:(NSNotification *)not {
    
    
    //    [dayContainerScroll.collectionViewDay reloadData];  // when the oriematation changes this was making the entire collection reload which was resetting the BG and text colors. Hence commented. Have to checked the consequences...
    
    if (!cBoolOrientationChange) {
        // No need to change the detail view for orientation change
        [self removeEditAndDetailViews];
        
    }
    
    [dayContainerScroll.collectionViewDay scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:[NSDate componentsOfDate:[[SMXDateManager sharedManager] currentDate]].day-1+7 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:boolAnimate];
    
    boolAnimate = NO;
    
    [self updateHeader];
    
    if ([NSDate isTheSameDateTheCompA:[NSDate componentsOfCurrentDate] compB:[NSDate componentsOfDate:[[SMXDateManager sharedManager] currentDate]]]) {
        [dayContainerScroll scrollRectToVisible:CGRectMake(0, dayContainerScroll.labelWithActualHour.frame.origin.y, dayContainerScroll.frame.size.width, dayContainerScroll.frame.size.height) animated:YES];
    }
}

#pragma mark - SMXDayCollectionView Protocol

- (void)updateHeader {
    if (collectionViewHeaderDay!=nil) {
        [collectionViewHeaderDay reloadData];
        [collectionViewHeaderDay scrollToDate:[[SMXDateManager sharedManager] currentDate]];
    }
    [self setMonthAndYear];
}

-(void)setMonthAndYear
{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [cal components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[[SMXDateManager sharedManager] currentDate]];
    NSInteger month = [components month];
    NSInteger year = [components year];
    
//    NSDateFormatter *df = [[NSDateFormatter alloc] init];
//    NSString *monthName = [[df monthSymbols] objectAtIndex:(month-1)];
    NSString *monthName = [CalenderHelper getTagValueForMonth:month-1];

    UIColor *monthColor = [UIColor colorWithRed:225.0/255.0 green:80.0/255.0 blue:1.0/255.0 alpha:1.0];
    UIColor *yearColor = [UIColor colorWithRed:225.0/255.0 green:80.0/255.0 blue:1.0/255.0 alpha:1.0];
    UIFont *monthFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0f];
    UIFont *yearFont = [UIFont fontWithName:@"HelveticaNeue-UltraLight"  size:18.0f];
    NSDictionary *monthDict = @{NSForegroundColorAttributeName:monthColor,
                                NSFontAttributeName:monthFont};
    NSDictionary *yearDict = @{NSForegroundColorAttributeName:yearColor,
                               NSFontAttributeName:yearFont};
    
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] init];
    [attString appendAttributedString:[[NSAttributedString alloc] initWithString:monthName    attributes:monthDict]];
    [attString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %ld",(long)year] attributes:yearDict]];
    [cMonthButton setAttributedTitle:attString forState:UIControlStateNormal];
    
    cMonthButton.titleEdgeInsets = UIEdgeInsetsMake(0, -cMonthButton.imageView.frame.size.width, 0, cMonthButton.imageView.frame.size.width);
    cMonthButton.imageEdgeInsets = UIEdgeInsetsMake(0, cMonthButton.titleLabel.frame.size.width, 0, -cMonthButton.titleLabel.frame.size.width);
    
}

#pragma mark - SMXDayHeaderCollectionView Protocol

- (void)daySelected:(NSDate *)date {
    
    boolAnimate = YES;
}

-(void)removeEditAndDetailViews
{
    [viewDetail removeFromSuperview];
    viewDetail = nil;
    
}

#pragma mark - SMXDayCell Protocol

- (void)showViewDetailsWithEvent:(SMXBlueButton *)_button cell:(UICollectionViewCell *)cell {
    
    [self removeEditAndDetailViews];
  
    BOOL showDetail = NO;

    if (_button!=nil) {
        lTempEvent = _button.event;
        showDetail = YES;
    }
    else
    {
        NSDateComponents *comp = [NSDate componentsOfDate:lTempEvent.dateTimeBegin];
        NSDate *newDate = [NSDate dateWithYear:comp.year month:comp.month day:comp.day];
        NSMutableArray *array = [dictEvents objectForKey:newDate];
        
        for (SMXEvent *event in array) {
            if ([event.localID isEqualToString:lTempEvent.localID]) {
                lTempEvent = event;
                showDetail = YES;

                break;
            }
        }
    }

    if (showDetail) {
        [self setUpDetailView];
    }
    
}


-(void)setUpDetailView
{
    viewDetail = [[SMXEventDetailView alloc] initWithFrame:CGRectMake(dayContainerScroll.frame.origin.x + dayContainerScroll.frame.size.width , 0, self.frame.size.width - dayContainerScroll.frame.size.width, self.frame.size.height) event:lTempEvent];
    //    [viewDetail setAutoresizingMask:AR_WIDTH_HEIGHT | UIViewAutoresizingFlexibleLeftMargin];
    [viewDetail setProtocol:self];
    viewDetail.backgroundColor = [UIColor whiteColor];
    [self addSubview:viewDetail];
    [self checkOrientationAndReset];
}

#pragma mark - SMXEventDetailView Protocol

- (void)showEditViewWithEvent:(SMXEvent *)_event {
    /*Here we are removing notification "EVENT_CLICKED_WEEK"*/
   // [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_CLICKED_WEEK object:_event];
    [[SMXCalendarViewController sharedInstance] eventSelectedShare:_event userInfor:nil];
}

-(void)rescheduleEvent:(SMXEvent *) _event{
    [self addReshudlingWindow:_event];
}

/*-(void)rescheduleEvent:(SMXEvent *) _event
{
    if (cBGView) {
        return;
    }
    lTempEvent = _event;
    cBGView = [[UIView alloc] initWithFrame:self.frame];
    cBGView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.3];
    cBGView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth ;
    cBGView.layer.zPosition = 2.0;
    [self addSubview:cBGView];
    
    cPopOverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024/2, 768/2.5)];
    [cPopOverView setBackgroundColor:[UIColor whiteColor]];
    cPopOverView.center = cBGView.center;
    
    cPopOverView.autoresizingMask = AR_LEFT_BOTTOM_TOP_RIGHT;
    
    [cBGView addSubview:cPopOverView];
    
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
    //    lCancelbutton.autoresizingMask = AR_LEFT_BOTTOM_TOP_RIGHT;
    
    [cPopOverView addSubview:lCancelbutton];
    
    UIButton *lSaveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    lSaveButton.frame = CGRectMake(cPopOverView.frame.size.width - buttonWidth, 0, buttonWidth, 45);
    [lSaveButton setTitle:[[TagManager sharedInstance]tagByName:kTagSfmActionButtonSave] forState:UIControlStateNormal];
    [lSaveButton setTitleColor:[UIColor colorWithRed:225.0/255.0 green:80.0/255.0 blue:1.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [lSaveButton addTarget:self action:@selector(saveRescheduledInfo:) forControlEvents:UIControlEventTouchUpInside];
    //    lSaveButton.autoresizingMask = AR_LEFT_BOTTOM_TOP_RIGHT;
    
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
 
    
    lTempStartDateTime = _event.dateTimeBegin_multi;
    lTempEndDateTime = _event.dateTimeEnd_multi;
    
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
    
    //    cStartDateTimeButton.titleEdgeInsets = UIEdgeInsetsMake(0, -cStartDateTimeButton.imageView.frame.size.width, 0, cStartDateTimeButton.imageView.frame.size.width);
    cStartDateTimeButton.imageEdgeInsets = UIEdgeInsetsMake(0, cStartDateTimeButton.frame.size.width - lImage.size.width - 5, 0, 0);
    
    
    [cPopOverView addSubview:cStartDateTimeButton];
    
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
//    lDate = [lDF stringFromDate:[NSDate combineDate:_event.ActivityDateDay withTime:_event.dateTimeEnd] ];
//    lDate = [lDF stringFromDate:_event.dateTimeEnd];

    lDate = [CalenderHelper getStringValueForTheDate:_event.dateTimeEnd_multi];

    [cEndDateTimeButton setTitle:lDate forState:UIControlStateNormal];
    [cEndDateTimeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cEndDateTimeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    [cEndDateTimeButton addTarget:self action:@selector(showDatePicker:) forControlEvents:UIControlEventTouchUpInside];
    [cEndDateTimeButton setImage:lImage forState:UIControlStateNormal];
    
    //    cEndDateTimeButton.titleEdgeInsets = UIEdgeInsetsMake(0, -cEndDateTimeButton.imageView.frame.size.width, 0, cEndDateTimeButton.imageView.frame.size.width);
    
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
    
}*/


-(void)cancelRescheduling:(id)sender
{
    isDatePickerVisible = NO;
    [cPopOverView removeFromSuperview];
    cPopOverView = nil;
    [cBGView removeFromSuperview];
    cBGView = nil;
}

-(void)saveRescheduledInfo:(id)sender
{
    
    
//    NSDateFormatter *lDF = [[NSDateFormatter alloc] init];
//    [lDF setDateFormat:@"EEE MMM d, yyyy hh:mm a"];
    
//    NSDate *lStartDate = [lDF dateFromString:cStartDateTimeButton.currentTitle];
//    NSDate *lEndDate = [lDF dateFromString:cEndDateTimeButton.currentTitle];
    
//    [lDF setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
//    NSDate *lStartDateTime = [lDF dateFromString:[lDF stringFromDate:lStartDate]];
//    NSDate *lEndDateTime = [lDF dateFromString:[lDF stringFromDate:lEndDate]];

    
    /* Start supporting multiday event---so this part was blocking that in earlier version */
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

   /* {
        // TODO: Temp Code. Multi-day event not supported.

        NSDateComponents *Startcomponents = [cal components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                             fromDate:lTempStartDateTime];
        NSDate *TempstartDate = [cal dateFromComponents:Startcomponents];
        
        NSDateComponents *Endcomponents = [cal components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                           fromDate:lTempEndDateTime];
        NSDate *TempEndDate = [cal dateFromComponents:Endcomponents];
        
        if ([TempstartDate compare:TempEndDate] != NSOrderedSame) {
            UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"Currently Multi-day event is not allowed." delegate:nil cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] otherButtonTitles: nil];
            [lAlert show];
            lAlert = nil;
            return;
        }
    }*/
    
    NSDateFormatter *lDF = [[NSDateFormatter alloc] init];
    [lDF setDateFormat:@"yyyy-MM-dd"];
    /*
    Test casees:
     1) Start date cannot be later than end date.
     2) End Date cannot be before start date.
     3) Start date cannot be equal to the end date.
     4) duration of event has to be atleast 1 min.
     */
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
//    NSDate *oldActivityDate = lTempEvent.ActivityDateDay;
    
    //[CalenderHelper updateEvent:lTempEvent toActivityDate:[lDF dateFromString:[lDF stringFromDate:lStartDateTime]] andStartTime:lStartDateTime withEndTime:lEndDateTime];
    if (![lTempEvent.eventTableName isEqualToString:kSVMXTableName] && [[SMXDateManager sharedManager] numberOfDate:lTempStartDateTime endDate:lTempEndDateTime]>14) {
        UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:@"" message:[[TagManager sharedInstance] tagByName:kTagFourteenDaysEventError] delegate:nil cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] otherButtonTitles: nil];
        
        [lAlert show];
        lAlert = nil;
    }else{
        [self updateEvent:lTempEvent fromActivityDate:lTempEvent.ActivityDateDay toActivityDate:[lDF dateFromString:[lDF stringFromDate:lTempStartDateTime]] andStartTime:lTempStartDateTime withEndTime:lTempEndDateTime fromIndex:1 toIndex:0];
        
        NSDateComponents *componentsActivitydate = [cal components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:lTempEvent.ActivityDateDay];
        NSDateComponents *componentsSelectedDay = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:lTempStartDateTime];
        if (!(componentsActivitydate.day == componentsSelectedDay.day && componentsActivitydate.month == componentsSelectedDay.month && componentsActivitydate.year == componentsSelectedDay.year)) {
            
            [self cancelRescheduling:nil];
            [viewDetail removeFromSuperview];
            viewDetail = nil;
        }else
        {
            [self cancelRescheduling:nil];

        }
        
        //Releasing the Temp DateHolders.
        
        lTempStartDateTime = nil;
        lTempEndDateTime = nil;
    }
    
    /*This function is responsible for fetching data from local DB and render it*/
    //[[NSNotificationCenter defaultCenter] postNotificationName:EVENT_DISPLAY_RESET object:nil];
}

-(void)updateEvent:(SMXEvent *)event fromActivityDate:(NSDate *)fromActivityDate toActivityDate:(NSDate *)activityDate andStartTime:(NSDate *)startTime withEndTime:(NSDate *)endTim fromIndex:(int)fromIndex toIndex:(int)toIndex{
    multiDayCalculation =[[SMXMultiDayCalculation alloc] init];
    [multiDayCalculation updateMultiDayEvent:event fromActivityDate:fromActivityDate toActivityDate:activityDate andStartTime:startTime withEndTime:endTim cellIndex:fromIndex toIndex:toIndex];
    [CalenderHelper updateEvent:event toActivityDate:fromActivityDate andStartTime:startTime withEndTime:endTim multiDayEvent:multiDayCalculation.eventObjects];
}
-(void)refreshCell:(int )fromCell Tocell:(int )toCell forEvent:(SMXEvent *)event{
    [dayContainerScroll.collectionViewDay reloadData];
    [self refreshDetailView];
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
    //    [lDF setDateStyle:NSDateFormatterFullStyle];
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

-(void) onDatePickerValueChanged:(UIDatePicker *)datePicker
{
    
//    NSDateFormatter *lDF = [[NSDateFormatter alloc] init];
//    [lDF setDateFormat:@"EEE MMM d, yyyy hh:mm a"];
    
//    NSString *selectionString = [[NSString alloc]  initWithFormat:@"%@", [lDF stringFromDate:[datePicker date]]];
    NSString *selectionString = [CalenderHelper getStringValueForTheDate:[datePicker date]];

//    NSDate *lStartTimeDate = [lDF dateFromString:cStartDateTimeButton.currentTitle];
//    NSDate *lEndTimeDate = [lDF dateFromString:cEndDateTimeButton.currentTitle];
//    
    
    if (datePicker.tag == START_DATE_BUTTON_TAG)
    {
        [cStartDateTimeButton setTitle:selectionString forState:UIControlStateNormal];
        lTempStartDateTime = [datePicker date];
    }
    else
    {
        [cEndDateTimeButton setTitle:selectionString forState:UIControlStateNormal];
        lTempEndDateTime = [datePicker date];

    }
    
//    NSLog(@"lTempStartDateTime:%@", lTempStartDateTime);
//    NSLog(@"lTempEndDateTime:%@", lTempEndDateTime);
    //Changed Start & End Time
//    lStartTimeDate = [lDF dateFromString:cStartDateTimeButton.currentTitle];
//    lEndTimeDate = [lDF dateFromString:cEndDateTimeButton.currentTitle];
    
    
    //Just for checking before running the loop.
    if ([lTempStartDateTime compare:lTempEndDateTime]==NSOrderedSame || [lTempStartDateTime compare:lTempEndDateTime]==NSOrderedDescending) {
        cEventClashingWithOtherEventLabel.hidden = YES;
        return;
    }
    
    NSDateFormatter *lDF = [[NSDateFormatter alloc] init];
    [lDF setDateFormat:@"yyyy-MM-dd"];

    NSArray *eventArray = [dictEvents objectForKey: [lDF dateFromString:[lDF stringFromDate:lTempStartDateTime]]];
    
    if (eventArray.count) {
        for (SMXEvent *event in eventArray) {
            
            if (event == lTempEvent) {
                continue;
            }


            
//            NSDate *eventStartTime = [NSDate combineDate:event.ActivityDateDay withTime:event.dateTimeBegin];
//            NSDate *eventEndTime = [NSDate combineDate:event.ActivityDateDay withTime:event.dateTimeEnd];
            
//            NSLog(@"event.dateTimeBegin: %@", event.dateTimeBegin);
//            NSLog(@"event.dateTimeEnd: %@", event.dateTimeEnd);
            
//            NSLog(@"eventStartTime: %@", eventStartTime);
//            NSLog(@"eventEndTime: %@", eventEndTime);
            
//            if (([eventStartTime compare:lTempStartDateTime] == NSOrderedAscending || [eventStartTime compare:lTempStartDateTime] == NSOrderedSame)&& ([lTempEndDateTime compare:eventEndTime] == NSOrderedAscending || [lTempEndDateTime compare:eventEndTime] == NSOrderedSame)) {
            if (([event.dateTimeBegin_multi compare:lTempStartDateTime] == NSOrderedAscending || [event.dateTimeBegin_multi compare:lTempStartDateTime] == NSOrderedSame)&& ([lTempEndDateTime compare:event.dateTimeEnd_multi] == NSOrderedAscending || [lTempEndDateTime compare:event.dateTimeEnd_multi] == NSOrderedSame)) {
 
                cEventClashingWithOtherEventLabel.hidden = NO;
                break;
            }
            else{
                cEventClashingWithOtherEventLabel.hidden = YES;
            }
        }
    }else
    {
        cEventClashingWithOtherEventLabel.hidden = YES;
    }
}

#pragma mark - SMXEditEventView Protocol

- (void)saveEvent:(SMXEvent *)_event {
    
    NSMutableArray *arrayEvents = [dictEvents objectForKey:_event.ActivityDateDay];
    
    if (!arrayEvents) {
        arrayEvents = [NSMutableArray new];
        [dictEvents setObject:arrayEvents forKey:_event.ActivityDateDay];
    }
    
    [arrayEvents addObject:_event];
}

- (void)deleteEvent:(SMXEvent *)_event {
    
    NSMutableArray *arrayEvents = [dictEvents objectForKey:_event.ActivityDateDay];
    [arrayEvents removeObject:_event];
    if (arrayEvents.count == 0) {
        [dictEvents removeObjectForKey:_event.ActivityDateDay];
    }
    
    if (protocol != nil && [protocol respondsToSelector:@selector(setNewDictionary:)]) {
        [protocol setNewDictionary:dictEvents];
    } else {
        [dayContainerScroll.collectionViewDay reloadData];
    }
}

- (void)removeThisView:(UIView *)view {
    
    [view removeFromSuperview];
    view = nil;
}


/*
 
 MethodName - checkOrientationAndReset
 Arguments - n/a
 Description - everytime the orientation changes, this method will reset the Day view.
 
 */

-(void)checkOrientationAndReset
{
    UIInterfaceOrientation lInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    CGRect applicationBounds = [[UIScreen mainScreen] applicationFrame];
    if (lInterfaceOrientation == UIInterfaceOrientationPortrait || lInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        isLeftPanelVisible = NO;
        if (cBoolOrientationChange) {
            
            [UIView animateWithDuration:ANIMATION_SPEED
                             animations:^{
                                 
                                 
                                 CGRect frame = collectionViewHeaderDay.frame;
                                 frame.origin.x -= collectionViewHeaderDay.frame.size.width;
                                 collectionViewHeaderDay.frame = frame;
                                 
                                 
                                 frame = cMonthButton.frame;
                                 frame.origin.x -= cMonthButton.frame.size.width;
                                 cMonthButton.frame = frame;
                                 
                                 
                                 frame = dayContainerScroll.frame;
                                 frame.origin.x -= dayContainerScroll.frame.size.width;
                                 frame.size.height = (applicationBounds.size.height > applicationBounds.size.width ? applicationBounds.size.height : applicationBounds.size.width) - gNavBarHeight - collectionViewHeaderDay.frame.size.height;
                                 
                                 dayContainerScroll.frame = frame;
                                 
                                 frame = viewDetail.frame;
                                 frame.size.width = self.frame.size.width;
                                 frame.size.height = self.frame.size.height;
                                 frame.origin.x = 0;
                                 viewDetail.frame = frame;
                                 
                             }];
        }
        else
        {
            
            CGRect frame = collectionViewHeaderDay.frame;
            frame.origin.x -= collectionViewHeaderDay.frame.size.width;
            collectionViewHeaderDay.frame = frame;
            
            
            frame = cMonthButton.frame;
            frame.origin.x -= cMonthButton.frame.size.width;
            cMonthButton.frame = frame;
            
            frame = dayContainerScroll.frame;
            frame.origin.x -= dayContainerScroll.frame.size.width;
            frame.size.height = (applicationBounds.size.height > applicationBounds.size.width ? applicationBounds.size.height : applicationBounds.size.width) - gNavBarHeight - collectionViewHeaderDay.frame.size.height;
            dayContainerScroll.frame = frame;
            
            
            frame = viewDetail.frame;
            frame.size.width = self.frame.size.width;
            frame.size.height = self.frame.size.height;
            frame.origin.x = 0;
            viewDetail.frame = frame;

        }
        
        CGRect frame = self.frame;
        cNoEventSelectedLabel.frame = frame;
        
    }
    else
    {
        // Landscape
        
        isLeftPanelVisible = YES;
        
        if (cBoolOrientationChange) {
            
            [UIView animateWithDuration:ANIMATION_SPEED
                             animations:^{
                                 
                                 CGRect frame = collectionViewHeaderDay.frame;
                                 frame.origin.x = 0 ;
                                 collectionViewHeaderDay.frame = frame;
                                 
                                 frame = cMonthButton.frame;
                                 frame.origin.x = 0;
                                 cMonthButton.frame = frame;
                                 
                                 
                                 frame = dayContainerScroll.frame;
                                 frame.origin.x = 0;
                                 frame.size.height = (applicationBounds.size.height > applicationBounds.size.width ? applicationBounds.size.width : applicationBounds.size.height) - gNavBarHeight - collectionViewHeaderDay.frame.size.height;
                                 
                                 dayContainerScroll.frame = frame;
                                 
                                 
                                 frame = CGRectMake(dayContainerScroll.frame.origin.x + dayContainerScroll.frame.size.width , 0, self.frame.size.width - dayContainerScroll.frame.size.width, self.frame.size.height);
                                 viewDetail.frame = frame;
                             }];
        }
        else
        {
            CGRect frame = collectionViewHeaderDay.frame;
            frame.origin.x = 0 ;
            collectionViewHeaderDay.frame = frame;
            
            frame = cMonthButton.frame;
            frame.origin.x = 0;
            cMonthButton.frame = frame;
            
            frame = dayContainerScroll.frame;
            frame.origin.x = 0;
            frame.size.height = (applicationBounds.size.height > applicationBounds.size.width ? applicationBounds.size.width : applicationBounds.size.height) - gNavBarHeight - collectionViewHeaderDay.frame.size.height;
            
            dayContainerScroll.frame = frame;
            
            frame = CGRectMake(dayContainerScroll.frame.origin.x + dayContainerScroll.frame.size.width, 0, self.frame.size.width - dayContainerScroll.frame.size.width, self.frame.size.height);
            viewDetail.frame = frame;
            
        }
        
        float selfWidth = self.frame.size.width;
        float selfHeight = self.frame.size.height;
        
        if (selfHeight>selfWidth) {  // When app is first launched, the app is still under transition to lanscape and will return protrait values. Hence to correct this issue ==>
            selfWidth = self.frame.size.height;
            selfHeight = self.frame.size.width;
        }
        
        CGRect frame = cNoEventSelectedLabel.frame;
        frame.origin.x = dayContainerScroll.frame.origin.x + dayContainerScroll.frame.size.width;
        frame.origin.y = 0.0;
        frame.size.width = selfWidth - dayContainerScroll.frame.size.width;
        frame.size.height = selfHeight;
        cNoEventSelectedLabel.frame = frame;
        
        
    }
    
    if (cBGView) {
        [self repositionReschedulePopoverView];
        [self bringSubviewToFront:cBGView];
    }
    
    if (cBoolOrientationChange)
    {
        cBoolOrientationChange = NO;
    }

    [collectionViewHeaderDay scrollToDate:[[SMXDateManager sharedManager] currentDate]];

}

- (void)showLeftPanel;
{
    if (isLeftPanelVisible) {
        [UIView animateWithDuration:ANIMATION_SPEED
                         animations:^{
                             CGRect frame = collectionViewHeaderDay.frame;
                             frame.origin.x -= collectionViewHeaderDay.frame.size.width;
                             collectionViewHeaderDay.frame = frame;
                             
                             frame = cMonthButton.frame;
                             frame.origin.x -= cMonthButton.frame.size.width;
                             cMonthButton.frame = frame;
                             
                             
                             frame = dayContainerScroll.frame;
                             frame.origin.x -= dayContainerScroll.frame.size.width;
                             
                             dayContainerScroll.frame = frame;
                         }];
    }
    else
    {
        [UIView animateWithDuration:ANIMATION_SPEED
                         animations:^{
                             CGRect frame = collectionViewHeaderDay.frame;
                             frame.origin.x = 0;
                             collectionViewHeaderDay.frame = frame;
                             
                             frame = cMonthButton.frame;
                             frame.origin.x = 0;
                             cMonthButton.frame = frame;
                             
                             
                             frame = dayContainerScroll.frame;
                             frame.origin.x = 0;
                             dayContainerScroll.frame = frame;
                         }];
        
        [self bringSubviewToFront:dayContainerScroll];
        [self bringSubviewToFront:collectionViewHeaderDay];
        [self bringSubviewToFront:cMonthButton];
        
    }
    isLeftPanelVisible = !isLeftPanelVisible;
}
-(void)removeCalender{
    if (grayCalenderBkView!=nil) {
        [monthCalender.view removeFromSuperview];
        monthCalender=nil;
        [grayCalenderBkView removeFromSuperview];
        grayCalenderBkView=nil;
    }
}

-(void)repositionReschedulePopoverView
{
    [UIView animateWithDuration:ANIMATION_SPEED
                     animations:^{
                         cPopOverView.center = self.center;
                         
                     }];

}

-(void)refreshDetailView
{    
    if (viewDetail) {
        
        if (lTempEvent.whatId.length) {
            NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setObject:[NSString stringWithFormat:@"%@",lTempEvent.dateTimeBegin] forKey:lTempEvent.whatId];
           
            {
                CalenderHelper *lCalendarHelper = [[CalenderHelper alloc] init];
                NSDictionary *slaPriorityDictionary = [lCalendarHelper SLAAndPriorityStatusForwhatID:lTempEvent.whatId];
                
                NSNumber *slaMetric = [slaPriorityDictionary objectForKey:@"slaStatus"];
                lTempEvent.sla = [slaMetric boolValue];
                
                NSString *priorityStatus = [slaPriorityDictionary objectForKey:@"priorityStatus"];
                if ([priorityStatus isEqualToString:@"High"]) {
                    lTempEvent.priority = YES;
                }
                else{
                    lTempEvent.priority = NO;
                }
                
                if (lTempEvent.isWorkOrder) {
                    
                    NSDictionary *lWODict =  [CalenderHelper getWorkOrdersForWhatIds:dict];
                    WorkOrderSummaryModel *model = [lWODict objectForKey:lTempEvent.whatId];
                    if (model) {
                        model.sla = [slaMetric boolValue];
                        model.priority = [NSNumber numberWithBool:lTempEvent.priority];
                        [[SMXCalendarViewController sharedInstance].cWODetailsDict setObject:model forKey:lTempEvent.whatId];
                    }
                }
                else if (lTempEvent.isCaseEvent) {
                    
                    CaseObjectModel *model = [[SMXCalendarViewController sharedInstance].cCaseDetailsDict objectForKey:lTempEvent.whatId];
                    if (model) {
                    model.sla = [slaMetric boolValue];
                    model.priority = lTempEvent.priority;
                    [[SMXCalendarViewController sharedInstance].cCaseDetailsDict setObject:model forKey:lTempEvent.whatId];
                    }
                }

                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[NSDate componentsOfDate:[[SMXDateManager sharedManager] currentDate]].day-1+7 inSection:0];
                NSDateComponents *comp = [NSDate componentsOfDate:[[SMXDateManager sharedManager] currentDate]];

                NSDate *lDate = [NSDate dateWithYear:comp.year month:comp.month day:1+indexPath.row-7];
                
                NSMutableDictionary *lDictionary = [[SMXDateManager sharedManager] getdictEvents];

                NSMutableArray *lEventArray = [[NSMutableArray alloc]initWithArray: [lDictionary objectForKey:lDate]];
                
                for (int i = 0; i<lEventArray.count; i++) {
                    SMXEvent *event = [lEventArray objectAtIndex:i];
                    if ([event.localID isEqualToString:lTempEvent.localID]) {
                        [lEventArray replaceObjectAtIndex:i withObject:lTempEvent];
                    }
                }
                [lDictionary setObject:lEventArray forKey:lDate];
                
                [dayContainerScroll.collectionViewDay reloadItemsAtIndexPaths:@[indexPath]];
                
            }
        }
       
            [self removeEditAndDetailViews];
            [self setUpDetailView];
    }
 
}
- (void)addReshudlingWindow:(SMXEvent *)event_Loc{
    if (sMXReschedulePopup!=nil) {
        [sMXReschedulePopup removeFromSuperview];
        sMXReschedulePopup=nil;
    }
    sMXReschedulePopup =[[SMXReschedulePopup alloc] initWithFrame:self.frame];
    sMXReschedulePopup.userInteractionEnabled=YES;
    [sMXReschedulePopup setEventInfo:event_Loc];
    [self.superview addSubview:sMXReschedulePopup];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end

