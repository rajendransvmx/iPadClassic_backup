//
//  SMXEvent.h
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

#import <Foundation/Foundation.h>
#import "WorkOrderSummaryModel.h"
#import "CalenderEventObjectModel.h"
#import "EventTransactionObjectModel.h"

@interface SMXEvent : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSNumber *numCustomerID;
@property (nonatomic, strong) NSDate *ActivityDateDay;
@property (nonatomic, strong) NSDate *dateTimeBegin;
@property (nonatomic, strong) NSDate *dateTimeEnd;
@property (nonatomic, strong) NSMutableArray *arrayWithGuests;
@property (nonatomic, strong) NSString *whatId;

// Added following Properties - Prasad.
//@property (nonatomic, strong) WorkOrderSummaryModel *cWorkOrderSummaryModel;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *IDString;
@property (nonatomic, strong) NSString *localID;
@property (nonatomic, strong) NSString *billingType;

@property (nonatomic, assign) BOOL sla;
@property (nonatomic, assign) BOOL priority;
@property (nonatomic, assign) BOOL conflict;
@property (nonatomic, assign) BOOL newData;
@property (nonatomic, assign) BOOL isWorkOrder;
@property (nonatomic, assign) BOOL isCaseEvent;
@property (nonatomic, assign) BOOL isMultidayEvent;
@property (nonatomic, assign) int eventIndex;
@property (nonatomic, assign) int numberOfDays;
@property (nonatomic, strong) NSDate *dateTimeBegin_multi;
@property (nonatomic, strong) NSDate *dateTimeEnd_multi;

@property (nonatomic, assign) float duration;
@property (nonatomic, strong) NSString *eventTableName;
@property (nonatomic, strong) NSString *eventType;
@property (nonatomic, assign) BOOL isAllDay;
@property (nonatomic, strong) NSString *priorityString;

//-(instancetype)initWithCalendarModel:(CalenderEventObjectModel*)model;
-(SMXEvent *) initWithEventTransactionObjectModel:(EventTransactionObjectModel*)model;
-(SMXEvent *) initWithEventWithKeyValue:(NSMutableDictionary *)Dict EventTransactionObjectModel:(EventTransactionObjectModel *)model;
-(SMXEvent *)initWithCalendarModel_self:(SMXEvent*)model;
-(void)convertDateForAllDay;
-(void)explainMe;

@end
