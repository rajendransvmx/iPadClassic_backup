//
//  SMDatabase.m
//  ServiceMaxiPad
//
//  Created by Vipindas on 31/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "SMDatabase.h"
#import "SQLResultSet.h"


@interface SMDatabase()
{
    
}

@property(nonatomic)  BOOL    isExecutingStatement;
@property(nonatomic)  BOOL    inTransaction;
@property(nonatomic)  BOOL    logsErrors;
@property(nonatomic)  BOOL    crashOnErrors;
@property(nonatomic)  BOOL    traceExecution;
@property(nonatomic)  BOOL    checkedOut;
@property(nonatomic)  BOOL    shouldCacheStatements;

@property(nonatomic)  sqlite3   *db;
@property(nonatomic)  NSTimeInterval      maxBusyRetryTimeInterval;
@property(nonatomic)  NSTimeInterval      startBusyRetryTime;

@property(nonatomic, strong)  NSString            *databasePath;
@property(nonatomic, strong)  NSMutableDictionary *cachedStatements;
@property(nonatomic, strong)  NSMutableSet        *openResultSets;
@property(nonatomic, strong)  NSMutableSet        *openFunctions;

@end

@implementation SMDatabase


@synthesize databasePath;
@synthesize cachedStatements;
@synthesize openResultSets;
@synthesize openFunctions;

@synthesize startBusyRetryTime;
@synthesize maxBusyRetryTimeInterval;

@synthesize isExecutingStatement;
@synthesize inTransaction;
@synthesize logsErrors;
@synthesize crashOnErrors;
@synthesize traceExecution;
@synthesize checkedOut;
@synthesize shouldCacheStatements;


+ (instancetype)databaseWithPath:(NSString*)aPath {
    return [[self alloc] initWithPath:aPath];
}

- (instancetype)init {
    return [self initWithPath:nil];
}

- (instancetype)initWithPath:(NSString*)aPath {
    
    self = [super init];
    
    if (self) {
        self.databasePath     = [aPath copy];
        self.openResultSets   = [[NSMutableSet alloc] init];
        _db                   = nil;
        self.logsErrors       = YES;
        self.crashOnErrors    = NO;
    }
    
    return self;
}


- (void)finalize
{
    [self close];
    [super finalize];
}

- (void)dealloc
{
    [self close];
    openResultSets = nil;
    cachedStatements = nil;
    openFunctions = nil;
}

- (NSString *)databasePath
{
    return databasePath;
}

#pragma mark SQLite information

+ (NSString*)sqliteLibVersion
{
    return [NSString stringWithFormat:@"%s", sqlite3_libversion()];
}

+ (BOOL)isSQLiteThreadSafe
{
    // make sure to read the sqlite headers on this guy!
    return sqlite3_threadsafe() != 0;
}

- (sqlite3*)sqliteHandle
{
    return _db;
}

- (const char*)sqlitePath
{
    if (!databasePath)
    {
        return ":memory:";
    }
    
    if ([databasePath length] == 0)
    {
        return ""; // this creates a temporary database (it's an sqlite thing).
    }
    
    return [databasePath fileSystemRepresentation];
}


#pragma mark Open and close database


- (BOOL)open
{
    if (_db)
    {
        return YES;
    }
    
    int err = sqlite3_open([self sqlitePath], &_db );
    
    if(err != SQLITE_OK)
    {
        SXLogError(@"error opening!: %d", err);
        return NO;
    }
    
    if (maxBusyRetryTimeInterval > 0.0)
    {
        // set the handler
        [self setMaxBusyRetryTimeInterval:maxBusyRetryTimeInterval];
    }
    
    return YES;
}


#if SQLITE_VERSION_NUMBER >= 3005000
- (BOOL)openWithFlags:(int)flags
{
    if (_db)
    {
        return YES;
    }
    
    int err = sqlite3_open_v2([self sqlitePath], &_db, flags, NULL /* Name of VFS module to use */);
    
    if(err != SQLITE_OK)
    {
        SXLogError(@"error opening!: %d", err);
        return NO;
    }
    
    
    if (maxBusyRetryTimeInterval > 0.0)
    {
        // set the handler
        [self setMaxBusyRetryTimeInterval:maxBusyRetryTimeInterval];
    }
    
    return YES;
}
#endif


- (BOOL)close
{
    [self clearCachedStatements];
    [self closeOpenResultSets];
    
    if (!_db)
    {
        return YES;
    }
    
    int  rc;
    BOOL retry;
    BOOL triedFinalizingOpenStatements = NO;
    
    do {
        retry   = NO;
        rc      = sqlite3_close(_db);
        
        if (SQLITE_BUSY == rc || SQLITE_LOCKED == rc)
        {
            if (!triedFinalizingOpenStatements)
            {
                triedFinalizingOpenStatements = YES;
                sqlite3_stmt *pStmt;
                while ((pStmt = sqlite3_next_stmt(_db, nil)) !=0)
                {
                    SXLogWarning(@"Closing leaked statement");
                    sqlite3_finalize(pStmt);
                    retry = YES;
                }
            }
        }
        else if (SQLITE_OK != rc)
        {
            SXLogError(@"error while closing db!: %d", rc);
        }
    }
    while (retry);
    
    _db = nil;
    return YES;
}

#pragma mark Busy handler routines

// NOTE: appledoc seems to choke on this function for some reason;
//       so when generating documentation, you might want to ignore the
//       .m files so that it only documents the public interfaces outlined
//       in the .h files.
//
//       This is a known appledoc bug that it has problems with C functions
//       within a class implementation, but for some reason, only this
//       C function causes problems; the rest don't. Anyway, ignoring the .m
//       files with appledoc will prevent this problem from occurring.

