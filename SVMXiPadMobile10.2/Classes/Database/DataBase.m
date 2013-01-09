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
extern void SVMXLog(NSString *format, ...);

@implementation DataBase 

@synthesize dbFilePath;
@synthesize didInsertTable;
@synthesize MyPopoverDelegate;
@synthesize tempDb;
@synthesize didTechnicianLocationUpdated;
@synthesize didUserGPSLocationUpdated;
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
        SMLog(@"SFM_Search_Process Table Create Success");
    else
        SMLog(@"SFM_Search_Process Table Create Failed");

    result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFM_Search_Objects ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0),'SVMXC__Module__c' VARCHAR,'SVMXC__ProcessID__c' VARCHAR,'SVMXC__Target_Object_Name__c' VARCHAR,'ProcessName' VARCHAR,'ProcessId' VARCHAR,'ObjectID' VARCHAR,'SVMXC__Advance_Expression__c' VARCHAR,'SVMXC__Name__c' VARCHAR)"]];
    if(result == YES)
        SMLog(@"SFM_Search_Objects Table Create Success");
    else
        SMLog(@"SFM_Search_Objects Table Create Failed");

    result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFM_Search_Field ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0), 'Id' VARCHAR,'SVMXC__Expression_Rule__c' VARCHAR,'SVMXC__Field_Name__c' VARCHAR,'SVMXC__Object_Name2__c' VARCHAR,'SVMXC__Search_Object_Field_Type__c' VARCHAR,'ObjectId' VARCHAR)"]];
    
    if(result == YES)
        SMLog(@"SFM_Search_Field Table Create Success");
    else
        SMLog(@"SFM_Search_Field Table Create Failed");

    result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFM_Search_Filter_Criteria ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0), 'Id' VARCHAR,'SVMXC__Display_Type__c' VARCHAR,'SVMXC__Expression_Rule__c' VARCHAR,'SVMXC__Field_Name__c' VARCHAR,'SVMXC__Object_Name2__c' VARCHAR,'SVMXC__Operand__c' VARCHAR,'SVMXC__Operator__c' VARCHAR,'ObjectId' VARCHAR)"]];
    if(result == YES)
        SMLog(@"SFM_Search_Filter_Criteria Table Create Success");
    else
        SMLog(@"SFM_Search_Filter_Criteria Table Create Failed");
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
            NSString *process_data=[[processData objectAtIndex:k] objectForKey:key];
            process_data=[process_data  stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            [valueFields appendFormat:@"'%@'",process_data];
        }

        NSString  *queryStatement = [NSString stringWithFormat:@"INSERT INTO SFM_Search_Process (%@) VALUES (%@)",queryFields,valueFields ];
        
        char * err;
        if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
            if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
                [MyPopoverDelegate performSelector:@selector(throwException)];
            SMLog(@"Failed to insert");
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
        processName=[processName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        NSString *processId = [processDict objectForKey:@"Id"];
        NSArray *objectsArray = [processDict objectForKey:@"Objects"];
        SMLog(@"Process Name = %@ and Objects = %@",processName, objectsArray);
        NSString *str;
        for(int m=0; m<[objectsArray count]; m++)
        {
            NSDictionary *objectDict = [objectsArray objectAtIndex:m];
            SMLog(@"Object ID = %@",[objectDict objectForKey:@"Id"] );
             str= [objectDict  objectForKey:@"SVMXC__Advance_Expression__c"];
            SMLog(@"%@",str);
            if(![[objectDict  objectForKey:@"SVMXC__Advance_Expression__c"] isEqualToString:@"(null)"])
            {
                if(!(str ==NULL))
                {
                    str=[str stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                }
                else
                {
                    str=@"(null)";
                }
            
            }
            else
            {
                str=@"(null)";
            }
            NSString *targetObjectNameFull = [objectDict objectForKey:@"SVMXC__Target_Object_Name__c"];
            targetObjectNameFull= [targetObjectNameFull stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString *targetObjectName = [self getFieldLabelForApiName:targetObjectNameFull];
            targetObjectName=[targetObjectName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString * Name = [objectDict objectForKey:@"SVMXC__Name__c"];
            Name = [Name stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString * Module = [objectDict objectForKey:@"SVMXC__Module__c"];
            Module = [Module  stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            
            NSString  *queryStatement =  [NSString stringWithFormat:@"INSERT INTO SFM_Search_Objects ('SVMXC__Module__c','SVMXC__ProcessID__c','SVMXC__Target_Object_Name__c','ProcessName','ProcessId','ObjectId','SVMXC__Advance_Expression__c','SVMXC__Name__c') VALUES ('%@','%@','%@','%@','%@','%@','%@','%@')",Module,[objectDict objectForKey:@"SVMXC__ProcessID__c"],targetObjectName,processName,processId,[objectDict objectForKey:@"Id"] ,str,Name];
            
            char * err;
            if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
            {
                if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
                    [MyPopoverDelegate performSelector:@selector(throwException)];
                SMLog(@"Failed to insert data in table SFM_Search_Objects");
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
                    SMLog(@"Failed to insert data in table SFM_Search_Filter_Criteria or SFM_Search_Field");
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
            if ((name !=nil) && strlen(name))
                [processDict setObject:[NSString stringWithUTF8String:name] forKey:@"Name"] ;
            else
                [processDict setObject:@"" forKey:@"Name"] ;

            const char * description = (char *)synchronized_sqlite3_column_text(statement, 1);
            if ((description != nil) && strlen(description))
                [processDict setObject:[NSString stringWithUTF8String:description] forKey:@"SVMXC__Description__c"] ;
            else
                [processDict setObject:@"" forKey:@"SVMXC__Description__c"] ;

            const char * search_process_name = (char *)synchronized_sqlite3_column_text(statement, 2);
            if ((search_process_name != nil) && strlen(search_process_name))
                [processDict setObject:[NSString stringWithUTF8String:search_process_name] forKey:@"SVMXC__Name__c"] ;
            else
                [processDict setObject:@"" forKey:@"SVMXC__Name__c"] ;
            
            const char * processId = (char *)synchronized_sqlite3_column_text(statement, 3);
            if ((processId != nil) && strlen(processId))
                [processDict setObject:[NSString stringWithUTF8String:processId] forKey:@"Id"] ;
            else
                [processDict setObject:@"" forKey:@"Id"] ;

            
            /*
            sqlite3_stmt * objectStatement;
            NSMutableArray *objectArray = [[NSMutableArray alloc] init];
            if (synchronized_sqlite3_prepare_v2(appDelegate.db, [objectQuery UTF8String], -1, &objectStatement, NULL) == SQLITE_OK)
            {
                while (synchronized_sqlite3_step(objectStatement) == SQLITE_ROW)
                {
                    NSMutableDictionary *objectDict = [[NSMutableDictionary alloc] init];
                    const char * object_processid = (char *)synchronized_sqlite3_column_text(objectStatement, 0);
                    if ((object_processid != nil)&& strlen(object_processid))
                        [objectDict setObject:[NSString stringWithUTF8String:object_processid] forKey:@"ObjectId"] ;
                    else
                        [objectDict setObject:@"" forKey:@"ObjectId"] ;
                    
                    const char * object_name = (char *)synchronized_sqlite3_column_text(objectStatement, 1);
                    if ((object_name!=nil)&&strlen(object_name))
                        [objectDict setObject:[NSString stringWithUTF8String:object_name] forKey:@"ObjectName"] ;
                    else
                        [objectDict setObject:@"" forKey:@"ObjectName"] ;
                    
                    const char * object_Description = (char *)synchronized_sqlite3_column_text(objectStatement, 2);
                    if ((object_Description!=nil)&&strlen(object_Description))
                        [objectDict setObject:[NSString stringWithUTF8String:object_Description] forKey:@"ObjectDescription"] ;
                    else
                        [objectDict setObject:@"" forKey:@"ObjectDescription"] ;
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
             synchronized_sqlite3_finalize(objectStatement);
             
            [processDict setObject:objectArray forKey:@"Objects"];
            [objectArray release];
             */
            [configSettings addObject:processDict];
            [processDict release];
        }
    }
    
    synchronized_sqlite3_finalize(statement);
//    SMLog(@"Config Settings = %@",configSettings);
    return [configSettings autorelease];
}
- (NSArray *) getConfigurationForProcess:(NSString *) processName 
{
    sqlite3_stmt * objectStatement;
    NSString *objectQuery = [NSString stringWithFormat:@"SELECT ObjectId,SVMXC__Target_Object_Name__c,SVMXC__Name__c FROM SFM_Search_Objects where ProcessName = '%@'",processName];
    SMLog(@"Object Query = %@",objectQuery);
    NSMutableArray *objectArray = [[NSMutableArray alloc] init];
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [objectQuery UTF8String], -1, &objectStatement, NULL) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(objectStatement) == SQLITE_ROW)
        {
            NSMutableDictionary *objectDict = [[NSMutableDictionary alloc] init];
            const char * object_processid = (char *)synchronized_sqlite3_column_text(objectStatement, 0);
            if ((object_processid != nil)&& strlen(object_processid))
                [objectDict setObject:[NSString stringWithUTF8String:object_processid] forKey:@"ObjectId"] ;
            else
                [objectDict setObject:@"" forKey:@"ObjectId"] ;
            
            const char * object_name = (char *)synchronized_sqlite3_column_text(objectStatement, 1);
            if ((object_name!=nil)&&strlen(object_name))
                [objectDict setObject:[NSString stringWithUTF8String:object_name] forKey:@"ObjectName"] ;
            else
                [objectDict setObject:@"" forKey:@"ObjectName"] ;
            
            const char * object_Description = (char *)synchronized_sqlite3_column_text(objectStatement, 2);
            if ((object_Description!=nil)&&strlen(object_Description))
                [objectDict setObject:[NSString stringWithUTF8String:object_Description] forKey:@"ObjectDescription"] ;
            else
                [objectDict setObject:@"" forKey:@"ObjectDescription"] ;
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
    synchronized_sqlite3_finalize(objectStatement);
    
    return [objectArray autorelease];
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
    NSMutableArray *searchableArray = [dataForObject objectForKey:@"SearchableFields"];
    if(![searchableArray count]>0)
    {
        NSMutableDictionary *dictforSearchObject=[[NSMutableDictionary alloc]init];
        [dictforSearchObject setObject:object forKey:@"SVMXC__Object_Name2__c"];
        [dictforSearchObject setObject:[self getNameFiled:object] forKey:@"SVMXC__Field_Name__c"];
        [searchableArray addObject:dictforSearchObject];
    }
    NSDictionary *uiControlsValue=[dataForObject objectForKey:@"uiControls"];
    NSArray *displayArray = [dataForObject objectForKey:@"DisplayFields"];
    NSMutableArray *displayFieldsArray = [[NSMutableArray alloc] init];
    NSMutableArray *TableArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *tableArrayDict=[[NSMutableDictionary alloc]init];
    NSArray *criteriaArray = [dataForObject objectForKey:@"SearchCriteriaFields"];
    NSMutableArray *results = [[NSMutableArray alloc] init];
    NSMutableString *finalQuery = [[NSMutableString alloc] init];
    NSMutableArray* refrenceObjectAtIndex=[[NSMutableArray alloc]init ];
    NSMutableString *queryFields = [[NSMutableString alloc] init];
    NSMutableString *joinFields = [[NSMutableString alloc] init];
    NSDictionary *dict;
    NSString *objectId=[dataForObject  objectForKey:@"ObjectId"];
    NSMutableDictionary *dictforparsing=[[NSMutableDictionary alloc]init];
    NSDictionary *logicalParsingResult=[[NSDictionary alloc ]init];
    NSMutableArray *searchFieldsArr=[[NSMutableArray alloc]init];
    NSMutableString *customizeSearch=[[NSMutableString alloc]init];
    [dictforparsing setObject:object forKey:@"object"]; 
    int fieldsCount = 2;
    /*
    NSString *refrence_to=[self getReferencetoFiledForObject:[self getApiNameFromFieldLabel:[[displayArray objectAtIndex:0]objectForKey:@"SVMXC__Object_Name2__c"]] api_Name:[[displayArray objectAtIndex:0]objectForKey:@"SVMXC__Field_Name__c"]];
    if([refrence_to length]>0)
        [queryFields appendString:[NSString stringWithFormat:@"'%@'.Id",refrence_to]];
    else
     */
        [queryFields appendString:[NSString stringWithFormat:@"'%@'.Id",object]]; // Change it to 1st display field
  
    [queryFields appendString:@","];
    [queryFields appendString:[NSString stringWithFormat:@"'%@'.local_id",object]];
    for(int i=0; i<[displayArray count]; i++)
    {
        [queryFields appendString:@","];
        NSString *fieldName = [[displayArray objectAtIndex:i] objectForKey:@"SVMXC__Field_Name__c"];
        NSString *TableName = [[displayArray objectAtIndex:i] objectForKey:@"SVMXC__Object_Name2__c"];
        NSMutableArray *fieldArrayTogetassociatedtable=[[[NSMutableArray alloc]init]autorelease]; 
        NSString *ApifieldName = [self getApiNameFromFieldLabel:fieldName];
        [fieldArrayTogetassociatedtable addObject:ApifieldName];
        NSString *ApiTableName = [self getApiNameFromFieldLabel:TableName];
        [fieldArrayTogetassociatedtable addObject:ApiTableName];
        [queryFields appendFormat:@"'%@'.%@",ApiTableName,ApifieldName];
        for (int i=0; i<[fieldArrayTogetassociatedtable count]; i++)
        {
        
            NSMutableString * queryStatementIstable = [[NSMutableString alloc]initWithCapacity:0];
            queryStatementIstable = [NSMutableString stringWithFormat:@"SELECT name FROM sqlite_master WHERE type='table' AND name='%@'",[fieldArrayTogetassociatedtable objectAtIndex:i]];    
            sqlite3_stmt * labelstmt;
            const char *selectStatement = [queryStatementIstable UTF8String];
            char *fieldIsTable=nil;        
            if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &labelstmt, nil) == SQLITE_OK )
            {
                if(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW)
                {
                    fieldIsTable = (char *) synchronized_sqlite3_column_text(labelstmt,0);
                       
                }
            }
            if(!(fieldIsTable != nil &&strlen(fieldIsTable)))
            {
                sqlite3_stmt * labelstmtGetTableName;
                NSMutableString * queryStatementGetTableName= [[NSMutableString alloc]initWithCapacity:0];
                queryStatementGetTableName = [NSMutableString stringWithFormat:@"SELECT reference_to FROM SFReferenceTo where object_api_name='%@' and field_api_name='%@'",object,[fieldArrayTogetassociatedtable objectAtIndex:i]];
                const char *selectStatementGetTableName = [queryStatementGetTableName UTF8String];
                char *TableName=nil;   
                NSString *strTableName=@"";
                if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatementGetTableName,-1, &labelstmtGetTableName, nil) == SQLITE_OK )
                {
                    if(synchronized_sqlite3_step(labelstmtGetTableName) == SQLITE_ROW)
                    {
                        TableName=(char *) synchronized_sqlite3_column_text(labelstmtGetTableName,0);
                        if(TableName !=nil && strlen(TableName))
                        {
                            strTableName=[NSString stringWithFormat:@"%s",TableName];
                        }
                    }
                }
                synchronized_sqlite3_finalize(labelstmtGetTableName);
                if([strTableName length]>0)
                {
                    if(![TableArray containsObject:strTableName]&& [strTableName length]>0)
                    {
                        [TableArray addObject:strTableName];
                         NSMutableArray * arry = [[NSMutableArray alloc] initWithCapacity:0];
                        [arry addObject:ApifieldName];
                        [tableArrayDict setObject:arry forKey:strTableName ];
                    }
                    else
                    {
                        NSMutableArray * array =  [tableArrayDict objectForKey:strTableName];
                        [array addObject:ApifieldName];
                    }
                }
                
            }
            if((fieldIsTable != nil &&strlen(fieldIsTable))&& [ApiTableName length] > 0)
            {
                if(![TableArray containsObject:ApiTableName] )
                {
                    [TableArray addObject:ApiTableName];
                    NSMutableArray * arry = [[NSMutableArray alloc] initWithCapacity:0];
                    [arry addObject:ApifieldName];
//                    [tableArrayDict setObject:ApifieldName forKey:ApiTableName ];
                    [tableArrayDict setObject:arry forKey:ApiTableName ];
                }
                else
                {
                    NSMutableArray * array =  [tableArrayDict objectForKey:ApiTableName];
                    [array addObject:ApifieldName];
                }
            }
        }
            [displayFieldsArray addObject:ApifieldName];

        fieldsCount++;
    }
    for(int i=0; i<[searchableArray count]; i++)
    {
        NSString *searchableField = [[searchableArray objectAtIndex:i] objectForKey:@"SVMXC__Field_Name__c"];
        NSString *searchableObject = [self getApiNameFromFieldLabel:[[searchableArray objectAtIndex:i] objectForKey:@"SVMXC__Object_Name2__c"]];
        if([searchableObject length] > 0)
        {
            if(![TableArray containsObject:searchableObject] )
            {
                [TableArray addObject:searchableObject];
                NSMutableArray * arry = [[NSMutableArray alloc] initWithCapacity:0];
                [arry addObject:searchableField];
    //            [tableArrayDict setObject:searchableField forKey:searchableObject ];
                [tableArrayDict setObject:arry forKey:searchableObject ];

            }
            else
            {
    //            NSArray *  allKeys = [tableArrayDict allKeys];
                NSMutableArray * array =  [tableArrayDict objectForKey:searchableObject];
                [array addObject:searchableField];
            
            }
        }
        searchableField = [self getApiNameFromFieldLabel:searchableField];
        NSMutableString * queryStatement1 = [[NSMutableString alloc]initWithCapacity:0];
        NSString *searchableFieldTableName=@"";
        queryStatement1 = [NSMutableString stringWithFormat:@"SELECT label FROM SFObjectField where object_api_name = '%@'and api_name='%@'",object,searchableField];    
        sqlite3_stmt * labelstmt;
        const char *selectStatement = [queryStatement1 UTF8String];
        char *field1=nil;        
        if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &labelstmt, nil) == SQLITE_OK )
        {
            if(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW)
            {
                field1 = (char *) synchronized_sqlite3_column_text(labelstmt,0);
                if((field1 !=nil) && strlen(field1))
                    searchableFieldTableName = [self getApiNameFromFieldLabel:[NSString stringWithFormat:@"%s",field1]];
                else
                    searchableFieldTableName = @"";
            }
        }
        
        NSMutableString * queryStatementIstable = [[NSMutableString alloc]initWithCapacity:0];
        queryStatementIstable = [NSMutableString stringWithFormat:@"SELECT name FROM sqlite_master WHERE type='table' AND name='%@'",searchableFieldTableName];    
        sqlite3_stmt * labelstmtIstable ;
        const char *selectStatementIstable  = [queryStatementIstable UTF8String];
        char *fieldIsTable=nil;        
        if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatementIstable ,-1, &labelstmtIstable , nil) == SQLITE_OK )
        {
            if(synchronized_sqlite3_step(labelstmtIstable) == SQLITE_ROW)
            {
                fieldIsTable = (char *) synchronized_sqlite3_column_text(labelstmtIstable,0);
                
            }
        }
        if(!(fieldIsTable != nil &&strlen(fieldIsTable)))
        {
            sqlite3_stmt * labelstmtGetTableName;
            NSMutableString * queryStatementGetTableName= [[NSMutableString alloc]initWithCapacity:0];
            queryStatementGetTableName = [NSMutableString stringWithFormat:@"SELECT reference_to FROM SFReferenceTo where object_api_name='%@' and field_api_name='%@'",object,searchableField];
            const char *selectStatementGetTableName = [queryStatementGetTableName UTF8String];
            char *TableName=nil;   
            NSString *strTableName=@"";
            if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatementGetTableName,-1, &labelstmtGetTableName, nil) == SQLITE_OK )
            {
                if(synchronized_sqlite3_step(labelstmtGetTableName) == SQLITE_ROW)
                {
                    TableName=(char *) synchronized_sqlite3_column_text(labelstmtGetTableName,0);
                    if(TableName !=nil && strlen(TableName))
                    {
                        strTableName=[NSString stringWithFormat:@"%s",TableName];
                        searchableFieldTableName=strTableName; 
                    }
                }
            }
            synchronized_sqlite3_finalize(labelstmtGetTableName);        
        }
        
        NSMutableString * queryStatementIstable2 = [[NSMutableString alloc]initWithCapacity:0];
        queryStatementIstable2 = [NSMutableString stringWithFormat:@"SELECT name FROM sqlite_master WHERE type='table' AND name='%@'",searchableFieldTableName];    
        sqlite3_stmt * labelstmtIstable2 ;
        const char *selectStatementIstable2  = [queryStatementIstable2 UTF8String];
        char *fieldIsTable2=nil;        
        if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatementIstable2 ,-1, &labelstmtIstable2 , nil) == SQLITE_OK )
        {
            if(synchronized_sqlite3_step(labelstmtIstable2) == SQLITE_ROW)
            {
                fieldIsTable2 = (char *) synchronized_sqlite3_column_text(labelstmtIstable2,0);
                
            }
        }
	    if((fieldIsTable2 != nil &&strlen(fieldIsTable2))||(fieldIsTable != nil &&strlen(fieldIsTable)))
           {
               if([searchableFieldTableName length] > 0)
               {
                   if(![TableArray containsObject:searchableFieldTableName] )
                   {
                       [TableArray addObject:searchableFieldTableName];
                       NSMutableArray * arry = [[NSMutableArray alloc] initWithCapacity:0];
                       [arry addObject:searchableField];
                       [tableArrayDict setObject:arry forKey:searchableFieldTableName ];
                   }
                   else
                   {
                       NSMutableArray * array =  [tableArrayDict objectForKey:searchableFieldTableName];
                       [array addObject:searchableField];
                       
                   }
               }

           }
        NSString * searchfield=[NSString stringWithFormat:@"'%@'.%@",[self getApiNameFromFieldLabel:[[searchableArray objectAtIndex:i] objectForKey:@"SVMXC__Object_Name2__c"]],searchableField];
        [searchFieldsArr addObject:searchfield];
        SMLog(@"%@",searchFieldsArr);
        if(![displayFieldsArray containsObject:searchableField])
        {
            [queryFields appendString:@","];
            [queryFields appendFormat:@"'%@'.%@",[self getApiNameFromFieldLabel:[[searchableArray objectAtIndex:i] objectForKey:@"SVMXC__Object_Name2__c"]],searchableField];
        }
        fieldsCount++;
    }
    [displayFieldsArray release];
    NSString *queryStatement;
    BOOL RecordExistForSearchField=FALSE;
    //for adding search field in the where clause
    for (int i=0; i<[searchFieldsArr count]; i++)
    {
        if(i !=0)
            [customizeSearch appendString:@" OR "];
        NSDictionary *name_field=[ self getNameFieldForRefrenceObject:[searchableArray objectAtIndex:i]];
        if([name_field count]>0)
        {
            //For Adding Name filed in search String
            [customizeSearch appendString:[NSString stringWithFormat:@"'%@'.%@",[name_field objectForKey:@"reference_to"],[name_field objectForKey:@"namefiled"]]];
            RecordExistForSearchField=[self isTableEmpty:[name_field objectForKey:@"reference_to"]];
            [customizeSearch appendString:@" LIKE "];
            NSString *strSearchCriteria=[self getSearchCriteriaStringFromUserData:[uiControlsValue objectForKey:@"searchCriteria"] withSearchString:[uiControlsValue objectForKey:@"searchString"]];
            [customizeSearch appendFormat:@"'%@'",strSearchCriteria];
        }
        else
        {
            
            [customizeSearch appendString:[searchFieldsArr objectAtIndex:i]];
            BOOL flag =[self isTableEmpty:[searchFieldsArr objectAtIndex:i]];
            if(flag)
            {
                RecordExistForSearchField = TRUE;
            }
            [customizeSearch appendString:@" LIKE "];
            NSString *strSearchCriteria=[self getSearchCriteriaStringFromUserData:[uiControlsValue objectForKey:@"searchCriteria"] withSearchString:[uiControlsValue objectForKey:@"searchString"]];
            [customizeSearch appendFormat:@"'%@'",strSearchCriteria];
                //getjoinfields Dict pass Table array and object
        }
    }
    if([criteriaArray count] == 0 )
    {
        NSMutableDictionary *dict_Join_field=[[NSMutableDictionary alloc]init ];
        [dict_Join_field setObject:TableArray forKey:@"TableArray"];
        [dict_Join_field setObject:tableArrayDict forKey:@"tableArrayDict"];
        [dict_Join_field setObject:object forKey:@"object"];
        joinFields=[self getJoinFields:dict_Join_field];
     if([joinFields length]>0)
     {
         if([customizeSearch length]>0)
         {
             if([[uiControlsValue objectForKey:@"searchString"] length]>0)
                 queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT %@ FROM '%@' %@ WHERE %@ LIMIT %@",queryFields,object,joinFields,customizeSearch,[uiControlsValue objectForKey:@"searchLimitString"]];
             else
                 queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT %@ FROM '%@' %@ LIMIT %@",queryFields,object,joinFields,[uiControlsValue objectForKey:@"searchLimitString"]];

         }
         else
             queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT %@ FROM '%@' %@",queryFields,object,joinFields];
     }
     else
     {
        if([customizeSearch length]>0)
        {
            if([[uiControlsValue objectForKey:@"searchString"] length]>0)
                queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT %@ FROM '%@' WHERE %@ LIMIT %@",queryFields,object,customizeSearch,[uiControlsValue objectForKey:@"searchLimitString"]];
            else
                queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT %@ FROM '%@' LIMIT %@",queryFields,object,[uiControlsValue objectForKey:@"searchLimitString"]];

        }
        else
            queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT %@ FROM '%@'",queryFields,object];
     }
    }
    else 
    {
 
     
        NSMutableString * conditionqueryStatement = [[NSMutableString alloc]initWithCapacity:0];
        conditionqueryStatement = [NSMutableString stringWithFormat:@"SELECT SVMXC__Advance_Expression__c,SVMXC__Target_Object_Name__c from SFM_Search_Objects where ObjectID='%@'",objectId];    
        sqlite3_stmt * conditionlabelstmt;
        const char *conditionselectStatement = [conditionqueryStatement UTF8String];
        char *fieldforCondition=nil,*TargetObject=nil;    
        NSString *Expression=@"",*strTargetObject=@""; 
        if ( synchronized_sqlite3_prepare_v2(appDelegate.db, conditionselectStatement,-1, &conditionlabelstmt, nil) == SQLITE_OK )
        {
            if(synchronized_sqlite3_step(conditionlabelstmt) == SQLITE_ROW)
            {
                fieldforCondition = (char *) synchronized_sqlite3_column_text(conditionlabelstmt,0);
                TargetObject = (char *) synchronized_sqlite3_column_text(conditionlabelstmt,1);
                if((fieldforCondition !=nil) && strlen(fieldforCondition))
                Expression=[NSString stringWithFormat:@"%s",fieldforCondition] ;
                if((TargetObject !=nil) && strlen(TargetObject))
                    strTargetObject=[NSString stringWithFormat:@"%s",TargetObject] ;
            }
        }
        SMLog(@"Adv Exp = %@",Expression);
        if(![Expression isEqualToString:@"(null)"])
        {
                SMLog(@"%@",Expression);
            int iTokenCount=-1;
            Expression=[Expression stringByReplacingOccurrencesOfString:@")" withString:@" ) "];
            Expression=[Expression stringByReplacingOccurrencesOfString:@"(" withString:@" ( "];
                NSMutableArray  *tokens = [[NSMutableArray alloc] init];
                NSMutableArray  *alltokens = [[NSMutableArray alloc] init];
                NSArray *logicalArray = [NSArray arrayWithObjects:@" AND ",@" OR ", nil];
                int index = 0;
                if([Expression rangeOfString:[logicalArray objectAtIndex:index]].length > 0)
                {    
                    NSArray *logicalTokens = [Expression componentsSeparatedByString:[logicalArray objectAtIndex:index]];
                    for(int i=0; i<[logicalTokens count]; i++)
                    {
                        NSString *token = [logicalTokens objectAtIndex:i];
                        if(i)
                            [tokens addObject:[logicalArray objectAtIndex:index]];
                        [tokens addObject:token];
                    }
                }
                SMLog(@"Tokens = %@",tokens);
                if([tokens count] == 0)
                {
                    [tokens addObject:Expression];
                }
                index++;
                for(NSString *data in tokens)
                {
                    if([data rangeOfString:[logicalArray objectAtIndex:index]].length > 0)
                    {   
                        NSArray *logicalTokens = [data componentsSeparatedByString:[logicalArray objectAtIndex:index]];
                        for(int i=0; i<[logicalTokens count]; i++)
                        {
                            NSString *token = [logicalTokens objectAtIndex:i];
                            if(i)
                                [alltokens addObject:[logicalArray objectAtIndex:index]];
                            [alltokens addObject:token];
                        }
                    }
                    else
                    {
                        [alltokens addObject:data];
                    }
                }
                [dictforparsing setObject:TableArray forKey:@"TableArray"];
                [dictforparsing setObject:tableArrayDict forKey:@"tableArrayDict"];
                [dictforparsing setObject:strTargetObject forKey:@"strTargetObject"];
                [dictforparsing setObject:criteriaArray forKey:@"criteriaArray"];
                SMLog(@"AllTokens = %@",alltokens);
                if(!([alltokens count]>0))
                {
                    alltokens=[NSString stringWithFormat:@"%@",Expression];
                    [dictforparsing setObject:finalQuery forKey:@"finalQuery"];
                    [dictforparsing setObject:alltokens forKey:@"token"];
                    logicalParsingResult= [self getupdatedToken:dictforparsing];
                    TableArray=[logicalParsingResult objectForKey:@"TableArray"];
                    tableArrayDict=[logicalParsingResult objectForKey:@"tableArrayDict"];
                    finalQuery=[logicalParsingResult objectForKey:@"finalQuery"];
                    [finalQuery appendString:@" COLLATE NOCASE"]; 
                }
                else
                {
                    for(NSString *token in alltokens)
                    {
                        if([token Contains:@" AND "]||([token Contains:@" OR "]))
                        {
                            [finalQuery appendFormat:@" %@ ",token];
                            continue;
                        }
                        iTokenCount++;
                        [dictforparsing setObject:[NSString stringWithFormat:@"%d",iTokenCount ] forKey:@"Count"];
                        [dictforparsing setObject:finalQuery forKey:@"finalQuery"];
                        [dictforparsing setObject:token forKey:@"token"];
                        logicalParsingResult= [self getupdatedToken:dictforparsing];
                        TableArray=[logicalParsingResult objectForKey:@"TableArray"];
                        tableArrayDict=[logicalParsingResult objectForKey:@"tableArrayDict"];
                        finalQuery=[logicalParsingResult objectForKey:@"finalQuery"];
                        [finalQuery appendString:@" COLLATE NOCASE"]; 

                    }
                    [alltokens release];
                    [tokens release];
                }
        }
        for(int j=0;j<[criteriaArray count]; j++)
        {
            NSString *fieldName=@"",*TableName=@"";
            dict = [criteriaArray objectAtIndex:j];
            NSString *displayType = [dict objectForKey:@"SVMXC__Display_Type__c"];
            if ([displayType isEqualToString:@"REFERENCE"]) 
            {
                [refrenceObjectAtIndex addObject:[NSString stringWithFormat:@"%d",j]];
                NSMutableString * queryStatement1 = [[NSMutableString alloc]initWithCapacity:0];
                queryStatement1 = [NSMutableString stringWithFormat:@"SELECT reference_to FROM SFObjectField where api_name='%@' and object_api_name='%@'",[dict objectForKey:@"SVMXC__Field_Name__c"],object];    
                sqlite3_stmt * labelstmt;
                const char *selectStatement = [queryStatement1 UTF8String];
                char *reference_to_field=nil;        
                if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &labelstmt, nil) == SQLITE_OK )
                {
                    if(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW)
                    {
                        reference_to_field = (char *) synchronized_sqlite3_column_text(labelstmt,0);
                        if((reference_to_field != nil) && strlen(reference_to_field))
                        TableName = [NSString stringWithFormat:@"%s",reference_to_field];

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
                            if((nameofObjectField !=nil)&&strlen(nameofObjectField))
                                fieldName = [NSString stringWithFormat:@"%s",nameofObjectField];

                        }
                    }
                
                    if ([TableName length]>0) 
                        TableName = [self getApiNameFromFieldLabel:TableName];
                    if(![TableArray containsObject:TableName]&& [TableName length] > 0 )
                    {
                        [TableArray addObject:TableName];
                        NSMutableArray * arry = [[NSMutableArray alloc] initWithCapacity:0];
                        [arry addObject:[dict objectForKey:@"SVMXC__Field_Name__c"]];
                        [tableArrayDict setObject:arry forKey:TableName];

                    }
                    else
                    {
                        NSMutableArray * array =  [tableArrayDict objectForKey:TableName];
                        [array addObject:[dict objectForKey:@"SVMXC__Field_Name__c"]];

                    }
 
                    synchronized_sqlite3_finalize(labelstmt);
                    synchronized_sqlite3_finalize(labelstmt2);
            }
        }
        NSMutableDictionary *dict_Join_field=[[NSMutableDictionary alloc]init ];
        [dict_Join_field setObject:TableArray forKey:@"TableArray"];
        [dict_Join_field setObject:tableArrayDict forKey:@"tableArrayDict"];
        [dict_Join_field setObject:object forKey:@"object"];
        joinFields=[self getJoinFields:dict_Join_field];

  
            
        if([finalQuery length] > 0)
        {
            if([customizeSearch length]>0)
            {
                if([[uiControlsValue objectForKey:@"searchString"] length]>0)
                    queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT %@ FROM '%@' %@ WHERE (%@) AND (%@) COLLATE NOCASE LIMIT %@",queryFields,object,joinFields,finalQuery,customizeSearch,[uiControlsValue objectForKey:@"searchLimitString"]];
                else
                    queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT %@ FROM '%@' %@ WHERE (%@) COLLATE NOCASE LIMIT %@",queryFields,object,joinFields,finalQuery,[uiControlsValue objectForKey:@"searchLimitString"]];

            }
            else
                queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT %@ FROM '%@' %@ WHERE (%@) COLLATE NOCASE LIMIT %@",queryFields,object,joinFields,finalQuery,[uiControlsValue objectForKey:@"searchLimitString"]];

        }
        else
        {
            if([customizeSearch length]>0)
            {
                if([[uiControlsValue objectForKey:@"searchString"] length]>0)
                    queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT %@ FROM '%@'%@ WHERE (%@) LIMIT %@",queryFields,object,joinFields,customizeSearch,[uiControlsValue objectForKey:@"searchLimitString"]];
                else
                    queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT %@ FROM '%@'%@ LIMIT %@",queryFields,object,joinFields,[uiControlsValue objectForKey:@"searchLimitString"]];
            }
            else
            queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT %@ FROM '%@'%@ LIMIT %@",queryFields,object,joinFields,[uiControlsValue objectForKey:@"searchLimitString"]];

        }

    }
    [queryFields release];
    sqlite3_stmt * statement;
    SMLog(@"Query = %@",queryStatement);
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            NSString *value=nil,*refrenceValue=nil;
            for(int j=0; j< fieldsCount; j++)
            {
                const char * _type = (char *)synchronized_sqlite3_column_text(statement, j);
                if ( !_type)
                {
                    _type = "";
                }
                value = [NSString stringWithUTF8String:_type];
                if(value == nil)
                {
                    value = @"";
                }
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
                        if([value length])
                        {
                            refrenceValue=[self getvalueforReference:object value:value];
                            if(refrenceValue)
                            {
                                [dict setObject:refrenceValue forKey:[NSString stringWithFormat:@"%@.%@",[object objectForKey:@"SVMXC__Object_Name2__c"],[object objectForKey:@"SVMXC__Field_Name__c"]]];
                            }
                            else
                            {
                                [dict setObject:value forKey:[NSString stringWithFormat:@"%@.%@",[object objectForKey:@"SVMXC__Object_Name2__c"],[object objectForKey:@"SVMXC__Field_Name__c"]]];
                            }
                            
                        }
                        else
                        {
                            [dict setObject:value forKey:[NSString stringWithFormat:@"%@.%@",[object 
                                                      objectForKey:@"SVMXC__Object_Name2__c"],[object 
                                                      objectForKey:@"SVMXC__Field_Name__c"]]];
                        }
                    }
                     else
                     {
                         int indexValue = j - [displayArray count] - 2;
                         NSString *object_name_2 = [[searchableArray objectAtIndex:indexValue ] objectForKey:@"SVMXC__Object_Name2__c"];
                         NSString *field_name = [[searchableArray objectAtIndex:indexValue ] objectForKey:@"SVMXC__Field_Name__c"];
                         NSString *key = [NSString stringWithFormat:@"%@.%@",object_name_2,field_name];
                         if(![[dict allKeys] containsObject:key])
                         {
                             refrenceValue=[self getvalueforReference:[searchableArray objectAtIndex:indexValue ]  value:value];
                             if(refrenceValue)
                             {
                                 [dict setObject:refrenceValue forKey:[NSString stringWithFormat:@"%@.%@",[[searchableArray objectAtIndex:indexValue ] objectForKey:@"SVMXC__Object_Name2__c"],[[searchableArray objectAtIndex:indexValue ] objectForKey:@"SVMXC__Field_Name__c"]]];
                             }
                             else
                             {
                                 [dict setObject:value forKey:[NSString stringWithFormat:@"%@.%@",[[searchableArray objectAtIndex:indexValue ] objectForKey:@"SVMXC__Object_Name2__c"],[[searchableArray objectAtIndex:indexValue ] objectForKey:@"SVMXC__Field_Name__c"]]]; 
                             }

                         }
                     }
                }
            }
            [results addObject:dict];
        }
    }
    synchronized_sqlite3_finalize(statement);
    return [results autorelease];
}
-(NSString*) getNameFiled:(NSString*)obejctName
{
    NSMutableString * queryStatementName = [[NSMutableString alloc]initWithCapacity:0];
    queryStatementName = [NSMutableString stringWithFormat:@"SELECT api_name FROM SFObjectField where name_field='TRUE' and object_api_name='%@'",obejctName];
    sqlite3_stmt * labelstmtName;
    NSString *fieldName=@"";
    const char *selectStatementName = [queryStatementName UTF8String];
    char *nameofObjectField;
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatementName,-1, &labelstmtName, nil) == SQLITE_OK )
    {
        if(synchronized_sqlite3_step(labelstmtName) == SQLITE_ROW)
        {
            nameofObjectField = (char *) synchronized_sqlite3_column_text(labelstmtName,0);
            if((nameofObjectField !=nil)&&strlen(nameofObjectField))
                fieldName = [NSString stringWithFormat:@"%s",nameofObjectField];
            
        }
    }
    synchronized_sqlite3_finalize(labelstmtName);
    return fieldName;
    
}
-(NSMutableString*)getJoinFields:(NSDictionary*)dict
{
    NSMutableArray *TableArray = [dict objectForKey:@"TableArray"];
    NSMutableString *joinFields = [[NSMutableString alloc] init];
	 NSMutableArray *arrayForApiName=[[[NSMutableArray alloc]init]autorelease];
   for (int i=0; i<[TableArray count]; i++)
   {
       NSMutableArray *arrApiName=[[[NSMutableArray alloc]init]autorelease];

        if(![[TableArray objectAtIndex:i]isEqual:[dict objectForKey:@"object"]])
        {
            sqlite3_stmt * labelstmtforlabel;
            NSMutableString * queryStatementforLabel= [[NSMutableString alloc]initWithCapacity:0];
            queryStatementforLabel = [NSMutableString stringWithFormat:@"SELECT label FROM SFObjectField where object_api_name ='%@'",[dict objectForKey:@"object"]];
            const char *selectStatementForlabel = [queryStatementforLabel UTF8String];
            char *label=nil;   
            NSString *strlabel=@"";
            NSMutableArray *labelForObject=[[NSMutableArray alloc]init];
            if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatementForlabel,-1, &labelstmtforlabel, nil) == SQLITE_OK )
            {
                while(synchronized_sqlite3_step(labelstmtforlabel) == SQLITE_ROW)
                {
                    label=(char *) synchronized_sqlite3_column_text(labelstmtforlabel,0);
                    if(label !=nil && strlen(label))
                    {
                        strlabel=[NSString stringWithFormat:@"%s",label];
                    }
                    [labelForObject addObject:strlabel];
                }
            }
            synchronized_sqlite3_finalize(labelstmtforlabel);
            
            char *apiName=nil,*type=nil,*relationshipName=nil,*reference_to=nil;   
            NSString *strapiName=@"",*strtype=@"",*strrelationshipName=@"",*strreference_to=@"";
            if([labelForObject containsObject: [self getFieldLabelForApiName:[TableArray objectAtIndex:i]]])
            {
                NSMutableString * queryStatement1 = [[NSMutableString alloc]initWithCapacity:0];
                queryStatement1 = [NSMutableString stringWithFormat:@"SELECT api_name,type,relationship_name,reference_to FROM SFObjectField where object_api_name = '%@'and label='%@'",[dict objectForKey:@"object"], [self getFieldLabelForApiName:[TableArray objectAtIndex:i]]];   
                const char *selectStatement = [queryStatement1 UTF8String];
                sqlite3_stmt * labelstmt;
                if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &labelstmt, nil) == SQLITE_OK )
                {
                    if(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW)
                    {
                        NSMutableDictionary *dictRefrenceFileds=[[[NSMutableDictionary alloc]init]autorelease];
                        apiName = (char *) synchronized_sqlite3_column_text(labelstmt,0);
                        if((apiName !=nil) && strlen(apiName))
                        {
                            strapiName=[NSString stringWithFormat:@"%s",apiName];
                            [dictRefrenceFileds setObject:strapiName forKey:@"apiName"];
                        }
                        type = (char *) synchronized_sqlite3_column_text(labelstmt,1);
                        if((type !=nil) && strlen(type))
                        {
                            strtype=[NSString stringWithFormat:@"%s",type];
                            [dictRefrenceFileds setObject:strtype forKey:@"type"];

                        }
                        relationshipName = (char *) synchronized_sqlite3_column_text(labelstmt,2);
                        if((relationshipName !=nil) && strlen(relationshipName))
                        {
                            strrelationshipName=[NSString stringWithFormat:@"%s",relationshipName];
                            [dictRefrenceFileds setObject:strrelationshipName forKey:@"relationshipName"];

                        }
                        reference_to =(char *) synchronized_sqlite3_column_text(labelstmt,3);
                        if((reference_to !=nil) && strlen(reference_to))
                        {
                            strreference_to=[NSString stringWithFormat:@"%s",reference_to];
                            [dictRefrenceFileds setObject:strreference_to forKey:@"reference_to"];

                        }
                        [arrApiName addObject:dictRefrenceFileds];
                    }
                }
                synchronized_sqlite3_finalize(labelstmt);
            }
            else
            {
                NSMutableString * queryStatement1 = [[NSMutableString alloc]initWithCapacity:0];
                /*queryStatement1 = [NSMutableString stringWithFormat:@"SELECT api_name,type,relationship_name,reference_to FROM SFObjectField where object_api_name = '%@'and reference_to='%@'and api_name='%@'",object, [self getApiNameFromFieldLabel:[TableArray objectAtIndex:i]],[tableArrayDict objectForKey:[self getApiNameFromFieldLabel:[TableArray objectAtIndex:i]]]]; */
               
                queryStatement1 = [NSMutableString stringWithFormat:@"SELECT api_name,type,relationship_name,reference_to FROM SFObjectField where object_api_name = '%@'and reference_to='%@'",[dict objectForKey:@"object"], [self getApiNameFromFieldLabel:[TableArray objectAtIndex:i]]];
                const char *selectStatement = [queryStatement1 UTF8String];
                sqlite3_stmt * labelstmt;
                if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &labelstmt, nil) == SQLITE_OK )
                {
                    while(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW)
                    {
                        NSMutableDictionary *dictRefrenceFileds=[[[NSMutableDictionary alloc]init]autorelease];
                        apiName = (char *) synchronized_sqlite3_column_text(labelstmt,0);
                        if((apiName !=nil) && strlen(apiName))
                        {
                            strapiName=[NSString stringWithFormat:@"%s",apiName];
                            [dictRefrenceFileds setObject:strapiName forKey:@"apiName"];
                        }
                        type = (char *) synchronized_sqlite3_column_text(labelstmt,1);
                        if((type !=nil) && strlen(type))
                        {
                            strtype=[NSString stringWithFormat:@"%s",type];
                            [dictRefrenceFileds setObject:strtype forKey:@"type"];
                            
                        }
                        relationshipName = (char *) synchronized_sqlite3_column_text(labelstmt,2);
                        if((relationshipName !=nil) && strlen(relationshipName))
                        {
                            strrelationshipName=[NSString stringWithFormat:@"%s",relationshipName];
                            [dictRefrenceFileds setObject:strrelationshipName forKey:@"relationshipName"];
                            
                        }
                        reference_to =(char *) synchronized_sqlite3_column_text(labelstmt,3);
                        if((reference_to !=nil) && strlen(reference_to))
                        {
                            strreference_to=[NSString stringWithFormat:@"%s",reference_to];
                            [dictRefrenceFileds setObject:strreference_to forKey:@"reference_to"];
                            
                        }
                        [arrayForApiName addObject:dictRefrenceFileds];
                    }
                }
                synchronized_sqlite3_finalize(labelstmt);
                if([arrayForApiName count]>0)
                {
                    NSString *objectApiName=[self getApiNameFromFieldLabel:[TableArray objectAtIndex:i]];
                    NSArray* refrence_to_array =[[dict objectForKey:@"tableArrayDict"] objectForKey:objectApiName];
                    for(int i=0;i<[refrence_to_array count];i++)
                    {
                        for (int j=0; j<[arrayForApiName count]; j++)
                        {
                            if([[[arrayForApiName objectAtIndex:j]objectForKey:@"apiName"] Contains:[refrence_to_array objectAtIndex:i]]&& [strtype isEqualToString:@"reference"])
                            {
                                [arrApiName addObject:[arrayForApiName objectAtIndex:j]];
                            }
                        }
                        
                    }
                    if(![arrApiName count]>0)
                        arrApiName=arrayForApiName;
                }
                

            }
            
            if([strtype isEqualToString:@"reference"])
            {
                [joinFields appendFormat:@" LEFT OUTER JOIN"];
                [joinFields appendFormat:@" '%@'",[TableArray objectAtIndex:i]];
                [joinFields appendFormat:@" ON"];
				
				if ([arrApiName count] > 0)
				{
					for (int join = 0; join < [arrApiName count]; join++)
					{
						NSDictionary * refDict = [arrApiName objectAtIndex:join];
						if (join == 0)
						{
							[joinFields appendFormat:@"('%@'.%@ = '%@'.Id",[dict objectForKey:@"object"],[refDict objectForKey:@"apiName"],[self getApiNameFromFieldLabel:[TableArray objectAtIndex:i]]];
						}
						else 
						{
                            if([[refDict objectForKey:@"type"] isEqualToString:@"reference"])
                            {
                                [joinFields appendFormat:@" or '%@'.%@ = '%@'.Id",[dict objectForKey:@"object"],[refDict objectForKey:@"apiName"],[self getApiNameFromFieldLabel:[TableArray objectAtIndex:i]]];
                            }
						}
						
						
					}
                    [joinFields appendFormat:@" )"];
				}
               
            }
        }
   }
    return joinFields;
}

