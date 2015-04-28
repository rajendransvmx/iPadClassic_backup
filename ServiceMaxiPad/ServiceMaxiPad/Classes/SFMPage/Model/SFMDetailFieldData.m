//
//  SFMDetailFieldData.m
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 25/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFMDetailFieldData.h"
#import "SFMPageField.h"
#import "DBCriteria.h"
#import "SFMPageHelper.h"
#import "DBField.h"
#import "StringUtil.h"

@implementation SFMDetailFieldData

- (NSMutableArray *)getAllFieldNames
{
    if (self.isSourceToTargetProcess) {
        return [NSMutableArray arrayWithArray:self.fieldsArray];
    }
    
    NSMutableArray *fieldNames = [[NSMutableArray alloc] initWithCapacity:0];
    
    for(SFMPageField *pageField in self.fieldsArray) {
        if (pageField != nil) {
            NSString *apiName = pageField.fieldName;
            if ([apiName length] > 0) {
                [fieldNames addObject:apiName];
            }
        }
    }
    return fieldNames;
}

- (void)updateEntryCriteriaObjects
{
    NSMutableArray * criteriaObjects = [[NSMutableArray alloc] initWithCapacity:0];
    
    if (self.isSourceToTargetProcess) {
        
        if ([self.parentLocalId length] > 0) {
            DBCriteria * criteria = [[DBCriteria alloc] initWithFieldName:kLocalId
                                                             operatorType:SQLOperatorEqual
                                                            andFieldValue:self.parentLocalId];
            [criteriaObjects addObject:criteria];
        }
    }
    else {
        
        if ([self.parentColumnName length] > 0 && [self.parentSfID length] > 0) {
            //NSString *fieldName = [NSString stringWithFormat:@"'%@'.%@", self.objectName, self.parentColumnName];
             NSString *fieldName = [NSString stringWithFormat:@"%@", self.parentColumnName];
            DBCriteria * criteria = [[DBCriteria alloc] initWithFieldName:fieldName operatorType:SQLOperatorEqual andFieldValue:self.parentSfID];
            [criteriaObjects addObject:criteria];
        }
        if ([self.parentColumnName length] > 0 && [self.parentLocalId length] > 0) {
            //NSString *fieldName = [NSString stringWithFormat:@"'%@'.%@", self.objectName, self.parentColumnName];
             NSString *fieldName = [NSString stringWithFormat:@"%@", self.parentColumnName];
            DBCriteria * criteria = [[DBCriteria alloc] initWithFieldName:fieldName operatorType:SQLOperatorEqual andFieldValue:self.parentLocalId];
            [criteriaObjects addObject:criteria];
        }
    }
    
    if ([self.criteriaObjects count] > 0 && [StringUtil isStringEmpty:self.expression]) {
        [self addDefaultAdvanceExpression];
    }
    
    if ([criteriaObjects count] > 0) {
        [self updateAdvanceExpression:criteriaObjects];
    }
}

- (void) addDefaultAdvanceExpression
{
    NSMutableString * defaultExpression = [NSMutableString new];
    
    for (int i = 0; i < [self.criteriaObjects count]; i++) {
        
        DBCriteria *criteria = [self.criteriaObjects objectAtIndex:i];
        
        if (criteria != nil) {
            if ([defaultExpression length] > 0)
            {
                [defaultExpression appendFormat:@" AND %d", i+1];
            }
            else
            {
                [defaultExpression appendFormat:@"%d", i+1];
            }
        }
    }
    if ([defaultExpression length] > 0)
    {
        self.expression = defaultExpression;
    }
}

