//
//  DataBase.m
//  iService
//
//  Created by Developer on 7/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DataBase.h"
#import "LocalizationGlobals.h"
#import "iServiceAppDelegate.h"
#import "PopoverButtons.h"

@implementation DataBase 

@synthesize dbFilePath;
@synthesize didInsertTable;
@synthesize MyPopoverDelegate;
@synthesize tempDb;
//@synthesize db;
-(id)init
{
    appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
    return self;
}


#pragma mark - SFM Search

- (void) createTablesForSFMSearch
{
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFM_Search_Process ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0), 'Id' VARCHAR,'Name' VARCHAR,'SVMXC__Active__c' VARCHAR,'SVMXC__Description__c' VARCHAR,'SVMXC__IsDefault__c' VARCHAR,'SVMXC__IsStandard__c' VARCHAR,'SVMXC__Name__c' VARCHAR,'SVMXC__Number_of_Lookup_Records__c' VARCHAR,'SVMXC__Rule_Type__c' VARCHAR)"]];
    if(result == YES)
        NSLog(@"SFM_Search_Process Table Create Success");
    else
        NSLog(@"SFM_Search_Process Table Create Failed");

    result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFM_Search_Objects ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0),'SVMXC__Module__c' VARCHAR,'SVMXC__ProcessID__c' VARCHAR,'SVMXC__Target_Object_Name__c' VARCHAR,'ProcessName' VARCHAR,'ProcessId' VARCHAR,'ObjectID' VARCHAR)"]];
    if(result == YES)
        NSLog(@"SFM_Search_Objects Table Create Success");
    else
        NSLog(@"SFM_Search_Objects Table Create Failed");

    result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFM_Search_Field ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0), 'Id' VARCHAR,'SVMXC__Expression_Rule__c' VARCHAR,'SVMXC__Field_Name__c' VARCHAR,'SVMXC__Object_Name2__c' VARCHAR,'SVMXC__Search_Object_Field_Type__c' VARCHAR,'ObjectId' VARCHAR)"]];
    
    if(result == YES)
        NSLog(@"SFM_Search_Field Table Create Success");
    else
        NSLog(@"SFM_Search_Field Table Create Failed");

    result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFM_Search_Filter_Criteria ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0), 'Id' VARCHAR,'SVMXC__Display_Type__c' VARCHAR,'SVMXC__Expression_Rule__c' VARCHAR,'SVMXC__Field_Name__c' VARCHAR,'SVMXC__Object_Name2__c' VARCHAR,'SVMXC__Operand__c' VARCHAR,'SVMXC__Operator__c' VARCHAR,'ObjectId' VARCHAR)"]];
    if(result == YES)
        NSLog(@"SFM_Search_Filter_Criteria Table Create Success");
    else
        NSLog(@"SFM_Search_Filter_Criteria Table Create Failed");
}
- (void) insertValuesintoSFMProcessTable:(NSMutableArray *) processData
{
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    [keys addObject:@"Id"];
    [keys addObject:@"Name"];
    [keys addObject:@"SVMXC__Active__c"];
    [keys addObject:@"SVMXC__Description__c"];
    [keys addObject:@"SVMXC__IsDefault__c"];
    [keys addObject:@"SVMXC__IsStandard__c"];
    [keys addObject:@"SVMXC__Name__c"];
    [keys addObject:@"SVMXC__Number_of_Lookup_Records__c"];
    [keys addObject:@"SVMXC__Rule_Type__c"];

    NSMutableString *queryFields = [[NSMutableString alloc] init];
    for(int i=0;i<[keys count]; i++)
    {
        if(i)
            [queryFields  appendString:@","];
        [queryFields appendFormat:@"'%@'",[keys objectAtIndex:i]];
    }
    for(int k=0; k< [ processData count]; k++)
    {
        NSMutableString *valueFields = [[NSMutableString alloc] init];
        for(int j=0;j<[keys count]; j++)
        {
            if(j)
                [valueFields  appendString:@","];
            NSString *key = [keys objectAtIndex:j];
            [valueFields appendFormat:@"'%@'",[[processData objectAtIndex:k] objectForKey:key]];
        }

        NSString  *queryStatement = [NSString stringWithFormat:@"INSERT INTO SFM_Search_Process (%@) VALUES (%@)",queryFields,valueFields ];
        
        char * err;
        if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
            if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
                [MyPopoverDelegate performSelector:@selector(throwException)];
            NSLog(@"Failed to insert");
        }
        [valueFields release];
    }
    [keys release];
    [queryFields release];
    [self insertValuesintoSFMObjectTable:processData];
}
- (void) insertValuesintoSFMObjectTable:(NSMutableArray *) processData
{
    for(int k=0; k< [ processData count]; k++)
    {
        NSDictionary *processDict = [processData objectAtIndex:k];
        NSString *processName = [processDict objectForKey:@"Name"];
        NSString *processId = [processDict objectForKey:@"Id"];
        NSArray *objectsArray = [processDict objectForKey:@"Objects"];
        NSLog(@"Process Name = %@ and Objects = %@",processName, objectsArray);
        for(int m=0; m<[objectsArray count]; m++)
        {
            NSDictionary *objectDict = [objectsArray objectAtIndex:m];
            NSLog(@"Object ID = %@",[objectDict objectForKey:@"Id"] );
            NSString *targetObjectNameFull = [objectDict objectForKey:@"SVMXC__Target_Object_Name__c"];
            NSString *targetObjectName = [self getFieldLabelForApiName:targetObjectNameFull];
            NSString  *queryStatement = [NSString stringWithFormat:@"INSERT INTO SFM_Search_Objects ('SVMXC__Module__c','SVMXC__ProcessID__c','SVMXC__Target_Object_Name__c','ProcessName','ProcessId','ObjectId') VALUES ('%@','%@','%@','%@','%@','%@')",[objectDict objectForKey:@"SVMXC__Module__c"],[objectDict objectForKey:@"SVMXC__ProcessID__c"],targetObjectName,processName,processId,[objectDict objectForKey:@"Id"] ];
            
            char * err;
            if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
            {
                if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
                    [MyPopoverDelegate performSelector:@selector(throwException)];
                NSLog(@"Failed to insert data in table SFM_Search_Objects");
            }
            
            NSArray *objectConfigDataArray = [objectDict objectForKey:@"ConfigData"];
            
            for(int n=0; n<[objectConfigDataArray count]; n++)
            {
                NSDictionary *objectConfigDict = [objectConfigDataArray objectAtIndex:n];
                NSArray *keys = [objectConfigDict allKeys];
                NSString  *queryStatement;
                NSString *fieldNameFull = [objectConfigDict objectForKey:@"SVMXC__Field_Name__c"];
                NSString *fieldName = [self getFieldLabelForApiName:fieldNameFull];

                NSString *objectName2Full = [objectConfigDict objectForKey:@"SVMXC__Object_Name2__c"];
                NSString *objectName2 = [self getFieldLabelForApiName:objectName2Full];

                if([keys containsObject:@"SVMXC__Search_Object_Field_Type__c"])
                {
                    
                    queryStatement = [NSString stringWithFormat:@"INSERT INTO SFM_Search_Field ('Id','SVMXC__Expression_Rule__c','SVMXC__Field_Name__c','SVMXC__Object_Name2__c','SVMXC__Search_Object_Field_Type__c','ObjectId') VALUES ('%@','%@','%@','%@','%@','%@')",[objectConfigDict objectForKey:@"Id"],[objectConfigDict objectForKey:@"SVMXC__Expression_Rule__c"],fieldName,objectName2,[objectConfigDict objectForKey:@"SVMXC__Search_Object_Field_Type__c"],[objectDict objectForKey:@"Id"] ];
                }
                else
                {
                    queryStatement = [NSString stringWithFormat:@"INSERT INTO SFM_Search_Filter_Criteria ('Id','SVMXC__Display_Type__c','SVMXC__Expression_Rule__c','SVMXC__Field_Name__c','SVMXC__Object_Name2__c','SVMXC__Operand__c','SVMXC__Operator__c','ObjectId') VALUES ('%@','%@','%@','%@','%@','%@','%@','%@')",[objectConfigDict objectForKey:@"Id"],[objectConfigDict objectForKey:@"SVMXC__Display_Type__c"],[objectConfigDict objectForKey:@"SVMXC__Expression_Rule__c"],fieldName,objectName2,[objectConfigDict objectForKey:@"SVMXC__Operand__c"],[objectConfigDict objectForKey:@"SVMXC__Operator__c"],[objectDict objectForKey:@"Id"] ];
                }
                char * err;
                if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
                {
                    if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
                        [MyPopoverDelegate performSelector:@selector(throwException)];
                    NSLog(@"Failed to insert data in table SFM_Search_Filter_Criteria or SFM_Search_Field");
                }
                

            }                
        }
     }

}
- (NSMutableArray *) getSFMSearchConfigurationSettings
{
    NSMutableArray *configSettings = [[NSMutableArray alloc] init];
    NSString *processQuery = [NSString stringWithFormat:@"SELECT Name,SVMXC__Description__c,SVMXC__Name__c,Id FROM SFM_Search_Process"];
    sqlite3_stmt * statement;
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [processQuery UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            NSMutableDictionary *processDict = [[NSMutableDictionary alloc] init];

            const char * name = (char *)synchronized_sqlite3_column_text(statement, 0);
            if (strlen(name))
                [processDict setObject:[NSString stringWithUTF8String:name] forKey:@"Name"] ;
            else
                [processDict setObject:@"" forKey:@"Name"] ;

            const char * description = (char *)synchronized_sqlite3_column_text(statement, 1);
            if (strlen(description))
                [processDict setObject:[NSString stringWithUTF8String:description] forKey:@"SVMXC__Description__c"] ;
            else
                [processDict setObject:@"" forKey:@"SVMXC__Description__c"] ;

            const char * search_process_name = (char *)synchronized_sqlite3_column_text(statement, 2);
            if (strlen(search_process_name))
                [processDict setObject:[NSString stringWithUTF8String:search_process_name] forKey:@"SVMXC__Name__c"] ;
            else
                [processDict setObject:@"" forKey:@"SVMXC__Name__c"] ;
            
            const char * processId = (char *)synchronized_sqlite3_column_text(statement, 3);
            if (strlen(processId))
                [processDict setObject:[NSString stringWithUTF8String:processId] forKey:@"Id"] ;
            else
                [processDict setObject:@"" forKey:@"Id"] ;

            
            NSString *objectQuery = [NSString stringWithFormat:@"SELECT ObjectId,SVMXC__Target_Object_Name__c FROM SFM_Search_Objects where ProcessName = '%@'",[processDict objectForKey:@"Name"]];
            NSLog(@"Object Query = %@",objectQuery);
            sqlite3_stmt * objectStatement;
            NSMutableArray *objectArray = [[NSMutableArray alloc] init];
                                
            if (synchronized_sqlite3_prepare_v2(appDelegate.db, [objectQuery UTF8String], -1, &objectStatement, NULL) == SQLITE_OK)
            {
                while (synchronized_sqlite3_step(objectStatement) == SQLITE_ROW)
                {
                    NSMutableDictionary *objectDict = [[NSMutableDictionary alloc] init];
                    const char * object_processid = (char *)synchronized_sqlite3_column_text(objectStatement, 0);
                    if (strlen(object_processid))
                        [objectDict setObject:[NSString stringWithUTF8String:object_processid] forKey:@"ObjectId"] ;
                    else
                        [objectDict setObject:@"" forKey:@"ObjectId"] ;
                    
                    const char * object_name = (char *)synchronized_sqlite3_column_text(objectStatement, 1);
                    if (strlen(object_name))
                        [objectDict setObject:[NSString stringWithUTF8String:object_name] forKey:@"ObjectName"] ;
                    else
                        [objectDict setObject:@"" forKey:@"ObjectName"] ;
                    // get searchable fields
                    NSMutableArray *searchableFieldsArray = [[self getSearchableFieldsForObject:[objectDict objectForKey:@"ObjectId"]] retain];
                    [objectDict setObject:searchableFieldsArray forKey:@"SearchableFields"] ;
                    [searchableFieldsArray release];
                    //get display fields
                    NSMutableArray *displayFieldsArray = [[self getDisplayFieldsForObject:[objectDict objectForKey:@"ObjectId"]] retain];
                    [objectDict setObject:displayFieldsArray forKey:@"DisplayFields"] ;
                    [displayFieldsArray release];
                    //get search criteria fields
                    NSMutableArray *searchCriteriaArray = [[self getSearchCriteriaForObject:[objectDict objectForKey:@"ObjectId"]] retain];
                    [objectDict setObject:searchCriteriaArray forKey:@"SearchCriteriaFields"] ;
                    [searchCriteriaArray release];

                    [objectArray addObject:objectDict];
                    [objectDict release];
                }
            }
            [processDict setObject:objectArray forKey:@"Objects"];
            [objectArray release];
            synchronized_sqlite3_finalize(objectStatement);
            [configSettings addObject:processDict];
            [processDict release];
        }
    }
    
    synchronized_sqlite3_finalize(statement);
    NSLog(@"Config Settings = %@",configSettings);
    return [configSettings autorelease];
}
- (NSMutableArray *) getSearchableFieldsForObject:(NSString *)objectId
{
    NSMutableArray *searchableArray = [[NSMutableArray alloc] init];
    NSString *objectQuery = [NSString stringWithFormat:@"SELECT Id,SVMXC__Field_Name__c, SVMXC__Object_Name2__c FROM SFM_Search_Field where SVMXC__Search_Object_Field_Type__c = 'Search' and ObjectId = '%@'",objectId];
    sqlite3_stmt * objectStatement;
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [objectQuery UTF8String], -1, &objectStatement, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(objectStatement) == SQLITE_ROW)
        {
            NSMutableDictionary *searchDict = [[NSMutableDictionary alloc] init];
            const char * searchid = (char *)synchronized_sqlite3_column_text(objectStatement, 0);
            if (strlen(searchid))
                [searchDict setObject:[NSString stringWithUTF8String:searchid] forKey:@"Id"] ;
            else
                [searchDict setObject:@"" forKey:@"Id"] ;
            
            const char * field_name = (char *)synchronized_sqlite3_column_text(objectStatement, 1);
            if (strlen(field_name))
                [searchDict setObject:[NSString stringWithUTF8String:field_name] forKey:@"SVMXC__Field_Name__c"] ;
            else
                [searchDict setObject:@"" forKey:@"SVMXC__Field_Name__c"] ;

            const char * object_name = (char *)synchronized_sqlite3_column_text(objectStatement, 2);
            if (strlen(object_name))
                [searchDict setObject:[NSString stringWithUTF8String:object_name] forKey:@"SVMXC__Object_Name2__c"] ;
            else
                [searchDict setObject:@"" forKey:@"SVMXC__Object_Name2__c"] ;

            [searchableArray addObject:searchDict];
            [searchDict release];
        }
    }
    synchronized_sqlite3_finalize(objectStatement);
    return [searchableArray autorelease];
    
}
- (NSMutableArray *) getDisplayFieldsForObject:(NSString *)objectId
{
    NSMutableArray *displayFieldsArray = [[NSMutableArray alloc] init];
    NSString *objectQuery = [NSString stringWithFormat:@"SELECT Id,SVMXC__Field_Name__c, SVMXC__Object_Name2__c FROM SFM_Search_Field where SVMXC__Search_Object_Field_Type__c = 'Result' and ObjectId = '%@'",objectId];
    sqlite3_stmt * objectStatement;
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [objectQuery UTF8String], -1, &objectStatement, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(objectStatement) == SQLITE_ROW)
        {
            NSMutableDictionary *displayDict = [[NSMutableDictionary alloc] init];
            const char * displayid = (char *)synchronized_sqlite3_column_text(objectStatement, 0);
            if (strlen(displayid))
                [displayDict setObject:[NSString stringWithUTF8String:displayid] forKey:@"Id"] ;
            else
                [displayDict setObject:@"" forKey:@"Id"] ;
            
            const char * field_name = (char *)synchronized_sqlite3_column_text(objectStatement, 1);
            if (strlen(field_name))
                [displayDict setObject:[NSString stringWithUTF8String:field_name] forKey:@"SVMXC__Field_Name__c"] ;
            else
                [displayDict setObject:@"" forKey:@"SVMXC__Field_Name__c"] ;
            
            const char * object_name = (char *)synchronized_sqlite3_column_text(objectStatement, 2);
            if (strlen(object_name))
                [displayDict setObject:[NSString stringWithUTF8String:object_name] forKey:@"SVMXC__Object_Name2__c"] ;
            else
                [displayDict setObject:@"" forKey:@"SVMXC__Object_Name2__c"] ;
            
            [displayFieldsArray addObject:displayDict];
            [displayDict release];
        }
    }
    synchronized_sqlite3_finalize(objectStatement);
    return [displayFieldsArray autorelease];
}
- (NSMutableArray *) getSearchCriteriaForObject:(NSString *)objectId
{
    NSMutableArray *searchCriteriaArray = [[NSMutableArray alloc] init];
    NSString *objectQuery = [NSString stringWithFormat:@"SELECT Id,SVMXC__Display_Type__c,SVMXC__Field_Name__c, SVMXC__Object_Name2__c,SVMXC__Operand__c,SVMXC__Operator__c FROM SFM_Search_Filter_Criteria where ObjectId = '%@'",objectId];
    sqlite3_stmt * objectStatement;
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [objectQuery UTF8String], -1, &objectStatement, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(objectStatement) == SQLITE_ROW)
        {
            NSMutableDictionary *searchCriteriaDict = [[NSMutableDictionary alloc] init];
            const char * criteriaid = (char *)synchronized_sqlite3_column_text(objectStatement, 0);
            if (strlen(criteriaid))
                [searchCriteriaDict setObject:[NSString stringWithUTF8String:criteriaid] forKey:@"Id"] ;
            else
                [searchCriteriaDict setObject:@"" forKey:@"Id"] ;

            const char * display_type = (char *)synchronized_sqlite3_column_text(objectStatement, 1);
            if (strlen(display_type))
                [searchCriteriaDict setObject:[NSString stringWithUTF8String:display_type] forKey:@"SVMXC__Display_Type__c"] ;
            else
                [searchCriteriaDict setObject:@"" forKey:@"SVMXC__Display_Type__c"] ;

            const char * field_name = (char *)synchronized_sqlite3_column_text(objectStatement, 2);
            if (strlen(field_name))
                [searchCriteriaDict setObject:[NSString stringWithUTF8String:field_name] forKey:@"SVMXC__Field_Name__c"] ;
            else
                [searchCriteriaDict setObject:@"" forKey:@"SVMXC__Field_Name__c"] ;
            
            const char * object_name = (char *)synchronized_sqlite3_column_text(objectStatement, 3);
            if (strlen(object_name))
                [searchCriteriaDict setObject:[NSString stringWithUTF8String:object_name] forKey:@"SVMXC__Object_Name2__c"] ;
            else
                [searchCriteriaDict setObject:@"" forKey:@"SVMXC__Object_Name2__c"] ;

            const char * operand = (char *)synchronized_sqlite3_column_text(objectStatement, 4);
            if (strlen(operand))
                [searchCriteriaDict setObject:[NSString stringWithUTF8String:operand] forKey:@"SVMXC__Operand__c"] ;
            else
                [searchCriteriaDict setObject:@"" forKey:@"SVMXC__Operand__c"] ;

            const char * operator = (char *)synchronized_sqlite3_column_text(objectStatement, 5);
            if (strlen(operator))
                [searchCriteriaDict setObject:[NSString stringWithUTF8String:operator] forKey:@"SVMXC__Operator__c"] ;
            else
                [searchCriteriaDict setObject:@"" forKey:@"SVMXC__Operator__c"] ;

            [searchCriteriaArray addObject:searchCriteriaDict];
            [searchCriteriaDict release];
        }
    }
    synchronized_sqlite3_finalize(objectStatement);
    return [searchCriteriaArray autorelease];

}
- (NSMutableArray *) getResults:(NSString *)object withConfigData:(NSDictionary *)dataForObject
{
    NSArray *searchableArray = [dataForObject objectForKey:@"SearchableFields"];
    NSArray *displayArray = [dataForObject objectForKey:@"DisplayFields"];
    NSMutableArray *displayFieldsArray = [[NSMutableArray alloc] init] ;
    NSMutableArray *TableArray = [[NSMutableArray alloc] init] ;
    NSArray *criteriaArray = [dataForObject objectForKey:@"SearchCriteriaFields"];
    NSMutableArray *results = [[NSMutableArray alloc] init];
    NSMutableString *queryFields = [[NSMutableString alloc] init];
    NSMutableString *joinFields = [[NSMutableString alloc] init];

    int fieldsCount = 2;
    [queryFields appendString:[NSString stringWithFormat:@"'%@'.Id",object]];
    [queryFields appendString:@","];
    [queryFields appendString:[NSString stringWithFormat:@"'%@'.local_id",object]];
    for(int i=0; i<[displayArray count]; i++)
    {
        [queryFields appendString:@","];
        NSString *fieldName = [[displayArray objectAtIndex:i] objectForKey:@"SVMXC__Field_Name__c"];
        NSString *TableName = [[displayArray objectAtIndex:i] objectForKey:@"SVMXC__Object_Name2__c"];
        fieldName = [self getApiNameFromFieldLabel:fieldName];
        TableName = [self getApiNameFromFieldLabel:TableName];

        [queryFields appendFormat:@"'%@'.%@",TableName,fieldName];
        [displayFieldsArray addObject:fieldName];
        if(![TableArray containsObject:TableName])
        [TableArray addObject:TableName];
        fieldsCount++;
    }
    for(int i=0; i<[searchableArray count]; i++)
    {
        NSString *searchableField = [[searchableArray objectAtIndex:i] objectForKey:@"SVMXC__Field_Name__c"];
        searchableField = [self getApiNameFromFieldLabel:searchableField];
        NSMutableString * queryStatement1 = [[NSMutableString alloc]initWithCapacity:0];
        
        queryStatement1 = [NSMutableString stringWithFormat:@"SELECT label FROM SFObjectField where object_api_name = '%@'and api_name='%@'",object,searchableField];    
        sqlite3_stmt * labelstmt;
        const char *selectStatement = [queryStatement1 UTF8String];
        char *field1;        
        if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &labelstmt, nil) == SQLITE_OK )
        {
            if(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW)
            {
                field1 = (char *) synchronized_sqlite3_column_text(labelstmt,0);
            }
        }
		NSString *searchableFieldTableName;
		if(field1)
	       searchableFieldTableName = [self getApiNameFromFieldLabel:[NSString stringWithFormat:@"%s",field1]];
	    else
	       searchableFieldTableName = @"";	
	    
        if(![TableArray containsObject:searchableFieldTableName])
        [TableArray addObject:searchableFieldTableName];
        if(![displayFieldsArray containsObject:searchableField])
        {
            [queryFields appendString:@","];
            [queryFields appendFormat:@"%@",searchableField];
            fieldsCount++;
        }
    }
    [displayFieldsArray release];
    NSString *queryStatement;
    if([criteriaArray count] == 0 )
        queryStatement = [NSString stringWithFormat:@"SELECT %@ FROM '%@' %@ COLLATE NOCASE",queryFields,object,joinFields];
    else 
    {
        NSMutableString *conditionFields = [[NSMutableString alloc] init];
        for(int j=0;j<[criteriaArray count]; j++)
        {
            /*
             "SVMXC__Field_Name__c" = Status;
             "SVMXC__Object_Name2__c" = Case;
             "SVMXC__Operand__c" = Closed;
             "SVMXC__Operator__c" = ne;
             */
            NSString *operand,*fieldName,*TableName,*operator;
            NSDictionary *dict = [criteriaArray objectAtIndex:j];
            NSString *displayType = [dict objectForKey:@"SVMXC__Display_Type__c"];
            if ([displayType isEqualToString:@"REFERENCE"]) 
            {
                NSMutableString * queryStatement1 = [[NSMutableString alloc]initWithCapacity:0];
                queryStatement1 = [NSMutableString stringWithFormat:@"SELECT reference_to FROM SFObjectField where api_name='%@' and object_api_name='%@'",[dict objectForKey:@"SVMXC__Field_Name__c"],object];    
                sqlite3_stmt * labelstmt;
                const char *selectStatement = [queryStatement1 UTF8String];
                char *reference_to_field;        
                if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &labelstmt, nil) == SQLITE_OK )
                {
                    if(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW)
                    {
                        reference_to_field = (char *) synchronized_sqlite3_column_text(labelstmt,0);
                    }
                }
               
                    NSMutableString * queryStatement2 = [[NSMutableString alloc]initWithCapacity:0];
                    queryStatement2 = [NSMutableString stringWithFormat:@"SELECT api_name FROM SFObjectField where name_field='TRUE' and object_api_name='%@'",object];    
                    sqlite3_stmt * labelstmt2;
                    const char *selectStatement2 = [queryStatement2 UTF8String];
                    char *nameofObjectField;        
                    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement2,-1, &labelstmt2, nil) == SQLITE_OK )
                    {
                        if(synchronized_sqlite3_step(labelstmt2) == SQLITE_ROW)
                        {
                            nameofObjectField = (char *) synchronized_sqlite3_column_text(labelstmt2,0);
                        }
                    }
                if(nameofObjectField)
                    fieldName = [NSString stringWithFormat:@"%s",nameofObjectField];
                else
                    fieldName = [NSString stringWithFormat:@""];
                
                if(reference_to_field)
                    TableName = [NSString stringWithFormat:@"%s",reference_to_field];
                else
                    TableName = [NSString stringWithFormat:@""];
                TableName = [self getApiNameFromFieldLabel:TableName];
               if(![TableArray containsObject:TableName])
                [TableArray addObject:TableName];
                operand = [dict objectForKey:@"SVMXC__Operand__c"];
                operator = [dict objectForKey:@"SVMXC__Operator__c"]; 
                synchronized_sqlite3_finalize(labelstmt);
                synchronized_sqlite3_finalize(labelstmt2);
            }
            else
            {
                fieldName = [dict objectForKey:@"SVMXC__Field_Name__c"];
                TableName = [dict objectForKey:@"SVMXC__Object_Name2__c"];
                TableName = [self getApiNameFromFieldLabel:TableName];
                operand = [dict objectForKey:@"SVMXC__Operand__c"];
                operator = [dict objectForKey:@"SVMXC__Operator__c"];
            }
            if(j)
                [conditionFields appendString:@" and "];
            if([operator isEqualToString:@"eq"] )
                [conditionFields appendFormat:@"'%@'.%@ = '%@'",TableName,fieldName,operand];
            if([operator isEqualToString:@"ne"] )
                [conditionFields appendFormat:@"'%@'.%@ != '%@'",TableName,fieldName,operand];
            if([operator isEqualToString:@"gt"] )
                [conditionFields appendFormat:@"'%@'.%@ > '%@'",TableName,fieldName,operand];
            if([operator isEqualToString:@"ge"] )
                [conditionFields appendFormat:@"'%@'.%@ >= '%@'",TableName,fieldName,operand];
            if([operator isEqualToString:@"lt"] )
                [conditionFields appendFormat:@"'%@'.%@ < '%@'",TableName,fieldName,operand];
            if([operator isEqualToString:@"le"] )
                [conditionFields appendFormat:@"'%@'.%@ <= '%@'",TableName,fieldName,operand];
        }
        sqlite3_stmt * labelstmt;
        for (int i=0; i<[TableArray count]; i++) {
            if(![[TableArray objectAtIndex:i]isEqual:object]){
                
                NSMutableString * queryStatement1 = [[NSMutableString alloc]initWithCapacity:0];
                
                queryStatement1 = [NSMutableString stringWithFormat:@"SELECT api_name,type,relationship_name,reference_to FROM SFObjectField where object_api_name = '%@'and label='%@'",object, [self getFieldLabelForApiName:[TableArray objectAtIndex:i]]];    
                
                const char *selectStatement = [queryStatement1 UTF8String];
                char *apiName,*type,*relationshipName,*reference_to;        
                if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &labelstmt, nil) == SQLITE_OK )
                {
                    if(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW)
                    {
                        apiName = (char *) synchronized_sqlite3_column_text(labelstmt,0);
                        type = (char *) synchronized_sqlite3_column_text(labelstmt,1);
                        relationshipName = (char *) synchronized_sqlite3_column_text(labelstmt,2);
                        reference_to =(char *) synchronized_sqlite3_column_text(labelstmt,3);
                        
                    }
                }
                if([[NSString stringWithFormat:@"%s",type]isEqualToString:@"reference"] && ![[NSString stringWithFormat:@"%s",relationshipName] isEqualToString:[NSString stringWithFormat:@"%s",reference_to]]  )
                {
                    [joinFields appendFormat:@" LEFT OUTER JOIN"];
                    [joinFields appendFormat:@" '%@'",[TableArray objectAtIndex:i]];
                    [joinFields appendFormat:@" ON"];
                    [joinFields appendFormat:@" %@.%@ = '%@'.Id",object,[NSString stringWithFormat:@"%s", apiName],[TableArray objectAtIndex:i]];
                }
            }
        }
        synchronized_sqlite3_finalize(labelstmt);
        
    if([conditionFields length] > 0)
            queryStatement = [NSString stringWithFormat:@"SELECT %@ FROM '%@' %@ WHERE %@ COLLATE NOCASE",queryFields,object,joinFields,conditionFields];
        else
            queryStatement = [NSString stringWithFormat:@"SELECT %@ FROM '%@'%@ COLLATE NOCASE ",queryFields,object,joinFields];
    }
    [queryFields release];
    sqlite3_stmt * statement;
    NSLog(@"Query = %@",queryStatement);
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            for(int j=0; j< fieldsCount; j++)
            {
                const char * _type = (char *)synchronized_sqlite3_column_text(statement, j);
                if ( !_type)
                {
                    _type = "";
                }
                NSString *value = [NSString stringWithUTF8String:_type];
                if(j==0)
                {
                    [dict setObject:value forKey:@"Id"];
                }
                else
                if(j==1)
                {
                    [dict setObject:value forKey:@"local_id"];
                }
                else
                {
                    if(j<([displayArray count] +2))
                    {
                        NSDictionary *object = [displayArray objectAtIndex:j-2];
                        [dict setObject:value forKey:[NSString stringWithFormat:@"%@.%@",[object 
                                                      objectForKey:@"SVMXC__Object_Name2__c"],[object 
                                                      objectForKey:@"SVMXC__Field_Name__c"]]];
                    }
                     else
                     {
                         int indexValue = j - [displayArray count] - 2;
                         [dict setObject:value forKey:[[searchableArray objectAtIndex:indexValue ] objectForKey:@"SVMXC__Field_Name__c"]];                      
                     }
                }
            }
            [results addObject:dict];
        }
    }
    synchronized_sqlite3_finalize(statement);
    return [results autorelease];
}
- (NSString *) getFieldLabelForApiName:(NSString *)apiName
{
    NSString *queryStatement = [NSString stringWithFormat:@"SELECT label from SFObject where api_name = '%@'",apiName];
    NSLog(@"Query Statement = %@",queryStatement);
    sqlite3_stmt * statement;
    NSString *apiLabel = apiName;
    if(appDelegate == nil)
        appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            const char * label = (char *)synchronized_sqlite3_column_text(statement, 0);
            if (strlen(label))
            {
              apiLabel = [NSString stringWithUTF8String:label];   
                NSLog(@"Label Name = %@",apiLabel);
            
            }
        }
    }
    
    synchronized_sqlite3_finalize(statement);
    return apiLabel;
    
}
- (NSString *) getApiNameFromFieldLabel:(NSString *)labelName
{
    NSString *queryStatement = [NSString stringWithFormat:@"SELECT api_name from SFObject where label = '%@'",labelName];
    NSLog(@"Query Statement = %@",queryStatement);
    sqlite3_stmt * statement;
    NSString *apiName = labelName;
    if(appDelegate == nil)
        appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            const char * label = (char *)synchronized_sqlite3_column_text(statement, 0);
            if (strlen(label))
            {
                apiName = [NSString stringWithUTF8String:label];   
                NSLog(@"Label Name = %@",apiName);
                
            }
        }
    }
    
    synchronized_sqlite3_finalize(statement);
    return apiName;
    
}
#pragma mark - Location Ping
- (void) didGetSettingsInfoforLocationPing:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    if (appDelegate.isForeGround == TRUE || !appDelegate.isInternetConnectionAvailable)
    {
        if(appDelegate.IsLogedIn == ISLOGEDIN_TRUE)
        {
            appDelegate.initial_sync_succes_or_failed = META_SYNC_FAILED;
            return;
        }
    }
    
    // Get the Active Global Profile
    if ([[result records] count] > 0)
    {
        if(settingInfoIdForLocationPing) [settingInfoIdForLocationPing release];
        if(settingsInfoArrayForLocationPing) [settingsInfoArrayForLocationPing release];
        settingInfoIdForLocationPing = [[NSMutableString alloc] initWithCapacity:0];
        settingsInfoArrayForLocationPing = [[NSMutableArray alloc] initWithCapacity:0];
        for (int i = 0; i < [[result records] count]; i++)
        {
            ZKSObject * obj = [[result records] objectAtIndex:i];
            
            [settingsInfoArrayForLocationPing addObject:[obj fields]];
            
            if ([settingInfoIdForLocationPing length] == 0)
                [settingInfoIdForLocationPing appendFormat:@"(\'%@\'", [[obj fields] objectForKey:@"Id"]];
            else
                [settingInfoIdForLocationPing appendFormat:@", \'%@\'", [[obj fields] objectForKey:@"Id"]];
        }
        [settingInfoIdForLocationPing appendString:@")"];
        
        NSString * _query = @"Select Id, SVMXC__Profile_Name__c, SVMXC__Active__c, SVMXC__IsDefault__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__RecordType_Name__c=\'Configuration Profile\' and SVMXC__Configuration_Type__c = \'Global\' and SVMXC__Active__c = true";
        [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didGetActiveGlobalProfileForLocationPing:error:context:) context:nil];
    }
    else
    {
        // Continue logging in
        didGetPDF = YES;
    }
    [self createTableForLocationHistory];
}
- (void) didGetActiveGlobalProfileForLocationPing:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    if (!appDelegate.isInternetConnectionAvailable)
    {
        [appDelegate displayNoInternetAvailable];
        return;
    }
    
    // Get Settings value Info(query could return multiple rows)
    if ([[result records] count] > 0)
    {
        ZKSObject * obj = [[result records] objectAtIndex:0];
        NSString *ActiveGloProInfoId = [[[obj fields] objectForKey:@"Id"] retain];
        NSString * _query = nil;
        if ([settingInfoIdForLocationPing length] != 0)
            _query = [NSString stringWithFormat:@"Select Id, SVMXC__Setting_Configuration_Profile__c, SVMXC__Setting_ID__c, SVMXC__Internal_Value__c, SVMXC__Display_Value__c, SVMXC__Active__c, SVMXC__IsDefault__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__Setting_Configuration_Profile__c = \'%@\' AND SVMXC__Setting_ID__c IN %@ AND RecordType.Name = \'SETTING VALUE\' ORDER BY SVMXC__Setting_Unique_ID__c", ActiveGloProInfoId, settingInfoIdForLocationPing];
        else
            _query = [NSString stringWithFormat:@"SELECT Id, SVMXC__Setting_Configuration_Profile__c, SVMXC__Setting_ID__c, SVMXC__Internal_Value__c, SVMXC__Display_Value__c, SVMXC__Active__c, SVMXC__IsDefault__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__Setting_Configuration_Profile__c = \'%@' AND RecordType.Name = \'SETTING VALUE\' ORDER BY SVMXC__Setting_Unique_ID__c", ActiveGloProInfoId];
        [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didGetLocationPingSettingsValue:error:context:) context:nil];
        
    }
    else
    {
        // Continue logging in
        didGetPDF = YES;
    }
}
- (void) didGetLocationPingSettingsValue:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    if ([[result records] count] > 0)
    {
        if(settingsValueArrayForLocationPing) [settingsValueArrayForLocationPing release];
        settingsValueArrayForLocationPing = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
        for (int i = 0; i < [[result records] count]; i++)
        {
            ZKSObject * obj = [[result records] objectAtIndex:i];
            [settingsValueArrayForLocationPing addObject:[obj fields]];
        }
        NSMutableArray *locationPingSettingsInfoArray = [[NSMutableArray alloc] init];
        NSMutableArray *locationPingSettingsValueArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < [settingsInfoArrayForLocationPing count]; i++)
        {
            NSMutableDictionary *locationPingSettingInfoDict = [[NSMutableDictionary alloc] init];
            NSDictionary *infoDict = [settingsInfoArrayForLocationPing objectAtIndex:i];
            [locationPingSettingInfoDict setObject:[infoDict objectForKey:@"Id"] forKey:@"Id"];
            [locationPingSettingInfoDict setObject:[infoDict objectForKey:@"SVMXC__Active__c"] forKey:@"SVMXC__Active__c"];
            [locationPingSettingInfoDict setObject:[infoDict objectForKey:@"SVMXC__Data_Type__c"] forKey:@"SVMXC__Data_Type__c"];
            [locationPingSettingInfoDict setObject:[infoDict objectForKey:@"SVMXC__Default_Value__c"] forKey:@"SVMXC__Default_Value__c"];
            [locationPingSettingInfoDict setObject:[infoDict objectForKey:@"SVMXC__Description__c"] forKey:@"SVMXC__Description__c"];
            [locationPingSettingInfoDict setObject:[infoDict objectForKey:@"SVMXC__IsPrivate__c"]  forKey:@"SVMXC__IsPrivate__c"];
            [locationPingSettingInfoDict setObject:[infoDict objectForKey:@"SVMXC__IsStandard__c"] forKey:@"SVMXC__IsStandard__c"];
            [locationPingSettingInfoDict setObject:[infoDict objectForKey:@"SVMXC__Search_Order__c"] forKey:@"SVMXC__Search_Order__c"];
            [locationPingSettingInfoDict setObject:[infoDict objectForKey:@"SVMXC__SettingID__c"] forKey:@"SVMXC__SettingID__c"];
            [locationPingSettingInfoDict setObject:[infoDict objectForKey:@"SVMXC__Setting_Type__c"] forKey:@"SVMXC__Setting_Type__c"];
            [locationPingSettingInfoDict setObject:[infoDict objectForKey:@"SVMXC__Setting_Unique_ID__c"] forKey:@"SVMXC__Setting_Unique_ID__c"];
            [locationPingSettingInfoDict setObject:[infoDict objectForKey:@"SVMXC__Settings_Name__c"] forKey:@"SVMXC__Settings_Name__c"];
            [locationPingSettingInfoDict setObject:[infoDict objectForKey:@"SVMXC__SubmoduleID__c"] forKey:@"SVMXC__SubmoduleID__c"];
            [locationPingSettingInfoDict setObject:[infoDict objectForKey:@"SVMXC__Submodule__c"] forKey:@"SVMXC__Submodule__c"];
            [locationPingSettingInfoDict setObject:[infoDict objectForKey:@"SVMXC__Values__c"] forKey:@"SVMXC__Values__c"];
            
            
            for (int j = 0; j < [settingsValueArrayForLocationPing count]; j++)
            {
                NSString * settingsInfoSettingId = [[settingsInfoArrayForLocationPing objectAtIndex:i] objectForKey:@"Id"];
                NSString * settingsValueSettingId = [[settingsValueArrayForLocationPing objectAtIndex:j] objectForKey:@"SVMXC__Setting_ID__c"];
                
                if ([settingsValueSettingId isEqualToString:settingsInfoSettingId])
                {
                    if ([[[settingsInfoArrayForLocationPing objectAtIndex:i] 
                          objectForKey:@"SVMXC__Setting_Unique_ID__c"] Contains:@"IPAD007"])
                    {
                        NSMutableDictionary *locationPingSettingDict = [[NSMutableDictionary alloc] init];
                        NSDictionary *valueDict = [settingsValueArrayForLocationPing objectAtIndex:j];
                        [locationPingSettingDict setObject:[valueDict objectForKey:@"Id"] forKey:@"Id"];
                        [locationPingSettingDict setObject:[valueDict objectForKey:@"SVMXC__Setting_Configuration_Profile__c"] forKey:@"SVMXC__Setting_Configuration_Profile__c"];
                        [locationPingSettingDict setObject:[valueDict objectForKey:@"SVMXC__Setting_ID__c"] forKey:@"SVMXC__Setting_ID__c"];
                        [locationPingSettingDict setObject:[valueDict objectForKey:@"SVMXC__Internal_Value__c"] forKey:@"SVMXC__Internal_Value__c"];
                        [locationPingSettingDict setObject:[valueDict objectForKey:@"SVMXC__Display_Value__c"] forKey:@"SVMXC__Display_Value__c"];
                        [locationPingSettingDict setObject:[valueDict objectForKey:@"SVMXC__Active__c"]  forKey:@"SVMXC__Active__c"];
                        [locationPingSettingDict setObject:[valueDict objectForKey:@"SVMXC__IsDefault__c"] forKey:@"SVMXC__IsDefault__c"];
                        
                        [locationPingSettingsValueArray addObject:locationPingSettingDict];
                        [locationPingSettingDict release];
                    }
                }
            }
            [locationPingSettingsInfoArray addObject:locationPingSettingInfoDict];
            [locationPingSettingInfoDict release];
        }
        [self insertSettingsIntoTable:locationPingSettingsInfoArray:@"SettingsInfo"];        
        [self insertSettingsIntoTable:locationPingSettingsValueArray:@"SettingsValue"];        
    }
}
- (void) createTableForLocationHistory
{
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS Location_History ('id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL UNIQUE DEFAULT  (0),local_id VARCHAR, 'latitude' VARCHAR,'longitude' VARCHAR,'time' VARCHAR,'additional_info' TEXT,'synched' VARCHAR,'synched_on' VARCHAR,'status'  VARCHAR)"]];
    if(result == YES)
        NSLog(@"Location_History Table Create Success");
    else
        NSLog(@"LocationHistory Table Create Failed");
    
}
-(void) insertrecordIntoTableNamed:(NSDictionary *)locationInfo
{
    char *err;
    [self purgeLocationPingTable];
    NSString *latitude = [locationInfo objectForKey:@"latitude"];
    NSString *longitude = [locationInfo objectForKey:@"longitude"];
    NSString *time = [locationInfo objectForKey:@"timestamp"];
    
    NSString *additionalInfo = [locationInfo objectForKey:@"additionalInfo"];
    NSString *status = [locationInfo objectForKey:@"status"];
    
    if(latitude == nil)
        latitude = @"";
    if(longitude == nil)
        longitude = @"";
    if(time == nil)
        time = @"";
    if(additionalInfo == nil)
        additionalInfo = @"";
    if(status == nil)
        status = @"";
    NSString *localID = [iServiceAppDelegate GetUUID];
    
    NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO Location_History ('id','local_id','latitude','longitude','time','additional_info','synched','synched_on','status') VALUES (NULL,'%@','%@','%@','%@','%@','False',' ','%@')",localID,latitude,longitude,time,additionalInfo,status];
    
    NSLog(@"Query = %@",sql);
    if(appDelegate == nil)
        appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
    if(sqlite3_exec(appDelegate.db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        sqlite3_close(appDelegate.db);
        NSLog(@"Failed to Populate Table");
    }
    else
        NSLog(@"Success to Insert Data in Table");
}
- (void) purgeLocationPingTable
{   
    NSString *sql = @"SELECT Count(*) FROM Location_History";
    sqlite3_stmt *statement;
    int field1;
    char *field2;
    if(sqlite3_prepare_v2(appDelegate.db, [sql UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW) 
        {
            field1 = sqlite3_column_int(statement, 0);
            NSLog(@"NO of location rows in DB %d",field1 );
            
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(appDelegate.db);
    //get limit from table
    NSString *limitLocationRecords = [appDelegate.dataBase getSettingValueWithName:@"IPAD007_SET003"];
    limitLocationRecords = (limitLocationRecords!=nil)?limitLocationRecords:@"100";
    if(field1 < [limitLocationRecords intValue])
    {
        return;
    }
    sql = @"select id from Location_History  asc limit 1";
    NSString *field2Str;
    
    if(sqlite3_prepare_v2(appDelegate.db, [sql UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW) 
        {
            field2 = (char *) sqlite3_column_text(statement, 0);
            field2Str =   [[NSString alloc] initWithUTF8String:field2];
            NSLog(@"id =%@",field2Str);
            
        }
        
        NSString * queryStatement = [NSString stringWithFormat:@"DELETE FROM Location_History where id=%@",field2Str];
        
        char * err;
        
        if (sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
            NSLog(@"Purging Failed to delete");
        }
    }
    sqlite3_finalize(statement);
    
}

- (NSString *) getSettingValueWithName:(NSString *)settingName
{
    NSString *settingValue = nil;
    NSString *queryStatement = [NSString stringWithFormat:@"SELECT Id from SettingsInfo where SVMXC__Setting_Unique_ID__c = '%@'",settingName];
    sqlite3_stmt * statement;
    NSString *settingInfoValue = nil;
    if(appDelegate == nil)
        appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            const char * value = (char *)synchronized_sqlite3_column_text(statement, 0);
            if (strlen(value))
            {
                settingInfoValue = [NSString stringWithUTF8String:value];   
            }
            else 
            {
                NSLog(@"Value is nil");
            }
        }
        else 
        {
            NSLog(@"No Records Found");
        }
    }
    else
    {
        NSLog(@"Query Execution Failed");
    }
    if(settingInfoValue!=nil)
    {
        queryStatement = [NSString stringWithFormat:@"SELECT SVMXC__Internal_Value__c from SettingsValue where SVMXC__Setting_ID__c = '%@'",settingInfoValue];
        if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            if (synchronized_sqlite3_step(statement) == SQLITE_ROW)
            {
                const char * value = (char *)synchronized_sqlite3_column_text(statement, 0);
                if (strlen(value))
                {
                    settingValue = [NSString stringWithUTF8String:value];   
                }
                else 
                {
                    NSLog(@"Value is nil");
                    return nil;
                }
            }
            else 
            {
                NSLog(@"No Records Found");
            }
        }
        else
        {
            NSLog(@"Query Execution Failed");
        }
    }
    synchronized_sqlite3_finalize(statement);
    return settingValue;
}
- (NSString *) getActiveTechnicainId
{
    if(appDelegate.isInternetConnectionAvailable)
        [appDelegate goOnlineIfRequired];
    if (appDelegate.loggedInUserId == nil)
        appDelegate.loggedInUserId = [appDelegate.dataBase getLoggedInUserId:appDelegate.username];    
    ZKUserInfo * userinfo = [[ZKServerSwitchboard switchboard] userInfo];    
    NSString * userId = [userinfo userId];
    
    if ((appDelegate.loggedInUserId == nil) || ([appDelegate.loggedInUserId length] > 0))
        appDelegate.loggedInUserId = userId;
    
    NSString * _query = [NSString stringWithFormat:@"SELECT Id, SVMXC__Service_Group__c, SVMXC__Inventory_Location__c  FROM SVMXC__Service_Group_Members__c WHERE SVMXC__Active__c = TRUE and SVMXC__Salesforce_User__c = '%@' limit 1", appDelegate.loggedInUserId];
    
    NSLog(@"Query = %@",_query);
    didUpdateTechnicianLocation = NO;
    [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(initDebriefDataLocationPing:error:context:) context:nil];
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, FALSE)) 
    {
        if (!appDelegate.isInternetConnectionAvailable)
            break;
        if (didUpdateTechnicianLocation)
            break;
    }
    NSLog(@"Active Technician ID = %@",appTechnicianId);
    return appTechnicianId;
}
- (void) initDebriefDataLocationPing:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    didUpdateTechnicianLocation = YES;
    if (!appDelegate.isInternetConnectionAvailable)
    {
        return;
    }
    NSArray * array = [result records];
    
    if([array count] == 0)
    {
        NSLog(@"No Active Technician Found");
        appTechnicianId = nil;
        appServiceTeamId = nil;
        return;
    }
    
    ZKSObject * obj = [array objectAtIndex:0];
    if (appServiceTeamId != nil)
    {
        [appServiceTeamId release];
        appServiceTeamId = nil;
    }
    appServiceTeamId = [[[obj fields] objectForKey:@"SVMXC__Service_Group__c"] retain];
    
    if (appTechnicianId != nil)
    {
        [appTechnicianId release];
        appTechnicianId = nil;
    }
    appTechnicianId = [[[obj fields] objectForKey:@"Id"] retain];
}
- (NSDictionary *)getUserLocation
{
    NSMutableDictionary *location = [[NSMutableDictionary alloc] init];
    NSString *sql = @"select latitude,longitude from Location_History  dsc limit 1";
    sqlite3_stmt *statement;
    char *longitude;
    char *latitude;
    if(sqlite3_prepare_v2(appDelegate.db, [sql UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW) 
        {
            latitude  = (char *) sqlite3_column_text(statement, 0);
            longitude = (char *) sqlite3_column_text(statement, 1);
            if(longitude!=nil)
                [location setObject:[NSString stringWithFormat:@"%s",longitude] forKey:@"longitude"];
            if(latitude!=nil)
                [location setObject:[NSString stringWithFormat:@"%s",latitude] forKey:@"latitude"];
        }        
    }
    sqlite3_finalize(statement);
    return [location autorelease];
}

#pragma mark - Initial MetaSync
- (void) insertValuesInToOBjDefTableWithObject:(NSMutableArray *)object definition:(NSMutableArray *)objectDefinition
{
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFObjectField ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0) ,'object_api_name' VARCHAR,'api_name' VARCHAR,'label' VARCHAR,'precision' DOUBLE,'length' INTEGER,'type' VARCHAR,'reference_to' VARCHAR,'nillable' BOOL,'unique' BOOL,'restricted_picklist' BOOL,'calculated' BOOL,'defaulted_on_create' BOOL,'name_field' BOOL, 'relationship_name' VARCHAR , 'dependent_picklist' BOOL ,'controler_field' VARCHAR)"]];
    
    if (result == YES)
    {
        int id_value = 1;
        
        NSMutableArray * objectArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
        NSArray * fieldArray  = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
        NSString * objectName = @"";
        
        NSString * emptyString = @"";
        
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@', '%@','%@', '%@', '%@', '%@', '%@', '%@', '%@') VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11, ?12, ?13, ?14)", SFOBJECTFIELD ,MOBJECT_API_NAME, MFIELD_API_NAME, MLENGTH, MTYPEM, MREFERENCE_TO, MRELATIONSHIP_NAME, MLABEL, MPRECISION, MNILLABLE, MRESTRICTED_PICKLIST, MCALCULATED, MDEFAULT_ON_CREATE, MNAME_FIELD, MLOCAL_ID];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);
        
        if (ret_value == SQLITE_OK)
        {
            for (int i = 0; i < [object count]; i++)
            {
                NSDictionary * dict = [object objectAtIndex:i];
                
                objectName = ([dict valueForKey:OBJECT] != nil)?[dict valueForKey:OBJECT]:@"";
           
                
                NSDictionary * objectDict = [objectDefinition objectAtIndex:i];
                NSArray * keys = [objectDict allKeys];
                for (int k = 0; k < [keys count]; k++)
                {
                    if ([objectName isEqualToString:[keys objectAtIndex:k]])
                    {
                        objectArray = [objectDict objectForKey:[keys objectAtIndex:k]];
                        break;
                    }
                }
                for (int m = 0; m < [objectArray count]; m++)
                {
                    NSDictionary * dictionary = [objectArray objectAtIndex:m];
                    keys = [dictionary allKeys];
                    for (int j = 0; j < [keys count]; j++)
                    {
                        if ( [[keys objectAtIndex:j] isEqualToString:MFIELDPROPERTY])
                        {
                            fieldArray = [dictionary objectForKey:MFIELDPROPERTY];
                            break;
                        }
                    }
                    
                }
                
                
                for (int m = 0; m < [fieldArray count]; m++)
                {
                    NSDictionary * dictionary = [fieldArray objectAtIndex:m];
                    
                    NSDictionary * obj = [dictionary objectForKey:FIELD];

                    NSString * label = ([obj objectForKey:_LABEL] != nil)?[obj objectForKey:_LABEL]:@"";
                    if (![label isEqualToString:@""])
                    {
                        label = [label stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                    }
                    
                    NSString * type = ([obj objectForKey:_TYPE] != nil)?[obj objectForKey:_TYPE]:@"";
                    type = [type lowercaseString];
                    
                    sqlite3_bind_text(bulkStmt, 1, [objectName UTF8String], [objectName length], SQLITE_TRANSIENT);
                    
                    sqlite3_bind_text(bulkStmt, 2, [([obj objectForKey:FIELD] != nil)?[obj objectForKey:FIELD]:@"" UTF8String], [([obj objectForKey:FIELD] != nil)?[obj objectForKey:FIELD]:@"" length], SQLITE_TRANSIENT);
                    
                    sqlite3_bind_text(bulkStmt, 3, [([obj objectForKey:_LENGTH] != nil)?[obj objectForKey:_LENGTH]:@"" UTF8String], [([obj objectForKey:_LENGTH] != nil)?[obj objectForKey:_LENGTH]:@"" length], SQLITE_TRANSIENT);
                    
                    sqlite3_bind_text(bulkStmt, 4, [type UTF8String], [type length], SQLITE_TRANSIENT);
                    
                    sqlite3_bind_text(bulkStmt, 5, [([obj objectForKey:_REFERENCETO] != nil)?[obj objectForKey:_REFERENCETO]:@"" UTF8String], [([obj objectForKey:_REFERENCETO] != nil)?[obj objectForKey:_REFERENCETO]:@"" length], SQLITE_TRANSIENT);
                    
                    sqlite3_bind_text(bulkStmt, 6, [([obj objectForKey:_RELATIONSHIPNAME] != nil)?[obj objectForKey:_RELATIONSHIPNAME]:@"" UTF8String], [([obj objectForKey:_RELATIONSHIPNAME] != nil)?[obj objectForKey:_RELATIONSHIPNAME]:@"" length], SQLITE_TRANSIENT);
                    
                    sqlite3_bind_text(bulkStmt, 7, [label UTF8String], [label length], SQLITE_TRANSIENT);
                    
                    sqlite3_bind_text(bulkStmt, 8, [emptyString UTF8String], [emptyString length], SQLITE_TRANSIENT);
                    
                    sqlite3_bind_text(bulkStmt, 9, [emptyString UTF8String], [emptyString length], SQLITE_TRANSIENT);
                    
                    sqlite3_bind_text(bulkStmt, 10, [emptyString UTF8String], [emptyString length], SQLITE_TRANSIENT);
                    
                    sqlite3_bind_text(bulkStmt, 11, [emptyString UTF8String], [emptyString length], SQLITE_TRANSIENT);
                    
                    sqlite3_bind_text(bulkStmt, 12, [emptyString UTF8String], [emptyString length], SQLITE_TRANSIENT);
                    
                    sqlite3_bind_text(bulkStmt, 13, [([obj objectForKey:_NAMEFIELD] != nil)?[obj objectForKey:_NAMEFIELD]:@"" UTF8String], [([obj objectForKey:_NAMEFIELD] != nil)?[obj objectForKey:_NAMEFIELD]:@"" length], SQLITE_TRANSIENT);
                    
                    sqlite3_bind_int(bulkStmt, 14, id_value++);
                    
                    if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                    {
                        printf("Commit Failed!\n");
                    }
                    
                    sqlite3_reset(bulkStmt);
                                        
                }
                            
            }
        }
    }
    
    [self insertValuesInToReferenceTable:object definition:objectDefinition];
}


