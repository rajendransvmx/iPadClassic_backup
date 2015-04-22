//
//  OneCallDataSyncHelper.m
//  ServiceMaxMobile
//
//  Created by shravya on 11/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "OneCallDataSyncHelper.h"
#import "TransactionObjectService.h"
#import "SyncRecordHeapModel.h"
#import "SyncHeapService.h"
#import "PlistManager.h"
#import "ModifiedRecordModel.h"
#import "DBRequestDelete.h"
#import "ModifiedRecordsService.h"
#import "CommonServices.h"
#import "StringUtil.h"
#import "CustomerOrgInfo.h"
#import "FactoryDAO.h"
#import "SuccessiveSyncManager.h"

@interface OneCallDataSyncHelper()
@property(nonatomic,strong)CommonServices *commonServices;
@end

@implementation OneCallDataSyncHelper

- (id)init {
    self = [super init];
    if (self != nil) {
        self.commonServices = [[CommonServices alloc] init];
    }
    return self;
}
- (void)updateSfId:(NSString *)sfId
       withLocalId:(NSString *)localId
     andObjectName:(NSString *)objectName {
    
    DBField *aField = [[DBField alloc] initWithFieldName:kId andTableName:objectName];
    DBCriteria *aDbcriteria = [[DBCriteria alloc] initWithFieldName:kLocalId operatorType:SQLOperatorEqual andFieldValue:localId];
    TransactionObjectService *service = [[TransactionObjectService alloc] init];
    [service updateField:aField withValue:sfId andDbCriteria:aDbcriteria];
    
}

- (BOOL)insertIdsIntoSyncHeapTable:(NSDictionary *)objectMapIds {
    
    SyncHeapService *service = [[SyncHeapService alloc] init];
    BOOL allInsertionSuccessfull = NO;
    for (NSString *objectName in objectMapIds) {
         NSMutableArray *syncHeapRecords = [[NSMutableArray alloc] init];
         NSDictionary *allIdsDictionary = [objectMapIds objectForKey:objectName];
        
        for (NSString *eachSfid in allIdsDictionary) {
            SyncRecordHeapModel *model = [[SyncRecordHeapModel alloc] init];
            model.objectName = objectName;
            model.sfId = eachSfid;
            model.localId = [objectMapIds objectForKey:eachSfid];
            model.syncFlag = false;
            
            [syncHeapRecords addObject:model];
        }
        
        if ([syncHeapRecords count] > 0) {
           allInsertionSuccessfull =  [service saveRecordModels:syncHeapRecords];
        }
        
    }
   return allInsertionSuccessfull;
}

- (void)deleteSyncRecordsFromSyncModificationTableWithIndex:(NSDictionary *)deletedIdsDict
                             withModificationType:(NSString *)modificationType {
    
    @synchronized([self class]){
        @autoreleasepool {
            NSArray * objectsArray = [deletedIdsDict allKeys];
            NSInteger lastIndex = [PlistManager getLastLocalIdFromDefaults];
            
            NSString * searchField = ([modificationType isEqualToString:kModificationTypeInsert])?@"recordLocalId":@"sfId";
            
            for(NSString * eachObject in objectsArray)
            {
                if([eachObject length] == 0)
                {
                    continue;
                }
                NSArray * recordIds = [deletedIdsDict objectForKey:eachObject];
                
                
                DBCriteria *aCriteria1 = [[DBCriteria alloc] initWithFieldName:kLocalId operatorType:SQLOperatorLessThanEqualTo andFieldValue: [[NSString alloc] initWithFormat:@"%ld",(long)lastIndex]];
                DBCriteria *aCriteria2 = [[DBCriteria alloc] initWithFieldName:@"operation" operatorType:SQLOperatorEqual andFieldValue:modificationType];
                 DBCriteria *aCriteria3 = [[DBCriteria alloc] initWithFieldName:searchField operatorType:SQLOperatorIn andFieldValues:recordIds];
                
                DBRequestDelete *deleteRequest = [[DBRequestDelete alloc] initWithTableName:kModifiedRecords whereCriteria:@[aCriteria1,aCriteria2,aCriteria3] andAdvanceExpression:@"(1 and 2 and 3)"];
                
               
                [self.commonServices executeStatement:[deleteRequest query]];
            }
        }
    }
}

