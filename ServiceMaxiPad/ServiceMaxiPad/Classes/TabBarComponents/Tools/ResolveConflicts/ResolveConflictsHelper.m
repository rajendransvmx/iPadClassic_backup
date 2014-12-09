//
//  ResolveConflictsHelper.m
//  ServiceMaxiPad
//
//  Created by Padmashree on 03/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ResolveConflictsHelper.h"
#import "FactoryDAO.h"
#import "SyncErrorConflictDAO.h"
#import "TransactionObjectDAO.h"
#import "SFObjectDAO.h"
#import "StringUtil.h"
#import "SFObjectFieldDAO.h"
#import "SyncErrorConflictService.h"
#import "SyncErrorConflictModel.h"
#import "SFMPageHelper.h"
#import "IncrementalSyncHelper.h"
#import "ModifiedRecordModel.h"
#import "SFMPageEditHelper.h"
#import "ModifiedRecordsDAO.h"
#import "SyncHeapDAO.h"
#import "OneCallDataSyncHelper.h"
#import "SVMXSystemConstant.h"

NSString *const kResolveConflictRetry                = @"retry";
NSString *const kResolveConflictRemove               = @"remove";
NSString *const kResolveConflictHold                 = @"hold";
NSString *const kResolveConflictApplyLocalChanges    = @"applyLocalChanges";
NSString *const kResolveConflictApplyServerChanges   = @"applyServerChanges";

NSString *const kSyncConflictChangeNotification      = @"SyncConflictChangeNotification";

@implementation ResolveConflictsHelper

+(NSInteger)getConflictsCount {
    NSInteger count = 0;
    id service = [FactoryDAO serviceByServiceType:ServiceTypeSyncErrorConflict];
    if ([service conformsToProtocol:@protocol(SyncErrorConflictDAO)]) {
        count = [service getNumberOfRecordsFromObject:kSyncErrorConflictTableName
                                       withDbCriteria:nil
                                andAdvancedExpression:nil];
    }
    return count;
}

// get conflict records from DB..
+(NSArray *)getConflictsRecords {
    NSArray *conflictsRecords = nil;
    id service = [FactoryDAO serviceByServiceType:ServiceTypeSyncErrorConflict];
    if ([service conformsToProtocol:@protocol(SyncErrorConflictDAO)]) {
        conflictsRecords =  [service fetchDataForFields:nil criterias:nil objectName:kSyncErrorConflictTableName andModelClass:[SyncErrorConflictModel class]];
    }
    [ResolveConflictsHelper additionalInfoForConflictRecords:conflictsRecords];
    return conflictsRecords;
}

// get additional info for conflict records..
+(void)additionalInfoForConflictRecords:(NSArray *)conflictsRecords {
    for (SyncErrorConflictModel *syncConflictModel in conflictsRecords) {
        
        // object label for object name..
        syncConflictModel.objectLabel = [ResolveConflictsHelper fetchObjectLabelForObjectName:syncConflictModel.objectName];
        
        // if local id is empty, fetch it using sfId..
        if ([StringUtil isStringEmpty:syncConflictModel.localId]) {
            syncConflictModel.localId = [SFMPageHelper getLocalIdForSFID:syncConflictModel.sfId objectName:syncConflictModel.objectName];
        }
        
        // reference name (record value) for record..
        syncConflictModel.recordValue = [SFMPageHelper getRefernceFieldValueForObject:syncConflictModel.objectName andId:syncConflictModel.localId];
        
        
        
        // check if it is work order object ..
        syncConflictModel.isWorkOrder = [syncConflictModel.objectName isEqualToString:kWorkOrderTableName];
        
        // if record is for work order, get account info ..
        if (syncConflictModel.isWorkOrder) {
            [ResolveConflictsHelper fetchAccountInfoForWorkOrderObject:syncConflictModel];
        }
    }
}

// returns object label for object name ..
+(NSString *)fetchObjectLabelForObjectName:(NSString *)objName {
    NSString *objectLbl = @"";
    id service = [FactoryDAO serviceByServiceType:ServiceTypeSFObject];
    if ([service conformsToProtocol:@protocol(SFObjectDAO)]) {
        objectLbl = [service getLabelForObjectApiName:objName];
    }
    return objectLbl;
}


