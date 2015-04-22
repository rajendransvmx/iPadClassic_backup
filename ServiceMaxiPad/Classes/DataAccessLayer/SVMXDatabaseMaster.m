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
#import "SFObjectFieldDAO.h"
#import "FactoryDAO.h"
#import "DatabaseManager.h"
#import "SQLResultSet.h"
#import "TransactionObjectModel.h"
#import "DBRequestSelect.h"
#import "ObjectNameFieldValueService.h"
#import "Base64.h"
#import "TagManager.h"
#import "SFObjectDAO.h"
#import "SFObjectFieldDAO.h"
#import "SFObjectFieldModel.h"
#import "SFObjectModel.h"

static SVMXDatabaseMaster *sharedDatamasterObject = nil;

@interface SVMXDatabaseMaster()

- (NSString *)columnType:(NSString *)type;
- (void)showLog:(NSString *)logs;
- (NSString *)extractTextFromSqliteStmt:(sqlite3_stmt *)selectStatement
                                AtIndex:(NSInteger)index;

@end

@implementation SVMXDatabaseMaster
@synthesize okMessage;
#pragma mark -  init functions

+ (SVMXDatabaseMaster *)sharedDataBaseMaterObject {
    
    if (sharedDatamasterObject == nil) {
        
        sharedDatamasterObject = [[SVMXDatabaseMaster alloc] init];
    }
    
    return sharedDatamasterObject;
}

- (id)init {
    self = [super init];
    if (self != nil) {
    //  database = [[SMXiPhone_Database sharedDataBase] databaseObject];
    }
    
    return self;
}
- (void)initialize {
   // database = [[SMXiPhone_Database sharedDataBase] databaseObject];
}


#pragma mark - Initialization functions


#pragma mark - Transactions functions 

- (void)startTransaction {
    //[[SMXiPhone_Database sharedDataBase] beginTransaction];
    
}
- (void)endTransaction {
    //[[SMXiPhone_Database sharedDataBase] endTransaction];
}

- (void)setOkayMessageForErrorAlerts:(NSString *)okMesg {
    self.okMessage = okMesg;
}

- (void)showLog:(NSString *)logs {
    SXLogDebug(@"OP_DOC:: %@",logs);
}

#pragma mark - Common functions
- (NSString *)extractTextFromSqliteStmt:(sqlite3_stmt *)selectStatement
                                AtIndex:(NSInteger)index {
    @synchronized([self class]){
//        char *_cString = (char *)synchronized_sqlite3_column_text(selectStatement,index);
//        if (_cString != NULL) {
//            NSString *tempString = [NSString stringWithUTF8String:_cString];
//            return tempString;
//        }
        return nil;
    }
}
#pragma End
#pragma mark - database access request object parser 

