//
//  SFMPageLookUpHelper.m
//  ServiceMaxMobile
//
//  Created by Sahana on 07/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "SFMPageLookUpHelper.h"

#import "DBCriteria.h"
#import "DBRequestSelect.h"
#import "SFMLookUp.h"
#import "SFNamedSearchComponentDAO.h"
#import "SFNamedSearchDAO.h"
#import "TransactionObjectDAO.h"
#import "FactoryDAO.h"
#import "StringUtil.h"
#import "SFNamedSearchModel.h"
#import "SFNamedSearchComponentModel.h"
#import "SFObjectFieldDAO.h"
#import "DateUtil.h"
#import "SFPicklistModel.h"
#import "SFRecordTypeModel.h"
#import "SFMPageHelper.h"

@interface SFMPageLookUpHelper ()

//@property (nonatomic, strong) NSMutableDictionary * fieldNameAndInternalValue;
//@property (nonatomic, strong) NSMutableDictionary * fieldNameAndObjectApiName;
@property (nonatomic, strong) NSMutableDictionary * pickListData;
@property (nonatomic, strong) NSMutableDictionary * recordTypeData;
@end

@implementation SFMPageLookUpHelper

-(void)loadLookUpConfigarationForLookUpObject:(SFMLookUp *)lookUpObj
{
    if(lookUpObj == nil){
       lookUpObj = [[SFMLookUp alloc] init];
       
    }
    
//    lookUpObj.lookUpId = @"a0gK00000016W5IIAU";
//    lookUpObj.objectName = @"Case";
   // lookUpObj.searchString = @"A";
    
    /* fill up LooUp details*/
    [self fillLookUpMetaDataLookUp:lookUpObj];
    
    /*fill Up LookUp component details*/
    [self fillLookUpComponentsForLookUpObject:lookUpObj];
    
    
   lookUpObj.fieldInfoDict = [self getFieldInformation:lookUpObj];
    
    /*fill up look up filtes*/
    
   // [self fillDataForLookUpObject:lookUpObj];
}


-(void)fillLookUpMetaDataLookUp:(SFMLookUp *)lookUpObj
{
    
    NSArray * criteriaArray = nil;
    DBCriteria * criteria1 = nil;
    DBCriteria * criteria2 = nil;
    
    if([StringUtil isStringEmpty:lookUpObj.lookUpId]){
        criteria1 = [[DBCriteria alloc] initWithFieldName:@"isStandard" operatorType:SQLOperatorEqual andFieldValue:@"1"];
    }
    else
    {
        criteria1 = [[DBCriteria alloc] initWithFieldName:@"namedSearchId" operatorType:SQLOperatorEqual andFieldValue:lookUpObj.lookUpId];
    }
    
    criteria2 = [[DBCriteria alloc] initWithFieldName:@"objectName" operatorType:SQLOperatorEqual andFieldValue:lookUpObj.objectName];
    
    criteriaArray = [[NSArray alloc] initWithObjects:criteria1,criteria2, nil];
    
    
    NSString * advExpression = @"(1 AND 2)";
    
    
    NSArray * fieldsArray = [[NSArray alloc] initWithObjects:@"noOfLookupRecords",@"defaultLookupColumn",@"searchName", @"namedSearchId",nil];
    
    
    id<SFNamedSearchDAO>   namedSearchObj =  [FactoryDAO serviceByServiceType:ServiceTypeNamedSearch];
    
    
    SFNamedSearchModel * namedSearchModel =  [namedSearchObj getLookUpRecordsForDBCriteria:criteriaArray advancedExpression:advExpression fields:fieldsArray];
    
     if([StringUtil isStringEmpty:lookUpObj.lookUpId])
     {
         lookUpObj.lookUpId = namedSearchModel.namedSearchId;
     }
    
    lookUpObj.recordLimit = [namedSearchModel.noOfLookupRecords intValue];
    lookUpObj.defaultColoumnName = namedSearchModel.defaultLookupColumn;
    
    if([StringUtil isStringEmpty:lookUpObj.defaultColoumnName])
    {
        lookUpObj.defaultColoumnName  = [SFMPageHelper getNameFieldForObject:lookUpObj.objectName];
    }
    
}

