//
//  TroubleshootingService.m
//  ServiceMaxiPad
//
//  Created by Chinnababu on 27/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "TroubleshootingService.h"
#import "TroubleshootDataModel.h"
#import "DatabaseConstant.h"
#import "DBRequestUpdate.h"
#import "DBRequestSelect.h"
#import "DBRequestInsert.h"

@implementation TroubleshootingService


- (NSString *)tableName
{
    return @"TroubleshootData";
}

- (NSArray * )fetchRecordsByFields:(NSArray *)fieldNames andCriteria:(DBCriteria *)criteria withDistinctFlag:(BOOL)isDistinct
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:fieldNames whereCriteria:criteria];
    
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
                
                TroubleshootDataModel * model = [[TroubleshootDataModel alloc] init];
                [resultSet kvcMagic:model];
                [records addObject:model];
            }
            [resultSet close];
        }];
    }
    return records;
}

- (NSArray*)getListOfDocument
{
    //   @"SELECT DeveloperName, Name From Document"]
    NSArray *documentModels = [self fetchRecordsByFields:@[@"DeveloperName"] andCriteria:nil withDistinctFlag:NO];
    return documentModels;
}


- (NSArray *)getDocumentDetails:(NSString *)docId
{
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:@"Id" operatorType:SQLOperatorEqual andFieldValue:docId];
    
    return [self fetchRecordsByFields:@[@"DeveloperName",@"Name",@"Type",KDocKeyWords,@"Id"] andCriteria:criteria withDistinctFlag:YES];
}

-(NSString *)getTheProductIdDetailsFromTheDocumentTableWithTheProductId:(NSString *)productId
{
    DBCriteria *criteria = [[DBCriteria alloc]initWithFieldName:KDocId
                                                   operatorType:SQLOperatorEqual andFieldValue:productId];
    DBRequestSelect *selectQuery = [[DBRequestSelect alloc]initWithTableName:[self tableName]
                                                               andFieldNames:@[KDocId] whereCriteria:criteria];
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    
    TroubleshootDataModel * model = [[TroubleshootDataModel alloc] init];
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
    for (TroubleshootDataModel * model in records)
    {
        return model.Id;
    }
    return nil;
}

- (BOOL )insertIntoDocumentsWithTheProductDetails:(NSArray *)productDetails
{
    NSMutableArray *array = [[NSMutableArray alloc]initWithObjects:KDocId,KDocKeyWords,KDocName,@"Type", nil];
    DBRequestInsert *insert = [[DBRequestInsert alloc] initWithTableName:[self tableName] andFieldNames:array];
    BOOL value = false;
    for(TroubleshootDataModel *model in productDetails)
    {
        value = [self updateEachRecord:model withQuery:[insert query]];
    }
    
    if(value)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}
- (NSArray *)getProductNamesForTheIds:(NSArray *)sFIds withDistinctFlag:(BOOL)isDistinct
{
        DBCriteria *criteria = [[DBCriteria alloc]initWithFieldName:KDocId
                                                       operatorType:SQLOperatorIn andFieldValues:sFIds];
        DBRequestSelect *selectQuery = [[DBRequestSelect alloc]initWithTableName:[self tableName]
                                                                   andFieldNames:@[KDocId,KDocName,@"Type"] whereCriteria:criteria];
        if (isDistinct) {
            
            [selectQuery setDistinctRowsOnly];
        }
        
        NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
        @autoreleasepool {
            DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
            
            [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
                NSString * query = [selectQuery query];
                
                SQLResultSet * resultSet = [db executeQuery:query];
                
                while ([resultSet next]) {
                    
                    TroubleshootDataModel * model = [[TroubleshootDataModel alloc] init];
                    [resultSet kvcMagic:model];
                    [records addObject:model];
                }
                [resultSet close];
            }];
        }
    return records;
}




@end
