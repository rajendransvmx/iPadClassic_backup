//
//  PriceBookTargetHandler.m
//  ServiceMaxiPhone
//
//  Created by Shravya shridhar on 6/17/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "PriceBookTargetHandler.h"
#import "PriceCalculationDBService.h"
#import "SFObjectFieldDAO.h"
#import "FactoryDAO.h"
#import "TransactionObjectDAO.h"
#import "SFMRecordFieldData.h"
#import "DatabaseConstant.h"
#import "Utility.h"
#import "StringUtil.h"
#import "DateUtil.h"


#define kFieldNameKey       @"key"
#define kFieldNameValue     @"value"
#define kFieldNameValue1    @"value1"

static NSString *appendedZeroes = @".000+0000";

@interface PriceBookTargetHandler() {
    
    NSMutableArray *psLines;
}

@property(nonatomic,strong) NSMutableDictionary *fieldDictionaryObjects;
@property(nonatomic,strong) id <TransactionObjectDAO> transactionObjectService;

@end


@implementation PriceBookTargetHandler

- (id)initWithSFPage:(SFMPage *)page {
    
    self = [super init];
    if (self != nil) {
         self.transactionObjectService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
        self.targetDictionary = [[NSMutableDictionary alloc] init];
        self.fieldDictionaryObjects = [[NSMutableDictionary alloc] init];
        [self createTargetDictionaryFromPage:page];
    }
    return self;
}


- (void)createTargetDictionaryFromPage:(SFMPage *)page {
    [self createHeaderTargetFromPage:page];
    [self createDetailTargetRecordsFromPage:page];
    [self getPSLinesRecords:page];
}


- (void)createHeaderTargetFromPage:(SFMPage *)page {
    
    NSMutableDictionary *headerTargetDictionary = [[NSMutableDictionary alloc] init];
    
    NSDictionary *headerDictionary = page.headerRecord;
    NSDictionary *allFieldsDictionary =  [self getFieldInformationForObject:page.objectName];
    
    /* Get header record from data base*/
    NSDictionary *recordDictionary = [self getObjectForLocalId:page.recordId andObjectName:page.objectName];;
  
    NSMutableDictionary *singleRecord = [[NSMutableDictionary alloc] init];
    SFMRecordFieldData *recordField = [headerDictionary objectForKey:kId];
    if (recordField.internalValue.length > 3) {
        [singleRecord setObject:recordField.internalValue forKey:@"targetRecordId"];
    }
    
    NSArray *targetRecordAsKeyValue = [self getTargetRecordAsKeyValueArray:allFieldsDictionary andHeaderDictioanry:headerDictionary andActualRecord:recordDictionary];
    [singleRecord setObject:targetRecordAsKeyValue forKey:@"targetRecordAsKeyValue"];
   
    
    NSArray *recordsArray = [[NSArray alloc] initWithObjects:singleRecord, nil];
    [headerTargetDictionary setObject:recordsArray forKey:@"records"];
    [headerTargetDictionary setObject:page.objectName forKey:@"objName"];
    if (page.process.processInfo.pageLayoutId != nil) {
        [headerTargetDictionary setObject:page.process.processInfo.pageLayoutId forKey:@"pageLayoutId"];
    }
    
    [self.targetDictionary setObject:headerTargetDictionary forKey:@"headerRecord"];
    
}

