//
//  OneCallDataSyncHelper.h
//  ServiceMaxMobile
//
//  Created by shravya on 11/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OneCallDataSyncHelper : NSObject

- (void)updateSfId:(NSString *)sfId
       withLocalId:(NSString *)localId
     andObjectName:(NSString *)objectName;

- (BOOL)insertIdsIntoSyncHeapTable:(NSDictionary *)objectMapIds;
-(void)deleteSyncRecordsFromSyncModificationTableWithIndex:(NSDictionary *)deletedIdsDict
                             withModificationType:(NSString *)modificationType;

- (BOOL)deleteRecordIds:(NSArray *)recordIds fromObject:(NSString *)objectName;
- (void)deleteFromAllTable:(NSDictionary *)objectNameAndIds;
- (BOOL)insertDCRecordIdsintoSyncHeapTable:(NSDictionary *)objectNameAndIds andResponseType:(NSString *)responseType;
- (void)purgeEventsFromServer:(NSDictionary *)eventsIdToBePurged;
- (NSArray *)getIdsFromSyncHeapTableForObjectName:(NSString *)objectName andEventType:(NSString *)eventType;
- (BOOL)deleteAllExceptRecordIds:(NSArray *)recordIds fromObject:(NSString *)objectName ;
- (void)deleteAllEventExceptTheseIdsFromSyncHeapAndModifiedRecordsTable:(NSDictionary *)objectDictionary;
- (void)deleteIdsFromSyncHeapForResponseType:(NSString *)responseType;
- (BOOL)deleteAllEventsOfTheLoggedInUserFromObject:(NSString*)objectName;
- (void)deleteRecordWithIds:(NSArray *)recordIds
             fromObjectName:(NSString *)objectName
       andCriteriaFieldName:(NSString *)fieldName;

- (void)deleteConflictRecordsFromSuccessiveSyncEntry:(NSDictionary *)deletedIdsDict
                                withModificationType:(NSString *)modificationType;

- (BOOL)checkIfWhatIdIsAssociatedWithAnyOtherEvent:(NSString *)whatId;
- (NSArray *)getChildLineIdsForWO:(NSString *)woSfId;

@end