- (void) insertValuesInToReferenceTable:(NSMutableArray *)object definition:(NSMutableArray *)objectDefinition
{
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFReferenceTo ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0) ,'object_api_name' VARCHAR,'field_api_name' VARCHAR,'reference_to' VARCHAR)"]];
    
    if (result == YES)
    {
        int id_Value = 1;
        NSMutableArray * objectArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
      
        
        NSString * objectName = @"";
        
                
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@') VALUES (?1,    ?2, ?3, ?4)", SFREFERENCETO, MOBJECT_API_NAME, _MFIELD_API_NAME, MREFERENCE_TO, MLOCAL_ID];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);
        

        
        for (int i = 0; i < [object count]; i++)
        {
            NSDictionary * dict = [object objectAtIndex:i];
            
            objectName = ([dict valueForKey:OBJECT] != nil)?[dict valueForKey:OBJECT]:@"";
              
            NSDictionary * objectDict = [objectDefinition objectAtIndex:i];
            NSArray * keys = [objectDict allKeys];
            for (int k = 0; k < [keys count]; k++)
            {
                if ([objectName isEqualToString:[keys objectAtIndex:k]])
                {
                    objectArray = [objectDict objectForKey:[keys objectAtIndex:k]];
                    break;
                }
            }
            NSLog(@"%d", [objectArray count]);
            
            NSArray * fieldArray = [[[NSArray alloc] init] autorelease];
            for (int m = 0; m < [objectArray count]; m++)
            {
                NSDictionary * dictionary = [objectArray objectAtIndex:m];
                keys = [dictionary allKeys];
                for (int j = 0; j < [keys count]; j++)
                {
                    if ( [[keys objectAtIndex:j] isEqualToString:MFIELDPROPERTY])
                    {
                        fieldArray = [dictionary objectForKey:MFIELDPROPERTY];
                        break;
                    }
                }
                
            }
            
            
            if (ret_value == SQLITE_OK)
            {
                for (int m = 0; m < [fieldArray count]; m++)
                {
                    NSDictionary * dictionary = [fieldArray objectAtIndex:m];
                    NSDictionary  * obj = [dictionary objectForKey:FIELD];
                    
                    NSString * referenceName = [obj objectForKey:_REFERENCETO];
                    NSLog(@"%@", referenceName);
                    if (!referenceName)
                        referenceName = @"";
                
                    if (!([referenceName isEqualToString:@""]))
                    {
                        sqlite3_bind_text(bulkStmt, 1, [objectName UTF8String], [objectName length], SQLITE_TRANSIENT);
                        
                        sqlite3_bind_text(bulkStmt, 2, [([obj objectForKey:FIELD] != nil)?[obj objectForKey:FIELD]:@"" UTF8String], [ ([obj objectForKey:FIELD] != nil)?[obj objectForKey:FIELD]:@"" length], SQLITE_TRANSIENT);
                        
                        sqlite3_bind_text(bulkStmt, 3, [([obj objectForKey:_REFERENCETO] != nil)?[obj objectForKey:_REFERENCETO]:@"" UTF8String], [([obj objectForKey:_REFERENCETO] != nil)?[obj objectForKey:_REFERENCETO]:@"" length], SQLITE_TRANSIENT);
                        
                        sqlite3_bind_int(bulkStmt, 4, id_Value++);
                        
                        if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                        {
                            printf("Commit Failed!\n");
                        }
                        
                        sqlite3_reset(bulkStmt);
                    }
                }
            }
        }
    }
    
    [self insertValuesInToRecordType:object defintion:objectDefinition];
    
}