-(void)fillLookUpComponentsForLookUpObject:(SFMLookUp *)lookUpObj
{
    
    NSArray * criteriaArray = nil;
    DBCriteria * criteria1 = nil;
    DBCriteria * criteria2 = nil;
    
    criteria1 = [[DBCriteria alloc] initWithFieldName: @"namedSearchId" operatorType:SQLOperatorEqual andFieldValue:lookUpObj.lookUpId];
    
    criteria2 = [[DBCriteria alloc] initWithFieldName:@"expressionType" operatorType:SQLOperatorEqual andFieldValue:kSearchObjectFields];
    
    criteriaArray = [[NSArray alloc] initWithObjects:criteria1,criteria2, nil];
    
    NSString * advExpression = @"(1 AND 2)";
    
    NSArray * fieldsArray = [[NSArray alloc] initWithObjects: @"fieldName",@"searchObjectFieldType", @"fieldDataType", @"namedSearchId",nil];
    
    
    id<SFNamedSearchComponentDAO>   namedSearchObj =  [FactoryDAO serviceByServiceType:ServiceTypeSearchObjectDetail];
    
    
    NSDictionary * componentInfo =  [namedSearchObj getNamedSearchComponentWithDBcriteria:criteriaArray advanceExpression:advExpression fields:fieldsArray orderbyField:[NSArray arrayWithObject:@"sequence"] distinct:YES];
    

   lookUpObj.searchFields  = [componentInfo objectForKey:kSearchFieldTypeSearch];
   lookUpObj.displayFields = [componentInfo objectForKey:kSearchFieldTypeResult];
    
}



-(void)fillDataForLookUpObject:(SFMLookUp *)lookUpObj
{
    
    NSArray * fieldsArray = [self getDisplayFields:lookUpObj];
    
    NSArray * criteriaArray = [self getWhereclause:lookUpObj];
    
    NSString * advanceExpression = [self advanceExpression:lookUpObj];
    
    id <TransactionObjectDAO> transactionModel = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
     NSArray * dataArray = [transactionModel fetchDataForObject:lookUpObj.objectName fields:fieldsArray expression:advanceExpression criteria:criteriaArray recordsLimit:lookUpObj.recordLimit];
    
    NSArray * recordsArray = [self getRecordArrayFromTransactionModel:dataArray lookUpObject:lookUpObj forDisplayFields:fieldsArray];
    
    lookUpObj.dataArray = recordsArray;
    
}