+(void)fetchAccountInfoForWorkOrderObject:(SyncErrorConflictModel *)syncConflictModel {
    
    NSDictionary *workOrderDict = [SFMPageHelper getDataForObject:syncConflictModel.objectName fields:@[kWorkOrderCompanyId] recordId:syncConflictModel.localId];
    
    // --  if work order doesn't exist in WO table -- ?
    
    NSString *accountSfId = [workOrderDict valueForKey:kWorkOrderCompanyId];
    
    if (![StringUtil isStringEmpty:accountSfId]) {
        NSString *accountLocalId = [SFMPageHelper getLocalIdForSFID:accountSfId objectName:kAccountTableName];
        if ([StringUtil isStringEmpty:accountLocalId]) {
            // if account info doesn't exist in account table, get value from ObjectNameFieldValue table ..
            NSDictionary *objectFieldValues = [SFMPageHelper getValuesFromReferenceTable:@[accountSfId]];
            if ([objectFieldValues count]) {
                syncConflictModel.accountValue = [objectFieldValues valueForKey:accountSfId];
            }
        }
        else {
            syncConflictModel.accountValue = [SFMPageHelper getRefernceFieldValueForObject:kAccountTableName andId:accountLocalId];
        }
    }
    else {
        // if account sfId is nil ..
    }
}

/*
 * Depending on model value we'll get the localized string to display.
 */
+ (NSString *)getLocalizedUserResolutionStringForDatabaseString:(NSString *)databaseString {
    
    NSString *userResolutionString = @"";
    
    if ([databaseString isEqualToString:kResolveConflictRetry]) {
        
        userResolutionString = @"Retry";
    } else if ([databaseString isEqualToString:kResolveConflictRemove]) {
        
        userResolutionString = @"Remove";
    } else if ([databaseString isEqualToString:kResolveConflictHold]) {
        
        userResolutionString = @"Decide later";
    } else if ([databaseString isEqualToString:kResolveConflictApplyLocalChanges]) {
        
        userResolutionString = @"Keep my changes";
    } else if ([databaseString isEqualToString:kResolveConflictApplyServerChanges]) {
        
        userResolutionString = @"Use server version (lose changes)";
    }
    return userResolutionString;
}

+ (NSArray *)fetchLocalizedUserResolutionOptionsForConflict:(SyncErrorConflictModel *)model {
    
    NSArray *resolutionOptions;
    if ([model.operationType isEqualToString:kModificationTypeInsert]) {
        
        resolutionOptions = @[[ResolveConflictsHelper getLocalizedUserResolutionStringForDatabaseString:kResolveConflictRetry],
                              [ResolveConflictsHelper getLocalizedUserResolutionStringForDatabaseString:kResolveConflictRemove],
                              [ResolveConflictsHelper getLocalizedUserResolutionStringForDatabaseString:kResolveConflictHold]];
        
    } else if ([model.operationType isEqualToString:kModificationTypeDelete]) {
        
        resolutionOptions = @[[ResolveConflictsHelper getLocalizedUserResolutionStringForDatabaseString:kResolveConflictRetry],
                              [ResolveConflictsHelper getLocalizedUserResolutionStringForDatabaseString:kResolveConflictApplyServerChanges],
                              [ResolveConflictsHelper getLocalizedUserResolutionStringForDatabaseString:kResolveConflictHold]];
        
    } else if ([model.operationType isEqualToString:kModificationTypeUpdate] && [model.errorType isEqualToString:kError]) {
        
        resolutionOptions = @[[ResolveConflictsHelper getLocalizedUserResolutionStringForDatabaseString:kResolveConflictRetry],
                              [ResolveConflictsHelper getLocalizedUserResolutionStringForDatabaseString:kResolveConflictApplyServerChanges],
                              [ResolveConflictsHelper getLocalizedUserResolutionStringForDatabaseString:kResolveConflictHold]];
        
    } else if ([model.operationType isEqualToString:kModificationTypeUpdate] && [model.errorType isEqualToString:kConflict]) {
        
        resolutionOptions = @[[ResolveConflictsHelper getLocalizedUserResolutionStringForDatabaseString:kResolveConflictApplyLocalChanges],
                              [ResolveConflictsHelper getLocalizedUserResolutionStringForDatabaseString:kResolveConflictApplyServerChanges],
                              [ResolveConflictsHelper getLocalizedUserResolutionStringForDatabaseString:kResolveConflictHold]];
        
    }
    return resolutionOptions;
}
/*
 * Converting from localized resolution string to standard database string.
 */
