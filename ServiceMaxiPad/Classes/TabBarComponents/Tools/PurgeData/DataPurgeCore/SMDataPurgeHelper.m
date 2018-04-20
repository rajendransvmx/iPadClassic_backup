//
//  SMDataPurgeHelper.m
//  ServiceMaxiPad
//
//  Created by Pushpak on 16/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "SMDataPurgeHelper.h"
#import "SMDataPurgeModel.h"
#import "SVMXSystemConstant.h"
#import "SFObjectDAO.h"
#import "SFObjectModel.h"
#import "FactoryDAO.h"
#import "Utility.h"
#import "FileManager.h"
#import "TransactionObjectDAO.h"
#import "ModifiedRecordModel.h"
#import "ModifiedRecordsDAO.h"
#import "DBRequestSelect.h"
#import "DBRequestDelete.h"
#import "DODRecordsModel.h"
#import "DODRecordsDAO.h"
#import "SFObjectFieldDAO.h"
#import "SFChildRelationshipDAO.h"
#import "SFChildRelationshipModel.h"
#import "SyncErrorConflictDAO.h"
#import "SyncErrorConflictModel.h"
#import "ProductManualDAO.h"
#import "ProductManualModel.h"
#import "SMObjectRelationModel.h"
#import "DatabaseQueue.h"
#import "DatabaseManager.h"
#import "MobileDeviceSettingDAO.h"
#import "DataPurgeDAO.h"
#import "ResolveConflictsHelper.h"
#import "DataPurgeModel.h"
#import "SMDataPurgeModel.h"
#import "AttachmentHelper.h"
#import "TroubleshootingDataHelper.h"

@implementation SMDataPurgeHelper
#pragma mark - Database operations changed
+ (NSMutableArray *)getGraceOrNonGraceRecord:(NSString *)object
                              filterCriteria:(DBCriteria *)criteria
                             trialerCriteria:(DBCriteria *)trialerCriteria
{
    
    NSMutableArray * recordIds = [[NSMutableArray alloc] initWithCapacity:0];
    id transactionService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    if ([transactionService conformsToProtocol:@protocol(TransactionObjectDAO)]) {
        
        NSArray *transactionModels = [transactionService fetchDataForObject:object
                                                                     fields:@[kId]
                                                                 expression:nil
                                                                   criteria:@[criteria]];
        if ([transactionModels count]) {
            for (TransactionObjectModel *model in transactionModels) {
                if ([model valueForField:kId]) {
                    [recordIds addObject:[model valueForField:kId]];
                }
            }
        }
    }
    
    NSMutableArray *modifiedRecordIDs = [self getRecordIdFromTrailerTable:object
                                                           filterCriteria:trialerCriteria];
    
    if ([modifiedRecordIDs count]) {
        for (NSString *recordID in modifiedRecordIDs) {
            [recordIds addObject:recordID];
        }
    }
    return recordIds;
}


+ (NSMutableArray *)getNonGraceTrailerRecord:(NSString *)object
                             trialerCriteria:(DBCriteria *)trialerCriteria {
    
    NSMutableArray * recordIds = [[NSMutableArray alloc] initWithCapacity:0];
    id transactionService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    if ([transactionService conformsToProtocol:@protocol(TransactionObjectDAO)]) {
        
        NSArray *transactionModels = [transactionService fetchDataForObject:object
                                                                     fields:@[kId]
                                                                 expression:nil
                                                                   criteria:@[trialerCriteria]];
        if ([transactionModels count]) {
            for (TransactionObjectModel *model in transactionModels) {
                if ([model valueForField:kId]) {
                    [recordIds addObject:[model valueForField:kId]];
                }
            }
        }
    }
    return recordIds;
}

+ (NSMutableArray *)getRecordIdFromTrailerTable:(NSString *)objectName
                                 filterCriteria:(DBCriteria *)criteria
{
    NSMutableArray * recordIds = [[NSMutableArray alloc] initWithCapacity:0];
    
    id modifiedRecordService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
    if ([modifiedRecordService conformsToProtocol:@protocol(ModifiedRecordsDAO)]) {
        
        DBCriteria *criteria1 = [[DBCriteria alloc]initWithFieldName:@"objectName"
                                                        operatorType:SQLOperatorEqual
                                                       andFieldValue:objectName];
        NSArray *models = [modifiedRecordService fetchDataForFields:@[@"sfId"]
                                                          criterias:@[criteria,criteria1]
                                                         objectName:kModifiedRecords
                                                      andModelClass:[ModifiedRecordModel class]];
        if ([models count]) {
            for (ModifiedRecordModel *model in models) {
                if (model.sfId) {
                    [recordIds addObject:model.sfId];
                }
            }
        }
    }
    return recordIds;
}

+ (NSMutableArray *)getGraceOrNonGraceDODRecord:(NSArray *)criterias{
    
    NSMutableArray * recordIds = [[NSMutableArray alloc] initWithCapacity:0];
    
    id dodService = [FactoryDAO serviceByServiceType:ServiceTypeDOD];
    if ([dodService conformsToProtocol:@protocol(DODRecordsDAO)]) {
        
        NSArray *models = [dodService fetchDataForFields:@[@"sfId"]
                                               criterias:criterias
                                              objectName:@"DODRecords"
                                           andModelClass:[DODRecordsModel class]];
        
        if ([models count]) {
            for (DODRecordsModel *model in models) {
                if (model.sfId) {
                    [recordIds addObject:model.sfId];
                }
            }
        }
    }
    return recordIds;
}

+ (NSMutableArray *)getEventRelatedRecords{
    
    NSMutableArray * eventWhatIds = [[NSMutableArray alloc] initWithCapacity:0];
    
    id transactionService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    if ([transactionService conformsToProtocol:@protocol(TransactionObjectDAO)]) {
        
        NSArray *transactionModels = [transactionService fetchDataForObject:kEventObject
                                                                     fields:@[@"WhatId"]
                                                                 expression:nil
                                                                   criteria:nil];
        if ([transactionModels count]) {
            for (TransactionObjectModel *model in transactionModels) {
                if ([model valueForField:@"WhatId"]) {
                    [eventWhatIds addObject:[model valueForField:@"WhatId"]];
                }
            }
        }
    }
    return eventWhatIds;
}

