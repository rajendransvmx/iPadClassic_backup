//
//  SQLResultSet.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 5/21/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import "SQLResultSet.h"

#import "DatabaseManager.h"
#import "SMDatabase.h"
#import "unistd.h"
#import "StringUtil.h"

@interface SMDatabase()
- (void)resultSetDidClose:(SQLResultSet *)resultSet;
@end


@implementation SQLResultSet

@synthesize query=_query;
@synthesize statement=_statement;

+ (instancetype)resultSetWithStatement:(SQLStatement *)statement usingParentDatabase:(SMDatabase *)aDB
{
    SQLResultSet *rs = [[SQLResultSet alloc] init];
    
    [rs setStatement:statement];
    [rs setParentDB:aDB];

    [statement setInUse:YES]; // weak reference
    
    return rs;
}

- (void)finalize
{
    [self close];
    [super finalize];
}

- (void)dealloc {
    [self close];

    _query = nil;
    _columnNameToIndexMap = nil;

}

- (void)close {
    [_statement reset];
    _statement = nil;
    [_parentDB resultSetDidClose:self];
    _parentDB = nil;
}

- (int)columnCount {
    return sqlite3_column_count([_statement statement]);
}

- (NSMutableDictionary *)columnNameToIndexMap {
    if (!_columnNameToIndexMap) {
        int columnCount = sqlite3_column_count([_statement statement]);
        _columnNameToIndexMap = [[NSMutableDictionary alloc] initWithCapacity:(NSUInteger)columnCount];
        int columnIdx = 0;
        for (columnIdx = 0; columnIdx < columnCount; columnIdx++) {
            [_columnNameToIndexMap setObject:[NSNumber numberWithInt:columnIdx]
                                      forKey:[[NSString stringWithUTF8String:sqlite3_column_name([_statement statement], columnIdx)] lowercaseString]];
        }
    }
    return _columnNameToIndexMap;
}

- (void)kvcMagic:(id)object {
    
    int columnCount = sqlite3_column_count([_statement statement]);
    
    int columnIdx = 0;
    for (columnIdx = 0; columnIdx < columnCount; columnIdx++) {
        
        const char *c = (const char *)sqlite3_column_text([_statement statement], columnIdx);
        
        // check for a null row
        if (c) {
            NSString *s = [NSString stringWithUTF8String:c];
            
            [object setValue:s forKey:[NSString stringWithUTF8String:sqlite3_column_name([_statement statement], columnIdx)]];
        }
    }
}

#pragma clang diagnostic pop

- (NSDictionary*)resultDictionary {
    
    NSUInteger num_cols = (NSUInteger)sqlite3_data_count([_statement statement]);
    
    if (num_cols > 0) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:num_cols];
        
        int columnCount = sqlite3_column_count([_statement statement]);
        
        int columnIdx = 0;
        for (columnIdx = 0; columnIdx < columnCount; columnIdx++) {
            
            NSString *columnName = [NSString stringWithUTF8String:sqlite3_column_name([_statement statement], columnIdx)];
            id objectValue = [self objectForColumnIndex:columnIdx];
            if ([objectValue isKindOfClass:[NSNull class]]) {
                [dict setValue:nil forKey:columnName];
            }
            else{
                /*
                 * Pushpak : changed as when column names were same, it was getting overridden.
                 */
                if ([[dict allKeys] containsObject:columnName]) {
                    columnName = [NSString stringWithFormat:@"%@%d",columnName,columnIdx];
                }
                [dict setObject:objectValue forKey:columnName];
            }
            
        }
        
        return dict;
    }
    else {
        NSLog(@"Warning: There seem to be no columns in this set.");
    }
    
    return nil;
}
//get all field values as string

- (NSDictionary*)resultDictionaryWithFieldsAsString {
    
    NSUInteger num_cols = (NSUInteger)sqlite3_data_count([_statement statement]);
    
    if (num_cols > 0) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:num_cols];
        
        int columnCount = sqlite3_column_count([_statement statement]);
        
        int columnIdx = 0;
        for (columnIdx = 0; columnIdx < columnCount; columnIdx++) {
            
            NSString *columnName = @"";
            columnName = [NSString stringWithUTF8String:sqlite3_column_name([_statement statement], columnIdx)];
            id objectValue = [self stringObjectForAllColumnIndex:columnIdx];
            
            if ([objectValue isKindOfClass:[NSNull class]]) {
                [dict setValue:nil forKey:columnName];
            }
            else{
                [dict setObject:objectValue forKey:columnName];
            }
        }
        
        return dict;
    }
    else {
        NSLog(@"Warning: There seem to be no columns in this set.");
    }
    return nil;
    
}

