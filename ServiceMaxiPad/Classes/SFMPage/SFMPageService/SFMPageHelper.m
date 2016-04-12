//
//  SFMPageHelper.m
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 19/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFMPageHelper.h"
#import "DBRequest.h"
#import "SFProcessService.h"
#import "SFProcessComponentModel.h"
#import "SFProcessModel.h"
#import "SFMProcess.h"
#import "SFProcessComponentService.h"
#import "FactoryDAO.h"
#import "SFObjectFieldService.h"
#import "TransactionObjectDAO.h"
#import "SFPicklistDAO.h"
#import "SFRecordTypeDAO.h"
#import "SFObjectFieldDAO.h"
#import "SFMDetailFieldData.h"
#import "ObjectNameFieldValueDAO.h"
#import "SFObjectDAO.h"
#import "SFObjectModel.h"
#import "DatabaseConstant.h"
#import "SFMPageHistoryInfo.h"
#import "DateUtil.h"
#import "SFMPageViewModel.h"
#import "PlistManager.h"
#import "Utility.h"
#import "StringUtil.h"
#import "NonTagConstant.h"
#import "CustomerOrgInfo.h"
#import "ResolveConflictsHelper.h"
#import "MobileDeviceSettingDAO.h"

@implementation SFMPageHelper

+ (NSMutableArray *)getAllProcessForType:(NSString *)processType name:(NSString *)objectName
{
    DBCriteria * criteriaType = [[DBCriteria alloc] initWithFieldName:ktype operatorType:SQLOperatorEqual andFieldValue:processType];

    DBCriteria * criteriaObjectName = [[DBCriteria alloc] initWithFieldName:kobjectApiName operatorType:SQLOperatorEqual andFieldValue:objectName];
    
    NSArray * fieldNames = [[NSArray alloc] initWithObjects:kidentifier, kobjectApiName, ksfId, kprocessName, ktype, ksfId, kpageLayoutId, nil];
    NSArray * criteriaObjects = [[NSArray alloc] initWithObjects:criteriaType, criteriaObjectName, nil];
    
    id <SFProcessDAO> sfProcess = [FactoryDAO serviceByServiceType:ServiceTypeProcess];
    NSArray * resultSet = [sfProcess fetchSFProcessInfoByFields:fieldNames andCriteria:criteriaObjects andExpression:@"(1 AND 2)"];
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    
    @autoreleasepool {
        for (SFProcessModel * model in resultSet)
        {
            SFMProcess * process = [[SFMProcess alloc] init];
            if (model != nil) {
                process.processInfo = model;
            }
            [records addObject:process];
        }
    }
    return records;
}

+ (NSDictionary *)getPageLayoutForProcess:(NSString *)sfId
{
    NSArray * fieldNames = [[NSArray alloc] initWithObjects:kprocessInfo, nil];
    
   id <SFProcessDAO> sfProcess = [FactoryDAO serviceByServiceType:ServiceTypeProcess];
    
    SFProcessModel * model = [sfProcess fetchSFProcessBySalesForceId:sfId andFields:fieldNames];
    
    if(model != nil)
    {
        NSData * data = model.processInfo;
        if (data != nil) {
            return [self serializePageLayoutData:data];
        }
    }
    return nil;
}

+ (NSDictionary *)serializePageLayoutData:(NSData *)data
{
   NSDictionary *jsonObject = nil;
    if (data != nil) {
        
        NSError *error = nil;
        jsonObject = [NSJSONSerialization
                      JSONObjectWithData:data
                      options:NSJSONReadingAllowFragments error:&error];
    }
    return jsonObject;
}

+ (SFProcessModel *)getProcessInfoForProcessId:(NSString *)processId
{
    return [self getProcessInfo:processId columnName:kidentifier];
}

+ (SFProcessModel *)getProcessInfoForSFID:(NSString *)sfId
{
    return [self getProcessInfo:sfId columnName:ksfId];
}

+ (id)getProcessInfo:(NSString *)criteriaId columnName:(NSString *)columnName
{
    DBCriteria * criteria = [[DBCriteria alloc] initWithFieldName:columnName operatorType:SQLOperatorEqual andFieldValue:criteriaId];
    
    id <SFProcessDAO> sfProcess = [FactoryDAO serviceByServiceType:ServiceTypeProcess];
    SFProcessModel * model = [sfProcess getSFProcessInfo:criteria];
    
    return model;
}

