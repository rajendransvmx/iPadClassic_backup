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
#import "SFNamedSearchFilterDAO.h"
#import "SFMLookUpFilter.h"
#import "SFMPageEditHelper.h"
#import "SFExpressionParser.h"
#import "SFExpressionModel.h"
#import "SFExpressionComponentDAO.h"
#import "SFExpressionComponentModel.h"
#import "SFMLookUpViewController.h"
#import "StringUtil.h"
#import "TagManager.h"
#import "DataTypeUtility.h"
#import "NSDate+SMXDaysCount.h"
#import "Utility.h"

@interface SFMPageLookUpHelper () {
    BOOL isCircularRefEnabled;
    BOOL includeOfflineRecords;
}

@property (nonatomic, strong) NSMutableDictionary * pickListData;
@property (nonatomic, strong) NSMutableDictionary * recordTypeData;
@property (nonatomic, assign) NSInteger expressionCount;
@property (nonatomic, assign) BOOL isCriteriaExistsForPreFilter;
@property (nonatomic, assign) BOOL isCriteriaExistsForAdvilter;
@property (nonatomic, strong) DataTypeUtility *dataTypeUtil;
@end

@implementation SFMPageLookUpHelper

-(void)loadLookUpConfigarationForLookUpObject:(SFMLookUp *)lookUpObj
{
    if(lookUpObj == nil){
       lookUpObj = [[SFMLookUp alloc] init];
       
    }
    /* fill up LooUp details*/
    [self fillLookUpMetaDataLookUp:lookUpObj];
    
    /*fill Up LookUp component details*/
    [self fillLookUpComponentsForLookUpObject:lookUpObj];
    
    
   lookUpObj.fieldInfoDict = [self getFieldInformation:lookUpObj];
   lookUpObj.defaultColumsnFieldRelationships = [self getFieldInformationForDefaultColumns:lookUpObj];
    
    /*fill up look up filtes*/
    
   // [self fillDataForLookUpObject:lookUpObj];
    self.isCriteriaExistsForPreFilter = NO;
    self.isCriteriaExistsForAdvilter  = NO;
    
}

-(void)fillLookUpMetaDataLookUp:(SFMLookUp *)lookUpObj
{
    NSArray * criteriaArray = nil;
    DBCriteria * criteria1 = nil;
    DBCriteria * criteria2 = nil;
    DBCriteria * criteria3 = nil;
    BOOL islookIDNil = NO;

    if([StringUtil isStringEmpty:lookUpObj.lookUpId]){
        criteria1 = [[DBCriteria alloc] initWithFieldName:@"isStandard" operatorType:SQLOperatorEqual andFieldValue:@"1"];
        criteria3 = [[DBCriteria alloc] initWithFieldName:@"isDefault" operatorType:SQLOperatorEqual andFieldValue:@"1"];
        islookIDNil = YES;
    }
    else
    {
        criteria1 = [[DBCriteria alloc] initWithFieldName:@"namedSearchId" operatorType:SQLOperatorEqual andFieldValue:lookUpObj.lookUpId];
    }

    criteria2 = [[DBCriteria alloc] initWithFieldName:@"objectName" operatorType:SQLOperatorEqual andFieldValue:lookUpObj.objectName];

    criteriaArray = [[NSArray alloc] initWithObjects:criteria1,criteria2,criteria3, nil];

    NSString * advExpression = nil;
    if (criteria3) {
        advExpression = @"((1 OR 3) AND 2)";
    }
    else{
        advExpression = @"(1 AND 2)";
    }
    
    NSArray * fieldsArray = [[NSArray alloc] initWithObjects:@"noOfLookupRecords",@"defaultLookupColumn",@"searchName", @"namedSearchId", @"isStandard", @"isDefault",nil];

    SFNamedSearchModel * namedSearchModel;
    NSArray *theNamedList;
    id<SFNamedSearchDAO>   namedSearchObj =  [FactoryDAO serviceByServiceType:ServiceTypeNamedSearch];

    if (islookIDNil) {
            theNamedList =  [namedSearchObj getLookUpRecordListForDBCriterias:criteriaArray advancedExpression:advExpression fields:fieldsArray];
        for (SFNamedSearchModel * searchModel in theNamedList) {

            namedSearchModel = searchModel;
            if (searchModel.isDefault && !searchModel.isStandard) {
                break;
            }
        }
    }
    else
    {
        namedSearchModel =  [namedSearchObj getLookUpRecordsForDBCriteria:criteriaArray advancedExpression:advExpression fields:fieldsArray];
    }
     if([StringUtil isStringEmpty:lookUpObj.lookUpId])
     {
         lookUpObj.lookUpId = namedSearchModel.namedSearchId;
     }
    lookUpObj.recordLimit = [namedSearchModel.noOfLookupRecords intValue];
    lookUpObj.defaultColoumnName = namedSearchModel.defaultLookupColumn;
    lookUpObj.serachName = namedSearchModel.searchName;
    
    //Get the defaultColumn Name for the selected lookup object.This is requried for include online item.
    
    lookUpObj.defaultObjectColumnName  = [SFMPageHelper getNameFieldForObject:lookUpObj.objectName];
    

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
    
    NSArray * fieldsArray = [[NSArray alloc] initWithObjects: @"fieldName",@"searchObjectFieldType", @"fieldDataType", @"namedSearchId",@"fieldRelationshipName",@"keyNameField",nil];
    
    
    id<SFNamedSearchComponentDAO>   namedSearchObj =  [FactoryDAO serviceByServiceType:ServiceTypeSearchObjectDetail];
    
    
    NSDictionary * componentInfo =  [namedSearchObj getNamedSearchComponentWithDBcriteria:criteriaArray advanceExpression:advExpression fields:fieldsArray orderbyField:[NSArray arrayWithObject:@"sequence"] distinct:YES];
    

   lookUpObj.searchFields  = [componentInfo objectForKey:kSearchFieldTypeSearch];
   lookUpObj.displayFields = [componentInfo objectForKey:kSearchFieldTypeResult];
}

-(void)fillDataForLookUpObject:(SFMLookUp *)lookUpObj
{
    
    NSArray * fieldsArray = [self getDisplayFields:lookUpObj];
    
    NSArray * criteriaArray = [self getWhereclause:lookUpObj forLocalRecords:NO];
    
    NSString * advanceExpression = [self advanceExpression:lookUpObj];
    
    id <TransactionObjectDAO> transactionModel = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    NSArray * dataArray = [transactionModel fetchDataForObject:lookUpObj.objectName fields:fieldsArray expression:advanceExpression criteria:criteriaArray recordsLimit:lookUpObj.recordLimit];
  
    NSArray * recordsArray = [self getRecordArrayFromTransactionModel:dataArray lookUpObject:lookUpObj forDisplayFields:fieldsArray];
    
    lookUpObj.dataArray = recordsArray;
    
}

/*
 Method: getDefaultColumnNameDataForLookup
 Defect fixed: 023314 and 023783
 Description: This method will display the default lookup values on edit sfm.
 */

