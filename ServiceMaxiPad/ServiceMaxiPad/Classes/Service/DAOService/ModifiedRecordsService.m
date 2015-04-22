//
//  ModifiedRecordsService.m
//  ServiceMaxMobile
//
//  Created by Sahana on 08/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "ModifiedRecordsService.h"
#import "DBCriteria.h"
#import "DBRequestSelect.h"
#import "DatabaseManager.h"
#import "SQLResultSet.h"
#import "ModifiedRecordModel.h"
#import "DatabaseConstant.h"


@implementation ModifiedRecordsService


- (NSDictionary *)getInsertedSyncRecords
{
    return [self getSyncRecordsOfType:kModificationTypeInsert];
}

- (NSDictionary *) getUpdatedRecords
{
    return [self getSyncRecordsOfType:kModificationTypeUpdate];
}

- (NSDictionary *)getDeletedRecords
{
    return [self getSyncRecordsOfType:kModificationTypeDelete];
    
}

- (NSMutableDictionary *) getSyncRecordsOfType:(NSString *)opertationType
{
    NSMutableDictionary * syncRecordDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    DBCriteria * criteriaObj = [[DBCriteria alloc] initWithFieldName:kSyncRecordOperation operatorType:SQLOperatorEqual andFieldValue:opertationType];
    
// added 'operation type' field
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:[NSArray arrayWithObjects:kSyncRecordLocalId,kSyncRecordObjectname,kSyncRecordType,kSyncRecordSFId,kSyncRecordOperation,@"fieldsModified",nil] whereCriteria:criteriaObj];
    [requestSelect setDistinctRowsOnly];
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {

        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        while ([resultSet next]) {
            
            ModifiedRecordModel * modifiedRecord = [[ModifiedRecordModel alloc] init];
            
            [resultSet kvcMagic:modifiedRecord];
           
            if (modifiedRecord.recordLocalId.length < 15) {
                modifiedRecord.recordLocalId = @"";
            }
            NSMutableDictionary *objectDictionary = [syncRecordDict valueForKey:modifiedRecord.recordType];
            if (nil == objectDictionary) {
                objectDictionary = [[NSMutableDictionary alloc] init];
                [syncRecordDict setObject:objectDictionary forKey:modifiedRecord.recordType];
            }
            NSMutableArray *recordsArray = [objectDictionary valueForKey:modifiedRecord.objectName];
            if (nil == recordsArray) {
                recordsArray = [[NSMutableArray alloc] init];
                [objectDictionary setObject:recordsArray forKey:modifiedRecord.objectName];
            }
            [recordsArray addObject:modifiedRecord];
        }
        [resultSet close];
    }];
    }
    return syncRecordDict;
}

-(NSString *)tableName
{
    return kModifiedRecords;
}

- (NSInteger)getLastLocalId {
    DBField *aField = [[DBField alloc] initWithFieldName:kLocalId andTableName:kModifiedRecords];
    DBRequestSelect *selectRequest = [[DBRequestSelect alloc] initWithField:aField aggregateFunction:SQLAggregateFunctionMax whereCriterias:nil andAdvanceExpression:nil];
    __block NSInteger maxNumber = -1;
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
    
    SQLResultSet * resultSet = [db executeQuery:[selectRequest query]];
    if([resultSet next])
    {
        NSString *keyString = [[NSString alloc] initWithFormat:@"%@(%@)",kSQLAggregateFunctionMax,kLocalId];
        NSDictionary * dict = [resultSet resultDictionary];
        if ([dict count]>0) {
            NSString *aValue = [dict valueForKey:keyString] ;
            if (![aValue isKindOfClass:[NSNull class]]) {
                maxNumber = [aValue intValue];
            }
        }
    }
        [resultSet close];
    }];
    }
    return maxNumber;
}

- (NSArray *)fieldNamesToBeRemovedFromQuery {
    return @[@"cannotSendToServer",@"jsonRecord", @"recordDictionary"];
}

-(BOOL)deleteRecordsForRecordLocalIds:(NSArray *)recordsIds
{
    DBCriteria *criteriaOne = [[DBCriteria alloc]initWithFieldName:@"recordLocalId"
                                                      operatorType:SQLOperatorIn
                                                    andFieldValues:recordsIds];
    
    BOOL status = [self deleteRecordsFromObject:kModifiedRecords
                                  whereCriteria:[NSArray arrayWithObject:criteriaOne]
                           andAdvanceExpression:nil];
    return status;
}

-(BOOL)deleteUpdatedRecordsForRecordLocalId:(NSString *)recordsId
{
    DBCriteria *criteriaOne = [[DBCriteria alloc]initWithFieldName:@"recordLocalId"
                                                      operatorType:SQLOperatorEqual
                                                    andFieldValue:recordsId];
    DBCriteria *criteriaTwo = [[DBCriteria alloc]initWithFieldName:@"operation"
                                                      operatorType:SQLOperatorEqual
                                                    andFieldValue:@"UPDATE"];
    
    BOOL status = [self deleteRecordsFromObject:kModifiedRecords
                                  whereCriteria:@[criteriaOne,criteriaTwo]
                           andAdvanceExpression:nil];
    return status;
}

