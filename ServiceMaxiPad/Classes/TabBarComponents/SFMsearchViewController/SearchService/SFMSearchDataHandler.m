//
//  SFMSearchDataHandler.m
//  ServiceMaxiPhone
//
//  Created by Shravya shridhar on 7/2/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "SFMSearchDataHandler.h"
#import "SFMSearchQueryCreator.h"
#import "OuterJoinObject.h"
#import "SFMSearchFieldModel.h"
#import "TransactionObjectDAO.h"
#import "SFExpressionParser.h"
#import "SFMRecordFieldData.h"
#import "Utility.h"
#import "RequestConstants.h"
#import "ResponseConstants.h"
#import "DatabaseConstant.h"
#import "FactoryDAO.h"
#import "SFObjectFieldDAO.h"
#import "SFMPageHelper.h"
#import "ObjectNameFieldValueDAO.h"
#import "FactoryDAO.h"
#import "DBRequestSelect.h"
#import "SFMSearchFilterCriteriaDAO.h"
#import "SFExpressionParser.h"
#import "SFExpressionComponentModel.h"
#import "SFMSearchFilterCriteriaModel.h"
#import "SFPicklistDAO.h"
#import "SFPicklistModel.h"
#import "SFRecordTypeDAO.h"
#import "SFRecordTypeModel.h"
#import "TransactionObjectDAO.h"
#import "TransactionObjectModel.h"
#import "StringUtil.h"

//#import "SFMPageDatabaseService.h" // SFM page view helper to fill up reference fields


@interface SFMSearchDataHandler ()

@property(nonatomic,strong) NSMutableDictionary *objectNameFieldDictionary;
@property(nonatomic,strong) SFMSearchObjectModel *searchObject;
@property(nonatomic,strong) NSString *searchString;
//@property(nonatomic,strong) SearchDBServices *dbService;
@property(nonatomic,strong) NSDictionary *outerJoinTables;
@property(nonatomic,strong) NSMutableDictionary * picklistDisplayValueDict;
@property(nonatomic,strong) NSMutableDictionary *recordTypeDisplayValueDict;
@property(nonatomic,strong) NSMutableDictionary *cacheOuterJoinTables;
@property(nonatomic,strong) NSMutableDictionary *expressionCache;

@property(nonatomic,assign) NSInteger joinCounter ;

- (NSString *)getAliasForObjectName:(NSString *)objectName;
@end

@implementation SFMSearchDataHandler

- (id)init {
    self = [super init];
    if (self != nil) {
        self.joinCounter = 1;
    }
    return self;
}

- (NSMutableArray *)searchResultsForSearchObject:(SFMSearchObjectModel *)newSearchObject
                                withSearchString:(NSString *)newSearchStr{
    self.searchObject = newSearchObject;
    self.searchString = newSearchStr;
    
    self.outerJoinTables = [self outerJoinTables];
    NSString *expression = [self searchExpression];
    [self fillUpDisplaysValues];
    
    NSString *newSearchQuery = [self getSearchObjectNameFieldValueQuery:newSearchObject searchString:newSearchStr expression:expression];
    
    if (newSearchQuery != nil) {
        
        NSMutableArray *dataArray = [self loadResults:newSearchQuery];
        
        dataArray = [self loadResults:newSearchQuery];
        
        [self replaceReferenceValuesIn:dataArray];
        [self loadDisplaysValues:dataArray];
        return dataArray;
    }

//    SFMSearchQueryCreator *queryCreator = [[SFMSearchQueryCreator alloc] initWithSearchObject:self.searchObject withOuterJoinTables:self.outerJoinTables];
//    NSString *searchQuery = [queryCreator generateQuery:expression andSearchText:newSearchStr];
//    //NSLog(@"OBJECT QUERY %@",searchQuery);
//    if (searchQuery != nil) {
//        NSMutableArray *dataArray = [self loadResults:searchQuery];
//        
//        if (dataArray.count == 0) {
//            
//            NSString *newSearchQuery = [self getSearchObjectNameFieldValueQuery:newSearchObject searchString:newSearchStr expression:expression];
//            
//            if (newSearchQuery != nil) {
//                
//                dataArray = [self loadResults:newSearchQuery];
//            }
//        }
//
//        [self replaceReferenceValuesIn:dataArray];
//        [self loadDisplaysValues:dataArray];
//        return dataArray;
//    }
    return nil;
}


