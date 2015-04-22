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
#import "DBRequestUpdate.h"

@implementation AttachmentService

- (NSString*)tableName {
    
    return kAttachmentTableName;
}

- (BOOL)updateSFIdForAttachmentModel:(AttachmentTXModel*)attachmentModel
{
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kAttachmentTXlocalId operatorType:SQLOperatorEqual andFieldValue:attachmentModel.localId];
    
    DBRequestUpdate * updatequery = [[DBRequestUpdate alloc] initWithTableName:[self tableName] andFieldNames:@[kAttachmentTXId] whereCriteria:@[criteria] andAdvanceExpression:nil];
    
    BOOL status = [self updateEachRecord:attachmentModel withQuery:[updatequery query]];
    return status;
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

-(BOOL)deleteRecordsForRecordLocalIds:(NSArray *)recordsIds
{
    DBCriteria *criteriaOne = [[DBCriteria alloc]initWithFieldName:kLocalId
                                                      operatorType:SQLOperatorIn
                                                    andFieldValues:recordsIds];
    
    BOOL status = [self deleteRecordsFromObject:[self tableName]
                                  whereCriteria:[NSArray arrayWithObject:criteriaOne]
                           andAdvanceExpression:nil];
    return status;
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