+ (NSMutableDictionary *)getProcessComponentForProcess:(NSString *)processId
{
    DBCriteria * criteria = [[DBCriteria alloc] initWithFieldName:kidentifier operatorType:SQLOperatorEqual andFieldValue:processId];

    id <SFProcessComponentDAO> sfProcessComponent = [FactoryDAO serviceByServiceType:ServiceTypeProcessComponent];
    NSArray * resultSet = [sfProcessComponent fetchSFProcessComponentsByCriteria:criteria];
    
    NSMutableDictionary * resultDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    @autoreleasepool {
        for (SFProcessComponentModel * model in resultSet) {
           if (model != nil) {
               [resultDict setObject:model forKey:model.sfId];
           }
        }
    }
    return resultDict;
}

+ (NSString *)expressionIdForProcess:(NSString *)processSfId
{
    NSString *expresssionId = nil;
    DBCriteria * criteria1 = [[DBCriteria alloc] initWithFieldName:kidentifier operatorType:SQLOperatorEqual andFieldValue:processSfId];
    DBCriteria * criteria2 = [[DBCriteria alloc] initWithFieldName:kSFProcessComponentType operatorType:SQLOperatorEqual andFieldValue:@"TARGET"];
    NSMutableArray *criteraArray = [[NSMutableArray alloc]initWithObjects:criteria1,criteria2, nil];

    id <SFProcessComponentDAO> sfProcessComponent = [FactoryDAO serviceByServiceType:ServiceTypeProcessComponent];
    NSMutableArray *fields = [[NSMutableArray alloc] initWithObjects:kSFExpressionId, nil];
    NSArray * resultSet = [sfProcessComponent fetchSFProcessComponentsByFields:fields andCriteria:criteraArray andExpression:@"(1 AND 2)"];
    if ([resultSet count]>0) {
        SFProcessComponentModel *expComp = [resultSet objectAtIndex:0];
        expresssionId = expComp.expressionId;
    }
    return expresssionId;
}

+ (NSDictionary *)getObjectFieldInfoForObjectName:(NSString *)objectName
{
    DBCriteria * criteria = [[DBCriteria alloc] initWithFieldName:kobjectName operatorType:SQLOperatorEqual andFieldValue:objectName];
    
    id <SFObjectFieldDAO> sfObjectField = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectField];
    NSArray * resultSet = [sfObjectField fetchSFObjectFieldsInfoByFields:nil andCriteria:criteria];
    
    NSMutableDictionary * fieldLabelDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    if ([resultSet count] > 0) {
        for (SFObjectFieldModel * model in resultSet) {
            if (model != nil) {
                [fieldLabelDict setObject:model forKey:model.fieldName];
            }
        }
    }
    return fieldLabelDict;
}

+ (NSMutableDictionary *)getDataForObject:(NSString *)objectName
                                   fields:(NSArray *)fields
                                 recordId:(NSString *)recordId
{
    /*id <TransactionObjectDAO> transactionObject = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    NSMutableArray * fieldArray = [[NSMutableArray alloc] initWithArray:fields];
    [fieldArray addObject:kId];
    [fieldArray addObject:kLocalId];
    
    TransactionObjectModel * model = [transactionObject getDataForObject:objectName fields:fieldArray recordId:recordId];
    
    NSMutableDictionary * fieldValueDict = nil;
    
    if (model != nil) {
        fieldValueDict = [NSMutableDictionary dictionaryWithDictionary:[model getFieldValueDictionaryForFields:fieldArray]];
    }
    return fieldValueDict;*/
    
    NSMutableArray * fieldArray = [[NSMutableArray alloc] initWithArray:fields];
    [fieldArray addObject:kId];
    [fieldArray addObject:kLocalId];
    
    
    NSString * nameField = [SFMPageHelper getNameFieldForObject:objectName];
    if ([nameField length] > 0) {
        [fieldArray addObject:nameField];
    }
    
    NSMutableDictionary * fieldValueDict = [self getDataFromTransactionModel:objectName localId:recordId fieldNames:fieldArray];
    
    return fieldValueDict;
}

+ (NSMutableDictionary *)getDataFromTransactionModel:(NSString *)objectName
                                             localId:(NSString *)recordId
                                          fieldNames:(NSArray *)fieldArray
{
    id <TransactionObjectDAO> transactionObject = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    
    TransactionObjectModel * model = [transactionObject getDataForObject:objectName fields:fieldArray recordId:recordId];
    
    NSMutableDictionary * fieldValueDict = nil;
    
    if (model != nil) {
        fieldValueDict = [NSMutableDictionary dictionaryWithDictionary:[model getFieldValueDictionaryForFields:fieldArray]];
    }
    return fieldValueDict;
}

