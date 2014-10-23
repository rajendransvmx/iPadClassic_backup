//
//  BaseProcessBusinessRule.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   ProcessBusinessRuleModel.h
 *  @class  ProcessBusinessRuleModel
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


@interface ProcessBusinessRuleModel : NSObject

@property(nonatomic, strong) NSString *Id;
@property(nonatomic, strong) NSString *businessRule;
@property(nonatomic, strong) NSString *errorMessage;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *processNodeObject;
@property(nonatomic, strong) NSString *sequence;
@property(nonatomic, strong) NSString *targetManager;

- (id)init;

- (void)explainMe;

+ (NSDictionary*)getMappingDictionary;


@end