static int DBDatabaseBusyHandler(void *f, int count)
{
    SMDatabase *self = (__bridge SMDatabase*)f;
    
    if (count == 0)
    {
        self->startBusyRetryTime = [NSDate timeIntervalSinceReferenceDate];
        return 1;
    }
    
    NSTimeInterval delta = [NSDate timeIntervalSinceReferenceDate] - (self->startBusyRetryTime);
    
    if (delta < [self maxBusyRetryTimeInterval])
    {
        sqlite3_sleep(50); // milliseconds
        return 1;
    }
    return 0;
}

- (void)setMaxBusyRetryTimeInterval:(NSTimeInterval)timeout
{
    maxBusyRetryTimeInterval = timeout;
    
    if (!_db)
    {
        return;
    }
    
    if (timeout > 0)
    {
        sqlite3_busy_handler(_db, &DBDatabaseBusyHandler, (__bridge void *)(self));
    }
    else
    {
        // turn it off otherwise
        sqlite3_busy_handler(_db, nil, nil);
    }
}

- (NSTimeInterval)maxBusyRetryTimeInterval
{
    return maxBusyRetryTimeInterval;
}


// we no longer make busyRetryTimeout public
// but for folks who don't bother noticing that the interface to changed,
// we'll still implement the method so they don't get suprise crashes
- (int)busyRetryTimeout
{
    NSLog(@"%s:%d", __FUNCTION__, __LINE__);
    NSLog(@"DB: busyRetryTimeout no longer works, please use maxBusyRetryTimeInterval");
    return -1;
}

- (void)setBusyRetryTimeout:(int)i
{
    SXLogInfo(@"%s:%d", __FUNCTION__, __LINE__);
    SXLogWarning(@"DB: setBusyRetryTimeout does nothing, please use setMaxBusyRetryTimeInterval:");
}

#pragma mark Result set functions

- (BOOL)hasOpenResultSets
{
    return [openResultSets count] > 0;
}

- (void)closeOpenResultSets
{
    //Copy the set so we don't get mutation errors
    NSSet *openSetCopy = (NSSet *)[openResultSets copy];
    for (NSValue *rsInWrappedInATastyValueMeal in openSetCopy)
    {
        SQLResultSet *rs = (SQLResultSet *)[rsInWrappedInATastyValueMeal pointerValue];
        [rs setParentDB:nil];
        [rs close];
        [openResultSets removeObject:rsInWrappedInATastyValueMeal];
    }
}

- (void)resultSetDidClose:(SQLResultSet *)resultSet
{
    NSValue *setValue = [NSValue valueWithNonretainedObject:resultSet];
    
    [openResultSets removeObject:setValue];
}

#pragma mark Cached statements

- (void)clearCachedStatements
{
    for (NSMutableSet *statements in [cachedStatements objectEnumerator])
    {
        [statements makeObjectsPerformSelector:@selector(close)];
    }
    
    [cachedStatements removeAllObjects];
}

- (SQLStatement*)cachedStatementForQuery:(NSString*)query
{
    NSMutableSet* statements = [cachedStatements objectForKey:query];
    
    return [[statements objectsPassingTest:^BOOL(SQLStatement* statement, BOOL *stop)
             {
                 *stop = ![statement inUse];
                 return *stop;
                 
             }] anyObject];
}


- (void)setCachedStatement:(SQLStatement*)statement forQuery:(NSString*)query
{
    query = [query copy]; // in case we got handed in a mutable string...
    [statement setQuery:query];
    
    NSMutableSet* statements = [cachedStatements objectForKey:query];
    
    if (!statements)
    {
        statements = [NSMutableSet set];
    }
    
    [statements addObject:statement];
    
    [cachedStatements setObject:statements forKey:query];
    
    query = nil;
}

#pragma mark Key routines

- (BOOL)rekey:(NSString*)key
{
    NSData *keyData = [NSData dataWithBytes:(void *)[key UTF8String] length:(NSUInteger)strlen([key UTF8String])];
    
    return [self rekeyWithData:keyData];
}

- (BOOL)rekeyWithData:(NSData *)keyData
{
#ifdef SQLITE_HAS_CODEC
    if (!keyData)
    {
        return NO;
    }
    
    int rc = sqlite3_rekey(_db, [keyData bytes], (int)[keyData length]);
    
    if (rc != SQLITE_OK)
    {
        SXLogError(@"error on rekey: %d", rc);
        SXLogError(@"%@", [self lastErrorMessage]);
    }
    
    return (rc == SQLITE_OK);
#else
    return NO;
#endif
}

- (BOOL)setKey:(NSString*)key
{
    NSData *keyData = [NSData dataWithBytes:[key UTF8String] length:(NSUInteger)strlen([key UTF8String])];
    
    return [self setKeyWithData:keyData];
}

- (BOOL)setKeyWithData:(NSData *)keyData
{
#ifdef SQLITE_HAS_CODEC
    if (!keyData)
    {
        return NO;
    }
    
    int rc = sqlite3_key(_db, [keyData bytes], (int)[keyData length]);
    
    return (rc == SQLITE_OK);
#else
    return NO;
#endif
}


#pragma mark State of database

- (BOOL)goodConnection
{
    if (!_db)
    {
        return NO;
    }
    
    SQLResultSet *rs = [self executeQuery:@"select name from sqlite_master where type='table'"];
    
    if (rs)
    {
        [rs close];
        return YES;
    }
    return NO;
}

- (void)warnInUse
{
    SXLogWarning(@"The Database %@ is currently in use.", self);
    
#ifndef NS_BLOCK_ASSERTIONS
    //if (crashOnErrors)
    {
        NSAssert(false, @"The Database %@ is currently in use.", self);
        abort();
    }
#endif
}

