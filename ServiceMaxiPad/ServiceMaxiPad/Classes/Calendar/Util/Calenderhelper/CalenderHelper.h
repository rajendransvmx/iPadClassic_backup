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

+ (NSString*) prefixForWorkOrder;

+ (ContactImageModel *)getContactObjectForId:(NSString *)contactId;
+ (NSString*)ownerId;
+ (NSArray*)allKeysForWorkOrderPopup;
+ (NSArray*)allTagValuesForWorkOrderPopup;



-(NSArray*) eventsOfRangeOfDays;
-(NSArray *) getEventDetailsForTheDay;
+(NSString *)getServiceLocation:(NSString *)whatID;
+(ServiceLocationModel *)getServiceLocationModel:(NSString *)lWhatID;

+ (NSString *) localTimeFromGMT:(NSString *)gmtDate;
+ (void)updateEvent:(SMXEvent *)event toActivityDate:(NSDate *) activityDate andStartTime:(NSDate *)startTime withEndTime:(NSDate *)endTime;

+ (TransactionObjectModel *)getRecordForSalesforceId:(NSString *)salesforceId;

+(BOOL)isConflicted:(NSString *)lWhatId;
+(NSDictionary *)SLAAndPriorityStatusForwhatID:(NSString *)lWhatId;
+ (NSArray*)getWorkOrdersForWhatIds:(NSMutableDictionary*)whatEventStartDateValueMap;

@end