- (NSDictionary*)getDefaultColumnNameDataForLookup:(SFMLookUp*)lookupObject withSfId:(NSString*)sfId  {
    
    NSMutableArray * criteriaArray = [[NSMutableArray alloc] init];
    NSArray *fieldsArray = @[lookupObject.defaultColoumnName];
    
    
    if (sfId != nil ) {
        DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorEqual andFieldValue:sfId];
        
        [criteriaArray addObject:criteria1];
    }
    id <TransactionObjectDAO> transactionModel = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    NSArray * dataArray = [transactionModel fetchDataForObject:lookupObject.objectName fields:fieldsArray expression:nil criteria:criteriaArray recordsLimit:1];
    
    NSArray *fieldInfo = [self getFieldInformationForDefaultColumns:lookupObject];
    
    NSString *fieldRelationshipName = nil;

    NSString *referenceTo = nil;
    for (SFObjectFieldModel *objectField in fieldInfo) {
        
        if ([objectField.fieldName isEqualToString:lookupObject.defaultColoumnName]) {
            referenceTo = objectField.referenceTo;
            NSString *keyFieldName = [SFMPageHelper getNameFieldForObject:objectField.referenceTo];
            if ([objectField.relationName length] > 0 && [keyFieldName length] > 0)
            {
                fieldRelationshipName = [NSString stringWithFormat:@"%@.%@",objectField.relationName,keyFieldName];
            }
            break;
        }
    }
    
    NSDictionary *dictioanry = [[dataArray firstObject] getFieldValueDictionary];;

    if (![StringUtil isStringEmpty:fieldRelationshipName]) {
        
        
        NSMutableDictionary * fieldNameAndInternalValue = [[NSMutableDictionary alloc] initWithCapacity:0];
        NSMutableDictionary * fieldNameAndObjectApiName =  [[NSMutableDictionary alloc] initWithCapacity:0];
        
        if (![StringUtil isStringEmpty:[dictioanry objectForKey:lookupObject.defaultColoumnName]]) {
            [fieldNameAndInternalValue setObject:[dictioanry objectForKey:lookupObject.defaultColoumnName] forKey:lookupObject.defaultColoumnName];
            if (![StringUtil isStringEmpty:referenceTo]) {
                [fieldNameAndObjectApiName setObject:referenceTo forKey:lookupObject.defaultColoumnName];
            }
            
            if ([fieldNameAndInternalValue count] > 0)
            {
                [self updateReferenceFieldDisplayValues:fieldNameAndInternalValue andFieldObjectNames:fieldNameAndObjectApiName];
                for (NSString *fieldName in fieldNameAndObjectApiName) {
                    NSString *displayValue = [fieldNameAndInternalValue objectForKey:fieldName];
                    if (![Utility isStringEmpty:displayValue]) {
                        [dictioanry setValue:displayValue forKey:lookupObject.defaultColoumnName];
                    }
                }
            }
        }
        
    }

    return dictioanry;
}

/*
  Method:fillOnlineLookupData:forLookupObject
  Params:onlineDataArray,lookUpObj
  Description:
  1.Get all sifids from onlineDataArray.
  2.Get all local records which matches with online sifds.
  3.Update localIds with onlineDataArray if sfid is available.This will indicate that record exits in local DB.
  4.Now get all locally created records which doesn't have sfid with circular check.
  5.Add locally created records with onlineDataArray.
 */

- (void)fillOnlineLookupData:(NSMutableArray*)onlineDataArray forLookupObject:(SFMLookUp*)lookUpObj {
    
    NSMutableArray *finalArray = [[NSMutableArray alloc] init];

    if (onlineDataArray.count > 0) {
        NSMutableArray *allSfids = [[NSMutableArray alloc] initWithCapacity:0];
        
        for (TransactionObjectModel *objectModel in onlineDataArray) {
            NSDictionary *currentDictionary = [objectModel getFieldValueDictionary];
            NSString *sfID = [currentDictionary objectForKey:kId];
            if (![Utility isStringEmpty:sfID]) {
                [allSfids addObject:sfID];
            }
        }
        
        NSArray * fieldsArray = [self getDisplayFields:lookUpObj];
        NSArray * criteriaArray = [self getWhereclauseForOnlineLookupData:lookUpObj withSFIds:allSfids];
        
        //    NSString * advanceExpression = [self advanceExpressionForOnlineData:lookUpObj withSFId:allSfids];
        NSString * advanceExpression = nil;
        
        id <TransactionObjectDAO> transactionModel = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
        
        NSArray * dataArray = [transactionModel fetchDataForObject:lookUpObj.objectName fields:fieldsArray expression:advanceExpression criteria:criteriaArray recordsLimit:lookUpObj.recordLimit];
        
        NSArray * localRecordsArray = [self getRecordArrayFromTransactionModel:dataArray lookUpObject:lookUpObj forDisplayFields:fieldsArray];
        
        NSArray * onlineRecordsArray = [self getRecordArrayFromTransactionModelForOnline:onlineDataArray lookUpObject:lookUpObj forDisplayFields:fieldsArray];
        
        [self updateLocalIdsForOnlineData:onlineRecordsArray withLocalData:localRecordsArray];
        if (onlineRecordsArray.count > 0) {
            [finalArray addObjectsFromArray:onlineRecordsArray];
        }
    }
    
    //Get locally created records if sfids are not matched.
    NSMutableArray *localRecords = nil;
    if (onlineDataArray.count < lookUpObj.recordLimit) {
        localRecords = (NSMutableArray *)[self getOfflineLookupRecordsForLookupObject:lookUpObj];
    }
    
    if (localRecords.count > 0) {
        NSInteger index = finalArray.count;
        for (NSInteger i = index; i < lookUpObj.recordLimit; i++)
        {
            if([localRecords count ] >0)
            {
                [finalArray addObject:[localRecords objectAtIndex:0]];
                [localRecords removeObjectAtIndex:0];
            }
            else
            {
                break;
            }
        }
    }
    
    
    NSMutableSet *addedRecords = [NSMutableSet set];
    NSPredicate *dupRecordPred = [NSPredicate predicateWithBlock: ^BOOL(id obj, NSDictionary *bind) {
        NSDictionary *e = (NSDictionary*)obj;
        
        id object = [[e objectForKey:@"localId"] internalValue];
        if (!object) {
            object = [[e objectForKey:@"Id"] internalValue];
        }
        BOOL seen = [addedRecords containsObject:object];
        if (!seen) {
            [addedRecords addObject:object];
        }
        return !seen;
    }];
    
    NSArray *filtered = [finalArray filteredArrayUsingPredicate:dupRecordPred];
    
    lookUpObj.dataArray = filtered;
}

/*
 Method: getOfflineLookupRecordsForLookupObject
 Params: lookUpObj
 Description:
 Get all the locally created if sfid is null and circular reference should not happen.
 */