- (void)updateAdvanceExpression:(NSArray *)criteriaObjects
{
    NSString * newExpression = nil;
    if (![StringUtil isStringEmpty:self.expression]) {
        if ([criteriaObjects count] == 2) {
            if ([self.criteriaObjects count] > 0) {
                newExpression = [[NSString alloc] initWithFormat:@"(%@) AND (%d OR %d)",self.expression,(int)([self.criteriaObjects count]+1), (int)([self.criteriaObjects count]+2)];
            }
            else {
                newExpression = @"(1 OR 2)";;
            }
        }
        else if ([criteriaObjects count] == 1) {
            if ([self.criteriaObjects count] > 0) {
                 newExpression = [[NSString alloc] initWithFormat:@"(%@) AND %d",self.expression,(int)([self.criteriaObjects count]+1)];
            }
        }
    }
    else {
        if ([criteriaObjects count] == 2)
            newExpression = @"(1 OR 2)";
    }
    self.expression = newExpression;

    if (self.criteriaObjects == nil) {
        self.criteriaObjects = [[NSMutableArray alloc] initWithCapacity:0];
    }
    [self.criteriaObjects addObjectsFromArray:criteriaObjects];
}

- (BOOL)shouldApplySortingOrder
{
    BOOL returnValue = NO;
    
    if ([self.sortingData length] > 0) {
        returnValue = YES;
    }
    return returnValue;
}

- (NSDictionary *)getSortingDetails
{
    NSMutableDictionary *datadict = nil;
    
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[self.sortingData dataUsingEncoding:NSUTF8StringEncoding]
                                    options:kNilOptions
                                      error:&error];
    if (jsonDict != nil) {
        NSMutableArray *orberByData = nil;
        
        NSArray *array = [jsonDict objectForKey:@"lstSortingRec"];
     
        for (NSMutableDictionary *sortingDataDict in array) {
            
            NSString *dataType = [sortingDataDict objectForKey:kDataType];
            if (datadict == nil) {
                datadict =[NSMutableDictionary dictionaryWithCapacity:0];
            }
            if (orberByData == nil) {
                orberByData = [NSMutableArray arrayWithCapacity:0];
            }
            
            if ([dataType caseInsensitiveCompare:kSfDTReference] == NSOrderedSame) {
                NSString *fieldName = [sortingDataDict objectForKey:kFieldAPIName];
                
                NSString *queryField = [[[sortingDataDict objectForKey:@"queryField"]
                                         componentsSeparatedByString:@"."] objectAtIndex:1];
                if ([fieldName length] > 0) {
                    NSString *relatedObjectName = [SFMPageHelper getReferenceNameForObject:self.objectName fieldName:fieldName];
                    if ([relatedObjectName length] > 0 && [queryField length] > 0) {
                        
                        if ([SFMPageHelper isTableEmptyForObject:relatedObjectName]) {
                            [datadict setObject:relatedObjectName forKey:fieldName];
                            
                            NSString *sortingOrder = [sortingDataDict objectForKey:@"sortingOrder"];
                            
                            DBField *orderByfield = [[DBField alloc] initWithFieldName:queryField tableName:relatedObjectName andOrderType:[self getSqlOrderType:sortingOrder]];
                            
                            [orberByData addObject:orderByfield];
                        }
                    }
                }
            }
            else {
                NSString *queryField = [sortingDataDict objectForKey:kFieldAPIName];
                
                NSString *sortingOrder = [sortingDataDict objectForKey:@"sortingOrder"];
                
                if ([queryField length] > 0 && [sortingOrder length] > 0) {
                    DBField *orderByfield = [[DBField alloc] initWithFieldName:queryField tableName:self.objectName andOrderType:[self getSqlOrderType:sortingOrder]];
                    [orberByData addObject:orderByfield];
                }
            }
        }
        if([orberByData count] > 0) {
            [datadict setObject:orberByData forKey:@"ORDER BY"];
        }
    }
    return datadict;
}

- (SQLOrderByType)getSqlOrderType:(NSString *)type
{
    if ([type isEqualToString:@"DESC"])
    {
        return SQLOrderByTypesDescending;
    }
    return SQLOrderByTypesAscending;
}
@end
