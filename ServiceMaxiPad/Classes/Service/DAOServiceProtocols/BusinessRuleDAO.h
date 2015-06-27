//
//  BusinessRuleDAO.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 21/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import"CommonServiceDAO.h"

@protocol BusinessRuleDAO <CommonServiceDAO>

- (NSArray *)fetchBusinessRuleInfoByFields:(NSArray *)fieldNames andCriteriaArray:(NSArray *)criteriaArray;
- (NSArray *)fetchFieldUpdateRuleInfoByFields:(NSArray *)fieldNames andCriteriaArray:(NSArray *)criteriaArray;

@end