- (void)deleteConflictRecordsFromSuccessiveSyncEntry:(NSDictionary *)deletedIdsDict
                                withModificationType:(NSString *)modificationType
{
    @synchronized([self class]){
         @autoreleasepool {
             NSArray * objectsArray = [deletedIdsDict allKeys];
             for(NSString * eachObject in objectsArray)
             {
                 if([eachObject length] == 0)
                 {
                     continue;
                 }
                 NSArray * recordIds = [deletedIdsDict objectForKey:eachObject];
                 
                 NSArray *localIds = nil;
                 
                 if ([modificationType isEqualToString:kModificationTypeInsert]) {
                    localIds = recordIds;
                 }
                 else {
                     localIds = [self getLocalIdsForSfId:recordIds objectName:eachObject];
                 }
                 if ([localIds count] >0) {
                     [[SuccessiveSyncManager sharedSuccessiveSyncManager] removeSuccessiveSyncRecordForLocalIds:localIds];
                 }
             }
         }
    }
}

- (NSArray *)getLocalIdsForSfId:(NSArray *)recordIds objectName:(NSString *)objectName
{
    @synchronized([self class]){
        @autoreleasepool {
            
            NSMutableArray *ids = [NSMutableArray new];
            
            id <TransactionObjectDAO> transObjectService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
            
            for (NSString *recordId in recordIds) {
                if ([recordId length] < 20) {
                    
                    TransactionObjectModel *model = [transObjectService getLocalIDForObject:objectName recordId:recordId];
                    
                    if ([[model valueForField:kLocalId] length] > 0) {
                        [ids addObject:[model valueForField:kLocalId]];
                    }
                }
                else {
                    if ([recordId length] > 0) {
                        [ids addObject:recordId];
                    }
                }
            }
            return ids;
        }
    }
    return nil;
}

- (BOOL)deleteRecordIds:(NSArray *)recordIds fromObject:(NSString *)objectName {
    DBCriteria *aCriteria1 = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorIn andFieldValues:recordIds];
    DBRequestDelete *deleteRequest = [[DBRequestDelete alloc] initWithTableName:objectName whereCriteria:@[aCriteria1] andAdvanceExpression:nil];
    return  [self.commonServices executeStatement:[deleteRequest query]];
}

- (BOOL)deleteAllExceptRecordIds:(NSArray *)recordIds fromObject:(NSString *)objectName {
    DBCriteria *aCriteria1 = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorNotIn andFieldValues:recordIds];
    DBRequestDelete *deleteRequest = [[DBRequestDelete alloc] initWithTableName:objectName whereCriteria:@[aCriteria1] andAdvanceExpression:nil];
    return  [self.commonServices executeStatement:[deleteRequest query]];
}

- (void)deleteFromAllTable:(NSDictionary *)objectNameAndIds {
    @synchronized([self class]) {
        @autoreleasepool {
            [self deleteIdsFromRespectiveTable:objectNameAndIds];
            [self deleteIdsFromSyncHeapAndModifiedRecordsTable:objectNameAndIds];
        }
    }
}

- (void)deleteIdsFromRespectiveTable:(NSDictionary *)objectNameAndIds {
    
    NSArray *allKeys =  [objectNameAndIds allKeys];
    for (NSString *objectName in allKeys) {
        
        NSMutableDictionary *someDictionary = [objectNameAndIds objectForKey:objectName];
        NSArray *idsArray  = [someDictionary allKeys];
        if ([idsArray count] <= 0) {
            continue;
        }
        /*Prepare ids query*/
        [self deleteRecordIds:idsArray fromObject:objectName];;
    }
}

