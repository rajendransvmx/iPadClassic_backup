//
//  BaseBusinessRule.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   BusinessRuleModel.h
 *  @class  BusinessRuleModel
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

@interface BusinessRuleModel : NSObject

@property(nonatomic, strong) NSString *Id;
@property(nonatomic, strong) NSString *advancedExpression;
@property(nonatomic, strong) NSString *description;
@property(nonatomic, strong) NSString *errorMessage;
@property(nonatomic, strong) NSString *messageType;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *processId;
@property(nonatomic, strong) NSString *sourceObjectName;

- (id)init;

- (void)explainMe;

+ (NSDictionary *)getMappingDictionary;
@end