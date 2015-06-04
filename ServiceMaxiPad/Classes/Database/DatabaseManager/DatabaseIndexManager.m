//
//  DatabaseIndexManager.m
//  ServiceMaxiPad
//
//  Created by Krishna Shanbhag on 10/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "DatabaseIndexManager.h"
#import "DatabaseIndexConstant.h"
#import "DatabaseManager.h"
#import "Utility.h"

@interface DatabaseIndexManager ()

@property (nonatomic, strong) NSMutableDictionary *compositeIndicesTableNames;

@end
@implementation DatabaseIndexManager

#pragma mark Singleton Methods

+ (instancetype) sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super alloc] initInstance];
    });
    return sharedInstance;
}

- (instancetype) initInstance {

    self = [super init];
    return self;
}

- (void)dealloc {
    // Should never be called, Debugging purpose.
}

#pragma mark - DB Index Schema
/**
 * @name - (NSArray*) getAllStaticTableCreateIndicesSchema
 *
 * @author Krishna Shanbhag
 *
 * @brief This method returns sqlstatement to create all the index in a array.
 *
 *
 * @param
 * @return array of query
 *
 */
- (NSArray *) getAllStaticTableCreateIndicesSchema {
    
   // NSArray *schemaArray = [NSArray arrayWithObjects:kTableSyncRecordIndexSchema,kTableMobileDeviceSettingsIndexSchema,kTableSFObjectKeyIndexSchema,kTableSearchObjectIndexSchema,kTableSearchFieldIndexSchema,kTableSearchExpressionIndexSchema,kTableSearchFilterCriteriaIndexSchema,kTableSyncErrorConflictIndex_1,kTableSyncErrorConflictIndex_2,kTableEventIndexSchema,kTableAttachmentIndexSchema,kTableTaskIndexSchema,kTablePricebookIndexSchema,kTableAccountIndexSchema, nil];
    
    // Vipindas  Removed -Task, Event, Account, Pricebook, Attachment - Since these tables are not generated
     NSArray *schemaArray = [NSArray arrayWithObjects:kTableSyncRecordIndexSchema,kTableMobileDeviceSettingsIndexSchema,kTableSFObjectKeyIndexSchema,kTableSearchObjectIndexSchema,kTableSearchFieldIndexSchema,kTableSearchExpressionIndexSchema,kTableSearchFilterCriteriaIndexSchema,kTableSyncErrorConflictIndex_1,kTableSyncErrorConflictIndex_2, nil];
    return schemaArray;
    
}

/**
 * @name - (NSArray*) getAllStaticTableDropIndicesSchema
 *
 * @author Krishna shanbhag
 *
 * @brief This method returns sqlstatement to drop all the index created, in a array.
 *
 *
 * @param
 * @return array of query
 *
 */
- (NSArray *) getAllStaticTableDropIndicesSchema {
    
    NSArray *schemaArray = [NSArray arrayWithObjects:kTableDropSyncRecordIndexSchema,kTableDropMobileDeviceSettingsIndexSchema,kTableDropSFObjectKeyIndexSchema,kTableDropSearchObjectIndexSchema,kTableDropSearchFieldIndexSchema,kTableDropSearchExpressionIndexSchema,kTableDropSearchFilterCriteriaIndexSchema,kTableDropSyncErrorConflictIndex_1,kTableDropSyncErrorConflictIndex_2,kTableDropEventIndexSchema,kTableDropAttachmentIndexSchema,kTableDropTaskIndexSchema,kTableDropPricebookIndexSchema,kTableDropAccountIndexSchema, nil];
    return schemaArray;
}

#pragma mark - Database operation
/**
 * @name - (void) databaseOperationForIndexArray:(NSArray *)indices
 *
 * @author Krishna Shanbhag
 *
 * @brief <Database operation to create and drop a index>
 *
 * \par
 *  < Depicts the Schema array >
 *
 */
- (void) databaseOperationForIndexArray:(NSArray *)indices {
    
    NSString *sqlStatement;
    
    __block BOOL sucessFull = NO;
    
    @autoreleasepool {
        
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        for (int i = 0; i < [indices count]; i++)
        {
            sqlStatement = [indices objectAtIndex:i];
            
            [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
                
                sucessFull = [db executeUpdate:sqlStatement];
                
                if (!sucessFull)
                {
                    if ([db hadError])
                    {
                        NSLog(@"Index DB operation failed with error : %@ ", [db lastErrorMessage]);
                    }
                    else
                    {
                        NSLog(@"Index DB operation failed with unknown error");
                    }
                }
            }];
        }
    }

}
#pragma mark - Static tables.
/**
 * @name  <createAllIndicesForStaticTables>
 *
 * @author Krishna Shanbhag
 *
 * @brief <Create all Index for static tables>
 * \par
 *  < Static table create and drop schema is hardcoded, get the array of schema and then create/drop index >
 *
 * @return Description of the return value
 *
 */
- (void) createAllIndicesForStaticTables {
    
    NSArray *createTableIndexSchemaArray = [self getAllStaticTableCreateIndicesSchema];

    [self databaseOperationForIndexArray:createTableIndexSchemaArray];
    
}
- (void) dropAllIndicesForStaticTables {
    
    NSArray *dropTableIndexSchemaArray = [self getAllStaticTableDropIndicesSchema];
    
    [self databaseOperationForIndexArray:dropTableIndexSchemaArray];
    
}
#pragma mark - single indexing based on ID for dynamic tables
/**
 * @name  <registerTableNameForSingleIndexing>
 *
 * @author Krishna Shanbhag
 *
 * @brief <Register dynamic tables for index creation>
 *
 * \par
 *  < This method mainly for creating a index based on Id >
 *
 *
 * @return Description of the return value
 *
 */
