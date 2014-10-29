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

/*
 Objective-C wrapper for `sqlite3_stmt`
 
 References
 - [FMDB on GitHub](https://github.com/ccgus/fmdb)
 - [SQLite web site](http://sqlite.org/)
 - [SQLite FAQ](http://www.sqlite.org/faq.html)
 */

#import <Foundation/Foundation.h>
#include <sqlite3.h>

#if ! __has_feature(objc_arc)
#define DBAutorelease(__v) ([__v autorelease]);
#define DBReturnAutoreleased DBAutorelease

#define DBRetain(__v) ([__v retain]);
#define DBReturnRetained DBRetain

#define DBRelease(__v) ([__v release]);

#define DBDispatchQueueRelease(__v) (dispatch_release(__v));
#else
// -fobjc-arc
#define DBAutorelease(__v)
#define DBReturnAutoreleased(__v) (__v)

#define DBRetain(__v)
#define DBReturnRetained(__v) (__v)

#define DBRelease(__v)

// If OS_OBJECT_USE_OBJC=1, then the dispatch objects will be treated like ObjC objects
// and will participate in ARC.
// See the section on "Dispatch Queues and Automatic Reference Counting" in "Grand Central Dispatch (GCD) Reference" for details.

#if OS_OBJECT_USE_OBJC
#define DBDispatchQueueRelease(__v)
#else
#define DBDispatchQueueRelease(__v) (dispatch_release(__v));
#endif
#endif

#if !__has_feature(objc_instancetype)
#define instancetype id
#endif


typedef int(^DBExecuteStatementsCallbackBlock)(NSDictionary *resultsDictionary);

@class SQLResultSet;

@interface DatabaseManager : NSObject

+ (DatabaseManager *)sharedInstance;

#pragma mark - Database Open close

- (BOOL)open;

- (BOOL)close;

#pragma mark - SQL Query Management

- (BOOL)executeUpdate:(NSString*)sql, ...;
- (BOOL)executeUpdate:(NSString*)sql withArgumentsInArray:(NSArray *)arguments;
- (BOOL)executeUpdate:(NSString*)sql withParameterDictionary:(NSDictionary *)arguments;

- (BOOL)executeUpdateWithEmptyStringInsertedForEmptyColumns:(NSString*)sql withParameterDictionary:(NSDictionary *)arguments;

- (BOOL)executeStatements:(NSString *)sql;

- (SQLResultSet *)executeQuery:(NSString*)sql, ...;
- (SQLResultSet *)executeQuery:(NSString *)sql withArgumentsInArray:(NSArray *)arguments;
- (SQLResultSet *)executeQuery:(NSString *)sql withParameterDictionary:(NSDictionary *)arguments;




#pragma mark - Database Transaction Management

- (BOOL)beginTransaction;

- (BOOL)beginDeferredTransaction;

- (BOOL)commit;

- (BOOL)inTransaction;

- (BOOL)rollback;

#pragma mark - SQL statement management

- (void)clearCachedStatements;

- (BOOL)shouldCacheStatements;

- (void)setShouldCacheStatements:(BOOL)value;

#pragma mark - ResultSet management

- (void)closeOpenResultSets;

- (BOOL)hasOpenResultSets;

- (void)resultSetDidClose:(SQLResultSet *)resultSet;

#pragma mark - Database Encryption

- (BOOL)setKey:(NSString*)key;

- (BOOL)rekey:(NSString*)key;

- (BOOL)setKeyWithData:(NSData *)keyData;

- (BOOL)rekeyWithData:(NSData *)keyData;


#pragma mark - Database Status

- (NSString *)databasePath;

- (NSString*)lastErrorMessage;

- (sqlite_int64)lastInsertRowId;

- (sqlite3*)sqliteHandle;

#pragma mark - Database Error Handling

- (int)lastErrorCode;

- (BOOL)hadError;

- (NSError*)lastError;



@end

/** 
 Objective-C wrapper for `sqlite3_stmt`
 */

@interface SQLStatement : NSObject
{
    sqlite3_stmt *_statement;
    NSString *_query;
    long _useCount;
    BOOL _inUse;
}

///-----------------
/// @name Properties
///-----------------

/** Usage count */

@property (atomic, assign) long useCount;

/** SQL statement */

@property (atomic, strong) NSString *query;

/** SQLite sqlite3_stmt
 
 @see [`sqlite3_stmt`](http://www.sqlite.org/c3ref/stmt.html)
 */

@property (atomic, assign) sqlite3_stmt *statement;

/** Indication of whether the statement is in use */

@property (atomic, assign) BOOL inUse;

///----------------------------
/// @name Closing and Resetting
///----------------------------

/** Close statement */

- (void)close;

/** Reset statement */

- (void)reset;

@end