+ (NSMutableArray *)getChildIdsRelatedToEventParentId:(NSArray *)childObjectData
                                             parentId:(NSString *)Ids
                                           parentName:(NSString *)parentObject{
    
    NSMutableArray * childIds = [[NSMutableArray alloc] initWithCapacity:0];
    NSString * query = nil;
    
    if ([childObjectData count] == 2)
    {
        NSString * childObject = [childObjectData objectAtIndex:0];
        NSString * childFieldName = [childObjectData objectAtIndex:1];
        
        query = [[NSString alloc] initWithFormat:@"SELECT child.Id FROM '%@' child LEFT OUTER JOIN '%@' parent ON child.%@ = parent.Id OR child.%@ = parent.localId WHERE parent.Id In (%@)", childObject, parentObject, childFieldName, childFieldName, Ids];
        
        @autoreleasepool {
            DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
            
            [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
                
                SQLResultSet * resultSet = [db executeQuery:query];
                
                while ([resultSet next]) {
                    NSDictionary * dict = [resultSet resultDictionary];
                    //Method in model to set the values
                    TransactionObjectModel * model = [[TransactionObjectModel alloc] init];
                    [model mergeFieldValueDictionaryForFields:dict];
                    if (model != nil) {
                        if ([model valueForField:kId]) {
                            [childIds addObject:[model valueForField:kId]];
                        }
                    }
                }
                [resultSet close];
            }];
        }
    }
    return childIds;
}

+ (void)purgeRecordForObject:(NSString *)objectName
                        data:(NSArray *)ids
{
    DBCriteria *criteria = [[DBCriteria alloc]initWithFieldName:kId
                                                   operatorType:SQLOperatorIn
                                                 andFieldValues:ids];
    
    DBRequestDelete *delQuery = [[DBRequestDelete alloc]initWithTableName:objectName
                                                            whereCriteria:@[criteria]
                                                     andAdvanceExpression:nil];
    
    id transactionService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    if ([transactionService conformsToProtocol:@protocol(TransactionObjectDAO)]) {
        BOOL status = [transactionService executeStatement:[delQuery query]];
        if (!status) {
            SXLogDebug(@"Purge records failed");
        }
    }
}

+ (NSSet *)getDistinctObjectApiNames{
    
    NSSet *apiNameSet = nil;
    NSMutableArray * apiNames = [[NSMutableArray alloc] initWithCapacity:0];
    
    id service = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectField];
    if ([service conformsToProtocol:@protocol(SFObjectFieldDAO)]) {
        NSArray *models = [service fetchDistinctSFObjectFieldsInfoByFields:@[@"objectName"] andCriteria:nil];
        if ([models count]) {
            for (SFObjectModel *model in models) {
                if (model.objectName) {
                    [apiNames addObject:model.objectName];
                }
            }
        }
        if ((apiNames != nil) && ([apiNames count] > 0))
        {
            apiNameSet = [[NSSet alloc] initWithArray:apiNames];
        }
        else
        {
            apiNameSet = [[NSSet alloc] init];
        }
    }
    return apiNameSet;
}

+ (NSArray*)getRelationshipForObject:(NSString *)parentName{
    
    NSMutableArray *smObjectRelationModels = [[NSMutableArray alloc] initWithCapacity:0];
    id service = [FactoryDAO serviceByServiceType:ServiceTypeSFChildRelationShip];
    if ([service conformsToProtocol:@protocol(SFChildRelationshipDAO)]) {
        
        DBCriteria *criteria = [[DBCriteria alloc]initWithFieldName:@"objectNameParent"
                                                       operatorType:SQLOperatorEqual
                                                      andFieldValue:parentName];
        
        NSArray *models = [service fetchSFChildRelationshipInfoByFields:@[@"fieldName",@"objectNameChild"]
                                                           andCriterias:@[criteria]
                                                    andAdvanceExpresion:nil];
        
        if ([models count]) {
            for (SFChildRelationshipModel *model in models) {
                
                SMObjectRelationModel *objectModel = [[SMObjectRelationModel alloc] init];
                objectModel.parentName = parentName;
                objectModel.childFieldName = model.fieldName;
                objectModel.childName = model.objectNameChild;
                [smObjectRelationModels addObject:objectModel];
            }
        }
    }
    return smObjectRelationModels;
}

+ (NSMutableArray *)getAllLocalIdsForSfId:(NSArray *)sfIds
                               objectName:(NSString *)objectName
{
    NSMutableArray *locaIdArray = [[NSMutableArray alloc]initWithCapacity:0];
    
    id service = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    if ([service conformsToProtocol:@protocol(TransactionObjectDAO)]) {
        
        NSArray *transactionModels = [service getLocalIDForObject:objectName recordIds:sfIds];
        if ([transactionModels count]) {
            
            for (TransactionObjectModel *model  in transactionModels) {
                if (model.recordLocalId) {
                    [locaIdArray addObject:model.recordLocalId];
                }
            }
        }
    }
    return locaIdArray;
}

+ (void)purgeRecordFromRealatedTables:(NSString *)tableName
                               column:(NSString *)columnName
                                 data:(NSArray *)ids
{
    DBCriteria *criteria = [[DBCriteria alloc]initWithFieldName:columnName
                                                   operatorType:SQLOperatorIn
                                                 andFieldValues:ids];
    
    DBRequestDelete *delQuery = [[DBRequestDelete alloc]initWithTableName:tableName
                                                            whereCriteria:@[criteria]
                                                     andAdvanceExpression:nil];
    
    id transactionService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    if ([transactionService conformsToProtocol:@protocol(TransactionObjectDAO)]) {
        BOOL status = [transactionService executeStatement:[delQuery query]];
        if (!status) {
            SXLogDebug(@"Purge records failed");
        }
    }
    
}

+ (NSMutableDictionary *)getConflictRecordMap
{
    NSMutableDictionary *conflictMap = [[NSMutableDictionary alloc]initWithCapacity:0];
    
    id service = [FactoryDAO serviceByServiceType:ServiceTypeSyncErrorConflict];
    if ([service conformsToProtocol:@protocol(SyncErrorConflictDAO)]) {
        
        NSArray *models = [service fetchDataForFields:@[@"sfId",@"objectName"]
                                            criterias:nil
                                           objectName:kSyncErrorConflictTableName
                                        andModelClass:[SyncErrorConflictModel class]];
        
        if ([models count]) {
            for (SyncErrorConflictModel *model in models) {
                
                NSString * recordId = nil;
                NSString * objectName = nil;
                
                if ((model.sfId != nil) && model.sfId.length)
                {
                    recordId = model.sfId;
                }
                if ((model.objectName != nil) && model.objectName.length)
                {
                    objectName = model.objectName;
                }
                NSMutableArray * array = [conflictMap objectForKey:objectName];
                
                if (recordId != nil)
                {
                    if ((array != nil) && ([array count] > 0))
                    {
                        [array addObject:recordId];
                    }
                    else
                    {
                        array = [[NSMutableArray alloc] initWithCapacity:0];
                        [array addObject:recordId];
                        
                        if (objectName != nil)
                        {
                            [conflictMap setObject:array forKey:objectName];
                        }
                    }
                }
            }
        }
    }
    
    return conflictMap;
}

