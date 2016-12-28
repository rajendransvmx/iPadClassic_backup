//
//  PriceCalculationDBService.m
//  ServiceMaxiPhone
//
//  Created by Shravya shridhar on 6/17/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "PriceCalculationDBService.h"
#import "SFRecordTypeService.h"
#import "SFRecordTypeDAO.h"
#import "SFRecordTypeModel.h"
#import "MobileDeviceSettingService.h"
#import "MobileDeviceSettingDAO.h"
#import "MobileDeviceSettingsModel.h"
#import "CommonServices.h"
#import "CommonServiceDAO.h"
#import "StringUtil.h"
#import "FactoryDAO.h"
#import "TransactionObjectDAO.h"
#import "SFObjectFieldService.h"
#import "SFMPageManager.h"
#import "Utility.h"

@implementation PriceCalculationDBService




#pragma mark - Private methods
- (NSArray *)getObjectsObjectName:(NSString *)objectName
                  withDBCriterias:(NSArray *)criterias
                   withExpression:(NSString *)expression
                        andFields:(NSArray *)fields {
    /* Get header record from data base*/
    
    
    id <TransactionObjectDAO>transObjectService  = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    NSArray *allRecords = [transObjectService fetchDataWithhAllFieldsAsStringObjects:objectName fields:fields expression:expression criteria:criterias];
    
    return allRecords;
}

- (NSArray *)getObjectsAsNumbersObjectName:(NSString *)objectName
                           withDBCriterias:(NSArray *)criterias
                            withExpression:(NSString *)expression
                                 andFields:(NSArray *)fields {
    /* Get header record from data base*/
    
    
    id <TransactionObjectDAO>transObjectService  = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    NSArray *allRecords = [transObjectService fetchDataForObject:objectName fields:fields expression:expression criteria:criterias];
    
    return allRecords;
}

- (NSArray *)getAllRecordsFromObjectName:(NSString *)objectName
                               forFields:(NSArray *)fields
                           withCriterias:(NSArray *)criterias
                           andModelClass:(Class)modelClass {
    
    id  <CommonServiceDAO> service = [[CommonServices alloc] init];
    NSArray *allModels =  [service fetchDataForFields:fields criterias:criterias objectName:objectName andModelClass:modelClass];
    return allModels;
}

#pragma mark End

//- (NSDictionary *)getObjectForLocalId:(NSString *)localId
//                           withFields:(NSArray *)fields
//                        andObjectname:(NSString *)objectName
//{
//    
//    NSString *whereClause = [NSString stringWithFormat:@" %@ = '%@'",kLocalId,localId];
//    NSArray *records =   [self getRecordsForFields:fields forObjectname:objectName andWhereClause:whereClause];
//    if ([records count] > 0) {
//        return [records objectAtIndex:0];
//    }
//    return nil;
//}
//


- (NSString *)getPricebookInformationForSettingId:(NSString *)settingId {
  
    DBCriteria *firstCriteria = [[DBCriteria alloc] initWithFieldName:@"settingId" operatorType:SQLOperatorEqual andFieldValue:settingId];
    NSArray *allModels =  [self getAllRecordsFromObjectName:@"MobileDeviceSettings" forFields:@[@"value"] withCriterias:@[firstCriteria] andModelClass:[MobileDeviceSettingsModel class]];
    if ([allModels count] > 0) {
         MobileDeviceSettingsModel *settingModel = [allModels objectAtIndex:0];
        return settingModel.value;
    }
    return nil;
}

-(NSDictionary *)getReferenceFieldsFor:(NSString *)objectName

{
    NSMutableDictionary *referenceToDict = [[NSMutableDictionary alloc] init];
    
    DBCriteria * criteia1 = [[DBCriteria alloc] initWithFieldName:@"objectName" operatorType:SQLOperatorEqual andFieldValue:objectName];
    DBCriteria * criteria2 = [[DBCriteria alloc] initWithFieldName:@"referenceTo" operatorType:SQLOperatorNotEqual andFieldValue:@"\\"];
    DBCriteria * criteria3 = [[DBCriteria alloc] initWithFieldName:@"referenceTo" operatorType:SQLOperatorIsNotNull andFieldValue:nil];
    
     NSArray *allModels =  [self getAllRecordsFromObjectName:kSFObjectField forFields:@[@"fieldName",@"referenceTo"] withCriterias:@[criteia1,criteria2,criteria3] andModelClass:[SFObjectFieldModel class]];
    
    for (SFObjectFieldModel * objField in allModels) {
        [referenceToDict setObject:objField.referenceTo forKey:objField.fieldName];
    }
    
    return referenceToDict;
}

- (NSDictionary *)getRecordTypeIdsForRecordType:(NSArray *)recordTypes{
    
    id  <SFRecordTypeDAO> service = [[SFRecordTypeService alloc] init];
    
    NSString *recordTypeFieldName = @"recordType";
    NSString *recordTypeId = @"recordTypeId";
    DBCriteria *firstCriteria = [[DBCriteria alloc] initWithFieldName:recordTypeFieldName operatorType:SQLOperatorIn andFieldValues:recordTypes];
    DBCriteria *secondCriteria = [[DBCriteria alloc] initWithFieldName:recordTypeId operatorType:SQLOperatorIsNotNull andFieldValue:nil];
    
   NSArray *recordTypeModels = [service fetchSFRecordTypeInfoByFields:@[recordTypeFieldName,recordTypeId] andCriteria:@[firstCriteria,secondCriteria] andExpression:nil];
    
    
    NSMutableDictionary *dataDictionary = [[NSMutableDictionary alloc] init];
    
    for (SFRecordTypeModel *model in recordTypeModels) {
        
        if (model.recordTypeId != nil && model.recordType != nil ) {
             [dataDictionary setObject:model.recordTypeId forKey:model.recordType];
        }
    }

    return dataDictionary;
}



- (NSArray *)getPriceBookObjectsForPriceBookIds:(NSArray *)priceBookIds
                               OrPriceBookNames:(NSArray *)priceBookNames {
    NSArray *fields = [NSArray arrayWithObjects:kId,@"Name", nil];
    NSString *objectName = @"Pricebook2";
    
    DBCriteria *firstCriteria = [[DBCriteria alloc] initWithFieldName:@"IsActive" operatorType:SQLOperatorEqual andFieldValue:@"true"];
    
    DBCriteria *criteria2 = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorIn andFieldValues:priceBookIds];
    DBCriteria *criteria3 = [[DBCriteria alloc] initWithFieldName:@"Name" operatorType:SQLOperatorIn andFieldValues:priceBookNames];

   
    NSString *advExpression = @"(1 and ( 2 or 3))";
    NSArray *transArray = [self getObjectsObjectName:objectName withDBCriterias:@[firstCriteria,criteria2,criteria3] withExpression:advExpression andFields:fields];
    
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    for (TransactionObjectModel *model in transArray) {
        [dataArray addObject:[model getFieldValueDictionary]];
    }
    return dataArray;
}

