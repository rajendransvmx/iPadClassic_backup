//
//  CustomActionsDAO.h
//  ServiceMaxiPad
//
//  Created by Vincent Sagar on 01/11/17.
//  Copyright © 2017 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonServiceDAO.h"
#import "ModifiedRecordModel.h"
@protocol CustomActionsDAO <CommonServiceDAO>
- (NSDictionary *) getDeletedRecords;
- (NSDictionary *) getInsertedSyncRecords;
- (NSDictionary *) getUpdatedRecords;
- (NSInteger)getLastLocalId ;

- (NSMutableDictionary *) getSyncRecordsOfType:(NSString *)opertationType;
-(BOOL)deleteRecordsForRecordLocalIds:(NSArray *)recordsIds;
-(BOOL)deleteUpdatedRecordsForRecordLocalId:(NSString *)recordsId;
- (NSArray *) getSyncRecordsOfType:(NSString *)opertationType andObjectName:(NSString *)objectName;
- (BOOL)doesRecordExistForId:(NSString *)someRecordId;

-(void)updateModifiedRecord:(ModifiedRecordModel *)model;
-(void)updateFieldsModifed:(ModifiedRecordModel *)model;
- (NSString *)fetchExistingModifiedFieldsJsonFromModifiedRecordForRecordId:(NSString*)recordId andSfId:(NSString*)sfId;
- (ModifiedRecordModel *)fetchExistingModifiedFieldsJsonFromModifiedRecordForRecordIdForProductIQ:(NSString*)recordId
                                                                                          andSfId:(NSString*)sfId;
- (BOOL)doesRecordExistForId:(NSString *)recordId andOperationType:(NSString *)operationType;
- (BOOL)doesRecordExistForId:(NSString *)recordId andOperationType:(NSString *)operationType andparentID:(NSString *)parentID;

- (NSArray *)getTheOperationValue;


-(BOOL)deleteUpdatedRecordsForModifiedRecordModel:(ModifiedRecordModel *)model; // CustomCall. TO delete the record which is updated.
- (NSArray *)getModifiedRecordListforRecordId:(NSString *)recordID sfid:(NSString *)sfId;

-(NSArray *)recordForRecordId:(NSString *)someRecordId;
-(NSArray *)childRecordForParentLocalId:(NSString *)someRecordId;
-(void)updateCustomActionFlagForRecord:(ModifiedRecordModel *)model;
-(NSArray *)getCustomActionRequestParamsRecord;

-(void)updateRecordsSent:(ModifiedRecordModel *)model;
- (BOOL)doesAnyRecordExistForSyncing;
- (BOOL)checkIfNonInsertRecordsExist;
-(BOOL)checkIfNonAfterSaveInsertRecordsExist;//HS1June
- (NSArray *)getInsertRecordsAsArray;

@end