- (NSDictionary *)getObjectForLocalId:(NSString *)recordId andObjectName:(NSString *)objectName {
    /* Get header record from data base*/
    id transObjectService =  self.transactionObjectService ;
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kLocalId operatorType:SQLOperatorEqual andFieldValue:recordId];
    NSArray *allRecords = [transObjectService fetchDataWithhAllFieldsAsStringObjects:objectName fields:nil expression:nil criteria:@[criteria]];
    
    NSDictionary *recordDictionary = nil;
    if ([allRecords count] > 0) {
        TransactionObjectModel *transModel = [allRecords objectAtIndex:0];
        recordDictionary = [transModel getFieldValueDictionary];
    }
    return recordDictionary;
}
- (void)createDetailTargetRecordsFromPage:(SFMPage *)page {
    
    NSMutableArray *priceCalcDetailRecords = [[NSMutableArray alloc] init];
    NSDictionary *processComponentDictionary = page.process.component;
    for (NSString *processComponentId in processComponentDictionary) {
        
        SFProcessComponentModel *component = [processComponentDictionary objectForKey:processComponentId];
        if ([component.componentType isEqualToString:kTargetChild]) {
            
             NSMutableDictionary *targetDetailDictionary = [[NSMutableDictionary alloc] init];
            
            
            [targetDetailDictionary setObject:component.objectName forKey:@"objName"];
            if (component.layoutId != nil) {
                [targetDetailDictionary setObject:component.layoutId forKey:@"pageLayoutId"];
            }
            if (component.parentColumnName != nil) {
                 [targetDetailDictionary setObject:component.parentColumnName forKey:@"parentColumnName"];
            }
            if (component.targetObjectLabel  != nil) {
                [targetDetailDictionary setObject:component.targetObjectLabel forKey:@"aliasName"];
            }
            
            if (component.sfId  != nil) {
                [targetDetailDictionary setObject:component.sfId forKey:@"iphProcessCompoSfid"];
            }
            
            
            NSMutableArray *finalDetailRecordList = [[NSMutableArray alloc] init];
            /* Add records */
            NSArray *allDetailRecords = [page.detailsRecord objectForKey:processComponentId];
            
            if ([allDetailRecords count] > 0) {
                NSDictionary *allFieldsDictionary = [self getFieldInformationForObject:component.objectName];
                for (int counter = 0;counter < [allDetailRecords count];counter++ ) {
                    
                    NSDictionary *detailPageDictionary = [allDetailRecords objectAtIndex:counter];
                    NSDictionary *recordDictionary = nil;
                    SFMRecordFieldData *localIdField =  [detailPageDictionary objectForKey:kLocalId];
                    NSString *recordLocalId = localIdField.internalValue;
                    
                    NSArray *createdArray =  [page.newlyCreatedRecordIds objectForKey:processComponentId];
                    if (![createdArray containsObject:recordLocalId]) {
                       recordDictionary = [self getObjectForLocalId:recordLocalId andObjectName:component.objectName];
                    }
                    NSMutableDictionary *singleRecord = [[NSMutableDictionary alloc] init];
                    SFMRecordFieldData *recordField = [detailPageDictionary objectForKey:kId];
                    if (recordField.internalValue.length > 3) {
                        [singleRecord setObject:recordField.internalValue forKey:@"targetRecordId"];
                    }
                    
                    NSArray *targetRecordAsKeyValue = [self getTargetRecordAsKeyValueArray:allFieldsDictionary andHeaderDictioanry:detailPageDictionary andActualRecord:recordDictionary];
                    [singleRecord setObject:targetRecordAsKeyValue forKey:@"targetRecordAsKeyValue"];
                    [finalDetailRecordList addObject:singleRecord];
                }
            }
           
            [targetDetailDictionary setObject:finalDetailRecordList forKey:@"records"];
            [priceCalcDetailRecords addObject:targetDetailDictionary];
       }
    }
    
    [self.targetDictionary setObject:priceCalcDetailRecords forKey:@"detailRecords"];
    [self.targetDictionary setObject:page.process.processInfo.sfID forKey:@"sfmProcessId"];
    
}


