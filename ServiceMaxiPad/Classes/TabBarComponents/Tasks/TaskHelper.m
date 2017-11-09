//
//  TaskHelper.m
//  ServiceMaxMobile
//
//  Created by Pushpak on 02/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "TaskHelper.h"
#import "TransactionObjectService.h"
#import "FactoryDAO.h"
#import "DBRequest.h"
#import "DBRequestInsert.h"
#import "AppManager.h"
#import "DBRequestDelete.h"
#import "ModifiedRecordModel.h"
#import "ModifiedRecordsDAO.h"
#import "SyncManager.h"
#import "DatabaseConstant.h"
#import "DateUtil.h"
#import "StringUtil.h"
#import "SyncHeapDAO.h"
#import "SuccessiveSyncManager.h"
#import "SFMPageEditHelper.h"
#import "SNetworkReachabilityManager.h"
#import "SFMPageEditManager.h"
#import "CustomActionsDAO.h"
NSString *const kTaskPriorityLow = @"Low";
NSString *const kTaskPriorityNormal = @"Normal";
NSString *const kTaskPriorityHigh = @"High";

@implementation TaskHelper

+ (NSArray *)fetchAllTask
{
    NSMutableArray *taskData = [NSMutableArray new];
    
    id <TransactionObjectDAO> transactionService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    /*
    DBCriteria *criteria = [[DBCriteria alloc]initWithFieldName:@"ActivityDate"
                                                   operatorType:SQLOperatorEqual
                                                  andFieldValue:[DateUtil stringFromDate:[NSDate date] inFormat:kDateFormatTypeOnlyDate]];
    */
    NSArray *dataArray =  [transactionService fetchDataForObject:@"Task" fields:[self getTaskFields] expression:nil criteria:nil];
    
    for (TransactionObjectModel *model in dataArray) {
        
        if (model != nil) {
            
            NSDictionary *values = [model getFieldValueDictionaryForFields:[self getTaskFields]];
            
            if ([StringUtil isStringEmpty:[values objectForKey:@"ActivityDate"]]) {
                continue;
            }
            
            SFMTaskModel *taskModel = [[SFMTaskModel alloc] initWithLocalId:[values objectForKey:kLocalId]
                                                                description:[values objectForKey:@"Subject"]
                                                                   priority:[values objectForKey:@"Priority"]
                                                                   recordId:[values objectForKey:kId]
                                                                createdDate:[DateUtil dateFromString:[values objectForKey:@"ActivityDate"] inFormat:kDateFormatTypeOnlyDate]];
            [taskData addObject:taskModel];
        }
    }
    return taskData;
}

+ (void)addNewTask:(SFMTaskModel *)model
{
    NSString *uniqueId = [AppManager generateUniqueId];
    
    if ([uniqueId length] > 0) {
        
        model.localID = uniqueId;
        
        id <TransactionObjectDAO> transactionService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
        
        NSDictionary *dataDict = [self getDataDict:model];
        NSArray *models = @[[self getTransactiomModel:dataDict]];
        
        BOOL status = [transactionService insertTransactionObjects:models andDbRequest:[self getInsertQuery:model]];
        if (status) {
            
            id modifiedRecordService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
            if ([modifiedRecordService conformsToProtocol:@protocol(ModifiedRecordsDAO)]) {
                
                ModifiedRecordModel *modifiedRecord = [[ModifiedRecordModel alloc]init];
                modifiedRecord.objectName = @"Task";
                modifiedRecord.recordLocalId = model.localID;
                modifiedRecord.operation = kModificationTypeInsert;
                modifiedRecord.recordType = kRecordTypeMaster;
                modifiedRecord.timeStamp = [DateUtil getDatabaseStringForDate:[NSDate date]];
                
                BOOL saveStatus = [modifiedRecordService saveRecordModel:modifiedRecord];
                if (saveStatus) {
                    [self performSelectorInBackground:@selector(triggerDataSync) withObject:nil];
                }
            }
        }
    }
}

