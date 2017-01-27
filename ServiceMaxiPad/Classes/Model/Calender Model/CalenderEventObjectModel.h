//
//  CalenderEventObjectModel.h
//  ServiceMaxMobile
//
//  Created by Sudguru Prasad on 07/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WorkOrderSummaryModel.h"
@interface CalenderEventObjectModel : NSObject

@property(nonatomic, copy) NSString *Id;
@property(nonatomic, copy) NSString *location;
@property(nonatomic, copy) NSString *durationInMinutes;
@property(nonatomic, copy) NSString *subject;
@property(nonatomic, copy) NSString *activityDate;
@property(nonatomic, copy) NSString *description;
@property(nonatomic, copy) NSString *activityDateTime;
@property(nonatomic, copy) NSDate *startDateTime;
@property(nonatomic, copy) NSDate *endDateTime;
@property(nonatomic, copy) NSString *ownerId;
@property(nonatomic, copy) NSString *WhatId;
@property(nonatomic, copy) NSString *objectSfId;
@property(nonatomic, copy) NSString *localId;
@property(nonatomic, assign) BOOL priority;
@property(nonatomic, assign) BOOL conflict;
@property(nonatomic, assign) BOOL sla;
@property (nonatomic, assign) BOOL isWorkOrder;
@property (nonatomic, assign) BOOL isCaseEvent;
@property(nonatomic, copy) NSString *isAllDayEvent;


@property(nonatomic, copy) NSString *eventObject;
@property(nonatomic, copy) NSString *eventType;


@property (nonatomic, strong) WorkOrderSummaryModel *cWorkOrderSummaryModel;

-(void)explainMe;

@end