- (NSArray *)getPriceBookObjectsForLabourPriceBookIds:(NSArray *)priceBookIds
                                     OrPriceBookNames:(NSArray *)priceBookNames {
    NSString *priceBookActive = kServicePricebookActive;
   
    NSArray *fields = [NSArray arrayWithObjects:kId,@"Name", nil];
    NSString *objectName = kTableServicePricebook;
    
    DBCriteria *firstCriteria = [[DBCriteria alloc] initWithFieldName:priceBookActive operatorType:SQLOperatorEqual andFieldValue:@"true"];
    
    DBCriteria *criteria2 = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorIn andFieldValues:priceBookIds];
    DBCriteria *criteria3 = [[DBCriteria alloc] initWithFieldName:@"Name" operatorType:SQLOperatorIn andFieldValues:priceBookNames];
    
    
    NSString *advExpression = @"(1 and ( 2 or 3))";
    NSArray *transArray = [self getObjectsObjectName:objectName withDBCriterias:@[firstCriteria,criteria2,criteria3] withExpression:advExpression andFields:fields];
    
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    for (TransactionObjectModel *model in transArray) {
        [dataArray addObject:[model getFieldValueDictionary]];
    }
    return dataArray;
}


- (NSDictionary *)preparePBEstimateId:(NSString *)estimateValue
                        andUsageValue:(NSString *)usageValue
                               andKey:(NSString *)key
                      andRecordTypeId:(NSDictionary *)recordTypeIds {
    
    NSString *usageRecordTypeId = [recordTypeIds objectForKey:@"Usage/Consumption"];
    NSString *estimateRecordTypeId = [recordTypeIds objectForKey:@"Estimate"];
    
    if (usageRecordTypeId != nil) {
        NSMutableArray *arrayTemp = [[NSMutableArray alloc] init];
        
        if (usageValue != nil) {
            NSArray *pbArray = [self getPriceBookObjectsForPriceBookIds:[NSArray arrayWithObject:usageValue] OrPriceBookNames:nil];
            for (int counter = 0; counter < [pbArray count ]; counter++) {
                
                NSDictionary *pbBook = [pbArray objectAtIndex:counter];
                NSString *finalValue = [pbBook objectForKey:@"Id"];
                if (finalValue != nil) {
                    NSDictionary *tempDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:finalValue,@"value", usageRecordTypeId,@"key", nil];
                    [arrayTemp addObject:tempDictionary];
                        tempDictionary = nil;
                }
            }
        }
        
        if (estimateRecordTypeId != nil && estimateValue != nil) {
            
            NSArray *pbArray = [self getPriceBookObjectsForPriceBookIds:[NSArray arrayWithObject:estimateValue] OrPriceBookNames:nil];
            for (int counter = 0; counter < [pbArray count ]; counter++) {
                NSDictionary *pbBook = [pbArray objectAtIndex:counter];
                NSString *finalValue = [pbBook objectForKey:@"Id"];
                if (finalValue != nil) {
                    NSDictionary *tempDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:finalValue, @"value",estimateRecordTypeId,@"key", nil];
                    [arrayTemp addObject:tempDictionary];
                    tempDictionary = nil;
                }
            }
        }
        NSDictionary *tempDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:arrayTemp,@"valueMap",key,@"key", nil];
        return tempDictionary;
    }
    return nil;
}

- (NSDictionary *)preparePBLaourEstimateId:(NSString *)estimateValue
                             andUsageValue:(NSString *)usageValue
                                    andKey:(NSString *)key
                           andRecordTypeId:(NSDictionary *)recordTypeIds {
    
    NSString *usageRecordTypeId = [recordTypeIds objectForKey:@"Usage/Consumption"];
    NSString *estimateRecordTypeId = [recordTypeIds objectForKey:@"Estimate"];
    
    if (usageRecordTypeId != nil) {
        NSMutableArray *arrayTemp = [[NSMutableArray alloc] init];
        
        if (usageValue != nil) {
            NSArray *pbArray = [self getPriceBookObjectsForLabourPriceBookIds:[NSArray arrayWithObject:usageValue] OrPriceBookNames:nil];
            for (int counter = 0; counter < [pbArray count ]; counter++) {
                
                NSDictionary *pbBook = [pbArray objectAtIndex:counter];
                NSString *finalValue = [pbBook objectForKey:@"Id"];
                if (finalValue != nil) {
                    NSDictionary *tempDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:finalValue,@"value", usageRecordTypeId,@"key", nil];
                    [arrayTemp addObject:tempDictionary];
                   
                }
            }
        }
        
        if (estimateRecordTypeId != nil && estimateValue != nil) {
            
            NSArray *pbArray = [self getPriceBookObjectsForLabourPriceBookIds:[NSArray arrayWithObject:estimateValue] OrPriceBookNames:nil];
            for (int counter = 0; counter < [pbArray count ]; counter++) {
                NSDictionary *pbBook = [pbArray objectAtIndex:counter];
                NSString *finalValue = [pbBook objectForKey:@"Id"];
                if (finalValue != nil) {
                    NSDictionary *tempDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:finalValue,@"value", estimateRecordTypeId,@"key", nil];
                    [arrayTemp addObject:tempDictionary];
                     tempDictionary = nil;
                }
            }
        }
        NSDictionary *tempDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:arrayTemp,@"valueMap",key,@"key", nil];
        return tempDictionary;
    }
    return nil;
}

