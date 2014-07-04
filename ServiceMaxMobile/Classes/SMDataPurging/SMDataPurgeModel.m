//
//  SMDataPurgeModel.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 1/3/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import "SMDataPurgeModel.h"
#import "SMDataPurgeHelper.h"
#import "SMDataPurgeManager.h"

@implementation SMDataPurgeModel 

@synthesize name;
@synthesize status;
@synthesize purgeableStatus;
@synthesize isolatedName; //9969 Defect Fix

@synthesize advancedOrDownloadedCriteriaRecords;
@synthesize gracePeriodRecords;
@synthesize purgeableNonGracePeriodRecords;
@synthesize purgeableTrailerTableRecords;
@synthesize purgeableConflictRecords;
@synthesize purgeableDODRecords;
@synthesize nonPurgeableDODRecords;
@synthesize eventsRelatedRecords;
@synthesize childRecordsOfEvents;
@synthesize parentObjectNames; //9969 Defect Fix
@synthesize purgeableChilds;
@synthesize nonPurgeableChilds;
@synthesize purgeableRelatedObjects;
@synthesize purgeableReferenceObjects;
@synthesize nonPurgeableRecordIdsAsAChilds;
@synthesize nonPurgeableRecordIdsAsARelatedTable;

@synthesize nonPurgeableRecordSet;
@synthesize purgeableRecordSet;
@synthesize purgedRecordSet;

#define PURGECOUNT  1000


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
    else if ([self.name hasSuffix:@"Pricebook2"]) //9982 defect fix
    {
        self.status = DPActionStatusNonPurgeableSincePricebook;
    }
    else if ([self.name hasSuffix:@"SVMXC__Code_Snippet__c"])
    {
        self.status = DPActionStatusNonPurgeableSinceCodeSnippet;
    }
    else if ([self.name hasSuffix:@"SVMXC__Code_Snippet_Manifest__c"])
    {
        self.status = DPActionStatusNonPurgeableSinceCodeSnippetManifest;
    }
    else
    {
        self.status = DPActionStatusAwaited;
    }
}

//9969 Defect Fix
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
    NSArray * relatedObjects = [[SMDataPurgeHelper getRelatedRecordNameForTable:self.name] retain];
    
    if (relatedObjects != nil)
    {
        NSMutableArray *records = [[NSMutableArray alloc] initWithArray:relatedObjects];
        self.purgeableRelatedObjects = records;
        [records release];
    }
    [relatedObjects release];
}


- (id)initWithName:(NSString *)objectNameOrApiName
{
    self = [super init];
    
    if (self)
    {
        self.name = objectNameOrApiName;
        [self verifyStatus];
        [self verifyIsolation]; //9969 Defect Fix
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
        case DPActionStatusNonPurgeableSincePricebook:  //9982 Defect Fix
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


//9982 defect Fix
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


//9969 Defect Fix
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
        [records release];
    }
    
    [advancedOrDownloadedCriteriaRecords addObject:recordId];
}


- (void)addGracePeriodRecord:(NSString *)recordId
{
    if (self.gracePeriodRecords == nil)
    {
        NSMutableArray *records = [[NSMutableArray alloc] init];
        self.gracePeriodRecords = records;
        [records release];
    }
    
    [gracePeriodRecords addObject:recordId];
}


- (void)addPurgeableNonGracePeriodRecords:(NSString *)recordId
{
    if (self.purgeableNonGracePeriodRecords == nil)
    {
        NSMutableArray *records = [[NSMutableArray alloc] init];
        self.purgeableNonGracePeriodRecords = records;
        [records release];
    }
    
    [purgeableNonGracePeriodRecords addObject:recordId];
}


- (void)addPurgeableTrailerTableRecords:(NSString *)recordId
{
    if (self.purgeableTrailerTableRecords == nil)
    {
        NSMutableArray *records = [[NSMutableArray alloc] init];
        self.purgeableTrailerTableRecords = records;
        [records release];
    }
    
    [purgeableTrailerTableRecords addObject:recordId];
}


- (void)addPurgeableConflictRecords:(NSString *)recordId
{
    if (self.purgeableConflictRecords == nil)
    {
        NSMutableArray *records = [[NSMutableArray alloc] init];
        self.purgeableConflictRecords = records;
        [records release];
    }
    
    [purgeableConflictRecords addObject:recordId];
}


- (void)addPurgeableDODRecord:(NSString *)recordId
{
    if (self.purgeableDODRecords == nil)
    {
        NSMutableArray *records = [[NSMutableArray alloc] init];
        self.purgeableDODRecords = records;
        [records release];
    }
    
    [purgeableDODRecords addObject:recordId];
}


