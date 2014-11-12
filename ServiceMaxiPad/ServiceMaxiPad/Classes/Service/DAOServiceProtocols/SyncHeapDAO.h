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

-(void)deleteRecordsForSfIds:(NSArray *)recordsIds;

- (NSArray *)getAllIdsFromHeapTableForObjectName:(NSString *) objectName  forLimit:(NSInteger)limi;

-(NSArray *)getDistinctObjectNames;

-(void)deleteRecordsFromHeap:(NSDictionary *)deletedIdsdict;
- (NSArray*)getRecordsFromQuery:(NSString*)query;
- (BOOL)doesRecordExistForId:(NSString *)recordId;

@end
