//
//  SearchProcessService.m
//  ServiceMaxMobile
//
//  Created by Krishna Shanbhag on 21/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SearchProcessService.h"
#import "DatabaseConstant.h"
#import "SearchProcessDAO.h"
#import "SFMSearchProcessModel.h"

@implementation SearchProcessService

- (NSString *)tableName {
    return kSearchProcessTableName;
}

- (NSArray *)fetchAllSearchProcess {
    
    NSArray *fieldsArray = @[@"identifier",@"name",@"processDescription",@"processName"];
    NSMutableArray * searchProcessRecords = [[NSMutableArray alloc] initWithCapacity:0];
    
    DBRequestSelect *requestSelect = [[DBRequestSelect alloc] initWithTableName:kSearchProcessTableName andFieldNames:fieldsArray];
    [requestSelect setDistinctRowsOnly];
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
                while ([resultSet next]) {
                    SFMSearchProcessModel * model = [[SFMSearchProcessModel alloc] init];
                    [resultSet kvcMagic:model];
                    [searchProcessRecords addObject:model];
                }
        [resultSet close];
    }];
    }
    return searchProcessRecords;
}
- (NSArray *)fieldNamesToBeRemovedFromQuery {
    
    return @[@"searchObjects", @"searchCriteria"]; // 029883
}
@end
