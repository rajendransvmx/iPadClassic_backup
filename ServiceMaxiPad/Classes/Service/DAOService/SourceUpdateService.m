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
#import "DateUtil.h"
#import "SVMXSystemConstant.h"
#import "SuccessiveSyncManager.h"
#import "SFMRecordFieldData.h"
#import "SFMPageEditManager.h"

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
    
    NSArray *srcUpdtList = nil;
    if(!srcUpdts.count)
        srcUpdtList = [NSArray array];
    else
        srcUpdtList = [[srcUpdts allValues] objectAtIndex:0];
    
    NSMutableDictionary *recordDictionary = [[NSMutableDictionary alloc] init];
    
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
            
            if([data_type isEqualToString:kSfDTDate])
            {
                newDisplayValue = [DateUtil evaluateDateLiteral:displayValue dataType:data_type];
                NSDate * date = [DateUtil getDateFromDatabaseString:newDisplayValue];
                if (date != nil)
                {
                    newDisplayValue = [DateUtil stringFromDate:date inFormat:kDataBaseDate];
                }
            }
            else if([data_type isEqualToString:kSfDTDateTime])
            {
                newDisplayValue = [DateUtil evaluateDateLiteral:displayValue dataType:data_type];
            }
            else
            {
                newDisplayValue = [SFMPageHelper valueOfLiteral:displayValue dataType:data_type];
            }
            
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
        [recordDictionary setObject:escapedValue?escapedValue:kEmptyString forKey:srcFieldName];
    }
    
    // Defect: 026451
    NSString *sfId = [SFMPageEditHelper getSfIdForLocalId:localId objectName:objectName];
    [recordDictionary setObject:sfId forKey:kId];
    NSDictionary *finalDict = [NSDictionary dictionaryWithDictionary:recordDictionary];
    
    SFMPageEditHelper *editHelper = [[SFMPageEditHelper alloc] init];
    SFMPageEditManager *editManager = [[SFMPageEditManager alloc] init];
    editManager.dataDictionaryAfterModification = [NSMutableDictionary dictionaryWithDictionary:finalDict];
    
    if ([StringUtil isStringEmpty:sfId]) {
        sfId = nil;
    }
    
    NSString *modifiedFieldAsJsonString = [editManager getJsonStringAfterComparisionForObject:objectName recordId:localId sfid:sfId andSettingsFlag:YES];
    
    ModifiedRecordModel * syncRecord = [[ModifiedRecordModel alloc] init];
    syncRecord.recordLocalId = localId;
    syncRecord.objectName = objectName;
    syncRecord.timeStamp = [DateUtil getDatabaseStringForDate:[NSDate date]];
    
    id <TransactionObjectDAO> transObjectService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    /* Check if record exist */
    BOOL isRecordExist =  [transObjectService isRecordExistsForObject:objectName forRecordLocalId:localId];
    if (isRecordExist && ![StringUtil isStringEmpty:sfId]) {
        
        syncRecord.operation = kModificationTypeUpdate;
        recordUpdatedSuccessFully = [editHelper updateFinalRecord:finalDict inObjectName:objectName andLocalId:localId];
    }
    else {
        syncRecord.operation = kModificationTypeInsert;
        recordUpdatedSuccessFully = [editHelper updateFinalRecord:finalDict inObjectName:objectName andLocalId:localId];
    }
    
    syncRecord.recordType = kRecordTypeMaster;
    syncRecord.sfId = sfId;
    
    BOOL canUpdate = YES;
    
    if([syncRecord.operation isEqualToString:kModificationTypeUpdate]) {
        if (![StringUtil isStringEmpty:modifiedFieldAsJsonString]) {
            syncRecord.fieldsModified = modifiedFieldAsJsonString;
        }
        else if (editManager.isfieldMergeEnabled && ![StringUtil isStringEmpty:sfId]) {
            canUpdate = NO;
        }
    }
    
    /*after save  make an entry in trailer table*/
    if (recordUpdatedSuccessFully && canUpdate) {
        id <ModifiedRecordsDAO>modifiedRecordService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
        BOOL doesExist =   [modifiedRecordService doesRecordExistForId:localId];
        if (!doesExist) {
            [modifiedRecordService saveRecordModel:syncRecord];
        }
        else {
            if (editManager.isfieldMergeEnabled && ![StringUtil isStringEmpty:sfId] && [syncRecord.operation isEqualToString:kModificationTypeUpdate]) {
                [modifiedRecordService updateFieldsModifed:syncRecord];
            }
        }
        [[SuccessiveSyncManager sharedSuccessiveSyncManager] registerForSuccessiveSync:syncRecord withData:finalDict];
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
