//
//  BusinessRuleResult.h
//  ServiceMaxiPhone
//
//  Created by Aparna on 11/06/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BusinessRuleResult : NSObject

/**
 NSString Instance to hold name of the object on which business rule is applied
 */
@property(nonatomic, strong) NSString *objectName;

/**
 NSString instance to hold the type of business rule (error/confirmation)
 */
@property(nonatomic, strong) NSString *messgaeType;

/**
 NSString instance to hold the business rule message to be shown.
 */
@property(nonatomic, strong) NSString *message;

/**
 NSString instance to hold the id of the business rule
 */
@property(nonatomic, strong) NSString *fieldLabel;

/**
 NSString instance to hold the id of the business rule
 */
@property(nonatomic, strong) NSString *ruleId;

@end