- (NSMutableDictionary *)searchResultsForSearchObjects:(NSArray *)searchObjects
                                      withSearchString:(NSString *)newSearchStr{
    
    NSMutableDictionary *resulstDictionary  = [[NSMutableDictionary alloc] init];
    for (SFMSearchObjectModel *searchObject in searchObjects) {
        @autoreleasepool {
            NSMutableArray *resultArray = [self searchResultsForSearchObject:searchObject withSearchString:newSearchStr];
            if (resultArray != nil && searchObject.objectId.length > 2) {
                [resulstDictionary setObject:resultArray forKey:searchObject.objectId];
            }
        }
    }
    return resulstDictionary;
}

- (NSString *)getSearchObjectNameFieldValueQuery:(SFMSearchObjectModel *)searchObject searchString:(NSString *)searchString expression:(NSString *)expression {
    
    NSMutableString *queryForObjectNameFieldValue = [[NSMutableString alloc] init];
    NSString *searchQuery;
    
    [queryForObjectNameFieldValue appendFormat:@"Select DISTINCT Id from ObjectNameFieldValue "];
    [queryForObjectNameFieldValue appendFormat:@" WHERE "];
    
    NSMutableArray *whereClauseArray = [[NSMutableArray alloc] init];
    
    NSString *criteriaString = @"";
    
    switch (self.searchObject.searchCriteriaIndex) {
        case SearchCriteriaContains:
            criteriaString = [NSString stringWithFormat:@" LIKE '%%%@%%' ", searchString];
            break;
        case SearchCriteriaExactMatch:
            criteriaString = [NSString stringWithFormat:@" = '%@' COLLATE NOCASE ", searchString];
            break;
        case SearchCriteriaEndsWith:
            criteriaString = [NSString stringWithFormat:@" LIKE '%%%@' ", searchString];
            break;
        case SearchCriteriaStartsWith:
            criteriaString = [NSString stringWithFormat:@" LIKE '%@%%' ", searchString];
            break;
        default:
            break;
    }

    for (SFMSearchFieldModel *searchField in searchObject.searchFields) {
        
        if ([searchField.displayType isEqualToString:kSfDTReference]) {
            
            NSString *whereString = [NSString stringWithFormat:@" ( value %@ ) ", criteriaString];
            [whereClauseArray addObject:whereString];
        }
    }
    
    [queryForObjectNameFieldValue appendFormat:@" %@ ", [whereClauseArray componentsJoinedByString:@" OR "]];
    
    NSArray *dataArray = [self loadResults:queryForObjectNameFieldValue];
    
    NSMutableArray *dataIdsArray = [[NSMutableArray alloc] init];
    
    if (dataArray.count > 0 && ![StringUtil checkIfStringEmpty:searchString] ) {
        
        for (TransactionObjectModel *dataDict in dataArray)
        {
            NSDictionary *valueDict = [dataDict getFieldValueDictionary];
            
            for (SFMRecordFieldData *fieldData in [valueDict allValues]) {
                
                if((fieldData.internalValue != nil) && (![Utility isStringEmpty:fieldData.internalValue])) {
                    
                    [dataIdsArray addObject:fieldData.internalValue];
                }
            }
        }

        SFMSearchQueryCreator *queryCreator = [[SFMSearchQueryCreator alloc] initWithSearchObject:self.searchObject withOuterJoinTables:self.outerJoinTables];
        
        searchQuery = [queryCreator generateQueryForReference:searchObject searchString:searchString expression:expression dataArray:dataIdsArray];
        
        return searchQuery;
    }
    else {
        
        SFMSearchQueryCreator *queryCreator = [[SFMSearchQueryCreator alloc] initWithSearchObject:self.searchObject withOuterJoinTables:self.outerJoinTables];
        NSString *searchQuery = [queryCreator generateQuery:expression andSearchText:searchString];
        return searchQuery;
    }
    
    return nil;
}