- (id)getDataForParams:(NSString *)parameterString andEventName:(NSString *)eventname {
    @try {
        /* Parse the params and find out the request type */
        @autoreleasepool {
            NSString *requestParameterString = parameterString;
            
            [self showLog:[NSString stringWithFormat:@"Request: %@",requestParameterString]];
            
            NSString *sssr = [eventname stringByReplacingOccurrencesOfString:@"darequest" withString:@""];
            NSInteger functionValue = [sssr intValue];
            NSDictionary *jsonDictionary = [Utility objectFromJsonString:requestParameterString];
            
            DARequest *request = [[DARequest alloc] initWithDictionary:jsonDictionary];
            
            switch (functionValue) {
                case ExecuteQuery:
                    [self executeSelectQuery:request];
                    break;
                case ObjectSchema:
                    [self getobjectSchema:request];
                    break;
//                case InsertQuery:
//                    [self insertValuesToTableFromRequest:request];
//                    break;
//                case UpdateQuery:
//                    [self updateValuesToTableFromRequest:request];
//                    break;
//                case DeleteQuery:
//                    [self deleteValuesToTableFromRequest:request];
//                    break;
                case SOQLJson:
                {
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
            
            NSString *json = [Utility jsonStringFromObject:requestDict];
            NSString *finalString = [[NSString alloc] initWithString:json];
            [self showLog:[NSString stringWithFormat:@"Response: %@",finalString]];
            return finalString;
        }
    }
    @catch (NSException *exception) {
        
        NSString * errorType=[exception name];
        NSString * errorMessage=[exception description];
        
        //Modified shravya - OPDOC-CR
        NSString *okMsg = self.okMessage;
        if ([Utility isStringEmpty:okMsg]) {
            okMsg = [[TagManager sharedInstance]tagByName:kTagAlertErrorOk];
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:errorType message:errorMessage delegate:nil cancelButtonTitle:okMsg otherButtonTitles:nil, nil];
        [alertView show];
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
        
        DARequestParser *requestParser = [[DARequestParser alloc] init];
        NSString *finalQuery =  [requestParser selectSqliteQueryRepresentationOfDARequest:request];
        //Execute query
        
        [self showLog:finalQuery];
        // [self executeSelectQueryFromDB:finalQuery];
        
            
        
        __block DAResponse *responseObject;
        @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            
            SQLResultSet * resultSet = [db executeQuery:finalQuery];
            if (resultSet == nil) {
                
                responseObject = [[DAResponse alloc] init];
                responseObject.statusCode = [NSString stringWithFormat:@"%d",DAL_DATABASE_ERROR];
                request.responseObject = responseObject;
            }
            else
            {
                NSMutableArray *objectsArray = [[NSMutableArray alloc] init];
                responseObject = [[DAResponse alloc] init];
                
                while ([resultSet next]) {
                    
                    NSMutableDictionary *finalDictionary = [[NSMutableDictionary alloc] init];
                    
                    NSDictionary *dict = [resultSet resultDictionaryWithFieldsAsString];
                    for (int counter = 0; counter < [request.fieldsArray count]; counter++) {
                        
                        NSDictionary *fieldDict = [request.fieldsArray objectAtIndex:counter];
                        
                        NSString *fieldName = [fieldDict objectForKey:kDAFieldName];
                        NSString *fieldType = [fieldDict objectForKey:kDAFieldType];
                        
                        
                        id newFieldValue = @"";
                        if ([[fieldType uppercaseString] isEqualToString:@"BLOB"]) {
                            ////
                            
                            NSData *data = [resultSet dataForColumn:fieldName];
                            NSString *someStr =   [Base64 encode:data];
                            newFieldValue = someStr;
                        }
                        else {
                            NSString *someStr = [dict objectForKey:fieldName];
                            //[self extractTextFromSqliteStmt:selectStatement AtIndex:counter];
                            if (![Utility isStringEmpty:someStr]) {
                                newFieldValue =  [self getNewFieldValue:someStr basedOnType:fieldType];
                            }
                        }
                        if(newFieldValue == nil) newFieldValue = @"";
                        [finalDictionary setObject:newFieldValue forKey:fieldName];
                    }
                    [objectsArray addObject:finalDictionary];
                }
                responseObject.objectName = request.objectName;
                responseObject.objectData = objectsArray;
                responseObject.statusCode = [NSString stringWithFormat:@"%d",DAL_SUCCESS];
                request.responseObject = responseObject;
            }

        }];
        }
        return responseObject;
    }
}