- (NSDictionary *)getEntitlementHistoryForWorkorder:(NSString *)workOrderId {
    
    NSString *tableName = [StringUtil appendOrgNameSpaceToString:@"__Entitlement_History__c"];
    
    DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:ORG_NAME_SPACE@"__Service_Order__c" operatorType:SQLOperatorEqual andFieldValue:workOrderId];
    
    DBCriteria *criteria2 = [[DBCriteria alloc] initWithFieldName:ORG_NAME_SPACE@"__Inactive_Date__c" operatorType:SQLOperatorIsNull andFieldValue:nil];
   
    
    NSArray *transArray =  [self getObjectsObjectName:tableName withDBCriterias:@[criteria1,criteria2] withExpression:nil andFields:nil];
    
    if ([transArray count] > 0  ) {
        TransactionObjectModel *model = [transArray objectAtIndex:0];
        NSDictionary *valueDictionary =  [model getFieldValueDictionary];
        return  valueDictionary;
    }
    return nil;

}
//
//- (NSDictionary *)getAllFieldsOfTable:(NSString *)tableName {
//    SMXiPhone_ObjectDefinitionService *objectDefn = [[SMXiPhone_ObjectDefinitionService alloc] init];
//    return [objectDefn getFieldNameAndTypeForObject:tableName];
//}
//
- (NSMutableDictionary *)getRecordForId:(NSString *)sfId andObjectName:(NSString *)objectName{
   
    DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorEqual andFieldValue:sfId];
    DBCriteria *criteria2 = [[DBCriteria alloc] initWithFieldName:kLocalId operatorType:SQLOperatorEqual andFieldValue:sfId];
    

    
    NSArray *transArray =  [self getObjectsAsNumbersObjectName:objectName withDBCriterias:@[criteria1,criteria2] withExpression:@"( 1 or 2 )" andFields:nil];
    
    if ([transArray count] > 0  ) {
        TransactionObjectModel *model = [transArray objectAtIndex:0];
        NSDictionary *valueDictionary =  [model getFieldValueMutableDictionary];
        return  [NSMutableDictionary dictionaryWithDictionary:valueDictionary];
    }
    return nil;


}


- (NSArray*)getPriceBookEntryRecordsFor:(NSArray *)priceBookIds
                        andProductArray:(NSArray *)productsArray
                           andTableName:(NSString *)tableName
                            andCurrency:(NSString *)currency {
    
    
    NSString *objectName = tableName;
    
    DBCriteria *firstCriteria = [[DBCriteria alloc] initWithFieldName:@"IsActive" operatorType:SQLOperatorEqual andFieldValue:@"true"];
    DBCriteria *criteria2 = [[DBCriteria alloc] initWithFieldName:@"Product2Id" operatorType:SQLOperatorIn andFieldValues:productsArray];
    DBCriteria *criteria3 = [[DBCriteria alloc] initWithFieldName:@"Pricebook2Id" operatorType:SQLOperatorIn andFieldValues:priceBookIds];
    DBCriteria *criteria4 = [[DBCriteria alloc] initWithFieldName:@"CurrencyIsoCode" operatorType:SQLOperatorEqual andFieldValue:currency];
    
    NSArray *allTransObjects = nil;
    
    if (currency != nil) {
         allTransObjects =  [self getObjectsAsNumbersObjectName:objectName withDBCriterias:@[firstCriteria,criteria2,criteria3,criteria4] withExpression:nil andFields:nil];
    }
    else{
         allTransObjects =  [self getObjectsAsNumbersObjectName:objectName withDBCriterias:@[firstCriteria,criteria2,criteria3] withExpression:nil andFields:nil];
    }
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    for (TransactionObjectModel *model in allTransObjects) {
        [dataArray addObject:[model getFieldValueDictionary]];
    }
    return dataArray;
}

//- (id)getTheProperObjectTypeForFieldType:(NSString *)fieldType andFieldValue:(NSString *)fieldValue {
//    id someObject = fieldValue;
//    
//    fieldType = [fieldType lowercaseString];
//    NSString *newFieldType = [[SMXiPhone_Database sharedDataBase] getSqliteDataTypeForSalesforceType:fieldType];
//    if ([newFieldType isEqualToString:@"DOUBLE"]) {
//        someObject = [NSNumber numberWithDouble:[fieldValue doubleValue]];
//        
//    }
//    else if ([newFieldType isEqualToString:@"INTEGER"]) {
//        someObject = [NSNumber numberWithInt:[fieldValue intValue]];
//        
//    }
//    
//    return someObject;
//}
//
- (NSArray *)getPriceBookEntryForLabourArray:(NSArray *)labourArray andPriceBookIds:(NSArray *)priceBookIds andCurrency:(NSString *)currency {
    
    NSString *objectName =  kTableServicePricebookEntry;
    
    DBCriteria *criteria2 = [[DBCriteria alloc] initWithFieldName:kPriceBookActivityType operatorType:SQLOperatorIn andFieldValues:labourArray];
    DBCriteria *criteria3 = [[DBCriteria alloc] initWithFieldName:kPriceBookType operatorType:SQLOperatorIn andFieldValues:priceBookIds];
    DBCriteria *criteria4 = [[DBCriteria alloc] initWithFieldName:@"CurrencyIsoCode" operatorType:SQLOperatorEqual andFieldValue:currency];
    
    NSArray *allTransObjects = nil;
    
    if (currency != nil) {
        allTransObjects =  [self getObjectsAsNumbersObjectName:objectName withDBCriterias:@[criteria2,criteria3,criteria4] withExpression:nil andFields:nil];
    }
    else{
        allTransObjects =  [self getObjectsAsNumbersObjectName:objectName withDBCriterias:@[criteria2,criteria3] withExpression:nil andFields:nil];
    }
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    for (TransactionObjectModel *model in allTransObjects) {
        [dataArray addObject:[model getFieldValueDictionary]];
    }
    return dataArray;

}

- (NSArray *)getValidLabourPriceBookNames:(NSArray *)labourPbNames andLabourIdArray:(NSArray *)labourIdArray andCurrency:(NSString *)currency{
    
    NSString *tablename = kTableServicePricebook;
    NSString *priceBookActive = kServicePricebookActive;
    
    NSArray *fields = [NSArray arrayWithObjects:kId,@"Name", nil];
   
    DBCriteria *firstCriteria = [[DBCriteria alloc] initWithFieldName:priceBookActive operatorType:SQLOperatorEqual andFieldValue:@"true"];
    
    DBCriteria *criteria2 = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorIn andFieldValues:labourIdArray];
    DBCriteria *criteria3 = [[DBCriteria alloc] initWithFieldName:@"Name" operatorType:SQLOperatorIn andFieldValues:labourPbNames];
    
    
    NSString *advExpression = @"(1 and ( 2 or 3))";
    NSArray *transArray = [self getObjectsObjectName:tablename withDBCriterias:@[firstCriteria,criteria2,criteria3] withExpression:advExpression andFields:fields];
    
    
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    for (TransactionObjectModel *model in transArray) {
        [dataArray addObject:[model getFieldValueDictionary]];
    }
    return dataArray;
    
}

