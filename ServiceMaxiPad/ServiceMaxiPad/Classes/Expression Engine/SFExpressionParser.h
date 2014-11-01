//
//  ExpressionParser.h
//  ServiceMaxiPhone
//
//  Created by Aparna on 13/08/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//


@interface SFExpressionParser : NSObject

@property(nonatomic, strong) NSString *objectName;
@property(nonatomic, strong) NSString *expressionId;

- (id)initWithExpressionId:(NSString *)expressionId objectName:(NSString *)objectName;
- (BOOL)isEntryCriteriaMatchingForRecordId:(NSString *)recordId;
- (NSArray *)expressionCriteriaObjects;
- (NSString *)advanceExpression;
- (NSString *) errorMessage;
- (NSArray *)expressionCriteriaObjectsForComponents:(NSArray *)componentArray;
@end
