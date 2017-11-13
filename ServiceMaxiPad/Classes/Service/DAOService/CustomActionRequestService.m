//
//  CustomActionRequestService.m
//  ServiceMaxiPad
//
//  Created by Vincent Sagar on 01/11/17.
//  Copyright © 2017 ServiceMax Inc. All rights reserved.
//

#import "CustomActionRequestService.h"
#import "DBCriteria.h"
#import "DBRequestSelect.h"
#import "DatabaseManager.h"
#import "SQLResultSet.h"
#import "ModifiedRecordModel.h"
#import "DatabaseConstant.h"
#import "ParserUtility.h"


@implementation CustomActionRequestService


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
    return kCustomActionRequestParams;
}

- (NSInteger)getLastLocalId {
    DBField *aField = [[DBField alloc] initWithFieldName:kLocalId andTableName:kCustomActionRequestParams];
    DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:@"operation" operatorType:SQLOperatorNotEqual andFieldValue:@"AFTERINSERT"];
    DBCriteria *criteria2 = [[DBCriteria alloc] initWithFieldName:@"operation" operatorType:SQLOperatorNotEqual andFieldValue:@"BEFOREUPDATE"];
    DBCriteria *criteria3 = [[DBCriteria alloc] initWithFieldName:@"operation" operatorType:SQLOperatorNotEqual andFieldValue:@"AFTERUPDATE"];
    DBRequestSelect *selectRequest = [[DBRequestSelect alloc] initWithField:aField aggregateFunction:SQLAggregateFunctionMax whereCriterias:@[criteria1,criteria2,criteria3] andAdvanceExpression:@"(1 AND 2 AND 3)"];
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
    return @[@"cannotSendToServer",@"jsonRecord", @"recordDictionary" ,@"overrideFlag", @"recordSent",@"requestData",@"requestId",@"Pending",@"webserviceName",
             @"className",
             @"syncType",@"syncFlag"];
}

-(BOOL)deleteRecordsForRecordLocalIds:(NSArray *)recordsIds
{
    DBCriteria *criteriaOne = [[DBCriteria alloc]initWithFieldName:@"recordLocalId"
                                                      operatorType:SQLOperatorIn
                                                    andFieldValues:recordsIds];
    DBCriteria *criteriaTwo = [[DBCriteria alloc]initWithFieldName:@"sfId"
                                                      operatorType:SQLOperatorIn
                                                    andFieldValues:recordsIds];
    
    BOOL status = [self deleteRecordsFromObject:kCustomActionRequestParams
                                  whereCriteria:@[criteriaOne, criteriaTwo]
                           andAdvanceExpression:@"(1 OR 2)"];
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
    
    BOOL status = [self deleteRecordsFromObject:kCustomActionRequestParams
                                  whereCriteria:@[criteriaOne,criteriaTwo]
                           andAdvanceExpression:nil];
    return status;
}