+ (NSMutableDictionary *)getRecordDictionaryForObjectRelationship:(SMObjectRelationModel *)model{
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    NSString *queryString = [[NSString alloc] initWithFormat:@"SELECT tSource.id, tDestination.id FROM '%@' tSource, '%@' tDestination WHERE tDestination.%@ = tSource.localId", model.parentName, model.childName, model.childFieldName];

    [self getdataThroughIdWithQuery:queryString inDictionary:dictionary];
    
    queryString = [[NSString alloc] initWithFormat:@"SELECT tSource.id, tDestination.id FROM '%@' tSource, '%@' tDestination WHERE tDestination.%@ = tSource.id", model.parentName, model.childName, model.childFieldName];

    [self getdataThroughIdWithQuery:queryString inDictionary:dictionary];

    return dictionary;
}

+(void)getdataThroughIdWithQuery:(NSString *)queryString inDictionary:(NSMutableDictionary *)dictionary{
    
//    SXLogInfo(@"queryString:%@", queryString);
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            
            SQLResultSet * resultSet = [db executeQuery:queryString];
            
            while ([resultSet next]) {
                NSDictionary * dict = [resultSet resultDictionary];
                
                NSString * sourceId = [dict objectForKey:@"Id"];
                NSString * destId = [dict objectForKey:@"Id1"];
                
                if ((sourceId != nil) && ([sourceId length] > 0) && (destId != nil) && ([destId length] > 0) )
                {
                    NSMutableArray * array = [dictionary objectForKey:sourceId];
                    
                    if ((array != nil) && [array count] > 0)
                    {
                        [array addObject:destId];
                    }
                    else
                    {
                        array = [[NSMutableArray alloc] initWithCapacity:0];
                        [array addObject:destId];
                        [dictionary setObject:array forKey:sourceId];
                    }
                }
            }
            [resultSet close];
        }];
    }
}

/*
+ (NSMutableDictionary *)changedGetRecordDictionaryForObjectRelationship:(SMObjectRelationModel *)model{
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    NSString *queryString = [[NSString alloc] initWithFormat:@"SELECT tSource.id, tDestination.id FROM %@ tSource, %@ tDestination WHERE tDestination.%@ = tSource.localId", model.parentName, model.childName, model.childFieldName];
    
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            
            SQLResultSet * resultSet = [db executeQuery:queryString];
            
            while ([resultSet next]) {
                NSDictionary * dict = [resultSet resultDictionary];
                
                NSString * sourceId = [dict objectForKey:@"Id"];
                NSString * destId = [dict objectForKey:@"Id1"];
                
                if ((sourceId != nil) && ([sourceId length] > 0) && (destId != nil) && ([destId length] > 0) )
                {
                    NSMutableArray * array = [dictionary objectForKey:sourceId];
                    
                    if ((array != nil) && [array count] > 0)
                    {
                        [array addObject:destId];
                    }
                    else
                    {
                        array = [[NSMutableArray alloc] initWithCapacity:0];
                        [array addObject:destId];
                        [dictionary setObject:array forKey:sourceId];
                    }
                }
            }
            [resultSet close];
        }];
    }
    
        queryString = [[NSString alloc] initWithFormat:@"SELECT tSource.id, tDestination.id FROM %@ tSource, %@ tDestination WHERE tDestination.%@ = tSource.id", model.parentName, model.childName, model.childFieldName];
    
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            
            SQLResultSet * resultSet = [db executeQuery:queryString];
            
            while ([resultSet next]) {
                NSDictionary * dict = [resultSet resultDictionary];
                
                NSString * sourceId = [dict objectForKey:@"Id"];
                NSString * destId = [dict objectForKey:@"Id1"];
                
                if ((sourceId != nil) && ([sourceId length] > 0) && (destId != nil) && ([destId length] > 0) )
                {
                    NSMutableArray * array = [dictionary objectForKey:sourceId];
                    
                    if ((array != nil) && [array count] > 0)
                    {
                        [array addObject:destId];
                    }
                    else
                    {
                        array = [[NSMutableArray alloc] initWithCapacity:0];
                        [array addObject:destId];
                        [dictionary setObject:array forKey:sourceId];
                    }
                }
            }
            [resultSet close];
        }];
    }
    
    
    return dictionary;
}
*/

+ (NSMutableArray *)getAllRelatedChildIdsForParentIds:(NSString *)childObject
                                            parentIds:(NSArray *)Ids
                                               column:(NSString *)columnName
{
    NSMutableArray * ids = [[NSMutableArray alloc] initWithCapacity:0];
    
    DBCriteria *criteria = [[DBCriteria alloc]initWithFieldName:columnName
                                                   operatorType:SQLOperatorIn
                                                 andFieldValues:Ids];
    
    DBRequestSelect *selectQuery = [[DBRequestSelect alloc]initWithTableName:childObject
                                                               andFieldNames:@[@"Id"]
                                                              whereCriterias:@[criteria]
                                                        andAdvanceExpression:nil];
    
    
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            
            SQLResultSet * resultSet = [db executeQuery:[selectQuery query]];
            
            while ([resultSet next]) {
                NSDictionary * dict = [resultSet resultDictionary];
                NSString *recordId = [dict objectForKey:@"Id"];
                if ((recordId != nil) && recordId.length) {
                    [ids addObject:recordId];
                }
            }
            [resultSet close];
        }];
    }
    return ids;
}