+ (NSArray *)getDetialsRecord:(SFMDetailFieldData *)detailData
{
    id <TransactionObjectDAO> transactionObject = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    NSMutableArray *fieldArray = [detailData getAllFieldNames];
    [fieldArray addObject:kId];
    [fieldArray addObject:kLocalId];
    
    [detailData updateEntryCriteriaObjects];
    
    NSArray *resultSet = nil;
    
    if ([detailData shouldApplySortingOrder]) {
        NSDictionary *dict = [detailData getSortingDetails];
        resultSet = [transactionObject fetchDetailDataForObject:detailData.objectName fields:fieldArray
                                               expression:detailData.expression
                                                 criteria:detailData.criteriaObjects withSorting:dict];
        
    }
    else {
        
       resultSet = [transactionObject fetchDataForObjectForSfmPage:detailData.objectName fields:fieldArray
                                               expression:detailData.expression
                                                 criteria:detailData.criteriaObjects];
      
    
    }
    
    
    NSArray *detailArray = [self parseDetailsResultSet:resultSet andFields:fieldArray];
    
    return detailArray;
}

+ (NSArray *)parseDetailsResultSet:(NSArray *)resultSet andFields:(NSArray *)fields
{
    NSMutableArray *array = nil;
    
    if ([resultSet count] > 0) {
        array = [[NSMutableArray alloc] initWithCapacity:0];
        
        for (TransactionObjectModel *model in resultSet) {
            NSDictionary *fieldValueDict = [model getFieldValueDictionaryForFields:fields];
            if (fieldValueDict != nil && [fieldValueDict count] > 0) {
                [array addObject:fieldValueDict];
            }
        }
    }
    return array;
}

+ (NSArray *)getPicklistValuesForObject:(NSString *)objectName pickListFields:(NSArray *)fields
{
    id <SFPicklistDAO> picklistService = [FactoryDAO serviceByServiceType:ServiceTypeSFPickList];

    DBCriteria * criteriaType = [[DBCriteria alloc] initWithFieldName:kfieldname operatorType:SQLOperatorIn andFieldValues:fields];
    
    DBCriteria * criteriaObjectName = [[DBCriteria alloc] initWithFieldName:kobjectName operatorType:SQLOperatorEqual andFieldValue:objectName];
    
    NSArray * fieldNames = [[NSArray alloc] initWithObjects:kfieldname, klabel, kvalue, nil];
    
    NSArray * criteriaObjects = [[NSArray alloc] initWithObjects:criteriaObjectName, criteriaType, nil];
    
    NSArray * resultSet = [picklistService fetchSFPicklistInfoByFields:fieldNames andCriteria:criteriaObjects
                                                          andExpression:@"(1 AND 2)"];

    return resultSet;
}

+ (NSArray *)getRecordTypeValuesForObject:(NSString *)objectName
{
    id <SFRecordTypeDAO> picklistService = [FactoryDAO serviceByServiceType:ServiceTypeSFRecordType];
    
    DBCriteria * criteriaObjectName = [[DBCriteria alloc] initWithFieldName:kobjectApiName operatorType:SQLOperatorEqual andFieldValue:objectName];
    
    NSArray * fieldNames = [[NSArray alloc] initWithObjects:kRecordType, kRecordTypeId, kRecordtypeLabel, nil];
    
    NSArray * resultSet = [picklistService fetchSFRecordTypeByFields:fieldNames andCriteria:criteriaObjectName];
    
    return resultSet;
}

+ (NSString *)getRefernceFieldValueForObject:(NSString *)objectName andId:(NSString *)sfId
{
    NSString * nameField = [self getNameFieldForObject:objectName];
    
    if ([nameField length] > 0) {
        DBCriteria * criteria1 = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorEqual andFieldValue:sfId];
        
        DBCriteria * criteria2 = [[DBCriteria alloc] initWithFieldName:kLocalId operatorType:SQLOperatorEqual andFieldValue:sfId];
        
        NSArray * criteriaArray = [NSArray arrayWithObjects:criteria1, criteria2, nil];
        
        id <TransactionObjectDAO> transactionObject = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
        
        TransactionObjectModel * model = [transactionObject getDataForObject:objectName fields:[NSArray arrayWithObjects:nameField, nil] expression:@"(1 OR 2)" criteria:criteriaArray];
        
        NSString * value = [model valueForField:nameField];
        
        return value;
    }
    return nil;
}

