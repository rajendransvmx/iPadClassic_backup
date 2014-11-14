//
//  BaseSFExpression.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFExpressionModel.h
 *  @class  SFExpressionModel
 *
 *  @brief
 *
 *   This is a modle class which holds all the info.
 *
 *  @author Shubha S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

@interface SFExpressionModel : NSObject

@property(nonatomic) NSInteger localId;
@property(nonatomic, strong) NSString *expressionId;
@property(nonatomic, strong) NSString *expression;
@property(nonatomic, strong) NSString *expressionName;
@property(nonatomic, strong) NSString *errorMessage;
@property(nonatomic, strong) NSString *sourceObjectName;
@property(nonatomic, strong) NSString *sequence;

- (id)init;
- (id)initWithArray:(NSArray *)dataArray;
+ (NSDictionary *)getMappingDictionary;

@end