-(BOOL)deleteUpdatedRecordsForModifiedRecordModel:(ModifiedRecordModel *)model
{
    DBCriteria *criteriaOne = [[DBCriteria alloc]initWithFieldName:@"recordLocalId"
                                                      operatorType:SQLOperatorEqual
                                                     andFieldValue:model.recordLocalId];
    DBCriteria *criteriaTwo = [[DBCriteria alloc]initWithFieldName:@"operation"
                                                      operatorType:SQLOperatorEqual
                                                     andFieldValue:model.operation];
    DBCriteria *criteriaThree = [[DBCriteria alloc]initWithFieldName:@"requestData"
                                                        operatorType:SQLOperatorEqual
                                                       andFieldValue:model.requestData];
    DBCriteria *criteriaFour = [[DBCriteria alloc]initWithFieldName:kLocalId
                                                       operatorType:SQLOperatorEqual
                                                      andFieldValue:[NSString stringWithFormat:@"%ld", (long)model.localId]];
    
    BOOL status = [self deleteRecordsFromObject:kCustomActionRequestParams
                                  whereCriteria:@[criteriaOne,criteriaTwo,criteriaThree,criteriaFour]
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
    
    DBCriteria *criteria3 = [[DBCriteria alloc] initWithFieldName:@"operation" operatorType:SQLOperatorNotEqual andFieldValue:kModificationTypeAfterInsert];
    
    DBCriteria *criteria4 = [[DBCriteria alloc] initWithFieldName:@"operation" operatorType:SQLOperatorNotEqual andFieldValue:kModificationTypeBeforeUpdate];
    
    DBCriteria *criteria5 = [[DBCriteria alloc] initWithFieldName:@"operation" operatorType:SQLOperatorNotEqual andFieldValue:kModificationTypeAfterUpdate];
    
    NSInteger totalCount =  [self getNumberOfRecordsFromObject:[self tableName] withDbCriteria:@[criteria1,criteria2,criteria3,criteria4,criteria5] andAdvancedExpression:@"((1 or 2) and 3 and 4 and 5)"];
    
    if(totalCount > 0)
    {
        flag = YES;
    }
    
    return flag;
}

-(NSArray *)recordForRecordId:(NSString *)someRecordId
{
    DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:@"recordLocalId" operatorType:SQLOperatorEqual andFieldValue:someRecordId];
    
    DBCriteria *criteria2 = [[DBCriteria alloc] initWithFieldName:@"sfId" operatorType:SQLOperatorEqual andFieldValue:someRecordId];
    
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:nil whereCriterias:@[criteria1,criteria2] andAdvanceExpression:@"(1 OR 2)"];
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            NSString * query = [requestSelect query];
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while ([resultSet next]) {
                ModifiedRecordModel * model = [[ModifiedRecordModel alloc] init];
                NSDictionary *dict = [resultSet resultDictionary];
                [ParserUtility parseJSON:dict toModelObject:model withMappingDict:nil];
                [records addObject:model];
            }
            [resultSet close];
        }];
    }
    return records;
    
}

-(NSArray *)childRecordForParentLocalId:(NSString *)someRecordId
{
    DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:@"parentLocalId" operatorType:SQLOperatorEqual andFieldValue:someRecordId];
    
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:nil whereCriterias:@[criteria1] andAdvanceExpression:nil];
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            NSString * query = [requestSelect query];
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while ([resultSet next]) {
                ModifiedRecordModel * model = [[ModifiedRecordModel alloc] init];
                NSDictionary *dict = [resultSet resultDictionary];
                [ParserUtility parseJSON:dict toModelObject:model withMappingDict:nil];
                [records addObject:model];
            }
            [resultSet close];
        }];
    }
    return records;
    
}

