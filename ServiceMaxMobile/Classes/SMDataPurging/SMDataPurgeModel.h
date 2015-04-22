//
//  SMDataPurgeModel.h
//  ServiceMaxMobile
//
//  Created by Vipindas on 1/3/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMObjectRelationModel.h"

//9969 Defect Fix
typedef enum DPIsolatedObjectName
{
    DPIsolatedObjectNameNotIsolated = 0, //Not isolated, By default all objects are not isolated
    DPIsolatedObjectNamePriceBookEntry = 1,
    
}DPIsolatedObjectName;

typedef enum DPActionStatus
{
    DPActionStatusUnknown = -1,
    DPActionStatusNonPurgeableSinceBelongsToDownloadCriteria = 1,
    DPActionStatusNonPurgeableSinceEvents = 2,
    DPActionStatusNonPurgeableSinceTask = 3,
    DPActionStatusNonPurgeableSinceChatter = 4,
    DPActionStatusNonPurgeableSinceLocationTracking = 5,
    DPActionStatusNonPurgeableSinceDataUnavailable = 6,
    DPActionStatusNonPurgeableSinceUser = 7,
    DPActionStatusNonPurgeableSinceRecordType = 8,
    DPActionStatusNonPurgeableSincePricebook = 9,           //9982 Defect Fix
    DPActionStatusNonPurgeableSinceCodeSnippet = 10,
    DPActionStatusNonPurgeableSinceCodeSnippetManifest = 11,
    DPActionStatusAwaited = 51,
    DPActionStatusInProgress = 81,
    DPActionStatusFailed = 91,
    DPActionStatusCompleted = 100,
}DPActionStatus;

@class SMDataPurgeManager;

@interface SMDataPurgeModel : NSObject


@property (nonatomic, retain)NSString *name;
@property (nonatomic, assign)DPActionStatus status;
@property (nonatomic, assign)DPIsolatedObjectName isolatedName; //9969 Defect Fix
@property (nonatomic, retain)NSString *purgeableStatus;

@property (nonatomic, retain)NSMutableArray *advancedOrDownloadedCriteriaRecords;
@property (nonatomic, retain)NSMutableArray *gracePeriodRecords;
@property (nonatomic, retain)NSMutableArray *purgeableNonGracePeriodRecords;
@property (nonatomic, retain)NSMutableArray *purgeableTrailerTableRecords;
@property (nonatomic, retain)NSMutableArray *purgeableConflictRecords;
@property (nonatomic, retain)NSMutableArray *purgeableDODRecords;
@property (nonatomic, retain)NSMutableArray *nonPurgeableDODRecords;
@property (nonatomic, retain)NSMutableArray *eventsRelatedRecords;
@property (nonatomic, retain)NSMutableArray *childRecordsOfEvents;
@property (nonatomic, retain)NSMutableArray *parentObjectNames; //9969 Defect Fix
@property (nonatomic, retain)NSMutableArray *purgeableChilds;
@property (nonatomic, retain)NSMutableArray *nonPurgeableChilds;
@property (nonatomic, retain)NSMutableArray *purgeableRelatedObjects;
@property (nonatomic, retain)NSMutableArray *purgeableReferenceObjects;
@property (nonatomic, retain)NSMutableArray *nonPurgeableRecordIdsAsAChilds;
@property (nonatomic, retain)NSMutableArray *nonPurgeableRecordIdsAsARelatedTable;


@property (nonatomic, retain)NSMutableSet *nonPurgeableRecordSet;
@property (nonatomic, retain)NSMutableSet *purgeableRecordSet;
@property (nonatomic, retain)NSMutableSet *purgedRecordSet;


- (id)initWithName:(NSString *)objectNameOrApiName;

- (BOOL)isPurgeable;
- (BOOL)hasDeletionPrecedenceByParent;

- (BOOL)isAttachmentObject;
- (BOOL)isChatterObject;
- (BOOL)isEventObject;
- (BOOL)isTaskObject;
- (BOOL)isLocationTrackingObject;
- (BOOL)isEmptyTable;
- (BOOL)isUserObject;
- (BOOL)isRcordTypeObject;
- (BOOL)isCompleted;
- (BOOL)hasError;
- (BOOL)isPriceBook;  //9982 defect Fix
- (BOOL)isCodeSnippetObject;
- (BOOL)isCodeSnippetManifestObject;

- (void)generatePurgeReport;


- (NSString *)displayStatus;

- (void)addDownloadedCriteriaObject:(NSString *)recordId;
- (void)addGracePeriodRecord:(NSString *)recordId;
- (void)addPurgeableNonGracePeriodRecords:(NSString *)recordId;
- (void)addPurgeableTrailerTableRecords:(NSString *)recordId;
- (void)addPurgeableConflictRecords:(NSString *)recordId;
- (void)addPurgeableDODRecord:(NSString *)recordId;
- (void)addNonPurgeableDODRecord:(NSString *)recordId;
- (void)addPurgeableRelatedObject:(NSString *)recordId;
- (void)addNonPurgeableChild:(NSString *)recordId;
- (void)addPurgeableChild:(SMObjectRelationModel *)objectModel;
- (void)addChildRecordsOfEvents:(NSString *)recordId;
- (void)addEventsRelatedRecord:(NSString *)recordId;
- (void)addNonPurgeableRecordIdsAsAChilds:(NSString *)recordId;
- (void)addNonPurgeableRecordIdsAsARelatedTable:(NSString *)recordId;
- (void)addPurgeableReferenceObject:(SMObjectRelationModel *)objectModel;
- (void)addParentObjectNames:(NSMutableDictionary *)objectDict; //9969 Defect Fix


- (void)aggregateNonPurgeableRecords;
- (void)doFinalAggregationForNonPurgeableRecords;

- (BOOL)shouldPurgeWithParent; //9969 Defect Fix

@end
