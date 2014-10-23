//
//  DBRequestInsert.h
//  ServiceMaxMobile
//
//  Created by Shravya on 10/08/14.
//  Copyright (c) 2014 SivaManne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBRequest.h"

@interface DBRequestInsert : DBRequest

/**
 * @brief Instance initialized from this function prepares precompiled insert query
 * @param tableName   table name from which row are extracted
 * @param fieldObjects  array of  DBField objects
 * @return instance of DBRequestInsert
 *
 */
- (id)initWithTableName:(NSString *)tableName andFieldObjects:(NSArray *)fieldObjects;


/**
 * @name  initWithTableName:(NSString *)tableName andFieldNames:(NSMutableArray *)fieldNames;
 *
 * @author Vipindas Palli
 *
 * @brief Instance initialized from this function prepares precompiled insert query
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param  tableName table name from which row are extracted
 * @param  fieldNames names of the field
 *
 * @return instance of DBRequestInsert
 *
 */

- (id)initWithTableName:(NSString *)tableName andFieldNames:(NSMutableArray *)fieldNames;

@end