-(NSArray *)getRecordArrayFromTransactionModel:(NSArray *)dataArray  lookUpObject:(SFMLookUp *)lookUpObject forDisplayFields:(NSArray *)displayFields
{
    NSMutableDictionary * fieldNameAndInternalValue = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    NSMutableDictionary * fieldNameAndObjectApiName =  [[NSMutableDictionary alloc] initWithCapacity:0];
    
    
    NSMutableDictionary * dataTypeVsFieldsDict =[self getFieldDataTypeMap:[lookUpObject.fieldInfoDict allValues]];
    
    [self fillPickPickListAndRecordTypeInfo:dataTypeVsFieldsDict andObjectName:lookUpObject.objectName];
    
    
    NSMutableArray *recordArray = [[NSMutableArray alloc]init];
    for(TransactionObjectModel * model in dataArray)
    {
        NSMutableDictionary * eachDataDict = [[NSMutableDictionary alloc] init];
        NSDictionary * dict =  [model getFieldValueDictionary];
        
        for ( NSString * eachField in displayFields) {
            
            SFMRecordFieldData * fieldDataObj = [[SFMRecordFieldData alloc] initWithFieldName:eachField value:[dict objectForKey:eachField] andDisplayValue:[dict objectForKey:eachField]];
            
           SFObjectFieldModel * aPageField =  [lookUpObject.fieldInfoDict objectForKey:eachField];
            
            NSString * displayValue = nil;
            
            if ([aPageField.type isEqualToString:kSfDTReference]) {
                if (![StringUtil isStringEmpty:fieldDataObj.internalValue]) {
                    [fieldNameAndInternalValue setObject:fieldDataObj.internalValue forKey:aPageField.fieldName];
                    if (aPageField.referenceTo != nil) {
                        [fieldNameAndObjectApiName setObject:aPageField.referenceTo forKey:aPageField.fieldName];
                    }
                }
            }
            else if ([aPageField.type isEqualToString:kSfDTDateTime]) {
                if (![StringUtil isStringEmpty:fieldDataObj.internalValue]) {
                    NSString *dateTime =[self getUserReadableDateTime:fieldDataObj.internalValue];
                    if (dateTime != nil) {
                        displayValue = dateTime;
                    }
                }
            }
            else if ([aPageField.type isEqualToString:kSfDTDate]) {
                if (![StringUtil isStringEmpty:fieldDataObj.internalValue]) {
                    NSString *dateString = [self getUserReadableDate:fieldDataObj.internalValue];
                    if (dateString != nil) {
                        displayValue = dateString;
                    }
                }
            }
            else if ([aPageField.type isEqualToString:kSfDTBoolean]) {
                if ([fieldDataObj.internalValue isEqualToString:@"1"]) {
                    displayValue = @"YES";
                }
                else if ([fieldDataObj.internalValue isEqualToString:@"0"]) {
                    displayValue = @"NO";
                }
            }

           if(![StringUtil isStringEmpty:displayValue])
           {
               fieldDataObj.displayValue = displayValue;
           }

           [eachDataDict setObject:fieldDataObj forKey:eachField];
        }
        
        /*Update each dict with picklist ,  multi picklist and  recordTypeId display values */
        [self updatePicklistDisplayValues:eachDataDict picklistFields:[dataTypeVsFieldsDict objectForKey:kSfDTPicklist] multiPicklistFields:[dataTypeVsFieldsDict objectForKey:kSfDTMultiPicklist] ];
        
        [self updateRecordTypeDisplayValue:eachDataDict];
        
        if ([fieldNameAndInternalValue count] > 0)
        {
            [self updateReferenceFieldDisplayValues:fieldNameAndInternalValue andFieldObjectNames:fieldNameAndObjectApiName];
            for (NSString *fieldName in fieldNameAndObjectApiName) {
                SFMRecordFieldData *fieldData = [eachDataDict objectForKey:fieldName];
                NSString *displayValue = [fieldNameAndInternalValue objectForKey:fieldName];
                if (displayValue != nil && ![displayValue isEqualToString:@""]) {
                    fieldData.displayValue = displayValue;
                }
            }
        }
        
        [recordArray addObject:eachDataDict];
    }
    
    return recordArray;
}

-(NSString *)getUserReadableDateTime:(NSString *)dateTime
{
    return [DateUtil getUserReadableDateForDateBaseDate:dateTime];
}

-(NSString *)getUserReadableDate:(NSString *)dateTime
{
    NSString *dateString = nil;
    NSDate * date = [DateUtil dateFromString:dateTime inFormat:kDateFormatDefault];
    if (date != nil) {
        dateString = [DateUtil stringFromDate:date inFormat:kDateFormatType5];
    }
    return dateString;
}

-(NSArray *)getDisplayFields:(SFMLookUp *)lookUpObj
{
    NSMutableArray * displayFields = [[NSMutableArray alloc] init];
    
    for (SFNamedSearchComponentModel * model in lookUpObj.displayFields) {
        
        if(model.fieldName != nil){
            [displayFields addObject:model.fieldName];
        }
    }
    
    if([displayFields count] == 0){
        if (lookUpObj.defaultColoumnName != nil) {
            [displayFields addObject:lookUpObj.defaultColoumnName];
        }
    }
    
    [displayFields addObject:@"Id"];
    
    return displayFields;
}
-(NSArray *)getWhereclause:(SFMLookUp *)lookUpObj 
{
    
    NSMutableArray * criteriaArray = [[NSMutableArray alloc] init];
    
    DBCriteria * criteria1 = [[DBCriteria alloc] initWithFieldName:@"Id" operatorType:SQLOperatorIsNotNull andFieldValue:nil];
    
    [criteriaArray addObject:criteria1];
    
    if(![StringUtil isStringEmpty:lookUpObj.searchString])
    {
        for ( int counter = 0 ; counter <  [lookUpObj.searchFields count]; counter ++)
        {
            SFNamedSearchComponentModel * compModel  =   [lookUpObj.searchFields objectAtIndex:counter];
            DBCriteria * tempCriteria = nil;
            if([compModel.fieldDataType isEqualToString:kLookUpReference])
            {
                SFObjectFieldModel * fieldModel =  [lookUpObj.fieldInfoDict objectForKey:compModel.fieldName];
                NSString * referenceTo  = fieldModel.referenceTo;
                
                NSString * nameField = [SFMPageHelper getNameFieldForObject:referenceTo];
                
                DBCriteria * insserCiteria = [[DBCriteria alloc] initWithFieldName:nameField operatorType:SQLOperatorLike andFieldValue:lookUpObj.searchString];
                
                DBRequestSelect *innerSelect = [[DBRequestSelect alloc] initWithTableName:referenceTo andFieldNames:[NSArray arrayWithObject:@"Id"] whereCriteria:insserCiteria];

                 tempCriteria =  [[DBCriteria alloc] initWithFieldName:compModel.fieldName operatorType:SQLOperatorIn andInnerQUeryRequest:innerSelect];
                
            }
            else
            {
                 tempCriteria =  [[DBCriteria alloc] initWithFieldName:compModel.fieldName operatorType:SQLOperatorLike andFieldValue:lookUpObj.searchString];
            }
            //ReferenceCheck
            
            [criteriaArray addObject:tempCriteria];
        }
    }
    
    return criteriaArray;
}

