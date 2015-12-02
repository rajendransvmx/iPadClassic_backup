//
//  SuccessiveSyncManager.m
//  ServiceMaxiPad
//
//  Created by Aparna on 31/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "SuccessiveSyncManager.h"
#import "SyncManager.h"
#import "FactoryDAO.h"
#import "ModifiedRecordsDAO.h"
#import "ModifiedRecordModel.h"
#import "TransactionObjectDAO.h"
#import "SFMPageEditHelper.h"
#import "SMXEvent.h"
#import "SFMRecordFieldData.h"
#import "DateUtil.h"
#import "SFMTaskModel.h"

static SuccessiveSyncManager *successiveSyncManager = nil;

@interface SuccessiveSyncManager ()

@property(nonatomic, strong)NSMutableDictionary *succSyncRecords;

@end

@implementation SuccessiveSyncManager

#pragma mark -
#pragma mark - Initialization Methods

- (id)init {

    self = [super init];
    
    if (self != nil) {
        self.succSyncRecords = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+ (SuccessiveSyncManager *)sharedSuccessiveSyncManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      if (successiveSyncManager == nil) {
                          successiveSyncManager = [[SuccessiveSyncManager alloc] init];
                      }
                  }
                  );
    
    return successiveSyncManager;
}

- (BOOL) shouldPerformSyccessiveSync:(NSString *)localId{
    
    @synchronized([self class]){
        
        BOOL isSuccessiveSync = NO;
        /*Succeessive sync is performed only if data sync is in progress and the record is part of the on-going data sync*/
        
        BOOL isSyncInProgress = [[SyncManager sharedInstance] isDataSyncInProgress];
        
        id <ModifiedRecordsDAO>modifiedRecordService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
        BOOL doesExistInModifiedRecordTable = [modifiedRecordService doesRecordExistForId:localId];

        
        id <ModifiedRecordsDAO> heapRecordService = [FactoryDAO serviceByServiceType:ServiceTypeSyncHeap];
        BOOL doesExistInSyncHeapTable = [heapRecordService doesRecordExistForId:localId];

        
        if (isSyncInProgress && (doesExistInModifiedRecordTable || doesExistInSyncHeapTable)) {

            //NSLog(@"Successive sync should trigger");
            isSuccessiveSync = YES;
        }

        return isSuccessiveSync;
    }
}


- (void) updateSuccessiveSyncRecord:(ModifiedRecordModel *)syncRecord{
    
    @synchronized([self class]){
        ModifiedRecordModel *existingSyncRecord = self.succSyncRecords[syncRecord.recordLocalId];
        /*Update the field values with the new values*/
        if (existingSyncRecord == nil) {
            ModifiedRecordModel *successiveSyncModel = [[ModifiedRecordModel alloc] init];
            [self copyModifiedRecordDataFrom:syncRecord toModel:successiveSyncModel];
            successiveSyncModel.recordDictionary = syncRecord.recordDictionary; // C - 28124
            [self.succSyncRecords setObject:successiveSyncModel forKey:syncRecord.recordLocalId];
        }
        else{
            [self copyModifiedRecordDataFrom:syncRecord toModel:existingSyncRecord];
            NSArray *allKeys = [syncRecord.recordDictionary allKeys];
            for (NSString *key in allKeys) {
                [existingSyncRecord.recordDictionary setObject:syncRecord.recordDictionary[key] forKey:key];
            }
        }
        
    }
}


- (void) removeSuccessiveSyncRecordForLocalId:(NSString *)localId{
    @synchronized([self class]){
        
        [self.succSyncRecords removeObjectForKey:localId];
    }
}


- (void) removeSuccessiveSyncRecordForLocalIds:(NSArray *)localIds{
    @synchronized([self class]){
        [self.succSyncRecords removeObjectsForKeys:localIds];
    }
}

- (ModifiedRecordModel *) successiveSyncRecordForLocalId:(NSString *)localId{
    @synchronized([self class]){
        
        return self.succSyncRecords[localId];
    }
}