- (void) insertValuesInToRecordType:(NSMutableArray *)object defintion:(NSMutableArray *)objectDefinition
{
    
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFRecordType ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0) ,'record_type_id' VARCHAR,'object_api_name' VARCHAR,'record_type' VARCHAR)"]];
    
    if (result == YES)
    {
        NSString * objectName = @"";
        int id_Value =  1;
                
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@') VALUES (?1, ?2,   ?3, ?4)", SFRECORDTYPE, MRECORD_TYPE_ID, MOBJECT_API_NAME, MRECORD_TYPE, MLOCAL_ID];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);
        
        for (int i = 0; i < [object count]; i++)
        {
            
            NSDictionary * dict = [object objectAtIndex:i];
            
            objectName = ([dict valueForKey:OBJECT] != nil)?[dict valueForKey:OBJECT]:@"";
            
            NSDictionary * objectDict = [objectDefinition objectAtIndex:i];
            
            NSArray * objectArray = [[[NSArray alloc] init] autorelease];
            NSArray * keys = [objectDict allKeys];
            for (int k = 0; k < [keys count]; k++)
            {
                if ([objectName isEqualToString:[keys objectAtIndex:k]])
                {
                    objectArray = [objectDict objectForKey:[keys objectAtIndex:k]];
                    break;
                }
            }
            
            NSMutableArray * propertyArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
            for (int m = 0; m < [objectArray count]; m++)
            {
                NSDictionary * dictionary = [objectArray objectAtIndex:m];
                keys = [dictionary allKeys];
                for (int j = 0; j < [keys count]; j++)
                {
                    if ( [[keys objectAtIndex:j] isEqualToString:MOBJECTPROPERTY])
                    {
                        propertyArray = [dictionary objectForKey:MOBJECTPROPERTY];
                        break;
                    }
                }
            }
            
            NSDictionary *  recordType = [[[NSDictionary alloc] init] autorelease];
            for (int m = 0; m < [propertyArray count]; m++)
            {
                
                NSDictionary * dict = [propertyArray objectAtIndex:m];
                keys = [dict allKeys];
                for (int j = 0; j < [keys count]; j++)
                {
                    if ( [[keys objectAtIndex:j] isEqualToString:MRECORDTYPE])
                    {
                        recordType = [dict objectForKey:MRECORDTYPE];
                        break;
                    }
                }            
            }
            
            NSArray * recordKeys = [recordType allKeys];
            NSArray * recordValues = [recordType allValues];
            
            
            if (ret_value == SQLITE_OK)
            {
                for (int r = 0; r < [recordKeys count]; r++)
                {
                    if (![[recordKeys objectAtIndex:r] isEqualToString:MRECORDTYPE])
                    {
                        
                        sqlite3_bind_text(bulkStmt, 1, [[recordKeys objectAtIndex:r] UTF8String], [[recordKeys objectAtIndex:r] length], SQLITE_TRANSIENT);
                        
                        sqlite3_bind_text(bulkStmt, 2, [objectName UTF8String], [objectName length], SQLITE_TRANSIENT);
                        
                        sqlite3_bind_text(bulkStmt, 3, [[recordValues objectAtIndex:r] UTF8String], [[recordValues objectAtIndex:r] length], SQLITE_TRANSIENT);
                        
                        sqlite3_bind_int(bulkStmt, 4, id_Value++);
                        
                        if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                        {
                            printf("Commit Failed!\n");
                        }
                        
                        sqlite3_reset(bulkStmt);
                    }
                }
            }
        }
    }
    [self insertValuesInToObjectTable:object definition:objectDefinition];
}


- (void) insertValuesInToObjectTable:(NSMutableArray *)object definition:(NSMutableArray *)objectDefintion
{
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFObject ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0) ,'key_prefix' VARCHAR,'label' VARCHAR,'label_plural' VARCHAR,'api_name' VARCHAR)"]];
    
    if (result == YES)
    {
    
        NSString * objectName = @"";
        int id_Value = 0;
        
        
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@') VALUES (?1, ?2, ?3, ?4, ?5)", SFOBJECT, MKEY_PREFIX, MLABEL, MLABEL_PURAL, MFIELD_API_NAME, MLOCAL_ID];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);

        if (ret_value == SQLITE_OK)
        {
            for (int i = 0; i < [object count]; i++)
            {
                
                NSDictionary * dict = [object objectAtIndex:i];
                objectName = ([dict valueForKey:OBJECT] != nil)?[dict valueForKey:OBJECT]:@"";
                
                
                NSDictionary * objectDict = [objectDefintion objectAtIndex:i];
                
                NSArray * objectArray = [[[NSArray alloc] init] autorelease];
                NSArray * keys = [objectDict allKeys];
                for (int k = 0; k < [keys count]; k++)
                {
                    if ([objectName isEqualToString:[keys objectAtIndex:k]])
                    {
                        objectArray = [objectDict objectForKey:[keys objectAtIndex:k]];
                        break;
                    }
                }
                
                NSMutableArray * propertyArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
                
                for (int m = 0; m < [objectArray count]; m++)
                {
                    NSDictionary * dictionary = [objectArray objectAtIndex:m];
                    keys = [dictionary allKeys];
                    for (int j = 0; j < [keys count]; j++)
                    {
                        if ( [[keys objectAtIndex:j] isEqualToString:MOBJECTPROPERTY])
                        {
                            propertyArray = [dictionary objectForKey:MOBJECTPROPERTY];
                            break;
                        }
                    }
                }
                NSDictionary *  objDef = [[[NSDictionary alloc] init] autorelease];
                for (int m = 0; m < [propertyArray count]; m++)
                {
                    
                    NSDictionary * dict = [propertyArray objectAtIndex:m];
                    keys = [dict allKeys];
                    for (int j = 0; j < [keys count]; j++)
                    {
                        if ( [[keys objectAtIndex:j] isEqualToString:MOBJECTDEFINITION])
                        {
                            objDef = [dict objectForKey:MOBJECTDEFINITION];
                            break;
                        }
                    }            
                }
                        
                sqlite3_bind_text(bulkStmt, 1, [([objDef objectForKey:_MKEYPREFIX]!= nil)?[objDef objectForKey:_MKEYPREFIX]:@"" UTF8String], [([objDef objectForKey:_MKEYPREFIX]!= nil)?[objDef objectForKey:_MKEYPREFIX]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 2, [([objDef objectForKey:_LABEL]!= nil)?[objDef objectForKey:_LABEL]:@"" UTF8String], [([objDef objectForKey:_LABEL]!= nil)?[objDef objectForKey:_LABEL]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 3, [([objDef objectForKey:_MPLURALLABEL]!= nil)?[objDef objectForKey:_MPLURALLABEL]:@"" UTF8String], [([objDef objectForKey:_MPLURALLABEL]!= nil)?[objDef objectForKey:_MPLURALLABEL]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 4, [objectName UTF8String], [objectName length], SQLITE_TRANSIENT);
                
                sqlite3_bind_int(bulkStmt, 5, ++id_Value);
                
                if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                {
                    printf("Commit Failed!\n");
                }
                
                sqlite3_reset(bulkStmt);
            }
        }
    }
    //Radha 9th jan
    [self insertValuesInToChildRelationshipTable:object definition:objectDefintion];
    
}

- (void) insertValuesInToChildRelationshipTable:(NSMutableArray *)object definition:(NSMutableArray *)objectDefinition
{
    
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFChildRelationship ('local_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  DEFAULT 0,'object_api_name_parent' VARCHAR, 'object_api_name_child' VARCHAR, 'cascade_delete' BOOL, 'field_api_name' VARCHAR)"]];
    
    if (result == YES)
    {
        int id_value = 0;
        NSString * objectName = @"";
        
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@') VALUES (?1, ?2, ?3, ?4, ?5)", SFCHILDRELATIONSHIP, @"object_api_name_parent", @"object_api_name_child", @"cascade_delete", @"field_api_name", MLOCAL_ID];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);
        
        NSString * emptyString = @"";
        
        if (ret_value == SQLITE_OK)
        {
            for (int i = 0; i < [object count]; i++)
            {
                NSDictionary * masterDetail;
                NSDictionary * dict = [object objectAtIndex:i];
                objectName = ([dict valueForKey:OBJECT] != nil)?[dict valueForKey:OBJECT]:@"";
                
                
                NSDictionary * objectDict = [objectDefinition objectAtIndex:i];
                
                NSArray * objectArray = [[[NSArray alloc] init] autorelease];
                NSArray * keys = [objectDict allKeys];
                for (int k = 0; k < [keys count]; k++)
                {
                    if ([objectName isEqualToString:[keys objectAtIndex:k]])
                    {
                        objectArray = [objectDict objectForKey:[keys objectAtIndex:k]];
                        break;
                    }
                }
                NSMutableArray * propertyArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
                for (int m = 0; m < [objectArray count]; m++)
                {
                    NSDictionary * dictionary = [objectArray objectAtIndex:m];
                    keys = [dictionary allKeys];
                    for (int j = 0; j < [keys count]; j++)
                    {
                        if ( [[keys objectAtIndex:j] isEqualToString:MOBJECTPROPERTY])
                        {
                            propertyArray = [dictionary objectForKey:MOBJECTPROPERTY];
                            break;
                        }
                    }
                }
                NSDictionary *  objDef = [[[NSDictionary alloc] init] autorelease];;
                for (int m = 0; m < [propertyArray count]; m++)
                {
                    
                    NSDictionary * dict = [propertyArray objectAtIndex:m];
                    keys = [dict allKeys];
                    for (int j = 0; j < [keys count]; j++)
                    {
                        if ( [[keys objectAtIndex:j] isEqualToString:MOBJECTDEFINITION])
                        {
                            objDef = [dict objectForKey:MOBJECTDEFINITION];
                            break;
                        }
                    }            
                }
                
                masterDetail = [objDef objectForKey:MASTERDETAILS];
                
                NSArray * masterDetailKeys = [masterDetail allKeys];
                NSArray * mastetDetaiValues = [masterDetail allValues];
                
                
                for (int val = 0; val < [masterDetailKeys count]; val++)
                {
                    sqlite3_bind_text(bulkStmt, 1, [objectName UTF8String], [objectName length], SQLITE_TRANSIENT);
                    
                    sqlite3_bind_text(bulkStmt, 2, [[masterDetailKeys objectAtIndex:val] UTF8String], [[masterDetailKeys objectAtIndex:val] length], SQLITE_TRANSIENT);
                    
                    sqlite3_bind_text(bulkStmt, 3, [emptyString UTF8String], [emptyString length], SQLITE_TRANSIENT);
                    
                    sqlite3_bind_text(bulkStmt, 4, [[mastetDetaiValues objectAtIndex:val] UTF8String], [[mastetDetaiValues objectAtIndex:val] length], SQLITE_TRANSIENT);
                    
                    sqlite3_bind_int(bulkStmt, 5, ++id_value);
                    
                    if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                    {
                        printf("Commit Failed!\n");
                    }
                    
                    sqlite3_reset(bulkStmt);

                    
                }
            }
        }
    }
    [self createObjectTable:object coulomns:objectDefinition];
}

- (void) createObjectTable:(NSMutableArray *)object coulomns:(NSMutableArray *)columns
{
    NSMutableArray * objectArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];;
    NSString * objectName = @"";
    NSString * queryStatement;
    
    for (int i = 0; i < [object count]; i++)
    {
        NSDictionary * dict = [object objectAtIndex:i];
        
        objectName = ([dict valueForKey:OBJECT] != nil)?[dict valueForKey:OBJECT]:@"";
        
        NSDictionary * objectDict = [columns objectAtIndex:i];
        NSArray * keys = [objectDict allKeys];
        for (int k = 0; k < [keys count]; k++)
        {
            if ([objectName isEqualToString:[keys objectAtIndex:k]])
            {
                objectArray = [objectDict objectForKey:[keys objectAtIndex:k]];
                break;
            }
        }
        
        NSMutableArray * fieldArray = [[[NSMutableArray alloc] init] autorelease];
        for (int m = 0; m < [objectArray count]; m++)
        {
            NSDictionary * dictionary = [objectArray objectAtIndex:m];
            keys = [dictionary allKeys];
            for (int j = 0; j < [keys count]; j++)
            {
                if ( [[keys objectAtIndex:j] isEqualToString:MFIELDPROPERTY])
                {
                    fieldArray = [dictionary objectForKey:MFIELDPROPERTY];
                    break;
                }
            }
            
        }
        
        if ([objectName isEqualToString:@"Case"])
        {
            objectName = @"'Case'";
            NSLog(@"%@", objectName);
        }
        char *err;
        queryStatement =[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", objectName];
        if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
            NSLog(@"Failed to drop");
            continue;
        }
        
        queryStatement = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ VARCHAR PRIMARY KEY  NOT NULL)", objectName, MLOCAL_ID];
        if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
            NSLog(@"Failed to drop");
            continue;
        }
        
        [self insertColoumnsForTable:objectName columns:fieldArray];

    }
    [self createTableForSummaryAndTroubleShooting];
    appDelegate.wsInterface.didGetObjectDef = TRUE;
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

- (void) insertColoumnsForTable:(NSString *)tableName columns:(NSMutableArray *)columns
{
    NSString * queryStatement;
    
    for (int i = 0; i < [columns count]; i++)
    {
        NSDictionary * dict = [columns objectAtIndex:i];
        
        NSString * type = [self columnType:[[dict objectForKey:FIELD] objectForKey:_TYPE]];
        
        queryStatement = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ %@", tableName, [[dict objectForKey:FIELD] objectForKey:FIELD], type];
        char * err;
        if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
            if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
                [MyPopoverDelegate performSelector:@selector(throwException)];
            NSLog(@"Failed to drop");
        }
    
    }
}