//Madhusudhan, #024488 Record type value should be displayed in user language.
+ (NSString *)getRecordTypeDisplayValueForsfId:(NSString *)sfId
{
    
    NSString * displayName = nil;
    id <SFRecordTypeDAO> recordTypeService = [FactoryDAO serviceByServiceType:ServiceTypeSFRecordType];
    DBCriteria * criteria = [[DBCriteria alloc] initWithFieldName:kRecordTypeId operatorType:SQLOperatorEqual andFieldValue:sfId];
    displayName = (NSString *)[recordTypeService fetchSFRecordTypeDisplayName:[NSArray arrayWithObjects:kRecordtypeLabel,nil] andCriteria:criteria];
    return displayName;
    
    
}

+ (NSString *)getNameFieldForObject:(NSString *)objectName
{
    NSString * nameField = nil;
    
    if ([objectName length] > 0) {
        DBCriteria * objNameCriteria = [[DBCriteria alloc] initWithFieldName:kobjectName operatorType:SQLOperatorEqual andFieldValue:objectName];
        DBCriteria * nameFieldCriteria = [[DBCriteria alloc] initWithFieldName:kSFObjectNameField operatorType:SQLOperatorEqual andFieldValue:@"true"];
        NSArray *criteriaArray = [[NSArray alloc]initWithObjects:objNameCriteria,nameFieldCriteria, nil];
     
        id <SFObjectFieldDAO> objectFieldService = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectField];

        SFObjectFieldModel * model = [objectFieldService getSFObjectFieldInfo:criteriaArray advanceExpression:@"1 AND 2"];
     
        if (model != nil) {
            nameField = model.fieldName;
        }
    }
    return nameField;
}

// 2-June BSP: For Defect 17514: Sorting on SFM Search
+(BOOL) checkIfTheTableExistsForObject:(NSString *)objectName
{
    id <TransactionObjectDAO> transactionObject = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    BOOL isRecordExist = [transactionObject isTransactionTableExist:objectName];
    
    return isRecordExist;
    
    
}

+ (NSDictionary *)getValuesFromReferenceTable:(NSArray *)ids
{
    NSMutableDictionary *idValue = nil;
    
    if ([ids count] > 0) {
        idValue = [[NSMutableDictionary alloc] initWithDictionary:0];
        
        DBCriteria * criteria = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorIn andFieldValues:ids];
        
        id <ObjectNameFieldValueDAO> nameFieldValueService = [FactoryDAO serviceByServiceType:ServiceTypeObjectNameFieldValue];
        
        NSArray *resultSet = [nameFieldValueService fetchObjectNameFieldValueByFields:nil andCriteria:criteria];
        
        for (ObjectNameFieldValueModel *model in resultSet) {
            if (model != nil) {
                NSString *sfId = model.Id;
                NSString *value = model.value;
                if ([sfId length] > 0 && [value length] > 0) {
                    [idValue setValue:value forKey:sfId];
                }
            }
        }
    }
    return idValue;
}


+ (NSString *)getObjectLabelForObjectName:(NSString *)objectName
{
    if ([objectName length] > 0) {
        
        NSString *label = nil;
        
        DBCriteria * criteria = [[DBCriteria alloc] initWithFieldName:kobjectName operatorType:SQLOperatorEqual andFieldValue:objectName];
        
        id <SFObjectDAO> objectService = [FactoryDAO serviceByServiceType:ServiceTypeSFObject];
        
        SFObjectModel *model = [objectService getSFObjectInfo:criteria fieldName:[NSArray arrayWithObject:klabel]];
        if (model != nil) {
            label = model.label;
        }
        return label;
    }
    return nil;
}

+ (NSDictionary *)getSlAInFo:(NSString *)objectName localId:(NSString *)recordId fieldNames:(NSArray *)fieldNames
{
    return [self getDataFromTransactionModel:objectName localId:recordId fieldNames:fieldNames];;
}