- (NSDictionary*)beforeModificationDictionaryWithFieldsAsString {
    
    NSUInteger num_cols = (NSUInteger)sqlite3_data_count([_statement statement]);
    
    if (num_cols > 0) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:num_cols];
        
        int columnCount = sqlite3_column_count([_statement statement]);
        
        int columnIdx = 0;
        for (columnIdx = 0; columnIdx < columnCount; columnIdx++) {
            
            NSString *columnName = @"";
            columnName = [NSString stringWithUTF8String:sqlite3_column_name([_statement statement], columnIdx)];
            id objectValue = [self stringObjectForAllColumnIndex:columnIdx];
            
            if ([objectValue isKindOfClass:[NSNull class]]) {
                [dict setValue:@"" forKey:columnName];
            }
            else{
                [dict setObject:objectValue forKey:columnName];
            }
        }
        
        return dict;
    }
    else {
        NSLog(@"Warning: There seem to be no columns in this set.");
    }
    return nil;
    
}



- (BOOL)next
{
    int rc = sqlite3_step([_statement statement]);
    
    if (SQLITE_BUSY == rc || SQLITE_LOCKED == rc)
    {
        NSLog(@"%s:%d Database busy (%@)", __FUNCTION__, __LINE__, [_parentDB databasePath]);
        NSLog(@"Database busy");
    }
    else if (SQLITE_DONE == rc || SQLITE_ROW == rc)
    {
        // all is well, let's return.
    }
    else if (SQLITE_ERROR == rc)
    {
        NSLog(@"Error calling sqlite3_step (%d: %s) rs", rc, sqlite3_errmsg([_parentDB sqliteHandle]));
    }
    else if (SQLITE_MISUSE == rc)
    {
        // uh oh.
        NSLog(@"Error calling sqlite3_step (%d: %s) rs", rc, sqlite3_errmsg([_parentDB sqliteHandle]));
    }
    else
    {
        // wtf?
        NSLog(@"Unknown error calling sqlite3_step (%d: %s) rs", rc, sqlite3_errmsg([_parentDB sqliteHandle]));
    }
    
    if (rc != SQLITE_ROW)
    {
        [self close];
    }
    
    return (rc == SQLITE_ROW);
}

- (BOOL)hasAnotherRow
{
    return sqlite3_errcode([_parentDB sqliteHandle]) == SQLITE_ROW;
}

- (int)columnIndexForName:(NSString*)columnName
{
    columnName = [columnName lowercaseString];
    
    NSNumber *n = [[self columnNameToIndexMap] objectForKey:columnName];
    
    if (n) {
        return [n intValue];
    }
    
    NSLog(@"Could not find the column named '%@'.", columnName);
    
    return -1;
}



- (int)intForColumn:(NSString*)columnName
{
    return [self intForColumnIndex:[self columnIndexForName:columnName]];
}

- (int)intForColumnIndex:(int)columnIdx
{
    return sqlite3_column_int([_statement statement], columnIdx);
}

- (long)longForColumn:(NSString*)columnName
{
    return [self longForColumnIndex:[self columnIndexForName:columnName]];
}

- (long)longForColumnIndex:(int)columnIdx
{
    return (long)sqlite3_column_int64([_statement statement], columnIdx);
}

- (long long int)longLongIntForColumn:(NSString*)columnName
{
    return [self longLongIntForColumnIndex:[self columnIndexForName:columnName]];
}

- (long long int)longLongIntForColumnIndex:(int)columnIdx {
    return sqlite3_column_int64([_statement statement], columnIdx);
}

- (unsigned long long int)unsignedLongLongIntForColumn:(NSString*)columnName
{
    return [self unsignedLongLongIntForColumnIndex:[self columnIndexForName:columnName]];
}

- (unsigned long long int)unsignedLongLongIntForColumnIndex:(int)columnIdx
{
    return (unsigned long long int)[self longLongIntForColumnIndex:columnIdx];
}

- (BOOL)boolForColumn:(NSString*)columnName
{
    return [self boolForColumnIndex:[self columnIndexForName:columnName]];
}

