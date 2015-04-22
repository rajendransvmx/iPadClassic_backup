//
//  SMXMultiDayCalculation.h
//  ServiceMaxiPad
//
//  Created by ServiceMax on 2/16/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMXEvent.h"
#import "SMXDateManager.h"
#import "CalenderHelper.h"
#import "NSDate+SMXDaysCount.h"
#import "SMXCalendarViewController.h"


@interface SMXMultiDayCalculation : NSObject
{

}
@property (nonatomic,strong)SMXEvent *multiEvent;
@property (nonatomic,strong)NSMutableDictionary *eventDictinory;
@property (nonatomic,strong)NSMutableArray *eventObjects;
-(void)processEvent:(SMXEvent *)event;
-(void)updateMultiDayEvent:(SMXEvent *)event fromActivityDate:(NSDate *)fromActivityDate toActivityDate:(NSDate *)toActivityDate andStartTime:(NSDate *)startTime withEndTime:(NSDate *)endTim cellIndex:(int)fromIndex toIndex:(int)toIndex;
//-(void)removeEventFromArray:(SMXEvent *)event;
-(void)addEventIntoArray:(SMXEvent *)event;
+(int)isMultidayEvent:(NSDate *)startDate endDate:(NSDate *)endDate;
@end