- (NSArray*)getOfflineLookupRecordsForLookupObject:(SFMLookUp*)lookUpObj {
    
    NSArray *lookupArray = nil;
    NSArray * fieldsArray = [self getDisplayFields:lookUpObj];
    NSArray * criteriaArray = [self getWhereclause:lookUpObj forLocalRecords:NO];
    NSString * advanceExpression = [self advanceExpression:lookUpObj];
    
    id <TransactionObjectDAO> transactionModel = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    lookupArray = [transactionModel fetchDataForObject:lookUpObj.objectName fields:fieldsArray expression:advanceExpression criteria:criteriaArray recordsLimit:lookUpObj.recordLimit];
    
    NSArray * recordsArray = [self getRecordArrayFromTransactionModel:lookupArray lookUpObject:lookUpObj forDisplayFields:fieldsArray];
    
    return recordsArray;
    
}

/*
 Method: getReferenceFieldsFor
 Params: objectName
 Description:
 This method will get reference columns for specified table.
 */
-(NSDictionary *)getReferenceFieldsFor:(NSString *)objectName
{
    NSMutableDictionary *referenceToDict = [[NSMutableDictionary alloc] init];
    
    DBCriteria * criteia1 = [[DBCriteria alloc] initWithFieldName:@"objectName" operatorType:SQLOperatorEqual andFieldValue:objectName];
    
    
    DBCriteria * criteria2 = [[DBCriteria alloc] initWithFieldName:@"referenceTo" operatorType:SQLOperatorNotEqual andFieldValue:@"\\"];
    
    DBCriteria * criteria3 = [[DBCriteria alloc] initWithFieldName:@"referenceTo" operatorType:SQLOperatorIsNotNull andFieldValue:nil];
    
    
    id <SFObjectFieldDAO> objFieldDAO = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectField];
    
    
    //   NSArray * sfFieldObjects =   [objFieldDAO fetchSFObjectFieldsInfoByFields:[NSArray arrayWithObjects:@"fieldName", @"referenceTo" , nil] andCriteria:[NSArray arrayWithObjects:criteia1,criteria2,criteria3, nil]];
    
    NSArray * sfFieldObjects =   [objFieldDAO fetchSFObjectFieldsInfoByFields:[NSArray arrayWithObjects:@"fieldName", @"referenceTo" , nil] andCriteriaArray:[NSArray arrayWithObjects:criteia1,criteria2,criteria3, nil] advanceExpression:@"(1 AND 2 AND 3)"];
    
    for (SFObjectFieldModel * objField in sfFieldObjects) {
        [referenceToDict setObject:objField.fieldName forKey:objField.referenceTo];
    }
    
    return referenceToDict;
}
/*
 Method: getReferenceColumnNameFromReferenceDictionary
 Params: referenceDictioanry,parentObject
 Description:
 This method will get reference column from specified table with refDictioanry.
 */
- (NSString*)getReferenceColumnNameFromReferenceDictionary:(NSDictionary*)referenceDictioanry forContextObject:(NSString*)parentObject {
    
    NSString *referenceFieldName = nil;
    
    referenceFieldName = [referenceDictioanry objectForKey:parentObject];
    
    return referenceFieldName;
}
/*
 Method: updateLocalIdsForOnlineData
 Params: onlineArray,localRecordsArray
 Description:
 This method will localIds with onlineArray.This will indicate that online record exits in local DB.
 */
- (void)updateLocalIdsForOnlineData:(NSArray*)onlineArray withLocalData:(NSArray*)localRecordsArray {
    
    @autoreleasepool {
        for (NSMutableDictionary *localDictionary in localRecordsArray) {
            
            SFMRecordFieldData *localSfIdRecord = [localDictionary objectForKey:kId];
            SFMRecordFieldData *localIdrecord = [localDictionary objectForKey:kLocalId];
            
            for (NSMutableDictionary *onlineDictionary in onlineArray) {
                SFMRecordFieldData *onlineSfIdRecord = [onlineDictionary objectForKey:kId];
                
                if ([localSfIdRecord.internalValue isEqualToString:onlineSfIdRecord.internalValue]) {
                    
                    //Update with local id for online record that indicates record already exits.
                    if (![Utility isStringEmpty:localIdrecord.internalValue]) {
                        SFMRecordFieldData *fieldData = [[SFMRecordFieldData alloc] initWithFieldName:kLocalId value:localIdrecord.internalValue andDisplayValue:localIdrecord.internalValue];
                        [onlineDictionary setObject:fieldData forKey:kLocalId];
                    }
                }
            }
        }
    }
}
/*
 Method: getCircularReferenceRecordsForParentObject
 Params: parentObject
 Description:
 This method will get the circular ref records localIds */
- (NSArray*)getCircularReferenceRecordsForParentObject:(NSString*)parentObject {
 
    NSArray *circularRefRecords = nil;
    NSMutableArray * criteriaArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray *fieldsArray = [[NSMutableArray alloc] initWithCapacity:0];
    [fieldsArray addObject:@"localId"];
    
    DBCriteria * criteria = [[DBCriteria alloc] initWithFieldName:@"Id" operatorType:SQLOperatorIsNull andFieldValue:nil];
    [criteriaArray addObject:criteria];
    
    id <TransactionObjectDAO> transactionModel = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    circularRefRecords = [transactionModel fetchDataForObject:parentObject
                                                       fields:fieldsArray
                                                   expression:nil
                                                     criteria:criteriaArray
                          ];
    NSMutableArray *refRecords = [[NSMutableArray alloc] initWithCapacity:0];
    for (TransactionObjectModel *model in circularRefRecords) {
        NSDictionary *dictionary = [model getFieldValueDictionary];
        NSString *localId = [dictionary objectForKey:kLocalId];
        if (![Utility isStringEmpty:localId]) {
            [refRecords addObject:localId];
        }
    }
    
    return refRecords;
}