+ (NSMutableArray *)getAllProductManualId:(NSArray *)ids
{
    NSMutableArray * productManualIds = [[NSMutableArray alloc] initWithCapacity:0];
    id service = [FactoryDAO serviceByServiceType:ServiceTypeProductManual];
    if ([service conformsToProtocol:@protocol(ProductManualDAO)]) {
        
        
        DBCriteria *criteria = [[DBCriteria alloc]initWithFieldName:@"ProductId"
                                                       operatorType:SQLOperatorIn
                                                     andFieldValues:ids];
        
        DBRequestSelect *selectQuery = [[DBRequestSelect alloc]initWithTableName:@"ProductManual"
                                                                   andFieldNames:@[@"prod_manual_Id"]
                                                                  whereCriterias:@[criteria]
                                                            andAdvanceExpression:nil];
        
        @autoreleasepool {
            DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
            
            [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
                
                SQLResultSet * resultSet = [db executeQuery:[selectQuery query]];
                
                while ([resultSet next]) {
                    NSDictionary * dict = [resultSet resultDictionary];
                    NSString *recordId = [dict objectForKey:@"prod_manual_Id"];
                    if ((recordId != nil) && recordId.length) {
                        [productManualIds addObject:recordId];
                    }
                }
                [resultSet close];
            }];
        }
    }
    return productManualIds;
}

+ (NSMutableSet *) getAllRecordsForObject:(NSString *)objectName{
    
    NSMutableSet * ids = [[NSMutableSet alloc] initWithCapacity:0];
    
    DBRequestSelect *selectQuery = [[DBRequestSelect alloc]initWithTableName:objectName
                                                               andFieldNames:@[@"Id"]
                                                               whereCriteria:nil];
    
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            
            SQLResultSet * resultSet = [db executeQuery:[selectQuery query]];
            
            while ([resultSet next]) {
                NSDictionary * dict = [resultSet resultDictionary];
                NSString *recordId = [dict objectForKey:@"Id"];
                if ((recordId != nil) && recordId.length) {
                    [ids addObject:recordId];
                }
            }
            [resultSet close];
        }];
    }
    return ids;
}

+ (void)cleanupDatabase {
    
}

+ (void)clearDataPurgeTableContents
{
    id service = [FactoryDAO serviceByServiceType:ServiceTypeDataPurge];
    if ([service conformsToProtocol:@protocol(DataPurgeDAO)]) {
        DBRequestDelete *delQuery = [[DBRequestDelete alloc]initWithTableName:kDataPurgeHeapTable];
        BOOL status = [service executeStatement:[delQuery query]];
        if (!status) {
            
        }
    }
}

#pragma mark -End

#pragma Configuration time management

+ (NSDate *)lastSuccessConfigSyncTimeForDataPurge
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (userDefaults)
    {
        return [userDefaults objectForKey:kDataPurgeLastSuccessfulConfigSyncStartTime];
    }
    return nil;
}

// Save Configuration Time
+ (void)startedConfigSyncTime
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (userDefaults)
    {
        [userDefaults setObject:[NSDate date] forKey:kDataPurgeConfigSyncStartTime];
        [userDefaults synchronize];
    }
}

+ (void)saveConfigSyncTimeSinceSyncCompleted
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (userDefaults)
    {
        NSDate *date =  [userDefaults objectForKey:kDataPurgeConfigSyncStartTime];
        if (date) {
            [userDefaults setObject:date forKey:kDataPurgeLastSuccessfulConfigSyncStartTime];
            [userDefaults synchronize];
        }
    }
}

//Data Purge time
+ (void)saveDataPurgeTimeSinceCompleted
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (userDefaults)
    {
        [userDefaults setObject:[NSDate date] forKey:kDataPurgeLastSyncTime];
        [userDefaults synchronize];
    }
}


+ (void)updateNextDataPurgeTime:(NSDate *)date
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (userDefaults)
    {
        [userDefaults setObject:date forKey:kDataPurgeNextSyncTime];
        [userDefaults synchronize];
    }
}


+ (void)saveDataPurgeStatusSinceCompleted:(NSString *)status
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (userDefaults)
    {
        [userDefaults setObject:status forKey:kDataPurgeStatus];
        [userDefaults synchronize];
    }
}


+ (void)saveIfDataPurgeDue:(BOOL)isDue
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (userDefaults)
    {
        [userDefaults setBool:isDue forKey:kDataPurgeHasConfigSyncInDue];
        [userDefaults synchronize];
    }
}


+ (BOOL)isPurgeDue
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (userDefaults)
    {
        return [userDefaults boolForKey:kDataPurgeHasConfigSyncInDue];
    }
    return NO;
}


+ (NSString *)lastDataPurgeStatus;
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (userDefaults)
    {
        return [userDefaults valueForKey:kDataPurgeStatus];
    }
    return nil;
}

+ (BOOL)isLastDataPurgeTimeExceeded:(NSDate *)date
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (userDefaults)
    {
        NSDate * nextDataPurge = [userDefaults valueForKey:kDataPurgeNextSyncTime];
        
        NSComparisonResult result = [date compare:nextDataPurge];
        
        if (result == NSOrderedDescending || result == NSOrderedSame)
        {
            return YES;
        }
    }
    return NO;
}


+ (NSDate *)retrieveLastSuccesDPTime
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (userDefaults)
    {
        return [userDefaults objectForKey:kDataPurgeLastSyncTime];
    }
    return nil;
}


+ (NSDate *)retrieveNextDPTime
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (userDefaults)
    {
        return [userDefaults objectForKey:kDataPurgeNextSyncTime];
    }
    return nil;
}

+ (NSString *)getDataPurgeGracelimit
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (userDefaults)
    {
        return [userDefaults objectForKey:kWSAPIResponseDataPurgeRecordOlderThan];
    }
    return @"";
}

+(NSMutableDictionary *)retieveKeyPrefixWithObjecName;
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithCapacity:0];
    
    id sfObjectService = [FactoryDAO serviceByServiceType:ServiceTypeSFObject];
    if ([sfObjectService conformsToProtocol:@protocol(SFObjectDAO)]) {
        
        NSArray *filedNames = @[@"keyPrefix",@"objectName"];
        DBCriteria *criteria = nil;
        NSArray *models = [sfObjectService fetchRecordsByFields:filedNames
                                                    andCriteria:criteria];
        if ([models count]) {
            for (SFObjectModel *model in models) {
                if (model.objectName && model.keyPrefix) {
                    [dict setObject:model.objectName forKey:model.keyPrefix];
                }
            }
        }
    }
    return dict;
}