#pragma mark - Loading Reference field value
/*
- (void)getReferenceFieldVaulesFor:(NSMutableDictionary *)referenceIdValues inObject:(NSString*)objectName
{
    @autoreleasepool
    {
        // referenceIDValues initially contains { Id : Id }
        
        NSArray *allIds = [referenceIdValues allKeys];
        NSString *idsString =  [Utility getConcatenatedStringFromArray:allIds withSingleQuotesAndBraces:YES];

        NSMutableDictionary *idsDictionary = [[NSMutableDictionary alloc] init];

        [self.dbService getNameFieldValuesIn:idsDictionary forIds:idsString];
        
        if (idsDictionary != nil)
        {
            NSMutableDictionary *exptnlIdValues = [[NSMutableDictionary alloc] init];
            
            NSArray *allKeys = [referenceIdValues allKeys];
            for (NSString *eachKey in allKeys)
            {
                NSString *value = [idsDictionary objectForKey:eachKey];
                if (![Utility isStringEmpty:value])
                {
                    [referenceIdValues setObject:value forKey:eachKey];
                }
                else
                {
                    [exptnlIdValues setObject:@"" forKey:eachKey];
                }
            }
            
            
            if((objectName != nil) && (exptnlIdValues.count))
            {
                [self.dbService fillDisplayValueForIds:exptnlIdValues andObjectName:objectName];
            }

            NSArray *allExcptnlKeys = [exptnlIdValues allKeys];
            for (NSString *eachKey in allExcptnlKeys)
            {
                NSString *str = [exptnlIdValues objectForKey:eachKey];
                if(![Utility isStringEmpty:str])
                    [referenceIdValues setObject:str forKey:eachKey];
                else
                    [referenceIdValues setObject:@"" forKey:eachKey];
                    
            }
        }
    }
}
*/

 - (void)getReferenceFieldVaulesFor:(NSMutableDictionary *)referenceIdValues inObject:(NSString*)objectName
{
    @autoreleasepool
    {
        // referenceIDValues initially contains { Id : Id }
        
        if((objectName != nil) && (referenceIdValues.count))
        {
            // [self.dbService fillDisplayValueForIds:referenceIdValues andObjectName:objectName];
            
            NSString *nameFieldValue = [self getNameFieldFOrObjectName:objectName];
            
            nameFieldValue = (nameFieldValue == nil)?@"":nameFieldValue;
            
            DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorIn andFieldValues:[referenceIdValues allKeys]];
            
            id <TransactionObjectDAO> nameFieldValueService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
            NSArray *resultSet = [nameFieldValueService fetchDataForObject:objectName
                                                                    fields:@[kId,nameFieldValue]
                                                                expression:nil
                                                                  criteria:@[criteria]];
            
            for (TransactionObjectModel *model in resultSet)
            {
                if (model != nil)
                {
                    NSString *sfId = [model valueForField:kId];
                    NSString *value = [model valueForField:nameFieldValue];
                    if ([sfId length] > 0 && [value length] > 0)
                    {
                        [referenceIdValues setValue:value forKey:sfId];
                    }
                }
            }

        }
        
        //If referenceIdValues key==value then value is not filled. Get the values from ObjectNameField
        if ([referenceIdValues count]>0) {
            NSMutableArray *exptnlIdValues = [[NSMutableArray alloc] init];
            NSArray *allIds = [referenceIdValues allKeys];
            NSArray *allValues = [referenceIdValues allValues];
            for(NSString *identifier in allIds)
            {
                if ([allValues containsObject:identifier]) {
                    [exptnlIdValues addObject:identifier];
                }
            }
            if ([exptnlIdValues count]>0) {
//                NSString *idsString =  [Utility getConcatenatedStringFromArray:exptnlIdValues withSingleQuotesAndBraces:YES];
//                [self.dbService getNameFieldValuesIn:referenceIdValues forIds:idsString];
                
                /* getNameFieldValuesIn: Replaced */
                DBCriteria * criteria = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorIn andFieldValues:exptnlIdValues];
                
                id <ObjectNameFieldValueDAO> nameFieldValueService = [FactoryDAO serviceByServiceType:ServiceTypeObjectNameFieldValue];
                
                NSArray *resultSet = [nameFieldValueService fetchObjectNameFieldValueByFields:nil andCriteria:criteria];
                
                for (ObjectNameFieldValueModel *model in resultSet) {
                    if (model != nil) {
                        NSString *sfId = model.Id;
                        NSString *value = model.value;
                        if ([sfId length] > 0 && [value length] > 0) {
                            [referenceIdValues setValue:value forKey:sfId];
                        }
                    }
                }
                /* END : getNameFieldValuesIn: Replaced */

            }
            
        }
    }
}


