	
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
#import "AppDelegate.h"
#import "SBJsonParser.h"
#import "ZKPicklistEntry.h"
#import "NSObject+SBJson.h"
#import "Utility.h"
#import "SVMXLookupFilter.h"
#import "PerformanceAnalytics.h"
#import "Util.h"
#import "SourceUpdateConfig.h"
#import "SuccessiveSyncModel.h"

void SMXLog(int level,const char *methodContext,int lineNumber,NSString *message);

@implementation databaseIntefaceSfm
@synthesize successiveSyncRecords;
@synthesize MyPopoverDelegate , databaseInterfaceDelegate;
@synthesize objectFieldDictionary;
@synthesize localIdOfFutureMasterRecords;
@synthesize parentobjectDictionary;
@synthesize parentColumnDictionary;

// Vipind-db-optmz
@synthesize apiNameToInsertionQueryDictionary;
@synthesize fieldDataTypeDictionary;
@synthesize childInfoDictionary;
@synthesize childInfoCacheDictionary;
@synthesize modifiedLineRecords;

- (void)dealloc {
    [objectFieldDictionary release];
    objectFieldDictionary = nil;
    
    // Vipin-db-optmz
    [apiNameToInsertionQueryDictionary release];
    apiNameToInsertionQueryDictionary = nil;
    
    [fieldDataTypeDictionary release];
    fieldDataTypeDictionary = nil;
    
    [childInfoDictionary release];
    childInfoDictionary = nil;
    
    [childInfoCacheDictionary release];
    childInfoCacheDictionary = nil;
    
    
    [localIdOfFutureMasterRecords release];
    localIdOfFutureMasterRecords = nil;
    [parentobjectDictionary release];
    [parentColumnDictionary release];
    [modifiedLineRecords release];
    [super dealloc];
}
-(NSString *) filePath:(NSString *)dataBaseName
{ 
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	NSString *documentsDir = [appDelegate getAppCustomSubDirectory]; // [paths objectAtIndex:0];
	return [documentsDir stringByAppendingPathComponent:dataBaseName];
}

-(id)init
{
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.modifiedLineRecords = [[NSMutableArray alloc] initWithCapacity:0];
    return self;
}


-(NSMutableDictionary *)queryProcessInfo:(NSString * )Process_id  object_name:(NSString *)object_name 
{
    NSString * sql = [NSString stringWithFormat:@"SELECT process_info FROM SFProcess where process_id = '%@'",Process_id];

    sqlite3_stmt * stmt;
    NSMutableDictionary * dict = nil;
    
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sql UTF8String], -1, &stmt, nil) == SQLITE_OK  )
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
          
            NSData * data = [[[NSData alloc] initWithBytes:sqlite3_column_blob(stmt, 0) length:synchronized_sqlite3_column_bytes(stmt, 0)]autorelease];
           
            NSString *errorStr = nil;
            
            NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString * documentsDirectoryPath = [appDelegate getAppCustomSubDirectory]; // [paths objectAtIndex:0];
            NSString * filePath = [documentsDirectoryPath stringByAppendingPathComponent:@"processInfo.plist"];
            
            NSPropertyListFormat * format = nil;
            
            id propertyList = [NSPropertyListSerialization propertyListFromData:data
                                                               mutabilityOption:NSPropertyListImmutable
                                                                         format:format
                                                               errorDescription:&errorStr];
            if(propertyList) 
            {
                SMLog(kLogLevelVerbose,@"No error creating XML data.");
                [propertyList writeToFile:filePath atomically:YES];
                dict = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
                
                break;
            }
        }
    }
    // Vipind-db-optmz
    synchronized_sqlite3_finalize(stmt);
    return dict;
    
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
        SMLog(kLogLevelVerbose,@" query  %@", query);
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
     SMLog(kLogLevelVerbose,@" query header %@",sql);
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

-(NSMutableArray *)queryLinesInfo:(NSMutableArray *)apiNames  detailObjectName:(NSString *)detailObjectName headerObjectName:(NSString *)headerObjectName detailaliasName:(NSString *)detailsAliasName headerRecordId:(NSString *)record_id expressionId:(NSString *)expression_id parent_column_name:(NSString *)parent_column sorting_order:(NSString *)sorting_order_string
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
//        fieldsString = [fieldsString stringByAppendingString:singleField];
         fieldsString = [fieldsString stringByAppendingFormat:@"'%@'.%@",detailObjectName,singleField];
    }
    
    NSMutableString * Join_str = [[NSMutableString alloc] initWithCapacity:0];
    NSMutableString * orderBy_str = [[NSMutableString alloc] initWithCapacity:0];
    NSMutableArray * order_array = [[NSMutableArray alloc] initWithCapacity:0];
    if([sorting_order_string length] > 0)
    {
        SBJsonParser * jsonParser = [[[SBJsonParser alloc] init] autorelease];
        NSDictionary * json_dict = [jsonParser objectWithString:sorting_order_string];
       
        NSArray  * sorting_array = [json_dict objectForKey:@"lstSortingRec"];

        NSInteger count = 0;
        for(int i = 0;i< [sorting_array count] ; i++)
        {
            NSDictionary * dict = [sorting_array objectAtIndex:i];
            NSString * data_type = [dict objectForKey:@"dataType"];
            if([data_type isEqualToString:@"reference"] || [data_type isEqualToString:@"REFERENCE"])
            {
                NSString * temp_queryfield = [dict objectForKey:@"queryField"];
                NSArray  * query_fields_array = [temp_queryfield componentsSeparatedByString:@"."];
                //NSMutableString * temp_reference_To = [NSMutableString   stringWithString:([query_fields_array objectAtIndex:0]!= nil)?[query_fields_array objectAtIndex:0]:@""];
                NSString * query_field = [query_fields_array objectAtIndex:1];
                //NSString * reference_To = [temp_reference_To stringByReplacingOccurrencesOfString:@"__r" withString:@"__c"];
                NSString * relation_ship_name = [dict objectForKey:@"fieldAPIName"];
                
                NSString * reference_To = [appDelegate.dataBase getReferencetoFiledForObject:detailObjectName api_Name:relation_ship_name];
                
                NSString * alias_name = [NSString stringWithFormat:@"%@%d",reference_To,count];
                
                NSString * sorting_order = [dict objectForKey:@"sortingOrder"];
                BOOL ifExists = [appDelegate.dataBase isTabelExistInDB:reference_To];
                
                if(ifExists)
                {
                    [Join_str appendFormat:@" LEFT OUTER JOIN '%@' AS %@ ON %@.%@ = %@.Id",reference_To,alias_name,detailObjectName,relation_ship_name,alias_name ];                   
                    [ order_array addObject:[NSString stringWithFormat:@" %@.%@ %@ ",alias_name,query_field,sorting_order]];
                    count++;
                }
            }
            else
            {
                NSString * sorting_order = [dict objectForKey:@"sortingOrder"];
                NSString * field_api_name = [dict objectForKey:@"fieldAPIName"];
                [order_array addObject:[NSString stringWithFormat:@" '%@'.%@ %@ ",detailObjectName,field_api_name, sorting_order]];
            }
        }
        
        if([order_array count] > 0)
        {
            [orderBy_str appendString:@"ORDER BY"];
            for( int j = 0 ; j< [order_array count];j++)
            {
                [orderBy_str appendFormat:@"%@",[order_array objectAtIndex:j]];
                if(j != [order_array count]-1)
                {
                    [orderBy_str appendString:@" , "];
                }
            }
        }
     
    }
    
        
    //fetch the parent  column name  in child table from  CHildInfo Table   -- IMP headerObjectName
    //Fix for defect #7679
    NSString * sql = @"";
    
    NSString * releated_column_name = [self getRefernceToFieldnameForObjct:detailObjectName reference_table:headerObjectName table_name:SF_REFERENCE_TO];
    if([parent_column length] == 0)
    {
        parent_column_name = releated_column_name;
    }
    
    NSString * parent_sf_id = [self getSfid_For_LocalId_From_Object_table:headerObjectName local_id:local_record_id ];
    
    if([parent_sf_id length] == 0 && [local_record_id length] == 0)
    {
        return array;
    }
    
    if([parent_sf_id length] == 0)
    {
        if([expression_ length ] != 0 && expression_ != nil)
            sql = [NSString stringWithFormat:@"SELECT %@ FROM '%@'  %@  WHERE '%@'.%@ = '%@' and %@  %@",fieldsString,detailObjectName,Join_str,detailObjectName,parent_column_name,local_record_id, expression_,orderBy_str];
        else
            sql = [NSString stringWithFormat:@"SELECT %@ FROM '%@' %@ WHERE '%@'.%@ = '%@' %@",fieldsString,detailObjectName,Join_str,detailObjectName,parent_column_name,local_record_id, orderBy_str];
    }
    else
    {
        if([expression_ length ] != 0 && expression_ != nil)
            sql = [NSString stringWithFormat:@"SELECT %@ FROM '%@'  %@  WHERE ('%@'.%@ = '%@'  or '%@'.%@ = '%@') and %@  %@",fieldsString,detailObjectName,Join_str,detailObjectName,parent_column_name,local_record_id,detailObjectName,parent_column_name,parent_sf_id, expression_,orderBy_str];
        else
            sql = [NSString stringWithFormat:@"SELECT %@ FROM '%@' %@ WHERE ('%@'.%@ = '%@' or '%@'.%@ = '%@')  %@  ",fieldsString,detailObjectName,Join_str,detailObjectName,parent_column_name,local_record_id, detailObjectName,parent_column_name, parent_sf_id,orderBy_str];
    }

    SMLog(kLogLevelVerbose,@" LineRecord %@",sql);
    
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
                            
                            //Aparna: 6889
                            if([label isEqualToString:@"" ]||[label isEqualToString:@" "] || label == nil)
                            {
                                NSString *sf_id =  [appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:reference_to_tableName local_id:value];
                                
                                label = [appDelegate.databaseInterface getReferenceValueFromReferenceToTable:reference_to_tableName field_name:referenceTo_Table_fieldName record_id:sf_id];
                            }
                            
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
    
    [Join_str release];
    [orderBy_str release];
 [order_array release];
    return array;
}

-(NSMutableArray *) selectProcessFromDB:(NSString *)currentObject
{
    NSMutableArray * view_process = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSString * query = [NSString stringWithFormat:@"Select process_name, process_id from SFProcess  where process_type = '%@' and object_api_name = '%@' ", @"VIEWRECORD",currentObject];
    
    sqlite3_stmt * stmt;
    @try{
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
	}@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name Database :selectProcessFromDB %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason Database :selectProcessFromDB %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
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
   
    // Vipind-db-optmz
    NSString *cacheKey = [NSString stringWithFormat:@"%@_%@", objectName, fieldName];
    
    if (self.fieldDataTypeDictionary == nil)
    {
        NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
        self.fieldDataTypeDictionary = tempDictionary;
        [tempDictionary  release];
    }
    else
    {
        datatype = [self.fieldDataTypeDictionary objectForKey:cacheKey];
    }
    
    // Just got it from cache, lets go back
    if ([Util isValidString:datatype])
    {
//        SMLog(kLogLevelVerbose,@" Go it from cache fieldDataTypeDictionary  %@ -> %@ ", cacheKey,  datatype);
        return datatype;
    }
    
    // Use cache here...
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"getFieldDataType"
                                                         andRecordCount:1];
    
    
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
    
    if ( (datatype != nil)
        && (self.fieldDataTypeDictionary != nil)
        && (cacheKey != nil))
    {
        // Stored in cache
//        SMLog(kLogLevelVerbose,@" Storing in cache fieldDataTypeDictionary  %@  > %@ ", cacheKey,  datatype);
        if ([self.fieldDataTypeDictionary count] > 100)
        {
            // Clear all objects it is exceeding the limit
            [self.fieldDataTypeDictionary removeAllObjects];
        }
        
        [self.fieldDataTypeDictionary setObject:datatype forKey:cacheKey];
    }
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"getFieldDataType"
                                                                      andRecordCount:0];
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
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"getTheObjectApiNameForThePrefix"
                                                         andRecordCount:1];
    
    
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
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"getTheObjectApiNameForThePrefix"
                                                                      andRecordCount:0];
    
    return keyPrefixValue;
}

-(NSString *)getFieldNameForReferenceTable:(NSString *)referedToTableName  tableName:(NSString *)tableName
{
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"getFieldNameForReferenceTable"
                                                         andRecordCount:1];
    
    
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
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"getFieldNameForReferenceTable"
                                                                      andRecordCount:0];
    
    
    return fieldName;
    
}

-(NSString *)getReferenceValueFromReferenceToTable:(NSString *)tableName field_name:(NSString *) filed_name record_id:(NSString *)record_id
{
    NSString * fieldvalue = @"";
	BOOL isTableExists = [appDelegate.databaseInterface checkForTheTableInTheDataBase:tableName];
    if(isTableExists)
    {
        NSString * query ;
        if([record_id length ] > 33)
        {
            query = [NSString stringWithFormat:@"SELECT %@ FROM '%@' where local_id = '%@'",filed_name,tableName,record_id];

        }
        else
        {
            query = [NSString stringWithFormat:@"SELECT %@ FROM '%@' where id = '%@'",filed_name,tableName,record_id];
        }
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
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"getObjectName"
                                                         andRecordCount:1];
    
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
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"getObjectName"
                                                                      andRecordCount:0];
    
    
    return fieldName;

}

// Get the child parent column name in child relationship table
-(NSString *)getParentColumnNameFormChildInfoTable:(NSString *)tableName  childApiName:(NSString *)objectApiNameChild parentApiName:(NSString *)objectApiNameParent
{
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"getParentColumnNameFormChildInfoTable"
                                                         andRecordCount:1];
    
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
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"getParentColumnNameFormChildInfoTable"
                                                                      andRecordCount:0];
    
    
    return fieldName;
}
//  Unused Methods
//-(NSString *)findTheTypeofTheRecordFromRecordTypeIdTable:(NSString *)tableName record_typeId:(NSString *)record_type_id objectOrLineApiName:(NSString *)apiName
//{
//    
//    NSString * recordType = @"";
//    if(record_type_id != nil && apiName != nil)
//    {
//        NSString * query = [NSString stringWithFormat:@"SELECT record_type FROM '%@' where object_api_name = '%@' && record_type_id = '%@' ", tableName ,apiName,record_type_id];
//        sqlite3_stmt * stmt ;
//        if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
//        {
//            while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
//            {
//                char * temp_fieldName = (char *)synchronized_sqlite3_column_text(stmt, 0);
//                if(temp_fieldName != nil)
//                {
//                    recordType = [NSString stringWithUTF8String:temp_fieldName];
//                }
//            }
//        }
//        synchronized_sqlite3_finalize(stmt);
//        
//    }
//    
//    return recordType;
//}

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
        NSString * query = [NSString stringWithFormat:@"SELECT SVMXC__Restoration_Customer_By__c, SVMXC__Resolution_Customer_By__c,SVMXC__Sla_Clock_Paused__C,SVMXC__Actual_Resolution__C,SVMXC__Actual_Restoration__C,SVMXC__Restoration_Customer_By__C,SVMXC__Resolution_Customer_By__C,SVMXC__Sla_Clock_Pause_Time__C FROM '%@' where local_id = '%@'", tableName ,record_id];
        
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
    
    [SLADict setObject:clockedPaused forKey:@"SVMXC__Sla_Clock_Paused__C"];
    [SLADict setObject:actualRestoration forKey:@"SVMXC__Actual_Resolution__C"];
    [SLADict setObject:actualResolution forKey:@"SVMXC__Actual_Restoration__C"];
    [SLADict setObject:restorationCustomerBy forKey:@"SVMXC__Restoration_Customer_By__C"];
    [SLADict setObject:resolutionCustomerBy forKey:@"SVMXC__Resolution_Customer_By__C"];
    [SLADict setObject:pausedTime forKey:@"SVMXC__Sla_Clock_Pause_Time__C"];
    return SLADict;
}

//method for Account history and Product History
-(NSMutableDictionary *)gettheAdditionalInfoForForaWorkOrder:(NSString *)record_id tableName:(NSString *)tablename
{
    NSString * account_Id = @"";
    NSString * topLevel_Id = @"";
    NSString * component = @"";
    
    NSMutableDictionary * additional_info = [[NSMutableDictionary alloc] initWithCapacity:0];
    
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
    
    //krishna 23-1 memory opt 9493
    [dateFormatter release];
    dateFormatter = nil;
    
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
    
    //krishna 23-1 memory opt 9493
    [dateFormatter release];
    dateFormatter = nil;

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
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"getLocalIdFromSFId"
                                                         andRecordCount:1];
    
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
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"getLocalIdFromSFId"
                                                                      andRecordCount:0];
    
    
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
        //Krishna Map 008225 //changed inner join to left outer join
        NSString * query = [NSString stringWithFormat:@"select c.phone ,c.Email, c.Name, w.Name ,w.SVMXC__Problem_Description__c ,w.SVMXC__Order_Type__c, w.SVMXC__Contact__c from SVMXC__Service_Order__c  as w  LEFT OUTER join  Contact  as c on  w.SVMXC__Contact__c = c. id   where  w.local_id = '%@'" ,record_id];
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

    // Vipin-memopt 15-1 9493
    NSMutableArray * processArray = [[NSMutableArray alloc] initWithCapacity:0];
    
   @autoreleasepool
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
                    
                    NSArray *processDetails = [NSArray arrayWithObjects:process_id,objectApi_name,
                                                process_name, process_description,nil];
                    
                    NSMutableDictionary * dict = [NSMutableDictionary  dictionaryWithObjects:processDetails
                                                                                     forKeys:createInfokeys];
                    [processArray addObject:dict];
                    
                    processDetails = nil;
                    dict = nil;
                }
                
            }
            query = nil;
            synchronized_sqlite3_finalize(stmt);
        }
    }
    
    return [processArray autorelease];
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
//OUTPUT docs Entry criteria : 8166
- (NSArray *) getExpressionIdsForOPDocForProcessId:(NSString *)processId {
    
    if([processId length ] != 0 ||  processId != nil)
    {
        NSString * query = @"";
        query = [NSString stringWithFormat:@"SELECT target_object_name, expression_id FROM '%@' WHERE process_id = '%@' and component_type = '%@' ",PROCESS_COMPONENT , processId, @"TARGET"];
        SMLog(kLogLevelVerbose,@" process component%@ ",query );
        NSMutableArray *tempArray = [NSMutableArray array];
        
        
        sqlite3_stmt * stmt ;
        if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
        {
            while (synchronized_sqlite3_step(stmt)  == SQLITE_ROW)
            {
                NSString *expressionId = @"";
                NSString *targetObjName = @"";
                NSMutableDictionary *tempDict  = [[NSMutableDictionary alloc] init];
                
                char * temp_object_mapping_id = (char *)synchronized_sqlite3_column_text(stmt, 0);
                if(temp_object_mapping_id != nil && strlen(temp_object_mapping_id))
                {
                    targetObjName = [NSString stringWithUTF8String:temp_object_mapping_id];
                }
                
                char * temp_expression_id = (char *)synchronized_sqlite3_column_text(stmt, 1);
                if(temp_expression_id != nil && strlen(temp_expression_id))
                {
                    expressionId = [NSString stringWithUTF8String:temp_expression_id];
                }
                
                if(![expressionId isEqualToString:@""] && ![targetObjName isEqualToString:@""]) {
                    [tempDict setObject:expressionId forKey:EXPRESSION_ID];
                    [tempDict setObject:targetObjName forKey:TARGET_OBJECT_NAME];
                }
                [tempArray addObject:tempDict];
                [tempDict release];
                
                
            }
            
        }
        synchronized_sqlite3_finalize(stmt);
        
        return tempArray;
    }
return nil;
}

-(NSMutableDictionary *)getProcessComponentsForComponentType:(NSString *)componentType process_id:(NSString *)processId  layoutId:(NSString *)layoutId  objectName:(NSString *)objectName  
{
    if([componentType isEqualToString:TARGET])
    {
        layoutId = nil;
    }
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
//    NSString * object_mapping_id = @"";
//    NSString * value_mapping_id  = @"";
//    NSString * expression_id = @"";
//    NSString * source_object_name = @"";
//    NSString * target_object_name = @"";
//    NSString * parent_column = @"";
//    NSString * source_child_parent_column = @"";
//    NSString * sorting_order = @"";
    
    BOOL field_exists = [self ColumnExists:@"Sorting_Order" tableName:SFPROCESSCOMPONENT];
    
    
    NSMutableString * field_string = [[NSMutableString alloc] initWithCapacity:0];
    
    NSArray * final_keys = nil,* final_fields = nil;
    
    if(field_exists)
    {
        final_fields = [[NSArray alloc] initWithObjects:@"object_mapping_id" ,@"expression_id",@"source_object_name",@"target_object_name",@"parent_column" ,@"value_mapping_id" ,@"source_child_parent_column",@"Sorting_Order",@"sfID", nil];;//4850
        final_keys = [[NSArray alloc] initWithObjects:OBJECT_MAPPING_ID,EXPRESSION_ID,SOURCE_OBJECT_NAME,TARGET_OBJECT_NAME, PARENT_COLUMN_NAME, VALUE_MAPPING_ID,SOURCE_CHILD_PARENT_COLUMN,SORTING_ORDER,@"sfID",nil];;
        
    }
    else
    {
        final_keys = [[NSArray alloc] initWithObjects:OBJECT_MAPPING_ID,EXPRESSION_ID,SOURCE_OBJECT_NAME,TARGET_OBJECT_NAME, PARENT_COLUMN_NAME, VALUE_MAPPING_ID,SOURCE_CHILD_PARENT_COLUMN,nil];;
        final_fields = [[NSArray alloc] initWithObjects:@"object_mapping_id" ,@"expression_id",@"source_object_name",@"target_object_name",@"parent_column" ,@"value_mapping_id" ,@"source_child_parent_column", nil];;
    }
   
    
    for (int i =0; i< [final_fields count] ; i++)
    {
        NSString * new_str = [final_fields objectAtIndex:i];
        if(i == 0)
        {
            [field_string  appendFormat:@"%@",new_str];
        }
        else
        {
            [field_string appendFormat:@" , %@ ",new_str];
        }
    }
   
    if([processId length ] != 0 ||  processId != nil)
    {
         NSString * query = @"";
        
        if(layoutId != nil || [layoutId length] != 0)
        {
            query = [NSString stringWithFormat:@"SELECT %@ FROM '%@' WHERE process_id = '%@' AND layout_id = '%@' and component_type = '%@'",field_string,PROCESS_COMPONENT , processId , layoutId,componentType];
        }
        else
        {
            query = [NSString stringWithFormat:@"SELECT %@ FROM '%@' WHERE process_id = '%@' and component_type = '%@'",field_string,PROCESS_COMPONENT , processId ,componentType];
        }
        SMLog(kLogLevelVerbose,@" process component%@ ",query );
        NSString * value = @"";
        sqlite3_stmt * stmt ;
        if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
        {
            while (synchronized_sqlite3_step(stmt)  == SQLITE_ROW) 
            {
//                char * temp_object_mapping_id = (char *)synchronized_sqlite3_column_text(stmt, 0);
//                if(temp_object_mapping_id != nil)
//                {
//                    object_mapping_id = [NSString stringWithUTF8String:temp_object_mapping_id];
//                }
//                
//                char * temp_expression_id = (char *)synchronized_sqlite3_column_text(stmt, 1);
//                if(temp_expression_id != nil)
//                {
//                    expression_id = [NSString stringWithUTF8String:temp_expression_id];
//                }
//                
//                char * temp_source_object_name = (char *)synchronized_sqlite3_column_text(stmt, 2);
//                if(temp_source_object_name != nil)
//                {
//                    source_object_name = [NSString stringWithUTF8String:temp_source_object_name];
//                }
//                
//                char * temp_target_object_name = (char *)synchronized_sqlite3_column_text(stmt, 3);
//                if(temp_target_object_name != nil)
//                {
//                    target_object_name = [NSString stringWithUTF8String:temp_target_object_name];
//                }
//                
//                char * temp_parent_column_name = (char *)synchronized_sqlite3_column_text(stmt, 4);
//                if(temp_parent_column_name != nil)
//                {
//                    parent_column = [NSString stringWithUTF8String:temp_parent_column_name];
//                }
//                
//                char * temp_value_mapping_id = (char *)synchronized_sqlite3_column_text(stmt, 5);
//                if(temp_value_mapping_id != nil)
//                {
//                    value_mapping_id = [NSString stringWithUTF8String:temp_value_mapping_id];
//                }
//                
//                char * temp_source_child_parent_column = (char *)synchronized_sqlite3_column_text(stmt, 6);
//                if(temp_source_child_parent_column != nil)
//                {
//                    source_child_parent_column = [NSString stringWithUTF8String:temp_source_child_parent_column];
//                }
//                
//                
//                char * temp_sorting_order = (char *)synchronized_sqlite3_column_text(stmt, 7);
//                if(temp_sorting_order != nil)
//                {
//                    sorting_order = [NSString stringWithUTF8String:temp_sorting_order];
//                }
            
                for(int i = 0 ; i< [final_keys count]; i++)
                {
                    NSString * key = [final_keys objectAtIndex:i];
                    char * temp_value= (char *)synchronized_sqlite3_column_text(stmt, i);
                    if(temp_value != nil)
                    {
                        value = @"";
                        value = [NSString stringWithUTF8String:temp_value];
                        [dict setObject:value forKey:key];
                    }
                }
               
                
//                [dict setObject:expression_id forKey:EXPRESSION_ID];
//                [dict setObject:object_mapping_id forKey:OBJECT_MAPPING_ID];
//                [dict setObject:source_object_name forKey:SOURCE_OBJECT_NAME];
//                [dict setObject:target_object_name forKey:TARGET_OBJECT_NAME];
//                [dict setObject:parent_column forKey:PARENT_COLUMN_NAME];
//                [dict setObject:value_mapping_id forKey:VALUE_MAPPING_ID];
//                [dict setObject:source_child_parent_column  forKey:SOURCE_CHILD_PARENT_COLUMN];
//                [dict setObject:sorting_order forKey:SORTING_ORDER];

            }
            
            synchronized_sqlite3_finalize(stmt);
        }
    }
    
    
    [field_string release];
    [final_fields release];
    [final_keys release];
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
                            
                            SMLog(kLogLevelVerbose,@"RecordTypeId  valuemapping %@" ,query);
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
                            //krishna 23-1 memory opt 9493
                            dateFormatter = nil;
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
			
            sqlite3_finalize(stmt);
		}
	}
    
    return dict;
}

