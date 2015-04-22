//
//  SFMPageHelper.h
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 19/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFRecordTypeModel.h"

@class TransactionObjectModel;
@class SFMProcess;
@class SFProcessModel;
@class SFMDetailFieldData;
@class SFMPageViewModel;
@class SFMPageField;

@interface SFMPageHelper : NSObject

+ (NSArray *)getAllProcessForType:(NSString *)processType name:(NSString *)objectName;
+ (NSDictionary *)getPageLayoutForProcess:(NSString *)sfId;
+ (SFProcessModel *)getProcessInfoForProcessId:(NSString *)processId;
+ (SFProcessModel *)getProcessInfoForSFID:(NSString *)sfId;
+ (NSMutableDictionary *)getProcessComponentForProcess:(NSString *)sfId;
+ (NSDictionary *)serializePageLayoutData:(NSData *)data;
+ (NSString *)expressionIdForProcess:(NSString *)processSfId;
+ (NSDictionary *)getObjectFieldInfoForObjectName:(NSString *)objectName;
+ (NSMutableDictionary *)getDataForObject:(NSString *)objectName
                              fields:(NSArray *)fields
                                recordId:(NSString *)recordId;
+ (NSArray *)getPicklistValuesForObject:(NSString *)objectName pickListFields:(NSArray *)fields;
+ (NSArray *)getRecordTypeValuesForObject:(NSString *)objectName;
+ (NSString *)getRefernceFieldValueForObject:(NSString *)objectName andId:(NSString *)sfId;
+ (NSDictionary *)getValuesFromReferenceTable:(NSArray *)ids;
+ (NSArray *)getDetialsRecord:(SFMDetailFieldData *)detailData;
+ (NSString *)getObjectLabelForObjectName:(NSString *)objectName;
+ (NSDictionary *)getSlAInFo:(NSString *)objectName localId:(NSString *)recordId fieldNames:(NSArray *)fieldNames;
+ (NSString *)getReferenceNameForObject:(NSString *)objectName fieldName:(NSString *)fieldName;
+ (BOOL)isTableEmptyForObject:(NSString *)objectName;
+ (NSArray *)getAccountHistoryInfo:(NSString *)objectName localId:(NSString *)recordId;
+ (NSArray *)getProductHistoryInfo:(NSString *)objectName localId:(NSString *)recordId;
+ (NSString *)getLocalIdForSFID:(NSString *)sfID objectName:(NSString *)objectName;
+ (NSString *)getSfIdForLocalId:(NSString *)localId objectName:(NSString *)objectName;
+ (BOOL)isRecordExistsForObject:(NSString *)objectName sfid:(NSString *)sfId;
+ (NSString *)getNameFieldForObject:(NSString *)objectName;
+ (NSDictionary *)getContactDetailsOfContactId:(NSString *)sfId object:(NSString *)objectName;

+(NSString *)getProcessTypeForId:(NSString *)processId;

+(NSDictionary *)getFieldsInfoFor:(NSArray *)fieldsArray objectName:(NSString *)objectName;

+ (NSString *)valueOfLiteral:(NSString *)literal dataType:(NSString *)dataType;

+ (NSArray *)getAllValuesFromMultiPicklistString:(NSString *)multipicklistString;
+ (NSString *)getMutliPicklistLabelForpicklistString:(NSArray *)allPicklistValues
                             andFieldLabelDictionary:(NSDictionary *)fieldDictionary;

+ (TransactionObjectModel *)getRequiredInfoForPageHistory:(NSString *)objectName
                                                  localId:(NSString *)recordId
                                                   fields:(NSArray *)fields;
+ (NSString *)getUserId;

+ (BOOL)conflictExistForObjectName:(NSString *)objectName
                          recordId:(NSString *)recordId;
+ (SFMPageField *)getObjectInfoForObject:(NSString *)objectName fieldName:(NSString *)fieldName;

+ (NSString *)getSettingValueForSeetingId:(NSString *)Id;
@end
