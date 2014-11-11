//
//  ProductManualService.m
//  ServiceMaxiPad
//
//  Created by Chinnababu on 06/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ProductManualService.h"
#import "DatabaseQueue.h"
#import "DatabaseManager.h"
#import "ProductManualDAO.h"
#import "DBRequestInsert.h"
#import "ProductManualModel.h"
#import "CacheManager.h"

@implementation ProductManualService

- (NSString *)tableName
{
    return @"troubleshootdata";
}

- (void)insertIntoDBWithObjectName:(NSString *)objectName andSfIdArray:(NSArray *)sfIdArray
{
    
    for(NSString *sfId in sfIdArray)
    {
        
        NSMutableArray *array = [[NSMutableArray alloc]initWithObjects:@"sFId",@"productName", nil];
        DBRequestInsert *insert = [[DBRequestInsert alloc] initWithTableName:@"troubleshootdata" andFieldNames:array];
        ProductManualModel *model = [[ProductManualModel alloc] init];
        model.prod_manual_Id = sfId;
        model.prod_manual_name = objectName;
        [self updateEachRecord:model withQuery:[insert query]];
        NSLog(@"key %@, value: %@",objectName,sfId);
    }
}


- (NSArray *)getDocumentDetails:(NSString *)docId
{
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:@"ProductId" operatorType:SQLOperatorEqual andFieldValue:docId];
    return [self fetchRecordsByFields:@[@"prod_manual_name",@"ProductId",@"prod_manual_Id"] andCriteria:criteria withDistinctFlag:YES];
}

- (NSArray * )fetchRecordsByFields:(NSArray *)fieldNames andCriteria:(DBCriteria *)criteria withDistinctFlag:(BOOL)isDistinct
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:@"troubleshootdata" andFieldNames:fieldNames whereCriteria:criteria];
    
    if (isDistinct) {
        
        [requestSelect setDistinctRowsOnly];
    }
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            NSString * query = [requestSelect query];
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while ([resultSet next]) {
                
                ProductManualModel * model = [[ProductManualModel alloc] init];
                [resultSet kvcMagic:model];
                [records addObject:model];
            }
            [resultSet close];
        }];
    }
    return records;
}

-(NSString *)getTheProductIdDetailsFromTheDocumentTableWithTheProductId:(NSString *)productId1
{
    NSString *productId = [[CacheManager sharedInstance] getCachedObjectByKey:@"pMId"];

    DBCriteria *criteria = [[DBCriteria alloc]initWithFieldName:@"ProductId"
                                                   operatorType:SQLOperatorEqual andFieldValue:productId];
    DBRequestSelect *selectQuery = [[DBRequestSelect alloc]initWithTableName:@"troubleshootdata"
                                                               andFieldNames:@[@"ProductId"] whereCriteria:criteria];
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    
    ProductManualModel * model = [[ProductManualModel alloc] init];
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            NSString * query = [selectQuery query];
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while ([resultSet next]) {
                
                [resultSet kvcMagic:model];
                [records addObject:model];
            }
            [resultSet close];
        }];
    }
    for (ProductManualModel * model in records)
    {
        return model.ProductId;
    }
    return nil;
}

 


@end