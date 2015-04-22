//
//  BaseSFExpressionComponent.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFExpressionComponentModel.h
 *  @class  SFExpressionComponentModel
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


@interface SFExpressionComponentModel : NSObject

@property(nonatomic) NSInteger localId;

@property(nonatomic) double componentSequenceNumber;

@property(nonatomic, strong) NSString *expressionId;
@property(nonatomic, strong) NSString *componentLHS;
@property(nonatomic, strong) NSString *componentRHS;
@property(nonatomic, strong) NSString *fieldType;
@property(nonatomic, strong) NSString *expressionType;
@property(nonatomic, strong) NSString *parameterType;
@property(nonatomic, strong) NSString *operatorValue;

- (id)init;
- (id)initWithArray:(NSArray *)dataArray;
+ (NSDictionary *)getMappingDictionary;
@end