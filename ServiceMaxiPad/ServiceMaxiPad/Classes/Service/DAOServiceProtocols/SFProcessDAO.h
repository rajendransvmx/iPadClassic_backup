//
//  SFProcessDAO.h
//  ServiceMaxMobile
//
//  Created by Vipindas on 5/27/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonServiceDAO.h"
#import "SFProcessModel.h"

@protocol SFProcessDAO <CommonServiceDAO>

- (NSArray *)fetchSFProcessByFields:(NSArray *)fieldNames;

- (SFProcessModel *)getSFProcessBySalesForceId:(NSString *)sfId;
- (SFProcessModel *)fetchSFProcessBySalesForceId:(NSString *)sfId andFields:(NSArray *)fieldNames;

- (SFProcessModel *)fetchSFProcessByFields:(NSArray *)fieldNames andCriteria:(id)criteria;

- (NSArray * )fetchSFProcessInfoByFields:(NSArray *)fieldNames
                             andCriteria:(NSArray *)criteria
                           andExpression:(NSString *)expression;

- (SFProcessModel *)getSFProcessInfo:(id)criteria;

- (NSArray*)fetchPageLayoutIds;

-(void)updatePageDataForPageLayoutIds:(NSArray *)processArray;

- (NSArray*)fetchAllViewProcessForObjectName:(NSString*)objectName;
- (NSArray *)getProcessTypeForCriteria:(DBCriteria *)criteria;

-(NSArray *)getS2TEventProcessForObject:(NSString *)objectName;
@end

