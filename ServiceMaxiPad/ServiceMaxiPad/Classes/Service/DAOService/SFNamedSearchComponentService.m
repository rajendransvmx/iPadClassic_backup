//
//  SFSearchObjectDetail.m
//  ServiceMaxMobile
//
//  Created by Anoop on 8/25/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFNamedSearchComponentService.h"
#import "SFNamedSearchComponentModel.h"
#import "ParserUtility.h"
#import "DatabaseConstant.h"


@implementation SFNamedSearchComponentService

- (NSString*)tableName {
    
    return kSFNamedSearchComponentTableName;
}

-(NSDictionary *)getNamedSearchComponentWithDBcriteria:(NSArray *)DBCriteria  advanceExpression:(NSString *)advanceExpression fields:(NSArray *)fields  orderbyField:(NSArray *)orderByFields distinct:(BOOL)distinctOnly;
{
    
    __block NSMutableArray      * displayFields = nil;
    __block NSMutableArray      * searchFields  = nil;
    
    DBRequestSelect * select = [[DBRequestSelect alloc] initWithTableName:[self tableName]
                                                        andFieldNames:fields
                                                        whereCriterias:DBCriteria
                                                        andAdvanceExpression:advanceExpression];
    
    if(distinctOnly){
        [select setDistinctRowsOnly];
    }
    [select addOrderByFields:orderByFields];
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        NSString * query = [select query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        while ([resultSet next]) {
            SFNamedSearchComponentModel * model = [[SFNamedSearchComponentModel alloc] init];
            NSDictionary *dict = [resultSet resultDictionary];
            [ParserUtility parseJSON:dict toModelObject:model withMappingDict:nil];
            if([model.searchObjectFieldType isEqualToString:kSearchFieldTypeSearch]){
                
                if(searchFields == nil){
                    searchFields = [NSMutableArray array];
                }
                [searchFields addObject:model];
            }
            else if([model.searchObjectFieldType isEqualToString:kSearchFieldTypeResult])
            {
                if(displayFields == nil){
                    displayFields = [NSMutableArray array];
                }
                [displayFields addObject:model];
            }
        }
        [resultSet close];
    }];
    }
    NSMutableDictionary * returnDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    if(searchFields != nil){
        [returnDict setObject:searchFields forKey:kSearchFieldTypeSearch];
    }
    
    if(displayFields != nil){
        [returnDict setObject:displayFields forKey:kSearchFieldTypeResult];
    }
    
    return returnDict;
}

@end
