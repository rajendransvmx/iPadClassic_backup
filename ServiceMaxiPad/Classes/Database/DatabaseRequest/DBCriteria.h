//
//  DBCriteria.h
//  ServiceMaxMobile
//
//  Created by Shravya on 10/08/14.
//  Copyright (c) 2014 SivaManne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBRequestConstant.h"




@interface DBCriteria : NSObject

@property(nonatomic,strong)NSString *lhsValue;
@property(nonatomic,strong)NSString *rhsValue;
@property(nonatomic,strong)NSArray *rhsValues;
@property(nonatomic,assign)SQLOperator operatorType;
@property(nonatomic,strong)NSString *dataType;
@property(nonatomic,strong)NSString *tableName;
@property(nonatomic,assign)BOOL     isCaseInsensitive;
@property(nonatomic,strong)NSArray *subCriterias;


- (id)initWithFieldName:(NSString *)fieldName
           operatorType:(SQLOperator)operatorType
          andFieldValue:(NSString *)fieldValue;

- (id)initWithFieldName:(NSString *)fieldName
           operatorType:(SQLOperator)operatorType
          andFieldValues:(NSArray *)fieldValues;


- (id)initWithFieldName:(NSString *)fieldName
           operatorType:(SQLOperator)operatorType
         andInnerQUeryRequest:(id)innerQueryRequest;

- (id)initWithFieldNameToBeBinded:(NSString *)fieldName;

- (BOOL)innerQueryExists;
- (NSString *)getInnerQuery;
- (void)setQueryBindNeed;

- (BOOL)isBindingExist;

- (void)addOrCriterias:(NSArray *)subCriteriaArray withExpression:(NSString *)expression;
- (NSArray *)getSubCriterias;
- (NSString *)getAdavncedExpression;
- (id )getInnerQueryRequest;

@end
