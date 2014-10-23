//
//  TransactionObjectDAO.h
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 22/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransactionObjectModel.h"
#import "DBRequestSelect.h"
#import "CommonServiceDAO.h"

@protocol TransactionObjectDAO <CommonServiceDAO>

- (TransactionObjectModel *)getDataForObject:(NSString *)objectName fields:(NSArray *)fieldNames recordId:(NSString *)recordId;
- (TransactionObjectModel *)getLocalIDForObject:(NSString *)objectName recordId:(NSString *)recordId;
- (TransactionObjectModel *)getDataForObject:(NSString *)objectName
                                      fields:(NSArray *)fieldNames
                                  expression:(NSString *)advancaeExpression
                                    criteria:(NSArray *)criteria;
- (NSArray *)fetchDataForObject:(NSString *)objectName
                         fields:(NSArray *)fieldNames
                     expression:(NSString *)advancaeExpression
                       criteria:(NSArray *)criteria;

- (NSArray *)fetchDetailDataForObject:(NSString *)objectName
                         fields:(NSArray *)fieldNames
                     expression:(NSString *)advancaeExpression
                       criteria:(NSArray *)criteria
                    withSorting:(NSDictionary *)sortingData;
- (BOOL)isTransactiontableEmpty:(NSString *)objectName;

- (NSArray *)getListWorkorderCurrencies;


-(BOOL)updateEachRecord:(NSDictionary *)dictionary  withFields:(NSArray *)fieldsArray withCriteria:(NSArray *)criteriaArray withTableName:(NSString *)tableName;

-(BOOL)isRecordExistsForObject:(NSString *)objectName forRecordLocalId:(NSString *)recordLoclaId;

-(NSString *)getSfIdForLocalId:(NSString *)recordLoclaId forObjectName:(NSString *)objectName;

- (BOOL)insertTransactionObjects:(NSArray *)transactionObjects
                    andDbRequest:(NSString *)insertQuery;

- (BOOL)updateOrInsertTransactionObjects:(NSArray *)transactionObjects
                          withObjectName:(NSString *)objectName
                            andDbRequest:(id)insertRequest
                        andUpdateRequest:(id)dbRequestUpdate;

- (NSArray *)fetchDataForObject:(NSString *)objectName
                         fields:(NSArray *)fieldNames
                     expression:(NSString *)advancaeExpression
                       criteria:(NSArray *)criteria
                   recordsLimit:(NSInteger)recordLimit;

- (NSMutableArray *)getDataForSearchQuery:(NSString *)selectQuery;
@end