- (void)addNonPurgeableDODRecord:(NSString *)recordId
{
    if (self.nonPurgeableDODRecords == nil)
    {
        NSMutableArray *records = [[NSMutableArray alloc] init];
        self.nonPurgeableDODRecords = records;
        [records release];
    }
    
    [nonPurgeableDODRecords addObject:recordId];
}


- (void)addPurgeableRelatedObject:(NSString *)objectName
{
    if (self.purgeableRelatedObjects == nil)
    {
        NSMutableArray *records = [[NSMutableArray alloc] init];
        self.purgeableRelatedObjects = records;
        [records release];
    }
    
    [purgeableRelatedObjects addObject:objectName];
}


- (void)addPurgeableReferenceObject:(SMObjectRelationModel *)objectModel
{
    if (self.purgeableReferenceObjects == nil)
    {
        NSMutableArray *records = [[NSMutableArray alloc] init];
        self.purgeableReferenceObjects = records;
        [records release];
    }
    
    [purgeableReferenceObjects addObject:objectModel];
}


- (void)addNonPurgeableChild:(NSString *)recordId
{
    if (self.nonPurgeableChilds == nil)
    {
        NSMutableArray *records = [[NSMutableArray alloc] init];
        self.nonPurgeableChilds = records;
        [records release];
    }
    
    [nonPurgeableChilds addObject:recordId];
}


- (void)addPurgeableChild:(SMObjectRelationModel *)objectModel
{
    if (self.purgeableChilds == nil)
    {
        NSMutableArray *records = [[NSMutableArray alloc] init];
        self.purgeableChilds = records;
        [records release];
    }
    
    [purgeableChilds addObject:objectModel];
}


- (void)addChildRecordsOfEvents:(NSString *)recordId
{
    if (self.childRecordsOfEvents == nil)
    {
        NSMutableArray *records = [[NSMutableArray alloc] init];
        self.childRecordsOfEvents = records;
        [records release];
    }
    
    [childRecordsOfEvents addObject:recordId];
}


- (void)addEventsRelatedRecord:(NSString *)recordId
{
    if (self.eventsRelatedRecords == nil)
    {
        NSMutableArray *records = [[NSMutableArray alloc] init];
        self.eventsRelatedRecords = records;
        [records release];
    }
    
    [eventsRelatedRecords addObject:recordId];
}


- (void)addNonPurgeableRecordIdsAsAChilds:(NSString *)recordId
{
    if (self.nonPurgeableRecordIdsAsAChilds == nil)
    {
        NSMutableArray *records = [[NSMutableArray alloc] init];
        self.nonPurgeableRecordIdsAsAChilds = records;
        [records release];
    }
    
    [nonPurgeableRecordIdsAsAChilds addObject:recordId];
}


- (void)addNonPurgeableRecordIdsAsARelatedTable:(NSString *)recordId
{
    if (self.nonPurgeableRecordIdsAsARelatedTable == nil)
    {
        NSMutableArray *records = [[NSMutableArray alloc] init];
        self.nonPurgeableRecordIdsAsARelatedTable = records;
        [records release];
    }
    
    [nonPurgeableRecordIdsAsARelatedTable addObject:recordId];
}


//9969 Defect Fix
- (void)addParentObjectNames:(NSMutableDictionary *)objectDict
{
    if (self.parentObjectNames == nil)
    {
        NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:0];
        self.parentObjectNames = array;
        [array release];
    }
    if (objectDict != nil)
        [self.parentObjectNames addObject:objectDict];
}


- (void)dealloc
{
    [purgeableStatus release];
    [name release];
    [advancedOrDownloadedCriteriaRecords release];
    [gracePeriodRecords release];
    
    [purgeableDODRecords release];
    [nonPurgeableDODRecords release];
    [eventsRelatedRecords release];
    [childRecordsOfEvents release];
    [purgeableChilds release];
    
    [nonPurgeableChilds release];
    [purgeableRelatedObjects release];
    [purgeableReferenceObjects release];
    [nonPurgeableRecordSet release];
    [purgeableRecordSet release];
    [purgedRecordSet release];
    [parentObjectNames release];
    
    [nonPurgeableRecordIdsAsAChilds release];
    [nonPurgeableRecordIdsAsARelatedTable release];

    [super dealloc];
}


