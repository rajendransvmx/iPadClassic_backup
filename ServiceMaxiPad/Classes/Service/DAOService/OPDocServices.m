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
#import "DatabaseConstant.h"

@implementation OPDocServices

- (NSString *)tableName
{
    return @"OPDocHTML";
}

/* Add signatures and HTML file to tables */
- (void)addHTMLfile:(OPDocHTML*)model
{
    BOOL isSaved = [self saveRecordModel:model];
    if (isSaved) {
        dispatch_async(dispatch_get_main_queue(), ^{
           [[NSNotificationCenter defaultCenter] postNotificationName:OPDocSavedNotification object:nil];
        });
    }
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

    SXLogInfo(@"Update %d HTML file %@ :: %@",status, model.Name, model.sfid);
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


-(NSArray *)getHTMLListToSubmitForHtmlFile:(NSString *)htmlFile
{
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kOPDocFileName operatorType:SQLOperatorEqual andFieldValue:htmlFile];
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:@[kOPDocSFID] whereCriteria:criteria];
    
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


//OLD START
-(NSArray *)getHTMLListToSubmit
{
    
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:nil whereCriteria:nil];
    
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
                    [lTheDataArray addObject:model];
                }
            }
            [resultSet close];
        }];
    }
    return lTheDataArray;
    
}

//OLD FINISH



-(NSArray *)getLocallySavedHTMLListForId:(NSString*)recordId
{
    if (![recordId length])
        return nil;
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kOPDocRecordId operatorType:SQLOperatorEqual andFieldValue:recordId];
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:nil whereCriteria:criteria];
    
    NSMutableArray *lTheDataArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            
            NSString * query = [requestSelect query];
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while ([resultSet next]) {
                
                OPDocHTML * model = [[OPDocHTML alloc] init];
                [resultSet kvcMagic:model];
                if (![model.sfid length]) {
                    [lTheDataArray addObject:model];
                }
            }
            [resultSet close];
        }];
    }
    return lTheDataArray;
}

- (NSMutableArray*)getWorkOrderNameWithTableName:(NSString*)tableName withRecordIdArray:(NSMutableArray*)recordIdArray {
    
    __block NSMutableArray *workOrderNamesArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kLocalId operatorType:SQLOperatorIn andFieldValues:recordIdArray];
    DBRequestSelect *requestSelect = [[DBRequestSelect alloc] initWithTableName:tableName andFieldNames:[NSArray arrayWithObjects:kWorkOrderName,kLocalId, nil] whereCriteria:criteria];
    
    
    @autoreleasepool {
        
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            
            NSString * query = [requestSelect query];
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while ([resultSet next]) {
                NSMutableDictionary *columnDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
                [resultSet kvcMagic:columnDictionary];
                [workOrderNamesArray addObject:columnDictionary];
            }
            [resultSet close];
        }];
    }
    
    return workOrderNamesArray;
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
    
    SXLogInfo(@"Update %d HTML file %@ :: %@",status, model.Name, model.sfid);
    
    return status;
}

/*
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

*/
-(NSArray *)getAllFilesPresentInTableForWhichNeedsToBeDeleted:(NSString *)theHTMLSFIDOrHTMLFileName
{
    // The entry should have sf_id assigned. So criteria is those entries whose sf_id is not null.
    DBCriteria *criteriaOne = [[DBCriteria alloc]initWithFieldName:kOPDocSFID operatorType:SQLOperatorEqual andFieldValue:theHTMLSFIDOrHTMLFileName];
    DBCriteria *criteriaTwo = [[DBCriteria alloc]initWithFieldName:kOPDocFileName operatorType:SQLOperatorEqual andFieldValue:theHTMLSFIDOrHTMLFileName];

    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:nil whereCriterias:@[criteriaOne, criteriaTwo] andAdvanceExpression:@"(1 or 2)"];
    
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

-(BOOL)updateTableToRemovetheSFIDForList:(NSArray *)listArray
{
    DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:kOPDocSFID operatorType:SQLOperatorIn andFieldValues:listArray];
    
    DBRequestUpdate * updatequery = [[DBRequestUpdate alloc] initWithTableName:[self tableName] andFieldNames:@[kOPDocSFID] whereCriteria:@[criteria1] andAdvanceExpression:nil];
    BOOL status = [self updateEachRecord:@{kOPDocSFID:@""} withQuery:[updatequery query]];
    
    
    return status;
}

@end
