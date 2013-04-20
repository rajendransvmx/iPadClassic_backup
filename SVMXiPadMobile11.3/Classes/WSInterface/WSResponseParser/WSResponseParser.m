//
//  WSResponseParser.m
//  iService
//
//  Created by Siva Manne on 02/01/13.
//
//

#import "WSResponseParser.h"

#import "WSIntfGlobals.h"
#import "SMGPObjectsResponseParser.h"
#import "SMGPCodeSnippetResponseParser.h"
#import "SMGPDataSyncResponseParser.h"
#import "iServiceAppDelegate.h"

extern void SVMXLog(NSString *format, ...);
@implementation WSResponseParser
@synthesize dataBase;
@synthesize dataBaseInterface;
+ (id) classForEventName:(NSString *)eventName eventType:(NSString *)eventType
{
    id object;
    if([eventType isEqualToString:SYNC])
    {
        if([eventName isEqualToString:GET_PRICE_OBJECTS])
        {
            object = [[SMGPObjectsResponseParser alloc] init];
        }
        if([eventName isEqualToString:GET_PRICE_CODE_SNIPPET])
        {
            object = [[SMGPCodeSnippetResponseParser alloc] init];
        }
        if([eventName isEqualToString:GET_PRICE_DATA])
        {
            object = [[SMGPDataSyncResponseParser alloc] init];
        }
    }
    return [object autorelease];
}

- (BOOL) parseResponse:(NSArray *)result
{
    SMLog(@"None of the sub classes parsed the response %@",result);
    return FALSE;
}
#pragma mark - DataBase Functions
- (void)insertRecords:(NSArray *)array intoTable:(NSString *)tableName
{
    for(int index = 0 ;index <[array count]; index++)
    {
        NSDictionary *dict = [array objectAtIndex:index];
        NSString *insertStatement = [self createInsertSQLStatmentWithDict:dict forTable:tableName];
        [self execStatementOnDataBase:insertStatement];
    };
}
- (NSString *)createInsertSQLStatmentWithDict:(NSDictionary *)dict forTable:(NSString *)tableName
{
    NSArray *keys   = [dict allKeys];
    NSArray *values = [dict allValues];
    
    NSString *keysString = [keys componentsJoinedByString:@","];
    NSString *valuesString = [values componentsJoinedByString:@","];
    
    NSString *insertString = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)",tableName,keysString,valuesString];
    return insertString;
}
- (void) execStatementOnDataBase:(NSString *)queryStatement
{
    char * err;
    int result = synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err);
    if (result != SQLITE_OK)
    {
        SMLog(@"Failed to Execute the Query %@. Error No = %d Error Message = %s",queryStatement,result,err);
    }

}
- (void) createTable:(NSString *) tableName
{
    NSString *queryStatement = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ VARCHAR PRIMARY KEY  NOT NULL)", tableName, MLOCAL_ID];
    SMLog(@"Creating New Table Query = %@",queryStatement);
    [self.dataBase createTable:queryStatement];
}

- (NSString *) getUUID
{
    return [iServiceAppDelegate GetUUID];
}
- (id) getRequiredData:(NSString *)key
{
    return nil;
}
#pragma mark - Memory Management
- (void) dealloc
{
    [super dealloc];
}
@end
