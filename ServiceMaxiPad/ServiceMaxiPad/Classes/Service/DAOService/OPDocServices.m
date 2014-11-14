//
//  OPDocServices.m
//  ServiceMaxiPad
//
//  Created by Damodar on 28/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "OPDocServices.h"
#import "DBRequestInsert.h"
#import "DBRequestUpdate.h"
#import "DBRequestSelect.h"
#import "DBCriteria.h"
#import "DBRequestDelete.h"

@implementation OPDocServices

- (NSString *)tableName
{
    return @"OPDocHTML";
}

/* Add signatures and HTML file to tables */
- (void)addHTMLfile:(OPDocHTML*)model
{
    [self saveRecordModel:model];
}

/* Update SFID of signatures and HTML file to tables */
- (void)updateHTML:(OPDocHTML*)model
{
    if(!model.sfid.length)
        return;
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kOPDocFileName operatorType:SQLOperatorEqual andFieldValue:model.Name];
    
    //Update query modified : krishna
    DBRequestUpdate * updatequery = [[DBRequestUpdate alloc] initWithTableName:[self tableName] andFieldNames:@[@"sfid"] whereCriteria:@[criteria] andAdvanceExpression:nil];
    
    BOOL status = [self updateEachRecord:model withQuery:[updatequery query]];

    NSLog(@"Update %d HTML file %@ :: %@",status, model.Name, model.sfid);
}

/* Get the model object for file name */
- (OPDocHTML*)getHTML:(NSString*)htmlName
{
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kOPDocFileName operatorType:SQLOperatorEqual andFieldValue:htmlName];
    
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:nil whereCriteria:criteria];
    
    __block OPDocHTML * model;
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        model = [[OPDocHTML alloc] init];
        
        if ([resultSet next]) {
            [resultSet kvcMagic:model];
        }
        [resultSet close];
    }];
    }
    return model;

}

-(NSMutableArray *)getHTMLModelListForFileUpload
{
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kOPDocSFID operatorType:SQLOperatorIsNull andFieldValue:nil];
    
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:nil whereCriteria:criteria];
    
    NSMutableArray *lTheDataArray = [[NSMutableArray alloc] init];
    
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            
            NSString * query = [requestSelect query];
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while ([resultSet next]) {
                
                OPDocHTML * model = [[OPDocHTML alloc] init];
                [resultSet kvcMagic:model];
                [lTheDataArray addObject:model];
            }
            [resultSet close];
        }];
    }
    return lTheDataArray;
    
}


-(NSArray *)getHTMLListToSubmit
{
    
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:@[kOPDocSFID] whereCriteria:nil];
    
    NSMutableArray *lTheDataArray = [[NSMutableArray alloc] init];
    
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            
            NSString * query = [requestSelect query];
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while ([resultSet next]) {
                
                OPDocHTML * model = [[OPDocHTML alloc] init];
                [resultSet kvcMagic:model];
                //Sending sfid instead of model : krishna
                if (model.sfid) {
                    [lTheDataArray addObject:model.sfid];
                }
            }
            [resultSet close];
        }];
    }
    return lTheDataArray;

}


-(BOOL)updateFileNameInTableForModel:(OPDocHTML*)model withNewFileName:(NSString *)lNewFileName
{
    
    DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:kOPDocFileName operatorType:SQLOperatorEqual andFieldValue:model.Name];
   
    //Clarify sudhguru.
    //DBCriteria *criteria2 = [[DBCriteria alloc] initWithFieldName:kOPDocFileName operatorType:SQLOperatorEqual andFieldValue:model.Name];

    //Update query modified : krishna
    model.Name = lNewFileName;
    DBRequestUpdate * updatequery = [[DBRequestUpdate alloc] initWithTableName:[self tableName] andFieldNames:@[@"Name"] whereCriteria:@[criteria1] andAdvanceExpression:nil];
    
    BOOL status = [self updateEachRecord:model withQuery:[updatequery query]];
    
    NSLog(@"Update %d HTML file %@ :: %@",status, model.Name, model.sfid);
    
    return status;
}


-(NSArray *)getAllFilesPresentInTableForWhichNeedsToBeDeleted
{
    // The entry should have sf_id assigned. So criteria is those entries whose sf_id is not null.
    DBCriteria *criteriaOne = [[DBCriteria alloc]initWithFieldName:kOPDocSFID operatorType:SQLOperatorIsNotNull andFieldValues:nil];
    
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:nil whereCriteria:criteriaOne];
    
    NSMutableArray *lTheDataArray = [[NSMutableArray alloc] init];
    
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            
            NSString * query = [requestSelect query];
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while ([resultSet next]) {
                
                OPDocHTML * model = [[OPDocHTML alloc] init];
                [resultSet kvcMagic:model];
                [lTheDataArray addObject:model];
            }
            [resultSet close];
        }];
    }
    return lTheDataArray;
}


-(BOOL)deleteRecordsHTMLTableForList:(NSArray *)listArray
{
    DBCriteria *criteriaOne = [[DBCriteria alloc]initWithFieldName:kOPDocSFID operatorType:SQLOperatorIn andFieldValues:listArray];
    DBRequestDelete *requestDelete = [[DBRequestDelete alloc] initWithTableName:[self tableName] whereCriteria:[NSArray arrayWithObject:criteriaOne] andAdvanceExpression:nil];
    
    BOOL result = [self executeStatement:[requestDelete query]];
    
    return result;
}

@end