- (void) insertValuesToProcessTable:(NSMutableDictionary *)processDictionary page:(NSMutableArray *)pageHistory
{
    int id_value = 0;
    NSArray * processArray = nil;
    processIdList = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFProcess ('local_id' INTEGER PRIMARY KEY  NOT NULL ,'process_id' VARCHAR,'object_api_name' VARCHAR,'process_type' VARCHAR,'process_name' VARCHAR,'process_description' VARCHAR, 'page_layout_id' VARCHAR, 'process_info' BLOB)"]];
    
    if (result == YES)
    {
        processArray = [processDictionary objectForKey:MSFMProcess];
        
        NSString * process_type = @"";
        
        for (int i = 0; i < [processArray count]; i++)
        {
            NSDictionary * dict = [processArray objectAtIndex:i];
            
            NSString * str = ([dict objectForKey:MPROCESS_DESCRIPTION] != nil)?[dict objectForKey:MPROCESS_DESCRIPTION]:@"";
            str = [str stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            
            process_type = ([dict objectForKey:MPROCESS_TYPE] != nil)?[dict objectForKey:MPROCESS_TYPE]:@"";
                        
            if ([process_type isEqualToString:SOURCE_TO_TARGET_ALL])
                process_type = SOURCETOTARGET;
            else if ([process_type isEqualToString:SOURCE_TO_TARGET_CHILD])
                process_type = SOURCETOTARGETONLYCHILDROWS;
            else if ([process_type isEqualToString:STANDALONE_EDIT])
                process_type = EDIT;
            else if ([process_type isEqualToString:STANDALONE_CREATE])
                process_type = STANDALONECREATE;
            else if ([process_type isEqualToString:VIEW_RECORD])
                process_type = VIEWRECORD;
                
            [processIdList addObject:([dict objectForKey:MPROCESS_UNIQUE_ID] != nil)?[dict objectForKey:MPROCESS_UNIQUE_ID]:@""];
            
            NSString * queryStatement = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@') VALUES ('%@', '%@', '%@', '%@', '%@', '%d')", SFPROCESS, MPROCESS_ID, MPROCESS_TYPE, MPROCESS_NAME, 
                                         MPROCESS_DESCRIPTION, @"page_layout_id", MLOCAL_ID, 
                    ([dict objectForKey:MPROCESS_UNIQUE_ID] != nil)?[dict objectForKey:MPROCESS_UNIQUE_ID]:@"", 
                    process_type, 
                    ([dict objectForKey:MPROCESS_NAME] != nil)?[dict objectForKey:MPROCESS_NAME]:@"", 
                    str, ([dict objectForKey:MPAGE_LAYOUT_ID] != nil)?[dict objectForKey:MPAGE_LAYOUT_ID]:@"", ++id_value];         
            
            char * err;
            int ret = synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err);
            if (ret != SQLITE_OK)
            {
                if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
                    [MyPopoverDelegate performSelector:@selector(throwException)];
                NSLog(@"Failed to insert");
            }

            
        }
        process_type = @"";
        for (int j = 0; j < [processArray count]; j++)
        {
            NSString * objectApiName = @"";
        
            NSData * data = nil;
            
            NSDictionary * dict = [processArray objectAtIndex:j];
            
            NSString * pageId = [dict objectForKey:MPAGE_LAYOUT_ID];
            NSString * process_id = [dict objectForKey:MPROCESS_UNIQUE_ID];
            
            for (int i = 0; i < [pageHistory count]; i++)
            {
                NSDictionary * page_dict = [pageHistory objectAtIndex:i];
                
                NSDictionary * headerDict = [page_dict objectForKey:MHEADER];
                
                NSString * page_layout_id = [headerDict objectForKey:MHEADER_LAYOUT_ID];
                
                if ([page_layout_id isEqualToString:pageId])
                {
                    objectApiName = ([headerDict objectForKey:MHEADER_OBJECT_NAME] != nil)?[headerDict objectForKey:MHEADER_OBJECT_NAME]:@"";
                    
                    //Query to find the process_type
                    sqlite3_stmt * statement;
                    NSString *queryStatement = [NSString stringWithFormat:@"SELECT process_type FROM SFProcess WHERE process_id = '%@'",
                                                   process_id];
                    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
                    {
                        if (synchronized_sqlite3_step(statement) == SQLITE_ROW)
                        {
                            const char * _type = (char *)synchronized_sqlite3_column_text(statement, 0);
                            if (strlen(_type))
                                process_type = [NSString stringWithUTF8String:_type];
                        }
                    }
                    
                    [page_dict setValue:process_type forKey:MPROCESSTYPE];
                    
                    NSString * err;
                    data = [NSPropertyListSerialization dataFromPropertyList:page_dict format:NSPropertyListXMLFormat_v1_0 errorDescription:&err];
                    
                    synchronized_sqlite3_finalize(statement);
                    break;
                }                                                               
            }  
            NSString * queryStatement = [NSString stringWithFormat:@"Update SFProcess Set %@ = '%@', %@ = '%@' Where %@ = '%@' AND %@ = '%@'", MOBJECT_API_NAME, objectApiName, MPROCESS_INFO, data, MPAGE_LAYOUT_ID, pageId, MPROCESS_ID, process_id];
            char * err;
            if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
            {
                if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
                    [MyPopoverDelegate performSelector:@selector(throwException)];
                NSLog(@"Failed to insert");
            }
        } 
    }
    
    
    result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFProcess_test ('process_id' VARCHAR,'layout_id' VARCHAR,'object_name' VARCHAR,'expression_id' VARCHAR,'object_mapping_id' VARCHAR,'component_type' VARCHAR,'local_id' INTEGER PRIMARY KEY  NOT NULL , 'parent_column' VARCHAR, 'value_id' VARCHAR, 'parent_object' VARCHAR)"]];
    
    if (result == YES)
    {
        char * err;
        
        NSString * txnstmt = @"BEGIN TRANSACTION";
        
        int exec_value = synchronized_sqlite3_exec(appDelegate.db, [txnstmt UTF8String], NULL, NULL, &err);
        
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@',  '%@', '%@', '%@', '%@', '%@',     '%@', '%@', '%@', '%@') VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10)", @"SFProcess_test", MPROCESS_ID, @"layout_id", @"object_name", @"expression_id", @"object_mapping_id", @"component_type", @"parent_column", @"value_id", @"parent_object", MLOCAL_ID];
    
        
        sqlite3_stmt * bulkStmt = nil;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], -1, &bulkStmt, NULL);
        
        NSArray * sfProcess_comp = [processDictionary objectForKey:MSFProcess_component];
        id_value = 0;
        
        NSString * processId = @"";
        
        if (ret_value == SQLITE_OK)
        {
            for (int i = 0; i < [sfProcess_comp count]; i++)
            {
                NSDictionary * dict = [sfProcess_comp objectAtIndex:i];
                NSString * processComp_Id = ([dict objectForKey:MPROCESS_ID] != nil)?[dict objectForKey:MPROCESS_ID]:@"";
                
                for (int j = 0; j < [processArray count]; j++)
                {
                    NSDictionary * sfdict = [processArray objectAtIndex:j];
                    
                    NSString * pId = ([sfdict objectForKey:MPROCESS_ID] != nil)?[sfdict objectForKey:MPROCESS_ID]:@"";
                    
                    if ([pId isEqualToString:processComp_Id])
                    {
                        processId = ([sfdict objectForKey:MPROCESS_UNIQUE_ID] != nil)?[sfdict objectForKey:MPROCESS_UNIQUE_ID]:@"";
                        break;
                    }
                }
                
                NSString * mapping_id = ([dict objectForKey:MOBJECT_MAPPING_ID] != nil)?[dict objectForKey:MOBJECT_MAPPING_ID]:@"";
                NSString * value = @"";
                if ([mapping_id isEqualToString:@""])
                {
                    value = ([dict objectForKey:@"value_mapping_id"] != nil)?[dict objectForKey:@"value_mapping_id"]:@"";
                }
                
                sqlite3_bind_text(bulkStmt, 1, [processId UTF8String], strlen([processId UTF8String]), SQLITE_TRANSIENT);  
                
                sqlite3_bind_text(bulkStmt, 2, [([dict objectForKey:MLAYOUT_ID] != nil)?[dict objectForKey:MLAYOUT_ID]:@"" UTF8String], [([dict objectForKey:MLAYOUT_ID] != nil)?[dict objectForKey:MLAYOUT_ID]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 3, [([dict objectForKey:MOBJECT_NAME] != nil)?[dict objectForKey:MOBJECT_NAME]:@"" UTF8String], [([dict objectForKey:MOBJECT_NAME] != nil)?[dict objectForKey:MOBJECT_NAME]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 4, [([dict objectForKey:MEXPRESSION_ID] != nil)?[dict objectForKey:MEXPRESSION_ID]:@"" UTF8String], [([dict objectForKey:MEXPRESSION_ID] != nil)?[dict objectForKey:MEXPRESSION_ID]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 5, [([dict objectForKey:MOBJECT_MAPPING_ID] != nil)?[dict objectForKey:MOBJECT_MAPPING_ID]:@"" UTF8String], [([dict objectForKey:MOBJECT_MAPPING_ID] != nil)?[dict objectForKey:MOBJECT_MAPPING_ID]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 6, [([dict objectForKey:MCOMPONENT_TYPE] != nil)?[dict objectForKey:MCOMPONENT_TYPE]:@"" UTF8String], [([dict objectForKey:MCOMPONENT_TYPE] != nil)?[dict objectForKey:MCOMPONENT_TYPE]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 7, [([dict objectForKey:MPARENT_COLUMN] != nil)?[dict objectForKey:MPARENT_COLUMN]:@"" UTF8String], [ ([dict objectForKey:MPARENT_COLUMN] != nil)?[dict objectForKey:MPARENT_COLUMN]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 8, [([dict objectForKey:MVALUE_MAPPING_ID] != nil)?[dict objectForKey:MVALUE_MAPPING_ID]: @"" UTF8String], [([dict objectForKey:MVALUE_MAPPING_ID] != nil)?[dict objectForKey:MVALUE_MAPPING_ID] :@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 9, [([dict objectForKey:MPARENT_OBJECT] != nil)?[dict objectForKey:MPARENT_OBJECT]:@"" UTF8String], [([dict objectForKey:MPARENT_OBJECT] != nil)?[dict objectForKey:MPARENT_OBJECT]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_int(bulkStmt, 10, ++id_value);
                
                if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                {
                    printf("Commit Failed!\n");
                }
                
                sqlite3_reset(bulkStmt);
                
            }
        }
        
        txnstmt = @"END TRANSACTION";
        exec_value = synchronized_sqlite3_exec(appDelegate.db, [txnstmt UTF8String], NULL, NULL, &err);
        
        
    }
    NSMutableArray * process_comp_array = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];

    for (int i = 0; i < [processIdList count]; i++)
    {        
        NSString * queryStatement = [NSString stringWithFormat:@"SELECT process_type FROM SFProcess WHERE process_id = '%@'", [processIdList objectAtIndex:i]];
        sqlite3_stmt * statement;
        NSString * processType = @"";
        if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            if (synchronized_sqlite3_step(statement) == SQLITE_ROW)
            {
                const char * _type = (char *)synchronized_sqlite3_column_text(statement, 0);
                if (strlen(_type))
                    processType = [NSString stringWithUTF8String:_type];
            }
        }
        
        synchronized_sqlite3_finalize(statement);
        
        NSArray * keys = [NSArray arrayWithObjects:MPROCESS_ID, MLAYOUT_ID, TARGET_OBJECT_NAME, SOURCE_OBJECT_NAME, EXPRESSION_ID, OBJECT_MAPPING_ID, MCOMPONENT_TYPE, MPARENT_COLUMN, MVALUE_MAPPING_ID, nil];
        NSString * processId = @"", * layoutId = @"", * sourceName = @"", * expressionId = @"", * oMappingId = @"",* componentType = @"", * parentColumn = @"", * targetName = @"", * vMappingid = @"";
                                                    
        if ([processType isEqualToString:VIEWRECORD])
        {
            sqlite3_stmt * viewstatement;
            queryStatement = [NSString stringWithFormat:@"SELECT * FROM SFprocess_test WHERE process_id = '%@'", [processIdList objectAtIndex:i]];
            
            if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &viewstatement, NULL) == SQLITE_OK)
            {
                while (synchronized_sqlite3_step(viewstatement) == SQLITE_ROW)
                {
                    char * _processId = (char *) synchronized_sqlite3_column_text(viewstatement, COLUMNPROCESS_ID);
                    if ((_processId != nil) && strlen(_processId))
                        processId = [NSString stringWithUTF8String:_processId];
                    
                    char * _layoutId = (char *) synchronized_sqlite3_column_text(viewstatement, COLUMNLAYOUT_ID);
                    if ((_layoutId != nil) && strlen(_layoutId))
                        layoutId = [NSString stringWithUTF8String:_layoutId];
                    
                    char * _objectName = (char *) synchronized_sqlite3_column_text(viewstatement, COLUMNOBJECT_NAME);
                    if ((_objectName != nil) && strlen(_objectName))
                        sourceName = [NSString stringWithUTF8String:_objectName];
                    
                    char * _expressionId = (char *) synchronized_sqlite3_column_text(viewstatement, COLUMNEXPRESSION_ID);
                    if ((_expressionId != nil) && strlen(_expressionId))
                        expressionId = [NSString stringWithUTF8String:_expressionId];
                    
                    char * _mappingId = (char *) synchronized_sqlite3_column_text(viewstatement, COLUMNMAPPING_ID);
                    if ((_mappingId != nil) && strlen(_mappingId))
                        oMappingId = [NSString stringWithUTF8String:_mappingId];

                    char * _componentType = (char *) synchronized_sqlite3_column_text(viewstatement, COLUMNCOMP_TYPE);
                    if ((_componentType != nil) && strlen(_componentType))
                        componentType = [NSString stringWithUTF8String:_componentType];

                    char * _parentColumn = (char *) synchronized_sqlite3_column_text(viewstatement, COLUMNPARENT_COLUMN);
                    if ((_parentColumn != nil) && strlen(_parentColumn))
                        parentColumn = [NSString stringWithUTF8String:_parentColumn];
                    
                    char * _value_id = (char *) synchronized_sqlite3_column_text(viewstatement, COLUNMVALUEMAP);
                    if ((_value_id != nil) && strlen(_value_id))
                        vMappingid = [NSString stringWithUTF8String:_value_id];
                    
                    if (![sourceName isEqualToString:@""])
                        targetName = sourceName;
                        
                    NSArray * objects = [NSArray arrayWithObjects:processId, layoutId, targetName, sourceName, expressionId, oMappingId, componentType, parentColumn, vMappingid, nil];
                    
                    NSDictionary * dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
                    NSArray * arr = [NSArray arrayWithObject:dict];
                    [process_comp_array addObjectsFromArray:arr];
                    processId = @"", layoutId = @"", sourceName = @"", expressionId = @"", oMappingId = @"",componentType = @"",  parentColumn = @"", targetName = @"", vMappingid = @"";
                }
                
            }
            synchronized_sqlite3_finalize(viewstatement);
        }
        else if ([processType isEqualToString:EDIT])
        {
            sqlite3_stmt * editstatement;
            queryStatement = [NSString stringWithFormat:@"SELECT * FROM SFprocess_test WHERE process_id = '%@'", [processIdList objectAtIndex:i]];
            
            if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &editstatement, NULL) == SQLITE_OK)
            {
                while (synchronized_sqlite3_step(editstatement) == SQLITE_ROW)
                {
                    char * _processId = (char *) synchronized_sqlite3_column_text(editstatement, COLUMNPROCESS_ID);
                    if ((_processId != nil) && strlen(_processId))
                        processId = [NSString stringWithUTF8String:_processId];
                    
                    char * _layoutId = (char *) synchronized_sqlite3_column_text(editstatement, COLUMNLAYOUT_ID);
                    if ((_layoutId != nil) && strlen(_layoutId))
                        layoutId = [NSString stringWithUTF8String:_layoutId];
                    
                    char * _objectName = (char *) synchronized_sqlite3_column_text(editstatement, COLUMNOBJECT_NAME);
                    if ((_objectName != nil) && strlen(_objectName))
                        sourceName = [NSString stringWithUTF8String:_objectName];
                    
                    char * _expressionId = (char *) synchronized_sqlite3_column_text(editstatement, COLUMNEXPRESSION_ID);
                    if ((_expressionId != nil) && strlen(_expressionId))
                        expressionId = [NSString stringWithUTF8String:_expressionId];
                    
                    char * _mappingId = (char *) synchronized_sqlite3_column_text(editstatement, COLUMNMAPPING_ID);
                    if ((_mappingId != nil) && strlen(_mappingId))
                        oMappingId = [NSString stringWithUTF8String:_mappingId];
                    
                    char * _componentType = (char *) synchronized_sqlite3_column_text(editstatement, COLUMNCOMP_TYPE);
                    if ((_componentType != nil) && strlen(_componentType))
                        componentType = [NSString stringWithUTF8String:_componentType];
                    
                    char * _parentColumn = (char *) synchronized_sqlite3_column_text(editstatement, COLUMNPARENT_COLUMN);
                    if ((_parentColumn != nil) && strlen(_parentColumn))
                        parentColumn = [NSString stringWithUTF8String:_parentColumn];
                    
                    char * _value_id = (char *) synchronized_sqlite3_column_text(editstatement, COLUNMVALUEMAP);
                    if ((_value_id != nil) && strlen(_value_id))
                        vMappingid = [NSString stringWithUTF8String:_value_id];
                    
                    if (![sourceName isEqualToString:@""])
                        targetName = sourceName;
                    
                    NSArray * objects = [NSArray arrayWithObjects:processId, layoutId, targetName, sourceName, expressionId, oMappingId, componentType, parentColumn,vMappingid, nil];
                    
                    NSDictionary * dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
                    NSArray * arr = [NSArray arrayWithObject:dict];
                    [process_comp_array addObjectsFromArray:arr];
                    processId = @"", layoutId = @"", sourceName = @"", expressionId = @"", oMappingId = @"",componentType = @"",  parentColumn = @"", targetName = @"", vMappingid = @"";
                }
               
            }
            synchronized_sqlite3_finalize(editstatement);
        }
        else if ([processType isEqualToString:STANDALONECREATE])
        {
            sqlite3_stmt * createstatement;
            queryStatement = [NSString stringWithFormat:@"SELECT * FROM SFprocess_test WHERE process_id = '%@'", [processIdList objectAtIndex:i]];
            
            if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &createstatement, NULL) == SQLITE_OK)
            {
                while (synchronized_sqlite3_step(createstatement) == SQLITE_ROW)
                {
                    char * _processId = (char *) synchronized_sqlite3_column_text(createstatement, COLUMNPROCESS_ID);
                    if ((_processId != nil) && strlen(_processId))
                        processId = [NSString stringWithUTF8String:_processId];
                    
                    char * _layoutId = (char *) synchronized_sqlite3_column_text(createstatement, COLUMNLAYOUT_ID);
                    if ((_layoutId != nil) && strlen(_layoutId))
                        layoutId = [NSString stringWithUTF8String:_layoutId];
                    
                    char * _objectName = (char *) synchronized_sqlite3_column_text(createstatement, COLUMNOBJECT_NAME);
                    if ((_objectName != nil) && strlen(_objectName))
                        sourceName = [NSString stringWithUTF8String:_objectName];
                    
                    char * _expressionId = (char *) synchronized_sqlite3_column_text(createstatement, COLUMNEXPRESSION_ID);
                    if ((_expressionId != nil) && strlen(_expressionId))
                        expressionId = [NSString stringWithUTF8String:_expressionId];
                    
                    char * _mappingId = (char *) synchronized_sqlite3_column_text(createstatement, COLUMNMAPPING_ID);
                    if ((_mappingId != nil) && strlen(_mappingId))
                        oMappingId = [NSString stringWithUTF8String:_mappingId];
                    
                    char * _componentType = (char *) synchronized_sqlite3_column_text(createstatement, COLUMNCOMP_TYPE);
                    if ((_componentType != nil) && strlen(_componentType))
                        componentType = [NSString stringWithUTF8String:_componentType];
                    
                    char * _parentColumn = (char *) synchronized_sqlite3_column_text(createstatement, COLUMNPARENT_COLUMN);
                    if ((_parentColumn != nil) && strlen(_parentColumn))
                        parentColumn = [NSString stringWithUTF8String:_parentColumn];
                    
                    char * _value_id = (char *) synchronized_sqlite3_column_text(createstatement, COLUNMVALUEMAP);
                    if ((_value_id != nil) && strlen(_value_id))
                        vMappingid = [NSString stringWithUTF8String:_value_id];
                    
                    if (![sourceName isEqualToString:@""])
                        targetName = sourceName;
                    
                    NSArray * objects = [NSArray arrayWithObjects:processId, layoutId, targetName, sourceName, expressionId, oMappingId, componentType, parentColumn, vMappingid, nil];
                    
                    NSDictionary * dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
                    NSArray * arr = [NSArray arrayWithObject:dict];
                    [process_comp_array addObjectsFromArray:arr];
                    processId = @"", layoutId = @"", sourceName = @"", expressionId = @"", oMappingId = @"",componentType = @"",  parentColumn = @"", targetName = @"", vMappingid = @"";
                }
                
            }
            synchronized_sqlite3_finalize(createstatement);

        }
              
    }
    result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFProcessComponent ('process_id' VARCHAR,'layout_id' VARCHAR,'target_object_name' VARCHAR,'source_object_name' VARCHAR,'expression_id' VARCHAR,'object_mapping_id' VARCHAR,'component_type' VARCHAR,'local_id' INTEGER PRIMARY KEY  NOT NULL ,'parent_column' VARCHAR, 'value_mapping_id' VARCHAR, 'source_child_parent_column' VARCHAR)"]];
    
    if (result == YES)
    {
        char * err;
        NSString * txnstmt = @"BEGIN TRANSACTION";
        
        int exec_value = synchronized_sqlite3_exec(appDelegate.db, [txnstmt UTF8String], NULL, NULL, &err);        
        
        
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@', '%@',  '%@', '%@', '%@', '%@') VALUES (?1, ?2, ?3, ?4, ?5, ?6,?7, ?8, ?9, ?10, ?11)", SFPROCESSCOMPONENT, MPROCESS_ID, MLAYOUT_ID, MTARGET_OBJECT_NAME, MSOURCE_OBJECT_NAME, MEXPRESSION_ID, MOBJECT_MAPPING_ID, MCOMPONENT_TYPE, MPARENT_COLUMN,MVALUE_MAPPING_ID,@"source_child_parent_column", MLOCAL_ID];
        
        sqlite3_stmt * bulkStmt;
        
        int ret_val = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]),  &bulkStmt, NULL);

        
        id_value = 0;
        NSString * emptyString = @"";
        
        if (ret_val == SQLITE_OK)
        {
        
            for (int i = 0; i < [process_comp_array count]; i++)
            {
                NSDictionary * dict = [process_comp_array objectAtIndex:i];
                
                sqlite3_bind_text(bulkStmt, 1, [([dict objectForKey:MPROCESS_ID] != nil)?[dict objectForKey:MPROCESS_ID]:@"" UTF8String], [([dict objectForKey:MPROCESS_ID] != nil)?[dict objectForKey:MPROCESS_ID]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 2, [([dict objectForKey:MLAYOUT_ID] != nil)?[dict objectForKey:MLAYOUT_ID]:@""  UTF8String], [([dict objectForKey:MLAYOUT_ID] != nil)?[dict objectForKey:MLAYOUT_ID]:@"" length], 
                                    SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 3, [([dict objectForKey:MTARGET_OBJECT_NAME] != nil)?[dict objectForKey:MTARGET_OBJECT_NAME]:@""  UTF8String], [([dict objectForKey:MTARGET_OBJECT_NAME] != nil)?[dict objectForKey:MTARGET_OBJECT_NAME]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 4, [([dict objectForKey:MSOURCE_OBJECT_NAME] != nil)?[dict objectForKey:MSOURCE_OBJECT_NAME]:@""  UTF8String], [([dict objectForKey:MSOURCE_OBJECT_NAME] != nil)?[dict objectForKey:MSOURCE_OBJECT_NAME]:@"" length], SQLITE_TRANSIENT);
                
                
                sqlite3_bind_text(bulkStmt, 5, [([dict objectForKey:MEXPRESSION_ID] != nil)?[dict objectForKey:MEXPRESSION_ID]:@""  UTF8String], [([dict objectForKey:MEXPRESSION_ID] != nil)?[dict objectForKey:MEXPRESSION_ID]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 6, [([dict objectForKey:MOBJECT_MAPPING_ID] != nil)?[dict objectForKey:MOBJECT_MAPPING_ID]:@""  UTF8String], [([dict objectForKey:MOBJECT_MAPPING_ID] != nil)?[dict objectForKey:MOBJECT_MAPPING_ID]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 7, [([dict objectForKey:MCOMPONENT_TYPE] != nil)?[dict objectForKey:MCOMPONENT_TYPE]:@""  UTF8String], [([dict objectForKey:MCOMPONENT_TYPE] != nil)?[dict objectForKey:MCOMPONENT_TYPE]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 8, [([dict objectForKey:MPARENT_COLUMN] != nil)?[dict objectForKey:MPARENT_COLUMN]:@""  UTF8String], [([dict objectForKey:MPARENT_COLUMN] != nil)?[dict objectForKey:MPARENT_COLUMN]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 9, [([dict objectForKey:MVALUE_MAPPING_ID] != nil)?[dict objectForKey:MVALUE_MAPPING_ID]:@""  UTF8String], [([dict objectForKey:MVALUE_MAPPING_ID] != nil)?[dict objectForKey:MVALUE_MAPPING_ID]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 10, [emptyString  UTF8String], [emptyString length], SQLITE_TRANSIENT);
                
                sqlite3_bind_int(bulkStmt, 11, ++id_value);
                
                if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                {
                    printf("Commit Failed!\n");
                }
                
                sqlite3_reset(bulkStmt);                
                            
            }
        }
        txnstmt = @"END TRANSACTION";
        exec_value = synchronized_sqlite3_exec(appDelegate.db, [txnstmt UTF8String], NULL, NULL, &err);
                                     
    }
    [self insertValuesInToExpressionTables:processDictionary];
}

-(void) insertvaluesToPicklist:(NSMutableArray *)object fields:(NSMutableArray *)fields value:(NSMutableArray *)values
{
    NSLog(@"SAMMAN insertvaluesToPicklist Processing starts: %@", [NSDate date]);
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFPickList ('local_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE, 'object_api_name' VARCHAR,'field_api_name' VARCHAR,'label' VARCHAR,'value' VARCHAR, 'defaultvalue'  VARCHAR , 'valid_for' VARCHAR , 'index_value' INTEGER)"]];
    
    if (result == YES)
    {
        NSString * pickValue = @"";
        NSString * pickLabel = @"";
        NSString * defautPickValue = @"";
        int id_value = 1;
        
        char * err;
        NSString * txnstmt = @"BEGIN TRANSACTION";
        
        int exec_value = synchronized_sqlite3_exec(appDelegate.db, [txnstmt UTF8String], NULL, NULL, &err);
        
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@') VALUES (?1, ?2, ?3, ?4, ?5, ?6)", SFPICKLIST, MOBJECT_API_NAME, _MFIELD_API_NAME, LABEL, MVALUEM, MDEFAULTVALUE, MLOCAL_ID];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);

        

        if (ret_value == SQLITE_OK)
        {
            for (int i = 0; i < [object count]; i++)
            {
                NSString * objectName = [[object objectAtIndex:i] objectForKey:OBJECT];
                
                NSDictionary * fieldDict = [fields objectAtIndex:i];
                
                NSArray * fieldArray = [fieldDict objectForKey:objectName];
                        
                NSDictionary * valueDict = [values objectAtIndex:i];
                
                
                NSArray * picklistValues = [valueDict objectForKey:objectName];
                        
                for (int j = 0; j < [picklistValues count]; j++)
                {
                    NSDictionary * dict = [fieldArray objectAtIndex:j];
                    
                    NSArray * keys = [dict allValues];
                    
                    NSString * fieldName = [keys objectAtIndex:0];
                    
                    NSArray * values = [[picklistValues objectAtIndex:j] objectForKey:fieldName];
                    
                    
                    for (int m = 0; m < [values count]; m++)
                    {
                        NSArray * key = [values objectAtIndex:m];
                        NSArray * value = [values objectAtIndex:++m];
                        
                        int count = [key count];
                        
                        for (int r = 0; r < count; ++r)
                        {
                            if ([[key objectAtIndex:r] isEqualToString:@"ISMULTIPICKLIST"])
                                continue;
                            
                            pickValue = [value objectAtIndex:r];
                            pickValue = [pickValue stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                            pickLabel = [value objectAtIndex:++r];
                            pickLabel = [pickLabel stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                            
                            if ( r < [key count] - 1)
                            {
                                if ([[key objectAtIndex:++r] isEqualToString:DEFAULTPICKLISTVALUE])
                                {
                                    defautPickValue = [value objectAtIndex:r];
                                    defautPickValue = [defautPickValue stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                                }
                                else
                                {
                                    --r;
                                    defautPickValue = @"";
                                }
                            }
                            
                            sqlite3_bind_text(bulkStmt, 1, [objectName UTF8String], [objectName length], SQLITE_TRANSIENT);
                            
                            sqlite3_bind_text(bulkStmt, 2, [fieldName UTF8String], [fieldName length], SQLITE_TRANSIENT);
                            
                            sqlite3_bind_text(bulkStmt, 3, [pickLabel UTF8String], [pickLabel length], SQLITE_TRANSIENT);
                            
                            sqlite3_bind_text(bulkStmt, 4, [pickValue UTF8String], [pickValue length], SQLITE_TRANSIENT);
                            
                            sqlite3_bind_text(bulkStmt, 5, [defautPickValue UTF8String], [defautPickValue length], SQLITE_TRANSIENT);
                            
                            sqlite3_bind_int(bulkStmt, 6, id_value++);
                                                        
                            if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                            {
                                printf("Commit Failed!\n");
                            }
                            
                            sqlite3_reset(bulkStmt);
                            
                        }
                    }
                }
             }
        }
        
        txnstmt = @"END TRANSACTION";
        exec_value = synchronized_sqlite3_exec(appDelegate.db, [txnstmt UTF8String], NULL, NULL, &err);
    }
  
    appDelegate.wsInterface.didGetPicklistValues = TRUE;
    NSLog(@"SAMMAN insertvaluesToPicklist Processing ends: %@", [NSDate date]);
}

- (void) insertValuesInToRTPicklistTableForObject:(id)objects Values:(NSMutableDictionary *)recordTypeDict
{
    int id_value = 0;
    
    NSLog(@"SAMMAN insertValuesInToRTPicklistTableForObject Processing starts: %@", [NSDate date]);
    
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFRTPicklist ('local_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL, 'object_api_name' VARCHAR, 'recordtypename' VARCHAR, 'recordtypelayoutid' VARCHAR, 'recordtypeid' VARCHAR, 'field_api_name' VARCHAR, 'label' VARCHAR, 'value' VARCHAR, 'defaultlabel' VARCHAR, 'defaultvalue' VARCHAR)"]];
    
    
    if (result == YES)
    {
        result = [self createTable:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS RTIndex ON SFRTPicklist (object_api_name, field_api_name, recordtypename, defaultlabel, defaultvalue, label, value)"]];
        
        
        char * err;
        
        NSString * txnstmt = @"BEGIN TRANSACTION";
        
        int exec_value = synchronized_sqlite3_exec(appDelegate.db, [txnstmt UTF8String], NULL, NULL, &err);
        
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ ( %@, %@, %@, %@, %@, %@, %@, %@, %@,%@ ) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10)", SFRTPICKLIST, MOBJECT_API_NAME, _MFIELD_API_NAME, MLABEL, MVALUEM, MDEFAULTVALUE, MDEFAULTLABEL, @"recordtypename", @"recordtypeid", @"recordtypelayoutid", MLOCAL_ID];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);

        
        if (ret_value == SQLITE_OK)
        {
        
            for (NSString * objectName in objects)
            {
                NSMutableArray * RecordTypePickList = [recordTypeDict objectForKey:objectName];
                
                for (NSMutableDictionary * sub_dict in RecordTypePickList)
                {
                    NSString * recordTypeName = ([sub_dict objectForKey:@"RecorTypeName"] != nil)?[sub_dict objectForKey:@"RecorTypeName"]:@"";
                    NSString * recordTypeID = ([sub_dict objectForKey:@"RecorTypeId"] != nil)?[sub_dict objectForKey:@"RecorTypeId"]:@"";
                    NSString * recordTypeLayoutId = ([sub_dict objectForKey:@"RecorTypeLayoutId"] != nil)?[sub_dict objectForKey:@"RecorTypeLayoutId"]:@"";
                    
                    
                    NSArray * picklists = [sub_dict objectForKey:@"PickLists"];
                    NSString * defaultValue = @"";
                    NSString * defaultLabel = @"";
                    NSString * api_name = @"";
                    
                    for (NSDictionary * picklistValueDict in picklists)
                    {
                        defaultLabel = ([picklistValueDict objectForKey:@"PickListDefaultLabel"] != nil)?[picklistValueDict objectForKey:@"PickListDefaultLabel"]:@"";
                        defaultValue = ([picklistValueDict objectForKey:@"PickListDefaultValue"] != nil)?[picklistValueDict objectForKey:@"PickListDefaultValue"]:@"";
                        api_name = ([picklistValueDict objectForKey:@"PickListName"] != nil)?[picklistValueDict objectForKey: @"PickListName"]:@"";
                        NSArray * pickListValue = [picklistValueDict objectForKey:@"PickListValue"];
                        
                        for (NSDictionary * labelValueDict in pickListValue)
                        {                        
                            NSString * label = ([labelValueDict objectForKey:@"label"] != nil)?[labelValueDict objectForKey:@"label"]:@"";
                            NSString * value = ([labelValueDict objectForKey:@"value"] != nil)?[labelValueDict objectForKey:@"value"]:@"";
                            
                            label = [label stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                            value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                            
                            sqlite3_bind_text(bulkStmt, 1, [objectName UTF8String], [objectName length], SQLITE_TRANSIENT);
                            
                            sqlite3_bind_text(bulkStmt, 2, [api_name UTF8String], [api_name length], SQLITE_TRANSIENT);
                            
                            sqlite3_bind_text(bulkStmt, 3, [label UTF8String], [label length], SQLITE_TRANSIENT);
                            
                            sqlite3_bind_text(bulkStmt, 4, [value UTF8String], [value length], SQLITE_TRANSIENT);
                            
                            sqlite3_bind_text(bulkStmt, 5, [defaultLabel UTF8String], [defaultLabel length], SQLITE_TRANSIENT);
                            
                            sqlite3_bind_text(bulkStmt, 6, [defaultValue UTF8String], [defaultValue length], SQLITE_TRANSIENT);
                            
                            sqlite3_bind_text(bulkStmt, 7, [recordTypeName UTF8String], [recordTypeName length], SQLITE_TRANSIENT);
                            
                            sqlite3_bind_text(bulkStmt, 8, [recordTypeID UTF8String], [recordTypeID length], SQLITE_TRANSIENT);
                            
                            sqlite3_bind_text(bulkStmt, 9, [recordTypeLayoutId UTF8String], [recordTypeLayoutId length], SQLITE_TRANSIENT);
                            
                            sqlite3_bind_int(bulkStmt, 10, ++id_value);
                            
                            if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                            {
                                printf("Commit Failed!\n");
                            }
                            
                            sqlite3_reset(bulkStmt);
                            
                        }
                    }
                }
            }
        
        }
        txnstmt = @"END TRANSACTION";
        exec_value = synchronized_sqlite3_exec(appDelegate.db, [txnstmt UTF8String], NULL, NULL, &err);
    
    }
    
    NSLog(@"SAMMAN insertValuesInToRTPicklistTableForObject Processing starts: %@", [NSDate date]);
    
    appDelegate.initial_sync_status = SYNC_SFW_METADATA;
    appDelegate.Sync_check_in = FALSE;
    [appDelegate.wsInterface metaSyncWithEventName:SFW_METADATA eventType:SYNC values:nil];

}
- (void) insertValuesInToExpressionTables:(NSMutableDictionary *)processDictionary
{
    int id_value = 0;
    
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFExpression ('local_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , 'expression_id' VARCHAR, 'expression' VARCHAR, 'expression_name' VARCHAR)"]];
    if (result == YES)
    {
        char * err;    
        
        NSString * txnstmt = @"BEGIN TRANSACTION";
        
        int exec_value = synchronized_sqlite3_exec(appDelegate.db, [txnstmt UTF8String], NULL, NULL, &err);
        
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@') VALUES (?1, ?2,   ?3, ?4)", SFEXPRESSION, MEXPRESSION_ID , MEXPRESSION_NAME, MEXPRESSION, MLOCAL_ID];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);

        
        NSArray * sfExpression = [processDictionary objectForKey:MSFExpression];
        
        if (ret_value == SQLITE_OK)
        {
        
            for (int i = 0; i < [sfExpression count]; i++)
            {
                NSDictionary * dict = [sfExpression objectAtIndex:i];
                
                sqlite3_bind_text(bulkStmt, 1, [([dict objectForKey:MEXPRESSION_ID] != nil)?[dict objectForKey:MEXPRESSION_ID]:@"" UTF8String], [([dict objectForKey:MEXPRESSION_ID] != nil)?[dict objectForKey:MEXPRESSION_ID]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 2, [([dict objectForKey:MEXPRESSION_NAME] != nil)?[dict objectForKey:MEXPRESSION_NAME]:@"" UTF8String], [([dict objectForKey:MEXPRESSION_NAME] != nil)?[dict objectForKey:MEXPRESSION_NAME]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 3, [([dict objectForKey:MADVANCE_EXPRESSION] != nil)?[dict objectForKey:MADVANCE_EXPRESSION]:@"" UTF8String], [([dict objectForKey:MADVANCE_EXPRESSION] != nil)?[dict objectForKey:MADVANCE_EXPRESSION]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_int(bulkStmt, 4, ++id_value);
                                
                if ( synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                {
                    printf("Commit Failed!\n");
                }
                
                sqlite3_reset(bulkStmt);

            }
        }
        txnstmt = @"END TRANSACTION";
        exec_value = synchronized_sqlite3_exec(appDelegate.db, [txnstmt UTF8String], NULL, NULL,     &err);

    }
    id_value = 0;
    
    result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFExpressionComponent ('local_id' INTEGER PRIMARY KEY  NOT NULL ,'expression_id' VARCHAR,'component_sequence_number' VARCHAR,'component_lhs' VARCHAR,'component_rhs' VARCHAR,'operator'CHAR)"]];
    
    if (result == YES)
    {
        char * err;
        
        NSString * txnstmt = @"BEGIN TRANSACTION";
        
        int exec_value = synchronized_sqlite3_exec(appDelegate.db, [txnstmt UTF8String], NULL, NULL, &err);
        
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@') VALUES (?1, ?2, ?3, ?4, ?5, ?6)", SFEXPRESSIONCOMPONENT, MEXPRESSION_ID, MCOMPONENT_SEQ_NUM, MCOMPONENT_LHS, MCOMPONENT_RHS, MOPERATOR, MLOCAL_ID];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);

        NSArray * sfExpression_com = [processDictionary objectForKey:MSFExpression_component];
        
        if (ret_value == SQLITE_OK)
        {
        
            for (int i = 0; i < [sfExpression_com count]; i++)
            {
                NSDictionary * dict = [sfExpression_com objectAtIndex:i];
                
                sqlite3_bind_text(bulkStmt, 1, [([dict objectForKey:MEXPRESSION_ID] != nil)?[dict objectForKey:MEXPRESSION_ID]:@"" UTF8String], [([dict objectForKey:MEXPRESSION_ID] != nil)?[dict objectForKey:MEXPRESSION_ID]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 2, [([dict objectForKey:MSEQUENCE] != nil)?[dict objectForKey:MSEQUENCE]:@"" UTF8String], [([dict objectForKey:MSEQUENCE] != nil)?[dict objectForKey:MSEQUENCE]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 3, [([dict objectForKey:MSOURCE_FIELD_NAME] != nil)?[dict objectForKey:MSOURCE_FIELD_NAME]:@"" UTF8String], [([dict objectForKey:MSOURCE_FIELD_NAME] != nil)?[dict objectForKey:MSOURCE_FIELD_NAME]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 4, [([dict objectForKey:MVALUEM] != nil)?[dict objectForKey:MVALUEM]:@"" UTF8String], [([dict objectForKey:MVALUEM] != nil)?[dict objectForKey:MVALUEM]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 5, [([dict objectForKey:MOPERATOR] != nil)?[dict objectForKey:MOPERATOR]:@"" UTF8String], [([dict objectForKey:MOPERATOR] != nil)?[dict objectForKey:MOPERATOR]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_int(bulkStmt, 6, ++id_value);
                
                if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                {
                    printf("Commit Failed!\n");
                }
                
                sqlite3_reset(bulkStmt);
            }
        }
        
        txnstmt = @"END TRANSACTION";
        exec_value = synchronized_sqlite3_exec(appDelegate.db, [txnstmt UTF8String], NULL, NULL, &err);

    }
    
    
    [self insertValuesInToObjectMappingTable:processDictionary];
}


- (void) insertValuesInToObjectMappingTable:(NSMutableDictionary *)processDictionary
{
    
    int id_value = 0;
    
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFObjectMapping ('local_id' INTEGER PRIMARY KEY  NOT NULL ,'object_mapping_id' VARCHAR , 'source_object_name' VARCHAR, 'target_object_name' VARCHAR)"]];
    if (result == YES)
    {
        
        char * err;
        
        NSString * txnstmt = @"BEGIN TRANSACTION";
        
        int exec_value = synchronized_sqlite3_exec(appDelegate.db, [txnstmt UTF8String], NULL, NULL, &err);
        
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@') VALUES (?1, ?2,   ?3, ?4)", SFOBJECTMAPPING, MOBJECT_MAPPING_ID , MSOURCE_OBJECT_NAME, MTARGET_OBJECT_NAME, MLOCAL_ID];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);

        
        NSArray * sfobjectMap = [processDictionary objectForKey:MSFObject_mapping];
        
        if (ret_value == SQLITE_OK)
        {
        
            for (int i = 0; i < [sfobjectMap count]; i++)
            {
                NSDictionary * dict = [sfobjectMap objectAtIndex:i];
                
                sqlite3_bind_text(bulkStmt, 1, [([dict objectForKey:MOBJECT_MAPPING_ID] != nil)?[dict objectForKey:MOBJECT_MAPPING_ID]:@"" UTF8String], [([dict objectForKey:MOBJECT_MAPPING_ID] != nil)?[dict objectForKey:MOBJECT_MAPPING_ID]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 2, [([dict objectForKey:MSOURCE_OBJECT_NAME] != nil)?[dict objectForKey:MSOURCE_OBJECT_NAME]:@"" UTF8String], [([dict objectForKey:MSOURCE_OBJECT_NAME] != nil)?[dict objectForKey:MSOURCE_OBJECT_NAME]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 3, [([dict objectForKey:MTARGET_OBJECT_NAME] != nil)?[dict objectForKey:MTARGET_OBJECT_NAME]:@"" UTF8String], [([dict objectForKey:MTARGET_OBJECT_NAME] != nil)?[dict objectForKey:MTARGET_OBJECT_NAME]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_int(bulkStmt, 4, ++id_value);
                
                if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                {
                    printf("Commit Failed!\n");
                }
                
                sqlite3_reset(bulkStmt);

            }
        }
        txnstmt = @"END TRANSACTION";
        exec_value = synchronized_sqlite3_exec(appDelegate.db, [txnstmt UTF8String], NULL, NULL, &err);
    }
    
    [self insertSourceToTargetInToSFProcessComponent];
    
    
    result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFObjectMappingComponent ('local_id' INTEGER PRIMARY KEY  NOT NULL ,'object_mapping_id' VARCHAR,'source_field_name' VARCHAR,'target_field_name' VARCHAR,'mapping_value' VARCHAR,'mapping_component_type' VARCHAR,'mapping_value_flag' BOOL)"]];
    
    if (result == YES)
    {
        NSArray * sfObject_com = [processDictionary objectForKey:MSFObject_mapping_component];
        
        NSString * flag = @"true";
        NSString * value = @"";
        id_value = 0;

        char * err;
        
        NSString * txnstmt = @"BEGIN TRANSACTION";
        
        int exec_value = synchronized_sqlite3_exec(appDelegate.db, [txnstmt UTF8String], NULL, NULL, &err);
        
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@', '%@') VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7)", SFOBJECTMAPCOMPONENT, MOBJECT_MAPPING_ID , MSOURCE_FIELD_NAME, MTARGET_FIELD_NAME, MMAPPING_VALUE, MMAPPING_COMP_TYPE, MMAPPING_VALUE_FLAG, MLOCAL_ID];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);

        
        if (ret_value == SQLITE_OK)
        {
        
            for (int i = 0; i < [sfObject_com count]; i++)
            {
                NSDictionary * dict = [sfObject_com objectAtIndex:i];
                
                NSString * target_field_name = ([dict objectForKey:@"target_field_name"] != nil)?[dict objectForKey:@"target_field_name"]:@"";
                NSString * mappingValue = ([dict objectForKey:@"mapping_value"] != nil)?[dict objectForKey:@"mapping_value"]:@"";
                
                if ([target_field_name isEqualToString:@""])
                {
                    value = MVALUEMAPPING;
                }
                if ((![target_field_name isEqualToString:@""]) && (![mappingValue isEqualToString:@""]))
                {
                    value = MVALUEMAPPING;
                }
                else
                {
                    value = MFIELDMAPPING;
                }
                
                
                sqlite3_bind_text(bulkStmt, 1, [([dict objectForKey:MOBJECT_MAPPING_ID] != nil)?[dict objectForKey:MOBJECT_MAPPING_ID]:@"" UTF8String], [([dict objectForKey:MOBJECT_MAPPING_ID] != nil)?[dict objectForKey:MOBJECT_MAPPING_ID]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 2, [([dict objectForKey:MSOURCE_FIELD_NAME] != nil)?[dict objectForKey:MSOURCE_FIELD_NAME]:@"" UTF8String], [([dict objectForKey:MSOURCE_FIELD_NAME] != nil)?[dict objectForKey:MSOURCE_FIELD_NAME]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 3, [([dict objectForKey:MTARGET_FIELD_NAME] != nil)?[dict objectForKey:MTARGET_FIELD_NAME]:@"" UTF8String], [([dict objectForKey:MTARGET_FIELD_NAME] != nil)?[dict objectForKey:MTARGET_FIELD_NAME]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 4, [([dict objectForKey:MMAPPING_VALUE] != nil)?[dict objectForKey:MMAPPING_VALUE]:@"" UTF8String], [([dict objectForKey:MMAPPING_VALUE] != nil)?[dict objectForKey:MMAPPING_VALUE]:@""  length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 5, [value UTF8String], [value length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 6, [flag UTF8String], [flag length], SQLITE_TRANSIENT);
                
                sqlite3_bind_int(bulkStmt, 7, ++id_value);
                
                if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                {
                    printf("Commit Failed!\n");
                }
                
                sqlite3_reset(bulkStmt);
                
            }
        }
        txnstmt = @"END TRANSACTION";
        exec_value = synchronized_sqlite3_exec(appDelegate.db, [txnstmt UTF8String], NULL, NULL, &err);
    }
    
    [self insertValuesInToLookUpTable:processDictionary];
}


- (void) insertValuesInToLookUpTable:(NSMutableDictionary *)processDictionary
{
    int id_value = 0;
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFNamedSearch ('local_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE , 'default_lookup_column' VARCHAR, 'search_name' VARCHAR, 'object_name' VARCHAR, 'search_type' VARCHAR, 'named_search_id' VARCHAR, 'no_of_lookup_records' VARCHAR, 'is_default' VARCHAR, 'is_standard' VARCHAR)"]];
    if (result == YES)
    {
        NSArray * sfNamedSearch = [processDictionary objectForKey:MSFNAMEDSEARCH];
        
        char *err;
        
        NSString * txnstmt = @"BEGIN TRANSACTION";
        
        int exec_value = synchronized_sqlite3_exec(appDelegate.db, [txnstmt UTF8String], NULL, NULL, &err);
        
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@' ) VALUES (?1, ?2, ?3, ?4, ?5, ?6,?7, ?8, ?9)", SFNAMEDSEARCH, MDEFAULT_LOOKUP_COLUMN, MOBJECT_NAME, MSEARCH_NAME, MSEARCH_TYPE, MNAMED_SEARCHID, MNO_OF_LOOKUP_RECORDS, MIS_DEFAULT, MIS_STANDARD, MLOCAL_ID];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);

        if (ret_value == SQLITE_OK)
        {
            for (int i = 0; i < [sfNamedSearch count]; i++)
            {
                NSDictionary * nameSearchDict = [sfNamedSearch objectAtIndex:i];
                
                sqlite3_bind_text(bulkStmt, 1, [([nameSearchDict objectForKey:MDEFAULT_LOOKUP_COLUMN] != nil)?[nameSearchDict objectForKey:MDEFAULT_LOOKUP_COLUMN]:@"" UTF8String], [([nameSearchDict objectForKey:MDEFAULT_LOOKUP_COLUMN] != nil)?[nameSearchDict objectForKey:MDEFAULT_LOOKUP_COLUMN]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 2, [([nameSearchDict objectForKey:MOBJECT_NAME] != nil)?[nameSearchDict objectForKey:MOBJECT_NAME]:@"" UTF8String], [([nameSearchDict objectForKey:MOBJECT_NAME] != nil)?[nameSearchDict objectForKey:MOBJECT_NAME]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 3, [([nameSearchDict objectForKey:MSEARCH_NAME] != nil)?[nameSearchDict objectForKey:MSEARCH_NAME]:@"" UTF8String], [([nameSearchDict objectForKey:MSEARCH_NAME] != nil)?[nameSearchDict objectForKey:MSEARCH_NAME]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 4, [([nameSearchDict objectForKey:MSEARCH_TYPE] != nil)?[nameSearchDict objectForKey:MSEARCH_TYPE]:@"" UTF8String], [([nameSearchDict objectForKey:MSEARCH_TYPE] != nil)?[nameSearchDict objectForKey:MSEARCH_TYPE]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 5, [([nameSearchDict objectForKey:MNAMED_SEARCHID] != nil)?[nameSearchDict objectForKey:MNAMED_SEARCHID]:@"" UTF8String], [([nameSearchDict objectForKey:MNAMED_SEARCHID] != nil)?[nameSearchDict objectForKey:MNAMED_SEARCHID]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 6, [([nameSearchDict objectForKey:MNO_OF_LOOKUP_RECORDS] != nil)?[nameSearchDict objectForKey:MNO_OF_LOOKUP_RECORDS]:@"" UTF8String], [([nameSearchDict objectForKey:MNO_OF_LOOKUP_RECORDS] != nil)?[nameSearchDict objectForKey:MNO_OF_LOOKUP_RECORDS]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 7, [([nameSearchDict objectForKey:MIS_DEFAULT] != nil)?[nameSearchDict objectForKey:MIS_DEFAULT]:@"" UTF8String], [([nameSearchDict objectForKey:MIS_DEFAULT] != nil)?[nameSearchDict objectForKey:MIS_DEFAULT]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 8, [([nameSearchDict objectForKey:MIS_STANDARD] != nil)?[nameSearchDict objectForKey:MIS_STANDARD]:@"" UTF8String], [([nameSearchDict objectForKey:MIS_STANDARD] != nil)?[nameSearchDict objectForKey:MIS_STANDARD]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_int(bulkStmt, 10, ++id_value);
                
                if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                {
                    printf("Commit Failed!\n");
                }
                
                sqlite3_reset(bulkStmt);
                            
            }
        }
        txnstmt = @"END TRANSACTION";
        exec_value = synchronized_sqlite3_exec(appDelegate.db, [txnstmt UTF8String], NULL, NULL, &err);
    }
    
    result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFNamedSearchComponent ('local_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE , 'expression_type' VARCHAR, 'field_name' VARCHAR, 'named_search' VARCHAR, 'search_object_field_type' VARCHAR,  'field_type' VARCHAR, 'field_relationship_name' VARCHAR, 'sequence' VARCHAR)"]];
              
    id_value = 0;
    if (result == YES)
    {
        NSArray * sfNameSearchComp = [processDictionary objectForKey:MSFNAMEDSEARCH_COMPONENT];
        
        char * err;
        
        NSString * txnstmt = @"BEGIN TRANSACTION";
        
        int exec_value = synchronized_sqlite3_exec(appDelegate.db, [txnstmt UTF8String], NULL, NULL, &err);
        
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@' ) VALUES (?1, ?2, ?3, ?4, ?5, ?6,?7, ?8)", SFNAMEDSEACHCOMPONENT, MEXPRESSION_TYPE, MFIELD_NAME, MNAMED_SEARCH, MSEARCH_OBJECT_FIELD, MFIELD_TYPE, MFIELD_RELATIONSHIPNAME, MSEQUENCE, MLOCAL_ID];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);
        
        if (ret_value == SQLITE_OK)
        {
            for (int i = 0; i < [sfNameSearchComp count]; i++)
            {
                NSDictionary * nameSearchComp = [sfNameSearchComp objectAtIndex:i];
                
                NSString * relationshipName = ([nameSearchComp objectForKey:MFIELD_RELATIONSHIPNAME] != nil)?[nameSearchComp objectForKey:MFIELD_RELATIONSHIPNAME]:@"";
                if (![relationshipName isEqualToString:@""])
                    relationshipName = [relationshipName stringByReplacingOccurrencesOfString:@"__r" withString:@"__c"];
                
                sqlite3_bind_text(bulkStmt, 1, [([nameSearchComp objectForKey:MEXPRESSION_TYPE] != nil)?[nameSearchComp objectForKey:MEXPRESSION_TYPE]:@"" UTF8String], [([nameSearchComp objectForKey:MEXPRESSION_TYPE] != nil)?[nameSearchComp objectForKey:MEXPRESSION_TYPE]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 2, [([nameSearchComp objectForKey:MFIELD_NAME] != nil)?[nameSearchComp objectForKey:MFIELD_NAME]:@"" UTF8String], [([nameSearchComp objectForKey:MFIELD_NAME] != nil)?[nameSearchComp objectForKey:MFIELD_NAME]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 3, [([nameSearchComp objectForKey:MNAMED_SEARCH] != nil)?[nameSearchComp objectForKey:MNAMED_SEARCH]:@"" UTF8String], [([nameSearchComp objectForKey:MNAMED_SEARCH] != nil)?[nameSearchComp objectForKey:MNAMED_SEARCH]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 4, [([nameSearchComp objectForKey:MSEARCH_OBJECT_FIELD] != nil)?[nameSearchComp objectForKey:MSEARCH_OBJECT_FIELD]:@"" UTF8String], [([nameSearchComp objectForKey:MSEARCH_OBJECT_FIELD] != nil)?[nameSearchComp objectForKey:MSEARCH_OBJECT_FIELD]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 5, [([nameSearchComp objectForKey:MFIELD_TYPE] != nil)?[nameSearchComp objectForKey:MFIELD_TYPE]:@"" UTF8String], [([nameSearchComp objectForKey:MFIELD_TYPE] != nil)?[nameSearchComp objectForKey:MFIELD_TYPE]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 6, [relationshipName UTF8String], [relationshipName length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 7, [([nameSearchComp objectForKey:MSEQUENCE] != nil)?[nameSearchComp objectForKey:MSEQUENCE]:@"" UTF8String], [([nameSearchComp objectForKey:MSEQUENCE] != nil)?[nameSearchComp objectForKey:MSEQUENCE]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_int(bulkStmt, 8, ++id_value);
                
                if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                {
                    printf("Commit Failed!\n");
                }
                
                sqlite3_reset(bulkStmt);
            }
        }
        txnstmt = @"END TRANSACTION";
        exec_value = synchronized_sqlite3_exec(appDelegate.db, [txnstmt UTF8String], NULL, NULL, &err);
    }
    appDelegate.wsInterface.didGetPageDataDb = TRUE;
}


- (void) insertValuesInToTagsTable:(NSMutableDictionary *)tagsDictionary
{
    
    if (appDelegate.isForeGround == TRUE || !appDelegate.isInternetConnectionAvailable)
    {
        if(appDelegate.IsLogedIn == ISLOGEDIN_TRUE)
        {
            appDelegate.initial_sync_succes_or_failed = META_SYNC_FAILED;
            return;
        }
    }
    NSLog(@"SAMMAN MetaSync insertValuesInToTagsTable starts: %@", [NSDate date]);
    int id_value = 0;
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS MobileDeviceTags ('local_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE , 'tag_id' VARCHAR, 'value' VARCHAR)"]];
    if (result == YES)
    {
    
        NSArray * keys = [tagsDictionary allKeys];
        NSArray * values = [tagsDictionary allValues];
        
        
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@' ) VALUES (?1, ?2, ?3)", MOBILEDEVICETAGS, MTAG_ID, MVALUEM, MLOCAL_ID];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);

        if (ret_value == SQLITE_OK)
        {
            for (int i = 0; i < [keys count]; i++)
            {
                NSString * value = ([values objectAtIndex:i] != nil)?[values objectAtIndex:i]:@"";
                value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            
                
                sqlite3_bind_text(bulkStmt, 1, [[keys objectAtIndex:i] UTF8String], [[keys objectAtIndex:i] length],  SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 2, [value UTF8String], [value length], SQLITE_TRANSIENT);
                
                sqlite3_bind_int(bulkStmt, 3, ++id_value);
                
                if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                {
                    printf("Commit Failed!\n");
                }
                
                sqlite3_reset(bulkStmt);                
            }
        }
    }
    NSLog(@"SAMMAN MetaSync insertValuesInToTagsTable ends: %@", [NSDate date]);
    appDelegate.initial_sync_status =  SYNC_MOBILE_DEVICE_SETTINGS;
    appDelegate.Sync_check_in = FALSE;
    [appDelegate.wsInterface metaSyncWithEventName:MOBILE_DEVICE_SETTINGS eventType:SYNC values:nil];
}

- (void) insertValuesInToSettingsTable:(NSMutableDictionary *)settingsDictionary
{
    NSString * meta_sync = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_meta_data_configuration];

    if (appDelegate.isForeGround == TRUE || !appDelegate.isInternetConnectionAvailable)
    {
        if (appDelegate.isIncrementalMetaSyncInProgress &&!appDelegate.isInternetConnectionAvailable)
        {
            //appDelegate.SyncStatus = SYNC_RED;
            
            [appDelegate setSyncStatus:SYNC_RED];
            //[appDelegate.wsInterface.refreshSyncButton showSyncStatusButton];
            //[appDelegate.wsInterface.refreshModalStatusButton showModalSyncStatus];
            //[appDelegate.wsInterface.refreshSyncStatusUIButton showSyncUIStatus];
           
            [appDelegate.calDataBase insertIntoConflictInternetErrorForMetaSync:meta_sync WithDB:tempDb];
            
            appDelegate.internet_Conflicts = [appDelegate.calDataBase getInternetConflictsForMetaSyncWithDB:appDelegate.dataBase.tempDb];
			[appDelegate.reloadTable ReloadSyncTable];

            if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
                [MyPopoverDelegate performSelector:@selector(throwException)];
            return;
        }

        if(appDelegate.IsLogedIn == ISLOGEDIN_TRUE)
        {
            appDelegate.initial_sync_succes_or_failed = META_SYNC_FAILED;
            return;
        }
    }
    NSLog(@"SAMMAN MetaSync insertValuesInToSettingsTable processing starts: %@", [NSDate date]);
    int id_value = 0;
    
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS MobileDeviceSettings ('local_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE , 'setting_id' VARCHAR, 'value' VARCHAR)"]];
                                     
    if (result == YES)
    {
    
        NSArray * keys = [settingsDictionary allKeys];
        NSArray * values = [settingsDictionary allValues];
        
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@' ) VALUES (?1, ?2, ?3)", MOBILEDEVICESETTINGS, MSETTING_ID, MVALUEM, MLOCAL_ID];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);
        
        if (ret_value == SQLITE_OK)
        {
            for (int i = 0; i < [keys count]; i++)
            {
                sqlite3_bind_text(bulkStmt, 1, [[keys objectAtIndex:i] UTF8String], [[keys objectAtIndex:i] length],  SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 2, [[values objectAtIndex:i] UTF8String], [[values objectAtIndex:i] length], 
                                    SQLITE_TRANSIENT);
                sqlite3_bind_int(bulkStmt, 3, ++id_value);
                
                if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                {
                    printf("Commit Failed!\n");
                }
                
                sqlite3_reset(bulkStmt);   
            }
        }
    }
    
    NSLog(@"SAMMAN MetaSync insertValuesInToSettingsTable processing ends: %@", [NSDate date]);
    //Radha - 24/March
    appDelegate.settingsDict = [self getSettingsDictionary];

    
    [self generatePDFSettings];
}

- (void) insertValuesInToSFWizardsTable:(NSDictionary *)wizardDict
{
    NSLog(@"SAMMAN MetaSync insertValuesInToSFWizardsTable: processing starts: %@", [NSDate date]);
    int id_value = 0;
    
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFWizard ('local_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , 'object_name' VARCHAR, 'wizard_id' VARCHAR, 'expression_id' VARCHAR, 'wizard_description' VARCHAR, 'wizard_name' VARCHAR)"]];

    if (result == YES)
    {
        NSArray * sfWizard = [wizardDict objectForKey:MSFW_wizard];
        
        NSString * _objectName = @"";
        
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@' ) VALUES (?1, ?2, ?3, ?4, ?5, ?6)", SFWIZARD, MOBJECT_NAME, MWIZARD_ID, MEXPRESSION_ID, MWIZARD_DESCRIPTION,MWIZARD_NAME, MLOCAL_ID];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);
        
        if (ret_value == SQLITE_OK)
        {
        
            for (int i = 0; i < [sfWizard count]; i++)
            {
                NSDictionary * dict = [sfWizard objectAtIndex:i];
                
                _objectName = ([dict objectForKey:MOBJECT_NAME] != nil)?[dict objectForKey:MOBJECT_NAME]:@"";
               
                sqlite3_bind_text(bulkStmt, 1, [_objectName UTF8String], [_objectName length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 2, [([dict objectForKey:MWIZARD_ID] != nil)?[dict objectForKey:MWIZARD_ID]:@"" UTF8String], [([dict objectForKey:MWIZARD_ID] != nil)?[dict objectForKey:MWIZARD_ID]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 3, [([dict objectForKey:MEXPRESSION_ID] != nil)?[dict objectForKey:MEXPRESSION_ID]:@"" UTF8String], [([dict objectForKey:MEXPRESSION_ID] != nil)?[dict objectForKey:MEXPRESSION_ID]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 4, [([dict objectForKey:MWIZARD_DESCRIPTION] != nil)?[dict objectForKey:MWIZARD_DESCRIPTION]:@"" UTF8String], [([dict objectForKey:MWIZARD_DESCRIPTION] != nil)?[dict objectForKey:MWIZARD_DESCRIPTION]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 5, [([dict objectForKey:MWIZARD_NAME] != nil)?[dict objectForKey:MWIZARD_NAME]:@"" UTF8String], [([dict objectForKey:MWIZARD_NAME] != nil)?[dict objectForKey:MWIZARD_NAME]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_int(bulkStmt, 6, ++id_value);
                
                if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                {
                    printf("Commit Failed!\n");
                }
                
                sqlite3_reset(bulkStmt);
            }
        }
    }
    
    result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFWizardComponent ('local_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , 'wizard_id' VARCHAR, 'action_id' VARCHAR, 'action_description' VARCHAR, 'expression_id' VARCHAR, 'process_id' VARCHAR, 'action_type' VARCHAR)"]];
    if (result == YES)
    {
        NSArray * sfWizComponent = [wizardDict objectForKey:MSFW_wizard_steps];
        NSArray * sfProcess = [appDelegate.wsInterface.processDictionary objectForKey:@"SFMProcess"];
        
        id_value = 0;
        NSString * wProcessId = @"";
        
        NSString * emptyString = @"";
        
        
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@', '%@') VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7)", SFWIZARDCOMPONENT, MWIZARD_ID, MACTION_ID, MACTION_DESCRIPTION, MEXPRESSION_ID, MPROCESS_ID, MACTION_TYPE, MLOCAL_ID];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);
        
        if (ret_value == SQLITE_OK)
        {
            for (int i = 0; i < [sfWizComponent count]; i++)
            {
                wProcessId = @"";
                
                NSDictionary * comp_dict = [sfWizComponent objectAtIndex:i];
                              
                NSString * wizard_processId = ([comp_dict objectForKey:MPROCESS_ID] != nil)?[comp_dict objectForKey:MPROCESS_ID]:@"";
                
                NSLog(@"%@", wizard_processId);
                
                if ([wizard_processId length] > 0)
                {
                    for (int j = 0; j < [sfProcess count]; j++)
                    {
                        NSDictionary * dict  = [sfProcess objectAtIndex:j];
                        
                        NSString * process_id = ([dict objectForKey:MPROCESS_ID] != nil)?[dict objectForKey:MPROCESS_ID]:@"";
                        
                        if ([wizard_processId isEqualToString:process_id])
                        {
                            wProcessId = ([dict objectForKey:MPROCESS_UNIQUE_ID] != nil)?[dict objectForKey:MPROCESS_UNIQUE_ID]:@"";
                            break;
                        }
                    }
                }
                              
                sqlite3_bind_text(bulkStmt, 1, [([comp_dict objectForKey:MWIZARD_ID] != nil)?[comp_dict objectForKey:MWIZARD_ID]:@"" UTF8String], [([comp_dict objectForKey:MWIZARD_ID] != nil)?[comp_dict objectForKey:MWIZARD_ID]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 2, [emptyString UTF8String], [emptyString length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 3, [([comp_dict objectForKey:MWIZARD_STEP_NAME]!= nil)?[comp_dict objectForKey:MWIZARD_STEP_NAME]:@"" UTF8String], [([comp_dict objectForKey:MWIZARD_STEP_NAME]!= nil)?[comp_dict objectForKey:MWIZARD_STEP_NAME]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 4, [([comp_dict objectForKey:MEXPRESSION_ID] != nil)?[comp_dict objectForKey:MEXPRESSION_ID]:@"" UTF8String], [([comp_dict objectForKey:MEXPRESSION_ID] != nil)?[comp_dict objectForKey:MEXPRESSION_ID]:@"" length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 5, [wProcessId UTF8String], [wProcessId length], SQLITE_TRANSIENT);
                
                sqlite3_bind_text(bulkStmt, 6, [SFM UTF8String], [SFM length], SQLITE_TRANSIENT);
                
                sqlite3_bind_int(bulkStmt, 7, ++id_value);
                
                if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                {
                    printf("Commit Failed!\n");
                }
                
                sqlite3_reset(bulkStmt);
                            
            }
        }
    }
    
    
    NSString * query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM '%@'", MSFExpression];
    int count = 0;
    sqlite3_stmt * statement;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, nil) == SQLITE_OK  )
    {
        if(synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            count = synchronized_sqlite3_column_int(statement, 0);
        }
    }
    id_value = count;
    synchronized_sqlite3_finalize(statement);
    NSArray * sfExpression = [wizardDict objectForKey:MSFExpression];
    
    
    NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@') VALUES (?1, ?2, ?3,   ?4)", SFEXPRESSION, MEXPRESSION_ID , MEXPRESSION_NAME, MEXPRESSION, MLOCAL_ID];
    
    sqlite3_stmt * bulkStmt;
    
    int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);
    
    if (ret_value == SQLITE_OK)
    {
        for (int i = 0; i < [sfExpression count]; i++)
        {
            NSDictionary * dict = [sfExpression objectAtIndex:i];
            
            sqlite3_bind_text(bulkStmt, 1, [([dict objectForKey:MEXPRESSION_ID] != nil)?[dict objectForKey:MEXPRESSION_ID]:@"" UTF8String], [([dict objectForKey:MEXPRESSION_ID] != nil)?[dict objectForKey:MEXPRESSION_ID]:@"" length], SQLITE_TRANSIENT);
            
            sqlite3_bind_text(bulkStmt, 2, [([dict objectForKey:MEXPRESSION_NAME] != nil)?[dict objectForKey:MEXPRESSION_NAME]:@"" UTF8String], [([dict objectForKey:MEXPRESSION_NAME] != nil)?[dict objectForKey:MEXPRESSION_NAME]:@"" length], SQLITE_TRANSIENT);
            
            sqlite3_bind_text(bulkStmt, 3, [([dict objectForKey:MADVANCE_EXPRESSION] != nil)?[dict objectForKey:MADVANCE_EXPRESSION]:@"" UTF8String], [([dict objectForKey:MADVANCE_EXPRESSION] != nil)?[dict objectForKey:MADVANCE_EXPRESSION]:@"" length], SQLITE_TRANSIENT);
            
            sqlite3_bind_int(bulkStmt, 4, ++id_value);
            
            if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
            {
                printf("Commit Failed!\n");
            }
            
            sqlite3_reset(bulkStmt);            
        }
    }

    query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM '%@'", SFEXPRESSION_COMPONENT];
    int count1 = 0;
    sqlite3_stmt * stmt;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
    {
        if(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            count1 = synchronized_sqlite3_column_int(stmt, 0);
        }
    }
    id_value = count1;
    synchronized_sqlite3_finalize(stmt);
    
    NSArray * sfExpression_com = [wizardDict objectForKey:MSFExpression_component];
    bulkQueryStmt = @"";
    
    bulkStmt=  nil;
    
    bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@') VALUES (?1, ?2, ?3,  ?4, ?5, ?6)", SFEXPRESSIONCOMPONENT, MEXPRESSION_ID, MCOMPONENT_SEQ_NUM, MCOMPONENT_LHS, MCOMPONENT_RHS, MOPERATOR, MLOCAL_ID];
    
    
    ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);
    
    if (ret_value == SQLITE_OK)
    {
        for (int i = 0; i < [sfExpression_com count]; i++)
        {
            NSDictionary * dict = [sfExpression_com objectAtIndex:i];
        
            sqlite3_bind_text(bulkStmt, 1, [([dict objectForKey:MEXPRESSION_ID] != nil)?[dict objectForKey:MEXPRESSION_ID]:@"" UTF8String], [([dict objectForKey:MEXPRESSION_ID] != nil)?[dict objectForKey:MEXPRESSION_ID]:@"" length], SQLITE_TRANSIENT);
            
            sqlite3_bind_text(bulkStmt, 2, [([dict objectForKey:MSEQUENCE] != nil)?[dict objectForKey:MSEQUENCE]:@"" UTF8String], [([dict objectForKey:MSEQUENCE] != nil)?[dict objectForKey:MSEQUENCE]:@"" length], SQLITE_TRANSIENT);
            
            sqlite3_bind_text(bulkStmt, 3, [([dict objectForKey:MSOURCE_FIELD_NAME] != nil)?[dict objectForKey:MSOURCE_FIELD_NAME]:@"" UTF8String], [([dict objectForKey:MSOURCE_FIELD_NAME] != nil)?[dict objectForKey:MSOURCE_FIELD_NAME]:@"" length], SQLITE_TRANSIENT);
            
            sqlite3_bind_text(bulkStmt, 4, [([dict objectForKey:MVALUEM] != nil)?[dict objectForKey:MVALUEM]:@"" UTF8String], [([dict objectForKey:MVALUEM] != nil)?[dict objectForKey:MVALUEM]:@"" length], SQLITE_TRANSIENT);
            
            sqlite3_bind_text(bulkStmt, 5, [([dict objectForKey:MOPERATOR] != nil)?[dict objectForKey:MOPERATOR]:@"" UTF8String], [([dict objectForKey:MOPERATOR] != nil)?[dict objectForKey:MOPERATOR]:@"" length], SQLITE_TRANSIENT);
            
            sqlite3_bind_int(bulkStmt, 6, ++id_value);
            
            if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
            {
                printf("Commit Failed!\n");
            }
            
            sqlite3_reset(bulkStmt);
        }
    }   
    NSLog(@"SAMMAN MetaSync insertValuesInToSFWizardsTable: processing ends: %@", [NSDate date]);
    
    appDelegate.initial_sync_status = SYNC_MOBILE_DEVICE_TAGS;
    appDelegate.Sync_check_in = FALSE;
    [appDelegate.wsInterface metaSyncWithEventName:MOBILE_DEVICE_TAGS eventType:SYNC values:nil];
}

#pragma mark - getTags
- (NSMutableDictionary *) getTagsDictionary
{
    sqlite3_stmt * statement;
    NSString * queryStatement = [NSString stringWithFormat:@"SELECT * FROM %@", MOBILEDEVICETAGS];
    
    NSMutableDictionary * tagDict = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW) 
        {
            NSString * key = @"";
            NSString * value = @"";
            char * _key = (char *) synchronized_sqlite3_column_text(statement, 1);
           
            if((_key !=nil) && strlen(_key))
            {
                key = [NSString stringWithUTF8String:_key];
            }
            
            char * _value = (char *) synchronized_sqlite3_column_text(statement, 2);
            if ((_value != nil) && strlen(_value))
            {
               value = [NSString stringWithUTF8String:_value];
            }
            
            if (![key isEqualToString:@""])
                [tagDict setValue:value forKey:key];
        }
    }
    return tagDict;
}
#pragma End



- (NSMutableDictionary *) getSettingsDictionary
{
    sqlite3_stmt * statement;
    NSString * queryStatement = [NSString stringWithFormat:@"SELECT * FROM %@", MOBILEDEVICESETTINGS];
    
    NSMutableDictionary * SeetingsDict = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW) 
        {
            NSString * key = @"";
            NSString * value = @"";
            char * _key = (char *) synchronized_sqlite3_column_text(statement, 1);
            
            if((_key !=nil) && strlen(_key))
            {
                key = [NSString stringWithUTF8String:_key];
            }
            
            char * _value = (char *) synchronized_sqlite3_column_text(statement, 2);
            if ((_value != nil) && strlen(_value))
            {
                value = [NSString stringWithUTF8String:_value];
            }
            
            if (![key isEqualToString:@""])
                [SeetingsDict setValue:value forKey:key];
        }
    }
    return SeetingsDict;
}

//Temperory Method - Removed After Data Sync is completed.
- (void) insertUsernameToUserTable:(NSString *)UserName
{
    NSString * queryStatement = [NSString stringWithFormat:@"SELECT Username FROM User"];
    sqlite3_stmt * stmt;
    
    BOOL flag = FALSE;
    
    NSString * name = @"";
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(stmt) == SQLITE_ROW) 
        {
            char * _name = (char *) synchronized_sqlite3_column_text(stmt, 0);
            if ((_name != nil) && strlen(_name))
                name = [NSString stringWithUTF8String:_name];
            
            if ([name isEqualToString:UserName])
            {
                flag = TRUE;
                break;
            }
        }
    }
    
    synchronized_sqlite3_finalize(stmt);
    
    if (!flag)
    {
        NSString * local_id = [iServiceAppDelegate GetUUID];
        
        queryStatement = [NSString stringWithFormat:@"INSERT INTO User (local_id, 'Username') VALUES ('%@', '%@')", local_id, UserName];
        
        char * err;
        if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
            if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
                [MyPopoverDelegate performSelector:@selector(throwException)];
            NSLog(@"Failed to insert");
        }
    }
}


#pragma mark - Delete All Tables
- (void) clearDatabase
{
    sqlite3_stmt *stmt;
    NSMutableArray * tables = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    NSString * queryStatemnt = [NSString stringWithFormat:@"SELECT * FROM sqlite_master WHERE type = 'table'"];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatemnt UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(stmt) == SQLITE_ROW) 
        {
            char * _table = (char *) synchronized_sqlite3_column_text(stmt, 1);
            
            if ((_table != nil) && strlen(_table))
            {
                NSString * table_name = [NSString stringWithUTF8String:_table];
                if ((![table_name isEqualToString:@"sqlite_sequence"]))
                    [tables addObject:table_name];
            }
            
        }
    }
    
    synchronized_sqlite3_finalize(stmt);
    
    
    char * err;
    
    for (int i = 0; i < [tables count]; i++)
        {
            queryStatemnt = [NSString stringWithFormat:@"DROP TABLE '%@'", [tables objectAtIndex:i]];
            if (synchronized_sqlite3_exec(appDelegate.db, [queryStatemnt UTF8String], NULL, NULL, &err) != SQLITE_OK)
            {
                if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
                    [MyPopoverDelegate performSelector:@selector(throwException)];
                NSLog(@"Failed to drop");
              
            }
                
        }    
}

#pragma mark - ADD Source to target
-(void) insertSourceToTargetInToSFProcessComponent
{
    NSMutableArray * process_info = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    for (int i = 0; i < [processIdList count]; i++)
    {        
        NSString * queryStatement = [NSString stringWithFormat:@"SELECT process_type FROM SFProcess WHERE process_id = '%@'", [processIdList objectAtIndex:i]];
        sqlite3_stmt * statement;
        NSString * processType = @"";
        if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            if (synchronized_sqlite3_step(statement) == SQLITE_ROW)
            {
                const char * _type = (char *)synchronized_sqlite3_column_text(statement, 0);
                if (strlen(_type))
                    processType = [NSString stringWithUTF8String:_type];
            }
        }
        synchronized_sqlite3_finalize(statement);
        NSArray * keys = [NSArray arrayWithObjects:MPROCESS_ID, MLAYOUT_ID, TARGET_OBJECT_NAME, SOURCE_OBJECT_NAME, EXPRESSION_ID, OBJECT_MAPPING_ID, MCOMPONENT_TYPE, MPARENT_COLUMN, MVALUE_MAPPING_ID, @"source_child_parent_column", nil];
        NSString * processId = @"", * layoutId = @"", * sourceName = @"", * expressionId = @"", * oMappingId = @"",* componentType = @"", * parentColumn = @"", * targetName = @"", * vMappingid = @"", * source_child_column = @"";
        NSArray * objects;
        
        NSString * query = @"";
        if ([processType isEqualToString:SOURCETOTARGET])
        {
             query = [NSString stringWithFormat:@"SELECT * FROM SFprocess_test WHERE process_id = '%@'  AND (component_type = 'TARGET' or component_type =  'SOURCE')", [processIdList objectAtIndex:i]];
            sqlite3_stmt * stmt;
            
            NSMutableArray * mappingArray = [[NSMutableArray alloc] initWithCapacity:0];
            
            if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
            {
                 while (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
                 {
                     char * _processId = (char *) synchronized_sqlite3_column_text(stmt, COLUMNPROCESS_ID);
                     if ((_processId != nil) && strlen(_processId))
                         processId = [NSString stringWithUTF8String:_processId];
                     
                     char * _layoutId = (char *) synchronized_sqlite3_column_text(stmt, COLUMNLAYOUT_ID);
                     if ((_layoutId != nil) && strlen(_layoutId))
                         layoutId = [NSString stringWithUTF8String:_layoutId];
                     
                     char * _objectName = (char *) synchronized_sqlite3_column_text(stmt, COLUMNOBJECT_NAME);
                     if ((_objectName != nil) && strlen(_objectName))
                         sourceName = [NSString stringWithUTF8String:_objectName];
                     
                     char * _expressionId = (char *) synchronized_sqlite3_column_text(stmt, COLUMNEXPRESSION_ID);
                     if ((_expressionId != nil) && strlen(_expressionId))
                         expressionId = [NSString stringWithUTF8String:_expressionId];
                     
                     char * _mappingId = (char *) synchronized_sqlite3_column_text(stmt, COLUMNMAPPING_ID);
                     if ((_mappingId != nil) && strlen(_mappingId))
                         oMappingId = [NSString stringWithUTF8String:_mappingId];
                     
                     char * _componentType = (char *) synchronized_sqlite3_column_text(stmt, COLUMNCOMP_TYPE);
                     if ((_componentType != nil) && strlen(_componentType))
                         componentType = [NSString stringWithUTF8String:_componentType];
                     
                     char * _parentColumn = (char *) synchronized_sqlite3_column_text(stmt, COLUMNPARENT_COLUMN);
                     if ((_parentColumn != nil) && strlen(_parentColumn))
                         parentColumn = [NSString stringWithUTF8String:_parentColumn];
                     
                     char * _value_id = (char *) synchronized_sqlite3_column_text(stmt, COLUNMVALUEMAP);
                     if ((_value_id != nil) && strlen(_value_id))
                         vMappingid = [NSString stringWithUTF8String:_value_id];
                     
                     objects = [NSArray arrayWithObjects:processId, layoutId, targetName, sourceName, expressionId, oMappingId, componentType, parentColumn, vMappingid, @"", nil];
                     
                     NSDictionary * dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
                     [mappingArray addObject:dict];
                     processId = @"", layoutId = @"", sourceName = @"", expressionId = @"", oMappingId = @"",componentType = @"",  parentColumn = @"", targetName = @"", vMappingid = @"", source_child_column = @"";
                }
                NSDictionary * source_dict = [mappingArray objectAtIndex:0];
                NSDictionary * target_dict = [mappingArray objectAtIndex:1];
                if ([[[mappingArray objectAtIndex:0]objectForKey:@"component_type"] isEqualToString:@"SOURCE"])
                {
                    source_dict = [mappingArray objectAtIndex:0];
                    target_dict = [mappingArray objectAtIndex:1];

                }
                else
                {
                   source_dict = [mappingArray objectAtIndex:1];
                   target_dict = [mappingArray objectAtIndex:0];
                }
                    
                objects = [NSArray arrayWithObjects:
                           ([source_dict objectForKey:MPROCESS_ID]!=@"")?[source_dict objectForKey:MPROCESS_ID]:[target_dict  objectForKey:MPROCESS_ID],
                           ([source_dict objectForKey:MLAYOUT_ID]!=@"")?[source_dict objectForKey:MLAYOUT_ID]:[target_dict  objectForKey:MLAYOUT_ID],
                           ([target_dict  objectForKey:SOURCE_OBJECT_NAME]!=@"")?[target_dict  objectForKey:SOURCE_OBJECT_NAME]:@"",
                           ([source_dict objectForKey:SOURCE_OBJECT_NAME]!=@"")?[source_dict  objectForKey:SOURCE_OBJECT_NAME]:@"",
                           ([source_dict objectForKey:EXPRESSION_ID]!=@"")?[source_dict objectForKey:EXPRESSION_ID]:[target_dict  objectForKey:EXPRESSION_ID],
                           ([source_dict objectForKey:OBJECT_MAPPING_ID]!=@"")?[source_dict objectForKey:OBJECT_MAPPING_ID]:[target_dict  objectForKey:OBJECT_MAPPING_ID],
                           ([target_dict objectForKey:MCOMPONENT_TYPE]!=@"")?[target_dict objectForKey:MCOMPONENT_TYPE]:@"",
                           ([source_dict objectForKey:MPARENT_COLUMN]!=@"")?[source_dict objectForKey:MPARENT_COLUMN]:[target_dict  objectForKey:MPARENT_COLUMN],
                           ([source_dict objectForKey:MVALUE_MAPPING_ID]!=@"")?[source_dict objectForKey:MVALUE_MAPPING_ID]:[target_dict  objectForKey:MVALUE_MAPPING_ID],
                           ([source_dict objectForKey:@"source_child_parent_column"]!=@"")?[source_dict objectForKey:@"source_child_parent_column"]:[target_dict  objectForKey:@"source_child_parent_column"], nil];
                NSDictionary * dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
                
                [process_info addObject:dict];
                
            }
            
            [mappingArray release];
            processId = @"", layoutId = @"", sourceName = @"", expressionId = @"", oMappingId = @"",componentType = @"",  parentColumn = @"", targetName = @"", vMappingid = @"", source_child_column = @"";
            query = @"";
            sqlite3_stmt * childStmt;
            
            query = [NSString stringWithFormat:@"SELECT * FROM SFprocess_test WHERE process_id = '%@' AND (component_type =  'TARGETCHILD')", [processIdList objectAtIndex:i]];
            
            if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &childStmt, NULL) == SQLITE_OK)
            {
                while (synchronized_sqlite3_step(childStmt) == SQLITE_ROW)
                {
                    char * _processId = (char *) synchronized_sqlite3_column_text(childStmt, COLUMNPROCESS_ID);
                    if ((_processId != nil) && strlen(_processId))
                        processId = [NSString stringWithUTF8String:_processId];
                    
                    char * _layoutId = (char *) synchronized_sqlite3_column_text(childStmt, COLUMNLAYOUT_ID);
                    if ((_layoutId != nil) && strlen(_layoutId))
                        layoutId = [NSString stringWithUTF8String:_layoutId];
                    
                    char * _objectName = (char *) synchronized_sqlite3_column_text(childStmt, COLUMNOBJECT_NAME);
                    if ((_objectName != nil) && strlen(_objectName))
                        sourceName = [NSString stringWithUTF8String:_objectName];
                    
                    char * _expressionId = (char *) synchronized_sqlite3_column_text(childStmt, COLUMNEXPRESSION_ID);
                    if ((_expressionId != nil) && strlen(_expressionId))
                        expressionId = [NSString stringWithUTF8String:_expressionId];
                    
                    char * _mappingId = (char *) synchronized_sqlite3_column_text(childStmt, COLUMNMAPPING_ID);
                    if ((_mappingId != nil) && strlen(_mappingId))
                        oMappingId = [NSString stringWithUTF8String:_mappingId];
                    
                    char * _componentType = (char *) synchronized_sqlite3_column_text(childStmt, COLUMNCOMP_TYPE);
                    if ((_componentType != nil) && strlen(_componentType))
                        componentType = [NSString stringWithUTF8String:_componentType];
                    
                    char * _parentColumn = (char *) synchronized_sqlite3_column_text(childStmt, COLUMNPARENT_COLUMN);
                    if ((_parentColumn != nil) && strlen(_parentColumn))
                        parentColumn = [NSString stringWithUTF8String:_parentColumn];
                    
                    char * _value_id = (char *) synchronized_sqlite3_column_text(childStmt, COLUNMVALUEMAP);
                    if ((_value_id != nil) && strlen(_value_id))
                        vMappingid = [NSString stringWithUTF8String:_value_id];
                    
                    NSString * source_objectName =  [self getObjectNameFromSFobjMapping:oMappingId];
                    
                    NSString * source_childName = [self getSourceChildNameFromProcessId:source_objectName processid:[processIdList objectAtIndex:i]];
                    
                    objects = [NSArray arrayWithObjects:processId, layoutId, sourceName, source_objectName, expressionId, oMappingId, componentType, parentColumn, vMappingid, source_childName, nil];
                    
                    NSDictionary * dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
                    
                    [process_info addObject:dict];
                    processId = @"", layoutId = @"", sourceName = @"", expressionId = @"", oMappingId = @"",componentType = @"",  parentColumn = @"", targetName = @"", vMappingid = @"", source_child_column = @"";
                }
                
            }
            synchronized_sqlite3_finalize(stmt);
        }
        else if ([processType isEqualToString:SOURCETOTARGETONLYCHILDROWS])
        {
            query = [NSString stringWithFormat:@"SELECT * FROM SFprocess_test WHERE process_id = '%@'  AND (component_type = 'SOURCE' or component_type =  'TARGET')", [processIdList objectAtIndex:i]];
            sqlite3_stmt * stmt;
            
            NSMutableArray * mappingArray = [[NSMutableArray alloc] initWithCapacity:0];
            
            if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
            {
                while (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
                {
                    char * _processId = (char *) synchronized_sqlite3_column_text(stmt, COLUMNPROCESS_ID);
                    if ((_processId != nil) && strlen(_processId))
                        processId = [NSString stringWithUTF8String:_processId];
                    
                    char * _layoutId = (char *) synchronized_sqlite3_column_text(stmt, COLUMNLAYOUT_ID);
                    if ((_layoutId != nil) && strlen(_layoutId))
                        layoutId = [NSString stringWithUTF8String:_layoutId];
                    
                    char * _objectName = (char *) synchronized_sqlite3_column_text(stmt, COLUMNOBJECT_NAME);
                    if ((_objectName != nil) && strlen(_objectName))
                        sourceName = [NSString stringWithUTF8String:_objectName];
                    
                    char * _expressionId = (char *) synchronized_sqlite3_column_text(stmt, COLUMNEXPRESSION_ID);
                    if ((_expressionId != nil) && strlen(_expressionId))
                        expressionId = [NSString stringWithUTF8String:_expressionId];
                    
                    char * _mappingId = (char *) synchronized_sqlite3_column_text(stmt, COLUMNMAPPING_ID);
                    if ((_mappingId != nil) && strlen(_mappingId))
                        oMappingId = [NSString stringWithUTF8String:_mappingId];
                    
                    char * _componentType = (char *) synchronized_sqlite3_column_text(stmt, COLUMNCOMP_TYPE);
                    if ((_componentType != nil) && strlen(_componentType))
                        componentType = [NSString stringWithUTF8String:_componentType];
                    
                    char * _parentColumn = (char *) synchronized_sqlite3_column_text(stmt, COLUMNPARENT_COLUMN);
                    if ((_parentColumn != nil) && strlen(_parentColumn))
                        parentColumn = [NSString stringWithUTF8String:_parentColumn];
                    
                    char * _value_id = (char *) synchronized_sqlite3_column_text(stmt, COLUNMVALUEMAP);
                    if ((_value_id != nil) && strlen(_value_id))
                        vMappingid = [NSString stringWithUTF8String:_value_id];
                    
                    objects = [NSArray arrayWithObjects:processId, layoutId, targetName, sourceName, expressionId, oMappingId, componentType, parentColumn, vMappingid, @"", nil];
                    
                    NSDictionary * dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
                    [mappingArray addObject:dict];
                    processId = @"", layoutId = @"", sourceName = @"", expressionId = @"", oMappingId = @"",componentType = @"",  parentColumn = @"", targetName = @"", vMappingid = @"", source_child_column = @"";
                }
                
                NSDictionary * source_dict = [mappingArray objectAtIndex:0];
                NSDictionary * target_dict = [mappingArray objectAtIndex:1];
                if ([[[mappingArray objectAtIndex:0]objectForKey:@"component_type"] isEqualToString:@"SOURCE"])
                {
                    source_dict = [mappingArray objectAtIndex:0];
                    target_dict = [mappingArray objectAtIndex:1];
                    
                }
                else
                {
                    source_dict = [mappingArray objectAtIndex:1];
                    target_dict = [mappingArray objectAtIndex:0];
                }

                
                
                
                objects = [NSArray arrayWithObjects:
                           ([source_dict objectForKey:MPROCESS_ID]!=@"")?[source_dict objectForKey:MPROCESS_ID]:[target_dict  objectForKey:MPROCESS_ID],
                           ([source_dict objectForKey:MLAYOUT_ID]!=@"")?[source_dict objectForKey:MLAYOUT_ID]:[target_dict  objectForKey:MLAYOUT_ID],
                           ([target_dict  objectForKey:SOURCE_OBJECT_NAME]!=@"")?[target_dict  objectForKey:SOURCE_OBJECT_NAME]:@"",
                           ([source_dict objectForKey:SOURCE_OBJECT_NAME]!=@"")?[source_dict  objectForKey:SOURCE_OBJECT_NAME]:@"",
                           ([source_dict objectForKey:EXPRESSION_ID]!=@"")?[source_dict objectForKey:EXPRESSION_ID]:[target_dict  objectForKey:EXPRESSION_ID],
                           ([source_dict objectForKey:OBJECT_MAPPING_ID]!=@"")?[source_dict objectForKey:OBJECT_MAPPING_ID]:[target_dict  objectForKey:OBJECT_MAPPING_ID],
                           ([target_dict objectForKey:MCOMPONENT_TYPE]!=@"")?[target_dict objectForKey:MCOMPONENT_TYPE]:@"",
                           ([source_dict objectForKey:MPARENT_COLUMN]!=@"")?[source_dict objectForKey:MPARENT_COLUMN]:[target_dict  objectForKey:MPARENT_COLUMN],
                           ([source_dict objectForKey:MVALUE_MAPPING_ID]!=@"")?[source_dict objectForKey:MVALUE_MAPPING_ID]:[target_dict  objectForKey:MVALUE_MAPPING_ID],
                           ([source_dict objectForKey:@"source_child_parent_column"]!=@"")?[source_dict objectForKey:@"source_child_parent_column"]:[target_dict  objectForKey:@"source_child_parent_column"], nil];
                NSDictionary * dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
                
                [process_info addObject:dict];
                
            }
            
            [mappingArray release];
            processId = @"", layoutId = @"", sourceName = @"", expressionId = @"", oMappingId = @"",componentType = @"",  parentColumn = @"", targetName = @"", vMappingid = @"", source_child_column = @"";
            query = @"";
            sqlite3_stmt * childStmt;
            
            query = [NSString stringWithFormat:@"SELECT * FROM SFprocess_test WHERE process_id = '%@' AND (component_type =  'TARGETCHILD')", [processIdList objectAtIndex:i]];
            
            if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &childStmt, NULL) == SQLITE_OK)
            {
                while (synchronized_sqlite3_step(childStmt) == SQLITE_ROW)
                {
                    char * _processId = (char *) synchronized_sqlite3_column_text(childStmt, COLUMNPROCESS_ID);
                    if ((_processId != nil) && strlen(_processId))
                        processId = [NSString stringWithUTF8String:_processId];
                    
                    char * _layoutId = (char *) synchronized_sqlite3_column_text(childStmt, COLUMNLAYOUT_ID);
                    if ((_layoutId != nil) && strlen(_layoutId))
                        layoutId = [NSString stringWithUTF8String:_layoutId];
                    
                    char * _objectName = (char *) synchronized_sqlite3_column_text(childStmt, COLUMNOBJECT_NAME);
                    if ((_objectName != nil) && strlen(_objectName))
                        sourceName = [NSString stringWithUTF8String:_objectName];
                    
                    char * _expressionId = (char *) synchronized_sqlite3_column_text(childStmt, COLUMNEXPRESSION_ID);
                    if ((_expressionId != nil) && strlen(_expressionId))
                        expressionId = [NSString stringWithUTF8String:_expressionId];
                    
                    char * _mappingId = (char *) synchronized_sqlite3_column_text(childStmt, COLUMNMAPPING_ID);
                    if ((_mappingId != nil) && strlen(_mappingId))
                        oMappingId = [NSString stringWithUTF8String:_mappingId];
                    
                    char * _componentType = (char *) synchronized_sqlite3_column_text(childStmt, COLUMNCOMP_TYPE);
                    if ((_componentType != nil) && strlen(_componentType))
                        componentType = [NSString stringWithUTF8String:_componentType];
                    
                    char * _parentColumn = (char *) synchronized_sqlite3_column_text(childStmt, COLUMNPARENT_COLUMN);
                    if ((_parentColumn != nil) && strlen(_parentColumn))
                        parentColumn = [NSString stringWithUTF8String:_parentColumn];
                    
                    char * _value_id = (char *) synchronized_sqlite3_column_text(childStmt, COLUNMVALUEMAP);
                    if ((_value_id != nil) && strlen(_value_id))
                        vMappingid = [NSString stringWithUTF8String:_value_id];
                    
                    NSString * source_objectName =  [self getObjectNameFromSFobjMapping:oMappingId];
                    
                    NSString * source_childName = [self getSourceChildNameFromProcessId:source_objectName processid:[processIdList objectAtIndex:i]];
                    
                    objects = [NSArray arrayWithObjects:processId, layoutId, sourceName, source_objectName, expressionId, oMappingId, componentType, parentColumn, vMappingid, source_childName, nil];
                    
                    NSDictionary * dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
                    
                    [process_info addObject:dict];
                    processId = @"", layoutId = @"", sourceName = @"", expressionId = @"", oMappingId = @"",componentType = @"",  parentColumn = @"", targetName = @"", vMappingid = @"", source_child_column = @"";
                }
                
            }
            synchronized_sqlite3_finalize(stmt);
        }
    }
    
    NSString * query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM SFProcessComponent"];
    sqlite3_stmt * stmt;
    int count = 0;
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            count = synchronized_sqlite3_column_int(stmt, 0);
        }
    }
    synchronized_sqlite3_finalize(stmt);
    int id_value = count;
    
    
    NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@', '%@',  '%@', '%@', '%@', '%@') VALUES (?1, ?2, ?3, ?4, ?5, ?6,?7, ?8, ?9, ?10, ?11)", SFPROCESSCOMPONENT, MPROCESS_ID, MLAYOUT_ID, MTARGET_OBJECT_NAME, MSOURCE_OBJECT_NAME, MEXPRESSION_ID, MOBJECT_MAPPING_ID, MCOMPONENT_TYPE, MPARENT_COLUMN,MVALUE_MAPPING_ID,@"source_child_parent_column", MLOCAL_ID];
    
    sqlite3_stmt * bulkStmt;
    
    int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);

    if (ret_value == SQLITE_OK)
    {
        for (NSDictionary * dict in process_info)
        {
            sqlite3_bind_text(bulkStmt, 1, [([dict objectForKey:MPROCESS_ID] != nil)?[dict objectForKey:MPROCESS_ID]:@"" UTF8String], [([dict objectForKey:MPROCESS_ID] != nil)?[dict objectForKey:MPROCESS_ID]:@"" length], SQLITE_TRANSIENT);
            
            sqlite3_bind_text(bulkStmt, 2, [([dict objectForKey:MLAYOUT_ID] != nil)?[dict objectForKey:MLAYOUT_ID]:@"" UTF8String], [([dict objectForKey:MLAYOUT_ID] != nil)?[dict objectForKey:MLAYOUT_ID]:@"" length], SQLITE_TRANSIENT);
            
            sqlite3_bind_text(bulkStmt, 3, [([dict objectForKey:MTARGET_OBJECT_NAME] != nil)?[dict objectForKey:MTARGET_OBJECT_NAME]:@"" UTF8String], [([dict objectForKey:MTARGET_OBJECT_NAME] != nil)?[dict objectForKey:MTARGET_OBJECT_NAME]:@"" length], SQLITE_TRANSIENT);
            
            sqlite3_bind_text(bulkStmt, 4, [([dict objectForKey:MSOURCE_OBJECT_NAME] != nil)?[dict objectForKey:MSOURCE_OBJECT_NAME]:@"" UTF8String], [([dict objectForKey:MSOURCE_OBJECT_NAME] != nil)?[dict objectForKey:MSOURCE_OBJECT_NAME]:@"" length], SQLITE_TRANSIENT);
            
            sqlite3_bind_text(bulkStmt, 5, [([dict objectForKey:MEXPRESSION_ID] != nil)?[dict objectForKey:MEXPRESSION_ID]:@"" UTF8String], [([dict objectForKey:MEXPRESSION_ID] != nil)?[dict objectForKey:MEXPRESSION_ID]:@"" length], SQLITE_TRANSIENT);
            
            sqlite3_bind_text(bulkStmt, 6, [([dict objectForKey:MOBJECT_MAPPING_ID] != nil)?[dict objectForKey:MOBJECT_MAPPING_ID]:@"" UTF8String], [([dict objectForKey:MOBJECT_MAPPING_ID] != nil)?[dict objectForKey:MOBJECT_MAPPING_ID]:@"" length], SQLITE_TRANSIENT);
            
            sqlite3_bind_text(bulkStmt, 7, [([dict objectForKey:MCOMPONENT_TYPE] != nil)?[dict objectForKey:MCOMPONENT_TYPE]:@"" UTF8String], [([dict objectForKey:MCOMPONENT_TYPE] != nil)?[dict objectForKey:MCOMPONENT_TYPE]:@"" length], SQLITE_TRANSIENT);
            
            sqlite3_bind_text(bulkStmt, 8, [([dict objectForKey:MPARENT_COLUMN] != nil)?[dict objectForKey:MPARENT_COLUMN]:@"" UTF8String], [([dict objectForKey:MPARENT_COLUMN] != nil)?[dict objectForKey:MPARENT_COLUMN]:@"" length], SQLITE_TRANSIENT);
            
            sqlite3_bind_text(bulkStmt, 9, [([dict objectForKey:MVALUE_MAPPING_ID] != nil)?[dict objectForKey:MVALUE_MAPPING_ID]:@"" UTF8String], [([dict objectForKey:MVALUE_MAPPING_ID] != nil)?[dict objectForKey:MVALUE_MAPPING_ID]:@"" length], SQLITE_TRANSIENT);
            
            sqlite3_bind_text(bulkStmt,  10, [([dict objectForKey:@"source_child_parent_column"] != nil)?[dict objectForKey:@"source_child_parent_column"]:@"" UTF8String], [([dict objectForKey:@"source_child_parent_column"] != nil)?[dict objectForKey:@"source_child_parent_column"]:@"" length], SQLITE_TRANSIENT);
            
            sqlite3_bind_int(bulkStmt, 11, ++id_value);
            
            if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
            {
                printf("Commit Failed!\n");
            }
            
            sqlite3_reset(bulkStmt);
        }
    }

}
#pragma mark - END


- (NSString *) getObjectNameFromSFobjMapping:(NSString *)mappingId
{
    NSString * qurey = [NSString stringWithFormat:@"SELECT source_object_name FROM SFObjectMapping where object_mapping_id = '%@'", mappingId];
    
    sqlite3_stmt * stmt;
    
    NSString * objectName = @"";
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [qurey UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if  (synchronized_sqlite3_step(stmt) == SQLITE_ROW) 
        {
            char * name = (char *) synchronized_sqlite3_column_text(stmt, 0);
            
            if ((name != nil) && strlen(name))
                objectName = [NSString stringWithUTF8String:name];
        }
    }
    synchronized_sqlite3_finalize(stmt);
    return objectName;
}


- (NSString *) getSourceChildNameFromProcessId:(NSString *)soureobjectName processid:(NSString *)processId
{
    NSString * qurey = [NSString stringWithFormat:@"SELECT parent_column FROM SFProcess_test WHERE process_id = '%@' AND object_name = '%@'", processId, soureobjectName];
    
    sqlite3_stmt * stmt;
    
    NSString * objectName = @"";
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [qurey UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if  (synchronized_sqlite3_step(stmt) == SQLITE_ROW) 
        {
            char * name = (char *) synchronized_sqlite3_column_text(stmt, 0);
            
            if ((name != nil) && strlen(name))
                objectName = [NSString stringWithUTF8String:name];            
        }
    }
    synchronized_sqlite3_finalize(stmt);
    return objectName;
}
 
#pragma mark - Create Extra Tables For TroubleShooting and Summary
- (void) createTableForSummaryAndTroubleShooting
{
    NSString * query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS  ChatterPostDetails ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0), 'ProductId' VARCHAR NOT NULL ,'Body' TEXT,'CreatedById' VARCHAR,'CreatedDate' VARCHAR,'Id' VARCHAR,'POSTTYPE' VARCHAR,'Username' VARCHAR,'Email' VARCHAR,'FeedPostId' VARCHAR,'FullPhotoUrl' VARCHAR)"];
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS Document ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0), 'AuthorId' VARCHAR, 'Body' VARCHAR, 'BodyLength' INTEGER, 'ContentType' VARCHAR, 'CreatedById' VARCHAR, 'Description' VARCHAR, 'DeveloperName' VARCHAR, 'FolderId' VARCHAR, 'Id' VARCHAR, 'IsBodySearchable' BOOL, 'IsDeleted' BOOL, 'IsInternalUseOnly' BOOL, 'IsPublic' BOOL, 'Keywords' TEXT, 'LastModifiedById' VARCHAR, 'LastModifiedDate' DATETIME, 'Name' VARCHAR, 'NamespacePrefix' VARCHAR, 'SystemModstamp' VARCHAR, 'Type' VARCHAR)"];
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS  ProductImage ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0), 'productId' VARCHAR, 'productImage' VARCHAR)"];
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS  SFSignatureData ('record_Id' VARCHAR,'object_api_name' VARCHAR,'signature_data' TEXT,'sig_Id' TEXT ,'WorkOrderNumber' VARCHAR, 'sign_type' VARCHAR)"];
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS UserImages ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0), 'username' VARCHAR,'userimage' BLOB)"];
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS  trobleshootdata ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0),'ProductId' VARCHAR, 'ProductName' VARCHAR, 'Product_Doc' BLOB, 'DocId' VARCHAR, 'prod_manual_Id' VARCHAR, 'prod_manual_name' VARCHAR, 'productmanbody' VARCHAR)"];
    [self createTable:query];
    

    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFDataTrailer ('timestamp' DATETIME, 'local_id' INTEGER,'sf_id' VARCHAR, 'record_type' VARCHAR, 'operation' VARCHAR, 'object_name' VARCHAR, 'sync_flag' BOOL , 'parent_object_name'  VARCHAR ,'parent_local_id'  VARCHAR , 'record_sent')"];
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFDataTrailer_Temp ('timestamp' DATETIME, 'local_id' INTEGER,'sf_id' VARCHAR, 'record_type' VARCHAR, 'operation' VARCHAR, 'object_name' VARCHAR, 'sync_flag' BOOL , 'parent_object_name'  VARCHAR ,'parent_local_id'  VARCHAR , 'record_sent')"];
    [self createTable:query];
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SYNC_HISTORY ('last_sync_time' DATETIME , 'sync_type' VARCHAR , 'request_id' VARCHAR , 'SYNC_STATUS' BOOL )"];
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS sync_Records_Heap ('sf_id' VARCHAR, 'local_id' VARCHAR,'object_name' VARCHAR, 'sync_type' VARCHAR, 'json_record' VARCHAR , 'sync_flag' BOOL , 'record_type' VARCHAR)"];
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS sync_Record_Heap_Index ON sync_Records_Heap (sf_id ASC, local_id ASC, object_name ASC, sync_flag ASC)"];
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS LookUpFieldValue ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0), 'object_api_name' VARCHAR, 'Id' VARCHAR, 'value' VARCHAR)"];
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE SettingsValue ('Id' VARCHAR, 'SVMXC__Active__c' BOOL, 'SVMXC__Display_Value__c' TEXT, 'SVMXC__Internal_Value__c' TEXT, 'SVMXC__IsDefault__c' BOOL, 'SVMXC__Setting_Configuration_Profile__c' TEXT, 'SVMXC__Setting_ID__c' TEXT)"];
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE SettingsInfo ('Id' VARCHAR, 'SVMXC__Active__c' BOOL, 'SVMXC__Data_Type__c' TEXT, 'SVMXC__Default_Value__c' TEXT, 'SVMXC__Description__c' TEXT, 'SVMXC__IsPrivate__c' BOOL, 'SVMXC__IsStandard__c' BOOL, 'SVMXC__Search_Order__c' VARCHAR, 'SVMXC__SettingID__c' VARCHAR, 'SVMXC__Setting_Type__c' VARCHAR, 'SVMXC__Setting_Unique_ID__c' TEXT, 'SVMXC__Settings_Name__c' TEXT, 'SVMXC__SubmoduleID__c' TEXT, 'SVMXC__Submodule__c' TEXT, 'SVMXC__Values__c' TEXT)"];
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS Summary_PDF ('record_Id' VARCHAR,'object_api_name' VARCHAR, 'PDF_data' TEXT, 'WorkOrderNumber' VARCHAR, 'PDF_Id' VARCHAR, 'sign_type' VARCHAR, 'pdf_name' VARCHAR)"];
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS sync_error_conflict ('sf_id' VARCHAR, 'local_id' VARCHAR,'object_name' VARCHAR, 'record_type' VARCHAR ,'sync_type' VARCHAR ,'error_message' VARCHAR ,'operation_type' VARCHAR , 'error_type' VARCHAR , 'override_flag'  VARCHAR)"];
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS contact_images ('contact_Id' VARCHAR, 'contact_Image' VARCHAR)"];
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS internet_conflicts ('sync_type' VARCHAR, 'error_message' VARCHAR, 'operation_type' VARCHAR, 'error_type' VARCHAR)"];
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS meta_sync_status ('sync_status' VARCHAR)"];
    [self createTable:query];
}


#pragma mark - Create All Tables
- (BOOL) createTable:(NSString *)statement
{
    char * err;
    if (synchronized_sqlite3_exec(appDelegate.db, [statement UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
            [MyPopoverDelegate performSelector:@selector(throwException)];
        NSLog(@"Failed");
        return NO;
    }
    return YES;
}

#pragma mark - DataSync

- (void) insertDataInToTables:(NSMutableArray *)fieldValueArray
{
    NSArray * fields = [[[NSArray alloc] init] autorelease];
    NSArray * values = [[[NSArray alloc] init] autorelease];
    int lookUp_id = 1;
    
    for (int i = 0; i < [fieldValueArray count]; i++)
    {
        NSDictionary * dict = [fieldValueArray objectAtIndex:i];
        
        NSArray * keys = [dict allKeys];
        
        for (int j = 0; j < [keys count]; j++)
        {
            NSString * objectName = [keys objectAtIndex:j];
            
            if ([objectName isEqualToString:@"Case"])
                objectName = @"'Case'";
            
            //int id_value = 1;
            NSString * id_value  = @"";
            NSMutableArray * fieldArray = [dict objectForKey:[keys objectAtIndex:j]];
            
            for (int val = 0; val < [fieldArray count]; val++)
            {
                NSDictionary * fieldValues = [fieldArray objectAtIndex:val];
                
                id_value = [iServiceAppDelegate GetUUID];
                
                fields = [fieldValues allKeys];
                values = [fieldValues allValues];
                
                NSString * field_string = @"";
                NSString * value_string = @"";
                
                for (int f = 0; f < [fields count]; f++)
                {
                    NSMutableDictionary * lookUpDict = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
                    
                    if ([[values objectAtIndex:f] isKindOfClass:[NSDictionary class]])
                    {
                        NSString * field = [fields objectAtIndex:f];
                        
                        NSRange range = [field rangeOfString:@"__r"];
                        
                        if (range.location != NSNotFound)
                        {
                            NSDictionary * attDict = [[values objectAtIndex:f] objectForKey:@"attributes"];
                            
                            [lookUpDict setValue:[[values objectAtIndex:f] objectForKey:@"Id"] forKey:@"Id"];
                            [lookUpDict setValue:[[values objectAtIndex:f] objectForKey:@"Name"] forKey:@"Name"];
                            [lookUpDict setValue:[attDict objectForKey:@"type"] forKey:@"type"];
                            
                            [self addvaluesToLookUpFieldTable:lookUpDict WithId:lookUp_id++];
                        }                        
                        
                    }
                    
                    if ([[fields objectAtIndex:f] isKindOfClass:[NSString class]] && (![[values objectAtIndex:f] isKindOfClass:[NSDictionary class]]))
                    {
                        NSString * value = [fieldValues objectForKey:[fields objectAtIndex:f]];
                        
                        if ([value isKindOfClass:[NSString class]])
                            value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                        
                        if ([field_string length] > 0)
                        {
                            value_string = [value_string stringByAppendingString:@", "];
                            field_string = [field_string stringByAppendingString:@","];                        
                        }
                        
                        value_string = [value_string stringByAppendingString:[NSString stringWithFormat:@"'%@'", value]];
                        field_string = [field_string stringByAppendingString:[NSString stringWithFormat:@"%@", [fields objectAtIndex:f]]];
                    }
                }  
                
                BOOL retVal = [self checkForDuplicateId:objectName sfId:[fieldValues objectForKey:@"Id"]];
                
                NSString * query = @"";
                if (retVal)
                {
                     query = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (%@, '%@') VALUES (%@, '%@')", objectName, field_string, MLOCAL_ID, value_string, id_value];
                
                    char * err;
                    if (synchronized_sqlite3_exec(appDelegate.db, [query UTF8String], NULL, NULL, &err) != SQLITE_OK)
                    {  
                        if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
                            [MyPopoverDelegate performSelector:@selector(throwException)];
                        NSLog(@"Failed to insert");
                    }
                }
            }
        }        
    }
    [self updateChildSfIdWithParentLocalId:appDelegate.wsInterface.childObject];
}

-(void) addvaluesToLookUpFieldTable:(NSDictionary *)lookUpDict WithId:(NSInteger)Id
{
    NSString * value = ([lookUpDict objectForKey:@"Name"] != nil)?[lookUpDict objectForKey:@"Name"]:@"";
    
    if (![value isEqualToString:@""])
        value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    
    NSString * query = [NSString stringWithFormat:@"INSERT OR REPLACE INTO LookUpFieldValue ('%@', '%@', '%@') VALUES ('%@',    '%@', '%@')", MOBJECT_API_NAME, @"Id", MVALUEM, 
                        ([lookUpDict objectForKey:@"type"] != nil)?[lookUpDict objectForKey:@"type"]:@"", 
                        ([lookUpDict objectForKey:@"Id"] != nil)?[lookUpDict objectForKey:@"Id"]:@"", 
                        value];
    
    char * err;
    if(synchronized_sqlite3_exec(appDelegate.db, [query UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
            [MyPopoverDelegate performSelector:@selector(throwException)];
        NSLog(@"Failed to insert");
    }
    
}
-(void) updateChildSfIdWithParentLocalId:(NSArray *)childObject
{
    for (NSString * objectName in childObject)
    {
        NSString * query = [NSString stringWithFormat:@"SELECT field_api_name, object_api_name_parent FROM SFChildRelationship where object_api_name_parent = (SELECT object_api_name_parent FROM SFChildRelationship WHERE object_api_name_child = '%@') and object_api_name_child = '%@'", objectName, objectName];
        
        sqlite3_stmt * statement;
        
        NSString * parentColumn = @""; 
        NSString * parent_object = @"";
        
        if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            if(synchronized_sqlite3_step(statement) == SQLITE_ROW)
            {
                char * _field_api_name = (char *)synchronized_sqlite3_column_text(statement, 0);
                
                if ((_field_api_name != nil) && strlen(_field_api_name))
                    parentColumn = [NSString stringWithUTF8String:_field_api_name];
                
                char * _parent_object = (char *)synchronized_sqlite3_column_text(statement, 1);
                
                if ((_parent_object != nil) && strlen(_parent_object))
                    parent_object = [NSString stringWithUTF8String:_parent_object];
            }
        }
        
        synchronized_sqlite3_finalize(statement);
        
                
        
        sqlite3_stmt * stmt;
        NSString * queryStatement = [NSString stringWithFormat:@"SELECT %@ FROM %@", parentColumn, objectName];
        
        NSMutableArray * sfid_array = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
        NSString * check_id = @"";
        
        if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &stmt, NULL) == SQLITE_OK)
        {
            while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
            {
                NSString * sf_Id = @"";
                char * _sfId = (char *) synchronized_sqlite3_column_text(stmt, 0);
                
                if ((_sfId != nil) && strlen(_sfId))
                    sf_Id = [NSString stringWithUTF8String:_sfId];
                
                if ([sfid_array count] > 0)
                {
                    if ([check_id isEqualToString:sf_Id])
                    {
                        
                    }
                    else
                    {
                        [sfid_array addObject:sf_Id];
                        check_id = sf_Id;
                    }
                }
                else
                {
                    [sfid_array addObject:sf_Id];
                    check_id = sf_Id;
                }
                
            }
        }
           
        synchronized_sqlite3_finalize(stmt);
        
        for (NSString * id_ in sfid_array)
        {
                sqlite3_stmt * stmt_localId;
                NSString * queryStatement1 = [NSString stringWithFormat:@"SELECT local_id FROM %@ WHERE Id = '%@'", parent_object, id_];
                
                if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement1 UTF8String], -1, &stmt_localId, NULL) == SQLITE_OK)
                {
                    while (synchronized_sqlite3_step(stmt_localId) == SQLITE_ROW)
                    {
                        char * temp_localId = (char *)synchronized_sqlite3_column_text(stmt_localId, 0);
                        NSString * _localId = @"";
                        if(temp_localId != nil)
                            _localId = [NSString stringWithUTF8String:temp_localId];
                        
                        NSString * localId = [NSString stringWithFormat:@"%@", _localId];
                        
                        sqlite3_stmt * stmt_id;
                        NSString * queryStatement2 = [NSString stringWithFormat:@"SELECT Id FROM %@ WHERE %@ = '%@'", objectName, parentColumn, id_];
                        if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement2 UTF8String], -1, &stmt_id, NULL) == SQLITE_OK)
                        {
                            while (synchronized_sqlite3_step(stmt_id) == SQLITE_ROW)
                            {
                                NSString * sfid = @"";
                                char * _sfid = (char *)synchronized_sqlite3_column_text(stmt_id, 0);
                                if(_sfid != nil)
                                    sfid = [NSString stringWithUTF8String:_sfid];
                                
                                NSString * queryStatement3 = [NSString stringWithFormat:@"UPDATE %@ SET %@ = '%@' WHERE Id = '%@'", objectName, parentColumn, localId, sfid];
                                
                                char * err;
                                if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement3 UTF8String], NULL, NULL, &err) != SQLITE_OK)
                                {
                                    if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
                                        [MyPopoverDelegate performSelector:@selector(throwException)];
                                    NSLog(@"Failed to update");
                                }

                            }
                                            
                        }
                    }
                                    
                }
            } //kdfjbjdkfg
            
        synchronized_sqlite3_finalize(stmt);
    }
    appDelegate.wsInterface.didOpComplete = TRUE;
    NSLog(@"IComeOUTHere Databse");
}

-(BOOL) checkForDuplicateId:(NSString *)objectName sfId:(NSString *)sfId
{
    int count = 0;
    
    if([objectName isEqualToString:@"Case"])
    {
        objectName = @"'Case'";
    }
    
    NSString * query = [[NSString alloc] initWithFormat:@"SELECT COUNT(*) FROM %@ WHERE Id = '%@'", objectName, sfId];
    
    sqlite3_stmt * stmt;
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            count = synchronized_sqlite3_column_int(stmt, 0); 
        }
    }
    synchronized_sqlite3_finalize(stmt);
    [query release];
    if (count > 0)
        return FALSE;
    else 
        return TRUE;

}

#pragma mark - PDF Settings
- (void) generatePDFSettings
{
    if (appDelegate.isForeGround == TRUE || !appDelegate.isInternetConnectionAvailable)
    {
        if(appDelegate.IsLogedIn == ISLOGEDIN_TRUE)
        {
            appDelegate.initial_sync_succes_or_failed = META_SYNC_FAILED;
            return;
        }
    }
    // Get details of the IPAD Module
    NSString * _query = @"SELECT Id, SVMXC__Name__c, SVMXC__Description__c, SVMXC__ModuleID__c, SVMXC__IsStandard__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__ModuleID__c = \'IPAD\' AND RecordType.Name = \'MODULE\'";
    [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didGetModuleInfo:error:context:) context:nil];
}

- (void) didGetModuleInfo:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    if (appDelegate.isForeGround == TRUE || !appDelegate.isInternetConnectionAvailable)
    {
        if(appDelegate.IsLogedIn == ISLOGEDIN_TRUE)
        {
            appDelegate.initial_sync_succes_or_failed = META_SYNC_FAILED;
            return;
        }
    }
    // Get Submodules Info (query could return multiple rows)
    if ([[result records] count] > 0)
    {
        ZKSObject * obj = [[result records] objectAtIndex:0];
        NSString * moduleInfo = [[obj fields] objectForKey:@"Id"];
        NSString * _query = [NSString stringWithFormat:@"SELECT Id, SVMXC__ModuleID__c, SVMXC__SubmoduleID__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__IsStandard__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Module__c = \'%@\' AND RecordType.Name = \'SUBMODULE\'", moduleInfo];
        [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didGetSubModuleInfo:error:context:) context:nil];
    }
    else
    {
        didGetPDF = YES;
    }
}

- (void) didGetSubModuleInfo:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    if (appDelegate.isForeGround == TRUE || !appDelegate.isInternetConnectionAvailable)
    {
        if(appDelegate.IsLogedIn == ISLOGEDIN_TRUE)
        {
            appDelegate.initial_sync_succes_or_failed = META_SYNC_FAILED;
            return;
        }
    }
    // Get Settings Info(query could return multiple rows)
    if ([[result records] count] > 0)
    {
        NSString * _query = [NSString stringWithFormat:@"SELECT Id, SVMXC__SubmoduleID__c, SVMXC__SettingID__c, SVMXC__Setting_Unique_ID__c, SVMXC__Settings_Name__c, SVMXC__Data_Type__c, SVMXC__Values__c, SVMXC__Default_Value__c, SVMXC__Setting_Type__c, SVMXC__Search_Order__c, SVMXC__IsPrivate__c, SVMXC__Active__c, SVMXC__Description__c, SVMXC__IsStandard__c, SVMXC__Submodule__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__SubmoduleID__c = 'IPAD004' AND RecordType.Name = \'SETTINGS\' ORDER BY SVMXC__Setting_Unique_ID__c"];
        [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didGetSettingsInfo:error:context:) context:nil];
    }
    else
    {
        // Continue logging in
        didGetPDF = YES;
    }
}

- (void) didGetSettingsInfo:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    if (appDelegate.isForeGround == TRUE || !appDelegate.isInternetConnectionAvailable)
    {
        if(appDelegate.IsLogedIn == ISLOGEDIN_TRUE)
        {
            appDelegate.initial_sync_succes_or_failed = META_SYNC_FAILED;
            return;
        }
    }
    // Get the Active Global Profile
    if ([[result records] count] > 0)
    {
       settingInfoId = [[NSMutableString alloc] initWithCapacity:0];
       settingsInfoArray = [[NSMutableArray alloc] initWithCapacity:0];
        for (int i = 0; i < [[result records] count]; i++)
        {
            ZKSObject * obj = [[result records] objectAtIndex:i];
            
            [settingsInfoArray addObject:[obj fields]];
            
            if ([settingInfoId length] == 0)
                [settingInfoId appendFormat:@"(\'%@\'", [[obj fields] objectForKey:@"Id"]];
            else
                [settingInfoId appendFormat:@", \'%@\'", [[obj fields] objectForKey:@"Id"]];
        }
        [settingInfoId appendString:@")"];
        
        NSString * _query = @"Select Id, SVMXC__Profile_Name__c, SVMXC__Active__c, SVMXC__IsDefault__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__RecordType_Name__c=\'Configuration Profile\' and SVMXC__Configuration_Type__c = \'Global\' and SVMXC__Active__c = true";
        [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didGetActiveGlobalProfile:error:context:) context:nil];
        //Get the Location Ping Settings
        _query = [NSString stringWithFormat:@"SELECT Id, SVMXC__SubmoduleID__c, SVMXC__SettingID__c, SVMXC__Setting_Unique_ID__c, SVMXC__Settings_Name__c, SVMXC__Data_Type__c, SVMXC__Values__c, SVMXC__Default_Value__c, SVMXC__Setting_Type__c, SVMXC__Search_Order__c, SVMXC__IsPrivate__c, SVMXC__Active__c, SVMXC__Description__c, SVMXC__IsStandard__c, SVMXC__Submodule__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__SubmoduleID__c = 'IPAD007' AND RecordType.Name = \'SETTINGS\' ORDER BY SVMXC__Setting_Unique_ID__c"];
        [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didGetSettingsInfoforLocationPing:error:context:) context:nil];

    }
    else
    {
        // Continue logging in
        didGetPDF = YES;
    }
}

- (void) didGetActiveGlobalProfile:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    if (appDelegate.isForeGround == TRUE || !appDelegate.isInternetConnectionAvailable)
    {
        if(appDelegate.IsLogedIn == ISLOGEDIN_TRUE)
        {
            appDelegate.initial_sync_succes_or_failed = META_SYNC_FAILED;
            return;
        }
    }
    // Get Settings value Info(query could return multiple rows)
    if ([[result records] count] > 0)
    {
        ZKSObject * obj = [[result records] objectAtIndex:0];
       NSString * ActiveGloProInfoId = [[[obj fields] objectForKey:@"Id"] retain];
        NSString * _query = nil;
        if ([settingInfoId length] != 0)
            _query = [NSString stringWithFormat:@"Select Id, SVMXC__Setting_Configuration_Profile__c, SVMXC__Setting_ID__c, SVMXC__Internal_Value__c, SVMXC__Display_Value__c, SVMXC__Active__c, SVMXC__IsDefault__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__Setting_Configuration_Profile__c = \'%@\' AND SVMXC__Setting_ID__c IN %@ AND RecordType.Name = \'SETTING VALUE\' ORDER BY SVMXC__Setting_Unique_ID__c", ActiveGloProInfoId, settingInfoId];
        else
            _query = [NSString stringWithFormat:@"SELECT Id, SVMXC__Setting_Configuration_Profile__c, SVMXC__Setting_ID__c, SVMXC__Internal_Value__c, SVMXC__Display_Value__c, SVMXC__Active__c, SVMXC__IsDefault__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__Setting_Configuration_Profile__c = \'%@' AND RecordType.Name = \'SETTING VALUE\' ORDER BY SVMXC__Setting_Unique_ID__c", ActiveGloProInfoId];
        [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didGetSettingsValue:error:context:) context:nil];
    }
    else
    {
        // Continue logging in
        didGetPDF = YES;
    }
}

- (void) didGetSettingsValue:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    if (appDelegate.isForeGround == TRUE || !appDelegate.isInternetConnectionAvailable)
    {
        if(appDelegate.IsLogedIn == ISLOGEDIN_TRUE)
        {
            appDelegate.initial_sync_succes_or_failed = META_SYNC_FAILED;
            return;
        }
    }
    if ([[result records] count] > 0)
    {
        appDelegate.serviceReport = [[NSMutableDictionary alloc] initWithCapacity:0];
        appDelegate.addressType = [[NSMutableString alloc] initWithCapacity:0];
        
        settingsValueArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
        for (int i = 0; i < [[result records] count]; i++)
        {
            ZKSObject * obj = [[result records] objectAtIndex:i];
            [settingsValueArray addObject:[obj fields]];
            
        }
    }
    [self insertSettingsIntoTable:settingsValueArray:@"SettingsValue"];
    [self insertSettingsIntoTable:settingsInfoArray:@"SettingsInfo"];
    
    appDelegate.wsInterface.didOpComplete = TRUE;
    NSLog(@"IComeOUTHere didgetsettings");

}
-(void)insertSettingsIntoTable:(NSMutableArray*)array:(NSString*)TableName
{
    NSLog(@"SAMMAN MetaSync insertSettingsIntoTable processing starts: %@", [NSDate date]);
    NSString * field_string = @"";
    NSString * field_value = @"";
    for (NSDictionary * dict in array) 
    {
        field_string = @"";
        field_value = @"";
        NSArray * allkeys = [dict allKeys];
        NSArray * allvalue = [dict allValues];
        
        for (int i = 0; i < [allkeys count]; i++)
        {
            NSString * str = [allkeys objectAtIndex:i];
            
            NSString * value = [allvalue objectAtIndex:i];
            if ([value isKindOfClass:[NSNull class]])
                value = @"";
            value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];

            if (![str isEqualToString:nil])
            {
                if ([field_string length] > 0)
                {
                    field_string = [field_string stringByAppendingString:@", "];
                    field_value = [field_value stringByAppendingString:@", "];
                }
                field_string = [field_string stringByAppendingString:[NSString stringWithFormat:@"%@", str]];
                field_value = [field_value stringByAppendingString:[NSString stringWithFormat:@"'%@'", value]];
            }
        }
        
        NSString * query =[NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)",TableName,field_string, field_value];
        [self createTable:query];
        
    }
    
}

#pragma mark - update recents plist
- (void) updateRecentsPlist
{
    NSString *error;
    
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *plistPath = [rootPath stringByAppendingPathComponent:OBJECT_HISTORY_PLIST];
    
    NSData * plistData = [NSPropertyListSerialization dataFromPropertyList:plistPath format:NSPropertyListXMLFormat_v1_0
                                                          errorDescription:&error];
    
    NSMutableArray * array = nil;
    
    NSMutableArray * updated_array = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    if(plistData)
    {
        array = [[[NSMutableArray alloc] initWithContentsOfFile:plistPath] autorelease];
    }
    
    for (NSDictionary * recentsDict in array)
    {
        NSString * nameField = [recentsDict objectForKey:NAME_FIELD];
        
        if ([nameField isEqualToString:nil] || [nameField isEqualToString:@""])
        {
            NSString * headerObjectName = [recentsDict objectForKey:OBJ_NAME];
            
            NSString * name = [self getNameFieldForObject:headerObjectName WithRecordId:[recentsDict objectForKey:RESULTID]];
            
            if (![name isEqualToString:@""])
                [recentsDict setValue:name forKey:NAME_FIELD];
        }
        
        [updated_array addObject:recentsDict];
    }
    
    [updated_array writeToFile:plistPath atomically:YES];
    [appDelegate.recentObject removeAllObjects];    
}


- (NSString *) getNameFieldForObject:(NSString *)headerObjectName WithRecordId:(NSString *)recordId
{
    NSString * queryStatement = @"";
    
    if ([headerObjectName isEqualToString:@"Case"])
        queryStatement = [NSString stringWithFormat:@"SELECT CaseNumber From '%@' WHERE local_id = '%@'", headerObjectName, recordId];
    else
        queryStatement = [NSString stringWithFormat:@"SELECT Name From %@ WHERE local_id = '%@'", headerObjectName, recordId];
    
    
    sqlite3_stmt * stmt;
    NSString * nameField = @"";
    
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            const char * name = (char *) synchronized_sqlite3_column_text(stmt, 0);
            if (name != nil && strlen(name))
                nameField = [NSString stringWithUTF8String:name];
        }
    }
    synchronized_sqlite3_finalize(stmt);
    return nameField;
}



-(void)StartIncrementalmetasync
{
    [self openDB:TEMPDATABASENAME type:DATABASETYPE1 sqlite:nil];
    
    [self clearTempDatabase];
    
    //We are retriving the SFObjectField table here so that we can compare the fields of the tables of the two databases
    //not necessary
    // tableNames = [self retrieveQueryForTableName];
    // [self createTemporaryTable:tableNames];
    
    //all the tables which do not form in metasync are being created here in the backup
    
    if (object_names != nil)
    {
        object_names = nil;
    }
    
    object_names = [[NSMutableArray alloc] initWithCapacity:0];
    
    object_names = [self retreiveTableNamesFronDB:appDelegate.db];
    
    
    for (NSString * objectName in object_names)
    {
        NSString * query = [self retrieveQuery:objectName sqlite:appDelegate.db];
        
        [self createTemporaryTable:query];
    }
    
    //This method fills the backup DB with all the data
    
    [self createBackUpDb];
    
    appDelegate.didincrementalmetasyncdone = TRUE;
    [appDelegate startBackgroundThreadForLocationServiceSettings];
    
}

- (void) createBackUpDb
{  
    NSString * query1 = [NSString stringWithFormat:@"ATTACH DATABASE '%@' AS sfm",self.dbFilePath];
    [self createTemporaryTable:query1];
    
    
    //Here we fill up the tables with data  
    for (NSString * objectName in object_names)
    {
        if ([objectName isEqualToString:@"Case"])
            objectName = @"'Case'";
        
        query1 = [NSString stringWithFormat:@"INSERT INTO %@ SELECT * FROM sfm.%@", objectName, objectName];
        [self createTemporaryTable:query1];
    }
       
    //Delete the old database after creating the backup
    [self deleteDatabase:DATABASENAME];

    //we again start metasync here

    appDelegate.db = nil;
    self.dbFilePath = nil;
    [appDelegate initWithDBName:DATABASENAME1 type:DATABASETYPE1];
    
    time_t t1;
    time(&t1);

    
    appDelegate.wsInterface.didOpComplete = FALSE;
    [appDelegate.wsInterface metaSyncWithEventName:SFM_METADATA eventType:INITIAL_SYNC values:nil];
    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, 1, NO))
    {
        if (!appDelegate.isInternetConnectionAvailable)
        {
            if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
                [MyPopoverDelegate performSelector:@selector(throwException)];
            break;
        }
        
        if (appDelegate.wsInterface.didOpComplete == TRUE)
            break; 
    }

    /*
     // Uncomment this when SFM Search Module is Required
    //SFM Search 
    
    appDelegate.wsInterface.didOpSFMSearchComplete = FALSE;
    [appDelegate.wsInterface metaSyncWithEventName:SFM_SEARCH eventType:SYNC values:nil];
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, YES))
    {
        if (!appDelegate.isInternetConnectionAvailable)
        {
            if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
                [MyPopoverDelegate performSelector:@selector(throwException)];
            break;
        }
        if (appDelegate.wsInterface.didOpSFMSearchComplete == TRUE)
            break; 
    }
    NSLog(@"MetaSync SFM Search End: %@", [NSDate date]);
    
    //SFM Search End
     */
    [appDelegate getDPpicklistInfo];
    NSLog(@"META SYNC 1");
    
    time_t t2;
    time(&t2);
    double diff = difftime(t2,t1);
    NSLog(@"time taken for meta and data sync = %f",diff);
    
    [self populateDatabaseFromBackUp];
    
    //Radha purging - 10/April/12
    NSMutableArray * recordId = [appDelegate.dataBase getAllTheRecordIdsFromEvent];
    
    appDelegate.initialEventMappinArray = [appDelegate.dataBase checkForTheObjectWithRecordId:recordId];
    //Radha End
}

- (NSMutableArray *) retreiveTableNamesFronDB:(sqlite3 *)dbName
{
    NSMutableArray * array = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    NSString * query = [NSString stringWithFormat:@"SELECT tbl_name FROM Sqlite_master where type = 'table'"];
    
    sqlite3_stmt * stmt;
    NSString * object_api_name = @"";
    if (synchronized_sqlite3_prepare_v2(dbName, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            const char * _object = (char *) synchronized_sqlite3_column_text(stmt, 0);
            
            if ((_object != nil) && strlen(_object))
            {
                object_api_name = [NSString stringWithUTF8String:_object];
                if ([object_api_name isEqualToString:@"sqlite_sequence"])
                    continue;
                [array addObject:object_api_name];
            }                   
        }
    }
    
    return array;
}


- (void) copyTempsqlToSfm
{
    if (object_names == nil)
        object_names = [[NSMutableArray alloc] initWithCapacity:0];
    
    object_names = [self retreiveTableNamesFronDB:tempDb];
    
    [appDelegate.dataBase clearDatabase];
    
    for (NSString * objectName in object_names)
    {
        NSString * query = [self retrieveQuery:objectName sqlite:tempDb];
        
        [self createTable:query];
    }

    
    
    [appDelegate initWithDBName:DATABASENAME1 type:DATABASETYPE1];

    
    NSString * query1 = [NSString stringWithFormat:@"ATTACH DATABASE '%@' AS tempsfm",filepath];
    [self createTable:query1];
    
    
    //Here we fill up the tables with data  
    for (NSString * objectName in object_names)
    {
        if ([objectName isEqualToString:@"Case"])
            objectName = @"'Case'";
        
        query1 = [NSString stringWithFormat:@"INSERT INTO %@ SELECT * FROM tempsfm.%@", objectName, objectName];
        [self createTable:query1];
    } 

}

-(void)openDB:(NSString *)name type:(NSString *)type sqlite:(sqlite3 *)database
{
    filepath = @"";
    
    NSError *error; 
    NSArray *searchPaths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolderPath = [searchPaths objectAtIndex: 0];
    filepath = [documentFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", TEMPDATABASENAME, DATABASETYPE1]];
    
    BOOL success=[[NSFileManager defaultManager] fileExistsAtPath:filepath];
    if ( success)
    { 
        NSLog(@"\n db exist in the path");		
    }
    else    //didn't find db, need to copy
    {
        NSString *backupDbPath = [[NSBundle mainBundle] pathForResource:TEMPDATABASENAME ofType:DATABASETYPE1]; 
        if (backupDbPath == nil) 
        {
            NSLog(@"\n db not able to create error");   
        }
        else 
        { 
            BOOL copiedBackupDb = [[NSFileManager defaultManager] copyItemAtPath:backupDbPath toPath:filepath error:&error]; 
            if (!copiedBackupDb) 
                NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
        } 
    }
    if( sqlite3_open ([filepath UTF8String], &tempDb) != SQLITE_OK )
    { 
        NSLog (@"couldn't open db:");
        NSAssert(0, @"Database failed to open.");		//throw another exception here
    }
} 


-(NSString *)retrieveQuery:(NSString *)tableName sqlite:(sqlite3 *)database
{
    NSMutableString * query = [NSMutableString stringWithFormat:@"SELECT sql FROM sqlite_master WHERE tbl_name = '%@' AND type = 'table'", tableName];
    
    sqlite3_stmt * stmt;
    
    NSString * queryStatement = @"";    
    const char * _query = [query UTF8String];
    
    if ( synchronized_sqlite3_prepare_v2(database, _query,-1, &stmt, nil) == SQLITE_OK )
    {
        while (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char *field1 = (char *) synchronized_sqlite3_column_text(stmt,0);
            if ((field1 != nil) && strlen(field1))
            {
                NSString *field1Str = [[NSString alloc] initWithUTF8String:field1];
                queryStatement = [NSString stringWithFormat:@"%@",field1Str];
            }
        }
    }
    synchronized_sqlite3_finalize(stmt);
    
    return queryStatement;
}
- (BOOL) createTemporaryTable:(NSString *)statement
{
    char * err;

    if (synchronized_sqlite3_exec(tempDb, [statement UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
            [MyPopoverDelegate performSelector:@selector(throwException)];
        NSLog(@"Failed");
        return NO;
    }
    return YES;
}

- (NSArray *) createTempTableForSummaryAndTroubleShooting
{
    NSString * query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS  ChatterPostDetails ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0), 'ProductId' VARCHAR NOT NULL ,'Body' TEXT,'CreatedById' VARCHAR,'CreatedDate' VARCHAR,'Id' VARCHAR,'POSTTYPE' VARCHAR,'Username' VARCHAR,'Email' VARCHAR,'FeedPostId' VARCHAR,'FullPhotoUrl' VARCHAR)"];
    [self createTemporaryTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS Document ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0), 'AuthorId' VARCHAR, 'Body' VARCHAR, 'BodyLength' INTEGER, 'ContentType' VARCHAR, 'CreatedById' VARCHAR, 'Description' VARCHAR, 'DeveloperName' VARCHAR, 'FolderId' VARCHAR, 'Id' VARCHAR, 'IsBodySearchable' BOOL, 'IsDeleted' BOOL, 'IsInternalUseOnly' BOOL, 'IsPublic' BOOL, 'Keywords' TEXT, 'LastModifiedById' VARCHAR, 'LastModifiedDate' DATETIME, 'Name' VARCHAR, 'NamespacePrefix' VARCHAR, 'SystemModstamp' VARCHAR, 'Type' VARCHAR)"];
    [self createTemporaryTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS  ProductImage ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0), 'productId' VARCHAR, 'productImage' VARCHAR)"];
    [self createTemporaryTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS  SFSignatureData ('record_Id' VARCHAR,'object_api_name' VARCHAR,'signature_data' TEXT,'sig_Id' TEXT ,'WorkOrderNumber' VARCHAR, 'sign_type' VARCHAR)"];
    [self createTemporaryTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS UserImages ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0), 'username' VARCHAR,'userimage' BLOB)"];
    [self createTemporaryTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS  trobleshootdata ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0),'ProductId' VARCHAR, 'ProductName' VARCHAR, 'Product_Doc' BLOB, 'DocId' VARCHAR, 'prod_manual_Id' VARCHAR, 'prod_manual_name' VARCHAR, 'productmanbody' VARCHAR)"];
    [self createTemporaryTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFDataTrailer ('timestamp' DATETIME, 'local_id' INTEGER,'sf_id' VARCHAR, 'record_type' VARCHAR, 'operation' VARCHAR, 'object_name' VARCHAR, 'sync_flag' BOOL , 'parent_object_name'  VARCHAR ,'parent_local_id'  VARCHAR , 'record_sent')"];
    [self createTemporaryTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFDataTrailer_Temp ('timestamp' DATETIME, 'local_id' INTEGER,'sf_id' VARCHAR, 'record_type' VARCHAR, 'operation' VARCHAR, 'object_name' VARCHAR, 'sync_flag' BOOL , 'parent_object_name'  VARCHAR ,'parent_local_id'  VARCHAR , 'record_sent')"];
    [self createTemporaryTable:query];
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SYNC_HISTORY ('last_sync_time' DATETIME , 'sync_type' VARCHAR , 'request_id' VARCHAR , 'SYNC_STATUS' BOOL )"];
    [self createTemporaryTable:query];
    
   
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS sync_Records_Heap ('sf_id' VARCHAR, 'local_id' VARCHAR,'object_name' VARCHAR, 'sync_type' VARCHAR, 'json_record' VARCHAR , 'sync_flag' BOOL , 'record_type' VARCHAR)"];
    [self createTemporaryTable:query];
    
    query = [NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS sync_Record_Heap_Index ON sync_Records_Heap (sf_id ASC, local_id ASC, object_name ASC, sync_flag ASC)"];
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS LookUpFieldValue ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0), 'object_api_name' VARCHAR, 'Id' VARCHAR, 'value' VARCHAR)"];
    [self createTemporaryTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS Summary_PDF ('record_Id' VARCHAR,'object_api_name' VARCHAR, 'PDF_data' TEXT, 'WorkOrderNumber' VARCHAR, 'PDF_Id' VARCHAR, 'sign_type' VARCHAR, 'pdf_name' VARCHAR)"];
    [self createTemporaryTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS sync_error_conflict ('sf_id' VARCHAR, 'local_id' VARCHAR,'object_name' VARCHAR, 'record_type' VARCHAR ,'sync_type' VARCHAR ,'error_message' VARCHAR ,'operation_type' VARCHAR , 'error_type' VARCHAR , 'override_flag'  VARCHAR)"];
    [self createTemporaryTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS contact_images ('contact_Id' VARCHAR, 'contact_Image' VARCHAR)"];
    [self createTemporaryTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS internet_conflicts ('sync_type' VARCHAR, 'error_message' VARCHAR, 'operation_type' VARCHAR, 'error_type' VARCHAR)"];
    [self createTemporaryTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS meta_sync_status ('sync_status' VARCHAR)"];  
    [self createTemporaryTable:query];
    
    NSArray * tempTableArray = [NSArray arrayWithObjects:@"ChatterPostDetails",@"Document",@"ProductImage",@"SFSignatureData",@"UserImages",@"trobleshootdata",@"SFDataTrailer",@"SFDataTrailer_Temp",@"SYNC_HISTORY",@"sync_Records_Heap",@"LookUpFieldValue",@"Summary_PDF",@"sync_error_conflict", @"contact_images",@"internet_conflicts", @"meta_sync_status", nil];
    
    return tempTableArray;
}
-(void)populateDatabaseFromBackUp
{
    [appDelegate initWithDBName:DATABASENAME1 type:DATABASETYPE1];
     
    NSString * query1 = [NSString stringWithFormat:@"ATTACH DATABASE '%@' AS tempsfm",filepath];
    [self createTable:query1];
    
    
    NSMutableArray * objects = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    NSString * queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT object_api_name FROM SFObjectField"];
    
    sqlite3_stmt * objectStatement;
    
    NSString * object_api_name = @"";
    
    if ( synchronized_sqlite3_prepare_v2(tempDb, [queryStatement UTF8String],-1, &objectStatement, nil) == SQLITE_OK )
    {
        while(synchronized_sqlite3_step(objectStatement) == SQLITE_ROW)
        {
            char * field = (char *) synchronized_sqlite3_column_text(objectStatement,0);
            if ((field != nil) && strlen(field))
                object_api_name = [[NSString alloc] initWithUTF8String:field];
            [objects  addObject:object_api_name];
            
        }
    }
    
    for (NSString * tableName in objects)
    {
        if ([tableName isEqualToString:@"Case"])
            tableName = @"'Case'";
        
        NSString * field_api = @"";
        NSString * field_type = @"";
        
        NSString * query_field = @"";
        
        NSMutableArray * old_fieldType = [[NSMutableArray alloc] initWithCapacity:0];
        NSMutableArray * new_fieldType = [[NSMutableArray alloc] initWithCapacity:0];
        
        sqlite3_stmt * stmt;
        
        NSString * query = [NSString stringWithFormat:@"PRAGMA table_info (%@)", tableName];
        
        
        if ( synchronized_sqlite3_prepare_v2(tempDb, [query UTF8String],-1, &stmt, nil) == SQLITE_OK )
        {
            while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
            {
                char * field = (char *) synchronized_sqlite3_column_text(stmt,1);
                if ((field != nil) && strlen(field))
                    field_api = [[NSString alloc] initWithUTF8String:field];
                
                
                char * type = (char *) synchronized_sqlite3_column_text(stmt,2);
                if ((type != nil) && strlen(type))
                    field_type = [[NSString alloc] initWithUTF8String:type];
                
                NSDictionary * dict = [NSDictionary dictionaryWithObject:field_type forKey:field_api];
                NSDictionary * _dict = [NSDictionary dictionaryWithDictionary:dict];
                [old_fieldType addObject:_dict];
            }
        }
        synchronized_sqlite3_finalize(stmt);
        query = [NSString stringWithFormat:@"PRAGMA table_info (%@)", tableName];
        
        
        if ( synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String],-1, &stmt, nil) == SQLITE_OK )
        {
            while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
            {
                char * field = (char *) synchronized_sqlite3_column_text(stmt,1);
                if ((field != nil) && strlen(field))
                    field_api = [[NSString alloc] initWithUTF8String:field];
                
                
                char * type = (char *) synchronized_sqlite3_column_text(stmt,2);
                if ((type != nil) && strlen(type))
                    field_type = [[NSString alloc] initWithUTF8String:type];
                
                NSDictionary * dict = [NSDictionary dictionaryWithObject:field_type forKey:field_api];
                NSDictionary * _dict = [NSDictionary dictionaryWithDictionary:dict];
                [new_fieldType addObject:_dict];
            }
        }
        
        synchronized_sqlite3_finalize(stmt);
        
        for (NSDictionary * old_dict in old_fieldType)
        {
            NSArray * old_keys = [old_dict allKeys];
            NSString * old_value = [old_keys objectAtIndex:0];
            
            for (NSDictionary * new_dict in new_fieldType)
            {
                NSArray * new_keys = [new_dict allKeys];
                NSString * new_value = [new_keys objectAtIndex:0];
                
                if ([old_value isEqualToString:new_value])
                {
                    NSString * old_type = [old_dict objectForKey:old_value];
                    NSString * new_type = [new_dict objectForKey:new_value];
                    
                    if ([old_type isEqualToString:new_type])
                    {
                        if ([query_field length] > 0)
                        {
                            query_field = [query_field stringByAppendingString:@", "];
                        }
                        query_field = [query_field stringByAppendingString:old_value];
                    }
                    
                }
            }            
            
        }
        NSString * finalQuery = [NSString stringWithFormat:@"INSERT INTO %@ (%@) SELECT %@ FROM tempsfm.%@",tableName,query_field,query_field,tableName];
        NSLog(@"%@",finalQuery);
        [self createTable:finalQuery];
        
    }
    //Radha 2012june08
    
    NSArray * tempArray = [self createTempTableForSummaryAndTroubleShooting];
    
    
    for (NSString * table in tempArray)
    {
        NSString * temp_query = [NSString stringWithFormat:@"INSERT INTO %@ SELECT * FROM tempsfm.%@", table, table];
        [self createTable:temp_query];
    }
    
}
- (void)deleteDatabase:(NSString *)databaseName
{
    NSError *error; 
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",databaseName,DATABASETYPE1]];
    
    [fileManager removeItemAtPath:fullPath error:&error];
    
    NSLog(@"database removed");
}

- (void) removecache
{
    if ((appDelegate.wsInterface.processDictionary != nil) && [appDelegate.wsInterface.processDictionary count] > 0)
    {
        appDelegate.wsInterface.processDictionary = nil;
        [appDelegate.wsInterface.processDictionary release];
        appDelegate.wsInterface.processDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    
    if ((appDelegate.wsInterface.objectDefinitions != nil) && [appDelegate.wsInterface.objectDefinitions count] > 0)
    {
        appDelegate.wsInterface.objectDefinitions = nil;
        [appDelegate.wsInterface.objectDefinitions release];
        appDelegate.wsInterface.objectDefinitions = [[NSMutableArray alloc] initWithCapacity:0];
    }
    if ((appDelegate.wsInterface.object != nil) && [appDelegate.wsInterface.object count] > 0)
    {
        appDelegate.wsInterface.object = nil;
        [appDelegate.wsInterface.object release];
        appDelegate.wsInterface.object = [[NSMutableArray alloc] initWithCapacity:0];
    }
    if ((appDelegate.wsInterface.picklistObject != nil) && [appDelegate.wsInterface.picklistObject count] > 0)
    {
        appDelegate.wsInterface.picklistObject = nil;
        [appDelegate.wsInterface.picklistObject release];
        appDelegate.wsInterface.picklistObject = [[NSMutableArray alloc] initWithCapacity:0];
    }
    if ((appDelegate.wsInterface.picklistField != nil) && [appDelegate.wsInterface.picklistField count] > 0)
    {
        appDelegate.wsInterface.picklistField = nil;
        [appDelegate.wsInterface.picklistField release];
        appDelegate.wsInterface.picklistField = [[NSMutableArray alloc] initWithCapacity:0];
    }
    if ((appDelegate.wsInterface.picklistValues != nil) && [appDelegate.wsInterface.picklistValues count] > 0)
    {
        appDelegate.wsInterface.picklistValues = nil;
        [appDelegate.wsInterface.picklistValues release];
        appDelegate.wsInterface.picklistValues = [[NSMutableArray alloc] initWithCapacity:0];
    }
    if ((appDelegate.wsInterface.pageUiHistory != nil) && [appDelegate.wsInterface.pageUiHistory count] > 0)
    {
        appDelegate.wsInterface.pageUiHistory = nil;
        [appDelegate.wsInterface.pageUiHistory release];
        appDelegate.wsInterface.pageUiHistory = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    
}

#pragma Mark to get loggedInUserId

- (NSString *)getLoggedInUserId:(NSString *)username
{
    NSMutableString * query = [NSMutableString stringWithFormat:@"SELECT Id FROM User WHERE Username = '%@'", username];
    
    sqlite3_stmt * stmt;
    
    NSString * queryStatement = @"";    
    const char * _query = [query UTF8String];
    
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, _query,-1, &stmt, nil) == SQLITE_OK )
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char *field1 = (char *) synchronized_sqlite3_column_text(stmt,COLUMN_1);
            if ((field1 != nil) && strlen(field1))
            {
                NSString *field1Str = [[NSString alloc] initWithUTF8String:field1];
                queryStatement = [NSString stringWithFormat:@"%@",field1Str];
            }
        }
    }
    synchronized_sqlite3_finalize(stmt);
    
    return queryStatement;
}

# pragma end


-(NSString *)getValueForRecordtypeId:(NSString *)recordtypeId object_api_name:(NSString *)object_api_name
{
    NSMutableString * query = [NSMutableString stringWithFormat:@"SELECT recordtypename FROM SFRTPicklist where object_api_name = '%@' and recordtypeid = '%@'", object_api_name, recordtypeId];
    
    sqlite3_stmt * stmt;
    
    NSString * value = @"";    
    const char * _query = [query UTF8String];
    
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, _query,-1, &stmt, nil) == SQLITE_OK )
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char *field1 = (char *) synchronized_sqlite3_column_text(stmt,COLUMN_1);
            if ((field1 != nil) && strlen(field1))
            {
                NSString *field1Str = [[NSString alloc] initWithUTF8String:field1];
                value = [NSString stringWithFormat:@"%@",field1Str];
            }
        }
    }
    synchronized_sqlite3_finalize(stmt);
    
    return value;
}

//RADHA 10th April 
#pragma mark - PURGING

- (NSMutableArray *) getAllTheRecordIdsFromEvent
{
    NSString * queryStatement = [NSString stringWithFormat:@"SELECT WhatId FROM Event"];
    
    NSMutableArray * recordId = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    NSString * whatId = @"";
    
    sqlite3_stmt * statement;
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            char * _id = (char *) synchronized_sqlite3_column_text(statement,COLUMN_1);
            if ((_id != nil) && strlen(_id))
            {
                whatId = [NSString stringWithUTF8String:_id];
                [recordId addObject:whatId];
            }
        }
    }
    synchronized_sqlite3_finalize(statement);
    
    return recordId;
    
}

- (NSMutableArray *) checkForTheObjectWithRecordId:(NSMutableArray *)recordId
{
    NSMutableArray * objectNames = [self retreiveObjectNames];
    
    NSMutableDictionary * detail_dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    NSMutableArray * mappingArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSString * name = @"";
    
    BOOL flag = FALSE;
    
    for (NSString * _id in recordId)
    {
        for (name in objectNames)
        {
            flag = [self doesObjectExistsForEventID:name _Id:_id];
            
            if (flag)
                break;
            else
                continue;
        }
        if ((name != nil) && (_id != nil))
            [detail_dict setObject:name forKey:_id];
    }
    
    NSArray * allVaues = [detail_dict allValues];
    
    
    NSString * str = @"";
    NSString * str1 = @"";
    for (int i = 0; i < [allVaues count];)
    {   
        str = [allVaues objectAtIndex:i];
        NSArray * array = [[NSArray alloc] init];
        NSDictionary * dict;
        
        if (i == 0)
        {
            array = [detail_dict allKeysForObject:str];
            dict = [NSDictionary dictionaryWithObject:array forKey:str];
            [mappingArray addObject:dict];
            [array release];
            [detail_dict removeObjectsForKeys:array];
            allVaues = [detail_dict allValues];
            str1 = str;
            i = 0;
        }
               
    }
    return mappingArray;
}


- (NSMutableArray *) retreiveObjectNames
{
    NSString * queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT object_api_name FROM SFObjectField"];
    
    NSMutableArray * objectNames = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    sqlite3_stmt * statement;
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW) 
        {
            char * _name = (char *)synchronized_sqlite3_column_text(statement, 0);
            
            if ((_name != nil) && (strlen(_name)))
            {
                NSString * name = [NSString stringWithUTF8String:_name];
                [objectNames addObject:name];
            }
        }
    }
    sqlite3_finalize(statement);
    
    return objectNames;
}