- (NSDictionary *)getPriceBookDictionaryWithProductArray:(NSArray *)productsArray andPriceBookNames:(NSArray *)partsPriceBookNames andPartsPriceBookIds:(NSArray *)partsPriceBookIdsArray andCurrency:(NSString *)currencyIsoCode{
    
   
    NSArray *tempArray =  [self getPriceBookObjectsForPriceBookIds:partsPriceBookIdsArray  OrPriceBookNames:partsPriceBookNames];
    
    NSMutableArray *priceBookIds = [[NSMutableArray alloc] init];
    for (int counter = 0; counter < [tempArray count]; counter++) {
        
        NSDictionary *pbDictioanry = [tempArray objectAtIndex:counter];
        NSString *identifier = [pbDictioanry objectForKey:@"Id"];
        if (identifier != nil) {
            [priceBookIds addObject:identifier];
        }
    }
    NSDictionary *tempDictionary = nil;
    if ([priceBookIds count] > 0) {
        /*get pricebook entry for these ids */
        NSArray *pricebookRecords =  [self getPriceBookEntryRecordsFor:priceBookIds andProductArray:productsArray andTableName:@"PricebookEntry" andCurrency:currencyIsoCode];
        tempDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"PARTSPRICING",@"key",pricebookRecords,@"data",nil];
        
    }
   
    return tempDictionary;
}

- (NSDictionary *)getPriceBookForLabourParts:(NSArray *)labourArray andLabourPbNames:(NSArray *)labourPbNames andLabourPbIds:(NSArray *)labourPbIds andCurrency:(NSString *)currency {
    
    NSArray *tempArray =  [self getValidLabourPriceBookNames:labourPbNames andLabourIdArray:labourPbIds andCurrency:currency];
    
    NSMutableArray *priceBookIds = [[NSMutableArray alloc] init];
    for (int counter = 0; counter < [tempArray count]; counter++) {
        
        NSDictionary *pbDictioanry = [tempArray objectAtIndex:counter];
        NSString *identifier = [pbDictioanry objectForKey:@"Id"];
        if (identifier != nil) {
            [priceBookIds addObject:identifier];
        }
    }
    NSDictionary *tempDictionary = nil;
    if ([priceBookIds count] > 0) {
        /*get pricebook entry for these ids */
        NSArray *pricebookRecords =  [self getPriceBookEntryForLabourArray:labourArray andPriceBookIds:priceBookIds andCurrency:currency];
        tempDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"LABORPRICING",@"key",pricebookRecords,@"data",nil];
        
    }
  
    return tempDictionary;
    
}

- (NSDictionary *)getReferenceToFieldsForObject:(NSString *)objectName {
    return  [self  getReferenceFieldsFor:objectName];
}




- (void)updateReferenceFields:(NSMutableDictionary *)fieldValueDictionary
            andObjectNameDict:(NSDictionary *)objectnameDict {
    SFMPageManager *dbService = [[SFMPageManager alloc] init];
    [dbService updateReferenceFieldDisplayValues:fieldValueDictionary andFieldObjectNames:objectnameDict];
    
}

- (NSArray *)getRecordWhereColumnNamesAndValues:(NSDictionary *)columnKeyAndValue
                                   andTableName:(NSString *)tableName {
    
    
    
    NSMutableArray *criterias = [[NSMutableArray alloc] init];
    for (NSString *columnName in columnKeyAndValue) {
        
        NSString *columnValue = [columnKeyAndValue objectForKey:columnName];
        DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:columnName operatorType:SQLOperatorEqual andFieldValue:columnValue];
        [criterias addObject:criteria];
    }
    
    NSArray *allTransObjects =  [self getObjectsAsNumbersObjectName:tableName withDBCriterias:criterias withExpression:nil andFields:nil];
    
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    for (TransactionObjectModel *model in allTransObjects) {
        [dataArray addObject:[model getFieldValueDictionary]];
    }
    return dataArray;
}

- (NSArray *)getNamedExpressionsForIds:(NSArray *)namedExpressionArray {
    
    if ([namedExpressionArray count] <= 0) {
        return nil;
    }
    
    NSDictionary *recordTypeDict = [self getRecordTypeIdsForRecordType:[NSArray arrayWithObjects:@"SVMX Rule",@"Expressions", nil]];
    
    NSString *recordTypeRule = [recordTypeDict objectForKey:@"SVMX Rule"];
    NSString *expressionRule = [recordTypeDict objectForKey:@"Expressions"];
    
    NSDictionary *expressionDictionary = [self getExpressionForRecordtypeId:recordTypeRule andExpressionIds:namedExpressionArray];
    
    NSMutableArray *expressionArray = [[NSMutableArray alloc] init];
    if ([expressionDictionary count] > 0) {
        for (int counter = 0; counter < [namedExpressionArray count]; counter++) {
            
            NSString *identifier = [namedExpressionArray objectAtIndex:counter];
            NSString *expression = [expressionDictionary objectForKey:identifier];
            
            NSArray *expressionComponenets =  [self getExpressionComponentsForExpressionId:identifier andExpression:expression andRecordId:expressionRule];
            if ([expressionComponenets count] > 0) {
                
                NSDictionary *dictionaryObj = nil;
                if (expression != nil) {
                    dictionaryObj = [[NSDictionary alloc] initWithObjectsAndKeys:identifier,@"key",expression,@"value",expressionComponenets,@"data", nil];
                }
                else {
                    dictionaryObj = [[NSDictionary alloc] initWithObjectsAndKeys:identifier,@"key",expressionComponenets,@"data", nil];
                    
                }
                [expressionArray addObject:dictionaryObj];
            }
            
        }
    }
    return expressionArray;
}

