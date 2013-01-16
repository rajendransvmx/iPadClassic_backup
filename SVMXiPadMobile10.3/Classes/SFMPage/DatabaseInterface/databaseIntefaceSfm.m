	
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
#import "SBJsonParser.h"
#import "ZKPicklistEntry.h"
#import "NSObject+SBJson.h"
extern void SVMXLog(NSString *format, ...);

@implementation databaseIntefaceSfm

@synthesize MyPopoverDelegate , databaseInterfaceDelegate;

-(NSString *) filePath:(NSString *)dataBaseName
{ 
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	NSString *documentsDir = [paths objectAtIndex:0];
	return [documentsDir stringByAppendingPathComponent:dataBaseName];
}

-(id)init
{
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    return self;
}


-(NSMutableDictionary *)queryProcessInfo:(NSString * )Process_id  object_name:(NSString *)object_name 
{
    NSString * sql = [NSString stringWithFormat:@"SELECT process_info FROM SFProcess where process_id = '%@'",Process_id];

    sqlite3_stmt * stmt;
    
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sql UTF8String], -1, &stmt, nil) == SQLITE_OK  )
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
          
            NSData * data = [[[NSData alloc] initWithBytes:sqlite3_column_blob(stmt, 0) length:synchronized_sqlite3_column_bytes(stmt, 0)]autorelease];
           
            NSString *errorStr = nil;
            
            NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString * documentsDirectoryPath = [paths objectAtIndex:0];
            NSString * filePath = [documentsDirectoryPath stringByAppendingPathComponent:@"processInfo.plist"];
            
            NSPropertyListFormat * format = nil;
            
            id propertyList = [NSPropertyListSerialization propertyListFromData:data
                                                               mutabilityOption:NSPropertyListImmutable
                                                                         format:format
                                                               errorDescription:&errorStr];
            if(propertyList) 
            {
                SMLog(@"No error creating XML data.");
                [propertyList writeToFile:filePath atomically:YES];
                NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
	synchronized_sqlite3_finalize(stmt);
                return dict;

            }
        }
    }
    
    synchronized_sqlite3_finalize(stmt);
    return nil;
    
}


-(NSMutableDictionary *)queryTheObjectInfoTable:(NSMutableArray *)api_names tableName:(NSString *)tableName object_name:(NSString *)objectName  
{
        
    NSMutableDictionary * dict = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];;
    for(int i = 0; i <[api_names count]; i++)
    {
        NSString * sql =[NSString stringWithFormat:@"SELECT %@ FROM '%@' WHERE %@ = '%@' and %@ ='%@' ",@"label",tableName ,@"api_name",[api_names objectAtIndex:i],@"object_api_name",objectName];
        
        sqlite3_stmt * sql_stmt;
        
        if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sql UTF8String], -1, &sql_stmt, nil)== SQLITE_OK)
        {
            while(synchronized_sqlite3_step(sql_stmt) == SQLITE_ROW)
            {
               char * temp = (char*)synchronized_sqlite3_column_text(sql_stmt, 0);
               NSString * name = @"";
                if(temp != nil && strlen(temp))
                {    
                    name  = [NSString stringWithUTF8String:temp]; 
                }
                if ([name length] == 0)
                    name  = @"";
                [dict setObject:name forKey:[api_names objectAtIndex:i]];
            }
        }
        
        synchronized_sqlite3_finalize(sql_stmt);
    }
    return dict;
}

-(BOOL)EntryCriteriaForRecordFortableName:(NSString *)tableName record_id:(NSString *) recordId  expression:(NSString *)expression
{
    NSString * expression_ = [appDelegate.databaseInterface  queryForExpression:expression forObject:tableName];
    if([expression_ length] != 0 && expression_ != nil)
    {
        BOOL flag = FALSE;
        NSString *  query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM '%@' where %@ = '%@' and %@",tableName,@"local_id", recordId,expression_];
        sqlite3_stmt * stmt ;
        SMLog(@" query  %@", query);
        if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
        {
            while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
            {
                NSString * count = @"";
                char * value = (char *)synchronized_sqlite3_column_text(stmt, 0);
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
        
        synchronized_sqlite3_finalize(stmt);
        return flag;
    }
    else
    {
        return TRUE;
    }
}
-(NSMutableDictionary *)queryDataFromObjectTable:(NSMutableArray *)api_names tableName:(NSString *)tableName record_id:(NSString *) recordId  expression:(NSString *)expression
{
    NSString * expression_ = [appDelegate.databaseInterface  queryForExpression:expression forObject:tableName];
    
    NSString * fieldsString =@"";
    NSString * singleField = @"";
    NSMutableDictionary * dict = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
       
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
     SMLog(@" query header %@",sql);
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sql UTF8String], -1, &sql_stmt, nil)== SQLITE_OK)
    {
        while(synchronized_sqlite3_step(sql_stmt) == SQLITE_ROW)
        {
            for(int j =0;j<[api_names count]; j++)
            {
                char * temp = (char*)synchronized_sqlite3_column_text(sql_stmt, j);
                NSString * value = @"";
                if(temp != nil)
                {    
                    value  =[NSString stringWithUTF8String:temp]; 
                }
                [dict setValue:value forKey:[api_names objectAtIndex:j]];
            }
        }
    }
    synchronized_sqlite3_finalize(sql_stmt);
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
    
    NSString * parent_column_name = @"";
    
    NSString * expression_ = [appDelegate.databaseInterface  queryForExpression:expression_id forObject:detailObjectName];
    parent_column_name = parent_column;
    
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
    
    NSString * sql;
    if([parent_column_name length] != 0)
    {
        if([expression_ length ] != 0 && expression_ != nil)
            
            sql = [NSString stringWithFormat:@"SELECT %@ FROM '%@' WHERE %@ = '%@' and %@",fieldsString,detailObjectName,parent_column_name,local_record_id, expression_];
        else
            sql = [NSString stringWithFormat:@"SELECT %@ FROM '%@' WHERE %@ = '%@'",fieldsString,detailObjectName,parent_column_name,local_record_id];
    }
    else
    {
        //sahana 16th June 2012
        NSString * releated_column_name = [self getRefernceToFieldnameForObjct:detailObjectName reference_table:headerObjectName table_name:SF_REFERENCE_TO];
        
        NSString * SF_id = [self getSfid_For_LocalId_From_Object_table:headerObjectName local_id:local_record_id ];
        
        if([releated_column_name length] != 0)
        {
            if([expression_ length ] != 0 && expression_ != nil)
                
                sql = [NSString stringWithFormat:@"SELECT %@ FROM '%@' WHERE %@ = '%@' and %@",fieldsString,detailObjectName,releated_column_name,SF_id, expression_];
            else
                sql = [NSString stringWithFormat:@"SELECT %@ FROM '%@' WHERE %@ = '%@'",fieldsString,detailObjectName,releated_column_name,SF_id];
        }
         //sahana 16th June 2012
    }
    SMLog(@" LineRecord %@",sql);
    
    sqlite3_stmt * sql_stmt;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sql UTF8String], -1, &sql_stmt, nil)== SQLITE_OK)
    {
        while(synchronized_sqlite3_step(sql_stmt) == SQLITE_ROW)
        {
        
            NSMutableArray * each_detail_array = [[NSMutableArray alloc ] initWithCapacity:0];
            for(int j =0;j<fieldsCount; j++)
            {
                char * temp = (char*)synchronized_sqlite3_column_text(sql_stmt, j);
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
                else if([filedDataType isEqualToString:@"reference"] && [[apiNames objectAtIndex:j] isEqualToString:@"RecordTypeId"])
                {
                    label = [appDelegate.databaseInterface getRecordTypeNameForObject:detailObjectName forId:value];
                    if([label isEqualToString:@"" ]||[label isEqualToString:@" "] || label == nil)
                    {
                        label = value;
                    }
                }
                else if([filedDataType isEqualToString:@"reference"])
                {
                    if([value isEqualToString:@""] || value == nil || [value length] == 0 )
                    {
                        label = value;
                    }
                    else
                    {
                        NSMutableArray * referenceTotableNames = [appDelegate.databaseInterface getReferenceToForField:[apiNames objectAtIndex:j] objectapiName:detailObjectName tableName:SF_REFERENCE_TO];
                        
                        if([referenceTotableNames count ] > 0)
                        {
                            NSString * reference_to_tableName = [referenceTotableNames objectAtIndex:0];
                            
                            NSString * referenceTo_Table_fieldName = [appDelegate.databaseInterface getFieldNameForReferenceTable:reference_to_tableName tableName:SFOBJECTFIELD];
                            
                            label = [appDelegate.databaseInterface getReferenceValueFromReferenceToTable:reference_to_tableName field_name:referenceTo_Table_fieldName record_id:value];
                            
                        }
                        if([label isEqualToString:@"" ]||[label isEqualToString:@" "] || label == nil)
                        {
                            //Radha 2012june08
                            label = [appDelegate.databaseInterface getLookUpNameForId:value];
                            if([label isEqualToString:@"" ]||[label isEqualToString:@" "] || label == nil)
                            {
                                label = value;
                            }
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
    
    synchronized_sqlite3_finalize(sql_stmt);
    return array;
}

-(NSMutableArray *) selectProcessFromDB:(NSString *)currentObject
{
    NSMutableArray * view_process = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSString * query = [NSString stringWithFormat:@"Select process_name, process_id from SFProcess  where process_type = '%@' and object_api_name = '%@' ", @"VIEWRECORD",currentObject];
    
    sqlite3_stmt * stmt;
    
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * temp_process_name = (char*)synchronized_sqlite3_column_text(stmt, 0);
            char * temp_process_id = (char*)synchronized_sqlite3_column_text(stmt,1);
            
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
    synchronized_sqlite3_finalize(stmt);
    return view_process;
}

-(NSMutableDictionary *)getPicklistValuesForTheFiled:(NSString *)fieldname  tableName:(NSString *)tablename objectName:(NSString *)objectName;
{
    
    NSMutableDictionary * picklistValues = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSString * query = [NSString stringWithFormat:@"SELECT label , value FROM '%@' WHERE %@ = '%@'  and %@ = '%@' ",tablename,@"object_api_name",objectName,@"field_api_name",fieldname];
    
    sqlite3_stmt * stmt ;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            NSString * label = @"" , * value = @"";
            char * temp_label = (char *)synchronized_sqlite3_column_text(stmt, 0);
            char * temp_value = (char *)(char*)synchronized_sqlite3_column_text(stmt, 1);
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
    
    synchronized_sqlite3_finalize(stmt);
    return picklistValues;
}

-(NSString *)getFieldDataType:(NSString *)objectName filedName:(NSString *)fieldName 
{
    NSString * datatype = @"";
    NSString * query = [NSString stringWithFormat:@"SELECT type FROM '%@' where object_api_name = '%@' and api_name = '%@'" ,SFOBJECTFIELD,objectName,fieldName];
    
    sqlite3_stmt * stmt ;
    
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * temp_data_type =  (char*)synchronized_sqlite3_column_text(stmt, 0);
            if(temp_data_type != nil)
            {
                datatype = [NSString stringWithUTF8String:temp_data_type];
            }
        }
    }

    synchronized_sqlite3_finalize(stmt);
    return datatype;
}

//methods to query for Reference field

-(NSMutableArray *)getReferenceToForField:(NSString *)field_apiname  objectapiName:(NSString *)objectApiName tableName:(NSString *)tableName ;
{
    NSMutableArray * referenceToTableNames = [[NSMutableArray alloc] initWithCapacity:0];
    NSString * referencetoName = @"";
    NSString * query = [NSString stringWithFormat:@"SELECT reference_to FROM '%@' where object_api_name = '%@' and field_api_name = '%@'" ,tableName,objectApiName ,field_apiname];
    sqlite3_stmt * stmt ;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * temp_referenceToName = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if(temp_referenceToName != nil)
            {
                referencetoName = [NSString stringWithUTF8String:temp_referenceToName];
            }
            [referenceToTableNames addObject:referencetoName];
            referencetoName = @"";
        }
    }
    synchronized_sqlite3_finalize(stmt);
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
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * temp_keyPrefixValue = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if(temp_keyPrefixValue != nil)
            {
                keyPrefixValue = [NSString stringWithUTF8String:temp_keyPrefixValue];
            }
        }
    }
    synchronized_sqlite3_finalize(stmt);
    return keyPrefixValue;
}

-(NSString *)getFieldNameForReferenceTable:(NSString *)referedToTableName  tableName:(NSString *)tableName
{
    NSString * fieldName = @"";
    NSString * query = [NSString stringWithFormat:@"SELECT api_name FROM '%@' where object_api_name = '%@' and name_field = 'TRUE'",tableName,referedToTableName];
    sqlite3_stmt * stmt ;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * temp_fieldName = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if(temp_fieldName != nil)
            {
                fieldName = [NSString stringWithUTF8String:temp_fieldName];
            }
        }
    }
    synchronized_sqlite3_finalize(stmt);
    return fieldName;
    
}

-(NSString *)getReferenceValueFromReferenceToTable:(NSString *)tableName field_name:(NSString *) filed_name record_id:(NSString *)record_id
{
    NSString * fieldvalue = @"";
	BOOL isTableExists = [appDelegate.databaseInterface checkForTheTableInTheDataBase:tableName];
    if(isTableExists)
    {
        NSString * query = [NSString stringWithFormat:@"SELECT %@ FROM '%@' where id = '%@'",filed_name,tableName,record_id];
        sqlite3_stmt * stmt ;
        if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
        {
            while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
            {
                char * temp_fieldvalue = (char *)synchronized_sqlite3_column_text(stmt, 0);
                if(temp_fieldvalue != nil)
                {
                    fieldvalue = [NSString stringWithUTF8String:temp_fieldvalue];
                }
            }
        }
        synchronized_sqlite3_finalize(stmt);
    }
    
    return fieldvalue;
}

-(BOOL)checkForTheTableInTheDataBase:(NSString *)tableName
{
    bool flag = FALSE;
    sqlite3_stmt *statement_Chk_table_exist;
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM sqlite_master WHERE type='table' AND name='%@'",tableName];
    if( synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement_Chk_table_exist, nil) == SQLITE_OK)
    {
        
        if (synchronized_sqlite3_step(statement_Chk_table_exist) == SQLITE_ROW)
        {
            flag = TRUE;
        }
    }
    synchronized_sqlite3_finalize(statement_Chk_table_exist);
    
    return flag;

}

-(NSString *) getObjectLabel:(NSString *)tableName objectApi_name:(NSString *)objectApiName;//SFObject
{
    NSString * fieldName = @"";
    NSString * query = [NSString stringWithFormat:@"SELECT label FROM '%@' where api_name = '%@' ",tableName,objectApiName];
    sqlite3_stmt * stmt ;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * temp_fieldName = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if(temp_fieldName != nil)
            {
                fieldName = [NSString stringWithUTF8String:temp_fieldName];
            }
        }
    }
    synchronized_sqlite3_finalize(stmt);
    return fieldName;
}

//get the work order name like WO -000000020
-(NSString *) getObjectName: (NSString *) tablename recordId:(NSString *)recordId;
{
	//Fix for the defect : #6238
	NSString * nameField = [appDelegate.databaseInterface getFieldNameForReferenceTable:tablename tableName:SFOBJECTFIELD];
    NSString * fieldName = @"";
    if(recordId != nil)
    {
        NSString * query = @"";
        if ([tablename isEqualToString:@"Case"])
			
            query = [NSString stringWithFormat:@"SELECT %@ FROM '%@' where local_id = '%@' ",nameField,tablename,recordId];
        else
            query = [NSString stringWithFormat:@"SELECT %@ FROM '%@' where local_id = '%@' ",nameField,tablename,recordId];
        sqlite3_stmt * stmt ;
        if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
        {
            while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
            {
                char * temp_fieldName = (char *)synchronized_sqlite3_column_text(stmt, 0);
                if(temp_fieldName != nil)
                {
                    fieldName = [NSString stringWithUTF8String:temp_fieldName];
                }
            }
        }
        synchronized_sqlite3_finalize(stmt);
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
        if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
        {
            while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
            {
                char * temp_fieldName = (char *)synchronized_sqlite3_column_text(stmt, 0);
                if(temp_fieldName != nil)
                {
                    fieldName = [NSString stringWithUTF8String:temp_fieldName];
                }
            }
        }
        synchronized_sqlite3_finalize(stmt);
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
        if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
        {
            while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
            {
                char * temp_fieldName = (char *)synchronized_sqlite3_column_text(stmt, 0);
                if(temp_fieldName != nil)
                {
                    recordType = [NSString stringWithUTF8String:temp_fieldName];
                }
            }
        }
        synchronized_sqlite3_finalize(stmt);
        
    }
    
    return recordType;
}