- (BOOL)boolForColumnIndex:(int)columnIdx
{
    return ([self intForColumnIndex:columnIdx] != 0);
}

- (double)doubleForColumn:(NSString*)columnName
{
    return [self doubleForColumnIndex:[self columnIndexForName:columnName]];
}

- (double)doubleForColumnIndex:(int)columnIdx
{
    return sqlite3_column_double([_statement statement], columnIdx);
}

- (NSString*)stringForColumnIndex:(int)columnIdx
{
    if (sqlite3_column_type([_statement statement], columnIdx) == SQLITE_NULL || (columnIdx < 0))
    {
        return nil;
    }
    
    const char *c = (const char *)sqlite3_column_text([_statement statement], columnIdx);
    
    if (!c) {
        // null row.
        return nil;
    }
    return [NSString stringWithUTF8String:c];
}

- (NSString*)stringForColumn:(NSString*)columnName
{
    return [self stringForColumnIndex:[self columnIndexForName:columnName]];
}

- (NSDate*)dateForColumn:(NSString*)columnName
{
    return [self dateForColumnIndex:[self columnIndexForName:columnName]];
}

- (NSDate*)dateForColumnIndex:(int)columnIdx
{
    if (sqlite3_column_type([_statement statement], columnIdx) == SQLITE_NULL || (columnIdx < 0))
    {
        return nil;
    }
    return [NSDate dateWithTimeIntervalSince1970:[self doubleForColumnIndex:columnIdx]];
}


- (NSData*)dataForColumn:(NSString*)columnName
{
    return [self dataForColumnIndex:[self columnIndexForName:columnName]];
}

- (NSData*)dataForColumnIndex:(int)columnIdx
{
    if (sqlite3_column_type([_statement statement], columnIdx) == SQLITE_NULL || (columnIdx < 0))
    {
        return nil;
    }
    
    int dataSize = sqlite3_column_bytes([_statement statement], columnIdx);
    
    NSMutableData *data = [NSMutableData dataWithLength:(NSUInteger)dataSize];
    
    memcpy([data mutableBytes], sqlite3_column_blob([_statement statement], columnIdx), dataSize);
    
    return data;
}


- (NSData*)dataNoCopyForColumn:(NSString*)columnName
{
    return [self dataNoCopyForColumnIndex:[self columnIndexForName:columnName]];
}

- (NSData*)dataNoCopyForColumnIndex:(int)columnIdx
{
    if (sqlite3_column_type([_statement statement], columnIdx) == SQLITE_NULL || (columnIdx < 0))
    {
        return nil;
    }
    
    int dataSize = sqlite3_column_bytes([_statement statement], columnIdx);
    
    NSData *data = [NSData dataWithBytesNoCopy:(void *)sqlite3_column_blob([_statement statement], columnIdx) length:(NSUInteger)dataSize freeWhenDone:NO];
    
    return data;
}


- (BOOL)columnIndexIsNull:(int)columnIdx
{
    return sqlite3_column_type([_statement statement], columnIdx) == SQLITE_NULL;
}

- (BOOL)columnIsNull:(NSString*)columnName
{
    return [self columnIndexIsNull:[self columnIndexForName:columnName]];
}

- (const unsigned char *)UTF8StringForColumnIndex:(int)columnIdx
{
    if (sqlite3_column_type([_statement statement], columnIdx) == SQLITE_NULL || (columnIdx < 0))
    {
        return nil;
    }
    
    return sqlite3_column_text([_statement statement], columnIdx);
}

- (const unsigned char *)UTF8StringForColumnName:(NSString*)columnName
{
    return [self UTF8StringForColumnIndex:[self columnIndexForName:columnName]];
}

- (id)objectForColumnIndex:(int)columnIdx
{
    int columnType = sqlite3_column_type([_statement statement], columnIdx);
    
//    if (columnType == SQLITE_INTEGER || columnType == SQLITE_FLOAT) {
//        columnType = SQLITE_TEXT;
//    }
    id returnValue = nil;
    
    if (columnType == SQLITE_INTEGER)
    {
        returnValue = [NSNumber numberWithLongLong:[self longLongIntForColumnIndex:columnIdx]];
    }
    else if (columnType == SQLITE_FLOAT)
    {
        returnValue = [NSNumber numberWithDouble:[self doubleForColumnIndex:columnIdx]];
    }
    else if (columnType == SQLITE_BLOB)
    {
        returnValue = [self dataForColumnIndex:columnIdx];
    }
    else
    {
        //default to a string for everything else
        returnValue = [self stringForColumnIndex:columnIdx];
    }
    
    if (returnValue == nil) {
        returnValue = [NSNull null];
    }
    
    return returnValue;
}