- (BOOL)databaseExists
{
    if (!_db)
    {
        SXLogWarning(@"The Database %@ is not open.", self);
        
#ifndef NS_BLOCK_ASSERTIONS
        if (crashOnErrors)
        {
            NSAssert(false, @"The Database %@ is not open.", self);
            abort();
        }
#endif
        
        return NO;
    }
    
    return YES;
}

#pragma mark Error routines

- (NSString*)lastErrorMessage
{
    return [NSString stringWithUTF8String:sqlite3_errmsg(_db)];
}

- (BOOL)hadError
{
    int lastErrCode = [self lastErrorCode];
    
    return (lastErrCode > SQLITE_OK && lastErrCode < SQLITE_ROW);
}

- (int)lastErrorCode
{
    return sqlite3_errcode(_db);
}

- (NSError*)errorWithMessage:(NSString*)message
{
    NSDictionary* errorMessage = [NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey];
    
    return [NSError errorWithDomain:@"Database" code:sqlite3_errcode(_db) userInfo:errorMessage];
}

- (NSError*)lastError
{
    return [self errorWithMessage:[self lastErrorMessage]];
}

#pragma mark Update information routines

- (sqlite_int64)lastInsertRowId
{
    if (isExecutingStatement)
    {
        [self warnInUse];
        return NO;
    }
    
    isExecutingStatement = YES;
    
    sqlite_int64 ret = sqlite3_last_insert_rowid(_db);
    
    isExecutingStatement = NO;
    
    return ret;
}


- (int)changes
{
    if (isExecutingStatement)
    {
        [self warnInUse];
        return 0;
    }
    
    isExecutingStatement = YES;
    
    int ret = sqlite3_changes(_db);
    
    isExecutingStatement = NO;
    
    return ret;
}

#pragma mark SQL manipulation

- (void)bindObject:(id)obj toColumn:(int)idx inStatement:(sqlite3_stmt*)pStmt
{
    
    if ((!obj) || ((NSNull *)obj == [NSNull null]))
    {
        sqlite3_bind_null(pStmt, idx);
    }
    
    // FIXME - someday check the return codes on these binds.
    else if ([obj isKindOfClass:[NSData class]])
    {
        const void *bytes = [obj bytes];
        
        if (!bytes)
        {
            // it's an empty NSData object, aka [NSData data].
            // Don't pass a NULL pointer, or sqlite will bind a SQL null instead of a blob.
            bytes = "";
        }
        sqlite3_bind_blob(pStmt, idx, bytes, (int)[obj length], SQLITE_STATIC);
    }
    else if ([obj isKindOfClass:[NSDate class]])
    {
        sqlite3_bind_double(pStmt, idx, [obj timeIntervalSince1970]);
        
        /* if (self.hasDateFormatter)
         {
         //sqlite3_bind_text(pStmt, idx, [[self stringFromDate:obj] UTF8String], -1, SQLITE_STATIC);
         }
         else
         {
         
         }
         */
    }
    else if ([obj isKindOfClass:[NSNumber class]])
    {
        
        if (strcmp([obj objCType], @encode(BOOL)) == 0)
        {
            sqlite3_bind_text(pStmt, idx,([obj boolValue] ? [@"true" UTF8String] :[@"false" UTF8String]), -1, SQLITE_STATIC);
        }
        else if (strcmp([obj objCType], @encode(char)) == 0)
        {
            sqlite3_bind_int(pStmt, idx, [obj charValue]);
        }
        else if (strcmp([obj objCType], @encode(unsigned char)) == 0)
        {
            sqlite3_bind_int(pStmt, idx, [obj unsignedCharValue]);
        }
        else if (strcmp([obj objCType], @encode(short)) == 0)
        {
            sqlite3_bind_int(pStmt, idx, [obj shortValue]);
        }
        else if (strcmp([obj objCType], @encode(unsigned short)) == 0)
        {
            sqlite3_bind_int(pStmt, idx, [obj unsignedShortValue]);
        }
        else if (strcmp([obj objCType], @encode(int)) == 0)
        {
            sqlite3_bind_int(pStmt, idx, [obj intValue]);
        }
        else if (strcmp([obj objCType], @encode(unsigned int)) == 0)
        {
            sqlite3_bind_int64(pStmt, idx, (long long)[obj unsignedIntValue]);
        }
        else if (strcmp([obj objCType], @encode(long)) == 0)
        {
            sqlite3_bind_int64(pStmt, idx, [obj longValue]);
        }
        else if (strcmp([obj objCType], @encode(unsigned long)) == 0)
        {
            sqlite3_bind_int64(pStmt, idx, (long long)[obj unsignedLongValue]);
        }
        else if (strcmp([obj objCType], @encode(long long)) == 0)
        {
            sqlite3_bind_int64(pStmt, idx, [obj longLongValue]);
        }
        else if (strcmp([obj objCType], @encode(unsigned long long)) == 0)
        {
            sqlite3_bind_int64(pStmt, idx, (long long)[obj unsignedLongLongValue]);
        }
        else if (strcmp([obj objCType], @encode(float)) == 0)
        {
            sqlite3_bind_double(pStmt, idx, [obj floatValue]);
        }
        else if (strcmp([obj objCType], @encode(double)) == 0)
        {
            sqlite3_bind_double(pStmt, idx, [obj doubleValue]);
        }
        else
        {
            sqlite3_bind_text(pStmt, idx, [[obj description] UTF8String], -1, SQLITE_STATIC);
        }
    }
    else
    {
        sqlite3_bind_text(pStmt, idx, [[obj description] UTF8String], -1, SQLITE_STATIC);
    }
}