-(NSMutableDictionary *)getRestorationAndResolutionTimeForWorkOrder:(NSString *)record_id  tableName:(NSString *)tableName;
{
    NSMutableDictionary * SLADict = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSString * Restoration = @"";
    NSString * Resolution = @"";
    NSString * clockedPaused = @"";
    NSString * actualRestoration = @"";
    NSString * actualResolution = @"";
    NSString * restorationCustomerBy = @"";
    NSString * resolutionCustomerBy = @"";
    NSString * pausedTime = @"";
    if(record_id != nil)
    {
        NSString * query = [NSString stringWithFormat:@"SELECT SVMXC__Restoration_Customer_By__c, SVMXC__Resolution_Customer_By__c,Svmxc__Sla_Clock_Paused__C,Svmxc__Actual_Resolution__C,Svmxc__Actual_Restoration__C,Svmxc__Restoration_Customer_By__C,Svmxc__Resolution_Customer_By__C,Svmxc__Sla_Clock_Pause_Time__C FROM '%@' where local_id = '%@'", tableName ,record_id];
        
        sqlite3_stmt * stmt ;
        if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
        {
            while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
            {
                char * temp_Restoration = (char *)synchronized_sqlite3_column_text(stmt, 0);
                char * temp_Resolution = (char *)synchronized_sqlite3_column_text(stmt, 1);
                char * temp_clock_paused = (char *)synchronized_sqlite3_column_text(stmt, 2);
                char * temp_actual_resolution = (char *)synchronized_sqlite3_column_text(stmt, 3);
                char * temp_actual_restoration = (char *)synchronized_sqlite3_column_text(stmt, 4);
                char * temp_restorationCustomerBy = (char *)synchronized_sqlite3_column_text(stmt, 5);
                char * temp_resolutionCustomerBy = (char *)synchronized_sqlite3_column_text(stmt, 6);
                char * temp_pausedTime = (char *)synchronized_sqlite3_column_text(stmt, 7);
                if(temp_Restoration != nil)
                {
                    Restoration = [NSString stringWithUTF8String:temp_Restoration];
                }
                if(temp_Resolution != nil)
                {
                    Resolution = [NSString stringWithUTF8String:temp_Resolution];
                }
                if(temp_clock_paused != nil)
                {
                    clockedPaused = [NSString stringWithUTF8String:temp_clock_paused];
                }
                if(temp_actual_resolution != nil)
                {
                    actualRestoration = [NSString stringWithUTF8String:temp_actual_resolution];
                }
                if(temp_actual_restoration != nil)
                {
                    actualResolution = [NSString stringWithUTF8String:temp_actual_restoration];
                }
                if(temp_restorationCustomerBy != nil)
                {
                    restorationCustomerBy = [NSString stringWithUTF8String:temp_restorationCustomerBy];
                }
                if(temp_resolutionCustomerBy != nil)
                {
                    resolutionCustomerBy = [NSString stringWithUTF8String:temp_resolutionCustomerBy];
                }
                if(temp_pausedTime != nil)
                {
                    pausedTime = [NSString stringWithUTF8String:temp_pausedTime];
                }
                
            }
        }
        synchronized_sqlite3_finalize(stmt);
    }
    
    [SLADict setObject:Restoration forKey:RESTORATIONTIME];
    [SLADict setObject:Resolution forKey:RESOLUTIONTIME];
    
    [SLADict setObject:clockedPaused forKey:@"Svmxc__Sla_Clock_Paused__C"];
    [SLADict setObject:actualRestoration forKey:@"Svmxc__Actual_Resolution__C"];
    [SLADict setObject:actualResolution forKey:@"Svmxc__Actual_Restoration__C"];
    [SLADict setObject:restorationCustomerBy forKey:@"Svmxc__Restoration_Customer_By__C"];
    [SLADict setObject:resolutionCustomerBy forKey:@"Svmxc__Resolution_Customer_By__C"];
    [SLADict setObject:pausedTime forKey:@"Svmxc__Sla_Clock_Pause_Time__C"];
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
        if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
        {
            while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
            {
                char * temp_topLevel_Id = (char *)synchronized_sqlite3_column_text(stmt, 0);
                char * temp_component = (char *)synchronized_sqlite3_column_text(stmt, 1);
                char * temp_account_Id = (char *)synchronized_sqlite3_column_text(stmt, 2);
                
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
        synchronized_sqlite3_finalize(stmt);
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
        NSString * query =  [NSString stringWithFormat:@"SELECT  SVMXC__Problem_Description__c, CreatedDate FROM '%@' WHERE CreatedDate <= '%@' AND SVMXC__Order_Status__c = 'Closed' AND Id != '%@' AND SVMXC__Company__c = '%@'",tablename, dateString, record_id, account_id];

        sqlite3_stmt * stmt ;
        
        if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
        {
            while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
            {
                char * temp_problemDiscription = (char *)synchronized_sqlite3_column_text(stmt, 0);
                char * temp_created_by = (char *)synchronized_sqlite3_column_text(stmt, 1);
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
        synchronized_sqlite3_finalize(stmt);
    }
    
    return account_history;
}


-(NSMutableArray *)getProductHistoryForanWorkOrder:(NSString *)record_id  filedName:(NSString *)fieldName tableName:(NSString *)tablename  fieldValue:(NSString *)fieldValue
{
    NSMutableArray * product_history = [[NSMutableArray alloc] initWithCapacity:0];
    NSArray * keys = [NSArray arrayWithObjects:@"CreatedDate" ,@"SVMXC__Problem_Description__c",nil];
    
    NSDate * _date = [NSDate date];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString * dateString = [NSString stringWithFormat:@"%@T00:00:00Z", [dateFormatter stringFromDate:_date]];
    
    
    NSString * problemDiscription = @"";
    NSString * created_by  = @"";
    
    if(record_id != nil && fieldValue != nil && dateString != nil)
    {
        NSString * query =  [NSString stringWithFormat:@"SELECT  SVMXC__Problem_Description__c, CreatedDate FROM '%@' WHERE CreatedDate <= '%@' AND SVMXC__Order_Status__c = 'Closed' AND Id != '%@' AND %@ = '%@'",tablename, dateString, record_id,fieldName, fieldValue];
        sqlite3_stmt * stmt ;
        
        NSDateFormatter * datetimeFormatter=[[[NSDateFormatter alloc]init]autorelease];
        [datetimeFormatter  setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSTimeZone * gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        [datetimeFormatter setTimeZone:gmt];
        
        if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
        {
            while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
            {
                NSDate * created_date = nil;
                if (created_date == nil)
                    created_date = [[NSDate alloc] init];
                
                char * temp_problemDiscription = (char *)synchronized_sqlite3_column_text(stmt, 0);
                char * temp_created_by = (char *)synchronized_sqlite3_column_text(stmt, 1);
                if(temp_problemDiscription != nil)
                {
                    problemDiscription = [NSString stringWithUTF8String:temp_problemDiscription];
                }
                if(temp_created_by != nil)
                {
                    created_by = [NSString stringWithUTF8String:temp_created_by];
                }
                
                NSString * _createdBy = [created_by stringByDeletingPathExtension];
                _createdBy = [_createdBy stringByReplacingOccurrencesOfString:@"T" withString:@" "];
                created_date = [datetimeFormatter dateFromString:_createdBy];            

                if(problemDiscription  == nil )
                {
                    problemDiscription = @"";
                }
                if(_createdBy  == nil )
                {
                    _createdBy  = @"";
                }
                
                NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:created_date,problemDiscription , nil] forKeys:keys];
                [product_history addObject:dict];

            }
        }
        synchronized_sqlite3_finalize(stmt);
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
        
        if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
        {
            while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
            {   
                char * temp_local_id = (char *)synchronized_sqlite3_column_text(stmt, 0);
                if(temp_local_id != nil)
                {
                    local_id = [NSString stringWithUTF8String:temp_local_id];
                }
                //local_id = temp_local_id;
            }
        }
        
        synchronized_sqlite3_finalize(stmt);
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
    NSString * contact_Id = @"";     //Shrinivas
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:0];

    if(record_id != nil)
    {
        //Shrinivas - 13.07.2012
        NSString * query = [NSString stringWithFormat:@"select c.phone ,c.Email, c.Name, w.Name ,w.SVMXC__Problem_Description__c ,w.SVMXC__Order_Type__c, w.SVMXC__Contact__c from SVMXC__Service_Order__c  as w  inner join  Contact  as c on  w.SVMXC__Contact__c = c. id   where  w.local_id = '%@'" ,record_id];
        sqlite3_stmt * stmt ;
        
        if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
        {
            while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
            {   
                char * temp_Phone  = (char *)synchronized_sqlite3_column_text(stmt, 0);
                
                if(temp_Phone!= nil) 
                    Phone = [NSString stringWithUTF8String:temp_Phone];
                
                char * temp_email  = (char *)synchronized_sqlite3_column_text(stmt, 1);
                if(temp_email != nil) 
                    email = [NSString stringWithUTF8String:temp_email];
                
                char * temp_caontactName  = (char *)synchronized_sqlite3_column_text(stmt, 2);
                if(temp_caontactName != nil)
                    caontactName = [NSString stringWithUTF8String:temp_caontactName];
                
                char * temp_Work_orderName  = (char *)synchronized_sqlite3_column_text(stmt, 3);
                if(temp_Work_orderName != nil)
                    Work_orderName = [NSString stringWithUTF8String:temp_Work_orderName];
                
                char * temp_workOrderProblemDescription  = (char *)synchronized_sqlite3_column_text(stmt, 4);
                if(temp_workOrderProblemDescription != nil)
                    workOrderProblemDescription = [NSString stringWithUTF8String:temp_workOrderProblemDescription];
                
                char * temp_workOrderOrderType  = (char *)synchronized_sqlite3_column_text(stmt, 5);
                if(temp_workOrderOrderType != nil)
                    workOrderOrderType = [NSString stringWithUTF8String:temp_workOrderOrderType];
                
                char * _contact_Id  = (char *)synchronized_sqlite3_column_text(stmt, 6);
                if(_contact_Id != nil)
                    contact_Id = [NSString stringWithUTF8String:_contact_Id];
                
                [dict  setObject:Phone forKey:@"SVMXC__Contact__r.Phone"];
                [dict  setObject:email forKey:@"SVMXC__Contact__r.Email"];
                [dict  setObject:caontactName forKey:@"SVMXC__Contact__r.Name"];
                [dict  setObject:Work_orderName forKey:@"Name"];
                [dict  setObject:workOrderProblemDescription forKey:@"SVMXC__Problem_Description__c"];
                [dict  setObject:workOrderOrderType forKey:@"SVMXC__Order_Type__c"];
                [dict  setObject:contact_Id forKey:@"SVMXC__Contact__c"]; //shrinivas
                
            }
            
        }
        
        synchronized_sqlite3_finalize(stmt);
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
        
        if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
        {
            while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
            {                
                char * temp_process_id  = (char *)synchronized_sqlite3_column_text(stmt, 0);
                
                if(temp_process_id!= nil) 
                    process_id = [NSString stringWithUTF8String:temp_process_id];
                
                char * temp_objectApi_name  = (char *)synchronized_sqlite3_column_text(stmt, 1);
                if(temp_objectApi_name != nil) 
                    objectApi_name = [NSString stringWithUTF8String:temp_objectApi_name];
                
                char * temp_process_name  = (char *)synchronized_sqlite3_column_text(stmt, 2);
                if(temp_process_name != nil)
                    process_name = [NSString stringWithUTF8String:temp_process_name];
                
                char * temp_process_description  = (char *)synchronized_sqlite3_column_text(stmt, 3);
                if(temp_process_description != nil)
                    process_description = [NSString stringWithUTF8String:temp_process_description];

                
                NSMutableDictionary * dict = [NSMutableDictionary  dictionaryWithObjects:[NSArray arrayWithObjects:process_id,objectApi_name,process_name, process_description,nil] forKeys:createInfokeys];       
                [processArray addObject:dict];
            }
            
        }
        
        synchronized_sqlite3_finalize(stmt);
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
        if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
        {
            while (synchronized_sqlite3_step(stmt)  == SQLITE_ROW) 
            {
                char * temp_process_id  = (char *)synchronized_sqlite3_column_text(stmt, 0);
                
                if(temp_process_id!= nil) 
                    field_api_name = [NSString stringWithUTF8String:temp_process_id];
                
                if([dict count] != 0)
                {
            
                }
                [dict setObject:@"" forKey:field_api_name];
            
            }
        }
        synchronized_sqlite3_finalize(stmt);
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
    NSString * source_child_parent_column = @"";
    
    
    if([processId length ] != 0 ||  processId != nil)
    {
         NSString * query = @"";
        
        if(layoutId != nil || [layoutId length] != 0)
        {
            query = [NSString stringWithFormat:@"SELECT object_mapping_id ,expression_id,source_object_name,target_object_name,parent_column ,value_mapping_id ,source_child_parent_column FROM '%@' WHERE process_id = '%@' AND layout_id = '%@' and component_type = '%@'",PROCESS_COMPONENT , processId , layoutId,componentType];
        }
        else
        {
            query = [NSString stringWithFormat:@"SELECT object_mapping_id ,expression_id,source_object_name,target_object_name,parent_column ,value_mapping_id  , source_child_parent_column FROM '%@' WHERE process_id = '%@' and component_type = '%@'",PROCESS_COMPONENT , processId ,componentType];
        }
        SMLog(@" process component%@ ",query );
        sqlite3_stmt * stmt ;
        if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
        {
            while (synchronized_sqlite3_step(stmt)  == SQLITE_ROW) 
            {
                char * temp_object_mapping_id = (char *)synchronized_sqlite3_column_text(stmt, 0);
                if(temp_object_mapping_id != nil)
                {
                    object_mapping_id = [NSString stringWithUTF8String:temp_object_mapping_id];
                }
                
                char * temp_expression_id = (char *)synchronized_sqlite3_column_text(stmt, 1);
                if(temp_expression_id != nil)
                {
                    expression_id = [NSString stringWithUTF8String:temp_expression_id];
                }
                
                char * temp_source_object_name = (char *)synchronized_sqlite3_column_text(stmt, 2);
                if(temp_source_object_name != nil)
                {
                    source_object_name = [NSString stringWithUTF8String:temp_source_object_name];
                }
                
                char * temp_target_object_name = (char *)synchronized_sqlite3_column_text(stmt, 3);
                if(temp_target_object_name != nil)
                {
                    target_object_name = [NSString stringWithUTF8String:temp_target_object_name];
                }
                
                char * temp_parent_column_name = (char *)synchronized_sqlite3_column_text(stmt, 4);
                if(temp_parent_column_name != nil)
                {
                    parent_column = [NSString stringWithUTF8String:temp_parent_column_name];
                }
                
                char * temp_value_mapping_id = (char *)synchronized_sqlite3_column_text(stmt, 5);
                if(temp_value_mapping_id != nil)
                {
                    value_mapping_id = [NSString stringWithUTF8String:temp_value_mapping_id];
                }
                
                char * temp_source_child_parent_column = (char *)synchronized_sqlite3_column_text(stmt, 6);
                if(temp_source_child_parent_column != nil)
                {
                    source_child_parent_column = [NSString stringWithUTF8String:temp_source_child_parent_column];
                }
                
                [dict setObject:expression_id forKey:EXPRESSION_ID];
                [dict setObject:object_mapping_id forKey:OBJECT_MAPPING_ID];
                [dict setObject:source_object_name forKey:SOURCE_OBJECT_NAME];
                [dict setObject:target_object_name forKey:TARGET_OBJECT_NAME];
                [dict setObject:parent_column forKey:PARENT_COLUMN_NAME];
                [dict setObject:value_mapping_id forKey:VALUE_MAPPING_ID];
                [dict setObject:source_child_parent_column  forKey:SOURCE_CHILD_PARENT_COLUMN];

            }
            
            synchronized_sqlite3_finalize(stmt);
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
        if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
        {
            while (synchronized_sqlite3_step(stmt)  == SQLITE_ROW) 
            {
                char * temp_object_mapping_id = (char *)synchronized_sqlite3_column_text(stmt, 0);
                if(temp_object_mapping_id != nil)
                {
                    object_mapping_id = [NSString stringWithUTF8String:temp_object_mapping_id];
                }
                
                char * temp_expression_id = (char *)synchronized_sqlite3_column_text(stmt, 1);
                if(temp_expression_id != nil)
                {
                    expression_id = [NSString stringWithUTF8String:temp_expression_id];
                }
                
                char * temp_source_object_name = (char *)synchronized_sqlite3_column_text(stmt, 2);
                if(temp_source_object_name != nil)
                {
                    source_object_name = [NSString stringWithUTF8String:temp_source_object_name];
                }
                
                char * temp_target_object_name = (char *)synchronized_sqlite3_column_text(stmt, 3);
                if(temp_target_object_name != nil)
                {
                    target_object_name = [NSString stringWithUTF8String:temp_target_object_name];
                }
                
                char * temp_parent_column_name = (char *)synchronized_sqlite3_column_text(stmt, 4);
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
        synchronized_sqlite3_finalize(stmt);
    }
    
    return dict;
}


-(NSMutableDictionary *)getObjectMappingForMappingId:(NSMutableDictionary *)process_components mappingType:(NSString *)mapping_type
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSString * value_mapping_id = [process_components objectForKey:VALUE_MAPPING_ID];
    NSString * target_object_name = [process_components objectForKey:TARGET_OBJECT_NAME];
	
	NSString * objectMappingId = [process_components objectForKey:OBJECT_MAPPING_ID];
	
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
            if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
            {
                while (synchronized_sqlite3_step(stmt)  == SQLITE_ROW) 
                {
                    source_field_name = @"";
                    mapping_value = @"";
                    mapping_value_flag = @"";
                    target_field_name = @"";

                    char * temp_source_field_name = (char *)synchronized_sqlite3_column_text(stmt, 0);
                    if(temp_source_field_name != nil)
                    {
                        source_field_name = [NSString stringWithUTF8String:temp_source_field_name];
                    }
                    
                    char * temp_mapping_value = (char *)synchronized_sqlite3_column_text(stmt, 1);
                    if(temp_mapping_value != nil)
                    {
                        mapping_value = [NSString stringWithUTF8String:temp_mapping_value];
                    }
                    
                    char * temp_mapping_value_flag = (char *)synchronized_sqlite3_column_text(stmt, 2);
                    if(temp_mapping_value_flag != nil)
                    {
                        mapping_value_flag = [NSString stringWithUTF8String:temp_mapping_value_flag];
                    }
                    char * temp_target_field_name = (char *)synchronized_sqlite3_column_text(stmt, 3);
                    if(temp_target_field_name != nil)
                    {
                        target_field_name = [NSString stringWithUTF8String:temp_target_field_name];
                    }
                        
                    if(target_field_name != nil || [target_field_name length] != 0)
                    {
                        
                        if([target_field_name isEqualToString:@"RecordTypeId"])
                        {
                            NSString * query = [NSString stringWithFormat:@"SELECT record_type_id FROM  SFRecordType where object_api_name = '%@' and record_type = '%@'" ,target_object_name,mapping_value];
                            NSString * record_type_id = @"";
                            
                            SMLog(@"RecordTypeId  valuemapping %@" ,query);
                            sqlite3_stmt * recordTypeId_statement ;
                            if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &recordTypeId_statement, nil) == SQLITE_OK)
                            {
                                while (synchronized_sqlite3_step(recordTypeId_statement) == SQLITE_ROW)
                                {
                                    char * temp_record_type_id = (char *) synchronized_sqlite3_column_text(recordTypeId_statement, 0);
                                    if(temp_record_type_id != nil)
                                    {
                                        record_type_id = [NSString stringWithUTF8String:temp_record_type_id];
                                    }
                                }
                            }
                            synchronized_sqlite3_finalize(recordTypeId_statement);
                            if(![record_type_id isEqualToString:@""])
                            {
                                mapping_value = record_type_id;
                            }
                            else
                            {
                                mapping_value = @"";
                            }
                            
                        }
                        
						[dict setObject:mapping_value forKey:target_field_name];
                        NSString * data_type = [[appDelegate.databaseInterface getFieldDataType:target_object_name filedName:target_field_name] lowercaseString];
                        
                        NSTimeInterval secondsPerDay = 24 * 60 * 60;
                        
                        NSString * today_Date ,* tomorow_date ,* yesterday_date;
                        
                        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
                        
                        NSDate *today = [NSDate date];
                        
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
							
                            if([mapping_value caseInsensitiveCompare:MACRO_TODAY] == NSOrderedSame)
                            {
                               [dict setObject:today_Date forKey:target_field_name];
                            }
                            else if([mapping_value caseInsensitiveCompare:MACRO_TOMMOROW] == NSOrderedSame)
                            {
                                [dict setObject:tomorow_date forKey:target_field_name];
                            }
                            else if([mapping_value caseInsensitiveCompare:MACRO_YESTERDAY] == NSOrderedSame)
                            {
                                [dict setObject:yesterday_date forKey:target_field_name];
                            }
                        }
                        if([data_type isEqualToString:@"datetime"])
                        {
                            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                            [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
                            
                            today_Date = [dateFormatter stringFromDate:today];
                            today_Date = [today_Date stringByReplacingOccurrencesOfString:@" " withString:@"T"];
                            
                            tomorow_date = [dateFormatter stringFromDate:tomorrow];
                            tomorow_date = [tomorow_date stringByReplacingOccurrencesOfString:@" " withString:@"T"];
                            
                            yesterday_date = [dateFormatter stringFromDate:yesterday];
                            yesterday_date = [yesterday_date stringByReplacingOccurrencesOfString:@" " withString:@"T"];
                            
                            if([mapping_value caseInsensitiveCompare:MACRO_NOW]== NSOrderedSame)
                            {
                                [dict setObject:today_Date forKey:target_field_name];
                            }
                            else if([mapping_value caseInsensitiveCompare:MACRO_TODAY] == NSOrderedSame)
                            {
                                [dict setObject:today_Date forKey:target_field_name];
                            }
                            else if([mapping_value caseInsensitiveCompare:MACRO_TOMMOROW] == NSOrderedSame)
                            {
                                [dict setObject:tomorow_date forKey:target_field_name];
                            }
                            else if([mapping_value caseInsensitiveCompare:MACRO_YESTERDAY] == NSOrderedSame)
                            {
                                [dict setObject:yesterday_date forKey:target_field_name]; //RADHA
                            }
                            [dateFormatter release];
                        }
                        
                        if ([mapping_value caseInsensitiveCompare:MACRO_CURRENTUSER] == NSOrderedSame)
                        {
                             [dict setObject:appDelegate.username forKey:target_field_name];
                        }
                        else if ([mapping_value isEqualToString:MACRO_RECORDOWNER])
                        {
                             [dict setObject:MACRO_RECORDOWNER forKey:target_field_name];
                        }
                    }
                    
                    
                }
            }
            
            synchronized_sqlite3_finalize(stmt);
        }
    }
    
	
	//6279 - DefectFix
	else if ([mapping_type isEqualToString:FIELD_MAPPING])
	{
		if(objectMappingId != nil || [objectMappingId length] != 0 )
        {
             NSString * query = [NSString stringWithFormat:@"SELECT source_field_name,target_field_name  FROM '%@' where mapping_component_type = '%@' and object_mapping_id = '%@'",OBJECT_MAPPING_COMPONENT,FIELD_MAPPING, objectMappingId];
			
			sqlite3_stmt * stmt ;
            if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
            {
                while (synchronized_sqlite3_step(stmt)  == SQLITE_ROW)
                {
					source_field_name = @"";
                    target_field_name = @"";
					
					char * temp_source_field_name = (char *)synchronized_sqlite3_column_text(stmt, 0);
                    if(temp_source_field_name != nil)
                    {
                        source_field_name = [NSString stringWithUTF8String:temp_source_field_name];
                    }
					char * temp_target_field_name = (char *)synchronized_sqlite3_column_text(stmt, 1);
                    if(temp_target_field_name != nil)
                    {
                        target_field_name = [NSString stringWithUTF8String:temp_target_field_name];
                    }
					[dict setObject:source_field_name forKey:target_field_name];
				}
			}
			
		}
	}
    
    return dict;
}

-(BOOL)insertdataIntoTable:(NSString *)tableName data:(NSMutableDictionary *)valuesDict
{
    
    NSAutoreleasePool * autorelease_pool = [[NSAutoreleasePool alloc] init];
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
            NSString * field_data_type = [self getFieldDataType:tableName filedName:field];
            if([field_data_type isEqualToString:@"boolean"])
            {
                if ([value isEqualToString:@"True"] || [value isEqualToString:@"true"] || [value isEqualToString:@"1"])
                {
                    value = @"1";
                }
                else
                {
                    value = @"0";
                }
            }
            
            values_string = [values_string stringByAppendingFormat:@"'%@'",value];
            fields_string = [fields_string stringByAppendingFormat:@"%@",field];
            count ++;
        }
    }
    
	if([[valuesDict objectForKey:@"Id"] length] == 0  && [tableName isEqualToString:@"Event"])
    {
        values_string = [values_string stringByAppendingFormat:@",''"];
        fields_string = [fields_string stringByAppendingFormat:@",Id"];
    }
    
    NSString * insert_statement;
    if([values_string length] != 0 && [fields_string length] != 0)
        insert_statement = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' (%@) VALUES (%@)",tableName , fields_string , values_string];
    else
        insert_statement = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' DEFAULT VALUES",tableName ];
    
    char * err;
      
    if(synchronized_sqlite3_exec(appDelegate.db, [insert_statement UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(@"%@", insert_statement);
		SMLog(@"METHOD: insertdataIntoTable");
        SMLog(@"ERROR IN INSERTING %s", err);
        success = FALSE;
        if([tableName isEqualToString:@"Event"])
        {
            NSString * startDateTime = [valuesDict objectForKey:@"StartDateTime"];
            NSString * enddatetime = [valuesDict objectForKey:@"EndDateTime"];
            NSString * overlappingEvent = [appDelegate.databaseInterface getallOverLappingEventsForStartDateTime:startDateTime EndDateTime:enddatetime];
            NSString * local_id = [valuesDict objectForKey:@"local_id"];
            [self insertIntoEventsLocal_ids:local_id];
            [databaseInterfaceDelegate displayALertViewinSFMDetailview:overlappingEvent];
        }
        
    }
    else
    {
        success = TRUE;
    }
   
    [autorelease_pool release];
    return success;
}

-(NSString *)getTheRecordIdOfnewlyInsertedRecord:(NSString *)tableName
{
    NSString * query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM '%@'",tableName];
    sqlite3_stmt * stmt ;
    NSString * count = @"";
    
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(stmt)  == SQLITE_ROW) 
        {
            char * value = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if(value != nil)
            {
                count = [NSString stringWithUTF8String:value];
            }
        }
    }
    synchronized_sqlite3_finalize(stmt);
    return count;
}

//For muti add  
-(NSMutableDictionary *)getDataForMultiAdd:(NSString *)object_name searchField:(NSString *)search_field 
{
    NSMutableDictionary * muti_add_data = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSMutableArray * eachRow = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSString * query = @"";
    if ([search_field length] > 0)
	{
        query = [NSString stringWithFormat:@"SELECT Id , %@ FROM '%@' Where Name LIKE '%%%@%%'",@"Name" , object_name, search_field];
    }
	else
	{
        query = [NSString stringWithFormat:@"SELECT Id , %@ FROM '%@'",@"Name" , object_name];
    }
    
    sqlite3_stmt * stmt ;
    NSString * Id = @"";
    NSString * field_value = @"";
    
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(stmt)  == SQLITE_ROW) 
        {
            NSMutableArray * arr = [[NSMutableArray alloc] initWithCapacity:0];
            
            char * id_value = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if(id_value != nil)
            {
                Id = [NSString stringWithUTF8String:id_value];
            }
            
            char * value = (char *)synchronized_sqlite3_column_text(stmt, 1);
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
    
    synchronized_sqlite3_finalize(stmt);
    [muti_add_data setObject:eachRow forKey:@"DATA"];
    
    return muti_add_data;
}


- (NSDictionary *) getLookupDataFromDBWith:(NSString *)lookupID referenceTo:(NSString *)object  searchFor:(NSString *)searchForString
{
    NSMutableDictionary * finalDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSMutableArray * fields_array = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray * each_record = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray * searchable_fields = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray * lookup_object_info = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray * results_array = [[NSMutableArray alloc] initWithCapacity:0];
    
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
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [querystring2 UTF8String], -1, &stmt_, nil) == SQLITE_OK  ) 
    {
        while(synchronized_sqlite3_step(stmt_) == SQLITE_ROW) 
        {
            
            default_column = @"";
            Object_name    = @"";
            isstandard     = @"";
            isdefault      = @"";
            
            char * temp_default_column = (char *) synchronized_sqlite3_column_text(stmt_, 0);
            if ( temp_default_column != nil ) 
            {
                default_column= [NSString stringWithUTF8String:temp_default_column];
            }
            char * temp_Object_name = (char *) synchronized_sqlite3_column_text(stmt_, 1);
            if ( temp_Object_name != nil ) 
            {
                Object_name= [NSString stringWithUTF8String:temp_Object_name];
            }
            char * temp_isstandard = (char *) synchronized_sqlite3_column_text(stmt_, 2);
            if ( temp_isstandard != nil ) 
            {
                isstandard= [NSString stringWithUTF8String:temp_isstandard];
            }
            char * temp_isdefault = (char *) synchronized_sqlite3_column_text(stmt_, 3);
            if(temp_isdefault != nil)
            {
                isdefault = [NSString stringWithUTF8String:temp_isdefault];
            }
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:default_column,Object_name,isstandard,isdefault, nil] forKeys:lookUp_info_object_keys];
            [lookup_object_info addObject:dict];
        }
    }
	
    
 	synchronized_sqlite3_finalize(stmt_);
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
        
        //Sahana Fixed   ---
        //Shrinivas for R4B2 - 20/04/2012
        NSString * _searchForString = [searchForString substringFromIndex:1];
        NSString * querystring2 = @"";
        SMLog(@"%d", [searchForString length]);
        if ([searchForString length] > 1)
        {
            querystring2 = [NSString stringWithFormat:@"Select %@ , Id from '%@'  WHERE  Id  NOT NULL   AND Id != '' and %@ LIKE '%%%@%%' ", default_column_name, object, default_column_name, _searchForString];
        }
		else
		{
            querystring2 = [NSString stringWithFormat:@"Select %@ , Id from '%@'  WHERE  Id  NOT NULL   AND Id != '' ", default_column_name, object];
        }
        
        sqlite3_stmt * stmt;
        
        if(synchronized_sqlite3_prepare_v2(appDelegate.db, [querystring2 UTF8String], -1, &stmt, nil) == SQLITE_OK)
        {
            while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
            {
                NSMutableArray *subdataArray = [[NSMutableArray alloc]initWithCapacity:0];
                NSString *field1 , * field2;
                char *_field1 = (char *) synchronized_sqlite3_column_text(stmt,0);
                if ( _field1 != nil ) 
                {
                    field1 = [[NSString alloc]initWithUTF8String:_field1];
                }
                else
                {
                    field1 = @"";
                }
                char *_field2 = (char *) synchronized_sqlite3_column_text(stmt,1);
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
        }
        synchronized_sqlite3_finalize(stmt);
        
        NSMutableArray *sequenceArray = [[NSMutableArray alloc]initWithCapacity:0];
        
        NSMutableDictionary *sequence_dict = [NSMutableDictionary dictionaryWithObject:default_column_name forKey:@"1"];
        [sequenceArray addObject:sequence_dict];
        
        finalDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:each_record,sequenceArray,default_column_name, nil] forKeys:_dictKeys];
    }
    else
    {
		//Sahana Fixed
        if([searchForString isEqualToString:@" "] )
        {
            searchForString = [searchForString stringByReplacingOccurrencesOfString:@" " withString:@""];
        }
		else
		{  //shrinivas fixed for search -- R4B2
            if([searchForString length] > 0)
				searchForString = [searchForString substringFromIndex:0];
        }

        NSString *querystring1 = [NSString stringWithFormat:@"Select DISTINCT field_name,search_object_field_type,sequence,field_type,field_relationship_name from '%@' where named_search = '%@'",SFNAMEDSEACHCOMPONENT, lookupID];
        NSString * field_name = @"";
        NSString * sequence   = @"";
        NSString * field_seach_type = @"";
        NSString * field_type = @"";
        NSString * field_relationShip_name = @"";
        sqlite3_stmt * stmt;
        if(synchronized_sqlite3_prepare_v2(appDelegate.db, [querystring1 UTF8String], -1, &stmt, nil) == SQLITE_OK  ) 
        {
            while(synchronized_sqlite3_step(stmt) == SQLITE_ROW) 
            {
                field_name = @"";
                sequence   = @"";
                field_seach_type = @"";
                field_type = @"";
                field_relationShip_name = @"";
                
                char * temp_field_name = (char *) synchronized_sqlite3_column_text(stmt, 0);
                if ( temp_field_name != nil ) 
                {
                    field_name= [NSString stringWithUTF8String:temp_field_name];
                }
                char * temp_field_seach_type = (char *) synchronized_sqlite3_column_text(stmt, 1);
                if ( temp_field_seach_type != nil ) 
                {
                    field_seach_type = [NSString stringWithUTF8String:temp_field_seach_type];
                }
                char * temp_sequence = (char *) synchronized_sqlite3_column_text(stmt, 2);
                if ( temp_sequence != nil ) 
                {
                    sequence= [NSString stringWithUTF8String:temp_sequence];
                }
                char * temp_field_type = (char *) synchronized_sqlite3_column_text(stmt, 3);
                if(temp_field_type != nil)
                {
                    field_type = [NSString stringWithUTF8String:temp_field_type];
                }
                char * temp_field_relation_ship_name = (char *) synchronized_sqlite3_column_text(stmt, 4);
                if(temp_field_relation_ship_name != nil)
                {
                    field_relationShip_name = [NSString stringWithUTF8String:temp_field_relation_ship_name];
                }
                
                
                if([field_seach_type isEqualToString:@"Search"])
                {
                    [searchable_fields addObject:field_name];
                }
                else if([field_seach_type isEqualToString:@"Result"])
                {
                    [results_array addObject:field_name];
                    
                    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:field_name, field_seach_type,sequence,field_type,field_relationShip_name,nil] forKeys:field_keys];
                    [fields_array addObject:dict];
                }
            }
        }
        
        [results_array addObject:@"Id"];
        NSMutableString *result_fieldNames = [[NSMutableString alloc]initWithCapacity:0];
        
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
        
        //Sahana Fixed
        if([searchForString isEqualToString:@" "] )
        {
            searchForString = [searchForString stringByReplacingOccurrencesOfString:@" " withString:@""];
        }
		else
		{
			//shrinivas fixed for search -- R4B2
			if([searchForString length] > 0)
				searchForString = [searchForString substringFromIndex:1];
        }

        NSMutableString * searchFieldNames  = [[NSMutableString alloc] initWithCapacity:0];
        NSMutableString  * newSearch_string  = [[NSMutableString alloc] initWithCapacity:0];
        [newSearch_string appendFormat:@"%%%@%%",searchForString];
        
		//Shrinivas Change for look Up search start
		NSMutableDictionary * field_referenceDict = [[NSMutableDictionary alloc] initWithCapacity:0];

		for(NSString * fieldName in searchable_fields)
		{
			NSMutableArray * refernceTo = [self getReferenceToForField:fieldName objectapiName:object tableName:SFREFERENCETO];
			if([refernceTo  count] > 0)
			{
				NSString * referenceToFieldName = [refernceTo objectAtIndex:0];
				[field_referenceDict setObject:referenceToFieldName forKey:fieldName];
			}
		}
		
		NSArray * referenceFields = [field_referenceDict allKeys];
        for(int j = 0 ; j < [searchable_fields count]; j++)
        {
            NSString * search_field = [searchable_fields objectAtIndex:j];
			NSString * cus_searchField = @"";
			if([search_field length] != 0 && [newSearch_string length] != 0 && newSearch_string != nil )
            {
				if([referenceFields containsObject:search_field])
				{
					NSString * referenceTo = [field_referenceDict objectForKey:search_field];
					cus_searchField = [NSString stringWithFormat:@" %@ In (SELECT  Id From %@ Where Name LIKE '%@') " , search_field,referenceTo,newSearch_string];
				}
				else
				{
					cus_searchField = [NSString stringWithFormat:@" %@ LIKE '%@' ",search_field,newSearch_string];
				}
				
                if(j == 0 )
                {
					[searchFieldNames appendFormat:@"( %@  ",cus_searchField];
                }
                else
                {
					[searchFieldNames appendFormat:@"  OR %@  ",cus_searchField];
                }
            }
        }
        
        if([searchable_fields count] > 0)
        {
            [searchFieldNames appendFormat:@" )  AND ( Id  NOT NULL AND Id != ' ')"];
        }
        else
        {
            [searchFieldNames appendFormat:@"  Id  NOT NULL AND Id != ' ' "];
        }
        
        NSString * querystring2 = [NSString stringWithFormat:@"Select %@ from '%@'  where %@ ", result_fieldNames, object, searchFieldNames];
              
        if(synchronized_sqlite3_prepare_v2(appDelegate.db, [querystring2 UTF8String], -1, &stmt, nil) == SQLITE_OK)
        {
            while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
            {
                NSMutableArray *subdataArray = [[NSMutableArray alloc]initWithCapacity:0];
                NSString *field1;
                for(int i = 0 ; i < [results_array count]; i++)
                {
                    char *_field1 = (char *) synchronized_sqlite3_column_text(stmt,i);
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
			
			//Shrinivas : Fix for defect : 5916
			NSString * is_standard  = [look_up objectForKey:LOOkUP_IS_DEFAULT]; //Please verufy this change before commiting contact coder : Shrinivas D
            if([is_standard boolValue])
            {
                default_display_column = [look_up objectForKey:LOOKUP_DEFAULT_LOOK_UP_CLMN];
            }
        }
        
        finalDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:each_record, sequenceArray,default_display_column, nil] forKeys:_dictKeys];        
        
    }
	[each_record release];
    
    return finalDict;
}