-(BOOL)insertdataIntoTable:(NSString *)tableName data:(NSMutableDictionary *)valuesDict
{
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"insertdataIntoTable"
                                                         andRecordCount:1];
        
    NSAutoreleasePool * autorelease_pool = [[NSAutoreleasePool alloc] init];
	
	//8374
	if ([tableName caseInsensitiveCompare:@"Event"] == NSOrderedSame )
	{
		
		NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
		
		NSString * currentUserName = [userDefaults valueForKey:@"UserFullName"];
		NSString * ownerId = @"";
		
		if ([currentUserName length] > 0 && currentUserName != nil)
		{
			ownerId  = [appDelegate.dataBase getLoggedInUserId:currentUserName];
		}
		
		if (ownerId != nil && [ownerId length] > 0)
		{
			[valuesDict setValue:ownerId forKey:@"OwnerId"];
		}
	}
	
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
    

    // Vipin-db-optmz
    
    sqlite3_stmt * bulk_statement = nil;
    
    int prepare = synchronized_sqlite3_prepare_v2(appDelegate.db, [insert_statement UTF8String], strlen([insert_statement UTF8String]), &bulk_statement, NULL);
    
    [appDelegate.dataBase beginTransaction];
    
    // Good prepare statement
    if (prepare == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(bulk_statement) != SQLITE_DONE)
        {
            SMLog(kLogLevelError,@"%@", insert_statement);
            SMLog(kLogLevelError,@"Failure insertdataIntoTable - insert_statement => %@", insert_statement);
           // Vipin - Fix for defect 7352
            success = FALSE;

            if([tableName isEqualToString:@"Event"])
            {
                NSString * startDateTime = [valuesDict objectForKey:@"StartDateTime"];
                NSString * enddatetime = [valuesDict objectForKey:@"EndDateTime"];
                NSString * local_id = [valuesDict objectForKey:@"local_id"];
                NSString * overlappingEvent = [appDelegate.databaseInterface getallOverLappingEventsForStartDateTime:startDateTime
                                                                                                         EndDateTime:enddatetime
                                                                                                            local_id:local_id];
                [self insertIntoEventsLocal_ids:local_id fromEvent_temp_table:Event_local_Ids];
                [databaseInterfaceDelegate displayALertViewinSFMDetailview:overlappingEvent];
            }
        }
        else
        {
            success = TRUE;
            [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:1];
            SMLog(kLogLevelVerbose,@"Success insertdataIntoTable insert_statement");
        }
        
        sqlite3_clear_bindings(bulk_statement);
        sqlite3_reset(bulk_statement);
        synchronized_sqlite3_finalize(bulk_statement);
    }
    else
    {
        SMLog(kLogLevelError,@"Failure prepare insertdataIntoTable - insert_statement => %@", insert_statement);
    }
    
    [appDelegate.dataBase endTransaction];

    
   
    [autorelease_pool release];
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"insertdataIntoTable"
                                                                      andRecordCount:0];
    
    
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
//Radha - Defect Fix 6483 
-(NSMutableDictionary *)getDataForMultiAdd:(NSString *)object_name searchField:(NSString *)search_field lookUpSearchId:(NSString *)searchId
{
    NSMutableDictionary * muti_add_data = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSMutableArray * eachRow = [[NSMutableArray alloc] initWithCapacity:0];
	
	int no_of_records = 0;
    
	//Radha - Defect Fix 6483
    NSString * query = @"";
	sqlite3_stmt * stmt ;
	
	if(searchId == nil || [searchId isEqualToString:@""])
	{
		query = [NSString stringWithFormat:@"SELECT DISTINCT no_of_lookup_records FROM '%@' WHERE object_name = '%@'", SFNAMEDSEARCH,object_name];
	}
	
	else
	{
		query = [NSString stringWithFormat:@"SELECT DISTINCT no_of_lookup_records FROM '%@' WHERE object_name = '%@' AND search_sfid = '%@'", SFNAMEDSEARCH,object_name, searchId];
	}
	
	
	if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
	{
		while (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
		{
			char * temprecord = (char *)synchronized_sqlite3_column_text(stmt, 0);
			NSString * records = @"";
			if (temprecord != nil && strlen(temprecord))
			{
				records = [NSString stringWithUTF8String:temprecord];
				no_of_records = [records intValue];
			}
			else if(temprecord == nil || !(strlen(temprecord)))
            {
                no_of_records = LOOKUP_RECORDS_LIMIT;
            }
		}
	}
	
    synchronized_sqlite3_finalize(stmt);
	query = @"";
	stmt = nil;
	
	//Radha - Defect Fix 6483
    if ([search_field length] > 0)
	{
        query = [NSString stringWithFormat:@"SELECT Id , %@ FROM '%@' Where Name LIKE '%%%@%%' LIMIT %d",@"Name" , object_name, search_field, no_of_records];
    }
	else
	{
        query = [NSString stringWithFormat:@"SELECT Id , %@ FROM '%@'",@"Name" , object_name];
    }
    
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


- (NSDictionary *) getLookupDataFromDBWith:(NSString *)lookupID
                               referenceTo:(NSString *)object
                                 searchFor:(NSString *)searchForString
                            withPreFilters:(NSArray *)preFilters
                                andFilters:(NSArray *)advancedFilters
{
    /*Shra-lookup*/
    
    /* Reading pre filters*/
    
    NSMutableString *  advancedFilterString = nil;
    NSString *preFiltersString = [self getPreFilters:preFilters];
    if (![Utility isStringEmpty:preFiltersString]) {
         advancedFilterString = [[NSMutableString alloc] init];
        [advancedFilterString appendFormat:@" %@ ",preFiltersString];
    }
    
    /* Reading advanced filters: Fix for issue 7375 */
    NSArray *allFilters = [self getFilterStringArrayForAdvancedFilters:advancedFilters];
   
    NSInteger filterCount = [allFilters count];
    if (filterCount > 0) {
       
        if (advancedFilterString == nil) {
            advancedFilterString = [[NSMutableString alloc] init];
        }
        else {
            [advancedFilterString appendFormat:@" AND "];
        }

        for (int counter = 0; counter < [allFilters count]; counter++) {
            NSString *filterString = [allFilters objectAtIndex:counter];
            if (counter == (filterCount - 1)) {
                [advancedFilterString appendFormat:@" ( Id IN ( %@ )  OR local_id IN ( %@ )) ",filterString, filterString];
            }
            else {
                [advancedFilterString appendFormat:@" ( Id IN ( %@ )  OR local_id IN ( %@ )) AND ", filterString, filterString];
            }
        }
    }
    
  
    /*Shra-lookup ends*/
    
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
    
	//Radha - Defect Fix 6483 - Get no_of_records to be displayed using lookupid
    NSString * no_of_records = @"";
    int records = LOOKUP_RECORDS_LIMIT;
	
	NSString *querystring2 = @"";
    
	 if(lookupID == nil || [lookupID isEqualToString:@""])
	 {
		 querystring2 = [NSString stringWithFormat:@"Select default_lookup_column,object_name,is_default,is_standard, no_of_lookup_records from '%@' where object_name = '%@'", SFNAMEDSEARCH,object];
	 }
	   
	 else
	 {
		 querystring2 = [NSString stringWithFormat:@"Select default_lookup_column,object_name,is_default,is_standard, no_of_lookup_records from '%@' where object_name = '%@' AND search_sfid = '%@'", SFNAMEDSEARCH,object, lookupID];

	 }
    
    
    NSArray * lookUp_info_object_keys = [NSArray arrayWithObjects:LOOKUP_DEFAULT_LOOK_UP_CLMN,LOOKUP_OBJECT_NAME,LOOkUP_IS_DEFAULT,LOOKUP_IS_STANDARD, nil];
    
    sqlite3_stmt * stmt_;
    @try{
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
			//Radha - Defect Fix 6483
            char * temp_records = (char *) synchronized_sqlite3_column_text(stmt_, 4);
            if (temp_records != nil && strlen(temp_records))
            {
                no_of_records = [NSString stringWithUTF8String:temp_records];
                records = [no_of_records intValue];
            }
            else if(temp_records == nil || !(strlen(temp_records)))
            {
                records = LOOKUP_RECORDS_LIMIT;
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
			//Radha - Defect Fix - 5419
			default_column_name = [dict objectForKey:LOOKUP_DEFAULT_LOOK_UP_CLMN];
			if ([default_column_name length] > 0 )
				break;
        }
        
        //Sahana Fixed   ---
        //Shrinivas for R4B2 - 20/04/2012
        NSString * _searchForString = [searchForString substringFromIndex:1];
        NSString * querystring2 = @"";
        SMLog(kLogLevelVerbose,@"%d", [searchForString length]);
        if ([searchForString length] > 1)
        {
            querystring2 = [NSString stringWithFormat:@"Select %@ , Id from '%@'  WHERE  Id  NOT NULL   AND Id != '' and %@ LIKE '%%%@%%' LIMIT %d", default_column_name, object, default_column_name, _searchForString, records];
        }
		else
		{
            querystring2 = [NSString stringWithFormat:@"Select %@ , Id from '%@'  WHERE  Id  NOT NULL   AND Id != '' LIMIT %d", default_column_name, object, records];
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
                    // defect 8460
                    field_relationShip_name = [NSString stringWithUTF8String:temp_field_relation_ship_name];
                    // defect 8460
                    if([field_relationShip_name Contains:@"__c"])
                    {
                        field_relationShip_name =[field_relationShip_name stringByReplacingOccurrencesOfString:@"__c" withString:@"__r"];
                    }
                    field_relationShip_name=[appDelegate.dataBase getRefrenceToField:object relationship:field_relationShip_name];
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
        
        synchronized_sqlite3_finalize(stmt);
        
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
        
        /* Shra-lookup */
        NSString * querystring2 = nil;
        if ([Utility isStringEmpty:advancedFilterString]) {
            querystring2 = [NSString stringWithFormat:@"Select %@ from '%@'  where %@ LIMIT %d ", result_fieldNames, object, searchFieldNames, records];
        }
        else {
            querystring2 = [NSString stringWithFormat:@"Select %@ from '%@'  where %@ AND %@ LIMIT %d ", result_fieldNames, object, searchFieldNames,advancedFilterString, records];
        }
        
        SMLog(kLogLevelVerbose,@"QUERY: Executed %@",querystring2);
        /* Shra-lookup ends*/
              
        if(synchronized_sqlite3_prepare_v2(appDelegate.db, [querystring2 UTF8String], -1, &stmt, nil) == SQLITE_OK)
        {
            SMLog(kLogLevelVerbose,@"QUERY: Compiled Successfully");
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
        synchronized_sqlite3_finalize(stmt);
        
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
                                // defect 8460
                                NSString *reference_Value=[appDelegate.dataBase getValueFromLookupwithId:value];
                                if([reference_Value length]>0)
                                {
                                    label=reference_Value;
                                }
                                else
                                {
                                    label = value;
                                    
                                }
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
        /* Fix for the issue 7386 */
        if ([Utility isStringEmpty:lookupID] ) {
            for(int k = 0 ; k< [lookup_object_info count]; k++)
            {
                NSDictionary * look_up =  [lookup_object_info objectAtIndex:k];
                
                //Shrinivas : Fix for defect : 5916
                NSString * is_standard  = [look_up objectForKey:LOOkUP_IS_DEFAULT];
                if([is_standard boolValue])
                {
                    default_display_column = [look_up objectForKey:LOOKUP_DEFAULT_LOOK_UP_CLMN];
                }
            }
            
        }
        else {
            if ([lookup_object_info count] > 0) {
                
                for(NSDictionary * look_up in lookup_object_info)
                {
                   
                    default_display_column = [look_up objectForKey:LOOKUP_DEFAULT_LOOK_UP_CLMN];
                    if ([default_display_column length] > 0 && ![Utility isStringEmpty:default_display_column])
                        break;
                }
                
            }
        }
        

        finalDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:each_record, sequenceArray,default_display_column, nil] forKeys:_dictKeys];
    }
	[each_record release];
    }@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name Database :getLookupDataFromDBWith %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason Database :getLookupDataFromDBWith %@",exp.reason);
         [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
    return finalDict;
}

//  Unused Methods
//-(NSString *)getTheDefaultDisplayColumnForLookUpId:(NSString *)lookup_id 
//{
//    NSString * query = [NSString stringWithFormat:@"SELECT SVMXC_Field_Name_c FROM '%@' where Id = '%@' and default_desplay_column = '%@' ",SFCONFIG_DATA_TABLE ,lookup_id,@"true" ];
//    sqlite3_stmt * stmt ;
//    NSString * field_name = @"";
//    
//    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
//    {
//        while (synchronized_sqlite3_step(stmt)  == SQLITE_ROW) 
//        {
//            char * value = (char *)synchronized_sqlite3_column_text(stmt, 0);
//            if(value != nil)
//            {
//                field_name = [NSString stringWithUTF8String:value];
//            }
//        }
//    }
//    synchronized_sqlite3_finalize(stmt);
//    return field_name;
//}

-(NSString *)queryForExpression:(NSString *)expression_id forObject:(NSString *)object_name;
{
    NSString * query = [NSString stringWithFormat:@"SELECT expression FROM '%@' where expression_id = '%@'",SFEXPRESSION, expression_id];
    sqlite3_stmt * stmt ;
    NSString * expression = @"";
    
    NSString * final_expr = @"";
    SMLog(kLogLevelVerbose,@"%@", query);
    
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
    NSString * retExpression = @"";
    @try
    {

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
        
		//SMLog(kLogLevelVerbose,@"%@", query);
        SMLog(kLogLevelVerbose,@"%@",query);
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
                    
                    SMLog(kLogLevelVerbose,@"component_operator %@",component_operator);
                    
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
                    
                    SMLog(kLogLevelVerbose,@"%@" ,operator_ );
                    
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
                                [temp appendString:@"%"];
                                [temp appendFormat:@"%@",value];
                                if(count >0)
                                [temp appendString:@"%"];
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
                    SMLog(kLogLevelVerbose,@"%@",expression_);
                }
            }
        }
        synchronized_sqlite3_finalize(stmt);
        
    }

    SMLog(kLogLevelVerbose,@" final component array %@",final_Comonent_array);
    
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
            //Major Change for Sorting lines
            //**********************************************************
            NSString * temp_lhs = [values_dict objectForKey:@"component_lhs"];
            NSString * lhs = [NSString  stringWithFormat:@"'%@'.%@",object_name,temp_lhs];
            //**********************************************************
            
            
            NSString * rhs = [values_dict objectForKey:@"component_rhs"];
            NSString * operator = [values_dict objectForKey:@"component_operator"];
            NSString * sequence = [values_dict objectForKey:@"sequence"];
            
                       
            NSString * component_expression = @"";
            NSString * data_type = [[appDelegate.databaseInterface getFieldDataType:object_name filedName:temp_lhs] lowercaseString];

            
            /* 7438 - Support for date literals in process entry criteria and wizard entry criteria*/
            if ([data_type isEqualToString:@"date"] || [data_type isEqualToString:@"datetime"]) {
                BOOL isDateOnly = NO;
                if ([data_type isEqualToString:@"date"]){
                    isDateOnly = YES;
                }
                NSString *newRhsValue = rhs;
                if([rhs caseInsensitiveCompare:MACRO_NOW]== NSOrderedSame)
                {
                    newRhsValue = [Utility today:0 andJusDate:isDateOnly];
                }
                else if([rhs caseInsensitiveCompare:MACRO_TODAY]== NSOrderedSame) {
                    newRhsValue = [Utility today:0 andJusDate:YES];
                }
                else if([rhs caseInsensitiveCompare:MACRO_TOMMOROW]== NSOrderedSame) {
                    newRhsValue = [Utility today:1 andJusDate:YES];
                }
                else if([rhs caseInsensitiveCompare:MACRO_YESTERDAY]== NSOrderedSame) {
                    newRhsValue = [Utility today:-1 andJusDate:YES];
                }
                rhs = newRhsValue;
            }
            
            
            // This check is for RecordTypeId
            if([temp_lhs isEqualToString:@"RecordTypeId"])
            {
                //5755
                if([operator isEqualToString:@"isnotnull"]) //#4722 defect fix for wizard billing type null
				{
                    //7960
                    //  component_expression = [NSString stringWithFormat:@" (length(%@) > 0) ",lhs];
                    component_expression = [NSString stringWithFormat:@"(%@ is not null and  ( trim(%@) != '' ))",lhs,lhs];

				}
                else if ([rhs isEqualToString:@"null"])
                {
                    component_expression = [NSString stringWithFormat:@" ( %@ = ' ' or typeof(%@) %@ '%@' or %@ = '' ) ",lhs,lhs,operator,rhs, lhs];
                }
				else
				{
                    //support for blank rhs. handled record_type and record_type_id = '' and null, for doesnot contain and not equal.
					if( [operator isEqualToString:@"!="] || [operator isEqualToString:@" NOT LIKE "])
                    {
                        component_expression = [NSString stringWithFormat:@"( %@   in   (select  record_type_id  from SFRecordType where (record_type %@ '%@' or trim(record_type) = '' or   record_type is null )))" ,lhs,operator, rhs];
                        component_expression = [NSString stringWithFormat:@" ( %@ OR  trim(%@) = '' OR %@ is null )",component_expression,lhs,lhs];
                        
                    }
                    else {
                        component_expression = [NSString stringWithFormat:@" %@   in   (select  record_type_id  from SFRecordType where record_type %@ '%@' )" ,lhs,operator, rhs];
                    }
				}
                //5755
            }
            else if([data_type isEqualToString:@"reference"])
            {
				NSString * referenceToTable = [appDelegate.dataBase getReferencetoFiledForObject:object_name api_Name:temp_lhs];
				if([operator isEqualToString:@"isnotnull"]) //#4722 defect fix for wizard billing type null
				{
                    //7960
                    //  component_expression = [NSString stringWithFormat:@" (length(%@) > 0) ",lhs];
                    component_expression = [NSString stringWithFormat:@"(%@ is not null and  ( trim(%@) != '' ))",lhs,lhs];
				}
                else if ([rhs isEqualToString:@"null"])
                {
                     component_expression = [NSString stringWithFormat:@" ( %@ = ' ' or typeof(%@) %@ '%@' or %@ = '' ) ",lhs,lhs,operator,rhs, lhs]; 
                }
				else
				{
					component_expression = [NSString stringWithFormat:@" %@   in   (select  Id  from '%@' where Name %@ '%@' )" , lhs,referenceToTable , operator ,rhs];
				}
                
            }
            else if ([operator isEqualToString: @"!="])
            {
                component_expression = [NSString stringWithFormat:@" ( %@ isnull or %@ %@ '%@' ) ",lhs,lhs,operator,rhs];
            }
			else if([operator isEqualToString:@"isnotnull"]) //#4722 defect fix for wizard billing type null
			{
                //7960
                //  component_expression = [NSString stringWithFormat:@" (length(%@) > 0) ",lhs];
                component_expression = [NSString stringWithFormat:@"(%@ is not null and  ( trim(%@) != '' ))",lhs,lhs];
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
                            
                            //component_expression = [component_expression stringByAppendingString:lhs_];
                             component_expression = [component_expression stringByAppendingFormat:@"'%@'.%@",object_name,lhs_];
                            component_expression = [component_expression stringByAppendingString:operator_];
                            rhs = [NSString stringWithFormat:@"'%@'",rhs_];
                            component_expression = [component_expression stringByAppendingString:rhs_];
                        }
                    }
                }
            }
            //for the key concatinate #$ and replace it with the expression
            NSString * concatinate_key = [NSString stringWithFormat:@"#$%@",key];
            SMLog(kLogLevelVerbose,@"%@", component_expression);
            regular_expression = [regular_expression stringByReplacingOccurrencesOfString:concatinate_key withString:component_expression];
        }
    }
        
    if ([regular_expression length] > 0)
    {
        retExpression = [NSString stringWithFormat:@"(%@)", regular_expression];
    }
    else
    {
        retExpression = [NSString stringWithFormat:@"%@", regular_expression];
    }
     }@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name Database :queryForExpressionComponent %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason Database :queryForExpressionComponent %@",exp.reason);
         [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
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
    
    //8890
    BOOL hasColumnSequence =  [Utility hasColumnSequence];

    NSMutableArray * buttons_array = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSArray * keys = [NSArray arrayWithObjects:SFW_ACTION_ID,SFW_ACTION_DESCRIPTION,SFW_EXPRESSION_ID,SFW_PROCESS_ID,SFW_ACTION_TYPE ,SFW_WIZARD_ID,SFW_ENABLE_ACTION_BUTTON,  PERFORM_SYNC, CLASS_NAME, METHOD_NAME, nil]; 
    
    for(int i = 0 ; i <[wizard_ids_array count]; i++)
    {
        NSString * wizard_id = [wizard_ids_array objectAtIndex:i];
        
        if(wizard_id != nil && [wizard_id length] != 0)
        {
            //8890
            NSString * query = nil;
            if (hasColumnSequence) {
                 query = [NSString stringWithFormat:@"SELECT action_id , action_description, expression_id , process_id ,action_type, perform_sync, class_name, method_name FROM '%@' where wizard_id ='%@' ORDER BY sequence" ,SFWizard_COMPONENT , wizard_id];
            }
            else{
                 query = [NSString stringWithFormat:@"SELECT action_id , action_description, expression_id , process_id ,action_type, perform_sync, class_name, method_name FROM '%@' where wizard_id ='%@'" ,SFWizard_COMPONENT , wizard_id];
            }
           
            
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
                    perfom_sync = @"";
                    class_name = @"";
                    method_name = @"";
                    
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
							//Sync Override :Radha
							BOOL customEntryExists = [self checkIfCustomEntryExistsInTrailerTable:record_id];
							NSMutableDictionary * dict = nil;
							
							//Check if button is associated with custom agressive sync webservice
							BOOL isCustomSync = NO;
							
							if (([class_name length] > 0) && ([method_name length] > 0))
							{
								isCustomSync = YES;
							}
							
                            
                            int isConflict = [appDelegate.dataBase checkIfObjectIsInConflict:objectName Id:appDelegate.sfmPageController.recordId];
                            
                            //if (customEntryExists && [action_type isEqualToString:@"SFM"] && isCustomSync)
							if (customEntryExists && [action_type isEqualToString:@"SFM"] && isCustomSync && isConflict == 0)
							{
								dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:action_id,action_description , expression_id, process_id, action_type , wizard_id, @"false",perfom_sync, class_name,method_name, nil] forKeys:keys];
							}
							else
							{
								dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:action_id,action_description , expression_id, process_id, action_type , wizard_id, @"true",perfom_sync, class_name,method_name, nil] forKeys:keys];
							}
                            
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
                        //krishna 23-1 memory opt 9493
                        [dateFormatter release];
                        dateFormatter = nil;
                        
                        if([target_field_name isEqualToString:@"RecordTypeId"])
                        {   
                            NSString * query = [NSString stringWithFormat:@"SELECT record_type_id FROM  SFRecordType where object_api_name = '%@' and record_type = '%@'" ,target_object_name,mapping_value];
                            NSString * record_type_id = @"";
                            
                            SMLog(kLogLevelVerbose,@"RecordTypeId  valuemapping %@" ,query);
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
                        //krishna 23-1 memory opt 9493
                        [dateFormatter release];
                        dateFormatter = nil;
                        
                        if([target_field_name isEqualToString:@"RecordTypeId"])
                        {
                            NSString * query = [NSString stringWithFormat:@"SELECT record_type_id FROM  SFRecordType where object_api_name = '%@' and record_type = '%@'" ,target_object_name,mapping_value];
                            NSString * record_type_id = @"";
                            
                            SMLog(kLogLevelVerbose,@"RecordTypeId  valuemapping %@" ,query);
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
 		//sahana - Child sfm fix  - stand alone
     /*   NSMutableDictionary * dataTypeForFeilds = [NSMutableDictionary dictionary];
        
        for(NSString * src_field_name in source_field_names)
        {
            NSString * data_type = [appDelegate.databaseInterface getFieldDataType:source_object_name filedName:src_field_name];
            if(data_type != nil)
            {
                [dataTypeForFeilds setObject:data_type forKey:src_field_name];
            }
            
        }*/
        NSString * query = @"";
        if(expression_ != nil && [expression_ length] != 0)
        {
            query = [NSString stringWithFormat:@"SELECT %@ FROM '%@' where %@ = '%@' and %@",query_field_names, source_object_name,field_name, source_record_id,expression_];
            SMLog(kLogLevelVerbose,@"SOURCETOTARGET %@", query);
        }
        else
        {
            query = [NSString stringWithFormat:@"SELECT %@ FROM '%@' where %@ = '%@' ",query_field_names, source_object_name,field_name, source_record_id];
            SMLog(kLogLevelVerbose,@"SOURCETOTARGET %@", query);
        }
       
       /* //sahana - child sfm fix
        BOOL Src_obj_isChild = [self IsChildObject:source_object_name];
        NSString *parent_obj_name = [self getchildInfoFromChildRelationShip:SFCHILDRELATIONSHIP ForChild:source_object_name field_name:@"parent_name"];
        NSString * parent_column_name = [self getchildInfoFromChildRelationShip:SFCHILDRELATIONSHIP ForChild:source_object_name field_name:@"parent_column_name"];
        */
        
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
                    
                 //   NSString * field_type = [dataTypeForFeilds objectForKey:[source_field_names objectAtIndex:k]];
                    NSString * Source_field_api = [source_field_names objectAtIndex:k];
                    NSString * targetFieldApi = [target_field_names  objectAtIndex:k];
                    
                    char * temp_field_value = (char *)synchronized_sqlite3_column_text(stmt,k);
                    if(temp_field_value != nil)
                    {
                        field_value = [NSString stringWithUTF8String:temp_field_value];
                    }
                    else
                    {
                        if([Source_field_api isEqualToString:@"Id"] && [field_value length] == 0)
                        {
                            field_value = source_record_id;
                            //handling Event object in fieldmapping.
                            if([target_object_name isEqualToString:@"Event"] && [targetFieldApi isEqualToString:@"WhatId"])
                            {
                                NSMutableDictionary * plist_dict = nil;
                                if([plistUtility DoesFileExist:EVENT_REFERENCE_PLIST])
                                {
                                   plist_dict = [plistUtility readFromPlist:EVENT_REFERENCE_PLIST];
                                }
                                else
                                {
                                    plist_dict = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
                                }
                                [plist_dict setObject:source_object_name forKey:source_record_id];

                                [plistUtility writeIntoPlist:EVENT_REFERENCE_PLIST data:plist_dict];
                            }
                        }
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
    
    SMLog(kLogLevelVerbose,@" Final array SOURCETOTARGET%@", final_array);
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
    synchronized_sqlite3_finalize(statement);
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
    
    synchronized_sqlite3_finalize(stmt);
    
    return process_Type;
}

-(BOOL)UpdateTableforId:(NSString *)local_id  forObject:(NSString *)objectName  data:(NSDictionary *)dict;
{
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"UpdateTableforId"
                                                         andRecordCount:0];
    
    
    BOOL success = FALSE;
    NSArray * allkeys = [dict allKeys];
    NSMutableString *  updateValue = [[NSMutableString alloc] initWithCapacity:0];
    @try{
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
    }@catch (NSException *exp)
    {
        SMLog(kLogLevelError,@"Exception Name databaseInterfaceSfm :UpdateTableforId %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason databaseInterfaceSfm :UpdateTableforId %@",exp.reason);
    }

    NSString * update_statement;
    
    if ([objectName isEqualToString:@"Case"])
        objectName = @"'Case'";
    
    if([updateValue length] != 0 && local_id != nil && [local_id length] != 0 )
        update_statement = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE local_id = '%@'",objectName ,updateValue,local_id];
    else if ( local_id != nil && [local_id length] != 0){
        
        // Vipin-db-optmz
        [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"UpdateTableforId"
                                                                          andRecordCount:0];
        
        return FALSE;
    }
    else {
        // Vipin-db-optmz
        [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"UpdateTableforId"
                                                                          andRecordCount:0];
        return TRUE;
    }
    
    char * err;
    [appDelegate.dataBase beginTransaction];
    if(synchronized_sqlite3_exec(appDelegate.db, [update_statement UTF8String],NULL, NULL, &err) != SQLITE_OK)
    {
        success = FALSE;
        SMLog(kLogLevelError,@"%@", update_statement);
		SMLog(kLogLevelError,@"METHOD:UpdateTableforId " );
		SMLog(kLogLevelError,@"ERROR IN UPDATING %s", err);
	 if([objectName isEqualToString:@"Event"])
        {
            NSString * startDateTime = [dict objectForKey:@"StartDateTime"];
            NSString * enddatetime = [dict objectForKey:@"EndDateTime"];
            NSString * overlappingEvent = [appDelegate.databaseInterface getallOverLappingEventsForStartDateTime:startDateTime EndDateTime:enddatetime local_id:local_id];
            [databaseInterfaceDelegate displayALertViewinSFMDetailview:overlappingEvent];
        }
//        else
//        {
//             [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:update_statement type:UPDATEQUERY];
//        }
    }
    else
    {
        success = TRUE;
        [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:1];
    }
    
    [appDelegate.dataBase endTransaction];
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"UpdateTableforId"
                                                                      andRecordCount:1];
    
    return success;
}


-(BOOL)UpdateTableforSFId:(NSString *)sf_id  forObject:(NSString *)objectName  data:(NSDictionary *)dict1
{
    // Vipin-db-optmz  Chance here done
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"UpdateTableforSFId"
                                                         andRecordCount:1];
    
    
	NSMutableDictionary * dict = [self updateEmptyFieldValuesForDict:dict1 objectName:objectName];
    NSString *  parent_column_name = [self getchildInfoFromChildRelationShip:SFCHILDRELATIONSHIP ForChild:objectName field_name:@"parent_column_name"];
	
	if (![objectName caseInsensitiveCompare:@"EVENT"] == NSOrderedSame)
	{
		[dict removeObjectForKey:parent_column_name];
	}
    
	BOOL success = FALSE;
    NSArray * allkeys = [dict allKeys];
    NSMutableString *  updateValue = [[[NSMutableString alloc] initWithCapacity:0] autorelease]; // sahana sep 13th
    @try{
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
	}@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name databaseInterfaceSfm :UpdateTableforSFId %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason databaseInterfaceSfm :UpdateTableforSFId %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }

    if ([objectName isEqualToString:@"Case"])
        objectName = @"'Case'";
    
    if([objectName isEqualToString:@"Event"])
    {
        [appDelegate.databaseInterface deleteRecordsFromEventLocalIdsFromTable:Event_local_Ids];
        [appDelegate.databaseInterface deleteRecordsFromEventLocalIdsFromTable:LOCAL_EVENT_UPDATE];
    }
    
     [appDelegate.dataBase beginTransaction];
    
    NSString * update_statement;
    
    sqlite3_stmt * statement;
    
    if ( ([updateValue length] != 0)
        && (sf_id != nil)
        && ([sf_id length] != 0 ) )
    {
        
        update_statement = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE Id = ?", objectName, updateValue];
        
        int ret_val = synchronized_sqlite3_prepare_v2(appDelegate.db, [update_statement UTF8String], strlen([update_statement UTF8String]),  &statement, NULL);
        
        // Good prepare statement
        if (ret_val == SQLITE_OK)
        {
            char * _sf_id = [appDelegate convertStringIntoChar:sf_id];
            sqlite3_bind_text(statement, 1, _sf_id, strlen(_sf_id), SQLITE_TRANSIENT);
            
            
            if (synchronized_sqlite3_step(statement) != SQLITE_DONE)
            {
                SMLog(kLogLevelError,@"%@", update_statement);
                SMLog(kLogLevelError,@"Failure UpdateTableforSFId - updateStatement => %@", update_statement);
                success = FALSE;
            }
            else
            {
                // SMLog(kLogLevelVerbose,@"Success updateParentColumnNameInChildTableWithParentLocalId - updateStatement => %@", updateStatement);
                success = TRUE;
            }
            
            sqlite3_clear_bindings(statement);
            sqlite3_reset(statement);
            synchronized_sqlite3_finalize(statement);
        }
        else
        {
            SMLog(kLogLevelVerbose,@"Failure prepare UpdateTableforSFId - updateStatement => %@", update_statement);
            success = FALSE;
        }
    }
    else if ( sf_id != nil && [sf_id length] != 0)
    {
        success = FALSE;
    }
    else
    {
        success = TRUE;
    }
    
    [appDelegate.dataBase endTransaction];
    
    [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:1];
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"UpdateTableforSFId"
                                                                      andRecordCount:0];
    
    
    
    return success;
}

#pragma mark - updateNullValue
- (NSMutableDictionary *) updateEmptyFieldValuesForDict:(NSDictionary *)dict objectName:(NSString *)objectName
{
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"updateEmptyFieldValuesForDict"
                                                         andRecordCount:1];
    
    
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"getAllObjectFields-1"
                                                         andRecordCount:1];
    
    
	NSMutableDictionary * allFieldsDict = [self getAllObjectFields:objectName tableName:@"SFObjectField"];
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"getAllObjectFields-1"
                                                                      andRecordCount:0];
    
	
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
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"updateEmptyFieldValuesForDict"
                                                                      andRecordCount:0];
	return mDict;
}


#pragma mark -END
-(NSString *)getLookUpNameForId:(NSString *)id_ 
{
    NSString * query = [NSString  stringWithFormat:@"SELECT DISTINCT value from LookUpFieldValue where Id = '%@'" ,id_ ]; //10214
    sqlite3_stmt * stmt;
    NSString * name = @"";
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(stmt)== SQLITE_ROW)
        {
            char * temp_name = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if(temp_name != nil && strlen(temp_name)) //10214
            {
                name =[NSString stringWithUTF8String:temp_name];
            }
        }
    }
    
    synchronized_sqlite3_finalize(stmt);
    
    return name;
}

-(NSMutableDictionary *) getAllRecordsFromRecordsHeap
{
	
	//Changes for optimized sync - One Call sync
	NSInteger count = [self getCountOfRecordsFromSyncRecordsHeap];
	
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    NSMutableArray * Objects_Array  = [[NSMutableArray alloc] initWithCapacity:0];
    NSString * query_ = [[NSString alloc ]initWithFormat:@"SELECT DISTINCT object_name from sync_Records_Heap where sync_flag = 'false'"];                 //18Apr 
     sqlite3_stmt * stmt_;
    
    // Mem_leak_fix - Vipindas 9493 Jan 18
    @autoreleasepool
    {
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
    }
    synchronized_sqlite3_finalize(stmt_);
    
    [query_ release];
	
	//Changes for optimized sync - One Call sync
	int noOfId = 0;
    
    // Mem_leak_fix - Vipindas 9493 Jan 18
    @autoreleasepool
    {
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
                            //Changes for optimized sync - One Call sync
                            noOfId++;
                            flag = TRUE;
                            break;
                        }
                    }
                    if(!flag)
                    {
                        NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:0] ;
                        [array addObject:sf_id];
                        //Changes for optimized sync - One Call sync
                        noOfId++;
                        [dict setObject:array forKey:object_name];
                        [array release];                //18Apr 
                    }
                }
            }
            synchronized_sqlite3_finalize(stmt);
            [query release];
        }
        
    }
    //Changes for optimized sync - One Call sync
	NSString * lastBatch = @"false";
    if (noOfId == count)
	{
		lastBatch = @"true";
	}
	[dict setObject:lastBatch forKey:@"LAST_BATCH"];    
    [Objects_Array release];
    
    // Mem_leak_fix - Vipindas 9493 Jan 18
    return [dict autorelease];
}
//Changes for optimized sync - One Call sync
- (NSInteger) getCountOfRecordsFromSyncRecordsHeap
{
	NSString * query = @"SELECT COUNT (*) FROM sync_Records_Heap WHERE sync_flag = 'false'";
	
	sqlite3_stmt * stmt_;
	NSInteger count = 0;
	
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt_, nil) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(stmt_) == SQLITE_ROW)
        {
            count = synchronized_sqlite3_column_int(stmt_, 0);
        }
		
		synchronized_sqlite3_finalize(stmt_);
    }
	
	return count;
}

// Vipin-db-optmz
-(void)updateAllRecordsToSyncRecordsHeap:(NSMutableDictionary *)sync_data
{
    // Vipin-db-optmz
    SMLog(kLogLevelVerbose,@"  updateAllRecordsToSyncRecordsHeap Processing starts: %@  for count %d", [NSDate date],[sync_data count]);
    
    sync_data = [sync_data retain];
    /*Mem Opt*/
    NSArray * all_objects = [[NSArray alloc]initWithArray:[sync_data allKeys]];
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"updateAllRecordsToSyncRecordsHeap"
                                                         andRecordCount:[all_objects count]];
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    sqlite3_stmt * bulkStmt;
    [appDelegate.dataBase beginTransaction];
    
    @try{
        
        NSString * sf_id = @"", *json_record = @"";
        NSString * update_query = [NSString stringWithFormat:@"UPDATE '%@' SET  json_record = ?1 , sync_flag = 'true' WHERE sf_id = ?2 ", SYNC_RECORD_HEAP];
        
        
        int ret_val = synchronized_sqlite3_prepare_v2(appDelegate.db, [update_query UTF8String], strlen([update_query UTF8String]),  &bulkStmt, NULL);
        
        if (ret_val == SQLITE_OK)
        {
            for(NSString * object_name in  all_objects)
            {
                NSMutableArray *  object_info = [sync_data objectForKey:object_name];
                SMLog(kLogLevelVerbose,@" no of records %d", [object_info count]);
                
                // Vipin-db-optmz - 2.0
                [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"updateAllRecordsToSyncRecordsHeap-Ext"
                                                                     andRecordCount:[object_info count]];
                for (int i = 0 ; i < [object_info count]; i++)
                {
                    NSDictionary * dict = [ object_info objectAtIndex:i];
                    NSArray * all_keys = [dict allKeys];
                    
                    for(NSString * key in all_keys)
                    {
                        // @"LOCAL_ID",@"JSON_RECORD",@"SF_ID",
                        if([key isEqualToString:@"JSON_RECORD"])
                        {
                            json_record = [dict objectForKey:@"JSON_RECORD"];
                            char * _json_record = [appDelegate convertStringIntoChar:json_record];
                            sqlite3_bind_text(bulkStmt, 1, _json_record, strlen(_json_record), SQLITE_TRANSIENT);
                            
                        }
                        else if ([key isEqualToString:@"SF_ID"])
                        {
                            sf_id = [dict objectForKey:@"SF_ID"];
                            char * _sf_id = [appDelegate convertStringIntoChar:sf_id];
                            sqlite3_bind_text(bulkStmt, 2, _sf_id, strlen(_sf_id), SQLITE_TRANSIENT);
                        }
                    }
                    
                    if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                    {
                        SMLog(kLogLevelVerbose,@"%@", update_query);
                        SMLog(kLogLevelVerbose,@"METHOD:updateAllRecordsToSyncRecordsHeap " ); //RADHA TODAY
                        
                        SMLog(kLogLevelError,@"Failure updateAllRecordsToSyncRecordsHeap - update_query => %@", update_query);
                    } else
                    {
                        //SMLog(kLogLevelVerbose,@"Success updateAllRecordsToSyncRecordsHeap - update_query => %@", update_query);
                    }
                    
                    sqlite3_clear_bindings(bulkStmt);
                    sqlite3_reset(bulkStmt);
                }
                
                // Vipin-db-optmz - 2.0
                [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"updateAllRecordsToSyncRecordsHeap-Ext"
                                                                                  andRecordCount:0];
                [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:[object_info count]];
            }
        }
    }@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name databaseInterfaceSfm :updateAllRecordsToSyncRecordsHeap %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason databaseInterfaceSfm :updateAllRecordsToSyncRecordsHeap %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
    
    synchronized_sqlite3_finalize(bulkStmt);
    [sync_data release];
    
    [pool release];
    
    /*Mem Opt*/
    [all_objects release];
    
    // Vipin-db-optmz
    [appDelegate.dataBase endTransaction];
    
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"updateAllRecordsToSyncRecordsHeap"
                                                                      andRecordCount:0];
    
    SMLog(kLogLevelVerbose,@"  updateAllRecordsToSyncRecordsHeap Processing ends: %@", [NSDate date]);
}




/* Modified to include parser :InitialSync-shr*/
-(NSMutableDictionary *)getDictForJsonString:(NSString *)json_record withParser:(SBJsonParser *)globalParser
{
    
    NSAutoreleasePool * autoreleasePool = [[NSAutoreleasePool alloc] init];
    
    SBJsonParser * jsonParser = globalParser;
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance]  observePerformanceForContext:@"getDictForJsonString - parsing"
                                                          andRecordCount:0];
    
    
    NSDictionary * json_dict = [jsonParser objectWithString:json_record];
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance]  completedPerformanceObservationForContext:@"getDictForJsonString - parsing"
                                                                       andRecordCount:1];
    
    
    //Vipin - defect 7350
    NSMutableDictionary * final_dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    // Vipin-db-optmz
    NSMutableDictionary *apiNameForNameFieldDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSMutableArray  *lookupDictionaryArray = [[NSMutableArray alloc] init];
    
    
    NSArray * json_allkeys = [json_dict allKeys];
   // NSInteger lookUp_id = 0;
    for (int f = 0; f < [json_allkeys count]; f++)
    {
        NSString * json_key = [json_allkeys objectAtIndex:f];
        id  id_type = [json_dict objectForKey:json_key];
        
        if ([id_type isKindOfClass:[NSDictionary class]])
        {
            NSString * field = [json_allkeys objectAtIndex:f];
            
            NSDictionary * dict = (NSDictionary *)id_type;
            NSRange range = [field rangeOfString:@"__r"];
            //defect 8460
            NSDictionary * attDict = [dict objectForKey:@"attributes"];
            NSString * object = [attDict objectForKey:@"type"];
            
            if (range.location != NSNotFound || [attDict count] > 0)
            {  // SMLog(kLogLevelVerbose,@"Querying");
				//RADHA 27/Sep/2012
				NSString * objectName = [appDelegate.dataBase getApiNameForNameField:object];
				
                // Vipind-db-optmz
                if (objectName == nil)
                {
                    // defect 8460 code review change.
                    // defect 8460
                    if (![objectName length]>0)
                    {
                        objectName=([[dict allKeys] containsObject:@"Name"])?@"Name":([[dict allKeys] containsObject:@"CaseNumber"])?@"CaseNumber":@"";
                    }
                    
                    [apiNameForNameFieldDict setObject:objectName forKey:object];
                }
                
                // Vipin - issue Fix #7350
                NSMutableDictionary * lookUpDict = [[NSMutableDictionary alloc] initWithCapacity:0];

                [lookUpDict setValue:[dict objectForKey:@"Id"] forKey:@"Id"];
                [lookUpDict setValue:[dict objectForKey:objectName] forKey:@"Name"];
                // defect 8460
                [lookUpDict setValue:object forKey:@"type"];

                
                // Vipind-db-optmz
                [lookupDictionaryArray addObject:lookUpDict];
                [lookUpDict release];// Vipin - 7350
                lookUpDict = nil;
            }
        }
        else
        {
            NSString * value =  [NSString stringWithFormat:@"%@", id_type];
            [final_dict setObject:value forKey:json_key];
        }
    }
    
    // Vipin-db-optmz
    [appDelegate.dataBase addValuesToLookUpFieldTable:lookupDictionaryArray];
    [lookupDictionaryArray release];
    [apiNameForNameFieldDict release];
    
    [autoreleasePool release];
    return final_dict;
}


// Vipin-db-optmz - Modified method
/* Inserts records into appropriate table and updates the sync flag in temporary table :InitialSync-shr*/
- (void)insertAllRecordsToRespectiveTables:(NSMutableDictionary *)syncedData andParser:(SBJsonParser *)jsonParser
{
    [syncedData retain];
    
    // Vipin-db-optmz
   // NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    // Mem_leak_fix - Vipindas 9493 Jan 18
    @autoreleasepool
    {
        if (self.objectFieldDictionary == nil)
        {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            self.objectFieldDictionary  = dict;
            [dict release];
            dict = nil;
        }
        
        // Vipin-db-optmz
        if (self.apiNameToInsertionQueryDictionary == nil)
        {
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            self.apiNameToInsertionQueryDictionary  = dictionary;
            [dictionary release];
            dictionary = nil;
        }
        
        int retVal =  [appDelegate.dataBase beginTransaction];
        SMLog(kLogLevelVerbose,@"Starting transcation Success = %d",retVal);
        
        /*For each object in object array, objectApiName = table name */
        NSArray *allKeysOfSyncData = [syncedData allKeys];
        
        for (NSString *objectApiName in allKeysOfSyncData)
        {
            // Mem_leak_fix - Vipindas 9493 Jan 18
            @autoreleasepool
            {
                SMLog(kLogLevelVerbose,@"Insertion starts for %@",objectApiName);
                
                /* get field and table schema only once and store it in global dictionary*/
                NSMutableDictionary *fieldDictionary =  [objectFieldDictionary objectForKey:objectApiName];
                
                if (fieldDictionary == nil)
                {
                    fieldDictionary = [self getAllFieldsAndItsDataTypesForObject:objectApiName tableName:SFOBJECTFIELD];
                    [fieldDictionary setValue:@"VARCHAR" forKey:@"local_id"];
                    [objectFieldDictionary setObject:fieldDictionary forKey:objectApiName];
                }
                
                // Form a query and store that in the global dictionary
                NSArray  *allKeysObjectApiNames = [fieldDictionary allKeys];
                
                NSString *insertionQuery = [self.apiNameToInsertionQueryDictionary objectForKey:objectApiName];
                
                if (insertionQuery == nil)
                {
                    NSString * fieldString = @"";
                    NSString * valuesString = @"";
                    
                    NSInteger allKeysCount = [allKeysObjectApiNames count];
                    
                    for (int t = 0; t < allKeysCount; t++)
                    {
                        NSString * keyFieldName = [allKeysObjectApiNames objectAtIndex:t];
                        
                        if (t != 0)
                        {
                            /*Mem Opt*/
                            NSString * temp_field_string = [[NSString alloc]initWithFormat:@",%@", keyFieldName];
                            fieldString  = [fieldString stringByAppendingFormat:@"%@", temp_field_string];
                            valuesString = [valuesString stringByAppendingFormat:@",?%d", t+1];
                            [temp_field_string release];
                        }
                        else
                        {
                            /*Mem Opt*/
                            NSString * temp_field_string = [[NSString alloc]initWithFormat:@"%@", keyFieldName];
                            fieldString  = [fieldString stringByAppendingFormat:@"%@", temp_field_string];
                            valuesString = [valuesString stringByAppendingFormat:@"?%d", t+1];
                            [temp_field_string release];
                        }
                    }
                    
                    insertionQuery = [NSString stringWithFormat:@"INSERT INTO '%@' (%@) VALUES (%@)", objectApiName, fieldString,valuesString];
                    [self.apiNameToInsertionQueryDictionary setObject:insertionQuery forKey:objectApiName];
                    
                }
                
                
                /* Compile it for the records and insert them */
                sqlite3_stmt * bulk_statement = nil;
                
                int preparedSuccessfully =  synchronized_sqlite3_prepare_v2(appDelegate.db, [insertionQuery UTF8String], strlen([insertionQuery UTF8String]), &bulk_statement, NULL);
                
                int counter = 0;
                
                NSString *localId = nil,*sfid=nil,*jsonRecord = nil;
                
                if (preparedSuccessfully == SQLITE_OK)
                {
                    NSArray *allRecords = [syncedData objectForKey:objectApiName];
                    NSInteger numberOfRecords = [allRecords count];
                    
                    // Vipin-db-optmz
                    [[PerformanceAnalytics sharedInstance]  observePerformanceForContext:[NSString stringWithFormat:@"insertAllRecordsToRespectiveTables : %@", objectApiName]
                                                                          andRecordCount:0];
                    // Mem_leak_fix - Vipindas 9493 Jan 18
                    @autoreleasepool
                    {
                        for (counter = 0; counter < numberOfRecords; counter++)
                        {
                            
                            NSDictionary *recordDictionary = [allRecords objectAtIndex:counter];
                            
                            localId    = [recordDictionary objectForKey:@"LOCAL_ID"];
                            sfid       = [recordDictionary objectForKey:@"SF_ID"];
                            jsonRecord = [recordDictionary objectForKey:@"JSON_RECORD"];
                            
                            
                            NSString * newLocalId = nil;
                            
                            // Vipin-db-optmz
                            [[PerformanceAnalytics sharedInstance]  observePerformanceForContext:@"insertAllRecordsToRespectiveTables-parser process"
                                                                                  andRecordCount:0];
                            
                            NSMutableDictionary * responseDictionary = [self getDictForJsonString:jsonRecord withParser:jsonParser];
                            if([objectApiName isEqualToString:@"Attachment"])
                            {
                                NSString *name = [responseDictionary objectForKey:@"Name"];
                                if ([name Contains:@"_sign.png"]){
                                    NSLog(@"%@",name);
                                    continue;
                                }
                            }
                            
                            // Vipin-db-optmz
                            [[PerformanceAnalytics sharedInstance]  observePerformanceForContext:@"insertAllRecordsToRespectiveTables-GETUUID"
                                                                                  andRecordCount:0];
                            
                            // Mem_leak_fix - Vipindas 9493 Jan 18
                            newLocalId = [[AppDelegate GetUUID] retain];
                            // Vipin-db-optmz
                            [[PerformanceAnalytics sharedInstance]  completedPerformanceObservationForContext:@"insertAllRecordsToRespectiveTables-GETUUID"
                                                                                               andRecordCount:1];
                            
                            
                            [[PerformanceAnalytics sharedInstance]  observePerformanceForContext:@"insertAllRecordsToRespectiveTables-parser process"
                                                                                  andRecordCount:1];
                            
                            [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"insertAllRecordsToRespectiveTables-parser process"
                                                                                              andRecordCount:0];
                            
                            
                            
                            /* It is not used as of now. */
                            BOOL  check_flag = YES;// [appDelegate.dataBase checkForDuplicateId:objectApiName sfId:sfid];
                            
                            /* Insertion */
                            if (check_flag)
                            {
                                
                                [responseDictionary setObject:newLocalId forKey:@"local_id"];
                                
                                NSInteger allTableColumnNamesCount = [allKeysObjectApiNames count];
                                
                                // Vipin-db-optmz
                                [[PerformanceAnalytics sharedInstance]  observePerformanceForContext:@"insertAllRecordsToRespectiveTables-Columns process"
                                                                                      andRecordCount:0];
                                
                                for (int x = 0; x < allTableColumnNamesCount; x++)
                                {
                                    int column_num = x+1;
                                    
                                    NSString * field       = [allKeysObjectApiNames objectAtIndex:x];
                                    NSString * data_type   = [fieldDictionary objectForKey:field];
                                    NSString * columnType  = [appDelegate.dataBase columnType:data_type];
                                    NSString * final_value = [responseDictionary objectForKey:field];
                                    
                                    if (final_value == nil)
                                    {
                                        final_value = @"";
                                    }
                                    
                                    char * _finalValue = [appDelegate convertStringIntoChar:final_value];
                                    
                                    if ([columnType isEqualToString:DOUBLE])
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
                                
                                // Vipin-db-optmz
                                [[PerformanceAnalytics sharedInstance]  observePerformanceForContext:@"insertAllRecordsToRespectiveTables-Columns process"
                                                                                      andRecordCount:allTableColumnNamesCount];
                                
                                [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"insertAllRecordsToRespectiveTables-Columns process"
                                                                                                  andRecordCount:0];
                                
                                
                                int ret = synchronized_sqlite3_step(bulk_statement);
                                SMLog(kLogLevelVerbose,@"Insertion For for %@ Success = %d",sfid,ret);
                                
                                if (ret != SQLITE_DONE)
                                {
                                    NSError *error = nil;
                                    SMLog(kLogLevelError,@"Commit Failed! insertAllRecordsToRespectiveTables Query : %@ \n error : %@ ", insertionQuery, error);
                                    //[appDelegate printIfError:[NSString stringWithFormat:@"%d",ret] ForQuery:insertionQuery type:INSERTQUERY];
                                }
                                
                                sqlite3_clear_bindings(bulk_statement);
                                sqlite3_reset(bulk_statement);
                                
                                [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:1];
                                
                            }
                            else
                            {
                                BOOL flag = [self UpdateTableforSFId:sfid forObject:objectApiName data:responseDictionary];
                                if(flag)
                                {
                                    
                                }
                            }
                            
                            [responseDictionary release];
                            responseDictionary = nil;
                            
                            [newLocalId release];
                            newLocalId = nil;
                            
                        }
                    }
                    
                    // Vipin-db-optmz
                    [[PerformanceAnalytics sharedInstance]  observePerformanceForContext:[NSString stringWithFormat:@"insertAllRecordsToRespectiveTables : %@", objectApiName]
                                                                          andRecordCount:[allRecords count]];
                    
                    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:[NSString stringWithFormat:@"insertAllRecordsToRespectiveTables : %@", objectApiName]
                                                                                      andRecordCount:0];
                }
                else
                {
                    SMLog(kLogLevelError,@"Failed prepared statement for insertAllRecordsToRespectiveTables : %@", objectApiName);
                }
                
                synchronized_sqlite3_finalize(bulk_statement);
                
                SMLog(kLogLevelVerbose,@"Insertion Ends for %@",objectApiName);
            }
        }
        
        // Vipin-db-optmz
        retVal = [appDelegate.dataBase endTransaction];
        SMLog(kLogLevelVerbose,@"Commit transaction %d",retVal);
        
        /* Change the status of records in sync table as true for the successfull insertion */
        [self updateTheStatusOfSynRecordsToTrue:syncedData];
    }
    
    // Vipin-db-optmz
    //[pool drain];
    //pool = nil;
    
    /*Once everything is done, clean up the necessary objects in the memory */
    [syncedData release];
}