- (void)extractSQL:(NSString *)sql argumentsList:(va_list)args
        intoString:(NSMutableString *)cleanedSQL
         arguments:(NSMutableArray *)arguments
{
    
    NSUInteger length = [sql length];
    
    unichar last = '\0';
    
    for (NSUInteger i = 0; i < length; ++i)
    {
        id arg = nil;
        unichar current = [sql characterAtIndex:i];
        unichar add = current;
        
        if (last == '%')
        {
            switch (current)
            {
                case '@':
                {
                    arg = va_arg(args, id);
                }
                    break;
                    
                case 'c':
                {
                    // warning: second argument to 'va_arg' is of promotable type 'char'; this va_arg has undefined behavior because arguments will be promoted to 'int'
                    arg = [NSString stringWithFormat:@"%c", va_arg(args, int)];
                    break;
                }
                    
                case 's':
                {
                    arg = [NSString stringWithUTF8String:va_arg(args, char*)];
                    break;
                }
                    
                case 'd':
                case 'D':
                case 'i':
                {
                    arg = [NSNumber numberWithInt:va_arg(args, int)];
                    break;
                }
                    
                case 'u':
                case 'U':
                {
                    arg = [NSNumber numberWithUnsignedInt:va_arg(args, unsigned int)];
                    break;
                }
                    
                case 'h':
                {
                    i++;
                    if (i < length && [sql characterAtIndex:i] == 'i')
                    {
                        //  warning: second argument to 'va_arg' is of promotable type 'short'; this va_arg has undefined behavior because arguments will be promoted to 'int'
                        arg = [NSNumber numberWithShort:(short)(va_arg(args, int))];
                    }
                    else if (i < length && [sql characterAtIndex:i] == 'u')
                    {
                        // warning: second argument to 'va_arg' is of promotable type 'unsigned short'; this va_arg has undefined behavior because arguments will be promoted to 'int'
                        arg = [NSNumber numberWithUnsignedShort:(unsigned short)(va_arg(args, uint))];
                    }
                    else
                    {
                        i--;
                    }
                    break;
                }
                    
                case 'q':
                {
                    i++;
                    if (i < length && [sql characterAtIndex:i] == 'i')
                    {
                        arg = [NSNumber numberWithLongLong:va_arg(args, long long)];
                    }
                    else if (i < length && [sql characterAtIndex:i] == 'u')
                    {
                        arg = [NSNumber numberWithUnsignedLongLong:va_arg(args, unsigned long long)];
                    }
                    else
                    {
                        i--;
                    }
                    break;
                }
                    
                case 'f':
                {
                    arg = [NSNumber numberWithDouble:va_arg(args, double)];
                    break;
                }
                    
                case 'g':
                {
                    // warning: second argument to 'va_arg' is of promotable type 'float'; this va_arg has undefined behavior because arguments will be promoted to 'double'
                    arg = [NSNumber numberWithFloat:(float)(va_arg(args, double))];
                    break;
                }
                    
                case 'l':
                {
                    i++;
                    if (i < length)
                    {
                        unichar next = [sql characterAtIndex:i];
                        
                        if (next == 'l')
                        {
                            i++;
                            
                            if (i < length && [sql characterAtIndex:i] == 'd')
                            {
                                //%lld
                                arg = [NSNumber numberWithLongLong:va_arg(args, long long)];
                            }
                            else if (i < length && [sql characterAtIndex:i] == 'u')
                            {
                                //%llu
                                arg = [NSNumber numberWithUnsignedLongLong:va_arg(args, unsigned long long)];
                            }
                            else
                            {
                                i--;
                            }
                        }
                        else if (next == 'd')
                        {
                            //%ld
                            arg = [NSNumber numberWithLong:va_arg(args, long)];
                        }
                        else if (next == 'u')
                        {
                            //%lu
                            arg = [NSNumber numberWithUnsignedLong:va_arg(args, unsigned long)];
                        }
                        else
                        {
                            i--;
                        }
                    }
                    else
                    {
                        i--;
                    }
                    break;
                }
                    
                    
                default:
                    // something else that we can't interpret. just pass it on through like normal
                    break;
            }
        }
        else if (current == '%')
        {
            // percent sign; skip this character
            add = '\0';
        }
        
        if (arg != nil)
        {
            [cleanedSQL appendString:@"?"];
            [arguments addObject:arg];
        }
        else if (add == (unichar)'@' && last == (unichar) '%')
        {
            [cleanedSQL appendFormat:@"NULL"];
        }
        else if (add != '\0')
        {
            [cleanedSQL appendFormat:@"%C", add];
        }
        last = current;
    }
}

#pragma mark Execute queries

- (SQLResultSet *)executeQuery:(NSString *)sql withParameterDictionary:(NSDictionary *)arguments
{
    return [self executeQuery:sql withArgumentsInArray:nil orDictionary:arguments orVAList:nil];
}

