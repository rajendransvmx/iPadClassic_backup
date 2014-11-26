//
//  TransactionObjectService.h
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 22/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransactionObjectDAO.h"
#import "DBRequest.h"
#import "CommonServices.h"

@interface TransactionObjectService : CommonServices <TransactionObjectDAO>


- (BOOL)insertTransactionObjects:(NSArray *)transactionObjects
                    andDbRequest:(NSString *)insertQuery;
- (BOOL)updateField:(DBField *)field withValue:(NSString *)value andDbCriteria:(DBCriteria *)criteria;

- (BOOL)updateOrInsertTransactionObjects:(NSArray *)transactionObjects
                          withObjectName:(NSString *)objectName
                            andDbRequest:(DBRequest *)insertRequest
                        andUpdateRequest:(DBRequest *)dbRequestUpdate;
- (NSArray *)getFieldValueForObjectName:(NSString *)objectName andNameFiled:(NSString*)nameField;

- (NSString *)getFieldValueForObjectName:(NSString *)objectName nameFiled:(NSString*)nameField andLocalId:(NSString*)localId;


@end