-(NSString *)advanceExpression:(SFMLookUp *)lookUpObj
{
    NSMutableString *advanceExpression  = [[NSMutableString alloc] init];
    NSMutableString *searchFieldsCount = [[NSMutableString alloc] init];
    
    for ( int counter = 0 ; counter <  [lookUpObj.searchFields count]; counter ++)
    {
        if(counter != 0){
            [searchFieldsCount appendString:@" OR "];
        }
        [searchFieldsCount appendFormat:@" %d " , (counter +2)];
    }
      if(![StringUtil isStringEmpty:lookUpObj.searchString])
      {
          [advanceExpression appendFormat:@"(1  AND (%@) )",searchFieldsCount];
      }
    else
    {
         [advanceExpression appendFormat:@"(1 )"];
    }
    
    return advanceExpression;
}

-(NSMutableDictionary *)getFieldInformation:(SFMLookUp *)lookUpObject
{
    NSMutableArray * displayFields = [[NSMutableArray alloc] init];
    
    for (SFNamedSearchComponentModel * model in lookUpObject.displayFields) {
        
        if(model.fieldName != nil){
            [displayFields addObject:model.fieldName];
        }
    }
    
    for ( int counter = 0 ; counter <  [lookUpObject.searchFields count]; counter ++)
    {
        SFNamedSearchComponentModel * compModel  =   [lookUpObject.searchFields objectAtIndex:counter];
        if(compModel.fieldName != nil){
            [displayFields addObject:compModel.fieldName];
        }
    }
    
    if(![StringUtil isStringEmpty:lookUpObject.defaultColoumnName] && ![displayFields containsObject:lookUpObject.defaultColoumnName])
    {
            [displayFields addObject:lookUpObject.defaultColoumnName];
    }
    
   
    DBCriteria * criteria1 = [[DBCriteria alloc] initWithFieldName:kobjectName operatorType:SQLOperatorEqual andFieldValue:lookUpObject.objectName];
    
    DBCriteria * criteria2 = [[DBCriteria alloc] initWithFieldName:kfieldname operatorType:SQLOperatorIn andFieldValues:displayFields];

    
    id <SFObjectFieldDAO> sfObjectField = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectField];
    
    NSArray * resultSet =   [sfObjectField fetchSFObjectFieldsInfoByFields:nil andCriteriaArray:[NSArray arrayWithObjects:criteria1,criteria2, nil] advanceExpression:@"( 1 AND 2 )"];
    
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

