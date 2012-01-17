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

@implementation DataBase 

@synthesize dbFilePath;
@synthesize didInsertTable;
//@synthesize db;
-(id)init
{
    appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
    return self;
}

/*-(id)initWithDBName:(NSString *)name type:(NSString *)type sqlite:(sqlite3 *)database
{
    appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    NSError *error; 
    NSArray *searchPaths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolderPath = [searchPaths objectAtIndex:0];
    dbFilePath = [[documentFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", DATABASENAME1, DATABASETYPE1]]retain];
   
    BOOL success=[[NSFileManager defaultManager] fileExistsAtPath:dbFilePath];
    if ( success)
    { 
        NSLog(@"\n db exist in the path");		
    }
    else    //didn't find db, need to copy
    {
        NSString *backupDbPath = [[NSBundle mainBundle] pathForResource:name ofType:type]; 
        if (backupDbPath == nil) 
        {
                NSLog(@"\n db not able to create error");   
        }
        else 
        { 
                BOOL copiedBackupDb = [[NSFileManager defaultManager] copyItemAtPath:backupDbPath toPath:dbFilePath error:&error]; 
                if (!copiedBackupDb) 
                    NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
        } 
    }
    if( sqlite3_open ([dbFilePath UTF8String], &db) != SQLITE_OK )
    { 
        NSLog (@"couldn't open db:"); 
        NSAssert(0, @"Database failed to open.");		//throw another exception here
        return nil;
    }
    return self;
}*/


#pragma mark - Initial MetaSync
- (void) insertValuesInToOBjDefTableWithObject:(NSMutableArray *)object definition:(NSMutableArray *)objectDefinition
{
    
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFObjectField ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0) ,'object_api_name' VARCHAR,'api_name' VARCHAR,'label' VARCHAR,'precision' DOUBLE,'length' INTEGER,'type' VARCHAR,'reference_to' VARCHAR,'nillable' BOOL,'unique' BOOL,'restricted_picklist' BOOL,'calculated' BOOL,'defaulted_on_create' BOOL,'name_field' BOOL, 'relationship_name' VARCHAR)"]];
    
    if (result == YES)
    {
        int id_value = 1;
        
        NSMutableArray * objectArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
        NSArray * fieldArray  = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
        NSString * objectName = @"";
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
               // NSLog(@"%@", dictionary);
                NSString * label = ([obj objectForKey:_LABEL] != nil)?[obj objectForKey:_LABEL]:@"";
                if (![label isEqualToString:@""])
                {
                    label = [label stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                }
                
                NSString * queryStatement =[NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@', '%@','%@', '%@', '%@', '%@', '%@', '%@', '%@') VALUES ( '%@', '%@', '%@', '%@', '%@', '%@', '%@','%@', '%@', '%@', '%@', '%@', '%@', '%d')", SFOBJECTFIELD ,MOBJECT_API_NAME, MFIELD_API_NAME, MLENGTH, MTYPEM, MREFERENCE_TO, MRELATIONSHIP_NAME, MLABEL, MPRECISION, MNILLABLE, MRESTRICTED_PICKLIST, MCALCULATED, MDEFAULT_ON_CREATE, MNAME_FIELD, MLOCAL_ID, objectName, 
                    ([obj objectForKey:FIELD] != nil)?[obj objectForKey:FIELD]:@"", 
                    ([obj objectForKey:_LENGTH] != nil)?[obj objectForKey:_LENGTH]:@"", 
                    ([obj objectForKey:_TYPE] != nil)?[obj objectForKey:_TYPE]:@"", 
                    ([obj objectForKey:_REFERENCETO] != nil)?[obj objectForKey:_REFERENCETO]:@"", 
                    ([obj objectForKey:_RELATIONSHIPNAME] != nil)?[obj objectForKey:_RELATIONSHIPNAME]:@"",
                    label, @"", @"", @"", @"", @"", ([obj objectForKey:_NAMEFIELD] != nil)?[obj objectForKey:_NAMEFIELD]:@"", 
                                            id_value++];
                char *err;
                if (sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
                {
                    NSLog(@"Failed to insert in to table");
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
                    NSString * queryStatement =[NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@') VALUES ('%@', '%@', '%@', '%d')", SFREFERENCETO, MOBJECT_API_NAME, _MFIELD_API_NAME, MREFERENCE_TO, MLOCAL_ID, objectName, 
                        ([obj objectForKey:FIELD] != nil)?[obj objectForKey:FIELD]:@"", 
                        ([obj objectForKey:_REFERENCETO] != nil)?[obj objectForKey:_REFERENCETO]:@"", id_Value++];
                                                
                    char *err;
                    if (sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
                    {
                        NSLog(@"Failed to insert in to table");
                    }

                }
            }
        }
    }
   // [self createObjectTable:object coulomns:objectDefinition];
    
    [self insertValuesInToRecordType:object defintion:objectDefinition];
    
}

