//
//  SMDataPurgeHelper.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 1/6/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import "SMDataPurgeHelper.h"
#import "AttachmentUtility.h"

@implementation SMDataPurgeHelper

#pragma Configuration time management

+ (AppDelegate *)getAppdelgateInstance
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


+ (DataBase *)getDatabaseConnection
{
    AppDelegate * appDelegate = [self  getAppdelgateInstance];
    return appDelegate.dataBase;
}


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
        [userDefaults setObject:date forKey:kDataPurgeLastSuccessfulConfigSyncStartTime];
        [userDefaults synchronize];
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
    //[self saveConfigSyncTimeSinceSyncCompleted];
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


+ (NSArray *) getAllRecordsFromDatabase:(NSArray *)data
{
    
    return [[self getDatabaseConnection] getAllRecordsFromTable:[data objectAtIndex:0]
                                      forColumns:[data objectAtIndex:1]
                                  filterCriteria:[data objectAtIndex:2]
                                           limit:[data objectAtIndex:3]];
}

+ (NSArray *) getUniqueRecordsFromDatabase:(NSArray *)data
{
    
    return [[self getDatabaseConnection] getUniqueRecordsFromTable:[data objectAtIndex:0]
                                                            forColumn:[data objectAtIndex:1]
                                                            filterCriteria:[data objectAtIndex:2]];
}


//Get keyprefix and its objectname from database
+(NSMutableDictionary *)retieveKeyPrefixWithObjecName;
{
    return [[self getDatabaseConnection] getKeyPrefixWithObjectNameFromSFObjectTable];
}

+ (NSString *)retrieveObjectNameForWhatId:(NSString *)whatId
{
    return [[self getDatabaseConnection] getObjectNameForWhatId:whatId];
}


+ (void)getAllGarceLimitRecrordsForModel:(SMDataPurgeModel *)model
                                                       criteria:(NSString *)criteria
                                                trialerCriteria:(NSString *)trialerCriteria
{
    NSMutableArray * recordIds = [[[self getDatabaseConnection] getGraceOrNonGraceRecord:model.name filterCriteria:criteria trialerCriteria:trialerCriteria] retain];
    
    if (model != nil)
    {
        for (NSString * Id in recordIds)
        {
            [model addGracePeriodRecord:Id];
        }
    }
    [recordIds release];
}

+ (void)getAllNonGraceLimitRecrordsForModel:(SMDataPurgeModel *)model
                                   criteria:(NSString *)criteria
                            trialerCriteria:(NSString *)trialerCriteria
{
    
    NSMutableArray * recordIds = [[[self getDatabaseConnection] getGraceOrNonGraceRecord:model.name filterCriteria:criteria trialerCriteria:trialerCriteria] retain];
    
    if (model != nil)
    {
        for (NSString * Id in recordIds)
        {
            [model addPurgeableNonGracePeriodRecords:Id];
        }
    }
    [recordIds release];
    
}


+ (void)getNonGracePeriodTrailerTableRecords:(SMDataPurgeModel *)model trailerCriteria:(NSString *)trailerCriteria;
{
    NSMutableArray * recordIds = [[[self getDatabaseConnection] getNonGraceTrailerRecord:model.name trialerCriteria:trailerCriteria] retain];
    
    @autoreleasepool
    {
        for (NSString * sfId in recordIds)
        {
            [model addPurgeableTrailerTableRecords:sfId];
        }
    }
    [recordIds release];
}


+ (void)getAllGarceDODRecrds:(SMDataPurgeModel *)model filterCriteria:(NSString *)criteria
{
    NSString * objectNameCriteria = [[NSString alloc] initWithFormat:@"object_name = '%@' AND %@", model.name, criteria];
    
    NSMutableArray * recordIds = [[[self getDatabaseConnection] getGraceOrNonGraceDODRecord:objectNameCriteria] retain];
    
    if (model != nil)
    {
        for (NSString * Id in recordIds)
        {
            [model addNonPurgeableDODRecord:Id];
        }
    }
    [recordIds release];
    [objectNameCriteria release];
    objectNameCriteria = nil;
}