- (NSDictionary *)getExpressionForRecordtypeId:(NSString *)recordTypeRule
                           andExpressionIds :(NSArray *)namedExpressionArray {
    
    NSMutableString *tempString = [[NSMutableString alloc] initWithFormat:@"( "];
    NSMutableArray *criteriaArray = [[NSMutableArray alloc] init];
    for (int counter = 0; counter < [namedExpressionArray count]; counter++) {
        
        NSString *someExpr = [namedExpressionArray objectAtIndex:counter];
        if (counter == 0) {
             [tempString appendFormat:@" %d ",(counter + 1)];
        }
        else {
            [tempString appendFormat:@" OR %d",(counter + 1)];
        }
        DBCriteria *criteria = [[DBCriteria alloc]initWithFieldName:kId operatorType:SQLOperatorLike andFieldValue:someExpr];
        [criteriaArray addObject:criteria];
    }
    [tempString appendString:@" ) "];
    
    [tempString appendFormat:@" and  %d",(int)([criteriaArray count] + 1)];
    
    DBCriteria *criteria1 = [[DBCriteria alloc]initWithFieldName:kRecordTypeId operatorType:SQLOperatorEqual andFieldValue:recordTypeRule];
     [criteriaArray addObject:criteria1];
    
    NSString *tableName = [StringUtil appendOrgNameSpaceToString:@"__ServiceMax_Processes__c"];
    NSString *fieldName = [StringUtil appendOrgNameSpaceToString:@"__Advance_Expression__c"];
    
    
    NSArray *transactionModels = [self getObjectsObjectName:tableName withDBCriterias:criteriaArray withExpression:tempString andFields:@[fieldName,kId]];
    
    NSMutableDictionary *expressionDictionary = [[NSMutableDictionary alloc] init];
    for (TransactionObjectModel *model in transactionModels) {
        
        NSDictionary *modelDict = [model getFieldValueDictionary];
        NSString *advancedExpression = [modelDict objectForKey:fieldName];
        NSString *identifier = [modelDict objectForKey:kId];
        advancedExpression = (advancedExpression == nil)?@"":advancedExpression;
        [expressionDictionary setObject:advancedExpression forKey:identifier];
    }
    return expressionDictionary;
}

- (NSArray *) getExpressionComponentsForExpressionId:(NSString *)expressionId
                                       andExpression:(NSString *)expressionName
                                         andRecordId:(NSString *)recordTypeId{

    NSString *tableName = [StringUtil appendOrgNameSpaceToString:@"__SERVICEMAX_CONFIG_DATA__C"];
    NSArray *fields = [[NSArray alloc] initWithObjects:kConfigTableFieldName,kConfigTableOperator, kConfigTableOperand,kConfigTableSequence,kConfigTableExpType,kConfigTableExpRule,kId,nil];
    
  
    DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:kConfigTableExpRule operatorType:SQLOperatorStartsWith andFieldValue:expressionId];
    DBCriteria *criteria2 = [[DBCriteria alloc] initWithFieldName:kRecordTypeId operatorType:SQLOperatorEqual andFieldValue:recordTypeId];
   NSArray *transactionModels =  [self getObjectsObjectName:tableName withDBCriterias:@[criteria1,criteria2] withExpression:nil andFields:fields];
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    for (TransactionObjectModel *model in transactionModels) {
        [dataArray addObject:[model getFieldValueDictionary]];
    }
    return dataArray;
}

- (NSArray *)getProductRecords:(NSArray *)productIdentifiers {
   DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorIn andFieldValues:productIdentifiers];
    NSString *tableName = @"Product2";
    NSArray *fields = [[NSArray alloc] initWithObjects:@"Id", [StringUtil appendOrgNameSpaceToString:@"__Product_Line__c"], @"Family", [StringUtil appendOrgNameSpaceToString:@"__Product_Type__c"], nil];
   
    NSArray *transactionModels =  [self getObjectsObjectName:tableName withDBCriterias:@[criteria1] withExpression:nil andFields:fields];
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    for (TransactionObjectModel *model in transactionModels) {
        [dataArray addObject:[model getFieldValueDictionary]];
    }
    return dataArray;
}

#pragma mark -
#pragma mark Get get price code snippet


- (NSString *)getPriceCodeSnippet:(NSString *)codeSnippetName {
    NSDictionary *codeSnippetDictMain = [self getCodeSnippetForNameOrId:codeSnippetName];
    
    NSString *codeSnippetId =  [codeSnippetDictMain objectForKey:@"Id"];
    NSString *codeSnippetMain = [codeSnippetDictMain objectForKey:kCodeSnippetData];
    NSMutableString *codeSnippetFinal = nil;
    if (![StringUtil isStringEmpty:codeSnippetId] && codeSnippetMain != nil) {
        codeSnippetFinal =  [[NSMutableString alloc] initWithString:codeSnippetMain];
        
        while (![StringUtil isStringEmpty:codeSnippetId]) {
            
            /*get the reference id from manifest */
            NSString *snippetId =  [self getCodeSnippetRefererenceForId:codeSnippetId];
            //Defect Fix:025261 , checking nil for snippetId, if there is no longer reference for snippet in manifest table
            if (snippetId !=nil)
            {
                NSDictionary *tempDictionary =  [self getCodeSnippetForNameOrId:snippetId];
                if ([tempDictionary count] > 0) {
                    codeSnippetId = [tempDictionary objectForKey:@"Id"];//instead of codesnipper id we shd use only referernce id
                    NSString *tempStr = [tempDictionary objectForKey:kCodeSnippetData];
                    if(![StringUtil isStringEmpty:codeSnippetId] && ![StringUtil isStringEmpty:tempStr] ) {
                        [codeSnippetFinal appendFormat:@" %@",tempStr];
                    }
                    else {
                        codeSnippetId = nil;
                    }
                }
                else {
                    codeSnippetId = nil;
                }
            }
            else
            {
                codeSnippetId = nil;
            }
          
            
        }
    }
    return codeSnippetFinal;
}
- (NSDictionary *)getCodeSnippetForNameOrId:(NSString *)codeSnippetNameOrId {
    
    NSString *tableName = kTableCodeSnippet;
    NSArray *fields = [NSArray arrayWithObjects:kId,kCodeSnippetData,nil];
    
    DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:kCodeSnippetName operatorType:SQLOperatorEqual andFieldValue:codeSnippetNameOrId];
    
    DBCriteria *criteria2 = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorEqual andFieldValue:codeSnippetNameOrId];
    NSString *advExpression = @"(1 or 2)";
    
    NSArray *transArray = [self getObjectsObjectName:tableName withDBCriterias:@[criteria1,criteria2] withExpression:advExpression andFields:fields];
    for (TransactionObjectModel *model in transArray) {
       return [model getFieldValueDictionary];
    }
    return nil;
    
}
- (NSString *)getCodeSnippetRefererenceForId:(NSString *)codeSnippetReference {
    NSString *fieldName = kCodeSnippetReference;
    NSString *objectname = kTableCodeManifest;
    NSString *codeSnipptFn = kTableCodeSnippet;
    
    DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:codeSnipptFn operatorType:SQLOperatorEqual andFieldValue:codeSnippetReference];
    
    DBCriteria *criteria2 = [[DBCriteria alloc] initWithFieldName:fieldName operatorType:SQLOperatorIsNotNull andFieldValue:nil];
    
    
    NSArray *transArray = [self getObjectsObjectName:objectname withDBCriterias:@[criteria1,criteria2] withExpression:nil andFields:@[fieldName]];
    
    if ([transArray count] > 0  ) {
        TransactionObjectModel *model = [transArray objectAtIndex:0];
        NSDictionary *valueDictionary =  [model getFieldValueDictionary];
        return  [valueDictionary objectForKey:fieldName];
    }
    return nil;
}