+ (void)updateTask:(SFMTaskModel *)model
{
    if (model != nil && [model.localID length] > 0)
    {
        DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kLocalId operatorType:SQLOperatorEqual andFieldValue:model.localID];
        
        id <TransactionObjectDAO> transactionService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
       
        NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionaryWithDictionary:[self getDataDict:model]];
        for (NSString * key in [dataDictionary allKeys]) {
            SFMRecordFieldData *recordFieldData = [[SFMRecordFieldData alloc]init];
            recordFieldData.name =  key;
            recordFieldData.internalValue = [dataDictionary objectForKey:key];
            [dataDictionary setObject:recordFieldData forKey:key];
        }
        
        SFMPageEditManager *pageEditManager = [[SFMPageEditManager alloc]init];
        pageEditManager.dataDictionaryAfterModification = dataDictionary;

        NSString *modifiedFieldAsJson = [pageEditManager getJsonStringAfterComparisionForObject:@"Task" recordId:model.localID sfid:model.sfId andSettingsFlag:YES];
        BOOL status = [transactionService updateEachRecord:[self getDataDict:model]
                                                withFields:[self getTaskFields]
                                              withCriteria:[NSArray arrayWithObject:criteria]
                                             withTableName:@"Task"];
        

        
        ModifiedRecordModel *modifiedRecord = [[ModifiedRecordModel alloc]init];
        modifiedRecord.objectName = @"Task";
        modifiedRecord.recordLocalId = model.localID;
        modifiedRecord.sfId = model.sfId;
        modifiedRecord.operation = kModificationTypeUpdate;
        modifiedRecord.recordType = kRecordTypeMaster;
        modifiedRecord.timeStamp = [DateUtil getDatabaseStringForDate:[NSDate date]];
        
        BOOL canUpdate = YES;
        if ([modifiedRecord.operation isEqualToString:kModificationTypeUpdate]) {
            
            if (modifiedFieldAsJson != nil) {
                modifiedRecord.fieldsModified = modifiedFieldAsJson;
            }
            else{
                if (pageEditManager.isfieldMergeEnabled) {
                    canUpdate = NO;
                }
            }
        }
        
        if (status && canUpdate) {
            if (![StringUtil isStringEmpty:model.sfId]) {
                
                id modifiedRecordService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
                if ([modifiedRecordService conformsToProtocol:@protocol(ModifiedRecordsDAO)]) {
                    if (![modifiedRecordService doesRecordExistForId:model.sfId]) {

                        BOOL saveStatus = [modifiedRecordService saveRecordModel:modifiedRecord];
                        
                        if (saveStatus) {
                            [[SuccessiveSyncManager sharedSuccessiveSyncManager] registerForSuccessiveSync:modifiedRecord withData:[self getDataDict:model]];
                            [self performSelectorInBackground:@selector(triggerDataSync) withObject:nil];
                        }
                    } else {
                        [modifiedRecordService updateFieldsModifed:modifiedRecord];
                    }
                }
            }
            else {
                //Since we don't have sfid yet we just perform data sync.
                [self performSelectorInBackground:@selector(triggerDataSync) withObject:nil];
            }
        }
    }
    
}

+ (void)triggerDataSync
{
   [[SyncManager sharedInstance] performDataSyncIfNetworkReachable];
}