-(NSString *)getTheDefaultDisplayColumnForLookUpId:(NSString *)lookup_id 
{
    NSString * query = [NSString stringWithFormat:@"SELECT SVMXC_Field_Name_c FROM '%@' where Id = '%@' and default_desplay_column = '%@' ",SFCONFIG_DATA_TABLE ,lookup_id,@"true" ];
    sqlite3_stmt * stmt ;
    NSString * field_name = @"";
    
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(stmt)  == SQLITE_ROW) 
        {
            char * value = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if(value != nil)
            {
                field_name = [NSString stringWithUTF8String:value];
            }
        }
    }
    synchronized_sqlite3_finalize(stmt);
    return field_name;
}

-(NSString *)queryForExpression:(NSString *)expression_id forObject:(NSString *)object_name;
{
    NSString * query = [NSString stringWithFormat:@"SELECT expression FROM '%@' where expression_id = '%@'",SFEXPRESSION, expression_id];
    sqlite3_stmt * stmt ;
    NSString * expression = @"";
    
    NSString * final_expr = @"";
    SMLog(@"%@", query);
    
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(stmt)  == SQLITE_ROW) 
        {
            char * value = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if(value != nil)
            {
                expression = [NSString stringWithUTF8String:value];
            }
        }
    }
    synchronized_sqlite3_finalize(stmt);

    final_expr = [appDelegate.databaseInterface queryForExpressionComponent:expression expression_id:expression_id object_name:object_name];

    return final_expr;
    
}


-(NSString *) queryForExpressionComponent:(NSString *)expression expression_id:(NSString *)expression_id object_name:(NSString *)object_name;
{
   
    NSString  * expression_ = expression;
    
    NSString * modified_expr = [expression_ stringByReplacingOccurrencesOfString:@"(" withString:@"#(#"];
    modified_expr = [modified_expr stringByReplacingOccurrencesOfString:@")" withString:@"#)#"];
    modified_expr  = [modified_expr stringByReplacingOccurrencesOfString:@"and" withString:@"#and#"];
    modified_expr  = [modified_expr stringByReplacingOccurrencesOfString:@"AND" withString:@"#AND#"];
    modified_expr  = [modified_expr stringByReplacingOccurrencesOfString:@"OR" withString:@"#OR#"];
    modified_expr = [modified_expr stringByReplacingOccurrencesOfString:@"or" withString:@"#or#"];
    
    NSArray * array = [modified_expr componentsSeparatedByString:@"#"];
    
    
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
        else if([str isEqualToString:@"or"] || [str isEqualToString:@"OR"])
        {
            [operators addObject:str];
        }
        else if([str isEqualToString:@"and"] || [str isEqualToString:@"AND"])
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
    
    NSString * lhs_value;
    
    for(int j = 0 ; j<[components count]; j++)
    {
        NSString * component_number = [components objectAtIndex:j];
        int f = [component_number intValue];
        NSString * appended_component_number = [NSString stringWithFormat:@"%d.0000",f];
    
        
        NSString * query = [NSString stringWithFormat:@"SELECT component_lhs , component_rhs , operator  FROM '%@' where expression_id = '%@'  and component_sequence_number = '%@'",SFEXPRESSION_COMPONENT, expression_id ,appended_component_number];
        
		//SMLog(@"%@", query);
        SMLog(@"%@",query);
        sqlite3_stmt * stmt ;
        
        NSString * component_lhs = @"";
        
        NSString * component_rhs = @"";
        
        NSString * component_operator = @"";
        
        NSString * operator_ = @"";
        
        if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
        {
            while (synchronized_sqlite3_step(stmt)  == SQLITE_ROW) 
            {
                operator_ = @"";
                component_lhs = @"";
                component_rhs = @"";
                
                
                char * lhs = (char *)synchronized_sqlite3_column_text(stmt, 0);
                if(lhs != nil)
                {
                    component_lhs = [NSString stringWithUTF8String:lhs];
                }
                
                char * rhs = (char *)synchronized_sqlite3_column_text(stmt, 1);
                if(rhs != nil)
                {
                    component_rhs = [NSString stringWithUTF8String:rhs];
                    if([component_rhs rangeOfString:@"true" options:NSCaseInsensitiveSearch].length>0 )
                    {
                        component_rhs=[component_rhs lowercaseString];
                        component_rhs=[component_rhs stringByReplacingOccurrencesOfString:@"true" withString:@"1" ];
                        
                    }
                    else if([component_rhs rangeOfString:@"false" options:NSCaseInsensitiveSearch].length>0)
                    {
                        component_rhs=[component_rhs lowercaseString];
                        component_rhs=[component_rhs stringByReplacingOccurrencesOfString:@"false" withString:@"0"];

                    }
                }
                
                char * operator = (char *)synchronized_sqlite3_column_text(stmt, 2);
                if(operator != nil)
                {
                    component_operator = [NSString stringWithUTF8String:operator];
                }
                
                if([component_lhs length] != 0 && [component_operator length] != 0)
                {
                    
                    SMLog(@"component_operator %@",component_operator);
                    
                    if([component_operator isEqualToString:@"eq"])
                    {
                        operator_  = @"=";
                    }
                    else if([component_operator isEqualToString:@"gt"])
                    {
                        operator_  = @">";
                    }
                    else if([component_operator isEqualToString:@"lt"])
                    {
                          operator_  = @"<";
                    }
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
						//#4722 defect fix for wizard billing type null
                        operator_ = @"isnotnull";
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
                    else if([component_operator  isEqualToString:@"isnull"])
                    {
                        lhs_value = component_lhs;
                        component_lhs = [NSString stringWithFormat:@"%@", component_lhs];
                        operator_ = @"=";
                        component_rhs = @"null";
                    }
                    
                    SMLog(@"%@" ,operator_ );
                    
                    if([operator_ length] != 0)
                    {
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
                                if(count >0)
                                [temp appendString:@"%%,"];
                                [temp appendFormat:@"%@",value];
                                if(count >0)
                                [temp appendString:@",%%"];
                                component_rhs = [temp retain];
                                NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:component_lhs,component_rhs,operator_ ,seq,nil] forKeys:keys];
                                NSMutableDictionary * component_dict = [NSMutableDictionary dictionaryWithObject:dict forKey:component_number];
                                [final_Comonent_array addObject:component_dict];
                                
                                [temp release];
                                count ++;
                            }  
                        }
                        else
                        {
                            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:component_lhs,component_rhs,operator_ ,@"",nil] forKeys:keys];
                            NSMutableDictionary * component_dict = [NSMutableDictionary dictionaryWithObject:dict forKey:component_number];
                            [final_Comonent_array addObject:component_dict];
                        }
                    }
                    SMLog(@"%@",expression_);
                }
            }
        }
        synchronized_sqlite3_finalize(stmt);
        
    }

    SMLog(@" final component array %@",final_Comonent_array);
    
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
            NSString * data_type = [[appDelegate.databaseInterface getFieldDataType:object_name filedName:lhs] lowercaseString];

            // This check is for RecordTypeId
            if([lhs isEqualToString:@"RecordTypeId"])
            {
                component_expression = [NSString stringWithFormat:@" RecordTypeId   in   (select  record_type_id  from SFRecordType where record_type = '%@' )" , rhs];
                
            }
            else if([data_type isEqualToString:@"reference"])
            {
				NSString * referenceToTable = [appDelegate.dataBase getReferencetoFiledForObject:object_name api_Name:lhs];
				if([operator isEqualToString:@"isnotnull"]) //#4722 defect fix for wizard billing type null
				{
                    operator = @"!=";
                    NSString * temp_operator = @"is not null";
                    
                    component_expression = [NSString stringWithFormat:@" ( %@ %@ null or trim(%@) %@ or ( trim(%@) != '') ) ",lhs,operator,lhs,temp_operator, lhs];
				}
                else if ([rhs isEqualToString:@"null"])
                {
                     component_expression = [NSString stringWithFormat:@" ( %@ = ' ' or typeof(%@) %@ '%@' or %@ = '' ) ",lhs,lhs,operator,rhs, lhs]; 
                }
				else
				{
					component_expression = [NSString stringWithFormat:@" %@   in   (select  Id  from %@ where Name %@ '%@' )" , lhs,referenceToTable , operator ,rhs];
				}
                
            }
            else if ([operator isEqualToString: @"!="])
            {
                component_expression = [NSString stringWithFormat:@" ( %@ isnull or %@ %@ '%@' ) ",lhs,lhs,operator,rhs];
            }
			else if([operator isEqualToString:@"isnotnull"]) //#4722 defect fix for wizard billing type null
			{
				//#4722 defect fix for wizard billing type null
				operator = @"!=";
				NSString * temp_operator = @"is not null";
				
				component_expression = [NSString stringWithFormat:@" ( %@ %@ null or trim(%@) %@ or ( trim(%@) != '') ) ",lhs,operator,lhs,temp_operator, lhs];
			}
            //Test
            else if ([rhs isEqualToString:@"null"])
            {
                component_expression = [NSString stringWithFormat:@" ( %@ = ' ' or typeof(%@) %@ '%@' or %@ = '' ) ",lhs,lhs,operator,rhs, lhs];            
            }
            else
            {
                component_expression = [component_expression stringByAppendingString:lhs];
                component_expression = [component_expression stringByAppendingString:operator];
                rhs = [NSString stringWithFormat:@"'%@'",rhs];
                component_expression = [component_expression stringByAppendingString:rhs];
            }
            
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
            SMLog(@"%@", component_expression);
            regular_expression = [regular_expression stringByReplacingOccurrencesOfString:concatinate_key withString:component_expression];
        }
    }
        
    NSString * retExpression = @"";
    if ([regular_expression length] > 0)
    {
        retExpression = [NSString stringWithFormat:@"(%@)", regular_expression];
    }
    else
    {
        retExpression = [NSString stringWithFormat:@"%@", regular_expression];
    }
    
    return retExpression;
}

-(BOOL)validateTheExpressionForRecordId:(NSString *)record_id objectName:(NSString *)objectName expression:(NSString *)expression
{
    BOOL flag = FALSE;
    if(record_id != nil && [record_id length] != 0 && objectName != nil && [objectName length] != 0)
    {
        NSString * query;
        if([expression length]!= 0 && expression != nil)
            query = [NSString stringWithFormat:@"SELECT COUNT(*)  FROM '%@' where local_id = '%@' and ( %@ ) ",objectName, record_id, expression];
        else
            query = [NSString stringWithFormat:@"SELECT COUNT(*)  FROM '%@' where local_id = '%@' ",objectName, record_id];
        
        sqlite3_stmt * stmt ;
        
        if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
        {
            while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
            {
                NSString * count = @"";
                char * value = (char *)synchronized_sqlite3_column_text(stmt, 0);
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
        
        synchronized_sqlite3_finalize(stmt);
        return flag;
    }
    else
    {
        return flag;
    }
}

//For Action Buttons 
-(NSMutableDictionary *)getWizardInformationForObjectname:(NSString *) objectName  record_id:(NSString *)record_id
{
    NSMutableDictionary * wizard_dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSMutableArray * wizard_array = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray * wizard_ids_array = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray * wizard_buttons_array = [[NSMutableArray alloc] initWithCapacity:0]; 
    NSString * query = [NSString stringWithFormat:@"SELECT wizard_id , expression_id , wizard_description, wizard_name  FROM '%@' where object_name = '%@'" ,SFWIZARD , objectName];
    NSString * wizard_id = @"";
    NSString * expression_id = @"";
    NSString * wizard_description = @"";
    NSString * wizard_title = @"";  //RADHA
    NSArray * keys = [NSArray arrayWithObjects:WIZARD_ID,WIZARD_DESCRIPTION, WIZARD_TITLE, nil];
    sqlite3_stmt * stmt ;
    
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * temp_wizard_id = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if(temp_wizard_id != nil)
            {
                wizard_id = [NSString stringWithUTF8String:temp_wizard_id];
            }
            
            char * temp_expression_id = (char *)synchronized_sqlite3_column_text(stmt, 1);
            if(temp_expression_id != nil)
            {
                expression_id = [NSString stringWithUTF8String:temp_expression_id];
            }
            
            char * temp_wizard_description = (char *)synchronized_sqlite3_column_text(stmt, 2);
            if(temp_wizard_description != nil)
            {
                wizard_description = [NSString stringWithUTF8String:temp_wizard_description];
            }
            
            char * temp_wizard_name = (char *)synchronized_sqlite3_column_text(stmt, 3);
            if (temp_wizard_name != nil)
            {
                wizard_title = [NSString stringWithUTF8String:temp_wizard_name];
            }
            
            if([expression_id length] != 0)
            {
                NSString * expression = [appDelegate.databaseInterface queryForExpression:expression_id forObject:objectName];
                BOOL flag = [appDelegate.databaseInterface validateTheExpressionForRecordId:record_id objectName:objectName expression:expression];
                if(flag)
                {
                    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:wizard_id,wizard_description, wizard_title, nil] forKeys:keys];
                    [wizard_array addObject:dict];
                    [wizard_ids_array addObject:wizard_id];
                }
                
            }
            else
            {
                NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:wizard_id,wizard_description, wizard_title, nil] forKeys:keys];
                [wizard_array addObject:dict];
                [wizard_ids_array addObject:wizard_id];
            }
        }
    }
    synchronized_sqlite3_finalize(stmt);
    if([wizard_ids_array count] > 0)
    {
        wizard_buttons_array  = [appDelegate.databaseInterface getButtonsForWizardInformation:wizard_ids_array record_id:record_id object_name:objectName]; 
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
    
    NSString * perfom_sync = @"";
    NSString * class_name = @"";
    NSString * method_name = @"";
    
    NSMutableArray * buttons_array = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSArray * keys = [NSArray arrayWithObjects:SFW_ACTION_ID,SFW_ACTION_DESCRIPTION,SFW_EXPRESSION_ID,SFW_PROCESS_ID,SFW_ACTION_TYPE ,SFW_WIZARD_ID,SFW_ENABLE_ACTION_BUTTON,  PERFORM_SYNC, CLASS_NAME, METHOD_NAME, nil]; 
    
    for(int i = 0 ; i <[wizard_ids_array count]; i++)
    {
        NSString * wizard_id = [wizard_ids_array objectAtIndex:i];
        
        if(wizard_id != nil && [wizard_id length] != 0)
        {
           
            NSString * query = [NSString stringWithFormat:@"SELECT action_id , action_description, expression_id , process_id ,action_type, perform_sync, class_name, method_name FROM '%@' where wizard_id ='%@'" ,SFWizard_COMPONENT , wizard_id];
            
            sqlite3_stmt * stmt ;
            
            if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
            {
                while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
                {
                    action_id = @"";
                    action_description = @"";
                    expression_id = @"";
                    process_id = @"";
                    action_type = @"";
                    
                    char * temp_action_id = (char *)synchronized_sqlite3_column_text(stmt, 0);
                    if(temp_action_id != nil)
                    {
                        action_id = [NSString stringWithUTF8String:temp_action_id];
                    }
                    
                    char * temp_action_description = (char *)synchronized_sqlite3_column_text(stmt, 1);
                    if(temp_action_description != nil)
                    {
                        action_description = [NSString stringWithUTF8String:temp_action_description];
                    }
                    
                    char * temp_expression_id = (char *)synchronized_sqlite3_column_text(stmt, 2);
                    if(temp_expression_id != nil)
                    {
                        expression_id  = [NSString stringWithUTF8String:temp_expression_id];
                    }
                    
                    char * temp_process_id = (char *)synchronized_sqlite3_column_text(stmt, 3);
                    if(temp_process_id != nil)
                    {
                        process_id = [NSString stringWithUTF8String:temp_process_id];
                    }
                    
                    char * temp_action_type = (char *)synchronized_sqlite3_column_text(stmt, 4);
                    if(temp_action_type != nil)
                    {
                        action_type = [NSString stringWithUTF8String:temp_action_type];
                    }
                    
                    char * temp_perform_sync = (char *)synchronized_sqlite3_column_text(stmt, 5);
                    if(temp_perform_sync != nil)
                    {
                        if (strlen(temp_action_type) && temp_action_type != nil)
                            perfom_sync = [NSString stringWithUTF8String:temp_perform_sync];
                    }
                    char * temp_class_name = (char *)synchronized_sqlite3_column_text(stmt, 6);
                    if(temp_class_name != nil)
                    {
                        if (strlen(temp_class_name) && temp_class_name != nil)
                            class_name = [NSString stringWithUTF8String:temp_class_name];
                    }
                    char * temp_method_name = (char *)synchronized_sqlite3_column_text(stmt, 7);
                    if(temp_method_name != nil)
                    {
                        if (strlen(temp_method_name) && temp_method_name != nil)
                            method_name = [NSString stringWithUTF8String:temp_method_name];
                    }
                    
                    if([expression_id length] != 0)
                    {
                        NSString * expression = [appDelegate.databaseInterface queryForExpression:expression_id forObject:objectName];
                        
                        BOOL flag = [appDelegate.databaseInterface validateTheExpressionForRecordId:record_id objectName:objectName expression:expression];
                        
                        if(flag)
                        {
                            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:action_id,action_description , expression_id, process_id, action_type , wizard_id, @"true",perfom_sync, class_name,method_name, nil] forKeys:keys];
                            [buttons_array addObject:dict];
                            
                        }
                        else
                        {
                            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:action_id,action_description , expression_id, process_id, action_type , wizard_id, @"false",perfom_sync, class_name,method_name, nil] forKeys:keys];
                            [buttons_array addObject:dict];
                        }
                    }
                    else
                    {
                        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:action_id,action_description , expression_id, process_id, action_type , wizard_id, @"true",perfom_sync, class_name,method_name, nil] forKeys:keys];
                        [buttons_array addObject:dict];
                        
                    }
                    
                }
            }
            synchronized_sqlite3_finalize(stmt);
        }
    }
    
    return buttons_array;
}

