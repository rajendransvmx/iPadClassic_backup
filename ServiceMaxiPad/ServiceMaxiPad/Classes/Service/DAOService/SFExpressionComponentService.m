//
//  SFExpressionComponentService.m
//  ServiceMaxMobile
//
//  Created by Aparna on 19/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFExpressionComponentService.h"
#import "DBRequestSelect.h"
#import "SFExpressionModel.h"
#import "DatabaseManager.h"
#import "SQLResultSet.h"
#import "SFExpressionComponentModel.h"
#import "DatabaseConstant.h"

@implementation SFExpressionComponentService

- (NSArray *) getExpressionComponentsBySFId:(NSString *)expSFId
{
    if ([expSFId length] > 0) {
        NSArray *fieldNames = [[NSArray alloc] initWithObjects:kSFExpressionId,kSFExpComponentLHS,kSFExpComponentRHS,kSFExpComponentOperator,kSFExpComponentFieldType,kSFExpComponentParamType,nil];
        DBCriteria *criteria =[[DBCriteria alloc] initWithFieldName:kSFExpressionId
                                                       operatorType:SQLOperatorEqual
                                                      andFieldValue:expSFId];
        DBRequestSelect *dbSelect = [[DBRequestSelect alloc] initWithTableName:kSFExpressionComponent andFieldNames:fieldNames whereCriteria:criteria];
        [dbSelect setDistinctRowsOnly];
        [dbSelect addOrderByFields:[[NSArray alloc]initWithObjects:kSFExpressionCompSeqNo, nil]];
        NSString *selectQuery = [dbSelect query];
        BOOL didOpen = [[DatabaseManager sharedInstance] open];
        NSMutableArray *expCompArray = [[NSMutableArray alloc] init];
        if (didOpen)
        {
            SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:selectQuery];
            
            while ([resultSet next]) {
                
                SFExpressionComponentModel * model = [[SFExpressionComponentModel alloc] init];
                [resultSet kvcMagic:model];
                
                [expCompArray addObject:model];
            }
            
        }
        return expCompArray;
    }
    return nil;
}

- (NSString *)tableName {
    return kSFExpressionComponentTableName;
}
@end
