//
//  SMDataPurgeHelper.h
//  ServiceMaxMobile
//
//  Created by Vipindas on 1/6/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVMXSystemConstant.h"
#import "AppDelegate.h"
#import "SMDataPurgeModel.h"

@interface SMDataPurgeHelper : NSObject
{
    AppDelegate * appDelegate;
}


// Store Successful DP finish time
// Retrieve Successful DP finish time
+ (void)startedConfigSyncTime;
+ (void)saveConfigSyncTimeSinceSyncCompleted;
+ (void)saveDataPurgeTimeSinceCompleted;
+ (void)updateNextDataPurgeTime:(NSDate *)date;
+ (void)saveDataPurgeStatusSinceCompleted:(NSString *)status;
+ (void)saveIfDataPurgeDue:(BOOL)isDue; //9946 Defect Fix
+ (BOOL)isPurgeDue;
+ (NSString *)lastDataPurgeStatus;
+ (NSDate *)retrieveLastSuccesDPTime;
+ (NSDate *)retrieveNextDPTime;
+ (NSDate *)lastSuccessConfigSyncTimeForDataPurge;

//Database related operation
// Fetch All Grace period Records
// Fetch Purgeable DOD Records

// Fetch Purgeable non - DOD Records

// Fetch Events and related Records
//
+ (NSMutableArray *)getAllRecordsFromDatabase:(NSArray *)data;
+ (NSMutableArray *)getUniqueRecordsFromDatabase:(NSArray *)data;

+ (NSMutableDictionary *)retieveKeyPrefixWithObjecName;
+ (NSString *)retrieveObjectNameForWhatId:(NSString *)whatId;
+ (void)getAllGarceLimitRecrordsForModel:(SMDataPurgeModel *)model
                                                       criteria:(NSString *)criteria
                                                trialerCriteria:(NSString *)trialerCriteria;

+ (void)getAllNonGraceLimitRecrordsForModel:(SMDataPurgeModel *)model
                                          criteria:(NSString *)criteria
                                   trialerCriteria:(NSString *)trialerCriteria;

+ (void)getAllGarceDODRecrds:(SMDataPurgeModel *)model filterCriteria:(NSString *)criteria;;
+ (void)getAllNonGraceDODRecrds:(SMDataPurgeModel *)model filterCriteria:(NSString *)criteria;

+ (NSMutableArray *)getAllEventRelatedWhatId;
+ (NSMutableArray *)getAllChildIdsForObject:(SMObjectRelationModel *)relatioModel parentId:(NSMutableArray *)Ids
                               parentName:(NSString *)parentObject; //9990 defect fix :- Method prototype is changed

+ (NSArray *)getAllTransactionalObjectName;
+ (BOOL)isEmptyTable:(NSString *)tableName;
+ (NSArray *)findAndFillChildAndRelatedObjectForModel:(SMDataPurgeModel *)model;
+ (void)purgeDataForObject:(SMDataPurgeModel *)model;
+ (void)executeDataPurging:(SMDataPurgeModel *)model;
+ (void)fillPurgeableRecordForIsolatedChild:(SMDataPurgeModel *)model parent:(SMDataPurgeModel *)parentModel column:(NSString *)columnName;//9969 Defect Fix
+ (NSMutableSet *)getPurgeableOrNonPurgableRecordForIsolatedChild:(NSString *)object ids:(NSMutableSet *)parentIds
                                                           column:(NSString *)columnName; //9969 Defect Fix
+ (void)updatePurgableSetForChild:(SMDataPurgeModel *)model purgableset:(NSMutableSet *)set;//9969 Defect Fix
+ (NSArray *)getRelatedRecordNameForTable:(NSString *)tableNameOrApiName;
+ (void)purgeRelatedRecordsForAttachment:(SMDataPurgeModel *)model;
+ (void)getNonGracePeriodTrailerTableRecords:(SMDataPurgeModel *)model trailerCriteria:(NSString *)trailerCriteria;
+ (NSMutableDictionary *)retrieveConflictRecordMap;
+ (void)retrievePurgeableConflictRecordForModel:(SMDataPurgeModel *)model conflictMap:(NSMutableDictionary *)confictMapDict;
+ (void)purgeAllDODTrailerAndConflictTableRecord:(NSString *)tableName column:(NSString *)columnName
                                      deletingId:(NSString *)idSeparetedByComas;
+ (NSMutableDictionary *)relationshipKeyDictionaryForRelationshipModel:(SMObjectRelationModel *)model;
+ (void)checkForDODTrailerAndConflictRecrdToPurge:(SMDataPurgeModel *)model;
+ (void)initiateDataBaseCleanUp;

@end