- (BOOL) doesObjectExistsForEventID:(NSString *)object _Id:(NSString *)recordId
{
    NSString * queryStatement = [NSString stringWithFormat:@"SELECT COUNT(*) FROM '%@' WHERE Id = '%@'", object, recordId];
    
    int count = 0;
    
    sqlite3_stmt * statement;
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW) 
        {
            count = synchronized_sqlite3_column_int(statement, 0);
        }
    }
    
    if (count)
        return TRUE;
    else
        return FALSE;
    
}


- (NSMutableArray *) getAllTheNewEventsFromSynCRecordHeap
{
    NSMutableArray * recordIds = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    NSString * queryStatement = [NSString stringWithFormat:@"SELECT json_record FROM sync_Records_Heap where object_name = 'Event' and sync_flag = 'true'"];
    
    
    if (parser == nil)
        parser = [[SBJsonParser alloc] init];
    
    NSString * jsonRecord = @"";
    
    sqlite3_stmt * statement;
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW) 
        {
            char * record = (char *) synchronized_sqlite3_column_text(statement, 0);
            
            if ((record != nil) && (strlen(record)))
            {
                jsonRecord = [NSString stringWithUTF8String:record];
                
                NSDictionary * dict = [parser objectWithString:jsonRecord];
                
                [recordIds addObject:([dict objectForKey:@"WhatId"] != nil)?[dict objectForKey:@"WhatId"]:@""];
            }
                
        }
    }
    return recordIds;
}