-(NSMutableArray *)getObjectMappingForMappingId:(NSMutableDictionary *)process_components  source_record_id:(NSString *)source_record_id field_name:(NSString *)field_name
{
    NSMutableArray * final_array = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    NSMutableDictionary * final_dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSMutableArray * local_array = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSString * object_mapping_id = [process_components objectForKey:OBJECT_MAPPING_ID];
    NSString * value_mapping_id = [process_components objectForKey:VALUE_MAPPING_ID];
    NSString * expression_id = [process_components objectForKey:EXPRESSION_ID];
    NSString * source_object_name = [process_components objectForKey:SOURCE_OBJECT_NAME]; 
    NSString * target_object_name = [process_components objectForKey:TARGET_OBJECT_NAME];
    NSString * source_field_name = @"";
    NSString * target_field_name = @"";
    NSString * mapping_value = @"";
    NSString * mapping_value_flag = @"";
    NSString * mapping_component_type = @"";
    NSString * expression_ = [appDelegate.databaseInterface  queryForExpression:expression_id forObject:source_object_name];
    
    if(object_mapping_id != nil || [object_mapping_id length] != 0 )
    {
        NSString * query = [NSString stringWithFormat:@"SELECT source_field_name , target_field_name, mapping_value ,mapping_value_flag,mapping_component_type FROM %@ where object_mapping_id = '%@'",OBJECT_MAPPING_COMPONENT, object_mapping_id];
        sqlite3_stmt * stmt ;
        if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
        {
            while (synchronized_sqlite3_step(stmt)  == SQLITE_ROW) 
            {
                
                source_field_name = @"";
                target_field_name = @"";
                mapping_value = @"";
                mapping_value_flag = @"";
                mapping_component_type = @"";
                
                char * temp_source_field_name = (char *)synchronized_sqlite3_column_text(stmt, 0);
                if(temp_source_field_name != nil)
                {
                    source_field_name = [NSString stringWithUTF8String:temp_source_field_name];
                }
                
                char * temp_target_field_name = (char *)synchronized_sqlite3_column_text(stmt, 1);
                if(temp_target_field_name != nil)
                {
                    target_field_name = [NSString stringWithUTF8String:temp_target_field_name];
                }
                
                char * temp_mapping_value = (char *)synchronized_sqlite3_column_text(stmt, 2);
                if(temp_mapping_value != nil)
                {
                    mapping_value = [NSString stringWithUTF8String:temp_mapping_value];
                }
                
                char * temp_mapping_value_flag = (char *)synchronized_sqlite3_column_text(stmt, 3);
                if(temp_mapping_value_flag != nil)
                {
                    mapping_value_flag = [NSString stringWithUTF8String:temp_mapping_value_flag];
                }
                
                char * temp_mapping_component_type = (char *)synchronized_sqlite3_column_text(stmt, 4);
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
                if([mapping_component_type isEqualToString:VALUE_MAPPING])
                {
                    if(target_field_name != 0 && [target_field_name length] != 0)
                    {
                        
                        [final_dict  setObject:mapping_value forKey:target_field_name];
                        
                        NSString * data_type = [appDelegate.databaseInterface getFieldDataType:target_object_name filedName:target_field_name];
                        
                        NSTimeInterval secondsPerDay = 24 * 60 * 60;
                        
                        NSString * today_Date ,* tomorow_date ,* yesterday_date;
                        
                        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
                        
                        NSDate *today = [[[NSDate alloc] init] autorelease];;
                        
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
                            
                            if([mapping_value caseInsensitiveCompare:MACRO_TODAY]== NSOrderedSame)
                            {
                                [final_dict setObject:today_Date forKey:target_field_name];
                                
                            }
                            else if([mapping_value caseInsensitiveCompare:MACRO_TOMMOROW] == NSOrderedSame)
                            {
                                [final_dict setObject:tomorow_date forKey:target_field_name];
                                
                            }
                            else if([mapping_value caseInsensitiveCompare:MACRO_YESTERDAY] == NSOrderedSame)
                            {
                                [final_dict setObject:yesterday_date forKey:target_field_name];
                            }
                            
                        }
                        
                        if([data_type isEqualToString:@"datetime"])
                        {
                            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                            
							[dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
                            
                            today_Date = [dateFormatter stringFromDate:today];
                            today_Date = [today_Date stringByReplacingOccurrencesOfString:@" " withString:@"T"];
                            
                            tomorow_date = [dateFormatter stringFromDate:tomorrow];
                            tomorow_date = [tomorow_date stringByReplacingOccurrencesOfString:@" " withString:@"T"];
                            
                            yesterday_date = [dateFormatter stringFromDate:yesterday];
                            yesterday_date = [yesterday_date stringByReplacingOccurrencesOfString:@" " withString:@"T"];
                            
                            if([mapping_value caseInsensitiveCompare:MACRO_NOW] == NSOrderedSame)
                            {
                                [final_dict setObject:today_Date forKey:target_field_name];
                            }
                            else if([mapping_value caseInsensitiveCompare:MACRO_TODAY] == NSOrderedSame)
                            {
                                [final_dict setObject:today_Date forKey:target_field_name];
                            }
                            else if([mapping_value caseInsensitiveCompare:MACRO_TOMMOROW] == NSOrderedSame)
                            {
                                [final_dict setObject:tomorow_date forKey:target_field_name];
                            }
                            else if([mapping_value caseInsensitiveCompare:MACRO_YESTERDAY] == NSOrderedSame)
                            {
                                [final_dict setObject:yesterday_date forKey:target_field_name];
                            }
                        }
                        if([target_field_name isEqualToString:@"RecordTypeId"])
                        {   
                            NSString * query = [NSString stringWithFormat:@"SELECT record_type_id FROM  SFRecordType where object_api_name = '%@' and record_type = '%@'" ,target_object_name,mapping_value];
                            NSString * record_type_id = @"";
                            
                            SMLog(@"RecordTypeId  valuemapping %@" ,query);
                            sqlite3_stmt * recordTypeId_statement ;
                            if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &recordTypeId_statement, nil) == SQLITE_OK)
                            {
                                while (synchronized_sqlite3_step(recordTypeId_statement) == SQLITE_ROW)
                                {
                                    char * temp_record_type_id = (char *) synchronized_sqlite3_column_text(recordTypeId_statement, 0);
                                    if(temp_record_type_id != nil)
                                    {
                                        record_type_id = [NSString stringWithUTF8String:temp_record_type_id];
                                    }
                                }
                            }
                            synchronized_sqlite3_finalize(recordTypeId_statement);
                            if(![record_type_id isEqualToString:@""])
                            {
                                mapping_value = record_type_id;
                            }
                            else
                            {
                                mapping_value = @"";
                            }
                            
                            [final_dict  setObject:mapping_value forKey:target_field_name];
                            
                        }
                        
                        
                        if ([mapping_value isEqualToString:MACRO_CURRENTUSER])
                        {
                            [final_dict setObject:appDelegate.username forKey:target_field_name];
                        }
                        else if ([mapping_value isEqualToString:MACRO_RECORDOWNER])
                        {
                            [final_dict setObject:MACRO_RECORDOWNER forKey:target_field_name];
                        }
                    }
                }
                
                if([mapping_component_type isEqualToString:FIELD_MAPPING])
                {
                    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:source_field_name, target_field_name, mapping_value, mapping_value_flag, mapping_component_type, nil] forKeys:[NSArray arrayWithObjects:SFOBJMAPPING_SOURCE_FIELD,SFOBJMAPPING_TARGET_FIELD,SFOBJMAPPING_MAPPING_VALUE,SFOBJMAPPING_MAPPINGVALUE_FLAG,SFOBJMAPPING_COMPONENT_TYPE, nil]];

                    [local_array addObject:dict];
                    
                }
                
            }
        }
        synchronized_sqlite3_finalize(stmt);
        
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
        if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
        {
            while (synchronized_sqlite3_step(stmt)  == SQLITE_ROW) 
            {
                
                source_field_name = @"";
                target_field_name = @"";
                mapping_value = @"";
                mapping_value_flag = @"";
                mapping_component_type = @"";
                
                char * temp_source_field_name = (char *)synchronized_sqlite3_column_text(stmt, 0);
                if(temp_source_field_name != nil)
                {
                    target_field_name = [NSString stringWithUTF8String:temp_source_field_name];
                }
                
                char * temp_target_field_name = (char *)synchronized_sqlite3_column_text(stmt, 1);
                if(temp_target_field_name != nil)
                {
                    target_field_name = [NSString stringWithUTF8String:temp_target_field_name];
                }
                
                char * temp_mapping_value = (char *)synchronized_sqlite3_column_text(stmt, 2);
                if(temp_mapping_value != nil)
                {
                    mapping_value = [NSString stringWithUTF8String:temp_mapping_value];
                }
                
                char * temp_mapping_value_flag = (char *)synchronized_sqlite3_column_text(stmt, 3);
                if(temp_mapping_value_flag != nil)
                {
                    mapping_value_flag = [NSString stringWithUTF8String:temp_mapping_value_flag];
                }
                
                char * temp_mapping_component_type = (char *)synchronized_sqlite3_column_text(stmt, 4);
                if(temp_mapping_component_type != nil)
                {
                    mapping_component_type = [NSString stringWithUTF8String:temp_mapping_component_type];
                }
                
                //check whether the value is 
                if([mapping_component_type isEqualToString:VALUE_MAPPING])
                {
                    if(target_field_name != 0 && [target_field_name length] != 0)
                    {
                        [final_dict  setObject:mapping_value forKey:target_field_name];
                        
                        NSString * data_type = [appDelegate.databaseInterface getFieldDataType:target_object_name filedName:target_field_name];
                        
                        NSTimeInterval secondsPerDay = 24 * 60 * 60;
                        
                        NSString * today_Date ,* tomorow_date ,* yesterday_date;
                        
                        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
                        
                        NSDate *today = [[[NSDate alloc] init] autorelease];;
                        
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
                                [final_dict setObject:today_Date forKey:target_field_name];
                                
                            }
                            else if([mapping_value isEqualToString:MACRO_TOMMOROW])
                            {
                                [final_dict setObject:tomorow_date forKey:target_field_name];
                                
                            }
                            else if([mapping_value isEqualToString:MACRO_YESTERDAY])
                            {
                                [final_dict setObject:yesterday_date forKey:target_field_name];
                            }
                            
                        }
                        
                        if([data_type isEqualToString:@"datetime"])
                        {
                            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                            
							[dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
                            
                            today_Date = [dateFormatter stringFromDate:today];
                            today_Date = [today_Date stringByReplacingOccurrencesOfString:@" " withString:@"T"];
                            
                            tomorow_date = [dateFormatter stringFromDate:tomorrow];
                            tomorow_date = [tomorow_date stringByReplacingOccurrencesOfString:@" " withString:@"T"];
                            
                            yesterday_date = [dateFormatter stringFromDate:yesterday];
                            yesterday_date = [yesterday_date stringByReplacingOccurrencesOfString:@" " withString:@"T"];
                            
                            if([mapping_value isEqualToString:MACRO_NOW])
                            {
                                [final_dict setObject:today_Date forKey:target_field_name];
                            }
                            else if([mapping_value isEqualToString:MACRO_TODAY])
                            {
                                [final_dict setObject:today_Date forKey:target_field_name];
                            }
                            else if([mapping_value isEqualToString:MACRO_TOMMOROW])
                            {
                                [final_dict setObject:tomorow_date forKey:target_field_name];
                            }
                            else if([mapping_value isEqualToString:MACRO_YESTERDAY])
                            {
                                [final_dict setObject:yesterday_date forKey:target_field_name];
                            }
                            
                        }
                        if([target_field_name isEqualToString:@"RecordTypeId"])
                        {
                            NSString * query = [NSString stringWithFormat:@"SELECT record_type_id FROM  SFRecordType where object_api_name = '%@' and record_type = '%@'" ,target_object_name,mapping_value];
                            NSString * record_type_id = @"";
                            
                            SMLog(@"RecordTypeId  valuemapping %@" ,query);
                            sqlite3_stmt * recordTypeId_statement ;
                            if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &recordTypeId_statement, nil) == SQLITE_OK)
                            {
                                while (synchronized_sqlite3_step(recordTypeId_statement) == SQLITE_ROW)
                                {
                                    char * temp_record_type_id = (char *) synchronized_sqlite3_column_text(recordTypeId_statement, 0);
                                    if(temp_record_type_id != nil)
                                    {
                                        record_type_id = [NSString stringWithUTF8String:temp_record_type_id];
                                    }
                                }
                            }
                            synchronized_sqlite3_finalize(recordTypeId_statement);
                            if(![record_type_id isEqualToString:@""])
                            {
                                mapping_value = record_type_id;
                            }
                            else
                            {
                                mapping_value = @"";
                            }
                            [final_dict  setObject:mapping_value forKey:target_field_name];
                        }

                        
                        if ([mapping_value isEqualToString:MACRO_CURRENTUSER])
                        {
                            [final_dict setObject:appDelegate.username forKey:target_field_name];
                        }
                        else if ([mapping_value isEqualToString:MACRO_RECORDOWNER])
                        {
                            [final_dict setObject:MACRO_RECORDOWNER forKey:target_field_name];
                        }
                        
                    }
                                        
                }
                                
            }
        }
        synchronized_sqlite3_finalize(stmt);

    }
    NSArray * allkeys = [final_dict allKeys];
    
    if([source_record_id length ] != 0 && source_record_id != nil )
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
        NSString * query = @"";
        if(expression_ != nil && [expression_ length] != 0)
        {
            query = [NSString stringWithFormat:@"SELECT %@ FROM '%@' where %@ = '%@' and %@",query_field_names, source_object_name,field_name, source_record_id,expression_];
            SMLog(@"SOURCETOTARGET %@", query);
        }
        else
        {
            query = [NSString stringWithFormat:@"SELECT %@ FROM '%@' where %@ = '%@' ",query_field_names, source_object_name,field_name, source_record_id];
            SMLog(@"SOURCETOTARGET %@", query);
        }
       
        
        NSString * field_value = @"";
        sqlite3_stmt * stmt ;
        
        if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
        {
            while (synchronized_sqlite3_step(stmt)  == SQLITE_ROW) 
            {
                NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:0];
                
                for(int k = 0 ; k < [source_field_names count]; k++ )
                {
                    field_value = @"";
                    char * temp_field_value = (char *)synchronized_sqlite3_column_text(stmt,k);
                    if(temp_field_value != nil)
                    {
                        field_value = [NSString stringWithUTF8String:temp_field_value];
                    }
                    [dict setObject:field_value forKey:[target_field_names  objectAtIndex:k]];
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
        
        synchronized_sqlite3_finalize(stmt);
           
    }
    
    SMLog(@" Final array SOURCETOTARGET%@", final_array);
    return final_array;
}

-(NSString * )checkforSalesForceIdForlocalId:(NSString *)objectName local_id:(NSString *)local_id
{
    NSString * query = [NSString  stringWithFormat:@"SELECT Id FROM '%@' WHERE local_id = '%@' " , objectName , local_id];
    sqlite3_stmt * statement ;
    NSString * id_value = @"";
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            char * temp_id_value = (char *) synchronized_sqlite3_column_text(statement, 0);
            if(temp_id_value  != nil)
                id_value = [NSString stringWithUTF8String:temp_id_value];
            
        }
    }
    return id_value;
}

-(NSMutableArray *)getChildLocalIdForParentId:(NSString *)parent_id childTableName:(NSString *)childObjectName sourceTableName:(NSString *)sourceObjectName
{
    NSMutableArray * source_child_ids = [[NSMutableArray alloc] initWithCapacity:0];
    NSString * source_child_id ;
    
    NSString * parent_column_name = [appDelegate.databaseInterface getParentColumnNameFormChildInfoTable:SFChildRelationShip childApiName:childObjectName parentApiName:sourceObjectName];

    NSString * query = [NSString stringWithFormat:@"SELECT local_id FROM '%@' where %@ = '%@'",childObjectName, parent_column_name,parent_id ];
    
    sqlite3_stmt * stmt ;
    
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(stmt)  == SQLITE_ROW) 
        {
            source_child_id = @"";
            
            char * temp_child_id = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if(temp_child_id != nil)
            {
                source_child_id = [NSString stringWithUTF8String:temp_child_id];    
            }
            
            [source_child_ids addObject:source_child_id];
        }
    }
    
    synchronized_sqlite3_finalize(stmt);
    return source_child_ids;
}

-(NSString *)getprocessTypeForProcessId:(NSString *)process_id;
{
    NSString * process_Type = @"";
    NSString * query = [NSString stringWithFormat:@"SELECT process_type FROM '%@' WHERE process_id = '%@'",SFPROCESS, process_id];
    
    sqlite3_stmt * stmt;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(stmt)== SQLITE_ROW)
        {
            char * temp_process_type = (char *)synchronized_sqlite3_column_text(stmt, 0);
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
            if([value isKindOfClass:[NSString class]])
                value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            
            NSString * field_data_type = [self getFieldDataType:objectName filedName:key];
            
            if([field_data_type isEqualToString:@"boolean"])
            {
                //Radha
                if ([value isEqualToString:@"True"] || [value isEqualToString:@"true"] || [value isEqualToString:@"1"])
                {
                    value = @"1";
                }
                else
                {
                    value = @"0";
                }
            }
            if(i== 0)
                [updateValue  appendFormat:@" %@ = '%@' ",key ,value ];
            else
                [updateValue  appendFormat:@" , %@ = '%@' ",key ,value ];
        }
    }
    
    NSString * update_statement;
    
    if ([objectName isEqualToString:@"Case"])
        objectName = @"'Case'";
    
    if([updateValue length] != 0 && local_id != nil && [local_id length] != 0 )
        update_statement = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE local_id = '%@'",objectName ,updateValue,local_id];
    else if ( local_id != nil && [local_id length] != 0)
        return FALSE;
    else
        return TRUE;
    
    char * err;
    
    if(synchronized_sqlite3_exec(appDelegate.db, [update_statement UTF8String],NULL, NULL, &err) != SQLITE_OK)
    {
        success = FALSE;
        SMLog(@"%@", update_statement);
		SMLog(@"METHOD:UpdateTableforId " );
		SMLog(@"ERROR IN UPDATING %s", err);
    }
    else
    {
        success = TRUE;
    }
    
    return success;
}


-(BOOL)UpdateTableforSFId:(NSString *)sf_id  forObject:(NSString *)objectName  data:(NSDictionary *)dict1
{
    
	NSMutableDictionary * dict = [self updateEmptyFieldValuesForDict:dict1 objectName:objectName];
    NSString *  parent_column_name = [self getchildInfoFromChildRelationShip:SFCHILDRELATIONSHIP ForChild:objectName field_name:@"parent_column_name"];
    [dict removeObjectForKey:parent_column_name];
	
	BOOL success = FALSE;
    NSArray * allkeys = [dict allKeys];
    NSMutableString *  updateValue = [[[NSMutableString alloc] initWithCapacity:0] autorelease]; // sahana sep 13th
    for(int i = 0 ; i < [allkeys count]; i++)
    {
        NSString * key = [allkeys objectAtIndex:i];
        NSString * value = [dict objectForKey:key];
        if(value != nil)
        {
            //RADHA 19/01/12
            value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString * field_data_type = [self getFieldDataType:objectName filedName:key];
            
            if([field_data_type isEqualToString:@"boolean"])
            {
                //Radha
                if ([value isEqualToString:@"True"] || [value isEqualToString:@"true"] || [value isEqualToString:@"1"])
                {
                    value = @"1";
                }
                else
                {
                    value = @"0";
                }
            }
			
            if(i== 0)
                [updateValue  appendFormat:@" %@ = '%@' ",key ,value ];
            else
                [updateValue  appendFormat:@" , %@ = '%@' ",key ,value ];
        }
        
    }
    
    if ([objectName isEqualToString:@"Case"])
        objectName = @"'Case'";
    
    NSString * update_statement;
    if([updateValue length] != 0 && sf_id != nil && [sf_id length] != 0 )
        update_statement = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE Id = '%@'",objectName ,updateValue,sf_id];
    else if ( sf_id != nil && [sf_id length] != 0)
        return FALSE;
    else
        return TRUE;
    
    char * err;
    
    if(synchronized_sqlite3_exec(appDelegate.db, [update_statement UTF8String],NULL, NULL, &err) != SQLITE_OK)
    {
        success = FALSE;
        
		SMLog(@"%@", update_statement);
		SMLog(@"METHOD:UpdateTableforSFId " );
		SMLog(@"ERROR IN UPDATING %s", err);

    }
    else
    {
        success = TRUE;
    }
    
    return success;
}

#pragma mark - updateNullValue
- (NSMutableDictionary *) updateEmptyFieldValuesForDict:(NSDictionary *)dict objectName:(NSString *)objectName
{
	NSMutableDictionary * allFieldsDict = [self getAllObjectFields:objectName tableName:@"SFObjectField"];
	
	NSArray * allfield = [allFieldsDict allKeys];
	NSMutableArray * valueFields =  (NSMutableArray*)[dict allKeys];
	
	NSMutableDictionary * mDict  = [NSMutableDictionary dictionaryWithDictionary:dict];
	
	for (NSString * valueField in allfield)
	{
		if ([valueFields containsObject:valueField])
		{
			continue;
		}
		else
		{
			[mDict setValue:@"" forKey:valueField];
		}
		
	}
	
	return mDict;
}


#pragma mark -END
-(NSString *)getLookUpNameForId:(NSString *)id_ 
{
    NSString * query = [NSString  stringWithFormat:@"SELECT value from LookUpFieldValue where Id = '%@'" ,id_ ];
    sqlite3_stmt * stmt;
    NSString * name = @"";
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(stmt)== SQLITE_ROW)
        {
            char * temp_name = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if(temp_name != nil)
            {
                name =[NSString stringWithUTF8String:temp_name];
            }
        }
    }
    return name;
}

-(NSMutableDictionary *) getAllRecordsFromRecordsHeap
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    NSMutableArray * Objects_Array  = [[NSMutableArray alloc] initWithCapacity:0];
    NSString * query_ = [[NSString alloc ]initWithFormat:@"SELECT DISTINCT object_name from sync_Records_Heap where sync_flag = 'false'"];                 //18Apr 
     sqlite3_stmt * stmt_;
    NSString * object_name_temp =@"";
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query_ UTF8String], -1, &stmt_, nil) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(stmt_) == SQLITE_ROW)
        {
            object_name_temp =@"";
            char * temp_object_name = (char *)synchronized_sqlite3_column_text(stmt_, 0);
            if(temp_object_name != nil)
            {
                object_name_temp =[NSString stringWithUTF8String:temp_object_name];
            }
            [Objects_Array addObject:object_name_temp];
        }
    }
    
    [query_ release];
    for(NSString * obj in Objects_Array)
    {
    
        NSString * query = [[NSString alloc ]initWithFormat:@"SELECT sf_id, object_name from sync_Records_Heap where sync_flag = 'false' AND object_name = '%@' LIMIT 2500 ",obj];                                                                                         //18Apr 
        sqlite3_stmt * stmt;
        NSString * object_name = @"";
        NSString * sf_id = @"";
        if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
        {
            while (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
            {
                object_name = @"", sf_id = @"";
                
                char * temp_sf_id = (char *)synchronized_sqlite3_column_text(stmt, 0);
                if(temp_sf_id != nil)
                {
                    sf_id =[NSString stringWithUTF8String:temp_sf_id];
                }
                
                char * temp_object_name = (char *)synchronized_sqlite3_column_text(stmt, 1);
                if(temp_object_name != nil)
                {
                    object_name =[NSString stringWithUTF8String:temp_object_name];
                }
                
                NSArray * allkeys = [dict allKeys];
                BOOL flag = FALSE;
                
                for( NSString * temp in allkeys )
                {
                    if([temp isEqualToString:object_name])
                    {
                        NSMutableArray * array = [dict objectForKey:object_name];
                        [array addObject:sf_id];
                        flag = TRUE;
                        break;
                    }
                }
                if(!flag)
                {
                    NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:0] ;
                    [array addObject:sf_id];
                    [dict setObject:array forKey:object_name];
                    [array release];                //18Apr 
                }
            }
        }
        [query release];
    }
    
    [Objects_Array release];
    return dict;
}

-(void)updateAllRecordsToSyncRecordsHeap:(NSMutableDictionary *)sync_data
{
   
    SMLog(@"SAMMAN updateAllRecordsToSyncRecordsHeap Processing starts: %@  for count %d", [NSDate date],[sync_data count]);
    sync_data = [sync_data retain];
    NSArray * all_objects = [sync_data allKeys];
    
    for(NSString * object_name in  all_objects)
    {
        NSMutableArray *  object_info = [sync_data objectForKey:object_name];
        SMLog(@" no of records %d", [object_info count]);
      
        for (int i = 0 ; i < [object_info count]; i++) 
        {
            NSAutoreleasePool * autorelease = [[NSAutoreleasePool alloc] init];
            NSDictionary * dict = [ object_info objectAtIndex:i];
            NSArray * all_keys = [dict allKeys];
            NSString * sf_id = @"", * local_id = @"", *json_record = @"";
            for(NSString * key in all_keys)
            {
                // @"LOCAL_ID",@"JSON_RECORD",@"SF_ID",
                if([key isEqualToString:@"LOCAL_ID"])
                {
                    local_id = [dict objectForKey:@"LOCAL_ID"];
                }
                else if([key isEqualToString:@"JSON_RECORD"])
                {
                    json_record = [dict objectForKey:@"JSON_RECORD"];
                }
                else if ([key isEqualToString:@"SF_ID"])
                {
                    sf_id = [dict objectForKey:@"SF_ID"];
                }
            }
            
            NSString * update_query = [NSString stringWithFormat:@"UPDATE '%@' SET  json_record = '%@' , sync_flag = 'true' WHERE sf_id = '%@' ", SYNC_RECORD_HEAP, json_record , sf_id];
            
            char * err;
            
            if(synchronized_sqlite3_exec(appDelegate.db, [update_query UTF8String],NULL, NULL, &err) != SQLITE_OK)
            {
                SMLog(@"%@", update_query);
				SMLog(@"METHOD:updateAllRecordsToSyncRecordsHeap " );
				SMLog(@"ERROR IN UPDATING %s", err); //RADHA TODAY
              
            }
            [autorelease drain];
        }
    }
    [sync_data release];
    SMLog(@"SAMMAN updateAllRecordsToSyncRecordsHeap Processing ends: %@", [NSDate date]);
}

-(void)PutconflictRecordsIntoHeapFor:(NSString *)sync_type override_flag:(NSString *)override_flag_value
{
    NSMutableDictionary * final_dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSArray * keys = [NSArray arrayWithObjects:@"LOCAL_ID",@"JSON_RECORD",@"SF_ID",@"SYNC_TYPE", @"RECORD_TYPE",nil];
    
    sqlite3_stmt * statement;
    NSString * local_id = @"", * object_name = @""  , * record_type = @"" , * sf_id = @"" ;
    NSString * query  = [NSString stringWithFormat:@"SELECT  local_id , object_name , record_type, sf_id  FROM '%@' WHERE sync_type = '%@'   and override_flag = '%@'" ,SYNC_ERROR_CONFLICT , sync_type , override_flag_value];
    
    // SMLog(@" getAllRecords  %@", query);
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1 , &statement , nil)  ==  SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement)== SQLITE_ROW)
        {
            local_id = @"", object_name = @"",record_type = @"" ,  sf_id = @"";
            
            char * temp_loca_id = (char *) synchronized_sqlite3_column_text(statement, 0);
            if(temp_loca_id != nil )
                local_id = [ NSString stringWithUTF8String:temp_loca_id];
            
            char * temp_object_name = (char *) synchronized_sqlite3_column_text(statement, 1);
            if(temp_object_name != nil)
                object_name = [NSString stringWithUTF8String:temp_object_name];
            
            char * temp_record_type = (char *) synchronized_sqlite3_column_text(statement, 2);
            if(temp_record_type != nil)
                record_type = [NSString stringWithUTF8String:temp_record_type];
            
            char * temp_sf_id = (char *) synchronized_sqlite3_column_text(statement, 3);
            if(temp_sf_id != nil)
                sf_id = [NSString stringWithUTF8String:temp_sf_id];
            
            NSArray * allkeys = [final_dict allKeys];
            
            BOOL object_exists = FALSE;
            for(NSString * str in allkeys)
            {
                if([str isEqualToString:object_name])
                {
                    object_exists = TRUE;
                    break;
                }
            }
            
            if(object_exists)
            {
                NSMutableArray * array  = [final_dict objectForKey:object_name];
                NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id,@"",sf_id,sync_type,record_type, nil] forKeys:keys];
                [array addObject:dict];
                
            }
            else
            {
                NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:0];
                NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id,@"",sf_id,sync_type,record_type, nil] forKeys:keys];
                [array addObject:dict];
                [final_dict setObject:array forKey:object_name];
                
            }
          
        }
    }
    
    [self insertRecordIdsIntosyncRecordHeap:final_dict];
}


