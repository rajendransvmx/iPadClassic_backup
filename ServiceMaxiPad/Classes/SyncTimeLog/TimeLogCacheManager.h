/**
 *  @file   TimeLogCacheManager.h
 *  @class  TimeLogCacheManager
 *
 *  @brief Responsible for managing sync time logs
 *
 *   Sync time logs manager
 *   T1 - Request made timeStamp.
 *   T4 - Response recieved timeStamp.
 *   T5 - Response processed timeStamp.
 *
 *  @author Krishna shanbhag
 *  @author Chinnababu
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import <Foundation/Foundation.h>
#import "TimeLogModel.h"
#import "SyncConstants.h"

@interface TimeLogCacheManager : NSObject

+ (instancetype) sharedInstance;
+ (instancetype) alloc  __attribute__((unavailable("alloc not available, call sharedInstance instead")));
- (instancetype) init   __attribute__((unavailable("init not available, call sharedInstance instead")));
+ (instancetype) new    __attribute__((unavailable("new not available, call sharedInstance instead")));

/**
 * @name  <logEntryForSyncResponceTime>
 *
 * @author Krishna Shanbhag
 *
 * @brief <log timestamp into cache>
 *
 * @param  Time log modelObject
 * Time log model consists of t4, t5 and log id.
 *
 * @return void
 *
 */
- (void) logEntryForSyncResponceTime:(TimeLogModel *)modelObject
                     forCategoryType:(CategoryType)categoryType;

/**
 * @name  <deleteLogEntryForId>
 *
 * @author Krishna Shanbhag
 *
 * @brief <Delete single entry from cache>
 *
 * @param  LogID
 * Key for which the record needs to be deleted.
 *
 * @return void
 *
 */
- (void) deleteLogEntryForId:(NSString *)logId
             forCategoryType:(CategoryType)categoryType;

/**
 * @name  <getLogEntry>
 *
 * @author Krishna Shanbhag
 *
 * @brief <Get the last entered log entry>
 *
 * \par
 *  < Getting single cache record which is in top of an array mentained >
 *
 * @return void
 *
 */
- (NSDictionary *) getLogEntryforCategoryType:(CategoryType)categoryType;

/**
 * @name  <getAllLogEntry>
 *
 * @author Krishna Shanbhag
 *
 * @brief <Everything in the cache in>
 *
 * @return complete cache in request format
 *
 */
- (NSDictionary *) getAllLogEntryforCategoryType:(CategoryType)categoryType;

/**
 * @name  <isCacheEmpty>
 *
 * @author Krishna Shanbhag
 *
 * @brief <Check if the cache is empty>
 *
 * @return empty/non empty
 *
 */
- (BOOL) isCacheEmptyforCategoryType:(CategoryType)categoryType;

/**
 * @name  <getRequestParameterForLogging>
 *
 * @author Krishna Shanbhag
 *
 * @brief <Request parameter to make intermediate request, which is to appended with request>
 *
 * @return array of values empty
 *
 */

- (NSArray *)getRequestParameterForTimeLogWithCategory:(NSString *)category
                                       forCategoryType:(CategoryType)categoryType;

/**
 * @name  <getCompleteLogEntry>
 *
 * @author Krishna Shanbhag
 *
 * @brief <complete log entries in cache for special request>
 *
 * @return empty/non empty
 *
 */
- (NSArray *) getCompleteLogEntryforCategoryType:(CategoryType)categoryType andCurrentRequestId:(NSString *)currentID; // IPAD-4764

- (void) addEntryToFailureList:(NSString *)requestId forCategoryType:(CategoryType)categoryType;
- (void) clearAllFailureListforCategoryType:(CategoryType)categoryType;
- (void) clearAllLogEntryForCategoryType:(CategoryType)categoryType;

@end