/* Inserts records into appropriate table and updates the sync flag in temporary table :InitialSync-shr*/


// Vipin-db-optmz  - Modified method
- (void)updateTheStatusOfSynRecordsToTrue:(NSMutableDictionary *)sync_data {
    
    SMLog(kLogLevelVerbose,@"Updating sync temporary table  starts: %@  for count %d", [NSDate date],[sync_data count]);
    // SMLog(kLogLevelVerbose,@"Updating sync temporary table  starts: %@  for count %d", [NSDate date],[sync_data count]);
    
    [sync_data retain];
    NSArray * all_objects = [sync_data allKeys];
    
    int retVal = [appDelegate.dataBase beginTransaction];
    
    @try{
        NSString * sf_id = @"", * local_id = @"";
        
        /*Mem Opt*/
        NSString * update_query = [[NSString alloc]initWithFormat:@"UPDATE '%@' SET sync_flag = 'true' WHERE sf_id = ?1", SYNC_RECORD_HEAP];
        
        sqlite3_stmt * bulkStmt;
        
        int ret_val = synchronized_sqlite3_prepare_v2(appDelegate.db, [update_query UTF8String], strlen([update_query UTF8String]),  &bulkStmt, NULL);
        
        if (ret_val == SQLITE_OK)
        {
            // Mem_leak_fix - Vipindas 9493 Jan 18
            @autoreleasepool
            {
                for (NSString * object_name in  all_objects)
                {
                    NSMutableArray *  object_info = [sync_data objectForKey:object_name];
                    SMLog(kLogLevelVerbose,@" no of records %d", [object_info count]);
                    //SMLog(kLogLevelVerbose,@" no of records %d", [object_info count]);
                    // Vipin-db-optmz
                    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:[NSString stringWithFormat:@"updateTheStatusOfSynRecordsToTrue : %@", object_name]
                                                                         andRecordCount:0];
                    for (int i = 0 ; i < [object_info count]; i++)
                    {
                        NSAutoreleasePool * autorelease = [[NSAutoreleasePool alloc] init];
                        NSDictionary * dict = [ object_info objectAtIndex:i];
                        NSArray * all_keys = [dict allKeys];
                        
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
                        }
                        
                        
                        char * _sf_id = [appDelegate convertStringIntoChar:sf_id];
                        sqlite3_bind_text(bulkStmt, 1, _sf_id, strlen(_sf_id), SQLITE_TRANSIENT);
                        
                        if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                        {
                            SMLog(kLogLevelError,@"%@", update_query);
                            SMLog(kLogLevelError,@"updateTheStatusOfSynRecordsToTrue query : %@ ", update_query); //RADHA TODAY
                        }else{
                            
                            // SMLog(kLogLevelVerbose,@" Success updateTheStatusOfSynRecordsToTrue - update_query => %@", update_query);
                            
                            
                        }
                        
                        sqlite3_clear_bindings(bulkStmt);
                        sqlite3_reset(bulkStmt);
                        
                        
                        //char * err;
                        
                        //if(synchronized_sqlite3_exec(appDelegate.db, [update_query UTF8String],NULL, NULL, &err) != SQLITE_OK)
                        //{
                        //  SMLog(kLogLevelVerbose,@"%@", update_query);
                        //SMLog(kLogLevelVerbose,@"METHOD:updateAllRecordsToSyncRecordsHeap " );
                        //SMLog(kLogLevelVerbose,@"ERROR IN UPDATING %s", err); //RADHA TODAY
                        
                        //[appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:update_query type:UPDATEQUERY];
                        //}
                        
                        [autorelease drain];
                    }
                    
                    [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:[object_info count]];
                    // Vipin-db-optmz
                    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:[NSString stringWithFormat:@"updateTheStatusOfSynRecordsToTrue : %@", object_name]
                                                                         andRecordCount:[object_info count]];
                    
                    
                    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:[NSString stringWithFormat:@"updateTheStatusOfSynRecordsToTrue : %@", object_name]
                                                                                      andRecordCount:0];
                }
            }
            
            synchronized_sqlite3_finalize(bulkStmt);
        }
        /*Mem Opt*/
        [update_query release];
        
    }@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Reason databaseInterfaceSfm :updateAllRecordsToSyncRecordsHeap  name : %@ \n reason : %@", exp.name, exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
    
    retVal = [appDelegate.dataBase endTransaction];
    
    [sync_data release];
    SMLog(kLogLevelVerbose,@"Updating sync temporary table ends: %@", [NSDate date]);
}


-(void)PutconflictRecordsIntoHeapFor:(NSString *)sync_type override_flag:(NSString *)override_flag_value
{
    NSMutableDictionary * final_dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSArray * keys = [NSArray arrayWithObjects:@"LOCAL_ID",@"JSON_RECORD",@"SF_ID",@"SYNC_TYPE", @"RECORD_TYPE",nil];
    //sahana Aug 27 fix for retry delete
    NSString * temp_syncType = @"";
    if([sync_type isEqualToString:PUT_DELETE] || [sync_type isEqualToString:PUT_UPDATE])
    {
        temp_syncType = PUT_UPDATE;
    }
    
    sqlite3_stmt * statement;
    NSString * local_id = @"", * object_name = @""  , * record_type = @"" , * sf_id = @"" ;
    NSString * query  = [NSString stringWithFormat:@"SELECT  local_id , object_name , record_type, sf_id  FROM '%@' WHERE sync_type = '%@'   and override_flag = '%@'" ,SYNC_ERROR_CONFLICT , sync_type , override_flag_value];
    
    // SMLog(kLogLevelVerbose,@" getAllRecords  %@", query);
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
                NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id,@"",sf_id,temp_syncType,record_type, nil] forKeys:keys];
                [array addObject:dict];
                
            }
            else
            {
                NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:0];
                NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id,@"",sf_id,temp_syncType,record_type, nil] forKeys:keys];
                [array addObject:dict];
                [final_dict setObject:array forKey:object_name];
                
            }
        }
        
        synchronized_sqlite3_finalize(statement);
    }
    
    [self insertRecordIdsIntosyncRecordHeap:final_dict];
}

- (void)insertRecordIdsIntosyncRecordHeap:(NSMutableDictionary *)sync_data
{
    SMLog(kLogLevelVerbose,@"insertRecordIdsIntosyncRecordHeap starts: %@", [NSDate date]);
    
    
    sync_data = [sync_data retain];
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSMutableDictionary *childObjectDictionary = [[NSMutableDictionary alloc] initWithCapacity:1];
    
    sqlite3_stmt * bulkStmt;
    [appDelegate.dataBase beginTransaction];
    
    {
        NSArray * all_objects = [sync_data allKeys];
        
        @try{
            
            NSString * sf_id = @"", * local_id = @"", *json_record = @"", * sync_type = @"", * record_type = @"";
            
            NSString * update_query = [NSString stringWithFormat:@"INSERT INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@', '%@') VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7)", SYNC_RECORD_HEAP, @"sf_id", @"local_id", @"object_name", @"sync_type", @"json_record", @"sync_flag", @"record_type"];
            
            
            
            // Vipin-db-optmz
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"insertRecordIdsIntosyncRecordHeap"
                                                                 andRecordCount:0];
            
            int reult = synchronized_sqlite3_prepare_v2(appDelegate.db,
                                                        [update_query UTF8String],
                                                        strlen([update_query UTF8String]),
                                                        &bulkStmt, NULL);
            if (reult == SQLITE_OK)
            {
                for (NSString * object_name in  all_objects)
                {
                    NSMutableArray *  object_info = [sync_data objectForKey:object_name];
                    
                    // May Change
                    for (int i = 0 ; i < [object_info count]; i++)
                    {
                        // NSAutoreleasePool * autorelesePool = [[NSAutoreleasePool alloc] init];
                        
                        NSDictionary * dict = [ object_info objectAtIndex:i];
                        NSArray * all_keys = [dict allKeys];
                        
                        for (NSString * key in all_keys)
                        {
                            // @"LOCAL_ID",@"JSON_RECORD",@"SF_ID",
                            if([key isEqualToString:@"LOCAL_ID"])
                            {
                                local_id = [dict objectForKey:@"LOCAL_ID"];
                                char * _local_id = [appDelegate convertStringIntoChar:local_id];
                                sqlite3_bind_text(bulkStmt, 2, _local_id, strlen(_local_id), SQLITE_TRANSIENT);
                            }
                            else if([key isEqualToString:@"JSON_RECORD"])
                            {
                                json_record = [dict objectForKey:@"JSON_RECORD"];
                                char * _json_record = [appDelegate convertStringIntoChar:json_record];
                                sqlite3_bind_text(bulkStmt, 5, _json_record, strlen(_json_record), SQLITE_TRANSIENT);
                            }
                            else if ([key isEqualToString:@"SF_ID"])
                            {
                                sf_id = [dict objectForKey:@"SF_ID"];
                                char * _sf_id = [appDelegate convertStringIntoChar:sf_id];
                                sqlite3_bind_text(bulkStmt, 1, _sf_id, strlen(_sf_id), SQLITE_TRANSIENT);
                            }
                            else if ([key isEqualToString:@"SYNC_TYPE"])
                            {
                                sync_type = [dict objectForKey:@"SYNC_TYPE"];
                                char * _sync_type = [appDelegate convertStringIntoChar:sync_type];
                                sqlite3_bind_text(bulkStmt, 4, _sync_type, strlen(_sync_type), SQLITE_TRANSIENT);
                            }
                            else if ([key isEqualToString:@"RECORD_TYPE"])
                            {
                                record_type = [dict objectForKey:@"RECORD_TYPE"];
                            }
                        }
                        
                        char * _object_name = [appDelegate convertStringIntoChar:object_name];
                        sqlite3_bind_text(bulkStmt, 3, _object_name, strlen(_object_name), SQLITE_TRANSIENT);
                        
                        NSNumber *exist = [childObjectDictionary objectForKey:object_name];
                        
                        
                        // Vipin-db-optmz 2.0
                        BOOL isChild = NO;
                        
                        if (exist == nil)
                        {
                            isChild = [self IsChildObject:object_name];
                            [childObjectDictionary setObject:[NSNumber numberWithBool:isChild] forKey:object_name];
                        }
                        else
                        {
                            isChild = [exist boolValue];
                        }
                        
                        if (isChild && ![object_name caseInsensitiveCompare:@"EVENT"] == NSOrderedSame)
                        {
                            record_type = DETAIL;
                        }
                        else
                        {
                            record_type = MASTER;
                        }
                        
                        char * _record_type = [appDelegate convertStringIntoChar:record_type];
                        sqlite3_bind_text(bulkStmt, 7, _record_type, strlen(_record_type), SQLITE_TRANSIENT);
                        
                        NSString *sync_flag = @"false";
                        char * _sync_flag = [appDelegate convertStringIntoChar:sync_flag];
                        sqlite3_bind_text(bulkStmt, 6, _sync_flag, strlen(_sync_flag), SQLITE_TRANSIENT);
                        
                        
                        if (sqlite3_step(bulkStmt) != SQLITE_DONE)
                        {
                            SMLog(kLogLevelError,@"insertRecordIdsIntosyncRecordHeap failed Query :%@ \n\n reason: \n %@", update_query, [NSString stringWithUTF8String:sqlite3_errmsg(appDelegate.db)]);
                        }
                        
                        sqlite3_clear_bindings(bulkStmt);
                        sqlite3_reset(bulkStmt);
                        
                        //[autorelesePool release];
                    }
                    
                    // Vipin-db-optmz
                    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"insertRecordIdsIntosyncRecordHeap"
                                                                         andRecordCount:[object_info count]];
                    [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:[object_info count]];
                    
                }
            }
            
            synchronized_sqlite3_finalize(bulkStmt);
            
        }@catch (NSException *exp) {
            
            SMLog(kLogLevelError,@"Exception Name databaseInterfaceSfm :insertRecordIdsIntosyncRecordHeap %@",exp.name);
            SMLog(kLogLevelError,@"Exception Reason databaseInterfaceSfm :insertRecordIdsIntosyncRecordHeap %@",exp.reason);
            [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
            
        }@finally {
            //
        }
        
        SMLog(kLogLevelVerbose,@" sync_data %d",[sync_data retainCount]);
        
    }
    
    //Vipin-db-optmz 2.0
    [childObjectDictionary release];
    childObjectDictionary = nil;
    
    [appDelegate.dataBase endTransaction];
    
    [pool drain];
    
    [sync_data release];
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"insertRecordIdsIntosyncRecordHeap"
                                                                      andRecordCount:0];
    
    SMLog(kLogLevelError,@"IComeOUTHere databaseinterface");
    SMLog(kLogLevelError,@"insertRecordIdsIntosyncRecordHeap ends: %@", [NSDate date]);
}


#pragma mark query for trailer table

-(NSMutableArray *) getAllInsertRecords:(NSString *)operation_type
{
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:[NSString stringWithFormat:@"getAllInsertRecords : %@", operation_type]
                                                         andRecordCount:0];
    
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
    
	// SMLog(kLogLevelVerbose,@" getAllRecords  %@", query);
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
    
    synchronized_sqlite3_finalize(statement);
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:[NSString stringWithFormat:@"getAllInsertRecords : %@", operation_type]
                                                         andRecordCount:0];
    
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:[NSString stringWithFormat:@"getAllInsertRecords : %@", operation_type]
                                                                      andRecordCount:0];

    
    return array;
}

//Sync_Override
-(void) insertdataIntoTrailerTableForRecord:(NSString *)local_id SF_id:(NSString *)sf_id record_type:(NSString *)record_type operation:(NSString *)operation object_name:(NSString *)object_name  sync_flag:(NSString *)sync  parentObjectName:(NSString *)parentObjectName parent_loacl_id:(NSString *)parent_local_id webserviceName:(NSString *)webservice_name className:(NSString *)class_name synctype:(NSString *)sync_type headerLocalId:(NSString *)header_localId requestData:(NSMutableDictionary *)request_data finalEntry:(BOOL)isFinalCustomEntry
{
    
    NSDate * date = [NSDate date];
    NSString * today_Date = @"";
    NSDateFormatter * dateFormatter  = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    today_Date = [dateFormatter stringFromDate:date];
    
    //krishna 23-1 memory opt 9493
    [dateFormatter release];
    dateFormatter = nil;
    
    BOOL ischild =  [appDelegate.databaseInterface IsChildObject:object_name];
    
    NSString * temp_record_type = @"";
    
    if(ischild)
    {
        temp_record_type = DETAIL;
    }
    else
    {
        temp_record_type = MASTER;
    }
	
	////Sync_Override check if colunm exists (Backward Compatibility)
	BOOL columnExists = [self checkColumnExists:@"webservice_name" tableName:SFDATATRAILER];
    
    NSString * insert_statement;
	
	if (columnExists)
	{
		if ([sync_type isEqualToString:CUSTOMSYNC] && (!isFinalCustomEntry))
		{
			[self fillSyncRecordDictForRecordType:record_type SF_Id:sf_id local_id:local_id operation_type:operation final_dictionary:request_data object_naem:object_name parent_object_name:parentObjectName parent_local_id:header_localId];
			return;
		}
		
		else if (isFinalCustomEntry && [sync_type isEqualToString:CUSTOMSYNC]) // #6963
		{
            appDelegate.data_sync_type = CUSTOM_DATA_SYNC;
            
            // Mem_leak_fix - Vipindas 9493 Jan 18
			NSString * requestId = [[AppDelegate GetUUID] retain];
			
			SBJsonWriter * jsonWriter = [[SBJsonWriter alloc] init];
			
			NSString * requestJsonString = [jsonWriter stringWithObject:request_data];
			
			[jsonWriter release];
			
			insert_statement = [NSString stringWithFormat:@"INSERT INTO '%@'(local_id, object_name, sf_id, parent_object_name, header_localId, request_id, request_data, webservice_name, class_name, sync_type, timestamp, operation) VALUES ('%@' , '%@' , '%@' , '%@' , '%@' ,'%@', '%@', '%@','%@', '%@', '%@', '%@' )", SFDATATRAILER, local_id, object_name, sf_id, parentObjectName, header_localId, requestId, requestJsonString, webservice_name, class_name, sync_type, today_Date, CUSTOMSYNC];
            
            [requestId release];
		}
		
		else
		{
            //Shravya-8282 if request data is not empty and sync_type = delete  , add request data for data trailer table
            if ([operation isEqualToString:DELETE] && [request_data count] > 0) {
                
                SBJsonWriter * jsonWriter = [[SBJsonWriter alloc] init];
                NSString * requestJsonString = [jsonWriter stringWithObject:request_data];
                [jsonWriter release];
                
                insert_statement = [NSString stringWithFormat:@"INSERT INTO '%@' (local_id ,sf_id ,record_type, operation, object_name, sync_flag, parent_object_name, parent_local_id,timestamp,record_sent, webservice_name, class_name, sync_type, header_localId,request_data) VALUES ('%@' , '%@' , '%@' , '%@' , '%@' ,'%@', '%@', '%@','%@','false', '%@', '%@', '%@', '%@','%@')",SFDATATRAILER,local_id , sf_id , temp_record_type, operation ,object_name , sync, parentObjectName, parent_local_id,today_Date, webservice_name, class_name, sync_type, header_localId,requestJsonString];
                
            }
            else{
                insert_statement = [NSString stringWithFormat:@"INSERT INTO '%@' (local_id ,sf_id ,record_type, operation, object_name, sync_flag, parent_object_name, parent_local_id,timestamp,record_sent, webservice_name, class_name, sync_type, header_localId) VALUES ('%@' , '%@' , '%@' , '%@' , '%@' ,'%@', '%@', '%@','%@','false', '%@', '%@', '%@', '%@')",SFDATATRAILER,local_id , sf_id , temp_record_type, operation ,object_name , sync, parentObjectName, parent_local_id,today_Date, webservice_name, class_name, sync_type, header_localId];
            }
		}
	}
	else
	{
		insert_statement = [NSString stringWithFormat:@"INSERT INTO '%@' (local_id ,sf_id ,record_type, operation, object_name, sync_flag, parent_object_name, parent_local_id,timestamp,record_sent) VALUES ('%@' , '%@' , '%@' , '%@' , '%@' ,'%@', '%@', '%@','%@','false')",SFDATATRAILER,local_id , sf_id , temp_record_type, operation ,object_name , sync, parentObjectName, parent_local_id,today_Date];
	}
        
    char * err;
    
    [appDelegate.dataBase beginTransaction];
    
    if(synchronized_sqlite3_exec(appDelegate.db, [insert_statement UTF8String],NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"%@", insert_statement);
		SMLog(kLogLevelError,@"METHOD: insertdataIntoTrailerTableForRecord");
        SMLog(kLogLevelError,@"ERROR IN INSERTING %s", err);
        /*
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:insert_statement type:INSERTQUERY];
         */
    }
    
    [appDelegate.dataBase endTransaction];
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
         synchronized_sqlite3_finalize(statement);
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
        
        synchronized_sqlite3_finalize(statement);
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
                    //7931
                    NSString *lowerCaseType = [field_data_type lowercaseString];
                    if ([lowerCaseType isEqualToString:@"multipicklist"]) {
                        
                        [dict setValue:@"" forKey:field];
                    }
                    
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
     [appDelegate.dataBase beginTransaction];
    NSString * update_statement = [NSString stringWithFormat:@"UPDATE '%@' SET record_sent = 'true' WHERE local_id = '%@' and operation = '%@' " ,SFDATATRAILER_TEMP , local_id , operationType];
    
    char * err ;
    if(synchronized_sqlite3_exec(appDelegate.db, [update_statement UTF8String], nil, nil, &err) != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"%@", update_statement);
		SMLog(kLogLevelError,@"METHOD:updateDataTrailer_RecordSentForlocalId " );
		SMLog(kLogLevelError,@"ERROR IN UPDATING %s", err);
        /*
		[appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:update_statement type:UPDATEQUERY];
         */
    }
    [appDelegate.dataBase endTransaction];
}

-(void)copyTrailerTableToTempTrailerForOperationType:(NSString *)operation_type
{
    
    [appDelegate.dataBase beginTransaction];
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:[NSString stringWithFormat:@"copyTrailerTableToTempTrailerForOperationType : %@", operation_type]
                                                         andRecordCount:0];
    
    NSString * query = [NSString stringWithFormat:@"INSERT INTO '%@' (timestamp ,  local_id , sf_id ,  record_type ,  operation ,  object_name ,  sync_flag  ,  parent_object_name   , parent_local_id   ,  record_sent )   SELECT timestamp ,  local_id , sf_id ,  record_type ,  operation ,  object_name ,  sync_flag  ,  parent_object_name   , parent_local_id   ,  record_sent  from  '%@' WHERE operation = '%@'",SFDATATRAILER_TEMP,SFDATATRAILER,operation_type];
    
    char * err ;
    if(synchronized_sqlite3_exec(appDelegate.db, [query UTF8String], nil, nil, &err) != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"%@", query);
		SMLog(kLogLevelError,@"METHOD: copyTrailerTableToTempTrailerForOperationType");
        SMLog(kLogLevelError,@"ERROR IN INSERTING %s", err);
        /*
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:query type:INSERTQUERY];
         */
    }
    
    [appDelegate.dataBase endTransaction];
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:[NSString stringWithFormat:@"copyTrailerTableToTempTrailerForOperationType : %@", operation_type]
                            andRecordCount:0];
    
}


// Vipin-db-optmz -rm
- (void)getRecordCountForTable:(NSString *) tableName
{
    
    int count = 0;
    sqlite3_stmt * stmt;
    
    NSString * query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM '%@'", tableName];
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            int temp_count = synchronized_sqlite3_column_int(stmt, 0);
            count = temp_count;
        }
    }else{
        SMLog(kLogLevelError,@" DEL cleartable  Failure getRecordCountForTable  - %@ ",tableName);
    }
    
    synchronized_sqlite3_finalize(stmt);
    
    SMLog(kLogLevelVerbose,@" DEL cleartable - %@   -%d",tableName, count);
    [[PerformanceAnalytics sharedInstance] addDeletedRecordsNumber:count];
    
}

-(void)cleartable:(NSString *)table_name
{
    // Vipin-db-optmz -rm
    SMLog(kLogLevelVerbose,@" DEL cleartable - %@",table_name);
    
    [self getRecordCountForTable:table_name];
    
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:[NSString stringWithFormat:@"cleartable : %@", table_name]
                                                         andRecordCount:0];
    
    
    char * err;
    NSString *  queryStatemnt = [NSString stringWithFormat:@"DELETE FROM  '%@'", table_name];
    if (synchronized_sqlite3_exec(appDelegate.db, [queryStatemnt UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
		SMLog(kLogLevelError,@"%@", queryStatemnt);
		SMLog(kLogLevelError,@"METHOD:cleartable");
		SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
		[appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:queryStatemnt type:DELETEQUERY];
    }
     
     // Vipin-db-optmz
     [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:[NSString stringWithFormat:@"cleartable : %@", table_name]
                                                                       andRecordCount:0];
     
}

//unused 
-(NSMutableArray *) getAllSyncRecordsFromSYNCHeap
{
    NSArray * keys = [NSArray arrayWithObjects:@"sf_id",@"local_id", @"object_name",@"json_record",@"record_type",@"sync_type" ,nil];
    NSString  * sql = [NSString stringWithFormat:@"SELECT sf_id ,local_id, object_name , json_record ,record_type,sync_type FROM 'sync_Records_Heap'  where sync_flag = 'true'"];
    sqlite3_stmt * statement ;
    NSString  * local_id = nil , *sf_id = nil, * object_name = nil , * json_record = nil , * record_type = nil, *sync_type = nil;
    @try{
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
            dict = nil;
                      
        }
    }
        synchronized_sqlite3_finalize(statement);
   }@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name databaseInterfaceSfm :getAllSyncRecordsFromSYNCHeap %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason databaseInterfaceSfm :getAllSyncRecordsFromSYNCHeap %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
    return nil;
}

-(NSArray *)getAllObjectsFromHeap
{
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"getAllObjectsFromHeap"
                                                         andRecordCount:1];

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
    
    synchronized_sqlite3_finalize(statement);
    
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"getAllObjectsFromHeap"
                                                                      andRecordCount:1];
    
    
    return array;
}

-(NSMutableDictionary *)getAllFieldsAndItsDataTypesForObject:(NSString *)object_api_name tableName:(NSString *)tableName
{
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:[NSString stringWithFormat:@"getAllFieldsAndItsDataTypesForObject : %@", object_api_name]
                                                         andRecordCount:0];
    
    
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
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:[NSString stringWithFormat:@"getAllFieldsAndItsDataTypesForObject : %@", object_api_name]
                                                                      andRecordCount:1];
    
    
    return dict;
}

-(void)updateSyncRecordsIntoLocalDatabase
{
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"updateSyncRecordsIntoLocalDatabase"
                                                         andRecordCount:1];
    
    
    NSArray * objects_names = [self getAllObjectsFromHeap];
    
    [appDelegate.dataBase beginTransaction];
    
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
        
        int prepare_ = synchronized_sqlite3_prepare_v2(appDelegate.db, [query_string UTF8String], strlen([query_string UTF8String]), &bulk_statement, NULL);
        
        // Vipin-db-optmz 2
        NSMutableDictionary *parentColumnToObjectNameDict = [[NSMutableDictionary alloc] initWithCapacity:0];
        
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
                    
                    // Mem_leak_fix - Vipindas 9493 Jan 18
                    NSString * new_local_id = [[AppDelegate GetUUID] retain];
                    
                    NSString * parent_column_name = @"";
                    if([record_type isEqualToString:MASTER])
                    {
                        //jst update 
                    }
                    else if ([record_type isEqualToString:DETAIL])
                    {
                        
                        parent_column_name = [parentColumnToObjectNameDict objectForKey:object_Name];
                        
                        if ( parent_column_name == nil)
                        {
                            // Good Chance
                            parent_column_name = [self getchildInfoFromChildRelationShip:SFCHILDRELATIONSHIP ForChild:object_Name field_name:@"parent_column_name"];
                            
                            [parentColumnToObjectNameDict setObject:parent_column_name forKey:object_Name];
                        }
                    }
                    
                    //memory suspect
                    NSMutableDictionary * final_dict = [self getDictForJsonString:json_record];
                    if([object_Name isEqualToString:@"Attachment"])
                    {
                        NSString *name = [final_dict objectForKey:@"Name"];
                        if ([name Contains:@"_sign.png"]){
                            NSLog(@"%@",name);
                            continue;
                        }
                    }
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
                                 if ([parent_local_id length] > 0) {
                                     [final_dict setObject:parent_local_id forKey:parent_column_name];  //008637
                                 }
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
                             //SUCCESSIVE_SYNC - overide update to DB after TxFetch
                            [self overrideResponseData:final_dict ForsfId:sf_id ObjectName:object_Name];
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
                                SMLog(kLogLevelError,"Commit Failed!\n");
								SMLog(kLogLevelError,@"%@", query_string);
								SMLog(kLogLevelError,@"METHOD: updateSyncRecordsIntoLocalDatabase");
                            }
                            sqlite3_clear_bindings(bulk_statement);
                            sqlite3_reset(bulk_statement);
                             [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:count];
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
                                SMLog(kLogLevelError,@"Failed to delete location record");
                            }
                        }
                        else
                        {
                            update_flag = [self UpdateTableforId:local_id forObject:object_Name data:final_dict];
                        }                        
                    }
                    
                    if([sync_type isEqualToString:GET_INSERT] || [sync_type isEqualToString:GET_UPDATE] )
                    {
                        // Fix for PB 
//                        [self deleteAllOndemandRecordsPartOfDownloadCriteriaForSfId:sf_id];
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
                            SMLog(kLogLevelError,@" failed! trailer table Delete Not succeded");
                        }
                    }
                    count++;
                    
                    [final_dict release];
                    [new_local_id release];
                    SMLog(kLogLevelVerbose,@"Record %d" ,count );
                    [autorelease release];
                }
            }
        }
        synchronized_sqlite3_finalize(bulk_statement);
        
        // Vipin-db-optmz 2
        [parentColumnToObjectNameDict release];
        parentColumnToObjectNameDict = nil;
        
        
        synchronized_sqlite3_finalize(statement);
    }
    

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
                SMLog(kLogLevelVerbose,@"parent_obj_name = %@", parent_obj_name );
                NSString * parent_column_name = [self getchildInfoFromChildRelationShip:SFCHILDRELATIONSHIP ForChild:temp_child_object_name field_name:@"parent_column_name"];
                [parent_obejct_dict setValue:parent_obj_name forKey:temp_child_object_name];
                [parent_column_dict setValue:parent_column_name forKey:temp_child_object_name];
            }
            
        }
    }
    synchronized_sqlite3_finalize(statement);
    
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
    
    [self updateSuccessiveSyncRecordsAfterTxFetch];
    
    // Vipin-db-optmz
    [appDelegate.dataBase endTransaction];
    
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"updateSyncRecordsIntoLocalDatabase"
                                                                      andRecordCount:0];
    
}

/* Updates the parent column to parent local id  :InitialSync-shr */
- (void)updatesfmIdsOfMasterToLocalIds {
    
    // Vipin-db-optmz
    [appDelegate.dataBase beginTransaction];
    
    
    /* Get the parent-child releation ships for the detail records :InitialSync-shr*/
    NSMutableDictionary * parent_obejct_dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSMutableDictionary * parent_column_dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    sqlite3_stmt *statement = nil;
    NSString  * getObjects_sql = [[NSString alloc ]initWithFormat:@"SELECT DISTINCT object_name  FROM 'sync_Records_Heap'  where sync_flag = 'true'  AND record_type = 'DETAIL'"];
    
    NSString * temp_child_object_name = @"";
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"sync_Records_Heap - DISTINCT object names"
                                                         andRecordCount:0];
    
    int counter = 0;

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
                SMLog(kLogLevelVerbose,@"parent_obj_name = %@", parent_obj_name );
                NSString * parent_column_name = [self getchildInfoFromChildRelationShip:SFCHILDRELATIONSHIP ForChild:temp_child_object_name field_name:@"parent_column_name"];
                [parent_obejct_dict setValue:parent_obj_name forKey:temp_child_object_name];
                [parent_column_dict setValue:parent_column_name forKey:temp_child_object_name];
                
                 counter = counter +1;
            }
            
        }
    }
    /*Mem Opt*/
    [getObjects_sql release];
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"sync_Records_Heap - DISTINCT object names"
                                                         andRecordCount:counter];
    
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"sync_Records_Heap - DISTINCT object names"
                                                                      andRecordCount:0];
    
    synchronized_sqlite3_finalize(statement);
    
    
    /*  Updating the local ids from master :InitialSync-shr*/
    
    statement = nil;
    NSString *local_id = @"",*sf_id = @"", *object_Name = @"" ,  *json_record = @"" ,  *record_type = @"", *sync_type = @"";
    
    NSString  * sql2 = [NSString stringWithFormat:@"SELECT sf_id, object_name,sync_type FROM 'sync_Records_Heap'  where sync_flag = 'true'  AND record_type = 'DETAIL' and sync_type = 'DATA_SYNC'"];
    
    counter = 0;
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"sync_Records_Heap - Field selection"
                                                         andRecordCount:counter];
    
    
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
            
            char * temp_object_name = (char *) synchronized_sqlite3_column_text(statement, 1);
            if(temp_object_name != nil)
            {
                object_Name = [NSString stringWithUTF8String:temp_object_name];
            }
            
            char * temp_sync_type = (char *) synchronized_sqlite3_column_text(statement, 2);
            if(temp_sync_type != nil)
            {
                sync_type = [NSString stringWithUTF8String:temp_sync_type];
            }
            
            if( sf_id != nil && [sf_id length] > 3)
            {
                    NSString *parent_obj_name = [parent_obejct_dict objectForKey:object_Name];
                    NSString * parent_column_name1 = [parent_column_dict objectForKey:object_Name];
                
                // Vipin-db-optmz
                [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"getParentLocalIdForChildSFID"
                                                                     andRecordCount:0];
                
                
                    
                    NSString * parent_local_id = [self getParentLocalIdForChildSFID:sf_id parentObject_name:parent_obj_name parent_column_name:parent_column_name1 child_object_name:object_Name];
                
                // Vipin-db-optmz
                [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"getParentLocalIdForChildSFID"
                                                                     andRecordCount:1];
                
                [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"getParentLocalIdForChildSFID"
                                                                                  andRecordCount:0];
                
                    
                    if([parent_local_id length] > 0)
                    {
                        [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"updateParentColumnNameInChildTableWithParentLocalId"
                                                                             andRecordCount:0];
                        
                        
                        [self updateParentColumnNameInChildTableWithParentLocalId:object_Name
                                                               parent_column_name:parent_column_name1
                                                                  parent_local_id:parent_local_id
                                                                      child_sf_id:sf_id];
                        
                        [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"updateParentColumnNameInChildTableWithParentLocalId"
                                                                             andRecordCount:1];
                        
                        [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"updateParentColumnNameInChildTableWithParentLocalId"
                                                                                          andRecordCount:0];
                    }
                counter = counter +1;
            }
        }
    }
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"sync_Records_Heap - Field selection"
                                                         andRecordCount:counter];
    
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"sync_Records_Heap - Field selection"
                                                                      andRecordCount:0];
    
    [appDelegate.dataBase endTransaction];
    synchronized_sqlite3_finalize(statement);
    /*Mem Opt*/
    [parent_obejct_dict release];
    [parent_column_dict release];
    
}