- (void)doFinalAggregationForNonPurgeableRecords
{
    if (self.nonPurgeableRecordSet == nil)
    {
        NSMutableSet *set = [[NSMutableSet alloc] init];
        self.nonPurgeableRecordSet = set;
        [set release];
    }
    
    if ((nonPurgeableRecordIdsAsAChilds != nil) && ([nonPurgeableRecordIdsAsAChilds count] > 0))
    {
        // Adding Records as child
        [nonPurgeableRecordSet addObjectsFromArray:nonPurgeableRecordIdsAsAChilds];
    }
    
    if ((nonPurgeableRecordIdsAsARelatedTable != nil) && ([nonPurgeableRecordIdsAsARelatedTable count] > 0))
    {
        // Adding Records as refernce
        [nonPurgeableRecordSet addObjectsFromArray:nonPurgeableRecordIdsAsARelatedTable];
    }
}


- (void)aggregateNonPurgeableRecords
{
    if (self.nonPurgeableRecordSet == nil)
    {
        NSMutableSet *set = [[NSMutableSet alloc] init];
        self.nonPurgeableRecordSet = set;
        [set release];
    }
    
    if ((advancedOrDownloadedCriteriaRecords != nil) && ([advancedOrDownloadedCriteriaRecords count] > 0))
    {
        // Adding Records which got by Downloaded Criteria, Adv. Downloaded Criteria and GetPrice Call
        [nonPurgeableRecordSet addObjectsFromArray:advancedOrDownloadedCriteriaRecords];
    }
    
    if ((gracePeriodRecords != nil) && ([gracePeriodRecords count] > 0))
    {
        // Adding Records which got by GracePeriod - Data Trailer Records
        [nonPurgeableRecordSet addObjectsFromArray:gracePeriodRecords];
    }
    
    if ((nonPurgeableDODRecords != nil) && ([nonPurgeableDODRecords count] > 0))
    {
        // Adding DOD Records which are falls under grace periods
        [nonPurgeableRecordSet addObjectsFromArray:nonPurgeableDODRecords];
    }
    
    if ((eventsRelatedRecords != nil) && ([eventsRelatedRecords count] > 0))
    {
        // Adding Records associated with Events
        [nonPurgeableRecordSet addObjectsFromArray:eventsRelatedRecords];
    }
    
    if ((childRecordsOfEvents != nil) && ([childRecordsOfEvents count] > 0))
    {
        // Adding Child Records associated with Events
        [nonPurgeableRecordSet addObjectsFromArray:childRecordsOfEvents];
    }
}

- (void)generatePurgeReport
{
    
    if (self.advancedOrDownloadedCriteriaRecords == nil)
    {
        // Just empty array
        NSMutableArray *records = [[NSMutableArray alloc] init];
        self.advancedOrDownloadedCriteriaRecords = records;
        [records release];
    }
    
    if (self.purgeableRecordSet == nil)
    {
        NSMutableSet *set = [[NSMutableSet alloc] init];
        self.purgeableRecordSet = set;
        [set release];
    }
    
    if (self.nonPurgeableRecordSet == nil)
    {
        NSMutableSet *set = [[NSMutableSet alloc] init];
        self.nonPurgeableRecordSet = set;
        [set release];
    }
    
    int adcCount = [advancedOrDownloadedCriteriaRecords count];
    int purgeCount = [purgeableRecordSet count];
    int nonPurgeCount = [nonPurgeableRecordSet count];
    
    NSString *adcIdString = [[NSString alloc] initWithString:[advancedOrDownloadedCriteriaRecords description]];
    NSString *purgeIdString = [[NSString alloc] initWithString:[purgeableRecordSet description]];
    NSString *nonPurgeIdString = [[NSString alloc] initWithString:[nonPurgeableRecordSet description]];
    
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
    
    NSString *reportLine = [[NSString alloc] initWithString:@"%@ : %@ { ADC_DC - %d, Purge_Count - %d, NonPurge_Count - %d } \n\n ADC_DC_IDs \t: [%@] \n Purge_IDs \t: [%@] \n NonPurge_IDs \t: [%@] "];
    
    finalReport = [[NSString alloc] initWithFormat:reportLine, statString, self.name, adcCount, purgeCount, nonPurgeCount, adcIdString, purgeIdString, nonPurgeIdString];
    
    SMLog(kLogLevelVerbose,@"Final Data Purge Report %@", finalReport);
    
    [adcIdString release];
    adcIdString = nil;
    [purgeIdString release];
    purgeIdString = nil;
    [nonPurgeIdString release];
    nonPurgeIdString = nil;
    [reportLine release];
    reportLine = nil;
    [finalReport release];
    finalReport = nil;
    statString = nil;
}


@end