- (void) registerTableNameForSingleIndexing:(NSString *)tableName {
    
    [self addCompositeIndices:@[@"Id"] ToTable:tableName];
    
}
- (void) registerTableNameForSingleIndexing:(NSString *)tableName forIndex:(NSString *)indexName withOrder:(NSString *)order {
    
    [self addCompositeIndices:@[indexName] ToTable:tableName];
}

#pragma mark - Clear all table cache
/**
 * @name  <clearAllRegisteredCompositeTables>
 *
 * @author Krishna Shanbhag
 *
 * @brief <DO NOT USE this method if there is no intention to clear all registered table names for indexing>
 *
 * @return Description of the return value
 *
 */
- (void) clearAllRegisteredCompositeTables {

    [self.compositeIndicesTableNames removeAllObjects];
    self.compositeIndicesTableNames = nil;
}
- (void) clearCache {
    
    [self clearAllRegisteredCompositeTables];
}
#pragma mark - Composite index
/**
 * @name  <createCompositeIndexSchemaForTable>
 *
 * @author Krishna Shanbhag
 *
 * @brief <Helpful to create a sql query based on the parameters>
 *
 * @return Description of the return value
 *
 */
- (NSString *) createCompositeIndexSchemaForTable:(NSString *)table withIndices:(NSArray *)indices withOrder:(NSString *)order andIndexName:(NSString *)indexName isIndexDrop:(BOOL)isDrop {
    
    NSMutableString *str = nil;
    if ([indices count] > 0) {
        str = [NSMutableString stringWithFormat:@"("];
        for (NSString *index in indices) {
            [str appendFormat:@"%@ %@",index,order];
            
            if ([indices count] == ([indices indexOfObject:index]+1)) {
                [str appendString:@")"];
            }
            else {
                [str appendString:@","];
            }
        }
        
    }
    //IsDrop bool depicts whether the index for the table has to be created or dropped
    if (!isDrop) {
        
        if (str.length > 0 && str != nil) {
            
            return [NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS %@ ON '%@' %@",indexName,table,str];
        }
        return [NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS %@ ON '%@' ",indexName,table];
    }
    else {
        return [NSString stringWithFormat:@"DROP INDEX IF EXISTS %@",indexName];
    }
    return @"";
}
/**
 * @name  <generateIndexingForCompositeIndices>
 *
 * @author Krishna Shanbhag
 *
 * @brief <Responsible for creating indices for dynamic table>
 *
 * @return Description of the return value
 *
 */
- (void) generateIndexingForCompositeIndices {
    
    [self popoulateDynamicTableCompositeIndices];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (NSString *tableName in self.compositeIndicesTableNames) {
       
        NSArray *indexarray = [self.compositeIndicesTableNames objectForKey:tableName];
        for (NSArray *indices in indexarray) {
            
            NSString *indexName = [NSString stringWithFormat:@"%@_index_%lu",tableName,(unsigned long)[indexarray indexOfObject:indices]];
            [array addObject:[self createCompositeIndexSchemaForTable:tableName withIndices:indices withOrder:@"ASC" andIndexName:indexName isIndexDrop:NO]];
        }
    }
    if ([array count] > 0) {
        [self databaseOperationForIndexArray:array];
    }

}
#pragma mark - Add our own composite indices for table.
- (void) addCompositeIndices:(NSArray *)indices ToTable:(NSString *)tableName {
    
    if (self.compositeIndicesTableNames == nil) {
        self.compositeIndicesTableNames = [[NSMutableDictionary alloc] init];
    }
    if ([self.compositeIndicesTableNames objectForKey:tableName] != nil) {
        
        NSMutableArray *arr = [self.compositeIndicesTableNames valueForKey:tableName];
        if (![arr containsObject:indices]) {
            [arr addObject:indices];
        }
    }
    else {
        NSMutableArray *indicesArray = [[NSMutableArray alloc] init];
        [indicesArray addObject:indices];
        [self.compositeIndicesTableNames setObject:indicesArray forKey:tableName];
    }
    
}
/**
 * @name  <popoulateDynamicTableCompositeIndices>
 *
 * @author Krishna Shanbhag
 *
 * @brief <USE THIS METHOD TO ADD YOUR OWN INDEXING>
 *
 * @return Description of the return value
 *
 */
- (void) popoulateDynamicTableCompositeIndices {
    
}
- (void) dropAllIndicesForDynamicTables {
 
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (NSString *tableName in self.compositeIndicesTableNames) {
        NSArray *indexarray = [self.compositeIndicesTableNames objectForKey:tableName];
        for (NSArray *indices in indexarray) {
            
            NSString *indexName = [NSString stringWithFormat:@"%@_index_%lu",tableName,(unsigned long)[indexarray indexOfObject:indices]];
            [array addObject:[self createCompositeIndexSchemaForTable:tableName withIndices:indices withOrder:@"ASC" andIndexName:indexName isIndexDrop:YES]];
        }
    }
    if ([array count] > 0) {
        [self databaseOperationForIndexArray:array];
    }
}
- (void) createAllIndices {
    
    [self createAllIndicesForStaticTables];
    [self generateIndexingForCompositeIndices];
}
- (void) dropAllIndices {
    
    [self dropAllIndicesForStaticTables];
    [self dropAllIndicesForDynamicTables];
}
@end
