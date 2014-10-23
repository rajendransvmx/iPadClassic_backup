//
//  ExpressionParseService.m
//  ServiceMaxMobile
//
//  Created by Aparna on 18/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "ExpressionParserService.h"
#import "DBRequestSelect.h"
#import "DatabaseConstant.h"
#import "StringUtil.h"
#import "SQLResultSet.h"
#import "DatabaseManager.h"

@implementation ExpressionParserService


- (BOOL) isRecordExistWithId:(NSString *)recordId
                  objectName:(NSString *)objectName
                    criteria:(NSArray *)criteriaArray
           advanceExpression:(NSString *)expression
{
    
    BOOL isRecordExist = NO;
    NSMutableArray *newDbCriteriaArray = [[NSMutableArray alloc] initWithArray:criteriaArray];
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kLocalId operatorType:SQLOperatorEqual andFieldValue:recordId];
    [newDbCriteriaArray addObject:criteria];
    
    NSString *newAdvExpr = nil;
    
    if ([StringUtil isStringEmpty:recordId] || [StringUtil isStringEmpty:expression]) {
        newAdvExpr = expression;
    }
    else if (![StringUtil isStringEmpty:expression])
    {
        newAdvExpr = [[NSString alloc] initWithFormat:@"(%@) AND %d",expression,([criteriaArray count]+1)];
    }
    else if([StringUtil isStringEmpty:expression])
    {
        newAdvExpr = [[NSString alloc] initWithFormat:@"%d",([criteriaArray count]+1)];
    }
    
    DBRequestSelect *dbSelect = [[DBRequestSelect alloc] initWithTableName:objectName aggregateFunction:SQLAggregateFunctionCount whereCriterias:newDbCriteriaArray andAdvanceExpression:newAdvExpr];
    
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    
    if (didOpen)
    {
        NSString * query = [dbSelect query];
        
        SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:query];
        if([resultSet next])
        {
            NSDictionary * dict = [resultSet resultDictionary];
            if ([dict count]>0) {
                isRecordExist = [[dict valueForKey:@"COUNT(*)"] boolValue];
            }
        }
    }
    return isRecordExist;
}


@end
