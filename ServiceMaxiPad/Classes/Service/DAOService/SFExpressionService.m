//
//  SFExpressionService.m
//  ServiceMaxMobile
//
//  Created by Aparna on 19/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFExpressionService.h"
#import "SFExpressionModel.h"
#import "DBCriteria.h"
#import "DBRequestSelect.h"
#import "DatabaseManager.h"
#import "SQLResultSet.h"
#import "DatabaseConstant.h"

@implementation SFExpressionService

- (SFExpressionModel *) getExpressionBySFId:(NSString *)expSFId
{
    if ([expSFId length] > 0) {
        NSArray *fieldNames = [[NSArray alloc] initWithObjects:kSFExpressionId,kSFExpressionKey,kSFExpSourceObjectName,kSFExpErrorMessage,nil];
        DBCriteria *criteria =[[DBCriteria alloc] initWithFieldName:kSFExpressionId
                                                       operatorType:SQLOperatorEqual
                                                      andFieldValue:expSFId];
        DBRequestSelect *dbSelect = [[DBRequestSelect alloc] initWithTableName:kSFExpression andFieldNames:fieldNames whereCriteria:criteria];
        NSString *selectQuery = [dbSelect query];
//        NSLog(@"Query %@", selectQuery);
        
        __block SFExpressionModel * model = nil;
        @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            SQLResultSet * resultSet = [db executeQuery:selectQuery];
            while ([resultSet next]) {
                model = [[SFExpressionModel alloc] init];
                [resultSet kvcMagic:model];
            }
            [resultSet close];
        }];
        }
    return model;
    }
    return nil;
}

- (NSString *)tableName {
    return kSFExpressionTableName;
}

@end