+ (void)getAllGarceLimitRecrordsForModel:(SMDataPurgeModel *)model
                                criteria:(DBCriteria *)criteria
                         trialerCriteria:(DBCriteria *)trialerCriteria
{
    NSMutableArray * recordIds = [self getGraceOrNonGraceRecord:model.name
                                                 filterCriteria:criteria
                                                trialerCriteria:trialerCriteria];
    
    if (model != nil && (![model isAttachmentObject]))
    {
        for (NSString * Id in recordIds)
        {
            [model addGracePeriodRecord:Id];
        }
    }
}

+ (void)getAllNonGraceLimitRecrordsForModel:(SMDataPurgeModel *)model
                                   criteria:(DBCriteria *)criteria
                            trialerCriteria:(DBCriteria *)trialerCriteria
{
    NSMutableArray * recordIds = [self getGraceOrNonGraceRecord:model.name filterCriteria:criteria trialerCriteria:trialerCriteria];
    
    if (model != nil)
    {
        for (NSString * Id in recordIds)
        {
            [model addPurgeableNonGracePeriodRecords:Id];
        }
    }
}


+ (void)getNonGracePeriodTrailerTableRecords:(SMDataPurgeModel *)model trailerCriteria:(DBCriteria *)trailerCriteria;
{
    NSMutableArray * recordIds = [self getNonGraceTrailerRecord:model.name trialerCriteria:trailerCriteria];
    
    @autoreleasepool
    {
        for (NSString * sfId in recordIds)
        {
            [model addPurgeableTrailerTableRecords:sfId];
        }
    }
}


+ (void)getAllGarceDODRecrds:(SMDataPurgeModel *)model filterCriteria:(DBCriteria *)criteria
{
    DBCriteria *criteria1 = [[DBCriteria alloc]initWithFieldName:@"objectName"
                                                    operatorType:SQLOperatorEqual
                                                   andFieldValue:model.name];
    
    NSMutableArray * recordIds = [self getGraceOrNonGraceDODRecord:@[criteria,criteria1]];
    
    if (model != nil && (![model isAttachmentObject]))
    {
        for (NSString * Id in recordIds)
        {
            [model addNonPurgeableDODRecord:Id];
        }
    }
    
}


+ (void)getAllGraceNonGraceDODRecords:(SMDataPurgeModel *)model filterCriteria:(DBCriteria *)criteria
{
    DBCriteria *criteria1 = [[DBCriteria alloc]initWithFieldName:@"objectName"
                                                    operatorType:SQLOperatorEqual
                                                   andFieldValue:model.name];
    
    NSMutableArray * recordIds = [self getGraceOrNonGraceDODRecord:@[criteria1]];
    DBCriteria *lmdCriteria = [[DBCriteria alloc]initWithFieldName:@"LastModifiedDate" operatorType:SQLOperatorLessThan andFieldValue:criteria.rhsValue];
    DBCriteria *sfIdCriteria = [[DBCriteria alloc]initWithFieldName:@"Id" operatorType:SQLOperatorIn andFieldValues:recordIds];
    id transactionService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    NSArray *transactionModels = [transactionService fetchDataForObject:model.name
                                                                 fields:@[kId]
                                                             expression:@"(1 AND 2)"
                                                               criteria:@[sfIdCriteria,lmdCriteria]];
    NSMutableArray *purgeableRecordIds = [NSMutableArray new];
    
    for (TransactionObjectModel *objectModel in transactionModels) {
        NSDictionary *fieldValueDict = [objectModel getFieldValueDictionary];
        if ([fieldValueDict objectForKey:kId]) {
            [purgeableRecordIds addObject:[fieldValueDict objectForKey:kId]];
        }
    }

    if (model != nil)
    {
        for (NSString * Id in recordIds)
        {
            if ([purgeableRecordIds containsObject:Id]) {
                [model addPurgeableDODRecord:Id];
            }
            else{
                [model addNonPurgeableDODRecord:Id];
            }
            
        }
    }
}


+ (NSMutableArray *)getAllEventRelatedWhatId
{
    return [self getEventRelatedRecords];
}


+ (NSMutableArray *)getAllChildIdsForObject:(SMObjectRelationModel *)relatioModel
                                   parentId:(NSMutableArray *)Ids
                                 parentName:(NSString *)parentObject
{
    NSArray * childRelatedData = [[NSArray alloc] initWithObjects:relatioModel.childName,relatioModel.childFieldName, nil];
    NSMutableArray * chunks  = [[NSMutableArray alloc] init];
    NSString * idSeparetedByComas = nil;
    NSMutableArray * childRecordIds = nil;
    
    NSMutableArray *  resultIds = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (int i = 0; i < [Ids count]; i++)
    {
        if ([chunks count] == 1000)
        {
            idSeparetedByComas = [self idSeparetedByComas:chunks];
            childRecordIds = [self getChildIdsRelatedToEventParentId:childRelatedData parentId:idSeparetedByComas parentName:parentObject];
            [resultIds addObjectsFromArray:childRecordIds];
            [chunks removeAllObjects];
        }
        [chunks addObject:[Ids objectAtIndex:i]];
    }
    if ([chunks count] > 0)
    {
        idSeparetedByComas = [self idSeparetedByComas:chunks];
        childRecordIds = [self getChildIdsRelatedToEventParentId:childRelatedData parentId:idSeparetedByComas parentName:parentObject];
        [resultIds addObjectsFromArray:childRecordIds];
        [chunks removeAllObjects];
    }
    
    return resultIds;
}


+(void)purgeDataForObject:(SMDataPurgeModel *)model
{
    if ( (model != nil) && (model.isPurgeable))
    {
        NSMutableSet * recordIds =  [self getAllRecordsForObject:model.name];
        SXLogDebug(@"Set All Records Id = %@", recordIds);
        NSMutableSet * backUpIds = [recordIds copy];
        [recordIds minusSet:model.nonPurgeableRecordSet];
        model.purgeableRecordSet = [[NSMutableSet alloc] initWithSet:recordIds copyItems:YES];
        SXLogDebug(@"Set All Purgeable RecordSet Id = %@", [model.purgeableRecordSet description]);
        SXLogDebug(@"Set All Backup Id = %@", backUpIds);
    }
}

