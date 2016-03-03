//
//  SMDataPurgeModel.m
//  ServiceMaxiPad
//
//  Created by Pushpak on 16/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "SMDataPurgeModel.h"
#import "SMDataPurgeHelper.h"
#import "SMDataPurgeManager.h"


#define PURGECOUNT  1000

@implementation SMDataPurgeModel


- (void)verifyStatus
{
    // Should not purge below mentioned tables
    // Task
    // Event
    // User
    // RecordType
    // LocationTracking
    
    if ([self.name isEqualToString:@"Task"])
    {
        self.status = DPActionStatusNonPurgeableSinceTask;
    }
    else if ([self.name isEqualToString:@"Event"])
    {
        self.status = DPActionStatusNonPurgeableSinceEvents;
    }
    else if ([self.name isEqualToString:@"User"])
    {
        self.status = DPActionStatusNonPurgeableSinceUser;
    }
    else if ([self.name isEqualToString:@"RecordType"])
    {
        self.status = DPActionStatusNonPurgeableSinceRecordType;
    }
    else if ([self.name hasSuffix:@"User_GPS_Log__c"])
    {
        self.status = DPActionStatusNonPurgeableSinceLocationTracking;
    }
    else if ([self.name hasSuffix:@"Pricebook2"])
    {
        self.status = DPActionStatusNonPurgeableSincePricebook;
    }
    else if ([self.name hasSuffix:@"__Code_Snippet__c"])
    {
        self.status = DPActionStatusNonPurgeableSinceCodeSnippet;
    }
    else if ([self.name hasSuffix:@"__Code_Snippet_Manifest__c"])
    {
        self.status = DPActionStatusNonPurgeableSinceCodeSnippetManifest;
    }
    else
    {
        self.status = DPActionStatusAwaited;
    }
}

- (void)verifyIsolation
{
    //Special Handling for the child to be deleted if parent is deleted
    if ([self.name isEqualToString:@"PricebookEntry"])
    {
        self.isolatedName = DPIsolatedObjectNamePriceBookEntry;
    }
    else
    {
        self.isolatedName = DPIsolatedObjectNameNotIsolated;
    }
}

- (void)fillRelatedObject
{
    NSArray * relatedObjects = [SMDataPurgeHelper getRelatedRecordNameForTable:self.name];
    
    if (relatedObjects != nil)
    {
        NSMutableArray *records = [[NSMutableArray alloc] initWithArray:relatedObjects];
        self.purgeableRelatedObjects = records;
    }
}


- (id)initWithName:(NSString *)objectNameOrApiName
{
    self = [super init];
    
    if (self)
    {
        self.name = objectNameOrApiName;
        [self verifyStatus];
        [self verifyIsolation];
        [self fillRelatedObject];
    }
    
    return self;
}


- (BOOL) isPurgeable
{
    BOOL purgeable = YES;
    
    switch (self.status)
    {
        case DPActionStatusNonPurgeableSinceTask:
        case DPActionStatusNonPurgeableSinceEvents:
        case DPActionStatusNonPurgeableSinceChatter:
        case DPActionStatusNonPurgeableSinceDataUnavailable:
        case DPActionStatusNonPurgeableSinceLocationTracking:
        case DPActionStatusNonPurgeableSinceUser:
        case DPActionStatusNonPurgeableSinceRecordType:
        case DPActionStatusNonPurgeableSincePricebook:
        case DPActionStatusNonPurgeableSinceCodeSnippet:
        case DPActionStatusNonPurgeableSinceCodeSnippetManifest:
        {
            purgeable = NO;
            break;
        }
        default:
        {
            // In case of unknown status
            purgeable = YES;
            break;
        }
    }
    
    return  purgeable;
}



- (BOOL)hasDeletionPrecedenceByParent
{
    if ([self.name isEqualToString:@"Attachment"])
    {
        return YES;
    }
    return NO;
}

- (BOOL)isAttachmentObject
{
    if ([self.name isEqualToString:@"Attachment"])
    {
        return YES;
    }
    return NO;
}



