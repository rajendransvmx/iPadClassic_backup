//
//  SMXReschedulePopup.h
//  ServiceMaxiPad
//
//  Created by Service Max on 11/02/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMXEvent.h"
#import "SMXConstants.h"
#import "CalenderHelper.h"
#import "SMXMultiDayCalculation.h"
#import "SMXDateManager.h"

#define ANIMATION_SPEED 0.25
#define START_DATE_BUTTON_TAG 1001
#define END_DATE_BUTTON_TAG 1002
@interface SMXReschedulePopup : UIImageView
{
    
}
@property (nonatomic,strong)SMXEvent *event;
@property (nonatomic,strong)UIDatePicker *cDatePicker;
@property (nonatomic,strong)UIView *cPopOverView;
@property (nonatomic,strong)UILabel *cEventClashingWithOtherEventLabel;
@property (nonatomic,strong)NSDate *lTempStartDateTime;
@property (nonatomic,strong)NSDate *lTempEndDateTime;
@property (nonatomic,strong)UIButton *cStartDateTimeButton;
@property (nonatomic,strong)UIButton *cEndDateTimeButton;
@property (nonatomic) BOOL isDatePickerVisible;
@property (nonatomic,strong) SMXMultiDayCalculation *multiDayCalculation;
-(void)setEventInfo:(SMXEvent *)event_loc;
-(void)updateEvent:(SMXEvent *)event fromActivityDate:(NSDate *)fromActivityDate toActivityDate:(NSDate *)activityDate andStartTime:(NSDate *)startTime withEndTime:(NSDate *)endTim fromIndex:(int)fromIndex toIndex:(int)toIndex;
@end