//- (id)executeSelectQuery:(DARequest *)request {
//    
//    @synchronized(self) {
//        
//        if ([request.fieldsArray count] <= 0) {
//            
//            NSArray *objectFields = [self getAllObjectFields:request.objectName fromTableName:@"SFObjectField"];
//            if ([objectFields count] > 0) {
//                request.fieldsArray = objectFields;
//            }
//        }
//        
//        DARequestParser *requestParser = [[DARequestParser alloc] init];
//        NSString *finalQuery =  [requestParser selectSqliteQueryRepresentationOfDARequest:request];
//        //Execute query
//        
//        [self showLog:finalQuery];
//        //
//        //        sqlite3_stmt *selectStatement = nil;
//        //        if (synchronized_sqlite3_prepare_v2(database, [finalQuery UTF8String], -1, &selectStatement, NULL) != SQLITE_OK) {
//        //            [self showLog:@"Prepare statement failed in testFunction"];
//        //
//        //            DAResponse *responseObject = [[DAResponse alloc] init];
//        //            responseObject.statusCode = [NSString stringWithFormat:@"%d",DAL_DATABASE_ERROR];
//        //            request.responseObject = responseObject;
//        //            return responseObject;
//        //        }
//        //
//        //
//        //        NSMutableArray *objectsArray = [[NSMutableArray alloc] init];
//        //        DAResponse *responseObject = [[DAResponse alloc] init];
//        //
//        //        while (synchronized_sqlite3_step(selectStatement) == SQLITE_ROW) {
//        //
//        //            NSMutableDictionary *finalDictionary = [[NSMutableDictionary alloc] init];
//        //
//        //            for (int counter = 0; counter < [request.fieldsArray count]; counter++) {
//        //
//        //                NSDictionary *fieldDict = [request.fieldsArray objectAtIndex:counter];
//        //
//        //                NSString *fieldName = [fieldDict objectForKey:kDAFieldName];
//        //                NSString *fieldType = [fieldDict objectForKey:kDAFieldType];
//        //
//        //
//        //                id newFieldValue = @"";
//        //                if ([[fieldType uppercaseString] isEqualToString:@"BLOB"]) {
//        //
//        //                     NSData * data = [[NSData alloc] initWithBytes:sqlite3_column_blob(selectStatement, counter) length:sqlite3_column_bytes(selectStatement, counter)];
//        //                    NSString *someStr =   [Base64 encode:data];//[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//        //                    newFieldValue = someStr;
//        //                }
//        //                else {
//        //                    NSString *someStr = [self extractTextFromSqliteStmt:selectStatement AtIndex:counter];
//        //                    if (![Utility isStringEmpty:someStr]) {
//        //                        newFieldValue =  [self getNewFieldValue:someStr basedOnType:fieldType];
//        //                    }
//        //                }
//        //                if(newFieldValue == nil) newFieldValue = @"";
//        //                [finalDictionary setObject:newFieldValue forKey:fieldName];
//        //           }
//        //            [objectsArray addObject:finalDictionary];
//        //        }
//        //        synchronized_sqlite3_finalize(selectStatement);
//        //        
//        //        responseObject.objectName = request.objectName;
//        //        responseObject.objectData = objectsArray;
//        //        responseObject.statusCode = [NSString stringWithFormat:@"%d",DAL_SUCCESS];
//        //        request.responseObject = responseObject;
//        //        
//        //        return responseObject;
//    }
//    return nil;
//}

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
                return responseObject;
            }
        }
    }
    return nil;
}
//
- (NSMutableArray *)getAllObjectFields:(NSString *)objectName fromTableName:(NSString *)tableName
{
    NSMutableArray * fieldObjectsArray = [[NSMutableArray alloc] initWithCapacity:0];
    if(objectName != nil || [objectName length ] != 0)
    {
        id <SFObjectFieldDAO> objectFieldDao =  [FactoryDAO serviceByServiceType:ServiceTypeSFObjectField];
        NSArray * fieldsArray = [objectFieldDao getSFObjectFieldsForObject:objectName];
        
        for (SFObjectFieldModel *model in fieldsArray) {
            
            NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
            if (model.fieldName != nil) {
                [tempDict setObject:model.fieldName forKey:kDAFieldName];
            }
            if (model.type!= nil) {
                [tempDict setObject:model.type forKey:kDAFieldType];
            }
            [fieldObjectsArray addObject:tempDict];
            
        }
        
//        if(synchronized_sqlite3_prepare_v2(database, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
//        {
//            while (synchronized_sqlite3_step(stmt)  == SQLITE_ROW)
//            {
//                field_api_name = [self extractTextFromSqliteStmt:stmt AtIndex:0];
//                fieldType = [self extractTextFromSqliteStmt:stmt AtIndex:1];
//                
//                NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
//                if (field_api_name != nil) {
//                    [tempDict setObject:field_api_name forKey:kDAFieldName];
//                }
//                if (fieldType != nil) {
//                    [tempDict setObject:fieldType forKey:kDAFieldType];
//                }
//                [fieldsArray addObject:tempDict];
//            }
//        }
//        synchronized_sqlite3_finalize(stmt);
    }
    return fieldObjectsArray;
    
}
//
//- (id)insertValuesToTableFromRequest:(DARequest *)request {
//    @synchronized(self) {
//        
//        if ([request.fieldsArray count] <= 0) {
//            NSArray *objectFields = [self getAllObjectFields:request.objectName fromTableName:@"SFObjectField"];
//            if ([objectFields count] > 0) {
//                request.fieldsArray = objectFields;
//            }
//        }
//        
//        DARequestParser *requestParser = [[DARequestParser alloc] init];
//        
//        NSString *finalQuery =  [requestParser insertSqliteQueryRepresentationOfDARequest:request];
//        
//        [self showLog:finalQuery];
//        
//        sqlite3_stmt *insertStatement = nil;
//        if (synchronized_sqlite3_prepare_v2(database, [finalQuery UTF8String], -1, &insertStatement, NULL) != SQLITE_OK) {
//            [self showLog:@"Prepare statement failed in testFunction"];
//            
//            DAResponse *responseObject = [[DAResponse alloc] init];
//            responseObject.statusCode = [NSString stringWithFormat:@"%d",DAL_DATABASE_ERROR];
//            request.responseObject = responseObject;
//            return responseObject;
//        }
//        
//        DAResponse *responseObject = [[DAResponse alloc] init];
//        int success = synchronized_sqlite3_step(insertStatement);
//        synchronized_sqlite3_finalize(insertStatement);
//        if (success != SQLITE_DONE ) {
//            [self showLog:[NSString stringWithFormat:@"Step statement failed in testFunction %d",success]];
//            responseObject.statusCode = [NSString stringWithFormat:@"%d",DAL_DATABASE_ERROR];
//        }
//        else {
//             responseObject.statusCode = [NSString stringWithFormat:@"%d",DAL_SUCCESS];
//        }
//        request.responseObject = responseObject;
//        return responseObject;
//    }
//}
//
//- (id)updateValuesToTableFromRequest:(DARequest *)request {
//    @synchronized(self) {
//        
//        DARequestParser *requestParser = [[DARequestParser alloc] init];
//        
//        NSString *finalQuery =  [requestParser updateSqliteQueryRepresentationOfDARequest:request];
//        
//        [self showLog:finalQuery];
//        
//        sqlite3_stmt *updateStatement = nil;
//        if (synchronized_sqlite3_prepare_v2(database, [finalQuery UTF8String], -1, &updateStatement, NULL) != SQLITE_OK) {
//            [self showLog:@"Prepare statement failed in testFunction"];
//            
//            DAResponse *responseObject = [[DAResponse alloc] init];
//            responseObject.statusCode = [NSString stringWithFormat:@"%d",DAL_DATABASE_ERROR];
//            request.responseObject = responseObject;
//            return responseObject;
//        }
//        
//        DAResponse *responseObject = [[DAResponse alloc] init];
//        int success = synchronized_sqlite3_step(updateStatement);
//        synchronized_sqlite3_finalize(updateStatement);
//        if (success != SQLITE_DONE ) {
//            [self showLog:[NSString stringWithFormat:@"Step statement failed in testFunction %d",success]];
//            responseObject.statusCode = [NSString stringWithFormat:@"%d",DAL_DATABASE_ERROR];
//        }
//        else {
//            responseObject.statusCode = [NSString stringWithFormat:@"%d",DAL_SUCCESS];
//        }
//        request.responseObject = responseObject;
//        return responseObject;
//    }
//}
//
//- (id)deleteValuesToTableFromRequest:(DARequest *)request {
//    @synchronized(self) {
//        
//        DARequestParser *requestParser = [[DARequestParser alloc] init];
//        
//        NSString *finalQuery =  [requestParser deleteSqliteQueryRepresentationOfDARequest:request];
//        
//        [self showLog:finalQuery];
//        
//        sqlite3_stmt *updateStatement = nil;
//        if (synchronized_sqlite3_prepare_v2(database, [finalQuery UTF8String], -1, &updateStatement, NULL) != SQLITE_OK) {
//            [self showLog:@"Prepare statement failed in testFunction"];
//            
//            DAResponse *responseObject = [[DAResponse alloc] init];
//            responseObject.statusCode = [NSString stringWithFormat:@"%d",DAL_DATABASE_ERROR];
//            request.responseObject = responseObject;
//            return responseObject;
//        }
//        
//        
//        DAResponse *responseObject = [[DAResponse alloc] init];
//        int success = synchronized_sqlite3_step(updateStatement);
//        synchronized_sqlite3_finalize(updateStatement);
//        if (success != SQLITE_DONE ) {
//            [self showLog:[NSString stringWithFormat:@"Step statement failed in testFunction %d",success]];
//            responseObject.statusCode = [NSString stringWithFormat:@"%d",DAL_DATABASE_ERROR];
//        }
//        else {
//            responseObject.statusCode = [NSString stringWithFormat:@"%d",DAL_SUCCESS];
//        }
//        request.responseObject = responseObject;
//        return responseObject;
//    }
//}
//
//
- (NSString *)executeQuery:(NSString *)fieldName andObjectName:(NSString *)objectName andCriria:(NSString *)criteria {
    
    NSString * queryStatement = [NSString stringWithFormat:@"SELECT %@ FROM '%@' where %@",fieldName,objectName,criteria];

    __block NSString *fieldValue = nil;
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            
            SQLResultSet * resultSet = [db executeQuery:queryStatement];
            if([resultSet next]) {
                
                fieldValue = [resultSet stringForColumnIndex:0];
            }
        }];
    }
    [self showLog:queryStatement];
