//
//  databaseIntefaceSfm.m
//  iService
//
//  Created by Pavamanaprasad Athani on 03/11/11.
//  Copyright (c) 2011 Bit Order Technologies. All rights reserved.
//

#import "databaseIntefaceSfm.h"
#import "WSIntfGlobals.h"
#import "LocalizationGlobals.h"
#import "iServiceAppDelegate.h"

@implementation databaseIntefaceSfm
-(NSString *) filePath:(NSString *)dataBaseName
{ 
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	NSString *documentsDir = [paths objectAtIndex:0];
	return [documentsDir stringByAppendingPathComponent:dataBaseName];
}


/*-(void)openDB:(NSString *)dataBaseName
{
    NSError * error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL ok =  [fileManager fileExistsAtPath:[self filePath:dataBaseName]];
    if(!ok)
    {
        NSString * appPath =[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:dataBaseName];
        ok = [fileManager copyItemAtPath:appPath toPath:[self filePath:dataBaseName] error:&error];
    }
    [fileManager release];
    if(sqlite3_open([[self filePath:dataBaseName] UTF8String], &db))
    {
        sqlite3_close(db); 
        NSAssert(0, @"Database failed to open."); 
    }
}*/

-(id)init
{
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    return self;
}

-(NSMutableDictionary *)queryProcessInfo:(NSString * )Process_id  object_name:(NSString *)object_name 
{
    NSString * sql = [NSString stringWithFormat:@"SELECT process_info FROM SFProcess where process_id = '%@'",Process_id];

    sqlite3_stmt * stmt;
    
    if(sqlite3_prepare_v2(appDelegate.db, [sql UTF8String], -1, &stmt, nil) == SQLITE_OK  )
    {
        while(sqlite3_step(stmt) == SQLITE_ROW)
        {
            NSLog(@"Hello");
           /* NSString * id_  =[NSString stringWithUTF8String:(char*)sqlite3_column_text(stmt, 1)];
            NSString * object_api_name  =[NSString stringWithUTF8String:(char*)sqlite3_column_text(stmt, 2)];
            NSString * processType  =[NSString stringWithUTF8String:(char*)sqlite3_column_text(stmt, 3)];
            NSString * processName  =[NSString stringWithUTF8String:(char*)sqlite3_column_text(stmt, 4)];
            NSString * processDescription  =[NSString stringWithUTF8String:(char*)sqlite3_column_text(stmt, 5)];*/
            NSData * data = [[NSData alloc] initWithBytes:sqlite3_column_blob(stmt, 0) length:sqlite3_column_bytes(stmt, 0)];
           
            NSString *errorStr = nil;
            
            NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString * documentsDirectoryPath = [paths objectAtIndex:0];
            NSString * filePath = [documentsDirectoryPath stringByAppendingPathComponent:@"sahana.plist"];
            
            NSPropertyListFormat * format = nil;
            
            id propertyList = [NSPropertyListSerialization propertyListFromData:data
                                                               mutabilityOption:NSPropertyListImmutable
                                                                         format:format
                                                               errorDescription:&errorStr];
            if(propertyList) 
            {
                NSLog(@"No error creating XML data.");
                [propertyList writeToFile:filePath atomically:YES];
                NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
                NSLog(@"%@",dict);
                return dict;

            }
        }
    }
    return nil;
    
}


-(NSMutableDictionary *)queryTheObjectInfoTable:(NSMutableArray *)api_names tableName:(NSString *)tableName object_name:(NSString *)objectName  
{
        
    NSMutableDictionary * dict = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];;
    for(int i = 0; i <[api_names count]; i++)
    {
        NSString * sql =[NSString stringWithFormat:@"SELECT %@ FROM '%@' WHERE %@ = '%@' and %@ ='%@' ",@"label",tableName ,@"api_name",[api_names objectAtIndex:i],@"object_api_name",objectName];
        // NSString * sql =[NSString stringWithFormat:@"SELECT * FROM %@ ",tableName];
        
        sqlite3_stmt * sql_stmt;
        
        if(sqlite3_prepare_v2(appDelegate.db, [sql UTF8String], -1, &sql_stmt, nil)== SQLITE_OK)
        {
            while(sqlite3_step(sql_stmt) == SQLITE_ROW)
            {
               char * temp = (char*)sqlite3_column_text(sql_stmt, 0);
               NSString * name = @"";
                if(temp != nil)
                {    
                    name  =[NSString stringWithUTF8String:temp]; 
                }
                [dict setObject:name forKey:[api_names objectAtIndex:i]];
            }
        }
        
        sqlite3_finalize(sql_stmt);
    }
    return dict;
}

-(BOOL)EntryCriteriaForRecordFortableName:(NSString *)tableName record_id:(NSString *) recordId  expression:(NSString *)expression
{
    NSString * expression_ = [appDelegate.databaseInterface  queryForExpression:expression];
    if([expression_ length] != 0 && expression_ != nil)
    {
        BOOL flag = FALSE;
        NSString *  query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM '%@' where %@ = '%@' and %@",tableName,@"local_id", recordId,expression_];
        sqlite3_stmt * stmt ;
        
        if(sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
        {
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                NSString * count = @"";
                char * value = (char *)sqlite3_column_text(stmt, 0);
                if(value != nil)
                {
                    count = [NSString stringWithUTF8String:value];
                }
                int count_int = [count intValue];
                if(count_int >= 1)
                    flag = TRUE;
                else
                    flag = FALSE;
            }
        }
        
        sqlite3_finalize(stmt);
        return flag;
    }
    else
    {
        return TRUE;
    }
}
-(NSMutableDictionary *)queryDataFromObjectTable:(NSMutableArray *)api_names tableName:(NSString *)tableName record_id:(NSString *) recordId  expression:(NSString *)expression
{
    
    //iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
     NSLog(@"%@",expression);
    NSString * expression_ = [appDelegate.databaseInterface  queryForExpression:expression];
    
    NSString * fieldsString =@"";
    NSString * singleField = @"";

    NSLog(@"%@",expression_);
    
    NSMutableDictionary * dict = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
   /* for(int i=0 ; i< [api_names count];i++)
    {
        NSString * sql ;
        if([expression_ length] != 0 && expression_ != nil)
            sql = [NSString stringWithFormat:@"SELECT %@ FROM %@ where %@ = '%@' and %@",[api_names objectAtIndex:i],tableName,@"local_id", recordId,expression_];
        else
            sql = [NSString stringWithFormat:@"SELECT %@ FROM %@ where %@ = '%@'",[api_names objectAtIndex:i],tableName,@"local_id", recordId];
        
        sqlite3_stmt * sql_stmt;
        
        NSLog(@"%@",sql);
        if(sqlite3_prepare_v2(appDelegate.db, [sql UTF8String], -1, &sql_stmt, nil)== SQLITE_OK)
        {
            while(sqlite3_step(sql_stmt) == SQLITE_ROW)
            {
                char * temp = (char*)sqlite3_column_text(sql_stmt, 0);
                NSString * name = @"";
                if(temp != nil)
                {    
                    name  =[NSString stringWithUTF8String:temp]; 
                }

                [dict setObject:name forKey:[api_names objectAtIndex:i]];
            }
        }
        
        sqlite3_finalize(sql_stmt);
    }*/
    
    
    for(int i=0 ;i< [api_names count];i++)
    {
        singleField = [api_names objectAtIndex:i];
        if(i != 0)
        {
            fieldsString = [fieldsString stringByAppendingString:@","];
        }
        fieldsString = [fieldsString stringByAppendingString:singleField];
    }
    
    NSString * sql ;
    if([expression_ length] != 0 && expression_ != nil)
        sql = [NSString stringWithFormat:@"SELECT %@ FROM '%@' where %@ = '%@' and %@",fieldsString,tableName,@"local_id", recordId,expression_];
    else
        sql = [NSString stringWithFormat:@"SELECT %@ FROM '%@' where %@ = '%@'",fieldsString,tableName,@"local_id", recordId];
    
    sqlite3_stmt * sql_stmt;
     NSLog(@" query header %@",sql);
    if(sqlite3_prepare_v2(appDelegate.db, [sql UTF8String], -1, &sql_stmt, nil)== SQLITE_OK)
    {
        while(sqlite3_step(sql_stmt) == SQLITE_ROW)
        {
            for(int j =0;j<[api_names count]; j++)
            {
                char * temp = (char*)sqlite3_column_text(sql_stmt, j);
                NSString * value = @"";
                if(temp != nil)
                {    
                    value  =[NSString stringWithUTF8String:temp]; 
                }
                [dict setValue:value forKey:[api_names objectAtIndex:j]];
            }
        }
    }
    
    NSLog(@" headerquery %@", dict);
    return dict;
}

-(NSMutableArray *)queryLinesInfo:(NSMutableArray *)apiNames  detailObjectName:(NSString *)detailObjectName headerObjectName:(NSString *)headerObjectName detailaliasName:(NSString *)detailsAliasName headerRecordId:(NSString *)record_id expressionId:(NSString *)expression_id parent_column_name:(NSString *)parent_column
{
    
    NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:0];

    NSString * fieldsString =@"";
    NSString * singleField = @"";
    [apiNames addObject:@"local_id"];
    NSInteger fieldsCount = [apiNames count];
    NSArray * detailkeys = [NSArray arrayWithObjects:gVALUE_FIELD_API_NAME,gVALUE_FIELD_VALUE_KEY,gVALUE_FIELD_VALUE_VALUE, nil];
    
    //iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString * parent_column_name = @"";
    
    NSString * expression_ = [appDelegate.databaseInterface  queryForExpression:expression_id];
    NSLog(@"%@",expression_);
    
    parent_column_name = parent_column;//[appDelegate.databaseInterface getParentColumnNameFormChildInfoTable:SFChildRelationShip childApiName:detailObjectName parentApiName:headerObjectName];
    
    NSString * local_record_id = record_id; //[appDelegate.databaseInterface getLocalIdFromSFId:record_id tableName:headerObjectName];
    
    for(int i=0 ;i< [apiNames count];i++)
    {
        singleField = [apiNames objectAtIndex:i];
        if(i != 0)
        {
            fieldsString = [fieldsString stringByAppendingString:@","];
        }
        fieldsString = [fieldsString stringByAppendingString:singleField];
    }
    
    
    
    //fetch the parent  column name  in child table from  CHildInfo Table   -- IMP headerObjectName
    // NSString * sql = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@ = '%@' and %@ = '%@'",fieldsString,detailObjectName,parent_column_name,local_record_id, @"SVMXC__Line_Type__c",detailsAliasName];
    NSString * sql;
    if([expression_ length ] != 0 && expression_ != nil)
        
        sql = [NSString stringWithFormat:@"SELECT %@ FROM '%@' WHERE %@ = '%@' and %@ ",fieldsString,detailObjectName,parent_column_name,local_record_id, expression_];
    else
        sql = [NSString stringWithFormat:@"SELECT %@ FROM '%@' WHERE %@ = '%@'",fieldsString,detailObjectName,parent_column_name,local_record_id];
    NSLog(@"%@",sql);
    
    sqlite3_stmt * sql_stmt;
    if(sqlite3_prepare_v2(appDelegate.db, [sql UTF8String], -1, &sql_stmt, nil)== SQLITE_OK)
    {
        while(sqlite3_step(sql_stmt) == SQLITE_ROW)
        {
        
            NSMutableArray * each_detail_array = [[NSMutableArray alloc ] initWithCapacity:0];
            for(int j =0;j<fieldsCount; j++)
            {
                char * temp = (char*)sqlite3_column_text(sql_stmt, j);
                NSString * value = @"";
                if(temp != nil)
                {    
                    value  =[NSString stringWithUTF8String:temp]; 
                }
                
                
                NSString * filedDataType = [[appDelegate.databaseInterface getFieldDataType:detailObjectName filedName:[apiNames objectAtIndex:j]] lowercaseString];
                
                NSString * label = @"";
                
                if([filedDataType isEqualToString:@"picklist"])
                {
                    //query to acces the picklist values for lines 
                    NSMutableDictionary * picklistValues = [appDelegate.databaseInterface  getPicklistValuesForTheFiled:[apiNames objectAtIndex:j] tableName:SFPicklist objectName:detailObjectName];
                    NSArray * allKeys = [picklistValues allKeys];
                    for(NSString * value_dict in allKeys)
                    {
                        if([value_dict isEqualToString:value])
                        {
                            label =[picklistValues objectForKey:value];
                            break;
                        }
                    }
                }
                else if([filedDataType isEqualToString:@"reference"] || [filedDataType isEqualToString:@"REFERENCE"])
                {
                    if([value isEqualToString:@""] || value == nil || [value length] == 0 )
                    {
                        label = value;
                        
                    }
                    else
                    {
                        NSMutableArray * referenceTotableNames = [appDelegate.databaseInterface getReferenceToForField:[apiNames objectAtIndex:j] objectapiName:detailObjectName tableName:SF_REFERENCE_TO];
                        
                        /*NSString *  keyPrefix = [value  substringToIndex:3];
                        NSString * reference_to_tableName = @"";
                        
                        if([keyPrefix length ] != 0)
                             reference_to_tableName = [appDelegate.databaseInterface getTheObjectApiNameForThePrefix:keyPrefix tableName:SFOBJECT];
                        
                        for(int i=0;i < [referenceTotableNames count];i++)
                        {
                            if([reference_to_tableName length] == 0 )
                            {
                                label = value;
                                break;
                            }
                            if([reference_to_tableName isEqualToString:[referenceTotableNames objectAtIndex:i]])
                            {
                                NSString * referenceTo_Table_fieldName = [appDelegate.databaseInterface getFieldNameForReferenceTable:reference_to_tableName tableName:SFOBJECTFIELD];
                                
                                 label = [appDelegate.databaseInterface getReferenceValueFromReferenceToTable:reference_to_tableName field_name:referenceTo_Table_fieldName record_id:value];
                                if([label isEqualToString:@"" ]||[label isEqualToString:@" "] || label == nil)
                                {
                                    label = value;
                                }
                                break;
                            }
                        }*/
                        if([referenceTotableNames count ] > 0)
                        {
                            NSString * reference_to_tableName = [referenceTotableNames objectAtIndex:0];
                            
                            NSString * referenceTo_Table_fieldName = [appDelegate.databaseInterface getFieldNameForReferenceTable:reference_to_tableName tableName:SFOBJECTFIELD];
                            
                            label = [appDelegate.databaseInterface getReferenceValueFromReferenceToTable:reference_to_tableName field_name:referenceTo_Table_fieldName record_id:value];
                            
                        }
                        if([label isEqualToString:@"" ]||[label isEqualToString:@" "] || label == nil)
                        {
                            label = value;
                        }
                        
                    }
                    
                }
                else if([filedDataType isEqualToString:@"datetime"])
                {
                    NSString * date = value;
                    date = [date stringByDeletingPathExtension];
                    label = date;
                    value = date;
                }
                else if([filedDataType isEqualToString:@"date"])
                {
                    NSString * date = value;
                    date = [date stringByDeletingPathExtension];
                    label = date;
                    value = date;
                }
                else if([filedDataType isEqualToString:@"multipicklist"])
                {
                    NSArray * valuearray = [value componentsSeparatedByString:@";"];
                    NSMutableArray * labelArray = [[NSMutableArray alloc] initWithCapacity:0];
                    //query to acces the picklist values for lines 
                    NSMutableDictionary * picklistValues = [appDelegate.databaseInterface  getPicklistValuesForTheFiled:[apiNames objectAtIndex:j] tableName:SFPicklist objectName:detailObjectName];
                    
                    NSArray * allKeys = [picklistValues allKeys];
                    for(NSString * value_dict in allKeys)
                    {
                        for(NSString * key  in valuearray)
                        {
                            if([value_dict isEqualToString:key])
                            {
                                [labelArray addObject:[picklistValues objectForKey:key]];
                                break;
                            }
                        }
                    }
                    
                     NSInteger count_ = 0;
                    for(NSString * each_label in labelArray)
                    {
                        if(count_ != 0)
                             label = [label stringByAppendingString:@";"];
                        
                        label = [label stringByAppendingString:each_label];
                        count_++;
                    }
                    
                }
                else
                {
                    label = value;
                }
                
                NSMutableArray * detailObjects = [NSMutableArray arrayWithObjects:
                                                [apiNames objectAtIndex:j],
                                                 value,
                                                  label,
                                                  nil];
                
                NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:detailObjects forKeys:detailkeys];
                
                [each_detail_array addObject:dict];
            }
            
            //adding additional flag to the values array 
            NSMutableArray * detailObjects = [NSMutableArray arrayWithObjects:
                                              gDETAIL_SAVED_RECORD,
                                              [NSNumber numberWithInt:1],
                                              [NSNumber numberWithInt:1], nil];
            
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:detailObjects forKeys:detailkeys];
            [each_detail_array addObject:dict];
            
            
            
            [array addObject:each_detail_array];
            [each_detail_array release];
        }
         
    }
    
    sqlite3_finalize(sql_stmt);
    return array;
    
}