-(NSArray *)getRecordArrayFromTransactionModel:(NSArray *)dataArray  lookUpObject:(SFMLookUp *)lookUpObject forDisplayFields:(NSArray *)displayFields
{
    NSMutableDictionary * dataTypeVsFieldsDict =[self getFieldDataTypeMap:[lookUpObject.fieldInfoDict allValues]];
    
    [self fillPickPickListAndRecordTypeInfo:dataTypeVsFieldsDict andObjectName:lookUpObject.objectName];
    
    
    NSMutableArray *recordArray = [[NSMutableArray alloc]init];
    for(TransactionObjectModel * model in dataArray)
    {
        NSMutableDictionary * fieldNameAndInternalValue = [[NSMutableDictionary alloc] initWithCapacity:0];
        NSMutableDictionary * fieldNameAndObjectApiName =  [[NSMutableDictionary alloc] initWithCapacity:0];

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
                
                 if ([fieldDataObj.internalValue isKindOfClass:[NSString class]]) {
                     if ([fieldDataObj.internalValue isEqualToString:@"1"]) {
                         displayValue = kTrue;
                     }
                     else if ([fieldDataObj.internalValue isEqualToString:@"0"]) {
                         displayValue = kFalse;
                     }
                 } else {
                     if ([fieldDataObj.internalValue isKindOfClass:[NSNumber class]]) {
                         NSNumber *number = (NSNumber*) fieldDataObj.internalValue ;
                         displayValue = number.stringValue;
                         if ([displayValue isEqualToString:@"1"]) {
                             displayValue = kTrue;
                         }
                         else if ([displayValue isEqualToString:@"0"]) {
                             displayValue = kFalse;
                         }
                     }
                 }
                
            } else if([aPageField.type isEqualToString:kSfDTCurrency]
                      || [aPageField.type isEqualToString:kSfDTDouble]
                      || [aPageField.type isEqualToString:kSfDTPercent]
                      || [aPageField.type isEqualToString:kSfDTInteger]) {
                
                if ([fieldDataObj.internalValue isKindOfClass:[NSString class]]) {
                    displayValue = fieldDataObj.internalValue;
                } else {
                    if ([fieldDataObj.internalValue isKindOfClass:[NSNumber class]]) {
                        NSNumber *number = (NSNumber*) fieldDataObj.internalValue ;
                        displayValue = number.stringValue;
                    }
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

-(NSArray *)getRecordArrayFromTransactionModelForOnline:(NSArray *)dataArray  lookUpObject:(SFMLookUp *)lookUpObject forDisplayFields:(NSArray *)displayFields
{
    NSMutableDictionary * dataTypeVsFieldsDict =[self getFieldDataTypeMap:[lookUpObject.fieldInfoDict allValues]];
    
    [self fillPickPickListAndRecordTypeInfo:dataTypeVsFieldsDict andObjectName:lookUpObject.objectName];
    
    
    NSMutableArray *recordArray = [[NSMutableArray alloc]init];
    for(TransactionObjectModel * model in dataArray)
    {
        NSMutableDictionary * fieldNameAndInternalValue = [[NSMutableDictionary alloc] initWithCapacity:0];
        NSMutableDictionary * fieldNameAndObjectApiName =  [[NSMutableDictionary alloc] initWithCapacity:0];
        
        NSMutableDictionary * eachDataDict = [[NSMutableDictionary alloc] init];
        NSDictionary * dict =  [model getFieldValueDictionary];
        
        for ( NSString * eachField in displayFields) {
            
            SFMRecordFieldData * fieldDataObj = [[SFMRecordFieldData alloc] initWithFieldName:eachField value:[dict objectForKey:eachField] andDisplayValue:[dict objectForKey:eachField]];
            
            SFObjectFieldModel * aPageField =  [lookUpObject.fieldInfoDict objectForKey:eachField];
            
            NSString * displayValue = nil;
            
            if ([aPageField.type isEqualToString:kSfDTReference]) {
                if (![StringUtil isStringEmpty:fieldDataObj.internalValue]) {
//                    [fieldNameAndInternalValue setObject:fieldDataObj.internalValue forKey:aPageField.fieldName];
//                    if (aPageField.referenceTo != nil) {
//                        [fieldNameAndObjectApiName setObject:aPageField.referenceTo forKey:aPageField.fieldName];
//                    }
                }
                
                //Logic to update online reference records.
                
                if ([aPageField.fieldName isEqualToString:eachField]) {
                    NSString * nameField = [SFMPageHelper getNameFieldForObject:aPageField.referenceTo];
                    NSDictionary *relationNameDictioanry = [dict objectForKey:aPageField.relationName];
                    NSString *referenceId = [relationNameDictioanry objectForKey:kId];
                    if (![StringUtil isStringEmpty:referenceId]) {
                        fieldDataObj.internalValue = referenceId;
                    }
                    NSString *nameString = [relationNameDictioanry objectForKey:nameField];
                    if (![StringUtil isStringEmpty:referenceId]) {
                        fieldDataObj.displayValue = nameString;
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
                
                if ([fieldDataObj.internalValue isKindOfClass:[NSString class]]) {
                    if ([fieldDataObj.internalValue isEqualToString:@"1"]) {
                        displayValue = kTrue;
                    }
                    else if ([fieldDataObj.internalValue isEqualToString:@"0"]) {
                        displayValue = kFalse;
                    }
                } else {
                    if ([fieldDataObj.internalValue isKindOfClass:[NSNumber class]]) {
                        NSNumber *number = (NSNumber*) fieldDataObj.internalValue ;
                        displayValue = number.stringValue;
                        if ([displayValue isEqualToString:@"1"]) {
                            displayValue = kTrue;
                        }
                        else if ([displayValue isEqualToString:@"0"]) {
                            displayValue = kFalse;
                        }
                    }
                }
                
            } else if([aPageField.type isEqualToString:kSfDTCurrency]
                      || [aPageField.type isEqualToString:kSfDTDouble]
                      || [aPageField.type isEqualToString:kSfDTPercent]
                      || [aPageField.type isEqualToString:kSfDTInteger]) {
                
                if ([fieldDataObj.internalValue isKindOfClass:[NSString class]]) {
                    displayValue = fieldDataObj.internalValue;
                } else {
                    if ([fieldDataObj.internalValue isKindOfClass:[NSNumber class]]) {
                        NSNumber *number = (NSNumber*) fieldDataObj.internalValue ;
                        displayValue = number.stringValue;
                    }
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
        //dateString = [DateUtil stringFromDate:date inFormat:kDateFormatType5];
        //Madhusudhan HK: 020516,
        dateString = [NSDate localDateTimeStringFromDate:date inFormat:kDateFormatType5];
        
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
    if(![StringUtil isStringEmpty:lookUpObj.defaultColoumnName])
    {
        [displayFields addObject:lookUpObj.defaultColoumnName];
    }
    if(![StringUtil isStringEmpty:lookUpObj.defaultObjectColumnName])
    {
        [displayFields addObject:lookUpObj.defaultObjectColumnName];
    }
    [displayFields addObject:@"Id"];
    [displayFields addObject:@"localId"]; 
    
    return displayFields;
}

-(NSArray *)getWhereclause:(SFMLookUp *)lookUpObj forLocalRecords:(BOOL)localRecords
{
    NSMutableArray * criteriaArray = [[NSMutableArray alloc] init];
    
    /******** Circular reference check **************/
    NSArray *circularRefArray = [self getCircularReferenceRecordsForParentObject:lookUpObj.contextLookupFilter.lookupContextParentObject];
    
    NSDictionary *referenceDictionary = [self getReferenceFieldsFor:lookUpObj.objectName];
    
    NSString *referenceFieldName = [self getReferenceColumnNameFromReferenceDictionary:referenceDictionary forContextObject:lookUpObj.contextLookupFilter.lookupContextParentObject];
    
    if (circularRefArray.count > 0 && ![Utility isStringEmpty:referenceFieldName]) {
        
        isCircularRefEnabled = YES;
        DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:referenceFieldName operatorType:SQLOperatorNotIn andFieldValues:circularRefArray];
        
        [criteriaArray addObject:criteria];
        
        DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:referenceFieldName operatorType:SQLOperatorIsNull andFieldValues:nil];
        [criteriaArray addObject:criteria1];
    }
    
    if (localRecords == YES) {
        includeOfflineRecords = YES;
        //Get local records if SFID is null.
        DBCriteria * criteria = [[DBCriteria alloc] initWithFieldName:@"Id" operatorType:SQLOperatorIsNull andFieldValue:nil];
        [criteriaArray addObject:criteria];
    }
    
//    DBCriteria * criteria1 = [[DBCriteria alloc] initWithFieldName:@"Id" operatorType:SQLOperatorIsNotNull andFieldValue:nil];
    
//    [criteriaArray addObject:criteria1];
    
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
    if ([lookUpObj.preFilters count] > 0) {
        NSArray *filerCriteria = [self getCriteriaArrayForPreFilters:lookUpObj.preFilters];
        if ([filerCriteria count] > 0) {
            [criteriaArray addObjectsFromArray:filerCriteria];
        }
    }
    
    if ([lookUpObj.advanceFilters count] > 0) {
        NSArray *filerCriteria = [self getCriteriaArrayForAdvanceFilters:lookUpObj.advanceFilters];
        if ([filerCriteria count] > 0) {
            [criteriaArray addObjectsFromArray:filerCriteria];
        }
    }
    if (lookUpObj.contextLookupFilter.lookupContext != nil && lookUpObj.contextLookupFilter.lookupContext.length > 0) {
        NSArray *contextfilterCriteria = [self getCriteriaArrayForContextLookUp:lookUpObj];
        if ([contextfilterCriteria count] > 0) {
            [criteriaArray addObjectsFromArray:contextfilterCriteria];
        }
    }
    return criteriaArray;
}

-(NSArray *)getWhereclauseForOnlineLookupData:(SFMLookUp *)lookUpObj withSFIds:(NSMutableArray*)allSFIds
{
    NSMutableArray * criteriaArray = [[NSMutableArray alloc] init];
    
    
    if (allSFIds != nil && allSFIds.count > 0) { // get local records which matches with online records.
        DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorIn andFieldValues:allSFIds];
        
        [criteriaArray addObject:criteria1];
    }
    
    return criteriaArray;
}



-(NSString *)advanceExpression:(SFMLookUp *)lookUpObj
{
    NSMutableString *advanceExpression  = [[NSMutableString alloc] init];
    NSMutableString *searchFieldsCount = [[NSMutableString alloc] init];
    
    if (isCircularRefEnabled) {
        for ( int counter = 0 ; counter <  [lookUpObj.searchFields count]; counter ++)
        {
            if(counter != 0){
                [searchFieldsCount appendString:@" OR "];
            }
            if (includeOfflineRecords) {
                [searchFieldsCount appendFormat:@" %d " , (counter +4)];
            } else {
                [searchFieldsCount appendFormat:@" %d " , (counter +3)];
            }
        }
    } else {
        for ( int counter = 0 ; counter <  [lookUpObj.searchFields count]; counter ++)
        {
            if(counter != 0){
                [searchFieldsCount appendString:@" OR "];
            }
            if (includeOfflineRecords) {
                [searchFieldsCount appendFormat:@" %d " , (counter +2)];
            } else {
                [searchFieldsCount appendFormat:@" %d " , (counter +1)];

            }
        }
    }
    
    //Forming the advance expression here.
    if(![StringUtil isStringEmpty:lookUpObj.searchString])
    {
        if (isCircularRefEnabled) {
            
            if (includeOfflineRecords) {
                if (searchFieldsCount.length == 0) {
                    [advanceExpression appendFormat:@"( ( (1 OR 2) AND 3) "];

                } else {
                    [advanceExpression appendFormat:@"( ( (1 OR 2) AND 3)  AND (%@) )",searchFieldsCount];
                }
            } else {
                
                if (searchFieldsCount.length == 0) {
                    [advanceExpression appendFormat:@"( (1 OR 2) "];

                } else {
                    [advanceExpression appendFormat:@"( (1 OR 2)  AND (%@) )",searchFieldsCount];
                }
            }

        } else {
            
            if (includeOfflineRecords) {
                if (searchFieldsCount.length == 0) {
                    [advanceExpression appendFormat:@"( 1 )"];
                } else {
                    [advanceExpression appendFormat:@"(1 AND (%@) )",searchFieldsCount];
                }
            } else {
                
                if (searchFieldsCount.length == 0) {
                    [advanceExpression appendFormat:@""];
                } else {
                    [advanceExpression appendFormat:@"(%@)",searchFieldsCount];
                }
            }
        }
    }
    else
    {
        if (isCircularRefEnabled) {
            if (includeOfflineRecords) {
                [advanceExpression appendFormat:@"((1 OR 2) AND 3 )"];
            } else {
                [advanceExpression appendFormat:@"(1 OR 2)"];
            }
        } else {
            
            if (includeOfflineRecords) {
                [advanceExpression appendFormat:@"( 1 )"];
            } else {
                [advanceExpression appendFormat:@""];
            }
        }
    }
    

    [self updateExpressionCount:lookUpObj];
    
    if ([lookUpObj.preFilters count] > 0) {
        [self updateAdvanceExpressionForFiltes:lookUpObj.preFilters expression:advanceExpression];
    }
    
    if ([lookUpObj.advanceFilters count] > 0) {
        [self updateAdvanceExpressionForAdvanceFiltes:lookUpObj.advanceFilters expression:advanceExpression];
    }
    if (lookUpObj.contextLookupFilter.lookupContext != nil && lookUpObj.contextLookupFilter.lookupContext.length > 0 && lookUpObj.contextLookupFilter.defaultOn ) {
        [self updateAdvancedExpressionForContextFilter:advanceExpression];
    }
    
    //Reset the values.
    isCircularRefEnabled = NO;
    includeOfflineRecords = NO;

    
    return advanceExpression;
}

-(NSString *)advanceExpressionForOnlineData:(SFMLookUp *)lookUpObj withSFId:(NSArray*)sfIds
{
    NSMutableString *advanceExpression  = [[NSMutableString alloc] init];
    NSMutableString *searchFieldsCount = [[NSMutableString alloc] init];
    
    
    for ( int counter = 0 ; counter <  [lookUpObj.searchFields count]; counter ++)
    {
        if(counter != 0){
            [searchFieldsCount appendString:@" OR "];
        }
        if (sfIds.count > 0) {
            [searchFieldsCount appendFormat:@" %d " , (counter +2)];
        } else {
            [searchFieldsCount appendFormat:@" %d " , (counter +1)];
        }
    }
    
    
    if(![StringUtil isStringEmpty:lookUpObj.searchString])
    {
        if (sfIds.count > 0) {
            [advanceExpression appendFormat:@"(1  AND (%@) )",searchFieldsCount];

        } else {
            [advanceExpression appendFormat:@"(%@)",searchFieldsCount];
        }
        
    }
    else
    {
        [advanceExpression appendFormat:@"(1)"];
    }
    
    [self updateExpressionCount:lookUpObj];
    
    if ([lookUpObj.preFilters count] > 0) {
        [self updateAdvanceExpressionForFiltes:lookUpObj.preFilters expression:advanceExpression];
    }
    
    if ([lookUpObj.advanceFilters count] > 0) {
        [self updateAdvanceExpressionForAdvanceFiltes:lookUpObj.advanceFilters expression:advanceExpression];
    }
    if (lookUpObj.contextLookupFilter.lookupContext != nil && lookUpObj.contextLookupFilter.lookupContext.length > 0 && lookUpObj.contextLookupFilter.defaultOn ) {
        [self updateAdvancedExpressionForContextFilter:advanceExpression];
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
        if(compModel.fieldName != nil && ![displayFields containsObject:compModel.fieldName]){
            [displayFields addObject:compModel.fieldName];
        }
    }
    if(![StringUtil isStringEmpty:lookUpObject.defaultColoumnName] && ![displayFields containsObject:lookUpObject.defaultColoumnName])
    {
            [displayFields addObject:lookUpObject.defaultColoumnName];
    }
    
    if(![StringUtil isStringEmpty:lookUpObject.defaultObjectColumnName] && ![displayFields containsObject:lookUpObject.defaultObjectColumnName])
    {
        [displayFields addObject:lookUpObject.defaultObjectColumnName];
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

-(NSArray *)getFieldInformationForDefaultColumns:(SFMLookUp *)lookUpObject
{
    NSMutableArray * displayFields = [[NSMutableArray alloc] init];
    
    
    if(![StringUtil isStringEmpty:lookUpObject.defaultColoumnName] && ![displayFields containsObject:lookUpObject.defaultColoumnName])
    {
        [displayFields addObject:lookUpObject.defaultColoumnName];
    }
    
    if(![StringUtil isStringEmpty:lookUpObject.defaultObjectColumnName] && ![displayFields containsObject:lookUpObject.defaultObjectColumnName])
    {
        [displayFields addObject:lookUpObject.defaultObjectColumnName];
    }
    
    DBCriteria * criteria1 = [[DBCriteria alloc] initWithFieldName:kobjectName operatorType:SQLOperatorEqual andFieldValue:lookUpObject.objectName];
    
    DBCriteria * criteria2 = [[DBCriteria alloc] initWithFieldName:kfieldname operatorType:SQLOperatorIn andFieldValues:displayFields];
    
    id <SFObjectFieldDAO> sfObjectField = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectField];
    
    NSArray * resultSet =   [sfObjectField fetchSFObjectFieldsInfoByFields:nil andCriteriaArray:[NSArray arrayWithObjects:criteria1,criteria2, nil] advanceExpression:@"( 1 AND 2 )"];
    
    return resultSet;
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
                    NSArray *values = [SFMPageHelper getAllValuesFromMultiPicklistString:displayValue];
                    NSDictionary *maappingDict = [self getMultiPicklistMappingDict:picklistDict value:values];
                    if ([maappingDict count] > 0) {
                        NSString *picklistValue = [SFMPageHelper getMutliPicklistLabelForpicklistString:values andFieldLabelDictionary:maappingDict];
                        if (picklistValue != nil) {
                            field.displayValue = picklistValue;
                        }
                    }
                }
            }
        }
    }
}

- (NSDictionary *)getMultiPicklistMappingDict:(NSDictionary *)picklistDict
                                        value:(NSArray *)displayValues
{
    NSMutableDictionary *dataDict = [NSMutableDictionary new];
    
    for (NSString *value in displayValues) {
        SFPicklistModel *model = [picklistDict objectForKey:value];
        if (model != nil) {
            [dataDict setObject:model.label forKey:model.value];
        }
    }
    return dataDict;
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

#pragma mark - Advance Lookup Filter

-(NSArray *)getLookupSearchFiltersForId:(NSString *)searchId forType:(NSString *)searchType
{
    NSArray *resultset = nil;
    
    DBCriteria *criteriaType = [[DBCriteria alloc] initWithFieldName:@"ruleType"
                                                        operatorType:SQLOperatorEqual
                                                       andFieldValue:searchType];
    
    DBCriteria *criteriaId = [[DBCriteria alloc] initWithFieldName:@"namedSearchId"
                                                      operatorType:SQLOperatorEqual
                                                     andFieldValue:searchId];
    
    id searchFilterService = [FactoryDAO serviceByServiceType:ServiceTypeNamedSerachFilter];
    
    if ([searchFilterService conformsToProtocol:@protocol(SFNamedSearchFilterDAO)]) {
        
       resultset = [searchFilterService fetchSFNameSearchFiltersInfoByFields:nil andCriteria:[NSArray arrayWithObjects:criteriaId, criteriaType, nil]];
    }
    
    NSMutableArray *records = [NSMutableArray new];
    
    for (SFNamedSearchFilterModel *model in resultset) {
        SFMLookUpFilter *filter = [[SFMLookUpFilter alloc] init];
        if (model != nil){
            filter.nameSearchID = model.namedSearchId;
            filter.name = model.name;
            filter.sourceObjectName = model.sourceObjectName;
            filter.searchFieldName = model.fieldName;
            filter.advanceExpression = model.advancedExpression;
            filter.ruleType = model.ruleType;
            filter.allowOverride = model.allowOverride;
            filter.defaultOn = model.defaultOn;
            filter.searchId = model.Id;
            
            if ([searchType isEqualToString:kSearchFilterCriteria]) {
                BOOL objectPermission = [self isObjectHasPermission:filter.sourceObjectName];
                filter.objectPermission = objectPermission;
            }
            [records addObject:filter];
        }
    }
    return records;
}


- (BOOL)isObjectHasPermission:(NSString *)objectName
{    
    return [SFMPageEditHelper getObjectFieldCountForObject:objectName];
}

- (NSArray *)getCriteriaArrayForPreFilters:(NSArray *)filters
{
    NSMutableArray *criteriaArray = [NSMutableArray new];
    
    for (SFMLookUpFilter *model in filters) {
        if (model != nil) {
            
            if ([model.ruleType isEqualToString:kSearchFilterCriteria]) {
                if (!model.allowOverride || !model.objectPermission) {
                    continue;
                }
            }
            NSArray *dataArray = [self getCriteriaObjectForfilter:model];
            [criteriaArray addObjectsFromArray:dataArray];
        }
    }
    return criteriaArray;
}

- (NSArray *)getCriteriaArrayForAdvanceFilters:(NSArray *)filters
{
    NSMutableArray *criteriaArray = [NSMutableArray new];
    
    for (SFMLookUpFilter *model in filters) {
        if (model != nil) {
            if ([model.lookupContext length] == 0) {
                if ([model.ruleType isEqualToString:kSearchFilterCriteria]) {
                    if ((!model.defaultOn || !model.objectPermission)) {
                        continue;
                    }
                }
                NSArray *dataArray = [self getCriteriaObjectForAdvanceFilter:model];
                [criteriaArray addObjectsFromArray:dataArray];
            }
            
        }
    }
    return criteriaArray;
}

- (NSArray *)getCriteriaObjectForfilter:(SFMLookUpFilter *)filter {
    SFExpressionParser *expressionParser = [[SFExpressionParser alloc] initWithExpressionId:nil
                                                    objectName:filter.sourceObjectName];
    SFExpressionModel *model = [[SFExpressionModel alloc] init];
    model.expressionId = filter.searchId;
    model.expression = filter.advanceExpression;
    model.sourceObjectName = filter.sourceObjectName;

    [expressionParser setExpressionData:model];
    
    NSArray *criteriaObjects = [expressionParser expressionCriteriaObjectsForFilters];
    
    [self updateLiteralValueForCriterai:criteriaObjects];

    return criteriaObjects;
}

- (void)updateLiteralValueForCriterai:(NSArray *)criteriaObjects
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rhsValue CONTAINS[c] %@", @"SVMX.CURRENTRECORD"];
    NSArray *literalArray1 = [criteriaObjects filteredArrayUsingPredicate:predicate];
    
    predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@", @"SVMX.CURRENTRECORD"];
    NSMutableArray *literalArray2 = [NSMutableArray new];
    for (DBCriteria *criteria in criteriaObjects) {
        NSArray *filteredArray = [criteria.rhsValues filteredArrayUsingPredicate:predicate];
        if (filteredArray) {
            [literalArray2 addObject:criteria];
            
        }
    }
    
    for (DBCriteria *criteria in literalArray1) {
        SFMRecordFieldData *recordData = [self.viewControllerdelegate getValueForLiteral:criteria.rhsValue];
        criteria.rhsValue = (recordData.internalValue != nil)?recordData.internalValue:@"";
        
        
        if ([[criteria getSubCriterias] count]) {
            [self updateLiteralValueForSubCriterai:[criteria getSubCriterias] data:recordData];
        }
    }
    
    for (DBCriteria *criteria in literalArray2) {
        
        for(NSString *rhsString in criteria.rhsValues)
        {
            NSMutableArray *resultArray = [NSMutableArray new];
            
            NSArray *partsArray =   [rhsString componentsSeparatedByString:@","];
            
            
            for(NSString *rhsValue in partsArray)
            {
                SFMRecordFieldData *recordData;
                
                recordData = [self.viewControllerdelegate getValueForLiteral:rhsValue];
                [resultArray addObject:(recordData.internalValue != nil)?recordData.internalValue:@""];
                
                if ([[criteria getSubCriterias] count]) {
                    [self updateLiteralValueForSubCriterai:[criteria getSubCriterias] data:recordData];
                }
                
            }
            
            criteria.rhsValues = resultArray;
        }
        
        
        
    }
    
    
}

- (NSString *)getNameFieldForId:(NSString *)Id objectName:(NSString *)objectName
{
    id <TransactionObjectDAO> transactionModel = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    DBCriteria * criteria = [[DBCriteria alloc]initWithFieldName:kId operatorType:SQLOperatorEqual andFieldValue:Id];
    
    TransactionObjectModel *model = [transactionModel getDataForObject:objectName
                                                                fields:nil
                                                            expression:nil
                                                              criteria:@[criteria]];
    
    NSString *fieldName = [SFMPageHelper getNameFieldForObject:objectName];
    
    return [model valueForField:fieldName];
}

- (void)updateLiteralValueForSubCriterai:(NSArray *)criteriaObjects data:(SFMRecordFieldData *)recordData
{
    NSString *tableName = nil;
    
    for (DBCriteria *criteria in criteriaObjects) {
        
        if ([[criteria getInnerQueryRequest] isKindOfClass:[DBRequestSelect class]]) {
            DBRequestSelect *innerRequest = [criteria getInnerQueryRequest];
            
            if ([recordData.displayValue isEqualToString:recordData.internalValue] && tableName == nil) {
                
                tableName = innerRequest.tableName;
                NSString *nameValue = [self getNameFieldForId:recordData.internalValue objectName:tableName];
                recordData.displayValue = (nameValue != nil)?nameValue:@"";
            }
            NSArray *innerCriteria = [innerRequest criteriaArray];
            
            for (DBCriteria *criteria1 in innerCriteria) {
                criteria1.rhsValue = (recordData.displayValue != nil)?recordData.displayValue:@"";
            }
        }        
    }
}


- (NSArray *)getCriteriaObjectForAdvanceFilter:(SFMLookUpFilter *)filter
{
    NSArray *dataArray = [self getCriteriaObjectForfilter:filter];
    
    NSString *expression = (filter.advanceExpression != nil)?filter.advanceExpression:@"";
    
    DBRequestSelect *select = [[DBRequestSelect alloc] initWithTableName:filter.sourceObjectName
                                                           andFieldNames:[NSArray arrayWithObject:filter.searchFieldName]
                                                          whereCriterias:dataArray andAdvanceExpression:expression];
    
    DBCriteria *criteriaId = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorIn andInnerQUeryRequest:select];
    
    //DBCriteria *criteriaLocalId = [[DBCriteria alloc] initWithFieldName:kLocalId operatorType:SQLOperatorIn andInnerQUeryRequest:select];
    
   // return [NSArray arrayWithObjects:criteriaId, criteriaLocalId, nil];
    
    return [NSArray arrayWithObjects:criteriaId, nil];
}

- (void)updateExpressionCount:(SFMLookUp *)lookUpObj
{
//    NSInteger count = 1;
    
    NSInteger count = 0;
    if (isCircularRefEnabled) {
        count = 2; // 037576
        if (includeOfflineRecords) {
            count = 2;
        }
    }
    if (includeOfflineRecords) {
        count = 1;
    }
    
    if ([lookUpObj.searchFields count] >0 && ![StringUtil isStringEmpty:lookUpObj.searchString]) {
        NSUInteger c = [lookUpObj.searchFields count];
        count = c;// + 1; Defect#024967
    }
    self.expressionCount = count;
}

- (void)updateAdvanceExpressionForFiltes:(NSArray *)filters
                              expression:(NSMutableString *)advanceexpression
{
    for (int count = 0; count <[filters count]; count++) {

        SFMLookUpFilter *model = [filters objectAtIndex:count];
        
        if (model != nil) {
            if ([model.advanceExpression length] == 0) {
                model.advanceExpression = [self getExpresionForExpressionId:model.searchId];
            }
            NSString *expression = [self getAdvanceExpression:model.advanceExpression criteriaCount:self.expressionCount];
            if (![StringUtil isStringEmpty:expression]) {
//                [advanceexpression appendFormat:@" AND (%@)", expression];
                if (isCircularRefEnabled == NO && includeOfflineRecords == NO && advanceexpression.length == 0) {
                    [advanceexpression appendFormat:@"(%@)", expression];
                } else {
                    [advanceexpression appendFormat:@" AND (%@)", expression];
                }
            }
        }
    }
}

- (void)updateAdvanceExpressionForAdvanceFiltes:(NSArray *)filters
                              expression:(NSMutableString *)advanceexpression
{
    for (int count = 0; count <[filters count]; count++) {
        
        SFMLookUpFilter *model = [filters objectAtIndex:count];
        
        if (model != nil) {
            if ([model.lookupContext length] > 0) {
                continue;
            }
            if ((!model.defaultOn || !model.objectPermission)) {
                continue;
            }
            if ([model.advanceExpression length] == 0) {
                model.advanceExpression = [self getExpresionForExpressionId:model.searchId];
            }
            if ([model.advanceExpression length] > 0) {
//                NSString *expression = [NSString stringWithFormat:@" %d OR %d ", (int)self.expressionCount+1,
//                              (int)(self.expressionCount +2)];
                
                NSString *expression = [NSString stringWithFormat:@" %d ", (int)self.expressionCount+1];
                if (isCircularRefEnabled == NO && includeOfflineRecords == NO && advanceexpression.length == 0) {
                    [advanceexpression appendFormat:@" ( %@ )", expression];
                } else {
                    [advanceexpression appendFormat:@" AND  ( %@ )", expression];
                }
//                [advanceexpression appendFormat:@" AND  ( %@ )", expression];
                self.expressionCount += 1;
            }
        }
    }
}

- (NSString *)getAdvanceExpression:(NSString *)expression criteriaCount:(NSInteger)count
{
    NSMutableString *modifiedExpression = nil;
    
    if ([expression length] > 0) {
        modifiedExpression = [[NSMutableString alloc] init];
        
        NSArray *expressionArray = [self getExpressionArray:expression];
        
        for (int counter = 0; counter < [expressionArray count]; counter++) {
            
            NSString *str  = [expressionArray objectAtIndex:counter];
            if (![StringUtil isStringNumber:str]) {
                [modifiedExpression appendFormat:@"%@ ", str];
            }
            else {
            //Fix for IPAD-4383
              [modifiedExpression appendFormat:@"%d ",str.intValue];
                if (str.intValue > self.expressionCount) {
                    self.expressionCount=str.intValue;
                }
            }
        }

    }
    return modifiedExpression;
}

- (NSArray *)getExpressionArray:(NSString *)expression
{
    NSString *newExpression = [expression stringByReplacingOccurrencesOfString:@"(" withString:@"#(#"];
    newExpression = [newExpression stringByReplacingOccurrencesOfString:@")" withString:@"#)#"];
    
    newExpression = [newExpression stringByReplacingOccurrencesOfString:@"AND" withString:@"#and#" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [newExpression length])];
    newExpression = [newExpression stringByReplacingOccurrencesOfString:@"OR" withString:@"#OR#" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [newExpression length])];
    
   return [newExpression componentsSeparatedByString:@"#"];
}


