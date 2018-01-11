//
//  SMDatabase.h
//  ServiceMaxiPad
//
//  Created by Vipindas on 31/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sqlite3.h>

#if defined(SQLITE_HAS_CODEC)
SQLITE_API int sqlite3_key(sqlite3 *db, const void *pKey, int nKey);
SQLITE_API int sqlite3_rekey(sqlite3 *db, const void *pKey, int nKey);
#endif

typedef int(^DBExecuteStatementsCallbackBlock)(NSDictionary *resultsDictionary);

@class SQLResultSet;

@interface SMDatabase : NSObject

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




+ (instancetype)databaseWithPath:(NSString*)aPath;

- (instancetype)initWithPath:(NSString*)aPath;

- (BOOL)openWithFlags:(int)flags;
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

+ (NSString *)dataBaseKey;


#pragma mark - Database Status

- (NSString *)databasePath;

- (NSString*)lastErrorMessage;

- (sqlite_int64)lastInsertRowId;

- (sqlite3*)sqliteHandle;

#pragma mark - Database Error Handling

- (int)lastErrorCode;

- (BOOL)hadError;

- (NSError*)lastError;

//- (BOOL)recreateDatabase;
//
//- (BOOL)resetDatabasePath;

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