-(NSMutableArray *) selectProcessFromDB:(NSString *)currentObject
{
    NSMutableArray * view_process = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSString * query = [NSString stringWithFormat:@"Select process_name, process_id from SFProcess  where process_type = '%@' and object_api_name = '%@' ", @"VIEWRECORD",currentObject];
    
    sqlite3_stmt * stmt;
    
    if(sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
    {
        while(sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * temp_process_name = (char*)sqlite3_column_text(stmt, 0);
            char * temp_process_id = (char*)sqlite3_column_text(stmt,1);
            
            NSString * process_name = @"";
            NSString * process_id  = @"";
            
            if( temp_process_name != nil)
            {
                 process_name = [NSString stringWithUTF8String:temp_process_name];
            }
            if(temp_process_id != nil)
            {
                process_id = [NSString stringWithUTF8String:temp_process_id];
            }

            
            NSArray * viewInfokeys = [NSArray arrayWithObjects:
                                      VIEW_OBJECTNAME,
                                      VIEW_SVMXC_Name,
                                      VIEW_SVMXC_ProcessID,
                                      nil];
            
            NSArray * viewInfoObjects = [NSArray arrayWithObjects:
                                         currentObject,
                                         process_name,
                                         process_id,
                                         nil];
            NSDictionary * dict = [NSDictionary dictionaryWithObjects:viewInfoObjects forKeys:viewInfokeys];
            [view_process addObject:dict];
        }
    }
    sqlite3_finalize(stmt);
    return view_process;
}
-(NSMutableDictionary *)getPicklistValuesForTheFiled:(NSString *)fieldname  tableName:(NSString *)tablename objectName:(NSString *)objectName;
{
    
    NSMutableDictionary * picklistValues = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSString * query = [NSString stringWithFormat:@"SELECT label , value FROM '%@' WHERE %@ = '%@'  and %@ = '%@' ",tablename,@"object_api_name",objectName,@"field_api_name",fieldname];
    
    sqlite3_stmt * stmt ;
    if(sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
    {
        while(sqlite3_step(stmt) == SQLITE_ROW)
        {
            NSString * label = @"" , * value = @"";
            char * temp_label = (char *)sqlite3_column_text(stmt, 0);
            char * temp_value = (char *)(char*)sqlite3_column_text(stmt, 1);
            if(temp_label != nil)
            {
                label = [NSString stringWithUTF8String:temp_label];
            }
            if(temp_value != nil)
            {
                value = [NSString stringWithUTF8String:temp_value];
            }
            
            [picklistValues setValue:label forKey:value];
        }
    }
    
    sqlite3_finalize(stmt);
    return picklistValues;
}

-(NSString *)getFieldDataType:(NSString *)objectName filedName:(NSString *)fieldName 
{
    NSString * datatype = @"";
    NSString * query = [NSString stringWithFormat:@"SELECT type FROM '%@' where object_api_name = '%@' and api_name = '%@'" ,SFOBJECTFIELD,objectName,fieldName];
    
    sqlite3_stmt * stmt ;
    
    if(sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
    {
        while(sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * temp_data_type =  (char*)sqlite3_column_text(stmt, 0);
            if(temp_data_type != nil)
            {
                datatype = [NSString stringWithUTF8String:temp_data_type];
            }
        }
    }

    sqlite3_finalize(stmt);
    return datatype;
}

//methods to query for Reference field

-(NSMutableArray *)getReferenceToForField:(NSString *)field_apiname  objectapiName:(NSString *)objectApiName tableName:(NSString *)tableName ;
{
    NSMutableArray * referenceToTableNames = [[NSMutableArray alloc] initWithCapacity:0];
    NSString * referencetoName = @"";
    NSString * query = [NSString stringWithFormat:@"SELECT reference_to FROM '%@' where object_api_name = '%@' and field_api_name = '%@'" ,tableName,objectApiName ,field_apiname];
    sqlite3_stmt * stmt ;
    if(sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
    {
        while(sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * temp_referenceToName = (char *)sqlite3_column_text(stmt, 0);
            if(temp_referenceToName != nil)
            {
                referencetoName = [NSString stringWithUTF8String:temp_referenceToName];
            }
            [referenceToTableNames addObject:referencetoName];
            referencetoName = @"";
        }
    }
    return referenceToTableNames;
}

-(NSString *)getTheObjectApiNameForThePrefix:(NSString *)keyPrefix  tableName:(NSString *)tableName
{
    NSString *  keyPrefixValue = @"";
    if([keyPrefix length] == 0)
    {
        return keyPrefixValue;
    }
    NSString * query = [NSString stringWithFormat:@"SELECT api_name FROM '%@' where key_prefix = '%@'",tableName,keyPrefix];
    sqlite3_stmt * stmt ;
    if(sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
    {
        while(sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * temp_keyPrefixValue = (char *)sqlite3_column_text(stmt, 0);
            if(temp_keyPrefixValue != nil)
            {
                keyPrefixValue = [NSString stringWithUTF8String:temp_keyPrefixValue];
            }
        }
    }
    return keyPrefixValue;
}

-(NSString *)getFieldNameForReferenceTable:(NSString *)referedToTableName  tableName:(NSString *)tableName
{
    NSString * fieldName = @"";
    NSString * query = [NSString stringWithFormat:@"SELECT api_name FROM '%@' where object_api_name = '%@' and name_field = 'TRUE'",tableName,referedToTableName];
    sqlite3_stmt * stmt ;
    if(sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
    {
        while(sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * temp_fieldName = (char *)sqlite3_column_text(stmt, 0);
            if(temp_fieldName != nil)
            {
                fieldName = [NSString stringWithUTF8String:temp_fieldName];
            }
        }
    }
    
    return fieldName;
    
}

-(NSString *)getReferenceValueFromReferenceToTable:(NSString *)tableName field_name:(NSString *) filed_name record_id:(NSString *)record_id
{
    NSString * fieldvalue = @"";
   // iServiceAppDelegate *appdelegate =(iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
     BOOL isTableExists = [appDelegate.databaseInterface checkForTheTableInTheDataBase:tableName];
    if(isTableExists)
    {
        NSString * query = [NSString stringWithFormat:@"SELECT %@ FROM '%@' where id = '%@'",filed_name,tableName,record_id];
        sqlite3_stmt * stmt ;
        if(sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
        {
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                char * temp_fieldvalue = (char *)sqlite3_column_text(stmt, 0);
                if(temp_fieldvalue != nil)
                {
                    fieldvalue = [NSString stringWithUTF8String:temp_fieldvalue];
                }
            }
        }
    }
    return fieldvalue;
}

-(BOOL)checkForTheTableInTheDataBase:(NSString *)tableName
{
    bool flag = FALSE;
    sqlite3_stmt *statement_Chk_table_exist;
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM sqlite_master WHERE type='table' AND name='%@'",tableName];
    if( sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement_Chk_table_exist, nil) == SQLITE_OK)
    {
        
        if (sqlite3_step(statement_Chk_table_exist) == SQLITE_ROW)
        {
            flag = TRUE;
        }
    }
    sqlite3_finalize(statement_Chk_table_exist);
    
    return flag;

}

-(NSString *) getObjectLabel:(NSString *)tableName objectApi_name:(NSString *)objectApiName;//SFObject
{
    NSString * fieldName = @"";
    NSString * query = [NSString stringWithFormat:@"SELECT label FROM '%@' where api_name = '%@' ",tableName,objectApiName];
    sqlite3_stmt * stmt ;
    if(sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
    {
        while(sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * temp_fieldName = (char *)sqlite3_column_text(stmt, 0);
            if(temp_fieldName != nil)
            {
                fieldName = [NSString stringWithUTF8String:temp_fieldName];
            }
        }
    }
    sqlite3_finalize(stmt);
    return fieldName;
}

//get the work order name like WO -000000020
-(NSString *) getObjectName: (NSString *) tablename recordId:(NSString *)recordId;
{
    NSString * fieldName = @"";
    if(recordId != nil)
    {
        NSString * query = [NSString stringWithFormat:@"SELECT Name FROM '%@' where local_id = '%@' ",tablename,recordId];
        sqlite3_stmt * stmt ;
        if(sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
        {
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                char * temp_fieldName = (char *)sqlite3_column_text(stmt, 0);
                if(temp_fieldName != nil)
                {
                    fieldName = [NSString stringWithUTF8String:temp_fieldName];
                }
            }
        }
        sqlite3_finalize(stmt);
    }
    return fieldName;

}

// Get the child parent column name in child relationship table

-(NSString *)getParentColumnNameFormChildInfoTable:(NSString *)tableName  childApiName:(NSString *)objectApiNameChild parentApiName:(NSString *)objectApiNameParent
{
    NSString * fieldName = @"";
    if(objectApiNameChild != nil && objectApiNameParent != nil)
    {
        NSString * query = [NSString stringWithFormat:@"SELECT field_api_name FROM '%@' where object_api_name_parent = '%@' and object_api_name_child = '%@' ", tableName ,objectApiNameParent,objectApiNameChild];
        sqlite3_stmt * stmt ;
        if(sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
        {
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                char * temp_fieldName = (char *)sqlite3_column_text(stmt, 0);
                if(temp_fieldName != nil)
                {
                    fieldName = [NSString stringWithUTF8String:temp_fieldName];
                }
            }
        }
        sqlite3_finalize(stmt);
    }
    
    return fieldName;
}

-(NSString *)findTheTypeofTheRecordFromRecordTypeIdTable:(NSString *)tableName record_typeId:(NSString *)record_type_id objectOrLineApiName:(NSString *)apiName
{
    
    NSString * recordType = @"";
    if(record_type_id != nil && apiName != nil)
    {
        NSString * query = [NSString stringWithFormat:@"SELECT record_type FROM '%@' where object_api_name = '%@' && record_type_id = '%@' ", tableName ,apiName,record_type_id];
        sqlite3_stmt * stmt ;
        if(sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
        {
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                char * temp_fieldName = (char *)sqlite3_column_text(stmt, 0);
                if(temp_fieldName != nil)
                {
                    recordType = [NSString stringWithUTF8String:temp_fieldName];
                }
            }
        }
        sqlite3_finalize(stmt);
        
    }
    
    return recordType;
}

-(NSMutableDictionary *)getRestorationAndResolutionTimeForWorkOrder:(NSString *)record_id  tableName:(NSString *)tableName;
{
    NSMutableDictionary * SLADict = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSString * Restoration = @"";
    NSString * Resolution = @"";
    if(record_id != nil)
    {
        NSString * query = [NSString stringWithFormat:@"SELECT SVMXC__Restoration_Customer_By__c, SVMXC__Resolution_Customer_By__c FROM '%@' where local_id = '%@'", tableName ,record_id];
        sqlite3_stmt * stmt ;
        if(sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
        {
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                char * temp_Restoration = (char *)sqlite3_column_text(stmt, 0);
                char * temp_Resolution = (char *)sqlite3_column_text(stmt, 1);
                if(temp_Restoration != nil)
                {
                    Restoration = [NSString stringWithUTF8String:temp_Restoration];
                }
                if(temp_Resolution != nil)
                {
                    Resolution = [NSString stringWithUTF8String:temp_Resolution];
                }
            }
        }
        sqlite3_finalize(stmt);
    }
    
    [SLADict setObject:Restoration forKey:RESTORATIONTIME];
    [SLADict setObject:Resolution forKey:RESOLUTIONTIME];
    
    return SLADict;
}

//method for Account history and Product History
-(NSMutableDictionary *)gettheAdditionalInfoForForaWorkOrder:(NSString *)record_id tableName:(NSString *)tablename
{
    NSString * account_Id = @"";
    NSString * topLevel_Id = @"";
    NSString * component = @"";
    
    NSMutableDictionary * additional_info = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    NSArray * keys = [NSArray arrayWithObjects:@"SVMXC__Top_Level__c",@"SVMXC__Component__c",@"SVMXC__Company__c", nil];
    if(record_id != nil)
    {
        NSString * query = [NSString stringWithFormat:@"SELECT  SVMXC__Top_Level__c,SVMXC__Component__c,SVMXC__Company__c  FROM '%@' where local_id = '%@'", tablename ,record_id];
        
        sqlite3_stmt * stmt ;
        if(sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
        {
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                char * temp_topLevel_Id = (char *)sqlite3_column_text(stmt, 0);
                char * temp_component = (char *)sqlite3_column_text(stmt, 1);
                char * temp_account_Id = (char *)sqlite3_column_text(stmt, 2);
                
                if(temp_topLevel_Id != nil)
                {
                    topLevel_Id = [NSString stringWithUTF8String:temp_topLevel_Id];
                }
                if(temp_component != nil)
                {
                    component = [NSString stringWithUTF8String:temp_component];
                }
                if(temp_account_Id != nil)
                {
                    account_Id = [NSString stringWithUTF8String:temp_account_Id];
                }
                
                if(topLevel_Id  == nil )
                {
                    topLevel_Id = @"";
                }
                if(component  == nil )
                {
                    component  = @"";
                }
                if(account_Id  == nil )
                {
                    account_Id  = @"";
                }

                [additional_info setObject:topLevel_Id forKey:@"SVMXC__Top_Level__c"];
                [additional_info setObject:component forKey:@"SVMXC__Component__c"];
                [additional_info setObject:account_Id forKey:@"SVMXC__Company__c"];
            }
        }
        sqlite3_finalize(stmt);
    }
    
    return additional_info;
    
}

-(NSMutableArray *)getAccountHistoryForanWorkOrder:(NSString *)record_id  account_id:(NSString *)account_id tableName:(NSString *)tablename 
{
    NSMutableArray * account_history = [[NSMutableArray alloc] initWithCapacity:0];
    NSArray * keys = [NSArray arrayWithObjects:@"CreatedDate",@"SVMXC__Problem_Description__c", nil];
    
    NSDate * _date = [NSDate date];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString * dateString = [NSString stringWithFormat:@"%@T00:00:00Z", [dateFormatter stringFromDate:_date]];
    
    NSString * problemDiscription = @"";
    NSString * created_by  = @"";

    if(record_id != nil && account_id != nil && dateString != nil)
    {
        NSString * query =  [NSString stringWithFormat:@"SELECT  SVMXC__Problem_Description__c, CreatedDate FROM '%@' WHERE CreatedDate <= '%@' AND SVMXC__Order_Status__c = 'Closed' AND local_id != '%@' AND SVMXC__Company__c = '%@'",tablename, dateString, record_id, account_id];
        
        sqlite3_stmt * stmt ;
        
        if(sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
        {
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                char * temp_problemDiscription = (char *)sqlite3_column_text(stmt, 0);
                char * temp_created_by = (char *)sqlite3_column_text(stmt, 1);
                if(temp_problemDiscription != nil)
                {
                    problemDiscription = [NSString stringWithUTF8String:temp_problemDiscription];
                }
                if(temp_created_by != nil)
                {
                    created_by = [NSString stringWithUTF8String:temp_created_by];
                }
                NSString * _createdBy = [created_by stringByDeletingPathExtension];
                
                if(problemDiscription  == nil )
                {
                    problemDiscription = @"";
                }
                if(_createdBy  == nil )
                {
                    _createdBy  = @"";
                }
                NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:_createdBy,problemDiscription , nil] forKeys:keys];
                [account_history addObject:dict];
                
            }
        }
        sqlite3_finalize(stmt);
    }
    
    return account_history;
}


-(NSMutableArray *)getProductHistoryForanWorkOrder:(NSString *)record_id  filedName:(NSString *)fieldName tableName:(NSString *)tablename  fieldValue:(NSString *)fieldValue
{
    NSMutableArray * product_history = [[NSMutableArray alloc] initWithCapacity:0];
   // NSArray * keys = [NSArray arrayWithObjects:@"",@"" nil];
    NSArray * keys = [NSArray arrayWithObjects:@"CreatedDate" ,@"SVMXC__Problem_Description__c",nil];
    
    NSDate * _date = [NSDate date];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString * dateString = [NSString stringWithFormat:@"%@T00:00:00Z", [dateFormatter stringFromDate:_date]];
    
    
    NSString * problemDiscription = @"";
    NSString * created_by  = @"";
    
    if(record_id != nil && fieldValue != nil && dateString != nil)
    {
        NSString * query =  [NSString stringWithFormat:@"SELECT  SVMXC__Problem_Description__c, CreatedDate FROM '%@' WHERE CreatedDate <= '%@' AND SVMXC__Order_Status__c = 'Closed' AND local_id != '%@' AND %@ = '%@'",tablename, dateString, record_id,fieldName, fieldValue];
        
        sqlite3_stmt * stmt ;
        
        if(sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
        {
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                char * temp_problemDiscription = (char *)sqlite3_column_text(stmt, 0);
                char * temp_created_by = (char *)sqlite3_column_text(stmt, 1);
                if(temp_problemDiscription != nil)
                {
                    problemDiscription = [NSString stringWithUTF8String:temp_problemDiscription];
                }
                if(temp_created_by != nil)
                {
                    created_by = [NSString stringWithUTF8String:temp_created_by];
                }
                
                NSString * _createdBy = [created_by stringByDeletingPathExtension];
                
                if(problemDiscription  == nil )
                {
                    problemDiscription = @"";
                }
                if(_createdBy  == nil )
                {
                    _createdBy  = @"";
                }
                
                NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:_createdBy,problemDiscription , nil] forKeys:keys];
                [product_history addObject:dict];

            }
        }
        sqlite3_finalize(stmt);
    }
    
    return product_history;
}

-(NSString *)getLocalIdFromSFId:(NSString *)recordId  tableName:(NSString *)tableName
{
    NSString * local_id = @"" ;
    if(tableName != nil && recordId != nil)
    {
    
        NSString * query = [NSString stringWithFormat:@"SELECT local_id FROM '%@' where id = '%@'" ,tableName,recordId];
        sqlite3_stmt * stmt ;
        
        if(sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
        {
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                //int  temp_local_id = sqlite3_column_int(stmt, 0);
                
                char * temp_local_id = (char *)sqlite3_column_text(stmt, 0);
                if(temp_local_id != nil)
                {
                    local_id = [NSString stringWithUTF8String:temp_local_id];
                }
                //local_id = temp_local_id;
            }
        }
        
        sqlite3_finalize(stmt);
    }
    
    return local_id;
}

-(NSMutableDictionary *)queryForMapWorkOrderInfo:(NSString *)record_id tableName:(NSString *)tableName;
{
    NSString * Phone = @"";
    NSString * email = @"";
    NSString * Work_orderName = @"";
    NSString * caontactName = @"";
    NSString * workOrderProblemDescription = @"";
    NSString * workOrderOrderType = @"";
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:0];

    if(record_id != nil)
    {
        
        NSString * query = [NSString stringWithFormat:@"select c.phone ,c.Email, c.Name,w.Name ,w.SVMXC__Problem_Description__c ,w.SVMXC__Order_Type__c from SVMXC__Service_Order__c  as w  inner join  Contact  as c on  w.SVMXC__Contact__c = c. id   where  w.local_id = '%@'" ,record_id];
        sqlite3_stmt * stmt ;
        
        if(sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
        {
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                //int  temp_local_id = sqlite3_column_int(stmt, 0);
                
                char * temp_Phone  = (char *)sqlite3_column_text(stmt, 0);
                
                if(temp_Phone!= nil) 
                    Phone = [NSString stringWithUTF8String:temp_Phone];
                
                char * temp_email  = (char *)sqlite3_column_text(stmt, 1);
                if(temp_email != nil) 
                    email = [NSString stringWithUTF8String:temp_email];
                
                char * temp_caontactName  = (char *)sqlite3_column_text(stmt, 2);
                if(temp_caontactName != nil)
                    caontactName = [NSString stringWithUTF8String:temp_caontactName];
                
                char * temp_Work_orderName  = (char *)sqlite3_column_text(stmt, 3);
                if(temp_Work_orderName != nil)
                    Work_orderName = [NSString stringWithUTF8String:temp_Work_orderName];
                
                char * temp_workOrderProblemDescription  = (char *)sqlite3_column_text(stmt, 4);
                if(temp_workOrderProblemDescription != nil)
                    workOrderProblemDescription = [NSString stringWithUTF8String:temp_workOrderProblemDescription];
                
                char * temp_workOrderOrderType  = (char *)sqlite3_column_text(stmt, 5);
                if(temp_workOrderOrderType != nil)
                    workOrderOrderType = [NSString stringWithUTF8String:temp_workOrderOrderType];
                
                [dict  setObject:Phone forKey:@"SVMXC__Contact__r.Phone"];
                [dict  setObject:email forKey:@"SVMXC__Contact__r.Email"];
                [dict  setObject:caontactName forKey:@"SVMXC__Contact__r.Name"];
                [dict  setObject:Work_orderName forKey:@"Name"];
                [dict  setObject:workOrderProblemDescription forKey:@"SVMXC__Problem_Description__c"];
                [dict  setObject:workOrderOrderType forKey:@"SVMXC__Order_Type__c"];
                
            }
            
        }
        
        sqlite3_finalize(stmt);
    }
    
    return dict;
}

-(NSMutableArray *)getAllTheProcesses:(NSString *)processType
{
    
    NSString * process_id = @"";
    NSString * objectApi_name = @"";
    NSString * process_name = @"";
    NSString * process_description = @"";
    
    NSArray * createInfokeys = [NSArray arrayWithObjects:
                                SVMXC_ProcessID,
                                SVMXC_OBJECT_NAME,
                                SVMXC_Name,
                                SVMXC_Description,
                                nil];
    
    NSMutableArray * processArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    if(processType != nil)
    {
        
        NSString * query = [NSString stringWithFormat:@"select process_id,object_api_name,process_name,process_description  from SFProcess   where  process_type = '%@'" ,processType];
        sqlite3_stmt * stmt ;
        
        if(sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
        {
            int ret = sqlite3_step(stmt);
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                //int  temp_local_id = sqlite3_column_int(stmt, 0);
                
                char * temp_process_id  = (char *)sqlite3_column_text(stmt, 0);
                
                if(temp_process_id!= nil) 
                    process_id = [NSString stringWithUTF8String:temp_process_id];
                
                char * temp_objectApi_name  = (char *)sqlite3_column_text(stmt, 1);
                if(temp_objectApi_name != nil) 
                    objectApi_name = [NSString stringWithUTF8String:temp_objectApi_name];
                
                char * temp_process_name  = (char *)sqlite3_column_text(stmt, 2);
                if(temp_process_name != nil)
                    process_name = [NSString stringWithUTF8String:temp_process_name];
                
                char * temp_process_description  = (char *)sqlite3_column_text(stmt, 3);
                if(temp_process_description != nil)
                    process_description = [NSString stringWithUTF8String:temp_process_description];

                
                NSMutableDictionary * dict = [NSMutableDictionary  dictionaryWithObjects:[NSArray arrayWithObjects:process_id,objectApi_name,process_name, process_description,nil] forKeys:createInfokeys];       
                [processArray addObject:dict];
            }
            
        }
        
        sqlite3_finalize(stmt);
    }
    
    return processArray;
}

-(NSMutableDictionary *)getAllObjectFields:(NSString *)objectName tableName:(NSString *)tableName
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSString * field_api_name = @"";
    if(objectName != nil || [objectName length ] != 0)
    {
        NSString * query = [NSString stringWithFormat:@"SELECT api_name from '%@' where object_api_name = '%@'" , tableName , objectName];
        sqlite3_stmt * stmt;
        if(sqlite3_prepare(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
        {
            while (sqlite3_step(stmt)  == SQLITE_ROW) 
            {
                char * temp_process_id  = (char *)sqlite3_column_text(stmt, 0);
                
                if(temp_process_id!= nil) 
                    field_api_name = [NSString stringWithUTF8String:temp_process_id];
                
                if([dict count] != 0)
                {
            
                }
                [dict setObject:@"" forKey:field_api_name];
            
            }
        }
    }
    return dict;
    
}
-(NSMutableDictionary *)getProcessComponentsForComponentType:(NSString *)componentType process_id:(NSString *)processId  layoutId:(NSString *)layoutId  objectName:(NSString *)objectName  
{
    if([componentType isEqualToString:TARGET])
    {
        layoutId = nil;
    }
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    NSString * object_mapping_id = @"";
    NSString * value_mapping_id  = @"";
    NSString * expression_id = @"";
    NSString * source_object_name = @"";
    NSString * target_object_name = @"";
    NSString * parent_column = @"";
    
    if([processId length ] != 0 ||  processId != nil)
    {
         NSString * query = @"";
        
        if(layoutId != nil || [layoutId length] != 0)
        {
            query = [NSString stringWithFormat:@"SELECT object_mapping_id ,expression_id,source_object_name,target_object_name,parent_column ,value_mapping_id  FROM '%@' WHERE process_id = '%@' AND layout_id = '%@' and component_type = '%@'",PROCESS_COMPONENT , processId , layoutId,componentType];
        }
        else
        {
            query = [NSString stringWithFormat:@"SELECT object_mapping_id ,expression_id,source_object_name,target_object_name,parent_column ,value_mapping_id FROM '%@' WHERE process_id = '%@' and component_type = '%@'",PROCESS_COMPONENT , processId ,componentType];
        }
        sqlite3_stmt * stmt ;
        if(sqlite3_prepare(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
        {
            while (sqlite3_step(stmt)  == SQLITE_ROW) 
            {
                char * temp_object_mapping_id = (char *)sqlite3_column_text(stmt, 0);
                if(temp_object_mapping_id != nil)
                {
                    object_mapping_id = [NSString stringWithUTF8String:temp_object_mapping_id];
                }
                
                char * temp_expression_id = (char *)sqlite3_column_text(stmt, 1);
                if(temp_expression_id != nil)
                {
                    expression_id = [NSString stringWithUTF8String:temp_expression_id];
                }
                
                char * temp_source_object_name = (char *)sqlite3_column_text(stmt, 2);
                if(temp_source_object_name != nil)
                {
                    source_object_name = [NSString stringWithUTF8String:temp_source_object_name];
                }
                
                char * temp_target_object_name = (char *)sqlite3_column_text(stmt, 3);
                if(temp_target_object_name != nil)
                {
                    target_object_name = [NSString stringWithUTF8String:temp_target_object_name];
                }
                
                char * temp_parent_column_name = (char *)sqlite3_column_text(stmt, 4);
                if(temp_parent_column_name != nil)
                {
                    parent_column = [NSString stringWithUTF8String:temp_parent_column_name];
                }
                
                char * temp_value_mapping_id = (char *)sqlite3_column_text(stmt, 5);
                if(temp_value_mapping_id != nil)
                {
                    value_mapping_id = [NSString stringWithUTF8String:temp_value_mapping_id];
                }
                
                [dict setObject:expression_id forKey:EXPRESSION_ID];
                [dict setObject:object_mapping_id forKey:OBJECT_MAPPING_ID];
                [dict setObject:source_object_name forKey:SOURCE_OBJECT_NAME];
                [dict setObject:target_object_name forKey:TARGET_OBJECT_NAME];
                [dict setObject:parent_column forKey:PARENT_COLUMN_NAME];
                [dict setObject:value_mapping_id forKey:VALUE_MAPPING_ID];

            }
            
            sqlite3_finalize(stmt);
        }
    }
    return dict;

}

-(NSMutableDictionary *)getValueMappingForlayoutId:(NSString *)layoutId process_id:(NSString *)processId objectName:(NSString *)objectName 
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    NSString * object_mapping_id = @"";
    NSString * expression_id = @"";
    NSString * source_object_name = @"";
    NSString * target_object_name = @"";
    NSString * parent_column = @"";
    
    if(layoutId != nil || [processId length ] != 0 || [layoutId length] != 0 || processId != nil)
    {
        NSString * query = [NSString stringWithFormat:@"SELECT object_mapping_id ,expression_id,source_object_name,target_object_name,parent_column  FROM '%@' WHERE process_id = '%@' AND layout_id = '%@' ",PROCESS_COMPONENT , processId , layoutId];
        sqlite3_stmt * stmt ;
        if(sqlite3_prepare(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
        {
            while (sqlite3_step(stmt)  == SQLITE_ROW) 
            {
                char * temp_object_mapping_id = (char *)sqlite3_column_text(stmt, 0);
                if(temp_object_mapping_id != nil)
                {
                    object_mapping_id = [NSString stringWithUTF8String:temp_object_mapping_id];
                }
                
                char * temp_expression_id = (char *)sqlite3_column_text(stmt, 1);
                if(temp_expression_id != nil)
                {
                    expression_id = [NSString stringWithUTF8String:temp_expression_id];
                }
                
                char * temp_source_object_name = (char *)sqlite3_column_text(stmt, 2);
                if(temp_source_object_name != nil)
                {
                    source_object_name = [NSString stringWithUTF8String:temp_source_object_name];
                }
                
                char * temp_target_object_name = (char *)sqlite3_column_text(stmt, 3);
                if(temp_target_object_name != nil)
                {
                    target_object_name = [NSString stringWithUTF8String:temp_target_object_name];
                }
                
                char * temp_parent_column_name = (char *)sqlite3_column_text(stmt, 4);
                if(temp_parent_column_name != nil)
                {
                    parent_column = [NSString stringWithUTF8String:temp_parent_column_name];
                }
                
                [dict setObject:expression_id forKey:EXPRESSION_ID];
                [dict setObject:object_mapping_id forKey:OBJECT_MAPPING_ID];
                [dict setObject:source_object_name forKey:SOURCE_OBJECT_NAME];
                [dict setObject:target_object_name forKey:TARGET_OBJECT_NAME];
                [dict setObject:parent_column forKey:PARENT_COLUMN_NAME];
            }
            
        }
        sqlite3_finalize(stmt);
    }
    
    return dict;
}


-(NSMutableDictionary *)getObjectMappingForMappingId:(NSMutableDictionary *)process_components mappingType:(NSString *)mapping_type
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSString * value_mapping_id = [process_components objectForKey:VALUE_MAPPING_ID];
   // NSString * source_object_name = [process_components objectForKey:SOURCE_OBJECT_NAME];
    NSString * target_object_name = [process_components objectForKey:TARGET_OBJECT_NAME];
    NSString * source_field_name = @"";
    NSString * mapping_value = @"";
    NSString * mapping_value_flag = @"";
    NSString * target_field_name = @"";
    
    
    
    //VALUEMAPPING
    if([mapping_type isEqualToString:VALUE_MAPPING])
    {
        if(value_mapping_id != nil || [value_mapping_id length] != 0 )
        {
            NSString * query = [NSString stringWithFormat:@"SELECT source_field_name, mapping_value,mapping_value_flag,target_field_name  FROM '%@' where mapping_component_type = '%@' and object_mapping_id = '%@'",OBJECT_MAPPING_COMPONENT,VALUE_MAPPING, value_mapping_id];
            sqlite3_stmt * stmt ;
            if(sqlite3_prepare(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
            {
                while (sqlite3_step(stmt)  == SQLITE_ROW) 
                {
                    source_field_name = @"";
                    mapping_value = @"";
                    mapping_value_flag = @"";
                    target_field_name = @"";

                    char * temp_source_field_name = (char *)sqlite3_column_text(stmt, 0);
                    if(temp_source_field_name != nil)
                    {
                        source_field_name = [NSString stringWithUTF8String:temp_source_field_name];
                    }
                    
                    char * temp_mapping_value = (char *)sqlite3_column_text(stmt, 1);
                    if(temp_mapping_value != nil)
                    {
                        mapping_value = [NSString stringWithUTF8String:temp_mapping_value];
                    }
                    
                    char * temp_mapping_value_flag = (char *)sqlite3_column_text(stmt, 2);
                    if(temp_mapping_value_flag != nil)
                    {
                        mapping_value_flag = [NSString stringWithUTF8String:temp_mapping_value_flag];
                    }
                    char * temp_target_field_name = (char *)sqlite3_column_text(stmt, 3);
                    if(temp_target_field_name != nil)
                    {
                        target_field_name = [NSString stringWithUTF8String:temp_target_field_name];
                    }
                        
                    if(target_field_name != nil || [target_field_name length] != 0)
                    {
                        
                         [dict setObject:mapping_value forKey:target_field_name];
                       // iServiceAppDelegate *appdelegate =(iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
                        NSString * data_type = [[appDelegate.databaseInterface getFieldDataType:target_object_name filedName:target_field_name] lowercaseString];
                        
                        NSTimeInterval secondsPerDay = 24 * 60 * 60;
                        
                        NSString * today_Date ,* tomorow_date ,* yesterday_date;
                        
                        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
                        //[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                        
                        NSDate *today = [NSDate date];;
                        
                        NSDate *tomorrow, *yesterday;
                        
                        tomorrow = [today dateByAddingTimeInterval: secondsPerDay];
                        
                        yesterday = [today dateByAddingTimeInterval: -secondsPerDay];
                        
                        
                        //for macros expantion
                        if([data_type isEqualToString:@"date"])
                        {
                            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                            
                            today_Date = [dateFormatter stringFromDate:today];
                            tomorow_date = [dateFormatter stringFromDate:tomorrow];
                            yesterday_date = [dateFormatter stringFromDate:yesterday];
                            
                            if([mapping_value isEqualToString:MACRO_TODAY])
                            {
                               [dict setObject:today_Date forKey:target_field_name];
                                
                            }
                            if([mapping_value isEqualToString:MACRO_TOMMOROW])
                            {
                                [dict setObject:tomorow_date forKey:target_field_name];

                            }
                            if([mapping_value isEqualToString:MACRO_YESTERDAY])
                            {
                                [dict setObject:yesterday_date forKey:target_field_name];
                            }
                            
                        }
                        
                        if([data_type isEqualToString:@"datetime"])
                        {
                            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                            
                            today_Date = [dateFormatter stringFromDate:today];
                            tomorow_date = [dateFormatter stringFromDate:tomorrow];
                            yesterday_date = [dateFormatter stringFromDate:yesterday];
                            
                            if([mapping_value isEqualToString:MACRO_NOW])
                            {
                                [dict setObject:today_Date forKey:target_field_name];
                            }
                            
                            if([mapping_value isEqualToString:MACRO_TODAY])
                            {
                                [dict setObject:today_Date forKey:target_field_name];
                            }
                            
                            if([mapping_value isEqualToString:MACRO_TOMMOROW])
                            {
                                [dict setObject:tomorow_date forKey:target_field_name];
                            }
                            
                            if([mapping_value isEqualToString:MACRO_YESTERDAY])
                            {
                                [dict setObject:yesterday forKey:target_field_name];
                            }
                            
                        }
                        
                        if ([mapping_value isEqualToString:MACRO_CURRENTUSER])
                        {
                             [dict setObject:appDelegate.username forKey:target_field_name];
                        }
                        if ([mapping_value isEqualToString:MACRO_RECORDOWNER])
                        {
                             [dict setObject:MACRO_RECORDOWNER forKey:target_field_name];
                        }
                    }
                    
                    
                }
            }
            
            sqlite3_finalize(stmt);
        }
    }
    
    
    return dict;
}

-(BOOL)insertdataIntoTable:(NSString *)tableName data:(NSMutableDictionary *)valuesDict
{
    BOOL success;
    NSArray * fields_array = [valuesDict allKeys];
    
    NSString * fields_string = @"";
    NSString * values_string = @"";
    int count = 0;
    for(NSString * field in fields_array)
    {
        NSString * value = [valuesDict objectForKey:field];
        if(value != nil && [value length] != 0)
        {
            //RADHA
            value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            if(count != 0)
            {
                values_string = [values_string stringByAppendingString:@","];
                fields_string = [fields_string stringByAppendingString:@","];
            }
            
            values_string = [values_string stringByAppendingFormat:@"'%@'",value];
            fields_string = [fields_string stringByAppendingFormat:@"%@",field];
            count ++;
        }
    }
    NSString * insert_statement;
    if([values_string length] != 0 && [fields_string length] != 0)
        
        insert_statement = [NSString stringWithFormat:@"INSERT INTO '%@' (%@) VALUES (%@)",tableName , fields_string , values_string];
    else
        insert_statement = [NSString stringWithFormat:@"INSERT INTO '%@' DEFAULT VALUES",tableName ];
    
    char * err;
    
    if(sqlite3_exec(appDelegate.db, [insert_statement UTF8String],NULL, NULL, &err) != SQLITE_OK)
    {
        //sqlite3_close(db);
        success = FALSE;
    }
    else
    {
        success = TRUE;
    }
    
    return success;
    
}

-(NSString *)getTheRecordIdOfnewlyInsertedRecord:(NSString *)tableName
{
    NSString * query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM '%@'",tableName];
    sqlite3_stmt * stmt ;
    NSString * count = @"";
    
    if(sqlite3_prepare(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while (sqlite3_step(stmt)  == SQLITE_ROW) 
        {
            char * value = (char *)sqlite3_column_text(stmt, 0);
            if(value != nil)
            {
                count = [NSString stringWithUTF8String:value];
            }
        }
    }
    sqlite3_finalize(stmt);
    return count;
}

//For muti add  
-(NSMutableDictionary *)getDataForMultiAdd:(NSString *)object_name searchField:(NSString *)search_field 
{
    NSMutableDictionary * muti_add_data = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSMutableArray * eachRow = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSString * query = [NSString stringWithFormat:@"SELECT Id , %@ FROM '%@'",@"Name" , object_name];
    sqlite3_stmt * stmt ;
    NSString * Id = @"";
    NSString * field_value = @"";
    
    if(sqlite3_prepare(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while (sqlite3_step(stmt)  == SQLITE_ROW) 
        {
            NSMutableArray * arr = [[NSMutableArray alloc] initWithCapacity:0];
            
            char * id_value = (char *)sqlite3_column_text(stmt, 0);
            if(id_value != nil)
            {
                Id = [NSString stringWithUTF8String:id_value];
            }
            
            char * value = (char *)sqlite3_column_text(stmt, 1);
            if(value != nil)
            {
                field_value = [NSString stringWithUTF8String:value];
            }
            
            NSMutableDictionary * dict1 = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Id",Id, nil] forKeys:[NSArray arrayWithObjects:@"key",@"value", nil]];
            
            NSMutableDictionary * dict2 = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Name",field_value, nil] forKeys:[NSArray arrayWithObjects:@"key",@"value", nil]];
            
            [arr  addObject:dict1];
            [arr  addObject:dict2];
           
            [eachRow addObject:arr];
            [arr release];
        }
    }
    sqlite3_finalize(stmt);
    [muti_add_data setObject:eachRow forKey:@"DATA"];
    
    return muti_add_data;
}


- (NSDictionary *) getLookupDataFromDBWith:(NSString *)lookupID referenceTo:(NSString *)object  searchFor:(NSString *)searchForString
{
    //lookupID = @"a0WA0000005yGL8MAM";
    NSMutableDictionary * finalDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSMutableArray * fields_array = [[NSMutableArray alloc] initWithCapacity:0];
     NSMutableArray * each_record = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray * searchable_fields = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray * lookup_object_info = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray * results_array = [[NSMutableArray alloc] initWithCapacity:0];
    //NSString * default_column_name = @"";
    
    NSArray * field_keys = [NSArray arrayWithObjects:LOOK_UP_FIELDNAME,SEARCH_OBJECT_FIELD_TYPE,LOOK_UP_SEQUENCE,LOOK_UP_FIELD_TYPE,LU_FIELD_RELATED_TO, nil];
    
    NSMutableArray *_dictKeys = [NSMutableArray arrayWithObjects:@"DATA", @"SEQUENCE", @"SVMXC__Default_Lookup_Column__c", nil];
    
    
    //query for look_up_object_info from SFNamedSearch table
    NSString * default_column = @"";
    NSString * Object_name = @"";
    NSString * isstandard = @"";
    NSString * isdefault = @"";
        
    NSString *querystring2 = [NSString stringWithFormat:@"Select default_lookup_column,object_name,is_default,is_standard from '%@' where object_name = '%@'", SFNAMEDSEARCH,object];
    NSArray * lookUp_info_object_keys = [NSArray arrayWithObjects:LOOKUP_DEFAULT_LOOK_UP_CLMN,LOOKUP_OBJECT_NAME,LOOkUP_IS_DEFAULT,LOOKUP_IS_STANDARD, nil];
    
    sqlite3_stmt * stmt_;
    if(sqlite3_prepare_v2(appDelegate.db, [querystring2 UTF8String], -1, &stmt_, nil) == SQLITE_OK  ) 
    {
        while(sqlite3_step(stmt_) == SQLITE_ROW) 
        {
            
            default_column = @"";
            Object_name    = @"";
            isstandard     = @"";
            isdefault      = @"";

            char * temp_default_column = (char *) sqlite3_column_text(stmt_, 0);
            if ( temp_default_column != nil ) 
            {
                default_column= [NSString stringWithUTF8String:temp_default_column];
            }
            char * temp_Object_name = (char *) sqlite3_column_text(stmt_, 1);
            if ( temp_Object_name != nil ) 
            {
                Object_name= [NSString stringWithUTF8String:temp_Object_name];
            }
            char * temp_isstandard = (char *) sqlite3_column_text(stmt_, 2);
            if ( temp_isstandard != nil ) 
            {
                isstandard= [NSString stringWithUTF8String:temp_isstandard];
            }
            char * temp_isdefault = (char *) sqlite3_column_text(stmt_, 3);
            if(temp_isdefault != nil)
            {
                isdefault = [NSString stringWithUTF8String:temp_isdefault];
            }
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:default_column,Object_name,isstandard,isdefault, nil] forKeys:lookUp_info_object_keys];
            [lookup_object_info addObject:dict];
        }
    }

    if(lookupID == nil || [lookupID isEqualToString:@""])
    {
        NSString * default_column_name = @"";
        
        for(NSDictionary * dict in lookup_object_info)
        {
            NSString * isdefault = [dict objectForKey:LOOKUP_IS_STANDARD];
            if([isdefault boolValue])
            {
                default_column_name = [dict objectForKey:LOOKUP_DEFAULT_LOOK_UP_CLMN];
                break;
            }
        }
        
        NSString * querystring2 = [NSString stringWithFormat:@"Select %@ , Id from '%@'", default_column_name, object];
        // NSMutableArray * _keys = [NSMutableArray arrayWithObjects:@"key", @"value", nil];
        
        sqlite3_stmt * stmt;
        
        if(sqlite3_prepare_v2(appDelegate.db, [querystring2 UTF8String], -1, &stmt, nil) == SQLITE_OK)
        {
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                NSMutableArray *subdataArray = [[NSMutableArray alloc]initWithCapacity:0];
                NSString *field1 , * field2;
                char *_field1 = (char *) sqlite3_column_text(stmt,0);
                if ( _field1 != nil ) 
                {
                    field1 = [[NSString alloc]initWithUTF8String:_field1];
                }
                else
                {
                    field1 = @"";
                }
                char *_field2 = (char *) sqlite3_column_text(stmt,1);
                if ( _field2 != nil ) 
                {
                    field2 = [[NSString alloc]initWithUTF8String:_field2];
                }
                else
                {
                    field2 = @"";
                }

                NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:default_column,field1, nil] forKeys:[NSArray   arrayWithObjects:@"key",@"value",nil]];
                NSMutableDictionary * dict1 = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Id",field2, nil] forKeys:[NSArray   arrayWithObjects:@"key",@"value",nil]];
                [subdataArray addObject:dict];
                [subdataArray addObject:dict1];
                [each_record addObject:subdataArray];
                [subdataArray release];
                
            }
            
            NSLog(@"%@", each_record);
        }
        
        NSMutableArray *sequenceArray = [[NSMutableArray alloc]initWithCapacity:0];
       
        NSMutableDictionary *sequence_dict = [NSMutableDictionary dictionaryWithObject:default_column_name forKey:@"1"];
        [sequenceArray addObject:sequence_dict];
    
        finalDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:each_record,sequenceArray,default_column_name, nil] forKeys:_dictKeys];
        NSLog(@"%@", finalDict);


    }
    else
    {
        NSString *querystring1 = [NSString stringWithFormat:@"Select field_name,search_object_field_type,sequence,field_type,field_relationship_name from '%@' where named_search = '%@'",SFNAMEDSEACHCOMPONENT, lookupID];
        NSString * field_name = @"";
        NSString * sequence   = @"";
        NSString * field_seach_type = @"";
        NSString * field_type = @"";
        NSString * field_relationShip_name = @"";
        sqlite3_stmt * stmt;
        if(sqlite3_prepare_v2(appDelegate.db, [querystring1 UTF8String], -1, &stmt, nil) == SQLITE_OK  ) 
        {
            
            while(sqlite3_step(stmt) == SQLITE_ROW) 
            {
                field_name = @"";
                sequence   = @"";
                field_seach_type = @"";
                field_type = @"";
                field_relationShip_name = @"";
                
                char * temp_field_name = (char *) sqlite3_column_text(stmt, 0);
                if ( temp_field_name != nil ) 
                {
                    field_name= [NSString stringWithUTF8String:temp_field_name];
                }
                char * temp_field_seach_type = (char *) sqlite3_column_text(stmt, 1);
                if ( temp_field_seach_type != nil ) 
                {
                    field_seach_type= [NSString stringWithUTF8String:temp_field_seach_type];
                }
                char * temp_sequence = (char *) sqlite3_column_text(stmt, 2);
                if ( temp_sequence != nil ) 
                {
                    sequence= [NSString stringWithUTF8String:temp_sequence];
                }
                char * temp_field_type = (char *) sqlite3_column_text(stmt, 3);
                if(temp_field_type != nil)
                {
                    field_type = [NSString stringWithUTF8String:temp_field_type];
                }
                char * temp_field_relation_ship_name = (char *) sqlite3_column_text(stmt, 4);
                if(temp_field_relation_ship_name != nil)
                {
                    field_relationShip_name = [NSString stringWithUTF8String:temp_field_relation_ship_name];
                }
                
               
                if([field_seach_type isEqualToString:@"Search"])
                {
                    [searchable_fields addObject:field_name];
                }
                if([field_seach_type isEqualToString:@"Result"])
                {
                    [results_array addObject:field_name];
                    
                    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:field_name, field_seach_type,sequence,field_type,field_relationShip_name,nil] forKeys:field_keys];
                    [fields_array addObject:dict];
                }
            }
        }
        
        [results_array addObject:@"Id"];
        NSLog(@"fields Array %@",fields_array);
        
        NSMutableString *result_fieldNames = [[NSMutableString alloc]initWithCapacity:0];
        
        
        /*for ( int i = 0; i < [results_array count]; i++ )
        {
            
            NSMutableString * field = [results_array objectAtIndex:i];
            for(int j= 0 ; j< [fields_array count]; j++)
            {
                NSDictionary * dict = [fields_array objectAtIndex:j];
                NSString * dict_field_name = [dict objectForKey:LOOK_UP_FIELDNAME];
                NSString * dict_field_type = [dict objectForKey:LOOK_UP_FIELD_TYPE];
                NSString * dict_related_to = [dict objectForKey:LU_FIELD_RELATED_TO];
                if([field isEqualToString:dict_field_name])
                {
                    if([dict_field_type isEqualToString:@"REFERENCE"])
                    {
                        field = [NSMutableString stringWithFormat:@"%@.Name",dict_related_to];
                    }
                }
            }
            
            if ( [field length] !=  0)
            {
                if ( i == 0 ) 
                {
                    [fieldNames appendFormat:@"%@ ", field];
                }
                else 
                {
                    [fieldNames appendFormat:@", %@", field];
                }
            }
        }*/
        
        for ( int i = 0; i < [results_array count]; i++ )
        {
            
            NSString * field = [results_array objectAtIndex:i];
                        
            if ( [field length] !=  0)
            {
                if ( i == 0 ) 
                {
                    [result_fieldNames appendFormat:@"%@ ", field];
                }
                else 
                {
                    [result_fieldNames appendFormat:@", %@", field];
                }
            }
        }
        
        
        NSMutableString * searchFieldNames  = [[NSMutableString alloc] initWithCapacity:0];
        
        NSMutableString  * newSearch_string  = [[NSMutableString alloc] initWithCapacity:0];
        [newSearch_string appendFormat:@"%%%@%%",searchForString];
       // NSString * keyword = [];
        for(int j = 0 ; j < [searchable_fields count]; j++)
        {
            NSString * search_field = [searchable_fields objectAtIndex:j];
            
            
            if([search_field length] != 0 && [newSearch_string length] != 0 && newSearch_string != nil )
            {
                if(j==0 )
                {
                    [searchFieldNames appendFormat:@" %@ LIKE '%@' ",search_field ,newSearch_string]; 
                }
                else
                {
                    [searchFieldNames appendFormat:@"  OR %@ LIKE '%@' ",search_field ,newSearch_string];
                }
            }
            
        }
    
        NSString * querystring2 = [NSString stringWithFormat:@"Select %@ from '%@'  where %@ ", result_fieldNames, object, searchFieldNames];
       // NSMutableArray * _keys = [NSMutableArray arrayWithObjects:@"key", @"value", nil];
       
        
        
        if(sqlite3_prepare_v2(appDelegate.db, [querystring2 UTF8String], -1, &stmt, nil) == SQLITE_OK)
        {
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                NSMutableArray *subdataArray = [[NSMutableArray alloc]initWithCapacity:0];
                NSString *field1;
                for(int i = 0 ; i < [results_array count]; i++)
                {
                    char *_field1 = (char *) sqlite3_column_text(stmt,i);
                    if ( _field1 != nil ) 
                    {
                        field1 = [[NSString alloc]initWithUTF8String:_field1];
                    }
                    else
                    {
                        field1 = @"";
                    }
                    
                    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[results_array objectAtIndex:i],field1, nil] forKeys:[NSArray   arrayWithObjects:@"key",@"value",nil]];
                    [subdataArray addObject:dict];
                }
                
                [each_record addObject:subdataArray];
                [subdataArray release];
                
            }
            
            NSLog(@"%@", each_record);
        }
        
        for (int i = 0; i < [each_record count] ; i++) 
        {
            NSMutableArray * array = [each_record objectAtIndex:i];
            for(int p = 0 ; p < [array count]; p++ )
            {
                NSMutableDictionary * dict = [array objectAtIndex:p];
                NSString * api_name  = [dict objectForKey:@"key"];
                
                for(int j= 0 ; j< [fields_array count]; j++)
                {
                    NSDictionary * dict_field = [fields_array objectAtIndex:j];
                    NSString * dict_field_name = [dict_field objectForKey:LOOK_UP_FIELDNAME];
                    NSString * dict_field_type = [dict_field objectForKey:LOOK_UP_FIELD_TYPE];
                    NSString * dict_related_to = [dict_field objectForKey:LU_FIELD_RELATED_TO];
                    if([api_name isEqualToString:dict_field_name])
                    {
                        if([dict_field_type isEqualToString:@"REFERENCE"])
                        {
                            
                            NSString * value = [dict objectForKey:@"value"];
                            NSString * label = @"";
                            
                            if([value length ]== 0 || value == nil)
                                continue;
                            
                            NSString * referenceTo_Table_fieldName = [appDelegate.databaseInterface getFieldNameForReferenceTable:dict_related_to 																					tableName:SFOBJECTFIELD];
                            
                            label = [appDelegate.databaseInterface getReferenceValueFromReferenceToTable:dict_related_to field_name:referenceTo_Table_fieldName 												record_id:value];
                            if([label isEqualToString:@"" ]||[label isEqualToString:@" "] || label == nil)
                            {
                                label = value;
                                [dict setObject:label forKey:@"value"];
                            }
                            else
                            {
                                [dict setObject:label forKey:@"value"];
                            }
                        }
                    }
                }
                             
            }
        }
        NSMutableArray *sequenceArray = [[NSMutableArray alloc]initWithCapacity:0];
        for(int j= 0 ; j< [fields_array count]; j++)
        {
            NSDictionary * dict = [fields_array objectAtIndex:j];
            NSString * dict_field_name = [dict objectForKey:LOOK_UP_FIELDNAME];
            NSString * dict_sequence = [dict objectForKey:LOOK_UP_SEQUENCE];
            NSMutableDictionary *sequence_dict = [NSMutableDictionary dictionaryWithObject:dict_field_name forKey:dict_sequence];
            [sequenceArray addObject:sequence_dict];
        }
        NSString * default_display_column = @"";
        for(int k = 0 ; k< [lookup_object_info count]; k++)
        {
           NSDictionary * look_up =  [lookup_object_info objectAtIndex:k];
            
           NSString * is_standard  = [look_up objectForKey:LOOKUP_IS_STANDARD];
            if([is_standard boolValue])
            {
                default_display_column = [look_up objectForKey:LOOKUP_DEFAULT_LOOK_UP_CLMN];
            }
        }

              
        finalDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:each_record, sequenceArray,default_display_column, nil] forKeys:_dictKeys];
        NSLog(@"%@", finalDict);


    }
    
    return finalDict;
}