- (NSArray *)getTargetRecordAsKeyValueArray:(NSDictionary *)allFieldsDictionary
                        andHeaderDictioanry:(NSDictionary *)headerDictionary
                            andActualRecord:(NSDictionary *)recordDictionary {
    
      NSString *emptyStringValue = @"",*keyName = kFieldNameKey,*keyValue =kFieldNameValue, *keyValue1 = kFieldNameValue1;
    NSMutableArray *targetRecordAsKeyValue = [[NSMutableArray alloc] init];
    for (NSString *fieldName in allFieldsDictionary) {
        
        NSString *fieldValue = nil; NSString *displayValue = nil;
        SFMRecordFieldData *recordField = [headerDictionary objectForKey:fieldName];
        if (recordField != nil) {
            fieldValue = recordField.internalValue;
            displayValue = recordField.displayValue;
        }
        else{
            fieldValue =  [recordDictionary objectForKey:fieldName];
            displayValue = fieldValue;
        }
        NSString *fieldType =  [allFieldsDictionary objectForKey:fieldName];
        if (fieldValue.length > 3 && [fieldType isEqualToString:kSfDTDateTime]) {
            fieldValue = [Utility replaceTinDateBySpace:fieldValue];
        }
        else if ([fieldType isEqualToString:kSfDTBoolean]){
            fieldValue = ([StringUtil isItTrue:fieldValue])? kTrue:kFalse;
        }
        if (([fieldType isEqualToString:kSfDTDate] || [fieldType isEqualToString:kSfDTDateTime])) {
            
            fieldValue =  [DateUtil getLocalDateForGetpriceFromDateString:displayValue];
        }
        fieldValue = (fieldValue == nil)?emptyStringValue:fieldValue;
        displayValue = (displayValue == nil)?emptyStringValue:displayValue;
        
        NSDictionary *keyDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:fieldName,keyName,fieldValue,keyValue,displayValue,keyValue1,nil];
        [targetRecordAsKeyValue addObject:keyDictionary];
    }
    
    SFMRecordFieldData *recordField = [headerDictionary objectForKey:kLocalId];
    if (recordField != nil) {
        
        NSDictionary *keyDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"local_id",keyName,recordField.internalValue,keyValue,recordField.internalValue,keyValue1,nil];
        [targetRecordAsKeyValue addObject:keyDictionary];
        
    }
    return targetRecordAsKeyValue;
}

- (NSDictionary *)getFieldInformationForObject:(NSString *)objectName {
    
    NSMutableDictionary *allFieldsDictionary = [self.fieldDictionaryObjects objectForKey:objectName];
    
    if (allFieldsDictionary == nil) {
        
          id <SFObjectFieldDAO>sfObjectService = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectField];
          NSArray *allFields = [sfObjectService getAllSFObjectFieldsForObject:objectName];
          allFieldsDictionary = [[NSMutableDictionary alloc] init];
        
        for (SFObjectFieldModel *fieldModel in allFields) {
            
            if (fieldModel.type != nil && fieldModel.fieldName != nil   ) {
                [allFieldsDictionary   setObject:fieldModel.type forKey:fieldModel.fieldName];
            }
        }
        
        if (allFieldsDictionary != nil) {
            [self.fieldDictionaryObjects setObject:allFieldsDictionary forKey:objectName];
        }
        
    }
    return allFieldsDictionary;
}
//
//- (void)updateResults:(NSDictionary *)result inPage:(SFPage *)page{
//    
//}
//
#pragma mark - Updating Price results to SFPage

- (void)updateTargetSfpage:(SFMPage *)currentPage
          fromPriceResults:(NSDictionary *)priceResults {
    
    NSDictionary *headerDictionary = [priceResults objectForKey:@"headerRecord"];
    [self updateHeaderRecord:headerDictionary inSfPage:currentPage];
    
     NSArray *detailRecords = [priceResults objectForKey:@"detailRecords"];
    [self updateDetailRecords:detailRecords inSfPage:currentPage];
    
}