- (NSString *) getDataTypeFor:(NSString *)objectName inArray:(NSArray *)dataArray
{
    NSString *dataType = nil;
    for(NSDictionary *dict in dataArray)
    {
        NSString *objName = [dict objectForKey:@"SVMXC__Field_Name__c"];
        if([objName isEqualToString:objectName])
        {
            dataType = [dict objectForKey:@"SVMXC__Display_Type__c"];
            break;
        }
    }
    return dataType;
}
-(NSString*)getReferencetoFiledForObject:(NSString*)objectName api_Name:(NSString*)api_name
{
    NSString *strRefrence_to=@"";
    NSMutableString * queryStatement1 = [[NSMutableString alloc]initWithCapacity:0];
    queryStatement1 = [NSMutableString stringWithFormat:@"SELECT reference_to FROM SFObjectField where object_api_name = '%@'and api_name='%@'",objectName,api_name];
    sqlite3_stmt * labelstmt;
    const char *selectStatement = [queryStatement1 UTF8String];
    char *refrence_to=nil;
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &labelstmt, nil) == SQLITE_OK )
    {
        if(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW)
        {
            refrence_to = (char *) synchronized_sqlite3_column_text(labelstmt,0);
        }
    }
    if((refrence_to != nil)&& strlen(refrence_to))
        strRefrence_to=[NSString stringWithFormat:@"%s",refrence_to];
    else
        strRefrence_to=@"";
    
    return strRefrence_to;
}

- (NSString *) getSearchCriteriaStringFromUserData:(NSString *)criteriaString withSearchString:searchString
{
    NSString *resultSearchString = nil;
    SMLog(@"Criteria String = :%@:",criteriaString);
    SMLog(@"Criteria String From Dict = :%@:",[appDelegate.wsInterface.tagsDictionary objectForKey:SFM_CRITERIA_CONTAINS]);
    if([criteriaString isEqualToString:[appDelegate.wsInterface.tagsDictionary objectForKey:SFM_CRITERIA_CONTAINS]])
    {
        resultSearchString = [NSString stringWithFormat:@"%%%@%%",searchString];
        SMLog(@"Matched Contains");
    }
    if([criteriaString isEqualToString:[appDelegate.wsInterface.tagsDictionary objectForKey:SFM_CRITERIA_EXTACT_MATCH]])
    {
        resultSearchString = searchString;
    }
    if([criteriaString isEqualToString:[appDelegate.wsInterface.tagsDictionary objectForKey:SFM_CRITERIA_ENDS_WITH]])
    {
        resultSearchString = [NSString stringWithFormat:@"%%%@",searchString];
    }
    if([criteriaString isEqualToString:[appDelegate.wsInterface.tagsDictionary objectForKey:SFM_CRITERIA_STARTS_WITH]])
    {
        resultSearchString = [NSString stringWithFormat:@"%@%%",searchString];
    }
    return resultSearchString;
}

