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

            NSLog(@"Successive sync should trigger");
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
            [self.succSyncRecords setObject:syncRecord forKey:syncRecord.recordLocalId];
        }
        else{
            NSArray *allKeys = [syncRecord.recordDictionary allKeys];
            for (NSString *key in allKeys) {
                
                NSLog(@"syncRecord.recordDictionary[key] %@",syncRecord.recordDictionary[key]);
                
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


- (ModifiedRecordModel *) successiveSyncRecordForLocalId:(NSString *)localId{
    @synchronized([self class]){
        
        return self.succSyncRecords[localId];
    }
}

- (ModifiedRecordModel *) successiveSyncRecordForSfId:(NSString *)sfId{
    
    @synchronized([self class]){
        
        NSArray *allLocalIds = [self.succSyncRecords allKeys];
        ModifiedRecordModel *syncRecord = nil;
        
        for (int i=0; i<[allLocalIds count]; i++) {
            
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
        SFMPageEditHelper *editHelper = [[SFMPageEditHelper alloc] init];

        NSArray *allLocalIds = [self.succSyncRecords allKeys];
        for (NSString *localId in allLocalIds) {
            
            ModifiedRecordModel *syncRecord = self.succSyncRecords[localId];
            syncRecord.syncType = kModificationTypeUpdate;
            
            id <TransactionObjectDAO> transObjectService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
            /* Check if record exist */
            BOOL isRecordExist =  [transObjectService isRecordExistsForObject:syncRecord.objectName forRecordLocalId:syncRecord.recordLocalId];
            
            if (isRecordExist) {
                [editHelper updateRecord:syncRecord.recordDictionary
                                           inObjectName:syncRecord.objectName
                                             andLocalId:syncRecord.recordLocalId ];
                /*Check for sfid */
                if ([syncRecord.sfId length]<=0) {
                    NSString *sfId = [SFMPageEditHelper getSfIdForLocalId:syncRecord.recordLocalId objectName:syncRecord.objectName];
                    if ([sfId length]>1) {
                        syncRecord.sfId = sfId;
                        
                        id <ModifiedRecordsDAO>modifiedRecordService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
                        [modifiedRecordService saveRecordModel:syncRecord];
                        [self.succSyncRecords removeObjectForKey:localId];
                    }
                }
                else{
                    
                    id <ModifiedRecordsDAO>modifiedRecordService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
                    [modifiedRecordService saveRecordModel:syncRecord];
                    [self.succSyncRecords removeObjectForKey:localId];

                }
                
            }
        }
    }
}


- (void) removeAllRecords{
    @synchronized([self class]){
        [self.succSyncRecords removeAllObjects];
    }
}


@end