- (SQLResultSet *)executeQuery:(NSString *)sql withArgumentsInArray:(NSArray*)arrayArgs
                  orDictionary:(NSDictionary *)dictionaryArgs orVAList:(va_list)args
{
    if (![self databaseExists])
    {
        return 0x00;
    }
    
    if (isExecutingStatement)
    {
        [self warnInUse];
        return 0x00;
    }
    
    isExecutingStatement = YES;
    
    int rc                  = 0x00;
    sqlite3_stmt *pStmt     = 0x00;
    SQLStatement *statement  = 0x00;
    SQLResultSet *rs         = 0x00;
    
    if (traceExecution && sql)
    {
        SXLogInfo(@"%@ executeQuery: %@", self, sql);
    }
    
    if (shouldCacheStatements)
    {
        statement = [self cachedStatementForQuery:sql];
        pStmt = statement ? [statement statement] : 0x00;
        [statement reset];
    }
    
    if (!pStmt)
    {
        rc      = sqlite3_prepare_v2(_db, [sql UTF8String], -1, &pStmt, 0);
        
        if (SQLITE_OK != rc)
        {
            if (logsErrors)
            {
                SXLogError(@"DB Error: %d \"%@\"", [self lastErrorCode], [self lastErrorMessage]);
                SXLogDebug(@"DB Query: %@", sql);
                // NSLog(@"DB Path: %@", _databasePath);
            }
            
            if (crashOnErrors)
            {
                NSAssert(false, @"DB Error: %d \"%@\"", [self lastErrorCode], [self lastErrorMessage]);
                abort();
            }
            
            sqlite3_finalize(pStmt);
            isExecutingStatement = NO;
            return nil;
        }
    }
    
    id obj;
    int idx = 0;
    int queryCount = sqlite3_bind_parameter_count(pStmt); // pointed out by Dominic Yu (thanks!)
    
    // If dictionaryArgs is passed in, that means we are using sqlite's named parameter support
    if (dictionaryArgs)
    {
        
        for (NSString *dictionaryKey in [dictionaryArgs allKeys])
        {
            
            // Prefix the key with a colon.
            NSString *parameterName = [[NSString alloc] initWithFormat:@":%@", dictionaryKey];
            
            if (traceExecution)
            {
                SXLogInfo(@"%@ = %@", parameterName, [dictionaryArgs objectForKey:dictionaryKey]);
            }
            
            // Get the index for the parameter name.
            int namedIdx = sqlite3_bind_parameter_index(pStmt, [parameterName UTF8String]);
            
            parameterName = nil;
            
            if (namedIdx > 0)
            {
                // Standard binding from here.
                [self bindObject:[dictionaryArgs objectForKey:dictionaryKey] toColumn:namedIdx inStatement:pStmt];
                // increment the binding count, so our check below works out
                idx++;
            }
            else
            {
                SXLogInfo(@"Could not find index for %@", dictionaryKey);
            }
        }
    }
    else
    {
        while (idx < queryCount)
        {
            
            if (arrayArgs && idx < (int)[arrayArgs count])
            {
                obj = [arrayArgs objectAtIndex:(NSUInteger)idx];
            }
            else if (args)
            {
                obj = va_arg(args, id);
            }
            else
            {
                //We ran out of arguments
                break;
            }
            
            if (traceExecution)
            {
                if ([obj isKindOfClass:[NSData class]])
                {
                    SXLogInfo(@"data: %ld bytes", (unsigned long)[(NSData*)obj length]);
                }
                else
                {
                    SXLogInfo(@"obj: %@", obj);
                }
            }
            
            idx++;
            
            [self bindObject:obj toColumn:idx inStatement:pStmt];
        }
    }
    
    if (idx != queryCount)
    {
        SXLogError(@"Error: the bind count is not correct for the # of variables (executeQuery)");
        sqlite3_finalize(pStmt);
        isExecutingStatement = NO;
        return nil;
    }
    
    if (!statement)
    {
        statement = [[SQLStatement alloc] init];
        [statement setStatement:pStmt];
        
        if (shouldCacheStatements && sql)
        {
            [self setCachedStatement:statement forQuery:sql];
        }
    }
    
    // the statement gets closed in rs's dealloc or [rs close];
    rs = [SQLResultSet resultSetWithStatement:statement usingParentDatabase:self];
    [rs setQuery:sql];
    
    NSValue *openResultSet = [NSValue valueWithNonretainedObject:rs];
    [openResultSets addObject:openResultSet];
    
    [statement setUseCount:[statement useCount] + 1];
    
    isExecutingStatement = NO;
    
    return rs;
}

- (SQLResultSet *)executeQuery:(NSString*)sql, ...
{
    va_list args;
    va_start(args, sql);
    
    id result = [self executeQuery:sql withArgumentsInArray:nil orDictionary:nil orVAList:args];
    
    va_end(args);
    return result;
}


- (SQLResultSet *)executeQueryWithFormat:(NSString*)format, ...
{
    va_list args;
    va_start(args, format);
    
    NSMutableString *sql = [NSMutableString stringWithCapacity:[format length]];
    NSMutableArray *arguments = [NSMutableArray array];
    [self extractSQL:format argumentsList:args intoString:sql arguments:arguments];
    
    va_end(args);
    
    return [self executeQuery:sql withArgumentsInArray:arguments];
}


- (SQLResultSet *)executeQuery:(NSString *)sql withArgumentsInArray:(NSArray *)arguments
{
    return [self executeQuery:sql withArgumentsInArray:arguments orDictionary:nil orVAList:nil];
}

- (SQLResultSet *)executeQuery:(NSString*)sql withVAList:(va_list)args
{
    return [self executeQuery:sql withArgumentsInArray:nil orDictionary:nil orVAList:args];
}

#pragma mark Execute updates