-(NSMutableDictionary*) getupdatedToken:(NSMutableDictionary*)dictforparsing
{
    NSArray *operatorArray = [NSArray arrayWithObjects:@"!=",@"<=",@">=",@"<>",@"=",@"<",@">",@"NOT LIKE",@" LIKE ",@" NOT IN ",@" IN ", nil];
    int Count=-1;
    if(appDelegate == nil)
        appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
    int tokenCount=[[dictforparsing objectForKey:@"Count"] integerValue];
    NSMutableArray *TableArray = [dictforparsing objectForKey:@"TableArray"];
    NSMutableDictionary *tableArrayDict=[dictforparsing objectForKey:@"tableArrayDict"];
    NSMutableDictionary *resultDict=[[NSMutableDictionary alloc]init ];
    NSMutableString *finalQuery=[dictforparsing objectForKey:@"finalQuery"];
    NSString *token=[dictforparsing objectForKey:@"token"];
    token=[token stringByReplacingOccurrencesOfString:@" ( " withString:@"("];
    token=[token stringByReplacingOccurrencesOfString:@" ) " withString:@")"];
    NSArray * criteria_array  = [dictforparsing objectForKey:@"criteriaArray"];
    NSDictionary * criteria_dict = [criteria_array objectAtIndex:0];
    NSString *rhs=@"";
    NSString *NameFiled=@"",*Objecttype=@"";
    NSString *refrence_to=@"";
    NSString * NotOp = @"NOT(";
    
    if([token rangeOfString:NotOp].length >0)
    {
        
        token = [token stringByReplacingOccurrencesOfString:@"(NOT(" withString:@" "];
        token = [token stringByReplacingOccurrencesOfString:@"LIKE" withString:@"NOT LIKE"];
       // token = [token stringByReplacingOccurrencesOfString:@")" withString:@" "];
        if([token rangeOfString:@")"].length >0)
        {
            NSRange  range = [token rangeOfString:@")"];
            NSUInteger location= range.location;
            token = [token stringByReplacingCharactersInRange:NSMakeRange(location, 2) withString:@""];
        }
    }
    
    for(NSString *operator in operatorArray)
    {
        if([token rangeOfString:operator].length > 0)
        {
            Count++;
            NSArray *operatorTokens = [token componentsSeparatedByString:operator];
            NSString *objectDef   = [operatorTokens objectAtIndex:0];
            NSString *objectValue = [operatorTokens objectAtIndex:1];
            NSString *objectDefWithoutBrace=[objectDef stringByReplacingOccurrencesOfString:@"(" withString:@""];      
            objectDefWithoutBrace=[objectDefWithoutBrace stringByReplacingOccurrencesOfString:@")" withString:@""];
            NSString *objectValueBrace=[objectValue stringByReplacingOccurrencesOfString:@"(" withString:@""];
            objectValueBrace=[objectValueBrace stringByReplacingOccurrencesOfString:@")" withString:@""];
            NSString *fieldName=@"",*tableName=@"";
            if([objectDef rangeOfString:@"."].length >0)
            {
                SMLog(@"Table Name is there");
                NSArray *fieldArray = [objectDef componentsSeparatedByString:@"."];
                tableName = [fieldArray objectAtIndex:0];
                fieldName = [fieldArray objectAtIndex:1];
                tableName = [tableName stringByReplacingOccurrencesOfString:@" " withString:@""];
                fieldName = [fieldName stringByReplacingOccurrencesOfString:@" " withString:@""];
                refrence_to=[self getRefrenceToField:[dictforparsing objectForKey:@"object"] relationship:objectDefWithoutBrace];
                if([tableName rangeOfString:@"__r"].length >0)
                {
                    NSDictionary *countDict=[self occurenceOfBraces:tableName];
                    tableName=[tableName stringByReplacingOccurrencesOfString:@"(" withString:@""];
                    tableName=[tableName stringByReplacingOccurrencesOfString:@")" withString:@""];
                    NSMutableString * queryStatementForRefrence = [[NSMutableString alloc]initWithCapacity:0];
                    queryStatementForRefrence = [NSMutableString stringWithFormat:@"SELECT reference_to from SFObjectField where object_api_name='%@' and relationship_name='%@'",[dictforparsing objectForKey:@"object"],tableName];    
                    sqlite3_stmt * labelstmtForRefrence;
                    const char *selectStatementForRefrence = [queryStatementForRefrence UTF8String];
                    char *field1;        
                    NSString *referenceObjectName=@"";
                    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatementForRefrence,-1, &labelstmtForRefrence, nil) == SQLITE_OK )
                    {
                        if(synchronized_sqlite3_step(labelstmtForRefrence) == SQLITE_ROW)
                        {
                            field1 = (char *) synchronized_sqlite3_column_text(labelstmtForRefrence,0);
                            if((field1 !=nil) && strlen(field1))
                                referenceObjectName =[NSString stringWithFormat:@"%s",field1];
                        }
                    }
                    synchronized_sqlite3_finalize(labelstmtForRefrence);

                    for (int i=0; i<[[countDict objectForKey:@"rightBraces"] intValue]; i++) 
                    {
                        if(!((i==0) && ([objectValue Contains:@"SVMX.CURRENTUSER"] || [objectValue Contains:@"SVMX.OWNER"])))
                        {
                            [finalQuery appendFormat:@"("];
                        }
                    }
                    if([objectValue rangeOfString:@"null"options:NSCaseInsensitiveSearch].length >0 &&([operator isEqualToString:@"!="] || [operator isEqualToString:@"<>"]) )
                    {
                        rhs=[NSString stringWithFormat:@"'%@'.%@",referenceObjectName,fieldName];
                        [finalQuery appendFormat:@"trim('%@'.%@)",referenceObjectName,fieldName];
                        for (int i=0; i<[[countDict objectForKey:@"leftBraces"] intValue]; i++)
                        {
                        	if(!((i==0) && ([objectValue Contains:@"SVMX.CURRENTUSER"] || [objectValue Contains:@"SVMX.OWNER"])))
	                            [finalQuery appendFormat:@" COLLATE NOCASE )"];
                        }
                    }
                    else if(![objectValue Contains:@"SVMX.CURRENTUSER"] && ![objectValue Contains:@"SVMX.OWNER"]&&![refrence_to isEqualToString:@"User"])
                    {
                        rhs=[NSString stringWithFormat:@"%@",referenceObjectName];
                        [finalQuery appendString:referenceObjectName];
                        [finalQuery appendString:@"."];
                        [finalQuery appendString:fieldName];
                        for (int i=0; i<[[countDict objectForKey:@"leftBraces"] intValue]; i++)
                        {
                            [finalQuery appendFormat:@" COLLATE NOCASE )"];
                        }
                    }
                    else
                    {
                        NameFiled=[self getRefrenceToField:[dictforparsing objectForKey:@"object"] relationship:referenceObjectName];
                        NSString *field=[[[dictforparsing objectForKey:@"criteriaArray"] objectAtIndex:tokenCount] objectForKey:@"SVMXC__Field_Name__c"];
                        Objecttype=[self getfieldTypeForApi:field fieldName:fieldName];
                    }
                    
                  
                }
                else
                {
                    NSDictionary *countBracesintableName=[self occurenceOfBraces:tableName];
                    NSDictionary *countBracesinFiledName=[self occurenceOfBraces:fieldName];
                    NSString * objectName = [dictforparsing objectForKey:@"object"];
                    refrence_to=[self getRefrenceToField:objectName relationship:[tableName stringByReplacingOccurrencesOfString:@"(" withString:@""]];
                    for (int i=0; i<[[countBracesintableName objectForKey:@"rightBraces"] intValue]; i++) 
                    {
                        if(!((i==0) && ([operator isEqualToString:@" NOT IN "] || [operator isEqualToString:@" IN "])))
                        {
                            [finalQuery appendFormat:@"("];
                        }
                    }
                    if([tableName isEqualToString:@"RecordType"])
                    {
                        
                        NSString * component_expression = [NSString stringWithFormat:@"'%@'.RecordTypeId   in   (select  record_type_id  from SFRecordType where record_type %@ %@ )" , objectName, operator,objectValue]; 
                        [finalQuery appendFormat:@"%@" , component_expression];
                    }
                    else if(![objectValue Contains:@"SVMX.CURRENTUSER"] && ![objectValue Contains:@"SVMX.OWNER"]&&![refrence_to isEqualToString:@"User"])
                    {
                        
                        if([objectValue rangeOfString:@"null"options:NSCaseInsensitiveSearch].length >0 &&([operator isEqualToString:@"!="] || [operator isEqualToString:@"<>"]) )
                        {
                            [finalQuery appendFormat:@"trim('%@'.%@)",tableName,fieldName];
                        }
                        else
                        {
                            [finalQuery appendFormat:@"'%@'.%@",tableName,fieldName];
                        }
                        for (int i=0; i<[[countBracesinFiledName objectForKey:@"leftBraces"] intValue]; i++) 
                        {
                            if(!((i==0) && ([objectValue Contains:@"SVMX.CURRENTUSER"] || [objectValue Contains:@"SVMX.OWNER"])))
                            {
                                [finalQuery appendFormat:@")"];
                            }
                        }
                        if(![TableArray containsObject:tableName] && [tableName length] > 0)
                        {
                            [TableArray addObject:tableName];
                            [tableArrayDict setObject:[[[dictforparsing objectForKey:@"criteriaArray"] objectAtIndex: Count] objectForKey:@"SVMXC__Field_Name__c"]  forKey:tableName ];
                        }
                    }
                }
                
                [finalQuery appendString:@" "];
            }
            else 
            {
                refrence_to=[self getRefrenceToField:[dictforparsing objectForKey:@"object"] relationship:objectDefWithoutBrace];
                SMLog(@"Table Name is not there. Append Object Name as Table Name");
                NSDictionary *dictforBraces=[self occurenceOfBraces:objectDef];
                for (int i=0; i<[[dictforBraces objectForKey:@"rightBraces"] intValue]; i++) 
                {
                    if(!((i==0) && ([objectValue Contains:@"SVMX.CURRENTUSER"]||[objectValue Contains:@"SVMX.OWNER"])))
                    {
                        [finalQuery appendFormat:@"("];
                    }
                }
                
                if([objectValue rangeOfString:@"null"options:NSCaseInsensitiveSearch].length >0 &&([operator isEqualToString:@"!="] || [operator isEqualToString:@"<>"]) )
                {
                    
                    [finalQuery appendFormat:@"trim('%@'.%@)",[self getApiNameFromFieldLabel:[dictforparsing objectForKey:@"strTargetObject"]],objectDefWithoutBrace];
                    
                }
                else if(![objectValue Contains:@"SVMX.CURRENTUSER"] && ![objectValue Contains:@"SVMX.OWNER"])
                {
                    rhs=[NSString stringWithFormat:@"'%@'.%@",[self getApiNameFromFieldLabel:[dictforparsing objectForKey:@"strTargetObject"]],objectDefWithoutBrace];
                    [finalQuery appendFormat:@"'%@'",[self getApiNameFromFieldLabel:[dictforparsing objectForKey:@"strTargetObject"]]];
                    [finalQuery appendString:@"."];
                    [finalQuery appendString:objectDefWithoutBrace];
                }
                fieldName = objectDefWithoutBrace;
                fieldName = [fieldName stringByReplacingOccurrencesOfString:@" " withString:@""];
                for (int i=0; i<[[dictforBraces objectForKey:@"leftBraces"] intValue]; i++) 
                {
                    if(!((i==0) && ([objectValue Contains:@"SVMX.CURRENTUSER"] || [objectValue Contains:@"SVMX.OWNER"])))
                    {
                        [finalQuery appendFormat:@" COLLATE NOCASE )"];
                    }
                }
            }
            if([objectValue rangeOfString:@"null"options:NSCaseInsensitiveSearch].length >0)
            {
                NSDictionary *Bracesinvalue=[self occurenceOfBraces:objectValue];
                if([objectValueBrace Contains:@"null"] &&([operator isEqualToString:@"!="] || [operator isEqualToString:@"<>"]) )
                {
                    [finalQuery appendFormat:@" != '' "];
                }
                else
                {
//                    [finalQuery appendString:@" isnull"];
                      [finalQuery appendFormat:@"= '' "];
                }
                
                
                for (int i=0; i<[[Bracesinvalue objectForKey:@"leftBraces"] intValue]; i++) 
                {
                    if(!((i==0) && ([objectValue Contains:@"SVMX.CURRENTUSER"] || [objectValue Contains:@"SVMX.OWNER"])))
                    {
                        [finalQuery appendFormat:@" COLLATE NOCASE )"];
                    }
                }
            }
            else if([refrence_to isEqualToString:@"User"]||[objectValue Contains:@"SVMX.CURRENTUSER"] || [objectValue Contains:@"SVMX.OWNER"])
            {
                NSString * objectName = [dictforparsing objectForKey:@"object"];
                refrence_to=[self getRefrenceToField:objectName relationship:[tableName stringByReplacingOccurrencesOfString:@"(" withString:@""]];
                NSString * component_expression=@"";
                
                if([objectValue Contains:@"SVMX.CURRENTUSER"] || [objectValue Contains:@"SVMX.OWNER"])
                {
                    if(Objecttype!=@"")
                    Objecttype=[self getfieldTypeForApi:objectName fieldName:fieldName];
                    if(![Objecttype isEqualToString:@"refrence"]||![Objecttype isEqualToString:@"refrence"])
                    {
                        
                        NSString *UserFullName=@"", *UserNameValue=@"";
                        if(![appDelegate.currentUserName length]>0)
                        {
                            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                            if ([[userDefaults objectForKey:@"UserFullName"] length]>0)
                            {
                                UserFullName = [userDefaults objectForKey:@"UserFullName"];
                                SMLog(@"User Full Name  = %@",UserFullName);
                            }
                            else
                            {
                                UserFullName=[self getLoggedInUser:appDelegate.username];
                            }
                        }
                        else
                        {
                            UserFullName=appDelegate.currentUserName;
                        }
                        if([UserFullName length]>0)
                        {
                            UserNameValue=[objectValue stringByReplacingOccurrencesOfString:@"SVMX.CURRENTUSER" withString:UserFullName];
                        }

                        if([refrence_to length]>0)
                        {
                                component_expression = [NSString stringWithFormat:@"'%@'.%@ %@ %@" , refrence_to,fieldName, operator,UserNameValue];
                        }
                        else
                        {
                                component_expression = [NSString stringWithFormat:@"'%@'.%@ %@ %@" ,[dictforparsing objectForKey:@"object"] ,fieldName, operator,UserNameValue];

                        }
                        [finalQuery appendString:component_expression];
                        
                    }
                    else
                    {
                        if(appDelegate.loggedInUserId == nil)
                        {
                            appDelegate.loggedInUserId=[self getLoggedInUserId:appDelegate.username];
                        }
                        NSString *field=[[[dictforparsing objectForKey:@"criteriaArray"] objectAtIndex:Count] objectForKey:@"SVMXC__Field_Name__c"];
                        component_expression = [NSString stringWithFormat:@"'%@'.%@ %@ '%@'" , objectName,field, operator,appDelegate.loggedInUserId];
                        [finalQuery appendString:component_expression];
                    }
                }
                else
                {
                    NSString *field=[[[dictforparsing objectForKey:@"criteriaArray"] objectAtIndex:Count] objectForKey:@"SVMXC__Field_Name__c"];
                    component_expression = [NSString stringWithFormat:@"'%@'.%@   in   (select  Id  from User where Name %@ %@ )" , objectName,field, operator,objectValue];
                    [finalQuery appendString:component_expression];
                }
                NSDictionary *valueBracesOccurence=[self occurenceOfBraces:objectValue];

                for (int i=0; i<[[valueBracesOccurence objectForKey:@"leftBraces"] intValue]; i++)
                {

                    if(!([objectValue Contains:@"SVMX.CURRENTUSER"] || [objectValue Contains:@"SVMX.OWNER"]))
                    {
                        [finalQuery appendFormat:@" COLLATE NOCASE )"];
                    }
                }
            }

            else if(([[self getDataTypeFor:fieldName inArray:criteria_array] isEqualToString:BOOLEAN]) && ([objectValue rangeOfString:@"True"options:NSCaseInsensitiveSearch].length >0))
            {
                NSDictionary *Bracesinvalue=[self occurenceOfBraces:objectValue];
                [finalQuery appendString:operator];
                objectValueBrace=[objectValueBrace stringByReplacingOccurrencesOfString:@"True"withString:@"1"];
                [finalQuery appendString:objectValueBrace];
                for (int i=0; i<[[Bracesinvalue objectForKey:@"leftBraces"] intValue]; i++) 
                {
                    if(!((i==0) && ([operator isEqualToString:@" NOT IN "] || [operator isEqualToString:@" IN "])))
                    {
                        [finalQuery appendFormat:@" COLLATE NOCASE )"];
                    }
                }
            }
            else if(([[self getDataTypeFor:fieldName inArray:criteria_array] isEqualToString:BOOLEAN]) && ([objectValue rangeOfString:@"False"options:NSCaseInsensitiveSearch].length>0))
            {
                NSDictionary *Bracesinvalue=[self occurenceOfBraces:objectValue];
                [finalQuery appendString:operator];
                objectValueBrace=[objectValueBrace stringByReplacingOccurrencesOfString:@"False"withString:@"0"];
                [finalQuery appendString:objectValueBrace];
                for (int i=0; i<[[Bracesinvalue objectForKey:@"leftBraces"] intValue]; i++) 
                {
                    if(!((i==0) && ([operator isEqualToString:@" NOT IN "] || [operator isEqualToString:@" IN "])))
                    {
                        [finalQuery appendFormat:@" COLLATE NOCASE )"];
                    }
                }
            }   
            else if ( ([objectValue rangeOfString:@"TODAY"options:NSCaseInsensitiveSearch].length>0) ||  ([objectValue rangeOfString:@"TOMORROW"options:NSCaseInsensitiveSearch].length>0) ||  ([objectValue rangeOfString:@"YESTERDAY"options:NSCaseInsensitiveSearch].length>0)||([objectValue rangeOfString:@"NOW"options:NSCaseInsensitiveSearch].length>0) )
            {
                NSDictionary *Bracesinvalue=[self occurenceOfBraces:objectValue];
                
                
                NSTimeInterval secondsPerDay = 24 * 60 * 60;
                
                NSString * today_Date ,* tomorow_date ,* yesterday_date;
                
                NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
                //[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                
                NSDate *today = [NSDate date];;
                
                NSDate *tomorrow, *yesterday;
                
                tomorrow = [today dateByAddingTimeInterval: secondsPerDay];
                
                yesterday = [today dateByAddingTimeInterval: -secondsPerDay];
                
        
                
                //for macros expantion
                if([[self getDataTypeFor:fieldName inArray:criteria_array] isEqualToString:@"DATE"])
                {
                    [finalQuery appendString:operator];
                    [finalQuery appendString:@"'"];
                    
                    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                    
                    today_Date = [dateFormatter stringFromDate:today];
                    tomorow_date = [dateFormatter stringFromDate:tomorrow];
                    yesterday_date = [dateFormatter stringFromDate:yesterday];
                    
                    if([objectValue rangeOfString:@"TODAY" options:NSCaseInsensitiveSearch ].length>0)
                    {
                        [finalQuery appendString:today_Date];
                        
                    }
                    if([objectValue rangeOfString:@"TOMORROW"options:NSCaseInsensitiveSearch ].length>0)
                    {
                       [finalQuery appendString:tomorow_date];
                        
                    }
                    if([objectValue rangeOfString:@"YESTERDAY"options:NSCaseInsensitiveSearch ].length>0)
                    {
                        [finalQuery appendString:yesterday_date];
                    }
                    for (int i=0; i<[[Bracesinvalue objectForKey:@"leftBraces"] intValue]; i++) 
                    {
                        if(!((i==0) && ([operator isEqualToString:@" NOT IN "] || [operator isEqualToString:@" IN "])))
	                        [finalQuery appendFormat:@"  COLLATE NOCASE )"];
                    }
                    
                }
                
                if([[self getDataTypeFor:fieldName inArray:criteria_array] isEqualToString:@"DATETIME"])
                {
                    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                    NSString *start_datetime,*end_datetime;
                    today_Date = [dateFormatter stringFromDate:today];
                    tomorow_date = [dateFormatter stringFromDate:tomorrow];
                    yesterday_date = [dateFormatter stringFromDate:yesterday];

                    if([objectValue rangeOfString:@"TODAY"options:NSCaseInsensitiveSearch ].length>0||[objectValue rangeOfString:@"NOW"options:NSCaseInsensitiveSearch ].length>0)
                    {
                        start_datetime = [today_Date stringByAppendingFormat:@"T00:00:00.000+0000"];
                        end_datetime   = [today_Date stringByAppendingFormat:@"T24:00:00.000+0000"];  
                        if([operator isEqualToString:@"="])
                        {
                                        
                            [finalQuery appendString:@" >= "];
                            [finalQuery appendFormat:@"'%@'",start_datetime];
                            [finalQuery appendFormat:@" AND %@",rhs];
                            [finalQuery appendFormat:@" < '%@",end_datetime];
                        }
                        else if([operator isEqualToString:@"<"] || [operator isEqualToString:@"<="])
                        {
                            [finalQuery appendFormat:@" %@",operator];
                            [finalQuery appendFormat:@"'%@",start_datetime];
                            
                        }
                        else if([operator isEqualToString:@">"] || [operator isEqualToString:@">="])
                        {
                            [finalQuery appendFormat:@" %@",operator];
                            [finalQuery appendFormat:@"'%@",end_datetime];
                            
                        }
                    }
                    
                    if([objectValue rangeOfString:@"TOMORROW"options:NSCaseInsensitiveSearch ].length>0)
                    {
                        start_datetime = [tomorow_date stringByAppendingFormat:@"T00:00:00.000+0000"];
                        end_datetime   = [tomorow_date stringByAppendingFormat:@"T24:00:00.000+0000"];  
                        if([operator isEqualToString:@"="])
                        {
                            
                            [finalQuery appendString:@" >= "];
                            [finalQuery appendFormat:@"'%@'",start_datetime];
                            [finalQuery appendFormat:@" AND %@",rhs];
                            [finalQuery appendFormat:@" < '%@",end_datetime];
                        }
                        else if([operator isEqualToString:@"<"] || [operator isEqualToString:@"<="])
                        {
                            [finalQuery appendFormat:@" %@",operator];
                            [finalQuery appendFormat:@"'%@",start_datetime];
                            
                        }
                        else if([operator isEqualToString:@">"] || [operator isEqualToString:@">="])
                        {
                            [finalQuery appendFormat:@" %@",operator];
                            [finalQuery appendFormat:@"'%@",end_datetime];
                            
                        }
                    }
                    
                    if([objectValue rangeOfString:@"YESTERDAY"options:NSCaseInsensitiveSearch ].length>0)
                    {
                        start_datetime = [yesterday_date stringByAppendingFormat:@"T00:00:00.000+0000"];
                        end_datetime   = [yesterday_date stringByAppendingFormat:@"T24:00:00.000+0000"];  
                        if([operator isEqualToString:@"="])
                        {
                            
                            [finalQuery appendString:@" >= "];
                            [finalQuery appendFormat:@"'%@'",start_datetime];
                            [finalQuery appendFormat:@" AND %@",rhs];
                            [finalQuery appendFormat:@" < '%@",end_datetime];
                        }
                        else if([operator isEqualToString:@"<"] || [operator isEqualToString:@"<="])
                        {
                            [finalQuery appendFormat:@" %@",operator];
                            [finalQuery appendFormat:@"'%@",start_datetime];
                            
                        }
                        else if([operator isEqualToString:@">"] || [operator isEqualToString:@">="])
                        {
                            [finalQuery appendFormat:@" %@",operator];
                            [finalQuery appendFormat:@"'%@",end_datetime];
                            
                        }
                    }
                    for (int i=0; i<[[Bracesinvalue objectForKey:@"leftBraces"] intValue]; i++) 
                    {
                        if(!((i==0) && ([operator isEqualToString:@" NOT IN "] || [operator isEqualToString:@" IN "])))
                        {
                            [finalQuery appendFormat:@")"];
                        }
                    }
                }
                [finalQuery appendString:@"'"];
            }
            else
            {
                NSDictionary *valueBracesOccurence=[self occurenceOfBraces:objectValue];
                if(![tableName isEqualToString:@"RecordType"] &&![objectValue Contains:@"SVMX.CURRENTUSER"] &&![objectValue Contains:@"SVMX.OWNER"]&&![refrence_to isEqualToString:@"User"])
                {
                    if([operator isEqualToString:@" NOT IN "] || [operator isEqualToString:@" IN "])
                    {
                        [finalQuery appendString:operator];
                         [finalQuery appendString:@"("];
                        [finalQuery appendString:objectValueBrace];

                    }
                    else
                    {
                        [finalQuery appendString:operator];
                        [finalQuery appendString:objectValueBrace];
                    }
                    for (int i=0; i<[[valueBracesOccurence objectForKey:@"leftBraces"] intValue]; i++) 
                    {
                        if(!((i==0) && ([operator isEqualToString:@" NOT IN "] || [operator isEqualToString:@" IN "])))
                        {
                            [finalQuery appendFormat:@" COLLATE NOCASE )"];
                        }
                    }
                }
                                
            }
            [resultDict setObject:TableArray forKey:@"TableArray"];
            [resultDict setObject:tableArrayDict forKey:@"tableArrayDict"];
            [resultDict setObject:finalQuery forKey:@"finalQuery"];
            break;    
        }    
    }
    return resultDict;
}
-(NSString*) getRefrenceToField:(NSString*)objectName relationship:(NSString*) relationship_name
{
    NSMutableString * queryStatementForRefrence = [[NSMutableString alloc]initWithCapacity:0];
    queryStatementForRefrence = [NSMutableString stringWithFormat:@"SELECT reference_to from SFObjectField where object_api_name='%@' and relationship_name='%@'",objectName,relationship_name];    
    sqlite3_stmt * labelstmtForRefrence;
    const char *selectStatementForRefrence = [queryStatementForRefrence UTF8String];
    char *field1=nil;
    NSString *referenceObjectName=@"";
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatementForRefrence,-1, &labelstmtForRefrence, nil) == SQLITE_OK )
    {
        if(synchronized_sqlite3_step(labelstmtForRefrence) == SQLITE_ROW)
        {
            field1 = (char *) synchronized_sqlite3_column_text(labelstmtForRefrence,0);
            if((field1 !=nil) && strlen(field1))
                referenceObjectName =[NSString stringWithFormat:@"%s",field1];
        }
    }
    synchronized_sqlite3_finalize(labelstmtForRefrence);
    return referenceObjectName;

}
-(NSMutableDictionary*) occurenceOfBraces:(NSString*)token
{
    NSUInteger countRight = 0,countLeft=0;
    NSMutableDictionary *bracesCount=[[NSMutableDictionary alloc]init];
    if([token Contains:@"("])
    {
        NSUInteger length = [token length];
        NSRange range = NSMakeRange(0, length); 
        while(range.location != NSNotFound)
        {
            range = [token rangeOfString: @"(" options:0 range:range];
            if(range.location != NSNotFound)
            {
                range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
                countRight++; 
            }
        }
        
        [bracesCount setObject:[NSString stringWithFormat:@"%d",countRight] forKey:@"rightBraces"];
    }
    else
    {
        [bracesCount setObject:[NSString stringWithFormat:@"%d",countRight] forKey:@"rightBraces"];

    }
    if([token Contains:@")"])
    {
            NSUInteger length = [token length];
            NSRange range = NSMakeRange(0, length); 
            while(range.location != NSNotFound)
            {
                range = [token rangeOfString: @")" options:0 range:range];
                if(range.location != NSNotFound)
                {
                    range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
                    countLeft++; 
                }
            }
            [bracesCount setObject:[NSString stringWithFormat:@"%d",countLeft] forKey:@"leftBraces"];
    }
    else
    {
        [bracesCount setObject:[NSString stringWithFormat:@"%d",countLeft] forKey:@"leftBraces"];

    }
   
    return bracesCount;
}

