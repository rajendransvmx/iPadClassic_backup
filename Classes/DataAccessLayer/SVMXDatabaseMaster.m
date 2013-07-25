//
//  SVMXDatabaseMaster.m
//  JavascriptInterface
//
//  Created by Shravya shridhar on 4/19/13.
//  Copyright (c) 2013 Shravya shridhar. All rights reserved.
//

#import "SVMXDatabaseMaster.h"
#import "Utility.h"
#import "DARequestParser.h"
#import "DAResponse.h"
#import "SBJsonParser.h"
#import "SBJsonWriter.h"
static SVMXDatabaseMaster *sharedDatamasterObject = nil;

#define DATABASE_NAME @"sfm.sqlite"
extern void SVMXLog(NSString *format, ...);
@interface SVMXDatabaseMaster()

- (BOOL)openDatabase;
- (BOOL)closeDatabase;
- (BOOL)loadDatabaseToDocumentFolderIfNecessaryToPath:(NSString *)writablePath ;
- (NSString *)columnType:(NSString *)type;

@end

@implementation SVMXDatabaseMaster
@synthesize okMessage;
#pragma mark - Dealloc & init functions

- (void)dealloc {
    [okMessage release];
    //[self closeDatabase];
    [super dealloc];
}

+ (SVMXDatabaseMaster *)sharedDataBaseMaterObject {
    
    if (sharedDatamasterObject == nil) {
        
        sharedDatamasterObject = [[SVMXDatabaseMaster alloc] init];
    }
    
    return sharedDatamasterObject;
}

- (id)init {
    self = [super init];
    if (self != nil) {
        
        [self openDatabase];
    }
    
    return self;
}


#pragma mark - Initialization functions 
- (BOOL)openDatabase {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:DATABASE_NAME];
   
    if (![[NSFileManager defaultManager] fileExistsAtPath:writableDBPath]) {
        [self loadDatabaseToDocumentFolderIfNecessaryToPath:writableDBPath];
    }
    
    /* Open the database. The database was prepared outside the application. */
    if (sqlite3_open([writableDBPath UTF8String], &database) != SQLITE_OK) {
        /* Even though the open failed, call close to properly clean up resources.*/
        sqlite3_close(database);
        SMLog(@"DALAYER: Unable to load Database ");
        return NO;
        /* Additional error handling, as appropriate... */
    }
    SMLog(@"DALAYER: Database opened successfully ");
    return YES;
}


- (BOOL)closeDatabase {
    if (sqlite3_close(database) != SQLITE_OK) {
         SMLog(@"DALAYER: Closing Database failed");
         return NO;
    }
    SMLog(@"DALAYER: Closing Database ");
    return YES;
}


- (BOOL)loadDatabaseToDocumentFolderIfNecessaryToPath:(NSString *)writablePath {
    
   NSString *resourcePath =  [[NSBundle mainBundle] pathForResource:@"sfm" ofType:@"sqlite"];
   NSError *error = nil;
   BOOL success = [[NSFileManager defaultManager] copyItemAtPath:resourcePath toPath:writablePath error:&error];
   return success;
}

#pragma mark - Transactions functions 

- (void)startTransaction {
    
    
}
- (void)endTransaction {
    
}

- (void)setOkayMessageForErrorAlerts:(NSString *)okMesg {
    self.okMessage = okMesg;
}
#pragma mark - database access request object parser 