- (NSMutableDictionary *)getFieldDataTypeMap:(NSArray *)fields
{
    NSMutableDictionary *mappingDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    for(SFObjectFieldModel *eachField in fields) {
        if ([eachField.type isEqualToString:kSfDTPicklist]) {
            NSMutableArray * picklistFields = [mappingDict objectForKey:kSfDTPicklist];
            if (picklistFields == nil) {
                NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:0];
                [array addObject:eachField.fieldName];
                [mappingDict setObject:array forKey:kSfDTPicklist];
            }
            else {
                [picklistFields addObject:eachField.fieldName];
            }
        }
        else if ([eachField.type isEqualToString:kSfDTMultiPicklist]) {
            NSMutableArray * multiPicklistFields = [mappingDict objectForKey:kSfDTMultiPicklist];
            if (multiPicklistFields == nil) {
                NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:0];
                [array addObject:eachField.fieldName];
                [mappingDict setObject:array forKey:kSfDTMultiPicklist];
            }
            else {
                [multiPicklistFields addObject:eachField.fieldName];
            }
        }
        else if ([eachField.type isEqualToString:kSfDTReference]  && [eachField.fieldName isEqualToString:kSfDTRecordTypeId]) {
            NSMutableArray * recordTypeFields = [mappingDict objectForKey:kSfDTRecordTypeId];
            if (recordTypeFields == nil) {
                NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:0];
                [array addObject:eachField.fieldName];
                [mappingDict setObject:array forKey:kSfDTRecordTypeId];
            }
            else {
                [recordTypeFields addObject:eachField.fieldName];
            }
        }
    }
    return mappingDict;
}

- (void)fillPickPickListAndRecordTypeInfo:(NSDictionary *)dataDictionary andObjectName:(NSString *)objectName
{
    NSMutableArray *picklistFields  = [dataDictionary objectForKey:kSfDTPicklist];
    NSMutableArray *multiPicklistFields = [dataDictionary objectForKey:kSfDTMultiPicklist];
    NSMutableArray *recordTypeFields = [dataDictionary objectForKey:kSfDTRecordTypeId];
    
    NSMutableArray *finalPicklist = nil;
    
    if ([picklistFields count] > 0) {
        finalPicklist = [[NSMutableArray alloc] initWithCapacity:0];
        [finalPicklist addObjectsFromArray:picklistFields];
    }
    if ([multiPicklistFields count] > 0) {
        if (finalPicklist == nil)
            finalPicklist = [[NSMutableArray alloc] initWithCapacity:0];
        [finalPicklist addObjectsFromArray:multiPicklistFields];
    }
    if ([finalPicklist count] > 0) {
        [self updatePicklistDataFor:objectName fields:finalPicklist];
    }
    if ([recordTypeFields count] > 0) {
        [self updateRecordTypeDataFor:objectName fields:recordTypeFields];
    }
}

- (void)updatePicklistDataFor:(NSString *)objectName fields:(NSMutableArray *)pickListFileds
{
    NSArray * picklistArray = [SFMPageHelper getPicklistValuesForObject:objectName pickListFields:pickListFileds];
    
    if ([picklistArray count] > 0) {
        if (self.pickListData == nil) {
            self.pickListData = [[NSMutableDictionary alloc] initWithCapacity:0];
        }
        for (SFPicklistModel * model in picklistArray) {
            if (model != nil) {
                NSMutableDictionary *picklistDict = [self.pickListData objectForKey:model.fieldName];
                if (picklistDict == nil) {
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:0];
                    [dict setObject:model forKey:model.value];
                    [self.pickListData setObject:dict forKey:model.fieldName];
                }
                else {
                    [picklistDict setObject:model forKey:model.value];
                }
            }
        }
    }
}

- (void)updateRecordTypeDataFor:(NSString *)objectName fields:(NSMutableArray *)recordTypeFields
{
    NSArray * recordTypeArray = [SFMPageHelper getRecordTypeValuesForObject:objectName];
    
    if ([recordTypeArray count] > 0) {
        if (self.recordTypeData == nil) {
            self.recordTypeData = [[NSMutableDictionary alloc] initWithCapacity:0];
        }
        for (SFRecordTypeModel * model in recordTypeArray) {
            if (model != nil) {
                if (![self.recordTypeData objectForKey:model.recordTypeId]) {
                    [self.recordTypeData setObject:model forKey:model.recordTypeId];
                }
            }
        }
    }
}

