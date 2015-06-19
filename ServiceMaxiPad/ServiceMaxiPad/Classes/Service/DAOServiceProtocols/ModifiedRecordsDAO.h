//
//  ModifiedRecordsDAO.h
//  ServiceMaxMobile
//
//  Created by Sahana on 08/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonServiceDAO.h"
#import "ModifiedRecordModel.h"
@protocol ModifiedRecordsDAO <CommonServiceDAO>
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
- (BOOL)doesRecordExistForId:(NSString *)recordId andOperationType:(NSString *)operationType;

@end