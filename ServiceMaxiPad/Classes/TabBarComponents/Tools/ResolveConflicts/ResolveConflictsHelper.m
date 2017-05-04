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
#import "DateUtil.h"
#import "TagManager.h"
#import "SFChildRelationshipDAO.h"
#import "SFChildRelationshipModel.h"
#import "AttachmentHelper.h"
#import "ModifiedRecordsService.h"
#import "MobileDeviceSettingService.h"
#import "OpDocHelper.h"

NSString *const kResolveConflictRetry                = @"retry";
NSString *const kResolveConflictRemove               = @"remove";
NSString *const kResolveConflictHold                 = @"hold";
NSString *const kResolveConflictApplyLocalChanges    = @"applyLocalChanges";
NSString *const kResolveConflictApplyServerChanges   = @"applyServerChanges";
NSString *const kResolveConflictIgnore               = @"Ignore";

NSString *const kSyncConflictChangeNotification      = @"SyncConflictChangeNotification";

/*
 * Sync Conflict Types.
 */
NSString *const kSyncTypeCustomOverrideSync          = @"SyncTypeCustomOverrideSync";
NSString *const kSyncTypeAttachmentSync              = @"SyncTypeAttachmentSync";

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
                syncConflictModel.svmxAcValue = [objectFieldValues valueForKey:accountSfId];
            }
        }
        else {
            syncConflictModel.svmxAcValue = [SFMPageHelper getRefernceFieldValueForObject:kAccountTableName andId:accountLocalId];
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
        
        userResolutionString = [[TagManager sharedInstance]tagByName:kTagConflictRetry];
    } else if ([databaseString isEqualToString:kResolveConflictRemove]) {
        
        userResolutionString = [[TagManager sharedInstance]tagByName:kTagConflictRemove];
    } else if ([databaseString isEqualToString:kResolveConflictHold]) {
        
        userResolutionString = [[TagManager sharedInstance]tagByName:kTag_DecideLater];
    } else if ([databaseString isEqualToString:kResolveConflictApplyLocalChanges]) {
        
        userResolutionString = [[TagManager sharedInstance]tagByName:kTag_KeepMyChanges];
    } else if ([databaseString isEqualToString:kResolveConflictApplyServerChanges]) {
        
        userResolutionString = [[TagManager sharedInstance]tagByName:kTag_UseServerVersion];
    } else if ([databaseString isEqualToString:kResolveConflictIgnore]) {
        
        userResolutionString = @"Ignore";//Add tag and replace it ith tag manager.
    }
    return userResolutionString;
}

+ (NSArray *)fetchLocalizedUserResolutionOptionsForConflict:(SyncErrorConflictModel *)model {
    
    NSArray *resolutionOptions;
    
    /*
     * Custom override sync options.
     */
    if ([model.syncType isEqualToString:kSyncTypeCustomOverrideSync]) {
        resolutionOptions = @[[ResolveConflictsHelper getLocalizedUserResolutionStringForDatabaseString:kResolveConflictRetry],
                              [ResolveConflictsHelper getLocalizedUserResolutionStringForDatabaseString:kResolveConflictIgnore],
                              [ResolveConflictsHelper getLocalizedUserResolutionStringForDatabaseString:kResolveConflictHold]];
        return resolutionOptions;
    } else if ([model.syncType isEqualToString:kSyncTypeAttachmentSync]) {
        resolutionOptions = @[[ResolveConflictsHelper getLocalizedUserResolutionStringForDatabaseString:kResolveConflictRetry],
                              [ResolveConflictsHelper getLocalizedUserResolutionStringForDatabaseString:kResolveConflictRemove]];
        return resolutionOptions;

    }
    
    /*
     * Other options based on operation type.
     */
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
    if ([userResolutionString isEqualToString:[[TagManager sharedInstance]tagByName:kTagConflictRetry]]) {
        
        databaseString = kResolveConflictRetry;
    } else if ([userResolutionString isEqualToString:[[TagManager sharedInstance]tagByName:kTagConflictRemove]]) {
        
        databaseString = kResolveConflictRemove;
    } else if ([userResolutionString isEqualToString:[[TagManager sharedInstance]tagByName:kTag_DecideLater]]) {
        
        databaseString = kResolveConflictHold;
    } else if ([userResolutionString isEqualToString:[[TagManager sharedInstance]tagByName:kTag_KeepMyChanges]]) {
        
        databaseString = kResolveConflictApplyLocalChanges;
    } else if ([userResolutionString isEqualToString:[[TagManager sharedInstance]tagByName:kTag_UseServerVersion]]) {
        
        databaseString = kResolveConflictApplyServerChanges;
    } else if ([userResolutionString isEqualToString:@"Ignore"]) {
        
        databaseString = kResolveConflictIgnore;
    }
    return databaseString;
}