- (void) insertValuesInToRecordType:(NSMutableArray *)object defintion:(NSMutableArray *)objectDefinition
{
    
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFRecordType ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0) ,'record_type_id' VARCHAR,'object_api_name' VARCHAR,'record_type' VARCHAR)"]];
    
    if (result == YES)
    {
        NSString * objectName = @"";
        int id_Value =  1;
        
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
            
            for (int r = 0; r < [recordKeys count]; r++)
            {
                if (![[recordKeys objectAtIndex:r] isEqualToString:MRECORDTYPE])
                {
                    
                    NSString * queryStatement =[NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@') VALUES ('%@', '%@', '%@', '%d')", SFRECORDTYPE, MRECORD_TYPE_ID, MOBJECT_API_NAME, MRECORD_TYPE, MLOCAL_ID, [recordKeys objectAtIndex:r], objectName, [recordValues objectAtIndex:r],id_Value++];
                    
                    char *err;
                    if (sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
                    {
                        NSLog(@"Failed to insert in to table");
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
            
            NSString * queryStatement = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@') VALUES ('%@', '%@', '%@', '%@', '%d')", SFOBJECT, MKEY_PREFIX, MLABEL, MLABEL_PURAL, MFIELD_API_NAME, MLOCAL_ID, 
                        ([objDef objectForKey:_MKEYPREFIX]!= nil)?[objDef objectForKey:_MKEYPREFIX]:@"",
                                         ([objDef objectForKey:_LABEL]!= nil)?[objDef objectForKey:_LABEL]:@"",
                        ([objDef objectForKey:_MPLURALLABEL]!= nil)?[objDef objectForKey:_MPLURALLABEL]:@"", objectName, ++id_Value];
            char * err;
            if (sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
            {
                NSLog(@"Failed To Insert");
            }
        }
    }
    //Radha 9th jan
    [self insertValuesInToChildRelationshipTable:object definition:objectDefintion];
    
    //[self createObjectTable:object coulomns:objectDefintion];
    
}

- (void) insertValuesInToChildRelationshipTable:(NSMutableArray *)object definition:(NSMutableArray *)objectDefinition
{
    
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFChildRelationship ('local_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  DEFAULT 0,'object_api_name_parent' VARCHAR, 'object_api_name_child' VARCHAR, 'cascade_delete' BOOL, 'field_api_name' VARCHAR)"]];
    
    if (result == YES)
    {
        int id_value = 0;
        NSString * objectName = @"";
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
                NSString * queryStatement = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@') VALUES ('%@', '%@', '%@', '%@', '%d')", SFCHILDRELATIONSHIP, @"object_api_name_parent", @"object_api_name_child", @"cascade_delete", @"field_api_name", MLOCAL_ID, objectName, [masterDetailKeys objectAtIndex:val], @"", [mastetDetaiValues objectAtIndex:val], ++id_value ];
                
                char * err;
                if (sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
                {
                    NSLog(@"Failed to insert");
                }
                
            }
        }
    }
    [self createObjectTable:object coulomns:objectDefinition];
}

- (void) createObjectTable:(NSMutableArray *)object coulomns:(NSMutableArray *)columns
{
 //   [self openDB:@"SFMTables" type:DATABASETYPE sqlite:self.db];
    
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
        //Temperory Change
        if ((![objectName isEqualToString:@"RecordType"]))
        {
            queryStatement =[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", objectName];
            if (sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
            {
                NSLog(@"Failed to drop");
                continue;
            }
            
            queryStatement = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0))", objectName, MLOCAL_ID];
            if (sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
            {
                NSLog(@"Failed to drop");
                continue;
            }
            
            [self insertColoumnsForTable:objectName columns:fieldArray];
        }

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
        if (sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
            NSLog(@"Failed to drop");
        }
    
    }
    //Just For testing purpose
    if ([tableName isEqualToString:@"Product2"])
    {
        NSString * query = [NSString stringWithFormat:@"INSERT INTO %@ (Name, Id) VALUES ('%@', '%@')", tableName, @"Wasing Machine",
                            @"01t70000002xWaeAAE"];
        char * err;
        if (sqlite3_exec(appDelegate.db, [query UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
            NSLog(@"Failed to insert");
        }
        

    }
}

- (void) insertValuesToProcessTable:(NSMutableDictionary *)processDictionary page:(NSMutableArray *)pageHistory
{
    int id_value = 0;
    NSArray * processArray = nil;
    NSMutableArray * processIdList = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    
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
            
            //    NSLog(@"%@", queryStatement);
            char * err;
            int ret = sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err);
            if (ret != SQLITE_OK)
            {
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
                    if (sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
                    {
                        if (sqlite3_step(statement) == SQLITE_ROW)
                        {
                            const char * _type = (char *)sqlite3_column_text(statement, 0);
                            if (strlen(_type))
                                process_type = [NSString stringWithUTF8String:_type];
                        }
                    }
                    
                    [page_dict setValue:process_type forKey:MPROCESSTYPE];
                    
                    NSString * err;
                    data = [NSPropertyListSerialization dataFromPropertyList:page_dict format:NSPropertyListXMLFormat_v1_0 errorDescription:&err];
                    
                    break;
                }                                                               
            }  
            NSString * queryStatement = [NSString stringWithFormat:@"Update SFProcess Set %@ = '%@', %@ = '%@' Where %@ = '%@' AND %@ = '%@'", MOBJECT_API_NAME, objectApiName, MPROCESS_INFO, data, MPAGE_LAYOUT_ID, pageId, MPROCESS_ID, process_id];
            char * err;
            if (sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
            {
                NSLog(@"Failed to insert");
            }
            //if (data)
              //  [data release];

        } 
    }
    
    
    result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFProcess_test ('process_id' VARCHAR,'layout_id' VARCHAR,'object_name' VARCHAR,'expression_id' VARCHAR,'object_mapping_id' VARCHAR,'component_type' VARCHAR,'local_id' INTEGER PRIMARY KEY  NOT NULL , 'parent_column' VARCHAR, 'value_id' VARCHAR, 'parent_object' VARCHAR)"]];
    
    if (result == YES)
    {
        NSArray * sfProcess_comp = [processDictionary objectForKey:MSFProcess_component];
        id_value = 0;
        
        NSString * processId = @"";
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
            
            NSString * queryStatement = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@',  '%@', '%@', '%@', '%@') VALUES ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@','%@', '%d')", @"SFProcess_test", MPROCESS_ID, @"layout_id", @"object_name", @"expression_id", @"object_mapping_id", @"component_type", @"parent_column", @"value_id", @"parent_object", MLOCAL_ID, processId, 
                                         ([dict objectForKey:MLAYOUT_ID] != nil)?[dict objectForKey:MLAYOUT_ID]:@"",
                                         ([dict objectForKey:MOBJECT_NAME] != nil)?[dict objectForKey:MOBJECT_NAME]:@"",
                                         ([dict objectForKey:MEXPRESSION_ID] != nil)?[dict objectForKey:MEXPRESSION_ID]:@"",
                                         ([dict objectForKey:MOBJECT_MAPPING_ID] != nil)?[dict objectForKey:MOBJECT_MAPPING_ID]:@"",
                                         ([dict objectForKey:MCOMPONENT_TYPE] != nil)?[dict objectForKey:MCOMPONENT_TYPE]:@"",
                                         ([dict objectForKey:MPARENT_COLUMN] != nil)?[dict objectForKey:MPARENT_COLUMN]:@"",
                                         ([dict objectForKey:MVALUE_MAPPING_ID] != nil)?[dict objectForKey:MVALUE_MAPPING_ID]:@"",
                                         ([dict objectForKey:MPARENT_OBJECT] != nil)?[dict objectForKey:MPARENT_OBJECT]:@"",
                                         ++id_value];
            char * err;
            if (sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
            {
                NSLog(@"Failed to insert");
            }
        }
    }
    NSMutableArray * process_comp_array = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];

    for (int i = 0; i < [processIdList count]; i++)
    {        
        NSString * queryStatement = [NSString stringWithFormat:@"SELECT process_type FROM SFProcess WHERE process_id = '%@'", [processIdList objectAtIndex:i]];
        sqlite3_stmt * statement;
        NSString * processType = @"";
        if (sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                const char * _type = (char *)sqlite3_column_text(statement, 0);
                if (strlen(_type))
                    processType = [NSString stringWithUTF8String:_type];
            }
        }
        NSArray * keys = [NSArray arrayWithObjects:MPROCESS_ID, MLAYOUT_ID, TARGET_OBJECT_NAME, SOURCE_OBJECT_NAME, EXPRESSION_ID, OBJECT_MAPPING_ID, MCOMPONENT_TYPE, MPARENT_COLUMN, MVALUE_MAPPING_ID, nil];
        NSString * processId = @"", * layoutId = @"", * sourceName = @"", * expressionId = @"", * oMappingId = @"",* componentType = @"", * parentColumn = @"", * targetName = @"", * vMappingid = @"";
                                                    
        if ([processType isEqualToString:VIEWRECORD])
        {
            queryStatement = [NSString stringWithFormat:@"SELECT * FROM SFprocess_test WHERE process_id = '%@'", [processIdList objectAtIndex:i]];
            
            if (sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
            {
                while (sqlite3_step(statement) == SQLITE_ROW)
                {
                    char * _processId = (char *) sqlite3_column_text(statement, COLUMNPROCESS_ID);
                    if ((_processId != nil) && strlen(_processId))
                        processId = [NSString stringWithUTF8String:_processId];
                    
                    char * _layoutId = (char *) sqlite3_column_text(statement, COLUMNLAYOUT_ID);
                    if ((_layoutId != nil) && strlen(_layoutId))
                        layoutId = [NSString stringWithUTF8String:_layoutId];
                    
                    char * _objectName = (char *) sqlite3_column_text(statement, COLUMNOBJECT_NAME);
                    if ((_objectName != nil) && strlen(_objectName))
                        sourceName = [NSString stringWithUTF8String:_objectName];
                    
                    char * _expressionId = (char *) sqlite3_column_text(statement, COLUMNEXPRESSION_ID);
                    if ((_expressionId != nil) && strlen(_expressionId))
                        expressionId = [NSString stringWithUTF8String:_expressionId];
                    
                    char * _mappingId = (char *) sqlite3_column_text(statement, COLUMNMAPPING_ID);
                    if ((_mappingId != nil) && strlen(_mappingId))
                        oMappingId = [NSString stringWithUTF8String:_mappingId];

                    char * _componentType = (char *) sqlite3_column_text(statement, COLUMNCOMP_TYPE);
                    if ((_componentType != nil) && strlen(_componentType))
                        componentType = [NSString stringWithUTF8String:_componentType];

                    char * _parentColumn = (char *) sqlite3_column_text(statement, COLUMNPARENT_COLUMN);
                    if ((_parentColumn != nil) && strlen(_parentColumn))
                        parentColumn = [NSString stringWithUTF8String:_parentColumn];
                    
                    char * _value_id = (char *) sqlite3_column_text(statement, COLUNMVALUEMAP);
                    if ((_value_id != nil) && strlen(_value_id))
                        vMappingid = [NSString stringWithUTF8String:_value_id];
                    
                    if (![sourceName isEqualToString:@""])
                        targetName = sourceName;
                        
                    NSArray * objects = [NSArray arrayWithObjects:processId, layoutId, targetName, sourceName, expressionId, oMappingId, componentType, parentColumn, vMappingid, nil];
                    
                    NSDictionary * dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
                    NSArray * arr = [NSArray arrayWithObject:dict];
                    [process_comp_array addObjectsFromArray:arr];
                }
                
            }
        }
        else if ([processType isEqualToString:EDIT])
        {
            queryStatement = [NSString stringWithFormat:@"SELECT * FROM SFprocess_test WHERE process_id = '%@'", [processIdList objectAtIndex:i]];
            
            if (sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
            {
                while (sqlite3_step(statement) == SQLITE_ROW)
                {
                    char * _processId = (char *) sqlite3_column_text(statement, COLUMNPROCESS_ID);
                    if ((_processId != nil) && strlen(_processId))
                        processId = [NSString stringWithUTF8String:_processId];
                    
                    char * _layoutId = (char *) sqlite3_column_text(statement, COLUMNLAYOUT_ID);
                    if ((_layoutId != nil) && strlen(_layoutId))
                        layoutId = [NSString stringWithUTF8String:_layoutId];
                    
                    char * _objectName = (char *) sqlite3_column_text(statement, COLUMNOBJECT_NAME);
                    if ((_objectName != nil) && strlen(_objectName))
                        sourceName = [NSString stringWithUTF8String:_objectName];
                    
                    char * _expressionId = (char *) sqlite3_column_text(statement, COLUMNEXPRESSION_ID);
                    if ((_expressionId != nil) && strlen(_expressionId))
                        expressionId = [NSString stringWithUTF8String:_expressionId];
                    
                    char * _mappingId = (char *) sqlite3_column_text(statement, COLUMNMAPPING_ID);
                    if ((_mappingId != nil) && strlen(_mappingId))
                        oMappingId = [NSString stringWithUTF8String:_mappingId];
                    
                    char * _componentType = (char *) sqlite3_column_text(statement, COLUMNCOMP_TYPE);
                    if ((_componentType != nil) && strlen(_componentType))
                        componentType = [NSString stringWithUTF8String:_componentType];
                    
                    char * _parentColumn = (char *) sqlite3_column_text(statement, COLUMNPARENT_COLUMN);
                    if ((_parentColumn != nil) && strlen(_parentColumn))
                        parentColumn = [NSString stringWithUTF8String:_parentColumn];
                    
                    char * _value_id = (char *) sqlite3_column_text(statement, COLUNMVALUEMAP);
                    if ((_value_id != nil) && strlen(_value_id))
                        vMappingid = [NSString stringWithUTF8String:_value_id];
                    
                    if (![sourceName isEqualToString:@""])
                        targetName = sourceName;
                    
                    NSArray * objects = [NSArray arrayWithObjects:processId, layoutId, targetName, sourceName, expressionId, oMappingId, componentType, parentColumn,vMappingid, nil];
                    
                    NSDictionary * dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
                    NSArray * arr = [NSArray arrayWithObject:dict];
                    [process_comp_array addObjectsFromArray:arr];
                }
               
            }

        }
        else if ([processType isEqualToString:STANDALONECREATE])
        {
            queryStatement = [NSString stringWithFormat:@"SELECT * FROM SFprocess_test WHERE process_id = '%@'", [processIdList objectAtIndex:i]];
            
            if (sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
            {
                while (sqlite3_step(statement) == SQLITE_ROW)
                {
                    char * _processId = (char *) sqlite3_column_text(statement, COLUMNPROCESS_ID);
                    if ((_processId != nil) && strlen(_processId))
                        processId = [NSString stringWithUTF8String:_processId];
                    
                    char * _layoutId = (char *) sqlite3_column_text(statement, COLUMNLAYOUT_ID);
                    if ((_layoutId != nil) && strlen(_layoutId))
                        layoutId = [NSString stringWithUTF8String:_layoutId];
                    
                    char * _objectName = (char *) sqlite3_column_text(statement, COLUMNOBJECT_NAME);
                    if ((_objectName != nil) && strlen(_objectName))
                        sourceName = [NSString stringWithUTF8String:_objectName];
                    
                    char * _expressionId = (char *) sqlite3_column_text(statement, COLUMNEXPRESSION_ID);
                    if ((_expressionId != nil) && strlen(_expressionId))
                        expressionId = [NSString stringWithUTF8String:_expressionId];
                    
                    char * _mappingId = (char *) sqlite3_column_text(statement, COLUMNMAPPING_ID);
                    if ((_mappingId != nil) && strlen(_mappingId))
                        oMappingId = [NSString stringWithUTF8String:_mappingId];
                    
                    char * _componentType = (char *) sqlite3_column_text(statement, COLUMNCOMP_TYPE);
                    if ((_componentType != nil) && strlen(_componentType))
                        componentType = [NSString stringWithUTF8String:_componentType];
                    
                    char * _parentColumn = (char *) sqlite3_column_text(statement, COLUMNPARENT_COLUMN);
                    if ((_parentColumn != nil) && strlen(_parentColumn))
                        parentColumn = [NSString stringWithUTF8String:_parentColumn];
                    
                    char * _value_id = (char *) sqlite3_column_text(statement, COLUNMVALUEMAP);
                    if ((_value_id != nil) && strlen(_value_id))
                        vMappingid = [NSString stringWithUTF8String:_value_id];
                    
                    if (![sourceName isEqualToString:@""])
                        targetName = sourceName;
                    
                    NSArray * objects = [NSArray arrayWithObjects:processId, layoutId, targetName, sourceName, expressionId, oMappingId, componentType, parentColumn, vMappingid, nil];
                    
                    NSDictionary * dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
                    NSArray * arr = [NSArray arrayWithObject:dict];
                    [process_comp_array addObjectsFromArray:arr];
                }
                
            }

        }
       /* else if ([processType isEqualToString:SOURCETOTARGET])
        {
            queryStatement = [NSString stringWithFormat:@"SELECT * FROM SFprocess_test WHERE process_id = '%@'", [processIdList objectAtIndex:i]];
            
            NSLog(@"cnvmxc");
            
            
        }
        else if ([processType isEqualToString:SOURCETOTARGETONLYCHILDROWS])
        {
            queryStatement = [NSString stringWithFormat:@"SELECT * FROM SFprocess_test WHERE process_id = '%@'", [processIdList objectAtIndex:i]];
        }*/
        
    }
    result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFProcessComponent ('process_id' VARCHAR,'layout_id' VARCHAR,'target_object_name' VARCHAR,'source_object_name' VARCHAR,'expression_id' VARCHAR,'object_mapping_id' VARCHAR,'component_type' VARCHAR,'local_id' INTEGER PRIMARY KEY  NOT NULL ,'parent_column' VARCHAR, 'value_mapping_id' VARCHAR)"]];
    
    if (result == YES)
    {
        id_value = 0;
        
        for (int i = 0; i < [process_comp_array count]; i++)
        {
            NSDictionary * dict = [process_comp_array objectAtIndex:i];
                        
            NSString * queryStatement = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@', '%@',  '%@', '%@', '%@') VALUES ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%d')", SFPROCESSCOMPONENT, MPROCESS_ID, MLAYOUT_ID, MTARGET_OBJECT_NAME, MSOURCE_OBJECT_NAME, MEXPRESSION_ID, MOBJECT_MAPPING_ID, MCOMPONENT_TYPE, MPARENT_COLUMN,MVALUE_MAPPING_ID, MLOCAL_ID, ([dict objectForKey:MPROCESS_ID] != nil)?[dict objectForKey:MPROCESS_ID]:@"",
                        ([dict objectForKey:MLAYOUT_ID] != nil)?[dict objectForKey:MLAYOUT_ID]:@"",
                        ([dict objectForKey:MTARGET_OBJECT_NAME] != nil)?[dict objectForKey:MTARGET_OBJECT_NAME]:@"",
                        ([dict objectForKey:SOURCE_OBJECT_NAME] != nil)?[dict objectForKey:MSOURCE_OBJECT_NAME]:@"",
                        ([dict objectForKey:MEXPRESSION_ID] != nil)?[dict objectForKey:MEXPRESSION_ID]:@"",
                        ([dict objectForKey:MOBJECT_MAPPING_ID] != nil)?[dict objectForKey:MOBJECT_MAPPING_ID]:@"",
                        ([dict objectForKey:MCOMPONENT_TYPE] != nil)?[dict objectForKey:MCOMPONENT_TYPE]:@"",
                        ([dict objectForKey:MPARENT_COLUMN] != nil)?[dict objectForKey:MPARENT_COLUMN]:@"",
                        ([dict objectForKey:MVALUE_MAPPING_ID] != nil)?[dict objectForKey:MVALUE_MAPPING_ID]:@"", ++id_value];
            char * err;
            if (sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
            {
                NSLog(@"Failed to insert");
            }
        }
                                     
    }
    [self insertValuesInToExpressionTables:processDictionary];
}

-(void) insertvaluesToPicklist:(NSMutableArray *)object fields:(NSMutableArray *)fields value:(NSMutableArray *)values
{
    
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFPickList ('local_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE, 'object_api_name' VARCHAR,'field_api_name' VARCHAR,'label' VARCHAR,'value' VARCHAR, 'defaultvalue'VARCHAR)"]];
    
    if (result == YES)
    {
        NSString * pickValue = @"";
        NSString * pickLabel = @"";
        NSString * defautPickValue = @"";
        int id_value = 1;
        
        for (int i = 0; i < [object count]; i++)
        {
            NSString * objectName = [[object objectAtIndex:i] objectForKey:OBJECT];
            
            NSDictionary * fieldDict = [fields objectAtIndex:i];
            
            NSArray * fieldArray = [fieldDict objectForKey:objectName];
            
       //     NSLog(@"%@", [fields objectAtIndex:i]);
            
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
                        
                        NSString * queryStatement =[NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@') VALUES ('%@', '%@', '%@', '%@', '%@', '%d')", SFPICKLIST, MOBJECT_API_NAME, _MFIELD_API_NAME, LABEL, MVALUEM, MDEFAULTVALUE, MLOCAL_ID, objectName, fieldName, pickLabel, pickValue, defautPickValue, id_value++];
                        
                        char *err;
                        if (sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
                        {
                            NSLog(@"Failed to insert in to table");
                        }                                                        
                    }
                }
            }
         }
    }
  //  appDelegate.wsInterface.didGetPicklistValueDb = TRUE;
    /*while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, FALSE))
    {
        if (appDelegate.wsInterface.didGetPicklistValueDb)
            break;
    }*/
    [appDelegate.wsInterface metaSyncWithEventName:SFW_METADATA eventType:SYNC values:nil];

}

- (void) insertValuesInToExpressionTables:(NSMutableDictionary *)processDictionary
{
    int id_value = 0;
    
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFExpression ('local_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , 'expression_id' VARCHAR, 'expression' VARCHAR, 'expression_name' VARCHAR)"]];
    if (result == YES)
    {
        
        NSArray * sfExpression = [processDictionary objectForKey:MSFExpression];
        
        for (int i = 0; i < [sfExpression count]; i++)
        {
            NSDictionary * dict = [sfExpression objectAtIndex:i];
            
            NSString * queryStatement =[NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@') VALUES ('%@', '%@', '%@', '%d')", SFEXPRESSION, MEXPRESSION_ID , MEXPRESSION_NAME, MEXPRESSION, MLOCAL_ID,
                                        ([dict objectForKey:MEXPRESSION_ID] != nil)?[dict objectForKey:MEXPRESSION_ID]:@"",
                                        ([dict objectForKey:MEXPRESSION_NAME] != nil)?[dict objectForKey:MEXPRESSION_NAME]:@"",
                                        ([dict objectForKey:MADVANCE_EXPRESSION] != nil)?[dict objectForKey:MADVANCE_EXPRESSION]:@"",
                                        ++id_value];
            char *err;
            if (sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
            {
                NSLog(@"Failed to insert in to table");
            }         
        }
    }
    id_value = 0;
    
    result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFExpressionComponent ('local_id' INTEGER PRIMARY KEY  NOT NULL ,'expression_id' VARCHAR,'component_sequence_number' VARCHAR,'component_lhs' VARCHAR,'component_rhs' VARCHAR,'operator'CHAR)"]];
    
    if (result == YES)
    {
    
        NSArray * sfExpression_com = [processDictionary objectForKey:MSFExpression_component];
        
        for (int i = 0; i < [sfExpression_com count]; i++)
        {
            NSDictionary * dict = [sfExpression_com objectAtIndex:i];
            
            NSString * queryStatement =[NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@') VALUES ('%@', '%@', '%@', '%@', '%@', '%d')", SFEXPRESSIONCOMPONENT, MEXPRESSION_ID, MCOMPONENT_SEQ_NUM, MCOMPONENT_LHS, MCOMPONENT_RHS, MOPERATOR, MLOCAL_ID,
                            ([dict objectForKey:MEXPRESSION_ID] != nil)?[dict objectForKey:MEXPRESSION_ID]:@"",
                            ([dict objectForKey:MSEQUENCE] != nil)?[dict objectForKey:MSEQUENCE]:@"",
                            ([dict objectForKey:MSOURCE_FIELD_NAME] != nil)?[dict objectForKey:MSOURCE_FIELD_NAME]:@"", 
                            ([dict objectForKey:MVALUEM] != nil)?[dict objectForKey:MVALUEM]:@"",
                            ([dict objectForKey:MOPERATOR] != nil)?[dict objectForKey:MOPERATOR]:@"",
                                        ++id_value];
            char *err;
            if (sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
            {
                NSLog(@"Failed to insert in to table");
            }         
        }
    }
    
    
    [self insertValuesInToObjectMappingTable:processDictionary];
}


- (void) insertValuesInToObjectMappingTable:(NSMutableDictionary *)processDictionary
{
    
    int id_value = 0;
    
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFObjectMapping ('local_id' INTEGER PRIMARY KEY  NOT NULL ,'object_mapping_id' VARCHAR , 'source_object_name' VARCHAR, 'target_object_name' VARCHAR)"]];
    if (result == YES)
    {
        NSArray * sfobjectMap = [processDictionary objectForKey:MSFObject_mapping];
        
        for (int i = 0; i < [sfobjectMap count]; i++)
        {
            NSDictionary * dict = [sfobjectMap objectAtIndex:i];
            
            NSString * queryStatement =[NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@') VALUES ('%@', '%@', '%@', '%d')", SFOBJECTMAPPING, MOBJECT_MAPPING_ID , MSOURCE_OBJECT_NAME, MTARGET_OBJECT_NAME, MLOCAL_ID,
                        ([dict objectForKey:MOBJECT_MAPPING_ID] != nil)?[dict objectForKey:MOBJECT_MAPPING_ID]:@"",
                        ([dict objectForKey:MSOURCE_OBJECT_NAME] != nil)?[dict objectForKey:MSOURCE_OBJECT_NAME]:@"",
                                        ([dict objectForKey:MTARGET_OBJECT_NAME] != nil)?[dict objectForKey:MTARGET_OBJECT_NAME]:@"", ++id_value];
            char *err;
            if (sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
            {
                NSLog(@"Failed to insert in to table");
            }         
        }
    }
    
    result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFObjectMappingComponent ('local_id' INTEGER PRIMARY KEY  NOT NULL ,'object_mapping_id' VARCHAR,'source_field_name' VARCHAR,'target_field_name' VARCHAR,'mapping_value' VARCHAR,'mapping_component_type' VARCHAR,'mapping_value_flag' BOOL)"]];
    
    if (result == YES)
    {
        NSArray * sfObject_com = [processDictionary objectForKey:MSFObject_mapping_component];
        
        NSString * flag = @"true";
        NSString * value = @"";
        id_value = 0;

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
            
            
            NSString * queryStatement =[NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@', '%@') VALUES ('%@', '%@', '%@', '%@', '%@', '%@', '%d')", SFOBJECTMAPCOMPONENT, MOBJECT_MAPPING_ID , MSOURCE_FIELD_NAME, MTARGET_FIELD_NAME, MMAPPING_VALUE, MMAPPING_COMP_TYPE, MMAPPING_VALUE_FLAG, MLOCAL_ID,
                        ([dict objectForKey:MOBJECT_MAPPING_ID] != nil)?[dict objectForKey:MOBJECT_MAPPING_ID]:@"",
                        ([dict objectForKey:MSOURCE_FIELD_NAME] != nil)?[dict objectForKey:MSOURCE_FIELD_NAME]:@"",
                        ([dict objectForKey:MTARGET_FIELD_NAME] != nil)?[dict objectForKey:MTARGET_FIELD_NAME]:@"",
                        ([dict objectForKey:MMAPPING_VALUE] != nil)?[dict objectForKey:MMAPPING_VALUE]:@"", value, flag,
                                        ++id_value];
            char *err;
            if (sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
            {
                NSLog(@"Failed to insert in to table");
            }         
        }
    }
    
    [self insertValuesInToLookUpTable:processDictionary];
   // appDelegate.wsInterface.didGetPageDataDb = TRUE;
  //  [appDelegate.wsInterface metaSyncWithEventName:SFM_OBJECT_DEFINITIONS eventType:SYNC values:nil];
}


- (void) insertValuesInToLookUpTable:(NSMutableDictionary *)processDictionary
{
    int id_value = 0;
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFNamedSearch ('local_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE , 'default_lookup_column' VARCHAR, 'search_name' VARCHAR, 'object_name' VARCHAR, 'search_type' VARCHAR, 'named_search_id' VARCHAR, 'no_of_lookup_records' VARCHAR, 'is_default' VARCHAR, 'is_standard' VARCHAR)"]];
    if (result == YES)
    {
        NSArray * sfNamedSearch = [processDictionary objectForKey:MSFNAMEDSEARCH];
        
        for (int i = 0; i < [sfNamedSearch count]; i++)
        {
            NSDictionary * nameSearchDict = [sfNamedSearch objectAtIndex:i];
            
            NSString * queryStatement = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@' ) VALUES ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%d')", SFNAMEDSEARCH, MDEFAULT_LOOKUP_COLUMN, MOBJECT_NAME, MSEARCH_NAME, MSEARCH_TYPE, MNAMED_SEARCHID, MNO_OF_LOOKUP_RECORDS, MIS_DEFAULT, MIS_STANDARD, MLOCAL_ID ,
                                         ([nameSearchDict objectForKey:MDEFAULT_LOOKUP_COLUMN] != nil)?[nameSearchDict objectForKey:MDEFAULT_LOOKUP_COLUMN]:@"",
                                         ([nameSearchDict objectForKey:MOBJECT_NAME] != nil)?[nameSearchDict objectForKey:MOBJECT_NAME]:@"",
                                         ([nameSearchDict objectForKey:MSEARCH_NAME] != nil)?[nameSearchDict objectForKey:MSEARCH_NAME]:@"",
                                         ([nameSearchDict objectForKey:MSEARCH_TYPE] != nil)?[nameSearchDict objectForKey:MSEARCH_TYPE]:@"",
                                         ([nameSearchDict objectForKey:MNAMED_SEARCHID] != nil)?[nameSearchDict objectForKey:MNAMED_SEARCHID]:@"",
                                         ([nameSearchDict objectForKey:MNO_OF_LOOKUP_RECORDS] != nil)?[nameSearchDict objectForKey:MNO_OF_LOOKUP_RECORDS]:@"",
                                         ([nameSearchDict objectForKey:MIS_DEFAULT] != nil)?[nameSearchDict objectForKey:MIS_DEFAULT]:@"",
                                         ([nameSearchDict objectForKey:MIS_STANDARD] != nil)?[nameSearchDict objectForKey:MIS_STANDARD]:@"", ++id_value]; 
            
            char * err;
            
            if (sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
            {
                NSLog(@"Failed To Insert");
            }
            
        }
        
    }
    
    result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFNamedSearchComponent ('local_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE , 'expression_type' VARCHAR, 'field_name' VARCHAR, 'named_search' VARCHAR, 'search_object_field_type' VARCHAR,  'field_type' VARCHAR, 'field_relationship_name' VARCHAR, 'sequence' VARCHAR)"]];
              
    id_value = 0;
    if (result == YES)
    {
        NSArray * sfNameSearchComp = [processDictionary objectForKey:MSFNAMEDSEARCH_COMPONENT];
        
        for (int i = 0; i < [sfNameSearchComp count]; i++)
        {
            NSDictionary * nameSearchComp = [sfNameSearchComp objectAtIndex:i];
            
            NSString * relationshipName = ([nameSearchComp objectForKey:MFIELD_RELATIONSHIPNAME] != nil)?[nameSearchComp objectForKey:MFIELD_RELATIONSHIPNAME]:@"";
            if (![relationshipName isEqualToString:@""])
                relationshipName = [relationshipName stringByReplacingOccurrencesOfString:@"__r" withString:@"__c"];
            
            NSString * queryStatement = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@',  '%@', '%@' ) VALUES ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%d')", SFNAMEDSEACHCOMPONENT, MEXPRESSION_TYPE,
                MFIELD_NAME, MNAMED_SEARCH, MSEARCH_OBJECT_FIELD, MFIELD_TYPE, MFIELD_RELATIONSHIPNAME, MSEQUENCE, MLOCAL_ID,  ([nameSearchComp objectForKey:MEXPRESSION_TYPE] != nil)?[nameSearchComp objectForKey:MEXPRESSION_TYPE]:@"", 
                    ([nameSearchComp objectForKey:MFIELD_NAME] != nil)?[nameSearchComp objectForKey:MFIELD_NAME]:@"", 
                    ([nameSearchComp objectForKey:MNAMED_SEARCH] != nil)?[nameSearchComp objectForKey:MNAMED_SEARCH]:@"", 
                    ([nameSearchComp objectForKey:MSEARCH_OBJECT_FIELD] != nil)?[nameSearchComp objectForKey:MSEARCH_OBJECT_FIELD]:@"", 
                    ([nameSearchComp objectForKey:MFIELD_TYPE] != nil)?[nameSearchComp objectForKey:MFIELD_TYPE]:@"", relationshipName,                           
                    ([nameSearchComp objectForKey:MSEQUENCE] != nil)?[nameSearchComp objectForKey:MSEQUENCE]:@"",  ++id_value];
            
            char * err;
            if (sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
            {
                NSLog(@"Failed To Insert");
            }
        }
    }
    appDelegate.wsInterface.didGetPageDataDb = TRUE;
}


- (void) insertValuesInToTagsTable:(NSMutableDictionary *)tagsDictionary
{
    int id_value = 0;
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS MobileDeviceTags ('local_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE , 'tag_id' VARCHAR, 'value' VARCHAR)"]];
    if (result == YES)
    {
    
        NSArray * keys = [tagsDictionary allKeys];
        NSArray * values = [tagsDictionary allValues];
        
        for (int i = 0; i < [keys count]; i++)
        {
            NSString * value = ([values objectAtIndex:i] != nil)?[values objectAtIndex:i]:@"";
            value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            
            
            NSString * queryStatement = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@' ) VALUES ('%@', '%@', '%d')", MOBILEDEVICETAGS, MTAG_ID, MVALUEM, MLOCAL_ID, [keys objectAtIndex:i], value,
                                         ++id_value];
            
            char * err;
            if (sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
            {
                NSLog(@"Failted to insert");
            }
            
        }
    }
   // appDelegate.wsInterface.didGetWizards = TRUE;
    [appDelegate.wsInterface metaSyncWithEventName:MOBILE_DEVICE_SETTINGS eventType:SYNC values:nil];
}

- (void) insertValuesInToSettingsTable:(NSMutableDictionary *)settingsDictionary
{
    int id_value = 0;
    
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS MobileDeviceSettings ('local_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE , 'setting_id' VARCHAR, 'value' VARCHAR)"]];
                                     
    if (result == YES)
    {
    
        NSArray * keys = [settingsDictionary allKeys];
        NSArray * values = [settingsDictionary allValues];
        
        for (int i = 0; i < [keys count]; i++)
        {
            NSString * queryStatement = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@' ) VALUES ('%@', '%@',      '%d')", MOBILEDEVICESETTINGS, MSETTING_ID, MVALUEM, MLOCAL_ID, [keys objectAtIndex:i],                                             [values objectAtIndex:i], ++id_value];
            
            char * err;
            if (sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
            {
                NSLog(@"Failted to insert");
            }
            
        }
    }
    appDelegate.wsInterface.didOpComplete = TRUE;

}

- (void) insertValuesInToSFWizardsTable:(NSDictionary *)wizardDict
{
    int id_value = 0;
    
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFWizard ('local_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , 'object_name' VARCHAR, 'wizard_id' VARCHAR, 'expression_id' VARCHAR, 'wizard_description' VARCHAR)"]];

    if (result == YES)
    {
        NSArray * sfWizard = [wizardDict objectForKey:MSFW_wizard];
        
        NSArray * sfexpression = [wizardDict objectForKey:MSFExpression];
        
        NSString * objectName = @"";
        
        for (int i = 0; i < [sfWizard count]; i++)
        {
            NSDictionary * dict = [sfWizard objectAtIndex:i];
            
            NSString * expression_id = [dict objectForKey:MEXPRESSION_ID];
            
            for (int j = 0; j < [sfexpression count]; j++)
            {
                NSDictionary * expDict = [sfexpression objectAtIndex:j];
                NSString * ex_id = [expDict objectForKey:MEXPRESSION_ID];
                
                if ([expression_id isEqualToString:ex_id])
                {
                    objectName = ([expDict objectForKey:MSOURCE_OBJECT_NAME] != nil)?[expDict objectForKey:MSOURCE_OBJECT_NAME]:@"";
                    break;
                }
                
            }
            if ([objectName isEqualToString:@""])
                objectName = ([dict objectForKey:MOBJECT_NAME] != nil)?[dict objectForKey:MOBJECT_NAME]:@"";
           
            NSString * queryStatement = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@' ) VALUES     ('%@', '%@', '%@', '%@', '%d')", SFWIZARD, MOBJECT_NAME, MWIZARD_ID, MEXPRESSION_ID, MWIZARD_DESCRIPTION, MLOCAL_ID, objectName, ([dict objectForKey:MWIZARD_ID] != nil)?[dict objectForKey:MWIZARD_ID]:@"",
                                    ([dict objectForKey:MEXPRESSION_ID] != nil)?[dict objectForKey:MEXPRESSION_ID]:@"",
                                    ([dict objectForKey:MWIZARD_DESCRIPTION] != nil)?[dict objectForKey:MWIZARD_DESCRIPTION]:@"",
                                         ++id_value];  
            char * err;
            if (sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
            {
                NSLog(@"Failted to insert");
            }
        }
    
    }
    
    result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFWizardComponent ('local_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , 'wizard_id' VARCHAR, 'action_id' VARCHAR, 'action_description' VARCHAR, 'expression_id' VARCHAR, 'process_id' VARCHAR, 'action_type' VARCHAR)"]];
    if (result == YES)
    {
        NSArray * sfExpComponent = [wizardDict objectForKey:MSFW_wizard_steps];
        NSArray * sfProcess = [appDelegate.wsInterface.processDictionary objectForKey:@"SFMProcess"];
        
        id_value = 0;
        NSString * wProcessId = @"";
        
        for (int i = 0; i < [sfExpComponent count]; i++)
        {
            NSDictionary * comp_dict = [sfExpComponent objectAtIndex:i];
            
            NSString * wizard_processId = ([comp_dict objectForKey:MPROCESS_ID] != nil)?[comp_dict objectForKey:MPROCESS_ID]:@"";
            
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
            
            
            NSString * queryStatement = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@', '%@') VALUES ('%@', '%@', '%@', '%@', '%@', '%@', '%d')", SFWIZARDCOMPONENT, MWIZARD_ID, MACTION_ID, MACTION_DESCRIPTION, MEXPRESSION_ID, MPROCESS_ID, MACTION_TYPE, MLOCAL_ID, 
                    ([comp_dict objectForKey:MWIZARD_ID] != nil)?[comp_dict objectForKey:MWIZARD_ID]:@"", @"",
                    ([comp_dict objectForKey:MWIZARD_STEP_NAME]!= nil)?[comp_dict objectForKey:MWIZARD_STEP_NAME]:@"",
                    ([comp_dict objectForKey:MEXPRESSION_ID] != nil)?[comp_dict objectForKey:MEXPRESSION_ID]:@"",
                    wProcessId, SFM, ++id_value];
            char * err;
            if (sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
            {
                NSLog(@"Failted to insert");
            }
            
        }
    }
   // appDelegate.wsInterface.didGetWizards = TRUE;
    [appDelegate.wsInterface metaSyncWithEventName:MOBILE_DEVICE_TAGS eventType:SYNC values:nil];
}

/*-(void)openDB:(NSString *)name type:(NSString *)type sqlite:(sqlite3 *)database
{
    NSError *error; 
    NSArray *searchPaths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolderPath = [searchPaths objectAtIndex: 0];
    dbFilePath = [[documentFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", name, type]]retain];
    
    BOOL success=[[NSFileManager defaultManager] fileExistsAtPath:dbFilePath];
    if ( success)
    { 
        NSLog(@"\n db exist in the path");		
    }
    else    //didn't find db, need to copy
    {
        NSString *backupDbPath = [[NSBundle mainBundle] pathForResource:name ofType:type]; 
        if (backupDbPath == nil) 
        {
            NSLog(@"\n db not able to create error");   
        }
        else 
        { 
            BOOL copiedBackupDb = [[NSFileManager defaultManager] copyItemAtPath:backupDbPath toPath:dbFilePath error:&error]; 
            if (!copiedBackupDb) 
                NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
        } 
    }
    if( sqlite3_open ([dbFilePath UTF8String], &db) != SQLITE_OK )
    { 
        NSLog (@"couldn't open db:");
        NSAssert(0, @"Database failed to open.");		//throw another exception here
    }
} */

#pragma mark - getTags
- (NSMutableDictionary *) getTagsDictionary
{
    sqlite3_stmt * statement;
    NSString * queryStatement = [NSString stringWithFormat:@"SELECT * FROM %@", MOBILEDEVICETAGS];
    
    NSMutableDictionary * tagDict = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
    
    if (sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW) 
        {
            NSString * key = @"";
            NSString * value = @"";
            char * _key = (char *) sqlite3_column_text(statement, 1);
           
            if((_key !=nil) && strlen(_key))
            {
                key = [NSString stringWithUTF8String:_key];
            }
            
            char * _value = (char *) sqlite3_column_text(statement, 2);
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

//Temperory Method - Removed After Data Sync is completed.
- (void) insertUsernameToUserTable:(NSString *)UserName
{
    NSString * queryStatement = [NSString stringWithFormat:@"INSERT INTO USER ('Username') VALUES ('%@')", UserName];
    
    char * err;
    if (sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        NSLog(@"Failed to insert");
    }
}


#pragma mark - Delete All Tables
- (void) clearDatabase
{
    sqlite3_stmt *stmt;
    NSMutableArray * tables = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    NSString * queryStatemnt = [NSString stringWithFormat:@"SELECT * FROM sqlite_master WHERE type = 'table'"];
    
    if (sqlite3_prepare_v2(appDelegate.db, [queryStatemnt UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW) 
        {
            char * _table = (char *) sqlite3_column_text(stmt, 1);
            if ((_table != nil) && strlen(_table))
            {
                NSString * table_name = [NSString stringWithUTF8String:_table];
                [tables addObject:table_name];
            }
            
        }
    }
    
    char * err;
    
    for (int i = 0; i < [tables count]; i++)
    {
        if (![[tables objectAtIndex:i] isEqualToString:@"Product2"])
        {
            queryStatemnt = [NSString stringWithFormat:@"DROP TABLE '%@'", [tables objectAtIndex:i]];
            if (sqlite3_exec(appDelegate.db, [queryStatemnt UTF8String], NULL, NULL, &err) != SQLITE_OK)
            {
                NSLog(@"Failed to drop");
            }

        }
        
     /*   if (sqlite3_exec(appDelegate.db, [queryStatemnt UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
            NSLog(@"Failed to drop");
        } */
    }
    
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
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS  SFSignatureData ('record_Id' VARCHAR,'object_api_name' VARCHAR,'signature_data' TEXT,'sig_Id' INTEGER PRIMARY KEY  NOT NULL ,'WorkOrderNumber' VARCHAR)"];
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS UserImages ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0), 'username' VARCHAR,'userimage' BLOB)"];
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS  trobleshootdata ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0),'ProductId' VARCHAR, 'ProductName' VARCHAR, 'Product_Doc' BLOB, 'DocId' VARCHAR, 'prod_manual_Id' VARCHAR, 'prod_manual_name' VARCHAR, 'productmanbody' VARCHAR)"];
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS  SVMXC__ServiceMax_Config_Data__c ('Id' TEXT,'SVMXC__Profile_Name__c' TEXT,'SVMXC__Active__c' BOOL,'SVMXC__IsDefault__c' BOOL,'SVMXC__RecordType_Name__c' TEXT,'SVMXC__Configuration_Type__c' VARCHAR,'SVMXC__Setting_Configuration_Profile__c' TEXT,'SVMXC__Setting_ID__c' VARCHAR,'SVMXC__Internal_Value__c' TEXT,'SVMXC__Display_Value__c' TEXT,'RecordTypeId' VARCHAR,'SVMXC__Setting_Unique_ID__c' TEXT,'local_id' INTEGER NOT NULL  DEFAULT (0) )"];
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS  SVMXC__ServiceMax_Processes__c ('Id' TEXT,'SVMXC__Name__c' TEXT,'SVMXC__Description__c' VARCHAR,'SVMXC__ModuleID__c' VARCHAR,'SVMXC__IsStandard__c' BOOL,'RecordTypeId' TEXT,'SVMXC__SubmoduleID__c' TEXT,'SVMXC__SettingID__c' TEXT,'SVMXC__Setting_Unique_ID__c' VARCHAR,'SVMXC__Settings_Name__c' TEXT,'SVMXC__Data_Type__c' VARCHAR,'SVMXC__Values__c' VARCHAR,'SVMXC__Default_Value__c' VARCHAR,'SVMXC__Setting_Type__c' VARCHAR,'SVMXC__Search_Order__c' TEXT,'SVMXC__IsPrivate__c' BOOL,'SVMXC__Active__c' BOOL,'SVMXC__Submodule__c' VARCHAR,'local_id' INTEGER NOT NULL  DEFAULT (0) , 'SVMXC__Module__c' VARCHAR)"];
    [self createTable:query];

    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFDataTrailer ('timestamp' DATETIME, 'local_id'INTEGER,'sf_id' VARCHAR, 'record_type' VARCHAR, 'operation' VARCHAR, 'object_name' VARCHAR, 'sync_flag' BOOL)"];
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS LookUpFieldValue ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0), 'object_api_name' VARCHAR, 'Id' VARCHAR, 'value' VARCHAR)"];
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE Event ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0), 'AccountId' TEXT,'ActivityDate' TEXT,'ActivityDateTime' DATETIME,'CreatedById' TEXT,'CreatedDate' DATETIME,'CurrencyIsoCode' TEXT,'Description' TEXT,'DurationInMinutes' INTEGER,'EndDateTime' DATETIME,'GroupEventType' VARCHAR,'IsAllDayEvent' BOOL,'IsArchived' BOOL,'IsChild' BOOL,'IsDeleted' BOOL,'IsGroupEvent' BOOL,'IsPrivate' BOOL,'IsRecurrence' BOOL,'IsReminderSet' BOOL,'LastModifiedById' VARCHAR,'LastModifiedDate' DATETIME,'Location' VARCHAR,'OwnerId' VARCHAR,'RecurrenceActivityId' VARCHAR,'RecurrenceDayOfMonth' INTEGER,'RecurrenceDayOfWeekMask' INTEGER,'RecurrenceEndDateOnly' VARCHAR,'RecurrenceInstance' VARCHAR,'RecurrenceInterval' INTEGER,'RecurrenceMonthOfYear' VARCHAR,'RecurrenceStartDateTime' DATETIME,'RecurrenceTimeZoneSidKey' VARCHAR,'RecurrenceType' VARCHAR,'ReminderDateTime' DATETIME,'SVMX_Event__c' VARCHAR,'ShowAs' VARCHAR,'StartDateTime' DATETIME,'Subject' VARCHAR,'SystemModstamp' DATETIME,'WhatId' VARCHAR,'WhoId' VARCHAR,'sa_EventStatus__c' VARCHAR,'sa_pick__c' VARCHAR,'Id' VARCHAR, 'IsVisibleInSelfService' BOOLEAN)"];
        [self createTable:query];
    
}


#pragma mark - Create All Tables
- (BOOL) createTable:(NSString *)statement
{
    char * err;
    
    if (sqlite3_exec(appDelegate.db, [statement UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
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
    int lookUp_id = 0;
    
    for (int i = 0; i < [fieldValueArray count]; i++)
    {
        NSDictionary * dict = [fieldValueArray objectAtIndex:i];
        
        NSArray * keys = [dict allKeys];
        
        for (int j = 0; j < [keys count]; j++)
        {
            NSString * objectName = [keys objectAtIndex:j];
            
            int id_value = 0;
            
            NSMutableArray * fieldArray = [dict objectForKey:[keys objectAtIndex:j]];
            
            for (int val = 0; val < [fieldArray count]; val++)
            {
                NSDictionary * fieldValues = [fieldArray objectAtIndex:val];
                
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
                        
                        if ([field_string length] > 0)
                        {
                            value_string = [value_string stringByAppendingString:@", "];
                            field_string = [field_string stringByAppendingString:@","];                        
                        }
                        
                        value_string = [value_string stringByAppendingString:[NSString stringWithFormat:@"'%@'", value]];
                        field_string = [field_string stringByAppendingString:[NSString stringWithFormat:@"%@", [fields objectAtIndex:f]]];
                    }
                }  
                
                NSString * query = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (%@, '%@') VALUES (%@, '%d')", objectName, field_string, MLOCAL_ID, value_string, id_value++];
                
                char * err;
                if (sqlite3_exec(appDelegate.db, [query UTF8String], NULL, NULL, &err) != SQLITE_OK)
                {  
                    NSLog(@"Failed to insert");
                }
            }
        }        
    }
    [self updateChildSfIdWithParentLocalId:appDelegate.wsInterface.childObject];
}

-(void) addvaluesToLookUpFieldTable:(NSDictionary *)lookUpDict WithId:(NSInteger)Id
{
    NSString * query = [NSString stringWithFormat:@"INSERT OR REPLACE INTO LookUpFieldValue ('%@', '%@', '%@', '%@') VALUES ('%@',    '%@', '%@', '%d')", MOBJECT_API_NAME, @"Id", MVALUEM, MLOCAL_ID, 
                        ([lookUpDict objectForKey:@"type"] != nil)?[lookUpDict objectForKey:@"type"]:@"", 
                        ([lookUpDict objectForKey:@"Id"] != nil)?[lookUpDict objectForKey:@"Id"]:@"", 
                        ([lookUpDict objectForKey:@"Name"] != nil)?[lookUpDict objectForKey:@"Name"]:@"", Id];
    
    char * err;
    if(sqlite3_exec(appDelegate.db, [query UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        NSLog(@"Failed to insert");
    }
    
}
-(void)  updateChildSfIdWithParentLocalId:(NSArray *)childObject
{
    for (NSString * objectName in childObject)
    {
        NSString * queryStatement = [NSString stringWithFormat:@"SELECT field_api_name, object_api_name_parent FROM SFChildRelationship where object_api_name_parent = (SELECT object_api_name_parent FROM SFChildRelationship WHERE object_api_name_child = '%@') and object_api_name_child = '%@'", objectName, objectName];
        
        sqlite3_stmt * statement;
        
        NSString * parentColumn = @""; 
        NSString * parent_object = @"";
        
        if (sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            if(sqlite3_step(statement))
            {
                char * _field_api_name = (char *)sqlite3_column_text(statement, 0);
                
                if ((_field_api_name != nil) && strlen(_field_api_name))
                    parentColumn = [NSString stringWithUTF8String:_field_api_name];
                
                char * _parent_object = (char *)sqlite3_column_text(statement, 1);
                
                if ((_parent_object != nil) && strlen(_parent_object))
                    parent_object = [NSString stringWithUTF8String:_parent_object];
            }
        }
        
        statement = nil;
        
        NSString * sfId = @"";
        int column = 0;
        queryStatement = [NSString stringWithFormat:@"SELECT %@ FROM %@", parentColumn, objectName];
        
        if (sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                char * _sfId = (char *) sqlite3_column_text(statement, column++);
                
                if ((_sfId != nil) && strlen(_sfId))
                    sfId = [NSString stringWithUTF8String:_sfId];
                
                queryStatement = [NSString stringWithFormat:@"SELECT local_id FROM %@ WHERE Id = '%@'", parent_object, sfId];
                
                if (sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
                {
                    if (sqlite3_step(statement))
                    {
                        int _localId = sqlite3_column_int(statement, 0);
                        
                        NSString * localId = [NSString stringWithFormat:@"%d", _localId];
                        
                        queryStatement = [NSString stringWithFormat:@"UPDATE %@ SET %@ = '%@' WHERE %@ = '%@'", objectName, parentColumn, localId, parentColumn, sfId];
                        
                        char * err;
                        if (sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
                        {
                            NSLog(@"Failed to update");
                        }
                    }
                                    
                }
                
                                
            }
        }        
        
    }
    appDelegate.wsInterface.didOpComplete = TRUE;
}

@end
