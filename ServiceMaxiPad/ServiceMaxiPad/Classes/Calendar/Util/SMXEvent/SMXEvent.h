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

@interface SMXEvent : NSObject

@property (nonatomic, strong) NSString *stringCustomerName;
@property (nonatomic, strong) NSNumber *numCustomerID;
@property (nonatomic, strong) NSDate *ActivityDateDay;
@property (nonatomic, strong) NSDate *dateTimeBegin;
@property (nonatomic, strong) NSDate *dateTimeEnd;
@property (nonatomic, strong) NSMutableArray *arrayWithGuests;
@property (nonatomic, strong) NSString *whatId;

// Added following Properties - Prasad.
@property (nonatomic, strong) WorkOrderSummaryModel *cWorkOrderSummaryModel;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *IDString;
@property (nonatomic, strong) NSString *localID;
@property (nonatomic, strong) NSString *billingType;
-(void)explainMe;

@end