+ (NSString *)getReferenceNameForObject:(NSString *)objectName fieldName:(NSString *)fieldName
{
    NSString *refernceObject = nil;
    
    if ([objectName length] > 0 && [fieldName length] > 0 ) {
        
        DBCriteria *objectCriteria = [[DBCriteria alloc] initWithFieldName:kobjectName operatorType:SQLOperatorEqual andFieldValue:objectName];
        
        DBCriteria *fieldCriteria = [[DBCriteria alloc] initWithFieldName:kfieldname operatorType:SQLOperatorEqual
                                                            andFieldValue:fieldName];
        
        id <SFObjectFieldDAO> sfObjectField = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectField];
        
        SFObjectFieldModel * model = [sfObjectField getSFObjectFieldInfo:[NSArray arrayWithObject:kSFObjectFieldReferenceTo] criteria:[NSArray arrayWithObjects:objectCriteria, fieldCriteria, nil] advanceExpression:@"(1 AND 2)"];
        
        if (model != nil) {
            refernceObject = model.referenceTo;
        }
    }
    return refernceObject;
}

+ (BOOL)isTableEmptyForObject:(NSString *)objectName
{
    BOOL isRecordExist = NO;
    
    id <TransactionObjectDAO> transactionObject = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    isRecordExist = [transactionObject isTransactiontableEmpty:objectName];
    
    return isRecordExist;
}

+ (BOOL)isRecordExistsForObject:(NSString *)objectName sfid:(NSString *)sfId
{
    BOOL recordExists = NO;
    
    NSString *localId = [self getLocalIdForSFID:sfId objectName:objectName];
    
    if ([localId length] > 0) {
        id <TransactionObjectDAO> transactionObject = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
        
        recordExists = [transactionObject isRecordExistsForObject:objectName forRecordLocalId:localId];
    }
    
    return recordExists;
}

+ (NSArray *)getAccountHistoryInfo:(NSString *)objectName localId:(NSString *)recordId;
{
    TransactionObjectModel *model = [self getRequiredInfoForAccountHistory:objectName localId:recordId];
    
    NSString *accounId  = [model  valueForField:kWorkOrderCompanyId];
    NSString *Id = [model valueForField:kId];
    NSString *date = [model valueForField:kTextCreateDate];
    
    NSArray *array = nil;
    if ((![accounId isKindOfClass:[NSNull class]] && [accounId length] > 0) && [Id length] > 0) {
        
        DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kWorkOrderCompanyId operatorType:SQLOperatorEqual andFieldValue:accounId];
        array = [self getPageHistortInfo:objectName sfId:Id requiredCriteria:criteria createdDate:date];
        
    }
    return [self processHistoryData:array];
}

+ (NSArray *)getProductHistoryInfo:(NSString *)objectName localId:(NSString *)recordId
{
    TransactionObjectModel *model = [self getRequiredInfoForProductHistory:objectName localId:recordId];
    
    NSString *topLevelId  = [model  valueForField:kTopLevelId];
    NSString *productId = [model valueForField:kComponentId];
    NSString *Id = [model valueForField:kId];
    NSString *date = [model valueForField:kTextCreateDate];
    
    NSMutableArray *criteriaArray = [NSMutableArray array];
    
    if (![Id isKindOfClass:[NSNull class]] && [Id length] > 0) {
        
         if (![topLevelId isKindOfClass:[NSNull class]] && [topLevelId length] > 0) {
            DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kTopLevelId operatorType:SQLOperatorEqual andFieldValue:topLevelId];
            [criteriaArray addObject:criteria];
        }
        else if (![productId isKindOfClass:[NSNull class]] && [productId length] > 0) {
            DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kComponentId operatorType:SQLOperatorEqual andFieldValue:productId];
            
            [criteriaArray addObject:criteria];
        }
    }
    
    NSArray *array = nil;
    if ([criteriaArray count] == 2) {
        array =  [self getPageHistortInfo:objectName sfId:Id requiredCriteria:criteriaArray createdDate:date];
    }
    else if ([criteriaArray count] == 1) {
        array = [self getPageHistortInfo:objectName sfId:Id
                        requiredCriteria:[criteriaArray objectAtIndex:0]
                             createdDate:date];
    }
    
    return [self processHistoryData:array];
}

+ (NSArray *)processHistoryData:(NSArray *)array
{
    NSMutableArray *dataArray = [NSMutableArray array];
    
    NSArray *fields = [NSArray arrayWithObjects:kWorkOrderProblemDescription, kTextCreateDate, nil];
    
    for (TransactionObjectModel *data in array) {
        if (data != nil) {
            NSDictionary *dict = [data getFieldValueDictionaryForFields:fields];
            SFMPageHistoryInfo *model = [[SFMPageHistoryInfo alloc] initWithDictionary:dict];
            [model updateCreatedDateToUserRedableFormat];
            [dataArray addObject:model];
        }
    }
    return dataArray;
}

