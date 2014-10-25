//
//  CalenderDAO.h
//  ServiceMaxMobile
//
//  Created by Sudguru Prasad on 07/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransactionObjectModel.h"

@protocol CalenderDAO <CommonServiceDAO>

- (NSArray *)fetchDataForObject:(NSString *)objectName  fields:(NSArray *)fieldNames expression:(NSString *)advancaeExpression criteria:(NSArray *)criteria;

-(NSDictionary *) fetchSFObjectTableDataForFields:(NSArray *)fieldNames criteria:(NSArray *)criteria andExpression:(NSString *)expression;

- (TransactionObjectModel *)getRecordForSalesforceId:(NSString *)salesforceId;
- (TransactionObjectModel *)getRecordForSalesforceId:(NSString *)salesforceId
                                      andDBCriterias:(NSArray *)dbCriterias
                               andAdvancedExpression:(NSString *)expression;

-(BOOL)updateEachRecord:(NSDictionary *)dictionary  withFields:(NSArray *)fieldsArray withCriteria:(NSArray *)criteriaArray withTableName:(NSString *)tableName;

-(NSArray *)conflictStatusOfChildInTable:(NSString *)tableName withWhatID:(NSString *)whatID andLocalID:(NSString *)localID forParentTable:(NSString *)parentTableName;

@end
