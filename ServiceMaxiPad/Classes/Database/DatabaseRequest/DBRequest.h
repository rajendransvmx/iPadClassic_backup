//
//  DBRequest.h
//  ServiceMaxMobile
//
//  Created by Shravya shridhar on 8/8/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

/**
 *  @file   DBRequest.h
 *  @class  DBRequest
 *
 *  @brief  This class is abstract and is used as super class different type of query builder sub classes.
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
#import "DBRequestConstant.h"
#import "DBField.h"
#import "DBCriteria.h"



@interface DBRequest : NSObject

@property(nonatomic) DBRequestQueryType requestQueryType;
@property(nonatomic,strong) NSArray     *fieldNames;
@property(nonatomic,strong) NSArray     *fieldObjects;
@property(nonatomic,strong) NSString    *tableName;
@property(nonatomic,strong) NSArray     *criteriaArray;
@property(nonatomic,strong) NSString    *advancedExpression;
@property(nonatomic,assign) NSInteger    offSet;
@property(nonatomic,assign) NSInteger    limit;
@property(nonatomic, strong) NSString *joinString; // 012895



- (void)setRequestType:(DBRequestQueryType)queryType;

- (void)setObjectTableName:(NSString *)newTableName;
- (NSString *)objectName;

- (void)setFields:(NSArray *)fields;
- (NSArray *)fields;

- (BOOL)setCriteria:(NSArray *)criterias
      andExpression:(NSString *)expression;

- (NSString *)query;

- (NSString *)getFieldNamesSeperatedByCommas;
- (NSString *)getFieldNamesWithTableNameSeparatedByCommas;
- (NSString *)whereClause;

- (void)addOrderByFields:(NSArray *)fields andDefaultOrderByOrder:(SQLOrderByType)defaultOrderType;
- (void)addOrderByFields:(NSArray *)fields;

- (void)addGroupByFields:(NSArray *)fieldNames;

- (NSString *)getGroupByString ;
- (NSString *)getOrderByString;

- (void)addLimit:(NSInteger )limit andOffSet:(NSInteger)offSet;

@end
