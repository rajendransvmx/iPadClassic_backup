//
//  OPDocSignatureService.m
//  ServiceMaxiPad
//
//  Created by Damodar on 29/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "OPDocSignatureService.h"
#import "DBRequestInsert.h"
#import "DBRequestUpdate.h"
#import "DBRequestSelect.h"
#import "DBCriteria.h"
#import "DatabaseManager.h"
#import "DBRequestDelete.h"

@implementation OPDocSignatureService


- (NSString *)tableName
{
    return @"OPDocSignature";
}

/* Add signatures and HTML file to tables */
- (void)addSignature:(OPDocSignature*)model
{
    [self saveRecordModel:model];
}

/* Update SFID of signatures and HTML file to tables */
- (void)updateSignature:(OPDocSignature*)model
{
    if(!model.sfid.length)
        return;
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kOPDocFileName operatorType:SQLOperatorEqual andFieldValue:model.Name];
    
//    DBRequestUpdate * updatequery = [[DBRequestUpdate alloc] initWithTableName:[self tableName] andFieldNames:@[model.sfid] whereCriteria:@[criteria] andAdvanceExpression:nil];
    
    //Update query changed : krishna
    DBRequestUpdate * updatequery = [[DBRequestUpdate alloc] initWithTableName:[self tableName] andFieldNames:@[kOPDocSFID] whereCriteria:@[criteria] andAdvanceExpression:nil];
    
    BOOL status = [self updateEachRecord:model withQuery:[updatequery query]];
    
    SXLogInfo(@"Update %d signature file %@ :: %@",status, model.Name, model.sfid);
}

/* Get the model object for file name */
- (OPDocSignature*)getSignatureObjectFor:(NSString*)signatureName
{
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kOPDocFileName operatorType:SQLOperatorEqual andFieldValue:signatureName];
    
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:nil whereCriteria:criteria];
    __block OPDocSignature * model;
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {

        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        model = [[OPDocSignature alloc] init];
        if ([resultSet next]) {
            [resultSet kvcMagic:model];
        }
        [resultSet close];
    }];
    }
    return model;;

}

- (NSArray*)getSignaturesForHTMLFile:(NSString*)htmlFilename
{
    NSMutableArray *signatures = [NSMutableArray array];
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kOPDocHTMLFileName operatorType:SQLOperatorEqual andFieldValue:htmlFilename];
    
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:nil whereCriteria:criteria];

    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            
            NSString * query = [requestSelect query];
            
            SQLResultSet * resultSet = [db executeQuery:query];

            while ([resultSet next])
            {
                OPDocSignature *model = [[OPDocSignature alloc] init];
                [resultSet kvcMagic:model];
                [signatures addObject:model];
            }
            [resultSet close];
        }];
    }
    
    return signatures;
}

/* Update html filenames for signature file to table */
- (void)updateHTMLFilenameInSignature:(OPDocSignature*)model
{
    if(!model.HTMLFileName.length)
        return;
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kOPDocFileName operatorType:SQLOperatorEqual andFieldValue:model.Name];
    
    //    DBRequestUpdate * updatequery = [[DBRequestUpdate alloc] initWithTableName:[self tableName] andFieldNames:@[model.sfid] whereCriteria:@[criteria] andAdvanceExpression:nil];
    
    //Update query changed : krishna
    DBRequestUpdate * updatequery = [[DBRequestUpdate alloc] initWithTableName:[self tableName] andFieldNames:@[kOPDocHTMLFileName] whereCriteria:@[criteria] andAdvanceExpression:nil];
    
    BOOL status = [self updateEachRecord:model withQuery:[updatequery query]];
    
    SXLogInfo(@"Update %d signature file %@ :: %@",status, model.Name, model.HTMLFileName);
}


- (NSMutableArray *)getSignatureModelListForFileUpload
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
                
                OPDocSignature * model = [[OPDocSignature alloc] init];
                [resultSet kvcMagic:model];
                [lTheDataArray addObject:model];
            }
            [resultSet close];
        }];
    }
    return lTheDataArray;
    
}

- (NSMutableArray *)getSignatureModelListForFileUploadforRecordID:(NSString *)record_ID andHTMLFileName:(NSString *)htmlFileName
{
    DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:kOPDocSFID operatorType:SQLOperatorIsNull andFieldValue:nil];
    DBCriteria *criteria2 = [[DBCriteria alloc] initWithFieldName:kOPDocRecordId operatorType:SQLOperatorEqual andFieldValue:record_ID];
    DBCriteria *criteria3 = [[DBCriteria alloc] initWithFieldName:kOPDocHTMLFileName operatorType:SQLOperatorEqual andFieldValue:htmlFileName];

    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:nil whereCriterias:@[criteria1, criteria2, criteria3] andAdvanceExpression:@"(1 AND 2 AND 3)"];
    
    NSMutableArray *lTheDataArray = [[NSMutableArray alloc] init];
    
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            
            NSString * query = [requestSelect query];
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while ([resultSet next]) {
                
                OPDocSignature *model = [[OPDocSignature alloc] init];
                [resultSet kvcMagic:model];
                [lTheDataArray addObject:model];
            }
            [resultSet close];
        }];
    }
    return lTheDataArray;
    
}


