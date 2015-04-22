//
//  AttachmentsService.m
//  ServiceMaxMobile
//
//  Created by Anoop on 8/21/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "AttachmentsService.h"
#import "AttachmentModel.h"

@implementation AttachmentsService

- (NSString*)tableName {
    
    return kAttachmentsTableName;
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
            
            AttachmentModel * model = [[AttachmentModel alloc] init];
            [resultSet kvcMagic:model];
            [records addObject:model];
        }
        [resultSet close];
    }];
    }
    return records;
}

- (NSArray*)getAttachmentIdsToBeDownloaded
{
    
    NSArray *attachementModels = [self fetchRecordsByFields:@[@"attachmentId"] andCriteria:nil withDistinctFlag:YES];
    NSMutableArray *listAttachmentId = [[NSMutableArray alloc]init];
    for (int i = 0; i < [attachementModels count]; i++) {
        AttachmentModel *model = [attachementModels objectAtIndex:i];
        [listAttachmentId addObject:model.attachmentId];
    }
    return listAttachmentId;
}

- (NSArray *)fieldNamesToBeRemovedFromQuery {
    
    NSArray *array = [[NSArray alloc] initWithObjects:@"localFilePath",@"urlSuffix", nil];
    return array;
}

-(void)updateAttachmentTableWithModelArray:(NSArray*)modelArray
{
    NSArray * fieldsArray = [[NSArray alloc] initWithObjects:@"attachmentBody", nil];
    DBCriteria * criteria1 = [[DBCriteria alloc] initWithFieldNameToBeBinded:@"attachmentId"];
    
    if([modelArray count] >0)
    {
        [self updateRecords:modelArray withFields:fieldsArray withCriteria:[NSArray arrayWithObjects:criteria1, nil]];
    }
}

@end
