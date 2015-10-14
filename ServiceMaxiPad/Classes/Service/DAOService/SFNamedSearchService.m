//
//  SFNameSearchService.m
//  ServiceMaxMobile
//
//  Created by Anoop on 8/22/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFNamedSearchService.h"
#import "ParserUtility.h"
#import "SFNamedSearchModel.h"

@implementation SFNamedSearchService

- (NSString*) tableName {
    
    return kSFNamedSearchTableName;

}
-(SFNamedSearchModel *)getLookUpRecordsForDBCriteria:(NSArray *)criteriaArray  advancedExpression:(NSString *)advancedExpression  fields:(NSArray *)fields;
{
    __block SFNamedSearchModel * namedSearchModel = nil;
    
    DBRequestSelect * select = [[DBRequestSelect alloc] initWithTableName:[self tableName]
                                                            andFieldNames:fields
                                                           whereCriterias:criteriaArray
                                                     andAdvanceExpression:advancedExpression];
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        NSString * query = [select query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        while([resultSet next])
        {
            namedSearchModel = [[SFNamedSearchModel alloc] init];
            NSDictionary *dict = [resultSet resultDictionary];
            [ParserUtility parseJSON:dict toModelObject:namedSearchModel withMappingDict:nil];
        }
        [resultSet close];
    }];
    }
    return namedSearchModel;
}

-(NSArray *)getLookUpRecordListForDBCriterias:(NSArray *)criteriaArray  advancedExpression:(NSString *)advancedExpression  fields:(NSArray *)fields;
{
    NSMutableArray *lNamedSearchModelList = [NSMutableArray new];
    
    DBRequestSelect * select = [[DBRequestSelect alloc] initWithTableName:[self tableName]
                                                            andFieldNames:fields
                                                           whereCriterias:criteriaArray
                                                     andAdvanceExpression:advancedExpression];
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            NSString * query = [select query];
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while([resultSet next])
            {
                SFNamedSearchModel * namedSearchModel = nil;

                namedSearchModel = [[SFNamedSearchModel alloc] init];
                NSDictionary *dict = [resultSet resultDictionary];
                [ParserUtility parseJSON:dict toModelObject:namedSearchModel withMappingDict:nil];
                [lNamedSearchModelList addObject:namedSearchModel];
            }
            [resultSet close];
        }];
    }
    return lNamedSearchModelList;
}


@end