-(void)insertRecordIdsIntosyncRecordHeap:(NSMutableDictionary *)sync_data
{
    SMLog(@"SAMMAN insertRecordIdsIntosyncRecordHeap starts: %@", [NSDate date]);
    sync_data = [sync_data retain];
    NSArray * all_objects = [sync_data allKeys];
    for(NSString * object_name in  all_objects)
    {
        NSMutableArray *  object_info = [sync_data objectForKey:object_name];
        for (int i = 0 ; i < [object_info count]; i++) 
        {
            NSAutoreleasePool * autorelesePool = [[NSAutoreleasePool alloc] init];
            NSDictionary * dict = [ object_info objectAtIndex:i];
            NSArray * all_keys = [dict allKeys];
            NSString * sf_id = @"", * local_id = @"", *json_record = @"" , * sync_type = @"", * record_type = @"";
            for(NSString * key in all_keys)
            {
                // @"LOCAL_ID",@"JSON_RECORD",@"SF_ID",
                if([key isEqualToString:@"LOCAL_ID"])
                {
                    local_id = [dict objectForKey:@"LOCAL_ID"];
                }
                else if([key isEqualToString:@"JSON_RECORD"])
                {
                    json_record = [dict objectForKey:@"JSON_RECORD"];
                }
                else if ([key isEqualToString:@"SF_ID"])
                {
                    sf_id = [dict objectForKey:@"SF_ID"];
                }
                else if ([key isEqualToString:@"SYNC_TYPE"])
                {
                    sync_type = [dict objectForKey:@"SYNC_TYPE"];
                }
                else if ([key isEqualToString:@"RECORD_TYPE"])
                {
                    record_type = [dict objectForKey:@"RECORD_TYPE"];
                }
                
            }
            
            BOOL isChild = [self IsChildObject:object_name];
            
            if (isChild)
            {
                record_type = DETAIL;
            }
            
            NSString * update_query = [NSString stringWithFormat:@"INSERT INTO '%@' (local_id , json_record, sf_id, sync_flag,object_name,sync_type,record_type) VALUES ('%@','%@','%@','false','%@','%@','%@')", SYNC_RECORD_HEAP,local_id , json_record , sf_id, object_name, sync_type, record_type];
            
            char * err;
            
            if(synchronized_sqlite3_exec(appDelegate.db, [update_query UTF8String],NULL, NULL, &err) != SQLITE_OK)
            {
                SMLog(@"%@", update_query);
				SMLog(@"METHOD: insertRecordIdsIntosyncRecordHeap");
				SMLog(@"ERROR IN INSERTING %s", err);
            }
             [autorelesePool release];
        }
        
    }
    SMLog(@" sync_data %d",[sync_data retainCount]);
    [sync_data release];
    SMLog(@"IComeOUTHere databaseinterface");
    SMLog(@"SAMMAN insertRecordIdsIntosyncRecordHeap ends: %@", [NSDate date]);
}

#pragma mark query for trailer table

-(NSMutableArray *) getAllInsertRecords:(NSString *)operation_type
{
    NSString * request_time = @"";
    if([operation_type isEqualToString:INSERT])
    {
        request_time = [appDelegate.wsInterface get_SYNCHISTORYTime_ForKey:LAST_INSERT_REQUEST_TIME];
    }
    else if ([operation_type isEqualToString:UPDATE])
    {
        request_time = [appDelegate.wsInterface get_SYNCHISTORYTime_ForKey:LAST_UPDATE_REQUEST_TIME];
    }
    else if ([operation_type isEqualToString:DELETE])
    {
        request_time = [appDelegate.wsInterface get_SYNCHISTORYTime_ForKey:LAST_DELETE_REQUEST_TIME];
    }
    
    NSMutableArray * array = [[NSMutableArray  alloc] initWithCapacity:0];
    NSArray * keys = [NSArray arrayWithObjects:@"local_id" ,@"object_name" , @"parent_object_name", @"parent_local_id" , @"time_stamp" , @"record_type" , nil];
    
    sqlite3_stmt * statement;
    NSString * local_id = @"", * object_name = @"" , * parent_object_name = @"" , *parent_local_id = @"" , * time_stamp= @"" , * record_type = @"";
    NSString * query  = [NSString stringWithFormat:@"SELECT  local_id , object_name  , parent_object_name, parent_local_id , timestamp , record_type  FROM '%@' WHERE operation = '%@' and sync_flag = 'false' and timestamp <= '%@' and record_sent = 'false'" ,SFDATATRAILER_TEMP , operation_type,request_time];
    
	// SMLog(@" getAllRecords  %@", query);
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String],-1 , &statement , nil)  ==  SQLITE_OK)
    {
        
        while (synchronized_sqlite3_step(statement)== SQLITE_ROW)
        {
            local_id = @"", object_name = @"" , parent_object_name = @"" , parent_local_id = @"" , time_stamp = @"" ,record_type = @"";
            
            char * temp_loca_id = (char *) synchronized_sqlite3_column_text(statement, 0);
            if(temp_loca_id != nil )
                local_id = [ NSString stringWithUTF8String:temp_loca_id];
            
            char * temp_object_name = (char *) synchronized_sqlite3_column_text(statement, 1);
            if(temp_object_name != nil)
                object_name = [NSString stringWithUTF8String:temp_object_name];
            
            char * temp_parent_name = (char *) synchronized_sqlite3_column_text(statement, 2);
            if(temp_parent_name != nil)
                parent_object_name = [NSString stringWithUTF8String:temp_parent_name];
            
            char * temp_local_id = (char *) synchronized_sqlite3_column_text(statement, 3);
            if(temp_local_id != nil)
                parent_local_id = [NSString stringWithUTF8String:temp_local_id];
            
            char * temp_time_stamp = (char *) synchronized_sqlite3_column_text(statement, 4);
            if(temp_time_stamp != nil)
                time_stamp = [NSString stringWithUTF8String:temp_time_stamp];
            
            char * temp_record_type = (char *) synchronized_sqlite3_column_text(statement, 5);
            if(temp_record_type != nil)
                record_type = [NSString stringWithUTF8String:temp_record_type];
            
            
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id, object_name , parent_object_name, parent_local_id , time_stamp,record_type,nil] forKeys:keys];
            [array addObject:dict];
        }
    }
    return array;
}


-(void) insertdataIntoTrailerTableForRecord:(NSString *)local_id SF_id:(NSString *)sf_id record_type:(NSString *)record_type operation:(NSString *)operation object_name:(NSString *)Object_name  sync_flag:(NSString *)sync  parentObjectName:(NSString *)parentObjectName parent_loacl_id:(NSString *)parent_local_id;
{
    
    NSDate * date = [NSDate date];
    NSString * today_Date = @"";
    NSDateFormatter * dateFormatter  = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    today_Date = [dateFormatter stringFromDate:date];
    
	// SMLog(@"%@  sf_id %@" , local_id, sf_id);
    NSString * insert_statement;
    insert_statement = [NSString stringWithFormat:@"INSERT INTO '%@' (local_id ,sf_id ,record_type, operation, object_name, sync_flag, parent_object_name, parent_local_id,timestamp,record_sent) VALUES ('%@' , '%@' , '%@' , '%@' , '%@' ,'%@', '%@', '%@','%@','false')",SFDATATRAILER,local_id , sf_id , record_type, operation ,Object_name , sync, parentObjectName, parent_local_id,today_Date];
    
    char * err;
    
    if(synchronized_sqlite3_exec(appDelegate.db, [insert_statement UTF8String],NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(@"%@", insert_statement);
		SMLog(@"METHOD: insertdataIntoTrailerTableForRecord");
        SMLog(@"ERROR IN INSERTING %s", err);
    }
    else
    {
        
    }
    
}

-(NSArray *)getAllObjectsForRecordType:(NSString *)record_type  forOperation:(NSString *)operation_type;
{
    NSAutoreleasePool * autoreleasePOol = [[NSAutoreleasePool alloc] init];                          //sahana30April
    NSMutableArray * array = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    if(appDelegate.speacialSyncIsGoingOn)
    {
        sqlite3_stmt * statement;
        NSString  * object_name = @"";
        NSString * query  = [NSString stringWithFormat:@"SELECT  object_name FROM '%@' WHERE sync_type = '%@' and record_type = '%@'" ,SYNC_ERROR_CONFLICT , PUT_INSERT , record_type ];  //Change  Of Query.
        
        if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String],-1 , &statement , nil)  ==  SQLITE_OK)
        {
            while (synchronized_sqlite3_step(statement) ==  SQLITE_ROW)
            {
                object_name = @"";
                
                char * temp_object_name = (char *) synchronized_sqlite3_column_text(statement, 0);
                if(temp_object_name != nil)
                    object_name = [NSString stringWithUTF8String:temp_object_name];
                
                BOOL present =  FALSE;
                for(NSString * str in array)
                {
                    if([str isEqualToString:object_name])
                    {
                        present = TRUE;
                        break;
                    }
                }
                if(!present)
                {
                    [array addObject:object_name];
                }
                
            }
        }

    }
    else
    {
        sqlite3_stmt * statement;
        NSString  * object_name = @"";
        NSString * query  = [NSString stringWithFormat:@"SELECT  object_name FROM '%@' WHERE operation = '%@' and record_type = '%@' and sync_flag = 'false' and record_sent != 'true'" ,SFDATATRAILER_TEMP , INSERT , record_type ];

        if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String],-1 , &statement , nil)  ==  SQLITE_OK)
        {
            
            while (synchronized_sqlite3_step(statement) ==  SQLITE_ROW)
            {
                object_name = @"";
                
                char * temp_object_name = (char *) synchronized_sqlite3_column_text(statement, 0);
                if(temp_object_name != nil)
                    object_name = [NSString stringWithUTF8String:temp_object_name];
                
                BOOL present =  FALSE;
                for(NSString * str in array)
                {
                    if([str isEqualToString:object_name])
                    {
                        present = TRUE;
                        break;
                    }
                }
                if(!present)
                {
                    [array addObject:object_name];
                }
                
            }
        }
    }
    if([array retainCount] == 1)                                     //sahana30April
        [array retain];
    [autoreleasePOol release];
    return [array autorelease];                                  //sahana30April
}

-(NSMutableDictionary *)getRecordsForRecordId:(NSString *)record_id ForObjectName:(NSString *)object_name fields:(NSString *)fields
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSString * query = [NSString stringWithFormat:@"SELECT  %@  FROM '%@' WHERE local_id = '%@'",fields , object_name, record_id];
    sqlite3_stmt * statement ;
    
    NSArray * fields_array = [fields componentsSeparatedByString:@","];
    
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, nil) ==  SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW) 
        {
            for(int i = 0 ; i < [fields_array count] ; i++)
            {
                NSString * value  = @"";
                NSString * field = [fields_array objectAtIndex:i];
                char * temp_column = (char * ) synchronized_sqlite3_column_text(statement, i);
                if(temp_column != nil)
                {
                    value  = [NSString stringWithUTF8String:temp_column];
                }
                
                //Radha
                NSString * field_data_type = [self getFieldDataType:object_name filedName:field];
                if([field_data_type isEqualToString:@"boolean"])
                {
                    if ([value isEqualToString:@"1"] || [value isEqualToString:@"true"] || [value isEqualToString:@"True"])
                    {
                        value = @"true";
                    }
                    else
                    {
                        value = @"false";
                    }
                }
            
                if([value isEqualToString:@""])
                {
                    
                }
                else
                {
                    [dict setValue:value forKey:field];
                }
                
            }
        }
    }
    synchronized_sqlite3_finalize(statement);
    return dict;
}

-(void)updateDataTrailer_RecordSentForlocalId:(NSString *)local_id operation_type:(NSString *)operationType
{
    NSString * update_statement = [NSString stringWithFormat:@"UPDATE '%@' SET record_sent = 'true' WHERE local_id = '%@' and operation = '%@' " ,SFDATATRAILER_TEMP , local_id , operationType];
    
    char * err ;
    if(synchronized_sqlite3_exec(appDelegate.db, [update_statement UTF8String], nil, nil, &err) != SQLITE_OK)
    {
        SMLog(@"%@", update_statement);
		SMLog(@"METHOD:updateDataTrailer_RecordSentForlocalId " );
		SMLog(@"ERROR IN UPDATING %s", err);
    }
}

-(void)copyTrailerTableToTempTrailerForOperationType:(NSString *)operation_type
{
    NSString * query = [NSString stringWithFormat:@"INSERT INTO '%@' (timestamp ,  local_id , sf_id ,  record_type ,  operation ,  object_name ,  sync_flag  ,  parent_object_name   , parent_local_id   ,  record_sent )   SELECT timestamp ,  local_id , sf_id ,  record_type ,  operation ,  object_name ,  sync_flag  ,  parent_object_name   , parent_local_id   ,  record_sent  from  '%@' WHERE operation = '%@'",SFDATATRAILER_TEMP,SFDATATRAILER,operation_type];
    
    char * err ;
    if(synchronized_sqlite3_exec(appDelegate.db, [query UTF8String], nil, nil, &err) != SQLITE_OK)
    {
        SMLog(@"%@", query);
		SMLog(@"METHOD: copyTrailerTableToTempTrailerForOperationType");
        SMLog(@"ERROR IN INSERTING %s", err);
    }
}

-(void)cleartable:(NSString *)table_name
{
    char * err;
    NSString *  queryStatemnt = [NSString stringWithFormat:@"DELETE FROM  '%@'", table_name];
    if (synchronized_sqlite3_exec(appDelegate.db, [queryStatemnt UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
		SMLog(@"%@", queryStatemnt);
		SMLog(@"METHOD:cleartable");
		SMLog(@"ERROR IN DELETE %s", err);

    }
}

//unused 
-(NSMutableArray *) getAllSyncRecordsFromSYNCHeap
{
    NSArray * keys = [NSArray arrayWithObjects:@"sf_id",@"local_id", @"object_name",@"json_record",@"record_type",@"sync_type" ,nil];
    NSString  * sql = [NSString stringWithFormat:@"SELECT sf_id ,local_id, object_name , json_record ,record_type,sync_type FROM 'sync_Records_Heap'  where sync_flag = 'true'"];
    sqlite3_stmt * statement ;
    NSString  * local_id = nil , *sf_id = nil, * object_name = nil , * json_record = nil , * record_type = nil, *sync_type = nil;
      
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sql UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            char * temp_sf_id = (char *)synchronized_sqlite3_column_text(statement, 0);
            if(temp_sf_id != nil)
            {
                sf_id = [NSString stringWithUTF8String:temp_sf_id];
            }
            char * temp_local_id = (char *) synchronized_sqlite3_column_text(statement, 1);
            if(temp_local_id != nil)
            {
                local_id = [NSString stringWithUTF8String:temp_local_id];
            }
            char * temp_object_name = (char *) synchronized_sqlite3_column_text(statement, 2);
            if(temp_object_name != nil)
            {
                object_name = [NSString stringWithUTF8String:temp_object_name];
            }
            char * temp_json_record = (char *) synchronized_sqlite3_column_text(statement, 3);
            if(temp_json_record != nil)
            {
                json_record = [NSString stringWithUTF8String:temp_json_record];
            }
            char * temp_record_type = (char *) synchronized_sqlite3_column_text(statement, 4);
            if(temp_record_type != nil)
            {
                record_type = [NSString stringWithUTF8String:temp_record_type];
            }
            char * temp_sync_type = (char *) synchronized_sqlite3_column_text(statement, 5);
            if(temp_sync_type != nil)
            {
                sync_type = [NSString stringWithUTF8String:temp_sync_type];
            }
            
            NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:sf_id,local_id,object_name,json_record, record_type, sync_type,nil] forKeys:keys];
                      
        }
    }
   
}

-(NSArray *)getAllObjectsFromHeap
{
    NSString  * sql = [NSString stringWithFormat:@"SELECT DISTINCT object_name FROM 'sync_Records_Heap'  where sync_flag = 'true'"];
    NSMutableArray * array = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    NSString * obj_name= @""; 
    sqlite3_stmt * statement ;
  
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sql UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {   
            char * temp_obj_name = (char *)synchronized_sqlite3_column_text(statement, 0);
            if(temp_obj_name != nil)
            {
                obj_name = [NSString stringWithUTF8String:temp_obj_name];
            }
            [array addObject:obj_name];
        }
    }
    return array;
}

-(NSMutableDictionary *)getAllFieldsAndItsDataTypesForObject:(NSString *)object_api_name tableName:(NSString *)tableName
{
    NSMutableDictionary * dict = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
    NSString * field_api_name = @"", *data_type = @"";
    if(object_api_name != nil || [object_api_name length ] != 0)
    {
        NSString * query = [NSString stringWithFormat:@"SELECT api_name,type from '%@' where object_api_name = '%@'" , tableName , object_api_name];
        sqlite3_stmt * stmt;
        if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
        {
            while (synchronized_sqlite3_step(stmt)  == SQLITE_ROW) 
            {
                char * temp_process_id  = (char *)synchronized_sqlite3_column_text(stmt, 0);
                
                if(temp_process_id!= nil) 
                    field_api_name = [NSString stringWithUTF8String:temp_process_id];
                
                char * temp_data_type = (char *)synchronized_sqlite3_column_text(stmt, 1);
                    data_type = [NSString stringWithUTF8String:temp_data_type];
                    
                if([dict count] != 0)
                {
                }
                
                [dict setObject:data_type forKey:field_api_name];
            }
        }
        synchronized_sqlite3_finalize(stmt);
    }
    return dict;
}