- (void)replaceReferenceValuesIn:(NSMutableArray*)dataArray
{
    for(SFMSearchFieldModel *srchField in self.searchObject.displayFields)
    {
        NSMutableDictionary *requiredNameFieldIds = [[NSMutableDictionary alloc] init];

        if(srchField.lookupFieldAPIName.length < 3 && [[srchField.displayType lowercaseString] isEqualToString:kSfDTReference])
        {
            for (TransactionObjectModel *dataDict in dataArray)
            {
                NSDictionary *valueDict = [dataDict getFieldValueDictionary];
                SFMRecordFieldData *recField = [valueDict objectForKey:srchField.fieldName];
                if((recField.internalValue != nil) && (![Utility isStringEmpty:recField.internalValue]))
                    [requiredNameFieldIds setObject:recField.internalValue forKey:recField.internalValue]; // { Id : Id }
            }
            
            [self getReferenceFieldVaulesFor:requiredNameFieldIds inObject:srchField.relatedObjectName];
            
            for (TransactionObjectModel *dataDict in dataArray)
            {
                NSDictionary *valueDict = [dataDict getFieldValueDictionary];
                SFMRecordFieldData *recField = [valueDict objectForKey:srchField.fieldName];
                if((recField.internalValue != nil) && (![Utility isStringEmpty:recField.internalValue]))
                {
                    NSString *dispVal = [requiredNameFieldIds objectForKey:recField.internalValue];
                    if(dispVal.length)
                        recField.displayValue = dispVal;
                }
            }
        }
    }
}

#pragma mark End


- (NSString *)getFieldNameFromRelationShipName:(NSString *)relationShip
                         withRelatedObjectName:(NSString *)relatedObjctName
                          andCurrentobjectName:(NSString *)objectName
{
    id service = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectField];
    return [service getFieldNameForRelationShipName:relationShip withRelatedObjectName:relatedObjctName andObjectName:objectName];
}

- (NSString *)getNameFieldFOrObjectName:(NSString *)objectName
{
    return [SFMPageHelper getNameFieldForObject:objectName];
}


#pragma mark - Loading related table joins

