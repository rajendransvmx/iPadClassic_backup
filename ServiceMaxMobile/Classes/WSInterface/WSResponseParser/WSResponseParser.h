//
//  WSResponseParser.h
//  iService
//
//  Created by Siva Manne on 02/01/13.
//
//

#import <Foundation/Foundation.h>
#import "DataBaseGlobals.h"
#import "SBJsonParser.h"
void SMXLog(int level,const char *methodContext,int lineNumber,NSString *message);
@class DataBase;
@class databaseIntefaceSfm;
@interface WSResponseParser : NSObject
@property (nonatomic, assign) DataBase * dataBase;
@property (nonatomic, assign) databaseIntefaceSfm * dataBaseInterface;
+ (id) classForEventName:(NSString *)eventName eventType:(NSString *)eventType;
- (BOOL) parseResponse:(NSArray *)result;
- (void)insertRecords:(NSArray *)array intoTable:(NSString *)tableName;
- (NSString *)createInsertSQLStatmentWithDict:(NSDictionary *)dict forTable:(NSString *)tableName;
- (void) execStatementOnDataBase:(NSString *)queryStatement;
- (void) createTable:(NSString *) tableName;
- (NSString *) getUUID;
- (id) getRequiredData:(NSString *)key;
@end
