//
//  ProcessBusinessRuleDAO.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 21/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonServiceDAO.h"

@class ProcessBusinessRuleModel;

@protocol ProcessBusinessRuleDAO <CommonServiceDAO>
- (NSArray * )fetchProcessBusinessRuleInfoByFields:(NSArray *)fieldNames
                                andCriteria:(NSArray *)criteria
                              andExpression:(NSString *)expression;

- (NSArray * )fetchProcessBusinessRuleInfoByFields:(NSArray *)fieldNames
                                       andCriteria:(DBCriteria *)criteria;


@end