-(NSString *)getvalueforReference:(NSDictionary*) tableArray value:(NSString*)value
{
    NSMutableString * queryStatement1 = [[NSMutableString alloc]initWithCapacity:0];
    queryStatement1 = [NSMutableString stringWithFormat:@"SELECT type,reference_to FROM SFObjectField where object_api_name = '%@'and api_name='%@'",[appDelegate.dataBase getApiNameFromFieldLabel:[tableArray objectForKey:@"SVMXC__Object_Name2__c"]],[appDelegate.dataBase getApiNameFromFieldLabel:[tableArray objectForKey:@"SVMXC__Field_Name__c"]]];
    sqlite3_stmt * labelstmt;
    const char *selectStatement = [queryStatement1 UTF8String];
    char *type=nil,*refrence_to=nil,*name_field=nil;
    NSString *strName_field=nil,*namefiled;
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &labelstmt, nil) == SQLITE_OK )
    {
        if(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW)
        {
            type = (char *) synchronized_sqlite3_column_text(labelstmt,0);
            refrence_to = (char *) synchronized_sqlite3_column_text(labelstmt,1);
        }
    }
    NSString *strType,*strRefrence_to;
    if((type != nil)&& strlen(type))
        strType=[NSString stringWithFormat:@"%s",type];
    else
        strType=@" ";
    if((refrence_to != nil)&& strlen(refrence_to))
        strRefrence_to=[NSString stringWithFormat:@"%s",refrence_to];
    else
        strRefrence_to=@" ";
    if([strType isEqualToString:@"reference"])
    {
        
        queryStatement1 = [NSMutableString stringWithFormat:@"SELECT api_name FROM SFObjectField where name_field='TRUE' and object_api_name='%@'",strRefrence_to];    
        sqlite3_stmt * labelstmt;
        const char *selectStatement = [queryStatement1 UTF8String];
        if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &labelstmt, nil) == SQLITE_OK )
        {
            if(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW)
            {
                name_field = (char *) synchronized_sqlite3_column_text(labelstmt,0);
                if ((name_field !=nil) && strlen(name_field))
                    namefiled=[NSString stringWithFormat:@"%s",name_field];
            }
        }
        NSString *queryRefrefield = [NSMutableString stringWithFormat:@"SELECT %@ FROM '%@' where Id='%@'",namefiled,[NSString stringWithFormat:@"%s",refrence_to],value];    
        sqlite3_stmt * queryRefrefieldstmt;
        const char *queryRefrefieldselectStatement = [queryRefrefield UTF8String];
        char *obejctFiled;
        NSString *refrenceObject=nil;
        if ( synchronized_sqlite3_prepare_v2(appDelegate.db, queryRefrefieldselectStatement,-1, &queryRefrefieldstmt, nil) == SQLITE_OK )
        {
            if(synchronized_sqlite3_step(queryRefrefieldstmt) == SQLITE_ROW)
            {
                obejctFiled = (char *) synchronized_sqlite3_column_text(queryRefrefieldstmt,0);
                if ((obejctFiled !=nil) && strlen(obejctFiled))
                {
                    refrenceObject=[NSString stringWithFormat:@"%s",obejctFiled];
                    strName_field=refrenceObject;
                }
            }
        }
        if(!refrenceObject)
        {
           strName_field=[self getValueFromLookupwithId:value];
            if (![strName_field length]>0)
            {
                strName_field=value;
            }
        }

    }
    return strName_field;

}
- (NSString *)getValueFromLookupwithId:(NSString *)_Id
{
    NSString * Id = @"";
	NSString * selectQuery = [NSString stringWithFormat:@"Select DISTINCT value from LookUpFieldValue where Id = '%@'", _Id];
	
	sqlite3_stmt * statement;
    const char * _selectQuery = [selectQuery UTF8String];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, _selectQuery,-1, &statement, nil) == SQLITE_OK)
    {
        
        while(synchronized_sqlite3_step(statement) == SQLITE_ROW){
            char * field1 = (char *) synchronized_sqlite3_column_text(statement, COLUMN_1);
            if (field1 != nil)
                Id = [[NSString alloc] initWithUTF8String:field1];
            
        }
    }
	
	return Id;
}
 
- (NSString *) getFieldLabelForApiName:(NSString *)apiName
{
    NSString *queryStatement = [NSString stringWithFormat:@"SELECT label from SFObject where api_name = '%@'",apiName];
    //    SMLog(@"Query Statement = %@",queryStatement);
    sqlite3_stmt * statement;
    NSString *apiLabel = apiName;
    if(appDelegate == nil)
        appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
//            const char * label = (char *)synchronized_sqlite3_column_text(statement, 0);
            char * label = (char *)synchronized_sqlite3_column_text(statement, 0);
            if ((label != nil) && strlen(label))
            {
                //apiLabel = [NSString stringWithUTF8String:label];
                apiLabel = [NSString stringWithFormat:@"%s",label];
            }
        }
    }
    
    synchronized_sqlite3_finalize(statement);
    return apiLabel;
       
}
- (NSString *) getApiNameFromFieldLabel:(NSString *)labelName
{
    NSString *queryStatement = [NSString stringWithFormat:@"SELECT api_name from SFObject where label = '%@'",labelName];
    sqlite3_stmt * statement;
    NSString *apiName = labelName;
    if(appDelegate == nil)
        appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
//            const char * label = (char *)synchronized_sqlite3_column_text(statement, 0);
            char * label = (char *)synchronized_sqlite3_column_text(statement, 0);
            if ((label !=nil) && strlen(label))
            {
//                apiName = [NSString stringWithUTF8String:label]; 
                apiName = [NSString stringWithFormat:@"%s",label];

            }
        }
        synchronized_sqlite3_finalize(statement);
    }
    
    
    return [apiName retain];
    
}
- (NSString*) getLabelFromApiName:(NSString*)api_name objectName:(NSString*) objectName
{ 
    NSString *queryStatement = [NSString stringWithFormat:@"SELECT label from SFObjectField where api_name ='%@' and object_api_name='%@'",api_name,objectName];
    sqlite3_stmt * statement;
    NSString *apiLabel = api_name;
    if(appDelegate == nil)
        appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            char * label = (char *)synchronized_sqlite3_column_text(statement, 0);
            if ((label != nil) && strlen(label))
            {
                apiLabel = [NSString stringWithUTF8String:label];   
            }
        }
    }
    
    synchronized_sqlite3_finalize(statement);
    return apiLabel;
    
}

#pragma mark - Location Ping
- (void) createUserGPSTable
{
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SVMXC__User_GPS_Log__c ('local_id' VARCHAR PRIMARY KEY  NOT NULL  DEFAULT (0), 'SVMXC__Status__c' TEXT, 'SVMXC__Latitude__c' VARCHAR, SVMXC__User__c 'TEXT', 'OwnerId' TEXT, 'SVMXC__Device_Type__c' TEXT, 'CreatedById' TEXT, 'SVMXC__Additional_Info__c' VARCHAR, 'SVMXC__Time_Recorded__c' VARCHAR, 'SVMXC__Longitude__c' VARCHAR)"]];
    if(result == YES)
        SMLog(@"SVMXC__User_GPS_Log__c Table Create Success");
    else
        SMLog(@"SVMXC__User_GPS_Log__c Table Create Failed");
}
- (void) deleteRecordFromUserGPSTable:(NSString *) localId
{
    NSString * queryStatementGPSLog = [NSString stringWithFormat:@"DELETE FROM SVMXC__User_GPS_Log__c where local_id='%@'",localId];
    char * err;
    if(localId != nil)
    {
        if (synchronized_sqlite3_exec(appDelegate.db, [queryStatementGPSLog UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
            SMLog(@"Failed to delete, for rowid= %@",localId);
        }
    }
}

// delete seq
- (void) deleteSequenceofTable:(NSString *)tableName 
{
    NSString *sql =[NSString stringWithFormat:@"SELECT name FROM sqlite_master WHERE type='table' AND name='%@'",tableName];
    sqlite3_stmt *statement;
    char *table_name;
    NSString *tblname;
    if(appDelegate == nil)
        appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];

    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sql UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(statement) == SQLITE_ROW) 
        {
            table_name  = (char *) synchronized_sqlite3_column_text(statement, 0);
            if(table_name!=nil)
                tblname=[NSString stringWithFormat:@"%s",table_name];
                
        }        
    }
    synchronized_sqlite3_finalize(statement);

    if([tblname isEqualToString:tableName])
    {
        SMLog(@"%@ Table exist",tableName);
        NSString * queryStatement = [NSString stringWithFormat:@"delete from sqlite_sequence where name='SVMXC__User_GPS_Log__c'"];
        
        char * err;
        
        if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
            SMLog(@"Sequence Failed to delete for Table");
        }
    }
   
}
-(void) insertrecordIntoUserGPSLog:(NSDictionary *)locationInfo
{
    char *err;
    if(appDelegate == nil)
        appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if(appDelegate.metaSyncRunning||appDelegate.dataSyncRunning)
    {
        SMLog(@"Sync is Running");
        return;
    }

    [self purgeLocationPingTable];
    NSString *latitude = [locationInfo objectForKey:@"latitude"];
    NSString *longitude = [locationInfo objectForKey:@"longitude"];
    NSString *time = [locationInfo objectForKey:@"timestamp"];
    
    NSString *additionalInfo = [locationInfo objectForKey:@"additionalInfo"];
    NSString *status = [locationInfo objectForKey:@"status"];
    if(appDelegate == nil)
        appDelegate = (iServiceAppDelegate *)[[ UIApplication sharedApplication] delegate];

    if(appDelegate.loggedInUserId == nil)
    {
        appDelegate.loggedInUserId=[self getLoggedInUserId:appDelegate.username];
    }
    SMLog(@"Logged In User Id = %@",appDelegate.loggedInUserId);
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
    
    NSString *id_value = [iServiceAppDelegate GetUUID];
    NSString *device=@"iPad";
    NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO SVMXC__User_GPS_Log__c('local_id','SVMXC__Status__c','SVMXC__Latitude__c','SVMXC__User__c','OwnerId','SVMXC__Device_Type__c', 'CreatedById','SVMXC__Additional_Info__c','SVMXC__Longitude__c','SVMXC__Time_Recorded__c') VALUES ('%@','%@','%@','%@','','%@','','%@','%@','%@')",id_value,status,latitude,appDelegate.loggedInUserId,device,additionalInfo,longitude,time];    
    BOOL isInsertedIntoLocationTable=TRUE;
    SMLog(@"Query = %@",sql);
    if(synchronized_sqlite3_exec(appDelegate.db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        isInsertedIntoLocationTable=FALSE;
        SMLog(@"Failed to Populate Table");
    }
   
    if(isInsertedIntoLocationTable)
    {
        SMLog(@"Success to Insert Data in Table");
        /*
        [appDelegate.databaseInterface  insertdataIntoTrailerTableForRecord:id_value SF_id:@"" record_type:MASTER operation:INSERT object_name:@"SVMXC__User_GPS_Log__c" sync_flag:@"false" parentObjectName:@"" parent_loacl_id:@""];*/
        SMLog(@"Insertion success");
        [self updateTechnicianLocation];
        [self updateUserGPSLocation];
    }
}
- (void) purgeLocationPingTable
{   
    NSString *sql = @"SELECT Count(*) FROM SVMXC__User_GPS_Log__c";
    sqlite3_stmt *statement;
    int row_count;
    char *Id,*local_id;
    if(appDelegate == nil)
        appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sql UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(statement) == SQLITE_ROW) 
        {
            row_count = synchronized_sqlite3_column_int(statement, 0);
            SMLog(@"No of location records in DB %d",row_count );
            
        }
        synchronized_sqlite3_finalize(statement);
    }
    //get limit from table
    NSString *limitLocationRecords = [appDelegate.settingsDict objectForKey:MAX_LOCATION_RECORD];
    limitLocationRecords = (limitLocationRecords!=nil)?limitLocationRecords:@"100";
    if(row_count < [limitLocationRecords intValue])
    {
        return;
    }
    while (row_count >=[limitLocationRecords intValue])
    {
        sql = @"select rowid,local_id from SVMXC__User_GPS_Log__c  asc limit 1";
        NSString *strId=nil,*strlocal_id=nil;
        
        if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sql UTF8String], -1, &statement, nil) == SQLITE_OK)
        {
            if (synchronized_sqlite3_step(statement) == SQLITE_ROW) 
            {
                Id = (char *) sqlite3_column_text(statement, 0);
                local_id = (char *) sqlite3_column_text(statement, 1);
                
                if (Id != nil && strlen(Id))
                    strId =   [[NSString alloc] initWithUTF8String:Id];
                SMLog(@"Id =%@",strId);
                if (local_id != nil && strlen(local_id))
                    strlocal_id =   [[NSString alloc] initWithUTF8String:local_id];
                SMLog(@"local_id =%@",strlocal_id);
            }
        }
        
        NSString * queryStatementGPSLog = [NSString stringWithFormat:@"DELETE FROM SVMXC__User_GPS_Log__c where rowid=%@",strId];
        BOOL isDataDeletedFromUser_GPS_Log=TRUE;
        char * err;
        if(strId != nil)
        {
            if (synchronized_sqlite3_exec(appDelegate.db, [queryStatementGPSLog UTF8String], NULL, NULL, &err) != SQLITE_OK)
            {
                SMLog(@"Purging Failed to delete, for rowid= %@",strId);
                isDataDeletedFromUser_GPS_Log=FALSE;
            }
        }
        /*
        if(isDataDeletedFromUser_GPS_Log)
            [appDelegate.databaseInterface DeleterecordFromTable:@"SFDataTrailer" Forlocal_id:strlocal_id];        
         */
        synchronized_sqlite3_finalize(statement);
        row_count--;
    }
    
}
- (NSString *) getSettingValueWithName:(NSString *)settingName
{
	NSString *settingValue = nil;
    NSString *queryStatement;
    sqlite3_stmt * statement;
    if(appDelegate == nil)
        appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
    if(appDelegate.metaSyncRunning )
    {
        SMLog(@"Meta Sync is Running");
        return  nil;
    }
    queryStatement = [NSString stringWithFormat:@"SELECT 'SettingsValue'.SVMXC__Internal_Value__c FROM 'SettingsValue' LEFT OUTER  JOIN 'SettingsInfo' ON ('SettingsInfo'.Id= 'SettingsValue'.'SVMXC__Setting_ID__c')  where SVMXC__Setting_Unique_ID__c ='%@'",settingName];
        if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            if (synchronized_sqlite3_step(statement) == SQLITE_ROW)
            {
                const char * value = (char *)synchronized_sqlite3_column_text(statement, 0);
                if ((value !=nil) && strlen(value))
                {
                    settingValue = [NSString stringWithUTF8String:value];   
                }
                else 
                {
                    SMLog(@"Value is nil");
                    return nil;
                }
            }
            else 
            {
                SMLog(@"No Records Found");
            }
        }
        else
        {
            SMLog(@"Query Execution Failed");
        }
    
    synchronized_sqlite3_finalize(statement);
    return settingValue;
}
- (void)updateUserGPSLocation
{
    if(appDelegate == nil)
        appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if(appDelegate.metaSyncRunning)
    {
        SMLog(@"Sync is Running");
        return;
    }    
    
    NSString *sql = @"SELECT SVMXC__Latitude__c,SVMXC__Longitude__c,SVMXC__Status__c,SVMXC__User__c,SVMXC__Device_Type__c,SVMXC__Additional_Info__c,SVMXC__Time_Recorded__c,local_id FROM SVMXC__User_GPS_Log__c  ORDER BY rowid desc";
    sqlite3_stmt *statement;
    char *_longitude = NULL;
    char *_latitude = NULL;
    char *_status = NULL;
    char *_user = NULL;
    char *_deviceType = NULL;
    char *_additional_info = NULL;
    char *_timeRecorded = NULL;
    char *_local_id = NULL;
    
    NSString *longitude = nil;
    NSString *latitude = nil;
    NSString *status = nil;
    NSString *user = nil;
    NSString *deviceType = nil;
    NSString *additional_info = nil;
    NSString *timeRecorded = nil;
    NSString *localId = nil;    
    
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];

    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sql UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW) 
        {
            _latitude  = (char *) synchronized_sqlite3_column_text(statement, 0);
            _longitude = (char *) synchronized_sqlite3_column_text(statement, 1);
            _status = (char *) synchronized_sqlite3_column_text(statement, 2);
            _user = (char *) synchronized_sqlite3_column_text(statement, 3);
            _deviceType = (char *) synchronized_sqlite3_column_text(statement, 4);
            _additional_info = (char *) synchronized_sqlite3_column_text(statement, 5);
            _timeRecorded = (char *) synchronized_sqlite3_column_text(statement, 6);
            _local_id = (char *) synchronized_sqlite3_column_text(statement, 7);
            if(_latitude!=nil && strlen(_latitude))
            {
                latitude = [NSString stringWithFormat:@"%s",_latitude];
            }
            else
            {
                latitude = @"";
            }
            if(_longitude!=nil && strlen(_longitude))
            {
                longitude = [NSString stringWithFormat:@"%s",_longitude];
            }
            else
            {
                longitude = @"";
            }

            if(_status!=nil && strlen(_status))
            {
                status = [NSString stringWithFormat:@"%s",_status];
            }
            else
            {
                status = @"";
            }
            
            if(_user!=nil && strlen(_user))
            {
                user = [NSString stringWithFormat:@"%s",_user];
            }
            else
            {
                user = @"";
            }

            if(_deviceType!=nil && strlen(_deviceType))
            {
                deviceType = [NSString stringWithFormat:@"%s",_deviceType];
            }
            else
            {
                deviceType = @"";
            }

            if(_additional_info!=nil && strlen(_additional_info))
            {
                additional_info = [NSString stringWithFormat:@"%s",_additional_info];
            }
            else
            {
                additional_info = @"";
            }

            if(_timeRecorded!=nil && strlen(_timeRecorded))
            {
                timeRecorded = [NSString stringWithFormat:@"%s",_timeRecorded];
                timeRecorded = [timeRecorded stringByReplacingOccurrencesOfString:@"T" withString:@" "];
                timeRecorded = [timeRecorded stringByReplacingOccurrencesOfString:@"Z" withString:@""];
            }
            else
            {
                timeRecorded = @"";
            }

            
            if(_local_id!=nil && strlen(_local_id))
            {
                localId = [NSString stringWithFormat:@"%s",_local_id];
            }
            else
            {
                continue;
            }
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:status forKey:@"SVMXC__Status__c"];
            [dict setObject:latitude forKey:@"SVMXC__Latitude__c"];
            [dict setObject:longitude forKey:@"SVMXC__Longitude__c"];
            [dict setObject:user forKey:@"SVMXC__User__c"];
            [dict setObject:deviceType forKey:@"SVMXC__Device_Type__c"];
            [dict setObject:additional_info forKey:@"SVMXC__Additional_Info__c"];
            [dict setObject:timeRecorded forKey:@"SVMXC__Time_Recorded__c"];
            [dict setObject:localId forKey:@"localId"];
            [resultArray addObject:dict];
            [dict release];
        }        
    }
    synchronized_sqlite3_finalize(statement);
    if (![appDelegate isInternetConnectionAvailable])
    {
        [resultArray release];
        return;
    }
    [appDelegate goOnlineIfRequired];
    didUserGPSLocationUpdated=FALSE;
    SMLog(@"Updating User GPS Location Table");
    [appDelegate.wsInterface dataSyncWithEventName:@"LOCATION_HISTORY" eventType:SYNC values:resultArray];
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(@"Datebase.m : updateUserGPSLocation: LocationHistory");
#endif
        
        if (didUserGPSLocationUpdated == TRUE)
            break;   
        if (![appDelegate isInternetConnectionAvailable])
        {
            break;
        }
        if (appDelegate.connection_error)
        {
            break;
        }
    }
    [resultArray release];
}
- (void)updateTechnicianLocation
{
    if(appDelegate == nil)
        appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];

    if(appDelegate.metaSyncRunning || appDelegate.isInitialMetaSyncInProgress)
    {
        didTechnicianLocationUpdated=TRUE;
        SMLog(@"Sync is Running");
        return;
    }    
    NSMutableArray *location = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT SVMXC__Latitude__c,SVMXC__Longitude__c FROM SVMXC__User_GPS_Log__c  ORDER BY rowid desc limit 1";
    sqlite3_stmt *statement;
    char *longitude;
    char *latitude;
    BOOL isLatitudeNull = YES;
    BOOL isLongitudeNull = YES;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sql UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(statement) == SQLITE_ROW) 
        {
            latitude  = (char *) synchronized_sqlite3_column_text(statement, 0);
            longitude = (char *) synchronized_sqlite3_column_text(statement, 1);
            if(latitude!=nil && strlen(latitude))
            {
                [location addObject:[NSString stringWithFormat:@"%s",latitude]];
                isLatitudeNull = NO;
            }
            if(longitude!=nil && strlen(longitude))
            {
                [location addObject:[NSString stringWithFormat:@"%s",longitude]];
                isLongitudeNull = NO;
            }
        }        
        else
        {
            didTechnicianLocationUpdated=TRUE;
            SMLog(@"Records are not available. Not calling Tech Location Update");
            return;
        }
    }
    synchronized_sqlite3_finalize(statement);
    if(isLatitudeNull || isLongitudeNull)
    {
        didTechnicianLocationUpdated=TRUE;
        SMLog(@"Latitude or Longitude data is null");
        return;
    }
    if (![appDelegate isInternetConnectionAvailable])
    {
        didTechnicianLocationUpdated=TRUE;
        return;
    }
    [appDelegate goOnlineIfRequired];
    didTechnicianLocationUpdated=FALSE;
    SMLog(@"Updating Technician Location");
    [appDelegate.wsInterface dataSyncWithEventName:@"TECH_LOCATION_UPDATE" eventType:SYNC values:location];
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(@"Datebase.m : updateTechinicianLocation: TECH_LOCATION_UPDATE");
#endif
        if (didTechnicianLocationUpdated == TRUE)
            break;   
        if (![appDelegate isInternetConnectionAvailable])
        {
            break;
        }
        if (appDelegate.connection_error)
        {
            break;
        }
        
        SMLog(@"Technician Location Updated");
    }
    [location release];
}