-(void)updateSyncRecordsIntoLocalDatabase
{
    NSArray * objects_names = [self getAllObjectsFromHeap];
    
    NSString* txnstmt = @"BEGIN TRANSACTION";
    char * err ;
    int retval = synchronized_sqlite3_exec(appDelegate.db, [txnstmt UTF8String], NULL, NULL, &err);   
    sqlite3_stmt * statement ;
    NSString  * local_id = nil , *sf_id = nil, * object_Name = nil , * json_record = nil , * record_type = nil, *sync_type = nil;
    
    for(int f = 0; f < [objects_names count]; f++)
    {
        NSString * Object_name_temp = [objects_names objectAtIndex:f];
        
        NSString  * sql = [NSString stringWithFormat:@"SELECT sf_id ,local_id, object_name , json_record ,record_type,sync_type FROM 'sync_Records_Heap'  where sync_flag = 'true' and object_name = '%@'",Object_name_temp];
        statement = nil;
        local_id = nil , sf_id = nil, object_Name = nil ,  json_record = nil ,  record_type = nil, sync_type = nil;
        
        NSInteger count = 0;
        
        NSMutableDictionary *dict = [self getAllFieldsAndItsDataTypesForObject:Object_name_temp tableName:SFOBJECTFIELD];
        
        [dict setValue:@"VARCHAR" forKey:@"local_id"];
        NSArray * all_keys_object_api_names = [dict allKeys];
        NSString * field_string = @"";
        NSString * values_string = @"";
        
        for(int t = 0; t < [all_keys_object_api_names count];t++)
        {
            NSString * obj_ = [all_keys_object_api_names objectAtIndex:t];
            if(t != 0)
            {
                NSString * temp_field_string = [NSString stringWithFormat:@",%@" ,obj_];
                field_string = [field_string stringByAppendingFormat:@"%@",temp_field_string];
                values_string = [values_string stringByAppendingFormat:@",?%d",t+1];
            }
            else
            {
                NSString * temp_field_string = [NSString stringWithFormat:@"%@" ,obj_];
                field_string = [field_string stringByAppendingFormat:@"%@",temp_field_string];
                values_string = [values_string stringByAppendingFormat:@"?%d",t+1];
            }
        }
        
        NSString * query_string = [NSString stringWithFormat:@"INSERT INTO '%@' (%@) VALUES (%@)",Object_name_temp,field_string,values_string]; 
        
        sqlite3_stmt * bulk_statement = nil;
        
        int prepare_ = sqlite3_prepare_v2(appDelegate.db, [query_string UTF8String], strlen([query_string UTF8String]), &bulk_statement, NULL);
        
        
        if(prepare_ == SQLITE_OK)
        {
            if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sql UTF8String], -1, &statement, nil) == SQLITE_OK)
            {
                while (synchronized_sqlite3_step(statement) == SQLITE_ROW)
                {   
                    local_id = @"",sf_id = @"", object_Name = @"" ,  json_record = @"" ,  record_type = @"", sync_type = @"";
                    
                    NSAutoreleasePool * autorelease = [[NSAutoreleasePool alloc] init];
                    char * temp_sf_id = (char *)synchronized_sqlite3_column_text(statement, 0);
                    if(temp_sf_id != nil)
                    {
                        sf_id = [NSString stringWithUTF8String:temp_sf_id];
                    }
                    char * temp_local_id = (char *) synchronized_sqlite3_column_text(statement, 1);
                    if(temp_local_id != nil)
                    {
                        local_id = [NSString stringWithUTF8String:temp_local_id];
                    }
                    char * temp_object_name = (char *) synchronized_sqlite3_column_text(statement, 2);
                    if(temp_object_name != nil)
                    {
                        object_Name = [NSString stringWithUTF8String:temp_object_name];
                    }
                    char * temp_json_record = (char *) synchronized_sqlite3_column_text(statement, 3);
                    if(temp_json_record != nil)
                    {
                        json_record = [NSString stringWithUTF8String:temp_json_record];
                    }
                    char * temp_record_type = (char *) synchronized_sqlite3_column_text(statement, 4);
                    if(temp_record_type != nil)
                    {
                        record_type = [NSString stringWithUTF8String:temp_record_type];
                    }
                    char * temp_sync_type = (char *) synchronized_sqlite3_column_text(statement, 5);
                    if(temp_sync_type != nil)
                    {
                        sync_type = [NSString stringWithUTF8String:temp_sync_type];
                    }
                    
                    BOOL insert_flag , update_flag;
                    // update trailer table  sync field 
                    //update local database from sync heap table
                    
                    NSString * new_local_id = [iServiceAppDelegate GetUUID];
                    
                    NSString * parent_column_name = @"";
                    if([record_type isEqualToString:MASTER])
                    {
                        //jst update 
                    }
                    else if ([record_type isEqualToString:DETAIL])
                    {
                        parent_column_name = [self getchildInfoFromChildRelationShip:SFCHILDRELATIONSHIP ForChild:object_Name field_name:@"parent_column_name"];
                    }
                    
                    //memory suspect
                    NSMutableDictionary * final_dict = [self getDictForJsonString:json_record];
                    
                    //if local_id exists then update the record 
                    if([local_id isEqualToString:@""] && [json_record length] != 0 && [sync_type isEqualToString:GET_INSERT])
                    {
                        
                        BOOL  check_flag = [appDelegate.dataBase checkForDuplicateId:object_Name sfId:sf_id];
                        //call insert method 
                        if(check_flag)
                        {
                            [final_dict setObject:new_local_id forKey:@"local_id"];
                            insert_flag = [self insertdataIntoTable:object_Name data:final_dict];
                        }
                    }
                    else if ([local_id isEqualToString:@""] && [json_record length] != 0 && ([sync_type isEqualToString:PUT_UPDATE] || [sync_type isEqualToString:GET_UPDATE ]) )
                    {
                        BOOL check_flag = [appDelegate.dataBase checkForDuplicateId:object_Name sfId:sf_id];
                        //call insert method 
                        if(check_flag)
                        {
                            if ([record_type isEqualToString:DETAIL])
                            {
                                NSString *parent_obj_name = [self getchildInfoFromChildRelationShip:SFCHILDRELATIONSHIP ForChild:object_Name field_name:@"parent_name"];
                                NSString * parent_column_name = [self getchildInfoFromChildRelationShip:SFCHILDRELATIONSHIP ForChild:object_Name field_name:@"parent_column_name"];
                                NSString * parent_sf_id = @"";
                                for(NSString * find_parent_column in final_dict)
                                {
                                    if([find_parent_column isEqualToString:parent_column_name])
                                    {
                                        parent_sf_id = [final_dict objectForKey:find_parent_column];
                                    }
                                }
                                
                                NSString * parent_local_id = [self getLocalIdFromSFId:parent_sf_id tableName:parent_obj_name];
                                [final_dict setObject:parent_local_id forKey:parent_column_name];
                            }
                            
                            [final_dict setObject:new_local_id forKey:@"local_id"];
                            insert_flag = [self insertdataIntoTable:object_Name data:final_dict];
                        }
                        else
                        {
                            if([record_type isEqualToString:DETAIL])
                            {
                                [final_dict removeObjectForKey:parent_column_name];
                            }
                            BOOL flag = [self UpdateTableforSFId:sf_id forObject:object_Name data:final_dict];
                            if(flag)
                            {
                                
                            }
                        }
                    }
                    else if([sync_type isEqualToString:@"DATA_SYNC"])
                    {
                        BOOL  check_flag = [appDelegate.dataBase checkForDuplicateId:object_Name sfId:sf_id];
                        //call insert method 
                        if(check_flag)
                        {
                            //temp change
                            [final_dict setObject:new_local_id forKey:@"local_id"];
                            
                            for(int x = 0; x < [all_keys_object_api_names count]; x++)
                            {
                                int column_num = x+1;
                                NSString * field = [all_keys_object_api_names objectAtIndex:x];
                                NSString * data_type = [dict objectForKey:field];
                                NSString * columnType = [appDelegate.dataBase columnType:data_type];
                                NSString * final_value = [final_dict objectForKey:field];
                                
                                if(final_value == nil)
                                {
                                    final_value = @"";
                                }
								
								char * _finalValue = [appDelegate convertStringIntoChar:final_value];
                                
                                if([columnType isEqualToString:DOUBLE])
                                {
                                    sqlite3_bind_double(bulk_statement, column_num, [final_value doubleValue]);
                                }
                                else if([columnType isEqualToString:INTEGER])
                                {
                                    sqlite3_bind_int(bulk_statement, column_num, [final_value intValue]);
                                }
                                else if([columnType isEqualToString:DATETIME])
                                {
                                    sqlite3_bind_text(bulk_statement, column_num, _finalValue, strlen(_finalValue), SQLITE_TRANSIENT);
                                }
                                else if([columnType isEqualToString:VARCHAR])
                                {
                                    sqlite3_bind_text(bulk_statement, column_num, _finalValue, strlen(_finalValue), SQLITE_TRANSIENT);
                                }
                                else if([columnType isEqualToString:_BOOL])
                                {
                                    sqlite3_bind_text(bulk_statement, column_num, _finalValue, strlen(_finalValue), SQLITE_TRANSIENT);
                                }
                                else
                                {
                                    sqlite3_bind_text(bulk_statement, column_num, _finalValue, strlen(_finalValue), SQLITE_TRANSIENT);
                                }
                            }
                            
                            int ret = synchronized_sqlite3_step(bulk_statement);
                            if (ret!= SQLITE_DONE)
                            {
                                printf("Commit Failed!\n");
								SMLog(@"%@", query_string);
								SMLog(@"METHOD: updateSyncRecordsIntoLocalDatabase");
                            }
                            sqlite3_reset(bulk_statement);
                        }
                        else
                        {
                            BOOL flag = [self UpdateTableforSFId:sf_id forObject:object_Name data:final_dict];
                            if(flag)
                            {
                                
                            }
                        }
                    }
                    else if ([local_id length] != 0 && [json_record length] != 0 )
                    {
                        if([record_type isEqualToString:DETAIL])
                        {
                            [final_dict removeObjectForKey:parent_column_name];
                        }
                        if ([object_Name isEqualToString:@"SVMXC__User_GPS_Log__c"]) {
                            BOOL isUser_GPS_LogTableDelete=[self DeleterecordFromTable:@"SVMXC__User_GPS_Log__c" Forlocal_id:local_id];
                            [appDelegate.dataBase deleteSequenceofTable:@"SVMXC__User_GPS_Log__c"];
                            if(!isUser_GPS_LogTableDelete)
                            {
                                SMLog(@"Failed to delete location record");
                            }
                        }
                        else
                        {
                            update_flag = [self UpdateTableforId:local_id forObject:object_Name data:final_dict];
                        }                        
                    }
                    
                    if([sync_type isEqualToString:GET_INSERT] || [sync_type isEqualToString:GET_UPDATE] )
                    {
                        [self deleteAllOndemandRecordsPartOfDownloadCriteriaForSfId:sf_id];
                    }
                    if([sync_type isEqualToString:PUT_UPDATE])
                    {
                        [self updateOndemandRecordForId:sf_id];
                    }
                    
                    
                    if(![sync_type isEqualToString:@"DATA_SYNC"])
                    {
                        
                        NSString * delete_id = @"";
                        
                        if([sync_type isEqualToString:PUT_INSERT ])
                        {
                            delete_id = local_id;
							//sahana  15th September Start
							[self updatedataTrailerTAbleForLocal_id:local_id sf_id:sf_id];
                            if([object_Name isEqualToString:@"Event"])
                            {
                                [self InsertInto_User_created_event_for_local_id:local_id sf_id:sf_id];
                            }
							//sahana  15th September ends
                            
                        }
                        else if ([sync_type isEqualToString:PUT_UPDATE] ||  [sync_type isEqualToString:PUT_DELETE])
                        {
                            delete_id = sf_id;
                        }
                        
                        BOOL flag = [self DeleteDataTrailerTableAfterSync:delete_id forObject:object_Name sync_type:sync_type];
                        if(flag)
                        {
                        }
                        else
                        {
                            SMLog(@" trailer table Delete Not succeded");
                        }
                    }
                    count++;
                    
                    [final_dict release];
                    [new_local_id release];
                    SMLog(@"Record %d" ,count );
                    [autorelease release];
                }
            }
        }
        synchronized_sqlite3_finalize(statement);
    }
    
    
    txnstmt = @"END TRANSACTION";
    retval = synchronized_sqlite3_exec(appDelegate.db, [txnstmt UTF8String], NULL, NULL, &err);    
    
    //Sahana Fixed memory oct4th
    NSMutableDictionary * parent_obejct_dict = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
    NSMutableDictionary * parent_column_dict = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
    statement = nil;
    NSString  * getObjects_sql = [NSString stringWithFormat:@"SELECT DISTINCT object_name  FROM 'sync_Records_Heap'  where sync_flag = 'true'  AND record_type = 'DETAIL'"];
    NSString * temp_child_object_name = @"";
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [getObjects_sql UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            temp_child_object_name = @"";
            char * temp_object_name = (char *)synchronized_sqlite3_column_text(statement, 0);
            if(temp_object_name != nil)
            {
                temp_child_object_name = [NSString stringWithUTF8String:temp_object_name];
                NSString *parent_obj_name = [self getchildInfoFromChildRelationShip:SFCHILDRELATIONSHIP ForChild:temp_child_object_name field_name:@"parent_name"];
                SMLog(@"parent_obj_name = %@", parent_obj_name );
                NSString * parent_column_name = [self getchildInfoFromChildRelationShip:SFCHILDRELATIONSHIP ForChild:temp_child_object_name field_name:@"parent_column_name"];
                [parent_obejct_dict setValue:parent_obj_name forKey:temp_child_object_name];
                [parent_column_dict setValue:parent_column_name forKey:temp_child_object_name];
            }
            
        }
    }
    
    
    statement = nil;
    
    NSString  * sql2 = [NSString stringWithFormat:@"SELECT sf_id ,local_id, object_name , json_record ,record_type,sync_type FROM 'sync_Records_Heap'  where sync_flag = 'true'  AND record_type = 'DETAIL'"];
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sql2 UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            local_id = @"",sf_id = @"", object_Name = @"" ,  json_record = @"" ,  record_type = @"", sync_type = @"";
            char * temp_sf_id = (char *)synchronized_sqlite3_column_text(statement, 0);
            if(temp_sf_id != nil)
            {
                sf_id = [NSString stringWithUTF8String:temp_sf_id];
            }
            char * temp_local_id = (char *) synchronized_sqlite3_column_text(statement, 1);
            if(temp_local_id != nil)
            {
                local_id = [NSString stringWithUTF8String:temp_local_id];
            }
            char * temp_object_name = (char *) synchronized_sqlite3_column_text(statement, 2);
            if(temp_object_name != nil)
            {
                object_Name = [NSString stringWithUTF8String:temp_object_name];
            }
            char * temp_json_record = (char *) synchronized_sqlite3_column_text(statement, 3);
            if(temp_json_record != nil)
            {
                json_record = [NSString stringWithUTF8String:temp_json_record];
            }
            char * temp_record_type = (char *) synchronized_sqlite3_column_text(statement, 4);
            if(temp_record_type != nil)
            {
                record_type = [NSString stringWithUTF8String:temp_record_type];
            }
            char * temp_sync_type = (char *) synchronized_sqlite3_column_text(statement, 5);
            if(temp_sync_type != nil)
            {
                sync_type = [NSString stringWithUTF8String:temp_sync_type];
            }
            
            if( [sync_type isEqualToString:GET_INSERT] )
            {
                if ([record_type isEqualToString:DETAIL])
                {
                    NSString *parent_obj_name = [parent_obejct_dict objectForKey:object_Name];
                    NSString * parent_column_name1 = [parent_column_dict objectForKey:object_Name];
                    
                    
                    NSString * parent_local_id = [self getParentLocalIdForChildSFID:sf_id parentObject_name:parent_obj_name parent_column_name:parent_column_name1 child_object_name:object_Name]; //sahana Intro Autorelease
                    
                    BOOL duplicateRecord = [appDelegate.dataBase checkForDuplicateId:object_Name sfId:sf_id];
                    
                    NSString * value = [appDelegate.dataBase getParentColumnValueFromchild:parent_column_name1 childTable:object_Name sfId:sf_id];//sahana Intro Autorelease
                    
                    if (!duplicateRecord && (![value isEqualToString:parent_local_id]) && ([parent_local_id length] > 0))
                    {
                        [self updateParentColumnNameInChildTableWithParentLocalId:object_Name parent_column_name:parent_column_name1 parent_local_id:parent_local_id child_sf_id:sf_id];
                    }
                    
                }
            }
            //Sahana Fixed memory oct4th
            if( [sync_type isEqualToString:@"DATA_SYNC"])
            {
                if ([record_type isEqualToString:DETAIL])
                {
                    
                    NSString *parent_obj_name = [parent_obejct_dict objectForKey:object_Name];
                    NSString * parent_column_name1 = [parent_column_dict objectForKey:object_Name];
                    
                    NSString * parent_local_id = [self getParentLocalIdForChildSFID:sf_id parentObject_name:parent_obj_name parent_column_name:parent_column_name1 child_object_name:object_Name]; 
                    
                    if([parent_local_id length] > 0)
                    {
                        [self updateParentColumnNameInChildTableWithParentLocalId:object_Name parent_column_name:parent_column_name1 parent_local_id:parent_local_id child_sf_id:sf_id];
                    }
                    
                }
            }
            
        }
    }
    
    synchronized_sqlite3_finalize(statement);
    
}

-(void)InsertInto_User_created_event_for_local_id:(NSString *)local_id sf_id:(NSString *)sf_id
{
    NSString * version = [appDelegate serverPackageVersion];
	int _stringNumber = [version intValue];
    
    if(_stringNumber >=  (KMinPkgForScheduleEvents * 100000))
    {
        NSDate * date = [NSDate date];
        NSString * today_Date = @"";
        NSDateFormatter * dateFormatter  = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        today_Date = [dateFormatter stringFromDate:date];
        NSString * insert_query = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ ('object_name','sf_id','time_stamp','local_id') VALUES ('%@','%@','%@','%@')" , User_created_events,@"Event",sf_id,today_Date,local_id ];
        char * err;
        
        if(synchronized_sqlite3_exec(appDelegate.db, [insert_query UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
            SMLog(@"Insert Failed");
        }
    }
}

-(void)updatedataTrailerTAbleForLocal_id:(NSString *)local_id  sf_id:(NSString *)sf_id
{
    char * err ;
    NSString * updateStatement = [NSString stringWithFormat:@"UPDATE '%@' SET %@ = '%@'  WHERE (local_id = '%@' )", SFDATATRAILER, @"sf_id" , sf_id,local_id ];
    
    if (synchronized_sqlite3_exec(appDelegate.db, [updateStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(@"%@", updateStatement);
		SMLog(@"METHOD:updatedataTrailerTAbleForLocal_id " );
		SMLog(@"ERROR IN UPDATING %s", err);

    }
    
}
-(void)updateParentColumnNameInChildTableWithParentLocalId:(NSString *)child_objectName parent_column_name:(NSString *)parent_column_name   parent_local_id:(NSString *)parent_local_id  child_sf_id:(NSString *)child_sfId
{
    char * err ;
    NSString * updateStatement = [NSString stringWithFormat:@"UPDATE '%@' SET %@ = '%@'  WHERE Id = '%@'", child_objectName,parent_column_name , parent_local_id ,child_sfId];
    
    if (synchronized_sqlite3_exec(appDelegate.db, [updateStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
		SMLog(@"%@", updateStatement);
		SMLog(@"METHOD:updateParentColumnNameInChildTableWithParentLocalId " );
		SMLog(@"ERROR IN UPDATING %s", err);

    }
}

-(NSString *)getParentLocalIdForChildSFID:(NSString *)childSF_Id parentObject_name:(NSString *)parentObjectName parent_column_name:(NSString *)parent_column_name child_object_name:(NSString *)child_obj_name  
{
    
    //Sahana Fixed memory oct4th
    NSString * Parent_Sf_id = @"";
    
    NSString * query = [[NSString alloc ] initWithFormat:@"SELECT %@ FROM '%@' WHERE Id = '%@'" ,parent_column_name ,child_obj_name , childSF_Id];
    
    sqlite3_stmt * stmt ;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * temp_fieldName = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if(temp_fieldName != nil)
            {
                Parent_Sf_id = [NSString stringWithUTF8String:temp_fieldName];
            }
        }
    }
    synchronized_sqlite3_finalize(stmt);
    [query release];
    
    
    NSString * paren_local_id = @"";
    NSString * query1 = [[NSString alloc ] initWithFormat:@"SELECT local_id FROM '%@' WHERE Id = '%@'" ,parentObjectName,Parent_Sf_id];
    sqlite3_stmt * stmt1 ;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query1 UTF8String], -1, &stmt1, nil) == SQLITE_OK  )
    {
        while( synchronized_sqlite3_step(stmt1) == SQLITE_ROW)
        {
            char * temp_fieldName = (char *)synchronized_sqlite3_column_text(stmt1, 0);
            if(temp_fieldName != nil && strlen(temp_fieldName))
            {
                paren_local_id = [NSString stringWithUTF8String:temp_fieldName];
            }
        }
    }
    [query1 release];
    synchronized_sqlite3_finalize(stmt1);
    return paren_local_id;
}


-(NSString *) getchildInfoFromChildRelationShip:(NSString * )tableName  ForChild:(NSString *)child_table  field_name:(NSString *)field_name
{
    NSString * fieldName = @"";
    if([field_name isEqualToString:@"parent_name"])
    {
        field_name = @"object_api_name_parent";
    }
    else if ([field_name isEqualToString:@"parent_column_name"])
    {
        field_name = @"field_api_name";
    }
    if(child_table != nil )
    {
        NSString * query = [[NSString  alloc ]  initWithFormat:@"SELECT %@ FROM '%@' where  object_api_name_child = '%@' ", field_name,tableName ,child_table];
        sqlite3_stmt * stmt ;
        if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
        {
            while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
            {
                char * temp_fieldName = (char *)synchronized_sqlite3_column_text(stmt, 0);
                if(temp_fieldName != nil)
                {
                    fieldName = [NSString stringWithUTF8String:temp_fieldName];
                }
            }
        }
        synchronized_sqlite3_finalize(stmt);
        [query release];
    }
    
    return fieldName;

}

-(BOOL)DeleteDataTrailerTableAfterSync:(NSString *)local_id forObject:(NSString *)object  sync_type:(NSString *)sync_type
{
     NSString * sync_initiated_forSyncType  = @"";
    if([sync_type isEqualToString:PUT_INSERT])
    {   
        sync_type = INSERT;
        sync_initiated_forSyncType  = [appDelegate.wsInterface get_SYNCHISTORYTime_ForKey:LAST_INSERT_REQUEST_TIME];
    }
    else if([sync_type isEqualToString:PUT_UPDATE])
    {
        sync_type = UPDATE;
         sync_initiated_forSyncType  = [appDelegate.wsInterface get_SYNCHISTORYTime_ForKey:LAST_UPDATE_REQUEST_TIME];
    }
    else if ([sync_type isEqualToString:PUT_DELETE ])
    {
        sync_type = DELETE;
         sync_initiated_forSyncType  = [appDelegate.wsInterface get_SYNCHISTORYTime_ForKey:LAST_DELETE_REQUEST_TIME];
    }
    NSString * update = @"";
    if([sync_type isEqualToString:UPDATE] || [sync_type isEqualToString:DELETE])
    {
        update = [NSString stringWithFormat:@"DELETE FROM '%@' WHERE sync_flag = 'false' and sf_id = '%@' and object_name = '%@' and operation = '%@' and timestamp <= '%@'", SFDATATRAILER,local_id,object , sync_type , sync_initiated_forSyncType];
    }
    else  if([sync_type isEqualToString:INSERT])
    {
        update = [NSString stringWithFormat:@"DELETE FROM '%@' WHERE sync_flag = 'false' and local_id = '%@' and object_name = '%@' and operation = '%@' and timestamp <= '%@'", SFDATATRAILER,local_id,object , sync_type , sync_initiated_forSyncType];
    }
    char * err;
   
     
    if (synchronized_sqlite3_exec(appDelegate.db, [update UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
		SMLog(@"%@", update);
		SMLog(@"METHOD:DeleteDataTrailerTableAfterSync");
		SMLog(@"ERROR IN DELETE %s", err);

        return FALSE;
    }
    return TRUE;
}

-(NSMutableDictionary *)getDictForJsonString:(NSString *)json_record
{
    NSAutoreleasePool * autoreleasePool = [[NSAutoreleasePool alloc] init];
    SBJsonParser * jsonParser = [[[SBJsonParser alloc] init] autorelease];
    NSDictionary * json_dict = [jsonParser objectWithString:json_record];

    NSMutableDictionary * lookUpDict = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
    NSMutableDictionary * final_dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSArray * json_allkeys = [json_dict allKeys];
    NSInteger lookUp_id = 0;
    for (int f = 0; f < [json_allkeys count]; f++)
    {
        NSString * json_key = [json_allkeys objectAtIndex:f];
        id  id_type = [json_dict objectForKey:json_key];
        
        if ([id_type isKindOfClass:[NSDictionary class]])
        {
            NSString * field = [json_allkeys objectAtIndex:f];

            NSDictionary * dict = (NSDictionary *)id_type;
            NSRange range = [field rangeOfString:@"__r"];
            
            if (range.location != NSNotFound)
            {
				//RADHA 27/Sep/2012
				NSDictionary * attDict = [dict objectForKey:@"attributes"];
				NSString * object = [attDict objectForKey:@"type"];
				NSString * Name = [appDelegate.dataBase getApiNameForNameField:object];
				
                [lookUpDict setValue:[dict objectForKey:@"Id"] forKey:@"Id"];
                [lookUpDict setValue:[dict objectForKey:Name] forKey:@"Name"];
                [lookUpDict setValue:[dict objectForKey:@"type"] forKey:@"type"];
                [appDelegate.dataBase addvaluesToLookUpFieldTable:lookUpDict WithId:lookUp_id];
            }                        
        }
        else
        {
            NSString * value =  [NSString stringWithFormat:@"%@", id_type];
            [final_dict setObject:value forKey:json_key];
        }
    }
    
    [autoreleasePool release];
    return final_dict;
}   



-(NSString *)getSfid_For_LocalId_From_Object_table:(NSString *)object_name  local_id:(NSString *)local_id
{
    NSString * query = [NSString stringWithFormat:@"SELECT Id FROM '%@' WHERE local_id = '%@'" , object_name , local_id];
    sqlite3_stmt * stmt ;
    NSString * Id_ = @"";
    
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * temp_id = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if(temp_id != nil)
            {
                Id_= [NSString stringWithUTF8String:temp_id];
            }
        }
    }
    return Id_;
}

-(NSString *)getSfid_For_LocalId_From_TrailerForlocal_id:(NSString *)local_id
{
    NSString * query = [NSString stringWithFormat:@"SELECT sf_id FROM '%@' WHERE local_id = '%@'" , SFDATATRAILER , local_id];
    sqlite3_stmt * stmt ;
    NSString * Id_ = @"";
    
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * temp_id = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if(temp_id != nil)
            {
                Id_= [NSString stringWithUTF8String:temp_id];
            }
        }
    }
    return Id_;
}

-(NSString *)getSfid_For_LocalId_FROM_SfHeapTable:(NSString *)local_id 
{
    NSString * query = [NSString stringWithFormat:@"SELECT Id FROM '%@' WHERE local_id = '%@'" , SYNC_RECORD_HEAP, local_id];
    sqlite3_stmt * stmt ;
    NSString * Id_ = @"";
    
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * temp_id = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if(temp_id != nil)
            {
                Id_= [NSString stringWithUTF8String:temp_id];
            }
        }
    }
    return Id_;
}

-(BOOL)IsChildObject:(NSString *)object_name
{
    int count = 0;
    NSAutoreleasePool * autoreleasePool = [[NSAutoreleasePool alloc] init];
    NSString * query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM '%@'  WHERE object_api_name_child = '%@'" ,SFCHILDRELATIONSHIP,object_name ];
    
    sqlite3_stmt * stmt ;
    
    SMLog(@" IschildObject ----%@" , query);
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            int temp_count = synchronized_sqlite3_column_int(stmt, 0);
            count = temp_count;
        }
    }
    
    [autoreleasePool release];
    
    if(count == 1)
    {
        return TRUE;
    }
    else 
    {
        return FALSE;
    }
    
}

-(BOOL)DeleterecordFromTable:(NSString *)object_name Forlocal_id:(NSString *)local_id
{
    NSString * delete_query = [NSString stringWithFormat:@"DELETE FROM '%@' WHERE local_id = '%@'" ,object_name , local_id ];
    
    char * err ;
    if(synchronized_sqlite3_exec(appDelegate.db, [delete_query UTF8String], NULL, NULL, &err))
    {
        SMLog(@"%@", delete_query);
		SMLog(@"METHOD:DeleterecordFromTable");
		SMLog(@"ERROR IN DELETE %s", err);

        return FALSE;
    }
    return YES;
}

-(void)insertSyncConflictsIntoSYNC_CONFLICT:(NSMutableDictionary *)conflictDict
{
    SMLog(@"SAMMAN insertSyncConflictsIntoSYNC_CONFLICT Processing starts: %@", [NSDate date]);
    NSArray * all_objects = [conflictDict allKeys];
    for(NSString * object_name in  all_objects)
    {
        NSMutableArray *  object_info = [conflictDict objectForKey:object_name];
        for (int i = 0 ; i < [object_info count]; i++) 
        {
            NSDictionary * dict = [ object_info objectAtIndex:i];
            NSArray * all_keys = [dict allKeys];
            NSString * sf_id = @"", * local_id = @"", * sync_type = @"" , * record_type = @"" , * error_message = @"" , * error_type = @"";
            for(NSString * key in all_keys)
            {
                if([key isEqualToString:@"LOCAL_ID"])
                {
                    local_id = [dict objectForKey:@"LOCAL_ID"];
                }
                else if ([key isEqualToString:@"SF_ID"])
                {
                    sf_id = [dict objectForKey:@"SF_ID"];
                }
                else if ([key isEqualToString:@"SYNC_TYPE"])
                {
                    sync_type = [dict objectForKey:@"SYNC_TYPE"];
                }
                else if ([key isEqualToString:@"RECORD_TYPE"])
                {
                    record_type = [dict objectForKey:@"RECORD_TYPE"];
                }
                else if ([key isEqualToString:@"ERROR_MSG"])
                {
                    error_message = [dict objectForKey:@"ERROR_MSG"];
                }
                else if ([key isEqualToString:@"ERROR_TYPE" ])
                {
                    error_type = [dict objectForKey:@"ERROR_TYPE"];
                }
            }
            error_message=[error_message stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            
            NSString * insert_query = [NSString stringWithFormat:@"INSERT INTO '%@' (local_id , sf_id, object_name, sync_type,record_type,error_message,error_type) VALUES ('%@','%@','%@','%@','%@','%@','%@')", SYNC_ERROR_CONFLICT, local_id , sf_id, object_name, sync_type, record_type, error_message, error_type];
            
            char * err;
            
            if(synchronized_sqlite3_exec(appDelegate.db, [insert_query UTF8String],NULL, NULL, &err) != SQLITE_OK)
            {
                SMLog(@"%@", insert_query);
				SMLog(@"METHOD: insertSyncConflictsIntoSYNC_CONFLICT");
				SMLog(@"ERROR IN INSERTING %s", err);
            
            }
            
        }
    }
    SMLog(@"SAMMAN insertSyncConflictsIntoSYNC_CONFLICT Processing ends: %@", [NSDate date]);
}

-(BOOL)DoesTrailerContainTheRecord:(NSString *)local_id  operation_type:(NSString *)operation_type  object_name:(NSString *)object_name
{
    NSString * query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM '%@' WHERE object_name = '%@' and operation = '%@' and local_id = '%@'" ,SFDATATRAILER ,object_name , operation_type , local_id ];
    sqlite3_stmt * stmt;
    int count;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            int temp_count = synchronized_sqlite3_column_int(stmt, 0);
            count = temp_count;
        }
    }
    
    
    synchronized_sqlite3_finalize(stmt);
    if(count == 0)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}


-(NSString *) selectLocalIdFrom:(NSString *)tablename WithId:(NSString *)SFId andParentColumnName:(NSString *)parent_column_name andSyncType:(NSString *)syncType
{
    NSString * selectQuery;
    if ([syncType isEqualToString:@"PUT_INSERT"])
    {
        selectQuery = [NSString stringWithFormat:@"Select %@ From '%@' Where local_id = '%@'",parent_column_name, tablename, SFId];
    }
    else
    {
        selectQuery = [NSString stringWithFormat:@"Select %@ From '%@' Where Id = '%@'",parent_column_name, tablename, SFId]; 
    }
    
    sqlite3_stmt * stmt ;
    NSString * local_Id = @"";
    
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * _local_Id = (char *)synchronized_sqlite3_column_text(stmt, COLUMN_1);
            if(_local_Id != nil)
            {
                local_Id = [NSString stringWithUTF8String:_local_Id];
            }
        }
    }
    
    return local_Id;
}