+ (void)deleteTask:(SFMTaskModel *)model
{
    if ([model.localID length] > 0) {
        
        DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kLocalId operatorType:SQLOperatorEqual andFieldValue:model.localID];
        
        DBRequestDelete *delete = [[DBRequestDelete alloc] initWithTableName:@"Task" whereCriteria:[NSArray arrayWithObject:criteria] andAdvanceExpression:nil];
        
        id  transactionService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
        
        if ([transactionService conformsToProtocol:@protocol(TransactionObjectDAO)]) {
            BOOL status = [transactionService executeStatement:[delete query]];
            if (status) {
                id modifiedRecordService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
                id syncHeapService = [FactoryDAO serviceByServiceType:ServiceTypeSyncHeap];
                if ([modifiedRecordService conformsToProtocol:@protocol(ModifiedRecordsDAO)]) {
                    [modifiedRecordService deleteRecordsForRecordLocalIds:@[model.localID]];
                }
                
                id customActionRequestService = [FactoryDAO serviceByServiceType:ServiceTypeCustomActionRequestParams];
                if ([customActionRequestService conformsToProtocol:@protocol(CustomActionsDAO)]){
                    [customActionRequestService deleteRecordsForRecordLocalIds:@[model.localID]];
                    
                }
                
                // delete conflict entry if task is deleted..
                SFMPageEditHelper *editHelper = [[SFMPageEditHelper alloc] init];
                [editHelper deleteRecordWithIds:@[model.localID] fromObjectName:kSyncErrorConflictTableName andCriteriaFieldName:kLocalId];

                if (![StringUtil isStringEmpty:model.sfId]) {
                    
                    if ([modifiedRecordService conformsToProtocol:@protocol(ModifiedRecordsDAO)] && [syncHeapService conformsToProtocol:@protocol(SyncHeapDAO)]) {
                        
                        [syncHeapService deleteRecordsForSfIds:@[model.sfId] forParallelSyncType:nil];
                        
                        // delete conflict entry if task is deleted..
                        [editHelper deleteRecordWithIds:@[model.sfId] fromObjectName:kSyncErrorConflictTableName andCriteriaFieldName:kSyncRecordSFId];
                        
                        ModifiedRecordModel *modifiedRecord = [[ModifiedRecordModel alloc]init];
                        modifiedRecord.objectName = @"Task";
                        modifiedRecord.recordLocalId = model.localID;
                        modifiedRecord.sfId = model.sfId;
                        modifiedRecord.operation = kModificationTypeDelete;
                        modifiedRecord.recordType = kRecordTypeMaster;
                        modifiedRecord.timeStamp = [DateUtil getDatabaseStringForDate:[NSDate date]];
                        
                        BOOL saveStatus = [modifiedRecordService saveRecordModel:modifiedRecord];
                        if (saveStatus) {
                            [self performSelectorInBackground:@selector(triggerDataSync) withObject:nil];
                        }
                    }
                }
            }
            
        }
    }
}

+ (NSString *)getInsertQuery:(SFMTaskModel *)model
{
    NSMutableArray *fields = [NSMutableArray arrayWithArray:[self getTaskFields]];
    DBRequestInsert *insert = [[DBRequestInsert alloc] initWithTableName:@"Task" andFieldNames:fields];
    
    return [insert query];
}

+ (TransactionObjectModel *)getTransactiomModel:(NSDictionary *)dataDict
{
    TransactionObjectModel *transactionModel = [[TransactionObjectModel alloc] initWithObjectApiName:@"Task"];
    [transactionModel mergeFieldValueDictionaryForFields:dataDict];
    return transactionModel;
}

+ (NSDictionary *)getDataDict:(SFMTaskModel *)model
{
    if (model != nil){
        [self checkAndUpdateTaskModel:model];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:0];
        
        [dict setObject:model.taskDescription forKey:@"Subject"];
        [dict setObject:model.priority forKey:@"Priority"];
        [dict setObject:[DateUtil stringFromDate:model.date inFormat:kDateFormatTypeOnlyDate] forKey:@"ActivityDate"];
        [dict setObject:model.localID forKey:kLocalId];
        [dict setObject:model.sfId forKey:kId];
        return dict;
    }
    return nil;
}

+ (void)checkAndUpdateTaskModel:(SFMTaskModel *)model
{
    model.taskDescription = (model.taskDescription) != nil? model.taskDescription:@"";
    model.priority = (model.priority) != nil? model.priority:@"";
    model.date = (model.date) != nil? model.date:[NSDate date];
    model.sfId = (model.sfId) != nil? model.sfId:@"";
    model.localID = (model.localID) != nil? model.localID:@"";
    
}
+ (NSArray *)getTaskFields
{
    return @[@"Subject", @"Priority", kLocalId, kId, @"ActivityDate"];
}

@end