- (NSString *)getDisplayValueForPicklist:(NSString *)pickListValue
                           withFieldName:(NSString *)fieldName
                           andObjectName:(NSString *)objetcName {
    
     DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:@"objectName" operatorType:SQLOperatorEqual andFieldValue:objetcName];
    DBCriteria *criteria2 = [[DBCriteria alloc] initWithFieldName:@"fieldName" operatorType:SQLOperatorEqual andFieldValue:fieldName];
    DBCriteria *criteria3 = [[DBCriteria alloc] initWithFieldName:@"value" operatorType:SQLOperatorEqual andFieldValue:pickListValue];
    
   
    NSString *name = @"label";
    NSString *tableName = @"SFPickList";
    NSArray *transArray = [self getObjectsObjectName:tableName withDBCriterias:@[criteria1,criteria2,criteria3] withExpression:nil andFields:@[name]];
    
    if ([transArray count] > 0  ) {
        TransactionObjectModel *model = [transArray objectAtIndex:0];
        NSDictionary *valueDictionary =  [model getFieldValueDictionary];
        return  [valueDictionary objectForKey:name];
    }
    return nil;
}
#pragma mark -Get price 2.0

- (NSDictionary *)getProductServiceWorkDetail:(NSString *)wordOrderId andWorkorderSfid:(NSString *)woSfid{
    
    NSArray *recordTypes = [NSArray arrayWithObjects:@"Products Serviced",nil];
    NSDictionary *recordTypeIds =  [self getRecordTypeIdsForRecordType:recordTypes];
    
    NSMutableDictionary * warrantyAndSfid = [[NSMutableDictionary alloc] init];
    NSString *serviceRecordTypeId = [recordTypeIds objectForKey:@"Products Serviced"];
    
    NSString * sfId = @"", *warrantyId = nil;
    if([serviceRecordTypeId length ] > 0)
    {
        NSString *tableName = ORG_NAME_SPACE@"__Service_Order_Line__c";
        NSString *warrantyField = ORG_NAME_SPACE@"__Product_Warranty__c";
        NSArray *fields = [NSArray arrayWithObjects:kLocalId,warrantyField,nil];
        
        DBCriteria *criteria1 =[[DBCriteria alloc] initWithFieldName:kRecordTypeId operatorType:SQLOperatorEqual andFieldValue:serviceRecordTypeId];
        DBCriteria *criteria2 =[[DBCriteria alloc] initWithFieldName:kWorkOrderTableName operatorType:SQLOperatorEqual andFieldValue:wordOrderId];
        
        DBCriteria *criteria3 =[[DBCriteria alloc] initWithFieldName:kWorkOrderTableName operatorType:SQLOperatorEqual andFieldValue:woSfid];
        
        NSArray *transObjects = [self getObjectsAsNumbersObjectName:tableName withDBCriterias:@[criteria1,criteria2,criteria3] withExpression:@"( 1 AND (2 OR 3))" andFields:fields];
        
        for (TransactionObjectModel *modle in transObjects) {
            
            NSDictionary *valueDictionary = [modle getFieldValueDictionary];
            warrantyId = [valueDictionary objectForKey:warrantyField];
            sfId = [valueDictionary objectForKey:kLocalId];
            if(warrantyId.length > 3 && sfId != nil) {
                [warrantyAndSfid setObject:warrantyId forKey:sfId];
            }
            
        }
    }
    return warrantyAndSfid;
}

- (NSDictionary *)getWorkDetailForProductServiceArray:(NSArray *)productServiceIds
                                      andWorkOrderIds:(NSString *)wordOrderId andSfid:(NSString *)wosfid{
    
    NSString *workDetailColumnName = ORG_NAME_SPACE@"__Work_Detail__c";
    
    NSMutableDictionary * serviceIdsAndSfid = [[NSMutableDictionary alloc] init];
    NSDictionary *sfidDict =  [self getAllSfidsForLocalIds:productServiceIds];
   
    
    NSString * sfId = @"", *serviceId = nil;
    if(wordOrderId != nil || [wordOrderId length ] != 0)
    {
         DBCriteria *criteria1 =[[DBCriteria alloc] initWithFieldName:workDetailColumnName operatorType:SQLOperatorIn andFieldValues:productServiceIds];
        DBCriteria *criteria2 =[[DBCriteria alloc] initWithFieldName:workDetailColumnName operatorType:SQLOperatorIn andFieldValues:[sfidDict allKeys]];
        
        DBCriteria *criteria3 =[[DBCriteria alloc] initWithFieldName:kWorkOrderTableName operatorType:SQLOperatorEqual  andFieldValue:wordOrderId];
         DBCriteria *criteria4 =[[DBCriteria alloc] initWithFieldName:kWorkOrderTableName operatorType:SQLOperatorEqual  andFieldValue:wosfid];
        
        NSString *advancedExpression = @"( (1 or 2) and (3 or 4))";
        
         NSArray *transObjects = [self getObjectsAsNumbersObjectName:kWorkOrderDetailTableName withDBCriterias:@[criteria1,criteria2,criteria3,criteria4] withExpression:advancedExpression andFields:@[kLocalId,workDetailColumnName]];
        
        for (TransactionObjectModel *modle in transObjects) {
            
            NSDictionary *valueDictionary = [modle getFieldValueDictionary];
            sfId = [valueDictionary objectForKey:kLocalId];
            serviceId = [valueDictionary objectForKey:workDetailColumnName];
            NSString *serviceLocalId = nil;
            if(serviceId != nil && sfId != nil)
            {
                if (serviceId.length < 30) {
                    serviceLocalId = [sfidDict objectForKey:serviceId];
                    if (serviceLocalId != nil) {
                        serviceId = serviceLocalId;
                    }
                }
                NSMutableArray *workDetailIds = [serviceIdsAndSfid objectForKey:serviceId];
                if(workDetailIds == nil){
                    workDetailIds = [[NSMutableArray alloc] init];
                    [serviceIdsAndSfid setObject:workDetailIds forKey:serviceId];
                }
                [workDetailIds addObject:sfId];
            }
        }
    }
    return serviceIdsAndSfid;
}