- (id)getDataForParams:(NSString *)parameterString andEventName:(NSString *)eventname {
    
    @try {
        
        /* Parse the params and find out the request type */
        
        NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
        NSString *requestParameterString = parameterString;
        
        [Utility showLog:[NSString stringWithFormat:@"Request: %@",requestParameterString]];
        
        NSString *sssr = [eventname stringByReplacingOccurrencesOfString:@"darequest" withString:@""];
        NSInteger functionValue = [sssr intValue];
        SBJsonParser *tempParser = [[SBJsonParser alloc] init];
        NSDictionary *jsonDictionary = [tempParser objectWithString:requestParameterString];
        [tempParser release];
        tempParser = nil;
        
        DARequest *request = [[DARequest alloc] initWithDictionary:jsonDictionary];
        
        switch (functionValue) {
            case ExecuteQuery:
                [self executeSelectQuery:request];
                break;
            case ObjectSchema:
                [self getobjectSchema:request];
                break;
            case InsertQuery:
                [self insertValuesToTableFromRequest:request];
                break;
            case UpdateQuery:
                [self updateValuesToTableFromRequest:request];
                break;
            case DeleteQuery:
                [self deleteValuesToTableFromRequest:request];
                break;
            case SOQLJson:
            {
                //            NSString *jsonRecord = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"json" ofType:@"txt"] encoding:NSUTF8StringEncoding error:NULL];
                //                request.query = jsonRecord;
                [self parseSOQLJsonStringFromDARequest:request];
            }
                break;
            case SubmitQuery:
                [self submitQuery:request];
                break;
            case DescribeObject:
                [self describeObject:request];
                break;
            default:
                break;
        }
        
        NSDictionary *requestDict = [request dictionaryRepresentation];
        
        SBJsonWriter *writer = [[[SBJsonWriter alloc] init] autorelease];
        NSString *json = [writer stringWithObject:requestDict];
        NSString *finalString = [[NSString alloc] initWithString:json];
        [Utility showLog:[NSString stringWithFormat:@"Response: %@",finalString]];
        [request release];
        request = nil;
        [aPool drain];
        aPool = nil;
        return [finalString autorelease];
    }
    @catch (NSException *exception) {
        
        NSString * errorType=[exception name];
        NSString * errorMessage=[exception description];
        
        //Modified shravya - OPDOC-CR
        NSString *okMsg = self.okMessage;
        if ([Utility isStringEmpty:okMsg]) {
            okMsg = @"Ok";
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:errorType message:errorMessage delegate:nil cancelButtonTitle:okMsg otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
        alertView = nil;
    }
    return @"";
}




#pragma mark -
#pragma mark - Data base access functions

- (id)executeSelectQuery:(DARequest *)request {
    
    @synchronized(self) {
        
        if ([request.fieldsArray count] <= 0) {
            NSArray *objectFields = [self getAllObjectFields:request.objectName fromTableName:@"SFObjectField"];
            if ([objectFields count] > 0) {
                request.fieldsArray = objectFields;
            }
        }
        
        DARequestParser *requestParser = [[[DARequestParser alloc] init] autorelease];
       
        NSString *finalQuery =  [requestParser selectSqliteQueryRepresentationOfDARequest:request];
        
        [Utility showLog:finalQuery];
        
       
       
        sqlite3_stmt *selectStatement = nil;
        if (synchronized_sqlite3_prepare_v2(database, [finalQuery UTF8String], -1, &selectStatement, NULL) != SQLITE_OK) {
            [Utility showLog:@"Prepare statement failed in testFunction"];
            
            DAResponse *responseObject = [[DAResponse alloc] init];
            responseObject.statusCode = [NSString stringWithFormat:@"%d",DAL_DATABASE_ERROR];
            request.responseObject = responseObject;
            return [responseObject autorelease];
        }
        
        
        NSMutableArray *objectsArray = [[NSMutableArray alloc] init];
        DAResponse *responseObject = [[DAResponse alloc] init];
        
        while (sqlite3_step(selectStatement) == SQLITE_ROW) {
            
            NSMutableDictionary *finalDictionary = [[NSMutableDictionary alloc] init];
            
            for (int counter = 0; counter < [request.fieldsArray count]; counter++) {
                
                NSDictionary *fieldDict = [request.fieldsArray objectAtIndex:counter];
                
                NSString *fieldName = [fieldDict objectForKey:kDAFieldName];
                NSString *fieldType = [fieldDict objectForKey:kDAFieldType];
                
            
                id newFieldValue = @"";
                
                if ([[fieldType uppercaseString] isEqualToString:@"BLOB"]) {
                    
                     NSData * data = [[NSData alloc] initWithBytes:sqlite3_column_blob(selectStatement, counter) length:sqlite3_column_bytes(selectStatement, counter)];
                    NSString *someStr = [[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] autorelease];
                    newFieldValue = someStr;
                    [data release];
                    data = nil;
                }
                else {
                    char *someChar = (char *)sqlite3_column_text(selectStatement, counter);
                    NSString *someStr = @"";
                    if(someChar != NULL || someChar != nil)
                        someStr = [NSString stringWithUTF8String:someChar];
                    
                    if (![Utility isStringEmpty:someStr]) {
                        newFieldValue =  [self getNewFieldValue:someStr basedOnType:fieldType];
                    }
                    //[Utility showLog:[NSString stringWithFormat:@"%@   %@,",fieldName,someStr]];
                }
                if(newFieldValue == nil) newFieldValue = @"";
                [finalDictionary setObject:newFieldValue forKey:fieldName];
               
                
            }
            
            [objectsArray addObject:finalDictionary];
            [finalDictionary release];
            finalDictionary = nil;
        }
        sqlite3_finalize(selectStatement);
        
        responseObject.objectName = request.objectName;
        responseObject.objectData = objectsArray;
        responseObject.statusCode = [NSString stringWithFormat:@"%d",DAL_SUCCESS];
        request.responseObject = responseObject;
        [objectsArray release];
        objectsArray = nil;
        return [responseObject autorelease];
    }
    return nil;
}


- (id)getobjectSchema:(DARequest *)request {
    @synchronized(self) {
        NSString *tableName = request.objectName;
        if (tableName != nil) {
            NSArray *objectFields = [self getAllObjectFields:tableName fromTableName:@"SFObjectField"];
            if ([objectFields count] > 0) {
               
                DAResponse *responseObject = [[DAResponse alloc] init];
                responseObject.objectName = request.objectName;
                responseObject.objectData = objectFields;
                responseObject.statusCode = [NSString stringWithFormat:@"%d",DAL_SUCCESS];
                request.responseObject = responseObject;
                return [responseObject autorelease];
            }
        }
    }
    return nil;
}

- (NSMutableArray *)getAllObjectFields:(NSString *)objectName fromTableName:(NSString *)tableName
{
    NSMutableArray * fieldsArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSString * field_api_name = @"", *fieldType = nil;
    if(objectName != nil || [objectName length ] != 0)
    {
        NSString * query = [NSString stringWithFormat:@"SELECT DISTINCT api_name , type from '%@' where object_api_name = '%@'" , tableName , objectName];
        sqlite3_stmt * stmt;
        
        if(synchronized_sqlite3_prepare_v2(database, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
        {
            while (sqlite3_step(stmt)  == SQLITE_ROW)
            {
                char * temp_process_id  = (char *)sqlite3_column_text(stmt, 0);
                
                if(temp_process_id!= nil)
                    field_api_name = [NSString stringWithUTF8String:temp_process_id];
                
                
                char * typeOfField  = (char *)sqlite3_column_text(stmt, 1);
                if(typeOfField!= nil)
                    fieldType = [NSString stringWithUTF8String:typeOfField];
               
                NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
                if (field_api_name != nil) {
                    [tempDict setObject:field_api_name forKey:kDAFieldName];
                }
                
                if (fieldType != nil) {
                    [tempDict setObject:fieldType forKey:kDAFieldType];
                }
                
                [fieldsArray addObject:tempDict];
                [tempDict release];
                tempDict = nil;
                
            }
        }
        sqlite3_finalize(stmt);
    }
    return [fieldsArray autorelease];
    
}

- (id)insertValuesToTableFromRequest:(DARequest *)request {
    @synchronized(self) {
        
        if ([request.fieldsArray count] <= 0) {
            NSArray *objectFields = [self getAllObjectFields:request.objectName fromTableName:@"SFObjectField"];
            if ([objectFields count] > 0) {
                request.fieldsArray = objectFields;
            }
        }
        
        DARequestParser *requestParser = [[[DARequestParser alloc] init] autorelease];
        
        NSString *finalQuery =  [requestParser insertSqliteQueryRepresentationOfDARequest:request];
        
        [Utility showLog:finalQuery];
        
        sqlite3_stmt *insertStatement = nil;
        if (synchronized_sqlite3_prepare_v2(database, [finalQuery UTF8String], -1, &insertStatement, NULL) != SQLITE_OK) {
            [Utility showLog:@"Prepare statement failed in testFunction"];
            
            DAResponse *responseObject = [[DAResponse alloc] init];
            responseObject.statusCode = [NSString stringWithFormat:@"%d",DAL_DATABASE_ERROR];
            request.responseObject = responseObject;
            return [responseObject autorelease];
        }
        
        
        DAResponse *responseObject = [[[DAResponse alloc] init] autorelease];
        int success = sqlite3_step(insertStatement);
        sqlite3_finalize(insertStatement);
        if (success != SQLITE_DONE ) {
            [Utility showLog:[NSString stringWithFormat:@"Step statement failed in testFunction %d",success]];
            responseObject.statusCode = [NSString stringWithFormat:@"%d",DAL_DATABASE_ERROR];
        }
        else {
             responseObject.statusCode = [NSString stringWithFormat:@"%d",DAL_SUCCESS];
        }
        request.responseObject = responseObject;
        return responseObject;
    }
}

- (id)updateValuesToTableFromRequest:(DARequest *)request {
    @synchronized(self) {
        
        DARequestParser *requestParser = [[[DARequestParser alloc] init] autorelease];
        
        NSString *finalQuery =  [requestParser updateSqliteQueryRepresentationOfDARequest:request];
        
        [Utility showLog:finalQuery];
        
        sqlite3_stmt *updateStatement = nil;
        if (synchronized_sqlite3_prepare_v2(database, [finalQuery UTF8String], -1, &updateStatement, NULL) != SQLITE_OK) {
            [Utility showLog:@"Prepare statement failed in testFunction"];
            
            DAResponse *responseObject = [[DAResponse alloc] init];
            responseObject.statusCode = [NSString stringWithFormat:@"%d",DAL_DATABASE_ERROR];
            request.responseObject = responseObject;
            return [responseObject autorelease];
        }
        
        
        DAResponse *responseObject = [[[DAResponse alloc] init] autorelease];
        int success = sqlite3_step(updateStatement);
        sqlite3_finalize(updateStatement);
        if (success != SQLITE_DONE ) {
            [Utility showLog:[NSString stringWithFormat:@"Step statement failed in testFunction %d",success]];
            responseObject.statusCode = [NSString stringWithFormat:@"%d",DAL_DATABASE_ERROR];
        }
        else {
            responseObject.statusCode = [NSString stringWithFormat:@"%d",DAL_SUCCESS];
        }
        request.responseObject = responseObject;
        return responseObject;
    }
}

- (id)deleteValuesToTableFromRequest:(DARequest *)request {
    @synchronized(self) {
        
        DARequestParser *requestParser = [[[DARequestParser alloc] init] autorelease];
        
        NSString *finalQuery =  [requestParser deleteSqliteQueryRepresentationOfDARequest:request];
        
        [Utility showLog:finalQuery];
        
        sqlite3_stmt *updateStatement = nil;
        if (synchronized_sqlite3_prepare_v2(database, [finalQuery UTF8String], -1, &updateStatement, NULL) != SQLITE_OK) {
            [Utility showLog:@"Prepare statement failed in testFunction"];
            
            DAResponse *responseObject = [[DAResponse alloc] init];
            responseObject.statusCode = [NSString stringWithFormat:@"%d",DAL_DATABASE_ERROR];
            request.responseObject = responseObject;
            return [responseObject autorelease];
        }
        
        
        DAResponse *responseObject = [[[DAResponse alloc] init] autorelease];
        int success = sqlite3_step(updateStatement);
        sqlite3_finalize(updateStatement);
        if (success != SQLITE_DONE ) {
            [Utility showLog:[NSString stringWithFormat:@"Step statement failed in testFunction %d",success]];
            responseObject.statusCode = [NSString stringWithFormat:@"%d",DAL_DATABASE_ERROR];
        }
        else {
            responseObject.statusCode = [NSString stringWithFormat:@"%d",DAL_SUCCESS];
        }
        request.responseObject = responseObject;
        return responseObject;
    }
}


- (NSString *)executeQuery:(NSString *)fieldName andObjectName:(NSString *)objectName andCriria:(NSString *)criteria {
    NSString * queryStatement = [NSString stringWithFormat:@"SELECT %@ FROM %@ where %@",fieldName,objectName,criteria];
    sqlite3_stmt *selectStmt = nil;
    NSString *fieldValue = nil;
    NSLog(@"%@",queryStatement);
    if(synchronized_sqlite3_prepare_v2(database, [queryStatement UTF8String], -1, &selectStmt, nil) == SQLITE_OK)
    {
        while (sqlite3_step(selectStmt)  == SQLITE_ROW)
        {
            char * temp_process_id  = (char *)sqlite3_column_text(selectStmt, 0);
            
            if(temp_process_id != NULL && temp_process_id != nil )
                fieldValue = [NSString stringWithUTF8String:temp_process_id];
            
        }
    }
    sqlite3_finalize(selectStmt);
    
    return fieldValue;
}

- (id)parseSOQLJsonStringFromDARequest:(DARequest *)requestObject {
    
    DARequestParser *requestParser = [[[DARequestParser alloc] init] autorelease];
    
    SBJsonParser *tempParser = [[SBJsonParser alloc] init];
    NSDictionary *jsonDictionary = [tempParser objectWithString:requestObject.query];
    [tempParser release];
    tempParser = nil;
    
    NSDictionary *maintableDict = nil;
    
    NSMutableArray *testArray =  [NSMutableArray arrayWithArray:[jsonDictionary objectForKey:@"Metadata"]];
    
    
    if ([testArray count] > 0 && requestObject.objectName != nil) {
        
        NSDictionary *idDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"Id",@"FN",@"TEXT",@"TYP",requestObject.objectName,@"OBJ",nil];
        [testArray addObject:idDict];
        [idDict release];
        idDict = nil;
    }
    
    
    NSMutableArray *allColumnFieldArr = [[NSMutableArray alloc] init];
   
    /*Getting main record data */
    DAResponse *response = [self executeSelectQuery:requestObject];
    if ([response.objectData count] > 0) {
        for (int i =0 ; i < [response.objectData count]; i++) {
            maintableDict = [response.objectData objectAtIndex:i];
            NSMutableDictionary *finalNewDictionary = [requestParser parseJsonToSqlFunction:testArray andRecordId:@"" andRecordDictionary:maintableDict];
            if (finalNewDictionary != nil) {
                 [allColumnFieldArr addObject:finalNewDictionary];
            }
        }
    }
    /* Ends */

    DAResponse *responseObject = [[[DAResponse alloc] init] autorelease];
    responseObject.objectData = allColumnFieldArr;
    responseObject.statusCode = [NSString stringWithFormat:@"%d",DAL_SUCCESS];
    requestObject.responseObject = responseObject;
    
    [allColumnFieldArr release];
    allColumnFieldArr = nil;
    return responseObject;
}

- (id)submitQuery:(DARequest *)request {
         
    @synchronized(self) {
        
        DARequestParser *requestParser = [[[DARequestParser alloc] init] autorelease];
        NSArray *fieldsArray = [requestParser parseFieldsFromQuery:request.query];
        NSString *sqlQuery = request.query;
        request.fieldsArray = fieldsArray;
        [Utility showLog:sqlQuery];
        
        sqlite3_stmt *selectStatement = nil;
        if (synchronized_sqlite3_prepare_v2(database, [sqlQuery UTF8String], -1, &selectStatement, NULL) != SQLITE_OK) {
            [Utility showLog:@"Prepare statement failed in testFunction"];
            
            DAResponse *responseObject = [[DAResponse alloc] init];
            responseObject.statusCode = [NSString stringWithFormat:@"%d",DAL_DATABASE_ERROR];
            request.responseObject = responseObject;
            return [responseObject autorelease];
        }
        DAResponse *responseObject = [[DAResponse alloc] init];
        
        NSMutableArray *objectsArray = [[NSMutableArray alloc] init];
        while (sqlite3_step(selectStatement) == SQLITE_ROW) {
            
            NSMutableDictionary *finalDictionary = [[NSMutableDictionary alloc] init];
            
            for (int counter = 0; counter < [request.fieldsArray count]; counter++) {
                
                NSDictionary *fieldDict = [request.fieldsArray objectAtIndex:counter];
                
                NSString *fieldName = [fieldDict objectForKey:kDAFieldName];
                
                //Modified Shavya - OPDOC-CR
                NSString *fieldType = nil;//[fieldDict objectForKey:kDAFieldType];
                
                id newFieldValue = @"";
                fieldType = @"TEXT";
                
                char *someChar = (char *)sqlite3_column_text(selectStatement, counter);
                NSString *someStr = @"";
                if (someChar != NULL) {
                    someStr = [NSString stringWithUTF8String:someChar];
                }
                 
                if (![Utility isStringEmpty:someStr]) {
                        newFieldValue =  [self getNewFieldValue:someStr basedOnType:fieldType];
                }
                [Utility showLog:[NSString stringWithFormat:@"%@   %@,",fieldName,someStr]];
                
                [finalDictionary setObject:newFieldValue forKey:fieldName];
           }
            
            [objectsArray addObject:finalDictionary];
            [finalDictionary release];
            finalDictionary = nil;
        }
        sqlite3_finalize(selectStatement);
        
        responseObject.objectName = request.objectName;
        responseObject.objectData = objectsArray;
        responseObject.statusCode = [NSString stringWithFormat:@"%d",DAL_SUCCESS];
        request.responseObject = responseObject;
        [objectsArray release];
        objectsArray = nil;
        return [responseObject autorelease];
    }
    return nil;
}

- (id)describeObject:(DARequest *)request {
    
    @synchronized(self) {
        
        NSString *objectName = request.objectName;
        NSMutableDictionary *tableInfo = [[NSMutableDictionary alloc] init];
        [tableInfo setObject:objectName forKey:@"name"];
        
        NSString *sqlQuery = [NSString stringWithFormat:@"Select label, label_plural from SFObject where api_name = '%@'",objectName];
        NSString *objectLabel = @"", *labelPlural = @"";
        sqlite3_stmt *selectStmt = nil;
        if(synchronized_sqlite3_prepare_v2(database, [sqlQuery UTF8String], -1, &selectStmt, nil) == SQLITE_OK)
        {
            while (sqlite3_step(selectStmt)  == SQLITE_ROW)
            {
                char * tempLabel  = (char *)sqlite3_column_text(selectStmt, 0);
                if(tempLabel != NULL && tempLabel != nil ) {
                     objectLabel = [NSString stringWithUTF8String:tempLabel];
                     objectLabel = objectLabel ? objectLabel:@"";
                    [tableInfo setObject:objectLabel forKey:@"label"];
                }
                   
                
                tempLabel = NULL;
                
                tempLabel  = (char *)sqlite3_column_text(selectStmt, 1);
                if(tempLabel != NULL && tempLabel != nil ) {
                    labelPlural = [NSString stringWithUTF8String:tempLabel];
                    labelPlural = labelPlural ? labelPlural:@"";
                    [tableInfo setObject:labelPlural forKey:@"labelPlural"];
                }
                
            }
        }
        sqlite3_finalize(selectStmt);  
        
        
        /*Getting fieldInfo*/
        NSMutableArray *fieldsArray = [[NSMutableArray alloc] init];
        sqlQuery = [NSString stringWithFormat:@"Select api_name, label ,type, reference_to, nillable, dependent_picklist, controler_field from SFObjectField where object_api_name = '%@'",objectName];
        selectStmt = nil;
        NSArray *someArray = [[NSArray alloc] initWithObjects:@"name",@"label",@"dataType",@"referenceTo",@"nillable", @"dependentPicklist", @"controlerName", nil];
        if(synchronized_sqlite3_prepare_v2(database, [sqlQuery UTF8String], -1, &selectStmt, nil) == SQLITE_OK)
        {
            while (sqlite3_step(selectStmt)  == SQLITE_ROW)
            {
                NSMutableDictionary *fieldInfo = [[NSMutableDictionary alloc] init];
                NSString *tempValue = @"";
                
                for (int counter = 0;counter < 7; counter++) {
                    tempValue = @"";
                    char * tempLabel  = (char *)sqlite3_column_text(selectStmt, counter);
                    if(tempLabel != NULL && tempLabel != nil ) {
                        tempValue = [NSString stringWithUTF8String:tempLabel];
                        tempValue = tempValue ? tempValue:@"";
                        NSString *keyName = [someArray objectAtIndex:counter];
                        if (counter == 3) {
                            [fieldInfo setObject:[NSArray arrayWithObject:tempValue] forKey:keyName];
                        }
                        else{
                            if (counter > 3 && counter < 7) {
                                if ([Utility isItTrue:tempValue]) {
                                     tempValue = @"true";
                                }
                                else {
                                    tempValue = @"false";
                                }
                            }
                            
                            [fieldInfo setObject:tempValue forKey:keyName];
                       }
                    }
                }
                [fieldInfo setObject:@"true" forKey:@"accessible"];
                [fieldInfo setObject:@"true" forKey:@"updateable"];
                [fieldsArray addObject:fieldInfo];
               
                [fieldInfo release];
                fieldInfo = nil;
                
           }
        }
        sqlite3_finalize(selectStmt);
        
        if ([fieldsArray count] > 0) {
            [tableInfo setObject:@"true" forKey:@"updateable"];
            [tableInfo setObject:fieldsArray forKey:@"fields"];
        }
      
        [fieldsArray release];
        fieldsArray = nil;
        
        [someArray release];
        someArray = nil;
    
        DAResponse *responseObject =  [[[DAResponse alloc] init] autorelease];
        responseObject.objectName = objectName;
        responseObject.objectData = [NSArray arrayWithObject:tableInfo];
        request.responseObject = responseObject;
        [tableInfo release];
        tableInfo = nil;
        return responseObject;
  }
    return nil;
}

#pragma mark - Data base utility functions
- (id)getNewFieldValue:(NSString *)fieldValue basedOnType:(NSString *)fieldType {
    
    id someObject = fieldValue;
    
    fieldType = [fieldType uppercaseString];
    NSString *newFieldType = [self columnType:fieldType];
    if ([newFieldType isEqualToString:DOUBLE]) {
        someObject = [NSNumber numberWithDouble:[fieldValue doubleValue]];
        
    }
    else if ([newFieldType isEqualToString:INTEGER]) {
        someObject = [NSNumber numberWithInt:[fieldValue intValue]];
        
    }
    
    return someObject;
}

- (NSString *)columnType:(NSString *)type
{
    if ([type isEqualToString:BOOLEAN])
        return _BOOL;
    else if ([type isEqualToString:CURRENCY] || [type isEqualToString:DOUBLE] || [type isEqualToString:PERCENT])
        return DOUBLE;
    else if ([type isEqualToString:INTEGER])
        return INTEGER;
    else if ([type isEqualToString:DATE] || [type isEqualToString:DATETIME])
        return DATETIME;
    else if ([type isEqualToString:TEXTAREA])
        return VARCHAR;
    else
        return TEXT;
}

//7609 defect - krishna //shravya
+(void) releaseTheDb{
    [sharedDatamasterObject release];
    sharedDatamasterObject = nil;
}
@end
