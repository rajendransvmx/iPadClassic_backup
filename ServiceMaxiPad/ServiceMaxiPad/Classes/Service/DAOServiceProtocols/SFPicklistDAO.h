//
//  SFPicklistDAO.h
//  ServiceMaxMobile
//
//  Created by shravya on 23/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonServiceDAO.h"
@class  DBCriteria;

@protocol SFPicklistDAO <CommonServiceDAO>

- (NSArray * )fetchSFPicklistByFields:(NSArray *)fieldNames andCriteria:(id)criteria;
- (NSArray * )fetchDistinctSFPicklistByFields:(NSArray *)fieldNames andCriteria:(NSArray *)criteria andExpression:(NSString *)expression;

- (NSArray * )fetchSFPicklistInfoByFields:(NSArray *)fieldNames
                              andCriteria:(NSArray *)criteria
                            andExpression:(NSString *)expression;

- (NSArray * )fetchSFPicklistInfoByFields:(NSArray *)fieldNames
                              andCriteria:(NSArray *)criteria
                            andExpression:(NSString *)expression
                                  OrderBy:(NSArray *)orberBy;

-(void)updateSFPicklistTable:(NSArray *)sfPickListTables;
- (NSArray *)getListOfLaborActivityType;

@end
