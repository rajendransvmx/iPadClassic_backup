//
//  DBCriteria.m
//  ServiceMaxMobile
//
//  Created by Shravya on 10/08/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "DBCriteria.h"
#import "DBRequest.h"

@interface DBCriteria()
@property(nonatomic,strong)DBRequest *innerQueryRequest;
@property(nonatomic,assign)BOOL bindNeededInQuery;
@property(nonatomic,strong)NSArray *subCriterias;
@property(nonatomic,strong)NSString *advancedExpression;
@end 

@implementation DBCriteria

- (id)initWithFieldName:(NSString *)fieldName
           operatorType:(SQLOperator)newOperatorType
          andFieldValue:(NSString *)fieldValue {
    
    self = [super init];
    if (self != nil) {
        self.lhsValue = fieldName;
        self.rhsValue = fieldValue;
        self.operatorType = newOperatorType;
    }
    return self;
}

- (id)initWithFieldName:(NSString *)fieldName
           operatorType:(SQLOperator)newOperatorType
         andFieldValues:(NSArray *)fieldValues {
    self = [super init];
    if (self != nil) {
        self.lhsValue = fieldName;
        self.rhsValues = fieldValues;
        self.operatorType = newOperatorType;
    }
    return self;
}
- (id)initWithFieldName:(NSString *)fieldName
           operatorType:(SQLOperator)newOperatorType
   andInnerQUeryRequest:(id)newInnerQueryRequest {
    self = [super init];
    if (self != nil) {
        self.lhsValue = fieldName;
        self.innerQueryRequest = newInnerQueryRequest;
        self.operatorType = newOperatorType;
    }
    return self;
}

- (id)initWithFieldNameToBeBinded:(NSString *)fieldName {
    self = [super init];
    if (self != nil) {
        self.lhsValue = fieldName;
        self.bindNeededInQuery = YES;
        self.operatorType = SQLOperatorEqual;
    }
    return self;
    
}

- (BOOL)innerQueryExists {
    if (self.innerQueryRequest != nil) {
        return YES;
    }
    return NO;
}
- (NSString *)getInnerQuery {
    return [self.innerQueryRequest query];
}

- (void)setQueryBindNeed {
    self.bindNeededInQuery = YES;
}
- (BOOL)isBindingExist {
    return self.bindNeededInQuery;
}

- (void)addOrCriterias:(NSArray *)subCriteriaArray withExpression:(NSString *)expression {
    self.subCriterias = subCriteriaArray;
    self.advancedExpression = expression;
}
- (NSArray *)getSubCriterias {
    return self.subCriterias;
    
}

- (NSString *)getAdavncedExpression {
    return self.advancedExpression;
}

@end
