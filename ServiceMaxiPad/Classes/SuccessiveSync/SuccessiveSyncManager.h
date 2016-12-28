//
//  SuccessiveSyncManager.h
//  ServiceMaxiPhone
//
//  Created by Aparna on 31/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModifiedRecordModel.h"

@interface SuccessiveSyncManager : NSObject

/**
 This method is used to get the shared instance of SuccessiveSyncManager
 @returns singleton instance of SuccessiveSyncManager.
 */
+ (SuccessiveSyncManager *)sharedSuccessiveSyncManager;

/**
 This method  indicates whether to perform successive sync or not.
 @param localId is the id of a record for which successive sync to be triggered
 @returns boolean value to indicate whether successive sync is required for a record or not.
 */
- (BOOL) shouldPerformSyccessiveSync:(NSString *)localId;

/**
 This method is used to update an existing record stored by the SuccessiveSyncManager
 @param syncRecord is the record to be updated
 */
- (void) updateSuccessiveSyncRecord:(ModifiedRecordModel *)syncRecord;

/**
 This method removes the syncRecord from the SuccessiveSyncManager cache
 @param localId is the id of a record for which successive sync is no more required
 */
- (void) removeSuccessiveSyncRecordForLocalId:(NSString *)localId;

/**
 This method  is to invoke the successive sync.
 */
- (void) doSuccessiveSync;

/**
 This method removes all the successive sync records cahed by the SuccessiveSyncManager
 */
- (void) resetData;


- (void) registerForSuccessiveSync:(ModifiedRecordModel *)syncRecord withData:(id)record;

- (void) removeSuccessiveSyncRecordForLocalIds:(NSArray *)localIds;

- (BOOL)updateRecord:(NSDictionary *)record inObjectName:(NSString *)objectName andLocalId:(NSString *)localId;
- (ModifiedRecordModel *) successiveSyncRecordForSfId:(NSString *)sfId;

- (ModifiedRecordModel *)getSyncRecordModelFromSuccessiveSyncRecords:(NSString *)localId;

@property (nonatomic,strong) NSMutableDictionary *whatIdsToDelete;

@end
