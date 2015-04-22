//
//  CalenderHelper.h
//  ServiceMaxMobile
//
//  Created by Sudguru Prasad on 07/10/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "CommonServices.h"
#import "SMXEvent.h"

@class ContactImageModel;

@interface CalenderHelper : CommonServices 


@property (nonatomic, copy) void (^completionHandler)(NSArray *);

+ (NSString*) prefixForWorkOrder;

+ (ContactImageModel *)getContactObjectForId:(NSString *)contactId;
+ (NSString*)ownerId;

-(NSArray*) eventsOfRangeOfDays;
-(NSArray *) getEventDetailsForTheDay;
+(NSString *)getServiceLocation:(NSString *)whatID;
+(ServiceLocationModel *)getServiceLocationModel:(NSString *)lWhatID;

+ (NSString *) localTimeFromGMT:(NSString *)gmtDate;
+ (void)updateEvent:(SMXEvent *)event toActivityDate:(NSDate *) activityDate andStartTime:(NSDate *)startTime withEndTime:(NSDate *)endTime;

+ (TransactionObjectModel *)getRecordForSalesforceId:(NSString *)salesforceId;
+ (TransactionObjectModel *)getRecordForlocalID:(NSString *)localID;

+(BOOL)isConflicted:(NSString *)lWhatId;
-(void)getSLAPriorityForEventArray:(NSArray *)eventArray;
-(NSDictionary *)SLAAndPriorityStatusForwhatID:(NSString *)lWhatId;
+ (NSMutableDictionary*)getWorkOrdersForWhatIds:(NSMutableDictionary*)whatEventStartDateValueMap;
+(NSString *)getTagValueForMonth:(long)month;
+(NSString *)getStringValueForTheDate:(NSDate *)lDate;

@end