/*- (NSDictionary *) getLookupDataFromDBWith:(NSString *)lookupID referenceTo:(NSString *)object 
{
    
    NSMutableArray *fieldArray   = [[[NSMutableArray alloc]initWithCapacity:0]autorelease];
    NSMutableArray *dataArray  = [[[NSMutableArray alloc]initWithCapacity:0]autorelease];
    NSMutableArray *Array = [[[NSMutableArray alloc]initWithCapacity:0]autorelease]; 
    NSMutableArray *_dictKeys = [NSMutableArray arrayWithObjects:@"DATA", @"SEQUENCE", @"SVMXC__Default_Lookup_Column__c", nil];
    
    
    NSString *querystring1 = [NSString stringWithFormat:@"Select SVMXC_Field_Name_c from Config_data_table where Id = '%@'", lookupID];
    sqlite3_stmt * stmt;
    if(sqlite3_prepare_v2(appDelegate.db, [querystring1 UTF8String], -1, &stmt, nil) == SQLITE_OK  ) 
    {
        while(sqlite3_step(stmt) == SQLITE_ROW) 
        {
            char *field1 = (char *) sqlite3_column_text(stmt, 0);
            if ( field1 != nil ) 
            {
                NSString * field1Str = [[NSString alloc] initWithUTF8String:field1];  
                [fieldArray addObject:field1Str];
                [field1Str release];
            }
         }
     }
    NSLog(@"%@", fieldArray);
    NSMutableString *fieldNames = [[NSMutableString alloc]initWithCapacity:0];
    for ( int i = 0; i < [fieldArray count]; i++ )
    {
        if ( [[fieldArray objectAtIndex:i]length] !=  0)
        {
            if ( i == 0 ) 
            {
                [fieldNames appendFormat:@"%@ ", [fieldArray objectAtIndex:i]];
            }
            else {
                [fieldNames appendFormat:@", %@", [fieldArray objectAtIndex:i]];
            }
        }
    }
    
    NSString * querystring2 = [NSString stringWithFormat:@"Select %@ from %@ ", fieldNames, object];
    NSMutableArray * _keys = [NSMutableArray arrayWithObjects:@"key", @"value", nil];
    NSMutableArray * each_record = [[NSMutableArray alloc] initWithCapacity:0];
    
    
    if(sqlite3_prepare_v2(appDelegate.db, [querystring2 UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while(sqlite3_step(stmt) == SQLITE_ROW)
        {
            NSMutableArray *subdataArray = [[NSMutableArray alloc]initWithCapacity:0];
            NSString *field1;
            for(int i = 0 ; i < [fieldArray count]; i++)
            {
                char *_field1 = (char *) sqlite3_column_text(stmt,i);
                if ( _field1 != nil ) 
                {
                    field1 = [[NSString alloc]initWithUTF8String:_field1];
                }
                else
                {
                    field1 = @"";
                }
                
                NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[fieldArray objectAtIndex:i],field1, nil] forKeys:[NSArray   arrayWithObjects:@"key",@"value",nil]];
                [subdataArray addObject:dict];
            }
            
            [each_record addObject:subdataArray];
            [subdataArray release];
            
         }
        
         NSLog(@"%@", each_record);
    }
    
   // iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    for (int i = 0; i < [each_record count] ; i++) 
    {
        
        NSMutableArray * array = [each_record objectAtIndex:i];
        
        for(int p = 0 ; p < [array count]; p++ )
        {
            NSMutableDictionary * dict = [array objectAtIndex:p];
            NSString * api_name  = [dict objectForKey:@"key"];
        
                
            NSString * filedDataType = [appDelegate.databaseInterface getFieldDataType:object filedName:api_name];
            if([filedDataType isEqualToString:@"reference"])
            {
                NSString * value = [dict objectForKey:@"value"];
                NSString * label = @"";
                NSMutableArray * referenceTotableNames = [appDelegate.databaseInterface getReferenceToForField:api_name objectapiName:object tableName:SF_REFERENCE_TO];
                
                if([value length ]== 0 || value == nil)
                    continue;
                    
                NSString *  keyPrefix = [value  substringToIndex:3];
                NSString * reference_to_tableName = @"";
                
                if([keyPrefix length ] != 0)
                    
                    reference_to_tableName = [appDelegate.databaseInterface getTheObjectApiNameForThePrefix:keyPrefix tableName:SFOBJECT];
                
                for(int i=0;i < [referenceTotableNames count];i++)
                {
                    if([reference_to_tableName length] == 0 )
                    {
                        label = value;
                        [dict setObject:label forKey:@"value"];
                        break;
                    }
                    if([reference_to_tableName isEqualToString:[referenceTotableNames objectAtIndex:i]])
                    {
                        NSString * referenceTo_Table_fieldName = [appDelegate.databaseInterface getFieldNameForReferenceTable:reference_to_tableName 																					tableName:SFOBJECTFIELD];
                        
                        label = [appDelegate.databaseInterface getReferenceValueFromReferenceToTable:reference_to_tableName field_name:referenceTo_Table_fieldName 												record_id:value];
                        if([label isEqualToString:@"" ]||[label isEqualToString:@" "] || label == nil)
                        {
                            label = value;
                            [dict setObject:label forKey:@"value"];
                        }
                        else
                        {
                            [dict setObject:label forKey:@"value"];
                        }
                        break;
                    }
                }
                
              }

            }
        }
    
    
    NSString *queryString3 = [NSString stringWithFormat:@"Select SVMXC_Sequence_Type__c from Config_data_table where Id = '%@'", lookupID];
    if(sqlite3_prepare_v2(appDelegate.db, [queryString3 UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while(sqlite3_step(stmt) == SQLITE_ROW)
        {
            NSString *field1;
            char *_field1 = (char *) sqlite3_column_text(stmt, 0);
            if ( _field1 != nil )
            {
                field1 = [[NSString alloc]initWithUTF8String:_field1];
            }
            else
            {
                field1 = @"";
            }
            [Array addObject:field1];
            [field1 release];
        }
    }
    
    NSMutableArray *sequenceArray = [[NSMutableArray alloc]initWithCapacity:0];
    for ( int i = 0; i < [fieldArray count]; i++ )
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[fieldArray objectAtIndex:i], nil]
                                                                       forKeys:[NSArray arrayWithObjects:[Array objectAtIndex:i], nil]];
        
        [sequenceArray addObject:dict];
         NSLog(@"%@", sequenceArray);
       
    }
    
    NSString * default_display_column = [appDelegate.databaseInterface getTheDefaultDisplayColumnForLookUpId:lookupID];
    if([default_display_column length] == 0)
    {
        default_display_column = @"Id";
    }
    NSDictionary *finalDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:each_record, sequenceArray,default_display_column, nil] forKeys:_dictKeys];
    NSLog(@"%@", finalDict);
    return  finalDict;

}*/

