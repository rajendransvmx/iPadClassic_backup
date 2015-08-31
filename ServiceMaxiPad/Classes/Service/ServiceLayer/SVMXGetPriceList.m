//
//  SVMXGetPriceList.m
//  ServiceMaxiPad
//
//  Created by Apple on 26/08/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "SVMXGetPriceList.h"
#import "DBRequestSelect.h"
#import "DatabaseQueue.h"
#import "SQLResultSet.h"
#import "DatabaseManager.h"
#import "SyncRecordHeapModel.h"
#import "SVMXSystemConstant.h"
#import "SVMXGetPriceModel.h"

@implementation SVMXGetPriceList

-(NSArray *)getPricebookIds
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:kDataPurgePriceBook andFieldNames:[NSArray arrayWithObjects:kId, nil] whereCriteria:nil];
    
    [requestSelect setDistinctRowsOnly];
    
    return [self getRecordsFromQuery:[requestSelect query]];
    
    return nil;
    return @[];
}
-(NSArray *)getServicePricebookIds
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:kDataPurgeCustomPriceBook andFieldNames:[NSArray arrayWithObjects:kId, nil] whereCriteria:nil];
    
    [requestSelect setDistinctRowsOnly];
    
    return [self getRecordsFromQuery:[requestSelect query]];
    
    return nil;
    return @[];
}

- (NSArray*)getRecordsFromQuery:(NSString*)query
{
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while ([resultSet next]) {
                SVMXGetPriceModel * model = [[SVMXGetPriceModel alloc] init];
                [resultSet kvcMagic:model];
                [records addObject:model];
            }
            [resultSet close];
        }];
    }
    return records;
}
@end