-(void)updateCustomActionFlagForRecord:(ModifiedRecordModel *)model {
    NSArray * fieldsArray = [[NSArray alloc] initWithObjects:@"customActionFlag", nil];
    DBCriteria * criteria1 = [[DBCriteria alloc] initWithFieldName:@"recordLocalId" operatorType:SQLOperatorEqual andFieldValue:model.recordLocalId];
    [self updateEachRecord:model withFields:fieldsArray withCriteria:[NSArray arrayWithObject:criteria1]];
}
-(NSArray *)getCustomActionRequestParamsRecord
{
    DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:@"customActionFlag" operatorType:SQLOperatorEqual andFieldValue:@"1"];
    
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:nil whereCriterias:@[criteria1] andAdvanceExpression:nil];
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            NSString * query = [requestSelect query];
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while ([resultSet next]) {
                ModifiedRecordModel * model = [[ModifiedRecordModel alloc] init];
                NSDictionary *dict = [resultSet resultDictionary];
                [ParserUtility parseJSON:dict toModelObject:model withMappingDict:nil];
                [records addObject:model];
            }
            [resultSet close];
        }];
    }
    return records;
    
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
//    DBCriteria *criteriaTwo = [[DBCriteria alloc]initWithFieldName:@"operation" operatorType:SQLOperatorEqual andFieldValue:@"UPDATE"];
    DBCriteria *criteriaThree = [[DBCriteria alloc]initWithFieldName:@"sfId" operatorType:SQLOperatorEqual andFieldValue:sfId];
    
    NSArray *tempArray = [self fetchDataForFields:@[@"fieldsModified"]
                                        criterias:@[criteriaOne,criteriaThree]
                                       objectName:@"CustomActionRequestParams"
                               advancedExpression:@"(1 or 2)"
                                    andModelClass:[ModifiedRecordModel class]];
    if ([tempArray count] > 0) {
        ModifiedRecordModel *modifiedRecordModel = [tempArray objectAtIndex:0];
        return modifiedRecordModel.fieldsModified;
    }
    return nil;
}
- (ModifiedRecordModel *)fetchExistingModifiedFieldsJsonFromModifiedRecordForRecordIdForProductIQ:(NSString*)recordId andSfId:(NSString*)sfId
{
    // DBCriteria *criteriaOne = [[DBCriteria alloc]initWithFieldName:@"recordLocalId" operatorType:SQLOperatorEqual andFieldValue:recordId];
    DBCriteria *criteriaTwo = [[DBCriteria alloc]initWithFieldName:@"operation" operatorType:SQLOperatorEqual andFieldValue:@"UPDATE"];
    DBCriteria *criteriaThree = [[DBCriteria alloc]initWithFieldName:@"sfId" operatorType:SQLOperatorEqual andFieldValue:sfId];
    
    NSArray *tempArray = [self fetchDataForFields:@[@"fieldsModified"]
                                        criterias:@[criteriaTwo,criteriaThree]
                                       objectName:@"CustomActionRequestParams"
                               advancedExpression:@"(1 and 2)"
                                    andModelClass:[ModifiedRecordModel class]];
    if ([tempArray count] > 0) {
        ModifiedRecordModel *modifiedRecordModel = [tempArray objectAtIndex:0];
        return modifiedRecordModel;
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

- (BOOL)doesRecordExistForId:(NSString *)recordId andOperationType:(NSString *)operationType andparentID:(NSString *)parentID{
    
    recordId = [NSString stringWithFormat:@"%@%@",recordId,kChangedLocalIDForCustomCall];
    parentID = [NSString stringWithFormat:@"%@%@",parentID,kChangedLocalIDForCustomCall];
    
    BOOL flag = NO;
    DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:@"recordLocalId" operatorType:SQLOperatorEqual andFieldValue:recordId];
    
    DBCriteria *criteria2 = [[DBCriteria alloc] initWithFieldName:@"parentLocalId" operatorType:SQLOperatorEqual andFieldValue:parentID];
    
    DBCriteria *criteria3 = [[DBCriteria alloc]initWithFieldName:@"operation" operatorType:SQLOperatorEqual andFieldValue:operationType];
    
    DBCriteria *criteria4 = [[DBCriteria alloc]initWithFieldName:@"recordLocalId" operatorType:SQLOperatorEqual andFieldValue:parentID];
    
    NSInteger totalCount =  [self getNumberOfRecordsFromObject:[self tableName] withDbCriteria:@[criteria1,criteria2,criteria3,criteria4] andAdvancedExpression:@"((1 or 2 or 4) and 3)"];
    
    if(totalCount > 0)
    {
        flag = YES;
    }
    
    return flag;
}

- (NSArray *)getTheOperationValue
{
    
    DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:@"operation" operatorType:SQLOperatorEqual andFieldValue:@"AFTERINSERT"];
    DBCriteria *criteria2 = [[DBCriteria alloc] initWithFieldName:@"operation" operatorType:SQLOperatorEqual andFieldValue:@"BEFOREUPDATE"];
    DBCriteria *criteria3 = [[DBCriteria alloc] initWithFieldName:@"operation" operatorType:SQLOperatorEqual andFieldValue:@"AFTERUPDATE"];
    DBCriteria *criteria4 = [[DBCriteria alloc] initWithFieldName:kSyncRecordSent operatorType:SQLOperatorNotEqual andFieldValue:@"hold"];
    DBCriteria *criteria5 = [[DBCriteria alloc] initWithFieldName:kSyncRecordSent operatorType:SQLOperatorIsNull andFieldValue:nil];
    
    DBRequestSelect *selectQuery = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:@[@"operation", @"requestData", @"recordLocalId", kLocalId] whereCriterias:@[criteria1, criteria2, criteria3, criteria4,criteria5] andAdvanceExpression:@"((1 OR 2 OR 3) AND (4 OR 5))"];
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            NSString * query = [selectQuery query];
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while ([resultSet next])
            {
                ModifiedRecordModel * model = [[ModifiedRecordModel alloc] init];
                
                [resultSet kvcMagic:model];
                [records addObject:model];
            }
            [resultSet close];
        }];
    }
    return records;
}

