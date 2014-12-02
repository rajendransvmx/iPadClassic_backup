//
//  MapHelper.h
//  ServiceMaxMobile
//
//  Created by Anoop on 9/15/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "CommonServices.h"

@class ContactImageModel, WorkOrderSummaryModel;

@interface MapHelper : CommonServices

+ (NSArray*) workOrderSummaryArrayOfCurrentDay:(NSDate*)selectedDate;
+ (NSString*) prefixForWorkOrder;
+ (NSArray*) eventsOfCurrentDay:(NSDate*)selectedDate;
+ (NSMutableDictionary *)getValuesFromReferenceTable:(NSArray *)ids;
+ (NSString *)getAccountNameForId:(NSString *)accountId;
+ (ContactImageModel *)getContactObjectForId:(NSString *)contactId;
+ (NSString*)ownerId;
+ (NSArray*)allKeysForWorkOrderPopup;
+ (NSArray*)allTagValuesForWorkOrderPopup;
+ (NSMutableDictionary*)objectValueMapDictionary:(WorkOrderSummaryModel*)workOrder;
+ (void)showMissingAddressWorkOrders:(NSMutableArray*)workOrders;
+ (void)requestTechnicianIdWithTheCallerDelegate:(id)delegate;
+ (void)requestTechnicianAddressForId:(NSString *)technicianId
                    andCallerDelegate:(id)delegate;

@end
