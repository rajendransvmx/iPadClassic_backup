//
//  SFMSearchQueryCreator.m
//  ServiceMaxiPhone
//
//  Created by Shravya shridhar on 7/1/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "SFMSearchQueryCreator.h"
#import "Utility.h"
#import "SFMSearchFieldModel.h"
#import "OuterJoinObject.h"
#import "SFMPageHelper.h"
#import "MobileDeviceSettingDAO.h"
#import "Utility.h"
#import "FactoryDAO.h"
#import "TagManager.h"
#import "SFMSearchProcessModel.h"

@interface SFMSearchQueryCreator()

@property(nonatomic,strong)SFMSearchObjectModel       *searchObject;
@property(nonatomic,strong)NSDictionary          *joinTables;
@property(nonatomic,assign)NSInteger              maxNumberOfResults;

- (NSString *)getAliasNameForRelationship:(NSString *)relationShipName;
@end

@implementation SFMSearchQueryCreator

- (id)initWithSearchObject:(SFMSearchObjectModel *)newSearchObject
       withOuterJoinTables:(NSDictionary *)outerJoinTables {
    self = [super init];
    if (self != nil) {
        self.searchObject = newSearchObject;
        self.joinTables = outerJoinTables;
        //Setting serch limit for number of items.
        self.maxNumberOfResults = [self fetchSearchRange];
        //self.maxNumberOfResults = 100;
    }
    return self;
}

-(int )fetchSearchRange
{
    id <MobileDeviceSettingDAO> mobileSettingService = [FactoryDAO serviceByServiceType:ServiceTypeMobileDeviceSettings];
    MobileDeviceSettingsModel *lMobileDeviceSettingsModel = [mobileSettingService fetchDataForSettingId:kTag_SFMSearchLimit];
    if ([Utility isStringNotNULL:lMobileDeviceSettingsModel.value]) {
        int limitValue = [lMobileDeviceSettingsModel.value intValue];
        if (limitValue <=0) {
            return 100;
        }
        else
        {
            /* Here we are checking, If limit is more then 400...then we are showing 400 records only*/
            if (limitValue > 400)
                return 400;
            else
                return limitValue;
        }
    }
    return 100;
}
- (NSString *)generateQuery:(NSString *)expression andSearchText:(NSString *)searchString {
    
    NSMutableString *finalQuery = [[NSMutableString alloc] initWithString:@" SELECT "];
    @autoreleasepool {
        
        /* Adding  select part */
        NSString *selectPart = [self getSelectPart];
        [finalQuery appendString:selectPart];
        
        /* Adding  From part */
        [finalQuery appendFormat:@" FROM '%@' ",self.searchObject.targetObjectName];
        
        /* Adding left outer join part */
        if ([self.joinTables count] > 0) {
            NSString *outerJoinPart = [self getOuterJoinPart];
            [finalQuery appendFormat:@" %@ ",outerJoinPart];
        }
        
        /* Adding expression and search criteria part */
        NSString *whereClause =  [self getWhereClause:searchString fromExpression:expression];
        if (whereClause != nil) {
            [finalQuery appendString:whereClause];
        }
        
        if ([self.searchObject.sortFields count]> 0) {
            
            NSString *orderByString = [self getOrderByString];
            [finalQuery appendString:orderByString];
        }
        /* Adding limit string  */
        [finalQuery appendFormat:@" LIMIT %d ",(int)self.maxNumberOfResults];
    }
    
    return finalQuery;
}

- (NSString *)getSelectPart {
    
    NSMutableString *selectPart = [[NSMutableString alloc] initWithFormat:@" DISTINCT '%@'.localId, '%@'.Id ",self.searchObject.targetObjectName,self.searchObject.targetObjectName];
    for (SFMSearchFieldModel *displayField in self.searchObject.displayFields) {
        
        if (displayField.lookupFieldAPIName.length > 2) {
            NSString *aliasName  = [self getAliasNameForRelationship:displayField.lookupFieldAPIName];
            [selectPart appendFormat:@" ,%@.%@ ",aliasName,displayField.fieldName];
        }
        else{
            [selectPart appendFormat:@" ,'%@'.%@ ",self.searchObject.targetObjectName,displayField.fieldName];
        }
    }
    return selectPart;
}

- (NSString *)getAliasNameForRelationship:(NSString *)relationShipName {
    
    
    OuterJoinObject *joinObject =  [self.joinTables objectForKey:relationShipName];
    return joinObject.aliasName;
}