+ (void)getAllNonGraceDODRecrds:(SMDataPurgeModel *)model filterCriteria:(NSString *)criteria
{
    NSString * objectNameCriteria = [[NSString alloc] initWithFormat:@"object_name = '%@' AND %@", model.name, criteria];
    
    NSMutableArray * recordIds = [[[self getDatabaseConnection] getGraceOrNonGraceDODRecord:objectNameCriteria] retain];
    
    if (model != nil)
    {
        for (NSString * Id in recordIds)
        {
            [model addPurgeableDODRecord:Id];
        }
    }
    [recordIds release];
    [objectNameCriteria release];
    objectNameCriteria = nil;
    
}


+ (NSMutableArray *)getAllEventRelatedWhatId
{
    return [[self getDatabaseConnection] getEventRelatedRecords];
}


+ (NSMutableArray *)getAllChildIdsForObject:(NSString *)objectName parentId:(NSString *)Id parentColumn:(NSString *)parentColumn
{
    return  [[self getDatabaseConnection] getChildIdsRelatedToParentId:objectName parentId:Id parentName:parentColumn];
}


+(void)purgeDataForObject:(SMDataPurgeModel *)model
{
    if ( (model != nil) && (model.isPurgeable))
    {
        NSMutableSet * recordIds =  [[[self getDatabaseConnection] getAllRecordsForObject:model.name] retain];
        SMLog(kLogLevelVerbose, @"Set All Records Id = %@", recordIds);
        NSMutableSet * backUpIds = [recordIds copy];
        [recordIds minusSet:model.nonPurgeableRecordSet];
        model.purgeableRecordSet = [[NSMutableSet alloc] initWithSet:recordIds copyItems:YES];
        SMLog(kLogLevelVerbose, @"Set All Purgeable RecordSet Id = %@", [model.purgeableRecordSet description]);
        SMLog(kLogLevelVerbose, @"Set All Backup Id = %@", backUpIds);
        
        [recordIds release];
        [backUpIds release];
    }
}


+ (NSMutableDictionary *)retrieveConflictRecordMap
{
    return [[self getDatabaseConnection] getConflictRecordMap];
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
                    [model addPurgeableConflictRecords:sfid];
                }
            }
        }
    }
}


+ (NSArray *)getAllTransactionalObjectName
{
    NSArray *transactionalObjects = nil;
    NSSet *nameSet = [[[self getDatabaseConnection] getDistinctObjectApiNames] retain];
    
    if ((nameSet != nil) && ([nameSet count] > 0))
    {
        transactionalObjects = [[NSArray alloc] initWithArray:[nameSet allObjects]];
    }
    else
    {
        transactionalObjects = [[NSArray alloc] init];
    }
    
    [nameSet release];
    return [transactionalObjects autorelease];
}


+ (BOOL)isEmptyTable:(NSString *)tableName
{
    return [[self getDatabaseConnection]  isTableEmpty:tableName];
}


+ (NSArray *)findAndFillChildAndRelatedObjectForModel:(SMDataPurgeModel *)model
{
    return [[self getDatabaseConnection] getRelationshipForObject:model.name];
}


+ (void)processedPurgeableIds:(NSMutableArray *)chunks forObject:(NSString *)objectName
{
    SMLog(kLogLevelVerbose,@"chunk to be deleted %@", [chunks description]);
    NSString *idSeparetedByComas = [self idSeparetedByComas:chunks];
    [[self getDatabaseConnection] purgeRecordForObject:objectName data:idSeparetedByComas];
}


+ (void)executeDataPurging:(SMDataPurgeModel *)model
{
    SMLog(kLogLevelVerbose,@"Purgeable record set for model = %@, Records = %@", model.name , [model.purgeableRecordSet description]);
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
    SMLog(kLogLevelVerbose,@"Chunks sending for model = %@, Records = %@", model.name , [chunks description]);
    if ([chunks count] > 0)
    {
        [self processedPurgeableIds:chunks
                          forObject:model.name];
        [chunks removeAllObjects];
    }
    
    model.status = DPActionStatusCompleted;
    
    [chunks release];
    chunks = nil;
    [recordIDs release];
    recordIDs = nil;
    
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
    return [relatedObject autorelease];
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
        }
        if ([chunks count] > 0)
        {
            [self processPurgableRecordsForAttachment:chunks objectName:model.name];
            [chunks removeAllObjects];
        }
    }
    [chunks release];
    chunks = nil;
    [recordIDs release];
    recordIDs = nil;
}