+ (void)fillPurgeableRecordForIsolatedChild:(SMDataPurgeModel *)model parent:(SMDataPurgeModel *)parentModel
                                     column:(NSString *)columnName
{
    NSMutableSet * purgeableChilsIds = nil;
    
    NSMutableSet * nonPurgeableChildIds = nil;
    
    if ( (parentModel != nil) && (parentModel.isPurgeable))
    {
        if (parentModel.purgeableRecordSet != nil)
        {
            purgeableChilsIds = [self getPurgeableOrNonPurgableRecordForIsolatedChild:model.name ids:parentModel.purgeableRecordSet column:columnName];
        }
        if (parentModel.nonPurgeableRecordSet != nil)
        {
            nonPurgeableChildIds = [self getPurgeableOrNonPurgableRecordForIsolatedChild:model.name ids:parentModel.nonPurgeableRecordSet column:columnName];
        }
        
        [model.purgeableRecordSet minusSet:nonPurgeableChildIds];
        [model.nonPurgeableRecordSet unionSet:nonPurgeableChildIds];
        [self updatePurgableSetForChild:model purgableset:purgeableChilsIds];
    }
}

+ (NSMutableSet *)getPurgeableOrNonPurgableRecordForIsolatedChild:(NSString *)object ids:(NSMutableSet *)parentIds
                                                           column:(NSString *)columnName
{
    NSMutableArray * childRecordIds = nil;
    
    NSMutableSet * ids = [[NSMutableSet alloc] initWithCapacity:0];
    
    if (parentIds != nil)
    {
        NSMutableArray * chunks  = [[NSMutableArray alloc] init];
        NSString * idSeparetedByComas = nil;
        
        NSArray *recordIDs  = [[NSArray alloc] initWithArray:[parentIds allObjects] copyItems:YES];
        for (int i = 0; i < [recordIDs count]; i++)
        {
            if ([chunks count] == 1000)
            {
                childRecordIds = [self getAllRelatedChildIdsForParentIds:object parentIds:chunks column:columnName];
                [ids addObjectsFromArray:childRecordIds];
                [chunks removeAllObjects];
            }
            NSString *recordId = [[recordIDs objectAtIndex:i] copy];
            [chunks addObject:recordId];
        }
        
        SXLogDebug(@"Chunks for retrieving child records = %@, Records = %@", object,
                   [chunks description]);
        if ([chunks count] > 0)
        {
            idSeparetedByComas = [self idSeparetedByComas:chunks];
            childRecordIds = [self getAllRelatedChildIdsForParentIds:object parentIds:chunks column:columnName];
            [ids addObjectsFromArray:childRecordIds];
            [chunks removeAllObjects];
        }
    }
    return ids;
}

+ (void)updatePurgableSetForChild:(SMDataPurgeModel *)model purgableset:(NSMutableSet *)set
{
    if (model.purgeableRecordSet != nil)
    {
        [model.nonPurgeableRecordSet minusSet:set];
        [model.purgeableRecordSet unionSet:set];
    }
}

+ (NSMutableDictionary *)retrieveConflictRecordMap
{
    return [self getConflictRecordMap];
}

+ (void)retrievePurgeableConflictRecordForModel:(SMDataPurgeModel *)model conflictMap:(NSMutableDictionary *)confictMapDict
{
    @autoreleasepool
    {
        if ((confictMapDict != nil) && [confictMapDict count] > 0 && [confictMapDict objectForKey:model.name])
        {
            if (model != nil)
            {
                NSMutableArray * recordIds = [confictMapDict objectForKey:model.name];
                for (NSString * sfid in recordIds)
                {
                    if (![[model nonPurgeableRecordSet] containsObject:sfid])
                    {
                        [model addPurgeableConflictRecords:sfid];
                    }
                }
            }
        }
    }
}

+ (NSArray *)getAllTransactionalObjectName
{
    NSArray *transactionalObjects = nil;
    NSSet *nameSet = [self getDistinctObjectApiNames];
    
    if ((nameSet != nil) && ([nameSet count] > 0))
    {
        transactionalObjects = [[NSArray alloc] initWithArray:[nameSet allObjects]];
    }
    else
    {
        transactionalObjects = [[NSArray alloc] init];
    }
    
    return transactionalObjects;
}

+ (BOOL)isEmptyTable:(NSString *)tableName
{
    id service = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    if ([service conformsToProtocol:@protocol(TransactionObjectDAO)]) {
        return [service isTransactiontableEmpty:tableName];
    }
    return NO;
}


+ (NSArray *)findAndFillChildAndRelatedObjectForModel:(SMDataPurgeModel *)model
{
    return [self getRelationshipForObject:model.name];
}


+ (void)processedPurgeableIds:(NSMutableArray *)chunks forObject:(NSString *)objectName
{
    SXLogDebug(@"chunk to be deleted %@", [chunks description]);
    [self purgeRecordForObject:objectName data:chunks];
}


+ (void)executeDataPurging:(SMDataPurgeModel *)model
{
    SXLogDebug(@"Purgeable record set for model = %@, Records = %@", model.name , [model.purgeableRecordSet description]);
    if ([model isAttachmentObject])
    {
        //Ask helper to delete the related object of the attachment
        [self purgeRelatedRecordsForAttachment:model];
    }
    else if ([model.name isEqualToString:kDataPurgeProduct])
    {
        [self purgeRelatedRecordsForProduct:model];
    }
    NSMutableArray * chunks  = [[NSMutableArray alloc] init];
    
    NSArray *recordIDs  = [[NSArray alloc] initWithArray:[model.purgeableRecordSet allObjects] copyItems:YES];
    for (int i = 0; i < [recordIDs count]; i++)
    {
        if ([chunks count] == 1000)
        {
            [self processedPurgeableIds:chunks
                              forObject:model.name];
            
            [chunks removeAllObjects];
        }
        
        NSString *recordId = [[recordIDs objectAtIndex:i] copy];
        [chunks addObject:recordId];
    }
    SXLogDebug(@"Chunks sending for model = %@, Records = %@", model.name , [chunks description]);
    if ([chunks count] > 0)
    {
        [self processedPurgeableIds:chunks
                          forObject:model.name];
        [chunks removeAllObjects];
    }
    
    model.status = DPActionStatusCompleted;
}


+ (NSArray *)getRelatedRecordNameForTable:(NSString *)tableNameOrApiName;
{
    NSArray * relatedObject = nil;
    
    //For product, below are the related table to be purged
    if ([tableNameOrApiName isEqualToString:kDataPurgeProduct])
    {
        relatedObject = [[NSArray alloc] initWithObjects:kDataPurgeTrobleShoot, kDataPurgeProductImage, nil];
    }
    
    else if ([tableNameOrApiName isEqualToString:kDataPurgeProduct])
    {
        relatedObject = [[NSArray alloc] initWithObjects:kDataPurgeTrobleShoot, kDataPurgeProductImage, nil];
    }
    return relatedObject;
}