- (NSDictionary *)outerJoinTables {
    
    if (self.cacheOuterJoinTables == nil) {
        
        self.cacheOuterJoinTables = [[NSMutableDictionary alloc] init];
    }
    
    NSDictionary *opDictionary = [ self.cacheOuterJoinTables objectForKey:self.searchObject.objectId];
    if ([opDictionary count] > 0) {
        return opDictionary;
    }
    NSMutableDictionary *outerJoinTables = [[NSMutableDictionary alloc] init];
    
    NSArray *displayFields = self.searchObject.displayFields;
    NSArray *searchFields = self.searchObject.searchFields;
    
    NSArray *finalFieldsArray = [searchFields arrayByAddingObjectsFromArray:displayFields];
    finalFieldsArray = [finalFieldsArray arrayByAddingObjectsFromArray:self.searchObject.sortFields];
    
    for (SFMSearchFieldModel *aField in finalFieldsArray) {
        
        if ([self isFieldFromRelatedObjectTable:aField]) {
            
				// 2-June BSP: For Defect 17514: Sorting on SFM Search

            /*
             
             Actual. If nothing works, enable this.
             
             
            NSString *fieldObjectName = aField.objectName;
            NSString *dictionaryKey = aField.lookupFieldAPIName;
            OuterJoinObject *outerJoinObject =  [outerJoinTables objectForKey:dictionaryKey];
            if (outerJoinObject == nil) {
                outerJoinObject = [[OuterJoinObject alloc] initWithObjectName:fieldObjectName];
                [outerJoinTables setObject:outerJoinObject forKey:dictionaryKey];
                outerJoinObject.relationShipName = aField.lookupFieldAPIName;
                outerJoinObject.aliasName = [self getAliasForObjectName:fieldObjectName];
                
                */
            
            NSString *fieldObjectName = (aField.lookupFieldAPIName? aField.objectName:aField.relatedObjectName);
            NSString *dictionaryKey = (aField.lookupFieldAPIName? aField.lookupFieldAPIName:aField.relatedObjectName);
            OuterJoinObject *outerJoinObject =  [outerJoinTables objectForKey:dictionaryKey];
            if (outerJoinObject == nil) {
                outerJoinObject = [[OuterJoinObject alloc] initWithObjectName:fieldObjectName];
                [outerJoinTables setObject:outerJoinObject forKey:dictionaryKey];
                outerJoinObject.relationShipName = (aField.lookupFieldAPIName? aField.lookupFieldAPIName:aField.relatedObjectName);
                outerJoinObject.aliasName = [self getAliasForObjectName:fieldObjectName];
            }
            
            /* This is the field from related table */
            NSString *searchObjectFieldName = [self getFieldNameFromRelationShipName:(aField.lookupFieldAPIName? aField.lookupFieldAPIName:aField.fieldRelationshipName) withRelatedObjectName:fieldObjectName andCurrentobjectName:self.searchObject.targetObjectName];
            if (searchObjectFieldName.length > 0) {
                [outerJoinObject addFieldName:searchObjectFieldName];
            }
        }
    }
    if ([outerJoinTables count] > 0) {
        [self.cacheOuterJoinTables setObject:outerJoinTables forKey:self.searchObject.objectId];
        return outerJoinTables;
    }
    return nil;
}
- (NSString *) getWhereClauseForExpression {
    
    id daoServiceTemp = [FactoryDAO serviceByServiceType:ServiceTypeSFMSearchFilterCriteria];
    NSArray *array;
    
    if ([daoServiceTemp conformsToProtocol:@protocol(SFMSearchFilterCriteriaDAO)]) {
        array = [daoServiceTemp fetchExpressionComponentForExpressionId:self.searchObject.objectId];
    }
    
    SFExpressionParser *parser = [[SFExpressionParser alloc] initWithExpressionId:self.searchObject.objectId objectName:self.searchObject.targetObjectName];
    
    NSMutableArray *expCompArray = [[NSMutableArray alloc] init];
    
    for (SFMSearchFilterCriteriaModel *expComp in array) {
        
        SFExpressionComponentModel *componentModel = [[SFExpressionComponentModel alloc] init];
        componentModel.operatorValue = expComp.operatorValue;
        componentModel.componentLHS = expComp.fieldName;
        componentModel.componentRHS = expComp.operand;
        componentModel.fieldType = expComp.displayType;
        [expCompArray addObject:componentModel];
    }
    
    
    NSArray *criteriaArray = [parser expressionCriteriaObjectsForComponents:expCompArray];
    
    NSString *advancedExpression = nil;
    if(![self.searchObject.advancedExpression isEqualToString:@""]) {
        advancedExpression = self.searchObject.advancedExpression;
    }
    //SXLogInfo(@"Advanced expression : %@",advancedExpression);
    
    DBRequestSelect *requestSelect = [[DBRequestSelect alloc] initWithTableName:self.searchObject.targetObjectName
                                                                  andFieldNames:@[kId]
                                                                 whereCriterias:criteriaArray
                                                           andAdvanceExpression:advancedExpression];
    
    return [requestSelect whereClause];
}
- (NSString *)searchExpression {
    
    if (self.expressionCache == nil) {
        self.expressionCache = [[NSMutableDictionary alloc] init];
    }
    
    NSString *expressionNew = [self.expressionCache objectForKey:self.searchObject.objectId];
    if (expressionNew != nil) {
        return expressionNew;
    }
    
    NSString * finalString = [self getWhereClauseForExpression];
    if (finalString != nil) {
        [self.expressionCache setObject:finalString forKey:self.searchObject.objectId];
    }
    return finalString;
}

- (BOOL)isFieldFromRelatedObjectTable:(SFMSearchFieldModel *)searchField {
     if (searchField.lookupFieldAPIName.length > 3) {
         return YES;
     }
    else if (searchField.objectName.length > 3 && [searchField.fieldType isEqualToString:@"OrderBy"] && searchField.relatedObjectName.length)
    {
				// 2-June BSP: For Defect 17514: Sorting on SFM Search

        return YES;
    }
    return NO;
}
#pragma mark End