- (ModifiedRecordModel *) successiveSyncRecordForSfId:(NSString *)sfId{
    
    @synchronized([self class]){
        
        ModifiedRecordModel *syncRecord = nil;
        
        NSArray *allKeys = [self.succSyncRecords allKeys];
        
        for (NSString *localId in allKeys) {
            ModifiedRecordModel *tempModel = [self.succSyncRecords objectForKey:localId];
            if ([tempModel.sfId isEqualToString:sfId]) {
                syncRecord = tempModel;
                break;
            }
        }
        return syncRecord;
    }
}



- (void) doSuccessiveSync{
   
    /*Check whether entry exixts in the respective table*/
    /*If exists make update the values in the table*/
    /*Make entry in the ModifiedRecords table*/
    /*remove from the successive sync records cache*/
    
    @synchronized([self class]){
        //SFMPageEditHelper *editHelper = [[SFMPageEditHelper alloc] init];
        
        NSArray *allLocalIds = [self.succSyncRecords allKeys];
       
        for (NSString *localId in allLocalIds) {
            
            @autoreleasepool {
                ModifiedRecordModel *syncRecord = self.succSyncRecords[localId];
                syncRecord.operation = kModificationTypeUpdate;
                
                id <TransactionObjectDAO> transObjectService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
                /* Check if record exist */
                BOOL isRecordExist =  [transObjectService isRecordExistsForObject:syncRecord.objectName
                                                                 forRecordLocalId:syncRecord.recordLocalId];
                
                NSLog(@"isRecordExist: %d", isRecordExist);
                
                
                if (isRecordExist) {
                    
                    [self updateRecord:syncRecord.recordDictionary
                          inObjectName:syncRecord.objectName
                            andLocalId:syncRecord.recordLocalId ];
                    
                    
                    /*Check for sfid */
                    if ([syncRecord.sfId length] <= 0) {
                        
                        NSString *sfId = [SFMPageEditHelper getSfIdForLocalId:syncRecord.recordLocalId
                                                                   objectName:syncRecord.objectName];
                        if ([sfId length] > 1) {
                            
                            syncRecord.sfId = sfId;
                            
                            id <ModifiedRecordsDAO>modifiedRecordService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
                            [modifiedRecordService saveRecordModel:syncRecord];
                        }
                        [self.succSyncRecords removeObjectForKey:localId];
                    }
                    else
                    {
                        id <ModifiedRecordsDAO>modifiedRecordService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
                        [modifiedRecordService saveRecordModel:syncRecord];
                        [self.succSyncRecords removeObjectForKey:localId];
                    }
                }
            }
        }
    }
}


- (void)resetData {
    @synchronized([self class]){
        [self.succSyncRecords removeAllObjects];
    }
}

- (void)registerForSuccessiveSync:(ModifiedRecordModel *)syncRecord withData:(id)record
{
    @synchronized([self class]){
        
        NSLog(@"shouldPerformSyccessiveSync");
        
        if ([self shouldPerformSyccessiveSync:syncRecord.recordLocalId]) {
            
            if ([record isKindOfClass:[NSDictionary class]]) {
                NSLog(@"Successive sync call");
                
                syncRecord.recordDictionary  = [[NSMutableDictionary alloc]initWithDictionary:record];
            }
            [self updateSuccessiveSyncRecord:syncRecord];
        }
    }
}