+(TransactionObjectModel *)getRequiredInfoForAccountHistory:(NSString *)objectName localId:(NSString *)recordId
{
    return [self getRequiredInfoForPageHistory:objectName localId:recordId fields:[NSArray arrayWithObjects:kWorkOrderCompanyId, kId, kTextCreateDate, nil]];
}

+(TransactionObjectModel *)getRequiredInfoForProductHistory:(NSString *)objectName localId:(NSString *)recordId
{
    
    return [self getRequiredInfoForPageHistory:objectName localId:recordId fields:[NSArray arrayWithObjects:kComponentId, kTopLevelId, kId, kTextCreateDate, nil]];
}

+ (TransactionObjectModel *)getRequiredInfoForPageHistory:(NSString *)objectName
                                                  localId:(NSString *)recordId
                                                   fields:(NSArray *)fields
{
    id <TransactionObjectDAO> transactionObject = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    TransactionObjectModel *model = [transactionObject getDataForObject:objectName fields:fields recordId:recordId];
    
    return model;
}

+ (NSArray *)getPageHistortInfo:(NSString *)objectName
                           sfId:(NSString *)sfId
               requiredCriteria:(id)criteria
                    createdDate:(NSString *)createdDate
{
    id <TransactionObjectDAO> transactionObject = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    NSMutableArray *criteriaArray = nil;
    NSString *advanceExpression = nil;
    
    NSArray *dataArray = nil;
    
    if ([createdDate length] > 0) {
        
        DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:kTextCreateDate operatorType:SQLOperatorLessThanEqualTo andFieldValue:createdDate];
        
        DBCriteria *criteria2 = [[DBCriteria alloc] initWithFieldName:kOrderStatus operatorType:SQLOperatorEqual andFieldValue:@"Closed"];
        
        DBCriteria *criteria3 = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorNotEqual andFieldValue:sfId];
        
        if ([criteria isKindOfClass:[NSArray class]]) {
            criteriaArray = [NSMutableArray arrayWithObjects:criteria1, criteria2, criteria3, nil];
            [criteriaArray addObjectsFromArray:(NSArray *)criteria];
            advanceExpression = @"(1 And 2 and 3 AND ( 4 OR 5))";
        }
        else{
            criteriaArray = [NSMutableArray arrayWithObjects:criteria1, criteria2, criteria3, criteria, nil];
            advanceExpression = @"(1 And 2 and 3 AND 4)";
        }
        dataArray = [transactionObject fetchDataForObject:objectName fields:[NSArray arrayWithObjects:kWorkOrderProblemDescription, kTextCreateDate, nil] expression:advanceExpression criteria:criteriaArray];
    }

    return dataArray;
    
}

+ (NSString *)getSettingValueForSettingId:(NSString *)Id
{
    id  mobileSettings = [FactoryDAO serviceByServiceType:ServiceTypeMobileDeviceSettings];
    
    if ([mobileSettings conformsToProtocol:@protocol(MobileDeviceSettingDAO)]) {
        
        MobileDeviceSettingsModel *model = [mobileSettings fetchDataForSettingId:Id];
        
        if (model.value) {
            return model.value;
        }
    }
    return nil;
}


+ (NSString *)getTodaysDate
{    
    return [DateUtil getDatabaseStringForDate:[NSDate date]];
    
}

+ (NSString *)getLocalIdForSFID:(NSString *)sfID objectName:(NSString *)objectName
{
    NSString *localId = nil;
    
    id <TransactionObjectDAO> transactionObject = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    TransactionObjectModel *model = [transactionObject getLocalIDForObject:objectName recordId:sfID];
    
    if (model != nil) {
        localId = [model valueForField:kLocalId];
    }
    return localId;
}

+ (NSString *)getSfIdForLocalId:(NSString *)localId objectName:(NSString *)objectName
{
    id <TransactionObjectDAO> transactionObject = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    return [transactionObject getSfIdForLocalId:localId forObjectName:objectName];
}

