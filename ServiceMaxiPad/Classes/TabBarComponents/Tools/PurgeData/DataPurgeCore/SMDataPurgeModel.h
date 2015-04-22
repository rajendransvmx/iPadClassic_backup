//
//  SMDataPurgeModel.h
//  ServiceMaxiPad
//
//  Created by Pushpak on 16/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMObjectRelationModel.h"

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
    DPActionStatusNonPurgeableSincePricebook = 9,
    DPActionStatusNonPurgeableSinceCodeSnippet = 10,
    DPActionStatusNonPurgeableSinceCodeSnippetManifest = 11,
    DPActionStatusAwaited = 51,
    DPActionStatusInProgress = 81,
    DPActionStatusFailed = 91,
    DPActionStatusCompleted = 100,
}DPActionStatus;

@class SMDataPurgeManager;

@interface SMDataPurgeModel : NSObject
@property (nonatomic, strong)NSString *name;
@property (nonatomic, assign)DPActionStatus status;
@property (nonatomic, assign)DPIsolatedObjectName isolatedName;
@property (nonatomic, strong)NSString *purgeableStatus;

@property (nonatomic, strong)NSMutableArray *advancedOrDownloadedCriteriaRecords;
@property (nonatomic, strong)NSMutableArray *gracePeriodRecords;
@property (nonatomic, strong)NSMutableArray *purgeableNonGracePeriodRecords;
@property (nonatomic, strong)NSMutableArray *purgeableTrailerTableRecords;
@property (nonatomic, strong)NSMutableArray *purgeableConflictRecords;
@property (nonatomic, strong)NSMutableArray *purgeableDODRecords;
@property (nonatomic, strong)NSMutableArray *nonPurgeableDODRecords;
@property (nonatomic, strong)NSMutableArray *eventsRelatedRecords;
@property (nonatomic, strong)NSMutableArray *childRecordsOfEvents;
@property (nonatomic, strong)NSMutableArray *parentObjectNames;
@property (nonatomic, strong)NSMutableArray *purgeableChilds;
@property (nonatomic, strong)NSMutableArray *nonPurgeableChilds;
@property (nonatomic, strong)NSMutableArray *purgeableRelatedObjects;
@property (nonatomic, strong)NSMutableArray *purgeableReferenceObjects;
@property (nonatomic, strong)NSMutableArray *nonPurgeableRecordIdsAsAChilds;
@property (nonatomic, strong)NSMutableArray *nonPurgeableRecordIdsAsARelatedTable;


@property (nonatomic, strong)NSMutableSet *nonPurgeableRecordSet;
@property (nonatomic, strong)NSMutableSet *purgeableRecordSet;
@property (nonatomic, strong)NSMutableSet *purgedRecordSet;


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
- (BOOL)isPriceBook;
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
- (void)addParentObjectNames:(NSMutableDictionary *)objectDict;


- (void)aggregateNonPurgeableRecords;
- (void)doFinalAggregationForNonPurgeableRecords;

- (BOOL)shouldPurgeWithParent;

@end