- (NSString *)getOuterJoinPart{
    
    NSMutableString *outerJoinString = [[NSMutableString alloc] init];
    NSString *sqliteString = @" LEFT OUTER JOIN ";
    
    NSArray *outerJoinObjects = [self.joinTables allValues];
    
    for (OuterJoinObject *joinObject in outerJoinObjects) {
        
        NSString *fieldMappingString = [self getFieldStringForFields:joinObject.leftFieldNames andObjectName:joinObject.aliasName];
        [outerJoinString appendFormat:@" %@ '%@' %@ on ( %@ ) " ,sqliteString, joinObject.objectName,joinObject.aliasName,fieldMappingString];
    }
    if (outerJoinString.length > 0) {
        return outerJoinString;
    }
    return nil;
}

- (NSString *)getFieldStringForFields:(NSArray *)fieldNames
                        andObjectName:(NSString *)joinObjectName {
    
    NSString *globalObjectName = self.searchObject.targetObjectName;
    NSMutableString *fieldNameString = [[NSMutableString alloc] init];
    
    int i = 0;
    for (NSString *fieldName in fieldNames) {
        if (i == 0) {
            [fieldNameString appendFormat:@" '%@'.'%@' = %@.'%@' ",globalObjectName,fieldName,joinObjectName,kId];
        }
        else{
            [fieldNameString appendFormat:@" OR '%@'.'%@' = %@.'%@' ",globalObjectName,fieldName,joinObjectName,kId];
        }
        i++;
    }
    return fieldNameString;
}