- (void)deleteIdsFromSyncHeapAndModifiedRecordsTable:(NSDictionary *)objectDictionary {
    @autoreleasepool {
        NSMutableArray *idsArray = [[NSMutableArray alloc] init];
        for (NSString *objectName in [objectDictionary allKeys]) {
            
            NSMutableDictionary *someDictionary = [objectDictionary objectForKey:objectName];
            NSArray *idsArrayNew  = [someDictionary allKeys ];
            [idsArray addObjectsFromArray:idsArrayNew];
        }
        
        if ([idsArray count] <= 0) {
            return;
        }
        
        /*Prepare ids query*/
        DBCriteria *aCriteria1 = [[DBCriteria alloc] initWithFieldName:@"sfId" operatorType:SQLOperatorIn andFieldValues:idsArray];
        
        NSArray *criteriaArray = @[aCriteria1];
        
        DBRequestDelete *deleteRequest = [[DBRequestDelete alloc] initWithTableName:@"Sync_Records_Heap" whereCriteria:criteriaArray andAdvanceExpression:nil];
        [self.commonServices executeStatement:[deleteRequest query]];
        
        
         deleteRequest = [[DBRequestDelete alloc] initWithTableName:kModifiedRecords whereCriteria:@[aCriteria1] andAdvanceExpression:nil];
        [self.commonServices executeStatement:[deleteRequest query]];
        
        
        deleteRequest = [[DBRequestDelete alloc] initWithTableName:kSyncErrorConflictTableName whereCriteria:@[aCriteria1] andAdvanceExpression:nil];
        [self.commonServices executeStatement:[deleteRequest query]];

    }
    
}

- (void)deleteAllEventExceptTheseIdsFromSyncHeapAndModifiedRecordsTable:(NSDictionary *)objectDictionary {
    @autoreleasepool {
        NSMutableArray *idsArray = [[NSMutableArray alloc] init];
        for (NSString *objectName in [objectDictionary allKeys]) {
            
            if ([objectName isEqualToString:kEventObject]) {
                NSMutableDictionary *someDictionary = [objectDictionary objectForKey:objectName];
                NSArray *idsArrayNew  = [someDictionary allKeys ];
                [idsArray addObjectsFromArray:idsArrayNew];
            }
        }
        
        if ([idsArray count] <= 0) {
            return;
        }
        
        /*Prepare ids query*/
        DBCriteria *aCriteria1 = [[DBCriteria alloc] initWithFieldName:@"sfId" operatorType:SQLOperatorNotIn andFieldValues:idsArray];
        DBCriteria *aCriteria2 = [[DBCriteria alloc] initWithFieldName:@"objectName" operatorType:SQLOperatorEqual andFieldValue:kEventObject];
        
        NSArray *criteriaArray = @[aCriteria1,aCriteria2];
        
        DBRequestDelete *deleteRequest = [[DBRequestDelete alloc] initWithTableName:@"Sync_Records_Heap" whereCriteria:criteriaArray andAdvanceExpression:nil];
        [self.commonServices executeStatement:[deleteRequest query]];
        
        
        deleteRequest = [[DBRequestDelete alloc] initWithTableName:kModifiedRecords whereCriteria:criteriaArray andAdvanceExpression:nil];
        [self.commonServices executeStatement:[deleteRequest query]];
    }
    
}


- (BOOL)insertDCRecordIdsintoSyncHeapTable:(NSDictionary *)objectNameAndIds
                           andResponseType:(NSString *)responseType {
    
    SyncHeapService *service = [[SyncHeapService alloc] init];
    BOOL allInsertionSuccessfull = NO;
    for (NSString *objectName in objectNameAndIds) {
        NSMutableArray *syncHeapRecords = [[NSMutableArray alloc] init];
        NSDictionary *allIdsDictionary = [objectNameAndIds objectForKey:objectName];
        
        for (NSString *eachSfid in allIdsDictionary) {
            SyncRecordHeapModel *model = [[SyncRecordHeapModel alloc] init];
            model.objectName = objectName;
            model.sfId = eachSfid;
            model.syncFlag = false;
            model.syncResponseType = responseType;
             [syncHeapRecords addObject:model];
        }
        
        if ([syncHeapRecords count] > 0) {
            allInsertionSuccessfull =  [service saveRecordModels:syncHeapRecords];
        }
        
    }
    return allInsertionSuccessfull;
    
}

- (void)purgeEventsFromServer:(NSDictionary *)objectNameAndIds {
    [self deleteEventsFromEventTable:objectNameAndIds];
    [self deleteAllEventExceptTheseIdsFromSyncHeapAndModifiedRecordsTable:objectNameAndIds];
}

