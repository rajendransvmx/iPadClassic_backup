//
//  SFCustomActionURLService.m
//  ServiceMaxiPad
//
//  Created by Apple on 12/06/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "SFCustomActionURLService.h"
#import "CustomActionURLModel.h"
#import "SFExpressionParser.h"

@implementation SFCustomActionURLService

- (NSString *)tableName
{
    return @"CustomActionParams";
}

- (NSArray *)fieldNamesToBeRemovedFromQuery
{
    return @[@"isEntryCriteriaMatching"];
}

- (NSArray * )fetchWizardComponentParamsInfoByFields:(NSArray *)fieldNames
                                   andCriteria:(NSArray *)criteria
                                 andExpression:(NSString *)expression
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:fieldNames whereCriterias:criteria andAdvanceExpression:expression];
    
    [requestSelect setDistinctRowsOnly];
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            
            NSString * query = [requestSelect query];
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while ([resultSet next]) {
                CustomActionURLModel * model = [[CustomActionURLModel alloc] init];
                [resultSet kvcMagic:model];
                [records addObject:model];
            }
            [resultSet close];
        }];
    }
    return records;
}
- (NSArray *)getCustomActionParams:(NSString *)wizardComponentId{
    DBCriteria * criteriaOne = [[DBCriteria alloc] initWithFieldName:@"DispatchProcessId"
                                                        operatorType:SQLOperatorEqual
                                                       andFieldValue:wizardComponentId];
    NSArray * fieldNames = [[NSArray alloc] initWithObjects:@"ParameterName",@"ParameterType",@"ParameterValue",nil];
    
    NSArray * criteriaObjects = [[NSArray alloc] initWithObjects:criteriaOne, nil];
    
    NSArray * wizardComponentParamArray = [self fetchWizardComponentParamsInfoByFields:fieldNames andCriteria:criteriaObjects andExpression:nil];
    return wizardComponentParamArray;
}
-(void)updateWizardComponentWithModelArray:(NSArray*)modelArray
{
    
}


@end
