//
//  SFNamedSearchFilterService.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 01/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "SFNamedSearchFilterService.h"
#import "ParserUtility.h"


@implementation SFNamedSearchFilterService

- (NSString *)tableName
{
    return kSFNamedSearchFilters;
}

- (NSArray * )fetchSFNameSearchFiltersInfoByFields:(NSArray *)fieldNames andCriteria:(NSArray *)criteria
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:kSFNamedSearchFilters andFieldNames:fieldNames whereCriterias:criteria andAdvanceExpression:nil];
    
    [requestSelect setDistinctRowsOnly];
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            
            NSString * query = [requestSelect query];
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while ([resultSet next]) {
                NSDictionary * dict = [resultSet resultDictionary];
                SFNamedSearchFilterModel * model = [[SFNamedSearchFilterModel alloc] init];
                [ParserUtility parseJSON:dict toModelObject:model withMappingDict:nil];
                [records addObject:model];
            }
            [resultSet close];
        }];
    }
    return records;
}

- (BOOL)enableInsertOrReplaceOption {
    return YES;
}


@end
