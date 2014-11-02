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

@implementation PriceCalculationDBService

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

- (NSArray *)getAllRecordsFromObjectName:(NSString *)objectName
                               forFields:(NSArray *)fields
                           withCriterias:(NSArray *)criterias
                           andModelClass:(Class)modelClass {
    
    id  <CommonServiceDAO> service = [[CommonServices alloc] init];
    NSArray *allModels =  [service fetchDataForFields:fields criterias:criterias objectName:objectName andModelClass:modelClass];
    return allModels;
}
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

//
//- (NSDictionary *)preparePBEstimateId:(NSString *)estimateValue
//                        andUsageValue:(NSString *)usageValue
//                               andKey:(NSString *)key
//                      andRecordTypeId:(NSDictionary *)recordTypeIds {
//    
//    NSString *usageRecordTypeId = [recordTypeIds objectForKey:@"Usage/Consumption"];
//    NSString *estimateRecordTypeId = [recordTypeIds objectForKey:@"Estimate"];
//    
//    if (usageRecordTypeId != nil) {
//        NSMutableArray *arrayTemp = [[NSMutableArray alloc] init];
//        
//        if (usageValue != nil) {
//            NSArray *pbArray = [self getPriceBookObjectsForPriceBookIds:[NSArray arrayWithObject:usageValue] OrPriceBookNames:nil];
//            for (int counter = 0; counter < [pbArray count ]; counter++) {
//                
//                NSDictionary *pbBook = [pbArray objectAtIndex:counter];
//                NSString *finalValue = [pbBook objectForKey:@"Id"];
//                if (finalValue != nil) {
//                    NSDictionary *tempDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:finalValue,@"value", usageRecordTypeId,@"key", nil];
//                    [arrayTemp addObject:tempDictionary];
//                        tempDictionary = nil;
//                }
//            }
//        }
//        
//        if (estimateRecordTypeId != nil && estimateValue != nil) {
//            
//            NSArray *pbArray = [self getPriceBookObjectsForPriceBookIds:[NSArray arrayWithObject:estimateValue] OrPriceBookNames:nil];
//            for (int counter = 0; counter < [pbArray count ]; counter++) {
//                NSDictionary *pbBook = [pbArray objectAtIndex:counter];
//                NSString *finalValue = [pbBook objectForKey:@"Id"];
//                if (finalValue != nil) {
//                    NSDictionary *tempDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:finalValue, @"value",estimateRecordTypeId,@"key", nil];
//                    [arrayTemp addObject:tempDictionary];
//                    tempDictionary = nil;
//                }
//            }
//        }
//        NSDictionary *tempDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:arrayTemp,@"valueMap",key,@"key", nil];
//        return tempDictionary;
//    }
//    return nil;
//}
//
//- (NSDictionary *)preparePBLaourEstimateId:(NSString *)estimateValue
//                             andUsageValue:(NSString *)usageValue
//                                    andKey:(NSString *)key
//                           andRecordTypeId:(NSDictionary *)recordTypeIds {
//    
//    NSString *usageRecordTypeId = [recordTypeIds objectForKey:@"Usage/Consumption"];
//    NSString *estimateRecordTypeId = [recordTypeIds objectForKey:@"Estimate"];
//    
//    if (usageRecordTypeId != nil) {
//        NSMutableArray *arrayTemp = [[NSMutableArray alloc] init];
//        
//        if (usageValue != nil) {
//            NSArray *pbArray = [self getPriceBookObjectsForLabourPriceBookIds:[NSArray arrayWithObject:usageValue] OrPriceBookNames:nil];
//            for (int counter = 0; counter < [pbArray count ]; counter++) {
//                
//                NSDictionary *pbBook = [pbArray objectAtIndex:counter];
//                NSString *finalValue = [pbBook objectForKey:@"Id"];
//                if (finalValue != nil) {
//                    NSDictionary *tempDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:finalValue,@"value", usageRecordTypeId,@"key", nil];
//                    [arrayTemp addObject:tempDictionary];
//                   
//                }
//            }
//        }
//        
//        if (estimateRecordTypeId != nil && estimateValue != nil) {
//            
//            NSArray *pbArray = [self getPriceBookObjectsForLabourPriceBookIds:[NSArray arrayWithObject:estimateValue] OrPriceBookNames:nil];
//            for (int counter = 0; counter < [pbArray count ]; counter++) {
//                NSDictionary *pbBook = [pbArray objectAtIndex:counter];
//                NSString *finalValue = [pbBook objectForKey:@"Id"];
//                if (finalValue != nil) {
//                    NSDictionary *tempDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:finalValue,@"value", estimateRecordTypeId,@"key", nil];
//                    [arrayTemp addObject:tempDictionary];
//                     tempDictionary = nil;
//                }
//            }
//        }
//        NSDictionary *tempDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:arrayTemp,@"valueMap",key,@"key", nil];
//        return tempDictionary;
//    }
//    return nil;
//}
//
//- (NSDictionary *)getEntitlementHistoryForWorkorder:(NSString *)workOrderId {
//    
//    NSString *tableName = [SMXiPhone_Utility appendOrgNameSpaceToString:@"__Entitlement_History__c"];
//    
//    NSString *whereClause = [NSString  stringWithFormat:@" %@__Service_Order__c = '%@' and ( %@__Inactive_Date__c = \"\" OR trim(%@__Inactive_Date__c) = '')",ORG_NAME_SPACE,workOrderId,ORG_NAME_SPACE,ORG_NAME_SPACE];
//    
//      NSDictionary *allFieldsOfTable = [self getAllFieldsOfTable:tableName];
//   NSArray *dataRecords =  [self getRecordsForFields:[allFieldsOfTable allKeys] forObjectname:tableName andWhereClause:whereClause];
//    if ([dataRecords count] > 0) {
//        return [dataRecords objectAtIndex:0];
//    }
//    return nil;
//}
//
//- (NSDictionary *)getAllFieldsOfTable:(NSString *)tableName {
//    SMXiPhone_ObjectDefinitionService *objectDefn = [[SMXiPhone_ObjectDefinitionService alloc] init];
//    return [objectDefn getFieldNameAndTypeForObject:tableName];
//}
//
//- (NSMutableDictionary *)getRecordForId:(NSString *)sfId andObjectName:(NSString *)objectName{
//   
//    
//    NSString *whereClause = [NSString  stringWithFormat:@" Id = '%@' OR local_id = '%@' ",sfId,sfId];
//    
//    NSDictionary *allFieldsOfTable = [self getAllFieldsOfTable:objectName];
//    NSArray *dataRecords =  [self getRecordsForFields:[allFieldsOfTable allKeys] forObjectname:objectName andWhereClause:whereClause];
//    if ([dataRecords count] > 0) {
//        return [dataRecords objectAtIndex:0];
//    }
//    return nil;
//
//}
//
//
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
//
//- (NSArray *)getRecordWhereColumnNamesAndValues:(NSDictionary *)columnKeyAndValue
//                                   andTableName:(NSString *)tableName {
//    
//    NSDictionary *allFieldsOfTable = [self getAllFieldsOfTable:tableName];
//    NSArray *allColumnNames = [allFieldsOfTable  allKeys];
//    NSString *allColumnNamesString = [SMXiPhone_Utility  getConcatenatedStringFromArray:allColumnNames withSingleQuotesAndBraces:NO];
//    
//    NSMutableString *someString = [[NSMutableString alloc] init];
//    NSArray *allKeys = [columnKeyAndValue allKeys];
//    NSInteger counter = 0;
//    for (NSString *columnKey in allKeys) {
//        NSString *columnValue = [columnKeyAndValue objectForKey:columnKey];
//        if (counter > 0) {
//            [someString appendFormat:@" and "];
//        }
//        counter++;
//       [someString appendFormat:@"%@ = '%@'",columnKey,columnValue];
//        
//    }
//    
//    NSString *sqlQuery = [NSString  stringWithFormat:@"select %@ from '%@' where %@",allColumnNamesString,tableName,someString];
//
//    
//    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
//    sqlite3_stmt *selectStmt = nil;
//    if(synchronized_sqlite3_prepare_v2([[SMXiPhone_Database sharedDataBase] databaseObject  ], [sqlQuery UTF8String], -1, &selectStmt, nil) == SQLITE_OK  )
//    {
//        
//        while(synchronized_sqlite3_step(selectStmt) == SQLITE_ROW)
//        {
//            NSMutableDictionary *recordDictionary = [[NSMutableDictionary alloc] init];
//            
//            NSString * tempString = @"";
//            for(int counter = 0;counter < [allColumnNames count];counter++) {
//                
//                tempString = [self extractTextFromSqliteStmt:selectStmt AtIndex:counter];
//                if (tempString != nil && counter < [allColumnNames count]) {
//                    NSString *fieldName = [allColumnNames objectAtIndex:counter];
//                    NSString *fieldType = [allFieldsOfTable objectForKey:fieldName];
//                    
//                    id someObject =  [self getTheProperObjectTypeForFieldType:fieldType andFieldValue:tempString];
//                    if (someObject != nil) {
//                        [recordDictionary setObject:someObject forKey:fieldName];
//                    }
//                }
//            }
//            NSDictionary *tempDict = [[NSDictionary alloc] initWithObjectsAndKeys:tableName,@"type", nil];
//            [recordDictionary setObject:tempDict forKey:@"attributes"];
//            [dataArray addObject:recordDictionary];
//        }
//		synchronized_sqlite3_finalize(selectStmt);
//    }
//    return dataArray;
//}
//
//- (NSArray *)getNamedExpressionsForIds:(NSArray *)namedExpressionArray {
//    
//    if ([namedExpressionArray count] <= 0) {
//        return nil;
//    }
//    NSMutableString *tempString = [[NSMutableString alloc] init];
//    for (int counter = 0; counter < [namedExpressionArray count]; counter++) {
//        
//        NSString *someExpr = [namedExpressionArray objectAtIndex:counter];
//        if (counter == 0) {
//            [tempString appendFormat:@"Id LIKE '%@%%'",someExpr];
//        }
//        else {
//            [tempString appendFormat:@" OR Id LIKE '%@%%'",someExpr];
//        }
//    }
//    
//    NSString *concatenatedExpId = [NSString stringWithFormat:@"( %@ )",tempString];
//    
//    
//    
//    NSDictionary *recordTypeDict = [self getRecordTypeIdsForRecordType:[NSArray arrayWithObjects:@"SVMX Rule",@"Expressions", nil]];
//    
//    NSString *recordTypeRule = [recordTypeDict objectForKey:@"SVMX Rule"];
//    NSString *expressionRule = [recordTypeDict objectForKey:@"Expressions"];
//    
//    NSDictionary *expressionDictionary = [self getExpressionForRecordtypeId:recordTypeRule andExpressionIdStr:concatenatedExpId];
//    
//    NSMutableArray *expressionArray = [[NSMutableArray alloc] init];
//    if ([expressionDictionary count] > 0) {
//        for (int counter = 0; counter < [namedExpressionArray count]; counter++) {
//            
//            NSString *identifier = [namedExpressionArray objectAtIndex:counter];
//            NSString *expression = [expressionDictionary objectForKey:identifier];
//            
//            NSArray *expressionComponenets =  [self getExpressionComponentsForExpressionId:identifier andExpression:expression andRecordId:expressionRule];
//            if ([expressionComponenets count] > 0) {
//                
//                NSDictionary *dictionaryObj = nil;
//                if (expression != nil) {
//                    dictionaryObj = [[NSDictionary alloc] initWithObjectsAndKeys:identifier,@"key",expression,@"value",expressionComponenets,@"data", nil];
//                }
//                else {
//                    dictionaryObj = [[NSDictionary alloc] initWithObjectsAndKeys:identifier,@"key",expressionComponenets,@"data", nil];
//                    
//                }
//                [expressionArray addObject:dictionaryObj];
//            }
//            
//        }
//    }
//    return expressionArray;
//}
//
//- (NSDictionary *)getExpressionForRecordtypeId:(NSString *)recordTypeRule
//                           andExpressionIdStr :(NSString *)concatenatedExpId {
//    
//    NSString *tableName = [SMXiPhone_Utility appendOrgNameSpaceToString:@"__ServiceMax_Processes__c"];
//    NSString *fieldName = [SMXiPhone_Utility appendOrgNameSpaceToString:@"__Advance_Expression__c"];
//    NSString *sqlQuery = [NSString stringWithFormat:@"Select %@ ,Id from %@ where %@ and recordTypeId = '%@'",fieldName,tableName,concatenatedExpId,recordTypeRule];
//    
//    sqlite3_stmt *selectStmt = nil;
//    NSMutableDictionary *expressionDictionary = [[NSMutableDictionary alloc] init ];
//    if(synchronized_sqlite3_prepare_v2([[SMXiPhone_Database sharedDataBase] databaseObject], [sqlQuery UTF8String], -1, &selectStmt, nil) == SQLITE_OK  )
//    {
//        while(synchronized_sqlite3_step(selectStmt) == SQLITE_ROW) {
//            
//            NSString *identifier = nil, *advancedExpression = nil;
//            
//            advancedExpression = [self extractTextFromSqliteStmt:selectStmt AtIndex:0];
//            identifier = [self extractTextFromSqliteStmt:selectStmt AtIndex:1];
//            advancedExpression = (advancedExpression == nil)?@"":advancedExpression;
//            [expressionDictionary setObject:advancedExpression forKey:identifier];
//            
//        }
//    }
//    synchronized_sqlite3_finalize(selectStmt);
//    return expressionDictionary;
//}
//
//- (NSArray *) getExpressionComponentsForExpressionId:(NSString *)expressionId
//                                       andExpression:(NSString *)expressionName
//                                         andRecordId:(NSString *)recordTypeId{
//
//    NSString *tableName = [SMXiPhone_Utility appendOrgNameSpaceToString:@"__SERVICEMAX_CONFIG_DATA__C"];
//    NSArray *fields = [[NSArray alloc] initWithObjects:kConfigTableFieldName,kConfigTableOperator, kConfigTableOperand,kConfigTableSequence,kConfigTableExpType,kConfigTableExpRule,kId,nil];
//    
//    NSString *whereClause = [NSString stringWithFormat:@" %@ LIKE '%@%%' and recordTypeId = '%@'",kConfigTableExpRule,expressionId,recordTypeId];
//    
//   return  [self getRecordsForFields:fields forObjectname:tableName andWhereClause:whereClause];
//   
//}
//
//- (NSArray *)getProductRecords:(NSArray *)productIdentifiers {
//    NSString *productIdentfierStr = [SMXiPhone_Utility getConcatenatedStringFromArray:productIdentifiers withSingleQuotesAndBraces:YES];
//    NSString *whereClause = [NSString stringWithFormat:@" Id IN %@ ",productIdentfierStr];
//    NSString *tableName = @"Product2";
//    NSArray *fields = [[NSArray alloc] initWithObjects:@"Id",[SMXiPhone_Utility appendOrgNameSpaceToString:@"__Product_Line__c"],@"Family",nil];
//    return  [self getRecordsForFields:fields forObjectname:tableName andWhereClause:whereClause];
//}
//
//#pragma mark -
//#pragma mark Get get price code snippet
//
//
//- (NSString *)getPriceCodeSnippet:(NSString *)codeSnippetName {
//    NSDictionary *codeSnippetDictMain = [self getCodeSnippetForNameOrId:codeSnippetName];
//    
//    NSString *codeSnippetId =  [codeSnippetDictMain objectForKey:@"Id"];
//    NSString *codeSnippetMain = [codeSnippetDictMain objectForKey:kCodeSnippetData];
//    NSMutableString *codeSnippetFinal = nil;
//    if (![SMXiPhone_Utility isStringEmpty:codeSnippetId] && codeSnippetMain != nil) {
//        codeSnippetFinal =  [[NSMutableString alloc] initWithString:codeSnippetMain];
//        
//        while (![SMXiPhone_Utility isStringEmpty:codeSnippetId]) {
//            
//            /*get the reference id from manifest */
//            NSString *snippetId =  [self getCodeSnippetRefererenceForId:codeSnippetId];
//            NSDictionary *tempDictionary =  [self getCodeSnippetForNameOrId:snippetId];
//            if ([tempDictionary count] > 0) {
//                codeSnippetId = [tempDictionary objectForKey:@"Id"];
//                NSString *tempStr = [tempDictionary objectForKey:kCodeSnippetData];
//                if(![SMXiPhone_Utility isStringEmpty:codeSnippetId] && ![SMXiPhone_Utility isStringEmpty:tempStr] ) {
//                    [codeSnippetFinal appendFormat:@" %@",tempStr];
//                }
//                else {
//                    codeSnippetId = nil;
//                }
//            }
//            else {
//                codeSnippetId = nil;
//            }
//            
//        }
//    }
//    return codeSnippetFinal;
//}
//- (NSDictionary *)getCodeSnippetForNameOrId:(NSString *)codeSnippetNameOrId {
//    
//    NSString *tableName = kTableCodeSnippet;
//    NSArray *fields = [NSArray arrayWithObjects:kId,kCodeSnippetData,nil];
//    
//    NSString * whereCluase = [NSString stringWithFormat:@" ( %@  = '%@' OR Id = '%@' )and %@ <> \"\"" , kCodeSnippetName,codeSnippetNameOrId,codeSnippetNameOrId,kCodeSnippetData];
//    NSArray *records = [self getRecordsForFields:fields forObjectname:tableName andWhereClause:whereCluase];
//    if ([records count] > 0) {
//        return [records objectAtIndex:0];
//    }
//    return nil;
//}
//- (NSString *)getCodeSnippetRefererenceForId:(NSString *)codeSnippetReference {
//    NSString *fieldName = kCodeSnippetReference;
//    NSString *objectname = kTableCodeManifest;
//    
//    NSString * whereClause = [NSString stringWithFormat:@" %@__Code_Snippet__c = '%@' and %@ <> \"\"" ,ORG_NAME_SPACE, codeSnippetReference,fieldName];
//    return [self getValueForField:fieldName fromTable:objectname andWhereClause:whereClause];
//}
//
//
//- (NSString *)getDisplayValueForPicklist:(NSString *)pickListValue
//                           withFieldName:(NSString *)fieldName
//                           andObjectName:(NSString *)objetcName {
//    
//    NSString *filterCriteria = [NSString stringWithFormat:@"object_name = '%@' and field_name = '%@' and value = '%@' ",objetcName,fieldName,pickListValue];
//    NSString *name = @"label";
//    NSString *tableName = @"SFPickList";
//    return  [self getValueForField:name fromTable:tableName andWhereClause:filterCriteria];
//}
//#pragma mark -Get price 2.0
//
//- (NSDictionary *)getProductServiceWorkDetail:(NSString *)wordOrderId andWorkorderSfid:(NSString *)woSfid{
//    
//    NSString *orgNameSpace = ORG_NAME_SPACE;
//    NSArray *recordTypes = [NSArray arrayWithObjects:@"Products Serviced",nil];
//    NSDictionary *recordTypeIds =  [self getRecordTypeIdsForRecordType:recordTypes];
//    
//    NSMutableDictionary * warrantyAndSfid = [[NSMutableDictionary alloc] init];
//    NSString *serviceRecordTypeId = [recordTypeIds objectForKey:@"Products Serviced"];
//    
//    NSString * sfId = @"", *warrantyId = nil;
//    if(serviceRecordTypeId != nil || [serviceRecordTypeId length ] != 0)
//    {
//        NSString * query = [[NSString alloc] initWithFormat:@"SELECT local_id , %@__Product_Warranty__c from '%@__Service_Order_Line__c' where RecordTypeId = '%@' and (%@__Service_Order__c = '%@' OR %@__Service_Order__c = '%@')" ,orgNameSpace,orgNameSpace, serviceRecordTypeId ,orgNameSpace, wordOrderId,orgNameSpace,woSfid];
//        sqlite3_stmt * stmt;
//        if(synchronized_sqlite3_prepare_v2([[SMXiPhone_Database sharedDataBase] databaseObject], [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
//        {
//            while (synchronized_sqlite3_step(stmt)  == SQLITE_ROW)
//            {
//                
//                sfId = [self extractTextFromSqliteStmt:stmt AtIndex:0];
//                warrantyId = [self extractTextFromSqliteStmt:stmt AtIndex:1];
//                if(warrantyId.length > 3 && sfId != nil) {
//                    [warrantyAndSfid setObject:warrantyId forKey:sfId];
//                }
//            }
//        }
//        synchronized_sqlite3_finalize(stmt);
//    }
//    return warrantyAndSfid;
//}
//
//- (NSDictionary *)getWorkDetailForProductServiceArray:(NSArray *)productServiceIds
//                                      andWorkOrderIds:(NSString *)wordOrderId andSfid:(NSString *)wosfid{
//    
//     NSString *orgNameSpace = ORG_NAME_SPACE;
//    NSString *idString =   [SMXiPhone_Utility getConcatenatedStringFromArray:productServiceIds withSingleQuotesAndBraces:YES];
//    NSMutableDictionary * serviceIdsAndSfid = [[NSMutableDictionary alloc] init];
//    //10760
//    NSDictionary *sfidDict =  [self getAllSfidsForLocalIds:idString];
//    NSString *sfidString =   [SMXiPhone_Utility getConcatenatedStringFromArray:[sfidDict allKeys] withSingleQuotesAndBraces:YES];
//    
//    NSString * sfId = @"", *serviceId = nil;
//    if(wordOrderId != nil || [wordOrderId length ] != 0)
//    {
//        //10760
//        NSString * query = [[NSString alloc  ] initWithFormat:@"SELECT local_id, %@__Work_Detail__c from '%@__Service_Order_Line__c' where ( %@__Work_Detail__c IN %@ OR %@__Work_Detail__c IN %@ ) and (%@__Service_Order__c = '%@' OR %@__Service_Order__c = '%@')" ,orgNameSpace,orgNameSpace,orgNameSpace, idString ,orgNameSpace,sfidString, orgNameSpace,wordOrderId,orgNameSpace,wosfid];
//        sqlite3_stmt * stmt;
//        if(synchronized_sqlite3_prepare_v2([[SMXiPhone_Database sharedDataBase] databaseObject], [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
//        {
//            while (synchronized_sqlite3_step(stmt)  == SQLITE_ROW)
//            {
//                sfId = [self extractTextFromSqliteStmt:stmt AtIndex:0];
//                serviceId = [self extractTextFromSqliteStmt:stmt AtIndex:1];
//
//                NSString *serviceLocalId = nil;
//                if(serviceId != nil && sfId != nil)
//                {
//                    if (serviceId.length < 30) {
//                        serviceLocalId = [sfidDict objectForKey:serviceId];
//                        if (serviceLocalId != nil) {
//                            serviceId = serviceLocalId;
//                        }
//                    }
//                    NSMutableArray *workDetailIds = [serviceIdsAndSfid objectForKey:serviceId];
//                    if(workDetailIds == nil){
//                        workDetailIds = [[NSMutableArray alloc] init];
//                        [serviceIdsAndSfid setObject:workDetailIds forKey:serviceId];
//                    }
//                    [workDetailIds addObject:sfId];
//                }
//            }
//        }
//        synchronized_sqlite3_finalize(stmt);
//    }
//    return serviceIdsAndSfid;
//    
//}
//
//- (NSDictionary *)getAllSfidsForLocalIds:(NSString *)localIdString {
//     NSString *orgNameSpace = ORG_NAME_SPACE;
//    NSString * query = [NSString stringWithFormat:@"SELECT Id ,local_id from '%@__Service_Order_Line__c' WHERE local_id in %@" , orgNameSpace,localIdString];
//    NSString * sfId = @"",*localId = @"";
//    NSMutableDictionary *idsDict = [NSMutableDictionary dictionary];
//    sqlite3_stmt * stmt;
//    if(synchronized_sqlite3_prepare_v2([[SMXiPhone_Database sharedDataBase] databaseObject], [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
//    {
//        while (synchronized_sqlite3_step(stmt)  == SQLITE_ROW)
//        {
//            sfId = [self extractTextFromSqliteStmt:stmt AtIndex:0];
//            localId = [self extractTextFromSqliteStmt:stmt AtIndex:1];
//            if(localId != nil && sfId != nil) {
//                [idsDict setObject:localId forKey:sfId];
//            }
//        }
//    }
//    synchronized_sqlite3_finalize(stmt);
//    return idsDict;
//}
//
//- (NSMutableDictionary *)getAllRecordForSfIds:(NSArray *)allIds andTableName:(NSString *)tableName {
//    
//    NSDictionary *allFieldsOfTable = [self getAllFieldsOfTable:tableName];
//    NSArray *allColumnNames = [allFieldsOfTable  allKeys];
//    NSString *allColumnNamesString = [SMXiPhone_Utility getConcatenatedStringFromArray:allColumnNames withSingleQuotesAndBraces:NO];
//    
//    NSString *idsString = [SMXiPhone_Utility getConcatenatedStringFromArray:allIds withSingleQuotesAndBraces:YES];
//    
//    NSString *sqlQuery = [NSString  stringWithFormat:@"select %@ from %@ where  Id IN %@",allColumnNamesString,tableName,idsString];
//    
//    NSMutableDictionary *allRecordsDictionary = [[NSMutableDictionary alloc] init];
//    sqlite3_stmt *selectStmt = nil;
//    if(synchronized_sqlite3_prepare_v2([[SMXiPhone_Database sharedDataBase] databaseObject], [sqlQuery UTF8String], -1, &selectStmt, nil) == SQLITE_OK  )
//    {
//        
//        while(synchronized_sqlite3_step(selectStmt) == SQLITE_ROW)
//        {
//            NSMutableDictionary *dataDictionary = [[NSMutableDictionary alloc] init];
//            
//            NSString * tempString = @"";
//			char * tempCharString = nil;
//            
//            for (int counter = 0; counter < [allColumnNames count]; counter++) {
//                tempCharString = (char *)sqlite3_column_text(selectStmt, counter);
//                if (tempCharString != nil) {
//                    tempString = [NSString stringWithUTF8String:tempCharString];
//                    if (tempString != nil) {
//                        NSString *fieldName = [allColumnNames objectAtIndex:counter];
//                        NSString *fieldType = [allFieldsOfTable objectForKey:fieldName];
//                        
//                       id someObject =  [self getTheProperObjectTypeForFieldType:fieldType andFieldValue:tempString];
//                            if (someObject != nil) {
//                                [dataDictionary setObject:someObject forKey:fieldName];
//                            }
//                    }
//                 }
//            }
//            
//            NSString *sfId = [dataDictionary objectForKey:@"Id"];
//            if(sfId != nil){
//                [allRecordsDictionary setObject:dataDictionary forKey:sfId];
//            }
//            
//        }
//		synchronized_sqlite3_finalize(selectStmt);
//    }
//    return allRecordsDictionary;
//}

#pragma mark End
@end