+ (NSString *)getDatabaseStringForLocalizedUserResolution:(NSString *)userResolutionString {
    
    NSString *databaseString = @"";
    if ([userResolutionString isEqualToString:@"Retry"]) {
        
        databaseString = kResolveConflictRetry;
    } else if ([userResolutionString isEqualToString:@"Remove"]) {
        
        databaseString = kResolveConflictRemove;
    } else if ([userResolutionString isEqualToString:@"Decide later"]) {
        
        databaseString = kResolveConflictHold;
    } else if ([userResolutionString isEqualToString:@"Keep my changes"]) {
        
        databaseString = kResolveConflictApplyLocalChanges;
    } else if ([userResolutionString isEqualToString:@"Use server version (lose changes)"]) {
        
        databaseString = kResolveConflictApplyServerChanges;
    }
    return databaseString;
}

+(BOOL)checkResolvedConflicts {
    BOOL conflictsResolved = FALSE;
    
    NSMutableDictionary *objectIdsDictionary;
    
    NSArray * conflictRecords = [ResolveConflictsHelper getConflictsRecords];
    
    for (SyncErrorConflictModel *syncConflictModel in conflictRecords) {
        
        // create modified record object..
        ModifiedRecordModel * newSyncRecord = [self createModifiedRecord:syncConflictModel];

        // if overrideFlag = apply local changes or retry, then insert record to M.R table and delete from conflicts table..
        if([syncConflictModel.overrideFlag isEqualToString:kResolveConflictApplyLocalChanges] || [syncConflictModel.overrideFlag isEqualToString:kResolveConflictRetry]) {
            [ResolveConflictsHelper insertRecordIntoModifiedRecords:newSyncRecord];
            [ResolveConflictsHelper deleteConflictRecord:syncConflictModel];
            conflictsResolved = TRUE;
        }
        
        // if overrideFlag = apply server changes, then insert record to heap table and delete from conflicts table..
        if([syncConflictModel.overrideFlag isEqualToString: kResolveConflictApplyServerChanges] && newSyncRecord.sfId != nil) {
            if(objectIdsDictionary == nil) {
                objectIdsDictionary = [[NSMutableDictionary alloc] init];
            }
            NSMutableDictionary *  idsDict = [objectIdsDictionary objectForKey:newSyncRecord.objectName];
            if(idsDict == nil){
                idsDict = [[NSMutableDictionary alloc] init];
                [objectIdsDictionary setObject:idsDict forKey:newSyncRecord.objectName];
            }
            [idsDict  setObject:newSyncRecord.sfId forKey:newSyncRecord.sfId];
            [ResolveConflictsHelper deleteConflictRecord:syncConflictModel];
            conflictsResolved = TRUE;
        }
        
        // if overrideFlag = remove, then delete from M.R table, related object table, conflicts table..
        if([syncConflictModel.overrideFlag isEqualToString: kResolveConflictRemove]) {
            NSString * deleteId = ([syncConflictModel.operationType isEqualToString:kModificationTypeUpdate])? newSyncRecord.sfId:newSyncRecord.recordLocalId;
            
            NSString * fieldName = ([syncConflictModel.operationType isEqualToString:kModificationTypeUpdate])? kSyncRecordSFId:kSyncRecordLocalId;
            [ResolveConflictsHelper deleteRecordWithFieldName:fieldName forRecord:deleteId fromObjectName:kModifiedRecords];
            
            fieldName = ([syncConflictModel.operationType isEqualToString:kModificationTypeUpdate])? kId:kLocalId;
            [ResolveConflictsHelper deleteRecordWithFieldName:fieldName forRecord:deleteId fromObjectName:syncConflictModel.objectName];
            
            [ResolveConflictsHelper deleteConflictRecord:syncConflictModel];
            conflictsResolved = TRUE;
        }
    }
    
    // if ids exist to be added to heap table, insert them..
    if(objectIdsDictionary != nil) {
        [self insertIdsIntoHeapTable:objectIdsDictionary];
    }
    
    if(conflictRecords) {
        /*
         * Since we have change in SyncErrorConflict table lets trigger notification so that resolve conflict screen can refresh.
         */
        [ResolveConflictsHelper sendSyncConflictChangeNotificationWithObject:self];
    }
    return conflictsResolved;
}


// method to insert to M.R table..
+(void)insertRecordIntoModifiedRecords:(ModifiedRecordModel *)syncRecord {
    id service = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
    if ([service conformsToProtocol:@protocol(ModifiedRecordsDAO)]) {
        [service saveRecordModel:syncRecord];
    }
}

// method to delete a record with specific id..
+(void)deleteRecordWithFieldName:(NSString *)fieldName forRecord:(NSString *)recordId fromObjectName:(NSString *)objectName {
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:fieldName operatorType:SQLOperatorEqual andFieldValue:recordId];
    id service = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    if ([service conformsToProtocol:@protocol(TransactionObjectDAO)]) {
        [service deleteRecordsFromObject:objectName whereCriteria:@[criteria] andAdvanceExpression:nil];
    }
}