- (BOOL)isChatterObject
{
    if (self.status == DPActionStatusNonPurgeableSinceChatter)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


- (BOOL)isEventObject
{
    if (self.status == DPActionStatusNonPurgeableSinceEvents)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


- (BOOL)isTaskObject
{
    if (self.status == DPActionStatusNonPurgeableSinceTask)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


- (BOOL)isLocationTrackingObject
{
    if (self.status == DPActionStatusNonPurgeableSinceLocationTracking)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


- (BOOL)isUserObject
{
    if (self.status == DPActionStatusNonPurgeableSinceUser)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


- (BOOL)isRcordTypeObject
{
    if (self.status == DPActionStatusNonPurgeableSinceRecordType)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)isPriceBook
{
    if (self.status == DPActionStatusNonPurgeableSincePricebook)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


- (BOOL)isCodeSnippetObject
{
    if (self.status == DPActionStatusNonPurgeableSinceCodeSnippet)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


- (BOOL)isCodeSnippetManifestObject
{
    if (self.status == DPActionStatusNonPurgeableSinceCodeSnippetManifest)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


- (BOOL)isEmptyTable
{
    if (self.status == DPActionStatusNonPurgeableSinceDataUnavailable)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


- (BOOL)isCompleted
{
    if (self.status == DPActionStatusCompleted)
    {
        return YES;
    }
    else
    {
        return NO;
    }
    
}


- (BOOL)hasError
{
    if (self.status == DPActionStatusFailed)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)shouldPurgeWithParent
{
    BOOL purgeWithParent = NO;
    
    if (self.isolatedName == DPIsolatedObjectNamePriceBookEntry)
    {
        purgeWithParent = YES;
    }
    return purgeWithParent;
}


- (NSString *)displayStatus
{
    // TODO : Vipin
    return @"";
}


- (void)addDownloadedCriteriaObject:(NSString *)recordId
{
    if (self.advancedOrDownloadedCriteriaRecords == nil)
    {
        NSMutableArray *records = [[NSMutableArray alloc] init];
        self.advancedOrDownloadedCriteriaRecords = records;
    }
    
    [self.advancedOrDownloadedCriteriaRecords addObject:recordId];
}


- (void)addGracePeriodRecord:(NSString *)recordId
{
    if (self.gracePeriodRecords == nil)
    {
        NSMutableArray *records = [[NSMutableArray alloc] init];
        self.gracePeriodRecords = records;
    }
    
    [self.gracePeriodRecords addObject:recordId];
}


- (void)addPurgeableNonGracePeriodRecords:(NSString *)recordId
{
    if (self.purgeableNonGracePeriodRecords == nil)
    {
        NSMutableArray *records = [[NSMutableArray alloc] init];
        self.purgeableNonGracePeriodRecords = records;
    }
    
    [self.purgeableNonGracePeriodRecords addObject:recordId];
}


- (void)addPurgeableTrailerTableRecords:(NSString *)recordId
{
    if (self.purgeableTrailerTableRecords == nil)
    {
        NSMutableArray *records = [[NSMutableArray alloc] init];
        self.purgeableTrailerTableRecords = records;
    }
    
    [self.purgeableTrailerTableRecords addObject:recordId];
}


- (void)addPurgeableConflictRecords:(NSString *)recordId
{
    if (self.purgeableConflictRecords == nil)
    {
        NSMutableArray *records = [[NSMutableArray alloc] init];
        self.purgeableConflictRecords = records;
    }
    
    [self.purgeableConflictRecords addObject:recordId];
}


- (void)addPurgeableDODRecord:(NSString *)recordId
{
    if (self.purgeableDODRecords == nil)
    {
        NSMutableArray *records = [[NSMutableArray alloc] init];
        self.purgeableDODRecords = records;
    }
    
    [self.purgeableDODRecords addObject:recordId];
}


- (void)addNonPurgeableDODRecord:(NSString *)recordId
{
    if (self.nonPurgeableDODRecords == nil)
    {
        NSMutableArray *records = [[NSMutableArray alloc] init];
        self.nonPurgeableDODRecords = records;
    }
    
    [self.nonPurgeableDODRecords addObject:recordId];
}


- (void)addPurgeableRelatedObject:(NSString *)objectName
{
    if (self.purgeableRelatedObjects == nil)
    {
        NSMutableArray *records = [[NSMutableArray alloc] init];
        self.purgeableRelatedObjects = records;
    }
    
    [self.purgeableRelatedObjects addObject:objectName];
}


- (void)addPurgeableReferenceObject:(SMObjectRelationModel *)objectModel
{
    if (self.purgeableReferenceObjects == nil)
    {
        NSMutableArray *records = [[NSMutableArray alloc] init];
        self.purgeableReferenceObjects = records;
    }
    
    [self.purgeableReferenceObjects addObject:objectModel];
}


- (void)addNonPurgeableChild:(NSString *)recordId
{
    if (self.nonPurgeableChilds == nil)
    {
        NSMutableArray *records = [[NSMutableArray alloc] init];
        self.nonPurgeableChilds = records;
    }
    
    [self.nonPurgeableChilds addObject:recordId];
}


- (void)addPurgeableChild:(SMObjectRelationModel *)objectModel
{
    if (self.purgeableChilds == nil)
    {
        NSMutableArray *records = [[NSMutableArray alloc] init];
        self.purgeableChilds = records;
    }
    
    [self.purgeableChilds addObject:objectModel];
}


- (void)addChildRecordsOfEvents:(NSString *)recordId
{
    if (self.childRecordsOfEvents == nil)
    {
        NSMutableArray *records = [[NSMutableArray alloc] init];
        self.childRecordsOfEvents = records;
    }
    
    [self.childRecordsOfEvents addObject:recordId];
}


- (void)addEventsRelatedRecord:(NSString *)recordId
{
    if (self.eventsRelatedRecords == nil)
    {
        NSMutableArray *records = [[NSMutableArray alloc] init];
        self.eventsRelatedRecords = records;
    }
    
    [self.eventsRelatedRecords addObject:recordId];
}


- (void)addNonPurgeableRecordIdsAsAChilds:(NSString *)recordId
{
    if (self.nonPurgeableRecordIdsAsAChilds == nil)
    {
        NSMutableArray *records = [[NSMutableArray alloc] init];
        self.nonPurgeableRecordIdsAsAChilds = records;
    }
    
    [self.nonPurgeableRecordIdsAsAChilds addObject:recordId];
}


- (void)addNonPurgeableRecordIdsAsARelatedTable:(NSString *)recordId
{
    if (self.nonPurgeableRecordIdsAsARelatedTable == nil)
    {
        NSMutableArray *records = [[NSMutableArray alloc] init];
        self.nonPurgeableRecordIdsAsARelatedTable = records;
    }
    
    [self.nonPurgeableRecordIdsAsARelatedTable addObject:recordId];
}


//9969 Defect Fix
- (void)addParentObjectNames:(NSMutableDictionary *)objectDict
{
    if (self.parentObjectNames == nil)
    {
        NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:0];
        self.parentObjectNames = array;
    }
    if (objectDict != nil)
        [self.parentObjectNames addObject:objectDict];
}


- (void)dealloc
{
    _purgeableStatus = nil;
    _name = nil;
    _advancedOrDownloadedCriteriaRecords = nil;
    _gracePeriodRecords = nil;
    
    _purgeableDODRecords = nil;
    _nonPurgeableDODRecords = nil;
    _eventsRelatedRecords = nil;
    _childRecordsOfEvents = nil;
    _purgeableChilds = nil;
    
    _nonPurgeableChilds = nil;
    _purgeableRelatedObjects = nil;
    _purgeableReferenceObjects = nil;
    _nonPurgeableRecordSet = nil;
    _purgeableRecordSet = nil;
    _purgedRecordSet = nil;
    _parentObjectNames = nil;
    
    _nonPurgeableRecordIdsAsAChilds = nil;
    _nonPurgeableRecordIdsAsARelatedTable = nil;
}


- (void)doFinalAggregationForNonPurgeableRecords
{
    if (self.nonPurgeableRecordSet == nil)
    {
        NSMutableSet *set = [[NSMutableSet alloc] init];
        self.nonPurgeableRecordSet = set;
    }
    
    if ((self.nonPurgeableRecordIdsAsAChilds != nil) && ([self.nonPurgeableRecordIdsAsAChilds count] > 0))
    {
        // Adding Records as child
        [self.nonPurgeableRecordSet addObjectsFromArray:self.nonPurgeableRecordIdsAsAChilds];
    }
    
    if ((self.nonPurgeableRecordIdsAsARelatedTable != nil) && ([self.nonPurgeableRecordIdsAsARelatedTable count] > 0))
    {
        // Adding Records as refernce
        [self.nonPurgeableRecordSet addObjectsFromArray:self.nonPurgeableRecordIdsAsARelatedTable];
    }
}


- (void)aggregateNonPurgeableRecords
{
    if (self.nonPurgeableRecordSet == nil)
    {
        NSMutableSet *set = [[NSMutableSet alloc] init];
        self.nonPurgeableRecordSet = set;
    }
    
    if ((self.advancedOrDownloadedCriteriaRecords != nil) && ([self.advancedOrDownloadedCriteriaRecords count] > 0))
    {
        // Adding Records which got by Downloaded Criteria, Adv. Downloaded Criteria and GetPrice Call
        [self.nonPurgeableRecordSet addObjectsFromArray:self.advancedOrDownloadedCriteriaRecords];
    }
    
    if ((self.gracePeriodRecords != nil) && ([self.gracePeriodRecords count] > 0))
    {
        // Adding Records which got by GracePeriod - Data Trailer Records
        [self.nonPurgeableRecordSet addObjectsFromArray:self.gracePeriodRecords];
    }
    
    if ((self.nonPurgeableDODRecords != nil) && ([self.nonPurgeableDODRecords count] > 0))
    {
        // Adding DOD Records which are falls under grace periods
        [self.nonPurgeableRecordSet addObjectsFromArray:self.nonPurgeableDODRecords];
    }
    
    if ((self.eventsRelatedRecords != nil) && ([self.eventsRelatedRecords count] > 0))
    {
        // Adding Records associated with Events
        [self.nonPurgeableRecordSet addObjectsFromArray:self.eventsRelatedRecords];
    }
    
    if ((self.childRecordsOfEvents != nil) && ([self.childRecordsOfEvents count] > 0))
    {
        // Adding Child Records associated with Events
        [self.nonPurgeableRecordSet addObjectsFromArray:self.childRecordsOfEvents];
    }
}

- (void)generatePurgeReport
{
    
    if (self.advancedOrDownloadedCriteriaRecords == nil)
    {
        // Just empty array
        NSMutableArray *records = [[NSMutableArray alloc] init];
        self.advancedOrDownloadedCriteriaRecords = records;
    }
    
    if (self.purgeableRecordSet == nil)
    {
        NSMutableSet *set = [[NSMutableSet alloc] init];
        self.purgeableRecordSet = set;
    }
    
    if (self.nonPurgeableRecordSet == nil)
    {
        NSMutableSet *set = [[NSMutableSet alloc] init];
        self.nonPurgeableRecordSet = set;
    }
    
    int adcCount = (int)[self.advancedOrDownloadedCriteriaRecords count];
    int purgeCount = (int)[self.purgeableRecordSet count];
    int nonPurgeCount = (int)[self.nonPurgeableRecordSet count];
    
    NSString *adcIdString = [[NSString alloc] initWithString:[self.advancedOrDownloadedCriteriaRecords description]];
    NSString *purgeIdString = [[NSString alloc] initWithString:[self.purgeableRecordSet description]];
    NSString *nonPurgeIdString = [[NSString alloc] initWithString:[self.nonPurgeableRecordSet description]];
    
    NSString *finalReport = nil;
    NSString *statString = nil;
    
    //To avoid unnecessary cleanup of databse - If purgable records is more than 1000 then do cleanupdatabase
    if (purgeCount >= PURGECOUNT)
    {
        [[SMDataPurgeManager sharedInstance] setIsCleanUpDataBaseRequired:YES];
    }
    
    if ([self isCompleted])
    {
        statString = @"success";
    }
    else if ([self hasError])
    {
        statString = @"failed";
    }
    else if ([self isPurgeable])
    {
        statString = @"NotPurgeable";
    }
    else
    {
        statString = @"--NA--";
    }
    
    NSString *reportLine = @"%@ : %@ { ADC_DC - %d, Purge_Count - %d, NonPurge_Count - %d } \n\n ADC_DC_IDs \t: [%@] \n Purge_IDs \t: [%@] \n NonPurge_IDs \t: [%@] ";
    
    finalReport = [[NSString alloc] initWithFormat:reportLine, statString, self.name, adcCount, purgeCount, nonPurgeCount, adcIdString, purgeIdString, nonPurgeIdString];
    
    SXLogDebug(@"Final Data Purge Report %@", finalReport);
    
    adcIdString = nil;
    purgeIdString = nil;
    nonPurgeIdString = nil;
    reportLine = nil;
    finalReport = nil;
    statString = nil;
}


@end
