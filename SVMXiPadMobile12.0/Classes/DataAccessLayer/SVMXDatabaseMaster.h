//
//  SVMXDatabaseMaster.h
//  JavascriptInterface
//
//  Created by Shravya shridhar on 4/19/13.
//  Copyright (c) 2013 Shravya shridhar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "DARequest.h"

#define BOOLEAN                 @"BOOLEAN"
#define _BOOL                   @"BOOL"
#define CURRENCY                @"CURRENCY"
#define DOUBLE                  @"DOUBLE"
#define PERCENT                 @"PERCENT"
#define INTEGER                 @"INTEGER"
#define DATE                    @"DATE"
#define DATETIME                @"DATETIME"
#define TEXTAREA                @"TEXTAREA"
#define VARCHAR                 @"VARCHAR"
#define TEXT                    @"TEXT"

typedef enum {
    DAL_SUCCESS = 1,
    DAL_DATABASE_ERROR = 2,
    DAL_INVALID_PARAM = 3,
    DAL_UNKNOWN_ERROR = 4
} DAL_STATUS_CODES ;

typedef enum {
    ExecuteQuery  = 1,
    ObjectSchema = 2,
    ObjectList = 3,
    InsertQuery = 4,
    UpdateQuery = 5,
    DeleteQuery = 6,
    SOQLJson = 7,
    SubmitQuery = 8,
    DescribeObject = 9
    
} functionMapper ;

@interface SVMXDatabaseMaster : NSObject {
    
    sqlite3  *database;
}
@property (nonatomic, retain) NSString *okMessage;
+ (SVMXDatabaseMaster *)sharedDataBaseMaterObject;


- (void)setOkayMessageForErrorAlerts:(NSString *)okMesg;
- (NSMutableArray *)getAllObjectFields:(NSString *)objectName fromTableName:(NSString *)tableName;
- (id)getNewFieldValue:(NSString *)fieldValue basedOnType:(NSString *)fieldType;
- (id)getDataForParams:(NSString *)parameterString andEventName:(NSString *)eventname;
- (NSString *)executeQuery:(NSString *)fieldName andObjectName:(NSString *)objectName andCriria:(NSString *)criteria;

- (id)executeSelectQuery:(DARequest *)request;
- (id)getobjectSchema:(DARequest *)request;
- (id)insertValuesToTableFromRequest:(DARequest *)request;
- (id)updateValuesToTableFromRequest:(DARequest *)request;
- (id)deleteValuesToTableFromRequest:(DARequest *)request;
- (id)parseSOQLJsonStringFromDARequest:(DARequest *)requestObject;
- (id)submitQuery:(DARequest *)request;
- (id)describeObject:(DARequest *)request;

@end