#pragma mark - Loading search results

- (NSMutableArray *)loadResults:(NSString *)searchQuery {
   // return [self.dbService getDataForQuery:searchQuery andObject:self.searchObject];
//    NSLog(@"Query : %@",searchQuery);
    NSMutableArray *resultSet = nil;
    id <TransactionObjectDAO> daoService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    if ([daoService conformsToProtocol:@protocol(TransactionObjectDAO)]) {
        resultSet = [daoService getDataForSearchQuery:searchQuery forSearchFields:self.searchObject.displayFields];
    }
    return resultSet;
}

#pragma mark End


-(void)fillUpDisplaysValues
{
    
    NSMutableDictionary *picklistDict = nil;
    NSMutableDictionary *recordTypeDict = nil;
    
    for (SFMSearchFieldModel *displayField in self.searchObject.displayFields)
    {
        NSString * objectname = nil;
        if (displayField.lookupFieldAPIName.length > 2) {
            objectname =  displayField.relatedObjectName;
        }
        else{
            objectname =  self.searchObject.targetObjectName;
        }
        if([[displayField.displayType lowercaseString] isEqualToString:kSfDTPicklist] || [[displayField.displayType lowercaseString] isEqualToString:kSfDTMultiPicklist])
        {
            NSString * fieldName = displayField.fieldName;
            if(![Utility isStringEmpty:fieldName] && ![Utility isStringEmpty:objectname]){
                BOOL entryExits = [self doesPicklistExntryExitsForObjectName:objectname fieldName:fieldName];
                if(entryExits){
                    continue;
                }
                
                if(picklistDict == nil){
                    picklistDict = [[NSMutableDictionary alloc] init];
                }
                NSMutableArray * fieldsArray = [picklistDict objectForKey:objectname];
                if(fieldsArray == nil){
                    fieldsArray = [[NSMutableArray alloc] init];
                    [picklistDict setObject:fieldsArray forKey:objectname];
                }
                [fieldsArray addObject:fieldName];
            }
        }
        else if ([displayField.fieldName isEqualToString:kSfDTRecordTypeId] && [[displayField.displayType lowercaseString] isEqualToString:kSfDTReference])
        {
            if(![Utility isStringEmpty:objectname])
            {
                BOOL entryExits = [self doesRecordTypeExistsForObjectName:objectname];
                if(entryExits){
                    continue;
                }
                if(recordTypeDict == nil){
                    recordTypeDict = [[NSMutableDictionary alloc] init];
                }
                [recordTypeDict setObject:@"" forKey:objectname];
            }
        }
    }
    
    if(picklistDict != nil){
        if(self.picklistDisplayValueDict == nil){
            self.picklistDisplayValueDict = [[NSMutableDictionary alloc] init];
        }
        [self fillUpPicklistValues:picklistDict pickListDict:self.picklistDisplayValueDict];
    }
    
    if(recordTypeDict != nil){
        if(self.recordTypeDisplayValueDict == nil){
            self.recordTypeDisplayValueDict = [[NSMutableDictionary alloc] init];
        }
        [self fillUpRecordTypeForObjects:recordTypeDict recordTypeDict: self.recordTypeDisplayValueDict];
    }
    
}

#pragma mark - PIcklists METHODS
-(void)fillUpPicklistValues:(NSMutableDictionary *)objectInfoDict  pickListDict:(NSMutableDictionary *)pickListDict
{
    for (NSString * objectName in objectInfoDict) {
        NSArray * fieldsInfoArray = objectInfoDict[objectName];
        NSMutableDictionary * fieldInfoDict = [pickListDict objectForKey:objectName];
        if(fieldInfoDict == nil){
            fieldInfoDict = [[NSMutableDictionary alloc] init];
            [pickListDict setObject:fieldInfoDict forKey:objectName];
        }
        
        [self fillPicklistValuesForFields:fieldsInfoArray objectName:objectName picklistDict:fieldInfoDict];
    }
    
}
-(void)fillUpRecordTypeForObjects:(NSMutableDictionary *)objectInfoDict  recordTypeDict:(NSMutableDictionary *)recordTypeDict
{
    for (NSString * objectName in objectInfoDict) {
        
        NSMutableDictionary * eachDict = [recordTypeDict objectForKey:objectName];
        if(eachDict == nil){
            eachDict = [[NSMutableDictionary alloc] init];
            [recordTypeDict setObject:eachDict forKey:objectName];
        }
        
        [self FillRecordTypeNameForObject:objectName withRecordTypeDict:eachDict];
    }
}