-(void)InsertInto_User_created_event_for_local_id:(NSString *)local_id sf_id:(NSString *)sf_id
{
    [appDelegate.dataBase beginTransaction];
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"InsertInto_User_created_event_for_local_id"
                                                         andRecordCount:1];

    
    NSString * version = [appDelegate serverPackageVersion];
	int _stringNumber = [version intValue];
    
    if(_stringNumber >=  (KMinPkgForScheduleEvents * 100000))
    {
        NSDate * date = [NSDate date];
        NSString * today_Date = @"";
        NSDateFormatter * dateFormatter  = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        today_Date = [dateFormatter stringFromDate:date];
        
        //krishna 23-1 memory opt 9493
        [dateFormatter release];
        dateFormatter = nil;
        NSString * insert_query = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ ('object_name','sf_id','time_stamp','local_id') VALUES ('%@','%@','%@','%@')" , User_created_events,@"Event",sf_id,today_Date,local_id ];
        char * err;
        
        if(synchronized_sqlite3_exec(appDelegate.db, [insert_query UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
            SMLog(kLogLevelError,@"Insert Failed");
            SMLog(kLogLevelError,@"METHOD:InsertInto_User_created_event_for_local_id " );
            SMLog(kLogLevelError,@"ERROR IN INSERTING %s", err);
            [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:insert_query type:INSERTQUERY];
        }
        [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:1];
    }
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"InsertInto_User_created_event_for_local_id"
                                                                      andRecordCount:0];
    
    [appDelegate.dataBase endTransaction];

}

-(void)updatedataTrailerTAbleForLocal_id:(NSString *)local_id  sf_id:(NSString *)sf_id
{
    // Vipin-db-optmz
    
    [appDelegate.dataBase beginTransaction];
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"updatedataTrailerTAbleForLocal_id"
                                                         andRecordCount:1];

    
    char * err ;
    NSString * updateStatement = [NSString stringWithFormat:@"UPDATE '%@' SET %@ = '%@'  WHERE (local_id = '%@' )", SFDATATRAILER, @"sf_id" , sf_id,local_id ];
    
    if (synchronized_sqlite3_exec(appDelegate.db, [updateStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"%@", updateStatement);
		SMLog(kLogLevelError,@"METHOD:updatedataTrailerTAbleForLocal_id " );
		SMLog(kLogLevelError,@"ERROR IN UPDATING %s", err);
        /*
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:updateStatement type:UPDATEQUERY];
         */

    }
    
    [appDelegate.dataBase endTransaction];
    
    [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:1];
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"updatedataTrailerTAbleForLocal_id"
                                                                      andRecordCount:0];
}


-(void)updateParentColumnNameInChildTableWithParentLocalId:(NSString *)child_objectName
                                        parent_column_name:(NSString *)parent_column_name
                                           parent_local_id:(NSString *)parent_local_id
                                              child_sf_ids:(NSArray *)child_sfIds
{
    
    //NSString * updateStatement = [NSString stringWithFormat:@"UPDATE '%@' SET %@ = '%@'  WHERE Id = '%@'", child_objectName,parent_column_name , parent_local_id ,child_sfId];
    
    [appDelegate.dataBase beginTransaction];
    
    NSString * updateStatement = [NSString stringWithFormat:@"UPDATE '%@' SET %@ = '%@'  WHERE Id = ?1", child_objectName,parent_column_name , parent_local_id];
    
    sqlite3_stmt * bulkStmt;
    
    @try {
        
        int ret_val = synchronized_sqlite3_prepare_v2(appDelegate.db, [updateStatement UTF8String], strlen([updateStatement UTF8String]),  &bulkStmt, NULL);
        
        if (ret_val == SQLITE_OK)
        {
            for (NSString * childSFId in  child_sfIds)
            {
                char * _sf_id = [appDelegate convertStringIntoChar:childSFId];
                sqlite3_bind_text(bulkStmt, 1, _sf_id, strlen(_sf_id), SQLITE_TRANSIENT);
                
                if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                {
                    SMLog(kLogLevelError,@"Failure updateParentColumnNameInChildTableWithParentLocalId - updateStatement => %@", updateStatement);
                }
                else
                {
                    SMLog(kLogLevelVerbose,@" Success updateParentColumnNameInChildTableWithParentLocalId - updateStatement => %@", updateStatement);
                }
                
                sqlite3_clear_bindings(bulkStmt);
                sqlite3_reset(bulkStmt);
            }
            
            [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:[child_sfIds count]];
        }
        
    }@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Reason databaseInterfaceSfm :updateParentColumnNameInChildTableWithParentLocalId name : %@ \n reason : %@",exp.name ,exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
    
    synchronized_sqlite3_finalize(bulkStmt);
    [appDelegate.dataBase endTransaction];
    
    
}


-(void)updateParentColumnNameInChildTableWithParentLocalId:(NSString *)child_objectName
                                        parent_column_name:(NSString *)parent_column_name
                                           parent_local_id:(NSString *)parent_local_id
                                               child_sf_id:(NSString *)child_sfId
{
    // Vipin-db-optmz
    
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"updateParentColumnNameInChildTable"
                                                         andRecordCount:1];
    
    
    [appDelegate.dataBase beginTransaction];
    
    NSString * updateStatement = [NSString stringWithFormat:@"UPDATE '%@' SET %@ = '%@'  WHERE Id = ?1", child_objectName,parent_column_name , parent_local_id];
    
    sqlite3_stmt * bulkStmt;
    
    @try {
        
        int ret_val = synchronized_sqlite3_prepare_v2(appDelegate.db, [updateStatement UTF8String], strlen([updateStatement UTF8String]),  &bulkStmt, NULL);
        
        if (ret_val == SQLITE_OK)
        {
            char * _sf_id = [appDelegate convertStringIntoChar:child_sfId];
            sqlite3_bind_text(bulkStmt, 1, _sf_id, strlen(_sf_id), SQLITE_TRANSIENT);
            
            if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
            {
                SMLog(kLogLevelError,@"Failure updateParentColumnNameInChildTableWithParentLocalId - updateStatement => %@", updateStatement);
            }
            else
            {
                // SMLog(kLogLevelVerbose,@"Success updateParentColumnNameInChildTableWithParentLocalId - updateStatement => %@", updateStatement);
            }
            
            sqlite3_clear_bindings(bulkStmt);
            sqlite3_reset(bulkStmt);
        }
        
    }@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name databaseInterfaceSfm :updateParentColumnNameInChildTableWithParentLocalId %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason databaseInterfaceSfm :updateParentColumnNameInChildTableWithParentLocalId %@",exp.reason);
        SMLog(kLogLevelError,@"Exception Reason databaseInterfaceSfm :updateParentColumnNameInChildTableWithParentLocalId %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
    
    synchronized_sqlite3_finalize(bulkStmt);
    [appDelegate.dataBase endTransaction];
    
    [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:1];
    
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"updateParentColumnNameInChildTable"
                                                                      andRecordCount:0];
    
    
    
    /*
    char * err ;
    NSString * updateStatement = [NSString stringWithFormat:@"UPDATE '%@' SET %@ = '%@'  WHERE Id = '%@'", child_objectName,parent_column_name , parent_local_id ,child_sfId];
    
    if (synchronized_sqlite3_exec(appDelegate.db, [updateStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
		SMLog(kLogLevelVerbose,@"%@", updateStatement);
		SMLog(kLogLevelVerbose,@"METHOD:updateParentColumnNameInChildTableWithParentLocalId " );
		SMLog(kLogLevelVerbose,@"ERROR IN UPDATING %s", err);
        
       // [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:updateStatement type:UPDATEQUERY];
         

    }
     */
}

-(NSString *)getParentLocalIdForChildSFID:(NSString *)childSF_Id parentObject_name:(NSString *)parentObjectName parent_column_name:(NSString *)parent_column_name child_object_name:(NSString *)child_obj_name  
{
    
    // Vipin-db-optmz
    
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"getParentLocalIdForChildSFID"
                                                         andRecordCount:1];
    
    
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
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"getParentLocalIdForChildSFID"
                                                                      andRecordCount:0];
    
    return paren_local_id;
}


-(NSString *) getchildInfoFromChildRelationShip:(NSString * )tableName  ForChild:(NSString *)child_table  field_name:(NSString *)field_name
{
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:[NSString  stringWithFormat:@"getchildInfoFromChildRelationShip - %@ - %@", tableName, child_table]
                                                         andRecordCount:1];
    
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
    
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:[NSString  stringWithFormat:@"getchildInfoFromChildRelationShip - %@ - %@", tableName, child_table]
                                                         andRecordCount:0];
    
    
    return fieldName;

}

-(BOOL)DeleteDataTrailerTableAfterSync:(NSString *)local_id forObject:(NSString *)object  sync_type:(NSString *)sync_type
{
    // Vipin-db-optmz -rm
    SMLog(kLogLevelVerbose,@" DEL DeleteDataTrailerTableAfterSync - %@",object);
    
    
    BOOL success = YES;
    
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:[NSString stringWithFormat:@"DeleteDataTrailerTableAfterSync : %@", object]
                                                         andRecordCount:0];
    
    
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
		SMLog(kLogLevelError,@"%@", update);
		SMLog(kLogLevelError,@"METHOD:DeleteDataTrailerTableAfterSync");
		SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:update type:DELETEQUERY];

        success = NO;
    }
    
    [[PerformanceAnalytics sharedInstance] addDeletedRecordsNumber:1];
    
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:[NSString stringWithFormat:@"DeleteDataTrailerTableAfterSync : %@", object]
                                                                      andRecordCount:1];
    return success;
}

-(NSMutableDictionary *)getDictForJsonString:(NSString *)json_record
{
    // Vipin-db-optmz -rm
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"getDictForJsonString"
                                                         andRecordCount:1];
    
    
    NSAutoreleasePool * autoreleasePool = [[NSAutoreleasePool alloc] init];
    SBJsonParser * jsonParser = [[[SBJsonParser alloc] init] autorelease];
    NSDictionary * json_dict = [jsonParser objectWithString:json_record];

    NSMutableDictionary * final_dict = [[NSMutableDictionary alloc] initWithCapacity:0]; //Vipin - 7350
    NSArray * json_allkeys = [json_dict allKeys];
    //NSInteger lookUp_id = 0;
    
    // Vipin-db-optmz
    NSMutableDictionary *apiNameForNameFieldDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSMutableArray  *lookupDictionaryArray = [[NSMutableArray alloc] init];
    // defect 8460
    @try{
    for (int f = 0; f < [json_allkeys count]; f++)
    {
        NSString * json_key = [json_allkeys objectAtIndex:f];
        id  id_type = [json_dict objectForKey:json_key];
        
        if ([id_type isKindOfClass:[NSDictionary class]])
        {
            NSString * field = [json_allkeys objectAtIndex:f];

            NSDictionary * dict = (NSDictionary *)id_type;
            NSRange range = [field rangeOfString:@"__r"];
            // defect 8460
            NSDictionary * attDict = [dict objectForKey:@"attributes"];
            NSString * object = [attDict objectForKey:@"type"];
            if (range.location != NSNotFound || [attDict count]>0 )
            {
                // defect 8460
				//RADHA 27/Sep/2012
                NSString *  objectName = [apiNameForNameFieldDict objectForKey:object];
                
                if (objectName == nil)
                {
                    objectName = [appDelegate.dataBase getApiNameForNameField:object];
                    // defect 8460
                    if (![objectName length]>0)
                    {
                        objectName=([[dict allKeys] containsObject:@"Name"])?@"Name":([[dict allKeys] containsObject:@"CaseNumber"])?@"CaseNumber":@"";
                    }
                    [apiNameForNameFieldDict setObject:objectName forKey:object];
                }
                // issue Fix #7350
				NSMutableDictionary * lookUpDict = [[NSMutableDictionary alloc] initWithCapacity:0];
                [lookUpDict setValue:[dict objectForKey:@"Id"] forKey:@"Id"];
                [lookUpDict setValue:[dict objectForKey:objectName] forKey:@"Name"];
                // defect 8460
                [lookUpDict setValue:object forKey:@"type"];
                [lookupDictionaryArray addObject:lookUpDict];
                [lookUpDict release];
                lookUpDict = nil;
               // [appDelegate.dataBase addvaluesToLookUpFieldTable:lookUpDict WithId:lookUp_id];
            }                        
        }
        else
        {
            NSString * value =  [NSString stringWithFormat:@"%@", id_type];
            [final_dict setObject:value forKey:json_key];
        }
    }
        
    // Vipin-db-optmz
    [appDelegate.dataBase addValuesToLookUpFieldTable:lookupDictionaryArray];
        
        
        
    }@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name databaseInterfaceSfm :getDictForJsonString %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason databaseInterfaceSfm :getDictForJsonString %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];    }
    @finally
    {
        [lookupDictionaryArray release];
        [apiNameForNameFieldDict release];
        [autoreleasePool release];
        
    }
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
    
    synchronized_sqlite3_finalize(stmt);
    return Id_;
}

-(NSString *)getSfid_For_LocalId_From_TrailerForlocal_id:(NSString *)local_id
{
    //sahana sat april 20 delete error
    NSString * query = [NSString stringWithFormat:@"SELECT sf_id FROM '%@' WHERE local_id = '%@' and operation = 'DELETE'" , SFDATATRAILER , local_id];
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
    
     synchronized_sqlite3_finalize(stmt);
    return Id_;
}

-(NSString *)getSfid_For_LocalId_FROM_SfHeapTable:(NSString *)local_id 
{
    NSString * query = [NSString stringWithFormat:@"SELECT sf_id FROM '%@' WHERE local_id = '%@'" , SYNC_RECORD_HEAP, local_id];
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
     synchronized_sqlite3_finalize(stmt);
    return Id_;
}


- (NSMutableDictionary *)getChildObjectRegisteredDictionary
{
    @synchronized(self)
    {
        return childInfoCacheDictionary;
    }
}

- (void)clearChildInfoCacheDictionary
{
    if (self.childInfoCacheDictionary != nil)
    {
        [self.childInfoCacheDictionary removeAllObjects];
    }
}

-(BOOL)IsChildObject:(NSString *)object_name
{
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"IsChildObject-x"
                                                         andRecordCount:1];
    
    // Load lazy
    if (self.childInfoCacheDictionary == nil)
    {
        NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
        self.childInfoCacheDictionary = tempDictionary;
        [tempDictionary release];
    }

    BOOL isChildObject = NO;
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"IsChildObject-x"
                                                                      andRecordCount:0];
    
    
    NSNumber *existObjectStatus = [self.childInfoCacheDictionary objectForKey:object_name];
    if (existObjectStatus != nil)
    {
        // Yes got from cache
        return [existObjectStatus boolValue];
    }
    
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"IsChildObject"
                                                         andRecordCount:1];
    
    
    int count = 0;
    NSAutoreleasePool * autoreleasePool = [[NSAutoreleasePool alloc] init];
    NSString * query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM '%@'  WHERE object_api_name_child = '%@'" ,SFCHILDRELATIONSHIP,object_name ];
    
    sqlite3_stmt * stmt ;
    
    SMLog(kLogLevelVerbose,@" IschildObject ----%@" , query);
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            int temp_count = synchronized_sqlite3_column_int(stmt, 0);
            count = temp_count;
        }
    }
    synchronized_sqlite3_finalize(stmt);
    [autoreleasePool release];
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"IsChildObject"
                                                                      andRecordCount:0];
    
    
    if(count == 1)
    {
        isChildObject = TRUE;
    }
    else 
    {
        isChildObject = FALSE;
    }
    
    [self.childInfoCacheDictionary setObject:[NSNumber numberWithBool:isChildObject] forKey:object_name];

    return isChildObject;
}

-(BOOL)DeleterecordFromTable:(NSString *)object_name Forlocal_id:(NSString *)local_id
{
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"DeleterecordFromTable"
                                                         andRecordCount:1];
    BOOL success = YES;
    
    // Vipin-db-optmz -rm
    SMLog(kLogLevelVerbose,@" DEL DeleterecordFromTable - %@",object_name);
    
    NSString * delete_query = [NSString stringWithFormat:@"DELETE FROM '%@' WHERE local_id = '%@'" ,object_name , local_id ];
    
    char * err ;
    if(synchronized_sqlite3_exec(appDelegate.db, [delete_query UTF8String], NULL, NULL, &err))
    {
        SMLog(kLogLevelError,@"%@", delete_query);
		SMLog(kLogLevelError,@"METHOD:DeleterecordFromTable");
		SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:delete_query type:DELETEQUERY];

        success = NO;
    }
    
    [[PerformanceAnalytics sharedInstance] addDeletedRecordsNumber:1];
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"DeleterecordFromTable"
                                                                      andRecordCount:0];
    
    return success;
}

-(void)insertSyncConflictsIntoSYNC_CONFLICT:(NSMutableDictionary *)conflictDict
{
    SMLog(kLogLevelVerbose,@"  insertSyncConflictsIntoSYNC_CONFLICT Processing starts: %@", [NSDate date]);
    
    SMLog(kLogLevelVerbose,@"[MON] insertSyncConflictsIntoSYNC_CONFLICT %d", [conflictDict count]);
    NSArray * all_objects = [conflictDict allKeys];
    @try{
        
    [appDelegate.dataBase beginTransaction];
        
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
                SMLog(kLogLevelError,@"%@", insert_query);
				SMLog(kLogLevelError,@"METHOD: insertSyncConflictsIntoSYNC_CONFLICT");
				SMLog(kLogLevelError,@"ERROR IN INSERTING %s", err);
                /*
                [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:insert_query type:INSERTQUERY];
                 */

            }
            
        }
         [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:[object_info count]];
    }
	}@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name databaseInterfaceSfm :insertSyncConflictsIntoSYNC_CONFLICT %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason databaseInterfaceSfm :insertSyncConflictsIntoSYNC_CONFLICT %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }

      [appDelegate.dataBase endTransaction];
    
    SMLog(kLogLevelVerbose,@"  insertSyncConflictsIntoSYNC_CONFLICT Processing ends: %@", [NSDate date]);
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
     synchronized_sqlite3_finalize(stmt);
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
    
    SMLog(kLogLevelVerbose,@" getAllRecords  %@", query);
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
    synchronized_sqlite3_finalize(statement);
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
     synchronized_sqlite3_finalize(stmt);
    return local_Id;
}

-(void) deleteAll_GET_DELETES_And_PUT_DELETE_From_HeapAndObject_tables:(NSString *)sync_type 
{
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:[NSString stringWithFormat:@"deleteObject_tables : %@", sync_type]
                                                         andRecordCount:0];
    
    
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
    
    synchronized_sqlite3_finalize(stmt);
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:[NSString stringWithFormat:@"deleteObject_tables : %@", sync_type]
                                                                      andRecordCount:1];
    
    
    [self deleteAllrecordsWithSF_ID:delete_list];
}

- (void) deleteAllrecordsWithSF_ID:(NSMutableDictionary *)delete_list
{
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"deleteAllrecordsWithSF_ID"
                                                         andRecordCount:0];
    
    NSMutableArray *syncRecordHeapsDeletionRecordIds = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray *trailerTableDeletionRecordIds = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray *trailerTableWithParentLocalIdDeletionRecordIds = [[NSMutableArray alloc] initWithCapacity:0];
   
    NSMutableDictionary *objectDeletionRecordIds = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    NSArray * allkeys = [delete_list allKeys];
    for (NSString * object_name in allkeys)
    {
        NSArray * deleteId = [delete_list objectForKey:object_name];
        
        for (NSString * sf_id in deleteId)
        {
            //[self DeleterecordFromTableWithSf_Id:SYNC_RECORD_HEAP sf_id:sf_id withColumn:@"sf_id"];
            //[self DeleterecordFromTableWithSf_Id:SFDATATRAILER sf_id:sf_id withColumn:@"sf_id"];
            
            [syncRecordHeapsDeletionRecordIds addObject:sf_id];
            [trailerTableDeletionRecordIds addObject:sf_id];
            
            
            //if the id is MASTER record id , for that master record id
            NSMutableArray *storedIds = [objectDeletionRecordIds  objectForKey:object_name];
            
            if (storedIds == nil)
            {
                storedIds = [NSMutableArray  arrayWithCapacity:0];
            }
            
            [storedIds addObject:sf_id];
            [objectDeletionRecordIds setObject:storedIds forKey:object_name];
            
            
            NSString * local_id = [self getLocalIdFromSFId:sf_id tableName:object_name];
            if([local_id length ]!= 0 && ![local_id isEqualToString:@""] && local_id != nil)
            {
                //[self DeleterecordFromTableWithSf_Id:SFDATATRAILER sf_id:local_id withColumn:@"parent_local_id"];
                [trailerTableWithParentLocalIdDeletionRecordIds addObject:local_id];
            }
            
            //if the id is MASTER record id , for that master record id
            //[self DeleterecordFromTableWithSf_Id:object_name sf_id:sf_id withColumn:@"Id"];
        }
    }
    
   
    [self deleteRecordFromTable:SYNC_RECORD_HEAP
              byCollectionsOfId:syncRecordHeapsDeletionRecordIds
                      forColumn:@"sf_id"];
    
    [self deleteRecordFromTable:SFDATATRAILER
              byCollectionsOfId:trailerTableDeletionRecordIds
                      forColumn:@"sf_id"];
    
    [self deleteRecordFromTable:SFDATATRAILER
              byCollectionsOfId:trailerTableWithParentLocalIdDeletionRecordIds
                      forColumn:@"parent_local_id"];
    
    [syncRecordHeapsDeletionRecordIds release];
    [trailerTableDeletionRecordIds release];
    [trailerTableWithParentLocalIdDeletionRecordIds release];

    
    NSArray *allKeys = [objectDeletionRecordIds allKeys];
    
    for (NSString *objectName in allKeys)
    {
        
        if ([objectDeletionRecordIds objectForKey:objectName] != nil)
        {
            [self deleteRecordFromTable:objectName
                      byCollectionsOfId:[objectDeletionRecordIds objectForKey:objectName]
                              forColumn:@"Id"];
        }
    }
    
    [objectDeletionRecordIds release];
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"deleteAllrecordsWithSF_ID"
                                                                      andRecordCount:[allkeys count]];
    
}

- (void)deleteRecordFromTable:(NSString *)tableName byCollectionsOfId:(NSArray *)ids forColumn:(NSString *)columnName
{
    
    SMLog(kLogLevelVerbose,@"deleteRecordFromTable  %@  -  %d", tableName, [ids count] );
    if (ids == nil || [ids count] == 0)
    {

        // Hey I m going back!
        return;
    }
    
    // Vipin-db-optmz -rm
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:[NSString stringWithFormat:@"deleteRecordFromTable :%@ ", tableName]
                                                         andRecordCount:[ids count]];
    
    NSString * delete_query = @"";
    
    NSString *idSeparetedByComas = nil;
    
    if ([ids count] > 1)
    {
       NSString *baseString = [ids componentsJoinedByString:@"','"];
       idSeparetedByComas = [NSString stringWithFormat:@"'%@'", baseString];
    }
    else
    {
        idSeparetedByComas =idSeparetedByComas = [NSString stringWithFormat:@"'%@'", [ids objectAtIndex:0]];
    }
    
    //sync_override
    if([tableName isEqualToString:SFDATATRAILER])
    {
        delete_query = [NSString stringWithFormat:@"DELETE FROM '%@' WHERE %@ in ( %@ ) and sync_type != '%@' " , tableName, columnName, idSeparetedByComas, CUSTOMSYNC];
    }
    else
    {
        delete_query = [NSString stringWithFormat:@"DELETE FROM '%@' WHERE %@ in ( %@ )" ,tableName, columnName, idSeparetedByComas];
    }
    
    SMLog(kLogLevelVerbose,@"delete_query - - %@",delete_query);
    char * err ;
    int executionResult  = synchronized_sqlite3_exec(appDelegate.db, [delete_query UTF8String], NULL, NULL, &err);

    if( executionResult != SQLITE_OK)
    {
        SMLog(kLogLevelVerbose,@" Failed deleteRecordFromTable error code - %d \n  messge : %s \n query : %@", executionResult, err, delete_query);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:delete_query type:DELETEQUERY];
    }
    
    [[PerformanceAnalytics sharedInstance] addDeletedRecordsNumber:[ids count]];
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:[NSString stringWithFormat:@"deleteRecordFromTable :%@ ", tableName]
                                                                      andRecordCount:0];
    
}


-(void) DeleterecordFromTableWithSf_Id:(NSString *)object_name sf_id:(NSString *)sf_id withColumn:(NSString *)columnName
{
    
    // Vipin-db-optmz -rm
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:[NSString stringWithFormat:@"DeleterecordFromTableWithSf_Id :%@ - %@",object_name, columnName]
                                                         andRecordCount:1];
    
    NSString * delete_query = @"";
    //sync_override
    if([object_name isEqualToString:SFDATATRAILER])
    {
        delete_query = [NSString stringWithFormat:@"DELETE FROM '%@' WHERE %@ = '%@' and sync_type != '%@' " ,object_name, columnName, sf_id,CUSTOMSYNC];
    }
    else
    {
        delete_query = [NSString stringWithFormat:@"DELETE FROM '%@' WHERE %@ = '%@'" ,object_name, columnName, sf_id];
    }
    SMLog(kLogLevelVerbose,@"delete_query - - %@",delete_query);
    char * err ;
    if(synchronized_sqlite3_exec(appDelegate.db, [delete_query UTF8String], NULL, NULL, &err))
    {
        SMLog(kLogLevelError,@"%@", delete_query);
		SMLog(kLogLevelError,@"METHOD:DeleterecordFromTableWithSf_Id");
		SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:delete_query type:DELETEQUERY];

    }
    
    [[PerformanceAnalytics sharedInstance] addDeletedRecordsNumber:1];
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:[NSString stringWithFormat:@"DeleterecordFromTableWithSf_Id :%@ - %@",object_name, columnName]
                                                                      andRecordCount:0];
    
}

-(void)deleteAllConflictedRecordsFrom:(NSString *)tableName
{
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"deleteAllConflictedRecordsFrom"
                                                         andRecordCount:1];
    
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

    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"deleteAllConflictedRecordsFrom"
                                                                      andRecordCount:0];
}


-(NSMutableArray *)getAllRecordsFromConflictTableForOperationType:(NSString *)operation_type  
{
    NSMutableArray * array = [[NSMutableArray  alloc] initWithCapacity:0];
    NSArray * keys = [NSArray arrayWithObjects:@"local_id" ,@"object_name" , @"record_type" ,@"sf_id",@"override_flag",nil];
    
    sqlite3_stmt * statement;
    NSString * query ;

    query  = [NSString stringWithFormat:@"SELECT  local_id , object_name , record_type, sf_id ,override_flag FROM '%@' WHERE sync_type = '%@'   " ,SYNC_ERROR_CONFLICT , operation_type ];
    
    NSString * local_id = @"", * object_name = @""  , * record_type = @"" , * sf_id = @"" , * override_flag = @"" ;
    
    SMLog(kLogLevelVerbose,@" getAllRecords  %@", query);
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
    
    synchronized_sqlite3_finalize(statement);
    
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
    
    synchronized_sqlite3_finalize(stmt);
    
    if (count > 0)
        return TRUE;
    else 
        return FALSE;
}

-(void)deleterecordsFromConflictTableForOperationType:(NSString *)opeation_type overrideFlag:(NSString *)override_flag  table_name:(NSString *)table_name   id_value:(NSString *)id_   field_name:(NSString *)field_name 
{
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:[NSString stringWithFormat:@"deleterecordsFromConflictTable : %@", opeation_type]
                                                         andRecordCount:0];
    
    
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
        SMLog(kLogLevelError,@"%@", delete_stmt);
		SMLog(kLogLevelError,@"METHOD:deleterecordsFromConflictTableForOperationType");
		SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:delete_stmt type:DELETEQUERY];

    }
    
    [[PerformanceAnalytics sharedInstance] addDeletedRecordsNumber:1];
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:[NSString stringWithFormat:@"deleterecordsFromConflictTable : %@", opeation_type]
                                                                      andRecordCount:0];

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
    
    synchronized_sqlite3_finalize(statement);
    
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
    NSMutableArray * describeObjects = [self getAllobjectsApiNameFromSFObjectField];
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

    synchronized_sqlite3_finalize(statement);
    
    return [objects_list autorelease];
}

-(void)didDescribeSObjects:(NSMutableArray *)result error:(NSError *)error context:(id)context
{
    [result retain];
    
    if(error != nil)
    {
        appDelegate.connection_error = TRUE;
        return;
    }
    
    // Vipin-db-optmz
    [appDelegate.dataBase beginTransaction];
    
    
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
            
            //5878: Aparna: Commented the block of code
            /*if ([type isEqualToString:@"multipicklist"])
			{
				if ([field_api_name isEqualToString:@"multipicklist_multiplelenght__c"])
				{
					SMLog(kLogLevelVerbose,@"STOP");
				}
				NSArray * multipickListEntryArray = [field_describe picklistValues];
				
                for (int k = 0; k < [multipickListEntryArray count]; k++)
                {
					
                    NSString * value = [[multipickListEntryArray objectAtIndex:k] value];
                    
                    [self UpdateSFPicklistForMultiSelect_IndexValue_For_Oject_Name:object_name field_api_name:field_api_name value:value index:k];
                }
			}*/
			
            if([type isEqualToString:@"picklist"] || [type isEqualToString:@"multipicklist"])
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

    // Vipin-db-optmz
    [appDelegate.dataBase endTransaction];
    
    appDelegate.dPicklist_retrieval_complete = TRUE;
}

// Chances SFObjectField
-(BOOL)UpdateSFObjectField_For_Picklist_TypeObject:(NSString *)object_api_name
                                    field_api_name:(NSString *)field_api_name
                                dependent_picklist:(NSString *)dependent_value
                              controler_field_name:(NSString *)controler_field
{
    
    BOOL isSuccess = YES;
    
    [appDelegate.dataBase beginTransaction];
    
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:[NSString stringWithFormat: @"UpdateSFObjectField_For_Picklist_TypeObject : %@", object_api_name] andRecordCount:1];
    
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"UpdateSFObjectField_For_Picklist_TypeObject : total"andRecordCount:1];
    
    
    [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:1];
    
    NSString * query = [NSString stringWithFormat:@"UPDATE  '%@' SET  dependent_picklist = '%@' , controler_field = '%@' WHERE  object_api_name = '%@' AND api_name = '%@' " ,SFOBJECTFIELD , dependent_value , controler_field , object_api_name,field_api_name];
    
    //NSString * query = @"UPDATE ?1 SET dependent_picklist = ?2, controler_field = ?3 WHERE  object_api_name = ?4 AND api_name = ?5";
    
    sqlite3_stmt * statement;
    
    int preparedStatementCreated = synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1 , &statement , nil);
    
    if ( preparedStatementCreated == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(statement) != SQLITE_DONE)
        {
            isSuccess = NO;
            SMLog(kLogLevelError,@"Failure UpdateSFObjectField_For_Picklist_TypeObject - update_query => %@", query);
            
        } else
        {
            //SMLog(kLogLevelVerbose,@"Success updateAllRecordsToSyncRecordsHeap - update_query => %@", update_query);
        }
        
    }
    else
    {
        isSuccess = NO;
        SMLog(kLogLevelError,@"Failure prepared UpdateSFObjectField_For_Picklist_TypeObject - update_query => %@", query);
    }
    
    sqlite3_clear_bindings(statement);
    sqlite3_reset(statement);
    synchronized_sqlite3_finalize(statement);
    
    [appDelegate.dataBase endTransaction];
    
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:[NSString stringWithFormat: @"UpdateSFObjectField_For_Picklist_TypeObject : %@", object_api_name] andRecordCount:0];
    
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"UpdateSFObjectField_For_Picklist_TypeObject : total"
                                                                      andRecordCount:0];
    
    
    return isSuccess;
}


/*
-(BOOL)UpdateSFObjectField_For_Picklist_TypeObject:(NSString *)object_api_name
                                    field_api_name:(NSString *)field_api_name
                                dependent_picklist:(NSString *)dependent_value
                              controler_field_name:(NSString *)controler_field
{
    NSString * query = [NSString stringWithFormat:@"UPDATE  '%@' SET  dependent_picklist = '%@' , controler_field = '%@' WHERE  object_api_name = '%@' AND api_name = '%@' " ,SFOBJECTFIELD , dependent_value , controler_field , object_api_name,field_api_name];
    char * err ;
    if(synchronized_sqlite3_exec(appDelegate.db, [query UTF8String], NULL, NULL, &err))
    {
        SMLog(kLogLevelVerbose,@"%@", query);
		SMLog(kLogLevelVerbose,@"METHOD:UpdateSFObjectField_For_Picklist_TypeObject " );
		SMLog(kLogLevelVerbose,@"ERROR IN UPDATING %s", err);
 
        //[appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:query type:UPDATEQUERY];
 

        return FALSE;
    }
    return TRUE;
}
*/

//Shrinivas : method for multiselect
-(void) UpdateSFPicklistForMultiSelect_IndexValue_For_Oject_Name:(NSString *)object_name  field_api_name:(NSString *)field_api_name value:(NSString *)value  index:(int)index_value
{    
    if([value isKindOfClass:[NSString class]])
        value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
     [appDelegate.dataBase beginTransaction];
    
    NSString * query = [NSString stringWithFormat:@"UPDATE  '%@' SET   index_value = '%d'  WHERE  object_api_name = '%@' AND field_api_name = '%@'  AND value = '%@'" , SFPicklist  ,index_value, object_name , field_api_name , value ];
	
	char * err ;
    if(synchronized_sqlite3_exec(appDelegate.db, [query UTF8String], NULL, NULL, &err))
    {
        SMLog(kLogLevelError,@"%@", query);
		SMLog(kLogLevelError,@"METHOD:UpdateSFPicklistForMultiSelect_IndexValue_For_Oject_Name " );
		SMLog(kLogLevelError,@"ERROR IN UPDATING %s", err);
        /*
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:query type:UPDATEQUERY];
         */
    }
    [appDelegate.dataBase endTransaction];
}

-(BOOL)UpdateSFPicklist_validFor_For_Oject_Name:(NSString *)object_name
                                 field_api_name:(NSString *)field_api_name
                                          value:(NSString *)value
                                valid_for_value:(NSString *)valid_for_value
                                          index:(int)index_value
{
    if (valid_for_value == nil)
    {
        valid_for_value = @"";
    }
    
    if([value isKindOfClass:[NSString class]])
        value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    BOOL isSuccessful = YES;
    
    NSString * query = [NSString stringWithFormat:@"UPDATE  '%@' SET  valid_for = '%@' , index_value = '%d'  WHERE  object_api_name = '%@' AND field_api_name = '%@'  AND value = '%@'" , SFPicklist , valid_for_value ,index_value, object_name , field_api_name , value ];
    
    //NSString * query = @"UPDATE  ?1 SET  valid_for = ?2, index_value = ?3  WHERE  object_api_name = ?4 AND field_api_name = ?5  AND value = ?6";
    
    [appDelegate.dataBase beginTransaction];
    
    sqlite3_stmt * statement;
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1 , &statement , nil)  ==  SQLITE_OK)
    {
        if (synchronized_sqlite3_step(statement) != SQLITE_DONE)
        {
            isSuccessful = NO;
            SMLog(kLogLevelError,@"Failure UpdateSFPicklist_validFor_For_Oject_Name - update_query => %@", query);
            
        } else
        {
            //SMLog(kLogLevelVerbose,@"Success updateAllRecordsToSyncRecordsHeap - update_query => %@", update_query);
        }
        
    }else
    {
        isSuccessful = NO;
        SMLog(kLogLevelError,@" Failure prepared UpdateSFPicklist_validFor_For_Oject_Name ");
    }
    
    sqlite3_clear_bindings(statement);
    sqlite3_reset(statement);
    synchronized_sqlite3_finalize(statement);
    
    [appDelegate.dataBase endTransaction];
    
    return isSuccessful;
}



/*
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
        SMLog(kLogLevelVerbose,@"%@", query);
		SMLog(kLogLevelVerbose,@"METHOD:UpdateSFPicklist_validFor_For_Oject_Name " );
		SMLog(kLogLevelVerbose,@"ERROR IN UPDATING %s", err);
 
        //[appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:query type:UPDATEQUERY];
 

        return FALSE;
    }
    return TRUE;
}
*/
-(int)getIndexOfPicklistValueForOject_Name:(NSString *)object_name  field_api_name:(NSString *)field_api_name value:(NSString *)value
{
    //6046
    NSString * query = [NSString  stringWithFormat:@"SELECT  index_value  FROM SFPicklist  WHERE object_api_name = '%@' AND field_api_name = '%@' AND label = '%@' ", object_name , field_api_name , [value stringByReplacingOccurrencesOfString:@"'" withString:@"''"]];
    sqlite3_stmt * statement;
    int index_value = 9999999;
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1 , &statement , nil)  ==  SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement)== SQLITE_ROW)
        {
            index_value =  synchronized_sqlite3_column_int(statement,0);
        }
    }
    
    synchronized_sqlite3_finalize(statement);
    
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
    
    synchronized_sqlite3_finalize(statement);
    
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
    
     synchronized_sqlite3_finalize(statement);
    
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
    
    synchronized_sqlite3_finalize(statement);
    
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
    
    synchronized_sqlite3_finalize(statement);
    return RTPicklistValues;
}

