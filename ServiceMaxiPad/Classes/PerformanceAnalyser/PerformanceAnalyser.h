/**
 *  @file   PerformanceAnalyser.h
 *  @class  PerformanceAnalyser
 *
 *  @brief Performance analyser.
 *
 *  Responsible For measuring DB operations, Network latency, Parse latency in each request made.
 *
 *  TODO : db operations for selecting. Operations on inserting into tables on sync is captured.
 *  TODO : algorithm performance is not captured.
 *  TODO : Code optimization.
 *
 *  @author Krishna shanbhag
 *  @author Shravya S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/
#import <Foundation/Foundation.h>
#import "PerformanceAnalyserModel.h"


@interface PerformanceAnalyser : NSObject

+ (instancetype) sharedInstance;

+ (instancetype) alloc  __attribute__((unavailable("alloc not available, call sharedInstance instead")));
- (instancetype) init   __attribute__((unavailable("init not available, call sharedInstance instead")));
+ (instancetype) new    __attribute__((unavailable("new not available, call sharedInstance instead")));

// set the value to NO if you want to stop capturing the performance.
@property (nonatomic) BOOL startedPerformanceAnalyser;

/**
 * @name  <observePerformanceForContext>
 *
 * @author Krishna Shanbhag
 *
 * @brief <Start observing the performance>
 *
 *
 * @param  Context name : Category type eg : INITIAL SYNC
 * @param  subContextName : sub type eg : SFM_PAGE_DATA
 * @param  operationType : Specifies for which operation type performance needs to be captured eg : PAOperationTypeParsing
 * @param  recordCount : Number of records.
 * @return void
 *
 */
- (void)observePerformanceForContext:(NSString *)contextName
                      subContextName:(NSString *)subContextName
                       operationType:(PAOperationType)operationType
                      andRecordCount:(int)recordCount;

/**
 * @name  <ObservePerformanceCompletionForContext>
 *
 * @author Krishna Shanbhag
 *
 * @brief <start observing the performance and Log analytics>
 *
 * @param  Context name : Category type eg : INITIAL SYNC
 * @param  subContextName : sub type eg : SFM_PAGE_DATA
 * @param  operationType : Specifies for which operation type performance needs to be captured eg : PAOperationTypeParsing
 * @param  recordCount : Number of records.
 * @return void
 *
 */
- (void)ObservePerformanceCompletionForContext:(NSString *)contextName
                                subContextName:(NSString *)subContextName
                                 operationType:(PAOperationType)operationType
                                andRecordCount:(int)recordCount;

/**
 * @name  <clearAllData>
 *
 * @author Krishna Shanbhag
 *
 * @brief <Clear all data once the operation is completed>
 *
 */
- (void) clearAllData;

/**
 * @name  <generatePerformanceAnalysisReportForContextName>
 *
 * @author Krishna Shanbhag
 *
 * @brief <Generate the report>
 *
 */

- (void) generatePerformanceAnalysisReportForContextName:(NSString *)contextName;

/**
 * @name  <getSubContextNameForContext>
 *
 * @author Krishna Shanbhag
 *
 * @brief <for a given subcontext if the performance is already logged eg : SFM_PAGE_DATA the value will be overwritten to avoid this get unique subcontext every time eg : SFM_PAGE_DATA_0>
 *
 *
 * @return New sub context value.
 *
 */
- (NSString *) getSubContextNameForContext:(NSString *)contextName SubContext:(NSString *)subContext forOperationTYpe:(PAOperationType)operationType;


//Buckets
@property (nonatomic, strong) NSMutableDictionary *nonCompletedAnalytics;
@property (nonatomic, strong) NSMutableDictionary *completedAnalytics;
@end