-(NSString *)getTheDefaultDisplayColumnForLookUpId:(NSString *)lookup_id 
{
    NSString * query = [NSString stringWithFormat:@"SELECT SVMXC_Field_Name_c FROM '%@' where Id = '%@' and default_desplay_column = '%@' ",SFCONFIG_DATA_TABLE ,lookup_id,@"true" ];
    sqlite3_stmt * stmt ;
    NSString * field_name = @"";
    
    if(sqlite3_prepare(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while (sqlite3_step(stmt)  == SQLITE_ROW) 
        {
            char * value = (char *)sqlite3_column_text(stmt, 0);
            if(value != nil)
            {
                field_name = [NSString stringWithUTF8String:value];
            }
        }
    }
    sqlite3_finalize(stmt);
    return field_name;
}

-(NSString *)queryForExpression:(NSString *)expression_id;
{
    NSString * query = [NSString stringWithFormat:@"SELECT expression FROM '%@' where expression_id = '%@'",SFEXPRESSION, expression_id];
    sqlite3_stmt * stmt ;
    NSString * expression = @"";
    
    NSString * final_expr = @"";
    //iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSLog(@"%@", query);
    
    if(sqlite3_prepare(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while (sqlite3_step(stmt)  == SQLITE_ROW) 
        {
            char * value = (char *)sqlite3_column_text(stmt, 0);
            if(value != nil)
            {
                expression = [NSString stringWithUTF8String:value];
            }
        }
    }
    sqlite3_finalize(stmt);

    final_expr = [appDelegate.databaseInterface queryForExpressionComponent:expression expression_id:expression_id];

    return final_expr;
    
}


-(NSString *) queryForExpressionComponent:(NSString *)expression expression_id:(NSString *)expression_id;
{
   /* NSString  * expression_ = @"((1 or 2) and 3) or (4 and 5)"; 
    NSArray * expression_test  = [expression_ componentsSeparatedByString:@" "];
    NSLog(@"%@",expression_test);
    
    return expression_;*/
    NSString  * expression_ = expression;
    
    NSString * modified_expr = [expression_ stringByReplacingOccurrencesOfString:@"(" withString:@"#(#"];
    modified_expr = [modified_expr stringByReplacingOccurrencesOfString:@")" withString:@"#)#"];
    modified_expr  = [modified_expr stringByReplacingOccurrencesOfString:@"and" withString:@"#and#"];
    modified_expr = [modified_expr stringByReplacingOccurrencesOfString:@"or" withString:@"#or#"];
    
    NSArray * array = [modified_expr componentsSeparatedByString:@"#"];

    NSLog(@"%@",array);
    
    NSMutableArray * components = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray * operators = [[NSMutableArray alloc] initWithCapacity:0];
    
    
    NSMutableArray * final_Comonent_array = [[NSMutableArray alloc] initWithCapacity:0];
    
    for(int i = 0 ; i<[array count]; i++)
    {
        NSString * str = [array objectAtIndex:i];
        if([str isEqualToString:@"("])
        {
            [operators addObject:str];
        }
        else if ([str isEqualToString:@")"])
        {
            [operators addObject:str];
        }
        else if([str isEqualToString:@"or"])
        {
            [operators addObject:str];
        }
        else if([str isEqualToString:@"and"])
        {
            [operators addObject:str];
        }
        else if([str length] == 0)
        {
            
        }
        else
        {
            str = [str  stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            BOOL flag = FALSE;
            
            for(int k=0 ;k< [components count]; k++)
            {
                if([[components objectAtIndex:k] isEqualToString:str])
                {
                    flag = TRUE;
                    break;
                }
            }
            if(flag)
            {
                
            }
            else
            {
                [components addObject:str];
            }
            
            
        }
        
    }
    
    
    NSArray * keys = [NSArray arrayWithObjects:@"component_lhs",@"component_rhs",@"component_operator",@"sequence", nil];
    for(int j = 0 ; j<[components count]; j++)
    {
        NSString * component_number = [components objectAtIndex:j];
        int f = [component_number intValue];
        NSString * appended_component_number = [NSString stringWithFormat:@"%d.0000",f];
    
        
        NSString * query = [NSString stringWithFormat:@"SELECT component_lhs , component_rhs , operator  FROM '%@' where expression_id = '%@'  and component_sequence_number = '%@'",SFEXPRESSION_COMPONENT, expression_id ,appended_component_number];
        
         NSLog(@"%@", query);
        NSLog(@"%@",query);
        sqlite3_stmt * stmt ;
        
        NSString * component_lhs = @"";
        
        NSString * component_rhs = @"";
        
        NSString * component_operator = @"";
        
        NSString * operator_ = @"";
        
        NSString * component_expression = @"";
        if(sqlite3_prepare(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
        {
            while (sqlite3_step(stmt)  == SQLITE_ROW) 
            {
                operator_ = @"";
                component_lhs = @"";
                component_rhs = @"";
                
                
                char * lhs = (char *)sqlite3_column_text(stmt, 0);
                if(lhs != nil)
                {
                    component_lhs = [NSString stringWithUTF8String:lhs];
                }
                
                char * rhs = (char *)sqlite3_column_text(stmt, 1);
                if(rhs != nil)
                {
                    component_rhs = [NSString stringWithUTF8String:rhs];
                }
                
                char * operator = (char *)sqlite3_column_text(stmt, 2);
                if(operator != nil)
                {
                    component_operator = [NSString stringWithUTF8String:operator];
                }
                
                if([component_rhs length] != 0 && [component_lhs length] != 0 && [component_operator length] != 0)
                {
                    
                    NSLog(@"component_operator %@",component_operator);
                    
                    if([component_operator isEqualToString:@"eq"])
                    {
                        operator_  = @"=";
                    }
                    /*else if([component_operator isEqualToString:@"Starts With"])
                    {
                        operator_ = @"";
                    }*/
                    else if([component_operator isEqualToString:@"Less or Equal To"])
                    {
                        
                    }
                    else if ([component_operator isEqualToString:@"ne"])
                    {
                        operator_  = @"!=";
                    }
                    else if ([component_operator isEqualToString:@"ge"])
                    {
                        operator_  = @">=";
                    }
                    else if ([component_operator isEqualToString:@"le"])
                    {
                        operator_  = @"<=";
                    }
                    else if([component_operator isEqualToString:@"isnotnull"])
                    {
                        operator_ = @"!=";
                        component_rhs = @"";
                    }
                    else if([component_operator isEqualToString:@"contains"])
                    {
                        operator_ = @" LIKE ";
                        NSString * temp = [NSString stringWithFormat:@"%%%@%%",component_rhs];
                        component_rhs = [temp retain];
                    }
                    else if([component_operator isEqualToString:@"notcontain"])
                    {
                        operator_ =  @" NOT LIKE ";
                        NSString * temp = [NSString stringWithFormat:@"%%%@%%",component_rhs];
                        component_rhs = [temp retain];
                    }
                    else if ([component_operator isEqualToString:@"in"])
                    {
                        operator_ = @" LIKE ";
                    }
                    else if ([component_operator isEqualToString:@"notin"])
                    {
                        operator_ = @" NOT LIKE ";
                    }
                    else if ([component_operator  isEqualToString:@"starts"])
                    {
                        operator_ = @" LIKE ";
                        NSString * temp = [NSString stringWithFormat:@"%%%@%%",component_rhs];
                        component_rhs = [temp retain];
                    }
                    NSLog(@"%@" ,operator_ );
                    
                    if([operator_ length] != 0)
                    {
                        /*component_expression = [component_expression stringByAppendingString:component_lhs];
                        component_expression = [component_expression stringByAppendingString:operator_];
                        component_expression = [component_expression stringByAppendingString:component_rhs];
                        
                        expression_ = [expression_ stringByReplacingOccurrencesOfString:component_number withString:component_expression];*/
                        if(component_rhs == nil)
                        {
                            component_rhs = @"";
                        }
                        if([component_operator isEqualToString:@"in" ] || [component_operator isEqualToString:@"notin"])
                        {
                            
                            NSArray * comp = [component_rhs componentsSeparatedByString:@","];
                            
                            int count = 0;
                            for(NSString * value in comp)
                            {
                                NSString * seq = [NSString stringWithFormat:@"%d",count];
                                NSMutableString * temp = [[NSMutableString alloc] initWithCapacity:0];
                                [temp appendString:@"%%,"];
                                [temp appendFormat:@"%@",value];
                                [temp appendString:@",%%"];
                                component_rhs = [temp retain];
                                NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:component_lhs,component_rhs,operator_ ,seq,nil] forKeys:keys];
                                NSMutableDictionary * component_dict = [NSMutableDictionary dictionaryWithObject:dict forKey:component_number];
                                [final_Comonent_array addObject:component_dict];
                                
                                [temp release];
                                count ++;
                            }
                            //component_rhs = [temp retain];
                            
                        }
                        else
                        {
                            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:component_lhs,component_rhs,operator_ ,@"",nil] forKeys:keys];
                            NSMutableDictionary * component_dict = [NSMutableDictionary dictionaryWithObject:dict forKey:component_number];
                            [final_Comonent_array addObject:component_dict];
                        }
                        
                    }
                    NSLog(@"%@",expression_);
                }
                
            }
        }
        sqlite3_finalize(stmt);
        
    }

    NSLog(@" final component array %@",final_Comonent_array);
    
    NSString * regular_expression = expression_;
    for(int k = 0 ; k<[components count]; k++)
    {
        NSString * value = [components objectAtIndex:k];
        NSString * replace_value = [NSString stringWithFormat:@"#$%@",value];// if 2 is there concatinate with #$
        regular_expression = [regular_expression stringByReplacingOccurrencesOfString:value withString:replace_value];
    }
    
    for(int p = 0 ; p < [final_Comonent_array count];p++)
    {
        NSMutableDictionary * dict = [final_Comonent_array objectAtIndex:p];
        NSArray * keys =[dict allKeys];
        
        for(int q = 0; q <[keys count]; q++)
        {
            NSString * key = [keys objectAtIndex:q];
            
            NSDictionary * values_dict = [dict objectForKey:key];
            
            NSString * lhs = [values_dict objectForKey:@"component_lhs"];
            NSString * rhs = [values_dict objectForKey:@"component_rhs"];
            NSString * operator = [values_dict objectForKey:@"component_operator"];
            NSString * sequence = [values_dict objectForKey:@"sequence"];
            
            
            NSString * component_expression = @"";
            component_expression = [component_expression stringByAppendingString:lhs];
            component_expression = [component_expression stringByAppendingString:operator];
            rhs = [NSString stringWithFormat:@"'%@'",rhs];
            component_expression = [component_expression stringByAppendingString:rhs];
            
            for(int p = 0 ; p < [final_Comonent_array count];p++)
            {
                NSMutableDictionary * dict_test = [final_Comonent_array objectAtIndex:p];
                NSArray * keys_test =[dict_test allKeys];
                
                for(int q = 0; q <[keys_test count]; q++)
                {
                    NSString * key_test = [keys_test objectAtIndex:q];
                    
                    if([key isEqualToString:key_test])
                    {
                       
                        NSDictionary * values_dict_test = [dict_test objectForKey:key];
                        NSString * lhs_ = [values_dict_test objectForKey:@"component_lhs"];
                        NSString * rhs_ = [values_dict_test objectForKey:@"component_rhs"];
                        NSString * operator_ = [values_dict_test objectForKey:@"component_operator"];
                        NSString * sequence_test = [values_dict_test objectForKey:@"sequence"];
                        int sequence_no= [sequence intValue];
                        int sequencetest_no = [sequence_test intValue];
                        if(sequence_no != sequencetest_no)
                        {
                            if([operator_ isEqualToString:@" LIKE "])
                            {
                                component_expression = [component_expression stringByAppendingString:@" OR "];
                            }
                            else
                            {
                                component_expression = [component_expression stringByAppendingString:@" AND "];
                            }
                            
                            component_expression = [component_expression stringByAppendingString:lhs_];
                            component_expression = [component_expression stringByAppendingString:operator_];
                            rhs = [NSString stringWithFormat:@"'%@'",rhs_];
                            component_expression = [component_expression stringByAppendingString:rhs_];
                        }
                    }

                }
            }
            
            //for the key concatinate #$ and replace it with the expression
            
            NSString * concatinate_key = [NSString stringWithFormat:@"#$%@",key];
            
            
            regular_expression = [regular_expression stringByReplacingOccurrencesOfString:concatinate_key withString:component_expression];
            
        }
        
    }
    
    NSLog(@"%@",regular_expression);
    return regular_expression;
}

-(BOOL)validateTheExpressionForRecordId:(NSString *)record_id objectName:(NSString *)objectName expression:(NSString *)expression
{
    BOOL flag = FALSE;
    if(record_id != nil && [record_id length] != 0 && objectName != nil && [objectName length] != 0)
    {
        NSString * query;
        if([expression length]!= 0 && expression != nil)
            query = [NSString stringWithFormat:@"SELECT COUNT(*)  FROM '%@' where local_id = '%@' and %@ ",objectName, record_id, expression];
        else
            query = [NSString stringWithFormat:@"SELECT COUNT(*)  FROM '%@' where local_id = '%@'",objectName, record_id];
        
        sqlite3_stmt * stmt ;
        
        if(sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
        {
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                NSString * count = @"";
                char * value = (char *)sqlite3_column_text(stmt, 0);
                if(value != nil)
                {
                    count = [NSString stringWithUTF8String:value];
                }
                int count_int = [count intValue];
                if(count_int >= 1)
                    flag = TRUE;
                else
                    flag = FALSE;
            }
        }
        
        sqlite3_finalize(stmt);
        return flag;
    }
   
    else
    {
        return flag;
    }
    
}

//For Action Buttons 
-(NSMutableDictionary *)getWizardInformationForObjectname : (NSString *) objectName  record_id:(NSString *)record_id
{
    NSMutableDictionary * wizard_dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    
    NSMutableArray * wizard_array = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray * wizard_ids_array = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray * wizard_buttons_array = [[NSMutableArray alloc] initWithCapacity:0]; 
    
    //iServiceAppDelegate * appdelegate =(iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString * query = [NSString stringWithFormat:@"SELECT wizard_id , expression_id , wizard_description  FROM '%@' where object_name = '%@'" ,SFWIZARD , objectName];
    
    NSString * wizard_id = @"";
    NSString * expression_id = @"";
    NSString * wizard_description = @"";
    
    NSArray * keys = [NSArray arrayWithObjects:WIZARD_ID,WIZARD_DESCRIPTION,nil];
    
    sqlite3_stmt * stmt ;
    
    if(sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
    {
        while(sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * temp_wizard_id = (char *)sqlite3_column_text(stmt, 0);
            if(temp_wizard_id != nil)
            {
                wizard_id = [NSString stringWithUTF8String:temp_wizard_id];
            }
            
            char * temp_expression_id = (char *)sqlite3_column_text(stmt, 1);
            if(temp_expression_id != nil)
            {
                expression_id = [NSString stringWithUTF8String:temp_expression_id];
            }
            
            char * temp_wizard_description = (char *)sqlite3_column_text(stmt, 2);
            if(temp_wizard_description != nil)
            {
                wizard_description = [NSString stringWithUTF8String:temp_wizard_description];
            }
            
            if([expression_id length] != 0)
            {
                
                NSString * expression = [appDelegate.databaseInterface queryForExpression:expression_id];
                BOOL flag = [appDelegate.databaseInterface validateTheExpressionForRecordId:record_id objectName:objectName expression:expression];
                if(flag)
                {
                    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:wizard_id,wizard_description, nil] forKeys:keys];
                    [wizard_array addObject:dict];
                    [wizard_ids_array addObject:wizard_id];
                }
                
            }
            else
            {
                NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:wizard_id,wizard_description, nil] forKeys:keys];
                [wizard_array addObject:dict];
                [wizard_ids_array addObject:wizard_id];
            }
        }
    }
    sqlite3_finalize(stmt);
    if([wizard_ids_array count] > 0)
    {
        wizard_buttons_array  = [appDelegate.databaseInterface getButtonsForWizardInformation:wizard_ids_array record_id:record_id object_name:objectName]; 
        NSLog(@"%@",wizard_array);
        NSLog(@"wizard buttons array -%@",wizard_buttons_array);
    }
    
    [wizard_dict  setObject:wizard_array forKey:SFW_WIZARD_INFO];
    [wizard_dict  setObject:wizard_buttons_array forKey:SFW_WIZARD_BUTTONS];
    
    return wizard_dict;
    
}