-(NSMutableArray *)getAllRecordsFromConflictTableForOperationType:(NSString *)operation_type  overrideFlag:(NSString *)override_flag_value
{
    NSMutableArray * array = [[NSMutableArray  alloc] initWithCapacity:0];
    NSArray * keys = [NSArray arrayWithObjects:@"local_id" ,@"object_name" , @"record_type" ,@"sf_id",@"override_flag",nil];
    
    sqlite3_stmt * statement;   
    NSString * query ;
    if([operation_type isEqualToString:PUT_UPDATE] && ([override_flag_value isEqualToString:CLIENT_OVERRIDE] || [override_flag_value isEqualToString:RETRY]))
    {
        query  = [NSString stringWithFormat:@"SELECT  local_id , object_name , record_type, sf_id ,override_flag FROM '%@' WHERE sync_type = '%@'   and (override_flag = '%@' or override_flag = '%@')" ,SYNC_ERROR_CONFLICT , operation_type , CLIENT_OVERRIDE,RETRY];
    }
    else 
    {
        query  = [NSString stringWithFormat:@"SELECT  local_id , object_name , record_type, sf_id ,override_flag FROM '%@' WHERE sync_type = '%@'   and override_flag = '%@'" ,SYNC_ERROR_CONFLICT , operation_type , override_flag_value];
    }
    
    NSString * local_id = @"", * object_name = @""  , * record_type = @"" , * sf_id = @"" , * override_flag = @"" ;
    
    SMLog(@" getAllRecords  %@", query);
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1 , &statement , nil)  ==  SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement)== SQLITE_ROW)
        {
            local_id = @"", object_name = @"",record_type = @"" ,  sf_id = @"";
            
            char * temp_loca_id = (char *) synchronized_sqlite3_column_text(statement, 0);
            if(temp_loca_id != nil )
                local_id = [ NSString stringWithUTF8String:temp_loca_id];
            
            char * temp_object_name = (char *) synchronized_sqlite3_column_text(statement, 1);
            if(temp_object_name != nil)
                object_name = [NSString stringWithUTF8String:temp_object_name];

            char * temp_record_type = (char *) synchronized_sqlite3_column_text(statement, 2);
            if(temp_record_type != nil)
                record_type = [NSString stringWithUTF8String:temp_record_type];
            
            char * temp_sf_id = (char *) synchronized_sqlite3_column_text(statement, 3);
            if(temp_sf_id != nil)
                sf_id = [NSString stringWithUTF8String:temp_sf_id];
            
            char * temp_override = (char *) synchronized_sqlite3_column_text(statement, 4);
            if(temp_override != nil)
                override_flag = [NSString stringWithUTF8String:temp_override];
            
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id, object_name ,record_type,sf_id,override_flag,nil] forKeys:keys];
            [array addObject:dict];
        }
    }
    
    return array;
}

-(NSString *) getParentIdFrom:(NSString *)tablename WithId:(NSString *)Id_ andParentColumnName:(NSString *)parent_column_name id_type:(NSString *)id_type
{
	//Sahana fix for defect #5818
    NSString * selectQuery = [NSString stringWithFormat:@"Select %@ From '%@' Where %@ = '%@'",parent_column_name, tablename,id_type, Id_];
    
    sqlite3_stmt * stmt ;
    
    NSString * local_Id = @"";
    
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * _local_Id = (char *)synchronized_sqlite3_column_text(stmt, COLUMN_1);
            if(_local_Id != nil)
            {
                local_Id = [NSString stringWithUTF8String:_local_Id];
            }
        }
    }
    
    return local_Id;
}

-(void) deleteAll_GET_DELETES_And_PUT_DELETE_From_HeapAndObject_tables:(NSString *)sync_type ; 
{
    NSMutableDictionary * delete_list = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSString * query = [NSString stringWithFormat:@"SELECT sf_id ,object_name FROM  '%@' WHERE  sync_type = '%@'" , SYNC_RECORD_HEAP,sync_type];
    sqlite3_stmt * stmt ;
    NSString * sf_id = @"" , * object_name = @"";
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * temp_sf_id = (char *) synchronized_sqlite3_column_text(stmt, 0);
            if(temp_sf_id != nil)
            {
                sf_id = [NSString stringWithUTF8String:temp_sf_id];
            }
            char * temp_object_name = (char *) synchronized_sqlite3_column_text(stmt, 1);
            if (temp_object_name != nil)
            {
                object_name = [NSString stringWithUTF8String:temp_object_name];
            }
            
            NSArray * allkeys = [delete_list allKeys];
            BOOL object_exists = FALSE;
            for(NSString * str in allkeys)
            {
                if([str isEqualToString:object_name])
                {
                    object_exists = TRUE;
                    break;
                }
            }
            
            if(object_exists)
            {
                NSMutableArray * array  = [delete_list objectForKey:object_name];
                [array addObject:sf_id];
                
            }
            else
            {
                NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:0];
                [array addObject:sf_id];
                [delete_list setObject:array forKey:object_name];
            }
        }
        
    }
    
    [self deleteAllrecordsWithSF_ID:delete_list];
}

- (void) deleteAllrecordsWithSF_ID:(NSMutableDictionary *)delete_list
{
    NSArray * allkeys = [delete_list allKeys];
    for (NSString * object_name in allkeys)
    {
        NSArray * deleteId = [delete_list objectForKey:object_name];
        
        for (NSString * sf_id in deleteId)
        {
            [self DeleterecordFromTableWithSf_Id:SYNC_RECORD_HEAP sf_id:sf_id withColumn:@"sf_id"];
            [self DeleterecordFromTableWithSf_Id:SFDATATRAILER sf_id:sf_id withColumn:@"sf_id"];
            
            NSString * local_id = [self getLocalIdFromSFId:sf_id tableName:object_name];
            if([local_id length ]!= 0 && ![local_id isEqualToString:@""] && local_id != nil)
            {
                [self DeleterecordFromTableWithSf_Id:SFDATATRAILER sf_id:local_id withColumn:@"parent_local_id"];
            }
            //if the id is MASTER record id , for that master record id 
            [self DeleterecordFromTableWithSf_Id:object_name sf_id:sf_id withColumn:@"Id"];
        }
    }
}

-(void) DeleterecordFromTableWithSf_Id:(NSString *)object_name sf_id:(NSString *)sf_id withColumn:(NSString *)columnName
{
    NSString * delete_query = [NSString stringWithFormat:@"DELETE FROM '%@' WHERE %@ = '%@'" ,object_name, columnName, sf_id];
    SMLog(@"delete_query - - %@",delete_query);
    char * err ;
    if(synchronized_sqlite3_exec(appDelegate.db, [delete_query UTF8String], NULL, NULL, &err))
    {
        SMLog(@"%@", delete_query);
		SMLog(@"METHOD:DeleterecordFromTableWithSf_Id");
		SMLog(@"ERROR IN DELETE %s", err);

    }
}

-(void)deleteAllConflictedRecordsFrom:(NSString *)tableName
{
    NSArray * sync_type_array = [NSArray arrayWithObjects:PUT_UPDATE ,PUT_DELETE, PUT_INSERT, nil];
    
    for(NSString * sync_type  in sync_type_array)
    {
        
        NSMutableArray * conflict_records = [self getAllRecordsFromConflictTableForOperationType:sync_type];
        for(int i = 0 ; i< [conflict_records count]; i++)
        {
            NSMutableDictionary * dict = [conflict_records objectAtIndex:i];
            NSArray * allkeys = [dict allKeys];
            NSString * sf_id = @"";
            NSString * local_id = @"";
            for(NSString * key in allkeys)
            {
                if([key isEqualToString:@"sf_id"])
                {
                    sf_id = [dict objectForKey:key];
                }
                if([key isEqualToString:@"local_id"])
                {
                    local_id = [dict objectForKey:key];
                }
            }
            if([sync_type isEqualToString:PUT_INSERT])
            {
                [self DeleterecordFromTableWithSf_Id:tableName sf_id:local_id withColumn:@"local_id"];
            }
            else  if ([sync_type isEqualToString:PUT_UPDATE] || [sync_type isEqualToString:PUT_DELETE])
            {
                [self DeleterecordFromTableWithSf_Id:tableName sf_id:sf_id withColumn:@"sf_id"];
            }
        }
    }
}


-(NSMutableArray *)getAllRecordsFromConflictTableForOperationType:(NSString *)operation_type  
{
    NSMutableArray * array = [[NSMutableArray  alloc] initWithCapacity:0];
    NSArray * keys = [NSArray arrayWithObjects:@"local_id" ,@"object_name" , @"record_type" ,@"sf_id",@"override_flag",nil];
    
    sqlite3_stmt * statement;
    NSString * query ;

    query  = [NSString stringWithFormat:@"SELECT  local_id , object_name , record_type, sf_id ,override_flag FROM '%@' WHERE sync_type = '%@'   " ,SYNC_ERROR_CONFLICT , operation_type ];
    
    NSString * local_id = @"", * object_name = @""  , * record_type = @"" , * sf_id = @"" , * override_flag = @"" ;
    
    SMLog(@" getAllRecords  %@", query);
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1 , &statement , nil)  ==  SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement)== SQLITE_ROW)
        {
            local_id = @"", object_name = @"",record_type = @"" ,  sf_id = @"";
            
            char * temp_loca_id = (char *) synchronized_sqlite3_column_text(statement, 0);
            if(temp_loca_id != nil )
                local_id = [ NSString stringWithUTF8String:temp_loca_id];
            
            char * temp_object_name = (char *) synchronized_sqlite3_column_text(statement, 1);
            if(temp_object_name != nil)
                object_name = [NSString stringWithUTF8String:temp_object_name];
            
            char * temp_record_type = (char *) synchronized_sqlite3_column_text(statement, 2);
            if(temp_record_type != nil)
                record_type = [NSString stringWithUTF8String:temp_record_type];
            
            char * temp_sf_id = (char *) synchronized_sqlite3_column_text(statement, 3);
            if(temp_sf_id != nil)
                sf_id = [NSString stringWithUTF8String:temp_sf_id];
            
            char * temp_override = (char *) synchronized_sqlite3_column_text(statement, 4);
            if(temp_override != nil)
                override_flag = [NSString stringWithUTF8String:temp_override];
            
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id, object_name ,record_type,sf_id,override_flag,nil] forKeys:keys];
            [array addObject:dict];
        }
    }
    return array;
}

-(BOOL)getConflictsStatus
{
    int count = 0;
    NSString * query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ " , SYNC_ERROR_CONFLICT];
    
    sqlite3_stmt * stmt;
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            count = synchronized_sqlite3_column_int(stmt, 0); 
        }
    }
    
    if (count > 0)
        return TRUE;
    else 
        return FALSE;
}

-(void)deleterecordsFromConflictTableForOperationType:(NSString *)opeation_type overrideFlag:(NSString *)override_flag  table_name:(NSString *)table_name   id_value:(NSString *)id_   field_name:(NSString *)field_name 
{
    NSString * delete_stmt ;
    if([opeation_type isEqualToString:PUT_UPDATE] && [override_flag isEqualToString:CLIENT_OVERRIDE])
    {
        delete_stmt = [NSString stringWithFormat:@"DELETE FROM %@  WHERE sync_type = '%@'  and (override_flag ='%@'  or override_flag = '%@' ) and %@ = '%@'",table_name,opeation_type,CLIENT_OVERRIDE,NONE , field_name , id_];
    }
    else
    {
        delete_stmt = [NSString stringWithFormat:@"DELETE FROM %@  WHERE sync_type = '%@'  and override_flag ='%@' and %@ = '%@'",table_name,opeation_type,override_flag, field_name , id_];
    }
    
    char * err ;
    if(synchronized_sqlite3_exec(appDelegate.db, [delete_stmt UTF8String], NULL, NULL, &err))
    {
        SMLog(@"%@", delete_stmt);
		SMLog(@"METHOD:deleterecordsFromConflictTableForOperationType");
		SMLog(@"ERROR IN DELETE %s", err);

    }
}


-(NSString *)getPicklistINfo_isdependentOrControllername_For_field_name:(NSString *)field_name  field_api_name:(NSString *)field_api_name   object_name:(NSString *)object_name
{
    sqlite3_stmt * statement;
    NSString * temp_field = @"";
    NSString  * select_stmt = [NSString stringWithFormat:@"SELECT %@ FROM  %@ WHERE api_name = '%@' AND object_api_name = '%@'", field_name , SFOBJECTFIELD,field_api_name , object_name];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [select_stmt UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            char * temp_field_name_value = (char *) synchronized_sqlite3_column_text(statement, 0);
            if(temp_field_name_value != nil)
            {
                temp_field = [NSString stringWithUTF8String:temp_field_name_value];
            }
            
        }
    }
    return temp_field;
}

-(NSMutableDictionary *)getValidForDictForObject:(NSString *)object_name  field_api_name:(NSString *)field_api_name
{
    
    NSMutableDictionary * picklistValues = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSString * query = [NSString stringWithFormat:@"SELECT valid_for , value FROM '%@' WHERE %@ = '%@'  and %@ = '%@' ",SFPICKLIST,@"object_api_name",object_name,@"field_api_name",field_api_name];
    
    sqlite3_stmt * stmt ;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            NSString * label = @"" , * value = @"";
            char * temp_label = (char *)synchronized_sqlite3_column_text(stmt, 0);
            char * temp_value = (char *)(char*)synchronized_sqlite3_column_text(stmt, 1);
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
    
    synchronized_sqlite3_finalize(stmt);
    return picklistValues;
}


-(void)fillDependencyPickListInfo
{
    NSMutableArray * describeObjects = [[self getAllobjectsApiNameFromSFObjectField] retain];
    [[ZKServerSwitchboard switchboard] describeSObjects:describeObjects  target:self selector:@selector(didDescribeSObjects:error:context:) context:nil];
}

-(NSMutableArray *)getAllobjectsApiNameFromSFObjectField
{
    NSMutableArray * objects_list = [[NSMutableArray alloc] initWithCapacity:0];
    NSString * query = [NSString  stringWithFormat:@"SELECT  DISTINCT object_api_name  FROM SFObjectField"];
    sqlite3_stmt * statement;
    NSString * object_api = @"";
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1 , &statement , nil)  ==  SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement)== SQLITE_ROW)
        {
            object_api = @"";
            char * temp_object_api_name = (char *) synchronized_sqlite3_column_text(statement,0);
            object_api = [NSString stringWithUTF8String:temp_object_api_name];
            
            if ([object_api length] > 0)
            {
                if (![objects_list containsObject:object_api])
                    [objects_list addObject:object_api];
            }
    
        }
    }
    
    return objects_list;
}

-(void)didDescribeSObjects:(NSMutableArray *)result error:(NSError *)error context:(id)context
{
    [result retain];
    
    if(error != nil)
    {
        appDelegate.connection_error = TRUE;
        return;
    }
    for (int i = 0; i < [result count]; i++)
    {
        ZKDescribeSObject * descObj = [result objectAtIndex:i];
        
        NSString * object_name = [descObj name];
        NSArray * fields = [descObj fields];
        
        for (ZKDescribeField * field_describe in fields)
        {
            NSString * field_api_name = [field_describe name];
            NSString * type = [field_describe  type];
            
			//Shrinvas : Fix for Defect : 6011
			if ([type isEqualToString:@"multipicklist"])
			{
				if ([field_api_name isEqualToString:@"multipicklist_multiplelenght__c"])
				{
					NSLog(@"STOP");
				}
				NSArray * multipickListEntryArray = [field_describe picklistValues];
				
                for (int k = 0; k < [multipickListEntryArray count]; k++)
                {
					
                    NSString * value = [[multipickListEntryArray objectAtIndex:k] value];
                    
                    [self UpdateSFPicklistForMultiSelect_IndexValue_For_Oject_Name:object_name field_api_name:field_api_name value:value index:k];
                }
			}
			
            if([type isEqualToString:@"picklist"])
            {
                BOOL  isdependentPicklist = [field_describe dependentPicklist];
                
                NSString *  dependent_value = (isdependentPicklist == TRUE)? @"true":@"false";
                NSString * controller_name = [field_describe controllerName];
                
                //update the controller type for the object anf field_name 
                if(isdependentPicklist)
                {
                    [self UpdateSFObjectField_For_Picklist_TypeObject:object_name field_api_name:field_api_name dependent_picklist:dependent_value controler_field_name:controller_name];
                }
                else
                {
                    [self UpdateSFObjectField_For_Picklist_TypeObject:object_name field_api_name:field_api_name dependent_picklist:@"false" controler_field_name:@""];
                }
                NSArray * pickListEntryArray = [field_describe picklistValues];
               
                for (int k = 0; k < [pickListEntryArray count]; k++)
                {
                    NSString * value = [[pickListEntryArray objectAtIndex:k] value];
                    ZKPicklistEntry * picklistEntry = [pickListEntryArray objectAtIndex:k];
                    NSString * validFor = [picklistEntry validFor];
                    
                    [self UpdateSFPicklist_validFor_For_Oject_Name:object_name field_api_name:field_api_name value:value valid_for_value:validFor  index:k];
                }
            }
		}
    }

    appDelegate.dPicklist_retrieval_complete = TRUE;
}

-(BOOL)UpdateSFObjectField_For_Picklist_TypeObject:(NSString *)object_api_name field_api_name:(NSString *)field_api_name  dependent_picklist:(NSString *)dependent_value  controler_field_name:(NSString *)controler_field
{
    NSString * query = [NSString stringWithFormat:@"UPDATE  '%@' SET  dependent_picklist = '%@' , controler_field = '%@' WHERE  object_api_name = '%@' AND api_name = '%@' " ,SFOBJECTFIELD , dependent_value , controler_field , object_api_name,field_api_name];
    char * err ;
    if(synchronized_sqlite3_exec(appDelegate.db, [query UTF8String], NULL, NULL, &err))
    {
        SMLog(@"%@", query);
		SMLog(@"METHOD:UpdateSFObjectField_For_Picklist_TypeObject " );
		SMLog(@"ERROR IN UPDATING %s", err);

        return FALSE;
    }
    return TRUE;
}


//Shrinivas : method for multiselect
-(void) UpdateSFPicklistForMultiSelect_IndexValue_For_Oject_Name:(NSString *)object_name  field_api_name:(NSString *)field_api_name value:(NSString *)value  index:(int)index_value
{    
    if([value isKindOfClass:[NSString class]])
        value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    NSString * query = [NSString stringWithFormat:@"UPDATE  '%@' SET   index_value = '%d'  WHERE  object_api_name = '%@' AND field_api_name = '%@'  AND value = '%@'" , SFPicklist  ,index_value, object_name , field_api_name , value ];
	
	char * err ;
    if(synchronized_sqlite3_exec(appDelegate.db, [query UTF8String], NULL, NULL, &err))
    {
        SMLog(@"%@", query);
		SMLog(@"METHOD:UpdateSFPicklistForMultiSelect_IndexValue_For_Oject_Name " );
		SMLog(@"ERROR IN UPDATING %s", err);

        
    }
}


-(BOOL)UpdateSFPicklist_validFor_For_Oject_Name:(NSString *)object_name  field_api_name:(NSString *)field_api_name value:(NSString *)value  valid_for_value:(NSString *)valid_for_value  index:(int)index_value
{
     if(valid_for_value == nil)
     {
         valid_for_value = @"";
     }
    
    if([value isKindOfClass:[NSString class]])
        value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    NSString * query = [NSString stringWithFormat:@"UPDATE  '%@' SET  valid_for = '%@' , index_value = '%d'  WHERE  object_api_name = '%@' AND field_api_name = '%@'  AND value = '%@'" , SFPicklist , valid_for_value ,index_value, object_name , field_api_name , value ];
	
	char * err ;
    if(synchronized_sqlite3_exec(appDelegate.db, [query UTF8String], NULL, NULL, &err))
    {
        SMLog(@"%@", query);
		SMLog(@"METHOD:UpdateSFPicklist_validFor_For_Oject_Name " );
		SMLog(@"ERROR IN UPDATING %s", err);

        return FALSE;
    }
    return TRUE;
}

-(int)getIndexOfPicklistValueForOject_Name:(NSString *)object_name  field_api_name:(NSString *)field_api_name value:(NSString *)value
{
    NSString * query = [NSString  stringWithFormat:@"SELECT  index_value  FROM SFPicklist  WHERE object_api_name = '%@' AND field_api_name = '%@' AND label = '%@' ", object_name , field_api_name , value];
    sqlite3_stmt * statement;
    int index_value = 9999999;
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1 , &statement , nil)  ==  SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement)== SQLITE_ROW)
        {
            index_value =  synchronized_sqlite3_column_int(statement,0);
        }
    }
    
    return index_value;
}

-(NSMutableArray *)getAllDependentPicklistSWhenControllerValueChanged:(NSString *)object_name controller_name:(NSString*)controllername
{
    NSMutableArray * dependent_fields = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    NSString * query = [NSString  stringWithFormat:@"SELECT  api_name  FROM SFObjectField  WHERE object_api_name = '%@' AND %@ = '%@'", object_name , CONTROLLER_FIRLD,controllername];
    NSString * field_api_name = @"";
    sqlite3_stmt * statement;
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1 , &statement , nil)  ==  SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement)== SQLITE_ROW)
        {
            field_api_name = @"";
            char * temp_field_name = (char *) synchronized_sqlite3_column_text(statement, 0);
            
            if (temp_field_name != nil)
            {
                field_api_name  = [NSString stringWithUTF8String:temp_field_name];
                
                [dependent_fields addObject:field_api_name];
            }
        }
    }
    return dependent_fields;
}

-(NSMutableArray *)getRecordTypeValuesForObjectName:(NSString *)object_name
{
    NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:0];
    [array addObject:@""];
    NSString * query = [NSString stringWithFormat:@"SELECT DISTINCT recordtypename FROM SFRTPicklist Where object_api_name = '%@'",object_name];
    sqlite3_stmt * statement;
    NSString * record_type= @"";
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1 , &statement , nil)  ==  SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement)== SQLITE_ROW)
        {
            char * field_api_name  = (char *) synchronized_sqlite3_column_text(statement, 0);
            
            if(field_api_name != nil)
            {
                record_type = [NSString stringWithUTF8String:field_api_name];
                if (![record_type isEqualToString:@"Master"])
                    [array addObject:record_type];
            }
        }
    }
    return array;
}

-(BOOL)checkForRTPicklistForFieldApiName:(NSString *)fieldApiName  objectApiname:(NSString *)objectApiName recordTypeId:(NSString *)recordTypeId
{
    NSString * query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM SFRTPicklist Where object_api_name = '%@' AND recordtypeid = '%@' AND field_api_name = '%@'",objectApiName , recordTypeId,fieldApiName];
    int count=0;
    sqlite3_stmt * statement;
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1 , &statement , nil)  ==  SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement)== SQLITE_ROW)
        {
            count = synchronized_sqlite3_column_int(statement, 0);
        }
    }
    if(count > 0)
        return TRUE;
    else
        return FALSE;
}

-(NSMutableArray *)getRTPicklistValuesForFieldApiName:(NSString *)field_api_name  objectApiName:(NSString *)objectApiName  recordTypeId:(NSString *)recordTypeId
{
    NSMutableArray * RTPicklistValues = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    [RTPicklistValues addObject:@""];
    NSString * picklist_value = @"";
    NSString * query = [NSString stringWithFormat:@"SELECT label FROM SFRTPicklist Where object_api_name = '%@' AND recordtypeid = '%@' AND field_api_name = '%@'",objectApiName,recordTypeId,field_api_name];
    sqlite3_stmt * statement;
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1 , &statement , nil)  ==  SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement)== SQLITE_ROW)
        {
            picklist_value = @"";
            char * temp_picklist_value = (char *) synchronized_sqlite3_column_text(statement, 0);
            
            if(temp_picklist_value != nil)
            {
                picklist_value = [NSString stringWithUTF8String:temp_picklist_value];
                [RTPicklistValues addObject:picklist_value];
            }
        }
    }
    return RTPicklistValues;
}

-(NSString *)getRecordTypeIdForRecordTypename:(NSString *)recorTypeName objectApi_name:(NSString *)objectApiName
{
    NSString * picklist_value = @"";
    NSString * query = [NSString stringWithFormat:@"SELECT recordtypeid FROM SFRTPicklist Where object_api_name = '%@' AND recordtypename = '%@' ",objectApiName,recorTypeName];
    sqlite3_stmt * statement;
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1 , &statement , nil)  ==  SQLITE_OK)
    {
        if (synchronized_sqlite3_step(statement)== SQLITE_ROW)
        {
            picklist_value = @"";
            char * temp_picklist_value = (char *) synchronized_sqlite3_column_text(statement, 0);
            
            if(temp_picklist_value != nil)
            {
                picklist_value = [NSString stringWithUTF8String:temp_picklist_value];
            }
        }
    }
    return picklist_value;
}