#pragma mark - Initial MetaSync
- (void) insertValuesInToOBjDefTableWithObject:(NSMutableArray *)object definition:(NSMutableArray *)objectDefinition
{

    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFObjectField ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0) ,'object_api_name' VARCHAR,'api_name' VARCHAR,'label' VARCHAR,'precision' DOUBLE,'length' INTEGER,'type' VARCHAR,'reference_to' VARCHAR,'nillable' BOOL,'unique' BOOL,'restricted_picklist' BOOL,'calculated' BOOL,'defaulted_on_create' BOOL,'name_field' BOOL, 'relationship_name' VARCHAR , 'dependent_picklist' BOOL ,'controler_field' VARCHAR)"]];
    
    if (result == YES)
    {
        
        result = [self createTable:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS SFObjectFieldIndex ON SFObjectField (object_api_name, api_name, label)"]];
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
           
                BOOL OBJFLAG = FALSE;
                
                for (NSDictionary * tempdict in objectDefinition)
                {
                    NSArray * tempKeys = [tempdict allKeys];
                    
                    for (int k = 0; k < [tempKeys count]; k++)
                    {
                        if ([objectName isEqualToString:[tempKeys objectAtIndex:k]])
                        {
                            objectArray = [tempdict objectForKey:[tempKeys objectAtIndex:k]];
                            OBJFLAG = TRUE;
                            break;
                        }
                    }
                    if (OBJFLAG)
                        break;
                    
                }

                
                for (int m = 0; m < [objectArray count]; m++)
                {
                    NSDictionary * dictionary = [objectArray objectAtIndex:m];
                    NSArray * keys = [dictionary allKeys];
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
					               
					char * _objectName = [appDelegate convertStringIntoChar:objectName];
					
                    sqlite3_bind_text(bulkStmt, 1, _objectName, strlen(_objectName), SQLITE_TRANSIENT);
					
					char * _field = [appDelegate convertStringIntoChar:([obj objectForKey:FIELD] != nil)?[obj objectForKey:FIELD]:@""];
                    
                    sqlite3_bind_text(bulkStmt, 2, _field, strlen(_field), SQLITE_TRANSIENT);
					
					char * _length = [appDelegate convertStringIntoChar:([obj objectForKey:_LENGTH] != nil)?[obj objectForKey:_LENGTH]:@""];
                    
                    sqlite3_bind_text(bulkStmt, 3, _length, strlen(_length), SQLITE_TRANSIENT);
					
					char * _type = [appDelegate convertStringIntoChar:type];
                    
                    sqlite3_bind_text(bulkStmt, 4, _type, strlen(_type), SQLITE_TRANSIENT);
					
					char * _reference_to = [appDelegate convertStringIntoChar:([obj objectForKey:_REFERENCETO] != nil)?[obj objectForKey:_REFERENCETO]:@""];
                    
                    sqlite3_bind_text(bulkStmt, 5, _reference_to, strlen(_reference_to), SQLITE_TRANSIENT);
					
					char * _relationshipName = [appDelegate convertStringIntoChar:([obj objectForKey:_RELATIONSHIPNAME] != nil)?[obj objectForKey:_RELATIONSHIPNAME]:@""];
                    
                    sqlite3_bind_text(bulkStmt, 6, _relationshipName, strlen(_relationshipName), SQLITE_TRANSIENT);
					
					char * _label = [appDelegate convertStringIntoChar:label];
                    
                    sqlite3_bind_text(bulkStmt, 7, _label, strlen(_label), SQLITE_TRANSIENT);
					
					char * _emptyString = [appDelegate convertStringIntoChar:emptyString];
                    
                    sqlite3_bind_text(bulkStmt, 8, _emptyString, strlen(_emptyString), SQLITE_TRANSIENT);
                    
                    sqlite3_bind_text(bulkStmt, 9, _emptyString, strlen(_emptyString), SQLITE_TRANSIENT);
                    
                    sqlite3_bind_text(bulkStmt, 10, _emptyString, strlen(_emptyString), SQLITE_TRANSIENT);
                    
                    sqlite3_bind_text(bulkStmt, 11, _emptyString, strlen(_emptyString), SQLITE_TRANSIENT);
                    
                    sqlite3_bind_text(bulkStmt, 12, _emptyString, strlen(_emptyString), SQLITE_TRANSIENT);
					
					char * _nameField = [appDelegate convertStringIntoChar:([obj objectForKey:_NAMEFIELD] != nil)?[obj objectForKey:_NAMEFIELD]:@""];
                    
                    sqlite3_bind_text(bulkStmt, 13, _nameField, strlen(_nameField), SQLITE_TRANSIENT);
                    
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
        
        NSString * objectName = @"";
        
                
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@') VALUES (?1,    ?2, ?3, ?4)", SFREFERENCETO, MOBJECT_API_NAME, _MFIELD_API_NAME, MREFERENCE_TO, MLOCAL_ID];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);
        

        
        for (int i = 0; i < [object count]; i++)
        {
            NSDictionary * dict = [object objectAtIndex:i];
            
            objectName = ([dict valueForKey:OBJECT] != nil)?[dict valueForKey:OBJECT]:@"";
              
			BOOL OBJFLAG = FALSE;
            
            NSArray * objectArray = [[[NSArray alloc] init] autorelease];
            for (NSDictionary * tempdict in objectDefinition)
            {
                NSArray * tempKeys = [tempdict allKeys];
                
                for (int k = 0; k < [tempKeys count]; k++)
                {
                    if ([objectName isEqualToString:[tempKeys objectAtIndex:k]])
                    {
                        objectArray = [tempdict objectForKey:[tempKeys objectAtIndex:k]];
                        OBJFLAG = TRUE;
                        break;
                    }
                }
                if (OBJFLAG)
                    break;
                
            }
            

            
            NSArray * fieldArray = [[[NSArray alloc] init] autorelease];
            for (int m = 0; m < [objectArray count]; m++)
            {
                NSDictionary * dictionary = [objectArray objectAtIndex:m];
                 NSArray * keys = [dictionary allKeys];
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
                    SMLog(@"%@", referenceName);
                    if (!referenceName)
                        referenceName = @"";
                
                    if (!([referenceName isEqualToString:@""]))
                    {
						char * _objectName = [appDelegate convertStringIntoChar:objectName];
						
                        sqlite3_bind_text(bulkStmt, 1, _objectName, strlen(_objectName), SQLITE_TRANSIENT);
						
						char * _field = [appDelegate convertStringIntoChar:([obj objectForKey:FIELD] != nil)?[obj objectForKey:FIELD]:@""];
                        
                        sqlite3_bind_text(bulkStmt, 2, _field, strlen(_field), SQLITE_TRANSIENT);
						
						char * _reference_to = [appDelegate convertStringIntoChar:([obj objectForKey:_REFERENCETO] != nil)?[obj objectForKey:_REFERENCETO]:@""];
                        
                        sqlite3_bind_text(bulkStmt, 3, _reference_to, strlen(_reference_to), SQLITE_TRANSIENT);
                        
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
    
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFRecordType ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0) ,'record_type_id' VARCHAR,'object_api_name' VARCHAR,'record_type' VARCHAR , 'recordtype_label' VARCHAR)"]];
    
    if (result == YES)
    {
        NSString * objectName = @"";
        int id_Value =  1;
                
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@') VALUES (?1, ?2,   ?3, ?4)", SFRECORDTYPE, MRECORD_TYPE_ID, MOBJECT_API_NAME, MRECORDTYPE_LABEL, MLOCAL_ID];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);
        
        for (int i = 0; i < [object count]; i++)
        {
            
            NSDictionary * dict = [object objectAtIndex:i];
            
            objectName = ([dict valueForKey:OBJECT] != nil)?[dict valueForKey:OBJECT]:@"";
            
					
            BOOL OBJFLAG = FALSE;
            
            NSArray * objectArray = [[[NSArray alloc] init] autorelease];
            for (NSDictionary * tempdict in objectDefinition)
            {
                NSArray * tempKeys = [tempdict allKeys];
                
                for (int k = 0; k < [tempKeys count]; k++)
                {
                    if ([objectName isEqualToString:[tempKeys objectAtIndex:k]])
                    {
                        objectArray = [tempdict objectForKey:[tempKeys objectAtIndex:k]];
                        OBJFLAG = TRUE;
                        break;
                    }
                }
                if (OBJFLAG)
                    break;
                
            }
            

            
            NSMutableArray * propertyArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
            for (int m = 0; m < [objectArray count]; m++)
            {
                NSDictionary * dictionary = [objectArray objectAtIndex:m];
                NSArray * keys = [dictionary allKeys];
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
                NSArray * keys = [dict allKeys];
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
						char * _recordKeys = [appDelegate convertStringIntoChar:[recordKeys objectAtIndex:r]];
                        
                        sqlite3_bind_text(bulkStmt, 1, _recordKeys, strlen(_recordKeys), SQLITE_TRANSIENT);
						
						char * _objectName = [appDelegate convertStringIntoChar:objectName];
                        
                        sqlite3_bind_text(bulkStmt, 2, _objectName, strlen(_objectName), SQLITE_TRANSIENT);
						
						char * _recordValues = [appDelegate convertStringIntoChar:[recordValues objectAtIndex:r]];
                        
                        sqlite3_bind_text(bulkStmt, 3, _recordValues, strlen(_recordValues), SQLITE_TRANSIENT);
                        
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
                
                BOOL OBJFLAG = FALSE;
                                
                NSArray * objectArray = [[[NSArray alloc] init] autorelease];
                for (NSDictionary * tempdict in objectDefintion)
                {
                    NSArray * tempKeys = [tempdict allKeys];
                    
                    for (int k = 0; k < [tempKeys count]; k++)
                    {
                        if ([objectName isEqualToString:[tempKeys objectAtIndex:k]])
                        {
                            objectArray = [tempdict objectForKey:[tempKeys objectAtIndex:k]];
                            OBJFLAG = TRUE;
                            break;
                        }
                    }
                    if (OBJFLAG)
                        break;
                    
                }

                NSMutableArray * propertyArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
                
                for (int m = 0; m < [objectArray count]; m++)
                {
                    NSDictionary * dictionary = [objectArray objectAtIndex:m];
                    NSArray * keys = [dictionary allKeys];
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
                    NSArray * keys = [dict allKeys];
                    for (int j = 0; j < [keys count]; j++)
                    {
                        if ( [[keys objectAtIndex:j] isEqualToString:MOBJECTDEFINITION])
                        {
                            objDef = [dict objectForKey:MOBJECTDEFINITION];
                            break;
                        }
                    }            
                }
                
				char * _keyprefix = [appDelegate convertStringIntoChar:([objDef objectForKey:_MKEYPREFIX]!= nil)?[objDef objectForKey:_MKEYPREFIX]:@""];
				
                sqlite3_bind_text(bulkStmt, 1, _keyprefix, strlen(_keyprefix), SQLITE_TRANSIENT);
				
				char * _label = [appDelegate convertStringIntoChar:([objDef objectForKey:_LABEL]!= nil)?[objDef objectForKey:_LABEL]:@""];
                
                sqlite3_bind_text(bulkStmt, 2, _label, strlen(_label), SQLITE_TRANSIENT);
				
				char * _plurallabel = [appDelegate convertStringIntoChar:([objDef objectForKey:_MPLURALLABEL]!= nil)?[objDef objectForKey:_MPLURALLABEL]:@""];
                
                sqlite3_bind_text(bulkStmt, 3, _plurallabel, strlen(_plurallabel), SQLITE_TRANSIENT);
				
				char * _objectName = [appDelegate convertStringIntoChar:objectName];
                
                sqlite3_bind_text(bulkStmt, 4, _objectName, strlen(_objectName), SQLITE_TRANSIENT);
                
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
                
                
				BOOL OBJFLAG = FALSE;
                
                NSArray * objectArray = [[[NSArray alloc] init] autorelease];
                for (NSDictionary * tempdict in objectDefinition)
                {
                    NSArray * tempKeys = [tempdict allKeys];
                    
                    for (int k = 0; k < [tempKeys count]; k++)
                    {
                        if ([objectName isEqualToString:[tempKeys objectAtIndex:k]])
                        {
                            objectArray = [tempdict objectForKey:[tempKeys objectAtIndex:k]];
                            OBJFLAG = TRUE;
                            break;
                        }
                    }
                    if (OBJFLAG)
                        break;
                    
                }
                
                NSMutableArray * propertyArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
                for (int m = 0; m < [objectArray count]; m++)
                {
                    NSDictionary * dictionary = [objectArray objectAtIndex:m];
                    NSArray * keys = [dictionary allKeys];
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
                    NSArray * keys = [dict allKeys];
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
					char * _objectName = [appDelegate convertStringIntoChar:objectName];
					
                    sqlite3_bind_text(bulkStmt, 1, _objectName, strlen(_objectName), SQLITE_TRANSIENT);
					
					char * _masterDetailKeys = [appDelegate convertStringIntoChar:[masterDetailKeys objectAtIndex:val]];
                    
                    sqlite3_bind_text(bulkStmt, 2, _masterDetailKeys, strlen(_masterDetailKeys), SQLITE_TRANSIENT);
					
					char * _emptyString = [appDelegate convertStringIntoChar:emptyString];
                    
                    sqlite3_bind_text(bulkStmt, 3, _emptyString, strlen(_emptyString), SQLITE_TRANSIENT);
					
					char * _mastetDetaiValues = [appDelegate convertStringIntoChar:[mastetDetaiValues objectAtIndex:val]];
                    
                    sqlite3_bind_text(bulkStmt, 4, _mastetDetaiValues, strlen(_mastetDetaiValues), SQLITE_TRANSIENT);
                    
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
        
        BOOL OBJFLAG = FALSE;
        
        for (NSDictionary * tempdict in columns)
        {
            NSArray * tempKeys = [tempdict allKeys];
            
            for (int k = 0; k < [tempKeys count]; k++)
            {
                if ([objectName isEqualToString:[tempKeys objectAtIndex:k]])
                {
                    objectArray = [tempdict objectForKey:[tempKeys objectAtIndex:k]];
                    OBJFLAG = TRUE;
                    break;
                }
            }
            if (OBJFLAG)
                break;
            
        }
        
        NSMutableArray * fieldArray = [[[NSMutableArray alloc] init] autorelease];
        for (int m = 0; m < [objectArray count]; m++)
        {
            NSDictionary * dictionary = [objectArray objectAtIndex:m];
            NSArray * keys = [dictionary allKeys];
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
            SMLog(@"%@", objectName);
        }
        char *err;
        queryStatement =[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", objectName];
        if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
            SMLog(@"Failed to drop");
            continue;
        }
        
        queryStatement = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ VARCHAR PRIMARY KEY  NOT NULL)", objectName, MLOCAL_ID];
        if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
            SMLog(@"Failed to drop");
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
            SMLog(@"Failed to drop");
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
            
            NSString * process_id = ( [dict objectForKey:MPROCESS_UNIQUE_ID] != nil)?[dict objectForKey:MPROCESS_UNIQUE_ID]:@"";
            process_id = [process_id stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString * process_name =  ([dict objectForKey:MPROCESS_NAME] != nil)?[dict objectForKey:MPROCESS_NAME]:@"";
            process_name = [process_name stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            
            NSString * queryStatement = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@') VALUES ('%@', '%@', '%@', '%@', '%@', '%d')", SFPROCESS, MPROCESS_ID, MPROCESS_TYPE, MPROCESS_NAME, 
                                         MPROCESS_DESCRIPTION, @"page_layout_id", MLOCAL_ID, 
                                         process_id, 
                                         process_type, 
                                         process_name, 
                                         str, ([dict objectForKey:MPAGE_LAYOUT_ID] != nil)?[dict objectForKey:MPAGE_LAYOUT_ID]:@"", ++id_value];         
            
            char * err;
            int ret = synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err);
            if (ret != SQLITE_OK)
            {
                if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
                    [MyPopoverDelegate performSelector:@selector(throwException)];
                SMLog(@"Failed to insert");
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
            process_id = [process_id stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            
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
                SMLog(@"Failed to insert");
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
                
				char * _processId = [appDelegate convertStringIntoChar:processId];
				
                sqlite3_bind_text(bulkStmt, 1, _processId, strlen(_processId), SQLITE_TRANSIENT);
				
				char * _layoutId = [appDelegate convertStringIntoChar:([dict objectForKey:MLAYOUT_ID] != nil)?[dict objectForKey:MLAYOUT_ID]:@""];
                
                sqlite3_bind_text(bulkStmt, 2, _layoutId, strlen(_layoutId), SQLITE_TRANSIENT);
				
				char * _object_name = [appDelegate convertStringIntoChar:([dict objectForKey:MOBJECT_NAME] != nil)?[dict objectForKey:MOBJECT_NAME]:@""];
                
                sqlite3_bind_text(bulkStmt, 3, _object_name, strlen(_object_name), SQLITE_TRANSIENT);
				
				char * _expressionId = [appDelegate convertStringIntoChar:([dict objectForKey:MEXPRESSION_ID] != nil)?[dict objectForKey:MEXPRESSION_ID]:@""];
                
                sqlite3_bind_text(bulkStmt, 4, _expressionId, strlen(_expressionId), SQLITE_TRANSIENT);
				
				char * _objectMappingId = [appDelegate convertStringIntoChar:([dict objectForKey:MOBJECT_MAPPING_ID] != nil)?[dict objectForKey:MOBJECT_MAPPING_ID]:@""];
                
                sqlite3_bind_text(bulkStmt, 5, _objectMappingId, strlen(_objectMappingId), SQLITE_TRANSIENT);
				
				char * _componentType = [appDelegate convertStringIntoChar:([dict objectForKey:MCOMPONENT_TYPE] != nil)?[dict objectForKey:MCOMPONENT_TYPE]:@""];
                
                sqlite3_bind_text(bulkStmt, 6, _componentType, strlen(_componentType), SQLITE_TRANSIENT);
				
				char * _parentcolumn = [appDelegate convertStringIntoChar:([dict objectForKey:MPARENT_COLUMN] != nil)?[dict objectForKey:MPARENT_COLUMN]:@""];
                
                sqlite3_bind_text(bulkStmt, 7, _parentcolumn, strlen(_parentcolumn), SQLITE_TRANSIENT);
				
				char * _valueMappingId = [appDelegate convertStringIntoChar:([dict objectForKey:MVALUE_MAPPING_ID] != nil)?[dict objectForKey:MVALUE_MAPPING_ID]: @""];
                
                sqlite3_bind_text(bulkStmt, 8, _valueMappingId, strlen(_valueMappingId), SQLITE_TRANSIENT);
				
				char * _parentObject = [appDelegate convertStringIntoChar:([dict objectForKey:MPARENT_OBJECT] != nil)?[dict objectForKey:MPARENT_OBJECT]: @""];
                
                sqlite3_bind_text(bulkStmt, 9, _parentObject, strlen(_parentObject), SQLITE_TRANSIENT);
                
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
                
				char * _processId = [appDelegate convertStringIntoChar:([dict objectForKey:MPROCESS_ID] != nil)?[dict objectForKey:MPROCESS_ID]:@""];
				
                sqlite3_bind_text(bulkStmt, 1, _processId, strlen(_processId), SQLITE_TRANSIENT);
				
				char * _layoutId = [appDelegate convertStringIntoChar:([dict objectForKey:MLAYOUT_ID] != nil)?[dict objectForKey:MLAYOUT_ID]:@""];
                
                sqlite3_bind_text(bulkStmt, 2, _layoutId, strlen(_layoutId), SQLITE_TRANSIENT);
				
				char * _targetObjectName = [appDelegate convertStringIntoChar:([dict objectForKey:MTARGET_OBJECT_NAME] != nil)?[dict objectForKey:MTARGET_OBJECT_NAME]:@""];
                
                sqlite3_bind_text(bulkStmt, 3, _targetObjectName, strlen(_targetObjectName), SQLITE_TRANSIENT);
				
				char * _sourceObjectName = [appDelegate convertStringIntoChar:([dict objectForKey:MSOURCE_OBJECT_NAME] != nil)?[dict objectForKey:MSOURCE_OBJECT_NAME]:@""];
                
                sqlite3_bind_text(bulkStmt, 4, _sourceObjectName, strlen(_sourceObjectName), SQLITE_TRANSIENT);
				
                char * _expressionId = [appDelegate convertStringIntoChar:([dict objectForKey:MEXPRESSION_ID] != nil)?[dict objectForKey:MEXPRESSION_ID]:@""];
                
                sqlite3_bind_text(bulkStmt, 5, _expressionId, strlen(_expressionId), SQLITE_TRANSIENT);
				
				char * _objectMappingId = [appDelegate convertStringIntoChar:([dict objectForKey:MOBJECT_MAPPING_ID] != nil)?[dict objectForKey:MOBJECT_MAPPING_ID]:@""];
                
                sqlite3_bind_text(bulkStmt, 6, _objectMappingId, strlen(_objectMappingId), SQLITE_TRANSIENT);
				
				char * _componentType = [appDelegate convertStringIntoChar:([dict objectForKey:MCOMPONENT_TYPE] != nil)?[dict objectForKey:MCOMPONENT_TYPE]:@""];
                
                sqlite3_bind_text(bulkStmt, 7, _componentType, strlen(_componentType), SQLITE_TRANSIENT);
				
				char * _parentColumn = [appDelegate convertStringIntoChar:([dict objectForKey:MPARENT_COLUMN] != nil)?[dict objectForKey:MPARENT_COLUMN]:@""];
                
                sqlite3_bind_text(bulkStmt, 8, _parentColumn, strlen(_parentColumn), SQLITE_TRANSIENT);
				
				char * _valueMappingId = [appDelegate convertStringIntoChar:([dict objectForKey:MVALUE_MAPPING_ID] != nil)?[dict objectForKey:MVALUE_MAPPING_ID]:@""];
                
                sqlite3_bind_text(bulkStmt, 9, _valueMappingId, strlen(_valueMappingId), SQLITE_TRANSIENT);
				
				char * _emptyString = [appDelegate convertStringIntoChar:emptyString];
                
                sqlite3_bind_text(bulkStmt, 10, _emptyString, strlen(_emptyString), SQLITE_TRANSIENT);
                
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
    SMLog(@"SAMMAN insertvaluesToPicklist Processing starts: %@", [NSDate date]);
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
				
				if ([objectName isEqualToString:@"SVMXC__Service_Order__c"])
				{
					NSLog(@"SVMXC__Service_Order__c");
				}
                
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
							
							char * _objectName = [appDelegate convertStringIntoChar:objectName];
							
                            sqlite3_bind_text(bulkStmt, 1, _objectName, strlen(_objectName), SQLITE_TRANSIENT);
							
							char * _fieldName = [appDelegate convertStringIntoChar:fieldName];
                            
                            sqlite3_bind_text(bulkStmt, 2, _fieldName, strlen(_fieldName), SQLITE_TRANSIENT);
							
							char * _pickLabel = [appDelegate convertStringIntoChar:pickLabel];
                            
                            sqlite3_bind_text(bulkStmt, 3, _pickLabel, strlen(_pickLabel), SQLITE_TRANSIENT);
							
							char * _pickValue = [appDelegate convertStringIntoChar:pickValue];
                            
                            sqlite3_bind_text(bulkStmt, 4, _pickValue, strlen(_pickValue), SQLITE_TRANSIENT);
							
							char * _defautPickValue = [appDelegate convertStringIntoChar:defautPickValue];
                            
                            sqlite3_bind_text(bulkStmt, 5, _defautPickValue, strlen(_defautPickValue), SQLITE_TRANSIENT);
                            
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
    SMLog(@"SAMMAN insertvaluesToPicklist Processing ends: %@", [NSDate date]);
}

- (void) insertValuesInToRTPicklistTableForObject:(id)objects Values:(NSMutableDictionary *)recordTypeDict
{
    int id_value = 0;
    
    SMLog(@"SAMMAN insertValuesInToRTPicklistTableForObject Processing starts: %@", [NSDate date]);
    
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
                            
							char * _objectName = [appDelegate convertStringIntoChar:objectName];
							
                            sqlite3_bind_text(bulkStmt, 1, _objectName, strlen(_objectName), SQLITE_TRANSIENT);
							
							char * _api_name = [appDelegate convertStringIntoChar:api_name];
                            
                            sqlite3_bind_text(bulkStmt, 2, _api_name, strlen(_api_name), SQLITE_TRANSIENT);
							
							char * _label = [appDelegate convertStringIntoChar:label];
                            
                            sqlite3_bind_text(bulkStmt, 3, _label, strlen(_label), SQLITE_TRANSIENT);
							
							char * _value = [appDelegate convertStringIntoChar:value];
                            
                            sqlite3_bind_text(bulkStmt, 4, _value, strlen(_value), SQLITE_TRANSIENT);
							
							char * _defaultLabel = [appDelegate convertStringIntoChar:defaultLabel];
                            
                            sqlite3_bind_text(bulkStmt, 5, _defaultLabel, strlen(_defaultLabel), SQLITE_TRANSIENT);
							
							char * _defaultValue = [appDelegate convertStringIntoChar:defaultValue];
                            
                            sqlite3_bind_text(bulkStmt, 6, _defaultValue, strlen(_defaultValue), SQLITE_TRANSIENT);
							
							char * _recordTypeName = [appDelegate convertStringIntoChar:recordTypeName];
                            
                            sqlite3_bind_text(bulkStmt, 7, _recordTypeName, strlen(_recordTypeName), SQLITE_TRANSIENT);
							
							char * _recordTypeID = [appDelegate convertStringIntoChar:recordTypeID];
                            
                            sqlite3_bind_text(bulkStmt, 8, _recordTypeID, strlen(_recordTypeID), SQLITE_TRANSIENT);
							
							char * _recordTypeLayoutId = [appDelegate convertStringIntoChar:recordTypeLayoutId];
                            
                            sqlite3_bind_text(bulkStmt, 9, _recordTypeLayoutId, strlen(_recordTypeLayoutId), SQLITE_TRANSIENT);
                            
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
    
    SMLog(@"SAMMAN insertValuesInToRTPicklistTableForObject Processing starts: %@", [NSDate date]);
    
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
				
				char * _expressionId = [appDelegate convertStringIntoChar:([dict objectForKey:MEXPRESSION_ID] != nil)?[dict objectForKey:MEXPRESSION_ID]:@""];
                
                sqlite3_bind_text(bulkStmt, 1, _expressionId, strlen(_expressionId), SQLITE_TRANSIENT);
				
				char * _expressionName = [appDelegate convertStringIntoChar:([dict objectForKey:MEXPRESSION_NAME] != nil)?[dict objectForKey:MEXPRESSION_NAME]:@""];
                
                sqlite3_bind_text(bulkStmt, 2, _expressionName, strlen(_expressionName), SQLITE_TRANSIENT);
				
				char * _advanceExpression = [appDelegate convertStringIntoChar:([dict objectForKey:MADVANCE_EXPRESSION] != nil)?[dict objectForKey:MADVANCE_EXPRESSION]:@"" ];
                
                sqlite3_bind_text(bulkStmt, 3, _advanceExpression, strlen(_advanceExpression), SQLITE_TRANSIENT);
                
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
				
				char * _expressionId = [appDelegate convertStringIntoChar:([dict objectForKey:MEXPRESSION_ID] != nil)?[dict objectForKey:MEXPRESSION_ID]:@""];
                
                sqlite3_bind_text(bulkStmt, 1, _expressionId, strlen(_expressionId), SQLITE_TRANSIENT);
				
				char * _sequence = [appDelegate convertStringIntoChar:([dict objectForKey:MSEQUENCE] != nil)?[dict objectForKey:MSEQUENCE]:@""];
                
                sqlite3_bind_text(bulkStmt, 2, _sequence, strlen(_sequence), SQLITE_TRANSIENT);
				
				char * _sourceFieldName = [appDelegate convertStringIntoChar:([dict objectForKey:MSOURCE_FIELD_NAME] != nil)?[dict objectForKey:MSOURCE_FIELD_NAME]:@""];
                
                sqlite3_bind_text(bulkStmt, 3, _sourceFieldName, strlen(_sourceFieldName), SQLITE_TRANSIENT);
				
				char * _value = [appDelegate convertStringIntoChar:([dict objectForKey:MVALUEM] != nil)?[dict objectForKey:MVALUEM]:@""];
                
                sqlite3_bind_text(bulkStmt, 4, _value, strlen(_value), SQLITE_TRANSIENT);
				
				char * _operator = [appDelegate convertStringIntoChar:([dict objectForKey:MOPERATOR] != nil)?[dict objectForKey:MOPERATOR]:@""];
                
                sqlite3_bind_text(bulkStmt, 5, _operator, strlen(_operator), SQLITE_TRANSIENT);
                
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
				
				char * _objectMappingId = [appDelegate convertStringIntoChar:([dict objectForKey:MOBJECT_MAPPING_ID] != nil)?[dict objectForKey:MOBJECT_MAPPING_ID]:@""];
                
                sqlite3_bind_text(bulkStmt, 1, _objectMappingId, strlen(_objectMappingId), SQLITE_TRANSIENT);
				
				char * _sourceObjectName = [appDelegate convertStringIntoChar:([dict objectForKey:MSOURCE_OBJECT_NAME] != nil)?[dict objectForKey:MSOURCE_OBJECT_NAME]:@""];

                
                sqlite3_bind_text(bulkStmt, 2, _sourceObjectName, strlen(_sourceObjectName), SQLITE_TRANSIENT);
				
				char * _targetObjectName = [appDelegate convertStringIntoChar:([dict objectForKey:MTARGET_OBJECT_NAME] != nil)?[dict objectForKey:MTARGET_OBJECT_NAME]:@""];
                
                sqlite3_bind_text(bulkStmt, 3, _targetObjectName, strlen(_targetObjectName), SQLITE_TRANSIENT);
                
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
        
        NSString * bulkQueryStmt = @"";
        bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@', '%@') VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7)", SFOBJECTMAPCOMPONENT, MOBJECT_MAPPING_ID , MSOURCE_FIELD_NAME, MTARGET_FIELD_NAME, MMAPPING_VALUE, MMAPPING_COMP_TYPE, MMAPPING_VALUE_FLAG, MLOCAL_ID];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);
        
        
        if (ret_value == SQLITE_OK)
        {
            for (int i = 0; i < [sfObject_com count]; i++)
            {
                NSDictionary * dict_ = [sfObject_com objectAtIndex:i];
                NSString * target_field_name = @"";
                NSString * mappingValue = @"";
                value = @"";
                
                target_field_name = ([dict_ objectForKey:@"target_field_name"] != nil)?[dict_ objectForKey:@"target_field_name"]:@"";
                mappingValue = ([dict_ objectForKey:@"mapping_value"] != nil)?[dict_ objectForKey:@"mapping_value"]:@"";
                
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
                
				
				char * _objectMappingid = [appDelegate convertStringIntoChar:([dict_ objectForKey:MOBJECT_MAPPING_ID] != nil)?[dict_ objectForKey:MOBJECT_MAPPING_ID]:@""];
                
                sqlite3_bind_text(bulkStmt, 1, _objectMappingid, strlen(_objectMappingid), SQLITE_TRANSIENT);
				
				char * _sourceFieldName = [appDelegate convertStringIntoChar:([dict_ objectForKey:MSOURCE_FIELD_NAME] != nil)?[dict_ objectForKey:MSOURCE_FIELD_NAME]:@""];
                
                sqlite3_bind_text(bulkStmt, 2, _sourceFieldName, strlen(_sourceFieldName), SQLITE_TRANSIENT);
				
				char * _targetFieldName = [appDelegate convertStringIntoChar:([dict_ objectForKey:MTARGET_FIELD_NAME] != nil)?[dict_ objectForKey:MTARGET_FIELD_NAME]:@""];
                
                sqlite3_bind_text(bulkStmt, 3, _targetFieldName, strlen(_targetFieldName), SQLITE_TRANSIENT);
				
				char * _mappingValue = [appDelegate convertStringIntoChar:([dict_ objectForKey:MMAPPING_VALUE] != nil)?[dict_ objectForKey:MMAPPING_VALUE]:@""];
				
                sqlite3_bind_text(bulkStmt, 4, _mappingValue, strlen(_mappingValue), SQLITE_TRANSIENT);
				
				char * _value = [appDelegate convertStringIntoChar:value];
                
                sqlite3_bind_text(bulkStmt, 5, _value, strlen(_value), SQLITE_TRANSIENT);
				
				char * _flag = [appDelegate convertStringIntoChar:flag];
                
                sqlite3_bind_text(bulkStmt, 6, _flag, strlen(_flag), SQLITE_TRANSIENT);
                
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
        result = [self createTable:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS SFNamedSearchIndex ON SFNamedSearch (default_lookup_column, object_name, is_default,is_standard)"]];

        
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
				
				char * _defaultLookupColumn = [appDelegate convertStringIntoChar:([nameSearchDict objectForKey:MDEFAULT_LOOKUP_COLUMN] != nil)?[nameSearchDict objectForKey:MDEFAULT_LOOKUP_COLUMN]:@""];
                
                sqlite3_bind_text(bulkStmt, 1, _defaultLookupColumn, strlen(_defaultLookupColumn), SQLITE_TRANSIENT);
				
				char * _objectName = [appDelegate convertStringIntoChar:([nameSearchDict objectForKey:MOBJECT_NAME] != nil)?[nameSearchDict objectForKey:MOBJECT_NAME]:@""];
                
                sqlite3_bind_text(bulkStmt, 2, _objectName, strlen(_objectName), SQLITE_TRANSIENT);
				
				char * _searchName = [appDelegate convertStringIntoChar:([nameSearchDict objectForKey:MSEARCH_NAME] != nil)?[nameSearchDict objectForKey:MSEARCH_NAME]:@""];
                
                sqlite3_bind_text(bulkStmt, 3, _searchName, strlen(_searchName), SQLITE_TRANSIENT);
				
				
				char * _searchType = [appDelegate convertStringIntoChar:([nameSearchDict objectForKey:MSEARCH_TYPE] != nil)?[nameSearchDict objectForKey:MSEARCH_TYPE]:@""];
                
                sqlite3_bind_text(bulkStmt, 4, _searchType, strlen(_searchType), SQLITE_TRANSIENT);
				
				
				char * _nameSearchID = [appDelegate convertStringIntoChar:([nameSearchDict objectForKey:MNAMED_SEARCHID] != nil)?[nameSearchDict objectForKey:MNAMED_SEARCHID]:@""];
                
                sqlite3_bind_text(bulkStmt, 5, _nameSearchID, strlen(_nameSearchID), SQLITE_TRANSIENT);
				
				char * _lookupRecords = [appDelegate convertStringIntoChar:([nameSearchDict objectForKey:MNO_OF_LOOKUP_RECORDS] != nil)?[nameSearchDict objectForKey:MNO_OF_LOOKUP_RECORDS]:@""];
                
                sqlite3_bind_text(bulkStmt, 6, _lookupRecords, strlen(_lookupRecords), SQLITE_TRANSIENT);
				
				char * _misDefault = [appDelegate convertStringIntoChar:([nameSearchDict objectForKey:MIS_DEFAULT] != nil)?[nameSearchDict objectForKey:MIS_DEFAULT]:@""];
                
                sqlite3_bind_text(bulkStmt, 7, _misDefault, strlen(_misDefault), SQLITE_TRANSIENT);
				
				char * _misStandard = [appDelegate convertStringIntoChar:([nameSearchDict objectForKey:MIS_STANDARD] != nil)?[nameSearchDict objectForKey:MIS_STANDARD]:@""];
                
                sqlite3_bind_text(bulkStmt, 8, _misStandard, strlen(_misStandard), SQLITE_TRANSIENT);
                
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
        result = [self createTable:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS SFNamedSearchComponentIndex ON SFNamedSearchComponent (field_name, search_object_field_type, sequence,field_type,field_relationship_name )"]];

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
				
				char * _expressionType = [appDelegate convertStringIntoChar:([nameSearchComp objectForKey:MEXPRESSION_TYPE] != nil)?[nameSearchComp objectForKey:MEXPRESSION_TYPE]:@""];
                
                sqlite3_bind_text(bulkStmt, 1, _expressionType, strlen(_expressionType), SQLITE_TRANSIENT);
				
				char * _fieldName = [appDelegate convertStringIntoChar:([nameSearchComp objectForKey:MFIELD_NAME] != nil)?[nameSearchComp objectForKey:MFIELD_NAME]:@""];
                
                sqlite3_bind_text(bulkStmt, 2, _fieldName, strlen(_fieldName), SQLITE_TRANSIENT);
				
				char * _namedSearch = [appDelegate convertStringIntoChar:([nameSearchComp objectForKey:MNAMED_SEARCH] != nil)?[nameSearchComp objectForKey:MNAMED_SEARCH]:@""];
                
                sqlite3_bind_text(bulkStmt, 3, _namedSearch, strlen(_namedSearch), SQLITE_TRANSIENT);
				
				char * _searchObjectField = [appDelegate convertStringIntoChar:([nameSearchComp objectForKey:MSEARCH_OBJECT_FIELD] != nil)?[nameSearchComp objectForKey:MSEARCH_OBJECT_FIELD]:@""];
                
                sqlite3_bind_text(bulkStmt, 4, _searchObjectField, strlen(_searchObjectField), SQLITE_TRANSIENT);
				
				char * _fieldType = [appDelegate convertStringIntoChar:([nameSearchComp objectForKey:MFIELD_TYPE] != nil)?[nameSearchComp objectForKey:MFIELD_TYPE]:@""];
                
                sqlite3_bind_text(bulkStmt, 5, _fieldType, strlen(_fieldType), SQLITE_TRANSIENT);
																		
				char * _relationshipName = [appDelegate convertStringIntoChar:relationshipName];														
                sqlite3_bind_text(bulkStmt, 6, _relationshipName, strlen(_relationshipName), SQLITE_TRANSIENT);
				
				char * _sequence = [appDelegate convertStringIntoChar:([nameSearchComp objectForKey:MSEQUENCE] != nil)?[nameSearchComp objectForKey:MSEQUENCE]:@""];
																		
                sqlite3_bind_text(bulkStmt, 7, _sequence, strlen(_sequence), SQLITE_TRANSIENT);
                
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
    
    SMLog(@"SAMMAN MetaSync insertValuesInToTagsTable starts: %@", [NSDate date]);
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
            
				char * _keys = [appDelegate convertStringIntoChar:[keys objectAtIndex:i]];
                
                sqlite3_bind_text(bulkStmt, 1, _keys, strlen(_keys),  SQLITE_TRANSIENT);
				
				char * _value = [appDelegate convertStringIntoChar:value];
                
                sqlite3_bind_text(bulkStmt, 2, _value, strlen(_value), SQLITE_TRANSIENT);
                
                sqlite3_bind_int(bulkStmt, 3, ++id_value);
                
                if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                {
                    printf("Commit Failed!\n");
                }
                
                sqlite3_reset(bulkStmt);                
            }
        }
    }
    SMLog(@"SAMMAN MetaSync insertValuesInToTagsTable ends: %@", [NSDate date]);
    appDelegate.initial_sync_status =  SYNC_MOBILE_DEVICE_SETTINGS;
    appDelegate.Sync_check_in = FALSE;
    [appDelegate.wsInterface metaSyncWithEventName:MOBILE_DEVICE_SETTINGS eventType:SYNC values:nil];
}

- (void) insertValuesInToSettingsTable:(NSMutableDictionary *)settingsDictionary
{
    SMLog(@"SAMMAN MetaSync insertValuesInToSettingsTable processing starts: %@", [NSDate date]);
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
				
				char * _keys = [appDelegate convertStringIntoChar:[keys objectAtIndex:i]];
                				
                sqlite3_bind_text(bulkStmt, 1, _keys, strlen(_keys),  SQLITE_TRANSIENT);
				
				char * _value = [appDelegate convertStringIntoChar:[values objectAtIndex:i]];
                
                sqlite3_bind_text(bulkStmt, 2, _value, strlen(_value), SQLITE_TRANSIENT);

				sqlite3_bind_int(bulkStmt, 3, ++id_value);
                
                if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                {
                    printf("Commit Failed!\n");
                }
                
                sqlite3_reset(bulkStmt);   
            }
        }
    }
    
    SMLog(@"SAMMAN MetaSync insertValuesInToSettingsTable processing ends: %@", [NSDate date]);
    //Radha - 24/March
    appDelegate.settingsDict = [self getSettingsDictionary];

    
    [self generatePDFSettings];
    
}

- (void) insertValuesInToSFWizardsTable:(NSDictionary *)wizardDict
{
    SMLog(@"SAMMAN MetaSync insertValuesInToSFWizardsTable: processing starts: %@", [NSDate date]);
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
				
				char * _objectName_temp = [appDelegate convertStringIntoChar:_objectName];
               
                sqlite3_bind_text(bulkStmt, 1, _objectName_temp, strlen(_objectName_temp), SQLITE_TRANSIENT);
				
				char * _WizardId = [appDelegate convertStringIntoChar:([dict objectForKey:MWIZARD_ID] != nil)?[dict objectForKey:MWIZARD_ID]:@""];
				
                sqlite3_bind_text(bulkStmt, 2, _WizardId, strlen(_WizardId), SQLITE_TRANSIENT);
				
				char * _expressionId = [appDelegate convertStringIntoChar:([dict objectForKey:MEXPRESSION_ID] != nil)?[dict objectForKey:MEXPRESSION_ID]:@""];
                
                sqlite3_bind_text(bulkStmt, 3, _expressionId, strlen(_expressionId), SQLITE_TRANSIENT);
				
				char * _wizardDescription = [appDelegate convertStringIntoChar:([dict objectForKey:MWIZARD_DESCRIPTION] != nil)?[dict objectForKey:MWIZARD_DESCRIPTION]:@""];
                
                sqlite3_bind_text(bulkStmt, 4, _wizardDescription, strlen(_wizardDescription), SQLITE_TRANSIENT);
				
				
				char * _wizardName = [appDelegate convertStringIntoChar:([dict objectForKey:MWIZARD_NAME] != nil)?[dict objectForKey:MWIZARD_NAME]:@""];
                
                sqlite3_bind_text(bulkStmt, 5, _wizardName, strlen(_wizardName), SQLITE_TRANSIENT);
                
                sqlite3_bind_int(bulkStmt, 6, ++id_value);
                
                if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                {
                    printf("Commit Failed!\n");
                }
                
                sqlite3_reset(bulkStmt);
            }
        }
    }
    
    result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFWizardComponent ('local_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , 'wizard_id' VARCHAR, 'action_id' VARCHAR, 'action_description' VARCHAR, 'expression_id' VARCHAR, 'process_id' VARCHAR, 'action_type' VARCHAR, 'perform_sync' VARCHAR,class_name VARCHAR, method_name VARCHAR)"]];
    if (result == YES)
    {
        NSArray * sfWizComponent = [wizardDict objectForKey:MSFW_wizard_steps];
        NSArray *customActionsArray = [wizardDict objectForKey:SFW_Custom_Actions];
        NSArray * sfProcess = [appDelegate.wsInterface.processDictionary objectForKey:@"SFMProcess"];
        
        id_value = 0;
        NSString * wProcessId = @"";
        
        NSString * emptyString = @"";
        
        
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@') VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10)", SFWIZARDCOMPONENT, MWIZARD_ID, MACTION_ID, MACTION_DESCRIPTION, MEXPRESSION_ID, MPROCESS_ID, MACTION_TYPE, MLOCAL_ID,MPERFORM_SYNC, @"class_name",@"method_name"];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);
        
        if (ret_value == SQLITE_OK)
        {
            for (int i = 0; i < [sfWizComponent count]; i++)
            {
                wProcessId = @"";
                
                NSDictionary * comp_dict = [sfWizComponent objectAtIndex:i];
                NSString * processId = [comp_dict objectForKey:@"process_id"]; 
                NSDictionary *customDict = nil;
                if(processId != nil)
                {
                    for(NSDictionary *dict in customActionsArray)
                    {
                        NSString *customProcessId = [dict objectForKey:@"Id"];
                        if([customProcessId isEqualToString:processId])
                        {
                            customDict = dict;
                            break;
                        }
                    }
                }
                NSString *className = nil; 
                NSString *methodName = nil;
                if(customDict != nil)
                {
                    className = [customDict objectForKey:@"class_name"];
                    methodName = [customDict objectForKey:@"method_name"];
                }
                BOOL isCustomAction = NO;
                if((className  != nil) || (methodName != nil))
                    isCustomAction = YES;
                className = (className != nil) ? className : @"";
                methodName = (methodName != nil) ? methodName : @"";
                
                NSString * wizard_processId = ([comp_dict objectForKey:MPROCESS_ID] != nil)?[comp_dict objectForKey:MPROCESS_ID]:@"";
                
                SMLog(@"%@", wizard_processId);
                
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
                NSString *performSync = [comp_dict objectForKey:MPERFORM_SYNC];
				
				
				char * _wizardId = [appDelegate convertStringIntoChar:([comp_dict objectForKey:MWIZARD_ID] != nil)?[comp_dict objectForKey:MWIZARD_ID]:@""];
				
                sqlite3_bind_text(bulkStmt, 1, _wizardId, strlen(_wizardId), SQLITE_TRANSIENT);
				
				char * _emptyString = [appDelegate convertStringIntoChar:emptyString];
                
                sqlite3_bind_text(bulkStmt, 2, _emptyString, strlen(_emptyString), SQLITE_TRANSIENT);
				
				char * _wizardStepName = [appDelegate convertStringIntoChar:([comp_dict objectForKey:MWIZARD_STEP_NAME]!= nil)?[comp_dict objectForKey:MWIZARD_STEP_NAME]:@""];
                
                sqlite3_bind_text(bulkStmt, 3, _wizardStepName, strlen(_wizardStepName), SQLITE_TRANSIENT);
				
				char * _expressionId = [appDelegate convertStringIntoChar:([comp_dict objectForKey:MEXPRESSION_ID] != nil)?[comp_dict objectForKey:MEXPRESSION_ID]:@""];
                
                sqlite3_bind_text(bulkStmt, 4, _expressionId, strlen(_expressionId), SQLITE_TRANSIENT);
				
				char * _wProcessId = [appDelegate convertStringIntoChar:wProcessId];
                
                sqlite3_bind_text(bulkStmt, 5, _wProcessId, strlen(_wProcessId), SQLITE_TRANSIENT);
                if(isCustomAction)
					
                    sqlite3_bind_text(bulkStmt, 6, [SFW_Custom_Actions UTF8String], [SFW_Custom_Actions length], SQLITE_TRANSIENT);
                else
                    sqlite3_bind_text(bulkStmt, 6, [SFM UTF8String], [SFM length], SQLITE_TRANSIENT);
                
                sqlite3_bind_int(bulkStmt, 7, ++id_value);
				char * _performSync = [appDelegate convertStringIntoChar:performSync];
                
                sqlite3_bind_text(bulkStmt, 8, _performSync, strlen(_performSync), SQLITE_TRANSIENT);
				
				char * _className = [appDelegate convertStringIntoChar:className];
				
                sqlite3_bind_text(bulkStmt, 9, _className, strlen(_className), SQLITE_TRANSIENT);
				
				char * _methodName = [appDelegate convertStringIntoChar:methodName];
				
                sqlite3_bind_text(bulkStmt, 10, _methodName, strlen(_methodName), SQLITE_TRANSIENT);
                
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
			
			
			char * _expressionId = [appDelegate convertStringIntoChar:([dict objectForKey:MEXPRESSION_ID] != nil)?[dict objectForKey:MEXPRESSION_ID]:@""];
            
            sqlite3_bind_text(bulkStmt, 1, _expressionId, strlen(_expressionId), SQLITE_TRANSIENT);
			
			char * _expressionName = [appDelegate convertStringIntoChar:([dict objectForKey:MEXPRESSION_NAME] != nil)?[dict objectForKey:MEXPRESSION_NAME]:@""];
            
            sqlite3_bind_text(bulkStmt, 2, _expressionName, strlen(_expressionName), SQLITE_TRANSIENT);
			
			char * _advanceExpression = [appDelegate convertStringIntoChar:([dict objectForKey:MADVANCE_EXPRESSION] != nil)?[dict objectForKey:MADVANCE_EXPRESSION]:@""];
            
            sqlite3_bind_text(bulkStmt, 3, _advanceExpression, strlen(_advanceExpression), SQLITE_TRANSIENT);
            
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
			
			char * _expressionId = [appDelegate convertStringIntoChar:([dict objectForKey:MEXPRESSION_ID] != nil)?[dict objectForKey:MEXPRESSION_ID]:@""];
        
            sqlite3_bind_text(bulkStmt, 1, _expressionId, strlen(_expressionId), SQLITE_TRANSIENT);
			
			char * _sequence = [appDelegate convertStringIntoChar:([dict objectForKey:MSEQUENCE] != nil)?[dict objectForKey:MSEQUENCE]:@""];
            
            sqlite3_bind_text(bulkStmt, 2, _sequence, strlen(_sequence), SQLITE_TRANSIENT);
			
			
			char * _sourceFieldName = [appDelegate convertStringIntoChar:([dict objectForKey:MSOURCE_FIELD_NAME] != nil)?[dict objectForKey:MSOURCE_FIELD_NAME]:@""];
            
            sqlite3_bind_text(bulkStmt, 3, _sourceFieldName, strlen(_sourceFieldName), SQLITE_TRANSIENT);
			
			char * _value = [appDelegate convertStringIntoChar:([dict objectForKey:MVALUEM] != nil)?[dict objectForKey:MVALUEM]:@""];
            
            sqlite3_bind_text(bulkStmt, 4, _value, strlen(_value), SQLITE_TRANSIENT);
			
			char * _operator = [appDelegate convertStringIntoChar:([dict objectForKey:MOPERATOR] != nil)?[dict objectForKey:MOPERATOR]:@""];
            
            sqlite3_bind_text(bulkStmt, 5, _operator, strlen(_operator), SQLITE_TRANSIENT);
            
            sqlite3_bind_int(bulkStmt, 6, ++id_value);
            
            if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
            {
                printf("Commit Failed!\n");
            }
            
            sqlite3_reset(bulkStmt);
        }
    }   
    SMLog(@"SAMMAN MetaSync insertValuesInToSFWizardsTable: processing ends: %@", [NSDate date]);
    
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
            SMLog(@"Failed to insert");
        }
    }
}

- (void) updateUserTable:(NSString *)UserId Name:(NSString*)name
{
    if(appDelegate == nil)
        appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
    NSString * queryStatement = [NSString stringWithFormat:@"SELECT Name,Id FROM User Where Username='%@'",appDelegate.username];
    sqlite3_stmt * stmt;
    BOOL flag=FALSE;
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * _name = (char *) synchronized_sqlite3_column_text(stmt, 0);
            if ((_name != nil) && strlen(_name))
            {
                flag=TRUE;
            }
            
            char * _id = (char *) synchronized_sqlite3_column_text(stmt, 1);
            if ((_id != nil) && strlen(_id))
            {
                flag=TRUE;
                
            }
                

        }
    }
    synchronized_sqlite3_finalize(stmt);
    if(!flag)
    {
        NSString *queryStatementUpdate = [NSString stringWithFormat:@"update User SET Id='%@',Name='%@' Where Username='%@' ",UserId ,name, appDelegate.username];
            
            char * err;
            if (synchronized_sqlite3_exec(appDelegate.db, [queryStatementUpdate UTF8String], NULL, NULL, &err) != SQLITE_OK)
            {
                if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
                    [MyPopoverDelegate performSelector:@selector(throwException)];
                SMLog(@"Failed to insert");
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
                SMLog(@"Failed to drop");
              
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
                
                NSDictionary * source_dict = nil;
                NSDictionary * target_dict = nil;
                
                NSArray * obj = [NSArray arrayWithObjects: processId = @"", layoutId = @"", sourceName = @"", expressionId = @"", oMappingId = @"",componentType = @"",  parentColumn = @"", targetName = @"", vMappingid = @"", source_child_column = @"", nil];
                
                source_dict = [mappingArray objectAtIndex:0];
                if ([mappingArray count] == 2)
                {
                    target_dict = [mappingArray objectAtIndex:1];
                    if (![[[mappingArray objectAtIndex:0]objectForKey:@"component_type"] isEqualToString:@"SOURCE"])
                    {
                        source_dict = [mappingArray objectAtIndex:1];
                        target_dict = [mappingArray objectAtIndex:0];
                    }
                }
                else
                {
                    if ([[[mappingArray objectAtIndex:0]objectForKey:@"component_type"] isEqualToString:@"SOURCE"])
                    {
                        target_dict = [NSDictionary dictionaryWithObjects:obj forKeys:keys];
                    }
                    else
                    {
                        target_dict = [mappingArray objectAtIndex:0];
                        source_dict = [NSDictionary dictionaryWithObjects:obj forKeys:keys];
                    }  
                }
                    
                objects = [NSArray arrayWithObjects:
                           ([source_dict objectForKey:MPROCESS_ID]!=@"")?[source_dict objectForKey:MPROCESS_ID]:[target_dict  objectForKey:MPROCESS_ID],
                           ([source_dict objectForKey:MLAYOUT_ID]!=@"")?[source_dict objectForKey:MLAYOUT_ID]:[target_dict  objectForKey:MLAYOUT_ID],
                           ([target_dict  objectForKey:SOURCE_OBJECT_NAME]!=@"")?[target_dict  objectForKey:SOURCE_OBJECT_NAME]:@"",
                           ([source_dict objectForKey:SOURCE_OBJECT_NAME]!=@"")?[source_dict  objectForKey:SOURCE_OBJECT_NAME]:([target_dict  objectForKey:SOURCE_OBJECT_NAME]!=@"")?[target_dict  objectForKey:SOURCE_OBJECT_NAME]:@"",
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
                
                
                NSDictionary * source_dict = nil;
                NSDictionary * target_dict = nil;
                
                NSArray * obj = [NSArray arrayWithObjects: processId = @"", layoutId = @"", sourceName = @"", expressionId = @"", oMappingId = @"",componentType = @"",  parentColumn = @"", targetName = @"", vMappingid = @"", source_child_column = @"", nil];
                
                source_dict = [mappingArray objectAtIndex:0];
                if ([mappingArray count] == 2)
                {
                    target_dict = [mappingArray objectAtIndex:1];
                    if (![[[mappingArray objectAtIndex:0]objectForKey:@"component_type"] isEqualToString:@"SOURCE"])
                    {
                        source_dict = [mappingArray objectAtIndex:1];
                        target_dict = [mappingArray objectAtIndex:0];
                    }
                }
                else
                {
                    if ([[[mappingArray objectAtIndex:0]objectForKey:@"component_type"] isEqualToString:@"SOURCE"])
                    {
                        target_dict = [NSDictionary dictionaryWithObjects:obj forKeys:keys];
                    }
                    else
                    {
                        target_dict = [mappingArray objectAtIndex:0];
                        source_dict = [NSDictionary dictionaryWithObjects:obj forKeys:keys];
                    }  
                }
                        
                objects = [NSArray arrayWithObjects:
                           ([source_dict objectForKey:MPROCESS_ID]!=@"")?[source_dict objectForKey:MPROCESS_ID]:[target_dict  objectForKey:MPROCESS_ID],
                           ([source_dict objectForKey:MLAYOUT_ID]!=@"")?[source_dict objectForKey:MLAYOUT_ID]:[target_dict  objectForKey:MLAYOUT_ID],
                           ([target_dict  objectForKey:SOURCE_OBJECT_NAME]!=@"")?[target_dict  objectForKey:SOURCE_OBJECT_NAME]:@"",
                           ([source_dict objectForKey:SOURCE_OBJECT_NAME]!=@"")?[source_dict  objectForKey:SOURCE_OBJECT_NAME]:([target_dict  objectForKey:SOURCE_OBJECT_NAME]!=@"")?[target_dict  objectForKey:SOURCE_OBJECT_NAME]:@"",
                           ([target_dict objectForKey:EXPRESSION_ID]!=@"")?[target_dict objectForKey:EXPRESSION_ID]:[source_dict  objectForKey:EXPRESSION_ID],
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
			
			char * _processId = [appDelegate convertStringIntoChar:([dict objectForKey:MPROCESS_ID] != nil)?[dict objectForKey:MPROCESS_ID]:@""];
			
            sqlite3_bind_text(bulkStmt, 1, _processId, strlen(_processId), SQLITE_TRANSIENT);
			
			
			char * _layoutId = [appDelegate convertStringIntoChar:([dict objectForKey:MLAYOUT_ID] != nil)?[dict objectForKey:MLAYOUT_ID]:@""];
            
            sqlite3_bind_text(bulkStmt, 2, _layoutId, strlen(_layoutId), SQLITE_TRANSIENT);
			
			char * _targetObjectName = [appDelegate convertStringIntoChar:([dict objectForKey:MTARGET_OBJECT_NAME] != nil)?[dict objectForKey:MTARGET_OBJECT_NAME]:@""];
            
            sqlite3_bind_text(bulkStmt, 3, _targetObjectName, strlen(_targetObjectName), SQLITE_TRANSIENT);
										
			char * _sourceObjectName = [appDelegate convertStringIntoChar:([dict objectForKey:MSOURCE_OBJECT_NAME] != nil)?[dict objectForKey:MSOURCE_OBJECT_NAME]:@""];
            
            sqlite3_bind_text(bulkStmt, 4, _sourceObjectName, strlen(_sourceObjectName), SQLITE_TRANSIENT);
										
			char * _expressionId = [appDelegate convertStringIntoChar:([dict objectForKey:MEXPRESSION_ID] != nil)?[dict objectForKey:MEXPRESSION_ID]:@""];
            
            sqlite3_bind_text(bulkStmt, 5, _expressionId, strlen(_expressionId), SQLITE_TRANSIENT);
										
			char * _objectmappingId = [appDelegate convertStringIntoChar:([dict objectForKey:MOBJECT_MAPPING_ID] != nil)?[dict objectForKey:MOBJECT_MAPPING_ID]:@""];
										
            sqlite3_bind_text(bulkStmt, 6, _objectmappingId, strlen(_objectmappingId), SQLITE_TRANSIENT);
										
			char * _componentType = [appDelegate convertStringIntoChar:([dict objectForKey:MCOMPONENT_TYPE] != nil)?[dict objectForKey:MCOMPONENT_TYPE]:@""];
										
            sqlite3_bind_text(bulkStmt, 7, _componentType, strlen(_componentType), SQLITE_TRANSIENT);
										
			char * _parentColumn = [appDelegate convertStringIntoChar:([dict objectForKey:MPARENT_COLUMN] != nil)?[dict objectForKey:MPARENT_COLUMN]:@""];
										
            sqlite3_bind_text(bulkStmt, 8, _parentColumn, strlen(_parentColumn), SQLITE_TRANSIENT);
			
            char * _valueMappingId = [appDelegate convertStringIntoChar:([dict objectForKey:MVALUE_MAPPING_ID] != nil)?[dict objectForKey:MVALUE_MAPPING_ID]:@""];
										
            sqlite3_bind_text(bulkStmt, 9, _valueMappingId, strlen(_valueMappingId), SQLITE_TRANSIENT);
										
			char * _sourceChildParentcolumn = [appDelegate convertStringIntoChar:([dict objectForKey:@"source_child_parent_column"] != nil)?[dict objectForKey:@"source_child_parent_column"]:@""];
            
            sqlite3_bind_text(bulkStmt,  10, _sourceChildParentcolumn, strlen(_sourceChildParentcolumn), SQLITE_TRANSIENT);
            
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
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS  SFSignatureData ('record_Id' VARCHAR,'object_api_name' VARCHAR,'signature_data' TEXT,'sig_Id' TEXT ,'WorkOrderNumber' VARCHAR, 'sign_type' VARCHAR , 'operation_type' VARCHAR)"];
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
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS meta_sync_due ('local_id' INTEGER PRIMARY KEY  NOT NULL UNIQUE, 'description' VARCHAR)"];
    [self createTable:query];
    
//    query =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS on_demand_download ('object_name' VARCHAR , 'sf_id' VARCHAR PRIMARY KEY  NOT NULL UNIQUE, 'time_stamp' DATETIME ,'local_id' VARCHAR, 'record_type' VARCHAR, 'json_record' VARCHAR) "];
//    [self createTable:query];

    query =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ ('object_name' VARCHAR , 'sf_id' VARCHAR PRIMARY KEY  NOT NULL UNIQUE, 'time_stamp' DATETIME ,'local_id' VARCHAR ) ",User_created_events];
    [self createTable:query];
    
    query =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ ('object_name' VARCHAR ,'local_id' VARCHAR ) ",Event_local_Ids];
    [self createTable:query];
    
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS servicereprt_logo ('logo' VARCHAR)"];
    [self createTable:query];
    if([appDelegate enableGPS_SFMSearch])
        [self createUserGPSTable];
}


#pragma mark - Create All Tables
- (BOOL) createTable:(NSString *)statement
{
    char * err;
    if (synchronized_sqlite3_exec(appDelegate.db, [statement UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
            [MyPopoverDelegate performSelector:@selector(throwException)];
        SMLog(@"Failed");
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
                        SMLog(@"Failed to insert");
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
        SMLog(@"Failed to insert");
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
                                    SMLog(@"Failed to update");
                                }

                            }
                                            
                        }
                    }
                                    
                }
            } //kdfjbjdkfg
            
        synchronized_sqlite3_finalize(stmt);
    }
    appDelegate.wsInterface.didOpComplete = TRUE;
    SMLog(@"IComeOUTHere Databse");
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
    // Get details of the IPAD Module
    NSString * _query = @"SELECT Id, SVMXC__Name__c, SVMXC__Description__c, SVMXC__ModuleID__c, SVMXC__IsStandard__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__ModuleID__c = \'IPAD\' AND RecordType.Name = \'MODULE\'";
    [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didGetModuleInfo:error:context:) context:nil];
}

