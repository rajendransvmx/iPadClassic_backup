//
//  DBRequestSelect.h
//  ServiceMaxMobile
//
//  Created by Shravya on 10/08/14.
//  Copyright (c) 2014 SivaManne. All rights reserved.
//


/**
 *  @file   DBRequestSelect.h
 *  @class  DBRequestSelect
 *
 *  @brief  This class prepares select query based on the given parameters
 *
 *
 *
 *  @author  Shravya Shridhar
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import <Foundation/Foundation.h>
#import "DBRequest.h"
#import "DBField.h"


@interface DBRequestSelect : DBRequest



/**
 * @brief prepares query to returns all rows of the given table if instance is initialzied using this function
 * @param tableName  table name from which row are extracted
 
 * @return instance of DBRequestSelect
 *
*/
- (id)initWithTableName:(NSString *)tableName;


/**
 * @brief Instance initialized from this function prepares query to returns given field names of all rows of the given table
 * @param tableName   table name from which row are extracted
 * @param fieldNames  array of  field name strings
 * @return instance of DBRequestSelect
 *
 */
- (id)initWithTableName:(NSString *)tableName
          andFieldNames:(NSArray *)fieldNames;

/**
 * @brief Instance initialized from this function prepares query to returns all field of rows which matches the criteria of the given table
 * @param tableName   table name from which row are extracted
 * @param criteriaArray  array of DBCriteria objects
 * @param advanceExpression  expression like (1 or 2 or 3 ),((1 and 2) or (1 and 3)) etc . If nill, and relationship used between all the criteria objects like (1 and 2 and 3).
 * @return instance of DBRequestSelect
 *
 */
- (id)initWithTableName:(NSString *)tableName
          whereCriterias:(NSArray *)criteriaArray
   andAdvanceExpression:(NSString *)advanceExpression;


/**
 * @brief Instance initialized from this function prepares query to returns mentioned field names of rows which matches the criteria of the given table
 * @param tableName   table name from which row are extracted
 * @param fieldNames  array of  field name strings
 * @param criteriaArray  array of DBCriteria objects
 * @param advanceExpression  expression like (1 or 2 or 3 ),((1 and 2) or (1 and 3)) etc . If nill, and relationship used between all the criteria objects like (1 and 2 and 3).
 * @return instance of DBRequestSelect
 *
 */
- (id)initWithTableName:(NSString *)tableName
          andFieldNames:(NSArray *)fieldNames
          whereCriterias:(NSArray *)criteriaArray
   andAdvanceExpression:(NSString *)advanceExpression;

/**
 * @brief Instance initialized from this function prepares query to returns mentioned DBFields of rows which matches the criteria of the given table.
 * @param tableName   table name from which row are extracted
 * @param fieldObjects  array of  DBField objects. DBField's table name is used to extract the field value when join query is used.
 * @param criteriaArray  array of DBCriteria objects
 * @param advanceExpression  expression like (1 or 2 or 3 ),((1 and 2) or (1 and 3)) etc . If nill, and relationship used between all the criteria objects like (1 and 2 and 3).
 * @return instance of DBRequestSelect
 *
 */
- (id)initWithTableName:(NSString *)tableName
        andFieldObjects:(NSArray *)fieldObjects
          whereCriterias:(NSArray *)criteriaArray
   andAdvanceExpression:(NSString *)advanceExpression;



/**
 * @brief Instance initialized from this function prepares query of aggregate function count (*) only
 * @param tableName   table name from which row are extracted
 * @param newAggregateFunction enum which specified aggregate function used
 * @param criteriaArray  array of DBCriteria objects
 * @param advanceExpression  expression like (1 or 2 or 3 ),((1 and 2) or (1 and 3)) etc . If nill, and relationship used between all the criteria objects like (1 and 2 and 3).
 * @return instance of DBRequestSelect
 *
 */
- (id)initWithTableName:(NSString *)tableName
              aggregateFunction:(SQLAggregateFunction)newAggregateFunction
                 whereCriterias:(NSArray *)criteriaArray
           andAdvanceExpression:(NSString *)advanceExpression;


/**
 * @brief Instance initialized from this function prepares query of aggregate function like count(field name),count (*) etc
 * @param field   DBField where table name , field name is requeired
 * @param newAggregateFunction enum which specified aggregate function used
 * @param criteriaArray  array of DBCriteria objects
 * @param advanceExpression  expression like (1 or 2 or 3 ),((1 and 2) or (1 and 3)) etc . If nill, and relationship used between all the criteria objects like (1 and 2 and 3).
 * @return instance of DBRequestSelect
 *
 */
- (id)initWithField:(DBField *)field
  aggregateFunction:(SQLAggregateFunction)newAggregateFunction
     whereCriterias:(NSArray *)criteriaArray
andAdvanceExpression:(NSString *)advanceExpression;


/**
 * @brief Instance initialized from this function prepares query to returns mentioned field names of rows which matches the criteria of the given table. Advanced expression is considered as (1 and 2 and so on..)
 * @param tableName   table name from which row are extracted
 * @param fieldNames  array of  field name strings
 * @param criteriaArray  array of DBCriteria objects
 * @return instance of DBRequestSelect
 *
 */
- (id)initWithTableName:(NSString *)tableName
          andFieldNames:(NSArray *)fieldNames
         whereCriteria:(DBCriteria *)criteria;


/**
 * @brief If this function is called ,DISTINCT gets attached to select query
 * @return None.
 *
 */
- (void)setDistinctRowsOnly;

/**
 * @brief If this function is called ,DISTINCT clause get applied on the specified field for select quieries
  * @param distinctField    field on which DISTINCT clause is used like SELECT DISTINCT Id
 * @return None.
 *
 */
- (void)setDistinctRowsOnField:(NSString *)distinctField;


- (void)addLeftOuterJoinTables:(NSArray *)joinTables;

/**
 * @brief This function takes table name to be joined and field name of primary table to which this table name is joined. Join willb e done using left field name of the Primary table and Id Field of join table.
 * @param joinTableName    Name of the table which will be joined to the primary table
 * @param leftFieldName    field name of the primary table using which join will be done.
 * @return None.
 *
 */
- (void)addLeftOuterJoinTable:(NSString *)joinTableName andPrimaryTableFieldName:(NSString *)leftFieldName;


@end
