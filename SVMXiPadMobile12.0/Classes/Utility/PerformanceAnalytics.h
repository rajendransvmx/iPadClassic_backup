//
//  PerformanceAnalytics.h
//  iService
//
//  Created by Vipindas on 2/27/13.
//
//

#import <Foundation/Foundation.h>

@interface PerformanceAnalytics : NSObject
{
    NSMutableDictionary *nameToStartTimeDictionary;
    NSMutableDictionary *nameToEndTimeDictionary;
    NSMutableDictionary *nameToRecordCount;
    NSMutableArray      *names;
    NSMutableDictionary *nameToTimeCountDictionary;
    NSString            *codeName;
    NSString            *description;
    NSString            *dbVersion;
    
    long long int  createdRecords;
    long long int  deletedRecords;
}

@property (nonatomic, retain)  NSMutableDictionary *nameToStartTimeDictionary;
@property (nonatomic, retain)  NSMutableDictionary *nameToEndTimeDictionary;
@property (nonatomic, retain)  NSMutableDictionary *nameToRecordCount;
@property (nonatomic, retain)  NSMutableDictionary *nameToTimeCountDictionary;
@property (nonatomic, retain)  NSMutableDictionary *dbOperationCounterDictionary;
@property (nonatomic, retain)  NSMutableDictionary *dbMemoryRecords;
@property (nonatomic, retain)  NSMutableArray      *names;
@property (nonatomic, retain)  NSString            *codeName;
@property (nonatomic, retain)  NSString            *description;
@property (nonatomic, retain)  NSString            *dbVersion;


@property (nonatomic, assign)  long long int  createdRecords;
@property (nonatomic, assign)  long long int  deletedRecords;

+ (id)sharedInstance;
- (void)observePerformanceForContext:(NSString *)contextName
                     andRecordCount:(long long int)count;

- (void)completedPerformanceObservationForContext:(NSString *)context
                                   andRecordCount:(long long int)count;


- (void)displayCurrentStatics;
- (void)stopPerformAnalysis;
- (void)removeContext:(NSString *)contextName;
- (void)setCode:(NSString *)codeName andDescription:(NSString *)descriptionName;

- (void)addCreatedRecordsNumber:(long long int)records;
- (void)addDeletedRecordsNumber:(long long int)records;

- (void)registerOperationCount:(int)count forDatabase:(NSString *)connectionName;
- (void)clearOperationCounter;
- (void)recordDBMemoryUsage:(NSNumber *)memoryUsed perContext:(NSString *) context;

@end