+ (NSString *)idSeparetedByComas:(NSArray *)chunks
{
    NSString *idSeparetedByComas = nil;
    
    if ([chunks count] > 1)
    {
        NSString *baseString = [chunks componentsJoinedByString:@"','"];
        idSeparetedByComas = [NSString stringWithFormat:@"'%@'", baseString];
    }
    else
    {
        idSeparetedByComas = [NSString stringWithFormat:@"'%@'", [chunks objectAtIndex:0]];
    }
    
    return idSeparetedByComas;
}

+ (void)purgeRelatedRecordsForAttachment:(SMDataPurgeModel *)model
{
    NSMutableArray * chunks  = [[NSMutableArray alloc] init];
    NSArray *recordIDs  = [[NSArray alloc] initWithArray:[model.purgeableRecordSet allObjects] copyItems:YES];
    
    @autoreleasepool
    {
        for (int i = 0; i < [recordIDs count]; i++)
        {
            if ([chunks count] == 1000)
            {
                [self processPurgableRecordsForAttachment:chunks objectName:model.name];
                [chunks removeAllObjects];
            }
            [chunks addObject:[recordIDs objectAtIndex:i]];
        }
        if ([chunks count] > 0)
        {
            [self processPurgableRecordsForAttachment:chunks objectName:model.name];
            [chunks removeAllObjects];
        }
    }
}


+ (void)processPurgableRecordsForAttachment:(NSMutableArray *)chunks objectName:(NSString *)objectName
{
    NSMutableArray *localIds;
    localIds = [self getAllLocalIdsForSfId:chunks objectName:objectName];
    [AttachmentHelper deleteAttachmentsWithLocalIds:localIds];
}


+ (void)purgeRelatedRecordsForProduct:(SMDataPurgeModel *)model
{
    NSMutableArray *chunks  = [[NSMutableArray alloc] init];
    NSArray *recordIDs  = [[NSArray alloc] initWithArray:[model.purgeableRecordSet allObjects] copyItems:YES];
    
    @autoreleasepool
    {
        for (int i = 0; i < [recordIDs count]; i++)
        {
            if ([chunks count] == 1000)
            {
                [self processPurgableRecordsForProduct:chunks];
                [chunks removeAllObjects];
            }
            [chunks addObject:[recordIDs objectAtIndex:i]];
        }
        if ([chunks count] > 0)
        {
            [self processPurgableRecordsForProduct:chunks];
            [chunks removeAllObjects];
        }
    }
}


+ (void)processPurgableRecordsForProduct:(NSMutableArray *)ids
{
    [self deleteProductRelatedFile:ids];
    if ([ids count])
    {
        [TroubleshootingDataHelper deleteTroubleShootFilesForTheIds:ids];
        [self purgeRecordFromRealatedTables:@"TroubleshootData" column:@"Id" data:ids];
        [self purgeRecordFromRealatedTables:@"ProductImage" column:@"productId" data:ids];
    }
}