- (id)stringObjectForAllColumnIndex:(int)columnIdx
{
  
    id returnValue = nil;
   returnValue = [self stringForColumnIndex_:columnIdx];
    if (returnValue == nil) {
        returnValue = [NSNull null];
    }
    
    return returnValue;
}
/*- (NSString*)stringForColumnIndex_:(int)columnIdx
{
    if (sqlite3_column_type([_statement statement], columnIdx) == SQLITE_NULL || (columnIdx < 0))
    {
        return nil;
    }
    
    int coloumn_type = sqlite3_column_type([_statement statement], columnIdx);
    
    if(coloumn_type == SQLITE_FLOAT){
        
        double doubleValue = [self doubleForColumnIndex:columnIdx];
        NSString * doubleStr = [[NSString alloc] initWithFormat:@"%f",doubleValue];
        

        
        NSInteger range = 18;
        if([doubleStr containsString:@"."] ){
            range = 19;
        }
        
        NSString * finalStr = nil;
        if(doubleStr.length > range){
            
            finalStr = [doubleStr substringToIndex:range];
            NSRange strRange = [finalStr  rangeOfString:@"."];
            if (strRange.location + 1 == finalStr.length) {
                finalStr = [finalStr substringToIndex:finalStr.length-1];
            }
        }
        else{
    
            finalStr = doubleStr;
        }
        
        NSLog(@"final value  %f %@",doubleValue, finalStr);
        return finalStr;
    }
    else
    {
        const char *c = (const char *)sqlite3_column_text([_statement statement], columnIdx);
        if (!c) {
            // null row.
            return nil;
        }
        return [NSString stringWithUTF8String:c];
    }
    
     return nil;
}*/

- (NSString*)stringForColumnIndex_:(int)columnIdx
{
    if (sqlite3_column_type([_statement statement], columnIdx) == SQLITE_NULL || (columnIdx < 0))
    {
        return nil;
    }
    
    int coloumn_type = sqlite3_column_type([_statement statement], columnIdx);

    const char *c = (const char *)sqlite3_column_text([_statement statement], columnIdx);

    if (!c) {
    // null row.
    return nil;
    }

    NSString * str  = [NSString stringWithUTF8String:c];
    if(coloumn_type == SQLITE_FLOAT && str.length > 15){
        
        double doubleValue = [self doubleForColumnIndex:columnIdx];
        NSString * doubleStr = [[NSString alloc] initWithFormat:@"%f",doubleValue];
        NSInteger range = 18;
       /* if([doubleStr containsString:@"."] ){
            range = 19;
        }*/
        
        
        if([StringUtil containsString:@"." inString:doubleStr] ){
                range = 19;
        }
            
            
        NSString * finalStr = nil;
        if(doubleStr.length > range){
            
            finalStr = [doubleStr substringToIndex:range];
            NSRange strRange = [finalStr  rangeOfString:@"."];
            if (strRange.location + 1 == finalStr.length) {
                finalStr = [finalStr substringToIndex:finalStr.length-1];
            }
        }
        else{
            finalStr = doubleStr;
        }

        NSLog(@"final value  %f %@",str.doubleValue, finalStr);
        return finalStr;
    }
    
    return [NSString stringWithUTF8String:c];
    
    return nil;
}



- (id)objectForColumnName:(NSString*)columnName
{
    return [self objectForColumnIndex:[self columnIndexForName:columnName]];
}

// returns autoreleased NSString containing the name of the column in the result set
- (NSString*)columnNameForIndex:(int)columnIdx
{
    return [NSString stringWithUTF8String: sqlite3_column_name([_statement statement], columnIdx)];
}

- (void)setParentDB:(SMDatabase *)newDb
{
    _parentDB = newDb;
}

- (id)objectAtIndexedSubscript:(int)columnIdx
{
    return [self objectForColumnIndex:columnIdx];
}

- (id)objectForKeyedSubscript:(NSString *)columnName
{
    return [self objectForColumnName:columnName];
}

@end

