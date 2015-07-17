//
//  EventsDAO.h
//  ServiceMaxMobile
//
//  Created by Krishna Shanbhag on 22/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonServiceDAO.h"

@protocol SyncHeapDAO <CommonServiceDAO>

-(void)deleteRecordsForSfIds:(NSArray *)recordsIds
         forParallelSyncType:(NSString*)parallelSyncType;
-(NSArray *)getAllIdsFromHeapTableForObjectName:(NSString *)objectName
                                       forLimit:(NSInteger)limit
                            forParallelSyncType:(NSString*)parallelSyncType;
-(NSArray *)getDistinctObjectNames;
-(void)deleteRecordsFromHeap:(NSDictionary *)deletedIdsdict
         forParallelSyncType:(NSString*)parallelSyncType;
-(NSArray*)getRecordsFromQuery:(NSString*)query;
-(BOOL)doesRecordExistForId:(NSString *)recordId;

@end
