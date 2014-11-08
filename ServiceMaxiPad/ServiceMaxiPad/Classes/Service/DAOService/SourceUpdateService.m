//
//  SourceUpdateService.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 23/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SourceUpdateService.h"
#import "DBCriteria.h"
#import "DBRequestSelect.h"
#import "SFSourceUpdateModel.h"

@implementation SourceUpdateService

- (NSString *)tableName
{
    return @"SFSourceUpdate";
}

-(NSDictionary *)getSourceUpdateRecordsforProcessId:(NSString *)processId
{
    DBCriteria * criteia1= [[DBCriteria alloc] initWithFieldName:@"process" operatorType:SQLOperatorEqual andFieldValue:processId];
    NSMutableArray * sourceUpdateRecords = [self fetchSourceUpdateByFields:nil andCriteria:[NSArray arrayWithObject:criteia1] ];
    
    NSMutableDictionary * finalDict = [[NSMutableDictionary alloc] init];
    
    for (SFSourceUpdateModel * model in sourceUpdateRecords) {
        if( model.settingId != nil){
             NSMutableArray * array = [finalDict  objectForKey:model.settingId];
            if(array == nil)
            {
                array = [[NSMutableArray alloc] initWithCapacity:0];
                [finalDict setObject:array forKey:model.settingId];
            }
            [array addObject:model];
        }
    }
    return finalDict;
}


- (NSMutableArray * )fetchSourceUpdateByFields:(NSArray *)fieldNames andCriteria:(NSArray *)criteriaArray
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:fieldNames whereCriterias:criteriaArray andAdvanceExpression:nil];
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        while ([resultSet next]) {
            
            SFSourceUpdateModel * model = [[SFSourceUpdateModel alloc] init];
            
            [resultSet kvcMagic:model];
          
            [records addObject:model];
        }
        [resultSet close];
    }];
    return records;
}

@end