- (NSString *)getExpresionForExpressionId:(NSString *)expressionId
{
    id <SFExpressionComponentDAO> expressionComponent = [FactoryDAO serviceByServiceType:ServiceTypeExpressionComponent];
    NSMutableString *advancedExpression = [[NSMutableString alloc] init];
    
    NSArray *array = [expressionComponent getExpressionComponentsBySFId:expressionId];
    
    for (SFExpressionComponentModel * model in array) {
        
        if (model.componentSequenceNumber > 0) {
            int number = (int)model.componentSequenceNumber;
            if ([advancedExpression length] > 0) {
                [advancedExpression appendFormat:@" AND %d", number];
            }
            else {
                [advancedExpression appendFormat:@"( %d", number];
            }
        }
    }
    if ([advancedExpression length] > 0)
    {
        [advancedExpression appendFormat:@")"];
    }
    
    return advancedExpression;
}
- (SFMRecordFieldData *) getFieldValueForFieldName:(NSString *)fieldName forHeaderField:(NSString *)headerValue {
    
    return [self.viewControllerdelegate getValueForContextFilterForfieldName:fieldName forHeaderObject:headerValue];
}
- (NSArray *) getCriteriaArrayForContextLookUp:(SFMLookUp *)lookup {

    NSString *filtervalue = @"";
    NSString *displayValue = @"";
    if (lookup.contextLookupFilter.lookupContext != nil && lookup.contextLookupFilter.lookupContext.length > 0 && lookup.contextLookupFilter.defaultOn) {
        
        SFMRecordFieldData *recordData = [self getFieldValueForFieldName:lookup.contextLookupFilter.lookupContext forHeaderField:lookup.contextLookupFilter.sourceObjectName];
        
        displayValue = (recordData.internalValue.length > 0) ? recordData.internalValue : @""; //IPAD-4734
        //Remvoe the white spaces from string.
        if (displayValue.length > 0) {
            displayValue = [displayValue stringByTrimmingCharactersInSet:
                            [NSCharacterSet whitespaceCharacterSet]];;
        }
        
        if (self.dataTypeUtil == nil) {
            self.dataTypeUtil = [[DataTypeUtility alloc] init];
        }

        SFMLookUpFilter *filter = [lookup.advanceFilters firstObject];
        if (filter !=nil && filter.lookupContext.length > 0 ) {
            
            //RHS
            SFObjectFieldModel *fieldModel = [self.dataTypeUtil getField:filter.lookupContext objectName:filter.lookupContextParentObject];
            
            //LHS
            SFObjectFieldModel *lhsFieldModel = [self.dataTypeUtil getField:filter.lookupQuery objectName:lookup.objectName];
            
            
            //check if its reference. then check for Id else just check with what is displayed
            if ([lhsFieldModel.type isEqualToString:kSfDTReference] || [fieldModel.type isEqualToString:kSfDTDate] ||   [fieldModel.type isEqualToString:kSfDTDateTime]  || ([lhsFieldModel.type caseInsensitiveCompare:kId] == NSOrderedSame)) {
                
                filtervalue = (recordData.internalValue.length > 0) ? recordData.internalValue : @"";
            }
            else {
                filtervalue = displayValue;
            }
            NSString *fieldLabel = (fieldModel.label.length > 0) ? fieldModel.label : @"";
            
           // NSString *value = [NSString stringWithFormat:@"%@ %@: %@",[[TagManager sharedInstance] tagByName:kTagLimitToForContextFilter],fieldLabel,displayValue];
            NSString *value = [NSString stringWithFormat:@"%@ %@: %@",[[TagManager sharedInstance] tagByName:kTagLimitToForContextFilter],fieldLabel,recordData.displayValue?recordData.displayValue:@""]; //IPAD-4792 //IPAD-4834
            
            filter.name = value;
        }
        
        DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:lookup.contextLookupFilter.lookupQuery operatorType:SQLOperatorEqual andFieldValue:filtervalue];
        criteria.isCaseInsensitive = YES;
        return @[criteria];
    }
    return @[];
    
}
- (void) updateAdvancedExpressionForContextFilter:(NSMutableString *)expression {
    
//    [expression appendFormat:@"AND ( %d )",(int)self.expressionCount+1];
    if (isCircularRefEnabled == NO && includeOfflineRecords == NO && expression.length == 0  ) {
        if (self.expressionCount > 0) {
            [expression appendFormat:@"( %d )",(int)self.expressionCount];
        } else {
            [expression appendFormat:@""];
        }
    } else {
        [expression appendFormat:@"AND ( %d )",(int)self.expressionCount+1];
    }
}
#pragma mark - END
@end