- (void)updateFinalValueFromNewDictionary:(NSDictionary *)fieldDictionary
                           withObjectName:(NSString *)objectName
                          intoRecordField:(SFMRecordFieldData *)recordField
                             andFieldType:(NSString *)fieldType{
    
    NSString *fieldName = [fieldDictionary objectForKey:kFieldNameKey];
    NSString *newFieldValue = [fieldDictionary objectForKey:kFieldNameValue];
    if ( ![StringUtil isStringNotNULL:newFieldValue]) {
        newFieldValue = @"";
    }
    
    newFieldValue = [self getStringFromNumber:newFieldValue];
    
    NSString *finalValue = nil;
    NSString *finalDisplayValue = nil;
    
    if ([StringUtil  isStringEmpty:newFieldValue] || ![StringUtil isStringNotNULL:newFieldValue]) {
    }
    else if([fieldType isEqualToString:kSfDTPicklist]) {
        
        finalValue = newFieldValue;
        finalDisplayValue = newFieldValue;
        NSString *displayValue =  [self getDisplayValueForPicklistRecord:fieldName andPicklistValue:newFieldValue andObjectName:objectName];
        if (displayValue != nil) {
            finalDisplayValue = displayValue;
        }
    }
    else if([fieldType isEqualToString:kSfDTDateTime]){
        
        NSString *replacedString =  [Utility replaceSpaceinDateByT:newFieldValue];
        if (![StringUtil isStringEmpty:replacedString] && replacedString.length < 20) {
            replacedString = [replacedString stringByAppendingString:appendedZeroes];
        }
        finalValue = replacedString;
        finalDisplayValue = replacedString;
        
        if(![StringUtil isStringEmpty:finalValue]) {
            
            NSString *dateTime = [DateUtil getUserReadableDateForDateBaseDate:finalValue];
            finalDisplayValue = dateTime;
        }

    }
    else if ([fieldType isEqualToString:kSfDTBoolean]){
        finalValue = ([StringUtil isItTrue:newFieldValue])?kTrue:kFalse;
        finalDisplayValue = finalValue;
    }
    else{
        NSString *fieldValue1 = [fieldDictionary objectForKey:kFieldNameValue1];
        if ([fieldValue1 isKindOfClass:[NSNumber class]]){
            fieldValue1 = [self getStringFromNumber:fieldValue1];
        }
        if (![StringUtil isStringNotNULL:fieldValue1]) {
            fieldValue1 = @"";
        }
        
        finalValue = newFieldValue;
        if (![fieldType isEqualToString:kSfDTReference]) {
            fieldValue1 = newFieldValue;
        }
        finalDisplayValue = fieldValue1;
    }
    recordField.internalValue = finalValue;
    recordField.displayValue = finalDisplayValue;
}