-(NSMutableArray *)getRtDependentPicklistsForObject:(NSString *)objectName recordtypeName:(NSString *)recordtypeName
{
    NSMutableArray * RTPicklistValues = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    [RTPicklistValues addObject:@""];
    NSString * picklist_value = @"";
    NSString * query = [NSString stringWithFormat:@"SELECT  DISTINCT field_api_name FROM SFRTPicklist Where object_api_name = '%@' AND recordtypename = '%@'",objectName,recordtypeName];
    sqlite3_stmt * statement;
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1 , &statement , nil)  ==  SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement)== SQLITE_ROW)
        {
            picklist_value = @"";
            char * temp_picklist_value = (char *) synchronized_sqlite3_column_text(statement, 0);
            
            if(temp_picklist_value != nil)
            {
                picklist_value = [NSString stringWithUTF8String:temp_picklist_value];
                [RTPicklistValues addObject:picklist_value];
            }
        }
    }
    return RTPicklistValues;
}

-(NSString *)getDefaultValueForRTPicklist:(NSString *)objectName recordtypeName:(NSString *)recordtypeName  field_api_name:(NSString *)field_api_name  type:(NSString *)returnField
{
    NSString * query =@"";
    NSString * default_value = @"" ;
    if([returnField  isEqualToString:@"Label"])
    {    
        query = [NSString stringWithFormat:@"SELECT  DISTINCT defaultlabel FROM SFRTPicklist Where object_api_name = '%@' AND recordtypename = '%@' AND field_api_name = '%@'",objectName,recordtypeName , field_api_name];
    }
    else  if([returnField  isEqualToString:@"Value"])
    {
        query = [NSString stringWithFormat:@"SELECT  DISTINCT defaultvalue FROM SFRTPicklist Where object_api_name = '%@' AND recordtypename = '%@'  AND field_api_name = '%@'",objectName,recordtypeName, field_api_name];
    }
    sqlite3_stmt * statement;
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1 , &statement , nil)  ==  SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement)== SQLITE_ROW)
        {
            char * temp_picklist_value = (char *) synchronized_sqlite3_column_text(statement, 0);
            
            if(temp_picklist_value != nil)
            {
                default_value = [NSString stringWithUTF8String:temp_picklist_value];
            }
        }
    }
    return default_value;
}

- (NSString *) getDefaultValueForRTPicklistDependency:(NSString *)objectName recordtypeId:(NSString *)recordtypeId field_api_name:(NSString *)field_api_name
{
    NSString * defaultValue = @"";
    
    sqlite3_stmt * statement;
    NSString * selectQuery = [NSString stringWithFormat:@"SELECT DISTINCT defaultvalue FROM SFRTPicklist where object_api_name = '%@' and field_api_name = '%@' and recordtypeid ='%@'", objectName, field_api_name, recordtypeId];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1 , &statement , nil)  ==  SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement)== SQLITE_ROW)
        {
            char * _defaultValue = (char *) synchronized_sqlite3_column_text(statement, COLUMN_1);
            
            if(_defaultValue != nil)
            {
                defaultValue = [NSString stringWithUTF8String:_defaultValue];
            }
        }
    }
    
    return defaultValue;
}

-(NSArray *)getAllIdsFromDatabase:(NSString *)sync_type forObjectName:(NSString *)object_name
{   
    NSString * str = [[NSString alloc] initWithFormat:@"SELECT sf_id FROM sync_Records_Heap WHERE sync_type = '%@' and object_name = '%@'" , sync_type, object_name];
    NSString * default_value = @"";
    
    NSMutableArray * array = [[[NSMutableArray alloc] initWithCapacity:0]autorelease];
    sqlite3_stmt * statement;
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [str UTF8String], -1 , &statement , nil)  ==  SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement)== SQLITE_ROW)
        {
            default_value = @"";
            char * temp_id_value = (char *) synchronized_sqlite3_column_text(statement, 0);
            if(temp_id_value != nil)
            {
                default_value = [NSString stringWithUTF8String:temp_id_value];
                [array addObject:default_value];
            }
        }
    }
    
    [str release];
    synchronized_sqlite3_finalize(statement);
    return array;
}

-(void)deleteDownloadCriteriaObjects:(NSArray *)deleted_objects
{
    for(NSString * str in deleted_objects)
    {
        char * err;
        NSString * delete_Statement = [[NSString alloc] initWithFormat:@"DELETE FROM '%@' where upper(Id) not in (SELECT upper(WhatId) FROM Event) and  upper(Id) not in (SELECT upper(Id) FROM LookUpFieldValue)",str];
        
        SMLog(@"delete Statementb %@" , delete_Statement);
        if (synchronized_sqlite3_exec(appDelegate.db, [delete_Statement UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
			SMLog(@"%@", delete_Statement);
			SMLog(@"METHOD:deleteDownloadCriteriaObjects");
			SMLog(@"ERROR IN DELETE %s", err);
      
		}
        [delete_Statement release];
    }
}

//sahana code starts    june8th
-(BOOL)ContinueIncrementalDataSync
{
    sqlite3_stmt * statement;
    int count = 0;
    NSString * query = [[[NSString alloc] initWithFormat:@"SELECT COUNT(*) FROM SFDataTrailer"] autorelease];
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String],-1, &statement, nil) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement)== SQLITE_ROW)
        {
             count =  sqlite3_column_int(statement, 0);
            
        }
    }
    if(count == 0)
    {
        return FALSE;
    }
    else
        return TRUE;
}

 //sahana 16th June 2012
-(NSString *)getRefernceToFieldnameForObjct:(NSString *) object_name reference_table:(NSString *)reference_table table_name:(NSString *)table_name;
{
    NSString * referencetoName = @"";
    NSString * query = [NSString stringWithFormat:@"SELECT field_api_name  FROM '%@' where object_api_name = '%@' and reference_to = '%@'" ,table_name,object_name ,reference_table];
    sqlite3_stmt * stmt ;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * temp_referenceToName = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if(temp_referenceToName != nil)
            {
                referencetoName = [NSString stringWithUTF8String:temp_referenceToName];
            }
        }
    }
    synchronized_sqlite3_finalize(stmt);
    return referencetoName;
}

-(BOOL)checkOndemandRecord:(NSString *)local_id
{
    sqlite3_stmt * statement;
    int count = 0;
    NSString * query = [[[NSString alloc] initWithFormat:@"SELECT COUNT(*) FROM on_demand_download where local_id  = '%@'",local_id] autorelease];
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String],-1, &statement, nil) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement)== SQLITE_ROW)
        {
            count =  sqlite3_column_int(statement, 0);
            
        }
    }
    if(count == 0)
    {
        return FALSE;
    }
    else
        return TRUE;
}

-(void)deleteAllOndemandRecordsPartOfDownloadCriteriaForSfId:(NSString *)sf_id
{
    NSString * delete_statement = [NSString stringWithFormat:@"DELETE FROM on_demand_download  WHERE sf_id = '%@'",sf_id];
    char * err;
    
    if (synchronized_sqlite3_exec(appDelegate.db, [delete_statement UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(@"%@", delete_statement);
		SMLog(@"METHOD:deleteAllOndemandRecordsPartOfDownloadCriteriaForSfId");
		SMLog(@"ERROR IN DELETE %s", err);
      
    }
    
}
-(NSMutableArray *)getAllOndemandObejcts
{
    NSString * query = [[NSString alloc] initWithFormat:@"SELECT DISTINCT object_name FROM on_demand_download"];
    NSMutableArray * ondemand_objects = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    sqlite3_stmt * statement;
    
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String],-1, &statement, nil) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement)== SQLITE_ROW)
        {
            NSString * object_name = @"";
            char * temp_referenceToName = (char *)synchronized_sqlite3_column_text(statement, 0);
            if(temp_referenceToName != nil)
            {
                object_name = [NSString stringWithUTF8String:temp_referenceToName];
                [ondemand_objects addObject:object_name];
            }
        }
        synchronized_sqlite3_finalize(statement);
    }
    
    
    if([ondemand_objects retainCount] == 1)
        [ondemand_objects retain];
    return ondemand_objects;
    
}

-(NSArray *)getAllIdsFromDatabaseForSyncType:(NSString *)sync_type
{
    
    NSString * str = [[NSString alloc] initWithFormat:@"SELECT sf_id FROM sync_Records_Heap WHERE sync_type = '%@' " , sync_type];
    NSString * default_value = @"";
    
    NSMutableArray * array = [[[NSMutableArray alloc] initWithCapacity:0]autorelease];
    sqlite3_stmt * statement;
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [str UTF8String], -1 , &statement , nil)  ==  SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement)== SQLITE_ROW)
        {
            default_value = @"";
            char * temp_id_value = (char *) synchronized_sqlite3_column_text(statement, 0);
            if(temp_id_value != nil)
            {
                default_value = [NSString stringWithUTF8String:temp_id_value];
                [array addObject:default_value];
            }
        }
    }
    
    [str release];
    synchronized_sqlite3_finalize(statement);
    return array;
}

-(void)updateOndemandRecordForId:(NSString *)record_id
{
    NSDate * date = [NSDate date];
    NSString * today_Date = @"";
    NSDateFormatter * dateFormatter  = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    today_Date = [dateFormatter stringFromDate:date];
    
    NSString * update_query = [NSString stringWithFormat:@"UPDATE on_demand_download SET time_stamp = '%@' where sf_id = '%@'", today_Date,record_id];
    char * err;
    
    if (synchronized_sqlite3_exec(appDelegate.db, [update_query UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(@"%@", update_query);
		SMLog(@"METHOD:updateOndemandRecordForId " );
		SMLog(@"ERROR IN UPDATING %s", err);

    }
    
    [dateFormatter release];
}

-(NSString *)getTimeLastModifiedTimeOfTheRecordForRecordId:(NSString *)record_id
{
    NSString * query = [[NSString alloc] initWithFormat:@"SELECT time_stamp FROM on_demand_download where local_id = '%@'",record_id];
    sqlite3_stmt * statement;
    NSString * time_stamp = @"";
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String],-1, &statement, nil) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement)== SQLITE_ROW)
        {
            
            char * temp_referenceToName = (char *)synchronized_sqlite3_column_text(statement, 0);
            if(temp_referenceToName != nil)
            {
                time_stamp = [NSString stringWithUTF8String:temp_referenceToName];
            }
        }
        synchronized_sqlite3_finalize(statement);
    }
    return time_stamp;
}
//sahana code ends    june8th

-(BOOL)isSFObject:(NSString*)objectName
{
    sqlite3_stmt * statement;
    int count = 0;
    NSString * query = [[[NSString alloc] initWithFormat:@"SELECT COUNT(*) FROM SFObject where api_name= '%@'",objectName] autorelease];
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String],-1, &statement, nil) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement)== SQLITE_ROW)
        {
            count =  sqlite3_column_int(statement, 0);
        }
    }
    if(count == 0)
    {
        return FALSE;
    }
    else
        return TRUE;
}

-(NSDictionary *)getAllChildRelationShipForObject:(NSString *)object_name
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSString * query = [[NSString  alloc ]  initWithFormat:@"SELECT  object_api_name_child ,field_api_name FROM SFChildRelationship where  object_api_name_parent = '%@' ",object_name];
    sqlite3_stmt * stmt ;
    
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            NSString *childtName = @"" ,*fieldName = @"";
            char * temp_ObjapiName= (char *)synchronized_sqlite3_column_text(stmt, 0);
             char * temp_fieldName = (char *)synchronized_sqlite3_column_text(stmt, 1);
            if(temp_ObjapiName != nil)
            {
                childtName = [NSString stringWithUTF8String:temp_ObjapiName];
            }
            if(temp_fieldName != nil)
            {
                fieldName = [NSString stringWithUTF8String:temp_fieldName];
            }
            [dict setObject:fieldName forKey:childtName];
            
        }
    }
    synchronized_sqlite3_finalize(stmt);
    [query release];
    return dict;
}

-(void)insertOndemandRecords:(NSMutableDictionary *)record_dict
{
    [record_dict retain];
    NSArray * allkeys = [record_dict allKeys];
    NSMutableDictionary * child_dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSString * master_object_name = @"" , * master_local_id = @"";
    
    for(NSString * recordType in allkeys)
    {
        NSDictionary * dict = [record_dict objectForKey:recordType];
        
        NSArray * allObjects = [dict allKeys];
        NSString * object_name = @"";
        
        if([allObjects count] > 0)
          object_name =  [allObjects objectAtIndex:0];
        
        NSArray * allrecords = [dict objectForKey:object_name];
        
        for(NSString * json_record in allrecords)
        {
            NSMutableDictionary * final_dict = [self getDictForJsonString:json_record];
            
            NSString * local_id = @"";
           
            NSString * sf_id = [final_dict objectForKey:@"Id"];
            BOOL check_flag = [appDelegate.dataBase checkForDuplicateId:object_name sfId:sf_id];
            //call insert method 
            if(check_flag)
            {
                 NSString * guid_id = [iServiceAppDelegate GetUUID];
                local_id = guid_id;
                [final_dict setObject:guid_id forKey:@"local_id"];
                [self insertdataIntoTable:object_name data:final_dict];
                if([recordType isEqualToString:MASTER])
                {
                    master_object_name = object_name;
                    master_local_id = guid_id;
                }
               
            }
            else
            {
                NSString * existing_local_id = [self getLocalIdFromSFId:sf_id tableName:object_name];
                local_id = existing_local_id;
                if([recordType isEqualToString:MASTER])
                {
                    master_object_name = object_name;
                    master_local_id = existing_local_id;
                }
                
                BOOL flag = [self UpdateTableforSFId:sf_id forObject:object_name data:final_dict];
                if(flag)
                {
                }
            }
            
            [self insertrecordintoOnDemandTableForId:sf_id  recordType:recordType local_id:local_id json_record:json_record object_name:object_name];
            
            if([recordType isEqualToString:DETAIL])
            {
                NSArray * all_child_objects = [child_dict allKeys];
                if([all_child_objects containsObject:object_name])
                {
                    NSMutableArray * child_ids = [child_dict objectForKey:object_name]; 
                    [child_ids addObject:sf_id];
                }
                else
                {
                    NSMutableArray * allChild_ids  = [[NSMutableArray alloc] initWithCapacity:0];
                    [allChild_ids addObject:sf_id];
                    [child_dict setObject:allChild_ids forKey:object_name];
                    [allChild_ids release];
                    
                }  
            }   
            [final_dict release];
        }
        
    }
    if(![master_object_name isEqualToString:@""] && ![master_local_id isEqualToString:@""] && [child_dict count] > 0 )
    {
        [self updateChildParentColumnNameForParentObject:master_object_name masterLocalId:master_local_id child_info:child_dict];
    }
    [record_dict release];
}

-(void)updateChildParentColumnNameForParentObject:(NSString *)master_object masterLocalId:(NSString *)masterLocal_id child_info:(NSMutableDictionary *)child_info
{
    NSArray * all_child_objects = [child_info allKeys];
    
    for(NSString * child_object in all_child_objects)
    {
        NSArray * all_child_ids = [child_info objectForKey:child_object];
        for(NSString * child_id in all_child_ids)
        {
            NSString * parent_column_name = [self getParentColumnNameFormChildInfoTable:SFChildRelationShip childApiName:child_object parentApiName:master_object];
            
            [self updateParentColumnNameInChildTableWithParentLocalId:child_object parent_column_name:parent_column_name parent_local_id:masterLocal_id child_sf_id:child_id];
        }
    }
}

-(void)insertrecordintoOnDemandTableForId:(NSString *)sf_id recordType:(NSString *)RecordType local_id:(NSString *)local_id json_record:(NSString *)json_record object_name:(NSString *)object_name
{
    NSDate * date = [NSDate date];
    NSString * today_Date = @"";
    NSDateFormatter * dateFormatter  = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    today_Date = [dateFormatter stringFromDate:date];
    NSString * insert_query = [NSString stringWithFormat:@"INSERT OR REPLACE INTO 'on_demand_download' ('object_name','sf_id','time_stamp','local_id','record_type','json_record') VALUES ('%@','%@','%@','%@','%@','%@')" , object_name,sf_id,today_Date,local_id,RecordType,json_record ];
    char * err;
    
    if(synchronized_sqlite3_exec(appDelegate.db, [insert_query UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(@"%@", insert_query);
		SMLog(@"METHOD: insertrecordintoOnDemandTableForId");
        SMLog(@"ERROR IN INSERTING %s", err);

    }

}

-(NSString *)getRecordTypeNameForObject:(NSString *)object_name forId:(NSString *)recordTYpeId
{
    NSString * recordTypeName = @"";
    NSString * query = [NSString stringWithFormat:@"SELECT record_type  FROM  SFRecordType where object_api_name = '%@' and record_type_id = '%@'" ,object_name,recordTYpeId];
    
    SMLog(@"RecordTypeId  valuemapping %@" ,query);
    sqlite3_stmt * recordTypeId_statement ;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &recordTypeId_statement, nil) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(recordTypeId_statement) == SQLITE_ROW)
        {
            char * temp_record_type_id = (char *) synchronized_sqlite3_column_text(recordTypeId_statement, 0);
            if(temp_record_type_id != nil)
            {
                recordTypeName = [NSString stringWithUTF8String:temp_record_type_id];
            }
        }
    }
    synchronized_sqlite3_finalize(recordTypeId_statement);
    return recordTypeName;
}

-(NSArray *)getEventProcessIdForProcessType:(NSString *)process_type SourceObject:(NSString *)sourceobjectName
{
    NSMutableArray * processIds_array = [[NSMutableArray alloc] initWithCapacity:0];
    NSString * process_id = @"";
    if([process_type isEqualToString:STANDALONECREATE])
    {
        
        NSString * query = [NSString stringWithFormat:@"SELECT process_id  FROM '%@' WHERE process_type = '%@' AND object_api_name = 'Event'",SFPROCESS, process_type];
        
        sqlite3_stmt * stmt;
        if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
        {
            while (synchronized_sqlite3_step(stmt)== SQLITE_ROW)
            {
                char * temp_process_id = (char *)synchronized_sqlite3_column_text(stmt, 0);
                if(temp_process_id != nil)
                {
                    process_id =[NSString stringWithUTF8String:temp_process_id];
                    if(process_id!= nil)
                    {
                        [processIds_array addObject:process_id];
                    }
                    
                }
            }
        }
        synchronized_sqlite3_finalize(stmt);
       
    }
    else if([process_type isEqualToString:SOURCETOTARGET])
    {
       NSString * query = [NSString stringWithFormat:@"SELECT process_id FROM '%@' WHERE component_type = '%@' and source_object_name = '%@' and target_object_name = 'Event'",PROCESS_COMPONENT , TARGET , sourceobjectName];
        sqlite3_stmt * stmt;
        if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
        {
            if (synchronized_sqlite3_step(stmt)== SQLITE_ROW)
            {
                char * temp_process_id = (char *)synchronized_sqlite3_column_text(stmt, 0);
                if(temp_process_id != nil)
                {
                    process_id =[NSString stringWithUTF8String:temp_process_id];
                    if(process_id!= nil)
                    {
                        [processIds_array addObject:process_id];
                    }
                    
                }
            }
        }
        synchronized_sqlite3_finalize(stmt);
    }
    else if([process_type isEqualToString:EDIT])
    {
        NSString * query = [NSString stringWithFormat:@"SELECT process_id  FROM '%@' WHERE process_type = '%@' AND object_api_name = 'Event'",SFPROCESS, process_type];
        
        sqlite3_stmt * stmt;
        if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
        {
            while (synchronized_sqlite3_step(stmt)== SQLITE_ROW)
            {
                char * temp_process_id = (char *)synchronized_sqlite3_column_text(stmt, 0);
                if(temp_process_id != nil)
                {
                    process_id =[NSString stringWithUTF8String:temp_process_id];
                    if(process_id!= nil)
                    {
                        [processIds_array addObject:process_id];
                    }
                    
                }
            }
        }
        synchronized_sqlite3_finalize(stmt);
    }
    else if([process_type isEqualToString:VIEWRECORD])
    {
        NSString * query = [NSString stringWithFormat:@"SELECT process_id  FROM '%@' WHERE process_type = '%@' AND object_api_name = 'Event'",SFPROCESS, process_type];
        
        sqlite3_stmt * stmt;
        if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
        {
            while (synchronized_sqlite3_step(stmt)== SQLITE_ROW)
            {
                char * temp_process_id = (char *)synchronized_sqlite3_column_text(stmt, 0);
                if(temp_process_id != nil)
                {
                    process_id =[NSString stringWithUTF8String:temp_process_id];
                    if(process_id!= nil)
                    {
                        [processIds_array addObject:process_id];
                    }
                }
            }
        }
        synchronized_sqlite3_finalize(stmt);
    }
    return processIds_array;
}

-(void)insertIntoEventsLocal_ids:(NSString *)local_id
{
    //delete before created event
    [self deleteRecordsFromEventLocalIds];
    NSString * insert_query = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ ('object_name','local_id') VALUES ('%@','%@')" , Event_local_Ids,@"Event",local_id ];
    char * err;
    
    if(synchronized_sqlite3_exec(appDelegate.db, [insert_query UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(@"Insert Failed Event_local_Ids");
    }
}

-(NSString *)getLocal_idFrom_Event_local_id
{
    NSString * local_id = @"";
    NSString * query = [NSString stringWithFormat:@"SELECT local_id FROM Event_local_Ids"];
    sqlite3_stmt * stmt;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(stmt)== SQLITE_ROW)
        {
            char * temp_local_id = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if(temp_local_id != nil)
            {
                local_id =[NSString stringWithUTF8String:temp_local_id];
                                
            }
        }
    }
    synchronized_sqlite3_finalize(stmt);
    return local_id;
}

-(void)deleteRecordsFromEventLocalIds
{
    NSString * delete_query = [NSString stringWithFormat:@"DELETE FROM %@",Event_local_Ids];
    char * err_delete;
    
    if(synchronized_sqlite3_exec(appDelegate.db, [delete_query UTF8String], NULL, NULL, &err_delete) != SQLITE_OK)
    {
        SMLog(@"delete Failed Event_local_Ids");
    }
}

-(NSString * )getallOverLappingEventsForStartDateTime:(NSString *)startDateTime EndDateTime:(NSString *)endDateTime
{
    NSString * overlapping_events = nil;
    NSMutableString * mutable_str = [[NSMutableString alloc] initWithCapacity:0];
    NSMutableArray * events = [[NSMutableArray alloc] initWithCapacity:0];
    NSString * query_str = [NSString stringWithFormat:@"SELECT DISTINCT Subject,WhatId  from  Event where(strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  ('%@','+0000','Z'))  <=  strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  ( StartDatetime, '+0000','Z') ) AND strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  ('%@','+0000','Z') )   > strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  ( StartDatetime, '+0000','Z') ) ) OR (strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  ('%@','+0000','Z') ) <  strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  ( EndDateTime, '+0000','Z') )   AND strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  ('%@', '+0000','Z') ) >= strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  ( EndDateTime, '+0000','Z') ))  OR (strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  ('%@', '+0000','Z') ) <= strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  ( StartDatetime, '+0000','Z') ) AND strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  ('%@', '+0000','Z') ) >= strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  ( EndDateTime, '+0000','Z') )) OR (strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  ('%@','+0000','Z') ) >= strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  ( StartDatetime, '+0000','Z') )  and strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  ('%@', '+0000','Z') ) <= strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  (EndDateTime, '+0000','Z') ))",startDateTime,endDateTime,startDateTime,endDateTime,startDateTime,endDateTime,startDateTime,endDateTime];
    NSString * subject = nil , * relatedTo = nil ;
    sqlite3_stmt * stmt;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query_str UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(stmt)== SQLITE_ROW)
        {
            relatedTo = @"" ,subject = @"";
            char * temp_subject = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if(temp_subject != nil)
            {
                subject =[NSString stringWithUTF8String:temp_subject];
            }
            char * temp_relatedTo = (char *)synchronized_sqlite3_column_text(stmt, 1);
            if(temp_relatedTo != nil) 
            {
                relatedTo =[NSString stringWithUTF8String:temp_relatedTo];
            }
            if([relatedTo length] > 0 && relatedTo != nil)
            {
                NSString * nameField = [self getNameForSFId:relatedTo];
                [events addObject:nameField];
            }
            else if([subject length] >0 && subject != nil)
            {
                [events addObject:subject];
            }
        }
    }
    NSLog(@" overlapping events%@",events);
    synchronized_sqlite3_finalize(stmt);
     [mutable_str appendFormat:@"\n"];
    for(NSString * event_temp in events)
    {
        [mutable_str appendFormat:@"%@\n",event_temp];
    }
    overlapping_events = [[NSString alloc]  initWithFormat:@"%@",mutable_str];
    [mutable_str release];
    return overlapping_events;
}

-(NSString *)getNameForSFId:(NSString *)sfId
{
    NSString * new_sf_id = [[NSString alloc] initWithString:sfId];
    NSString * keyPrefix = [new_sf_id substringWithRange:NSMakeRange(0, 3)];
    
    NSString * referencetoObject = [appDelegate.databaseInterface getTheObjectApiNameForThePrefix:keyPrefix tableName:SFOBJECT];
    
    NSString * name_field = @"";
    
    if([referencetoObject length] > 0)
    {
        NSString * local_id = [appDelegate.databaseInterface getLocalIdFromSFId:sfId tableName:referencetoObject];
        name_field =  [appDelegate.databaseInterface  getObjectName:referencetoObject recordId:local_id];
    }
    [new_sf_id release];
    return name_field;
}
@end