- (void) didGetModuleInfo:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
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
    }
    else
    {
        // Continue logging in
        didGetPDF = YES;
    }
}

- (void) didGetActiveGlobalProfile:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
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
    
    NSString * version = [appDelegate serverPackageVersion];
	int _stringNumber = [version intValue];
    if(_stringNumber >=  (KMinPkgForScheduleEvents * 100000))
    {
        [self getCodeSnippetSetting];
    }
    
    [self getImageForServiceReportLogo];
    
    appDelegate.wsInterface.didOpComplete = TRUE;
    SMLog(@"IComeOUTHere didgetsettings");

}
-(void)insertSettingsIntoTable:(NSMutableArray*)array:(NSString*)TableName
{
    SMLog(@"SAMMAN MetaSync insertSettingsIntoTable processing starts: %@", [NSDate date]);
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

-(NSMutableDictionary *)getNameFieldForRefrenceObject:(NSDictionary*)tableArray
{
    NSMutableString * queryStatement1 = [[NSMutableString alloc]initWithCapacity:0];
    NSMutableDictionary *NameFieldDict=[[NSMutableDictionary alloc]init];
    queryStatement1 = [NSMutableString stringWithFormat:@"SELECT type,reference_to FROM SFObjectField where object_api_name = '%@'and api_name='%@'",[appDelegate.dataBase getApiNameFromFieldLabel:[tableArray objectForKey:@"SVMXC__Object_Name2__c"]],[appDelegate.dataBase getApiNameFromFieldLabel:[tableArray objectForKey:@"SVMXC__Field_Name__c"]]];
    sqlite3_stmt * labelstmt;
    const char *selectStatement = [queryStatement1 UTF8String];
    char *type=nil,*refrence_to=nil,*name_field=nil;
    NSString *namefiled=@"";
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &labelstmt, nil) == SQLITE_OK )
    {
        if(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW)
        {
            type = (char *) synchronized_sqlite3_column_text(labelstmt,0);
            refrence_to = (char *) synchronized_sqlite3_column_text(labelstmt,1);
        }
    }
    NSString *strType,*strRefrence_to;
    if((type != nil)&& strlen(type))
        strType=[NSString stringWithFormat:@"%s",type];
    else
        strType=@" ";
    if((refrence_to != nil)&& strlen(refrence_to))
        strRefrence_to=[NSString stringWithFormat:@"%s",refrence_to];
    else
        strRefrence_to=@" ";
    if([strType isEqualToString:@"reference"])
    {
        queryStatement1 = [NSMutableString stringWithFormat:@"SELECT api_name FROM SFObjectField where name_field='TRUE' and object_api_name='%@'",strRefrence_to];
        sqlite3_stmt * labelstmt;
        const char *selectStatement = [queryStatement1 UTF8String];
        if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &labelstmt, nil) == SQLITE_OK )
        {
            if(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW)
            {
                name_field = (char *) synchronized_sqlite3_column_text(labelstmt,0);
                if ((name_field !=nil) && strlen(name_field))
                    namefiled=[NSString stringWithFormat:@"%s",name_field];
                [NameFieldDict setObject:namefiled forKey:@"namefiled"];
                [NameFieldDict setObject:strRefrence_to forKey:@"reference_to"];
            }
        }

    }
    return NameFieldDict;
}
- (NSString *) getNameFieldForObject:(NSString *)headerObjectName WithRecordId:(NSString *)recordId
{
    NSString * queryStatement = @"";
    
    NSString * Name = [appDelegate.dataBase getApiNameForNameField:headerObjectName];
    
//    if ([headerObjectName isEqualToString:@"Case"])
//        queryStatement = [NSString stringWithFormat:@"SELECT %@ From '%@' WHERE local_id = '%@'", headerObjectName, recordId];
//    else
//        queryStatement = [NSString stringWithFormat:@"SELECT Name From %@ WHERE local_id = '%@'", headerObjectName, recordId];
    
    
    queryStatement = [NSString stringWithFormat:@"SELECT %@ From '%@' WHERE local_id = '%@'" , Name, headerObjectName, recordId];

    
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
    [appDelegate startBackgroundThreadForLocationServiceSettings];
    appDelegate.didincrementalmetasyncdone = TRUE;
    
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
    self.dbFilePath = @"";
    [appDelegate initWithDBName:DATABASENAME1 type:DATABASETYPE1];
    
    [self doMetaSync];
    
}