- (NSDictionary *)getAllSfidsForLocalIds:(NSArray *)localIds {
    
    DBCriteria *criteria =[[DBCriteria alloc] initWithFieldName:kLocalId operatorType:SQLOperatorIn andFieldValues:localIds];
    NSMutableDictionary *idsDict = [NSMutableDictionary dictionary];
    NSString * sfId = @"",*localId = @"";
    NSArray *transObjects = [self getObjectsAsNumbersObjectName:kWorkOrderDetailTableName withDBCriterias:@[criteria] withExpression:nil andFields:@[kId,kLocalId]];
    
    for (TransactionObjectModel *modle in transObjects) {
        
        NSDictionary *valueDictionary = [modle getFieldValueDictionary];
        localId = [valueDictionary objectForKey:kLocalId];
        sfId = [valueDictionary objectForKey:kId];
        if(localId.length > 3 && sfId != nil) {
            [idsDict setObject:localId forKey:sfId];
        }
        
    }
    return idsDict;
}

- (NSMutableDictionary *)getAllRecordForSfIds:(NSArray *)allIds andTableName:(NSString *)tableName {
    
    NSMutableDictionary *allRecordsDictionary = [[NSMutableDictionary alloc] init];
    
    DBCriteria *criteria =[[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorIn andFieldValues:allIds];
    
    NSArray *transObjects = [self getObjectsAsNumbersObjectName:tableName withDBCriterias:@[criteria] withExpression:nil andFields:nil];
    
    for (TransactionObjectModel *modle in transObjects) {
        
        NSDictionary *valueDictionary = [modle getFieldValueDictionary];
        NSString *sfId = [valueDictionary objectForKey:kId];
        if(sfId != nil){
            [allRecordsDictionary setObject:valueDictionary forKey:sfId];
        }

    }

    return allRecordsDictionary;
}

#pragma mark - PS Lines Entitlement


-(NSArray *)getPSLineRecordsForHeaderRecord:(NSString *)sfId andObjectname:(NSString*)objectname {
    NSString *tableName = ORG_NAME_SPACE@"__Service_Order_Line__c";
    NSString *columname = ORG_NAME_SPACE@"__Service_Order__c";
    NSArray *fields = @[kId, kSfDTRecordTypeId];
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:columname operatorType:SQLOperatorEqual andFieldValue:sfId];
    NSArray *transArray =  [self getObjectsObjectName:tableName withDBCriterias:@[criteria] withExpression:nil andFields:fields];
    
    NSMutableArray *psLinesArray = [[NSMutableArray alloc] init];
    
    NSArray *recordTypes = [NSArray arrayWithObjects:@"Products Serviced",nil];
    NSDictionary *recordTypeIds =  [self getRecordTypeIdsForRecordType:recordTypes];
    NSString *serviceRecordTypeId = [recordTypeIds objectForKey:@"Products Serviced"];
    
    for (TransactionObjectModel *model in transArray) {
        NSDictionary *recordDict = model.getFieldValueDictionary;
        NSString *recordType = [recordDict objectForKey:kSfDTRecordTypeId];
        if (recordType && [recordType isEqualToString:serviceRecordTypeId]) {
            [psLinesArray addObject:recordDict];
        }
    }
    
    return psLinesArray;
}


- (NSDictionary *)getEntitlementHistoryForPSLine:(NSString *)psLineId {
    
    NSString *entitlementHistorytableName = ORG_NAME_SPACE@"__Entitlement_History__c";
    NSString *workDetailColumnName = ORG_NAME_SPACE@"__Work_Detail__c";
    
    DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:workDetailColumnName operatorType:SQLOperatorEqual andFieldValue:psLineId];
    DBCriteria *criteria2 = [[DBCriteria alloc] initWithFieldName:ORG_NAME_SPACE@"__Inactive_Date__c" operatorType:SQLOperatorIsNull andFieldValue:nil];
    
    
    NSArray *transArray =  [self getObjectsObjectName:entitlementHistorytableName withDBCriterias:@[criteria1,criteria2] withExpression:nil andFields:nil];
    
    if ([transArray count] > 0  ) {
        TransactionObjectModel *model = [transArray objectAtIndex:0];
        NSDictionary *valueDictionary =  [model getFieldValueDictionary];
        return  valueDictionary;
    }
    
    return nil;
}


-(NSDictionary *)getPSLineSconRecordForId:(NSString *)sconId {
    
    NSString *sconTableName = ORG_NAME_SPACE@"__Service_Contract__c";
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorEqual andFieldValue:sconId];
    
    NSArray *fields = @[ORG_NAME_SPACE@"__Default_Travel_Price__c", ORG_NAME_SPACE@"__Default_Travel_Unit__c", ORG_NAME_SPACE@"__Service_Pricebook__c", ORG_NAME_SPACE@"__Default_Parts_Price_Book__c", ORG_NAME_SPACE@"__Labor_Rounding_Type__c", ORG_NAME_SPACE@"__Travel_Rounding_Type__c", @"Id"];
    
    NSArray *transArray =  [self getObjectsObjectName:sconTableName withDBCriterias:@[criteria] withExpression:nil andFields:fields];
    
    if ([transArray count] > 0  ) {
        TransactionObjectModel *model = [transArray objectAtIndex:0];
        NSDictionary *valueDictionary =  [model getFieldValueDictionary];
        
        NSDictionary *attributeDict = [NSDictionary dictionaryWithObjects:@[sconTableName, @""] forKeys:@[@"type", @"url"]];
        NSMutableDictionary *finalDict = [NSMutableDictionary dictionaryWithDictionary:valueDictionary];
        [finalDict setObject:attributeDict forKey:@"attributes"];
        return  finalDict;
    }
    
    return nil;
}

-(NSArray *)getPSLinePartsPricingForId:(NSString *)sconId {
    NSString *partsPricingTableName = ORG_NAME_SPACE@"__Parts_Pricing__c";
    NSString *sconColumnName = ORG_NAME_SPACE@"__Service_Contract__c";
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:sconColumnName operatorType:SQLOperatorEqual andFieldValue:sconId];
    
    NSArray *fields = @[ORG_NAME_SPACE@"__Product__c", ORG_NAME_SPACE@"__Service_Contract__c", ORG_NAME_SPACE@"__Price_Per_Unit__c", @"Id"];
    NSArray *transArray =  [self getObjectsObjectName:partsPricingTableName withDBCriterias:@[criteria] withExpression:nil andFields:fields];
    return transArray;
}

