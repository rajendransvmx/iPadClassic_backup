//
//  CommonServiceDAO.h
//  ServiceMaxMobile
//
//  Created by shravya on 20/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBCriteria.h"

@protocol CommonServiceDAO <NSObject>

- (BOOL)saveRecordsInTransaction:(id )model;
- (BOOL)saveRecordModel:(id )model;
- (BOOL)saveRecordModels:(NSMutableArray *)recordsArray ;
- (NSString *)tableName;
-(BOOL)updateEachRecord:(id)model  withQuery:(NSString *)query_;
- (NSString *)updateQuery;
-(BOOL)updateEachRecord:(id)model  withFields:(NSArray *)fieldsArray withCriteria:(NSArray *)criteriaArray;
-(void)updateRecords:(NSArray *)modelsArray  withFields:(NSArray *)fieldsArray withCriteria:(NSArray *)criteriaArray;
- (NSInteger)getNumberOfRecordsFromObject:(NSString *)objectName
                           withDbCriteria:(NSArray *)criterias
                    andAdvancedExpression:(NSString *)advancedExpression;
- (BOOL)doesRecordExistInTheTable;
@optional
- (BOOL)removeLocalIdField;
- (NSArray *)fieldNamesToBeRemovedFromQuery;

- (BOOL)executeStatement:(NSString*)queryStatement;

- (BOOL)deleteRecordsFromObject:(NSString *)objectName
                  whereCriteria:(NSArray *)criteriaArray
           andAdvanceExpression:(NSString *)advanceExpression;

- (BOOL)doesObjectHavePermission:(NSString *)objectName;

@end
