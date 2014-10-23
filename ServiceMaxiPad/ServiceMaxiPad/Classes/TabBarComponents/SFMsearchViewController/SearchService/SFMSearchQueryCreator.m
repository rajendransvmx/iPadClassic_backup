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

@interface SFMSearchQueryCreator()

@property(nonatomic,strong)SFMSearchObjectModel       *searchObject;
@property(nonatomic,strong)NSDictionary          *joinTables;
@property(nonatomic,assign)NSInteger              maxNumberOfResults;
@end

@implementation SFMSearchQueryCreator

- (id)initWithSearchObject:(SFMSearchObjectModel *)newSearchObject
       withOuterJoinTables:(NSDictionary *)outerJoinTables {
    self = [super init];
    if (self != nil) {
        self.searchObject = newSearchObject;
        self.joinTables = outerJoinTables;
        self.maxNumberOfResults = 100;
    }
    return self;
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
             [selectPart appendFormat:@" ,'%@'.%@ ",displayField.objectName,displayField.fieldName];
        }
        else{
            [selectPart appendFormat:@" ,'%@'.%@ ",self.searchObject.targetObjectName,displayField.fieldName];
        }
    }
    return selectPart;
}

- (NSString *)getOuterJoinPart{
    
    NSMutableString *outerJoinString = [[NSMutableString alloc] init];
    NSString *sqliteString = @" LEFT OUTER JOIN ";
    
    NSArray *outerJoinObjects = [self.joinTables allValues];
    
    for (OuterJoinObject *joinObject in outerJoinObjects) {
        
        NSString *fieldMappingString = [self getFieldStringForFields:joinObject.leftFieldNames andObjectName:joinObject.objectName];
        [outerJoinString appendFormat:@" %@ '%@' on ( %@ ) " ,sqliteString, joinObject.objectName,fieldMappingString];
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
    
    for (NSString *fieldName in fieldNames) {
        [fieldNameString appendFormat:@" '%@'.'%@' = '%@'.'%@' ",globalObjectName,fieldName,joinObjectName,kId];
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
    for (int counter = 0;counter < totalCount;counter++) {
        
        if (counter > 0) {
            [searchString appendString:orOperator];
        }
        SFMSearchFieldModel *searchField = [self.searchObject.searchFields objectAtIndex:counter];
        if (searchField.lookupFieldAPIName.length > 2) {
            [searchString appendFormat:@" '%@'.%@ ",searchField.objectName,searchField.fieldName];
             [searchString appendFormat:@" LIKE '%%%@%%' ",searchText];
        }
        else{
            if ([searchField.fieldType isEqualToString:kSfDTReference]) {
               NSString *expression =  [self getReferenceExpression:searchField.fieldName withSearchText:searchText andReferenceTable:searchField.relatedObjectName];
                  [searchString appendFormat:@" %@ ",expression];
            }
            else{
                [searchString appendFormat:@" '%@'.%@ ",self.searchObject.targetObjectName,searchField.fieldName];
                 [searchString appendFormat:@" LIKE '%%%@%%' ",searchText];
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

- (NSString *)getReferenceExpression:(NSString *)fieldName
                      withSearchText:(NSString *)searchText
                   andReferenceTable:(NSString *)referenceToTable {
   
    NSString *finalExpression = nil;
    if ([fieldName isEqualToString:@"RecordTypeId"]) {
        finalExpression = [NSString stringWithFormat:@"( %@   in   (select  record_type_id  from SFRecordType where record_type LIKE '%%%@%%' ) )" ,fieldName,searchText];
    }
    else
    {
        NSString *fieldNameAppendedWithObjName = [NSString stringWithFormat:@" '%@'.%@ ",self.searchObject.targetObjectName,fieldName];
        NSString *nameFieldValue = [self  getNameFieldNameForObject:referenceToTable];
        if (![Utility isStringEmpty:referenceToTable])
        {
            finalExpression = [NSString stringWithFormat:@" ( %@   in   (select  Id  from '%@' where ( %@ LIKE '%%%@%%')) OR %@   in   (select  local_id  from '%@' where (%@ LIKE '%%%@%%')))" , fieldNameAppendedWithObjName,referenceToTable ,nameFieldValue ,searchText,fieldNameAppendedWithObjName,referenceToTable ,nameFieldValue,searchText];
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
        
        [orderByString appendFormat:@" '%@'.%@ COLLATE NOCASE %@ ",sortField.objectName,sortField.fieldName,sortOrder];
        if (counter != (totalCount - 1)) {
            [orderByString appendString:@" , "];
        }
    }
    return orderByString;
}

@end