-(NSMutableArray *)getButtonsForWizardInformation:(NSMutableArray *)wizard_ids_array  record_id:(NSString *)record_id  object_name:(NSString *)objectName
{

    NSString * action_id = @"";
    NSString * action_description = @"";
    NSString * expression_id = @"";
    NSString * process_id = @"";
    NSString * action_type = @"";
    
    NSMutableArray * buttons_array = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSArray * keys = [NSArray arrayWithObjects:SFW_ACTION_ID,SFW_ACTION_DESCRIPTION,SFW_EXPRESSION_ID,SFW_PROCESS_ID,SFW_ACTION_TYPE ,SFW_WIZARD_ID,SFW_ENABLE_ACTION_BUTTON,nil]; 
    
    for(int i = 0 ; i <[wizard_ids_array count]; i++)
    {
        NSString * wizard_id = [wizard_ids_array objectAtIndex:i];
        
        if(wizard_id != nil && [wizard_id length] != 0)
        {
           
            NSString * query = [NSString stringWithFormat:@"SELECT action_id , action_description, expression_id , process_id ,action_type  FROM '%@' where wizard_id ='%@'" ,SFWizard_COMPONENT , wizard_id];
            
            
            sqlite3_stmt * stmt ;
            
            if(sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
            {
                while(sqlite3_step(stmt) == SQLITE_ROW)
                {
                    action_id = @"";
                    action_description = @"";
                    expression_id = @"";
                    process_id = @"";
                    action_type = @"";
                    
                    char * temp_action_id = (char *)sqlite3_column_text(stmt, 0);
                    if(temp_action_id != nil)
                    {
                        action_id = [NSString stringWithUTF8String:temp_action_id];
                    }
                    
                    char * temp_action_description = (char *)sqlite3_column_text(stmt, 1);
                    if(temp_action_description != nil)
                    {
                        action_description = [NSString stringWithUTF8String:temp_action_description];
                    }
                    
                    char * temp_expression_id = (char *)sqlite3_column_text(stmt, 2);
                    if(temp_expression_id != nil)
                    {
                        expression_id  = [NSString stringWithUTF8String:temp_expression_id];
                    }
                    
                    char * temp_process_id = (char *)sqlite3_column_text(stmt, 3);
                    if(temp_process_id != nil)
                    {
                        process_id = [NSString stringWithUTF8String:temp_process_id];
                    }
                    
                    char * temp_action_type = (char *)sqlite3_column_text(stmt, 4);
                    if(temp_action_type != nil)
                    {
                        action_type = [NSString stringWithUTF8String:temp_action_type];
                    }
                    
                    if([expression_id length] != 0)
                    {
                        //iServiceAppDelegate * appdelegate =(iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
                        
                        NSString * expression = [appDelegate.databaseInterface queryForExpression:expression_id];
                        
                        BOOL flag = [appDelegate.databaseInterface validateTheExpressionForRecordId:record_id objectName:objectName expression:expression];
                        
                        if(flag)
                        {
                            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:action_id,action_description , expression_id, process_id, action_type , wizard_id, @"true", nil] forKeys:keys];
                            [buttons_array addObject:dict];
                            
                        }
                        else
                        {
                            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:action_id,action_description , expression_id, process_id, action_type , wizard_id, @"false", nil] forKeys:keys];
                            [buttons_array addObject:dict];
                        }
                    }
                    else
                    {
                        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:action_id,action_description , expression_id, process_id, action_type , wizard_id, @"true", nil] forKeys:keys];
                        [buttons_array addObject:dict];
                        
                    }
                    
                }
            }
            sqlite3_finalize(stmt);
        }
    }
    
    return buttons_array;
}

