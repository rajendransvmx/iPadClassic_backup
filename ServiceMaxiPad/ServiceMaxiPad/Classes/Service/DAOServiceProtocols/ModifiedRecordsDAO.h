//
//  ModifiedRecordsDAO.h
//  ServiceMaxMobile
//
//  Created by Sahana on 08/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonServiceDAO.h"
@protocol ModifiedRecordsDAO <CommonServiceDAO>
- (NSDictionary *) getDeletedRecords;
- (NSDictionary *) getInsertedSyncRecords;
- (NSDictionary *) getUpdatedRecords;
- (NSInteger)getLastLocalId ;

- (NSMutableDictionary *) getSyncRecordsOfType:(NSString *)opertationType;
-(BOOL)deleteRecordsForRecordLocalIds:(NSArray *)recordsIds;
- (NSArray *) getSyncRecordsOfType:(NSString *)opertationType andObjectName:(NSString *)objectName;
- (BOOL)doesRecordExistForId:(NSString *)someRecordId;

@end
