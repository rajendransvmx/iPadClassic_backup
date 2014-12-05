//
//  ResolveConflictsHelper.h
//  ServiceMaxiPad
//
//  Created by Padmashree on 03/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "CommonServices.h"
#import "SyncErrorConflictModel.h"
extern NSString *const kResolveConflictRetry;
extern NSString *const kResolveConflictRemove;
extern NSString *const kResolveConflictHold;
extern NSString *const kResolveConflictApplyLocalChanges;
extern NSString *const kResolveConflictApplyServerChanges;

extern NSString *const kSyncConflictChangeNotification;
@interface ResolveConflictsHelper : CommonServices

+ (NSInteger)getConflictsCount;
+ (NSArray *)getConflictsRecords;
+ (BOOL)checkResolvedConflicts;
+ (NSString *)getLocalizedUserResolutionStringForDatabaseString:(NSString *)databaseString;
+ (NSArray *)fetchLocalizedUserResolutionOptionsForConflict:(SyncErrorConflictModel *)model;
+ (NSString *)getDatabaseStringForLocalizedUserResolution:(NSString *)userResolutionString;
+ (void)saveConflict:(SyncErrorConflictModel *)conflict;
+ (void)sendSyncConflictChangeNotificationWithObject:(id)object;
+(NSArray *)fetchSfIdsFromConflictRecords;
+(NSInteger)getNonHoldConflictsCount;
@end