+ (NSDictionary *)getContactDetailsOfContactId:(NSString *)sfId object:(NSString *)objectName
{
    id <TransactionObjectDAO> transactionObject = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    NSString *localId = [self getLocalIdForSFID:sfId objectName:objectName];
    
    if ([localId length] > 0){
        NSArray *fields = [NSArray arrayWithObjects:@"MobilePhone", @"Email", nil];

        TransactionObjectModel *model = [transactionObject getDataForObject:objectName fields:fields recordId:localId];
        if (model != nil) {
            return [model getFieldValueDictionaryForFields:fields];
        }
    }
    return nil;
}


+ (NSArray *)getContactRefernceFieldForObject:(NSString *)objectName
{
    id  sfobjectField = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectField];
    
    if ([sfobjectField conformsToProtocol:@protocol(SFObjectFieldDAO)]) {
        
        DBCriteria *criteriaReference = [[DBCriteria alloc] initWithFieldName:kSFObjectFieldReferenceTo operatorType:SQLOperatorEqual andFieldValue:kContactTableName];
        
        DBCriteria *criteriaReferenceTo = [[DBCriteria alloc] initWithFieldName:@"type" operatorType:SQLOperatorEqual andFieldValue:kSfDTReference];
        
       NSArray *ressultSet = [sfobjectField fetchSFObjectFieldsInfoByFields:@[kfieldname] andCriteriaArray:@[criteriaReference, criteriaReferenceTo] advanceExpression:@"1 AND 2"];
        
        if ([ressultSet count] > 0) {
            
            NSMutableArray *fieldNames = [NSMutableArray new];
            
            for (SFObjectFieldModel *model in ressultSet) {
                
                if (model.fieldName) {
                    [fieldNames addObject:model.fieldName];
                }
            }
            return fieldNames;
        }
     }
    return nil;
}


+ (NSString *)getProcessTypeForId:(NSString *)processId {
    DBCriteria * criteria = [[DBCriteria alloc] initWithFieldName:ksfId operatorType:SQLOperatorEqual andFieldValue:processId];
    id <SFProcessDAO> sfProcess = [FactoryDAO serviceByServiceType:ServiceTypeProcess];
    NSArray * allModels = [sfProcess getProcessTypeForCriteria:criteria];
    if ([allModels count] > 0) {
        SFProcessModel *model = [allModels objectAtIndex:0];
        return model.processType;
    }
    return nil;
}
+(NSDictionary *)getFieldsInfoFor:(NSArray *)fieldsArray objectName:(NSString *)objectName
{
    id <SFObjectFieldDAO> sfObjectField = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectField];
    NSDictionary * fieldsDict =[sfObjectField getFieldsInformationFor:fieldsArray objectName:objectName];
    return fieldsDict;
}

+ (NSString *)valueOfLiteral:(NSString *)literal dataType:(NSString *)dataType
{
    NSString *literalValue = nil;
    if (([dataType caseInsensitiveCompare:kSfDTDate] == NSOrderedSame) || ([dataType caseInsensitiveCompare:kSfDTDateTime] == NSOrderedSame))
    {
        BOOL isDateOnly = NO;
        if ([dataType isEqualToString:kSfDTDate])
        {
            isDateOnly = YES;
        }
        if([literal caseInsensitiveCompare:kLiteralNow]== NSOrderedSame)
        {
            literalValue = [Utility today:0 andJusDate:isDateOnly];
        }
        else if([literal caseInsensitiveCompare:kLiteralToday]== NSOrderedSame)
        {
            literalValue = [Utility today:0 andJusDate:YES];
        }
        else if([literal caseInsensitiveCompare:kLiteralTomorrow]== NSOrderedSame)
        {
            literalValue = [Utility today:1 andJusDate:YES];
        }
        else if([literal caseInsensitiveCompare:kLiteralYesterday]== NSOrderedSame)
        {
            literalValue = [Utility today:-1 andJusDate:YES];
        }
        if ([dataType caseInsensitiveCompare:kSfDTDate] == NSOrderedSame){
            if ([literalValue length] >= 10 ) {
                literalValue = [literalValue substringToIndex:10];
            }
        }
    }
    else if (([dataType caseInsensitiveCompare:kSfDTBoolean] == NSOrderedSame))
    {
//        if([literal caseInsensitiveCompare:@"true"]== NSOrderedSame)
//            literalValue = @"1";
//        else
//            literalValue = @"0";
        
        if ([literal containsString:kLiteralCurrentRecord]) { // Defect#029314
            
        }
        else{
            if ([StringUtil isItTrue:literal]) {
                literalValue = kTrue;
            }
            else{
                literalValue = kFalse;
            }
        }
        
    }
    else
    {
        if(([literal caseInsensitiveCompare:kLiteralCurrentUser]== NSOrderedSame) || ([literal caseInsensitiveCompare:kLiteralOwner]== NSOrderedSame) || ([literal caseInsensitiveCompare:kLiteralCurrentUserId] == NSOrderedSame))
        {
            literalValue = [PlistManager getLoggedInUserName];
        }
        else if(([literal caseInsensitiveCompare:kLiteralCurrentRecord]== NSOrderedSame) || ([literal caseInsensitiveCompare:kLiteralCurrentRecordHeader] == NSOrderedSame))
        {
        }
        else if([literal caseInsensitiveCompare:kLiteralUserTrunk] == NSOrderedSame)
        {
            literalValue = [PlistManager getTechnicianLocation];
        }
    }
    return literalValue;
}