- (void)updateDetailRecords:(NSArray *)detailRecords
                   inSfPage:(SFMPage *)sfPage {
    
    for (NSDictionary *eachDetailRecord in detailRecords) {
        
        NSString *processComponentId = [eachDetailRecord objectForKey:@"iphProcessCompoSfid"];
        if (processComponentId != nil) {
            
            
            NSDictionary *previousDetailDictionary = [self getPreviousDetailRecordForComponentId:processComponentId];
            NSArray *previousRecords = [previousDetailDictionary objectForKey:@"records"];
           
            NSArray *newRecords = [eachDetailRecord objectForKey:@"records"];
            
            if ([newRecords count] <= 0) {
                continue;
            }
          
            NSString *objectName = [eachDetailRecord objectForKey:@"objName"];
            NSDictionary *dataTypeDictionary = [self getFieldInformationForObject:objectName];
            for (int counter = 0; counter < [newRecords count]; counter++) {
                
                NSMutableDictionary *pageDetailDictionary = [self getRecordForProcessCompoId:processComponentId andRecordIndex:counter fromsfPage:sfPage];
                
                NSDictionary *childLineRecord = [newRecords objectAtIndex:counter];
                
                NSArray *allFieldArray = [childLineRecord objectForKey:@"targetRecordAsKeyValue"];
                for (int innerCounter = 0; innerCounter < [allFieldArray count]; innerCounter++) {
                    
                    NSDictionary *newFieldDictionary = [allFieldArray objectAtIndex:innerCounter];
                    NSString *fieldName = [newFieldDictionary objectForKey:kFieldNameKey];
                    NSString *fieldType = [dataTypeDictionary objectForKey:fieldName];
                    NSDictionary *previousDictionary = [self getPreviousValueForrecordAtIndex:counter withFieldName:fieldName inDetailArray:previousRecords];
                    
                    NSString *newValue = [newFieldDictionary objectForKey:kFieldNameValue];
                    if ( ![StringUtil isStringNotNULL:newValue]) {
                        newValue = @"";
                    }
                    
                    NSString *prebiousValue = [previousDictionary objectForKey:kFieldNameValue];
                    
                    newValue = [self getStringFromNumber:newValue];
                    prebiousValue = [self getStringFromNumber:prebiousValue];
                    
                    if (![prebiousValue isEqualToString:newValue]) {
                        
                        SFMRecordFieldData *aField = [pageDetailDictionary objectForKey:fieldName];
                        if (aField == nil) {
                            
                            aField = [[SFMRecordFieldData alloc] initWithFieldName:fieldName value:nil andDisplayValue:nil];
                            [pageDetailDictionary setObject:aField forKey:fieldName];
                        }
                        [self updateFinalValueFromNewDictionary:newFieldDictionary withObjectName:objectName intoRecordField:aField andFieldType:fieldType];

                    }
                    
                }
                
            }
            
        }
    }
    
}
- (void)updateHeaderRecord:(NSDictionary *)headerDictionary
                  inSfPage:(SFMPage *)page {
    
    
    NSArray *oldTargetFieldsArray = [self getTargetKeyValueArrayFromHeader];
    
    NSDictionary *dataTypeDictionary = [self getFieldInformationForObject:page.objectName];
    NSArray *records =  [headerDictionary objectForKey:@"records"];
    if ([records count] > 0) {
        
        NSDictionary *recordDictionary = [records objectAtIndex:0];
        NSArray *targetKeyValueArray = [recordDictionary objectForKey:@"targetRecordAsKeyValue"];
        
        for (NSDictionary *fieldDictionary in targetKeyValueArray) {
            
            NSString *fieldName = [fieldDictionary objectForKey:kFieldNameKey];
            NSString *newFieldValue = [fieldDictionary objectForKey:kFieldNameValue];
            if ( ![StringUtil isStringNotNULL:newFieldValue]) {
                newFieldValue = @"";
            }
            newFieldValue = [self getStringFromNumber:newFieldValue];
            
            NSString *fieldType = [dataTypeDictionary objectForKey:fieldName];
            
            NSDictionary *oldRecordDictionary = [self getFieldDictioanaryForFiedName:fieldName inTargetKeyAsArray:oldTargetFieldsArray];
            NSString *oldFieldValue = [oldRecordDictionary objectForKey:kFieldNameValue];
            oldFieldValue = [self getStringFromNumber:oldFieldValue];
            
            if (![oldFieldValue isEqualToString:newFieldValue]) {
               
                SFMRecordFieldData  *aField = [page.headerRecord objectForKey:fieldName];
                if (aField == nil) {
                    
                    aField = [[SFMRecordFieldData alloc] initWithFieldName:fieldName value:nil andDisplayValue:nil];
                    [page.headerRecord setObject:aField forKey:fieldName];
                }
                [self updateFinalValueFromNewDictionary:fieldDictionary withObjectName:page.objectName intoRecordField:aField andFieldType:fieldType];
            }
        }
    }
}

#pragma mark End

- (NSMutableDictionary*)getRecordForProcessCompoId:(NSString *)processCompId
                                    andRecordIndex:(NSInteger)recordIndex
                                        fromsfPage:(SFMPage *)sfPage {
    
    NSArray *recordsArray = [sfPage.detailsRecord    objectForKey:processCompId];
    if ([recordsArray count] > recordIndex) {
        
        return [recordsArray objectAtIndex:recordIndex];
    }
    return nil;
}
- (NSDictionary *)getPreviousDetailRecordForComponentId:(NSString *)componentId {
    
    NSDictionary *currentContext = self.targetDictionary;
    NSArray *detailRecords =  [currentContext objectForKey:@"detailRecords"];
    for (NSDictionary *eachDetailRecord in detailRecords) {
        NSString *oldId = [eachDetailRecord objectForKey:@"iphProcessCompoSfid"];
        if ([oldId isEqualToString:componentId]) {
            return eachDetailRecord;
        }

    }
    return nil;
}

