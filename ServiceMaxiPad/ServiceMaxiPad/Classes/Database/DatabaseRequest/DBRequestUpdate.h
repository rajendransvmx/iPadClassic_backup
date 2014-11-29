//
//  DBRequestUpdate.h
//  ServiceMaxMobile
//
//  Created by Shravya on 10/08/14.
//  Copyright (c) 2014 SivaManne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBRequest.h"

@interface DBRequestUpdate : DBRequest


/**
 * @brief Instance initialized from this function prepares precompiled update query with where clause
 * @param tableName   table name from which row are extracted
 * @param fieldNames  array of  field names
 * @return instance of DBRequestUpdate
 *
 */
- (id)initWithTableName:(NSString *)tableName
          andFieldNames:(NSArray *)fieldNames;


/**
 * @brief Instance initialized from this function prepares precompiled update query with where clause
 * @param tableName   table name from which row are extracted
 * @param fieldNames  array of  field names
 * @param criteriaArray  array of DBCriteria objects
 * @param advanceExpression  expression like (1 or 2 or 3 ),((1 and 2) or (1 and 3)) etc . If nill, and relationship used between all the criteria objects like (1 and 2 and 3).
 * @return instance of DBRequestUpdate
 *
 */
//- (id)initWithTableName:(NSString *)tableName
//        andFieldObjects:(NSArray *)fieldObjects
//          whereCriteria:(NSArray *)criteriaArray
//   andAdvanceExpression:(NSString *)advanceExpression;


- (id)initWithTableName:(NSString *)tableName
        andFieldNames:(NSArray *)fieldNames
          whereCriteria:(NSArray *)criteriaArray
   andAdvanceExpression:(NSString *)advanceExpression;

@end