-(NSArray *)getPSLinePartsDiscountForId:(NSString *)sconId {
    NSString *partsDiscountTableName = ORG_NAME_SPACE@"__Parts_Discount__c";
    NSString *sconColumnName = ORG_NAME_SPACE@"__Service_Contract__c";
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:sconColumnName operatorType:SQLOperatorEqual andFieldValue:sconId];
    
    NSArray *fields = @[ORG_NAME_SPACE@"__Discount_Percentage__c", ORG_NAME_SPACE@"__Product__c", ORG_NAME_SPACE@"__Service_Contract__c", @"Id"];
    NSArray *transArray =  [self getObjectsObjectName:partsDiscountTableName withDBCriterias:@[criteria] withExpression:nil andFields:fields];
    return transArray;
}

-(NSArray *)getPSLineLaborPricingForId:(NSString *)sconId {
    NSString *laborPricingTableName = ORG_NAME_SPACE@"__Labor_Pricing__c";
    NSString *sconColumnName = ORG_NAME_SPACE@"__Service_Contract__c";
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:sconColumnName operatorType:SQLOperatorEqual andFieldValue:sconId];
    
    NSArray *fields = @[ORG_NAME_SPACE@"__Activity_Type__c", ORG_NAME_SPACE@"__Service_Contract__c", ORG_NAME_SPACE@"__Unit__c", ORG_NAME_SPACE@"__Regular_Rate__c", ORG_NAME_SPACE@"__Activity__c", ORG_NAME_SPACE@"__Minimum_Labor__c", @"Id"];
    NSArray *transArray =  [self getObjectsObjectName:laborPricingTableName withDBCriterias:@[criteria] withExpression:nil andFields:fields];
    return transArray;
}

-(NSArray *)getPSLineExpensePricingForId:(NSString *)sconId {
    NSString *expensePricingTableName = ORG_NAME_SPACE@"__Expense_Pricing__c";
    NSString *sconColumnName = ORG_NAME_SPACE@"__Service_Contract__c";
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:sconColumnName operatorType:SQLOperatorEqual andFieldValue:sconId];
    
    NSArray *fields = @[ORG_NAME_SPACE@"__Rate__c", ORG_NAME_SPACE@"__Rate_Type__c", ORG_NAME_SPACE@"__Service_Contract__c", ORG_NAME_SPACE@"__Expense_Type__c", @"Id"];
    NSArray *transArray =  [self getObjectsObjectName:expensePricingTableName withDBCriterias:@[criteria] withExpression:nil andFields:fields];
    return transArray;
}



-(NSArray *)getPSLinePartsPBForId:(NSString *)sconId {
    
    NSString *sconTableName = ORG_NAME_SPACE@"__Service_Contract__c";
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorEqual andFieldValue:sconId];
    NSArray *fields = @[ORG_NAME_SPACE@"__Default_Parts_Price_Book__c"];
    NSArray *transArray =  [self getObjectsObjectName:sconTableName withDBCriterias:@[criteria] withExpression:nil andFields:fields];
    
    if ([transArray count] > 0  ) {
        TransactionObjectModel *model = [transArray objectAtIndex:0];
        NSDictionary *valueDictionary =  [model getFieldValueDictionary];
        NSString *partsPriceBookId = [valueDictionary objectForKey:ORG_NAME_SPACE@"__Default_Parts_Price_Book__c"];
        
        
        NSString *priceBookTableName = @"Pricebook2";
        NSString *idColumn = kId;
        DBCriteria *pbCriteria = [[DBCriteria alloc] initWithFieldName:idColumn operatorType:SQLOperatorEqual andFieldValue:partsPriceBookId];
        NSArray *pbfields = @[@"Id", @"Name"];
        NSArray *pbResults =  [self getObjectsObjectName:priceBookTableName withDBCriterias:@[pbCriteria] withExpression:nil andFields:pbfields];
        
        if ([pbResults count] > 0) {
            TransactionObjectModel *model = [pbResults objectAtIndex:0];
            NSDictionary *pbDictionary =  [model getFieldValueDictionary];
            
            NSString *pbEntryTableName = @"PricebookEntry";
            NSString *priceBook2Column = @"Pricebook2Id";
            DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:priceBook2Column operatorType:SQLOperatorEqual andFieldValue:partsPriceBookId];
            
            NSArray *fields = @[@"Name", @"UnitPrice", @"UseStandardPrice", @"Product2Id", @"Pricebook2Id", @"Id"];
            NSArray *transArray =  [self getObjectsObjectName:pbEntryTableName withDBCriterias:@[criteria] withExpression:nil andFields:fields];
            
            for (TransactionObjectModel *model in transArray) {
                [model.getFieldValueMutableDictionary setObject:pbDictionary forKey:@"Pricebook2"];
            }
            return transArray;
        }
    }
    return nil;
}

-(NSArray *)getRelatedDetailRecordsForPSline:(NSString *)psLineId {
    NSString *tableName = ORG_NAME_SPACE@"__Service_Order_Line__c";
    NSString *workDetailColumnName = ORG_NAME_SPACE@"__Work_Detail__c";
    NSArray *fields = @[kId];
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:workDetailColumnName operatorType:SQLOperatorEqual andFieldValue:psLineId];
    NSArray *transArray =  [self getObjectsObjectName:tableName withDBCriterias:@[criteria] withExpression:nil andFields:fields];
    
    NSMutableArray *relatedRecords = [[NSMutableArray alloc] init];
    
    for (TransactionObjectModel *model in transArray) {
        NSDictionary *recordDict = model.getFieldValueDictionary;
        NSString *sfId = [recordDict objectForKey:kId];
        [relatedRecords addObject:sfId];
    }
    
    return relatedRecords;
}


-(NSDictionary *)getPSLineWarrantyRecordForId:(NSString *)warrantyId {
    
    NSString *warrantyTableName = ORG_NAME_SPACE@"__Warranty__c";
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorEqual andFieldValue:warrantyId];
    
    NSArray *fields = @[ORG_NAME_SPACE@"__Time_Covered__c", ORG_NAME_SPACE@"__Material_Covered__c", ORG_NAME_SPACE@"__Expenses_Covered__c", @"Id"];
    
    NSArray *transArray =  [self getObjectsObjectName:warrantyTableName withDBCriterias:@[criteria] withExpression:nil andFields:fields];
    
    if ([transArray count] > 0  ) {
        TransactionObjectModel *model = [transArray objectAtIndex:0];
        NSDictionary *valueDictionary =  [model getFieldValueDictionary];
        
        NSDictionary *attributeDict = [NSDictionary dictionaryWithObjects:@[warrantyTableName, @""] forKeys:@[@"type", @"url"]];
        NSMutableDictionary *finalDict = [NSMutableDictionary dictionaryWithDictionary:valueDictionary];
        [finalDict setObject:attributeDict forKey:@"attributes"];
        return  finalDict;
    }
    
    return nil;
}


#pragma mark End
@end
