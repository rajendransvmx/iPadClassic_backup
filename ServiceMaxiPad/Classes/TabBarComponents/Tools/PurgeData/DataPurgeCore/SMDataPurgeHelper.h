//
//  SMDataPurgeHelper.h
//  ServiceMaxiPad
//
//  Created by Pushpak on 16/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMDataPurgeModel.h"
#import "DBCriteria.h"

@interface SMDataPurgeHelper : NSObject
/*
    Store Successful DP finish time
    Retrieve Successful DP finish time
 */
+ (void)startedConfigSyncTime;

+ (void)saveConfigSyncTimeSinceSyncCompleted;

+ (void)saveDataPurgeTimeSinceCompleted;

+ (void)updateNextDataPurgeTime:(NSDate *)date;

+ (void)saveDataPurgeStatusSinceCompleted:(NSString *)status;

+ (void)saveIfDataPurgeDue:(BOOL)isDue;

+ (BOOL)isPurgeDue;

+ (NSString *)lastDataPurgeStatus;

+ (NSDate *)retrieveLastSuccesDPTime;

+ (NSDate *)retrieveNextDPTime;

+ (NSDate *)lastSuccessConfigSyncTimeForDataPurge;

/*
    Database related operation
    Fetch All Grace period Records
    Fetch Purgeable DOD Records
    Fetch Purgeable non - DOD Records
    Fetch Events and related Records
*/
+ (NSMutableDictionary *)retieveKeyPrefixWithObjecName;

+ (void)getAllGarceLimitRecrordsForModel:(SMDataPurgeModel *)model
                                criteria:(DBCriteria *)criteria
                         trialerCriteria:(DBCriteria *)trialerCriteria;

+ (void)getAllNonGraceLimitRecrordsForModel:(SMDataPurgeModel *)model
                                   criteria:(DBCriteria *)criteria
                            trialerCriteria:(DBCriteria *)trialerCriteria;

+ (void)getAllGarceDODRecrds:(SMDataPurgeModel *)model
              filterCriteria:(DBCriteria *)criteria;

+ (void)getAllGraceNonGraceDODRecords:(SMDataPurgeModel *)model
                 filterCriteria:(DBCriteria *)criteria;

+ (NSMutableArray *)getAllEventRelatedWhatId;

+ (NSMutableArray *)getAllChildIdsForObject:(SMObjectRelationModel *)relatioModel
                                   parentId:(NSMutableArray *)Ids
                                 parentName:(NSString *)parentObject;

+ (NSArray *)getAllTransactionalObjectName;

+ (BOOL)isEmptyTable:(NSString *)tableName;

+ (NSArray *)findAndFillChildAndRelatedObjectForModel:(SMDataPurgeModel *)model;

+ (void)purgeDataForObject:(SMDataPurgeModel *)model;

+ (void)executeDataPurging:(SMDataPurgeModel *)model;

+ (void)fillPurgeableRecordForIsolatedChild:(SMDataPurgeModel *)model
                                     parent:(SMDataPurgeModel *)parentModel column:(NSString *)columnName;

+ (NSMutableSet *)getPurgeableOrNonPurgableRecordForIsolatedChild:(NSString *)object
                                                              ids:(NSMutableSet *)parentIds
                                                           column:(NSString *)columnName;

+ (void)updatePurgableSetForChild:(SMDataPurgeModel *)model
                      purgableset:(NSMutableSet *)set;

+ (NSArray *)getRelatedRecordNameForTable:(NSString *)tableNameOrApiName;

+ (void)purgeRelatedRecordsForAttachment:(SMDataPurgeModel *)model;

+ (void)getNonGracePeriodTrailerTableRecords:(SMDataPurgeModel *)model
                             trailerCriteria:(DBCriteria *)trailerCriteria;

+ (NSMutableDictionary *)retrieveConflictRecordMap;

+ (void)retrievePurgeableConflictRecordForModel:(SMDataPurgeModel *)model
                                    conflictMap:(NSMutableDictionary *)confictMapDict;

+ (void)purgeAllDODTrailerAndConflictTableRecord:(NSString *)tableName
                                          column:(NSString *)columnName
                                      deletingId:(NSArray *)idSeparetedByComas;

+ (NSMutableDictionary *)relationshipKeyDictionaryForRelationshipModel:(SMObjectRelationModel *)model;

+ (void)checkForDODTrailerAndConflictRecrdToPurge:(SMDataPurgeModel *)model;

+ (void)initiateDataBaseCleanUp;

+ (NSString *)getDataPurgeRecordOlderThanSettingsValue;

+ (NSString *)getDataPurgeFrequencySettingsValue;

+ (NSTimeInterval)getTimerIntervalForDataPurge;

+ (NSMutableDictionary *)populatePurgeMapFromDataPurgeTable;

//For ProductIQ
+ (void)saveLocationSfIdsFromDataPurgeTableForWorkOrderObject;

+ (void)clearDataPurgeTableContents;
@end