-(NSMutableArray *)getObjectMappingForMappingId:(NSMutableDictionary *)process_components  source_record_id:(NSString *)source_record_id field_name:(NSString *)field_name
{
    NSMutableArray * final_array = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSMutableDictionary * final_dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSMutableArray * local_array = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSString * object_mapping_id = [process_components objectForKey:OBJECT_MAPPING_ID];
    NSString * value_mapping_id = [process_components objectForKey:VALUE_MAPPING_ID];
    NSString * expression_id = [process_components objectForKey:EXPRESSION_ID];
    
   // iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString * expression_ = [appDelegate.databaseInterface  queryForExpression:expression_id];
    
    
    NSString * source_object_name = [process_components objectForKey:SOURCE_OBJECT_NAME]; 
    NSString * target_object_name = [process_components objectForKey:TARGET_OBJECT_NAME];
    NSString * source_field_name = @"";
    NSString * target_field_name = @"";
    NSString * mapping_value = @"";
    NSString * mapping_value_flag = @"";
    NSString * mapping_component_type = @"";
    
    if(object_mapping_id != nil || [object_mapping_id length] != 0 )
    {
        NSString * query = [NSString stringWithFormat:@"SELECT source_field_name , target_field_name, mapping_value ,mapping_value_flag,mapping_component_type FROM %@ where object_mapping_id = '%@'",OBJECT_MAPPING_COMPONENT, object_mapping_id];
        sqlite3_stmt * stmt ;
        if(sqlite3_prepare(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
        {
            while (sqlite3_step(stmt)  == SQLITE_ROW) 
            {
                
                source_field_name = @"";
                target_field_name = @"";
                mapping_value = @"";
                mapping_value_flag = @"";
                mapping_component_type = @"";
                
                char * temp_source_field_name = (char *)sqlite3_column_text(stmt, 0);
                if(temp_source_field_name != nil)
                {
                    source_field_name = [NSString stringWithUTF8String:temp_source_field_name];
                }
                
                char * temp_target_field_name = (char *)sqlite3_column_text(stmt, 1);
                if(temp_target_field_name != nil)
                {
                    target_field_name = [NSString stringWithUTF8String:temp_target_field_name];
                }
                
                char * temp_mapping_value = (char *)sqlite3_column_text(stmt, 2);
                if(temp_mapping_value != nil)
                {
                    mapping_value = [NSString stringWithUTF8String:temp_mapping_value];
                }
                
                char * temp_mapping_value_flag = (char *)sqlite3_column_text(stmt, 3);
                if(temp_mapping_value_flag != nil)
                {
                    mapping_value_flag = [NSString stringWithUTF8String:temp_mapping_value_flag];
                }
                
                char * temp_mapping_component_type = (char *)sqlite3_column_text(stmt, 4);
                if(temp_mapping_component_type != nil)
                {
                    mapping_component_type = [NSString stringWithUTF8String:temp_mapping_component_type];
                }
                
                //check whether the value is 
                if([mapping_component_type isEqualToString:VALUE_MAPPING])
                {
                    if([mapping_value_flag boolValue])
                    {
                        
                    }
                    else
                    {
                        
                    }
                }
                
                
               /* if([mapping_component_type isEqualToString:VALUE_MAPPING])
                {
                    if(source_field_name != 0 && [source_field_name length] != 0)
                    {
                        [final_dict  setObject:mapping_value forKey:target_field_name];
                    }
                }*/
                
                if([mapping_component_type isEqualToString:FIELD_MAPPING])
                {
                    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:source_field_name, target_field_name, mapping_value, mapping_value_flag, mapping_component_type, nil] forKeys:[NSArray arrayWithObjects:SFOBJMAPPING_SOURCE_FIELD,SFOBJMAPPING_TARGET_FIELD,SFOBJMAPPING_MAPPING_VALUE,SFOBJMAPPING_MAPPINGVALUE_FLAG,SFOBJMAPPING_COMPONENT_TYPE, nil]];
                  

                    [local_array addObject:dict];
                    
                    
                }
                
            }
        }
        sqlite3_finalize(stmt);
        
        if([mapping_component_type isEqualToString:FIELD_MAPPING])
        {
            NSMutableDictionary * dict1 = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"local_id", @"local_id", @"", @"", @"", nil] forKeys:[NSArray arrayWithObjects:SFOBJMAPPING_SOURCE_FIELD,SFOBJMAPPING_TARGET_FIELD,SFOBJMAPPING_MAPPING_VALUE,SFOBJMAPPING_MAPPINGVALUE_FLAG,SFOBJMAPPING_COMPONENT_TYPE, nil]];
            
            [local_array addObject:dict1];
        }

    }
    if(value_mapping_id != nil && [value_mapping_id length ] != 0 && [value_mapping_id isEqualToString:@""] )
    {
        NSString * query = [NSString stringWithFormat:@"SELECT source_field_name , target_field_name, mapping_value ,mapping_value_flag,mapping_component_type FROM '%@' where object_mapping_id = '%@'",OBJECT_MAPPING_COMPONENT, value_mapping_id];
        
        sqlite3_stmt * stmt ;
        if(sqlite3_prepare(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
        {
            while (sqlite3_step(stmt)  == SQLITE_ROW) 
            {
                
                source_field_name = @"";
                target_field_name = @"";
                mapping_value = @"";
                mapping_value_flag = @"";
                mapping_component_type = @"";
                
                char * temp_source_field_name = (char *)sqlite3_column_text(stmt, 0);
                if(temp_source_field_name != nil)
                {
                    target_field_name = [NSString stringWithUTF8String:temp_source_field_name];
                }
                
                char * temp_target_field_name = (char *)sqlite3_column_text(stmt, 1);
                if(temp_target_field_name != nil)
                {
                    target_field_name = [NSString stringWithUTF8String:temp_target_field_name];
                }
                
                char * temp_mapping_value = (char *)sqlite3_column_text(stmt, 2);
                if(temp_mapping_value != nil)
                {
                    mapping_value = [NSString stringWithUTF8String:temp_mapping_value];
                }
                
                char * temp_mapping_value_flag = (char *)sqlite3_column_text(stmt, 3);
                if(temp_mapping_value_flag != nil)
                {
                    mapping_value_flag = [NSString stringWithUTF8String:temp_mapping_value_flag];
                }
                
                char * temp_mapping_component_type = (char *)sqlite3_column_text(stmt, 4);
                if(temp_mapping_component_type != nil)
                {
                    mapping_component_type = [NSString stringWithUTF8String:temp_mapping_component_type];
                }
                
                //check whether the value is 
                if([mapping_component_type isEqualToString:VALUE_MAPPING])
                {
                    
                    //if([mapping_value isEqualToString:])
                    
                    if(target_field_name != 0 && [target_field_name length] != 0)
                    {
                       
                        [final_dict  setObject:mapping_value forKey:target_field_name];
                        
                        NSString * data_type = [appDelegate.databaseInterface getFieldDataType:target_object_name filedName:target_field_name];
                        
                        NSTimeInterval secondsPerDay = 24 * 60 * 60;
                        
                        NSString * today_Date ,* tomorow_date ,* yesterday_date;
                        
                        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
                        //[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                        
                        NSDate *today = [[NSDate alloc] init];
                        
                        NSDate *tomorrow, *yesterday;
                        
                        tomorrow = [today dateByAddingTimeInterval: secondsPerDay];
                        
                        yesterday = [today dateByAddingTimeInterval: -secondsPerDay];
                        
                        [today release];
                        
                        //for macros expantion
                        if([data_type isEqualToString:@"date"])
                        {
                            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                            
                            today_Date = [dateFormatter stringFromDate:today];
                            tomorow_date = [dateFormatter stringFromDate:tomorrow];
                            yesterday_date = [dateFormatter stringFromDate:yesterday];
                            
                            if([mapping_value isEqualToString:MACRO_TODAY])
                            {
                                [final_dict setObject:today_Date forKey:target_field_name];
                                
                            }
                            if([mapping_value isEqualToString:MACRO_TOMMOROW])
                            {
                                [final_dict setObject:tomorow_date forKey:target_field_name];
                                
                            }
                            if([mapping_value isEqualToString:MACRO_YESTERDAY])
                            {
                                [final_dict setObject:yesterday_date forKey:target_field_name];
                            }
                            
                        }
                        
                        if([data_type isEqualToString:@"datetime"])
                        {
                            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                            
                            today_Date = [dateFormatter stringFromDate:today];
                            tomorow_date = [dateFormatter stringFromDate:tomorrow];
                            yesterday_date = [dateFormatter stringFromDate:yesterday];
                            
                            if([mapping_value isEqualToString:MACRO_NOW])
                            {
                                [final_dict setObject:today forKey:target_field_name];
                            }
                            
                            if([mapping_value isEqualToString:MACRO_TODAY])
                            {
                                [final_dict setObject:today forKey:target_field_name];
                            }
                            
                            if([mapping_value isEqualToString:MACRO_TOMMOROW])
                            {
                                [final_dict setObject:tomorow_date forKey:target_field_name];
                            }
                            
                            if([mapping_value isEqualToString:MACRO_YESTERDAY])
                            {
                                [final_dict setObject:yesterday forKey:target_field_name];
                            }
                            
                        }
                        
                        if ([mapping_value isEqualToString:MACRO_CURRENTUSER])
                        {
                            [final_dict setObject:appDelegate.username forKey:target_field_name];
                        }
                        if ([mapping_value isEqualToString:MACRO_RECORDOWNER])
                        {
                            [final_dict setObject:MACRO_RECORDOWNER forKey:target_field_name];
                        }
                        
                    }
                                        
                }
                                
            }
        }
        sqlite3_finalize(stmt);

    }
    NSArray * allkeys = [final_dict allKeys];
    
    if([source_record_id length ] != 0 && source_record_id != nil  && expression_ != nil && [expression_ length] != 0)
    {
        
        NSMutableString * query_field_names = [[NSMutableString alloc]initWithCapacity:0];
        NSMutableArray * source_field_names = [[NSMutableArray alloc] initWithCapacity:0];
        NSMutableArray * target_field_names = [[NSMutableArray alloc] initWithCapacity:0];
        for(int i = 0 ; i< [local_array count]; i++)
        {
            NSMutableDictionary * dict  = [local_array objectAtIndex:i];
            
            NSString * source_field = [dict objectForKey:SFOBJMAPPING_SOURCE_FIELD];
            NSString * target_field = [dict objectForKey:SFOBJMAPPING_TARGET_FIELD];
            if(source_field != nil && [source_field length] != 0 && target_field != nil && [target_field length] != 0)
            {
                [source_field_names addObject:source_field];
                [target_field_names addObject:target_field];
                
                if ( i == [local_array count]-1) 
                {
                    [query_field_names appendFormat:@"%@ ", source_field];
                }
                else 
                {
                    [query_field_names appendFormat:@"%@ ,",source_field];
                }

            }
            
        }
        
        NSString * query = [NSString stringWithFormat:@"SELECT %@ FROM '%@' where %@ = '%@' and %@",query_field_names, source_object_name,field_name, source_record_id,expression_];
        
        NSString * field_value = @"";
        sqlite3_stmt * stmt ;
        
        if(sqlite3_prepare(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
        {
            while (sqlite3_step(stmt)  == SQLITE_ROW) 
            {
                NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:0];
                
                for(int k = 0 ; k < [source_field_names count]; k++ )
                {
                    field_value = @"";
                    char * temp_field_value = (char *)sqlite3_column_text(stmt,k);
                    if(temp_field_value != nil)
                    {
                        field_value = [NSString stringWithUTF8String:temp_field_value];
                    }
                    [dict setObject:field_value forKey:[target_field_names  objectAtIndex:k]];
                   // [final_dict setObject:field_value forKey:[target_field_names  objectAtIndex:k]];
                }
                
                
                for(int p = 0 ; p < [allkeys count]; p++ )
                {
                    NSString * value = [allkeys objectAtIndex:p];
                    BOOL flag = FALSE;
                    NSArray * dict_keys = [dict allKeys];
                    for(NSString * dict_str in  dict_keys )
                    {
                        if([dict_str isEqualToString:value])
                        {
                            flag = TRUE;
                            break;
                        }
                    }
                    if(!flag)
                    {
                        [dict setObject:[final_dict objectForKey:value] forKey:value];
                    }
                }
                
                [final_array addObject:dict];
            }
        }
        
        sqlite3_finalize(stmt);
           
    }
    
    return final_array;
}


-(NSMutableArray *)getChildLocalIdForParentId:(NSString *)parent_id childTableName:(NSString *)childObjectName sourceTableName:(NSString *)sourceObjectName
{
    NSMutableArray * source_child_ids = [[NSMutableArray alloc] initWithCapacity:0];
    NSString * source_child_id ;
    
   // iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString * parent_column_name = [appDelegate.databaseInterface getParentColumnNameFormChildInfoTable:SFChildRelationShip childApiName:childObjectName parentApiName:sourceObjectName];

    NSString * query = [NSString stringWithFormat:@"SELECT local_id FROM '%@' where %@ = '%@'",childObjectName, parent_column_name,parent_id ];
    
    sqlite3_stmt * stmt ;
    
    if(sqlite3_prepare(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while (sqlite3_step(stmt)  == SQLITE_ROW) 
        {
            source_child_id = @"";
            
            char * temp_child_id = (char *)sqlite3_column_text(stmt, 0);
            if(temp_child_id != nil)
            {
                source_child_id = [NSString stringWithUTF8String:temp_child_id];    
            }
            
            [source_child_ids addObject:source_child_id];
        }
    }
    
    sqlite3_finalize(stmt);
    return source_child_ids;
}
-(NSString *)getprocessTypeForProcessId:(NSString *)process_id;
{
    NSString * process_Type = @"";
    NSString * query = [NSString stringWithFormat:@"SELECT process_type FROM '%@' WHERE process_id = '%@'",SFPROCESS, process_id];
    
    sqlite3_stmt * stmt;
    if(sqlite3_prepare(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while (sqlite3_step(stmt)== SQLITE_ROW)
        {
            char * temp_process_type = (char *)sqlite3_column_text(stmt, 0);
            if(temp_process_type != nil)
            {
                process_Type =[NSString stringWithUTF8String:temp_process_type];
            }
        }
    }
    return process_Type;
}

-(BOOL)UpdateTableforId:(NSString *)local_id  forObject:(NSString *)objectName  data:(NSDictionary *)dict;
{
    BOOL success = FALSE;
    NSArray * allkeys = [dict allKeys];
    NSMutableString *  updateValue = [[NSMutableString alloc] initWithCapacity:0];
    for(int i = 0 ; i < [allkeys count]; i++)
    {
        NSString * key = [allkeys objectAtIndex:i];
        NSString * value = [dict objectForKey:key];
        if(value != nil)
        {
            //RADHA 19/01/12
            value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            if(i== 0)
                [updateValue  appendFormat:@" %@ = '%@' ",key ,value ];
            else
                [updateValue  appendFormat:@" , %@ = '%@' ",key ,value ];
        }
        
    }
    
    NSString * update_statement;
    if([updateValue length] != 0 && local_id != nil && [local_id length] != 0 )
        update_statement = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE local_id = %@",objectName ,updateValue,local_id];
    else if ( local_id != nil && [local_id length] != 0)
        return FALSE;
    else
        return TRUE;
       
    
    char * err;
    
    if(sqlite3_exec(appDelegate.db, [update_statement UTF8String],NULL, NULL, &err) != SQLITE_OK)
    {
        success = FALSE;
        NSLog(@"ERROR IN UPDATING");
    }
    else
    {
        success = TRUE;
    }
    
    return success;
    
    
}

-(NSString *)getLookUpNameForId:(NSString *)id_ 
{
    NSString * query = [NSString  stringWithFormat:@"SELECT value from LookUpFieldValue where Id = '%@'" ,id_ ];
    sqlite3_stmt * stmt;
    NSString * name = @"";
    if(sqlite3_prepare(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while (sqlite3_step(stmt)== SQLITE_ROW)
        {
            char * temp_name = (char *)sqlite3_column_text(stmt, 0);
            if(temp_name != nil)
            {
                name =[NSString stringWithUTF8String:temp_name];
            }
        }
    }
    return name;
}
@end