//    if(synchronized_sqlite3_prepare_v2(database, [queryStatement UTF8String], -1, &selectStmt, nil) == SQLITE_OK)
//    {
//        while (synchronized_sqlite3_step(selectStmt)  == SQLITE_ROW)
//        {
//         
//            fieldValue =   [self extractTextFromSqliteStmt:selectStmt AtIndex:0];
//        }
//    }
//    synchronized_sqlite3_finalize(selectStmt);
    
    return fieldValue;
}

- (id)parseSOQLJsonStringFromDARequest:(DARequest *)requestObject {
    
    
    DARequestParser *requestParser = [[DARequestParser alloc] init];
    NSDictionary *jsonDictionary = nil;
    if ( [requestObject.query isKindOfClass:[NSString class]] && requestObject.query.length >= 4) {
        
        jsonDictionary = [Utility objectFromJsonString:requestObject.query];
    }
    else{
        jsonDictionary = @{};
    }
    
    NSDictionary *maintableDict = nil;
    
    NSArray *metaArray = [jsonDictionary objectForKey:@"Metadata"];
    if ([metaArray count] <= 0   ) {
        metaArray = @[];
    }
    NSMutableArray *testArray =  [NSMutableArray arrayWithArray:metaArray];
    
    if ([testArray count] > 0 && requestObject.objectName != nil) {
        NSDictionary *idDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"Id",@"FN",@"TEXT",@"TYP",requestObject.objectName,@"OBJ",nil];
        [testArray addObject:idDict];
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

    DAResponse *responseObject = [[DAResponse alloc] init];
    responseObject.objectData = allColumnFieldArr;
    responseObject.statusCode = [NSString stringWithFormat:@"%d",DAL_SUCCESS];
    requestObject.responseObject = responseObject;
    return responseObject;
}