-(NSMutableArray *)getSignatureListToSubmitForHtmlFile:(NSString *)htmlFile
{
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kOPDocHTMLFileName operatorType:SQLOperatorEqual andFieldValue:htmlFile];
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:@[kOPDocSFID] whereCriteria:criteria];
    
    NSMutableArray *lTheDataArray = [[NSMutableArray alloc] init];
    
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            
            NSString * query = [requestSelect query];
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while ([resultSet next]) {
                
                OPDocSignature * model = [[OPDocSignature alloc] init];
                [resultSet kvcMagic:model];
                //Sfid sent in array instead of model : krishna
                if (model.sfid) {
                     [lTheDataArray addObject:model.sfid];
                }
            }
            [resultSet close];
        }];
    }
    return lTheDataArray;
    
}


//OLD Start

-(NSMutableArray *)getSignatureListToSubmit
{
    
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:@[kOPDocSFID] whereCriteria:nil];
    
    NSMutableArray *lTheDataArray = [[NSMutableArray alloc] init];
    
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            
            NSString * query = [requestSelect query];
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while ([resultSet next]) {
                
                OPDocSignature * model = [[OPDocSignature alloc] init];
                [resultSet kvcMagic:model];
                //Sfid sent in array instead of model : krishna
                if (model.sfid) {
                    [lTheDataArray addObject:model.sfid];
                }
            }
            [resultSet close];
        }];
    }
    return lTheDataArray;
    
}

//OLD Finish






-(BOOL)updateFileNameInTableForModel:(OPDocSignature*)model withNewFileName:(NSString *)lNewFileName
{
    model.HTMLFileName = lNewFileName;
    
    DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:kOPDocFileName operatorType:SQLOperatorEqual andFieldValue:model.Name];
    DBCriteria *criteria2 = [[DBCriteria alloc] initWithFieldName:kOPDocRecordId operatorType:SQLOperatorEqual andFieldValue:model.record_id];

    //Update query changed : krishna
    DBRequestUpdate * updatequery = [[DBRequestUpdate alloc] initWithTableName:[self tableName] andFieldNames:@[kOPDocHTMLFileName] whereCriteria:@[criteria1, criteria2] andAdvanceExpression:nil];
    
    BOOL status = [self updateEachRecord:model withQuery:[updatequery query]];
    
    SXLogInfo(@"Update %d signature file %@ :: %@",status, model.Name, model.sfid);
    
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
                
                OPDocSignature * model = [[OPDocSignature alloc] init];
                [resultSet kvcMagic:model];
                [lTheDataArray addObject:model];
            }
            [resultSet close];
        }];
    }
    return lTheDataArray;
}
*/


-(NSArray *)getAllFilesPresentInTableForWhichNeedsToBeDeleted:(NSString *)signatureSFIDOrHTMLFileName
{
    // The entry should have sf_id assigned. So criteria is those entries whose sf_id is not null.
    DBCriteria *criteriaOne = [[DBCriteria alloc]initWithFieldName:kOPDocSFID operatorType:SQLOperatorEqual andFieldValue:signatureSFIDOrHTMLFileName];
    DBCriteria *criteriaTwo = [[DBCriteria alloc]initWithFieldName:kOPDocHTMLFileName operatorType:SQLOperatorEqual andFieldValue:signatureSFIDOrHTMLFileName];

    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:nil whereCriterias:@[criteriaOne, criteriaTwo] andAdvanceExpression:@"(1 or 2)"];
    
    NSMutableArray *lTheDataArray = [[NSMutableArray alloc] init];
    
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            
            NSString * query = [requestSelect query];
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while ([resultSet next]) {
                
                OPDocSignature * model = [[OPDocSignature alloc] init];
                [resultSet kvcMagic:model];
                [lTheDataArray addObject:model];
            }
            [resultSet close];
        }];
    }
    return lTheDataArray;
}

-(BOOL)deleteRecordsSignatureTableForList:(NSArray *)listArray
{
    
    DBCriteria *criteriaOne = [[DBCriteria alloc]initWithFieldName:kOPDocSFID operatorType:SQLOperatorIn andFieldValues:listArray];
    DBRequestDelete *requestDelete = [[DBRequestDelete alloc] initWithTableName:[self tableName] whereCriteria:[NSArray arrayWithObject:criteriaOne] andAdvanceExpression:nil];
    
    BOOL result = [self executeStatement:[requestDelete query]];
    
    return result;
    
}
    
    
    
@end