- (void) doMetaSync
{
    time_t t1;
    time(&t1);
    
    //RADHA 2012june12
    [appDelegate.dataBase removecache];
    appDelegate.wsInterface.didOpComplete = FALSE;
    appDelegate.connection_error = FALSE;

   // [appDelegate goOnlineIfRequired];
    [appDelegate updateInstalledPackageVersion];    
    NSString * retVal = [self callMetaSync];

     // Uncomment this when SFM Search Module is Required
     //SFM Search 
     if([appDelegate enableGPS_SFMSearch])
     {
         appDelegate.wsInterface.didOpSFMSearchComplete = FALSE;
         [appDelegate.wsInterface metaSyncWithEventName:SFM_SEARCH eventType:SYNC values:nil];
         while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
         {
#ifdef kPrintLogsDuringWebServiceCall
             SMLog(@"Datebase.m : doMetaSync: SFM_SEARCH");
#endif
             if (![appDelegate isInternetConnectionAvailable])
             {
             if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
             [MyPopoverDelegate performSelector:@selector(throwException)];
             break;
             }
             if (appDelegate.wsInterface.didOpSFMSearchComplete == TRUE)
             break;
             if (appDelegate.connection_error)
             {
                 break;
             }

         }
         SMLog(@"MetaSync SFM Search End: %@", [NSDate date]);
         
         //SFM Search End
     }
    
    if ([retVal isEqualToString:SUCCESS_])
    {
        [appDelegate getDPpicklistInfo];
        SMLog(@"META SYNC 1");
        
        time_t t2;
        time(&t2);
        double diff = difftime(t2,t1);
        SMLog(@"time taken for meta and data sync = %f",diff);
        
        [self populateDatabaseFromBackUp];
        
        //Radha purging - 10/April/12
        NSMutableArray * recordId = [appDelegate.dataBase getAllTheRecordIdsFromEvent];
        
        appDelegate.initialEventMappinArray = [appDelegate.dataBase checkForTheObjectWithRecordId:recordId];
        
    }
    //Radha End

}



- (NSString *) callMetaSync
{
    appDelegate.wsInterface.didOpComplete = FALSE;
    appDelegate.connection_error = FALSE;
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
        [appDelegate goOnlineIfRequired];
        if(!appDelegate.connection_error)
        {
            break;
        }
    }
    [appDelegate.wsInterface metaSyncWithEventName:SFM_METADATA eventType:INITIAL_SYNC values:nil];
    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(@"Datebase.m : callMetaSync: SFM_METADATA");
#endif

        if (![appDelegate isInternetConnectionAvailable])
        {
            break;
        }
        
        if (appDelegate.wsInterface.didOpComplete == TRUE)
            break; 
        
        
        if (appDelegate.connection_error)
            break;
    }
    
    //RADHA - If connection error start meta sync again
    if (![appDelegate isInternetConnectionAvailable])
    {
        if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
            [MyPopoverDelegate performSelector:@selector(throwException)];
        return NOINTERNET;
    }
    
    if (appDelegate.connection_error && [appDelegate isInternetConnectionAvailable])
    {
        appDelegate.connection_error = FALSE;
        [self doMetaSync];
        return CONNECTIONERROR;
    }
    
    return SUCCESS_;
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
    
    [self openDB:TEMPDATABASENAME type:DATABASETYPE1 sqlite:nil];
    
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
    appDelegate.internetAlertFlag = TRUE;
    popOver_view.syncConfigurationFailed = TRUE;
    [self settingAfterIncrementalMetaSync];

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
        SMLog(@"\n db exist in the path");		
    }
    else    //didn't find db, need to copy
    {
        NSString *backupDbPath = [[NSBundle mainBundle] pathForResource:TEMPDATABASENAME ofType:DATABASETYPE1]; 
        if (backupDbPath == nil) 
        {
            SMLog(@"\n db not able to create error");   
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
        SMLog (@"couldn't open db:");
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
        SMLog(@"Failed");
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
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS meta_sync_due ('local_id' INTEGER PRIMARY KEY  NOT NULL  UNIQUE, 'description' VARCHAR)"];
    [self createTemporaryTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS servicereprt_logo ('logo' VARCHAR)"];
    [self createTemporaryTable:query];
    
//    query =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS on_demand_download ('object_name' VARCHAR , 'sf_id' VARCHAR  PRIMARY KEY  NOT NULL UNIQUE, 'time_stamp' DATETIME ,'local_id' VARCHAR, 'record_type' VARCHAR, 'json_record' VARCHAR)"];
//    [self createTemporaryTable:query];
    
    
    query =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ ('object_name' VARCHAR , 'sf_id' VARCHAR PRIMARY KEY  NOT NULL UNIQUE, 'time_stamp' DATETIME ,'local_id' VARCHAR ) ",User_created_events];
    [self createTable:query];
    
    query =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ ('object_name' VARCHAR ,'local_id' VARCHAR ) ",Event_local_Ids];
    [self createTable:query];
    
    [self createTemporaryTable:query];

    
    NSArray * tempTableArray = [NSArray arrayWithObjects:@"ChatterPostDetails",@"Document",@"ProductImage",@"SFSignatureData",@"UserImages",@"trobleshootdata",@"SFDataTrailer",@"SFDataTrailer_Temp",@"SYNC_HISTORY",@"sync_Records_Heap",@"LookUpFieldValue",@"Summary_PDF",@"sync_error_conflict", @"contact_images",@"internet_conflicts", @"meta_sync_status", @"meta_sync_due", nil];
    
    return tempTableArray;
}
-(void)populateDatabaseFromBackUp
{
    [appDelegate initWithDBName:DATABASENAME1 type:DATABASETYPE1];
    [self openDB:TEMPDATABASENAME type:DATABASETYPE1 sqlite:nil];
     
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
        SMLog(@"%@",finalQuery);
        [self createTable:finalQuery];
        
    }
    //Radha 2012june08
    
    NSArray * tempArray = [self createTempTableForSummaryAndTroubleShooting];
    
    
    for (NSString * table in tempArray)
    {
        NSString * temp_query = [NSString stringWithFormat:@"INSERT INTO %@ SELECT * FROM tempsfm.%@", table, table];
        [self createTable:temp_query];
    }
    appDelegate.internetAlertFlag = TRUE;
    
    popOver_view.syncConfigurationFailed = FALSE;
    [self settingAfterIncrementalMetaSync];
    
}
- (void)deleteDatabase:(NSString *)databaseName
{
    NSError *error; 
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",databaseName,DATABASETYPE1]];
    
    [fileManager removeItemAtPath:fullPath error:&error];
    
    SMLog(@"database removed");
}

- (void) removecache
{
    if ((appDelegate.wsInterface.processDictionary != nil) && [appDelegate.wsInterface.processDictionary count] > 0)
    {
        appDelegate.wsInterface.processDictionary = nil;
        appDelegate.wsInterface.processDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    
    if ((appDelegate.wsInterface.objectDefinitions != nil) && [appDelegate.wsInterface.objectDefinitions count] > 0)
    {
        appDelegate.wsInterface.objectDefinitions = nil;
        appDelegate.wsInterface.objectDefinitions = [[NSMutableArray alloc] initWithCapacity:0];
    }
    if ((appDelegate.wsInterface.object != nil) && [appDelegate.wsInterface.object count] > 0)
    {
        appDelegate.wsInterface.object = nil;
        appDelegate.wsInterface.object = [[NSMutableArray alloc] initWithCapacity:0];
    }
    if ((appDelegate.wsInterface.picklistObject != nil) && [appDelegate.wsInterface.picklistObject count] > 0)
    {
        appDelegate.wsInterface.picklistObject = nil;
        appDelegate.wsInterface.picklistObject = [[NSMutableArray alloc] initWithCapacity:0];
    }
    if ((appDelegate.wsInterface.picklistField != nil) && [appDelegate.wsInterface.picklistField count] > 0)
    {
        appDelegate.wsInterface.picklistField = nil;
        appDelegate.wsInterface.picklistField = [[NSMutableArray alloc] initWithCapacity:0];
    }
    if ((appDelegate.wsInterface.picklistValues != nil) && [appDelegate.wsInterface.picklistValues count] > 0)
    {
        appDelegate.wsInterface.picklistValues = nil;
        appDelegate.wsInterface.picklistValues = [[NSMutableArray alloc] initWithCapacity:0];
    }
    if ((appDelegate.wsInterface.pageUiHistory != nil) && [appDelegate.wsInterface.pageUiHistory count] > 0)
    {
        appDelegate.wsInterface.pageUiHistory = nil;
        appDelegate.wsInterface.pageUiHistory = [[NSMutableArray alloc] initWithCapacity:0];
    }
}

#pragma mark - settingsAfterIncMetaSync
//Call Finaally Method
- (void) settingAfterIncrementalMetaSync
{
    appDelegate.settingsDict = [appDelegate.dataBase getSettingsDictionary];
    
    
    if (appDelegate.wsInterface.tagsDictionary != nil)
        [appDelegate.wsInterface.tagsDictionary removeAllObjects];
    appDelegate.wsInterface.tagsDictionary = [appDelegate.dataBase getTagsDictionary];
    NSMutableDictionary * temp_dict = [appDelegate.wsInterface fillEmptyTags:appDelegate.wsInterface.tagsDictionary];
    appDelegate.wsInterface.tagsDictionary = temp_dict;
    
    [appDelegate.dataBase deleteDatabase:TEMPDATABASENAME];
    [appDelegate initWithDBName:DATABASENAME1 type:DATABASETYPE1];
    
    if ([appDelegate.StandAloneCreateProcess count] > 0)
    {
        [appDelegate.StandAloneCreateProcess  removeAllObjects];
        NSMutableArray * createprocessArray = [appDelegate.databaseInterface getAllTheProcesses:@"STANDALONECREATE"];
        [appDelegate getCreateProcessArray:createprocessArray];
    }
    
    if ([appDelegate.view_layout_array count] > 0)
    {
        [appDelegate.view_layout_array removeAllObjects];
        appDelegate.view_layout_array = [appDelegate.databaseInterface getAllTheProcesses:@"VIEWRECORD"]; 
    }
    
    if (appDelegate.soqlQuery != nil)
        appDelegate.soqlQuery = nil;
    
    [appDelegate.calDataBase startQueryConfiguration];

    appDelegate.isIncrementalMetaSyncInProgress = FALSE;
    
    [popOver_view syncSuccess];
    
}

#pragma mark -END

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
-(NSString*) getLoggedInUser:(NSString *)username
{
    {
        NSMutableString * query = [NSMutableString stringWithFormat:@"SELECT Name FROM User WHERE Username = '%@'", username];
        
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
    synchronized_sqlite3_finalize(statement);
    
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

- (NSString *) getDateToDeleteEventsAndTaskOlder:(NSTimeInterval)Value
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

- (NSString *) getDateToDeleteEventsAndTaskForNext:(NSTimeInterval)Value
{
    NSDate * today = [NSDate date];
    
    NSDateFormatter * formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [formatter setTimeZone:gmt];
    
    
    NSDate * previousDate = [today dateByAddingTimeInterval:(+Value * 24 * 60 * 60)];
    
    NSString * currentDate = [formatter stringFromDate:previousDate];
    
    currentDate = [currentDate stringByReplacingCharactersInRange:NSMakeRange(11, 8) withString:@"00:00:00"];
    return currentDate;
}


- (void) purgingDataOnSyncSettings:(NSString *)Date tableName:(NSString *)tableName 
                            Action:(NSString*)Action
{
    
    NSString * column = @"";
    
    if ([tableName isEqualToString:@"Event"])
    {
        column = @"EndDateTime";
    }
    else
    {
        Date = [Date substringToIndex:10];
        column = @"ActivityDate";
    }

    NSString * queryStatement = @"";
    NSString * version = [appDelegate serverPackageVersion];
	int _stringNumber = [version intValue];
    
    if(_stringNumber >=  (KMinPkgForScheduleEvents * 100000))
    {
        if ([Action isEqualToString:@"LESSTHAN"])
        {
            queryStatement = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ < '%@' and Id not in (SELECT sf_id  FROM user_created_events) and Id != '' ", tableName, column, Date];   
        }
        else if([Action isEqualToString:NOT_OWNER_GREATERTHAN]) //sahana dec 14 2012
        {
            if(appDelegate.loggedInUserId == nil)
            {
                appDelegate.loggedInUserId=[self getLoggedInUserId:appDelegate.username];
            }
            queryStatement = [NSString stringWithFormat:@"DELETE FROM %@ WHERE  Id  in (SELECT sf_id  FROM user_created_events) and OwnerId != '%@'", tableName ,appDelegate.loggedInUserId];
            
        }
        else if([Action isEqualToString:NOT_OWNERLESSTHAN]) //sahana dec 14 2012
        {
            if(appDelegate.loggedInUserId == nil)
            {
                appDelegate.loggedInUserId=[self getLoggedInUserId:appDelegate.username];
            }
            queryStatement = [NSString stringWithFormat:@"DELETE FROM %@ WHERE  Id  in (SELECT sf_id  FROM user_created_events) and OwnerId != '%@'", tableName,appDelegate.loggedInUserId];
        }
        else
        {
              queryStatement = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ >= '%@' and Id not in (SELECT sf_id  FROM user_created_events) and Id != '' ", tableName, column, Date];  
        }
    }
    else if (!([Action isEqualToString:NOT_OWNERLESSTHAN] || [Action isEqualToString:NOT_OWNER_GREATERTHAN]))
    {
        if ([Action isEqualToString:@"LESSTHAN"])
        {
            queryStatement = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ < '%@'", tableName, column, Date];
        }
        else
        {
            queryStatement = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ > '%@'", tableName, column, Date];
        }
    }
    char * err;
    
    if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(@"Purging Failed to delete");
    }
    
}
#pragma mark -End


#pragma mark - FULL DATA SYNC
-(void)setSyncStatus
{
    [appDelegate setSyncStatus:SYNC_GREEN];
}

- (BOOL) startEventSync
{
    
    NSString * event_sync = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_events];
    appDelegate.connection_error = FALSE;
    BOOL retVal = TRUE;
    SMLog(@"SAMMAN DataSync WS Start: %@", [NSDate date]);
    appDelegate.wsInterface.didOpComplete = FALSE;

    [appDelegate.wsInterface dataSyncWithEventName:EVENT_SYNC eventType:SYNC requestId:@""];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(@"Datebase.m : startEventSync: EVENT_SYNC");
#endif
        if (![appDelegate isInternetConnectionAvailable])
            break;
        
        if (appDelegate.wsInterface.didOpComplete == TRUE)
        {
            break; 
        }

        if(appDelegate.connection_error)
        {
            appDelegate.SyncStatus = SYNC_GREEN;
            [self performSelectorOnMainThread:@selector(setSyncStatus) withObject:nil waitUntilDone:NO];
            return FALSE;
        }
    }
    
    if(retVal == NO)
    {       
        
        [appDelegate setSyncStatus:SYNC_RED];
               
        [appDelegate.calDataBase insertIntoConflictInternetErrorWithSyncType:event_sync];
        appDelegate.internet_Conflicts = [appDelegate.calDataBase getInternetConflicts];
        [appDelegate.reloadTable ReloadSyncTable];
        if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
            [MyPopoverDelegate performSelector:@selector(throwException)];
        return FALSE;
    }

    
    if (![appDelegate isInternetConnectionAvailable])
    {
        
        [appDelegate setSyncStatus:SYNC_RED];
          
        [appDelegate.calDataBase insertIntoConflictInternetErrorWithSyncType:event_sync];
         appDelegate.internet_Conflicts = [appDelegate.calDataBase getInternetConflicts];
        [appDelegate.reloadTable ReloadSyncTable];
        if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
            [MyPopoverDelegate performSelector:@selector(throwException)];
        return FALSE;
    }
    
    appDelegate.Incremental_sync_status = INCR_STARTS;
    
    [appDelegate.wsInterface PutAllTheRecordsForIds];
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(@"Datebase.m : startEventSync: TX_FETCH");
#endif

        if (![appDelegate isInternetConnectionAvailable])
            break;
        
        if (appDelegate.Incremental_sync_status == PUT_RECORDS_DONE)
            break; 
        if(appDelegate.connection_error)
        {
            appDelegate.SyncStatus = SYNC_GREEN;
            [self performSelectorOnMainThread:@selector(setSyncStatus) withObject:nil waitUntilDone:NO];
             return FALSE;
        }
    }
    
    if (![appDelegate isInternetConnectionAvailable])
    {
        
        [appDelegate setSyncStatus:SYNC_RED];
            
        [appDelegate.calDataBase insertIntoConflictInternetErrorWithSyncType:event_sync];
        
        appDelegate.internet_Conflicts = [appDelegate.calDataBase getInternetConflicts];
        [appDelegate.reloadTable ReloadSyncTable];
        if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
            [MyPopoverDelegate performSelector:@selector(throwException)];
        return FALSE;
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
    
    synchronized_sqlite3_finalize(stmt);
    
    return array;
    
}

#pragma mark - END

#pragma mark - Incremental Meta And Event
- (void) callIncrementalMetasync
{
    if (popOver_view == nil)
        popOver_view = [[PopoverButtons alloc] init];
    
    [popOver_view startSyncConfiguration];

}

- (void) scheduleEventSync
{
    if (popOver_view == nil)
        popOver_view = [[PopoverButtons alloc] init];
    
    [popOver_view startSyncEvents];
    
}
#pragma mark - END

- (void) clearTempDatabase
{
    [self openDB:TEMPDATABASENAME type:DATABASETYPE1 sqlite:nil];
    
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
            SMLog(@"Failed to drop");
            
        }
        
    }    

}


