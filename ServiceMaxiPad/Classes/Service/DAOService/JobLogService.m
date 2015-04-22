//
//  JobLogService.m
//  ServiceMaxiPad
//
//  Created by Pushpak on 13/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "JobLogService.h"
#import "ParserUtility.h"
#import "DBRequestDelete.h"

@implementation JobLogService
- (NSString *)tableName {
   return kJobLogsTableName;
}

- (NSMutableArray *)fetchNextBatchOfJobLogs
{
    NSMutableArray * detailsArray = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        NSArray *fieldList = @[@"timeStamp",
                               @"level",
                               @"context",
                               @"message",
                               @"type",
                               @"profileId",
                               @"groupId",
                               @"category",
                               @"operation"];
        DBCriteria *selCriteria = [[DBCriteria alloc]initWithFieldName:kLocalId
                                                          operatorType:SQLOperatorGreaterThan
                                                         andFieldValue:@"0"];
        DBRequestSelect *selQuery = [[DBRequestSelect alloc]initWithTableName:kJobLogsTableName
                                                                andFieldNames:fieldList
                                                                whereCriteria:selCriteria];
        [selQuery setLimit:kNumberOfRecordsToSendPerBatch];
        [selQuery addOrderByFields:@[kLocalId]];
        NSString * query = [selQuery query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        while ([resultSet next]) {
            NSDictionary * dict = [resultSet resultDictionary];
            //Method in model to set the values
            JobLogModel * model = [[JobLogModel alloc] init];
            model = [ParserUtility parseJSON:dict toModelObject:model withMappingDict:nil];
            if (model != nil) {
                [detailsArray addObject:model];
            }
        }
        [resultSet close];
    }];
    }
    return detailsArray;
}

- (BOOL)deleteJobLogsIfRecordCountCrossedLimit {
    
    BOOL status = NO;
    NSInteger recordCount = [self getNumberOfRecordsFromObject:kJobLogsTableName
                                                withDbCriteria:nil
                                         andAdvancedExpression:nil];
    if (recordCount > kMaxNumberOfLogRecordsToKeep) {
        
        //Deleting kMaxNumberOfLogRecordsToKeep records. As per old iPad application implementation.
        DBRequestSelect *innerSelect = [[DBRequestSelect alloc]initWithTableName:kJobLogsTableName
                                                                   andFieldNames:@[kLocalId]
                                                                  whereCriterias:nil
                                                            andAdvanceExpression:nil];
        [innerSelect addOrderByFields:@[kLocalId]];
        [innerSelect setLimit:kMaxNumberOfLogRecordsToKeep];
        
        DBCriteria *delCriteria = [[DBCriteria alloc]initWithFieldName:kLocalId
                                                          operatorType:SQLOperatorIn
                                                  andInnerQUeryRequest:innerSelect];
        DBRequestDelete *delRequest = [[DBRequestDelete alloc]initWithTableName:kJobLogsTableName
                                                                  whereCriteria:@[delCriteria]
                                                           andAdvanceExpression:nil];
        NSString *delQuery = [delRequest query];
        status = [self executeStatement:delQuery];
    }
    return status;
}


- (BOOL)deleteJobLogsThatAreSent {
    
    BOOL status = NO;
    NSInteger count = [self getNumberOfRecordsFromObject:kJobLogsTableName
                                          withDbCriteria:nil
                                   andAdvancedExpression:nil];
    if(count > kNumberOfRecordsToSendPerBatch)
    {
        count = kNumberOfRecordsToSendPerBatch;
    }
    //Deleting kNumberOfRecordsToSendPerBatch records. As per old iPad application implementation.
    DBRequestSelect *innerSelect = [[DBRequestSelect alloc]initWithTableName:kJobLogsTableName
                                                               andFieldNames:@[kLocalId]
                                                              whereCriterias:nil
                                                        andAdvanceExpression:nil];
    [innerSelect addOrderByFields:@[kLocalId]];
    [innerSelect setLimit:kNumberOfRecordsToSendPerBatch];
    
    DBCriteria *delCriteria = [[DBCriteria alloc]initWithFieldName:kLocalId
                                                      operatorType:SQLOperatorIn
                                              andInnerQUeryRequest:innerSelect];
    DBRequestDelete *delRequest = [[DBRequestDelete alloc]initWithTableName:kJobLogsTableName
                                                              whereCriteria:@[delCriteria]
                                                       andAdvanceExpression:nil];
    NSString *delQuery = [delRequest query];
    status = [self executeStatement:delQuery];

    return status;
}
@end