-(void)fillPicklistValuesForFields:(NSArray *)fieldsArray  objectName:(NSString *)objectName  picklistDict:(NSMutableDictionary *)picklistsDict
{
    @synchronized([self class]){
        @autoreleasepool {
            NSArray * resultSet = nil;
            
            id <SFPicklistDAO> picklistDaoService = [FactoryDAO serviceByServiceType:ServiceTypeSFPickList];
            
            if ([picklistDaoService conformsToProtocol:@protocol(SFPicklistDAO)]) {
                
                NSArray * fieldNames = [[NSArray alloc] initWithObjects:kfieldname, klabel, kvalue, nil];
                
                DBCriteria * criteriaType = [[DBCriteria alloc] initWithFieldName:kfieldname operatorType:SQLOperatorIn andFieldValues:fieldsArray];
                
                DBCriteria * criteriaObjectName = [[DBCriteria alloc] initWithFieldName:kobjectName operatorType:SQLOperatorEqual andFieldValue:objectName];
                
                NSArray * criteriaObjects = [[NSArray alloc] initWithObjects:criteriaObjectName, criteriaType, nil];
                
                resultSet = [picklistDaoService fetchSFPicklistInfoByFields:fieldNames andCriteria:criteriaObjects andExpression:@"(1 AND 2)"];
            }
            if (picklistsDict == nil)
            {
                picklistsDict = [[NSMutableDictionary alloc] initWithCapacity:0];
            }
            for (SFPicklistModel *picklist in resultSet) {
                
                NSMutableDictionary * eachdict = [picklistsDict objectForKey:picklist.fieldName];
                if (eachdict == nil)
                {
                    eachdict  = [[NSMutableDictionary alloc] init];
                    [picklistsDict setObject:eachdict forKey:picklist.fieldName];
                }
                [eachdict setObject:picklist.label forKey:picklist.value];
                
            }            
        }
    }
}


-(void)FillRecordTypeNameForObject:(NSString *)objectName withRecordTypeDict:(NSMutableDictionary *)recordTypeDict
{
    id <SFRecordTypeDAO> recordTypeDaoService = [FactoryDAO serviceByServiceType:ServiceTypeSFRecordType];
    NSArray * resultSet = nil;
    if ([recordTypeDaoService conformsToProtocol:@protocol(SFRecordTypeDAO)]) {
        
        DBCriteria * criteriaObjectName = [[DBCriteria alloc] initWithFieldName:kobjectApiName operatorType:SQLOperatorEqual andFieldValue:objectName];
        
        NSArray * fieldNames = [[NSArray alloc] initWithObjects:kRecordType, kRecordTypeId, kRecordtypeLabel, nil];
        
        resultSet = [recordTypeDaoService fetchSFRecordTypeByFields:fieldNames andCriteria:criteriaObjectName];
        
    }
    for (SFRecordTypeModel *recordTypeModel in resultSet) {
        if(recordTypeDict == nil)
        {
            
            recordTypeDict = [[NSMutableDictionary alloc] init];
        }
        
        [recordTypeDict setObject:recordTypeModel.recordtypeLabel forKey:recordTypeModel.recordTypeId];
    }
    
}

-(BOOL)doesPicklistExntryExitsForObjectName:(NSString *)objectname  fieldName:(NSString *)fieldName{
    
    NSMutableDictionary * fieldDict = [self.picklistDisplayValueDict objectForKey:objectname];
    NSDictionary * labelvalueDict = [fieldDict objectForKey:fieldName];

    if(labelvalueDict == nil)
    {
        return NO;
    }
    return YES;
}
-(BOOL)doesRecordTypeExistsForObjectName:(NSString *)objectName {
    
    NSMutableDictionary * fieldDict = [self.recordTypeDisplayValueDict objectForKey:objectName];
    if(fieldDict == nil)
    {
        return NO;
    }
    return YES;
}

