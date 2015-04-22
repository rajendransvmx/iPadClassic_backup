//
//  DBRequestConstant.m
//  ServiceMaxMobile
//
//  Created by Shravya shridhar on 8/11/14.
//  Copyright (c) 2014 SivaManne. All rights reserved.
//

#import "DBRequestConstant.h"
#import "DatabaseConstant.h"

const NSString *kSqlOperatorGreaterThan         = @">";
const NSString *kSqlOperatorLessThan            = @"<";
const NSString *kSqlOperatorGreaterThanEqualTo  = @">=";
const NSString *kSqlOperatorLessThanEqualTo     = @"<=";
const NSString *kSqlOperatorLike                = @"LIKE";
const NSString *kSqlOperatorNotLike             = @"NOT LIKE";
const NSString *kSqlOperatorIn                  = @"IN";
const NSString *kSqlOperatorNotIn               = @"NOT IN";
const NSString *kSqlOperatorIsNull              = @"IS NULL";
const NSString *kSqlOperatorIsNotNull           = @"IS NOT NULL";
const NSString *kSqlOperatorBetween             = @"BETWEEN";
const NSString *kSqlOperatorEqual               = @"=";
const NSString *kSqlOperatorNotEqual             = @"!=";


const NSString *kSQLAggregateFunctionSum                = @"SUM";
const NSString *kSQLAggregateFunctionCount              = @"COUNT";
const NSString *kSQLAggregateFunctionTotal              = @"TOTAL";
const NSString *kSQLAggregateFunctionAvg                = @"AVG";
const NSString *kSQLAggregateFunctionMax                = @"MAX";


const NSString *kSQLOrderByTypeAscending                = @"ASC";
const NSString *kSQLOrderByTypeDescending               = @"DESC";
const NSString *kSQLOrderByTypeOrderBy                  = @" ORDER BY ";


const NSString *kSQLCollateNocase                  = @" COLLATE NOCASE ";


@implementation DBRequestUtility

+ (NSString *)getSqliteDataTypeForSalesforceType:(NSString *)salesforceType {
    
    NSString *type = salesforceType;
    if ([type isEqualToString:kSfDTBoolean])
        return kDTBool;
    else if ([type isEqualToString:kSfDTCurrency] || [type isEqualToString:kSfDTDouble] || [type isEqualToString:kSfDTPercent])
        return kDTDouble;
    else if ([type isEqualToString:kSfDTInteger])
        return kDTInteger;
    else if ([type isEqualToString:kSfDTDate] || [type isEqualToString:kSfDTDateTime])
        return kDTDateTime;
    else if ([type isEqualToString:kSfDTTextArea])
        return kDTVarChar;
    else
        return kDTText;
    
}

@end