-(NSString *)getRecordTypeIdForRecordTypename:(NSString *)recorTypeName objectApi_name:(NSString *)objectApiName
{
    NSString * picklist_value = @"";
    //6046
    NSString * query = [NSString stringWithFormat:@"SELECT recordtypeid FROM SFRTPicklist Where object_api_name = '%@' AND recordtypename = '%@' ",objectApiName,[recorTypeName stringByReplacingOccurrencesOfString:@"'" withString:@"''"]];
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
    
    synchronized_sqlite3_finalize(statement);
    return picklist_value;
}

-(NSMutableArray *)getRtDependentPicklistsForObject:(NSString *)objectName recordtypeName:(NSString *)recordtypeName
{
    NSMutableArray * RTPicklistValues = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    [RTPicklistValues addObject:@""];
    NSString * picklist_value = @"";
    //6046
    NSString * query = [NSString stringWithFormat:@"SELECT  DISTINCT field_api_name FROM SFRTPicklist Where object_api_name = '%@' AND recordtypename = '%@'",objectName,[recordtypeName stringByReplacingOccurrencesOfString:@"'" withString:@"''"]];
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
    
    synchronized_sqlite3_finalize(statement);
    
    return RTPicklistValues;
}

-(NSString *)getDefaultValueForRTPicklist:(NSString *)objectName recordtypeName:(NSString *)recordtypeName  field_api_name:(NSString *)field_api_name  type:(NSString *)returnField
{
    NSString * query =@"";
    NSString * default_value = @"" ;
    //6046
    if([returnField  isEqualToString:@"Label"])
    {    
        query = [NSString stringWithFormat:@"SELECT  DISTINCT defaultlabel FROM SFRTPicklist Where object_api_name = '%@' AND recordtypename = '%@' AND field_api_name = '%@'",objectName,[recordtypeName stringByReplacingOccurrencesOfString:@"'" withString:@"''"], field_api_name];
    }
    else  if([returnField  isEqualToString:@"Value"])
    {
        query = [NSString stringWithFormat:@"SELECT  DISTINCT defaultvalue FROM SFRTPicklist Where object_api_name = '%@' AND recordtypename = '%@'  AND field_api_name = '%@'",objectName,[recordtypeName stringByReplacingOccurrencesOfString:@"'" withString:@"''"], field_api_name];
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
    
    synchronized_sqlite3_finalize(statement);
    
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
    
    synchronized_sqlite3_finalize(statement);
    
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
    
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"deleteDownloadCriteriaObjects"
                                                         andRecordCount:[deleted_objects count]];
    

    for(NSString * str in deleted_objects)
    {
        char * err;
        NSString * delete_Statement = [[NSString alloc] initWithFormat:@"DELETE FROM '%@' where upper(Id) not in (SELECT upper(WhatId) FROM Event) and  upper(Id) not in (SELECT upper(Id) FROM LookUpFieldValue)",str];
        
        SMLog(kLogLevelVerbose,@"delete Statementb %@" , delete_Statement);
        if (synchronized_sqlite3_exec(appDelegate.db, [delete_Statement UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
			SMLog(kLogLevelError,@"%@", delete_Statement);
			SMLog(kLogLevelError,@"METHOD:deleteDownloadCriteriaObjects");
			SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
            [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:delete_Statement type:DELETEQUERY];

		}
        [delete_Statement release];
    }
    
    [[PerformanceAnalytics sharedInstance] addDeletedRecordsNumber:[deleted_objects count]];
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"deleteDownloadCriteriaObjects"
                                                                      andRecordCount:0];
    
}

//sahana code starts    june8th
-(BOOL)ContinueIncrementalDataSync
{
    sqlite3_stmt * statement;
    int count = 0;
    NSString * query = [[NSString alloc] initWithFormat:@"SELECT COUNT(*) FROM SFDataTrailer"];
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String],-1, &statement, nil) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement)== SQLITE_ROW)
        {
             count =  sqlite3_column_int(statement, 0);
            
        }
    }
    [query release];
    query=nil;
    synchronized_sqlite3_finalize(statement);
    
    if(count == 0)
    {
        return FALSE;
    }
    else
        return TRUE;
}

-(BOOL)ContinueIncrementalDataSync_forNoncustomRecords
{
    sqlite3_stmt * statement;
    int count = 0;
    NSString * query = [[NSString alloc] initWithFormat:@"SELECT COUNT(*) FROM SFDataTrailer where sync_type != '%@'",CUSTOMSYNC];
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String],-1, &statement, nil) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement)== SQLITE_ROW)
        {
            count =  sqlite3_column_int(statement, 0);
        }
    }
    [query release];
    query = nil;
     synchronized_sqlite3_finalize(statement);
    
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
    NSString * query = [[NSString alloc] initWithFormat:@"SELECT COUNT(*) FROM on_demand_download where local_id  = '%@'",local_id];
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String],-1, &statement, nil) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement)== SQLITE_ROW)
        {
            count =  sqlite3_column_int(statement, 0);
            
        }
    }
    [query release];
    query= nil;
    synchronized_sqlite3_finalize(statement);
    
    if(count == 0)
    {
        return FALSE;
    }
    else
        return TRUE;
}

-(void)deleteAllOndemandRecordsPartOfDownloadCriteriaForSfId:(NSString *)sf_id
{
    
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"deleteAllOndemandRecordsPartOfDownloadCriteriaForSfId"
                                                         andRecordCount:1];
    
    
    BOOL isTableExist= [appDelegate.dataBase isTabelExistInDB:@"on_demand_download"];
    if(!isTableExist)
        return;
    NSString * delete_statement = [NSString stringWithFormat:@"DELETE FROM on_demand_download  WHERE sf_id = '%@'",sf_id];
    char * err;
    
    if (synchronized_sqlite3_exec(appDelegate.db, [delete_statement UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"%@", delete_statement);
		SMLog(kLogLevelError,@"METHOD:deleteAllOndemandRecordsPartOfDownloadCriteriaForSfId");
		SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
      	[appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:delete_statement type:DELETEQUERY];
    }
    
    [[PerformanceAnalytics sharedInstance] addDeletedRecordsNumber:1];
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"deleteAllOndemandRecordsPartOfDownloadCriteriaForSfId"
                                                                      andRecordCount:0];
    
    
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
    
    [query release];
    query= nil;
    
    if([ondemand_objects retainCount] == 1)
        [ondemand_objects retain];
    return ondemand_objects;
    
}
//  Unused Methods
//-(NSArray *)getAllIdsFromDatabaseForSyncType:(NSString *)sync_type
//{
//    
//    NSString * str = [[NSString alloc] initWithFormat:@"SELECT sf_id FROM sync_Records_Heap WHERE sync_type = '%@' " , sync_type];
//    NSString * default_value = @"";
//    
//    NSMutableArray * array = [[[NSMutableArray alloc] initWithCapacity:0]autorelease];
//    sqlite3_stmt * statement;
//    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [str UTF8String], -1 , &statement , nil)  ==  SQLITE_OK)
//    {
//        while (synchronized_sqlite3_step(statement)== SQLITE_ROW)
//        {
//            default_value = @"";
//            char * temp_id_value = (char *) synchronized_sqlite3_column_text(statement, 0);
//            if(temp_id_value != nil)
//            {
//                default_value = [NSString stringWithUTF8String:temp_id_value];
//                [array addObject:default_value];
//            }
//        }
//    }
//    
//    [str release];
//    synchronized_sqlite3_finalize(statement);
//    return array;
//}

-(void)updateOndemandRecordForId:(NSString *)record_id
{
   BOOL isTableExist= [appDelegate.dataBase isTabelExistInDB:@"on_demand_download"];
    if(!isTableExist)
        return;
    NSDate * date = [NSDate date];
    NSString * today_Date = @"";
    NSDateFormatter * dateFormatter  = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    today_Date = [dateFormatter stringFromDate:date];
    
    [appDelegate.dataBase beginTransaction];
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"updateOndemandRecordForId"
                                                         andRecordCount:1];
    
    
    NSString * update_query = [NSString stringWithFormat:@"UPDATE on_demand_download SET time_stamp = '%@' where sf_id = '%@'", today_Date,record_id];
    char * err;
    
    if (synchronized_sqlite3_exec(appDelegate.db, [update_query UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"%@", update_query);
		SMLog(kLogLevelError,@"METHOD:updateOndemandRecordForId " );
		SMLog(kLogLevelError,@"ERROR IN UPDATING %s", err);
		[appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:update_query type:UPDATEQUERY];
    }
    
    [appDelegate.dataBase endTransaction];
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"updateOndemandRecordForId"
                                                                      andRecordCount:0];
    
    
    [dateFormatter release];
    //krishna 23-1 memory opt 9493
    dateFormatter = nil;
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
    [query release];
    query = nil;
    return time_stamp;
}
//sahana code ends    june8th

-(BOOL)isSFObject:(NSString*)objectName
{
    sqlite3_stmt * statement;
    int count = 0;
    NSString * query = [[NSString alloc] initWithFormat:@"SELECT COUNT(*) FROM SFObject where api_name= '%@'",objectName];
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String],-1, &statement, nil) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement)== SQLITE_ROW)
        {
            count =  sqlite3_column_int(statement, 0);
        }
    }
    [query release];
    query=nil;
    synchronized_sqlite3_finalize(statement);
    
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
    @try{
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
                // Mem_leak_fix - Vipindas 9493 Jan 18
                 NSString * guid_id = [[AppDelegate GetUUID] retain];
                local_id = guid_id;
                [final_dict setObject:guid_id forKey:@"local_id"];
                [self insertdataIntoTable:object_name data:final_dict];
                if([recordType isEqualToString:MASTER])
                {
                    master_object_name = object_name;
                    master_local_id = guid_id;
                }
                [guid_id release];
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
    }@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name databaseInterfaceSfm :insertOndemandRecords %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason databaseInterfaceSfm :insertOndemandRecords %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];    }
    @finally {
        [record_dict release];
    }
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
    object_name=[object_name stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    RecordType=[RecordType stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    json_record=[json_record stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    //krishna 23-1 memory opt 9493
    [dateFormatter release];
    dateFormatter = nil;
    NSString * insert_query = [NSString stringWithFormat:@"INSERT OR REPLACE INTO 'on_demand_download' ('object_name','sf_id','time_stamp','local_id','record_type','json_record') VALUES ('%@','%@','%@','%@','%@','%@')" , object_name,sf_id,today_Date,local_id,RecordType,json_record ];
    char * err;
    [appDelegate.dataBase beginTransaction];
    if(synchronized_sqlite3_exec(appDelegate.db, [insert_query UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"%@", insert_query);
		SMLog(kLogLevelError,@"METHOD: insertrecordintoOnDemandTableForId");
        SMLog(kLogLevelError,@"ERROR IN INSERTING %s", err);
        /*
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:insert_query type:INSERTQUERY];
         */

    }
     [appDelegate.dataBase endTransaction];
}

-(NSString *)getRecordTypeNameForObject:(NSString *)object_name forId:(NSString *)recordTYpeId
{
    NSString * recordTypeName = @"";
    //10354 : krishna : Record type Id is displayed in English post save, even though there are translations in logged in user language.
    
    //fix : krishna : The translations are done to the recordtype_label field of SFRecordType. hence it was not respcting the translations and user language changes.
    //changed the field to recordtype_label instead of record_type
    
    NSString * query = [NSString stringWithFormat:@"SELECT recordtype_label  FROM  SFRecordType where object_api_name = '%@' and record_type_id = '%@'" ,object_name,recordTYpeId];
    
    SMLog(kLogLevelVerbose,@"RecordTypeId  valuemapping %@" ,query);
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

-(void)insertIntoEventsLocal_ids:(NSString *)local_id  fromEvent_temp_table:(NSString *)event_temp_table
{
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"insertIntoEventsLocal_ids"
                                                         andRecordCount:1];
    
    
    
    //delete before created event
    BOOL table_exist = [appDelegate.dataBase isTabelExistInDB:event_temp_table];
    if(!table_exist)
    {
        return;
    }
    [self deleteRecordsFromEventLocalIdsFromTable:event_temp_table];
    
    [appDelegate.dataBase beginTransaction];
    
    NSString * insert_query = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ ('object_name','local_id' ) VALUES ('%@','%@')" , event_temp_table,@"Event",local_id ];
    char * err;
    
    if(synchronized_sqlite3_exec(appDelegate.db, [insert_query UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"Insert Failed Event_local_Ids");
        SMLog(kLogLevelError,@"METHOD:insertIntoEventsLocal_ids " );
        SMLog(kLogLevelError,@"ERROR IN INSERTING %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:insert_query type:INSERTQUERY];
    }
    
    [appDelegate.dataBase endTransaction];
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"insertIntoEventsLocal_ids"
                                                                      andRecordCount:0];

}

-(NSString *)getLocal_idFrom_Event_local_id:(NSString *)event_temp_table
{
    NSString * local_id = @"";
    NSString * query = [NSString stringWithFormat:@"SELECT local_id FROM %@",event_temp_table];
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

-(void)deleteRecordsFromEventLocalIdsFromTable:(NSString *)event_temp_table
{
    
    BOOL table_exist = [appDelegate.dataBase isTabelExistInDB:event_temp_table];
    if(!table_exist)
    {
        return;
    }
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"deleteRecordsFromEventLocalIdsFromTable"
                                                         andRecordCount:1];
    
    
    NSString * delete_query = [NSString stringWithFormat:@"DELETE FROM %@ ",event_temp_table];
    char * err_delete;
    
    if(synchronized_sqlite3_exec(appDelegate.db, [delete_query UTF8String], NULL, NULL, &err_delete) != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"delete Failed Event_local_Ids");
        SMLog(kLogLevelError,@"%@", delete_query);
		SMLog(kLogLevelError,@"METHOD:deleteRecordsFromEventLocalIds");
		SMLog(kLogLevelError,@"ERROR IN DELETE %s", err_delete);
        [appDelegate printIfError:[NSString stringWithUTF8String:err_delete] ForQuery:delete_query type:DELETEQUERY];
        
    }

    [[PerformanceAnalytics sharedInstance] addDeletedRecordsNumber:1];
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"deleteRecordsFromEventLocalIdsFromTable"
                                                                      andRecordCount:0];

}

-(NSString * )getallOverLappingEventsForStartDateTime:(NSString *)startDateTime EndDateTime:(NSString *)endDateTime local_id:(NSString *)local_id
{
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"getallOverLappingEventsForStartDateTime"
                                                         andRecordCount:1];
    
    
    NSDateFormatter * formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"hh:mm"];
    
    NSDateFormatter * date_formatter = [[[NSDateFormatter alloc] init] autorelease];
    [date_formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeInterval timeZoneOffset = [[NSTimeZone systemTimeZone] secondsFromGMT];
    
    NSString * overlapping_events = nil;
    NSMutableString * mutable_str = [[NSMutableString alloc] initWithCapacity:0] ;
    NSMutableArray * events = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    NSMutableArray * startDate_time_array = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    NSMutableArray * endDate_time_array = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    NSString * query_str = [NSString stringWithFormat:@"SELECT DISTINCT  Subject, WhatId , StartDatetime, EndDateTime FROM Event WHERE (('%@' >=  StartDatetime AND '%@' < EndDateTime) OR ('%@' >= StartDatetime AND    '%@' <=  EndDateTime) OR  ('%@' <= StartDatetime  AND '%@' >= EndDateTime)   OR ('%@' >=  StartDatetime  AND '%@' <= EndDateTime)) AND local_id!='%@'" ,startDateTime,startDateTime,endDateTime,endDateTime,startDateTime,endDateTime ,startDateTime,startDateTime,local_id];
    NSString * subject = nil , * relatedTo = nil ,*startTime = nil,* endTime = nil;
    sqlite3_stmt * stmt;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query_str UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(stmt)== SQLITE_ROW)
        {
            relatedTo = @"" ,subject = @"",startTime = @"",endTime = @"";
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
            char * temp_start_time = (char *)synchronized_sqlite3_column_text(stmt, 2);
            if (temp_start_time != nil)
            {
                startTime = [NSString stringWithUTF8String:temp_start_time];
            }
            char * temp_end_time = (char *)synchronized_sqlite3_column_text(stmt, 3);
            if (temp_end_time != nil)
            {
                endTime = [NSString stringWithUTF8String:temp_end_time];
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
            else
            {
                [events addObject:@""];
            }
            
            if([startTime length] > 0 && [endTime length] > 0)
            {
                NSString * s_time = @"" ,* e_time = @"";
                NSString * After_replacing_stime = [[[NSString alloc] initWithString:startTime] autorelease];
                After_replacing_stime = [After_replacing_stime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
                After_replacing_stime = [After_replacing_stime stringByReplacingOccurrencesOfString:@".000+0000" withString:@""];
                
                NSString * afterReplacing_etime = [[[NSString alloc] initWithString:endTime] autorelease];
                afterReplacing_etime = [afterReplacing_etime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
                afterReplacing_etime = [afterReplacing_etime stringByReplacingOccurrencesOfString:@".000+0000" withString:@""];

                
                NSDate * gmtSartDate = [date_formatter dateFromString:After_replacing_stime];
                NSTimeInterval NDS_gmtTimeInterval = [gmtSartDate timeIntervalSinceReferenceDate] + timeZoneOffset;
                NSDate * NSDlocal_startDate = [NSDate dateWithTimeIntervalSinceReferenceDate:NDS_gmtTimeInterval];
                s_time = [formatter stringFromDate:NSDlocal_startDate];
                
                NSDate * gmtendDate = [date_formatter dateFromString:afterReplacing_etime];
                NSTimeInterval NDS_gmtTimeInterval_end = [gmtendDate timeIntervalSinceReferenceDate] + timeZoneOffset;
                NSDate * NSDlocal_endDate = [NSDate dateWithTimeIntervalSinceReferenceDate:NDS_gmtTimeInterval_end];
                e_time = [formatter stringFromDate:NSDlocal_endDate];
                
                if(s_time != nil)
                {
                    [startDate_time_array addObject:s_time];
                }
                else
                {
                     [startDate_time_array addObject:@""];
                }
                if(e_time!= nil)
                {
                     [endDate_time_array addObject:e_time];
                }
                else
                {
                      [endDate_time_array addObject:@""];
                }
            }
            else
            {
                [startDate_time_array addObject:@""];
                [endDate_time_array addObject:@""];
            }
            
        }
    }
    SMLog(kLogLevelVerbose,@" overlapping events%@",events);
    synchronized_sqlite3_finalize(stmt);
     [mutable_str appendFormat:@"\n"];
    for(int i= 0;i<[events count];i++)
    {
        NSString * event_temp = [events objectAtIndex:i];
        NSString * disp_st_time = [startDate_time_array objectAtIndex:i];
        NSString * disp_et_time = [endDate_time_array objectAtIndex:i];
        if([event_temp length] >0)
        {
            [mutable_str appendFormat:@"%@: (%@-%@)\n",event_temp,disp_st_time,disp_et_time];
        }
        else
        {
             [mutable_str appendFormat:@"(%@-%@)\n",disp_st_time,disp_et_time];
        }
    }
    overlapping_events = [[NSString alloc]  initWithFormat:@"%@",mutable_str];
    [mutable_str release];
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"getallOverLappingEventsForStartDateTime"
                                                                      andRecordCount:0];
    
    
    return overlapping_events;
}

-(NSString *)getNameForSFId:(NSString *)sfId
{
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"getNameForSFId"
                                                         andRecordCount:1];
    
    
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
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"getNameForSFId"
                                                                      andRecordCount:0];
    
    
    return name_field;
}


#pragma mark - 
#pragma mark Get price deletion of records
- (void)insertGetPriceRecordsToRespectiveTables:(NSMutableDictionary *)gpData andParser:(SBJsonParser *)jsonParser{
   
    int retVal =  [appDelegate.dataBase beginTransaction];;
    SMLog(kLogLevelVerbose,@"GP Starting transcation Success = %d",retVal);
    
    @try {
        
        NSMutableDictionary *objectFieldDictionaryLocal = [[NSMutableDictionary alloc] init];
        
        BOOL allRecordInsertedSuccessFully = YES;
        
        /*For each object in object array, objectApiName = table name  */
        NSArray *allKeysOfSyncData = [gpData allKeys];
        for(NSString *objectApiName in allKeysOfSyncData) {
            
            NSAutoreleasePool * autoreleaseExternal = [[NSAutoreleasePool alloc] init];
            
            SMLog(kLogLevelVerbose,@"GP Insertion starts for %@",objectApiName);
            
            NSArray *allRecords =[gpData objectForKey:objectApiName];
            NSInteger numberOfRecords = [allRecords count];
            if (numberOfRecords <= 0) {
                continue;
            }
            
            /* get field and table schema only once and store it in global dictionary*/
            NSMutableDictionary *fieldDictionary =  [objectFieldDictionaryLocal objectForKey:objectApiName];
            if(fieldDictionary == nil ) {
                
                fieldDictionary = [self getAllFieldsAndItsDataTypesForObject:objectApiName tableName:SFOBJECTFIELD];
                [fieldDictionary setValue:@"VARCHAR" forKey:@"local_id"];
                [objectFieldDictionaryLocal setObject:fieldDictionary forKey:objectApiName];
            }
            
            /* Form a query and store that in the global dictionary */
            NSArray * allKeysObjectApiNames = [fieldDictionary allKeys];
            NSString * fieldString = @"";
            NSString * valuesString = @"";
            
            NSInteger allKeysCount = [allKeysObjectApiNames count];
            for(int t = 0; t < allKeysCount;t++)
            {
                NSString * keyFieldName = [allKeysObjectApiNames objectAtIndex:t];
                if(t != 0)
                {
                    NSString * temp_field_string = [NSString stringWithFormat:@",%@" ,keyFieldName];
                    fieldString = [fieldString stringByAppendingFormat:@"%@",temp_field_string];
                    valuesString = [valuesString stringByAppendingFormat:@",?%d",t+1];
                }
                else
                {
                    NSString * temp_field_string = [NSString stringWithFormat:@"%@" ,keyFieldName];
                    fieldString = [fieldString stringByAppendingFormat:@"%@",temp_field_string];
                    valuesString = [valuesString stringByAppendingFormat:@"?%d",t+1];
                }
            }
            
            /*get all these records whether master or detail */
            NSString *insertionQuery = [NSString stringWithFormat:@"INSERT INTO '%@' (%@) VALUES (%@)",objectApiName,fieldString,valuesString];
            
            /* Compile it for the records and insert them */
            sqlite3_stmt * bulk_statement = nil;
            
            int preparedSuccessfully = synchronized_sqlite3_prepare_v2(appDelegate.db, [insertionQuery UTF8String], strlen([insertionQuery UTF8String]), &bulk_statement, NULL);
            int counter = 0;
            
            NSString *sfid=nil,*jsonRecord = nil;
            if(preparedSuccessfully == SQLITE_OK)
            {
                for (counter = 0; counter < numberOfRecords; counter++) {
                    
                    NSAutoreleasePool * autoreleaseInternal = [[NSAutoreleasePool alloc] init];
                    
                    jsonRecord = [allRecords objectAtIndex:counter];
                    NSMutableDictionary * responseDictionary = [self getDictForJsonString:jsonRecord withParser:jsonParser];
                    
                    sfid = [responseDictionary objectForKey:@"Id"];
                    
                    // Mem_leak_fix - Vipindas 9493 Jan 18
                    NSString * newLocalId  = [[AppDelegate GetUUID] retain];
                    
                    BOOL  noDuplicate = [appDelegate.dataBase checkForDuplicateId:objectApiName sfId:sfid];
                    /* Insertion */
                    if(noDuplicate)
                    {
                        [responseDictionary setObject:newLocalId forKey:@"local_id"];
                        
                        NSInteger allTableColumnNamesCount = [allKeysObjectApiNames count];
                        for(int x = 0; x < allTableColumnNamesCount; x++)
                        {
                            int column_num = x+1;
                            NSString * field = [allKeysObjectApiNames objectAtIndex:x];
                            NSString * data_type = [fieldDictionary objectForKey:field];
                            NSString * columnType = [appDelegate.dataBase columnType:data_type];
                            NSString * final_value = [responseDictionary objectForKey:field];
                            
                            
                            if([data_type isEqualToString:@"boolean"])
                            {
                                if ([final_value isEqualToString:@"True"] || [final_value isEqualToString:@"true"] || [final_value isEqualToString:@"1"])
                                {
                                    final_value = @"1";
                                }
                                else
                                {
                                    final_value = @"0";
                                }
                            }
                            
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
                        
                        int ret = sqlite3_step(bulk_statement);
                        SMLog(kLogLevelVerbose,@"Insertion For for %@ Success = %d",sfid,ret);
                        if (ret!= SQLITE_DONE)
                        {
                            allRecordInsertedSuccessFully = NO;
                            NSError *error = nil;
                            SMLog(kLogLevelError,@"Commit Failed!\n");
                            SMLog(kLogLevelError,@"%@", insertionQuery);
                            SMLog(kLogLevelError,@"METHOD:updateAllRecordsToSyncRecordsHeap " );
                            SMLog(kLogLevelError,@"ERROR IN UPDATING %@", error); //RADHA TODAY
                            
                        }
                        
                        sqlite3_clear_bindings(bulk_statement);
                        sqlite3_reset(bulk_statement);
                    }
                    else
                    {
                        BOOL flag = [self updateGPTableforSFId:sfid forObject:objectApiName data:responseDictionary];
                        if(flag)
                        {
                            SMLog(kLogLevelVerbose,@"Record updated ");
                        }
                        else {
                            allRecordInsertedSuccessFully = NO;
                        }
                    }
                    
                    
                    [responseDictionary release];
                    [newLocalId release];
                    
                    [autoreleaseInternal drain];
                    autoreleaseInternal = nil;
                }
                
            }
            else
            {
                SMLog(kLogLevelError,@"Failed to insert Initial Sync");
            }
            
            synchronized_sqlite3_finalize(bulk_statement);
            
            [autoreleaseExternal release];
            autoreleaseExternal = nil;
            SMLog(kLogLevelVerbose,@"Insertion Ends for %@",objectApiName);
        }
        
        [objectFieldDictionaryLocal release];
        objectFieldDictionaryLocal = nil;
        if (!allRecordInsertedSuccessFully ) {
            
        }
    }
    @catch (NSException *exception) {
        
        SMLog(kLogLevelError,@"Exception Name databaseInterfaceSfm :UpdateTableforSFId %@",exception.name);
        SMLog(kLogLevelError,@"Exception Reason databaseInterfaceSfm :UpdateTableforSFId %@",exception.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exception];
    }
   
    retVal = [appDelegate.dataBase endTransaction];
    SMLog(kLogLevelVerbose,@"Commit transaction %d",retVal);
    
}




- (BOOL)updateGPTableforSFId:(NSString *)sfId  forObject:(NSString *)objectName  data:(NSDictionary *)dictionaryValue {
    
    BOOL success = FALSE;
    if ( sfId == nil && [sfId length] <= 0)
        return success;
    
	NSMutableDictionary * dict = [self updateEmptyFieldValuesForDict:dictionaryValue objectName:objectName];
    
	
    NSArray * allkeys = [dict allKeys];
    NSMutableString *  updateValue = [[[NSMutableString alloc] initWithCapacity:0] autorelease]; 
    @try{
        for(int i = 0 ; i < [allkeys count]; i++)
        {
            NSString * key = [allkeys objectAtIndex:i];
            NSString * value = [dict objectForKey:key];
            if(value != nil)
            {
                value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                NSString * field_data_type = [self getFieldDataType:objectName filedName:key];
                
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
                
                if(i== 0)
                    [updateValue  appendFormat:@" %@ = '%@' ",key ,value ];
                else
                    [updateValue  appendFormat:@" , %@ = '%@' ",key ,value ];
            }
            
        }
        
        NSString * update_statement = nil;
        if([updateValue length] != 0 && sfId != nil && [sfId length] > 0 ){
             update_statement = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE Id = '%@'",objectName ,updateValue,sfId];
                char * err = NULL;
         
                if(synchronized_sqlite3_exec(appDelegate.db, [update_statement UTF8String],NULL, NULL, &err) != SQLITE_OK) {
                    success = FALSE;
             
                    SMLog(kLogLevelError,@"%@", update_statement);
                    SMLog(kLogLevelError,@"METHOD:UpdateTableforSFId " );
                    SMLog(kLogLevelError,@"ERROR IN UPDATING %s", err);
                }
                else
                {
                    success = TRUE;
                }
        }
    }
    @catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name databaseInterfaceSfm :UpdateTableforSFId %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason databaseInterfaceSfm :UpdateTableforSFId %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
    return success;
}

-(NSMutableDictionary *)getRecordsGPForRecordId:(NSString *)record_id ForObjectName:(NSString *)object_name fields:(NSString *)fields
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
                    [dict setValue:value forKey:field];
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

#pragma custom agggressive sync implementation Begins
-(NSArray *)getallmasterRecordsForCustomAggressiveSync
{
    NSMutableArray * all_local_ids = [[NSMutableArray alloc] initWithCapacity:0];
    NSString * query = [NSString stringWithFormat:@"SELECT DISTINCT request_id FROM '%@' WHERE sync_type = '%@' and request_id not in (select request_id FROM '%@')",SFDATATRAILER,CUSTOMSYNC,SYNC_ERROR_CONFLICT];
    sqlite3_stmt * statement ;
    
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, nil) ==  SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            NSString * value = @"";
            char * temp_header_local_id = (char * ) synchronized_sqlite3_column_text(statement, 0);
            if(temp_header_local_id != nil)
            {
                value  = [NSString stringWithUTF8String:temp_header_local_id];
            }
            if(value != nil)
            {
                [all_local_ids addObject:value];
            }
        }
    }
    
     synchronized_sqlite3_finalize(statement);
    return all_local_ids ;
}

-(NSArray *)getallmasterRecordsForCustomAggressiveSyncFrom_SyncErrorTable
{
    NSMutableArray * all_local_ids = [[NSMutableArray alloc] initWithCapacity:0];
    NSString * query = [NSString stringWithFormat:@"SELECT  request_id FROM '%@' WHERE ( custom_ws_error = 'RELATED_REC_ERROR' or custom_ws_error = '%@')  and override_flag = 'retry'",SYNC_ERROR_CONFLICT,CUSTOM_SYNC_SOAP_FAULT];
    sqlite3_stmt * statement ;
    
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, nil) ==  SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            NSString * value = @"";
            char * temp_header_local_id = (char * ) synchronized_sqlite3_column_text(statement, 0);
            if(temp_header_local_id != nil)
            {
                value  = [NSString stringWithUTF8String:temp_header_local_id];
            }
            if(value != nil)
            {
                [all_local_ids addObject:value];
            }
        }
    }
    synchronized_sqlite3_finalize(statement);
    return all_local_ids ;
}

-(NSMutableDictionary *)getClassNameMethodnameForHeaderLocalId:(NSString *)header_lcal_id
{
    NSMutableDictionary * config_info = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    NSString * query = [NSString stringWithFormat:@"SELECT DISTINCT class_name , webservice_name  FROM '%@' WHERE  request_id = '%@'",SFDATATRAILER,header_lcal_id];
    sqlite3_stmt * statement ;
    
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, nil) ==  SQLITE_OK)
    {
        if(synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            NSString * class_name = @"" , * webservice_name = @"";
            char * temp_class_name = (char * ) synchronized_sqlite3_column_text(statement, 0);
            if(temp_class_name != nil)
            {
                class_name  = [NSString stringWithUTF8String:temp_class_name];
            }
            char * temp_webservice = (char * ) synchronized_sqlite3_column_text(statement, 1);
            if(temp_webservice != nil)
            {
                webservice_name  = [NSString stringWithUTF8String:temp_webservice];
            }
            if([class_name length] > 0 && [webservice_name length] >0)
            {
                [config_info setObject:class_name forKey:CLASS_NAME];
                [config_info setObject:webservice_name forKey:WEBSERVICE_NAME];
            }
        }
    }
    synchronized_sqlite3_finalize(statement);
    return config_info ;
}

-(NSMutableDictionary *)getCustomAggressiveSyncRecordsForHearedRecord:(NSString *)header_reco_id
{
    NSMutableDictionary * sync_record_dict = nil;
    
    NSString * query = [NSString stringWithFormat:@"SELECT  request_data FROM '%@' WHERE request_id = '%@'",SFDATATRAILER ,header_reco_id];
    
    NSString *request_data = nil;
    sqlite3_stmt * statement ;
    
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, nil) ==  SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            request_data = @"";
            
            char * temp_request_data = (char * ) synchronized_sqlite3_column_text(statement, 0);
            if(temp_request_data != nil)
            {
                request_data  = [NSString stringWithUTF8String:temp_request_data];
            }
                       
//            [self fillSyncRecordDictForRecordType:record_type SF_Id:sf_id local_id:local_id operation_type:operation final_dictionary:sync_record_dict object_naem:object_name parent_object_name:parent_obj_name parent_local_id:parent_local_id];
        }
    }
    if(request_data != nil)
    {
        SBJsonParser * jsonParser = [[[SBJsonParser alloc] init] autorelease];
        sync_record_dict = [jsonParser objectWithString:request_data];
    }
    synchronized_sqlite3_finalize(statement);
    return sync_record_dict ;
}
//  Unused Methods
//-(BOOL)ShouldTriggerCustomAggressive
//{
//    BOOL flag = [self checkColumnExists:@"sync_type" tableName:SFDATATRAILER];
//    return flag;
//}

-(void)fillSyncRecordDictForRecordType:(NSString *)record_type SF_Id:(NSString *)SF_id local_id:(NSString *)local_id  operation_type:(NSString *)operation_type  final_dictionary:(NSMutableDictionary *)sync_record_dict  object_naem:(NSString *)object_name parent_object_name:(NSString *)parent_object_name parent_local_id:(NSString *)parent_local_id
{
    
    if([operation_type isEqualToString:UPDATE] || [operation_type isEqualToString:DELETE])
    {
        BOOL sf_id_exists = FALSE;
        if(SF_id != nil || [SF_id length] != 0)
        {
             sf_id_exists = [self doesIdexistsinSyncrecord:sync_record_dict new_local_id:SF_id idType:@"SF_ID"];
        }
        BOOL Local_id_exists = [self doesIdexistsinSyncrecord:sync_record_dict new_local_id:local_id idType:@"LOCAL_ID" ];
        if(sf_id_exists || Local_id_exists)
        {
//            SMLog(kLogLevelVerbose,@"Duplicate_id %@ ,%@",local_id,SF_id);
            return;
        }
    }
    
    NSArray * keys =  [[NSArray alloc] initWithObjects:@"Id",@"local_id",@"Operation_type", @"parent_object_name", @"parent_local_id",nil ];
    NSDictionary *  info_dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:SF_id,local_id, operation_type,parent_object_name,parent_local_id, nil] forKeys:keys];
    
    if([record_type isEqualToString:SYNC_RECORD_header])
    {
        NSMutableArray * detail_records = [[NSMutableArray alloc] initWithCapacity:0];
        [detail_records addObject:info_dict];
        NSMutableDictionary * final_dict = [[NSMutableDictionary alloc] initWithCapacity:0];
        NSMutableDictionary * operation_dict = [[NSMutableDictionary alloc] initWithCapacity:0];
        [operation_dict setObject:detail_records forKey:operation_type];
        [final_dict setObject:operation_dict forKey:object_name];
        [sync_record_dict setObject:final_dict forKey:SYNC_RECORD_header];
        [final_dict release];
        [detail_records release];
    }
    else if([record_type isEqualToString:SYNC_RECORD_DETAIL])
    {
        if([[sync_record_dict allKeys] containsObject:SYNC_RECORD_DETAIL])
        {
            NSMutableDictionary * objects_dict = [sync_record_dict objectForKey:SYNC_RECORD_DETAIL];
            
            if([[objects_dict allKeys] containsObject:object_name])
            {
                NSMutableDictionary * operation_dict  = [objects_dict objectForKey:object_name];
                
                if([[operation_dict allKeys] containsObject:operation_type])
                {
                    NSMutableArray * detail_records = [operation_dict objectForKey:operation_type];
                    [detail_records addObject:info_dict];
                }
                else
                {
                    NSMutableArray * detail_records = [[NSMutableArray alloc] initWithCapacity:0];
                    [detail_records addObject:info_dict];
                    [operation_dict setObject:detail_records forKey:operation_type];
                    [detail_records release];
                }
            }
            else
            {
                NSMutableDictionary * operation_dict = [[NSMutableDictionary alloc] initWithCapacity:0];
                NSMutableArray * detail_records = [[NSMutableArray alloc] initWithCapacity:0];
                
                [detail_records addObject:info_dict];
                [operation_dict setObject:detail_records forKey:operation_type];
                [objects_dict setObject:operation_dict forKey:object_name];
                [detail_records release];
                [operation_dict release];
                
            }
        }
        else
        {
            NSMutableArray * detail_records = [[NSMutableArray alloc] initWithCapacity:0];
            NSMutableDictionary * objects_dict = [[NSMutableDictionary alloc] initWithCapacity:0];
            NSMutableDictionary * operation_dict = [[NSMutableDictionary alloc] initWithCapacity:0];
            
            [detail_records addObject:info_dict];
            [operation_dict setObject:detail_records forKey:operation_type];
            [objects_dict setObject:operation_dict forKey:object_name];
            [sync_record_dict setObject:objects_dict forKey:SYNC_RECORD_DETAIL];
            [detail_records release];
            [objects_dict release];
            [operation_dict release];
            
        }
    }
    
    [info_dict release];
}

