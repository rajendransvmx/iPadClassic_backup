//
//  DBRequestConstant.h
//  ServiceMaxMobile
//
//  Created by Shravya shridhar on 8/11/14.
//  Copyright (c) 2014 SivaManne. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum DBRequestQueryType : NSUInteger
{
    DBRequestQueryTypeSelect = 1,
    DBRequestQueryTypeInsert = 2,
    DBRequestQueryTypeUpdate = 3,
    DBRequestQueryTypeDelete = 4,
}
DBRequestQueryType;


typedef enum SQLOperatorType : NSUInteger
{
    SQLOperatorNone = 0,
    SQLOperatorLessThan = 1,
    SQLOperatorGreaterThan = 2,
    SQLOperatorLessThanEqualTo = 3,
    SQLOperatorGreaterThanEqualTo = 4,
    SQLOperatorLike = 5,
    SQLOperatorNotLike = 6,
    SQLOperatorIn = 7,
    SQLOperatorNotIn = 8,
    SQLOperatorBetween = 13,
    SQLOperatorIsNull = 9,
    SQLOperatorIsNotNull = 10,
    SQLOperatorEqual = 11,
    SQLOperatorNotEqual = 12,
    SQLOperatorStartsWith = 14,
    SQLOperatorEndsWith = 15,
    SQLOperatorLikeOverride = 16,
    SQLOperatorNotLikeOverride = 17,
    SQLOperatorNotLikeWithIsNull = 18,
    SQLOperatorNotEqualWithIsNull = 19
    
}
SQLOperator;


typedef enum SQLAggregateFunctionTypes : NSUInteger
{
    SQLAggregateFunctionSum = 11,
    SQLAggregateFunctionAvg = 12,
    SQLAggregateFunctionCount = 13,
    SQLAggregateFunctionTotal =14,
    SQLAggregateFunctionMax = 15,
}
SQLAggregateFunction;


typedef enum SQLOrderByTypes : NSUInteger
{
    SQLOrderByTypesAscending = 21,
    SQLOrderByTypesDescending,
    SQLOrderByTypesNone
   
}
SQLOrderByType;

extern  NSString  const *kSqlOperatorGreaterThan;
extern  NSString const *kSqlOperatorLessThan;
extern  NSString const *kSqlOperatorGreaterThanEqualTo;
extern  NSString const *kSqlOperatorLessThanEqualTo;
extern  NSString const *kSqlOperatorLike;
extern  NSString const *kSqlOperatorNotLike;
extern  NSString const *kSqlOperatorIn;
extern  NSString const *kSqlOperatorNotIn;
extern  NSString const *kSqlOperatorIsNull;
extern  NSString const *kSqlOperatorIsNotNull;
extern  NSString const *kSqlOperatorBetween;
extern  NSString const *kSqlOperatorEqual;
extern  NSString const *kSqlOperatorNotEqual;


extern  NSString const *kSQLAggregateFunctionSum;
extern  NSString const *kSQLAggregateFunctionAvg;
extern  NSString const *kSQLAggregateFunctionCount;
extern  NSString const *kSQLAggregateFunctionTotal;
extern  NSString const *kSQLAggregateFunctionMax;

extern  NSString const *kSQLOrderByTypeAscending;
extern  NSString const *kSQLOrderByTypeDescending;
extern  NSString const *kSQLOrderByTypeOrderBy;

extern  NSString const *kSQLCollateNocase;

@interface DBRequestUtility : NSObject

+ (NSString *)getSqliteDataTypeForSalesforceType:(NSString *)salesforceType;

@end