- (void) removeIdExistsInIntialEventMappingArray
{
    for (NSDictionary * dict in appDelegate.newEventMappinArray)
    {
        NSArray * allKeys = [dict allKeys];
        
        NSString * str = [allKeys objectAtIndex:0];
        
        NSArray * allValues = [dict allValues];
                
        for (NSDictionary * dict1 in appDelegate.initialEventMappinArray)
        {
            NSArray * allInitialKeys = [dict1 allKeys];
            
            NSString * value = [allInitialKeys objectAtIndex:0];
            
            if ([value isEqualToString:str])
            {                
                NSMutableArray * initialValues = (NSMutableArray *) [dict1 allValues];
                
                for (NSString * key in allValues) 
                {
                    if ([initialValues containsObject:key])
                    {
                        [initialValues removeObject:key];
                    }
                }
                break;
            }
            else
                continue;            
        }
    }

}

- (NSString *) getDateToDeleteEventsAndTask:(NSTimeInterval)Value
{
    NSDate * today = [NSDate date];
    
    NSDateFormatter * formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [formatter setTimeZone:gmt];
    
    
    NSDate * previousDate = [today dateByAddingTimeInterval:(-Value * 24 * 60 * 60)];
    
    NSString * currentDate = [formatter stringFromDate:previousDate];
    
    currentDate = [currentDate stringByReplacingCharactersInRange:NSMakeRange(11, 8) withString:@"00:00:00"];
    
    return currentDate;
}

