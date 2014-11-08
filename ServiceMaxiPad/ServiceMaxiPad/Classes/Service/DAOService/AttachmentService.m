//
//  AttachmentService.m
//  ServiceMaxMobile
//
//  Created by Anoop on 8/21/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "AttachmentService.h"
#import "AttachmentTXModel.h"
#import "ParserUtility.h"

@implementation AttachmentService

- (NSString*)tableName {
    
    return kAttachmentTableName;
}

- (NSArray * )fetchRecordsByFields:(NSArray *)fieldNames andCriteria:(DBCriteria *)criteria withDistinctFlag:(BOOL)isDistinct
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:fieldNames whereCriteria:criteria];
    
    if (isDistinct) {
        
        [requestSelect setDistinctRowsOnly];
    }
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {

        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        while ([resultSet next]) {
            AttachmentTXModel *model = [[AttachmentTXModel alloc] init];
            NSDictionary *dict = [resultSet resultDictionary];
            [ParserUtility parseJSON:dict toModelObject:model withMappingDict:[AttachmentTXModel getMappingDictionary]];
            [records addObject:model];
        }
        }];
    }
    return records;
}


-(void)updateAttachmentTableWithModelArray:(NSArray*)modelArray
{
    NSArray * fieldsArray = [[NSArray alloc] initWithObjects:kAttachmentBody, nil];
    DBCriteria * criteria1 = [[DBCriteria alloc] initWithFieldNameToBeBinded:kAttachmentId];
    
    if([modelArray count] >0)
    {
        [self updateRecords:modelArray withFields:fieldsArray withCriteria:[NSArray arrayWithObjects:criteria1, nil]];
    }
}

@end
