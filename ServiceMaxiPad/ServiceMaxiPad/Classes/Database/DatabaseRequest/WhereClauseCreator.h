//
//  WhereClauseCreator.h
//  ServiceMaxMobile
//
//  Created by Shravya on 10/08/14.
//  Copyright (c) 2014 SivaManne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBRequestConstant.h"


@interface WhereClauseCreator : NSObject

- (id)initWithCriteriaArray:(NSArray *)criteriaArray
      andAdvancedExpression:(NSString *)expression;
- (NSString *)whereClause;

@end
