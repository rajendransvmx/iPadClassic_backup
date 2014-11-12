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
#import "DBRequestUpdate.h"
#import "SFSourceUpdateModel.h"
#import "SFMPageHelper.h"
#import "FactoryDAO.h"
#import "SFObjectFieldDAO.h"
#import "ModifiedRecordsDAO.h"
#import "ModifiedRecordModel.h"
#import "TransactionObjectModel.h"
#import "TransactionObjectDAO.h"
#import "SFMPageEditHelper.h"
#import "StringUtil.h"

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

- (void)updateTargetObjectsForSmartDocProcess:(NSString *)processId forObject:(NSString*)objectName andLocalId:(NSString*)localId
{
    BOOL recordUpdatedSuccessFully = NO;
    
    NSDictionary *srcUpdts = [self getSourceUpdateRecordsforProcessId:processId];
    NSArray *srcUpdtList = [[srcUpdts allValues] objectAtIndex:0];
    
    for (SFSourceUpdateModel *model in srcUpdtList)
    {
        NSString *srcFieldName = model.sourceFieldName;
        NSString *displayValue = model.displayValue;
        NSString *action = model.action;
        
        NSString *newDisplayValue = nil;
        
        if ([action isEqualToString:@"Set"])
        {
            id objDefSrv = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectField];
            
            DBCriteria * criteria1 = [[DBCriteria alloc] initWithFieldName:kobjectName operatorType:SQLOperatorEqual andFieldValue:objectName];
            DBCriteria * criteria2 = [[DBCriteria alloc] initWithFieldName:kfieldname operatorType:SQLOperatorEqual andFieldValue:srcFieldName];
            // @[@"type",@"referenceTo"]
            NSArray *fieldInfoList = [objDefSrv fetchSFObjectFieldsInfoByFields:@[@"type",@"referenceTo"] andCriteriaArray:@[criteria1, criteria2] advanceExpression:@"(1 AND 2)"];
            
            SFObjectFieldModel *objFldModel = ((fieldInfoList.count != 0) ? [fieldInfoList objectAtIndex:0] : nil);
            NSString * data_type = [objFldModel.type lowercaseString];
            
            newDisplayValue = [SFMPageHelper valueOfLiteral:displayValue dataType:data_type];
            if (nil == newDisplayValue)
            {
                newDisplayValue = [NSString stringWithString:displayValue];
            }
            
        }
        else if([action isEqualToString:@"Increase"])
        {
            newDisplayValue = [self getValueForField:srcFieldName objectName:objectName recordId:localId];
            float newValue = [newDisplayValue floatValue]+[displayValue floatValue];
            newDisplayValue = [NSString stringWithFormat:@"%f",newValue];
        }
        else if([action isEqualToString:@"Decrease"])
        {
            newDisplayValue = [self getValueForField:srcFieldName objectName:objectName recordId:localId];
            float newValue = [newDisplayValue floatValue]-[displayValue floatValue];
            newDisplayValue = [NSString stringWithFormat:@"%f",newValue];
        }
        
        NSString *escapedValue = [newDisplayValue stringByReplacingOccurrencesOfString:@"'" withString:@"''"];

        id <TransactionObjectDAO>  transObj = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
        
        DBCriteria *crit = [[DBCriteria alloc] initWithFieldName:@"localId" operatorType:SQLOperatorEqual andFieldValue:localId];
        recordUpdatedSuccessFully = [transObj updateEachRecord:[NSDictionary dictionaryWithObject:escapedValue forKey:srcFieldName]
                                                    withFields:[NSArray arrayWithObject:srcFieldName]
                                                  withCriteria:[NSArray arrayWithObject:crit]
                                                 withTableName:objectName];
        
    }
    
    // Modify inserted records into modified table
    /*after save  make an entry in trailer table*/
    if (recordUpdatedSuccessFully)
    {
        id <ModifiedRecordsDAO>modifiedRecordService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
        BOOL doesExist =   [modifiedRecordService doesRecordExistForId:localId];
        if (!doesExist)
        {
            ModifiedRecordModel * syncRecord = [[ModifiedRecordModel alloc] init];
            syncRecord.recordLocalId = localId;
            syncRecord.objectName = objectName;
            syncRecord.recordType = kRecordTypeMaster;
            syncRecord.operation = kModificationTypeUpdate;
            
            syncRecord.sfId = [SFMPageEditHelper getSfIdForLocalId:localId objectName:objectName];
            
            [modifiedRecordService saveRecordModel:syncRecord];
        }
    }

}

- (NSString *)getValueForField:(NSString *)fieldName objectName:(NSString *)objectName recordId:(NSString *)localId
{
    __block NSString * fieldValue = @"";
    
    DBCriteria *dbcrit1 = [[DBCriteria alloc] initWithFieldName:@"localId" operatorType:SQLOperatorEqual andFieldValue:localId];
    DBCriteria *dbcrit2 = [[DBCriteria alloc] initWithFieldName:@"Id" operatorType:SQLOperatorEqual andFieldValue:localId];
    DBRequestSelect *selectReq = [[DBRequestSelect alloc] initWithTableName:objectName
                                                              andFieldNames:@[fieldName]
                                                             whereCriterias:@[dbcrit1, dbcrit2]
                                                       andAdvanceExpression:@"(1 OR 2)"];
    
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            NSString * query = [selectReq query];
            
            SQLResultSet *resultSet = [db executeQuery:query];
            
            if ([resultSet next])
            {
                NSDictionary * dict = [resultSet resultDictionary];
                fieldValue = [dict objectForKey:fieldName];
            }
            
            [resultSet close];
        }];
    }
    
    return fieldValue;
}


@end