- (void) purgingDataOnSyncSettings:(NSString *)Date tableName:(NSString *)tableName
{
    
    NSString * column = @"";
    
    if ([tableName isEqualToString:@"Event"])
        column = @"EndDateTime";
    else
        column = @"ActivityDate";

    NSString * queryStatement = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ <= '%@'", tableName, column, Date];
    
    char * err;
    
    if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        NSLog(@"Purging Failed to delete");
    }
    
}
#pragma mark -End


#pragma mark - FULL DATA SYNC
- (BOOL) startEventSync
{
    
    NSString * event_sync = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_events];
    
    BOOL retVal = TRUE;
    NSLog(@"SAMMAN DataSync WS Start: %@", [NSDate date]);
    appDelegate.wsInterface.didOpComplete = FALSE;
    
    [appDelegate.wsInterface dataSyncWithEventName:EVENT_SYNC eventType:SYNC requestId:@""];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, YES))
    {
        if (!appDelegate.isInternetConnectionAvailable)
            break;
        
        if (appDelegate.wsInterface.didOpComplete == TRUE)
        {
            break; 
        }
        
        retVal = [appDelegate pingServer];
        if(retVal == NO)
        {
            break;
        }

    }
    
    if(retVal == NO)
    {       
        //appDelegate.SyncStatus = SYNC_RED;
        
        [appDelegate setSyncStatus:SYNC_RED];
        //[appDelegate.wsInterface.refreshSyncButton showSyncStatusButton];
        //[appDelegate.wsInterface.refreshModalStatusButton showModalSyncStatus];
        //[appDelegate.wsInterface.refreshSyncStatusUIButton showSyncUIStatus];
        
        [appDelegate.calDataBase insertIntoConflictInternetErrorWithSyncType:event_sync];
        appDelegate.internet_Conflicts = [appDelegate.calDataBase getInternetConflicts];
        [appDelegate.reloadTable ReloadSyncTable];
        if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
            [MyPopoverDelegate performSelector:@selector(throwException)];
        return FALSE;
    }

    
    if (!appDelegate.isInternetConnectionAvailable)
    {
        //appDelegate.SyncStatus = SYNC_RED;
        
        [appDelegate setSyncStatus:SYNC_RED];
        //[appDelegate.wsInterface.refreshSyncButton showSyncStatusButton];
        //[appDelegate.wsInterface.refreshModalStatusButton showModalSyncStatus];
        //[appDelegate.wsInterface.refreshSyncStatusUIButton showSyncUIStatus];
        
        [appDelegate.calDataBase insertIntoConflictInternetErrorWithSyncType:event_sync];
         appDelegate.internet_Conflicts = [appDelegate.calDataBase getInternetConflicts];
        [appDelegate.reloadTable ReloadSyncTable];
        if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
            [MyPopoverDelegate performSelector:@selector(throwException)];
        return FALSE;
    }
    
    appDelegate.Incremental_sync_status = INCR_STARTS;
    
    [appDelegate.wsInterface PutAllTheRecordsForIds];
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, YES))
    {
        if (!appDelegate.isInternetConnectionAvailable)
            break;
        
        if (appDelegate.Incremental_sync_status == PUT_RECORDS_DONE)
            break; 
        retVal = [appDelegate pingServer];
        if(retVal == NO)
        {
            break;
        }
    }
    
    if(retVal == NO)
    {
        //appDelegate.SyncStatus = SYNC_RED;
        [appDelegate.calDataBase insertIntoConflictInternetErrorWithSyncType:event_sync];
        
        [appDelegate setSyncStatus:SYNC_RED];
        //[appDelegate.wsInterface.refreshSyncButton showSyncStatusButton];
        //[appDelegate.wsInterface.refreshModalStatusButton showModalSyncStatus];
        //[appDelegate.wsInterface.refreshSyncStatusUIButton showSyncUIStatus];
        appDelegate.internet_Conflicts = [appDelegate.calDataBase getInternetConflicts];
        [appDelegate.reloadTable ReloadSyncTable];
        if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
            [MyPopoverDelegate performSelector:@selector(throwException)];
        return FALSE;
    }

    
    if (!appDelegate.isInternetConnectionAvailable)
    {
        //appDelegate.SyncStatus = SYNC_RED;
        
        [appDelegate setSyncStatus:SYNC_RED];
        //[appDelegate.wsInterface.refreshSyncButton showSyncStatusButton];
        //[appDelegate.wsInterface.refreshModalStatusButton showModalSyncStatus];
        //[appDelegate.wsInterface.refreshSyncStatusUIButton showSyncUIStatus];

        [appDelegate.calDataBase insertIntoConflictInternetErrorWithSyncType:event_sync];
        appDelegate.internet_Conflicts = [appDelegate.calDataBase getInternetConflicts];
        [appDelegate.reloadTable ReloadSyncTable];
        if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
            [MyPopoverDelegate performSelector:@selector(throwException)];
        return FALSE;
    }
    
    
    [appDelegate.databaseInterface updateSyncRecordsIntoLocalDatabase];
    
    
    return TRUE;
}