- (BOOL)executeUpdateWithEmptyStringInsertedForEmptyColumns:(NSString*)sql error:(NSError**)outErr
                                       withArgumentsInArray:(NSArray*)arrayArgs
                                               orDictionary:(NSDictionary *)dictionaryArgs
                                                   orVAList:(va_list)args
{
    
    if (![self databaseExists])
    {
        return NO;
    }
    
    if (isExecutingStatement)
    {
        [self warnInUse];
        return NO;
    }
    
    isExecutingStatement = YES;
    
    int rc                   = 0x00;
    sqlite3_stmt *pStmt      = 0x00;
    SQLStatement *cachedStmt  = 0x00;
    
    if (traceExecution && sql)
    {
        SXLogDebug(@"%@ executeUpdate: %@", self, sql);
    }
    
    if (shouldCacheStatements)
    {
        cachedStmt = [self cachedStatementForQuery:sql];
        pStmt = cachedStmt ? [cachedStmt statement] : 0x00;
        [cachedStmt reset];
    }
    
    if (!pStmt)
    {
        rc = sqlite3_prepare_v2(_db, [sql UTF8String], -1, &pStmt, 0);
        
        if (SQLITE_OK != rc)
        {
            if (logsErrors)
            {
                SXLogError(@"DB Error: %d \"%@\"", [self lastErrorCode], [self lastErrorMessage]);
                SXLogInfo(@"DB Query: %@", sql);
            }
            
            if (crashOnErrors)
            {
                NSAssert(false, @"DB Error: %d \"%@\"", [self lastErrorCode], [self lastErrorMessage]);
                abort();
            }
            
            sqlite3_finalize(pStmt);
            
            if (outErr)
            {
                *outErr = [self errorWithMessage:[NSString stringWithUTF8String:sqlite3_errmsg(_db)]];
            }
            
            isExecutingStatement = NO;
            return NO;
        }
    }
    
    id obj;
    int idx = 0;
    int queryCount = sqlite3_bind_parameter_count(pStmt);
    //    NSString *emptyString = @"";
    // If dictionaryArgs is passed in, that means we are using sqlite's named parameter support
    if (dictionaryArgs)
    {
        for (int innerC = 1; innerC <= queryCount ; innerC++) {
            
            char *cStringName = (char *)sqlite3_bind_parameter_name(pStmt,innerC);
            
            if (cStringName != nil) {
                NSString *parameterName = [NSString stringWithUTF8String:cStringName];
                
                parameterName = [parameterName stringByReplacingOccurrencesOfString:@":" withString:@""];
                NSString *bindValue = [dictionaryArgs objectForKey:parameterName];
                if (bindValue == nil) {
                    bindValue = nil;
                }
                if (traceExecution)
                {
                    SXLogInfo(@"%@ = %@", parameterName, bindValue);
                }
                // Standard binding from here.
                [self bindObject:bindValue toColumn:innerC inStatement:pStmt];
                
                // increment the binding count, so our check below works out
                idx++;
            }
            
            
        }
    }
    else
    {
        while (idx < queryCount)
        {
            if (arrayArgs && idx < (int)[arrayArgs count])
            {
                obj = [arrayArgs objectAtIndex:(NSUInteger)idx];
            }
            else if (args)
            {
                obj = va_arg(args, id);
            }
            else
            {
                //We ran out of arguments
                break;
            }
            
            if (traceExecution)
            {
                if ([obj isKindOfClass:[NSData class]])
                {
                    SXLogInfo(@"data: %ld bytes", (unsigned long)[(NSData*)obj length]);
                }
                else
                {
                    SXLogInfo(@"obj: %@", obj);
                }
            }
            
            idx++;
            
            [self bindObject:obj toColumn:idx inStatement:pStmt];
        }
    }
    
    if (idx != queryCount)
    {
        SXLogError(@"Error: the bind count (%d) is not correct for the # of variables in the query (%d) (%@) (executeUpdate)", idx, queryCount, sql);
        sqlite3_finalize(pStmt);
        isExecutingStatement = NO;
        return NO;
    }
    
    /* Call sqlite3_step() to run the virtual machine. Since the SQL being
     ** executed is not a SELECT statement, we assume no data will be returned.
     */
    
    rc = sqlite3_step(pStmt);
    
    if (SQLITE_DONE == rc)
    {
        // all is well, let's return.
    }
    else if (SQLITE_ERROR == rc)
    {
        if (logsErrors)
        {
            SXLogError(@"Error calling sqlite3_step (%d: %s) SQLITE_ERROR", rc, sqlite3_errmsg(_db));
            SXLogInfo(@"DB Query: %@", sql);
        }
    }
    else if (SQLITE_MISUSE == rc)
    {
        // uh oh.
        if (logsErrors)
        {
            SXLogError(@"Error calling sqlite3_step (%d: %s) SQLITE_MISUSE", rc, sqlite3_errmsg(_db));
            SXLogInfo(@"DB Query: %@", sql);
        }
    }
    else
    {
        //
        if (logsErrors)
        {
            SXLogError(@"Unknown error calling sqlite3_step (%d: %s) eu", rc, sqlite3_errmsg(_db));
            SXLogInfo(@"DB Query: %@", sql);
        }
    }
    
    if (rc == SQLITE_ROW)
    {
        NSAssert(NO, @"A executeUpdate is being called with a query string '%@'", sql);
    }
    
    if (shouldCacheStatements && !cachedStmt)
    {
        cachedStmt = [[SQLStatement alloc] init];
        
        [cachedStmt setStatement:pStmt];
        
        [self setCachedStatement:cachedStmt forQuery:sql];
        
    }
    
    int closeErrorCode;
    
    if (cachedStmt)
    {
        [cachedStmt setUseCount:[cachedStmt useCount] + 1];
        closeErrorCode = sqlite3_reset(pStmt);
    }
    else
    {
        /* Finalize the virtual machine. This releases all memory and other
         ** resources allocated by the sqlite3_prepare() call above.
         */
        closeErrorCode = sqlite3_finalize(pStmt);
    }
    
    if (closeErrorCode != SQLITE_OK)
    {
        if (logsErrors)
        {
            SXLogError(@"Unknown error finalizing or resetting statement (%d: %s)", closeErrorCode, sqlite3_errmsg(_db));
            SXLogInfo(@"DB Query: %@", sql);
        }
    }
    
    isExecutingStatement = NO;
    return (rc == SQLITE_DONE || rc == SQLITE_OK);
}

