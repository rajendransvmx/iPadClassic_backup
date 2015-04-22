//
//  DatabaseManager.h
//  ServiceMaxMobile
//
//
/**
 *  @file   DatabaseManager.h
 *  @class  DatabaseManager
 *
 *  @brief  This class will provide interface to talk to database file and database file encryption mechanism
 *
 *  @author  Vipindas Palli
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/


#import <Foundation/Foundation.h>
#import "DatabaseQueue.h"
#import "SMDatabase.h"
#import "SQLResultSet.h"
@interface DatabaseManager : NSObject

+ (instancetype) sharedInstance;
+ (instancetype) alloc  __attribute__((unavailable("alloc not available, call sharedInstance instead")));
- (instancetype) init   __attribute__((unavailable("init not available, call sharedInstance instead")));
+ (instancetype) new    __attribute__((unavailable("new not available, call sharedInstance instead")));


- (BOOL)createEditableDatabaseIfNeeded;

- (DatabaseQueue *)databaseQueue;
- (NSString *)primaryDatabasePath;
- (NSString *)secondaryDatabasePath;
- (NSString *)databaseAttachmentName;

- (void)resetDatabasePath;

@end