- (id)submitQuery:(DARequest *)request {
         
    @synchronized(self) {
        
        DARequestParser *requestParser = [[DARequestParser alloc] init];
        NSArray *fieldsArray = [requestParser parseFieldsFromQuery:request.query];
        NSString *sqlQuery = request.query;
        request.fieldsArray = fieldsArray;
        [self showLog:sqlQuery];
        
        NSMutableArray *objectsArray = [[NSMutableArray alloc] init];
        
        NSString * queryStatement = sqlQuery;
        
        @autoreleasepool
        {
            DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
            
            [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
                
                SQLResultSet * resultSet = [db executeQuery:queryStatement];
                
                while([resultSet next])
                {
                    [objectsArray addObject:[resultSet resultDictionaryWithFieldsAsString]];
                }
            }];
        }
        [self showLog:queryStatement];
        
        DAResponse *responseObject = [[DAResponse alloc] init];
        
        responseObject.objectName = request.objectName;
        responseObject.objectData = objectsArray;
        responseObject.statusCode = [NSString stringWithFormat:@"%d",DAL_SUCCESS];
        request.responseObject = responseObject;
        return responseObject;
    }
    return nil;
}

- (id)describeObject:(DARequest *)request {
    
//    
    @synchronized(self) {
        
        NSString *objectName = request.objectName;
        NSMutableDictionary *tableInfo = [[NSMutableDictionary alloc] init];
        [tableInfo setObject:objectName forKey:@"name"];
        
        id <SFObjectDAO> objectDao =  [FactoryDAO serviceByServiceType:ServiceTypeSFObject];
        DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kobjectName operatorType:SQLOperatorEqual andFieldValue:objectName];
        NSArray *resultArray = [objectDao fetchRecordsByFields:@[klabel,@"labelPlural"] andCriteria:criteria];
        NSString *objectLabel = @"", *labelPlural = @"";
        for (SFObjectModel *sfobjectModelObject in resultArray) {
            
            objectLabel = sfobjectModelObject.label ? sfobjectModelObject.label : @"";
            labelPlural = sfobjectModelObject.labelPlural ? sfobjectModelObject.labelPlural:@"";
            
        }

        [tableInfo setObject:objectLabel forKey:@"label"];
        [tableInfo setObject:labelPlural forKey:@"labelPlural"];

        
//        NSString *sqlQuery = [NSString stringWithFormat:@"Select label, label_plural from SFObject where object_name = '%@'",objectName];
//        NSString *objectLabel = @"", *labelPlural = @"";
//        sqlite3_stmt *selectStmt = nil;
//        if(synchronized_sqlite3_prepare_v2(database, [sqlQuery UTF8String], -1, &selectStmt, nil) == SQLITE_OK)
//        {
//            while (synchronized_sqlite3_step(selectStmt)  == SQLITE_ROW)
//            {
//                objectLabel = [self extractTextFromSqliteStmt:selectStmt AtIndex:0];
//                objectLabel = objectLabel ? objectLabel:@"";
//                [tableInfo setObject:objectLabel forKey:@"label"];
//                
//                labelPlural = [self extractTextFromSqliteStmt:selectStmt AtIndex:1];
//                labelPlural = labelPlural ? labelPlural:@"";
//                [tableInfo setObject:labelPlural forKey:@"labelPlural"];
//            }
//        }
//        synchronized_sqlite3_finalize(selectStmt);
        
        
        /*Getting fieldInfo*/
        NSMutableArray *fieldsArray = [[NSMutableArray alloc] init];
        
        
        id <SFObjectFieldDAO> objectFieldDao =  [FactoryDAO serviceByServiceType:ServiceTypeSFObjectField];
        DBCriteria *objectFieldcriteria = [[DBCriteria alloc] initWithFieldName:kobjectName operatorType:SQLOperatorEqual andFieldValue:objectName];
        NSArray *resultObjFieldsArray = [objectFieldDao fetchSFObjectFieldsInfoByFields:@[@"fieldName",@"label",@"type",@"referenceTo",@"isNillable",@"dependentPicklist",@"controlerField",@"precision"] andCriteriaArray:@[objectFieldcriteria] advanceExpression:nil];
        
        for (SFObjectFieldModel *sfobjectFldModelObject in resultObjFieldsArray) {
            
            NSMutableDictionary *fieldInfo = [[NSMutableDictionary alloc] init];
            [fieldInfo setObject:sfobjectFldModelObject.fieldName forKey:@"name"];
            [fieldInfo setObject:sfobjectFldModelObject.label forKey:@"label"];
            [fieldInfo setObject:sfobjectFldModelObject.type forKey:@"dataType"];
            
            NSString *precision = [NSString stringWithFormat:@"%d",(int)sfobjectFldModelObject.precision];
            [fieldInfo setObject:precision forKey:@"precision"];
            NSString *referenceTo = sfobjectFldModelObject.referenceTo ? sfobjectFldModelObject.referenceTo : @"";
            [fieldInfo setObject:referenceTo forKey:@"referenceTo"];
            
            NSString *isNillableValue = sfobjectFldModelObject.isNillable ? @"true" : @"false";
            [fieldInfo setObject:isNillableValue forKey:@"nillable"];
            
            NSString *dependentPicklist = sfobjectFldModelObject.dependentPicklist ? sfobjectFldModelObject.dependentPicklist : @"";
            [fieldInfo setObject:dependentPicklist forKey:@"dependentPicklist"];
            
            NSString *controlerField = sfobjectFldModelObject.controlerField ? sfobjectFldModelObject.controlerField : @"";
            [fieldInfo setObject:controlerField forKey:@"controlerName"];
            
            [fieldInfo setObject:@"true" forKey:@"accessible"];
            [fieldInfo setObject:@"true" forKey:@"updateable"];
            [fieldsArray addObject:fieldInfo];

        }
        if ([fieldsArray count] > 0) {
            [tableInfo setObject:@"true" forKey:@"updateable"];
            [tableInfo setObject:fieldsArray forKey:@"fields"];
        }
        DAResponse *responseObject =  [[DAResponse alloc] init];
        responseObject.objectName = objectName;
        responseObject.objectData = [NSArray arrayWithObject:tableInfo];
        request.responseObject = responseObject;
        
        return responseObject;

        
//        sqlQuery = [NSString stringWithFormat:@"Select field_name, label ,type, reference_to, nillable, dependent_picklist, controler_field from SFObjectField where object_name = '%@'",objectName];
//
//        selectStmt = nil;
//        NSArray *someArray = [[NSArray alloc] initWithObjects:@"name",@"label",@"dataType",@"referenceTo",@"nillable", @"dependentPicklist", @"controlerName", nil];
//        if(synchronized_sqlite3_prepare_v2(database, [sqlQuery UTF8String], -1, &selectStmt, nil) == SQLITE_OK)
//        {
//            while (synchronized_sqlite3_step(selectStmt)  == SQLITE_ROW)
//            {
//                NSMutableDictionary *fieldInfo = [[NSMutableDictionary alloc] init];
//                NSString *tempValue = @"";
//                
//                for (int counter = 0;counter < 7; counter++) {
//                    tempValue = [self extractTextFromSqliteStmt:selectStmt AtIndex:counter];
//                    
//                    NSString *keyName = [someArray objectAtIndex:counter];
//                    if (counter == 3) {
//                        [fieldInfo setObject:[NSArray arrayWithObject:tempValue] forKey:keyName];
//                    }
//                    else{
//                        if (counter > 3 && counter < 7) {
//                            if ([Utility isItTrue:tempValue]) {
//                                tempValue = @"true";
//                            }
//                            else {
//                                tempValue = @"false";
//                            }
//                        }
//                        
//                        [fieldInfo setObject:tempValue forKey:keyName];
//                    }
//                }
//                [fieldInfo setObject:@"true" forKey:@"accessible"];
//                [fieldInfo setObject:@"true" forKey:@"updateable"];
//                [fieldsArray addObject:fieldInfo];
//            }
//        }
//        synchronized_sqlite3_finalize(selectStmt);
        
//        if ([fieldsArray count] > 0) {
//            [tableInfo setObject:@"true" forKey:@"updateable"];
//            [tableInfo setObject:fieldsArray forKey:@"fields"];
//        }
//        DAResponse *responseObject =  [[DAResponse alloc] init];
//        responseObject.objectName = objectName;
//        responseObject.objectData = [NSArray arrayWithObject:tableInfo];
//        request.responseObject = responseObject;
//       
//        return responseObject;
  }
    return nil;
}
//
- (NSString *)getNameValueForId:(NSString *)recordSfid {
    NSString *nameValue = @"";
    
    id service = [FactoryDAO serviceByServiceType:ServiceTypeObjectNameFieldValue];
    DBCriteria *dbcrit = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorEqual andFieldValue:recordSfid];
    NSArray *nameFieldValues = [service fetchObjectNameFieldValueByFields:@[@"value"] andCriteria:dbcrit];
    
    if(nameFieldValues.count)
    {
        ObjectNameFieldValueModel *model = nameFieldValues[0];
        nameValue = model.value;
    }
    
    
    return nameValue;
}

