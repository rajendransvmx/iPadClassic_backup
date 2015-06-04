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
#import "SQLResultSet.h"
@protocol TransactionObjectDAO <CommonServiceDAO>

- (TransactionObjectModel *)getDataForObject:(NSString *)objectName fields:(NSArray *)fieldNames recordId:(NSString *)recordId;
- (TransactionObjectModel *)getLocalIDForObject:(NSString *)objectName recordId:(NSString *)recordId;
- (TransactionObjectModel *)getTechnicianIdForObject:(NSString *)objectName ownerId:(NSString *)ownerId;
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

- (NSArray *)fetchEventDataForObject:(NSString *)objectName
                              fields:(NSArray *)fieldNames
                          expression:(NSString *)advancaeExpression
                            criteria:(NSArray *)criteria;

- (BOOL)isTransactiontableEmpty:(NSString *)objectName;
- (BOOL)isTransactionTableExist:(NSString *)objectName;  // BSP 2-June

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

- (NSMutableArray *)getDataForSearchQuery:(NSString *)selectQuery forSearchFields:(NSArray *)searchFields;

-(BOOL)doesRecordExistsForObject:(NSString *)objectName forRecordId:(NSString *)recordId;

- (NSDictionary*)resultDictionaryForFields:(NSArray *)fields withResultset:(SQLResultSet *)resultSet;

- (NSArray *)fetchDataWithhAllFieldsAsStringObjects:(NSString *)objectName
fields:(NSArray *)fieldNames
expression:(NSString *)advancaeExpression
                                           criteria:(NSArray *)criteria;


#pragma mark DataPurge
- (NSArray *)getLocalIDForObject:(NSString *)objectName recordIds:(NSArray *)recordIds;
#pragma End

#pragma mark - for sfmpage precision fix
- (NSArray *)fetchDataForObjectForSfmPage:(NSString *)objectName fields:(NSArray *)fieldNames expression:(NSString *)advancaeExpression
                                 criteria:(NSArray *)criteria;

- (NSMutableArray *)getDetailsDataForQueryForSfmPage:(DBRequestSelect *)selectQuery;

#pragma End
@end