//
//  SVMXGetPriceHelper.m
//  ServiceMaxiPad
//
//  Created by Apple on 04/09/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "SVMXGetPriceHelper.h"
#import "DBRequestSelect.h"
#import "DatabaseQueue.h"
#import "SQLResultSet.h"
#import "DatabaseManager.h"
#import "SyncRecordHeapModel.h"
#import "SVMXSystemConstant.h"
#import "Utility.h"

@implementation SVMXGetPriceHelper
-(NSArray *)getPricebookIds
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:kDataPurgePriceBook andFieldNames:[NSArray arrayWithObjects:kId, nil] whereCriteria:nil];
    
    [requestSelect setDistinctRowsOnly];
    
    return [self getRecordsFromQuery:[requestSelect query]];
}
-(NSArray *)getServicePricebookIds
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:kDataPurgeCustomPriceBook andFieldNames:[NSArray arrayWithObjects:kId, nil] whereCriteria:nil];
    
    [requestSelect setDistinctRowsOnly];
    
    return [self getRecordsFromQuery:[requestSelect query]];
}

- (NSArray*)getRecordsFromQuery:(NSString*)query
{
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            SQLResultSet * resultSet = [db executeQuery:query];
            while ([resultSet next]) {
                NSDictionary *dict = [resultSet resultDictionary];
                if([dict count] > 0)
                {
                    NSString *recordId = [dict objectForKey:kId];
                    if (![Utility isStringEmpty:recordId])
                    {
                        [records addObject:recordId];
                    }

                }
                           }
            [resultSet close];
        }];
    }
    return records;
}
@end