-(void)loadDisplaysValues:(NSMutableArray *)dataArray{
  
    for (TransactionObjectModel *transactionModel in dataArray) {
        
        NSMutableDictionary *valueFieldDictionary = [transactionModel getFieldValueMutableDictionary];
        for (SFMSearchFieldModel *displayField in self.searchObject.displayFields)
        {
            NSString * objectname = nil;
            
            NSString *recordKey = [displayField getDisplayField];

            objectname =  displayField.objectName;
            
            if([[displayField.displayType lowercaseString] isEqualToString:kSfDTPicklist] || [[displayField.displayType lowercaseString] isEqualToString:kSfDTMultiPicklist])
            {
                NSMutableDictionary * fieldDict = [self.picklistDisplayValueDict objectForKey:objectname];
                NSDictionary * labelvalueDict = [fieldDict objectForKey:displayField.fieldName];
                
                
                SFMRecordFieldData * record = [valueFieldDictionary objectForKey:recordKey];
                
                if([[displayField.displayType lowercaseString] isEqualToString:kSfDTMultiPicklist])
                {
                    record.displayValue = [self getDiplayValueForMultipicklist:labelvalueDict forValue:record.internalValue];
                }
                else
                {
                    record.displayValue = [labelvalueDict objectForKey:record.internalValue];
                }
            }
            else if ([displayField.fieldName isEqualToString:kSfDTRecordTypeId] && [[displayField.displayType lowercaseString] isEqualToString:kSfDTReference])
            {
                NSMutableDictionary * fieldDict = [self.recordTypeDisplayValueDict objectForKey:objectname];
                
                SFMRecordFieldData * record = [valueFieldDictionary objectForKey:recordKey];
                record.displayValue = [fieldDict objectForKey:record.internalValue];
            }
        }

    }
    

}

-(NSString *)getDiplayValueForMultipicklist:(NSDictionary *)picklistDict forValue:(NSString *)fieldValue
{
    @synchronized([self class]){
        @autoreleasepool {
            if ([Utility isStringEmpty:fieldValue]) {
                return nil;
            }
            NSMutableString * displayValue = [[NSMutableString alloc] init];
            NSArray * valuearray = [fieldValue componentsSeparatedByString:@";"];
            int count_ = 0;
            for ( NSString * eachStr in valuearray)
            {
                NSString * label = [picklistDict objectForKey:eachStr];
                if(label != nil)
                {
                    if( count_ != 0 )
                    {
                        [displayValue appendString:@";"];
                    }
                    
                    [displayValue appendString:label];
                    count_++;
                }
                
            }
            return displayValue;
        }
        
    }
}

- (NSMutableDictionary*)getSfidVsLocalIdDictionaryForSFids:(NSArray*)listOfSfid andObjectName:(NSString*)objectName
{
    NSMutableDictionary *sfIdVsLocalIdDictionary = [[NSMutableDictionary alloc]init];
    DBCriteria *criteria = [[DBCriteria alloc]initWithFieldName:kId operatorType:SQLOperatorIn andFieldValues:listOfSfid];
    id <TransactionObjectDAO> transactionObject = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    NSArray * sourceRecords = [transactionObject fetchDataForObject:objectName fields:@[kId,kLocalId] expression:@" 1 " criteria:@[criteria]];
    
    for ( TransactionObjectModel * objectModel in sourceRecords) {
        NSMutableDictionary * sourceDict = [objectModel getFieldValueMutableDictionary];
        NSString *sfId = ([sourceDict objectForKey:kId] == nil)?@"":[sourceDict objectForKey:kId];
        NSString *localId = ([sourceDict objectForKey:kLocalId] == nil)?@"":[sourceDict objectForKey:kLocalId];
        [sfIdVsLocalIdDictionary setValue:localId forKeyPath:sfId];
    }
    return sfIdVsLocalIdDictionary;
}

- (NSString *)getAliasForObjectName:(NSString *)objectName {
    
    
    return [[NSString alloc] initWithFormat:@"%@ios%ld",objectName,(long)_joinCounter++];
}
@end