#pragma mark - Multipicklist functions
+ (NSArray *)getAllValuesFromMultiPicklistString:(NSString *)multipicklistString {
    
    return [multipicklistString componentsSeparatedByString:@";"];
}

+ (NSString *)getMutliPicklistLabelForpicklistString:(NSArray *)allPicklistValues
                             andFieldLabelDictionary:(NSDictionary *)fieldDictionary {
    
    NSMutableString *dataString = [[NSMutableString alloc] init];
    int counter = 0;
    for (NSString *picklist in  allPicklistValues) {
        
        NSString *labelValue = [fieldDictionary objectForKey:picklist];
        labelValue = ([StringUtil isStringEmpty:labelValue])?picklist:labelValue;
        if (counter == 0) {
              [dataString appendFormat:@"%@",labelValue];
        }
        else{
              [dataString appendFormat:@";%@",labelValue];
        }
        counter++;
    }
    return dataString;
}

#pragma mark End

+ (NSString *)getUserId;
{
    return [CustomerOrgInfo sharedInstance].currentUserId;
}


+ (BOOL)conflictExistForObjectName:(NSString *)objectName
                          recordId:(NSString *)recordId {
    BOOL status = NO;
    if (objectName && recordId) {
    
        id transactionObject = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
        if ([transactionObject conformsToProtocol:@protocol(TransactionObjectDAO)]) {
            
            TransactionObjectModel * model = [transactionObject getDataForObject:objectName
                                                                          fields:nil
                                                                        recordId:recordId];
            
            status = [ResolveConflictsHelper isConflictPresentForRecord:model];
        }
    }
    return status;
}


+ (SFMPageField *)getObjectInfoForObject:(NSString *)objectName fieldName:(NSString *)fieldName
{
    SFMPageField * pageField = nil;
    
    if ([objectName length] > 0) {
        DBCriteria * fieldNameCriteria = [[DBCriteria alloc] initWithFieldName:kfieldname operatorType:SQLOperatorEqual andFieldValue:fieldName];
        
        DBCriteria * objNameCriteria = [[DBCriteria alloc] initWithFieldName:kobjectName operatorType:SQLOperatorEqual andFieldValue:objectName];
        
        id <SFObjectFieldDAO> objectFieldService = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectField];
        
        SFObjectFieldModel *model = [objectFieldService getSFObjectFieldInfo:@[fieldNameCriteria, objNameCriteria]
                                                           advanceExpression:@"1 AND 2"];
        
        if (model) {
            
            pageField = [[SFMPageField alloc] init];
            
            pageField.fieldName = model.fieldName;
            pageField.dataType = model.type;
            pageField.isDependentPicklist = model.dependentPicklist;
            pageField.controlerField = model.controlerField;
            
        }
        
    
    }
    
    return pageField;
}

+(NSString*)getTechnicianIdForOwnerId:(NSString*)ownerId
{
    NSString *technicianId = nil;
    
    id <TransactionObjectDAO> transactionObject = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    TransactionObjectModel *model = [transactionObject getTechnicianIdForObject:ORG_NAME_SPACE"__Service_Group_Members__c" ownerId:ownerId];
    
 //   TransactionObjectModel *model = [transactionObject getLocalIDForObject:ORG_NAME_SPACE"__Service_Group_Members__c" recordId:ownerId];
    
    if (model != nil) {
      technicianId   = [model valueForField:kId];
    }
    return technicianId;
}
@end