+(BOOL)checkResolvedConflicts {
    BOOL conflictsResolved = TRUE;
    
    NSMutableDictionary *objectIdsDictionary;
    
    NSArray * conflictRecords = [ResolveConflictsHelper getConflictsRecords];
    
    for (SyncErrorConflictModel *syncConflictModel in conflictRecords) {
        
        if([StringUtil isStringEmpty:syncConflictModel.overrideFlag]) {
            
            conflictsResolved = FALSE;
            break;
        }
        else {
            // create modified record object..
            ModifiedRecordModel * newSyncRecord = [self createModifiedRecord:syncConflictModel];
            
            // if overrideFlag = apply local changes or retry, then insert record to M.R table and delete from conflicts table..
            if([syncConflictModel.overrideFlag isEqualToString:kResolveConflictApplyLocalChanges] || [syncConflictModel.overrideFlag isEqualToString:kResolveConflictRetry]) {
                
                MobileDeviceSettingService *mobileDeviceSettingService = [[MobileDeviceSettingService alloc]init];
                MobileDeviceSettingsModel *mobDeviceSettings = [mobileDeviceSettingService fetchDataForSettingId:@"IPAD018_SET016"];
                BOOL isFieldMergeEnabled = [StringUtil isItTrue:mobDeviceSettings.value];
                if (isFieldMergeEnabled) {
                    [self addClientOverrideFlagToJSON:newSyncRecord];
                }
                id <ModifiedRecordsDAO>modifiedRecordService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
                BOOL doesExist =   [modifiedRecordService doesRecordExistForId:newSyncRecord.recordLocalId andOperationType:newSyncRecord.operation];
                if (!doesExist) {
                    [ResolveConflictsHelper insertRecordIntoModifiedRecords:newSyncRecord];
                }
                else {
                    if (isFieldMergeEnabled && ![StringUtil isStringEmpty:newSyncRecord.fieldsModified]) {
                        [modifiedRecordService updateFieldsModifed:newSyncRecord];
                    }
                }
                [self handleCustomCallRecordToUpdateTheRecordSentToREMOVEHold:syncConflictModel]; // To enable the record to participate in Data Sync.

                [ResolveConflictsHelper deleteConflictRecord:syncConflictModel];
                //conflictsResolved = TRUE;
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
                
                if ([syncConflictModel.operationType isEqualToString:kModificationTypeUpdate]) {
                    [ResolveConflictsHelper deleteRecordWithFieldName:kSyncRecordSFId forRecord:newSyncRecord.sfId fromObjectName:kModifiedRecords];
                }
                
                [ResolveConflictsHelper deleteConflictRecord:syncConflictModel];
                // conflictsResolved = TRUE;
            }
            
            // if overrideFlag = remove, then delete from M.R table, related object table, conflicts table..
            if([syncConflictModel.overrideFlag isEqualToString: kResolveConflictRemove]) {
                NSString * deleteId = ([syncConflictModel.operationType isEqualToString:kModificationTypeUpdate])? newSyncRecord.sfId:newSyncRecord.recordLocalId;
                
                NSString * fieldName = ([syncConflictModel.operationType isEqualToString:kModificationTypeUpdate])? kSyncRecordSFId:kSyncRecordLocalId;
                [ResolveConflictsHelper deleteRecordWithFieldName:fieldName forRecord:deleteId fromObjectName:kModifiedRecords];
                if ([fieldName isEqualToString:kSyncRecordLocalId]) {
                    //For deleting record which is scheduled to be synced for Custom Webservice BeforeSave/AfterSave.
                    NSString *lTempDeletedID = [NSString stringWithFormat:@"%@%@", deleteId, kChangedLocalIDForCustomCall];
                    [ResolveConflictsHelper deleteRecordWithFieldName:fieldName forRecord:lTempDeletedID fromObjectName:kModifiedRecords];
                }
                [[OpDocHelper sharedManager] deleteSignatureAndHtmlFilesForConflicts:deleteId];
                fieldName = ([syncConflictModel.operationType isEqualToString:kModificationTypeUpdate])? kId:kLocalId;
                [ResolveConflictsHelper deleteRecordWithFieldName:fieldName forRecord:deleteId fromObjectName:syncConflictModel.objectName];
                
                [ResolveConflictsHelper deleteConflictRecordFromRecents:syncConflictModel];
                
                [ResolveConflictsHelper deleteConflictRecord:syncConflictModel];
                //conflictsResolved = TRUE;
                
                //HS 2June -- Remove Child record related to Header roecord, in case of Remove.
                NSArray *childRecordArray = [ResolveConflictsHelper fetchChildRecordsFromModifiedRecords:deleteId];
                
                
                if (childRecordArray.count > 0) {
                    
                    NSMutableArray *recordIds  = [[NSMutableArray alloc] init];
                    NSMutableArray *childObjectNameArr = [[NSMutableArray alloc]init];

                    
                    for (ModifiedRecordModel *mrModel in childRecordArray) {
                        
                         [ResolveConflictsHelper deleteRecordWithFieldName:@"localId" forRecord:mrModel.recordLocalId fromObjectName:mrModel.objectName];
                        
                        if ([StringUtil isStringNotNULL:mrModel.recordLocalId] && ![StringUtil isStringEmpty:mrModel.recordLocalId]) {
                            [recordIds addObject:mrModel.recordLocalId];
                        }
                        
                    }

                    
                     ModifiedRecordsService *modifiedRrcordServiceObj = [[ModifiedRecordsService alloc] init];
                   
                        [modifiedRrcordServiceObj deleteRecordsForRecordLocalIds:recordIds];
                    
                }
                
                
                //HS 2June ends here
            }
            
            if([syncConflictModel.overrideFlag isEqualToString:kResolveConflictHold]) {
                
                // If there are earlier changes in modified record fetch them add in conflict table
                ModifiedRecordsService *modifiedRecordService = [[ModifiedRecordsService alloc]init];
                
                NSString *existingModifiedFields = [modifiedRecordService fetchExistingModifiedFieldsJsonFromModifiedRecordForRecordId:syncConflictModel.localId andSfId:syncConflictModel.sfId];
                if (![StringUtil isStringEmpty:existingModifiedFields]) {
                    syncConflictModel.fieldsModified = existingModifiedFields;
                    [ResolveConflictsHelper updateFieldsModifiedJsonInConflictsTable:syncConflictModel];
                }
                
                [ResolveConflictsHelper deleteDecideLaterConflictsFromModifiedRecordsTable:syncConflictModel];
                // conflictsResolved = TRUE;
            }

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
    
    NSString *parentId = [SFMPageHelper getSfIdForLocalId:recordId objectName:objectName];
    if ([StringUtil isStringEmpty:parentId])
    {
       parentId = recordId;
       [AttachmentHelper deleteAttachmentsFromDBDirectoryForParentId:parentId];
    }
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
    newSyncRecord.timeStamp = [DateUtil getDatabaseStringForDate:[NSDate date]];
    newSyncRecord.fieldsModified = syncConflictModel.fieldsModified;
    
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

//HS 2June
+(NSArray *)fetchChildRecordsFromModifiedRecords:(NSString *)parentRecordLocalId
{
    NSArray *childModifiedRecords = nil;
    id service = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
    if ([service conformsToProtocol:@protocol(ModifiedRecordsDAO)]) {
        
        DBCriteria *criteria = [[DBCriteria alloc]initWithFieldName:@"parentLocalId" operatorType:SQLOperatorEqual andFieldValue:parentRecordLocalId];
        
        childModifiedRecords =  [service fetchDataForFields:@[@"recordLocalId",@"objectName"] criterias:@[criteria] objectName:kModifiedRecords andModelClass:[ModifiedRecordModel class]];
    }
    
    return childModifiedRecords;
}
//

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

+ (BOOL)isConflictPresentForRecord:(TransactionObjectModel *)model {
    
    BOOL status = NO;
    long numberOfRecords = [self getNumberOfConflictRecordsForTransactionModel:model];
    
    if (numberOfRecords>0) {
        /*
         * If the parent itself is there in the conflict table
         */
        status = YES;
        
    } else {
        
        id <SFChildRelationshipDAO> childRelationServiceRequest = [FactoryDAO serviceByServiceType:ServiceTypeSFChildRelationShip];
        
        DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:kCRObjectNameParentField
                                                         operatorType:SQLOperatorEqual
                                                        andFieldValue:model.objectAPIName];
        
        DBCriteria *criteria2 = [[DBCriteria alloc] initWithFieldName:kCRFieldNameField
                                                         operatorType:SQLOperatorEqual
                                                        andFieldValue:model.objectAPIName];
        
        NSArray *lChildModelArray = [childRelationServiceRequest fetchSFChildRelationshipInfoByFields:@[kCRObjectNameChildField]
                                                                                         andCriterias:@[criteria1, criteria2]
                                                                                  andAdvanceExpresion:@"(1 AND 2)"];
        
        if ((lChildModelArray == nil) || ([lChildModelArray count] < 1)) {
            // No child records found. Lets go back
            status = NO;
            
        } else {
            
            SFChildRelationshipModel * lCRModel = [lChildModelArray objectAtIndex:0];
            
            // Record of the children from child table.
            DBCriteria * criteria1 = [[DBCriteria alloc] initWithFieldName:model.objectAPIName operatorType:SQLOperatorEqual andFieldValue:[model valueForField:@"Id"]];
            DBCriteria * criteria2 = [[DBCriteria alloc] initWithFieldName:model.objectAPIName operatorType:SQLOperatorEqual andFieldValue:model.recordLocalId];
            
            id <TransactionObjectDAO> transObjectService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
            
            NSMutableArray *objects =   (NSMutableArray *)[transObjectService fetchDataForObject:lCRModel.objectNameChild fields:nil expression:@"(1 OR 2)" criteria:@[criteria1, criteria2]];
            
            if ([objects count] > 0) {
                for (int i = 0; i<objects.count; i++) {
                    TransactionObjectModel *record =  [objects objectAtIndex:i];
                    [record setObjectName:lCRModel.objectNameChild];
                    [objects replaceObjectAtIndex:i withObject:record];
                }
            }
            
            NSArray *lDataArray = objects;
            
            for (TransactionObjectModel *lTransModel in lDataArray)
            {
                //Check if the child ids present in the SyncErrorConflictTable
                
                long numberOfRecords = [self getNumberOfConflictRecordsForTransactionModel:lTransModel];
                
                if (numberOfRecords>0) {
                    
                    // this child has Sync error. Break from here and inform of the Sync Status
                    status = YES;
                    break;
                }
            }
        }
    }
    return status;
}

+ (NSInteger)getNumberOfConflictRecordsForTransactionModel:(TransactionObjectModel *)model
{
    DBCriteria *syncCriteria1 = [[DBCriteria alloc] initWithFieldName:kLocalId operatorType:SQLOperatorEqual andFieldValue:model.recordLocalId];
    
    DBCriteria *syncCriteria2 = [[DBCriteria alloc] initWithFieldName:kSyncRecordSFId operatorType:SQLOperatorEqual andFieldValue:[model valueForField:@"Id"]];
    
    id <SyncErrorConflictDAO> syncErrorService = [FactoryDAO serviceByServiceType:ServiceTypeSyncErrorConflict];
    
    NSInteger numberOfRecords = [syncErrorService getNumberOfRecordsFromObject:kSyncErrorConflictTableName withDbCriteria:@[syncCriteria1, syncCriteria2] andAdvancedExpression:@"(1 OR 2)"];
    
    return numberOfRecords;
}


+(void)deleteDecideLaterConflictsFromModifiedRecordsTable:(SyncErrorConflictModel *)syncConflictModel
{
//    Manage decide later for custom webservice calls related record.
    //retriedve decide later records
    //delete decide later records from modified records table
    [self handleCustomCallRecordToUpdateTheRecordSentToINSERTHold:syncConflictModel];
    
    NSString * deleteId = ([syncConflictModel.operationType isEqualToString:kModificationTypeUpdate])? syncConflictModel.sfId:syncConflictModel.localId;
    NSString * fieldName = ([syncConflictModel.operationType isEqualToString:kModificationTypeUpdate])? kSyncRecordSFId:kSyncRecordLocalId;
    [ResolveConflictsHelper deleteRecordWithFieldName:fieldName forRecord:deleteId fromObjectName:kModifiedRecords];
}

+(void)handleCustomCallRecordToUpdateTheRecordSentToINSERTHold:(SyncErrorConflictModel *)syncConflictModel
{
    id <ModifiedRecordsDAO>modifiedRecordService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];

    NSString * deleteId = [NSString stringWithFormat:@"%@%@", syncConflictModel.localId, kChangedLocalIDForCustomCall];
    
    NSArray *customCallPendingRecords = [modifiedRecordService recordForRecordId:deleteId];
    if (customCallPendingRecords.count) {

        for (ModifiedRecordModel *newSyncRecord in customCallPendingRecords) {
            newSyncRecord.recordSent = kResolveConflictHold;
            [modifiedRecordService updateRecordsSent:newSyncRecord];
        }
    }
}

+(void)handleCustomCallRecordToUpdateTheRecordSentToREMOVEHold:(SyncErrorConflictModel *)syncConflictModel
{
    id <ModifiedRecordsDAO>modifiedRecordService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
    
    
    NSString * deleteId = [NSString stringWithFormat:@"%@%@", syncConflictModel.localId, kChangedLocalIDForCustomCall];
    
    NSArray *customCallPendingRecords = [modifiedRecordService recordForRecordId:deleteId];
    if (customCallPendingRecords.count) {
        
        for (ModifiedRecordModel *newSyncRecord in customCallPendingRecords) {
            newSyncRecord.recordSent = @"";
            [modifiedRecordService updateRecordsSent:newSyncRecord];
            
        }
        
    }
    
    
}

+ (void)deleteConflictRecordFromRecents:(SyncErrorConflictModel *)syncConflictModel
{
    if ([syncConflictModel.localId length] > 0) {
        [ResolveConflictsHelper deleteRecordWithFieldName:kLocalId
                                                forRecord:syncConflictModel.localId
                                           fromObjectName:@"RecentRecord"];
    }
    
}


+(void)updateFieldsModifiedJsonInConflictsTable:(SyncErrorConflictModel *)syncConflictModel {
    NSArray * fieldsArray = [[NSArray alloc] initWithObjects:@"fieldsModified", nil];
    DBCriteria * criteria1 = [[DBCriteria alloc] initWithFieldName:@"sfId" operatorType:SQLOperatorEqual andFieldValue:syncConflictModel.sfId];
    DBCriteria * criteria2 = [[DBCriteria alloc] initWithFieldName:@"operationType" operatorType:SQLOperatorEqual andFieldValue:@"UPDATE"];
    
    id <SyncErrorConflictDAO> syncErrorService = [FactoryDAO serviceByServiceType:ServiceTypeSyncErrorConflict];
    [syncErrorService updateEachRecord:syncConflictModel withFields:fieldsArray withCriteria:[NSArray arrayWithObjects:criteria1, criteria2, nil]];
}


+(void)addClientOverrideFlagToJSON:(ModifiedRecordModel *)syncRecord {
    NSString *fieldsModifiedJson = nil;
    ModifiedRecordsService *modifiedRecordService = [[ModifiedRecordsService alloc]init];
    fieldsModifiedJson = [modifiedRecordService fetchExistingModifiedFieldsJsonFromModifiedRecordForRecordId:syncRecord.recordLocalId andSfId:syncRecord.sfId];
    if ([StringUtil isStringEmpty:fieldsModifiedJson]) {
        fieldsModifiedJson = syncRecord.fieldsModified;
    }
    
    NSError *error = nil;
    NSData *jsonData;
    if (![StringUtil isStringEmpty:fieldsModifiedJson])
    {
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[fieldsModifiedJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
        NSMutableDictionary *finalDict = [NSMutableDictionary dictionaryWithDictionary:jsonDict];
        [finalDict setObject:@"YES" forKey:@"CLIENT_OVERRIDE"];
        
        error = nil;
        jsonData = [NSJSONSerialization dataWithJSONObject:finalDict options:NSJSONWritingPrettyPrinted error:&error];
    }
  
    
    if (jsonData != nil) {
        syncRecord.fieldsModified = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    else {
        NSLog(@"field merging json creatn failed error :%@ ", error);
    }
}

@end
