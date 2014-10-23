//
//  StaticResourceService.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 26/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   StaticResourceService.m
 *  @class  StaticResourceService
 *
 *  @brief
 *
 *   This is a DAO service which interact with DB for static resource related info.
 *
 *  @author Shubha S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "StaticResourceService.h"
#import "StaticResourceModel.h"
#import "ResponseConstants.h"

@implementation StaticResourceService

/**
 * @name tableName
 *
 * @author Shubha
 *
 * @brief It returns name of the table which is going to effect by this DAO.
 *
 *
 *
 * @param None
 *
 * @return tablename
 *
 */

- (NSString *)tableName
{
    return @"StaticResource";
}

/**
 * @name (NSArray * )fetchRecordsByFields:(NSArray *)fieldNames andCriteria:(DBCriteria *)criteria withDistinctFlag:(BOOL)isDistinct
 *
 * @author Shubha
 *
 * @brief fetches record from DB based on the field name,criteria and distinct flag
 *
 *
 *
 * @param   Fieldnames(NSArray),Criteria(DBCriteria),DistinctFlag(BOOL)
 * @param
 *
 * @return it returns array of model class.
 *
 */

- (NSArray * )fetchRecordsByFields:(NSArray *)fieldNames andCriteria:(DBCriteria *)criteria withDistinctFlag:(BOOL)isDistinct
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:fieldNames whereCriteria:criteria];
    
    if (isDistinct) {
        
        [requestSelect setDistinctRowsOnly];
    }
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    
    if (didOpen)
    {
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:query];
        
        while ([resultSet next]) {
            
            StaticResourceModel * model = [[StaticResourceModel alloc] init];
            [resultSet kvcMagic:model];
            [records addObject:model];
        }
    }
    return records;
}

/**
 * @name (NSArray*)getDistinctStaticResourceIdsToBeDownloaded
 *
 * @author Shubha
 *
 * @brief it gives listof staticresource ids to be downloaded
 * @param None
 * @param
 *
 * @return list of static resource id.
 *
 */

- (NSArray*)getDistinctStaticResourceIdsToBeDownloaded
{
    NSArray *staticResouceModels = [self fetchRecordsByFields:@[kStaticResourceId,kStaticResourceName] andCriteria:nil withDistinctFlag:YES];
//    NSMutableArray *listOfStaticResourceId = [[NSMutableArray alloc]init];
//    for (int i = 0; i < [staticeResouceModels count]; i++) {
//        StaticResourceModel *model = [staticeResouceModels objectAtIndex:i];
//        [listOfStaticResourceId addObject:model.Id];
//    }
    return staticResouceModels;
}
@end