- (NSString*)getNameFieldForObject:(NSString*)objectName
{
    NSString *fieldName = @"";
    
    id service = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectField];
    
    DBCriteria *dbcrit = [[DBCriteria alloc] initWithFieldName:kobjectName operatorType:SQLOperatorEqual andFieldValue:objectName];
    DBCriteria *dbcrit2 = [[DBCriteria alloc] initWithFieldName:kSFObjectNameField operatorType:SQLOperatorEqual andFieldValue:kTrue];
    NSArray *fieldNames = [service fetchSFObjectFieldsInfoByFields:@[kfieldname] andCriteriaArray:@[dbcrit,dbcrit2] advanceExpression:nil];
    
    if(fieldNames.count)
    {
        SFObjectFieldModel *model = fieldNames[0];
        fieldName = model.fieldName;
    }
    return fieldName;
}
- (NSDictionary*)getFieldTypeForFieldName:(NSString *)fieldName Object:(NSString*)objectName {
    return nil;
}
//#pragma mark -
//#pragma mark 8906
//
//- (NSDictionary*)getFieldTypeForFieldName:(NSString *)fieldName Object:(NSString*)objectName {
//    NSString *queryStatement1 = [NSMutableString stringWithFormat:@"SELECT type,reference_to FROM SFObjectField where object_name = '%@' and field_name = '%@' ",objectName,fieldName];
//    sqlite3_stmt * labelstmt = nil;
//    NSString *fieldType = nil,*referenceTable = nil;
//    if (synchronized_sqlite3_prepare_v2(database, [queryStatement1 UTF8String],-1, &labelstmt, nil) == SQLITE_OK )
//    {
//        if(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW)
//        {
//            fieldType = [self extractTextFromSqliteStmt:labelstmt AtIndex:0];
//            referenceTable = [self extractTextFromSqliteStmt:labelstmt AtIndex:1];
//        }
//    }
//    synchronized_sqlite3_finalize(labelstmt);
//    if (![Utility isStringEmpty:fieldType]) {
//        NSMutableDictionary *fieldDict = [[NSMutableDictionary alloc] init];
//        [fieldDict setObject:fieldType forKey:@"type"];
//        if (![Utility isStringEmpty:referenceTable]) {
//            [fieldDict setObject:referenceTable forKey:@"object"];
//        }
//        return fieldDict;
//    }
//    return nil;
//}
//
//#pragma mark - Data base utility functions
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
    else if ([newFieldType isEqualToString:_BOOL]) {            //defect 7744 :shravya converting 1/0 to true/false [OPDOC3]

        if ([Utility isItTrue:someObject]) {
            someObject = @"true";
        }
        else{
            someObject = @"false";
        }
    }
    
    return someObject;
}
//
- (NSString *)columnType:(NSString *)type {
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

@end
