//
//  DatabaseQueue.m
//  fmdb
//
//  Created by August Mueller on 6/22/11.
//  Copyright 2011 Flying Meat Inc. All rights reserved.
//

#import "DatabaseQueue.h"
#import "SMDatabase.h"
#import "SQLResultSet.h"
#import "DatabaseManager.h"

//NSString *const kDBEncryptionKey               = @"svmxipad";

/*
 
 Note: we call [self retain]; before using dispatch_sync, just incase 
 DatabaseQueue is released on another thread and we're in the middle of doing
 something in dispatch_sync
 
 */

/*
 * A key used to associate the DatabaseQueue object with the dispatch_queue_t it uses.
 * This in turn is used for deadlock detection by seeing if inDatabase: is called on
 * the queue's dispatch queue, which should not happen and causes a deadlock.
 */
static const void * const kDispatchQueueSpecificKey = &kDispatchQueueSpecificKey;
 
@implementation DatabaseQueue

@synthesize path = _path;
@synthesize openFlags = _openFlags;

+ (instancetype)databaseQueueWithPath:(NSString*)aPath {
    
    NSLog(@"DB-Q initialize");
    DatabaseQueue *q = [[self alloc] initWithPath:aPath];
    return q;
}

+ (instancetype)databaseQueueWithPath:(NSString*)aPath flags:(int)openFlags {
    
    DatabaseQueue *q = [[self alloc] initWithPath:aPath flags:openFlags];

    return q;
}

+ (Class)databaseClass {
    return [SMDatabase class];
}

- (instancetype)initWithPath:(NSString*)aPath flags:(int)openFlags {
    
    self = [super init];
    
    if (self != nil) {
        
        _db = [[[self class] databaseClass] databaseWithPath:aPath];
        
#if SQLITE_VERSION_NUMBER >= 3005000
        BOOL success = [_db openWithFlags:openFlags];
#else
        BOOL success = [_db open];
#endif
        if (!success) {
            NSLog(@"Could not create database queue for path %@", aPath);
            return 0x00;
        }
        
        _path = aPath;
        
        _queue = dispatch_queue_create([[NSString stringWithFormat:@"fmdb.%@", self] UTF8String], NULL);
        dispatch_queue_set_specific(_queue, kDispatchQueueSpecificKey, (__bridge void *)self, NULL);
        _openFlags = openFlags;
    }
    
    return self;
}

- (instancetype)initWithPath:(NSString*)aPath {
    
    // default flags for sqlite3_open
    return [self initWithPath:aPath flags:SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE];
}

- (instancetype)init {
    return [self initWithPath:nil];
}

    
- (void)dealloc {
    
    _db = nil;
    _path = nil;
    
    if (_queue) {
        _queue = nil;
        _queue = 0x00;
    }
}

- (void)close {
    
    dispatch_sync(_queue, ^() { 
        [_db close];
        _db = 0x00;
    });
}


- (BOOL)closeDatabase {
    
    BOOL close = [_db close];
    
    if(close)
    {
        _db = 0x00;
    }
    else
    {
        NSLog(@"Unable to close database connection");
    }
    return close;
}


- (SMDatabase*)database {
    
    if (!_db) {
        _db = [SMDatabase databaseWithPath:_path];
        
#if SQLITE_VERSION_NUMBER >= 3005000
        BOOL success = [_db openWithFlags:_openFlags];
#else
        BOOL success = [db open];
#endif
        if (!success) {
            NSLog(@"DatabaseQueue could not reopen database for path %@", _path);
            _db  = 0x00;
            return 0x00;
        }
        else
        {
            NSLog(@"DatabaseQueue opened new database ");
        }
    }
    
    return _db;
}

- (void)inDatabase:(void (^)(SMDatabase *db))block {
    /* Get the currently executing queue (which should probably be nil, but in theory could be another DB queue
     * and then check it against self to make sure we're not about to deadlock. */
    DatabaseQueue *currentSyncQueue = (__bridge id)dispatch_get_specific(kDispatchQueueSpecificKey);
    assert(currentSyncQueue != self && "inDatabase: was called reentrantly on the same queue, which would lead to a deadlock");
    
    dispatch_sync(_queue, ^() {
        
        SMDatabase *db = [self database];
        block(db);
        
//        //if ([db hasOpenResultSets]) {
//            NSLog(@"Warning: there is at least one open result set around after performing [DatabaseQueue inDatabase:]");
//            
//#ifdef DEBUG
//            NSSet *openSetCopy = [[db valueForKey:@"_openResultSets"] copy];
//            for (NSValue *rsInWrappedInATastyValueMeal in openSetCopy) {
//                SQLResultSet *rs = (SQLResultSet *)[rsInWrappedInATastyValueMeal pointerValue];
//                NSLog(@"query: '%@'", [rs query]);
//            }
//#endif
//      //  }
    });
}


- (void)beginTransaction:(BOOL)useDeferred withBlock:(void (^)(SMDatabase *db, BOOL *rollback))block {

    dispatch_sync(_queue, ^() { 
        
        BOOL shouldRollback = NO;
        
        if (useDeferred) {
            [[self database] beginDeferredTransaction];
        }
        else {
            [[self database] beginTransaction];
        }
        
        block([self database], &shouldRollback);
        
        if (shouldRollback) {
            [[self database] rollback];
        }
        else {
            [[self database] commit];
        }
    });
    
}

- (void)inDeferredTransaction:(void (^)(SMDatabase *db, BOOL *rollback))block {
    [self beginTransaction:YES withBlock:block];
}

- (void)inTransaction:(void (^)(SMDatabase *db, BOOL *rollback))block {
    [self beginTransaction:NO withBlock:block];
}

#if SQLITE_VERSION_NUMBER >= 3007000
//- (NSError*)inSavePoint:(void (^)(SMDatabase *db, BOOL *rollback))block {
//    
//    static unsigned long savePointIdx = 0;
//    __block NSError *err = 0x00;
//    DBRetain(self);
//    dispatch_sync(_queue, ^() { 
//        
//        NSString *name = [NSString stringWithFormat:@"savePoint%ld", savePointIdx++];
//        
//        BOOL shouldRollback = NO;
//        
//        if ([[self database] startSavePointWithName:name error:&err]) {
//            
//            block([self database], &shouldRollback);
//            
//            if (shouldRollback) {
//                // We need to rollback and release this savepoint to remove it
//                [[self database] rollbackToSavePointWithName:name error:&err];
//            }
//            [[self database] releaseSavePointWithName:name error:&err];
//            
//        }
//    });
//    DBRelease(self);
//    return err;
//}
#endif

@end
