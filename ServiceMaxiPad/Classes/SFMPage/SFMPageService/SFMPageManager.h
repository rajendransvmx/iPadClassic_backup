//
//  SFMPageManager.h
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 19/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFMPage.h"

@interface SFMPageManager : NSObject

@property(nonatomic,copy) NSString *objectName;
@property(nonatomic,copy) NSString *recordId;
@property(nonatomic,copy) NSString *processId;
@property(nonatomic,copy) NSString *Fieldname;

@property(nonatomic,strong) NSMutableDictionary *pickListData;
@property(nonatomic,strong) NSMutableDictionary *recordTypeData;

- (id)initWithObjectName:(NSString *)objectName
                recordId:(NSString *)recordLocalId
               processSFId:(NSString *)processId;


- (BOOL) isValidProcess:(NSString *)processId error:(NSError **)error;
- (BOOL)isValidOPDocProcess:(NSString *)processId error:(NSError **)error;
- (NSString *)getLocalIdForSFID:(NSString *)sfID objectName:(NSString *)objectName;

- (SFMPage *) sfmPage;
- (SFMProcess *) sfmProcessForPage;

- (NSMutableDictionary *)getHeaderRecordForSFMPage:(SFMPage *)sfmPage;

- (NSString *)getProcessTypeForProcessId:(NSString *)processId;
- (NSMutableDictionary *)getFieldDataTypeMap:(NSArray *)fields;
- (void)updatePicklistDataFor:(NSString *)objectName fields:(NSMutableArray *)pickListFileds;
- (void)updateRecordTypeDisplayValue:(NSMutableDictionary *)dataDictionary;
- (void)updateRecordTypeDataFor:(NSString *)objectName fields:(NSMutableArray *)recordTypeFields;
- (void)updatePicklistDisplayValues:(NSDictionary *)dataDict picklistFields:(NSMutableArray *)picklistFields multiPicklistFields:(NSMutableArray *)multiPicklistFields;
- (void)fillPickPickListAndRecordTypeInfo:(NSDictionary *)dataDictionary andObjectName:(NSString *)objectName;
- (void)updateReferenceFieldDisplayValues:(NSMutableDictionary *)fieldNameAndInternalValue
                      andFieldObjectNames:(NSDictionary *)fieldNameAndObjectNames;
- (void)resetPicklistAndRecordTypeData;
- (NSString *)getUserReadableDateTime:(NSString *)dateTime;
- (NSString *)getUserReadableDate:(NSString *)dateTime;
- (NSString *)getDateForValueMapping:(NSString *)datetime;
- (NSString *)getUserReadableDateForValueMapping:(NSString *)datetime;



- (SFMPage *)theSFMPagewithObjectName:(NSString *)theObjectName andRecordID:(NSString *)lRecordID andProcessID:(NSString *)lProcessId;
- (NSMutableDictionary *)getDetailRecordsForCustom:(SFMPage *)sfmPage andHeaderId:(NSString *)headerSfId;

@end
