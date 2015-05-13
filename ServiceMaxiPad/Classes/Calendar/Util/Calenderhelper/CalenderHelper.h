//
//  CalenderHelper.h
//  ServiceMaxMobile
//
//  Created by Sudguru Prasad on 07/10/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "CommonServices.h"
#import "SMXEvent.h"
#import "SMXDateManager.h"

@class ContactImageModel;

@interface CalenderHelper : CommonServices 


@property (nonatomic, copy) void (^completionHandler)(NSArray *);

+ (NSString*) prefixForWorkOrder;

+ (ContactImageModel *)getContactObjectForId:(NSString *)contactId;
+ (NSString*)ownerId;

-(NSArray *) getEventDetailsForTheDay;
+(NSString *)getServiceLocation:(NSString *)whatID;
+(ServiceLocationModel *)getServiceLocationModel:(NSString *)lWhatID;

+ (NSString *) localTimeFromGMT:(NSString *)gmtDate;
+ (void)updateEvent:(SMXEvent *)event toActivityDate:(NSDate *) activityDate andStartTime:(NSDate *)startTime withEndTime:(NSDate *)endTime multiDayEvent:(NSArray *)objectArray;

+ (TransactionObjectModel *)getRecordForSalesforceId:(NSString *)salesforceId;
+ (TransactionObjectModel *)getRecordForEvent:(SMXEvent *)event;

+(BOOL)isConflicted:(NSString *)lWhatId;
-(void)getSLAPriorityForEventArray:(NSArray *)eventArray;
-(NSDictionary *)SLAAndPriorityStatusForwhatID:(NSString *)lWhatId;
+ (NSMutableDictionary*)getWorkOrdersForWhatIds:(NSMutableDictionary*)whatEventStartDateValueMap;
+(NSString *)getTagValueForMonth:(long)month;
+(NSString *)getStringValueForTheDate:(NSDate *)lDate;
+ (NSString*)getEventTypeFromMobileDeviceSettings;


+(NSDate *)getStartEndDateTime:(NSString *)lTempDateTime;

+ (NSString *)getTheHexaCodeForTheSettingId:(NSString *)settingId;


@end