- (NSArray *) getSyncRecordsOfType:(NSString *)opertationType andObjectName:(NSString *)objectName
{
   
    
    DBCriteria * criteriaObj = [[DBCriteria alloc] initWithFieldName:kSyncRecordOperation operatorType:SQLOperatorEqual andFieldValue:opertationType];
    
    DBCriteria * criteriaObj2 = [[DBCriteria alloc] initWithFieldName:kSyncRecordObjectname operatorType:SQLOperatorEqual andFieldValue:objectName];
    
    
    
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:[NSArray arrayWithObjects:kSyncRecordLocalId, nil] whereCriterias:@[criteriaObj,criteriaObj2] andAdvanceExpression:nil];
    
    NSMutableArray *allRecordArray = [[NSMutableArray alloc] init];
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        while ([resultSet next]) {
            
            ModifiedRecordModel * modifiedRecord = [[ModifiedRecordModel alloc] init];
            
            [resultSet kvcMagic:modifiedRecord];
            
            if (modifiedRecord.recordLocalId != nil) {
                [allRecordArray addObject:modifiedRecord.recordLocalId];
            }
            
        }
        [resultSet close];
    }];
    }
    return allRecordArray;
}


- (BOOL)doesRecordExistForId:(NSString *)recordId {
    BOOL flag = NO;
    DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:@"recordLocalId" operatorType:SQLOperatorEqual andFieldValue:recordId];
    
    DBCriteria *criteria2 = [[DBCriteria alloc] initWithFieldName:@"sfId" operatorType:SQLOperatorEqual andFieldValue:recordId];
    
    NSInteger totalCount =  [self getNumberOfRecordsFromObject:[self tableName] withDbCriteria:@[criteria1,criteria2] andAdvancedExpression:@"(1 or 2)"];
    
    if(totalCount > 0)
    {
        flag = YES;
    }
    
    return flag;
}

// if modified record has operation type 'Update' but no sfid, fetch sfid using localid and continue sync..
-(void)updateModifiedRecord:(ModifiedRecordModel *)model {
    NSArray * fieldsArray = [[NSArray alloc] initWithObjects:@"sfId", nil];
    DBCriteria * criteria1 = [[DBCriteria alloc] initWithFieldName:@"recordLocalId" operatorType:SQLOperatorEqual andFieldValue:model.recordLocalId];
    [self updateEachRecord:model withFields:fieldsArray withCriteria:[NSArray arrayWithObject:criteria1]];
}

-(void)updateFieldsModifed:(ModifiedRecordModel *)model {
    NSArray * fieldsArray = [[NSArray alloc] initWithObjects:@"fieldsModified", nil];
    DBCriteria * criteria1 = [[DBCriteria alloc] initWithFieldName:@"recordLocalId" operatorType:SQLOperatorEqual andFieldValue:model.recordLocalId];
    [self updateEachRecord:model withFields:fieldsArray withCriteria:[NSArray arrayWithObject:criteria1]];
}

- (NSString *)fetchExistingModifiedFieldsJsonFromModifiedRecordForRecordId:(NSString*)recordId andSfId:(NSString*)sfId
{
    DBCriteria *criteriaOne = [[DBCriteria alloc]initWithFieldName:@"recordLocalId" operatorType:SQLOperatorEqual andFieldValue:recordId];
    DBCriteria *criteriaTwo = [[DBCriteria alloc]initWithFieldName:@"operation" operatorType:SQLOperatorEqual andFieldValue:@"UPDATE"];
    DBCriteria *criteriaThree = [[DBCriteria alloc]initWithFieldName:@"sfId" operatorType:SQLOperatorEqual andFieldValue:sfId];
    
    NSArray *tempArray = [self fetchDataForFields:@[@"fieldsModified"]
                                        criterias:@[criteriaOne,criteriaTwo,criteriaThree]
                                       objectName:@"ModifiedRecords"
                               advancedExpression:@"((1 or 3) and 2)"
                                    andModelClass:[ModifiedRecordModel class]];
    if ([tempArray count] > 0) {
        ModifiedRecordModel *modifiedRecordModel = [tempArray objectAtIndex:0];
        return modifiedRecordModel.fieldsModified;
    }
    return nil;
}


- (BOOL)doesRecordExistForId:(NSString *)recordId andOperationType:(NSString *)operationType {
    BOOL flag = NO;
    DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:@"recordLocalId" operatorType:SQLOperatorEqual andFieldValue:recordId];
    
    DBCriteria *criteria2 = [[DBCriteria alloc] initWithFieldName:@"sfId" operatorType:SQLOperatorEqual andFieldValue:recordId];
    
    DBCriteria *criteria3 = [[DBCriteria alloc]initWithFieldName:@"operation" operatorType:SQLOperatorEqual andFieldValue:operationType];
    
    
    NSInteger totalCount =  [self getNumberOfRecordsFromObject:[self tableName] withDbCriteria:@[criteria1,criteria2,criteria3] andAdvancedExpression:@"((1 or 2) and 3 )"];
    
    if(totalCount > 0)
    {
        flag = YES;
    }
    
    return flag;
}

@end