-(BOOL)doesIdexistsinSyncrecord:(NSDictionary *)sync_record new_local_id:(NSString *)new_id idType:(NSString *)id_type
{
    
    BOOL flag = FALSE;
    NSArray * object_types = [sync_record allKeys];
    
    for(NSString * object_type in object_types)
    {
        NSDictionary * each_dict = [sync_record objectForKey:object_type];
        NSArray * allobjects = [each_dict allKeys];
        for(NSString * object_name in allobjects)
        {
            NSDictionary  * operation_type_dict  = [each_dict objectForKey:object_name];
            NSArray * all_operations = [operation_type_dict allKeys];
            for(NSString  * single_operation in all_operations)
            {
                NSArray * record_info_dict_array = [operation_type_dict objectForKey:single_operation];
                
                for(NSDictionary * info_dict in record_info_dict_array)
                {
                    NSString * id_to_compare = @"";
                    
                    if([id_type isEqualToString:@"SF_ID"])
                    {
                        id_to_compare = [info_dict objectForKey:@"Id"];
                    }
                    else if([id_type isEqualToString:@"LOCAL_ID"])
                    {
                        id_to_compare = [info_dict objectForKey:@"local_id"];
                    }
//                    SMLog(kLogLevelVerbose,@"ID_to_compare %@,%@" ,id_to_compare,new_id);
                  
                    if([id_to_compare isEqualToString:new_id])
                    {
                        flag = TRUE;
                        break;
                    }
                }
            }
        }
    }
    return flag;
}
#pragma custom agggressive sync implementation Ends
//Sync Override :Radha
-(BOOL)checkColumnExists:(NSString *)columnname tableName:(NSString *)tableName
{
    BOOL columnExists = NO;
    sqlite3_stmt *selectStmt;
    const char *sql = "PRAGMA table_info(SFDataTrailer)";
	
	
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, sql, -1, &selectStmt, nil) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(selectStmt)== SQLITE_ROW)
        {
            NSString *fieldName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectStmt, 1)];
			if([columnname isEqualToString:fieldName])
			{
				columnExists = YES;
                break;
//				return columnExists;
			}
        }
    }
    
    synchronized_sqlite3_finalize(selectStmt);
    return columnExists;
}

- (BOOL)ColumnExists:(NSString *)columnname tableName:(NSString *)tableName
{
    BOOL columnExists = NO;
    sqlite3_stmt *selectStmt;
    
    NSString * temp = [NSString stringWithFormat:@"PRAGMA table_info(%@)",tableName];
    const char *sql = [temp UTF8String];//"PRAGMA table_info(SFDataTrailer)";
	
	
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, sql, -1, &selectStmt, nil) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(selectStmt)== SQLITE_ROW)
        {
            NSString *fieldName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectStmt, 1)];
			if([columnname isEqualToString:fieldName])
			{
				columnExists = YES;
                break;
//				return columnExists;
			}
        }
    }
    
    synchronized_sqlite3_finalize(selectStmt);
    
    return columnExists;
}
- (BOOL) checkIfCustomEntryExistsInTrailerTable:(NSString *)parentLocalId
{
	BOOL entryExists = FALSE;
	
	if (![self checkColumnExists:@"sync_type" tableName:SFDATATRAILER])
	{
		return entryExists;
	}
	int count = 0;
	
	sqlite3_stmt * statement = nil;

	
	NSString * queryStatement = [NSString stringWithFormat:@"SELECT COUNT(*) FROM '%@' WHERE header_localId = '%@' AND sync_type = '%@'", SFDATATRAILER, parentLocalId, CUSTOMSYNC];
	
	if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
	{
		while (synchronized_sqlite3_step(statement) == SQLITE_ROW)
		{
			count = synchronized_sqlite3_column_int(statement, 0);
		}
	}
	
	if (count > 0)
	{
		entryExists = TRUE;
	}
	synchronized_sqlite3_finalize(statement);
	
	return entryExists;
}

-(void)deletecustomWebservicefrom_detailTrailer_for_request_id:(NSString *)request_id table_name:(NSString *)table_name
{
    NSString * delete_stmt = @"";
   
    delete_stmt = [NSString stringWithFormat:@"DELETE FROM '%@' WHERE  request_id = '%@'", table_name,request_id];
    char * err;
    
    if (synchronized_sqlite3_exec(appDelegate.db, [delete_stmt UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
		SMLog(kLogLevelError,@"%@", delete_stmt);
		SMLog(kLogLevelError,@"METHOD:DeleteDataTrailerTableAfterSync");
		SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:delete_stmt type:DELETEQUERY];
    }
}


-(void)insertIntoConflictTable_forlocal_id:(NSString *)local_id sf_id:(NSString *)sf_id class_name:(NSString *)class_name method_name:(NSString *)method_name   error_type:(NSString *)error_type error_message:(NSString *)error_msg custom_service:(NSString *)custom_wsservice request_id:(NSString *)request_id record_type:(NSString *)record_type object_name:(NSString *)object_name operation_type:(NSString *)operation_type
{
   
     NSString * insert_query = @"";
    NSString * mod_error_msg = [[NSString alloc] initWithString:error_msg];
    NSString * final_error_msg =[mod_error_msg stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    if([custom_wsservice isEqualToString:@"RELATED_REC_ERROR"] || [custom_wsservice isEqualToString:CUSTOM_SYNC_SOAP_FAULT])
    {
        BOOL record_exists = [self doesRequestIdExistsintable:SYNC_ERROR_CONFLICT request_id:request_id error_type:custom_wsservice];
        if(record_exists)
        {
            return;
        }
        insert_query = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' (local_id , sf_id, object_name, sync_type,record_type,error_message,error_type,class_name,method_name,custom_ws_error,request_id) VALUES ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')", SYNC_ERROR_CONFLICT, local_id , sf_id, object_name, custom_wsservice, record_type, final_error_msg, error_type,class_name,method_name,custom_wsservice,request_id];
    }
    else if([custom_wsservice isEqualToString:@"DML_ERROR"])
    {
         insert_query = [NSString stringWithFormat:@"INSERT INTO '%@' (local_id , sf_id, object_name, sync_type,record_type,error_message,error_type) VALUES ('%@','%@','%@','%@','%@','%@','%@')", SYNC_ERROR_CONFLICT, local_id , sf_id, object_name, operation_type, record_type, final_error_msg, error_type];
    }
    
    char * err;
    
    [appDelegate.dataBase beginTransaction];
    
    if(synchronized_sqlite3_exec(appDelegate.db, [insert_query UTF8String],NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"%@", insert_query);
        SMLog(kLogLevelError,@"METHOD: insertSyncConflictsIntoSYNC_CONFLICT");
        SMLog(kLogLevelError,@"ERROR IN INSERTING %s", err);
    }
    
    [appDelegate.dataBase endTransaction];
}
-(void)deleteAllRecordsWithIgnoreTagFromConflictTable
{
    NSMutableArray * all_request_ids = [self getAllrequestIdsWithFlag:@"IGNORE"];
    
    NSMutableString  * request_ids_str = [[NSMutableString alloc] initWithCapacity:0];
    
    for(int count = 0;count < [all_request_ids count] ; count++)
    {
        NSString * request_id = [all_request_ids objectAtIndex:count];
        if(count == 0)
        {
            [request_ids_str appendFormat:@"'%@'",request_id];
        }else{
             [request_ids_str appendFormat:@" , '%@'",request_id];
        }
        
    }
    
    if([request_ids_str length] >0)
    {
        [self deleteallRecordsForRequest_ids:SFDATATRAILER request_ids:request_ids_str];
        [self deleteallRecordsForRequest_ids:SYNC_ERROR_CONFLICT request_ids:request_ids_str];
        
    }
    [request_ids_str release];
    [all_request_ids release];
}
-(void)deleteallRecordsForRequest_ids:(NSString *)table_name request_ids:(NSString *)request_id_str
{
    NSString * deleteQuery = [NSString stringWithFormat:@"Delete from %@ where request_id in (%@)", table_name,request_id_str];
    char * err;
    
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"deleteallRecordsForRequest_ids"
                                                         andRecordCount:1];
    
    if(synchronized_sqlite3_exec(appDelegate.db, [deleteQuery UTF8String],NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"%@", deleteQuery);
        SMLog(kLogLevelError,@"METHOD: insertSyncConflictsIntoSYNC_CONFLICT");
        SMLog(kLogLevelError,@"ERROR IN INSERTING %s", err);
    }
    
    [[PerformanceAnalytics sharedInstance] addDeletedRecordsNumber:1];
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"deleteallRecordsForRequest_ids"
                                                                      andRecordCount:1];

}
-(NSArray *)getAllrequestIdsWithFlag:(NSString *)flag
{
    NSMutableArray * request_ids_array = [[NSMutableArray alloc] initWithCapacity:0];
    NSString * request_id = @"";
    
    NSString * selectQuery = [NSString stringWithFormat:@"Select request_id  from sync_error_conflict where override_flag = '%@'",flag];
    sqlite3_stmt *stmt;
    int ret = synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, NULL);
    if(ret == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * _request_id = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_1);
            if (_request_id != nil && strlen(_request_id))
            {
                request_id = [NSString stringWithUTF8String:_request_id];
                [request_ids_array addObject:request_id];
            }
        }
    }
    synchronized_sqlite3_finalize(stmt);
    return request_ids_array ;
}
-(void)insertCustomWebserviceResponse:(NSMutableArray *)records_array class_name:(NSString *)class_name method_name:(NSString *)method_name related_record_error:(BOOL)related_record_error request_id:(NSString *)request_id
{
    
    NSMutableDictionary * MasterDetails = [[NSMutableDictionary alloc] initWithCapacity:0];
    for(int i = 0; i< [records_array count]; i++)
    {
        NSDictionary * each_record = [records_array objectAtIndex:i];
        NSString * operation_type = [each_record objectForKey:cw_operation_type];
        NSString * record_type = [each_record objectForKey:cw_record_type];
        NSString * json_string = [each_record objectForKey:cw_json_record];
        NSString * object_name = [each_record objectForKey:cw_object_name];
        NSString * parent_column_name = [each_record objectForKey:cw_parent_colmn_name];
        NSString * parent_object_name = [each_record objectForKey:cw_header_obj_name];
        NSString * local_id = [each_record objectForKey:cw_local_id];
        
        NSMutableDictionary * temp_dict = [self getDictForJsonString:[[NSString alloc] initWithString:json_string]];
        [temp_dict removeObjectForKey:@"attributes"];
        NSString * sf_id = [temp_dict objectForKey:@"Id"];
      
      
        if(![record_type isEqualToString:@"RELATED_REC"])
        {
            if([operation_type isEqualToString:INSERT])
            {
                if([local_id length] > 0)
                {
                    if([record_type isEqualToString:DETAIL])
                    {
                        [temp_dict removeObjectForKey:parent_column_name];
                    }
                    BOOL  update_flag = [self UpdateTableforId:local_id forObject:object_name data:temp_dict];
                    if(update_flag){}
                }
                else
                {
					//Check if entry exists
					BOOL check = [appDelegate.dataBase checkIfRecordExistForObject:object_name Id:sf_id];
					
					if (check)
					{
                        //SUCCESSIVE_SYNC - overide update to DB after TxFetch
                        [self overrideResponseData:temp_dict ForsfId:sf_id ObjectName:object_name];

                        
						[self UpdateTableforSFId:sf_id forObject:object_name data:temp_dict];
					}
					else
					{
                        // Mem_leak_fix - Vipindas 9493 Jan 18
						NSString * new_local_id = [[AppDelegate GetUUID] retain];
						if ([record_type isEqualToString:DETAIL])
						{
							NSString * parent_sf_id = @"";
							parent_sf_id = [temp_dict objectForKey:parent_column_name];
							NSString * parent_local_id = [self getLocalIdFromSFId:parent_sf_id tableName:parent_object_name];
							[temp_dict setObject:parent_local_id forKey:parent_column_name];
						}
						[temp_dict setObject:new_local_id forKey:@"local_id"];
						BOOL insert_flag = [self insertdataIntoTable:object_name data:temp_dict];
                        [new_local_id release];
						if(insert_flag){}
					}
                   
                }
            }
            else if([operation_type isEqualToString:UPDATE])
            {
                BOOL id_exist = [appDelegate.dataBase checkIfRecordExistForObject:object_name Id:sf_id];
                if(!id_exist)
                {
                    // Mem_leak_fix - Vipindas 9493 Jan 18
                    NSString * new_local_id = [[AppDelegate GetUUID] retain];
                    if ([record_type isEqualToString:DETAIL])
                    {
                        NSString * parent_sf_id = @"";
                        parent_sf_id = [temp_dict objectForKey:parent_column_name];
                        NSString * parent_local_id = [self getLocalIdFromSFId:parent_sf_id tableName:parent_object_name];
                        [temp_dict setObject:parent_local_id forKey:parent_column_name];
                    }
                    
                    [temp_dict setObject:new_local_id forKey:@"local_id"];
                    BOOL insert_flag = [self insertdataIntoTable:object_name data:temp_dict];
                    
                    if(insert_flag){}
                    [new_local_id release];
                }
                else
                {
                    //SUCCESSIVE_SYNC - overide update to DB after TxFetch
                    [self overrideResponseData:temp_dict ForsfId:sf_id ObjectName:object_name];
                    
                    if([record_type isEqualToString:DETAIL])
                    {
                        [temp_dict removeObjectForKey:parent_column_name];
                    }
                    BOOL flag = [self UpdateTableforSFId:sf_id forObject:object_name data:temp_dict];
                    if(flag){}
                    
                }
            }
            else if([operation_type isEqualToString:DELETE])
            {
                
            }
        }
        else
        {
            if(![operation_type isEqualToString:DELETE])
            {
                BOOL id_exist = [appDelegate.dataBase checkIfRecordExistForObject:object_name Id:sf_id];
            
                //sahana fix for #6951
                BOOL ischild =  [appDelegate.databaseInterface IsChildObject:object_name];
                NSString * parent_object_name = @"", * parent_column_name = @"";
                if(ischild)
                {
                    if([[MasterDetails allKeys] containsObject:object_name])
                    {
                        NSDictionary * detail = [MasterDetails objectForKey:object_name];
                        parent_column_name = [detail objectForKey:PARENT_COLUMN_NAME];
                        parent_object_name = [detail objectForKey:cw_header_obj_name];
                    }
                    else
                    {
                      
                        parent_object_name  = [self getchildInfoFromChildRelationShip:SFCHILDRELATIONSHIP ForChild:object_name field_name:@"parent_name"];
                        parent_column_name = [appDelegate.databaseInterface getParentColumnNameFormChildInfoTable:SFCHILDRELATIONSHIP childApiName:object_name parentApiName:parent_object_name];
                        NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:parent_object_name,parent_column_name, nil] forKeys:[NSArray arrayWithObjects:cw_header_obj_name,PARENT_COLUMN_NAME, nil]];
                        [MasterDetails setObject:dict forKey:object_name];
                        
                    }
                }

                
                if(!id_exist)
                {
                    // Mem_leak_fix - Vipindas 9493 Jan 18
                    NSString * new_local_id = [[AppDelegate GetUUID] retain];
                    [temp_dict setObject:new_local_id forKey:@"local_id"];
                    if(ischild)
                    {
                        NSString * parent_sf_id = [temp_dict objectForKey:parent_column_name];
                        NSString * parent_local_id = [self getLocalIdFromSFId:parent_sf_id tableName:parent_object_name];
                        [temp_dict setObject:parent_local_id forKey:parent_column_name];
                    }
                    BOOL insert_flag = [self insertdataIntoTable:object_name data:temp_dict];
                    if(insert_flag){}
                    
                    // Mem_leak_fix - Vipindas 9493 Jan 18
                    [new_local_id release];
                }
                else
                {
                    if(ischild)
                    {
                        [temp_dict removeObjectForKey:parent_column_name];
                    }
                    BOOL flag = [self UpdateTableforSFId:sf_id forObject:object_name data:temp_dict];
                    if(flag){}
                }
            }
            else
            {
                [self DeleterecordFromTableWithSf_Id:object_name sf_id:sf_id withColumn:@"Id"];
            }
        }
    }
    //SUCCESSIVE_SYNC - overide update to DB after TxFetch
    [self updateSuccessiveSyncRecordsAfterTxFetch];
    if(!related_record_error)
    {
        [self deletecustomWebservicefrom_detailTrailer_for_request_id:request_id table_name:SFDATATRAILER];
    }
    
    [MasterDetails release];
}

-(void)insertCustomWebserviceResponsewithError:(NSMutableArray *)error_list class_name:(NSString *)class_name method_name:(NSString *)method_name related_record_error:(BOOL)related_record_error request_id:(NSString *)request_id;
{
    for(int i =0; i < [error_list count]; i++)
    {
        NSDictionary * dict = [error_list objectAtIndex:i];
        NSString * local_id =[dict objectForKey:cw_local_id];
        NSString * sf_id = [dict objectForKey:cw_sf_id];
        NSString * error_type = [dict objectForKey:cw_error_type];
        NSString * error_msg = [dict objectForKey:cw_error_mesg];
        NSString * object_name = [dict objectForKey:cw_object_name];
        NSString * record_type = [dict objectForKey:cw_record_type];
        NSString * custom_error_type = [dict objectForKey:cw_custom_error_type];
        NSString * operation_type = [dict objectForKey:cw_operation_type];
        
        NSString * final_operation_type = @"";
        
        if([operation_type isEqualToString:INSERT])
        {
            final_operation_type = PUT_INSERT;
        }
        else if([operation_type isEqualToString:UPDATE])
        {
            final_operation_type = PUT_UPDATE;
        }
        else if([operation_type isEqualToString:DELETE])
        {
            final_operation_type = PUT_DELETE;
        }
        
        if([sf_id length] == 0)
        {
            sf_id = [self getSfid_For_LocalId_From_Object_table:object_name local_id:local_id];
        }
        
        [self insertIntoConflictTable_forlocal_id:local_id sf_id:sf_id class_name:class_name method_name:method_name error_type:error_type error_message:error_msg custom_service:custom_error_type request_id:request_id record_type:record_type object_name:object_name operation_type:final_operation_type];
        
    }
}

-(NSString *)errorTypeOfrRequestId:(NSString *)request_id
{
    NSString * query = [NSString stringWithFormat:@"SELECT custom_ws_error FROM '%@' WHERE request_id = '%@'",SYNC_ERROR_CONFLICT,request_id];
    sqlite3_stmt * statement ;
    
    NSString * custom_ws_error = @"";
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, nil) ==  SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            char * temp_header_local_id = (char * ) synchronized_sqlite3_column_text(statement, 0);
            if(temp_header_local_id != nil)
            {
                custom_ws_error  = [NSString stringWithUTF8String:temp_header_local_id];
            }
           
        }
    }
    synchronized_sqlite3_finalize(statement);
    return custom_ws_error;
}
-(BOOL)doesRequestIdExistsintable:(NSString *)table_name request_id:(NSString *)request_id error_type:(NSString *)error_type
{
    BOOL record_exists = FALSE;
    int count = 0;
    sqlite3_stmt * statement ;
    NSString * select = [NSString stringWithFormat:@"SELECT COUNT(*) FROM '%@' WHERE request_id = '%@' and custom_ws_error = '%@' ",table_name,request_id,error_type];
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [select UTF8String], -1, &statement, nil) ==  SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
          count = synchronized_sqlite3_column_int(statement, 0);
        }
    }
     synchronized_sqlite3_finalize(statement);
    
    if(count > 0)
    {
        record_exists = TRUE;
    }
    else
    {
        record_exists = FALSE;
    }
    return record_exists;
}


-(BOOL)DoesTrailerContainTheRecordForSf_id:(NSString *)sf_id  operation_type:(NSString *)operation_type  object_name:(NSString *)object_name
{
    NSString * query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM '%@' WHERE object_name = '%@' and operation = '%@' and sf_id = '%@'" ,SFDATATRAILER ,object_name , operation_type , sf_id ];
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


-(void)deleteCustomWebserviceEntriesFromSyncHeap:(NSMutableArray *)custom_entries
{
    NSMutableString  * request_ids_str = [[NSMutableString alloc] initWithCapacity:0];
    for(int count = 0;count < [custom_entries count] ; count++)
    {
        NSString * request_id = [custom_entries objectAtIndex:count];
        if(count == 0)
        {
            [request_ids_str appendFormat:@"'%@'",request_id];
        }else{
            [request_ids_str appendFormat:@" , '%@'",request_id];
        }
    }
    
    if([request_ids_str length] >0)
    {
        
        NSString * deleteQuery = [NSString stringWithFormat:@"Delete from %@ where sf_id in (%@)  AND sync_type = '%@'", SYNC_RECORD_HEAP,request_ids_str,GET_UPDATE];
        SMLog(kLogLevelVerbose,@"customws_%@", deleteQuery);
        char * err;
        
        if(synchronized_sqlite3_exec(appDelegate.db, [deleteQuery UTF8String],NULL, NULL, &err) != SQLITE_OK)
        {
            SMLog(kLogLevelError,@"%@", deleteQuery);
            SMLog(kLogLevelError,@"METHOD: deleteCustomWebserviceEntriesFromSyncHeap");
            SMLog(kLogLevelError,@"ERROR IN Delete %s", err);
        }
    }
    
    [request_ids_str release];
}

//Get the sf_id for process_unique id
-(NSString *)getProcessSfIdForProcess_uniqueName:(NSString *)process_id
{
    
    NSString * query = [NSString stringWithFormat:@"SELECT sfID FROM '%@' WHERE process_id = '%@'",SFPROCESS,process_id];
    sqlite3_stmt * statement ;
    
    NSString * process_sf_id = @"";
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, nil) ==  SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            char * temp_process_sf_id= (char * ) synchronized_sqlite3_column_text(statement, 0);
            if(temp_process_sf_id != nil)
            {
                process_sf_id  = [NSString stringWithUTF8String:temp_process_sf_id];
            }
            
        }
    }
    synchronized_sqlite3_finalize(statement);
    return process_sf_id;
}
//  Unused Methods
//-(NSString *)getProcessNameForProcessSfId:(NSString *)process_sf_id 
//{
//    NSString * query = [NSString stringWithFormat:@"SELECT process_id FROM '%@' WHERE sfID = '%@'",SFPROCESS,process_sf_id];
//    sqlite3_stmt * statement ;
//    
//    NSString * process_id = @"";
//    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, nil) ==  SQLITE_OK)
//    {
//        while (synchronized_sqlite3_step(statement) == SQLITE_ROW)
//        {
//            char * temp_process_id= (char * ) synchronized_sqlite3_column_text(statement, 0);
//            if(temp_process_id != nil)
//            {
//                process_id  = [NSString stringWithUTF8String:temp_process_id];
//            }
//        }
//    }
//    synchronized_sqlite3_finalize(statement);
//    return process_sf_id;
//
//}
-(NSString *)getProcessNodeIdForLayoutId:(NSString *)layout_id process_id:(NSString *)process_unique_id
{
    
    NSString * query = [NSString stringWithFormat:@"SELECT process_node_id FROM '%@' WHERE layout_id = '%@'  and process_id = '%@'",SFPROCESSCOMPONENT,layout_id,process_unique_id];
    sqlite3_stmt * statement ;
    
    NSString * ProcessNodeId = @"";
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, nil) ==  SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            char * temp_ProcessNodeId= (char * ) synchronized_sqlite3_column_text(statement, 0);
            if(temp_ProcessNodeId != nil)
            {
                if([ProcessNodeId length] == 0)
                {
                    ProcessNodeId  = [NSString stringWithUTF8String:temp_ProcessNodeId];
                }
            }
        }
    }
    synchronized_sqlite3_finalize(statement);
    return ProcessNodeId;
}

-(NSArray *)getLinkedProcessIdsForProcess_node_id:(NSString *)Processnode_id  process_sf_id:(NSString *)process_sf_id
{
    NSMutableArray * linked_process_ids = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    NSString * query = [NSString stringWithFormat:@"SELECT target_header FROM '%@' WHERE source_header = '%@' and source_detail = '%@' ",LINKED_SFMProcess,process_sf_id,Processnode_id];
    sqlite3_stmt * statement ;
    
    NSString * linked_process_id = @"";
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, nil) ==  SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            char * temp_linked_process_id= (char * ) synchronized_sqlite3_column_text(statement, 0);
            if(temp_linked_process_id != nil)
            {
                    linked_process_id  = [NSString stringWithUTF8String:temp_linked_process_id];
            }
            
            if([linked_process_id length] != 0 || linked_process_ids != nil)
            {
                [linked_process_ids addObject:linked_process_id];
            }
            
            linked_process_id = @"";
        }
    }
    synchronized_sqlite3_finalize(statement);
    return linked_process_ids;
}

-(NSArray *)getAllProcessId_forProcess_sf_id:(NSArray *)process_sf_id
{
    NSMutableArray * process_ids = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    NSMutableString * list_of_process_sf_ids = [[NSMutableString alloc] initWithCapacity:0];
    
    for(int count =0; count < [process_sf_id count]; count++)
    {
       NSString * linked_process =  [process_sf_id objectAtIndex:count];
        if(count != 0)
        {
            [list_of_process_sf_ids appendString:@","];
        }
        [list_of_process_sf_ids appendFormat:@"'%@'",linked_process];
    }
    
    NSString * query = [NSString stringWithFormat:@"SELECT process_id , process_name FROM '%@' WHERE  sfID  in (%@) ",SFPROCESS,list_of_process_sf_ids];
    sqlite3_stmt * statement ;
    
    NSString * linked_process_id = @"" , * linked_process_name = @"";
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, nil) ==  SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            char * temp_linked_process_id= (char * ) synchronized_sqlite3_column_text(statement, 0);
            if(temp_linked_process_id != nil)
            {
                linked_process_id  = [NSString stringWithUTF8String:temp_linked_process_id];
            }
            
            char * temp_linked_process_name = (char * ) synchronized_sqlite3_column_text(statement, 1);
            if(temp_linked_process_name != nil)
            {
                linked_process_name  = [NSString stringWithUTF8String:temp_linked_process_name];
            }
            
            if([linked_process_id length] != 0 || linked_process_id != nil)
            {
                
                NSMutableDictionary * dict = [NSMutableDictionary dictionary];
                [dict setObject:(linked_process_name != nil)?linked_process_name:@"" forKey:linked_process_id];
                [process_ids addObject:dict];
            }
            
            linked_process_id = @"", linked_process_name = @"";
        }
    }
    synchronized_sqlite3_finalize(statement);
    [list_of_process_sf_ids release];
    return process_ids;
}
-(NSString *)getObjectNameForProcessId:(NSString *)process_id
{
    NSString * query = [NSString stringWithFormat:@"SELECT object_api_name FROM '%@' WHERE process_id = '%@' ",SFPROCESS,process_id];
    sqlite3_stmt * statement ;
    
    NSString * object_name = @"";
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, nil) ==  SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            char * temp_linked_process_id= (char * ) synchronized_sqlite3_column_text(statement, 0);
            if(temp_linked_process_id != nil)
            {
                object_name  = [NSString stringWithUTF8String:temp_linked_process_id];
            }
            
        }
    }
    synchronized_sqlite3_finalize(statement);
    return object_name;

}


// Vipin - Shra-lookup


#pragma mark - Look up filters 
- (NSArray *)getLookupfiltersForNamedSearchId:(NSString *)namedSearchId andfilterType:(NSString *)filterType {
    
        /* Get all the main filters from SFNamedSearchFilters depending on the rule type */
        NSArray *lookupFilters = [self getAllSearchCriteriaForId:namedSearchId andFilterType:filterType];
    
        /* For each of the main filters , get expression components */
    
        if ([filterType isEqualToString:kLOOKUP_ADVANCED_FILTER]) {
            for (int counter = 0; counter < [lookupFilters count]; counter++) {
                SVMXLookupFilter *aFilter = [lookupFilters objectAtIndex:counter];
                NSString *objectName = aFilter.sourceObjectName;
                NSInteger fieldCount = [self getFieldCountForObject:objectName];
                
                if (fieldCount < 2) {
                    aFilter.objectPermission = NO;
                }
                else {
                    aFilter.objectPermission = YES;
                }
            }
        }
        return lookupFilters;
}

- (NSMutableArray *)getAllSearchCriteriaForId:(NSString *)namedSearchId andFilterType:(NSString *)filterType {
   
    NSString *sqlQuery = [NSString stringWithFormat:@"Select Id, name, named_search_id, rule_type, parent_object_criteria, source_object_name, field_name, sequence, advanced_expression, allow_override, default_on, description from SFNamedSearchFilters where rule_type = '%@' AND  named_search_id = '%@'", filterType,namedSearchId];
    sqlite3_stmt *selectStatement = nil;
     int i = 0;
     NSMutableArray *finalArray = [[NSMutableArray alloc] init];
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sqlQuery UTF8String], -1, &selectStatement, nil) == SQLITE_OK  )
    {
        while(synchronized_sqlite3_step(selectStatement) == SQLITE_ROW)
        {
            i = 0;
            SVMXLookupFilter *lookupfilter = [[SVMXLookupFilter alloc] init];
            NSString *valueString = nil;
            char *tempCharStr = (char *)sqlite3_column_text(selectStatement,i);
            if (tempCharStr != NULL) {
                valueString = [NSString stringWithUTF8String:tempCharStr];
                lookupfilter.identifier = valueString;
            }
            
            valueString = nil; tempCharStr = NULL;i++;
            tempCharStr = (char *)sqlite3_column_text(selectStatement,i);
            if (tempCharStr != NULL) {
                valueString = [NSString stringWithUTF8String:tempCharStr];
                lookupfilter.name = valueString;
            }
            
            valueString = nil; tempCharStr = NULL;i++;
            tempCharStr = (char *)sqlite3_column_text(selectStatement,i);
            if (tempCharStr != NULL) {
                valueString = [NSString stringWithUTF8String:tempCharStr];
                lookupfilter.namedSearchId = valueString;
            }
            
            valueString = nil; tempCharStr = NULL;i++;
            tempCharStr = (char *)sqlite3_column_text(selectStatement,i);
            if (tempCharStr != NULL) {
                valueString = [NSString stringWithUTF8String:tempCharStr];
                lookupfilter.ruleType = valueString;
            }
            
            valueString = nil; tempCharStr = NULL;i++;
            tempCharStr = (char *)sqlite3_column_text(selectStatement,i);
            if (tempCharStr != NULL) {
                valueString = [NSString stringWithUTF8String:tempCharStr];
                lookupfilter.parentObjectCriteria = valueString;
            }
            
            valueString = nil; tempCharStr = NULL;i++;
            tempCharStr = (char *)sqlite3_column_text(selectStatement,i);
            if (tempCharStr != NULL) {
                valueString = [NSString stringWithUTF8String:tempCharStr];
                lookupfilter.sourceObjectName = valueString;
            }
            
            valueString = nil; tempCharStr = NULL;i++;
            tempCharStr = (char *)sqlite3_column_text(selectStatement,i);
            if (tempCharStr != NULL) {
                valueString = [NSString stringWithUTF8String:tempCharStr];
                lookupfilter.fieldName = valueString;
            }
            
            valueString = nil; tempCharStr = NULL;i++;
            tempCharStr = (char *)sqlite3_column_text(selectStatement,i);
            if (tempCharStr != NULL) {
                valueString = [NSString stringWithUTF8String:tempCharStr];
                lookupfilter.sequence = [valueString intValue];
            }
            
            valueString = nil; tempCharStr = NULL;i++;
            tempCharStr = (char *)sqlite3_column_text(selectStatement,i);
            if (tempCharStr != NULL) {
                valueString = [NSString stringWithUTF8String:tempCharStr];
                lookupfilter.advancedExpressions = valueString;
            }
            
            valueString = nil; tempCharStr = NULL;i++;
            tempCharStr = (char *)sqlite3_column_text(selectStatement,i);
            if (tempCharStr != NULL) {
                valueString = [NSString stringWithUTF8String:tempCharStr];
                if ([Utility isItTrue:valueString]) {
                    lookupfilter.isDefaultOn = YES;
                }
                else {
                    lookupfilter.isDefaultOn = NO;
                }
                
            }
            
            valueString = nil; tempCharStr = NULL;i++;
            tempCharStr = (char *)sqlite3_column_text(selectStatement,i);
            if (tempCharStr != NULL) {
                valueString = [NSString stringWithUTF8String:tempCharStr];
                if ([Utility isItTrue:valueString]) {
                    lookupfilter.allowOverride = YES;
                }
                else {
                    lookupfilter.allowOverride = NO;
                }
            }
            
            valueString = nil; tempCharStr = NULL;i++;
            tempCharStr = (char *)sqlite3_column_text(selectStatement,i);
            if (tempCharStr != NULL) {
                valueString = [NSString stringWithUTF8String:tempCharStr];
                lookupfilter.description = valueString;
            }
            
            [finalArray addObject:lookupfilter];
            [lookupfilter release];
            lookupfilter = nil;
        }
    }
    synchronized_sqlite3_finalize(selectStatement);
    return [finalArray autorelease];
}

#pragma mark -  Advanced filters
- (NSString *)getPreFilters:(NSArray *)preFilters {
    NSMutableString *finalString = [[NSMutableString alloc] init];
     for (int counter = 0; counter < [preFilters count]; counter++) {
         
         SVMXLookupFilter *aFilter = [preFilters objectAtIndex:counter];
         
         NSString *sourceObjectName = aFilter.sourceObjectName;
         NSString *identifier = aFilter.identifier;
         NSString *advancedExpression  = nil;
        
         if (![Utility isStringEmpty:aFilter.advancedExpressions]) {
             advancedExpression =  [NSString stringWithFormat:@"( %@ )",aFilter.advancedExpressions];
         }
         else {
             /* If expression is not there */
             advancedExpression =  [self getAdvanceExpressionComponentExpressionId:identifier];
         }
          NSString *criteriaString =  [self queryForExpressionComponent:advancedExpression expressionId:identifier object_name:sourceObjectName];
         if ([Utility isStringEmpty:criteriaString]) {
             continue;
         }
         if (counter ==  ([preFilters count] - 1)) {
               [finalString appendFormat:@"%@",criteriaString];
         }
         else{
               [finalString appendFormat:@" %@  AND ",criteriaString];
         }
       

     }
    return [finalString autorelease];
}
- (NSArray *)getFilterStringArrayForAdvancedFilters:(NSArray *)filters {
   
    NSMutableArray *queryArray = [[NSMutableArray alloc] init];
    for (int counter = 0; counter < [filters count]; counter++) {
        
        SVMXLookupFilter *aFilter = [filters objectAtIndex:counter];
        if (!aFilter.isDefaultOn || !aFilter.objectPermission) {
            continue;
        }
        NSString *sourceObjectName = aFilter.sourceObjectName;
        NSString *identifier = aFilter.identifier;
        NSString *advancedExpression  = nil;
        
       
        if (![Utility isStringEmpty:aFilter.advancedExpressions]) {
            advancedExpression =  [NSString stringWithFormat:@"( %@ )",aFilter.advancedExpressions];
        }
        else {
            /* If expression is not there */
           advancedExpression =  [self getAdvanceExpressionComponentExpressionId:identifier];
        }
        
        NSString *criteriaString =  [self queryForExpressionComponent:advancedExpression expressionId:identifier object_name:sourceObjectName];
        NSString *queryString = [NSString stringWithFormat:@"SELECT %@ FROM '%@' ",aFilter.fieldName,sourceObjectName];
        if (![Utility isStringEmpty:criteriaString]) {
            queryString = [queryString stringByAppendingFormat:@" WHERE %@",criteriaString];
        }
        
        [queryArray addObject:queryString];
    }
    return [queryArray autorelease];
}
//  Unused Methods
//- (NSArray *)getIdsFromObjectName:(NSString *)objectName withCriteria:(NSString *)criteria andFieldName:(NSString *)fieldName {
//    
//    NSString *queryString = [NSString stringWithFormat:@"SELECT %@ FROM %@ ",fieldName,objectName];
//    if (![Utility isStringEmpty:criteria]) {
//        queryString = [queryString stringByAppendingFormat:@" WHERE %@",criteria];
//    }
//    sqlite3_stmt *selectStatement = nil;
//    NSMutableArray *finalArray = [[NSMutableArray alloc] init];
//    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [queryString UTF8String], -1, &selectStatement, nil) == SQLITE_OK  )
//    {
//        while(synchronized_sqlite3_step(selectStatement) == SQLITE_ROW)
//        {
//           
//            NSString *valueString = nil;
//            char *tempCharStr = (char *)sqlite3_column_text(selectStatement,0);
//            if (tempCharStr != NULL) {
//                valueString = [NSString stringWithUTF8String:tempCharStr];
//               
//            }
//            if (valueString != nil) {
//                [finalArray addObject:valueString];
//            }
//        }
//    }
//    synchronized_sqlite3_finalize(selectStatement);
//    return [finalArray autorelease];
//}


