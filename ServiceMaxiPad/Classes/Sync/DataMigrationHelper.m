//
//  DataMigrationHelper.m
//  ServiceMaxiPad
//
//  Created by Pushpak on 29/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "DataMigrationHelper.h"
#import "SFObjectFieldDAO.h"
#import "FactoryDAO.h"
#import "TransactionObjectDAO.h"
#import "DatabaseManager.h"

@implementation DataMigrationHelper

+ (NSDictionary *)fetchMigrationMetaDataFromOldDatabase{
    
    NSDictionary *result;
    NSArray      *tables;
    
    tables = [self fetchAllTransactionalTables];
    tables = [self removeEmptyOrExceptionalTablesFrom:tables];
    result = [self populateTableSchemaForTables:tables];
    return result;
}

+ (NSArray *)fetchAllTransactionalTables{
    
    NSMutableArray *objectNames = [[NSMutableArray alloc]initWithCapacity:0];
    NSArray *models;
    
    id sfObjectService = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectField];
    
    if ([sfObjectService conformsToProtocol:@protocol(SFObjectFieldDAO)]) {
        
        models = [sfObjectService fetchDistinctSFObjectFieldsInfoByFields:@[@"objectName"] andCriteria:nil];
        for (SFObjectFieldModel *model in models) {
            if (model.objectName) {
                [objectNames addObject:model.objectName];
            }
        }
    }
    return objectNames;
}

+ (NSArray *)removeEmptyOrExceptionalTablesFrom:(NSArray *)tables
{
    NSMutableArray *objectNames = [[NSMutableArray alloc]initWithCapacity:0];
    
    id transactionService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    if ([transactionService conformsToProtocol:@protocol(TransactionObjectDAO)])
    {
        for (NSString *tableName in tables) {
            
            /**
             * Check whether table is empty, if yes then skip.
             */
            if ([tableName hasSuffix:@"Service_Pricebook__c"] || [tableName hasSuffix:@"Service_Pricebook_Entry__c"])
            {
                /**
                 * By passing these tables...
                 */
            }
            else if ([self isEmptyTable:tableName])
            {
                //NSLog(@"TXN %@ --  record count 0", tableName);
                continue;
            }
            /**
             * Check whether table is meta table, if yes then skip.
             */
            if ([tableName isEqualToString:kTableCodeSnippet] || [tableName isEqualToString:kTableCodeManifest]){
                // NSLog(@"TXN  %@ -- skipping non meta table", tableName);
                continue;
            }
            /**
             * Well here we can go head and insert into the array.
             */
            [objectNames addObject:tableName];
        }
    }
    return objectNames;
}


/**
 * @name   isEmptyTable:(NSString *)tableName
 *
 * @author Vipindas Palli
 *
 * @brief  Find empty tables
 *
 * \par
 *  <Longer description starts here>
 *
 * @return String value
 *
 */


+ (BOOL)isEmptyTable:(NSString *)tableName
{
    NSInteger count = 0;
    id service = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    if ([service conformsToProtocol:@protocol(TransactionObjectDAO)])
    {
        count = [service getNumberOfRecordsFromObject:tableName
                                       withDbCriteria:nil
                                andAdvancedExpression:nil];
    }
    
   // NSLog(@" %@ record count - %d", tableName, (int)count);
    
    if (count > 0)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}


+ (NSDictionary *)populateTableSchemaForTables:(NSArray *)tables
{
    NSMutableDictionary *finalDict = [[NSMutableDictionary alloc]initWithCapacity:0];
    
    id sfObjectService = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectField];
    
    if ([sfObjectService conformsToProtocol:@protocol(SFObjectFieldDAO)]){
        
        for (NSString *tableName in tables) {
            
            NSArray *models = [sfObjectService getSFObjectFieldsForObjectWithLocalId:tableName];
            NSMutableDictionary *fieldDict = [[NSMutableDictionary alloc]initWithCapacity:0];
            for (SFObjectFieldModel *model in models) {
                if (model.fieldName && model.type) {
                    [fieldDict setObject:model.type forKey:model.fieldName];
                }
            }
            
            if ([tableName isEqualToString:kServicemaxEventObject]) {
                
                [fieldDict setObject:@"text" forKey:kObjectSfId];
            }
            [finalDict setObject:fieldDict forKey:tableName];
        }
    }
    [self addStaticTableSchemaWithTransactionTableSchema:finalDict];
    return finalDict;
}

+ (NSArray *)fetchAllStaticTables {
    
    return @[@"ObjectNameFieldValue",
             @"Sync_Records_Heap",
             @"ModifiedRecords",
             @"SyncErrorConflict",
             @"OPDocSignature",
             @"OPDocHTML",
             @"User",
             @"Pricebook2",
             @"RecentRecord",
             @"DODRecords",
             @"TroubleshootData",
             @"ProductManual",
             @"UserImages",
             @"ChatterPostDetail",
             @"ProductImageData",
             @"RecordName",
             @"Translations",
             @"FieldDescribe",
             @"ObjectDescribe",
             @"Configuration",
             @"InstallBaseObject",
             @"ClientSyncLogTransient",
             @"CustomActionRequestParams"
             ];
}

+ (void)addStaticTableSchemaWithTransactionTableSchema:(NSMutableDictionary *)dict
{
    NSArray *staticTables = [self fetchAllStaticTables];
    for (NSString *table in staticTables) {
        
        NSString *queryString = [[NSString alloc]initWithFormat:@"PRAGMA table_info ('%@')",table];
        @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            
            SQLResultSet * resultSet = [db executeQuery:queryString];
            NSMutableDictionary *fieldDict = [[NSMutableDictionary alloc]initWithCapacity:0];
            while ([resultSet next]) {
                NSDictionary * dict = [resultSet resultDictionary];
                if ([dict count]>0) {
                    
                    NSString *name = [dict objectForKey:@"name"];
                    NSString *type = [dict objectForKey:@"type"];
                    if (name && type) {
                         [fieldDict setObject:type forKey:name];
                    }
                }
            }
            [dict setObject:fieldDict forKey:table];
            [resultSet close];
        }];
        }
    }
}

+ (BOOL)checkObjectPermission:(NSString *)objectName
{
    BOOL result = NO;
    
    id sfObjectService = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectField];
    
    if ([sfObjectService conformsToProtocol:@protocol(SFObjectFieldDAO)]){
        
        result = [sfObjectService doesObjectHavePermission:objectName];
    }
    return result;
}
@end
