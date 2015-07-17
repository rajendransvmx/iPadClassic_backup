//
//  TXFetchHelper.h
//  ServiceMaxMobile
//
//  Created by shravya on 27/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBRequestInsert.h"

extern NSString *const kInsertQueryCache;
extern NSString *const UpdateQueryCache;

@interface TXFetchHelper : NSObject

- (BOOL)insertObjects:(NSArray *)objects
       withObjectName:(NSString *)objectName;
- (NSMutableDictionary *)getIdListFromSyncHeapTableWithLimit:(NSInteger)overAllIdLimit
                                         forParallelSyncType:(NSString*)parallelSyncType;
- (id)initWithCheckForDuplicateRecords:(BOOL)shouldCheck ;
- (NSArray *)getValueMapDictionary:(NSDictionary *)objectDictionary;
- (DBRequestInsert *)getInsertQuery:(NSString *)objectName;
@end
