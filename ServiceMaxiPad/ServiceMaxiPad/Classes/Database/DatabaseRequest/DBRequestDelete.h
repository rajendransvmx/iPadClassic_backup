//
//  DBRequestDelete.h
//  ServiceMaxMobile
//
//  Created by Shravya on 10/08/14.
//  Copyright (c) 2014 SivaManne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBRequest.h"

@interface DBRequestDelete : DBRequest


/**
 * @brief Instance initialized from this function prepares deletes query with where clause
 * @param tableName   table name from which row are extracted
 * @param criteriaArray  array of DBCriteria objects
 * @param advanceExpression  expression like (1 or 2 or 3 ),((1 and 2) or (1 and 3)) etc . If nill, and relationship used between all the criteria objects like (1 and 2 and 3).
 * @return instance of DBRequestDelete
 *
 */
- (id)initWithTableName:(NSString *)tableName
          whereCriteria:(NSArray *)criteriaArray
   andAdvanceExpression:(NSString *)advanceExpression;

/**
 * @brief Instance initialized from this function prepares deletes query without any where clause
 * @param tableName   table name from which row are extracted
 * @return instance of DBRequestDelete
 *
 */
- (id)initWithTableName:(NSString *)tableName;

@end