- (NSDictionary *)getPreviousValueForrecordAtIndex:(NSInteger )index
                                     withFieldName:(NSString *)fieldName
                                     inDetailArray:(NSArray *)detailArray{
    
    if (index < [detailArray count]) {
        NSDictionary *childLineRecord = [detailArray objectAtIndex:index];
        
        NSArray *allFieldArray = [childLineRecord objectForKey:@"targetRecordAsKeyValue"];
        for (int innerCounter = 0; innerCounter < [allFieldArray count]; innerCounter++) {
            
            NSDictionary *newFieldDictionary = [allFieldArray objectAtIndex:innerCounter];
            NSString *currentFName = [newFieldDictionary objectForKey:kFieldNameKey];
            if ([currentFName isEqualToString:fieldName]) {
                return newFieldDictionary;
            }
        }
    }
    return nil;
   
}
- (NSArray *)getTargetKeyValueArrayFromHeader{
    
    NSDictionary *currentContext = self.targetDictionary;
    NSDictionary *headerRecord =  [currentContext objectForKey:@"headerRecord"];
   
    NSArray *recordsArr = [headerRecord objectForKey:@"records"];
    if ([recordsArr count] <= 0) {
        return nil;
    }
    
    NSDictionary *headerDataDictionary = [recordsArr objectAtIndex:0];
   return   [headerDataDictionary objectForKey:@"targetRecordAsKeyValue"];
}


- (NSDictionary *)getFieldDictioanaryForFiedName:(NSString * )newFieldName
                              inTargetKeyAsArray:(NSArray *)taregtKeyArray {
    for (NSDictionary *fieldDictionary in taregtKeyArray) {
        
        NSString *oldFieldName = [fieldDictionary objectForKey:kFieldNameKey];
        if ([newFieldName isEqualToString:oldFieldName]) {
            return fieldDictionary;
        }
    }
    return nil;
}

- (NSString *)getDisplayValueForPicklistRecord:(NSString *)fieldName
                              andPicklistValue:(NSString*)picklistValue
                                 andObjectName:(NSString *)objectName{
    
     PriceCalculationDBService *priceCalcDBService = [[PriceCalculationDBService alloc] init];
    return [priceCalcDBService getDisplayValueForPicklist:picklistValue withFieldName:fieldName andObjectName:objectName];
    
}

- (NSString *)getStringFromNumber:(NSString *)maybeNumber {
    if ([maybeNumber isKindOfClass:[NSNumber class]]) {
        return  [NSString stringWithFormat:@"%.3f",[maybeNumber floatValue]];
    }
    return maybeNumber;
}


#pragma mark - PS Lines Entitlement


-(void)getPSLinesRecords:(SFMPage *)page {
    SFMRecordFieldData *headerSfIDField = [page.headerRecord objectForKey:kId];
    if (headerSfIDField) {
        NSString *sfID = headerSfIDField.internalValue;
        NSString *objectName = page.objectName;
        PriceCalculationDBService *dbService = [[PriceCalculationDBService alloc] init];
        NSArray *psLineRecords = [dbService getPSLineRecordsForHeaderRecord:sfID andObjectname:objectName];
        for (NSDictionary *record in psLineRecords) {
            [self checkIfRecordIsPSLineIsEntitled:record];
        }
        if (psLines) {
            [self.targetDictionary setObject:psLines forKey:@"pslines"];
        }
    }
}

-(void)checkIfRecordIsPSLineIsEntitled:(NSDictionary *)recordDictionary {
    NSString *sfId = [recordDictionary objectForKey:kId];
    PriceCalculationDBService *dbService = [[PriceCalculationDBService alloc] init];
    NSDictionary *entitlementDict = [dbService getEntitlementHistoryForPSLine:sfId];
    if(entitlementDict != nil) {
        NSMutableDictionary *psInfoDict = [NSMutableDictionary dictionary];
        [psInfoDict setObject:sfId forKey:kId];
        [psInfoDict setObject:entitlementDict forKey:@"PSEntitlement"];
        if (psLines == nil) {
            psLines = [NSMutableArray array];
        }
        [psLines addObject:psInfoDict];
    }
}


@end
