//
//  WorkOrderSummaryModel.h
//  ServiceMaxMobile
//
//  Created by Anoop on 9/19/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

typedef NS_ENUM(NSUInteger, Priority){
    PriorityHigh = 1,
    PriorityMedium = 2,
    PriorityLow = 3
};

#import <Foundation/Foundation.h>

@class TransactionObjectModel, ServiceLocationModel;

@interface WorkOrderSummaryModel : NSObject

@property(nonatomic, copy) NSString *Id;
@property(nonatomic, copy) NSString *localId;
@property(nonatomic, copy) NSString *contactId;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *companyId;
@property(nonatomic, copy) NSString *companyName;
@property(nonatomic, copy) NSString *gmtScheduledDateTime;
@property(nonatomic, copy) NSString *gmtEventStartDateTime;
@property(nonatomic, copy) NSString *localScheduleDateTime;
@property(nonatomic, copy) NSString *localEventStartDateTime;
@property(nonatomic, strong) NSDate *eventStartDateTime;
@property(nonatomic, strong) NSDate *scheduledDateTime;
@property(nonatomic, copy) NSString *purposeOfVisit;
@property(nonatomic, copy) NSString *problemDescription;
@property(nonatomic, copy) NSString *priorityString;
@property(nonatomic, strong) NSNumber *priority;
@property(nonatomic, copy) NSString *billingType;
@property(nonatomic, copy) NSString *orderStatus;
@property(nonatomic, copy) NSString *site;
@property (nonatomic, retain) NSArray *IPAtLocation;
@property(nonatomic, strong) ServiceLocationModel *serviceLocationModel;

- (id)initWithTransactionModel:(TransactionObjectModel*)transactionModel andIdEventStartValueMap:(NSMutableDictionary*)idEventStartValueMap;
- (void)explainMe;

@end