- (BOOL)executeUpdate:(NSString*)sql error:(NSError**)outErr
 withArgumentsInArray:(NSArray*)arrayArgs
         orDictionary:(NSDictionary *)dictionaryArgs
             orVAList:(va_list)args
{
    
    if (![self databaseExists])
    {
        return NO;
    }
    
    if (isExecutingStatement)
    {
        [self warnInUse];
        return NO;
    }
    
    isExecutingStatement = YES;
    
    int rc                   = 0x00;
    sqlite3_stmt *pStmt      = 0x00;
    SQLStatement *cachedStmt  = 0x00;
    
    if (traceExecution && sql)
    {
        NSLog(@"%@ executeUpdate: %@", self, sql);
    }
    
    if (shouldCacheStatements)
    {
        cachedStmt = [self cachedStatementForQuery:sql];
        pStmt = cachedStmt ? [cachedStmt statement] : 0x00;
        [cachedStmt reset];
    }
    
    if (!pStmt)
    {
        rc = sqlite3_prepare_v2(_db, [sql UTF8String], -1, &pStmt, 0);
        
        if (SQLITE_OK != rc)
        {
            if (logsErrors)
            {
                SXLogError(@"DB Error: %d \"%@\"", [self lastErrorCode], [self lastErrorMessage]);
                SXLogInfo(@"DB Query: %@", sql);
                // NSLog(@"DB Path: %@", _databasePath);
            }
            
            if (crashOnErrors)
            {
                NSAssert(false, @"DB Error: %d \"%@\"", [self lastErrorCode], [self lastErrorMessage]);
                abort();
            }
            
            sqlite3_finalize(pStmt);
            
            if (outErr)
            {
                *outErr = [self errorWithMessage:[NSString stringWithUTF8String:sqlite3_errmsg(_db)]];
            }
            
            isExecutingStatement = NO;
            return NO;
        }
    }
    
    id obj;
    int idx = 0;
    int queryCount = sqlite3_bind_parameter_count(pStmt);
    
    // If dictionaryArgs is passed in, that means we are using sqlite's named parameter support
    if (dictionaryArgs)
    {
        for (NSString *dictionaryKey in [dictionaryArgs allKeys])
        {
            
            // Prefix the key with a colon.
            NSString *parameterName = [[NSString alloc] initWithFormat:@":%@", dictionaryKey];
            
            if (traceExecution)
            {
                SXLogInfo(@"%@ = %@", parameterName, [dictionaryArgs objectForKey:dictionaryKey]);
            }
            // Get the index for the parameter name.
            int namedIdx = sqlite3_bind_parameter_index(pStmt, [parameterName UTF8String]);
            
            if (namedIdx > 0)
            {
                // Standard binding from here.
                [self bindObject:[dictionaryArgs objectForKey:dictionaryKey] toColumn:namedIdx inStatement:pStmt];
                
                // increment the binding count, so our check below works out
                idx++;
            }
            else
            {
                SXLogWarning(@"Could not find index for %@", dictionaryKey);
            }
        }
    }
    else
    {
        while (idx < queryCount)
        {
            if (arrayArgs && idx < (int)[arrayArgs count])
            {
                obj = [arrayArgs objectAtIndex:(NSUInteger)idx];
            }
            else if (args)
            {
                obj = va_arg(args, id);
            }
            else
            {
                //We ran out of arguments
                break;
            }
            
            if (traceExecution)
            {
                if ([obj isKindOfClass:[NSData class]])
                {
                    SXLogInfo(@"data: %ld bytes", (unsigned long)[(NSData*)obj length]);
                }
                else
                {
                    SXLogInfo(@"obj: %@", obj);
                }
            }
            
            idx++;
            
            [self bindObject:obj toColumn:idx inStatement:pStmt];
        }
    }
    
    if (idx != queryCount)
    {
        SXLogError(@"Error: the bind count (%d) is not correct for the # of variables in the query (%d) (%@) (executeUpdate)", idx, queryCount, sql);
        sqlite3_finalize(pStmt);
        isExecutingStatement = NO;
        return NO;
    }
    
    /* Call sqlite3_step() to run the virtual machine. Since the SQL being
     ** executed is not a SELECT statement, we assume no data will be returned.
     */
    
    rc = sqlite3_step(pStmt);
    
    if (SQLITE_DONE == rc)
    {
        // all is well, let's return.
    }
    else if (SQLITE_ERROR == rc)
    {
        if (logsErrors)
        {
            SXLogError(@"Error calling sqlite3_step (%d: %s) SQLITE_ERROR", rc, sqlite3_errmsg(_db));
            SXLogInfo(@"DB Query: %@", sql);
        }
    }
    else if (SQLITE_MISUSE == rc)
    {
        // uh oh.
        if (logsErrors)
        {
            SXLogError(@"Error calling sqlite3_step (%d: %s) SQLITE_MISUSE", rc, sqlite3_errmsg(_db));
            SXLogInfo(@"DB Query: %@", sql);
        }
    }
    else
    {
        //
        if (logsErrors)
        {
            SXLogError(@"Unknown error calling sqlite3_step (%d: %s) eu", rc, sqlite3_errmsg(_db));
            SXLogInfo(@"DB Query: %@", sql);
        }
    }
    
    if (rc == SQLITE_ROW)
    {
        NSAssert(NO, @"A executeUpdate is being called with a query string '%@'", sql);
    }
    
    if (shouldCacheStatements && !cachedStmt)
    {
        cachedStmt = [[SQLStatement alloc] init];
        
        [cachedStmt setStatement:pStmt];
        
        [self setCachedStatement:cachedStmt forQuery:sql];
        
    }
    
    int closeErrorCode;
    
    if (cachedStmt)
    {
        [cachedStmt setUseCount:[cachedStmt useCount] + 1];
        closeErrorCode = sqlite3_reset(pStmt);
    }
    else
    {
        /* Finalize the virtual machine. This releases all memory and other
         ** resources allocated by the sqlite3_prepare() call above.
         */
        closeErrorCode = sqlite3_finalize(pStmt);
    }
    
    if (closeErrorCode != SQLITE_OK)
    {
        if (logsErrors)
        {
            NSLog(@"Unknown error finalizing or resetting statement (%d: %s)", closeErrorCode, sqlite3_errmsg(_db));
            NSLog(@"DB Query: %@", sql);
        }
    }
    
    isExecutingStatement = NO;
    return (rc == SQLITE_DONE || rc == SQLITE_OK);
}