- (void) copyMetaTableInToSfm:(NSMutableArray *)metaTable
{
    for (NSString * objectName in metaTable)
    {
        NSString * query = [self retrieveQuery:objectName sqlite:tempDb];
        [self createTable:query];
    }
    
    NSString * query1 = [NSString stringWithFormat:@"ATTACH DATABASE '%@' AS tempSfm",filepath];
    [self createTable:query1];
    
    //Here we fill up the tables with data  
    for (NSString * objectName in metaTable)
    {
        if ([objectName isEqualToString:@"Case"])
            objectName = @"'Case'";
        query1 = [NSString stringWithFormat:@"INSERT INTO %@ SELECT * FROM tempSfm.%@", objectName, objectName];
        [self createTable:query1];
    }

    
}


- (NSMutableArray *) retreiveDataObjectTable
{
    NSMutableArray * array = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    NSString * queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT object_api_name FROM SFObjectField"];

    sqlite3_stmt * stmt;
    
    if (sqlite3_prepare_v2(tempDb, [queryStatement UTF8String], -1, &stmt, NULL) == SQLITE_OK){
        
        while (synchronized_sqlite3_step(stmt) == SQLITE_ROW) 
        {
            char * _object = (char *)sqlite3_column_text(stmt, 0);
            
            if (_object != nil && strlen(_object))
                [array addObject:[NSString stringWithUTF8String:_object]];
        }
        
    }
    
    sqlite3_finalize(stmt);
    
    return array;
    
}

#pragma mark - END

#pragma mark - Incremental Meta And Event
- (void) callIncrementalMetasync
{
    if (metaSyncPopover == nil)
        metaSyncPopover = [[PopoverButtons alloc] init];
    
    [metaSyncPopover startSyncConfiguration];
    
}

- (void) scheduleEventSync
{
    if (metaSyncPopover == nil)
        metaSyncPopover = [[PopoverButtons alloc] init];
    
    [metaSyncPopover startSyncEvents];
    
}
#pragma mark - END

- (void) clearTempDatabase
{
    sqlite3_stmt *stmt;
    NSMutableArray * tables = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    NSString * queryStatemnt = [NSString stringWithFormat:@"SELECT * FROM sqlite_master WHERE type = 'table'"];
    
    if (synchronized_sqlite3_prepare_v2(tempDb, [queryStatemnt UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(stmt) == SQLITE_ROW) 
        {
            char * _table = (char *) synchronized_sqlite3_column_text(stmt, 1);
            
            if ((_table != nil) && strlen(_table))
            {
                NSString * table_name = [NSString stringWithUTF8String:_table];
                if ((![table_name isEqualToString:@"sqlite_sequence"]))
                    [tables addObject:table_name];
            }
            
        }
    }
    
    synchronized_sqlite3_finalize(stmt);
    
    
    char * err;
    
    for (int i = 0; i < [tables count]; i++)
    {
        queryStatemnt = [NSString stringWithFormat:@"DROP TABLE '%@'", [tables objectAtIndex:i]];
        if (synchronized_sqlite3_exec(tempDb, [queryStatemnt UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
            if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
                [MyPopoverDelegate performSelector:@selector(throwException)];
            NSLog(@"Failed to drop");
            
        }
        
    }    

}

@end