- (NSString *)getWhereClause:(NSString *)searchText fromExpression:(NSString *)expression {
    
    searchText = [searchText stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSMutableString *whereString = [[NSMutableString alloc] initWithString:@"WHERE"];
    BOOL doesSearchTextExist = NO;
    @autoreleasepool {
        if ([self.searchObject.searchFields count] > 0 && searchText.length > 0) {
            NSString *finalString = [self getSearchFieldStringOnText:searchText];
            [whereString appendFormat:@"  %@ ",finalString];
            doesSearchTextExist = YES;
        }
        /* Adding expression and search criteria part */
        if (expression.length > 0) {
            if (doesSearchTextExist) {
                [whereString appendString:@" AND "];
            }
            [whereString appendFormat:@"  ( %@ )",expression];
            doesSearchTextExist = YES;
        }
    }
    if (doesSearchTextExist) {
        return whereString;
    }
    return nil;
}


- (NSString *)getSearchFieldStringOnText:(NSString *)searchText {
    NSMutableString *searchString = [[NSMutableString alloc] initWithString:@" ( "];
    NSString *orOperator = @" OR ";
    NSInteger totalCount =  [self.searchObject.searchFields count];
    
    // 029883
    
    NSString *criteriaString = @"";
    
    switch (self.searchObject.searchCriteriaIndex) {
        case SearchCriteriaContains:
            criteriaString = [NSString stringWithFormat:@" LIKE '%%%@%%' ", searchText];
            break;
        case SearchCriteriaExactMatch:
            criteriaString = [NSString stringWithFormat:@" = '%@' COLLATE NOCASE ", searchText];
            break;
        case SearchCriteriaEndsWith:
            criteriaString = [NSString stringWithFormat:@" LIKE '%%%@' ", searchText];
            break;
        case SearchCriteriaStartsWith:
            criteriaString = [NSString stringWithFormat:@" LIKE '%@%%' ", searchText];
            break;
        default:
            break;
    }
    
    for (int counter = 0;counter < totalCount;counter++) {
        
        if (counter > 0) {
            [searchString appendString:orOperator];
        }
        SFMSearchFieldModel *searchField = [self.searchObject.searchFields objectAtIndex:counter];
        if (searchField.lookupFieldAPIName.length > 2) {
            NSString *aliasName =  [self getAliasNameForRelationship:searchField.lookupFieldAPIName];
            [searchString appendFormat:@" %@.%@ ",aliasName,searchField.fieldName];
            [searchString appendString:criteriaString];
        }
        else{
            if ([[searchField.displayType lowercaseString] isEqualToString:kSfDTReference]) {
                NSString *expression =  [self getReferenceExpression:searchField.fieldName withSearchText:searchText andReferenceTable:searchField.relatedObjectName];
                [searchString appendFormat:@" %@ ",expression];
            }
            else{
                [searchString appendFormat:@" '%@'.%@ ",self.searchObject.targetObjectName,searchField.fieldName];
                [searchString appendString:criteriaString];
            }
        }
    }
    [searchString appendString:@" ) "];
    return searchString;
}

- (NSString *)getNameFieldNameForObject:(NSString *)objectName
{
    return [SFMPageHelper getNameFieldForObject:objectName];
}

// 2-June BSP: For Defect 17514: Sorting on SFM Search
-(BOOL)doesTableExist:(NSString *)objectName
{
    return [SFMPageHelper checkIfTheTableExistsForObject:objectName];
    
}
- (NSString *)getReferenceExpression:(NSString *)fieldName
                      withSearchText:(NSString *)searchText
                   andReferenceTable:(NSString *)referenceToTable {
    
    // 029883
    
    NSString *criteriaString = @"";
    
    switch (self.searchObject.searchCriteriaIndex) {
        case SearchCriteriaContains:
            criteriaString = [NSString stringWithFormat:@" LIKE '%%%@%%' ", searchText];
            break;
        case SearchCriteriaExactMatch:
            criteriaString = [NSString stringWithFormat:@" = '%@' COLLATE NOCASE ", searchText];
            break;
        case SearchCriteriaEndsWith:
            criteriaString = [NSString stringWithFormat:@" LIKE '%%%@' ", searchText];
            break;
        case SearchCriteriaStartsWith:
            criteriaString = [NSString stringWithFormat:@" LIKE '%@%%' ", searchText];
            break;
        default:
            break;
    }
    
    NSString *finalExpression = nil;
    if ([fieldName isEqualToString:@"RecordTypeId"]) {
        finalExpression = [NSString stringWithFormat:@"( %@   in   (select  recordTypeId  from SFRecordType where recordType %@ ) )" ,fieldName, criteriaString];
    }
    else
    {
        NSString *fieldNameAppendedWithObjName = [NSString stringWithFormat:@" '%@'.%@ ",self.searchObject.targetObjectName,fieldName];
        NSString *nameFieldValue = [self  getNameFieldNameForObject:referenceToTable];
        if (![Utility isStringEmpty:referenceToTable])
        {
            finalExpression = [NSString stringWithFormat:@" ( %@   in   (select  Id  from '%@' where ( %@ %@ )) OR %@   in   (select  localId  from '%@' where (%@ %@ )))" , fieldNameAppendedWithObjName,referenceToTable ,nameFieldValue ,criteriaString,fieldNameAppendedWithObjName,referenceToTable ,nameFieldValue,criteriaString];
        }
    }
    return finalExpression;
}

- (NSString *)getOrderByString {
    NSMutableString *orderByString = [[NSMutableString alloc] initWithString:@" ORDER BY "];
    
    NSString *sortOrder = @"ASC";
    NSInteger totalCount =  [self.searchObject.sortFields   count];
    for (int counter = 0;counter < totalCount;counter++) {
        SFMSearchFieldModel *sortField = [self.searchObject.sortFields objectAtIndex:counter];
        
        if ([sortField.sortOrder isEqualToString:@"descending"]) {
            sortOrder = @"DESC";
        }
        
        if (sortField.lookupFieldAPIName.length > 2) {
            NSString *aliasName = [self getAliasNameForRelationship:sortField.lookupFieldAPIName];
            [orderByString appendFormat:@" %@.%@ COLLATE NOCASE %@ ",aliasName,sortField.fieldName,sortOrder];
        }
        else if(sortField.relatedObjectName && [self doesTableExist:sortField.relatedObjectName])
        {
            // 2-June BSP: For Defect 17514: Sorting on SFM Search
            NSString *aliasName = [self getAliasNameForRelationship:sortField.relatedObjectName];
            NSString *theFieldName = [self getNameFieldNameForObject:sortField.relatedObjectName];
            [orderByString appendFormat:@" '%@'.%@ COLLATE NOCASE %@ ",aliasName, theFieldName,sortOrder];
            
        }
        else
        {
            [orderByString appendFormat:@" '%@'.%@ COLLATE NOCASE %@ ",sortField.objectName,sortField.fieldName,sortOrder];
        }
        if (counter != (totalCount - 1)) {
            [orderByString appendString:@" , "];
        }
    }
    return orderByString;
}

- (NSString *)generateQueryForReference:(SFMSearchObjectModel *)searchObject searchString:(NSString *)searchString expression:(NSString *)expression dataArray:(NSArray *)dataArray {
    
    NSMutableString *finalQuery = [[NSMutableString alloc] initWithString:@" SELECT "];
    
    /* Adding  select part */
    NSString *selectPart = [self getSelectPart];
    [finalQuery appendString:selectPart];
    
    /* Adding  From part */
    [finalQuery appendFormat:@" FROM '%@' ",self.searchObject.targetObjectName];
    
    /* Adding left outer join part */
    if ([self.joinTables count] > 0) {
        NSString *outerJoinPart = [self getOuterJoinPart];
        [finalQuery appendFormat:@" %@ ",outerJoinPart];
    }
    
    /* Adding expression and search criteria part */
    NSString *whereClause =  [self getWhereClauseForReference:searchString fromExpression:expression dataArray:dataArray];
    if (whereClause != nil) {
        [finalQuery appendString:whereClause];
    }
    
    if ([self.searchObject.sortFields count]> 0) {
        
        NSString *orderByString = [self getOrderByString];
        [finalQuery appendString:orderByString];
    }
    
    /* Adding limit string  */
    [finalQuery appendFormat:@" LIMIT %ld ",(long)self.maxNumberOfResults];
    
    return finalQuery;
}

- (NSString *)getWhereClauseForReference:(NSString *)searchText fromExpression:(NSString *)expression dataArray:(NSArray *)dataArray {
    
    searchText = [searchText stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSMutableString *whereString = [[NSMutableString alloc] initWithString:@"WHERE"];
    BOOL doesSearchTextExist = NO;
    
    NSMutableString *finalString = [[NSMutableString alloc] init];

    if ([self.searchObject.searchFields count] > 0 && searchText.length > 0) {
        [finalString appendFormat:@"%@", [self getSearchFieldStringOnText:searchText]];
        doesSearchTextExist = YES;
    }

    if (dataArray.count > 0) {
        
        NSMutableArray *newDataArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < dataArray.count; i++) {
            
            NSString *dataString = [dataArray objectAtIndex:i];
            [newDataArray addObject:[NSString stringWithFormat:@"'%@'", dataString]];
        }
        
        if (finalString.length > 0) {
            NSString *orOperator = @" OR ";
            [finalString appendFormat:@"%@", orOperator];
        }
        
        [finalString appendFormat:@" %@ ", [self getSearchFieldTextForReference:searchText dataArray:newDataArray]];
        doesSearchTextExist = YES;
    }
    
    if (finalString.length > 0) {
        
        [whereString appendFormat:@" ( %@ ) ",finalString]; // IPAD-4605
    }

    /* Adding expression and search criteria part */
    if (expression.length > 0) {
        if (doesSearchTextExist) {
            [whereString appendString:@" AND "];
        }
        [whereString appendFormat:@"  ( %@ )",expression];
        doesSearchTextExist = YES;
    }
    
    if (doesSearchTextExist) {
        return whereString;
    }
    return nil;
    
}

- (NSString *)getSearchFieldTextForReference:(NSString *)searchText dataArray:(NSArray *)dataArray {
    
    NSMutableString *searchString = [[NSMutableString alloc] initWithString:@" ( "];
    NSString *orOperator = @" OR ";
    NSInteger totalCount =  [self.searchObject.searchFields count];
    
    NSString *criteriaString = @"";
    
    switch (self.searchObject.searchCriteriaIndex) {
        case SearchCriteriaContains:
            criteriaString = [NSString stringWithFormat:@" LIKE '%%%@%%' ", searchText];
            break;
        case SearchCriteriaExactMatch:
            criteriaString = [NSString stringWithFormat:@" = '%@' COLLATE NOCASE ", searchText];
            break;
        case SearchCriteriaEndsWith:
            criteriaString = [NSString stringWithFormat:@" LIKE '%%%@' ", searchText];
            break;
        case SearchCriteriaStartsWith:
            criteriaString = [NSString stringWithFormat:@" LIKE '%@%%' ", searchText];
            break;
        default:
            break;
    }

    for (int counter = 0;counter < totalCount;counter++) {
        
        if (counter > 0) {
            [searchString appendString:orOperator];
        }
        SFMSearchFieldModel *searchField = [self.searchObject.searchFields objectAtIndex:counter];
        
        if (searchField.lookupFieldAPIName.length > 2) {
            NSString *aliasName =  [self getAliasNameForRelationship:searchField.lookupFieldAPIName];
            [searchString appendFormat:@" %@.%@ ",aliasName,searchField.fieldName];
            [searchString appendString:criteriaString];
        }
        else{
            if ([[searchField.displayType lowercaseString] isEqualToString:kSfDTReference]) {
                
                [searchString appendFormat:@"'%@'.%@", searchField.objectName, searchField.fieldName];
                [searchString appendFormat:@" IN "];
                
                NSString *dataString = [dataArray componentsJoinedByString:@", "];
                [searchString appendFormat:@"( %@ )", dataString];
            }
            else{
                [searchString appendFormat:@" '%@'.%@ ",self.searchObject.targetObjectName,searchField.fieldName];
                [searchString appendString:criteriaString];
            }
        }
    }
    
    [searchString appendString:@" ) "];
    return searchString;
}

@end