- (BOOL)executeUpdate:(NSString*)sql, ...
{
    va_list args;
    va_start(args, sql);
    
    BOOL result = [self executeUpdate:sql error:nil withArgumentsInArray:nil orDictionary:nil orVAList:args];
    
    va_end(args);
    return result;
}

- (BOOL)executeUpdate:(NSString*)sql withArgumentsInArray:(NSArray *)arguments
{
    return [self executeUpdate:sql error:nil withArgumentsInArray:arguments orDictionary:nil orVAList:nil];
}

- (BOOL)executeUpdate:(NSString*)sql withParameterDictionary:(NSDictionary *)arguments
{
    return [self executeUpdate:sql error:nil withArgumentsInArray:nil orDictionary:arguments orVAList:nil];
}

- (BOOL)executeUpdateWithEmptyStringInsertedForEmptyColumns:(NSString*)sql withParameterDictionary:(NSDictionary *)arguments
{
    return [self executeUpdateWithEmptyStringInsertedForEmptyColumns:sql error:nil withArgumentsInArray:nil orDictionary:arguments orVAList:nil];
}

- (BOOL)executeUpdate:(NSString*)sql withVAList:(va_list)args
{
    return [self executeUpdate:sql error:nil withArgumentsInArray:nil orDictionary:nil orVAList:args];
}

- (BOOL)executeUpdateWithFormat:(NSString*)format, ...
{
    va_list args;
    va_start(args, format);
    
    NSMutableString *sql      = [NSMutableString stringWithCapacity:[format length]];
    NSMutableArray *arguments = [NSMutableArray array];
    
    [self extractSQL:format argumentsList:args intoString:sql arguments:arguments];
    
    va_end(args);
    
    return [self executeUpdate:sql withArgumentsInArray:arguments];
}


- (BOOL)rollback
{
    BOOL success = [self executeUpdate:@"rollback transaction"];
    
    if (success)
    {
        inTransaction = NO;
    }
    
    return success;
}

- (BOOL)commit
{
    BOOL success =  [self executeUpdate:@"commit transaction"];
    
    if (success)
    {
        inTransaction = NO;
    }
    
    return success;
}

- (BOOL)beginDeferredTransaction
{
    BOOL success = [self executeUpdate:@"begin deferred transaction"];
    if (success)
    {
        inTransaction = YES;
    }
    
    return success;
}

- (BOOL)beginTransaction
{
    BOOL success = [self executeUpdate:@"begin exclusive transaction"];
    if (success)
    {
        inTransaction = YES;
    }
    
    return success;
}

- (BOOL)inTransaction
{
    return inTransaction;
}



int DBExecuteBulkSQLCallback(void *theBlockAsVoid, int columns, char **values, char **names); // shhh clang.
int DBExecuteBulkSQLCallback(void *theBlockAsVoid, int columns, char **values, char **names)
{
    if (!theBlockAsVoid)
    {
        return SQLITE_OK;
    }
    
    int (^execCallbackBlock)(NSDictionary *resultsDictionary) = (__bridge int (^)(NSDictionary *__strong))(theBlockAsVoid);
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:(NSUInteger)columns];
    
    for (NSInteger i = 0; i < columns; i++)
    {
        NSString *key = [NSString stringWithUTF8String:names[i]];
        id value = values[i] ? [NSString stringWithUTF8String:values[i]] : [NSNull null];
        [dictionary setObject:value forKey:key];
    }
    
    return execCallbackBlock(dictionary);
}

- (BOOL)executeStatements:(NSString *)sql
{
    return [self executeStatements:sql withResultBlock:nil];
}


- (BOOL)executeStatements:(NSString *)sql withResultBlock:(DBExecuteStatementsCallbackBlock)block
{
    int rc;
    char *errmsg = nil;
    
    rc = sqlite3_exec([self sqliteHandle], [sql UTF8String], block ? DBExecuteBulkSQLCallback : nil, (__bridge void *)(block), &errmsg);
    
    if (errmsg && [self logsErrors])
    {
        NSLog(@"Error inserting batch: %s", errmsg);
        sqlite3_free(errmsg);
    }
    
    return (rc == SQLITE_OK);
}

- (BOOL)executeUpdate:(NSString*)sql withErrorAndBindings:(NSError**)outErr, ...
{
    va_list args;
    va_start(args, outErr);
    
    BOOL result = [self executeUpdate:sql error:outErr withArgumentsInArray:nil orDictionary:nil orVAList:args];
    
    va_end(args);
    return result;
}

@end

@implementation SQLStatement

@synthesize statement =_statement;
@synthesize query =_query;
@synthesize useCount =_useCount;
@synthesize inUse =_inUse;

- (void)finalize
{
    [self close];
    _query = nil;
    [super finalize];
}

- (void)dealloc
{
    [self close];
}

- (void)close
{
    if (_statement)
    {
        sqlite3_finalize(_statement);
        _statement = 0x00;
    }
    _inUse = NO;
}

- (void)reset
{
    if (_statement)
    {
        // sqlite3_reset(_statement);
    }
    _inUse = NO;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"%@ %ld hit(s) for query %@", [super description], _useCount, _query];
}


@end