- (NSString *)queryForExpressionComponent:(NSString *)expression expressionId:(NSString *)expression_id object_name:(NSString *)object_name {
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
    NSString * retExpression = @"";
    @try
    {
        
        for(int i = 0 ; i<[array count]; i++)
        {
            NSString * str = [array objectAtIndex:i];
            str = [str  stringByReplacingOccurrencesOfString:@" " withString:@""];
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
            
            
            NSString * query = [NSString stringWithFormat:@"SELECT component_lhs , component_rhs , operator  FROM '%@' where expression_id = '%@'  and component_sequence_number = '%@' GROUP BY component_sequence_number",SFEXPRESSION_COMPONENT, expression_id ,appended_component_number];
            
            //SMLog(kLogLevelVerbose,@"%@", query);
            SMLog(kLogLevelVerbose,@"%@",query);
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
                    
                    char * operator = (char *)synchronized_sqlite3_column_text(stmt, 2);
                    if(operator != nil)
                    {
                        component_operator = [NSString stringWithUTF8String:operator];
                    }
                    
                    char * rhs = (char *)synchronized_sqlite3_column_text(stmt, 1);
                    if(rhs != nil)
                    {
                        component_rhs = [NSString stringWithUTF8String:rhs];
                        
                        if ([component_rhs isEqualToString:@"SVMX.CURRENTUSER"] || [component_rhs Contains:@"SVMX.OWNER"]) {
                            
                            component_rhs = [self getUserNameofLoggedInUser];
                        }
                        else {
                            if ([component_rhs isEqualToString:SVMX_USER_TRUNK] ) {
                                component_rhs = [appDelegate.dataBase getTechnicianLocation];
                                
                                if ([Utility isStringEmpty:component_rhs]) {
                                    component_rhs = SVMX_USER_TRUNK;
                                }
                            }
                            else if ([Utility containsString:CURRENTRECORD inString:component_rhs] && ![component_operator isEqualToString:@"in"] && ![component_operator isEqualToString:@"notin"]) {
                               
                                component_rhs = [self getLiteralValue:component_rhs];
                            }
                        }
                        component_rhs = [component_rhs stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                    }
                    
                   if ([component_rhs isEqualToString:SVMX_USER_TRUNK]) {
                        component_rhs = SVMX_USER_TRUNK;
                        component_operator = @"LIKE";
                        operator_ = @" LIKE ";
                    }
                    if([component_lhs length] != 0 && [component_operator length] != 0)
                    {
                        
                        SMLog(kLogLevelVerbose,@"component_operator %@",component_operator);
                        
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
                            NSString * temp = [NSString stringWithFormat:@"%@%%",component_rhs];
                            component_rhs = [temp retain];
                        }
                        else if([component_operator  isEqualToString:@"isnull"])
                        {
                            lhs_value = component_lhs;
                            component_lhs = [NSString stringWithFormat:@"%@", component_lhs];
                            operator_ = @"=";
                            component_rhs = @"null";
                        }
                        
                        SMLog(kLogLevelVerbose,@"%@" ,operator_ );
                        
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
                                    
                                    if ([value isEqualToString:@"SVMX.CURRENTUSER"] || [value Contains:@"SVMX.OWNER"]) {
                                        
                                        value = [self getUserNameofLoggedInUser];
                                        value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                                    }
                                    else {
                                        if ([value isEqualToString:SVMX_USER_TRUNK]) {
                                            value = [appDelegate.dataBase getTechnicianLocation];
                                            value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                                            if ([Utility isStringEmpty:value]) {
                                                value = SVMX_USER_TRUNK;
                                            }
                                        }
                                        else if ([Utility containsString:CURRENTRECORD inString:value]) {
                                            
                                            value = [self getLiteralValue:value];
                                            value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                                        }
                                    }
                                    
                                    NSString * seq = [NSString stringWithFormat:@"%d",count];
                                    NSMutableString * temp = [[NSMutableString alloc] initWithCapacity:0];
                                    [temp appendString:@"%"];
                                    [temp appendFormat:@"%@",value];
                                    [temp appendString:@"%"];
                                    
                                    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:component_lhs,temp,operator_ ,seq,nil] forKeys:keys];
                                    NSMutableDictionary * component_dict = [NSMutableDictionary dictionaryWithObject:dict forKey:component_number];
                                    [final_Comonent_array addObject:component_dict];
                                    
                                    [temp release];
                                    temp = nil;
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
                        SMLog(kLogLevelVerbose,@"%@",expression_);
                    }
                }
            }
            synchronized_sqlite3_finalize(stmt);
            
        }
        
        SMLog(kLogLevelVerbose,@" final component array %@",final_Comonent_array);
        
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
                //Major Change for Sorting lines
                //**********************************************************
                NSString * temp_lhs = [values_dict objectForKey:@"component_lhs"];
                NSString * lhs = [NSString  stringWithFormat:@"'%@'.%@",object_name,temp_lhs];
                //**********************************************************
                
                
                NSString * rhs = [values_dict objectForKey:@"component_rhs"];
                NSString * operator = [values_dict objectForKey:@"component_operator"];
                NSString * sequence = [values_dict objectForKey:@"sequence"];
                
                
                NSString * component_expression = @"";
               
                NSString * data_type = [[appDelegate.databaseInterface getFieldDataType:object_name filedName:temp_lhs] lowercaseString];
                
                if ([data_type isEqualToString:@"date"] || [data_type isEqualToString:@"datetime"]) {
                    BOOL isDateOnly = NO;
                    if ([data_type isEqualToString:@"date"]){
                        isDateOnly = YES;
                    }
                    NSString *newRhsValue = rhs;
                    if([rhs caseInsensitiveCompare:MACRO_NOW]== NSOrderedSame)
                    {
                        newRhsValue = [Utility today:0 andJusDate:isDateOnly];
                    }
                    else if([rhs caseInsensitiveCompare:MACRO_TODAY]== NSOrderedSame) {
                        newRhsValue = [Utility today:0 andJusDate:YES];
                    }
                    else if([rhs caseInsensitiveCompare:MACRO_TOMMOROW]== NSOrderedSame) {
                        newRhsValue = [Utility today:1 andJusDate:YES];
                    }
                    else if([rhs caseInsensitiveCompare:MACRO_YESTERDAY]== NSOrderedSame) {
                        newRhsValue = [Utility today:-1 andJusDate:YES];
                    }
                    rhs = newRhsValue;
                }
                else if ([data_type isEqualToString:@"boolean"] || [data_type isEqualToString:@"bool"]) {
                    rhs = [rhs lowercaseString];
                    if ([Utility isItTrue:rhs]) {
                        
                        rhs = [rhs stringByReplacingOccurrencesOfString:@"true" withString:@"1" ];
                    }
                    else {
                         rhs = [rhs stringByReplacingOccurrencesOfString:@"false" withString:@"0" ];
                    }
               }
                
                
                // This check is for RecordTypeId
                if([rhs isEqualToString:SVMX_USER_TRUNK]) {
                    component_expression = @" 1 ";
                }
                else if([temp_lhs isEqualToString:@"RecordTypeId"])
                {
                    
                    //5755
                    if([operator isEqualToString:@"isnotnull"]) //#4722 defect fix for wizard billing type null
                    {
                        //7960
                        //  component_expression = [NSString stringWithFormat:@" (length(%@) > 0) ",lhs];
                        component_expression = [NSString stringWithFormat:@"(%@ is not null and  ( trim(%@) != '' ))",lhs,lhs];
                    }
                    else if ([rhs isEqualToString:@"null"])
                    {
                        component_expression = [NSString stringWithFormat:@" ( %@ = ' ' or typeof(%@) %@ '%@' or %@ = '' ) ",lhs,lhs,operator,rhs, lhs];
                    }
                    else
                    {
                        //support for blank rhs. handled record_type and record_type_id = '' and null, for doesnot contain and not equal.
                        if( [operator isEqualToString:@"!="] || [operator isEqualToString:@" NOT LIKE "])
                        {
                            component_expression = [NSString stringWithFormat:@"( %@   in   (select  record_type_id  from SFRecordType where (record_type %@ '%@' or trim(record_type) = '' or   record_type is null )))" ,lhs,operator, rhs];
                            component_expression = [NSString stringWithFormat:@" ( %@ OR  trim(%@) = '' OR %@ is null )",component_expression,lhs,lhs];

                        }
                        else {
                        component_expression = [NSString stringWithFormat:@" %@   in   (select  record_type_id  from SFRecordType where record_type %@ '%@' )" ,lhs,operator, rhs];
                        }
                    }
                    //5755
                    
                }
                else if([data_type isEqualToString:@"reference"])
                {
                    NSString * referenceToTable = [appDelegate.dataBase getReferencetoFiledForObject:object_name api_Name:temp_lhs];
                    NSInteger fieldCount = [self getFieldCountForObject:referenceToTable];
                    
                    if (fieldCount > 1) {
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
                            NSString *nameField = [self getNameFieldForObject:referenceToTable];
                            if ([Utility isStringEmpty:nameField]) {
                                component_expression = [NSString stringWithFormat:@" ( %@   in   (select  Id  from '%@' where ( Name %@ '%@'  OR Id %@ '%@' )) OR %@   in   (select  local_id  from '%@' where (Name %@ '%@'  OR Id %@ '%@')) )" , lhs,referenceToTable , operator ,rhs,operator ,rhs,lhs,referenceToTable , operator ,rhs,operator ,rhs];
                            }
                            else {
                                component_expression = [NSString stringWithFormat:@" ( %@   in   (select  Id  from '%@' where ( %@ %@ '%@'  OR Id %@ '%@') ) OR %@   in   (select  local_id  from '%@' where ( %@ %@ '%@' OR Id %@ '%@')) )" , lhs,referenceToTable , nameField, operator ,rhs,operator ,rhs,lhs,referenceToTable , nameField, operator ,rhs,operator ,rhs];
                            }
                            
                            if ([operator isEqualToString: @"!="] || [operator isEqualToString: @" NOT LIKE "]){
                                component_expression = [NSString stringWithFormat:@"( %@  OR %@ = \"\" OR %@ isnull)",component_expression,lhs,lhs];
                            }
                            
                        }
                    }
                    else {
                        component_expression = @" 1 ";
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
                    
                    //8451- Shravya
                   component_expression = [NSString stringWithFormat:@" ( %@ %@ null or trim(%@) %@ or ( trim(%@) != '') ) ",lhs,operator,lhs,temp_operator, lhs];
                }
               
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
                
                BOOL isIncludeTrue = NO;
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
                                isIncludeTrue = YES;
                                if([operator_ isEqualToString:@" LIKE "])
                                {
                                    component_expression = [component_expression stringByAppendingString:@" OR "];
                                }
                                else
                                {
                                    component_expression = [component_expression stringByAppendingString:@" AND "];
                                }
                                
                                if ([Utility containsString:SVMX_USER_TRUNK inString:rhs_]) {
                                   
                                    component_expression = [component_expression stringByAppendingFormat:@" 1 "];   
                                } else if ([data_type isEqualToString:@"reference"]) {
                                    NSString *newExpression = @"1";
                                    NSString * referenceToTable = [appDelegate.dataBase getReferencetoFiledForObject:object_name api_Name:lhs_];
                                    NSInteger fieldCount = [self getFieldCountForObject:referenceToTable];
                                    
                                    if (fieldCount > 1) {
                                        NSString *nameField = [self getNameFieldForObject:referenceToTable];
                                        NSString *newLhsField = [NSString stringWithFormat:@"'%@'.%@",object_name,lhs_];
                                        if ([Utility isStringEmpty:nameField]) {
                                            newExpression = [NSString stringWithFormat:@" ( %@   in   (select  Id  from '%@' where (Name %@ '%@'  OR Id %@ '%@') ) OR %@   in   (select  local_id  from '%@' where (Name %@ '%@' OR OR Id %@ '%@')) )" , newLhsField,referenceToTable , operator_ ,rhs_,operator_ ,rhs_,newLhsField,referenceToTable , operator_ ,rhs_,operator_ ,rhs_];
                                        }
                                        else {
                                            newExpression = [NSString stringWithFormat:@" (%@   in   (select  Id  from '%@' where ( %@ %@ '%@' OR Id %@ '%@')) OR  %@   in   (select  local_id  from '%@' where ( %@ %@ '%@' OR Id %@ '%@' )) )" , newLhsField,referenceToTable , nameField, operator_ ,rhs_,operator_ ,rhs_,newLhsField,referenceToTable , nameField, operator_ ,rhs_,operator_ ,rhs_];
                                        }
                                        
                                        if ([operator isEqualToString: @"!="] || [operator isEqualToString: @" NOT LIKE "]){
                                            newExpression = [NSString stringWithFormat:@"( %@  OR %@ = \"\" OR %@ isnull)",newExpression,newLhsField,newLhsField];
                                        }
                                    }
                                    else {
                                        newExpression = @" 1 ";
                                    }
                                     component_expression = [component_expression stringByAppendingFormat:@" %@ ",newExpression];   
                                }
                                else {
                                    component_expression = [component_expression stringByAppendingFormat:@"'%@'.%@",object_name,lhs_];
                                    component_expression = [component_expression stringByAppendingString:operator_];
                                    rhs = [NSString stringWithFormat:@"'%@'",rhs_];
                                    component_expression = [component_expression stringByAppendingString:rhs];
                                }
                            }
                        }
                    }
                }
                //for the key concatinate #$ and replace it with the expression
                NSString * concatinate_key = [NSString stringWithFormat:@"#$%@",key];
                SMLog(kLogLevelVerbose,@"%@", component_expression);
                if (isIncludeTrue) {
                    component_expression = [NSString stringWithFormat:@" ( %@ ) ",component_expression];
                    regular_expression = [regular_expression stringByReplacingOccurrencesOfString:concatinate_key withString:component_expression];
                }
                else {
                    regular_expression = [regular_expression stringByReplacingOccurrencesOfString:concatinate_key withString:component_expression];
                }
                
            }
        }
        
        if ([regular_expression length] > 0)
        {
            retExpression = [NSString stringWithFormat:@"(%@)", regular_expression];
        }
        else
        {
            retExpression = [NSString stringWithFormat:@"%@", regular_expression];
        }
    }@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name Database :queryForExpressionComponent %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason Database :queryForExpressionComponent %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
    
    return retExpression;
}

- (NSString *)getAdvanceExpressionComponentExpressionId:(NSString *)expressionId  {
    
    
   NSString * query = [NSString stringWithFormat:@"SELECT DISTINCT component_sequence_number  FROM '%@' where expression_id = '%@'  ORDER BY component_sequence_number",SFEXPRESSION_COMPONENT, expressionId];
    
    SMLog(kLogLevelVerbose,@"%@",query);
    sqlite3_stmt * stmt = nil;
    
    NSMutableString *advancedExpression = [[NSMutableString alloc] init];
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(stmt)  == SQLITE_ROW)
        {
                    
            char * sequence = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if(sequence != nil)
            {
               NSString *sequenceString = [NSString stringWithUTF8String:sequence];
                NSInteger se = [sequenceString intValue];
                if (se >=1 && se < 2) {
                    [advancedExpression appendFormat:@"%d ",se];
                }
                else {
                     [advancedExpression appendFormat:@" AND %d ",se];
                }
            }
       }
    }
    
    NSString *finalString = @"";
    if (![Utility isStringEmpty:advancedExpression]) {
        finalString = [NSString stringWithFormat:@"( %@ )",advancedExpression];
    }
    [advancedExpression release];
    advancedExpression = nil;
    
    synchronized_sqlite3_finalize(stmt);
    return finalString;
}

- (NSString *)getUserNameofLoggedInUser{
    NSString *UserFullName=@"";
   
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([[userDefaults objectForKey:USERFULLNAME] length]>0)
    {
        UserFullName = [userDefaults objectForKey:USERFULLNAME];  //To get user display name not email id
        SMLog(kLogLevelVerbose,@"User Full Name  = %@",UserFullName);
    }
    else
    {
            UserFullName=[appDelegate.dataBase getLoggedInUser:appDelegate.username];
    }
    if (UserFullName == nil) {
         UserFullName = @"";
    }
    return UserFullName;
}

- (NSString*)getNameFieldForObject:(NSString*)objectName {
    NSString *queryStatement1 = [NSMutableString stringWithFormat:@"SELECT api_name FROM SFObjectField where object_api_name = '%@'and (name_field = 'TRUE' OR name_field = 'True' OR name_field = 'true' OR name_field = '1') and api_name != \"\"",objectName];
    sqlite3_stmt * labelstmt = nil;
    char *refrence_to=nil;
    NSString *fieldName = @"";
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement1 UTF8String],-1, &labelstmt, nil) == SQLITE_OK )
    {
        if(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW)
        {
            refrence_to = (char *) synchronized_sqlite3_column_text(labelstmt,0);
            if((refrence_to != nil)&& strlen(refrence_to))
                fieldName = [NSString stringWithUTF8String:refrence_to];
            else
                fieldName = @"";
        }
    }
    sqlite3_finalize(labelstmt);
    return fieldName;
}


- (NSInteger)getFieldCountForObject:(NSString*)objectName {
    NSString *queryStatement1 = [NSMutableString stringWithFormat:@"SELECT count(*) FROM SFObjectField where object_api_name = '%@' and api_name != \"\"",objectName];
    sqlite3_stmt * labelstmt = nil;
   
    NSInteger fieldCount = 0;
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement1 UTF8String],-1, &labelstmt, nil) == SQLITE_OK )
    {
        if(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW)
        {
            fieldCount =  synchronized_sqlite3_column_int(labelstmt,0);
           
        }
    }
    sqlite3_finalize(labelstmt);
    return fieldCount;
}

#pragma mark -
#pragma mark get value for Current record literal
- (NSString *)getLiteralValue:(NSString *)literalValue {
    /*Checking if the CURRENTRECORD and CURRENTRECORD_HEADER literal exists in RHS value*/
   // NSString *jsonRep = [appDelegate.SFMPage JSONRepresentation];
    if (![Utility containsString:CURRENTRECORD inString:literalValue]) {
        return literalValue;
    }
    NSString *fieldValue = @"";
    NSDictionary *indexDictonary =  [appDelegate.sfmPageController.detailView getCurrentSelectedIndex];

    NSInteger isHeader = [[indexDictonary objectForKey:@"isHeader"] intValue];
    NSIndexPath *detailIndexPath = [indexDictonary objectForKey:@"detail"];
    
    
    NSString *processId = appDelegate.sfmPageController.processId;
    SMLog(kLogLevelVerbose,@"Process Id: %@", processId);
    
    NSString *recordId = appDelegate.sfmPageController.recordId;
    SMLog(kLogLevelVerbose,@"recordId Id: %@", recordId);
    
    NSDictionary *currentPageDictionary = appDelegate.SFMPage;
    NSDictionary *headerDictionary = [currentPageDictionary objectForKey:gHEADER];
   
    if (isHeader == 1) {
        
        /*If trying to refer the header of header, then return the literal value */
        if ([Utility containsString:CURRENTRECORD_HEADER inString:literalValue]) {
            return literalValue;
        }
        
        NSArray *componentsArray =  [Utility splitString:literalValue byString:@"."];
        if ([componentsArray count] > 2) {
            NSString *fieldName = [componentsArray objectAtIndex:2];
            
            /* look for field name in the page layout*/
            /* If field value is empty then look into database */
            fieldValue =  [self getFieldValueForFieldName:fieldName fromHeaderSections:headerDictionary andRecordId:recordId];
       }
    }
    else if (isHeader == 2){
        if ([Utility containsString:CURRENTRECORD_HEADER inString:literalValue]) {
            NSArray *componentsArray =  [Utility splitString:literalValue byString:@"."];
            if ([componentsArray count] > 2) {
                NSString *fieldName = [componentsArray objectAtIndex:2];
                /* look for field name in the page layout*/
                /* If field value is empty then look into database */
                fieldValue =  [self getFieldValueForFieldName:fieldName fromHeaderSections:headerDictionary andRecordId:recordId];
            }
        }
        else {
            NSArray *componentsArray =  [Utility splitString:literalValue byString:@"."];
            if ([componentsArray count] > 2) {
                NSString *fieldName = [componentsArray objectAtIndex:2];
                
                NSArray *details = [currentPageDictionary objectForKey:gDETAILS];
                if ([details count] > detailIndexPath.section) {
                    NSDictionary *detailDictionary = [details objectAtIndex:detailIndexPath.section];
                    
                   fieldValue = [self getFieldValueForFieldName:fieldName fromDetailsDictionary:detailDictionary andRecordId:detailIndexPath.row];
                }
           }
        }
    }
   //NSString *jsonRep = [appDelegate.SFMPage JSONRepresentation];
   // SMLog(kLogLevelVerbose,@"JSON: %@",jsonRep);
    SMLog(kLogLevelVerbose,@"%@  fieldValue: %@",literalValue,fieldValue);
    if ([Utility isStringEmpty:fieldValue]) {
        fieldValue = @"";
    }
    return fieldValue;
}

- (NSString *)getFieldValueForFieldName:(NSString *)fieldName fromHeaderSections:(NSDictionary *)headerDictionary andRecordId:(NSString *)recordId{
    
    NSString *headerObjectName = [headerDictionary objectForKey:gHEADER_OBJECT_NAME];
    NSArray *headerSections = [headerDictionary objectForKey:gHEADER_SECTIONS];
    int totalCount = [headerSections count];
    NSString *fieldValue =  nil;
    BOOL isItInPage = NO;
    for (int counter = 0; counter < totalCount; counter++) {
        NSDictionary *sectionFieldDict = [headerSections objectAtIndex:counter];
        NSArray *fieldsArray = [sectionFieldDict objectForKey:gSECTION_FIELDS];
        int fieldLength = [fieldsArray count];
        for (int innerCounter = 0; innerCounter < fieldLength; innerCounter++) {
            NSDictionary *fieldDictionary = [fieldsArray objectAtIndex:innerCounter];
            NSString *fieldApiName = [fieldDictionary objectForKey:gFIELD_API_NAME];
            if ([fieldApiName isEqualToString:fieldName]) {
                fieldValue = [fieldDictionary objectForKey:gFIELD_VALUE_KEY];
                isItInPage = YES;
                 NSString *fieldType =  [fieldDictionary objectForKey:@"Field_Data_Type"];
                if ([[fieldType lowercaseString] isEqualToString:@"boolean"]) {
                    fieldValue = [fieldValue lowercaseString];
                }
            }
        }
    }
    if ([Utility isStringEmpty:fieldValue] && recordId != nil && !isItInPage) {
        fieldValue = [self getValueForField:fieldName objectName:headerObjectName recordId:recordId andWhereField:@"local_id"];
    }
    return fieldValue;
}

- (NSString *)getFieldValueForFieldName:(NSString *)fieldName fromDetailsDictionary:(NSDictionary *)detailDictionary andRecordId:(NSInteger )recordIndex{
    
    NSString *recordLocalId = nil;
    NSArray *fieldsValueArray = nil;
    NSString *fieldValue = nil;
    NSString *detailObjectName = [detailDictionary objectForKey:gDETAIL_OBJECT_NAME];
    BOOL isBoolField = NO;
    BOOL isItInPage = NO;
    
    /* Checking if field type is boolean */
    NSArray *pageFieldsInfo = [detailDictionary objectForKey:gDETAILS_FIELDS_ARRAY];
    for (int counter = 0; counter < [pageFieldsInfo count] ; counter++) {
        NSDictionary *fieldDictionary = [pageFieldsInfo objectAtIndex:counter];
        NSString *fieldApiName = [fieldDictionary objectForKey:gFIELD_API_NAME];
        if ([fieldApiName isEqualToString:fieldName]) {
            isItInPage = YES;
            NSString *fieldType =  [fieldDictionary objectForKey:@"Field_Data_Type"];
            if ([[fieldType lowercaseString] isEqualToString:@"boolean"]) {
                isBoolField = YES;
                break;
            }
        }

    }
    /* Getting local record if of detail record */
    NSArray *detailObjectRecordIdsArray = [detailDictionary objectForKey:gDETAIL_VALUES_RECORD_ID];
    if ([detailObjectRecordIdsArray count] > recordIndex) {
        recordLocalId = [detailObjectRecordIdsArray objectAtIndex:recordIndex];
    }
    
     /* Getting the data record from page   */
    NSArray *valueArray = [detailDictionary objectForKey:gDETAILS_VALUES_ARRAY];
    if ([valueArray count] > recordIndex) {
        fieldsValueArray = [valueArray objectAtIndex:recordIndex];
        
        for (int counter = 0; counter < [fieldsValueArray count]; counter++) {
            NSDictionary *fieldDictionary = [fieldsValueArray objectAtIndex:counter];
            NSString *fieldApiName = [fieldDictionary objectForKey:gVALUE_FIELD_API_NAME];
            if ([fieldApiName isEqualToString:fieldName]) {
                 fieldValue = [fieldDictionary objectForKey:gVALUE_FIELD_VALUE_KEY];
                if (isBoolField) {
                    fieldValue = [fieldValue lowercaseString];
                }
                
            }
        }
    }
    
    if ([Utility isStringEmpty:recordLocalId]) {
        recordLocalId = nil;
    }
      /* if page does not have data , then try the db */
    if ([Utility isStringEmpty:fieldValue] && recordLocalId != nil && !isItInPage) {
         fieldValue = [self getValueForField:fieldName objectName:detailObjectName recordId:recordLocalId andWhereField:@"local_id"];
    }
    
    return fieldValue;
}

- (NSString *)getValueForField:(NSString *)fieldName objectName:(NSString *)objectName recordId:(NSString *)localId andWhereField:(NSString *)whereField
{
    NSString * fieldValue = @"";
    NSString * query = [NSString stringWithFormat:@"SELECT %@ FROM '%@' WHERE %@ = '%@' ",fieldName,objectName,whereField,localId];
    sqlite3_stmt * statement ;
    
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, nil) ==  SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            char * temp_field_value= (char * ) synchronized_sqlite3_column_text(statement, 0);
            if(temp_field_value != nil)
            {
                fieldValue  = [NSString stringWithUTF8String:temp_field_value];
            }
        }
    }
    synchronized_sqlite3_finalize(statement);
    return fieldValue;
}

-(void)replaceCurrentRecordOrheaderLiteral:(NSMutableDictionary * )RecordDict headerRecordId:(NSString *)headerRecordId headerObjectName:(NSString *)headerObjectNAme currentRecordId:(NSString *)currentRecordId currentObjectName:(NSString *)currentObjectName
{
    NSArray * allField_names = [RecordDict allKeys];
    for (NSString * fieldApiName in  allField_names)
    {
        NSString * mappingValue = [RecordDict objectForKey:fieldApiName];
        
        if([mappingValue length] == 0)
        {
            continue;
        }
    
        if([[mappingValue lowercaseString] rangeOfString:[CURRENTRECORD_HEADER lowercaseString]].location != NSNotFound )
        {
            NSString * referenceFieldName = @"";
            NSArray * SeperateComponents = [mappingValue componentsSeparatedByString:@"."];
            
            if([SeperateComponents count] == 3)
            {
                referenceFieldName = [SeperateComponents objectAtIndex:2];
            }
                      
            if([headerRecordId length] != 0)
            {
                //Fix for defect #7811

                NSString * newValue = @"";
                
                newValue = [self getValueForField:referenceFieldName objectName:headerObjectNAme recordId:headerRecordId];

                if([referenceFieldName isEqualToString:@"Id"] && [newValue length] == 0)
                {
                    newValue = headerRecordId;
                }
                
                [RecordDict setObject:newValue forKey:fieldApiName];
            }
            else
            {
                [RecordDict setObject:@"" forKey:fieldApiName];
            }

        }
        else if([[mappingValue lowercaseString] rangeOfString:[CURRENTRECORD lowercaseString]].location != NSNotFound )
        {

            NSString * referenceFieldName = @"";
            NSArray * SeperateComponents = [mappingValue componentsSeparatedByString:@"."];
            
            if([SeperateComponents count] == 3)
            {
                referenceFieldName = [SeperateComponents objectAtIndex:2];
            }
            
            if([allField_names containsObject:referenceFieldName])
            {
                NSString * newValue= [RecordDict objectForKey:referenceFieldName];
                [RecordDict setObject:newValue forKey:fieldApiName];
                
            }
            else if([currentRecordId length] != 0)
            {
                NSString * newValue = [self getValueForField:referenceFieldName objectName:currentObjectName recordId:currentRecordId];
                [RecordDict setObject:newValue forKey:fieldApiName];
            }
            else
            {
                [RecordDict setObject:@"" forKey:fieldApiName];
            }
      
        }

    }
}
-(NSString *)getValueForField:(NSString *)fieldName objectName:(NSString *)objectName recordId:(NSString *)localId
{
    NSString * fieldValue = @"";
    //Aparna: FORMFILL
    NSString * query = [NSString stringWithFormat:@"SELECT %@ FROM '%@' WHERE ( local_id = '%@' OR Id = '%@')",fieldName,objectName,localId,localId];
    sqlite3_stmt * statement ;
    
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, nil) ==  SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            char * temp_field_value= (char * ) synchronized_sqlite3_column_text(statement, 0);
            if(temp_field_value != nil)
            {
                fieldValue  = [NSString stringWithUTF8String:temp_field_value];
            }
        }
    }
    synchronized_sqlite3_finalize(statement);
    return fieldValue;
}

-(NSMutableDictionary *)getReferenceToForObjectapiName:(NSString *)objectApiName
{
    NSMutableDictionary * referenceToTableNames = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSString * referencetoName = @"", * field_api_name= @"";
    NSString * query = [NSString stringWithFormat:@"SELECT reference_to,field_api_name FROM '%@' where object_api_name = '%@'" ,SFREFERENCETO,objectApiName ];
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
            
            char * temp_fieldApiName = (char *)synchronized_sqlite3_column_text(stmt, 1);
            if(temp_fieldApiName != nil)
            {
                field_api_name = [NSString stringWithUTF8String:temp_fieldApiName];
            }
            if(![[referenceToTableNames allKeys] containsObject:field_api_name])
            {
                NSMutableArray * reference_objs = [[NSMutableArray alloc] initWithCapacity:0];
                [reference_objs addObject:referencetoName];
                [referenceToTableNames setObject:reference_objs forKey:field_api_name];
                [reference_objs release];
            }
            else
            {
                NSMutableArray * reference_objs = [referenceToTableNames objectForKey:field_api_name];
                [reference_objs addObject:referencetoName];
            }
            
            referencetoName = @"",field_api_name= @"";
        }
    }
    synchronized_sqlite3_finalize(stmt);
    return referenceToTableNames;
}


- (BOOL)checkRecordExistForObject:(NSString *)tableName LocalId:(NSString *)LocalId
{
    NSString * query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM '%@' WHERE local_id = '%@'", tableName, LocalId];
    
    sqlite3_stmt * stmt;
    
    int count = 0;
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            count = synchronized_sqlite3_column_int(stmt, 0);
        }
    }
    
    synchronized_sqlite3_finalize(stmt);
    
    if (count > 0)
        return TRUE;
    else
        return FALSE;
}

-(BOOL)checkSentFlagForReferenceId:(NSString *)loalId forOperation:(NSString *)OperationType
{
    NSString * getcount = [NSString stringWithFormat:@"SELECT COUNT(*) FROM '%@' WHERE local_id = '%@' and operation = '%@' and  record_sent = 'true' " ,SFDATATRAILER_TEMP , loalId , OperationType];
    
    sqlite3_stmt * stmt;
    
    int count = 0;
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [getcount UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            count = synchronized_sqlite3_column_int(stmt, 0);
        }
    }
    
    synchronized_sqlite3_finalize(stmt);
    
    if (count > 0)
        return TRUE;
    else
        return FALSE;
}
-(void)deleteRecordFromConflictTableForRecord:(NSString *)local_id operation:(NSString *)operationType
{
    
    NSString * delete_stmt ;
    
    delete_stmt = [NSString stringWithFormat:@"DELETE FROM '%@'  WHERE sync_type = '%@'  and local_id = '%@'",SYNC_ERROR_CONFLICT,operationType, local_id];
    
    char * err ;
    if(synchronized_sqlite3_exec(appDelegate.db, [delete_stmt UTF8String], NULL, NULL, &err))
    {
        SMLog(kLogLevelError,@"%@", delete_stmt);
		SMLog(kLogLevelError,@"METHOD:deleteRecordFromConflictTableForRecord");
		SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:delete_stmt type:DELETEQUERY];
    }
    
}

-(BOOL)DeleterecordFromDataTrailerTableForlocal_id:(NSString *)local_id
{
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"DeleterecordFromTable"
                                                         andRecordCount:1];
    BOOL success = YES;
    
    // Vipin-db-optmz -rm
    
    NSString * delete_query = [NSString stringWithFormat:@"DELETE FROM '%@' WHERE local_id = '%@' and sync_type != '%@'" ,SFDATATRAILER , local_id ,CUSTOMSYNC];
    
    char * err ;
    if(synchronized_sqlite3_exec(appDelegate.db, [delete_query UTF8String], NULL, NULL, &err))
    {
        SMLog(kLogLevelVerbose,@"%@", delete_query);
		SMLog(kLogLevelVerbose,@"METHOD:DeleterecordFromTable");
		SMLog(kLogLevelVerbose,@"ERROR IN DELETE %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:delete_query type:DELETEQUERY];
        
        success = NO;
    }
    
    [[PerformanceAnalytics sharedInstance] addDeletedRecordsNumber:1];
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"DeleterecordFromTable"
                                                                      andRecordCount:0];
    
    return success;
}
//  Unused Methods
//-(BOOL)DoesEntryExistsForInsertOperationForLocalId:(NSString *)localId
//{
//    NSString * getcount = [NSString stringWithFormat:@"SELECT COUNT(*) FROM '%@' WHERE local_id = '%@' and operation = 'INSERT' " ,SFDATATRAILER , localId];
//    
//    sqlite3_stmt * stmt;
//    
//    int count = 0;
//    
//    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [getcount UTF8String], -1, &stmt, NULL) == SQLITE_OK)
//    {
//        
//        while (sqlite3_step(stmt) == SQLITE_ROW)
//        {
//            count = synchronized_sqlite3_column_int(stmt, 0);
//        }
//    }
//    
//    synchronized_sqlite3_finalize(stmt);
//    
//    if (count > 0)
//        return TRUE;
//    else
//        return FALSE;
//}

-(BOOL)DeleteEntryFromDataTrailerTableFor:(NSString *)Id forObject:(NSString *)object  sync_type:(NSString *)sync_type fieldName:(NSString *)fieldName
{
    
    BOOL success = YES;
     
    if([sync_type isEqualToString:PUT_INSERT])
    {
        sync_type = INSERT;
    }
    else if([sync_type isEqualToString:PUT_UPDATE])
    {
        sync_type = UPDATE;
    }
    else if ([sync_type isEqualToString:PUT_DELETE ])
    {
        sync_type = DELETE;
    }
    
    NSString * update = @"";
    update = [NSString stringWithFormat:@"DELETE FROM '%@' WHERE  %@ = '%@' and object_name = '%@' and operation = '%@' ", SFDATATRAILER,fieldName,Id,object,sync_type ];
    
    char * err;
    if (synchronized_sqlite3_exec(appDelegate.db, [update UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
		SMLog(kLogLevelError,@"%@", update);
		SMLog(kLogLevelError,@"DeleteEntryFromDataTrailerTableFor");
		SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:update type:DELETEQUERY];
        success = NO;
    }
    return success;
}
-(void)replaceCURRENTRECORDLiteral:(NSMutableDictionary *)detailDict sourceDict:(NSDictionary *)sourceDict
{
    NSArray * allkeys = [detailDict allKeys];
    for(NSString * fieldApi in allkeys)
    {
        NSString * fieldValue = [detailDict objectForKey:fieldApi];
        if([fieldValue length] == 0)
        {
            continue;
        }
        if([self findLiteral:fieldValue literal:CURRENTRECORD] || [self findLiteral:fieldValue literal:CURRENTRECORD_HEADER])
        {
            if([self findLiteral:fieldValue literal:CURRENTRECORD_HEADER])
            {
                NSString * sourceFieldName = [self getFieldApiNameFromString:fieldValue forLiteral:CURRENTRECORD];
                if([sourceFieldName length] != 0)
                {
                    NSString * sourceFieldValue = ([sourceDict objectForKey:sourceFieldName]!=nil)?[sourceDict objectForKey:sourceFieldName]:@"";
                    if([sourceFieldValue length] != 0)
                    {
                      [detailDict setObject:sourceFieldValue forKey:fieldApi];
                    }
                    else
                    {
                        NSString *recordId = appDelegate.sfmPageController.recordId;
                        if([recordId length] != 0)
                        {
                            NSDictionary *currentPageDictionary = appDelegate.SFMPage;
                            NSDictionary *headerDictionary = [currentPageDictionary objectForKey:gHEADER];
                            NSString * headerObjName = [headerDictionary objectForKey:gHEADER_OBJECT_NAME];
                            NSString * newValue = @"";
                            
                            //Fix for defect #7811
                            newValue = [self getValueForField:sourceFieldName objectName:headerObjName recordId:recordId];
                            if([sourceFieldName isEqualToString:@"Id"] && [newValue length] == 0)
                            {
                                newValue = recordId;
                            }
                            [detailDict setObject:newValue forKey:fieldApi];
                        }
                        else
                        {   
                            [detailDict setObject:@"" forKey:fieldApi];
                        }
                    }
                }
            }
            else if([self findLiteral:fieldValue literal:CURRENTRECORD])
            {
                [detailDict setObject:@"" forKey:fieldApi];
            }
        }
    }
}

-(BOOL)findLiteral:(NSString *)FieldValue literal:(NSString *)literal
{
    BOOL flag = FALSE;
    if([[FieldValue lowercaseString] rangeOfString:[literal lowercaseString]].location != NSNotFound )
    {
        flag = TRUE;
    }
    return flag;
}
-(NSString *)getFieldApiNameFromString:(NSString *)valueString forLiteral:(NSString *)literal
{
   NSArray * componentArray = [Utility splitString:valueString byString:@"."];
    NSInteger count = [componentArray count];
     NSString * fieldName = @"";
    if(count != 0)
    {
        fieldName = [componentArray objectAtIndex:count-1];
    }
    return fieldName;
}

#pragma mark -
#pragma mark FORMFILL
//Aparna: FORMFILL
//8013 : Added new method
- (NSDictionary *)objectMappingInfoForMappingId:(NSString *)mappingId
{
    NSMutableDictionary *objMappingDict = [NSMutableDictionary dictionary];
    
    sqlite3_stmt * stmt;
    NSString *selectQuery = [NSString stringWithFormat:@"SELECT %@ , %@, %@ From %@ WHERE %@ = '%@'",TARGET_OBJECT_NAME, SOURCE_OBJECT_NAME, OBJECT_MAPPING_ID, OBJECT_MAPPING, OBJECT_MAPPING_ID, mappingId];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * targetObjNameChar= (char *) synchronized_sqlite3_column_text(stmt, 0);
            if ((targetObjNameChar != nil) && strlen(targetObjNameChar))
            {
                NSString *targetObjName = [NSString stringWithUTF8String:targetObjNameChar];
                [objMappingDict setValue:targetObjName forKey:TARGET_OBJECT_NAME];
            }
            
            char * sourceObjNameChar= (char *) synchronized_sqlite3_column_text(stmt, 1);
            if ((sourceObjNameChar != nil) && strlen(sourceObjNameChar))
            {
                NSString *sourceObjName = [NSString stringWithUTF8String:sourceObjNameChar];
                [objMappingDict setValue:sourceObjName forKey:SOURCE_OBJECT_NAME];
            }
            
            char * objMappingIdChar = (char *) synchronized_sqlite3_column_text(stmt, 2);
            if ((objMappingIdChar != nil) && strlen(objMappingIdChar))
            {
                NSString *objMappingId = [NSString stringWithUTF8String:objMappingIdChar];
                [objMappingDict setValue:objMappingId forKey:OBJECT_MAPPING_ID];
            }
            
        }
    }
    synchronized_sqlite3_finalize(stmt);
    return objMappingDict;
}