// method to delete a conflict record..
+(void)deleteConflictRecord:(SyncErrorConflictModel *)syncConflictModel {
    NSString *deleteId = [NSString stringWithFormat:@"%lu", (long)syncConflictModel.scLocalId];
    [self deleteRecordWithFieldName:@"scLocalId" forRecord:deleteId fromObjectName:kSyncErrorConflictTableName];
}


// insert ids to heap table..
+(void)insertIdsIntoHeapTable:(NSDictionary *)idsDictionary {
    OneCallDataSyncHelper *syncHelper = [[OneCallDataSyncHelper alloc] init];
    [syncHelper insertIdsIntoSyncHeapTable:idsDictionary];
}

// create M.R record from conflict record..
+(ModifiedRecordModel *)createModifiedRecord:(SyncErrorConflictModel *)syncConflictModel {
    NSString *recordLocalId = syncConflictModel.localId;
    if([StringUtil isStringEmpty:recordLocalId]) {
        recordLocalId = [SFMPageHelper getLocalIdForSFID:syncConflictModel.sfId objectName:syncConflictModel.objectName];
    }

    IncrementalSyncHelper *syncHelper = [[IncrementalSyncHelper alloc] init];
    NSString *parentColumnName = [syncHelper getMasterColumnNameForObject:syncConflictModel.objectName];
    NSString * recordType = (parentColumnName != nil)?kRecordTypeDetail:kRecordTypeMaster;
    ModifiedRecordModel * newSyncRecord = [[ModifiedRecordModel alloc] init];
    newSyncRecord.objectName = syncConflictModel.objectName;
    newSyncRecord.sfId = syncConflictModel.sfId;
    newSyncRecord.recordLocalId = recordLocalId;
    newSyncRecord.operation = syncConflictModel.operationType;
    newSyncRecord.recordType = recordType;
    
    return newSyncRecord;
}

+ (void)saveConflict:(SyncErrorConflictModel *)conflict {
    
    if (!conflict) {
        return;
    }
    
    id service = [FactoryDAO serviceByServiceType:ServiceTypeSyncErrorConflict];
    if ([service conformsToProtocol:@protocol(SyncErrorConflictDAO)]) {
        
        DBCriteria *criteria = [[DBCriteria alloc]initWithFieldName:@"scLocalId" operatorType:SQLOperatorEqual andFieldValue:[NSString stringWithFormat:@"%ld",(long)conflict.scLocalId]];
        
        BOOL status = [service updateEachRecord:conflict withFields:@[@"overrideFlag"] withCriteria:@[criteria]];
        
        if (status) {
            SXLogDebug(@"conflict updated");
        }
    }
}

+ (void)sendSyncConflictChangeNotificationWithObject:(id)object {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSyncConflictChangeNotification object:object];
}


+(NSArray *)fetchSfIdsFromConflictRecords {
    NSArray *conflictsRecords = nil;
    id service = [FactoryDAO serviceByServiceType:ServiceTypeSyncErrorConflict];
    if ([service conformsToProtocol:@protocol(SyncErrorConflictDAO)]) {
        conflictsRecords =  [service fetchDataForFields:@[@"sfId"] criterias:nil objectName:kSyncErrorConflictTableName andModelClass:[SyncErrorConflictModel class]];
    }
    
    NSMutableArray *recordIds  = [[NSMutableArray alloc] init];
    
    for (SyncErrorConflictModel *syncConflictModel in conflictsRecords) {
        if ([StringUtil isStringNotNULL:syncConflictModel.sfId] && ![StringUtil isStringEmpty:syncConflictModel.sfId]) {
            [recordIds addObject:syncConflictModel.sfId];
        }
    }
    return recordIds;
}

+(NSInteger)getNonHoldConflictsCount {
    NSInteger count = 0;
    id service = [FactoryDAO serviceByServiceType:ServiceTypeSyncErrorConflict];
    if ([service conformsToProtocol:@protocol(SyncErrorConflictDAO)]) {
        DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:@"overrideFlag" operatorType:(SQLOperatorNotEqual) andFieldValue:kResolveConflictHold];
        DBCriteria *criteria2 = [[DBCriteria alloc] initWithFieldName:@"overrideFlag" operatorType:(SQLOperatorIsNull) andFieldValue:nil];
        count = [service getNumberOfRecordsFromObject:kSyncErrorConflictTableName
                                       withDbCriteria:@[criteria, criteria2]
                                andAdvancedExpression:@"1 OR 2"];
    }
    return count;
}

@end