+ (void)deleteProductRelatedFile:(NSArray *)ids
{
    NSMutableArray * productMaulaId = nil;
    if (ids != nil)
    {
        productMaulaId = [self getAllProductManualId:ids];
    }
    
    NSString * documentsDirectoryPath = [FileManager getProductManualSubDirectoryPath];
    
    for (NSString * productId in productMaulaId)
    {
        NSString * filePath = [documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",productId, @".pdf"]];
        NSFileManager * fileManager = [NSFileManager defaultManager];
        NSError * error = nil;
        if ([fileManager fileExistsAtPath:filePath])
        {
            [fileManager removeItemAtPath:filePath error:&error];
        }
    }
    [self purgeRecordFromRealatedTables:@"ProductManual" column:@"prod_manual_Id" data:productMaulaId];
}

+ (void)checkForDODTrailerAndConflictRecrdToPurge:(SMDataPurgeModel *)model
{
    NSMutableArray * chunks  = [[NSMutableArray alloc] init];
    NSString *idSeparetedByComas = nil;
    
    if ([model purgeableDODRecords] != nil && [[model purgeableDODRecords] count] > 0)
    {
        @autoreleasepool
        {
            NSMutableArray  * recordIDs = [model purgeableDODRecords];
            
            for (int i = 0; i < [recordIDs count]; i++)
            {
                if ([chunks count] == 1000)
                {
                    idSeparetedByComas = [self idSeparetedByComas:chunks];
                    [self purgeAllDODTrailerAndConflictTableRecord:@"DODRecords"
                                                            column:@"sfId"
                                                        deletingId:chunks];
                    [chunks removeAllObjects];
                }
                [chunks addObject:[recordIDs objectAtIndex:i]];
            }
            if ([chunks count] > 0)
            {
                [self purgeAllDODTrailerAndConflictTableRecord:@"DODRecords"
                                                        column:@"sfId"
                                                    deletingId:chunks];
                [chunks removeAllObjects];
            }
        }
        
    }
    if ([model purgeableTrailerTableRecords] != nil && [[model purgeableTrailerTableRecords] count] > 0)
    {
        @autoreleasepool
        {
            NSMutableArray  * recordIDs = [model purgeableTrailerTableRecords];
            
            for (int i = 0; i < [recordIDs count]; i++)
            {
                if ([chunks count] == 1000)
                {
                    [self purgeAllDODTrailerAndConflictTableRecord:kModifiedRecords
                                                            column:@"sfId"
                                                        deletingId:chunks];
                    [chunks removeAllObjects];
                }
                [chunks addObject:[recordIDs objectAtIndex:i]];
            }
            if ([chunks count] > 0)
            {
                [self purgeAllDODTrailerAndConflictTableRecord:kModifiedRecords
                                                        column:@"sfId"
                                                    deletingId:chunks];
                [chunks removeAllObjects];
            }
        }
        
    }
    if ([model purgeableConflictRecords] != nil && [[model purgeableConflictRecords] count] > 0)
    {
        @autoreleasepool
        {
            NSMutableArray  * recordIDs = [model purgeableConflictRecords];
            
            for (int i = 0; i < [recordIDs count]; i++)
            {
                if ([chunks count] == 1000)
                {
                    [self purgeAllDODTrailerAndConflictTableRecord:kSyncErrorConflictTableName
                                                            column:@"sfId"
                                                        deletingId:chunks];
                    [chunks removeAllObjects];
                }
                [chunks addObject:[recordIDs objectAtIndex:i]];
            }
            if ([chunks count] > 0)
            {
                [[self class] purgeAllDODTrailerAndConflictTableRecord:kSyncErrorConflictTableName
                                                                column:@"sfId"
                                                            deletingId:chunks];
                [chunks removeAllObjects];
            }
            /*
             * Since we have change in SyncErrorConflict table lets trigger notification so that resolve conflict screen can refresh.
             */
            [ResolveConflictsHelper sendSyncConflictChangeNotificationWithObject:self];
        }
    }
}


+ (void)purgeAllDODTrailerAndConflictTableRecord:(NSString *)tableName
                                          column:(NSString *)columnName
                                      deletingId:(NSArray *)ids
{
    [self purgeRecordFromRealatedTables:tableName column:columnName data:ids];
}


+ (NSMutableDictionary *)relationshipKeyDictionaryForRelationshipModel:(SMObjectRelationModel *)model
{
    return  [self getRecordDictionaryForObjectRelationship:model];
}


+ (void)initiateDataBaseCleanUp
{
    [self cleanupDatabase];
}


+ (NSString *)getDataPurgeRecordOlderThanSettingsValue
{
    NSString *value;
    id mobileSettingService = [FactoryDAO serviceByServiceType:ServiceTypeMobileDeviceSettings];
    if ([mobileSettingService conformsToProtocol:@protocol(MobileDeviceSettingDAO)]) {
        
        MobileDeviceSettingsModel *model = [mobileSettingService fetchDataForSettingId:kWSAPIResponseDataPurgeRecordOlderThan];
        value = model.value;
    }
    return value;
}

+ (NSTimeInterval)getTimerIntervalForDataPurge
{
    NSString * purgeFrequency = [self getDataPurgeFrequencySettingsValue];
    
    int value = [purgeFrequency intValue];
    
    NSTimeInterval scheduledTimer = 0;
    
    if (value != 0)
    {
        if (![purgeFrequency isEqualToString:@""] && ([purgeFrequency length] > 0) )
        {
            double timeInterval = [purgeFrequency doubleValue];
            
            scheduledTimer = timeInterval * 60 * 60;
        }
    }
    return scheduledTimer;
}


+ (NSString *)getDataPurgeFrequencySettingsValue {
    
    NSString *value;
    id mobileSettingService = [FactoryDAO serviceByServiceType:ServiceTypeMobileDeviceSettings];
    if ([mobileSettingService conformsToProtocol:@protocol(MobileDeviceSettingDAO)]) {
        
        MobileDeviceSettingsModel *model = [mobileSettingService fetchDataForSettingId:kWSAPIResponseDataPurgeFrequency];
        value = model.value;
    }
    return value;
}

+ (NSMutableDictionary *)populatePurgeMapFromDataPurgeTable {

    NSMutableDictionary *purgeMap = [[NSMutableDictionary alloc]initWithCapacity:0];
    
    id service = [FactoryDAO serviceByServiceType:ServiceTypeDataPurge];
    
    if ([service conformsToProtocol:@protocol(DataPurgeDAO)]) {
        
        NSArray *models = [service fetchDistinctObjectNames];
        if ([models count]) {
            for (DataPurgeModel *model in models) {
                if ([model.objectName length]) {
                    
                    SMDataPurgeModel *purgeModel = [[SMDataPurgeModel alloc]initWithName:model.objectName];
                    NSMutableArray *sfIds = [service fetchSfIdsForObjectName:model.objectName];
                    if ([sfIds count]) {
                        NSMutableArray *listOfSfids = [[NSMutableArray alloc]initWithCapacity:0];
                        for (DataPurgeModel *sfIdModel in sfIds) {
                            if (sfIdModel.sfId.length) {
                                [listOfSfids addObject:sfIdModel.sfId];
                            }
                        }
                        purgeModel.advancedOrDownloadedCriteriaRecords = listOfSfids;
                    }
                    [purgeMap setObject:purgeModel forKey:model.objectName];
                }
            }
        }
    }
    return purgeMap;
}
#pragma mark - ProductIQ related methods
+ (void)saveLocationSfIdsFromDataPurgeTableForWorkOrderObject {
    
    @autoreleasepool {
        
        id service = [FactoryDAO serviceByServiceType:ServiceTypeDataPurge];
        
        if ([service conformsToProtocol:@protocol(DataPurgeDAO)]) {
            NSArray *workOrderSfIds = [service fetchSfIdsForObjectName:kWorkOrderTableName];
            
            if ([workOrderSfIds count]) {
                NSMutableArray *listOfSfids = [[NSMutableArray alloc]initWithCapacity:0];
                for (DataPurgeModel *sfIdModel in workOrderSfIds) {
                    if (sfIdModel.sfId.length) {
                        [listOfSfids addObject:sfIdModel.sfId];
                    }
                }
                
                if (listOfSfids.count > 0) {
                    
                    NSString *locationObjName = kWorkOrderSite;
                    
                    id <TransactionObjectDAO>  transObj = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
                    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:locationObjName operatorType:SQLOperatorIn andFieldValues:listOfSfids];
                    
                    NSArray * transactionRecords =  [transObj fetchDataWithhAllFieldsAsStringObjects:kWorkOrderTableName fields:@[locationObjName] expression:nil criteria:@[criteria]];

                    NSMutableArray *dataPurgeArray = [[NSMutableArray alloc] initWithCapacity:0];
                    
                    for (TransactionObjectModel *model in transactionRecords) {
                        NSString *sfID = [[model getFieldValueDictionary] objectForKey:locationObjName];
                        DataPurgeModel *model = [DataPurgeModel new];
                        model.sfId = sfID;
                        model.objectName = locationObjName;
                        
                        [dataPurgeArray addObject:model];
                    }
                    
                    if (dataPurgeArray.count > 0) {
                        [[self class] saveModelsToDataPurgeTable:dataPurgeArray];
                    }
                }
            }
            
        }
    }
}
+ (BOOL)saveModelsToDataPurgeTable:(NSMutableArray *)models {
    
    BOOL status = NO;
    if ([models count]) {
        id service = [FactoryDAO serviceByServiceType:ServiceTypeDataPurge];
        if ([service conformsToProtocol:@protocol(DataPurgeDAO)]) {
            status = [service saveRecordModels:models];
            if (status) {
                /** Success **/
            }
        }
    }
    return status;
}
@end