- (void)updatePicklistDisplayValues:(NSDictionary *)dataDict
                     picklistFields:(NSMutableArray *)picklistFields
                multiPicklistFields:(NSMutableArray *)multiPicklistFields
{
    if ([self.pickListData count] > 0) {
        for (NSString *pickListFieldName in picklistFields) {
            NSMutableDictionary *picklistDict = [self.pickListData objectForKey:pickListFieldName];
            SFMRecordFieldData *field = [dataDict objectForKey:pickListFieldName];
            NSString *displayValue = nil;
            if (field != nil) {
                displayValue = field.internalValue;
            }
            if ([picklistDict count] > 0 ) {
                if (![StringUtil isStringEmpty:displayValue]) {
                    SFPicklistModel *model = [picklistDict objectForKey:displayValue];
                    if (model != nil) {
                        field.displayValue = model.label;
                    }
                }
            }
        }
        for (NSString *pickListFieldName in multiPicklistFields) {
            NSMutableDictionary *picklistDict = [self.pickListData objectForKey:pickListFieldName];
            SFMRecordFieldData *field = [dataDict objectForKey:pickListFieldName];
            NSString *displayValue = nil;
            if (field != nil) {
                displayValue = field.internalValue;
            }
            if ([picklistDict count] > 0 ) {
                if (![StringUtil isStringEmpty:displayValue]) {
                    SFPicklistModel *model = [picklistDict objectForKey:displayValue];
                    if (model != nil) {
                        field.displayValue = model.label;
                    }
                }
            }
        }
    }
}

- (void)updateRecordTypeDisplayValue:(NSMutableDictionary *)dataDictionary
{
    if ([self.recordTypeData count] > 0) {
        SFMRecordFieldData *fieldData = [dataDictionary objectForKey:kSfDTRecordTypeId];
        if (fieldData != nil) {
            SFRecordTypeModel *model = [self.recordTypeData objectForKey:fieldData.internalValue];
            if (model != nil) {
                fieldData.displayValue = model.recordtypeLabel;
            }
        }
    }
}

- (void)updateReferenceFieldDisplayValues:(NSMutableDictionary *)fieldNameAndInternalValue
                      andFieldObjectNames:(NSDictionary *)fieldNameAndObjectNames
{
    
    NSMutableSet *foundRefernceValues = [[NSMutableSet alloc] initWithCapacity:0];
    
    NSArray *array = [fieldNameAndInternalValue allValues];
    
    NSMutableSet *set  = [[NSMutableSet alloc] initWithArray:[NSArray arrayWithArray:array]];
    
    for (NSString *objectName in [fieldNameAndInternalValue allKeys]) {
        NSString * value = [fieldNameAndInternalValue objectForKey:objectName];
        if ([StringUtil isStringEmpty:value])
            continue;
        NSString * relatedObjectName = [fieldNameAndObjectNames objectForKey:objectName];
        if ([relatedObjectName length] > 0) {
            //Get the value form the transactionmodel
            NSString * displayValue = [self getReferenceValueForObject:relatedObjectName andsfId:value];
            //Check Also if record exists
            
            if (![StringUtil isStringEmpty:displayValue]) {
                [foundRefernceValues addObject:value];
                [fieldNameAndInternalValue setObject:displayValue forKey:objectName];
            }
        }
    }
    
    //check for remaning id
    NSMutableSet *remainigIds = [NSMutableSet setWithSet:set]; //To test
    [remainigIds minusSet:foundRefernceValues];
    
    NSDictionary *idDictionary = nil;
    
    if ([set count] > 0) {
        idDictionary = [self getReferenceFieldValueFromLookUpTable:remainigIds];
    }
    
    for (NSString * sfId in remainigIds) {
        NSString * newValue = [idDictionary objectForKey:sfId];
        if ([StringUtil isStringEmpty:newValue])
            continue;
        NSArray *matchingKeys = [fieldNameAndInternalValue allKeysForObject:sfId];
        if ([matchingKeys count] > 0)
            [fieldNameAndInternalValue setValue:newValue forKey:[matchingKeys objectAtIndex:0]];
    }
}

- (NSString *)getReferenceValueForObject:(NSString *)objectName andsfId:(NSString *)sfId
{
    return [SFMPageHelper getRefernceFieldValueForObject:objectName andId:sfId];
}

- (NSDictionary *)getReferenceFieldValueFromLookUpTable:(NSMutableSet *)remainingIds
{
    return [SFMPageHelper getValuesFromReferenceTable:[remainingIds allObjects]];
}

-(NSString *)getObjectLabel:(NSString *)objectName
{
   return [SFMPageHelper getObjectLabelForObjectName:objectName];
}

/* Reference handling  in Where  clause*/
/* Display Picklist ,date , dateTime and reference handling,Record Type*/
/* default column name  Check*/
/* Filters Implementation*/
/*Field value label mapping dict*/
@end