/*
- (NSMutableDictionary *) createDictionaryForEvent:(SMXEvent *)event forRecord:(ModifiedRecordModel *)syncRecord
{
    NSMutableDictionary *fieldDictionary = [[NSMutableDictionary alloc]init];
    NSString *startDateString = [DateUtil getDatabaseStringForDate:event.dateTimeBegin];
    NSString *endDateString = [DateUtil getDatabaseStringForDate:event.dateTimeEnd];;
    SFMRecordFieldData *startTimeRecordField = [[SFMRecordFieldData alloc] initWithFieldName:@"StartDateTime" value:startDateString andDisplayValue:startDateString];
    
    SFMRecordFieldData *endTimeRecordField = [[SFMRecordFieldData alloc] initWithFieldName:@"EndDateTime" value:endDateString andDisplayValue:endDateString];
    SFMRecordFieldData *activityTimeRecordField = [[SFMRecordFieldData alloc] initWithFieldName:@"ActivityDateTime" value:startDateString andDisplayValue:startDateString];
    [fieldDictionary setObject:startTimeRecordField forKey:@"StartDateTime"];
    [fieldDictionary setObject:endTimeRecordField forKey:@"EndDateTime"];
    [fieldDictionary setObject:activityTimeRecordField forKey:@"ActivityDateTime"];
    return fieldDictionary;
}
*/
- (BOOL)updateRecord:(NSDictionary *)record inObjectName:(NSString *)objectName andLocalId:(NSString *)localId {
    
    NSMutableDictionary *eachRecord = [[NSMutableDictionary alloc] init];
    
    NSMutableArray *allFields = [[NSMutableArray alloc] init];
    for (NSString *fieldName in record) {
        if ([fieldName isEqualToString:kId]) {
            continue;
        }
        id fieldData = [record objectForKey:fieldName];
        NSString *fieldValue = nil;
        if ([fieldData isKindOfClass:[SFMRecordFieldData class]]) {
            fieldValue = [(SFMRecordFieldData *)fieldData internalValue];
        }
        else
        {
            fieldValue = [record objectForKey:fieldName];
        }
        
        // C -28124
        if (fieldValue == nil) {
            fieldValue = @"";
        }

        if (fieldValue != nil) {
            [eachRecord setObject:fieldValue forKey:fieldName];
        }
        [allFields addObject:fieldName];
    }
    TransactionObjectModel *aModel = [[TransactionObjectModel alloc] initWithObjectApiName:objectName];
    [aModel mergeFieldValueDictionaryForFields:eachRecord];
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kLocalId operatorType:SQLOperatorEqual andFieldValue:localId];
    
    id <TransactionObjectDAO> transObjectService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    return [transObjectService updateEachRecord:eachRecord withFields:allFields withCriteria:@[criteria] withTableName:objectName];
}


-(void)copyModifiedRecordDataFrom:(ModifiedRecordModel *)syncRecord toModel:(ModifiedRecordModel *)successiveSyncModel {
    successiveSyncModel.localId = syncRecord.localId;
    successiveSyncModel.recordLocalId = syncRecord.recordLocalId;
    successiveSyncModel.sfId = syncRecord.sfId;
    successiveSyncModel.recordType = syncRecord.recordType;
    successiveSyncModel.operation = syncRecord.operation;
    successiveSyncModel.objectName = syncRecord.objectName;
    successiveSyncModel.parentObjectName = syncRecord.parentObjectName;
    successiveSyncModel.parentLocalId = syncRecord.parentLocalId;
    successiveSyncModel.recordSent = syncRecord.recordSent;
    successiveSyncModel.webserviceName = syncRecord.webserviceName;
    successiveSyncModel.className = syncRecord.className;
    successiveSyncModel.headerLocalId = syncRecord.headerLocalId;
    successiveSyncModel.requestData = syncRecord.requestData;
    successiveSyncModel.requestId = syncRecord.requestId;
    successiveSyncModel.timeStamp = syncRecord.timeStamp;
    successiveSyncModel.fieldsModified = syncRecord.fieldsModified;
    successiveSyncModel.cannotSendToServer = syncRecord.cannotSendToServer;
    successiveSyncModel.jsonRecord = syncRecord.jsonRecord;
    successiveSyncModel.overrideFlag = syncRecord.overrideFlag;
//    successiveSyncModel.recordDictionary = syncRecord.recordDictionary; // 28124
}

-(ModifiedRecordModel *)getSyncRecordModelFromSuccessiveSyncRecords:(NSString *)localId {
    ModifiedRecordModel *syncRecord = self.succSyncRecords[localId];
    return syncRecord;
}


@end