- (NSArray *) objectMappingComponentInfoForMappingId:(NSString *)mappingId
{
    NSMutableArray *objMappingCompInfoArray = [NSMutableArray array];
    
    sqlite3_stmt * stmt;
    
    //Aparna: FORMFILL (ADDITIONAL MAPPING SUPPORT)
    NSString *selectQuery = [NSString stringWithFormat:@"SELECT DISTINCT %@ , %@, %@, %@, %@, %@ From %@ WHERE %@ = '%@'", MSOURCE_FIELD_NAME, MTARGET_FIELD_NAME, MMAPPING_VALUE, MMAPPING_COMP_TYPE, MMAPPING_PREFERENCE2, MMAPPING_PREFERENCE3,SFOBJECTMAPCOMPONENT, MOBJECT_MAPPING_ID,mappingId];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            
            NSMutableDictionary *objMappingDict = [[NSMutableDictionary alloc] init];
            
            char * sourceFieldNameChar= (char *) synchronized_sqlite3_column_text(stmt, 0);
            if ((sourceFieldNameChar != nil) && strlen(sourceFieldNameChar))
            {
                NSString *sourceFieldName = [NSString stringWithUTF8String:sourceFieldNameChar];
                [objMappingDict setValue:sourceFieldName forKey:MSOURCE_FIELD_NAME];
            }
            
            char * targetFieldNameChar= (char *) synchronized_sqlite3_column_text(stmt, 1);
            if ((targetFieldNameChar != nil) && strlen(targetFieldNameChar))
            {
                NSString *targetFieldName = [NSString stringWithUTF8String:targetFieldNameChar];
                [objMappingDict setValue:targetFieldName forKey:MTARGET_FIELD_NAME];
            }
            
            char * mappingValChar = (char *) synchronized_sqlite3_column_text(stmt, 2);
            if ((mappingValChar != nil) && strlen(mappingValChar))
            {
                NSString *mappingValue = [NSString stringWithUTF8String:mappingValChar];
                [objMappingDict setValue:mappingValue forKey:MMAPPING_VALUE];
            }
            
            char * mappingComTypeChar = (char *) synchronized_sqlite3_column_text(stmt, 3);
            if ((mappingComTypeChar != nil) && strlen(mappingComTypeChar))
            {
                NSString *mappingCompType = [NSString stringWithUTF8String:mappingComTypeChar];
                [objMappingDict setValue:mappingCompType forKey:MMAPPING_COMP_TYPE];
            }
            
            //Aparna: FORMFILL (ADDITIONAL MAPPING SUPPORT)
            char * preference2Char = (char *) synchronized_sqlite3_column_text(stmt, 4);
            if ((preference2Char != nil) && strlen(preference2Char))
            {
                NSString *preference2 = [NSString stringWithUTF8String:preference2Char];
                [objMappingDict setValue:preference2 forKey:MMAPPING_PREFERENCE2];
            }

            char * preference3Char = (char *) synchronized_sqlite3_column_text(stmt, 5);
            if ((preference3Char != nil) && strlen(preference3Char))
            {
                NSString *preference3 = [NSString stringWithUTF8String:preference3Char];
                [objMappingDict setValue:preference3 forKey:MMAPPING_PREFERENCE3];
            }

            
            
            [objMappingCompInfoArray addObject:objMappingDict];
            [objMappingDict release];
        }
    }
    synchronized_sqlite3_finalize(stmt);
    return objMappingCompInfoArray;
}


- (NSDictionary *)recordsToUpdateForObjectId:(NSString *)objectId
                                   mappingId:(NSString *)mappingId
                                  objectName:(NSString *)objName
{
    
    NSMutableDictionary *formFillRecords = [NSMutableDictionary dictionary];
    NSArray *objMappingComponentArray = [appDelegate.databaseInterface objectMappingComponentInfoForMappingId:mappingId];
    NSDictionary *objMappingDict = nil; //8013
    
    for (NSDictionary *dict in objMappingComponentArray)
    {
        NSString *targetFieldName = [dict valueForKey:MTARGET_FIELD_NAME];
        NSString *mappingType = [dict valueForKey:MMAPPING_COMP_TYPE];
        NSString *mappedValue = nil;
        
        if ([mappingType isEqualToString:FIELD_MAPPING ])
        {
            NSString *sourceFieldName = [dict valueForKey:MSOURCE_FIELD_NAME];
            mappedValue = [appDelegate.databaseInterface getValueForField:sourceFieldName objectName:objName recordId:objectId];
            
            //Aparna: FORMFILL (ADDITIONAL MAPPING SUPPORT)
            if ((mappedValue == nil) || ([mappedValue length] ==0))
            {
                //Set the value from preference2 field
                NSString *preference2 = [dict valueForKey:MMAPPING_PREFERENCE2];
                mappedValue = [appDelegate.databaseInterface getValueForField:preference2 objectName:objName recordId:objectId];
            }
            if ((mappedValue == nil) || ([mappedValue length] ==0))
            {
                //Set the value from preference3 field
                NSString *preference3 = [dict valueForKey:MMAPPING_PREFERENCE3];
                mappedValue = [appDelegate.databaseInterface getValueForField:preference3 objectName:objName recordId:objectId];
            }
            
            //8013 : Below code is to display name instead of SFId if source field type is reference.
            NSString *sourceDataType = [appDelegate.databaseInterface getFieldDataType:objName filedName:sourceFieldName];
            if ([sourceDataType isEqualToString:@"reference"])
            {
                if (nil == objMappingDict)
                {
                    objMappingDict = [self objectMappingInfoForMappingId:mappingId];
                }
                NSString *targetObjName = [objMappingDict valueForKey:TARGET_OBJECT_NAME];
                NSString *targetDataType = [appDelegate.databaseInterface getFieldDataType:targetObjName filedName:targetFieldName];
                if(![targetDataType isEqualToString:@"reference"])
                {
                    NSString *refernce = [appDelegate.dataBase getReferencetoFiledForObject:objName api_Name:sourceFieldName];
                    NSString *nameField = [appDelegate.databaseInterface getNameFieldForObject:refernce];
                    NSString *nameValue = [appDelegate.databaseInterface getValueForField:nameField objectName:refernce recordId:mappedValue];
                    SMLog(kLogLevelVerbose,@"\n[sourceDataType: %@]\n[targetDataType: %@]\n[sourceObjName: %@]\n[targetObjName: %@]\n[sourceFieldName: %@]\n[targetFieldName: %@]\n[mappedValue: %@]\n[refernce: %@]\n[nameValue: %@]\n[nameField: %@]",sourceDataType,targetDataType,objName,targetObjName,sourceFieldName,targetFieldName,mappedValue,refernce,nameValue,nameField);
                    if ([nameValue length]>0)
                    {
                        mappedValue = nameValue;
                    }else
                    {
                        NSString *valueFromLookUp = [appDelegate.dataBase getValueFromLookupwithId:mappedValue];
                        if ([valueFromLookUp length]>0)
                        {
                            mappedValue = valueFromLookUp;
                        }
                    }
                }
            }
        }
        else if([mappingType isEqualToString:VALUE_MAPPING])
        {
            NSString *mappingValue = [dict valueForKey:MMAPPING_VALUE];
            mappedValue = mappingValue;
        }
        
        [formFillRecords setValue:mappedValue forKey:targetFieldName];
    }
    
    return formFillRecords;
}
#pragma mark - Getting record for sfid
//8282

- (NSMutableArray *) getAllOPDocsHtmlFiles {
    
    NSString *woLocalId =  appDelegate.sfmPageController.recordId;
    NSString *selectQuery = [NSString stringWithFormat:@"Select local_id, object_api_name,process_id,doc_name,sf_id,WorkOrderNumber From SFOPDocHtmlData where local_id='%@'",woLocalId];
    
    sqlite3_stmt * stmt;
    
    NSMutableArray *docArray = [NSMutableArray array];
    NSString  * recordId = @"";
    NSString  * objectapiName = @"";
    NSString  * processID = @"";
    NSString  * docName = @"";
    NSString  * sfid = @"";
    NSString  * wNumber = @"";
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            NSMutableDictionary * OPDOC_Data = [[NSMutableDictionary alloc] init];
            
            char *field = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_1);
            if ( field != nil )
                recordId = [NSString stringWithUTF8String:field];
            
            char *field1 = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_2);
            if ( field1 != nil )
                objectapiName = [NSString stringWithUTF8String:field1];
            
            char *field2 = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_3);
            if ( field2 != nil )
                processID = [NSString stringWithUTF8String:field2];
            
            char *field3 = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_4);
            if ( field3 != nil )
                docName = [NSString stringWithUTF8String:field3];
            
            char *field4 = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_5);
            if ( field4 != nil )
                sfid = [NSString stringWithUTF8String:field4];
            
            char *field5 = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_6);
            if ( field5 != nil )
                wNumber= [NSString stringWithUTF8String:field5];
            
            [OPDOC_Data setObject:processID forKey:@"process_id"];
            [OPDOC_Data setObject:recordId forKey:@"record_id"];
            [OPDOC_Data setObject:objectapiName forKey:@"object_api_name"];
            [OPDOC_Data setObject:docName forKey:@"doc_name"];
            [OPDOC_Data setObject:docName forKey:@"sfid"];
            [OPDOC_Data setObject:docName forKey:@"wo_number"];
            
            [docArray addObject:OPDOC_Data];
            [OPDOC_Data release];
            OPDOC_Data = nil;
            
            recordId = @"";
            objectapiName = @"";
            processID = @"";
            docName = @"";
            sfid = @"";
            wNumber = @"";
        }
    }
    
    synchronized_sqlite3_finalize(stmt);
    
    return docArray;
    
}

- (NSMutableDictionary *)getRecordForSfId:(NSString *)sfId andTableName:(NSString *)tableName {
    
    NSMutableDictionary *allFieldsOfTable = [self getAllObjectFields:tableName tableName:SFOBJECTFIELD];
    [allFieldsOfTable setValue:@"VARCHAR" forKey:@"local_id"];
    NSArray *allColumnNames = [allFieldsOfTable  allKeys];
    NSString *allColumnNamesString = [Utility getConcatenatedStringFromArray:allColumnNames withSingleQuotesAndBraces:NO];
    
    
    NSString *sqlQuery = [NSString  stringWithFormat:@"select %@ from %@ where  ( Id = '%@' OR local_id = '%@' )",allColumnNamesString,tableName,sfId,sfId];
    
    NSMutableDictionary *dataDictionary = [[NSMutableDictionary alloc] init];
    sqlite3_stmt *selectStmt = nil;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sqlQuery UTF8String], -1, &selectStmt, nil) == SQLITE_OK  )
    {
        
        while(synchronized_sqlite3_step(selectStmt) == SQLITE_ROW)
        {
            NSString * tempString = @"";
			char * tempCharString = nil;
            
            for (int counter = 0; counter < [allColumnNames count]; counter++) {
                tempCharString = (char *)sqlite3_column_text(selectStmt, counter);
                if (tempCharString != nil) {
                    tempString = [NSString stringWithUTF8String:tempCharString];
                    if (tempString != nil) {
                        NSString *fieldName = [allColumnNames objectAtIndex:counter];
                        tempString =  [tempString stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                        [dataDictionary setObject:tempString forKey:fieldName];
                        
                    }
                }
                
            }
        }
		
    }
    synchronized_sqlite3_finalize(selectStmt);
    return [dataDictionary autorelease];
}

//Insertion happens in while loop in order to prevent memory from increasing
- (void)reInsertDeletedRecordsOnConflict {
    
    
    NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
    SBJsonParser *someParser = [[SBJsonParser alloc] init];
    
    NSString *sqlQuery = [NSString  stringWithFormat:@"select sf_id, local_id, object_name from 'sync_error_conflict' where  sync_type LIKE '%%PUT_DELETE%%'"];
    
    sqlite3_stmt *selectStmt = nil;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sqlQuery UTF8String], -1, &selectStmt, nil) == SQLITE_OK  )
    {
        
        while(synchronized_sqlite3_step(selectStmt) == SQLITE_ROW)
        {
            NSString *sfid = nil,*localId = nil,*objectName = nil;
            
            NSString * tempString = @"";
			char * tempCharString = nil;
            tempCharString = (char *)sqlite3_column_text(selectStmt, 0);
            if (tempCharString != nil) {
                tempString = [NSString stringWithUTF8String:tempCharString];
                if (tempString != nil) {
                    sfid = tempString;
                }
            }
            tempString = nil;
            
            tempCharString = (char *)sqlite3_column_text(selectStmt, 1);
            if (tempCharString != nil) {
                tempString = [NSString stringWithUTF8String:tempCharString];
                if (tempString != nil) {
                    localId = tempString;
                }
            }
            tempString = nil;
            
            tempCharString = (char *)sqlite3_column_text(selectStmt, 2);
            if (tempCharString != nil) {
                tempString = [NSString stringWithUTF8String:tempCharString];
                if (tempString != nil) {
                    objectName = tempString;
                }
            }
            tempString = nil;
            
            if ((![Utility isStringEmpty:sfid]  || ![Utility isStringEmpty:localId]) && ![Utility isStringEmpty:objectName]) {
                
                //Get the json string from data trailer table and re insert into the respective table
                NSString *jsonString =  [self getRecordFromDataTrailerTableForSFId:sfid withLocalId:localId andObjectName:objectName];
                
                if (![Utility isStringEmpty:jsonString]) {
                    NSDictionary * jsonDict = [someParser objectWithString:jsonString];
                    if ([jsonDict count] > 0) {
                        [self insertRecordToRespectiveTableWithSfid:sfid withDataDictionary:jsonDict withObjectName:objectName];
                    }
                }
            }
            
        }
    }
    
    synchronized_sqlite3_finalize(selectStmt);
    [someParser release];
    someParser = nil;
    [aPool drain];
    aPool = nil;
}

- (NSString *)getRecordFromDataTrailerTableForSFId:(NSString *)sfid
                                       withLocalId:(NSString *)localId
                                     andObjectName:(NSString *)objectName {
    
    NSString *jsonString = nil;
    NSString *sqlQuery = [NSString  stringWithFormat:@"select request_data from 'SFDataTrailer' where  operation LIKE '%%DELETE%%' and object_name = '%@' and  sf_id = '%@'",objectName,sfid];
    
    sqlite3_stmt *selectStmt = nil;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sqlQuery UTF8String], -1, &selectStmt, nil) == SQLITE_OK  )
    {
        while(synchronized_sqlite3_step(selectStmt) == SQLITE_ROW)
        {
            
            NSString * tempString = @"";
			char * tempCharString = nil;
            tempCharString = (char *)sqlite3_column_text(selectStmt, 0);
            if (tempCharString != nil) {
                tempString = [NSString stringWithUTF8String:tempCharString];
                if (tempString != nil) {
                    jsonString = tempString;
                }
            }
        }
    }
    synchronized_sqlite3_finalize(selectStmt);
    return jsonString;
}

- (void)insertRecordToRespectiveTableWithSfid:(NSString *)sfid
                           withDataDictionary:(NSDictionary *)dataDictionary
                               withObjectName:(NSString *) objectApiName
{
    
    [appDelegate.dataBase beginTransaction];
    NSAutoreleasePool * autoreleaseExternal = [[NSAutoreleasePool alloc] init];
    
    SMLog(@"Insertion starts for %@",objectApiName);
    
    /* get field and table schema only once and store it in global dictionary*/
    NSMutableDictionary *fieldDictionary = [self getAllFieldsAndItsDataTypesForObject:objectApiName tableName:SFOBJECTFIELD];
    [fieldDictionary setValue:@"VARCHAR" forKey:@"local_id"];
    
    
    // Form a query and store that in the global dictionary
    NSArray  *allKeysObjectApiNames = [fieldDictionary allKeys];
    NSString * fieldString = @"";
    NSString * valuesString = @"";
    
    NSInteger allKeysCount = [allKeysObjectApiNames count];
    
    for (int t = 0; t < allKeysCount; t++) {
        NSString * keyFieldName = [allKeysObjectApiNames objectAtIndex:t];
        
        if (t != 0) {
            NSString * temp_field_string = [NSString stringWithFormat:@",%@", keyFieldName];
            fieldString  = [fieldString stringByAppendingFormat:@"%@", temp_field_string];
            valuesString = [valuesString stringByAppendingFormat:@",?%d", t+1];
        }
        else {
            NSString * temp_field_string = [NSString stringWithFormat:@"%@", keyFieldName];
            fieldString  = [fieldString stringByAppendingFormat:@"%@", temp_field_string];
            valuesString = [valuesString stringByAppendingFormat:@"?%d", t+1];
        }
    }
    
    NSString *insertionQuery = [NSString stringWithFormat:@"INSERT INTO '%@' (%@) VALUES (%@)", objectApiName, fieldString,valuesString];
    
    /* Compile it for the records and insert them */
    sqlite3_stmt * bulk_statement = nil;
    
    int preparedSuccessfully =  synchronized_sqlite3_prepare_v2(appDelegate.db, [insertionQuery UTF8String], strlen([insertionQuery UTF8String]), &bulk_statement, NULL);
    if (preparedSuccessfully == SQLITE_OK) {
        
        NSMutableDictionary *responseDictionary = [[NSMutableDictionary alloc] initWithDictionary:dataDictionary];
        
        
        BOOL  check_flag =  [appDelegate.dataBase checkForDuplicateId:objectApiName sfId:sfid];
        
        /* Insertion */
        if (check_flag)
        {
            //Need to cross check the local id
            // NSString *newLocalId = nil;
            //[responseDictionary setObject:newLocalId forKey:@"local_id"];
            
            NSInteger allTableColumnNamesCount = [allKeysObjectApiNames count];
            
            
            for (int x = 0; x < allTableColumnNamesCount; x++)
            {
                int column_num = x+1;
                
                NSString * field       = [allKeysObjectApiNames objectAtIndex:x];
                NSString * data_type   = [fieldDictionary objectForKey:field];
                NSString * columnType  = [appDelegate.dataBase columnType:data_type];
                NSString * final_value = [responseDictionary objectForKey:field];
                
                if (final_value == nil)
                {
                    final_value = @"";
                }
                
                char * _finalValue = [appDelegate convertStringIntoChar:final_value];
                
                if ([columnType isEqualToString:DOUBLE])
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
            
            
            if (ret != SQLITE_DONE)
            {
                
                SMLog(@"Insertion failed For for %@ Success = %d",sfid,ret);
                
            }
            else {
                SMLog(@"Insertion For for %@ Success = %d",sfid,ret);
            }
            
            sqlite3_clear_bindings(bulk_statement);
            sqlite3_reset(bulk_statement);
        }
        else
        {
            BOOL flag = [self updateExistingRecordforSFId:sfid forObject:objectApiName data:responseDictionary andFieldDictionary:fieldDictionary];
            if(flag)
            {
                SMLog(@"Update existing record successful for Id %@",sfid);
            }
        }
        
        [responseDictionary release];
        responseDictionary = nil;
    }
    synchronized_sqlite3_finalize(bulk_statement);
    
    [autoreleaseExternal release];
    autoreleaseExternal = nil;
    
    [appDelegate.dataBase endTransaction];
}

-(BOOL)updateExistingRecordforSFId:(NSString *)sfId  forObject:(NSString *)objectName  data:(NSDictionary *)dataDictionary andFieldDictionary:(NSDictionary *)fieldDictionary
{
    
	BOOL success = FALSE;
    NSArray * allkeys = [fieldDictionary allKeys];
    NSMutableString *  updateValue = [[NSMutableString alloc] initWithCapacity:0];
    @try{
        for(int i = 0 ; i < [allkeys count]; i++)
        {
            NSString * key = [allkeys objectAtIndex:i];
            NSString * value = [dataDictionary objectForKey:key];
            if (value == nil) {
                value = @"";
            }
            if(value != nil)
            {
                
                value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                NSString * field_data_type = [[fieldDictionary objectForKey:key] lowercaseString];
                
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
        
        
        NSString *updateQuery = [NSString stringWithFormat:@"UPDATE '%@' SET %@ WHERE Id = '%@'", objectName, updateValue,sfId];
        sqlite3_stmt *updateStatement = nil;
        int ret_val = synchronized_sqlite3_prepare_v2(appDelegate.db, [updateQuery UTF8String], strlen([updateQuery UTF8String]),  &updateStatement, NULL);
        if (ret_val == SQLITE_OK) {
            if (synchronized_sqlite3_step(updateStatement) != SQLITE_DONE)
            {
                SMLog(@"%@", updateQuery);
                SMLog(@"Failure UpdateTableforSFId - updateStatement => %@", updateQuery);
                success = FALSE;
            }
            else
            {
                // SMLog(@"Success updateParentColumnNameInChildTableWithParentLocalId - updateStatement => %@", updateStatement);
                success = TRUE;
            }
        }
        synchronized_sqlite3_finalize(updateStatement);
        
        
	}@catch (NSException *exp) {
        SMLog(@"Exception Name databaseInterfaceSfm :UpdateTableforSFId %@",exp.name);
        SMLog(@"Exception Reason databaseInterfaceSfm :UpdateTableforSFId %@",exp.reason);
        
    }
    [updateValue release];
    updateValue = nil;
}

#pragma mark - SOURCE UPDATE functions - 4850
- (NSArray *)sourceUpdatesConfigurationForProcessId:(NSString *)processId andSettingId:(NSString*)settingId
{
    NSMutableArray *sourceUpdatesArray = [[NSMutableArray alloc] init];
    sqlite3_stmt * stmt;
    NSString *selectQuery = [NSString stringWithFormat:@"SELECT Id,source_object_name, target_object_name, source_field_name,  target_field_name,action,display_value From %@ WHERE process = '%@' and setting_Id = '%@'",SOURCE_UPDATE,processId,settingId];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            SourceUpdateConfig *aConfig = [[SourceUpdateConfig alloc] init];
            int i = 0;
            char * tempChar= (char *) synchronized_sqlite3_column_text(stmt, i);
            if ((tempChar != nil) && strlen(tempChar))
            {
                NSString *objString = [NSString stringWithUTF8String:tempChar];
                aConfig.identifier =objString;
                
            }
            i++;
            tempChar = nil;
            
            tempChar= (char *) synchronized_sqlite3_column_text(stmt, i);
            if ((tempChar != nil) && strlen(tempChar))
            {
                NSString *objString = [NSString stringWithUTF8String:tempChar];
                aConfig.sourceObjectName =objString;
                
            }
            i++;
            tempChar = nil;
            
            tempChar= (char *) synchronized_sqlite3_column_text(stmt, i);
            if ((tempChar != nil) && strlen(tempChar))
            {
                NSString *objString = [NSString stringWithUTF8String:tempChar];
                aConfig.targetObjectName =objString;
                
            }
            i++;
            tempChar = nil;
            
            tempChar= (char *) synchronized_sqlite3_column_text(stmt, i);
            if ((tempChar != nil) && strlen(tempChar))
            {
                NSString *objString = [NSString stringWithUTF8String:tempChar];
                aConfig.sourceFieldName =objString;
                
            }
            i++;
            tempChar = nil;
            
            tempChar= (char *) synchronized_sqlite3_column_text(stmt, i);
            if ((tempChar != nil) && strlen(tempChar))
            {
                NSString *objString = [NSString stringWithUTF8String:tempChar];
                aConfig.targetFieldname =objString;
                
            }
            i++;
            tempChar = nil;
            
            tempChar= (char *) synchronized_sqlite3_column_text(stmt, i);
            if ((tempChar != nil) && strlen(tempChar))
            {
                NSString *objString = [NSString stringWithUTF8String:tempChar];
                aConfig.actionType =objString;
                
            }
            i++;
            tempChar = nil;
            
            tempChar= (char *) synchronized_sqlite3_column_text(stmt, i);
            if ((tempChar != nil) && strlen(tempChar))
            {
                NSString *objString = [NSString stringWithUTF8String:tempChar];
                aConfig.displayValue =objString;
                
            }
            i++;
            tempChar = nil;
            
            aConfig.settingId = settingId;
            aConfig.processId = processId;
            
            [sourceUpdatesArray addObject:aConfig];
            [aConfig release];
            aConfig = nil;
            
            
        }
    }
    synchronized_sqlite3_finalize(stmt);
    return [sourceUpdatesArray autorelease];
}
- (void)updateRecord:(NSString *)localId ofObject:(NSString *)objectName andFieldDictionary:(NSDictionary *)fieldDictionary {
    
    NSMutableString *queryString = [[NSMutableString alloc] initWithFormat:@"UPDATE '%@' SET ",objectName];
    NSArray *allKeys = [fieldDictionary allKeys];
    for (int counter = 0; counter < [allKeys count]; counter++) {
        NSString *fieldName = [allKeys objectAtIndex:counter];
        NSString *fValue = [fieldDictionary objectForKey:fieldName];
        
        fValue = [fValue stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        
        if (counter == 0) {
            [queryString appendFormat:@" %@ = '%@' ",fieldName,fValue];
        }
        else {
            [queryString appendFormat:@", %@ = '%@' ",fieldName,fValue];
        }
    }
    
    [queryString appendFormat:@" WHERE local_id = '%@'",localId];
    
    char *err;
    int ret = synchronized_sqlite3_exec(appDelegate.db, [queryString UTF8String], NULL, NULL, &err);
    
    if (ret != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"%@", queryString);
        SMLog(kLogLevelError,@"ERROR IN UPDATING %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:queryString type:UPDATEQUERY];
    }
    
    [queryString release];
    queryString = nil;
    
    
}
#pragma mark -
#pragma mark SUCCESSIVE_SYNC Utility Methods


- (void)addSuccessiveSyncModel:(SuccessiveSyncModel*)inSuccSyncObj forLocalId:(NSString*)localId
{
    // successiveSyncRecords
    
    if(successiveSyncRecords == nil)
    {
        successiveSyncRecords = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    
    SuccessiveSyncModel *sucSyncobj = [successiveSyncRecords objectForKey:localId];
    if(sucSyncobj != nil) {
        
        NSDictionary *inDataDict = [NSDictionary dictionaryWithDictionary:inSuccSyncObj.dataDict];
        NSArray *keys = [inDataDict allKeys];
        
        for (NSString *key in keys) {
            [sucSyncobj.dataDict setObject:[inDataDict objectForKey:key] forKey:key];
        }
        
        if(sucSyncobj.isDBUpdated) {
            sucSyncobj.isDBUpdated = FALSE;
        }
    }
    else {
        [successiveSyncRecords setObject:inSuccSyncObj forKey:localId];
    }
}

- (SuccessiveSyncModel*)getSuccessiveSyncModelForLocalId:(NSString*)localId
{
    SuccessiveSyncModel *sucSyncobj = [successiveSyncRecords objectForKey:localId];
    if(sucSyncobj == nil) {
      // NSLog(@"No successive sync records found for %@!!",localId);
    }
    return sucSyncobj;
}

- (void)clearAllSuccessiveSyncObjects
{
    [successiveSyncRecords removeAllObjects];
}

- (BOOL)removeSuccessiveSyncModelForLocalId:(NSString*)localId
{
    SuccessiveSyncModel *sucSyncobj = [successiveSyncRecords objectForKey:localId];
    if(sucSyncobj == nil) {
        NSLog(@"No successive sync records found for %@!!",localId);
        return FALSE;
    }
    
    [successiveSyncRecords removeObjectForKey:localId];
    return TRUE;
}

- (void)overrideResponseData:(NSMutableDictionary*)responseDictionary ForsfId:(NSString *)sfId ObjectName:(NSString *)objectname
{
    NSString * localId = nil;
  
    localId = [self getLocalIdFromSFId:sfId tableName:objectname];
    
    SuccessiveSyncModel * sucSyncData = [self getSuccessiveSyncModelForLocalId:localId];
    if(sucSyncData == nil)
    {
        return;
    }
    NSDictionary *sucSyncDataDict = [NSDictionary dictionaryWithDictionary:sucSyncData.dataDict];
    // replace key/value pairs
    NSArray *keys = [sucSyncDataDict allKeys];
    for (NSString* key in keys) {
        [responseDictionary setObject:[sucSyncDataDict objectForKey:key] forKey:key];
        sucSyncData.isDBUpdated = TRUE; //Sahana this statement can be out of loop
    }
}

- (void)updateSuccessiveSyncRecordsAfterTxFetch
{
    // Update records in trailer table for successive sync objects whose update flag is TRUE
    NSArray *keys = [successiveSyncRecords allKeys];
    for (NSString *key in keys) {
        SuccessiveSyncModel *sucSyncObj = [successiveSyncRecords objectForKey:key];
        if(sucSyncObj.isDBUpdated) {
            // insert into trailer table
            [self insertdataIntoTrailerTableForRecord:sucSyncObj.localId
                                                SF_id:sucSyncObj.sfId
                                          record_type:sucSyncObj.record_type
                                            operation:sucSyncObj.operation
                                          object_name:sucSyncObj.objectName
                                            sync_flag:sucSyncObj.syncFlag
                                     parentObjectName:sucSyncObj.parentObjectName
                                      parent_loacl_id:sucSyncObj.parentLocalId
                                       webserviceName:@""
                                            className:@""
                                             synctype:sucSyncObj.syncType
                                        headerLocalId:sucSyncObj.headerLocalId
                                          requestData:nil
                                           finalEntry:FALSE];
            [self removeSuccessiveSyncModelForLocalId:sucSyncObj.localId];
        }
    }
}


 //SUCCESSIVE_SYNC
-(BOOL)ShouldRecordRespectSuccessiveSync:(NSString *)TargetId objectName:(NSString *)objectName headerRecordId:(NSString *)headerRecordId operationType:(NSString *)operationType
{
    // check Trailer table for Normal sync(direct entry) and custom sync(custom entry)
    //
    BOOL does_exists = [self DoesTrailerContainTheRecord:TargetId operation_type:operationType object_name:objectName];
    BOOL custom_entry = [self doesEntryExistsForCutomSyncForId:headerRecordId targetId:TargetId operationType:operationType objectName:objectName];
    
    if((does_exists || custom_entry )&& appDelegate.dataSyncRunning)
    {
        return YES;
    }
    return NO;
}
-(BOOL)doesEntryExistsForCutomSyncForId:(NSString *)headerId targetId:(NSString *)targetId operationType:(NSString *)operationType objectName:(NSString *)objectName
{
    BOOL entryExists = FALSE;
    NSArray * requestIds = [self getCustomSyncentry:headerId];
    
    for(NSString * requestId in requestIds)
    {
        //sahana Jan 27 2014 Fix for Defect #9627
        NSDictionary * dict = [[self getCustomAggressiveSyncRecordsForHearedRecord:requestId] retain];
        entryExists = [self doesIdExistinCustomDict:dict recordId:targetId objectName:objectName operationType:operationType];
        [dict release];
        if(entryExists)
        {
            break;
        }
    }
    return entryExists;
}

-(BOOL)doesIdExistinCustomDict:(NSDictionary *)sync_record  recordId:(NSString *)recordId objectName:(NSString *)targetobjectName operationType:(NSString *)operationType
{
    BOOL entryExists = FALSE;
    NSArray * object_types = [sync_record allKeys];
    
    for(NSString * object_type in object_types)
    {
        NSDictionary * each_dict = [sync_record objectForKey:object_type];
        NSArray * allobjects = [each_dict allKeys];
        for(NSString * object_name in allobjects)
        {
            
            if([object_name isEqualToString:targetobjectName])
            {
                NSDictionary  * operation_type_dict  = [each_dict objectForKey:object_name];
                NSArray * all_operations = [operation_type_dict allKeys];
                for(NSString  * single_operation in all_operations)
                {
                    if([single_operation isEqualToString:operationType])
                    {
                        NSArray * record_info_dict_array = [operation_type_dict objectForKey:single_operation];
                        
                        for(NSDictionary * info_dict in record_info_dict_array)
                        {
                            NSString * local_id = [info_dict objectForKey:SYNC_RECORD_LOCAL_ID];
                            if([local_id isEqualToString:recordId])
                            {
                                entryExists = TRUE;
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
    return entryExists;
}


-(NSMutableArray *)getCustomSyncentry:(NSString *)header_record_id
{

    NSMutableArray * requestIdsArray = nil;
    NSString * query = [NSString stringWithFormat:@"SELECT  request_id FROM '%@' WHERE header_localId = '%@'",SFDATATRAILER ,header_record_id];
    
    NSString *request_id = nil;
    sqlite3_stmt * statement ;
    
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, nil) ==  SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            
            char * temp_request_data = (char * ) synchronized_sqlite3_column_text(statement, 0);
            if(temp_request_data != nil)
            {
                request_id  = [NSString stringWithUTF8String:temp_request_data];
                
                if(requestIdsArray == nil)
                {
                    requestIdsArray = [[NSMutableArray alloc] initWithCapacity:0];
                }
                if(request_id != nil)
                {
                    [requestIdsArray addObject:request_id];
                }
            }
        }
    }
    synchronized_sqlite3_finalize(statement);
    return requestIdsArray ;
}
//SUCCESSIVE_SYNC
-(void)successiveSyncEntryForLocalId:(NSString *)localId sfId:(NSString *)sfId operation:(NSString *)operation recordType:(NSString *)recordType  objName:(NSString *)objectName_ parentObjName:(NSString *)parentObjName parentLocalId:(NSString *)parentlocalId headerLocalId:(NSString *)headerLocalId syncType:(NSString *)syncType_ dataDict:(NSMutableDictionary *)dataDict syncFlag:(NSString *)syncFlag valuemapping:(BOOL)mappingCount
{
    BOOL isRecordModified = FALSE;
    
    for (NSString  * tempLocalid in appDelegate.databaseInterface.modifiedLineRecords) {
        if([tempLocalid isEqualToString:localId])
        {
            isRecordModified = TRUE;
            break;
        }
    }
    
    BOOL successiveSyncFlag = [appDelegate.databaseInterface ShouldRecordRespectSuccessiveSync:localId objectName:objectName_ headerRecordId:headerLocalId operationType:operation];
    if(successiveSyncFlag && (isRecordModified || mappingCount))
    {
        SuccessiveSyncModel * model_object = [self makeSuccessiveSyncObjectWithLocalId:localId sfId:sfId operation:operation recordType:recordType objName:objectName_ parentObjName:parentObjName parentLocalId:parentlocalId headerLocalId:headerLocalId syncType:syncType_ dataDict:dataDict syncFlag:syncFlag];
        [appDelegate.databaseInterface addSuccessiveSyncModel:model_object forLocalId:localId];
        [model_object release];
    }
    
}
//SUCCESSIVE_SYNC
-(SuccessiveSyncModel *)makeSuccessiveSyncObjectWithLocalId:(NSString *)localId sfId:(NSString *)sfId operation:(NSString *)operation recordType:(NSString *)recordType  objName:(NSString *)objectName_ parentObjName:(NSString *)parentObjName parentLocalId:(NSString *)parentlocalId headerLocalId:(NSString *)headerLocalId syncType:(NSString *)syncType_ dataDict:(NSMutableDictionary *)dataDict syncFlag:(NSString *)syncFlag
{
    //SUCCESSIVE_SYNC
    SuccessiveSyncModel *successiveSyncdict = [[SuccessiveSyncModel alloc] init];
    successiveSyncdict.localId = localId;
    successiveSyncdict.sfId = sfId;
    successiveSyncdict.operation = operation;
    successiveSyncdict.objectName = objectName_;
    successiveSyncdict.parentObjectName = parentObjName;
    successiveSyncdict.parentLocalId = parentlocalId;
    successiveSyncdict.record_type = recordType;
    successiveSyncdict.syncType = syncType_;
    successiveSyncdict.headerLocalId = headerLocalId;
    successiveSyncdict.syncFlag = syncFlag;
    successiveSyncdict.dataDict = [NSMutableDictionary dictionaryWithDictionary:dataDict];
    return successiveSyncdict;
}

//9778
-(NSMutableArray *)getSortedRTPicklistValues:(NSArray *)picklistValues fieldApiName:(NSString *)field_api_name  objectApiName:(NSString *)objectApiName
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    for (NSString *value in picklistValues)
    {
        NSString * indexQuery = [NSString stringWithFormat:@"SELECT index_value FROM SFPickList Where object_api_name = '%@' AND field_api_name = '%@' AND label = '%@'",objectApiName,field_api_name,[value stringByReplacingOccurrencesOfString:@"'" withString:@"''"]];
        sqlite3_stmt * statement;
        if (synchronized_sqlite3_prepare_v2(appDelegate.db, [indexQuery UTF8String], -1 , &statement , nil)  ==  SQLITE_OK)
        {
            while (synchronized_sqlite3_step(statement)== SQLITE_ROW)
            {
                int index = synchronized_sqlite3_column_int(statement, 0);
                
                if(index>=0)
                {
                    [dict setValue:[NSNumber numberWithInt:index] forKey:value];
                }
            }
        }
        synchronized_sqlite3_finalize(statement);
        
    }
    NSMutableArray *sortedPicklistValues = [NSMutableArray arrayWithArray:[dict keysSortedByValueUsingSelector:@selector(compare:)]];
    [dict release];
    [sortedPicklistValues insertObject:@"" atIndex:0];
    return sortedPicklistValues;
}

@end