//RADHA 2012june08
#pragma mark - Check

- (BOOL) checkIfRecordExistForObject:(NSString *)tableName Id :(NSString *)Id
{
    NSString * query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM '%@' WHERE Id = '%@'", tableName, Id];
    
    sqlite3_stmt * stmt;
    
    int count = 0;
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            count = synchronized_sqlite3_column_int(stmt, 0);
        }
    }
    
    if (count > 0)
        return TRUE;
    else
        return FALSE;
}

- (BOOL) checkIfRecordExistForObjectWithRecordId:(NSString *)tableName Id :(NSString *)Id
{
    NSString * query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM '%@' WHERE local_id = '%@'", tableName, Id];
    
    sqlite3_stmt * stmt;
    
    int count = 0;
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            count = synchronized_sqlite3_column_int(stmt, 0);
        }
    }
    
    if (count > 0)
        return TRUE;
    else
        return FALSE;
}
#pragma mark - END

#pragma mark - MetaSyncDue
//Radha 2012june16
- (void) insertMetaSyncDue:(NSString *)description
{
    NSString * msg = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_metasync_due];
    
    NSString * query = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ ('description', 'local_id') VALUES ('%@', '1')",description,  msg];
    
    char * err; 
        
    if ([appDelegate.metaSyncThread isExecuting])
    {
        
    }
    else 
    {
        if (synchronized_sqlite3_exec(appDelegate.db, [query UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
            SMLog(@"Failed to insert into duetable");
        }
    }
}

- (BOOL) checkIfSyncConfigDue
{
    NSString * query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM '%@' WHERE local_id = '1'", METASYNCDUE];
    
    sqlite3_stmt * stmt;
    
    int count = 0;
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            count = synchronized_sqlite3_column_int(stmt, 0);
        }
    }
    
    if (count > 0)
        return TRUE;
    else
        return FALSE;

}
 
#pragma mark - END

-(NSString *) getfieldTypeForApi:(NSString *)tableName fieldName:(NSString *)fieldName
{
    NSString * query = [NSString stringWithFormat:@"SELECT type from SFobjectField where object_api_name = '%@' and api_name = '%@'",[self getApiNameFromFieldLabel:tableName], fieldName];
    
    
    sqlite3_stmt * stmt;
    
    NSString * type = @"";
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * _type = (char *)synchronized_sqlite3_column_text(stmt, 0);
            
            if (_type != nil && strlen(_type))
            {
                type = [NSString stringWithUTF8String:_type];
            }
            
        }
        synchronized_sqlite3_finalize(stmt);
    }
    
    
    return type;

}
- (NSString *) getApiNameForNameField:(NSString *)headerObjectName
{
    NSString * fieldName = @"";
    NSString * query = [NSString stringWithFormat:@"SELECT api_name FROM 'SFObjectField' where object_api_name = '%@' and name_field = 'TRUE'",headerObjectName];
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


- (NSString *) getReferenceObjectNameForPdf:(NSString *)ObjectName Field:(NSString *)FieldName Id:(NSString *)Id
{
    NSString * query = [NSString stringWithFormat:@"SELECT %@ FROM '%@' where Id = '%@' ",FieldName, ObjectName, Id];
    
    NSString * name = @"";
    
    sqlite3_stmt * stmt;
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * temp_fieldName = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if(temp_fieldName != nil)
            {
                name = [NSString stringWithUTF8String:temp_fieldName];
            }
        }

    }
    synchronized_sqlite3_finalize(stmt);
    return name;
    
}


#pragma mark - ServiceReportLogo
- (void) getImageForServiceReportLogo
{
    NSString * _query = [NSString stringWithFormat:@"SELECT Body FROM Document Where Name = 'ServiceMax_iPad_CompanyLogo'"];
    
    [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didGetServiceReportLogo:error:context:) context:nil];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, FALSE))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(@"Datebase.m : getImageForServiceReportLogo: ZKs ServiceReportLogo");
#endif
        

        if (![appDelegate isInternetConnectionAvailable] || appDelegate.connection_error)
               break;
        if (didGetServiceReportLogo)
               break;
    }
    
    
}

- (void) didGetServiceReportLogo:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    // Store the image in a appDelegate UIImage
    
    NSArray * array = [result records];
    
    if ([array count] == 0)
    {
        didGetServiceReportLogo = YES;
        return;
    }
    
    NSString * dataString = [[[array objectAtIndex:0] fields] objectForKey:@"Body"];
    
   // NSData * data = [Base64 decode:dataString];
    
    // Decode data from Base64
    if (dataString != nil && [dataString length] > 0)
    {        
        // Save the image to the application bundle
//        NSFileManager * fileManager = [NSFileManager defaultManager];
//        
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *saveDirectory = [paths objectAtIndex:0];	
//        NSString * filePath = [saveDirectory stringByAppendingPathComponent:@"header_image.png"];
//        
//        [fileManager createFileAtPath:filePath contents:data attributes:nil];
        
        NSString * query = [NSString stringWithFormat:@"INSERT INTO servicereprt_logo VALUES ('%@')", dataString];
        
        char * err;
        if (synchronized_sqlite3_exec(appDelegate.db, [query UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
            SMLog(@"FAILED TO INSERT LOGO");
        }
        
    
    }
        
    didGetServiceReportLogo = YES;
}



//RADHA
- (NSString *) getParentColumnValueFromchild:(NSString *)parentColumn childTable:(NSString *)objectName sfId:(NSString *)sf_id
{
    
    NSString * value = @"";
    
    sqlite3_stmt * stmt = nil;
    
    NSString * query = [NSString stringWithFormat:@"SELECT %@ FROM %@ Where Id = '%@'", parentColumn, objectName, sf_id];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * temp_fieldName = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if(temp_fieldName != nil)
            {
                value = [NSString stringWithUTF8String:temp_fieldName];
            }
        }
        
    }
    synchronized_sqlite3_finalize(stmt);
    
    
    return value;
}


- (NSString *) getParentlocalIdchild:(NSString *)parentColumn childTable:(NSString *)objectName local_id:(NSString *)local_id
{
    
    NSString * value = @"";
    
    sqlite3_stmt * stmt = nil;
    
    NSString * query = [NSString stringWithFormat:@"SELECT %@ FROM %@ Where local_id = '%@'", parentColumn, objectName, local_id];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * temp_fieldName = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if(temp_fieldName != nil)
            {
                value = [NSString stringWithUTF8String:temp_fieldName];
            }
        }
        
    }
    synchronized_sqlite3_finalize(stmt);
    
    
    return value;
}


#pragma mark - CONFLICT
- (BOOL) checkIfConflictsExistsForEvent:(NSString *)SF_Id objectName:(NSString *)objectName local_id:(NSString *)local_id
{
    
    int count = 0;
    
    sqlite3_stmt * stmt;
    
    NSString * query = [NSString stringWithFormat:@"SELECT COUNT (*) FROM sync_error_conflict where object_name = '%@' and (sf_id = '%@' or local_id = '%@')", objectName, SF_Id, local_id];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            count = synchronized_sqlite3_column_int(stmt, 0);
        }
        
    }
    
    if (count > 0)
       return TRUE;
    else
        return FALSE;
    synchronized_sqlite3_finalize(stmt);
    
    
}

- (BOOL) checkIfConflictsExistsForEventWithLocalId:(NSString *)local_id objectName:(NSString *)objectName
{
    int count = 0;
    
    sqlite3_stmt * stmt;
    
    NSString * query = [NSString stringWithFormat:@"SELECT COUNT (*) FROM sync_error_conflict where object_name = '%@' and local_id = '%@'", objectName,local_id];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            count = synchronized_sqlite3_column_int(stmt, 0);
        }
        
    }
    
    if (count > 0)
        return TRUE;
    else
        return FALSE;
    synchronized_sqlite3_finalize(stmt);
}


- (BOOL) checkIfConflictsExistsForEventWithSFID:(NSString *)sfid objectName:(NSString *)objectName
{
    int count = 0;
    
    sqlite3_stmt * stmt;
    
    NSString * query = [NSString stringWithFormat:@"SELECT COUNT (*) FROM sync_error_conflict where object_name = '%@' and sf_id = '%@'", objectName,sfid];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            count = synchronized_sqlite3_column_int(stmt, 0);
        }
        
    }
    
    if (count > 0)
        return TRUE;
    else
        return FALSE;
    synchronized_sqlite3_finalize(stmt);
}



- (BOOL) checkIfChildConflictexist:(NSString *)objectName sfId:(NSString *)SF_Id
{
    BOOL conflictExist = FALSE;
    
    NSString * child_column = [self getChildColumnForParent:objectName];
    
    NSString * localId = [appDelegate.databaseInterface getLocalIdFromSFId:SF_Id tableName:objectName];
	
	if ([localId length] == 0 || [localId isEqualToString:nil])
		localId = SF_Id;
    
    
   // NSString * Id = [self getchildSfIdOrLocalId:child_column Id:localId parentColumn:objectName Key:@"ID"];
    
    
    NSMutableArray * childId = [appDelegate.databaseInterface getChildLocalIdForParentId:localId childTableName:child_column sourceTableName:objectName];
    
    
    
    for (int i = 0; i < [childId count]; i++)
    {
        NSString * Id = @"";
        NSString * localId_ = [childId objectAtIndex:i];
    
        conflictExist = [self checkIfConflictsExistsForEventWithLocalId:localId_ objectName:child_column];
        
        if (conflictExist)
            break;
        else 
        {
            Id = [appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:child_column local_id:localId_];
            conflictExist = [self checkIfConflictsExistsForEventWithSFID:Id objectName:child_column];
            
            if (conflictExist)
                break;
        }
        
    }
             
    return conflictExist;
}


- (NSString *) getChildColumnForParent:(NSString *)objectName
{
    NSString * value = @"";
    
    sqlite3_stmt * stmt = nil;
    
    NSString * query = [NSString stringWithFormat:@"SELECT object_api_name_child FROM SFChildRelationship Where object_api_name_parent = '%@' and field_api_name = '%@'", objectName, objectName];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * temp_fieldName = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if(temp_fieldName != nil)
            {
                value = [NSString stringWithUTF8String:temp_fieldName];
            }
        }
        
    }
    
    synchronized_sqlite3_finalize(stmt);
    
    return value;

}
- (NSMutableString *) getAllTheConflictRecordsForObject:(NSString *)ObjectName local_id:(NSString *)local_id
{
    
    NSString * value = @"";
    
    NSMutableString * conflictMessage = [[NSMutableString alloc] initWithCapacity:0];
    
    sqlite3_stmt * stmt = nil;
    
    NSString * sfid = [appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:ObjectName local_id:local_id];
    
    NSString * query = [NSString stringWithFormat:@"SELECT error_message FROM sync_error_conflict Where object_name = '%@' and (sf_id = '%@' or local_id = '%@')", ObjectName, sfid, local_id];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * temp_fieldName = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if(temp_fieldName != nil)
            {
                value = [NSString stringWithUTF8String:temp_fieldName];
            }
        }
        
    }
    if ([value length] > 0)
    {
        [conflictMessage appendString:[NSString stringWithFormat:@"%@", value]];
    }
    if(![appDelegate.From_SFM_Search isEqualToString:FROM_SFM_SEARCH])
    {
        NSString * childColumn = [self getChildColumnForParent:ObjectName];

        NSMutableArray * childId = [appDelegate.databaseInterface getChildLocalIdForParentId:local_id childTableName:childColumn sourceTableName:ObjectName];
        
        query = nil;
        sfid = nil;


        for (int i = 0; i < [childId count]; i++)
        {
            
            sfid = [appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:childColumn local_id:[childId objectAtIndex:i]];
            
            query = [NSString stringWithFormat:@"SELECT error_message FROM sync_error_conflict Where object_name = '%@' and (sf_id = '%@' or local_id = '%@')", childColumn, sfid, [childId objectAtIndex:i]];
            
            if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
            {
                while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
                {
                    char * temp_fieldName = (char *)synchronized_sqlite3_column_text(stmt, 0);
                    if(temp_fieldName != nil)
                    {
                        value = [NSString stringWithUTF8String:temp_fieldName];
                    }
                    if ([value length] > 0)
                    {
                        [conflictMessage appendString:[NSString stringWithFormat:@"\n%@", value]];
                    }
                }
                

                
            }
            
        }
    }

    return conflictMessage;
    
}
//- (NSString *) getchildSfIdOrLocalId:(NSString *)tablename Id:(NSString *)Id  parentColumn:(NSString *)parentColumn  Key:(NSString *)key
//{
//    NSString * value = @"";
//    
//    sqlite3_stmt * stmt = nil;
//    NSString * query = nil;
//    
//    if ([key isEqualToString:@"ID"])
//    {
//        query = [NSString stringWithFormat:@"SELECT Id FROM %@ Where %@ = '%@'", tablename, parentColumn, Id];
//        
//        if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
//        {
//            while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
//            {
//                char * temp_fieldName = (char *)synchronized_sqlite3_column_text(stmt, 0);
//                if(temp_fieldName != nil)
//                {
//                    value = [NSString stringWithUTF8String:temp_fieldName];
//                }
//            }
//            
//        }
//    }
//    else 
//    {
//        query = [NSString stringWithFormat:@"SELECT local_id FROM %@ Where %@ = '%@'", tablename, parentColumn, Id];
//        
//        if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
//        {
//            while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
//            {
//                char * temp_fieldName = (char *)synchronized_sqlite3_column_text(stmt, 0);
//                if(temp_fieldName != nil)
//                {
//                    value = [NSString stringWithUTF8String:temp_fieldName];
//                }
//            }
//            
//        }
//
//    }
//    synchronized_sqlite3_finalize(stmt);
//    
//    return value;
//
//}

#pragma mark - END

//sahana Aug 16th ----------*********** start*************
-(void)getRecordTypeValuesForObject:(NSArray *)allObjects
{

    NSString * objectList = @"";
    
    for(int i = 0 ; i < [allObjects count];i++)
    {
       
        NSString * object_name = [allObjects objectAtIndex:i];
        if(i == 0)
        {
             objectList = [objectList stringByAppendingFormat:@" '%@' ",object_name];
        }
        else
        {
             objectList = [objectList stringByAppendingFormat:@", '%@' ",object_name];
        }
    }
    
     RecordTypeflag = FALSE;
    NSString * _query = [NSString stringWithFormat:@"SELECT Id, Name ,SobjectType FROM RecordType WHERE SobjectType in (%@) ",objectList];
    
    [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didgetRecordtypeInfo:error:context:) context:nil];
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES)) 
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(@"Datebase.m : getRecordTypeValuesForObject: ZKs get record type");
#endif

        if(RecordTypeflag)
        {
            break;
        }
        if (![appDelegate isInternetConnectionAvailable])
        {
            appDelegate.initial_sync_succes_or_failed = META_SYNC_FAILED;
            break;
        }
        if(appDelegate.initial_sync_succes_or_failed == META_SYNC_FAILED)
        {
            break;
        }
        if (appDelegate.connection_error)
        {
            break;
        }
    }
    
}

//sahana RecordType fix  - Aug 16th 2012
- (void) didgetRecordtypeInfo:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    //sahana RecordType fix  - Aug 16th 2012
    SMLog(@"RecordTypeInfo");
       if ([[result records] count] > 0)
    {
        NSArray * resultArray = [result records];
        
        for(int i = 0 ; i< [resultArray count]; i++)
        {
            ZKSObject * sobj = [resultArray objectAtIndex:i];
            NSDictionary * fields = sobj.fields;
            NSArray * allkeys = [fields allKeys];
            if([allkeys containsObject:@"Id"] && [allkeys containsObject:@"Name"])
            {
                NSString * _id = [fields objectForKey:@"Id"];
                NSString * Name = [fields objectForKey:@"Name"];
                [self UpdateSFRecordTypeForId:_id value:Name];
            }
        }      
    }
    
    RecordTypeflag = TRUE;
    

}
#pragma mark - END



//Radha DefectFix - 5721
- (NSInteger) getTextareaLengthForFieldApiName:(NSString *)api_name objectName:(NSString *)objectName;
{
	NSInteger textLength = 0;
	
	NSString * query = [NSString stringWithFormat:@"SELECT length FROM SFobjectField WHERE api_name = '%@' and object_api_name = '%@'", api_name, objectName];
	
	
	sqlite3_stmt * stmt = nil;
	
	if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
	{
		if (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
		{
			textLength = synchronized_sqlite3_column_int(stmt, 0);
		}
		
		synchronized_sqlite3_finalize(stmt);
	}

	return textLength;
}


//- (NSMutableString *) getAllEventRelatedIdFromSyncRecordHeap
//{
//	NSMutableString * Id = [[[NSMutableString alloc] initWithCapacity:0] autorelease];
//	
//	NSString * query = [NSString stringWithFormat:@"SELECT sf_id from %@ WHERE object_name = 'Event'", SYNC_RECORD_HEAP];
//	
//	sqlite3_stmt * stmt = nil;
//	
//	if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
//	{
//		while (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
//		{
//			char * eventId = (char *) synchronized_sqlite3_column_text(stmt, 0);
//			
//			if ([Id length] == 0)
//			{
//				[Id appendString:[NSMutableString stringWithFormat:@"'%@'", [NSMutableString stringWithUTF8String:eventId]]];
//			}
//			else
//			{
//				[Id appendString:[NSMutableString stringWithFormat:@" ,'%@'", [NSMutableString stringWithUTF8String:eventId]]];
//			}
//		}
//		
//		synchronized_sqlite3_finalize(stmt);
//	}
//	
//	
//	return Id;
//	
//	
//}
//- (void) deleteEventNotRelatedToLoggedInUser:(NSMutableString *)Id tableName:(NSString *)tableName
//{
//	NSString * settingValue = [appDelegate.settingsDict objectForKey:@"Synchronization To Remove Events"];
//    
//    NSTimeInterval value = [settingValue integerValue];
//	value = value - 1;
//    
//    NSString * startDate = [self getDateToDeleteEventsAndTaskOlder:value];
//	
//	settingValue = @"";
//    
//    settingValue = [appDelegate.settingsDict objectForKey:@"Synchronization To Get Events"];
//    
//    value = [settingValue integerValue];
//	value = value + 1;
//    
//    NSString * endDate = [appDelegate.dataBase getDateToDeleteEventsAndTaskForNext:value];
//
//	
//	NSString * query = [NSString stringWithFormat:@"DELETE FROM %@ where StartDateTime >= '%@' AND EndDateTime <= '%@' AND Id not in (%@) AND (Id != ' ' AND ID NOT NULL AND Id != '')", tableName,startDate, endDate, Id];
//	
//    char * err;
//	
//	if (synchronized_sqlite3_exec(appDelegate.db, [query UTF8String], NULL, NULL, &err) != SQLITE_OK)
//	{
//		SMLog(@"Failed to delete");
//	}
//}


-(void)UpdateSFRecordTypeForId:(NSString *)_id value:(NSString *)valueField
{
    //sahana RecordType fix  - Aug 16th 2012
    NSString * update_statement = [NSString stringWithFormat:@"UPDATE %@ SET %@ = '%@' WHERE record_type_id = '%@'",SFRecordType ,MRECORD_TYPE,valueField,_id];
    char * err;
    
    if(synchronized_sqlite3_exec(appDelegate.db, [update_statement UTF8String],NULL, NULL, &err) != SQLITE_OK)
    {
       
        SMLog(@"ERROR IN UPDATING");
    }
   // [update_statement release];
}
-(BOOL)isTabelExistInDB:(NSString*)tableName
{
    BOOL isTabel=FALSE;
   NSMutableString * queryStatementIstable = [NSMutableString stringWithFormat:@"SELECT name FROM sqlite_master WHERE type='table' AND name='%@'",tableName];
    sqlite3_stmt * labelstmt;
    const char *selectStatement = [queryStatementIstable UTF8String];
    char *fieldIsTable=nil;
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &labelstmt, nil) == SQLITE_OK )
    {
        if(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW)
        {
            fieldIsTable = (char *) synchronized_sqlite3_column_text(labelstmt,0);
            if ((fieldIsTable !=nil) && strlen(fieldIsTable))
            {
                isTabel=TRUE;
            }
        }
		synchronized_sqlite3_finalize(labelstmt);
    }
    return isTabel;

}

-(BOOL)isHeaderRecord:(NSString*)objectName
{
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM SFChildRelationship where object_api_name_child='%@'",objectName];
    sqlite3_stmt *statement;
    int row_count;
    if(appDelegate == nil)
        appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sql UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            row_count = synchronized_sqlite3_column_int(statement, 0);
            SMLog(@"No of location records in DB %d",row_count );
            
        }
        synchronized_sqlite3_finalize(statement);
    }
    if(row_count == 0)
        return TRUE;
    else
        return FALSE;
    
}
-(BOOL)isTableEmpty:(NSString*)tableName
{
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM '%@'",tableName];
    sqlite3_stmt *statement;
    int row_count;
    if(appDelegate == nil)
        appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sql UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            row_count = synchronized_sqlite3_column_int(statement, 0);
            SMLog(@"No of location records in DB %d",row_count );
            
        }
        synchronized_sqlite3_finalize(statement);
    }
    if(row_count == 0)
        return FALSE;
    else
        return TRUE;
    
}

//sahana Aug 16th ----------*********** end *************
-(void)getCodeSnippetSetting
{
    appDelegate.get_trigger_code = FALSE;
    NSString * _query = @"SELECT SVMXC__Setting_Unique_ID__c, SVMXC__SubmoduleID__c, SVMXC__SettingID__c, SVMXC__Settings_Name__c, SVMXC__Data_Type__c, SVMXC__Values__c, SVMXC__Default_Value__c, SVMXC__Setting_Type__c, SVMXC__Search_Order__c, SVMXC__IsPrivate__c, SVMXC__Active__c, SVMXC__Description__c, SVMXC__IsStandard__c, SVMXC__Submodule__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__SubmoduleID__c = 'IPAD007' AND SVMXC__SettingID__c = 'SET005'";
    [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(getCodeSnippetInfo:error:context:) context:nil];
    
    while(CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
        if(appDelegate.get_trigger_code)
        {
           
            break;
        }
        if (![appDelegate isInternetConnectionAvailable])
        { 
            break;
        }
        if (appDelegate.connection_error)
        {
            break;
        }
        
    }
    appDelegate.get_trigger_code = FALSE;
    
}

- (void) getCodeSnippetInfo:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    if(error != nil)
    {
        appDelegate.get_trigger_code = TRUE;
    }
    NSMutableArray * settings_Array = [[NSMutableArray alloc] initWithCapacity:0];
    if ([[result records] count] > 0)
    {
        
        ZKSObject * obj = [[result records] objectAtIndex:0];
    
        NSDictionary * dict = [obj fields];
        
        NSArray * all_unique_keys = [dict allKeys];
        if([all_unique_keys containsObject:@"SVMXC__Values__c"])
        {
            NSString * value_string = [dict objectForKey:@"SVMXC__Values__c"];
           
            NSArray  *  comma_seperatedValues  =  [value_string componentsSeparatedByString:@","];
            for(NSString * str in comma_seperatedValues)
            {
                
                if(appDelegate.code_snippet_ids == nil)
                {
                    appDelegate.code_snippet_ids = [[NSMutableArray alloc] initWithCapacity:0];
                }
                [appDelegate.code_snippet_ids addObject:str];
            }
        }
        
        [settings_Array addObject:dict];
        [self insertSettingsIntoTable:settings_Array:@"SettingsInfo"];
       
    }
  
    appDelegate.get_trigger_code = TRUE;
   
    
}
-(NSString *)getSettingUniqueIdForSettingId:(NSString *)setting_id submodule_id:(NSString *)submodule_id
{
    sqlite3_stmt * statement;
    NSString * Setting_Unique_ID__c = @"";
    NSString  * select_stmt = [NSString stringWithFormat:@"SELECT SVMXC__Values__c FROM  SettingsInfo WHERE SVMXC__SettingID__c = '%@' AND SVMXC__SubmoduleID__c = '%@'",setting_id , submodule_id];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [select_stmt UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            char * temp_field_name_value = (char *) synchronized_sqlite3_column_text(statement, 0);
            if(temp_field_name_value != nil)
            {
                Setting_Unique_ID__c = [NSString stringWithUTF8String:temp_field_name_value];
            }
            
        }
    }
    return Setting_Unique_ID__c;
}

-(void)createEventTrigger:(NSString *)code_snippet;
{

//    NSString * query = [NSString stringWithFormat:@"CREATE TRIGGER 'Event_trigger' BEFORE INSERT ON 'Event' FOR EACH ROW WHEN NEW.Id = '' AND              (SELECT NOT COUNT(*) FROm Event_local_Ids where local_id = NEW.local_id)  AND (SELECT  COUNT(*)  from  Event where(strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  (NEW.StartDatetime,'+0000','Z'))  <=  strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  ( StartDatetime, '+0000','Z') ) AND strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  (NEW.EndDateTime,'+0000','Z') )   > strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  ( StartDatetime, '+0000','Z') ) ) OR (strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  (NEW.StartDatetime,'+0000','Z') ) <  strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  ( EndDateTime, '+0000','Z') )   AND strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  (NEW.EndDateTime, '+0000','Z') ) >= strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  ( EndDateTime, '+0000','Z') ))  OR (strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  (NEW.StartDatetime, '+0000','Z') ) <= strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  ( StartDatetime, '+0000','Z') ) AND strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  (NEW.EndDateTime, '+0000','Z') ) >= strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  ( EndDateTime, '+0000','Z') )) OR (strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  (NEW.StartDatetime,'+0000','Z') ) >= strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  ( StartDatetime, '+0000','Z') )  and strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  (NEW.EndDateTime, '+0000','Z') ) <= strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  (EndDateTime, '+0000','Z') ))) BEGIN  SELECT RAISE(ABORT,'StartDate Time and EndDate Time'); END"];
    
//    NSString * query = [NSString stringWithFormat:@"%@",code_snippet];
  
    [self createTable:code_snippet];
}
@end