- (NSArray *)getModifiedRecordListforRecordId:(NSString *)recordID sfid:(NSString *)sfId
{
    
    DBCriteria *criteriaOne = [[DBCriteria alloc]initWithFieldName:@"recordLocalId" operatorType:SQLOperatorEqual andFieldValue:recordID];
    DBCriteria *criteriaTwo = [[DBCriteria alloc]initWithFieldName:@"operation" operatorType:SQLOperatorEqual andFieldValue:@"UPDATE"];
    DBCriteria *criteriaThree = [[DBCriteria alloc]initWithFieldName:@"sfId" operatorType:SQLOperatorEqual andFieldValue:sfId];
    
    DBRequestSelect *selectQuery = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:nil whereCriterias:@[criteriaOne, criteriaTwo, criteriaThree] andAdvanceExpression:@"(1 AND 2 AND 3)"];
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            NSString * query = [selectQuery query];
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while ([resultSet next]) {
                ModifiedRecordModel * model = [[ModifiedRecordModel alloc] init];
                /*
                 [resultSet kvcMagic:model];
                 [records addObject:model];
                 */
                NSDictionary *dict = [resultSet resultDictionary];
                [ParserUtility parseJSON:dict toModelObject:model withMappingDict:nil];
                [records addObject:model];
            }
            [resultSet close];
        }];
    }
    return records;
    
}

//- (BOOL)doesAnyRecordExistForSyncing {
//    BOOL flag = NO;
//    DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:kSyncRecordSent operatorType:SQLOperatorNotEqual andFieldValue:@"hold"];
//    DBCriteria *criteria2 = [[DBCriteria alloc] initWithFieldName:kSyncRecordSent operatorType:SQLOperatorIsNull andFieldValue:nil];
//    
//    NSInteger totalCount =  [self getNumberOfRecordsFromObject:[self tableName] withDbCriteria:@[criteria1,criteria2] andAdvancedExpression:@"(1 OR 2)"];
//    
//    if(totalCount > 0)
//    {
//        flag = YES;
//    }
//    
//    return flag;
//}

//Method for Fix:020834
//-(BOOL)checkIfNonInsertRecordsExist {
//    BOOL recordsExist = NO;
//    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kSyncRecordOperation operatorType:SQLOperatorNotEqual andFieldValue:@"INSERT"];
//
//    NSInteger totalCount =  [self getNumberOfRecordsFromObject:[self tableName] withDbCriteria:@[criteria] andAdvancedExpression:nil];
//
//    if(totalCount > 0) {
//        recordsExist = YES;
//    }
//
//    return recordsExist;
//}
//
////HS 1June
//-(BOOL)checkIfNonAfterSaveInsertRecordsExist {
//    BOOL recordsExist = NO;
//    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kSyncRecordOperation operatorType:SQLOperatorEqual andFieldValue:@"AFTERINSERT"];
//    NSInteger totalCount =  [self getNumberOfRecordsFromObject:[self tableName] withDbCriteria:@[criteria] andAdvancedExpression:nil];
//
//    if(totalCount > 0) {
//        recordsExist = YES;
//    }
//
//    return recordsExist;
//}

//Make the above common function passing operatortype.

//HS 1June ends here
-(NSArray *)getInsertRecordsAsArray {
    DBCriteria *criteria = [[DBCriteria alloc]initWithFieldName:@"operation" operatorType:SQLOperatorEqual andFieldValue:@"INSERT"];
    DBRequestSelect *selectQuery = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:nil whereCriterias:@[criteria] andAdvanceExpression:nil];
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            NSString * query = [selectQuery query];
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while ([resultSet next]) {
                ModifiedRecordModel * model = [[ModifiedRecordModel alloc] init];
                //NSDictionary *dict = [resultSet resultDictionary];
                
                /* converting text into string */
                NSDictionary *dict = [resultSet resultDictionaryWithFieldsAsString];
                [ParserUtility parseJSON:dict toModelObject:model withMappingDict:nil];
                [records addObject:model];
            }
            [resultSet close];
        }];
    }
    return records;
}
//Fix:020834 ends here

@end
