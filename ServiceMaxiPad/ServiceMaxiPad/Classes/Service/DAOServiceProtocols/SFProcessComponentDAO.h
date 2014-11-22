//
//  SFProcessComponentDAO.h
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 19/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SFProcessComponentDAO <NSObject>

- (NSArray *)fetchSFProcessComponentsByCriteria:(id)criteria;

- (NSArray * )fetchSFProcessComponentsByFields:(NSArray *)fieldNames
                                   andCriteria:(NSArray *)criteria
                                 andExpression:(NSString *)expression;
- (NSArray *)getAllObjectApiNames;

@end