+ (void)processPurgableRecordsForAttachment:(NSMutableArray *)chunks objectName:(NSString *)objectName
{
    NSMutableArray *localIds = nil;
    
    NSString *idSeparetedByComas = [self idSeparetedByComas:chunks];
    
    localIds = [[[self getDatabaseConnection] getAllLocalIdsForSfId:idSeparetedByComas objectName:objectName] retain];
    
    [AttachmentUtility deleteAttachmentRecordsFromRelatedTable:localIds];
    
    [localIds release];
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
        }
        if ([chunks count] > 0)
        {
            [self processPurgableRecordsForProduct:chunks];
            [chunks removeAllObjects];
        }
    }
    [chunks release];
    chunks = nil;
    [recordIDs release];
    recordIDs = nil;
}


+ (void)processPurgableRecordsForProduct:(NSMutableArray *)ids
{
    NSString *idSeparetedByComas = [self idSeparetedByComas:ids];
    
    if (idSeparetedByComas != nil)
    {
        [[self getDatabaseConnection] purgeRecordFromRealatedTables:@"trobleshootdata" column:@"ProductId" data:idSeparetedByComas];
        [[self getDatabaseConnection] purgeRecordFromRealatedTables:@"ProductImage" column:@"productId" data:idSeparetedByComas];
    }
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
                    [self purgeAllDODTrailerAndConflictTableRecord:@"on_demand_download" column:@"sf_id" deletingId:idSeparetedByComas];
                    [chunks removeAllObjects];
                }
            }
            if ([chunks count] > 0)
            {
                idSeparetedByComas = [self idSeparetedByComas:chunks];
                [self purgeAllDODTrailerAndConflictTableRecord:@"on_demand_download" column:@"sf_id" deletingId:idSeparetedByComas];
                [chunks removeAllObjects];
            }
        }
        
    }
    if ([model purgeableTrailerTableRecords] != nil && [[model purgeableTrailerTableRecords] count] > 0)
    {
        @autoreleasepool
        {
            NSMutableArray  * recordIDs = [model purgeableTrailerTableRecords];
            NSString *idSeparetedByComas = nil;
            
            for (int i = 0; i < [recordIDs count]; i++)
            {
                if ([chunks count] == 1000)
                {
                    idSeparetedByComas = [self idSeparetedByComas:chunks];
                    [self purgeAllDODTrailerAndConflictTableRecord:@"SFDataTrailer" column:@"sf_id" deletingId:idSeparetedByComas];
                    [chunks removeAllObjects];
                }
            }
            if ([chunks count] > 0)
            {
                idSeparetedByComas = [self idSeparetedByComas:chunks];
                [self purgeAllDODTrailerAndConflictTableRecord:@"SFDataTrailer" column:@"sf_id" deletingId:idSeparetedByComas];
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
                    idSeparetedByComas = [self idSeparetedByComas:chunks];
                    [self purgeAllDODTrailerAndConflictTableRecord:@"sync_error_conflict" column:@"sf_id" deletingId:idSeparetedByComas];
                    [chunks removeAllObjects];
                }
            }
            if ([chunks count] > 0)
            {
                idSeparetedByComas = [self idSeparetedByComas:chunks];
                [self purgeAllDODTrailerAndConflictTableRecord:@"sync_error_conflict" column:@"sf_id" deletingId:idSeparetedByComas];
                [chunks removeAllObjects];
            }
        }
    }
    [chunks release];
    chunks = nil;
}


+ (void)purgeAllDODTrailerAndConflictTableRecord:(NSString *)tableName column:(NSString *)columnName
                                      deletingId:(NSString *)idSeparetedByComas
{
    [[self getDatabaseConnection] purgeRecordFromRealatedTables:tableName column:columnName data:idSeparetedByComas];
}


+ (NSMutableDictionary *)relationshipKeyDictionaryForRelationshipModel:(SMObjectRelationModel *)model
{
    return  [[self getDatabaseConnection] getRecordDictionaryForObjectRelationship:model];
}


+ (void)initiateDataBaseCleanUp
{
    [[self getDatabaseConnection] cleanupDatabase];
}

@end