- (BOOL)deleteEventsFromEventTable:(NSDictionary *)objectNameAndIds {
    NSArray *allKeys =  [objectNameAndIds allKeys];
    for (NSString *objectName in allKeys) {
        
        if ([objectName isEqualToString:kEventObject]) {
            NSMutableDictionary *someDictionary = [objectNameAndIds objectForKey:objectName];
            NSArray *idsArray  = [someDictionary allKeys];
            if ([idsArray count] <= 0) {
                continue;
            }
            
            return [self deleteAllExceptRecordIds:idsArray fromObject:objectName];
        }
    }
    return YES;
}

- (NSArray *)getIdsFromSyncHeapTableForObjectName:(NSString *)objectName andEventType:(NSString *)eventType {
    @synchronized([self class]){
          NSMutableArray *sfIdsArray = [[NSMutableArray alloc] init];
        @autoreleasepool {
            DBCriteria *aDbcriteria1 = [[DBCriteria alloc] initWithFieldName:@"objectName" operatorType:SQLOperatorEqual andFieldValue:objectName];
            DBCriteria *aDbcriteria2 = [[DBCriteria alloc] initWithFieldName:@"syncResponseType" operatorType:SQLOperatorEqual andFieldValue:eventType]
            ;
            NSArray *criteriaArray =  @[aDbcriteria1,aDbcriteria2];
            DBRequestSelect *selectRequest = [[DBRequestSelect alloc] initWithTableName:@"Sync_Records_Heap" andFieldNames:@[@"sfId"] whereCriterias:criteriaArray andAdvanceExpression:nil];
            [selectRequest setDistinctRowsOnly];
            NSArray *allRecords = nil;
            SyncHeapService *service = [[SyncHeapService alloc] init];
            if ([service conformsToProtocol:@protocol(SyncHeapDAO)]) {
                allRecords =  [service getRecordsFromQuery:[selectRequest query]];
            }
            
            for (SyncRecordHeapModel *heapModel in allRecords) {
                if (![StringUtil isStringEmpty:heapModel.sfId] ) {
                    [sfIdsArray addObject:heapModel.sfId];
                }
            }
        }
        return sfIdsArray;
    }
}

- (void)deleteIdsFromSyncHeapForResponseType:(NSString *)responseType {
    
    @autoreleasepool {
        DBCriteria *aCriteria1 = [[DBCriteria alloc] initWithFieldName:@"syncResponseType" operatorType:SQLOperatorEqual andFieldValue:responseType];
        
        NSArray *criteriaArray = @[aCriteria1];
        
        DBRequestDelete *deleteRequest = [[DBRequestDelete alloc] initWithTableName:@"Sync_Records_Heap" whereCriteria:criteriaArray andAdvanceExpression:nil];
        [self.commonServices executeStatement:[deleteRequest query]];
      
    }
}
- (BOOL)deleteAllEventsOfTheLoggedInUser {
    NSString *ownerId = [ self getUserIdForLoggedInUser];
    if (ownerId != nil) {
        
        DBCriteria *aCriteria1 = [[DBCriteria alloc] initWithFieldName:kEventOwnerId   operatorType:SQLOperatorEqual andFieldValue:ownerId];
        DBCriteria *aCriteria2 = [[DBCriteria alloc] initWithFieldName:kId         operatorType:SQLOperatorIsNotNull andFieldValue:nil];
        
        DBRequestDelete *deleteRequest = [[DBRequestDelete alloc] initWithTableName:kEventObject whereCriteria:@[aCriteria1,aCriteria2] andAdvanceExpression:nil];
         return  [self.commonServices executeStatement:[deleteRequest query]];
    }
    return NO;
}

- (NSString *)getUserIdForLoggedInUser {
      NSString *ownerId = [[CustomerOrgInfo sharedInstance] userId];
    return ownerId;
}

- (void)deleteRecordWithIds:(NSArray *)recordIds
             fromObjectName:(NSString *)objectName
       andCriteriaFieldName:(NSString *)fieldName {
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:fieldName operatorType:SQLOperatorIn andFieldValues:recordIds];
    id <TransactionObjectDAO> transObjectService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    [transObjectService deleteRecordsFromObject:objectName whereCriteria:@[criteria] andAdvanceExpression:nil];
}

@end
