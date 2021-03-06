//
//  SFMPageEditHelper.h
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 08/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "SFMPageHelper.h"
#import "SFMPageField.h"
#import "SFMRecordFieldData.h"
#import "SFPicklistModel.h"

@interface SFMPageEditHelper : SFMPageHelper

+ (NSArray *)getPickListInfoForObject:(NSString *)objectName field:(NSString *)fieldName;

+ (NSMutableArray *)getPicklistValuesForField:(NSString *)fieldApiName  objectName:(NSString *)objectName;
+ (NSMutableArray *)getRecordTypeValuesForObjectName:(NSString *)objectName;
+ (NSArray *)getDependentPicklistValuesForPageField:(SFMPageField *)controllerPageField recordFieldVal:(NSString *)recordField objectName:(NSString *)objectName fromPicklist:(NSArray *)picklist;
+ (NSArray *)getDependentPicklistValuesForIndex:(int)index fromPicklist:(NSArray *)picklist;
+ (NSArray*)getCommonDependentValuesFromRecordTypeValue:(NSArray*)recordTypeDepValues andDependentValues:(NSArray *)dependentPicklistValues;
+ (BOOL)isRecordTypeDependent:(NSString *)fieldName RecordTypeFieldData:(NSString *)recordTypeValue
                andObjectName:(NSString *)objectName;

+ (NSArray *)getRecordTypePicklistData:(NSString *)objectName fieldName:(NSString *)fieldName
                         pageDataValue:(NSString *)internalValue;
+ (NSArray *)getRTDependencyFieldsForobject:(NSString *)objectName recordTypeId:(NSString *)value;
+ (NSDictionary *)getDefaultValueForRTDepFields:(NSArray *)fields
                                objectName:(NSString *)objectName
                              recordTypeId:(NSString *)recordTypeId;

+ (NSString *)getObjectNameForProcessId:(NSString *)processId;
+ (NSArray *)getFieldMappingDataForMappingId:(NSString *)objectMappingId;
+ (NSDictionary *)getRecordTypeDataByName:(NSString *)objectname;
+ (NSDictionary *)getObjectFieldInfoByType:(NSString *)objectName;
+ (NSDictionary *)getProcessNameForProcessId:(NSArray *)processIds;
+ (NSArray *)getLinkedProcessIdsForDetail:(NSString *)processId componentId:(NSString *)componentId;

+ (BOOL)getObjectFieldCountForObject:(NSString *)objectName;

- (BOOL)insertRecord:(NSMutableDictionary *)record intoObjectName:(NSString *)objectName;
- (BOOL)updateRecord:(NSDictionary *)record
        inObjectName:(NSString *)objectName
          andLocalId:(NSString *)localId;

- (void)deleteRecordWithId:(NSString *)recordId fromObjectName:(NSString *)objectName;
- (void)deleteRecordWithIds:(NSArray *)recordIds
             fromObjectName:(NSString *)objectName
       andCriteriaFieldName:(NSString *)fieldName;

- (BOOL)updateFinalRecord:(NSDictionary *)eachRecord inObjectName:(NSString *)objectName andLocalId:(NSString *)localId;

+ (NSDictionary *)getAllDataForObject:(NSString *)objectName
                          andRecordId:(NSString *)recordId;
+ (SFRecordTypeModel *)getRecordTypeobjectForIdOrName:(NSString *)recordType andObjectName:(NSString *)objectName;
+ (SFPicklistModel *)getPickListLabelFor:(NSString *)picklistValue
                           withFieldName:(NSString *)fieldApiName
                           andObjectName:(NSString *)objectName;
+ (NSDictionary *)getPicklistLabelsFor:(NSArray *)picklistValues
                         withFieldName:(NSString *)fieldApiName
                         andObjectName:(NSString *)objectName;
+ (NSString *) getSettingValueForKey:(NSString *)setting;
@end
