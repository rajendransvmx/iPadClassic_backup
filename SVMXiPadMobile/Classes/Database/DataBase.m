//
//  DataBase.m
//  iService
//
//  Created by Developer on 7/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DataBase.h"
#import "LocalizationGlobals.h"
#import "Globals.h"
#import "iServiceAppDelegate.h"

@implementation DataBase 
@synthesize dbFilePath;
@synthesize whatId1, subject;

-initWithDBName
{
   appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];    
    NSError *error; 
    NSArray *searchPaths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolderPath = [searchPaths objectAtIndex: 0];
    dbFilePath = [[documentFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", DATABASENAME, DATABASETYPE]]retain];
    NSLog(@"%@", dbFilePath);
    BOOL success=[[NSFileManager defaultManager] fileExistsAtPath:dbFilePath];
    if ( success)
    { 
            NSLog(@"\n db exist in the path");		
    }
    else    //didn't find db, need to copy
    {
            NSString *backupDbPath = [[NSBundle mainBundle] pathForResource:DATABASENAME ofType:DATABASETYPE]; 
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
}

-(void)insertIntoDBResponse:(NSMutableArray *)result
{
    resultArray = result;   
}

-(void)getPageLayoutDataFromDatabase:(NSMutableDictionary *)pageLayout
{
    NSLog(@"Pagelayout = %@", pageLayout);
    NSLog(@"PROCESSTYPE = %@", [pageLayout valueForKey:@"PROCESSTYPE"]);
    NSDictionary *header  = [pageLayout objectForKey:@"header"];
    NSLog(@"header = %@", header);
    NSString *tableName = [header objectForKey:@"hdr_Object_Name"];
    NSArray *hdr_Buttons  = [header objectForKey:@"hdr_Buttons"];
    NSDictionary *hdr_data = [header objectForKey:@"hdr_Data"];
    NSLog(@"hdr_data = %@", hdr_data);
    NSLog(@"SVMXC__Order_Status__c = %@",[hdr_data valueForKey:@"SVMXC__Order_Status__c"]);
    NSString *string = @"Open";
    NSLog(@"header_buttons = %@",hdr_Buttons);
    if ( [[pageLayout valueForKey:@"PROCESSTYPE"]isEqualToString:@"VIEWRECORD"])
    {
        /*####################################### HEADER VIEW #######################################*/
        if ( [[hdr_data valueForKey:@"SVMXC__Order_Status__c"] isEqualToString:string] )
        {
            NSArray *hdr_Sections = [header objectForKey:@"hdr_Sections"];
            NSLog(@"header_sections = %@", hdr_Sections);
            for ( int i = 0; i < [hdr_Sections count]; i++ )
            {
                NSLog(@"%@", [hdr_Sections objectAtIndex:i]); 
                NSDictionary *sections = [hdr_Sections objectAtIndex:i];
                NSArray *sectionsFields = [sections objectForKey:@"section_Fields"];
                NSMutableString *apiNames1 = [[NSMutableString alloc]initWithCapacity:0];
                NSMutableString *referencingTables = [[NSMutableString alloc]initWithCapacity:0];
                NSMutableString *compareTables = [[NSMutableString alloc]initWithCapacity:0];
                [referencingTables appendFormat:@"%@,", tableName];
                for (int j = 0; ([sectionsFields count]  && j < [sectionsFields count] ); j++ ) 
                {
                    NSLog(@"section_fields = %@", [sectionsFields objectAtIndex:j]);
                    NSMutableDictionary *mDict = [[NSMutableDictionary alloc]initWithCapacity:0];
                    mDict = [sectionsFields objectAtIndex:j];
                    int flag = 1;
                    if ( [[mDict valueForKey:@"Field_Data_Type"]isEqualToString:@"reference"])
                    {
                        NSString *reference = [mDict valueForKey:@"Field_Related_Object_Name"];
                        NSMutableString *referenceString = [[NSMutableString alloc]initWithCapacity:0];
                        [referenceString appendFormat:@"%@.Name",reference];
                        if ( j == 0 )
                        {
                            [referencingTables appendFormat:@"%@",reference];
                            [apiNames1 appendFormat:@"%@", referenceString];
                            [compareTables appendFormat:@"%@.%@ = %@.Id", tableName,[mDict valueForKey:@"Field_API_Name"],reference];
                        }
                        else
                        {
                            [referencingTables appendFormat:@",%@",reference];
                            [apiNames1 appendFormat:@",%@", referenceString];
                            [compareTables appendFormat:@",%@.%@ = %@.Id", tableName,[mDict valueForKey:@"Field_API_Name"],reference];
                        }
                        NSLog(@"%@", apiNames1);
                        [referenceString release];
                        flag = 0;
                    }
                    if ( flag == 1 )
                    {
                        if ( j == 0 )
                            [apiNames1 appendFormat:@" %@.%@ ",tableName,[mDict valueForKey:@"Field_API_Name"]];
                        else
                            [apiNames1 appendFormat:@",%@.%@ ",tableName,[mDict valueForKey:@"Field_API_Name"]];
                        NSLog(@"%@", apiNames1);
                    }
                    
                }
                NSLog(@"%@", apiNames1);
                if ( [sectionsFields count] && [compareTables isEqualToString:@""] )
                {
                    NSMutableString *finalQueryString =  [NSMutableString stringWithFormat:@"SELECT %@ FROM %@ WHERE Id = 1",apiNames1,referencingTables];
                    NSLog(@"FINAL QUERY STRING = %@", finalQueryString);
                }
                else if ( [sectionsFields count] )
                {
                    NSMutableString *finalQueryString =  [NSMutableString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@",apiNames1,referencingTables,compareTables];
                    NSLog(@"FINAL QUERY STRING = %@", finalQueryString);
                }
                [apiNames1 release];
                [referencingTables release];
                [compareTables release];
            }
            /*#################################### LINE VIEW ######################################*/
            NSArray *details = [pageLayout objectForKey:@"details"];
            NSLog(@"Details = %@", details);
            NSLog(@"%@", [details objectAtIndex:0]);
            for ( int i = 0; i < [details count]; i++ )
            {
                NSDictionary *detailsDict = [details objectAtIndex:i];
                NSString *lineTable = [[NSString alloc]init];
                lineTable = [detailsDict valueForKey:@"detail_object_name"];
                NSMutableArray  *detailsFields = [detailsDict objectForKey:@"details_Fields_Array"];
                NSMutableArray  *detailsValues = [detailsDict objectForKey:@"details_Values_Array"];
                NSMutableString *apiNames1 = [[NSMutableString alloc]initWithCapacity:0];
                NSMutableString *referencingTables = [[NSMutableString alloc]initWithCapacity:0];
                NSMutableString *compareTables = [[NSMutableString alloc]initWithCapacity:0];
                for ( int a = 0; a < [detailsFields count]; a++ )
                {
                    NSMutableDictionary *mDict = [[NSMutableDictionary alloc]init];
                    mDict = [detailsFields objectAtIndex:a];
                    int flag = 1;
                    if ( [[mDict valueForKey:@"Field_Data_Type"]isEqualToString:@"reference"])
                    {
                        NSString *reference = [mDict valueForKey:@"Field_Related_Object_Name"];
                        NSMutableString *referenceString = [[NSMutableString alloc]initWithCapacity:0];
                        [referenceString appendFormat:@"%@.Name",reference];
                        if ( a == 0 )
                        {
                            [referencingTables appendFormat:@"%@",reference];
                            [apiNames1 appendFormat:@"%@", referenceString];
                            [compareTables appendFormat:@"%@.%@ = %@.Id", lineTable,[mDict valueForKey:@"Field_API_Name"],reference];
                        }
                        else
                        {
                            [referencingTables appendFormat:@",%@",reference];
                            [apiNames1 appendFormat:@",%@", referenceString];
                            [compareTables appendFormat:@",%@.%@ = %@.Id", lineTable,[mDict valueForKey:@"Field_API_Name"],reference];
                        }
                        NSLog(@"%@", apiNames1);
                        [referenceString release];
                        flag = 0;
                    }
                    if ( flag == 1 )
                    {
                        if ( a == 0 )
                            [apiNames1 appendFormat:@" %@.%@ ",lineTable,[mDict valueForKey:@"Field_API_Name"]];
                        else
                            [apiNames1 appendFormat:@",%@.%@ ",lineTable,[mDict valueForKey:@"Field_API_Name"]];
                        NSLog(@"%@", apiNames1);
                    }
                    [mDict release];
                    
                 }
                NSLog(@"APINAMES = %@", apiNames1);
                
             }
            
        }
        else
        {
            NSLog(@"The Entry Criteria doesnt match the requirements");
        }
    }
    else if ( [[pageLayout valueForKey:@"PROCESSTYPE"]isEqualToString:@"EDIT"] )
    {
        [self standAloneEdit:pageLayout];  
    }
    else if ( [[pageLayout valueForKey:@"PROCESSTYPE"]isEqualToString:@"SOURCETOTARGET"] )
    {
        [self sourceToTarget:pageLayout];  
    }
    
}

- (void) standAloneEdit:(NSMutableDictionary*)pageLayout
{
    NSLog(@"I am in standAlone");
}

- (void) sourceToTarget:(NSMutableDictionary*)pageLayout
{
    NSLog(@"I am in source to target");
}

- (BOOL) isUsernamePresent:(NSString *)username password:(NSString *)passWord
{
    NSString *query = @"Select * from Users";
    int flag = 0;
    if (sqlite3_prepare_v2( db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while(sqlite3_step(statement) == SQLITE_ROW)
        {
            char *field1 = (char *) sqlite3_column_text(statement,0);
            NSString *field1Str = [[NSString alloc] initWithUTF8String: field1]; 
            
            char *field2 = (char *) sqlite3_column_text(statement,2);
            NSString *field2Str = [[NSString alloc] initWithUTF8String: field2]; 

            if ( [field1Str isEqualToString:username] && [field2Str isEqualToString:passWord] )
                flag = 1;
            
            [field1Str release];
            [field2Str release];
        }
    }
    if ( flag )
        return  YES;
    else
        return NO;
    
}

- (NSMutableArray *) getProcessFromDatabase
{
    NSString *query = @"Select * from Processes";
    NSMutableArray *viewArray = [[[NSMutableArray alloc]initWithCapacity:0]autorelease];
    
    const char * _query = [query UTF8String];
    
    if ( sqlite3_prepare_v2(db, _query,-1, &statement, nil) == SQLITE_OK )
    {
        while(sqlite3_step(statement) == SQLITE_ROW)
        {
            char *field1 = (char *) sqlite3_column_text(statement,1);
            NSString *field1Str = [[NSString alloc] initWithUTF8String: field1];
            [viewArray addObject:field1Str];
            
            char *field2 = (char *) sqlite3_column_text(statement,2);
            NSString *field2Str = [[NSString alloc] initWithUTF8String: field2];
            [viewArray addObject:field2Str];
            
            char *field3 = (char *) sqlite3_column_text(statement,3);
            NSString *field3Str = [[NSString alloc] initWithUTF8String: field3];
            [viewArray addObject:field3Str];
            
            [field1Str release];
            [field2Str release];
            [field3Str release];
        }
    }
    return  viewArray;
}


- (NSMutableArray *) getViewLayoutsFromDB
{
    NSString *query = @"Select * from ViewLayout";
    NSMutableArray *viewArray = [[[NSMutableArray alloc]initWithCapacity:0]autorelease];
    
    const char * _query = [query UTF8String];
    
    if ( sqlite3_prepare_v2(db, _query,-1, &statement, nil) == SQLITE_OK )
    {
        while(sqlite3_step(statement) == SQLITE_ROW)
        {
            NSMutableArray *_viewArray =[[NSMutableArray alloc]initWithCapacity:0];
            char *field1 = (char *) sqlite3_column_text(statement,0);
            NSString *field1Str = [[NSString alloc] initWithUTF8String: field1];
            [_viewArray addObject:field1Str];
            
            char *field2 = (char *) sqlite3_column_text(statement,1);
            
            NSString *field2Str = [[NSString alloc] initWithUTF8String: field2];
            [_viewArray addObject:field2Str];

            char *field3 = (char *) sqlite3_column_text(statement,2);
            NSString *field3Str = [[NSString alloc] initWithUTF8String: field3];
            [_viewArray addObject:field3Str];

            [viewArray addObject:_viewArray];
            [field1Str release];
            [field2Str release];
            [field3Str release];
            [_viewArray release];
        }
    }
    return  viewArray;
}

- (NSMutableArray *) didGetTaskFromDB:(NSString *)_date
{
    NSMutableString *query = [NSMutableString stringWithFormat:@"Select Priority, Subject, CreatedDate, Id from Tasks where CreatedDate = '%@'", _date];
    NSLog(@"%@", query);
    NSMutableArray *taskArray = [[[NSMutableArray alloc]initWithCapacity:0]autorelease];
    
    const char * _query = [query UTF8String];
    
    if ( sqlite3_prepare_v2(db, _query,-1, &statement, nil) == SQLITE_OK )
    {
        while(sqlite3_step(statement) == SQLITE_ROW)
        {
            NSMutableArray *_taskArray =[[NSMutableArray alloc]initWithCapacity:0];
            char *field1 = (char *) sqlite3_column_text(statement,0);
            NSString *field1Str = [[NSString alloc] initWithUTF8String: field1];
            [_taskArray addObject:field1Str];
            
            char *field2 = (char *) sqlite3_column_text(statement,1);
            NSString *field2Str = [[NSString alloc] initWithUTF8String: field2];
            [_taskArray addObject:field2Str];
            
            char *field3 = (char *) sqlite3_column_text(statement,2);
            NSString *field3Str = [[NSString alloc] initWithUTF8String: field3];
            [_taskArray addObject:field3Str];
            
            char *field4 = (char *) sqlite3_column_text(statement,3);
            NSString *field4Str = [[NSString alloc] initWithUTF8String: field4];
            [_taskArray addObject:field4Str];
            
            [taskArray addObject:_taskArray];
            [field1Str release];
            [field2Str release];
            [field3Str release];
            [field4Str release];
            [_taskArray release];
        }
    }
    return  taskArray; 
}

- (void) insertTasksIntoDB:(NSArray *)_tasks WithDate:(NSString*)_date
{
    NSLog(@"I am in DB");
    
    NSString *tableName = @"Tasks";
    NSString *sql = [NSString stringWithFormat: @"INSERT  INTO '%@' (Priority,Subject,CreatedDate) VALUES ('%@','%@', '%@')",
                     tableName, [_tasks objectAtIndex:0], [_tasks objectAtIndex:1], _date];
    
    NSLog(@"%@", sql);
    char *err;
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        NSLog(@"error");
    }
}


- (NSMutableArray *) GetEventsFromDBWithStartDate:(NSString *)startdate endDate:(NSString *)endDate
 {
     
     sqlite3_stmt *dbps;
     NSMutableArray * resultSet = [[NSMutableArray alloc] initWithCapacity:0];
     NSMutableString *queryStatement = [[NSMutableString alloc]initWithCapacity:0];
          
     queryStatement = [NSString stringWithFormat:@"SELECT  ActivityDate, ActivityDateTime,DurationInMinutes,EndDateTime,StartDateTime,Subject,WhatId,Id FROM Events where StartDateTime >= '%@' and EndDateTime <= '%@'", startdate, endDate];
         
     const char * selectStatement = [queryStatement UTF8String];
     
     int dbrc = sqlite3_prepare_v2(db, selectStatement, -1, &dbps, NULL);
     
     dbrc = sqlite3_step(dbps);
     NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init]autorelease];
     [dateFormatter setDateFormat:@"YYYY-MM-dd"];
     NSDateFormatter * datetimeFormatter=[[[NSDateFormatter alloc]init]autorelease];
     [datetimeFormatter  setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
     NSTimeZone * gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
     [datetimeFormatter setTimeZone:gmt];
     NSArray * keys = [NSArray arrayWithObjects:
                                            ACTIVITYDATE,
                                            ACTIVITYDTIME,
                                            DURATIONINMIN,
                                            ENDDATETIME,
                                            STARTDATETIME,
                                            SUBJECT,
                                            ADDITIONALINFO,
                                            WHATID,
                                            EVENTID,
                                            OBJECTAPINAME,
                                            nil];
 
            
     while (dbrc == SQLITE_ROW)
     {
     
         char * _activityDate = (char *) sqlite3_column_text(dbps,0);
         NSString * activitydate = @"";
         NSDate * activityDate = nil;
         if (activityDate == nil)
         activityDate = [[NSDate alloc] init];
         if ((_activityDate != nil) && strlen(_activityDate))
         {
             activitydate = [NSString stringWithCString:_activityDate encoding:NSUTF8StringEncoding];
             activitydate = [activitydate stringByDeletingPathExtension];
             activityDate = [datetimeFormatter dateFromString:activitydate];
             if (activityDate == nil)
             activityDate = [[NSDate alloc] init];
         
         }
         
         char * _activityDateTime = (char *) sqlite3_column_text(dbps,1);
         NSString *activitydateTime = @"";
         NSDate *activityDateTime = nil; 
         if (activityDateTime == nil)
         activityDateTime = [[NSDate alloc] init];
         if ((_activityDateTime != nil) && strlen(_activityDateTime))
         {
             activitydateTime = [NSString stringWithCString:_activityDateTime encoding:NSUTF8StringEncoding];
             activitydateTime = [activitydateTime stringByDeletingPathExtension];
             activityDateTime = [datetimeFormatter dateFromString:activitydateTime];
             if (activityDateTime == nil)
             activityDateTime = [[NSDate alloc] init];
         }
         
                
         char * _durationInMins = (char *) sqlite3_column_text(dbps,2);
         NSString * durationInMins = @"";
         if ((_durationInMins != nil) && strlen(_durationInMins))
         {
             durationInMins = [NSString stringWithUTF8String:_durationInMins];
         }
         
         char * _endDateTime = (char *) sqlite3_column_text(dbps,3);
         NSString * enddateTime = @"";
         NSDate * endDateTime = nil;
         if (endDateTime == nil)
         endDateTime = [[NSDate alloc] init];
         if ((_endDateTime != nil) && strlen(_endDateTime))
         {
             enddateTime = [NSString stringWithCString:_endDateTime encoding:NSUTF8StringEncoding];
             enddateTime = [enddateTime stringByDeletingPathExtension];
             endDateTime = [datetimeFormatter dateFromString:enddateTime];
             if (endDateTime == nil)
             endDateTime = [[NSDate alloc] init];
         }
         
                
         char * _startDateTime = (char *) sqlite3_column_text(dbps,4);
         NSString * startdateTime = @"";
         NSDate * startDateTime = nil;
         if (startDateTime == nil)
         startDateTime = [[NSDate alloc] init];
         if ((_startDateTime != nil) && strlen(_startDateTime))
         {
             startdateTime = [NSString stringWithCString:_startDateTime encoding:NSUTF8StringEncoding];
             startdateTime = [startdateTime stringByDeletingPathExtension];
             startDateTime = [datetimeFormatter dateFromString:startdateTime];
             if (startDateTime == nil)
             startDateTime = [[NSDate alloc] init];
         }
         
         char * _subject = (char *) sqlite3_column_text(dbps,5);
         
         if ((_subject != nil) && strlen(_subject))
         {
             subject = [NSString stringWithUTF8String:_subject];
         }
         
                
         char * _whatId = (char *) sqlite3_column_text(dbps,6);
         NSString *whatId = @"";
         if ((_whatId != nil) && strlen(_whatId))
         {
             whatId = [NSString stringWithUTF8String:_whatId];
             whatId1 = nil;
             whatId1 = whatId;
         }
         
         char *_eventId = (char *) sqlite3_column_text(dbps,7);
         NSString * eventId = @"";
         if ((_eventId != nil) && strlen(_eventId))
         {
             eventId = [NSString stringWithUTF8String: _eventId];
         }
             
         BOOL retVal, retVal1;
         retVal = [self isWorkOrder:whatId1];
         retVal1 = [self isCase:whatId1];
         if ( retVal == YES && (whatId1 != @"" || whatId1 != nil) )
         {
             NSString *subject1  = @"";
             NSMutableString *queryStatement = [[NSMutableString alloc]initWithCapacity:0];
             queryStatement = [NSString stringWithFormat:@"SELECT Name from SVMXC__Service_Order__c where Id = '%@'", whatId1];
             const char * selectStatement = [queryStatement UTF8String];
             if ( sqlite3_prepare_v2(db, selectStatement,-1, &statement, nil) == SQLITE_OK )
             {
                 while(sqlite3_step(statement) == SQLITE_ROW)
                 {
                     char * _subject = (char *) sqlite3_column_text(statement,0);
                     
                     if ((_subject != nil) && strlen(_subject))
                     {
                         subject1 = [NSString stringWithUTF8String:_subject];
                         subject = nil;
                         subject = subject1;
                         NSLog(@"%@", subject);
                     }
                     
                 }
                 
             }                 
             additonalInfo = @"";
             NSString * info = @"";
             queryStatement = [NSString stringWithFormat:@"SELECT ObjectLabel from LabelInfo where ObjectAPIName = '%@'", @"SVMXC__Service_Order__c"];
             selectStatement = [queryStatement UTF8String];
             if ( sqlite3_prepare_v2(db, selectStatement,-1, &statement, nil) == SQLITE_OK )
             {
                 while(sqlite3_step(statement) == SQLITE_ROW)
                 {
                     char * _addInfo = (char *) sqlite3_column_text(statement,0);
                     
                     if ((_addInfo != nil) && strlen(_addInfo))
                         info = [NSString stringWithUTF8String:_addInfo];
                 }
             }
             additonalInfo = [NSString stringWithFormat:@"%@ : %@", info, subject];
             objectApiName = @"SVMXC__Service_Order__c";
         }
         
         //Case 
         else if ( retVal1 == YES && (whatId1 != @"" || whatId1 != nil) )             {
             NSString * subject1  = @"";
             NSMutableString *queryStatement = [[NSMutableString alloc]initWithCapacity:0];
             queryStatement = [NSString stringWithFormat:@"SELECT CaseNumber from Case where Id = '%@'", whatId1];
             const char * selectStatement = [queryStatement UTF8String];
             if ( sqlite3_prepare_v2(db, selectStatement,-1, &statement, nil) == SQLITE_OK )
             {
                 while(sqlite3_step(statement) == SQLITE_ROW)
                 {
                     char * _subject = (char *) sqlite3_column_text(statement,0);
                     
                     if ((_subject != nil) && strlen(_subject))
                     {
                         subject1 = [NSString stringWithUTF8String:_subject];
                         subject = nil;
                         subject = subject1;
                         NSLog(@"%@", subject);
                     }
                     
                 }
                 
             }                 
             additonalInfo = @"";
             NSString * info = @"";
             queryStatement = [NSString stringWithFormat:@"SELECT ObjectLabel from LabelInfo where ObjectAPIName = '%@'", @"Case"];
             selectStatement = [queryStatement UTF8String];
             if ( sqlite3_prepare_v2(db, selectStatement,-1, &statement, nil) == SQLITE_OK )
             {
                 while(sqlite3_step(statement) == SQLITE_ROW)
                 {
                     char * _addInfo = (char *) sqlite3_column_text(statement,0);
                     
                     if ((_addInfo != nil) && strlen(_addInfo))
                         info = [NSString stringWithUTF8String:_addInfo];
                 }
             }
             additonalInfo = [NSString stringWithFormat:@"%@ : %@", info, subject];
             objectApiName = @"Case";
         }  
         
         //Other 
         // Radha and abinash 
         else
         {
             NSString * tableName = [self getTableNameForWhatId:whatId1];
             
             NSString * info = @"";
             queryStatement = [NSString stringWithFormat:@"SELECT ObjectLabel from LabelInfo where ObjectAPIName = '%@'", tableName];
             selectStatement = [queryStatement UTF8String];
             if ( sqlite3_prepare_v2(db, selectStatement,-1, &statement, nil) == SQLITE_OK )
             {
                 while(sqlite3_step(statement) == SQLITE_ROW)
                 {
                     char * _addInfo = (char *) sqlite3_column_text(statement,0);
                     
                     if ((_addInfo != nil) && strlen(_addInfo))
                         info = [NSString stringWithUTF8String:_addInfo];
                 }
             }
             if (whatId1 != nil || whatId1 != @"")
                 subject = [self getNameFieldForTableName:tableName];
             
             additonalInfo = [NSString stringWithFormat:@"%@ : %@", info, subject];
             objectApiName = tableName;
             
         }
         
         NSMutableArray * objects = [[NSArray arrayWithObjects:activityDate,
                                      activityDateTime,durationInMins,
                                      endDateTime,startDateTime,subject,additonalInfo,
                                      whatId,eventId, objectApiName, nil] retain];
         
         NSDictionary * dictionary = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
         [resultSet addObject:dictionary];
         [dictionary release];
         [objects release]; 
         
         // RELEASE ALL ALLOCATED OBJECTS AFTER ADDING THEM TO THE ARRAY
         dbrc= sqlite3_step(dbps);
     }
        
      NSLog(@"%@", resultSet);
      return resultSet;
 }


- (void) updateMovedEventWithStartTime:(NSString *)_startDT EndDate:(NSString *)_endDT RecordID:_recordId
{
    NSString *sql = [NSString stringWithFormat: @"Update  Events Set StartDateTime = '%@', EndDateTime = '%@', ActivityDateTime = '%@' Where Id = '%@'", _startDT, _endDT,_startDT, _recordId];
    NSLog(@"%@", sql);
    char *err;
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        sqlite3_close(db); 
        NSAssert(0, @"Error updating table.");
    }
}

- (BOOL) isWorkOrder:(NSString *)__whatId
{
    
    NSString *str = [__whatId substringToIndex:3];
    NSLog(@"%@" ,str);
    if ([str isEqualToString:@"a0t"])
        return YES;
    else
        return NO;
}

- (BOOL) isCase:(NSString *)whatId
{
    
    NSString *str = [whatId substringToIndex:3];
    NSLog(@"%@" ,str);
    if ([str isEqualToString:@"500"])
        return YES;
    else
        return NO;
}


- (void)dealloc
{
	sqlite3_close(db);
    [super dealloc];
}


- (NSString *)getColorCodeForPriority:(NSString *)whatId
{
    BOOL retVal;
    NSString *priority  = @"";
    retVal = [self isWorkOrder:whatId];
    if ( retVal == YES )
    {
        NSMutableString *queryStatement = [[NSMutableString alloc]initWithCapacity:0];
        queryStatement = [NSString stringWithFormat:@"SELECT SVMXC__Priority__c from SVMXC__Service_Order__c where Id = '%@'", whatId];
        const char * selectStatement = [queryStatement UTF8String];
        if ( sqlite3_prepare_v2(db, selectStatement,-1, &statement, nil) == SQLITE_OK )
        {
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                char * _priority = (char *) sqlite3_column_text(statement,0);
                
                if ((_priority != nil) && strlen(_priority))
                {
                    priority = [NSString stringWithUTF8String:_priority];
                    
                }

            }
         }                 
     }    
    if ( [priority isEqualToString:@"High"])
        return @"#F75D59";
    else if ( [priority isEqualToString:@"Medium"]) 
        return @"#ADDFFF";
    else if ( [priority isEqualToString:@"Low"]) 
        return @"#C9BE62";
    else
        return @"";
}


- (void)deleteTaskFromDB:(NSString *)taskId
{
    NSLog(@"%@", taskId);
    NSMutableString *queryStatement = [[NSMutableString alloc]initWithCapacity:0];
    queryStatement = [NSString stringWithFormat:@"Delete  from Tasks where Id = '%@'", taskId];
    const char * selectStatement = [queryStatement UTF8String];
    char *err;
    
    if (sqlite3_exec(db, selectStatement, NULL, NULL, &err) != SQLITE_OK)
    {
        sqlite3_close(db); 
        NSAssert(0, @"Error updating table.");
    }

}

- (NSString *) retreiveCurrentTaskIdCreated
{
    NSString *field1Str = @"";
    NSMutableString *queryStatement = [[NSMutableString alloc]initWithCapacity:0];
    queryStatement = [NSString stringWithFormat:@"Select Id from Tasks where Id = (Select MAX (Id) From Tasks)"];
    NSLog(@"%@", queryStatement);
    const char * selectStatement = [queryStatement UTF8String];
    
    if ( sqlite3_prepare_v2(db, selectStatement,-1, &statement, nil) == SQLITE_OK )
    {
        if(sqlite3_step(statement) == SQLITE_ROW)
        {
            char *field1 = (char *) sqlite3_column_text(statement,0);
            field1Str = [[NSString alloc] initWithUTF8String: field1];
            
        }
    
    }
    return  field1Str;
}

- (NSString *) getTableNameForWhatId:(NSString *)whatId
{
    if ([[whatId substringToIndex:3] isEqualToString:@"a0S"])
        return @"SVMXC__RMA_Shipment_Order__c";
    else if ([[whatId substringToIndex:3] isEqualToString:@"a0C"]) 
        return @"SVMXC__Installed_Product__c";
    else if ([[whatId substringToIndex:3] isEqualToString:@"a0p"])
        return @"SVMXC__Service_Group_Skills__c";
    else if ([[whatId substringToIndex:3] isEqualToString:@"a0G"])
        return @"SVMXC__Offline_View__c";
    else
        return @"";
    
}

- (NSString *) getNameFieldForTableName:(NSString *)tableName
{
    NSString *fieldStr = @"";
    NSMutableString *queryStatement = [[NSMutableString alloc]initWithCapacity:0];
    queryStatement = [NSString stringWithFormat:@"Select NameField From LabelInfo where ObjectAPIName = '%@'",tableName];
    const char * selectStatement = [queryStatement UTF8String];
    
    if ( sqlite3_prepare_v2(db, selectStatement,-1, &statement, nil) == SQLITE_OK )
    {
        if(sqlite3_step(statement) == SQLITE_ROW)
        {
            char *field1 = (char *) sqlite3_column_text(statement,0);
            fieldStr = [[NSString alloc] initWithUTF8String:field1];
            
        }
    }
    return  fieldStr;
}

//Abinash

/*-(BOOL) isEventWithoutViewProcess:(NSString *)__whatId
{
    NSString *str = [__whatId substringToIndex:3];
    if ([str isEqualToString:@"a0G"]) 
        return YES;
    else
        return NO;
}*/

//Abinash
#pragma mark - Service Report Methods

-(NSString*)getNameField:(NSString *)SVMXC__Product__c
{
    NSMutableString *queryStatement = [[NSMutableString alloc]initWithCapacity:0];
    NSString * Name1 = @"";
    sqlite3_stmt *statement1;
    queryStatement = [NSString stringWithFormat:@"SELECT Name from Product2 where Id = '%@'", SVMXC__Product__c];
    NSLog(@"%@",queryStatement);   
    const  char * selectStatement = [queryStatement UTF8String];
    if ( sqlite3_prepare_v2(db, selectStatement,-1, &statement1, nil) == SQLITE_OK )
    {
        if(sqlite3_step(statement1) == SQLITE_ROW)
        {
            char * _name = (char *) sqlite3_column_text(statement1,0);
            
            if ((_name != nil) && strlen(_name))
                Name1 = [NSString stringWithUTF8String:_name];
        }
    }
    return Name1;
 
}
//Abinash


 //For Expenses
-(NSMutableArray*)queryForExpenses:(NSString *)currentRecordId
{
        NSMutableString *queryStatement = [[NSMutableString alloc]initWithCapacity:0];
        Expenses = [[NSMutableArray alloc] initWithCapacity:0];
        sqlite3_stmt *statement1;
        queryStatement = [NSString stringWithFormat:@"SELECT Id, SVMXC__Expense_Type__c, SVMXC__Actual_Quantity2__c, SVMXC__Actual_Price2__c, SVMXC__Work_Description__c FROM SVMXC__Service_Order_Line__c WHERE SVMXC__Line_Type__c = 'Expenses' AND SVMXC__Service_Order__c = '%@' AND SVMXC__Is_Billable__c = 'true'", currentRecordId];
        NSLog(@"%@",queryStatement);
        const char * _query = [queryStatement UTF8String];
        NSArray * keys = [NSArray arrayWithObjects:
                          _ID,
                          SVMXC__EXPENSE_TYPE__C,
                          SVMXC__ACTUAL_QUANTITY2__C,
                          SVMXC__ACTUAL_PRICE2__C,
                          SVMXC__WORK_DESCRIPTION__C,
                          nil];
    
        if ( sqlite3_prepare_v2(db, _query,-1, &statement1, nil) == SQLITE_OK )
        {
            while(sqlite3_step(statement1) == SQLITE_ROW)
            {
                char *_Id = (char *) sqlite3_column_text(statement1,0);
                NSString * Id = @"";    
                if ((_Id != nil) && strlen(_Id))
                {         
                    Id = [[NSString alloc] initWithUTF8String:_Id];
                    
                }
                char *_SVMXC__Expense_Type__c = (char *) sqlite3_column_text(statement1,1);
                NSString * SVMXC__Expense_Type__c = @"";
                if ((_SVMXC__Expense_Type__c != nil) && strlen(_SVMXC__Expense_Type__c))
                {         
                    SVMXC__Expense_Type__c = [[NSString alloc] initWithUTF8String:_SVMXC__Expense_Type__c];
                }  
                char *_SVMXC__Actual_Quantity2__c = (char *) sqlite3_column_text(statement1,2);
                NSString * SVMXC__Actual_Quantity2__c_ = @"";    
                if ((_SVMXC__Actual_Quantity2__c != nil) && strlen(_SVMXC__Actual_Quantity2__c))
                {         
                    SVMXC__Actual_Quantity2__c_ = [[NSString alloc] initWithUTF8String:_SVMXC__Actual_Quantity2__c];
                }
                char *_SVMXC__Actual_Price2__c = (char *) sqlite3_column_text(statement1,3);
                NSString * SVMXC__Actual_Price2__c_ = @"";    
                if ((_SVMXC__Actual_Price2__c != nil) && strlen(_SVMXC__Actual_Price2__c))
                {         
                    SVMXC__Actual_Price2__c_ = [[NSString alloc] initWithUTF8String:_SVMXC__Actual_Price2__c];
                }   
                char *_SVMXC__Work_Description_c = (char *) sqlite3_column_text(statement1,4);
                NSString * SVMXC__Work_Description_c = @"";    
                if ((_SVMXC__Work_Description_c != nil) && strlen(_SVMXC__Work_Description_c))
                {         
                    SVMXC__Work_Description_c = [[NSString alloc] initWithUTF8String:_SVMXC__Work_Description_c];
                }   
                NSMutableArray * objects = [[NSMutableArray arrayWithObjects:Id,SVMXC__Expense_Type__c, SVMXC__Actual_Quantity2__c_,SVMXC__Actual_Price2__c_,SVMXC__Work_Description_c,nil] retain];
                
                NSDictionary * dictionary = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
                [Expenses addObject:dictionary];
                [dictionary release];
                [objects release]; 
                NSLog(@"%@",Expenses);
                
            }
        } 
        
    return Expenses;
    }

//For Parts
- (NSMutableArray *) queryForParts:(NSString *)currentRecordId
{
    NSMutableDictionary * part = nil;
    NSMutableString *queryStatement = [[NSMutableString alloc]initWithCapacity:0];
    sqlite3_stmt *statement1;
    NSString * nameField = @"";
    
    Parts = [[NSMutableArray alloc] initWithCapacity:0];

    queryStatement = [NSString stringWithFormat:@"SELECT Id, SVMXC__Product__c,SVMXC__Actual_Quantity2__c, SVMXC__Actual_Price2__c, SVMXC__Work_Description__c, SVMXC__Discount__c, Name FROM SVMXC__Service_Order_Line__c WHERE SVMXC__Line_Type__c = 'Parts' AND SVMXC__Service_Order__c = '%@' AND SVMXC__Actual_Quantity2__c > 0 AND SVMXC__Actual_Price2__c >= 0 AND SVMXC__Is_Billable__c ='true'", currentRecordId];
    NSLog(@"%@",queryStatement);
    const char * _query = [queryStatement UTF8String];
    if ( sqlite3_prepare_v2(db, _query,-1, &statement1, nil) == SQLITE_OK )
    {
        while(sqlite3_step(statement1) == SQLITE_ROW)
        {
            NSMutableArray * keys = [NSMutableArray arrayWithObjects:
                                     _ID,
                                     SVMXC__PRODUCT__C,
                                     SVMXC__PRODUCT2__NAME,
                                     SVMXC__ACTUAL_QUANTITY2__C,
                                     SVMXC__ACTUAL_PRICE2__C,
                                     SVMXC__WORK_DESCRIPTION__C,
                                     SVMXC__DISCOUNT__C,
                                     nil];

            char *_Id = (char *) sqlite3_column_text(statement1,0);
            NSString * Id = @"";    
            if ((_Id != nil) && strlen(_Id))
            {         
                Id = [[NSString alloc] initWithUTF8String:_Id];
                
            }
            char *_SVMXC__Product__c = (char *) sqlite3_column_text(statement1,1);
            NSString * SVMXC__Product__c = @"";
            if ((_SVMXC__Product__c != nil) && strlen(_SVMXC__Product__c))
            {         
                SVMXC__Product__c = [[NSString alloc] initWithUTF8String:_SVMXC__Product__c];
                nameField = [self getNameField:SVMXC__Product__c];
            }  
            char *_SVMXC__Actual_Quantity2__c = (char *) sqlite3_column_text(statement1,2);
            NSString * SVMXC__Actual_Quantity2__c_ = @"";    
            if ((_SVMXC__Actual_Quantity2__c != nil) && strlen(_SVMXC__Actual_Quantity2__c))
            {         
                SVMXC__Actual_Quantity2__c_ = [[NSString alloc] initWithUTF8String:_SVMXC__Actual_Quantity2__c];
            }
            char *_SVMXC__Actual_Price2__c = (char *) sqlite3_column_text(statement1,3);
            NSString * SVMXC__Actual_Price2__c_ = @"";    
            if ((_SVMXC__Actual_Price2__c != nil) && strlen(_SVMXC__Actual_Price2__c))
            {         
                SVMXC__Actual_Price2__c_ = [[NSString alloc] initWithUTF8String:_SVMXC__Actual_Price2__c];
            }   
            char *_SVMXC__Work_Description_c = (char *) sqlite3_column_text(statement1,4);
            NSString * SVMXC__Work_Description_c = @"";    
            if ((_SVMXC__Work_Description_c != nil) && strlen(_SVMXC__Work_Description_c))
            {         
                SVMXC__Work_Description_c = [[NSString alloc] initWithUTF8String:_SVMXC__Work_Description_c];
            }   
            char *_SVMXC__Discount__c = (char *) sqlite3_column_text(statement1,5);
            NSString * SVMXC__Discount__c = @"";    
            if ((_SVMXC__Discount__c != nil) && strlen(_SVMXC__Discount__c))
            {         
                SVMXC__Discount__c = [[NSString alloc] initWithUTF8String:_SVMXC__Discount__c];
            } 
            
            NSMutableArray * objects = [[NSMutableArray arrayWithObjects:Id,SVMXC__Product__c,nameField,SVMXC__Actual_Quantity2__c_,SVMXC__Actual_Price2__c_,SVMXC__Work_Description_c,SVMXC__Discount__c,nil] retain];
            NSLog(@"%@ %@", objects, keys);
            
            NSDictionary * dictionary = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
            
            [objects removeAllObjects];
            [keys removeAllObjects];
            
            
            keys = [NSMutableArray arrayWithObjects:gName,
                                                    gPartsUsed,
                                                    KEY_PARTDESCRIPTION,
                                                    KEY_COSTPERPART,
                                                    KEY_PRODUCTID,
                                                    KEY_DISCOUNT,
                                                    nil];
                                            
            
            
            NSString * numPartsUsed = [dictionary objectForKey:gSVMXC__Actual_Quantity2__c];
            if ([numPartsUsed isKindOfClass:[NSString class]] && numPartsUsed != nil)
             numPartsUsed = [NSString stringWithFormat:@"%d", [numPartsUsed intValue]];
            
            NSString * description = [dictionary objectForKey:gSVMXC__Work_Description__c];
            if ([description isKindOfClass:[NSString class]])
                 description = [NSString stringWithFormat:@"%@", description];
            
            NSString * costPerPart = @"";
            costPerPart = [dictionary objectForKey:gSVMXC__Actual_Price2__c];
            
            NSString * keyProduct = @"";
            keyProduct = [dictionary objectForKey:gSVMXC__Product__c];
            
            NSString * discount = [dictionary objectForKey:gSVMXC__Discount__c];
            if ([discount isKindOfClass:[NSString class]])
                discount = [NSString stringWithFormat:@"%@", discount];

            objects = [NSMutableArray arrayWithObjects:nameField,numPartsUsed,description,costPerPart, keyProduct, discount,
                       nil];
                    
            part = [NSMutableDictionary dictionaryWithObjects:objects forKeys:keys];
            NSLog(@"%@", part);
            [Parts addObject:part];
            [objects removeAllObjects];
            [keys removeAllObjects];
            [dictionary release];            
        }
    } 
    NSLog(@"%@", Parts);
    return Parts;
}

//For Labour
- (NSMutableDictionary *) queryForLabor:(NSString *)currentRecordId    
{ 
    NSMutableDictionary * LabourValuesDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSMutableArray * linePriceItems = [[NSMutableArray alloc] initWithCapacity:0];

    Labor = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableString *queryStatement = [[NSMutableString alloc]initWithCapacity:0];
    sqlite3_stmt *statement1;
   
    queryStatement = [NSString stringWithFormat:@"SELECT Id, SVMXC__Activity_Type__c, SVMXC__Actual_Quantity2__c, SVMXC__Actual_Price2__c, SVMXC__Work_Description__c FROM SVMXC__Service_Order_Line__c WHERE SVMXC__Line_Type__c = 'Labor' AND SVMXC__Service_Order__c = '%@' AND SVMXC__Actual_Quantity2__c > 0 AND SVMXC__Actual_Price2__c >= 0 AND SVMXC__Is_Billable__c = 'true'", currentRecordId];
    NSLog(@"%@",queryStatement);
    const char * _query = [queryStatement UTF8String];
    NSArray * keys = [NSArray arrayWithObjects:
                      _ID,
                      SVMXC__ACTIVITY_TYPE__C,
                      SVMXC__ACTUAL_QUANTITY2__C,
                      SVMXC__ACTUAL_PRICE2__C,
                      SVMXC__WORK_DESCRIPTION__C,
                      nil];
    if ( sqlite3_prepare_v2(db, _query,-1, &statement1, nil) == SQLITE_OK )
    {
        while(sqlite3_step(statement1) == SQLITE_ROW)
        {
            char *_Id = (char *) sqlite3_column_text(statement1,0);
            NSString * Id = @"";    
            if ((_Id != nil) && strlen(_Id))
            {         
                Id = [[NSString alloc] initWithUTF8String:_Id];
                
            }
            char *_SVMXC__Activity_Type__c = (char *) sqlite3_column_text(statement1,1);
            NSString * SVMXC__Activity_Type__c_ = @"";
            if ((_SVMXC__Activity_Type__c != nil) && strlen(_SVMXC__Activity_Type__c))
            {         
                SVMXC__Activity_Type__c_ = [[NSString alloc] initWithUTF8String:_SVMXC__Activity_Type__c];
            }  
            char *_SVMXC__Actual_Quantity2__c = (char *) sqlite3_column_text(statement1,2);
            NSString * SVMXC__Actual_Quantity2__c_ = @"";    
            if ((_SVMXC__Actual_Quantity2__c != nil) && strlen(_SVMXC__Actual_Quantity2__c))
            {         
                SVMXC__Actual_Quantity2__c_ = [[NSString alloc] initWithUTF8String:_SVMXC__Actual_Quantity2__c];
            }
            char *_SVMXC__Actual_Price2__c = (char *) sqlite3_column_text(statement1,3);
            NSString * SVMXC__Actual_Price2__c_ = @"";    
            if ((_SVMXC__Actual_Price2__c != nil) && strlen(_SVMXC__Actual_Price2__c))
            {         
                SVMXC__Actual_Price2__c_ = [[NSString alloc] initWithUTF8String:_SVMXC__Actual_Price2__c];
            }   
            char *_SVMXC__Work_Description_c = (char *) sqlite3_column_text(statement1,4);
            NSString * SVMXC__Work_Description_c = @"";    
            if ((_SVMXC__Work_Description_c != nil) && strlen(_SVMXC__Work_Description_c))
            {         
                SVMXC__Work_Description_c = [[NSString alloc] initWithUTF8String:_SVMXC__Work_Description_c];
            }   
            NSMutableArray * objects = [[NSMutableArray arrayWithObjects:Id,SVMXC__Activity_Type__c_,SVMXC__Actual_Quantity2__c_,SVMXC__Actual_Price2__c_,SVMXC__Work_Description_c,nil] retain];
            
            NSDictionary * dictionary = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
                    
            [LabourValuesDictionary setValue:@"0" forKey:CALIBRATION];
            [LabourValuesDictionary setValue:@"0" forKey:CLEANUP];
            [LabourValuesDictionary setValue:@"0" forKey:INSTALLATION];
            [LabourValuesDictionary setValue:@"0" forKey:REPAIR];
            [LabourValuesDictionary setValue:@"0" forKey:SERVICE];
        
            if ([[dictionary objectForKey:@"SVMXC__Activity_Type__c"] isEqualToString:CALIBRATION])
            {
                [LabourValuesDictionary setValue:[dictionary objectForKey:@"SVMXC__Actual_Price2__c"] forKey:RATE_CALIBRATION];
                [LabourValuesDictionary setValue:[dictionary objectForKey:@"SVMXC__Actual_Quantity2__c"] forKey:QTY_CALIBRATION];
            }
            if ([[dictionary objectForKey:@"SVMXC__Activity_Type__c"] isEqualToString:CLEANUP])
            {
                [LabourValuesDictionary setValue:[dictionary objectForKey:@"SVMXC__Actual_Price2__c"] forKey:RATE_CLEANUP];
                [LabourValuesDictionary setValue:[dictionary objectForKey:@"SVMXC__Actual_Quantity2__c"] forKey:QTY_CLEANUP];
            }
            if ([[dictionary objectForKey:@"SVMXC__Activity_Type__c"] isEqualToString:INSTALLATION])
            {
                [LabourValuesDictionary setValue:[dictionary objectForKey:@"SVMXC__Actual_Price2__c"] forKey:RATE_INSTALLATION];
                [LabourValuesDictionary setValue:[dictionary  objectForKey:@"SVMXC__Actual_Quantity2__c"] forKey:QTY_INSTALLATION];
            }
            if ([[dictionary objectForKey:@"SVMXC__Activity_Type__c"] isEqualToString:REPAIR])
            {
                [LabourValuesDictionary setValue:[dictionary objectForKey:@"SVMXC__Actual_Price2__c"] forKey:RATE_REPAIR];
                [LabourValuesDictionary setValue:[dictionary objectForKey:@"SVMXC__Actual_Quantity2__c"] forKey:QTY_REPAIR];
            }
            if ([[dictionary objectForKey:@"SVMXC__Activity_Type__c"] isEqualToString:SERVICE])
            {
                [LabourValuesDictionary setValue:[dictionary objectForKey:@"SVMXC__Actual_Price2__c"] forKey:RATE_SERVICE];
                [LabourValuesDictionary setValue:[dictionary objectForKey:@"SVMXC__Actual_Quantity2__c"] forKey:QTY_SERVICE];
            }
        }
        
        NSLog(@"%@ %@", LabourValuesDictionary, linePriceItems);
        //NSString * query = [NSString stringWithFormat:@"SELECT SVMXC__Billable_Cost2__c FROM SVMXC__Service_Group_Costs__c	WHERE SVMXC__Group_Member__c = '%@' AND SVMXC__Cost_Category__c = 'Straight' LIMIT 1", appDelegate.appTechnicianId];
        //NSLog(@"%@",query);
        //[[ZKServerSwitchboard switchboard] query:query target:self selector:@selector(getPriceForLabor:error:context:) context:nil];
    
   }
  
    return LabourValuesDictionary;
}

- (void) startQueryConfiguration
{
    //iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.reference_field_names = [[NSMutableDictionary alloc]initWithCapacity:0];
    
    sqlite3_stmt *statement;
    NSMutableString *queryStatement = [[NSMutableString alloc]initWithCapacity:0];
    queryStatement = [NSMutableString stringWithFormat:@"Select Id, SVMXC__Name__c, SVMXC__Description__c, SVMXC__ModuleID__c, SVMXC__IsStandard__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__ModuleID__c = 'IPAD' AND  RecordTypeId = (Select Id FROM RecordType WHERE Name = 'MODULE') "];
    NSLog(@"%@", queryStatement);
    NSMutableArray *ConfigurationArray = [[NSMutableArray alloc]initWithCapacity:0];
    
    const char * _query = [queryStatement UTF8String];
    NSArray * keys = [NSArray arrayWithObjects:
                      _ID,
                      SVMXC__NAME__C,
                      SVMXC__DESCRIPTION__C,
                      SVMXC__MODULEID__C,
                      SVMXC__ISSTANDARD__C,
                      nil];
    int ret = sqlite3_prepare_v2(db, _query,-1, &statement, nil);
    NSLog(@"%d", ret);
    
    
    if ( sqlite3_prepare_v2(db, _query,-1, &statement, nil) == SQLITE_OK )
    {
        while(sqlite3_step(statement) == SQLITE_ROW)
        {
            char *_Id = (char *) sqlite3_column_text(statement,0);
            NSString * Id = @"";    
            if ((_Id != nil) && strlen(_Id))
            {         
                Id = [[NSString alloc] initWithUTF8String:_Id];
                
            }
            char *_SVMXC__Name__c = (char *) sqlite3_column_text(statement,1);
            NSString * SVMXC__Name__c = @"";
            if ((_SVMXC__Name__c != nil) && strlen(_SVMXC__Name__c))
            {         
                SVMXC__Name__c = [[NSString alloc] initWithUTF8String:_SVMXC__Name__c];
            }  
            char *_SVMXC__Description__c = (char *) sqlite3_column_text(statement,2);
            NSString * SVMXC__Description__c = @"";    
            if ((_SVMXC__Description__c != nil) && strlen(_SVMXC__Description__c))
            {         
                SVMXC__Description__c = [[NSString alloc] initWithUTF8String:_SVMXC__Description__c];
            }
            char *_SVMXC__ModuleID__c = (char *) sqlite3_column_text(statement,3);
            NSString * SVMXC__ModuleID__c = @"";    
            if ((_SVMXC__ModuleID__c != nil) && strlen(_SVMXC__ModuleID__c))
            {         
                SVMXC__ModuleID__c = [[NSString alloc] initWithUTF8String:_SVMXC__ModuleID__c ];
            }   
            char *_SVMXC__IsStandard__c = (char *) sqlite3_column_text(statement,4);
            NSString * SVMXC__IsStandard__c = @"";    
            if ((_SVMXC__IsStandard__c != nil) && strlen(_SVMXC__IsStandard__c))
            {         
                SVMXC__IsStandard__c = [[NSString alloc] initWithUTF8String:_SVMXC__IsStandard__c];
            }   
            NSMutableArray * objects = [[NSMutableArray arrayWithObjects:Id,SVMXC__Name__c,SVMXC__Description__c,SVMXC__ModuleID__c,SVMXC__IsStandard__c,nil] retain];
            
            NSDictionary * dictionary = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
            [ConfigurationArray addObject:dictionary];
            [dictionary release];
            [objects release];
        }
    }
    
    NSLog(@"%@",ConfigurationArray);
    NSMutableArray *ModuleInfoArray = [[NSMutableArray alloc]initWithCapacity:0];
    
    if ([ConfigurationArray count] > 0)
    {   
        NSMutableDictionary * obj = [[NSMutableDictionary alloc]initWithCapacity:0];
        obj = [ConfigurationArray objectAtIndex:0];
        NSString * moduleInfo = [obj objectForKey:@"Id"];
        sqlite3_stmt *statement1;
        NSMutableString *queryStatement1 = [[NSMutableString alloc]initWithCapacity:0];
        queryStatement1 = [NSMutableString stringWithFormat:@"Select Id, SVMXC__ModuleID__c, SVMXC__SubmoduleID__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__IsStandard__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Module__c = '%@' AND  RecordTypeId = (Select Id FROM RecordType WHERE Name = 'SUBMODULE')",moduleInfo]; 
        NSLog(@"%@", queryStatement1);
        
        const char * _query1 = [queryStatement1 UTF8String];
        NSArray * keys1 = [NSArray arrayWithObjects:
                           _ID,
                           SVMXC__MODULEID__C,
                           SVMXC__SUBMODULEID__C,
                           SVMXC__NAME__C,
                           SVMXC__DESCRIPTION__C,
                           SVMXC__ISSTANDARD__C,
                           nil];
        if ( sqlite3_prepare_v2(db, _query1,-1, &statement1, nil) == SQLITE_OK )
        {
            while(sqlite3_step(statement1) == SQLITE_ROW)
            {
                char *_Id = (char *) sqlite3_column_text(statement1,0);
                NSString * Id = @"";    
                if ((_Id != nil) && strlen(_Id))
                {         
                    Id = [[NSString alloc] initWithUTF8String:_Id];
                    
                }
                char *_SVMXC__ModuleID__c = (char *) sqlite3_column_text(statement1,1);
                NSString * SVMXC__ModuleID__c = @"";
                if ((_SVMXC__ModuleID__c != nil) && strlen(_SVMXC__ModuleID__c))
                {         
                    SVMXC__ModuleID__c = [[NSString alloc] initWithUTF8String:_SVMXC__ModuleID__c];
                }  
                char *_SVMXC__SubmoduleID__c = (char *) sqlite3_column_text(statement1,2);
                NSString * SVMXC__SubmoduleID__c = @"";    
                if ((_SVMXC__SubmoduleID__c != nil) && strlen(_SVMXC__SubmoduleID__c))
                {         
                    SVMXC__SubmoduleID__c = [[NSString alloc] initWithUTF8String:_SVMXC__SubmoduleID__c];
                }
                char *_SVMXC__Name__c = (char *) sqlite3_column_text(statement1,3);
                NSString * SVMXC__Name__c = @"";    
                if ((_SVMXC__Name__c!= nil) && strlen(_SVMXC__Name__c))
                {         
                    SVMXC__Name__c = [[NSString alloc] initWithUTF8String:_SVMXC__Name__c];
                }   
                char *_SVMXC__Description__c = (char *) sqlite3_column_text(statement1,4);
                NSString * SVMXC__Description__c = @"";    
                if ((_SVMXC__Description__c != nil) && strlen(_SVMXC__Description__c))
                {         
                    SVMXC__Description__c = [[NSString alloc] initWithUTF8String:_SVMXC__Description__c];
                } 
                char *_SVMXC__IsStandard__c = (char *) sqlite3_column_text(statement1,5);
                NSString * SVMXC__IsStandard__c = @"";    
                if ((_SVMXC__IsStandard__c != nil) && strlen(_SVMXC__IsStandard__c))
                {         
                    SVMXC__IsStandard__c = [[NSString alloc] initWithUTF8String:_SVMXC__IsStandard__c];
                }   
                
                NSMutableArray * objects1 = [[NSMutableArray arrayWithObjects:Id,SVMXC__ModuleID__c,SVMXC__SubmoduleID__c,SVMXC__Name__c,SVMXC__Description__c,SVMXC__IsStandard__c,nil] retain];
                
                NSDictionary * dictionary1 = [[NSDictionary alloc] initWithObjects:objects1 forKeys:keys1];
                [ModuleInfoArray addObject:dictionary1];
                [dictionary1 release];
                [objects1 release];
            }
        }
    }
    
    NSLog(@"%@",ModuleInfoArray);
    NSMutableArray *SubModuleInfoArray = [[NSMutableArray alloc]initWithCapacity:0];
    
    if([ModuleInfoArray count] > 0)
    {   
        
        NSMutableString * idArray = [[NSMutableString alloc] initWithCapacity:0];
        for (int i = 0; i < [ModuleInfoArray count]; i++)
        {
            NSMutableDictionary * obj5 = [ModuleInfoArray objectAtIndex:i];
            if ([idArray length] == 0)
                [idArray appendFormat:@"('%@'", [obj5 objectForKey:@"SVMXC__SubmoduleID__c"]];
            else
            {
                [idArray appendFormat:@", '%@'", [obj5 objectForKey:@"SVMXC__SubmoduleID__c"]];
            }
        }
        [idArray appendString:@")"];
        
        sqlite3_stmt *statement2;
        NSMutableString *queryStatement2 = [[NSMutableString alloc]initWithCapacity:0];
        
        queryStatement2 = [NSMutableString stringWithFormat:@"SELECT Id, SVMXC__SubmoduleID__c, SVMXC__SettingID__c, SVMXC__Setting_Unique_ID__c, SVMXC__Settings_Name__c, SVMXC__Data_Type__c, SVMXC__Values__c, SVMXC__Default_Value__c, SVMXC__Setting_Type__c, SVMXC__Search_Order__c, SVMXC__IsPrivate__c, SVMXC__Active__c, SVMXC__Description__c, SVMXC__IsStandard__c, SVMXC__Submodule__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__SubmoduleID__c IN %@ AND RecordTypeId = (Select Id FROM RecordType WHERE Name = 'SETTINGS') ORDER BY SVMXC__Setting_Unique_ID__c",idArray];
        NSLog(@"%@", queryStatement2);
        
        const char * _query2 = [queryStatement2 UTF8String];
        NSArray * keys2 = [NSArray arrayWithObjects:
                           _ID,
                           SVMXC__SUBMODULEID__C,
                           SVMXC__SETTINGID__C,
                           SVMXC__SETTING_UNIQUE_ID__C,
                           SVMXC__SETTINGS_NAME__C,
                           SVMXC__DATA_TYPE__C,
                           SVMXC__VALUES__C,
                           SVMXC__DEFAULT_VALUE__C,
                           SVMXC__SETTING_TYPE__C,
                           SVMXC__SEARCH_ORDER__C,
                           SVMXC__ISPRIVATE__C,
                           SVMXC__ACTIVE__C,
                           SVMXC__DESCRIPTION__C,
                           SVMXC__ISSTANDARD__C,
                           SVMXC__SUBMODULE__C,
                           nil];
        if ( sqlite3_prepare_v2(db, _query2,-1, &statement2, nil) == SQLITE_OK )
        {
            while(sqlite3_step(statement2) == SQLITE_ROW)
            {
                char *_Id = (char *) sqlite3_column_text(statement2,0);
                NSString * Id = @"";    
                if ((_Id != nil) && strlen(_Id))
                {         
                    Id = [[NSString alloc] initWithUTF8String:_Id];
                    
                }
                char *_SVMXC__SubmoduleID__c = (char *) sqlite3_column_text(statement2,1);
                NSString * SVMXC__SubmoduleID__c = @"";
                if ((_SVMXC__SubmoduleID__c != nil) && strlen(_SVMXC__SubmoduleID__c))
                {         
                    SVMXC__SubmoduleID__c = [[NSString alloc] initWithUTF8String:_SVMXC__SubmoduleID__c];
                }  
                char *_SVMXC__SettingID__c = (char *) sqlite3_column_text(statement2,2);
                NSString * SVMXC__SettingID__c = @"";    
                if ((_SVMXC__SettingID__c != nil) && strlen(_SVMXC__SettingID__c))
                {         
                    SVMXC__SettingID__c = [[NSString alloc] initWithUTF8String:_SVMXC__SettingID__c];
                }
                char *_SVMXC__Setting_Unique_ID = (char *) sqlite3_column_text(statement2,3);
                NSString * SVMXC__Setting_Unique_ID = @"";    
                if ((_SVMXC__Setting_Unique_ID != nil) && strlen(_SVMXC__Setting_Unique_ID))
                {         
                    SVMXC__Setting_Unique_ID = [[NSString alloc] initWithUTF8String:_SVMXC__Setting_Unique_ID];
                }   
                char *_SVMXC__Settings_Name__c = (char *) sqlite3_column_text(statement2,4);
                NSString * SVMXC__Settings_Name__c = @"";    
                if ((_SVMXC__Settings_Name__c != nil) && strlen(_SVMXC__Settings_Name__c))
                {         
                    SVMXC__Settings_Name__c = [[NSString alloc] initWithUTF8String:_SVMXC__Settings_Name__c];
                }
                char *_SVMXC__Data_Type__c = (char *) sqlite3_column_text(statement2,5);
                NSString * SVMXC__Data_Type__c = @"";
                if ((_SVMXC__Data_Type__c != nil) && strlen(_SVMXC__Data_Type__c))
                {         
                    SVMXC__Data_Type__c = [[NSString alloc] initWithUTF8String:_SVMXC__Data_Type__c];
                }  
                char *_SVMXC__Values__c = (char *) sqlite3_column_text(statement2,6);
                NSString * SVMXC__Values__c = @"";
                if ((_SVMXC__Values__c != nil) && strlen(_SVMXC__Values__c))
                {         
                    SVMXC__Values__c = [[NSString alloc] initWithUTF8String:_SVMXC__Values__c];
                }  
                char *_SVMXC__Default_Value__c = (char *) sqlite3_column_text(statement2,7);
                NSString * SVMXC__Default_Value__c = @"";
                if ((_SVMXC__Default_Value__c != nil) && strlen(_SVMXC__Default_Value__c))
                {         
                    SVMXC__Default_Value__c = [[NSString alloc] initWithUTF8String:_SVMXC__Default_Value__c];
                }  
                char *_SVMXC__Setting_Type__c = (char *) sqlite3_column_text(statement2,8);
                NSString * SVMXC__Setting_Type__c = @"";
                if ((_SVMXC__Setting_Type__c != nil) && strlen(_SVMXC__Setting_Type__c))
                {         
                    SVMXC__Setting_Type__c = [[NSString alloc] initWithUTF8String:_SVMXC__Setting_Type__c];
                }  
                char *_SVMXC__Search_Order__c = (char *) sqlite3_column_text(statement2,9);
                NSString * SVMXC__Search_Order__c = @"";
                if ((_SVMXC__Search_Order__c != nil) && strlen(_SVMXC__Search_Order__c))
                {         
                    SVMXC__Search_Order__c = [[NSString alloc] initWithUTF8String:_SVMXC__Search_Order__c];
                }  
                char *_SVMXC__IsPrivate__c = (char *) sqlite3_column_text(statement2,10);
                NSString * SVMXC__IsPrivate__c = @"";
                if ((_SVMXC__IsPrivate__c != nil) && strlen(_SVMXC__IsPrivate__c))
                {         
                    SVMXC__IsPrivate__c = [[NSString alloc] initWithUTF8String:_SVMXC__IsPrivate__c];
                }  
                char *_SVMXC__Active__c = (char *) sqlite3_column_text(statement2,11);
                NSString * SVMXC__Active__c = @"";
                if ((_SVMXC__Active__c != nil) && strlen(_SVMXC__Active__c))
                {         
                    SVMXC__Active__c = [[NSString alloc] initWithUTF8String:_SVMXC__Active__c];
                }  
                char *_SVMXC__Description__c = (char *) sqlite3_column_text(statement2,12);
                NSString * SVMXC__Description__c = @"";
                if ((_SVMXC__Description__c != nil) && strlen(_SVMXC__Description__c))
                {         
                    SVMXC__Description__c = [[NSString alloc] initWithUTF8String:_SVMXC__Description__c];
                }  
                char *_SVMXC__IsStandard__c = (char *) sqlite3_column_text(statement2,13);
                NSString * SVMXC__IsStandard__c = @"";
                if ((_SVMXC__IsStandard__c != nil) && strlen(_SVMXC__IsStandard__c))
                {         
                    SVMXC__IsStandard__c = [[NSString alloc] initWithUTF8String:_SVMXC__IsStandard__c];
                }  
                char *_SVMXC__Submodule__c = (char *) sqlite3_column_text(statement2,14);
                NSString * SVMXC__Submodule__c = @"";
                if ((_SVMXC__Submodule__c != nil) && strlen(_SVMXC__Submodule__c))
                {         
                    SVMXC__Submodule__c = [[NSString alloc] initWithUTF8String:_SVMXC__Submodule__c];
                }  
                
                NSMutableArray * objects2 = [[NSMutableArray arrayWithObjects:Id,SVMXC__SubmoduleID__c,SVMXC__SettingID__c,SVMXC__Setting_Unique_ID,SVMXC__Settings_Name__c,SVMXC__Data_Type__c,SVMXC__Values__c,SVMXC__Default_Value__c,SVMXC__Setting_Type__c,SVMXC__Search_Order__c,SVMXC__IsPrivate__c,SVMXC__Active__c,SVMXC__Description__c,SVMXC__IsStandard__c,SVMXC__Submodule__c,nil] retain];
                
                NSDictionary * dictionary2 = [[NSDictionary alloc] initWithObjects:objects2 forKeys:keys2];
                [SubModuleInfoArray addObject:dictionary2];
                [dictionary2 release];
                [objects2 release];
            }
        }
    }            
    
    NSLog(@"%@",SubModuleInfoArray);
    NSMutableArray * ActiveGlobalProfileArray = [[NSMutableArray alloc]initWithCapacity:0];
    
    if ([SubModuleInfoArray count] > 0)
    {
        settingInfoId = [[NSMutableString alloc] initWithCapacity:0];
        settingsInfoArray = [[NSMutableArray alloc] initWithCapacity:0];
        for (int i = 0; i < [SubModuleInfoArray count]; i++)
        {
            NSMutableDictionary * obj1 = [SubModuleInfoArray objectAtIndex:i];
            
            [settingsInfoArray addObject:obj1];
            
            if ([settingInfoId length] == 0)
                [settingInfoId appendFormat:@"('%@'", [obj1 objectForKey:@"Id"]];
            else
                [settingInfoId appendFormat:@", '%@'", [obj1 objectForKey:@"Id"]];
        }
        
        [settingInfoId appendString:@")"];
        sqlite3_stmt *statement3;
        NSMutableString *queryStatement3 = [[NSMutableString alloc]initWithCapacity:0];
        queryStatement3 = [NSMutableString stringWithFormat:@"Select Id, SVMXC__Profile_Name__c, SVMXC__Active__c, SVMXC__IsDefault__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__RecordType_Name__c='Configuration Profile' and SVMXC__Configuration_Type__c = 'Global' and SVMXC__Active__c = 'true'"];        
        NSLog(@"%@", queryStatement3);
        
        const char * _query3 = [queryStatement3 UTF8String];
        NSArray * keys3 = [NSArray arrayWithObjects:
                           _ID,
                           SVMXC__PROFILE_NAME__C,
                           SVMXC__ACTIVE__C,
                           SVMXC__ISDEFAULT__C,
                           nil];
        if ( sqlite3_prepare_v2(db, _query3,-1, &statement3, nil) == SQLITE_OK )
        {
            while(sqlite3_step(statement3) == SQLITE_ROW)
            {
                char *_Id = (char *) sqlite3_column_text(statement3,0);
                NSString * Id = @"";    
                if ((_Id != nil) && strlen(_Id))
                {         
                    Id = [[NSString alloc] initWithUTF8String:_Id];
                    
                }
                char *_SVMXC__Profile_Name__c = (char *) sqlite3_column_text(statement3,1);
                NSString * SVMXC__Profile_Name__c = @"";
                if ((_SVMXC__Profile_Name__c != nil) && strlen(_SVMXC__Profile_Name__c))
                {         
                    SVMXC__Profile_Name__c = [[NSString alloc] initWithUTF8String:_SVMXC__Profile_Name__c];
                }  
                char *_SVMXC__Active__c = (char *) sqlite3_column_text(statement3,2);
                NSString * SVMXC__Active__c = @"";    
                if ((_SVMXC__Active__c != nil) && strlen(_SVMXC__Active__c))
                {         
                    SVMXC__Active__c = [[NSString alloc] initWithUTF8String:_SVMXC__Active__c];
                }
                char *_SVMXC__IsDefault__c = (char *) sqlite3_column_text(statement3,3);
                NSString * SVMXC__IsDefault__c = @"";    
                if ((_SVMXC__IsDefault__c!= nil) && strlen(_SVMXC__IsDefault__c))
                {         
                    SVMXC__IsDefault__c = [[NSString alloc] initWithUTF8String:_SVMXC__IsDefault__c];
                }   
                NSMutableArray * objects3 = [[NSMutableArray arrayWithObjects:Id,SVMXC__Profile_Name__c,SVMXC__Active__c,SVMXC__IsDefault__c,nil] retain];
                
                NSDictionary * dictionary3 = [[NSDictionary alloc] initWithObjects:objects3 forKeys:keys3];
                [ActiveGlobalProfileArray addObject:dictionary3];
                [dictionary3 release];
                [objects3 release];
            }
        }
    }
    
    NSLog(@"%@",ActiveGlobalProfileArray);
    NSMutableArray * GetSettingsValueArray = [[NSMutableArray alloc]initWithCapacity:0];
    if ([ActiveGlobalProfileArray count] > 0)
    {
        NSMutableDictionary * obj2 = [ActiveGlobalProfileArray objectAtIndex:0];
        ActiveGloProInfoId = [[obj2 objectForKey:@"Id"] retain];
        if ([settingInfoId length] != 0)
        {
            sqlite3_stmt *statement4;
            NSMutableString *queryStatement4 = [[NSMutableString alloc]initWithCapacity:0];
            
            queryStatement4 = [NSMutableString stringWithFormat:@"Select Id, SVMXC__Setting_Configuration_Profile__c, SVMXC__Setting_ID__c, SVMXC__Internal_Value__c, SVMXC__Display_Value__c, SVMXC__Active__c, SVMXC__IsDefault__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__Setting_Configuration_Profile__c = '%@' AND SVMXC__Setting_ID__c IN %@ AND RecordTypeId = (Select Id FROM RecordType WHERE Name = 'SETTINGS VALUE') ORDER BY SVMXC__Setting_Unique_ID__c", ActiveGloProInfoId, settingInfoId];           
            NSLog(@"%@", queryStatement4);
            
            const char * _query4 = [queryStatement4 UTF8String];
            NSArray * keys4 = [NSArray arrayWithObjects:
                               _ID,
                               SVMXC__SETTING_CONFIGURATION_PROFILE__C,
                               SVMXC__SETTING_ID__C,
                               SVMXC__INTERNAL_VALUE__C,
                               SVMXC__DISPLAY_VALUE__C,
                               SVMXC__ACTIVE__C,
                               SVMXC__ISDEFAULT__C,
                               nil];
            if ( sqlite3_prepare_v2(db, _query4,-1, &statement4, nil) == SQLITE_OK )
            {
                while(sqlite3_step(statement4) == SQLITE_ROW)
                {
                    char *_Id = (char *) sqlite3_column_text(statement4,0);
                    NSString * Id = @"";    
                    if ((_Id != nil) && strlen(_Id))
                    {         
                        Id = [[NSString alloc] initWithUTF8String:_Id];
                        
                    }
                    char *_SVMXC__Setting_Configuration_Profile__c = (char *) sqlite3_column_text(statement4,1);
                    NSString * SVMXC__Setting_Configuration_Profile__c = @"";
                    if ((_SVMXC__Setting_Configuration_Profile__c != nil) && strlen(_SVMXC__Setting_Configuration_Profile__c))
                    {         
                        SVMXC__Setting_Configuration_Profile__c = [[NSString alloc] initWithUTF8String:_SVMXC__Setting_Configuration_Profile__c];
                    }  
                    char *_SVMXC__Setting_ID__c = (char *) sqlite3_column_text(statement4,2);
                    NSString * SVMXC__Setting_ID__c = @"";    
                    if ((_SVMXC__Setting_ID__c != nil) && strlen(_SVMXC__Setting_ID__c))
                    {         
                        SVMXC__Setting_ID__c = [[NSString alloc] initWithUTF8String:_SVMXC__Setting_ID__c];
                    }
                    char *_SVMXC__Internal_Value__c = (char *) sqlite3_column_text(statement4,3);
                    NSString * SVMXC__Internal_Value__c = @"";    
                    if ((_SVMXC__Internal_Value__c!= nil) && strlen(_SVMXC__Internal_Value__c))
                    {         
                        SVMXC__Internal_Value__c = [[NSString alloc] initWithUTF8String:_SVMXC__Internal_Value__c];
                    }   
                    char *_SVMXC__Display_Value__c = (char *) sqlite3_column_text(statement4,4);
                    NSString * SVMXC__Display_Value__c = @"";    
                    if ((_SVMXC__Display_Value__c != nil) && strlen(_SVMXC__Display_Value__c))
                    {         
                        SVMXC__Display_Value__c = [[NSString alloc] initWithUTF8String:_SVMXC__Display_Value__c];
                    }
                    char *_SVMXC__Active__c = (char *) sqlite3_column_text(statement4,5);
                    NSString * SVMXC__Active__c = @"";    
                    if ((_SVMXC__Active__c != nil) && strlen(_SVMXC__Active__c))
                    {         
                        SVMXC__Active__c = [[NSString alloc] initWithUTF8String:_SVMXC__Active__c];
                    }
                    char *_SVMXC__IsDefault__c = (char *) sqlite3_column_text(statement4,6);
                    NSString * SVMXC__IsDefault__c = @"";    
                    if ((_SVMXC__IsDefault__c != nil) && strlen(_SVMXC__IsDefault__c))
                    {         
                        SVMXC__IsDefault__c = [[NSString alloc] initWithUTF8String:_SVMXC__IsDefault__c];
                    }
                    NSMutableArray * objects4 = [[NSMutableArray arrayWithObjects:Id,SVMXC__Setting_Configuration_Profile__c,SVMXC__Setting_ID__c,SVMXC__Internal_Value__c,SVMXC__Display_Value__c,SVMXC__Active__c,SVMXC__IsDefault__c,nil] retain];
                    
                    NSDictionary * dictionary4 = [[NSDictionary alloc] initWithObjects:objects4 forKeys:keys4];
                    [GetSettingsValueArray addObject:dictionary4];
                    [dictionary4 release];
                    [objects4 release];
                }
            }
            NSLog(@"%@",GetSettingsValueArray);
        }
        else
        {
            sqlite3_stmt *statement5;
            NSMutableString *queryStatement5 = [[NSMutableString alloc]initWithCapacity:0];
            
            queryStatement5 = [NSMutableString stringWithFormat:@"SELECT Id, SVMXC__Setting_Configuration_Profile__c, SVMXC__Setting_ID__c, SVMXC__Internal_Value__c, SVMXC__Display_Value__c, SVMXC__Active__c, SVMXC__IsDefault__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__Setting_Configuration_Profile__c = '%@' AND RecordTypeId = (Select Id FROM RecordType WHERE Name = 'SETTINGS VALUE') ORDER BY SVMXC__Setting_Unique_ID__c", ActiveGloProInfoId];            
            NSLog(@"%@", queryStatement5);
            
            const char * _query5 = [queryStatement5 UTF8String];
            NSArray * keys5 = [NSArray arrayWithObjects:
                               _ID,
                               SVMXC__SETTING_CONFIGURATION_PROFILE__C,
                               SVMXC__SETTING_ID__C,
                               SVMXC__INTERNAL_VALUE__C,
                               SVMXC__DISPLAY_VALUE__C,
                               SVMXC__ACTIVE__C,
                               SVMXC__ISDEFAULT__C,
                               nil];
            if ( sqlite3_prepare_v2(db, _query5,-1, &statement5, nil) == SQLITE_OK )
            {
                while(sqlite3_step(statement5) == SQLITE_ROW)
                {
                    char *_Id = (char *) sqlite3_column_text(statement5,0);
                    NSString * Id = @"";    
                    if ((_Id != nil) && strlen(_Id))
                    {         
                        Id = [[NSString alloc] initWithUTF8String:_Id];
                        
                    }
                    char *_SVMXC__Setting_Configuration_Profile__c = (char *) sqlite3_column_text(statement5,1);
                    NSString * SVMXC__Setting_Configuration_Profile__c = @"";
                    if ((_SVMXC__Setting_Configuration_Profile__c != nil) && strlen(_SVMXC__Setting_Configuration_Profile__c))
                    {         
                        SVMXC__Setting_Configuration_Profile__c = [[NSString alloc] initWithUTF8String:_SVMXC__Setting_Configuration_Profile__c];
                    }  
                    char *_SVMXC__Setting_ID__c = (char *) sqlite3_column_text(statement5,2);
                    NSString * SVMXC__Setting_ID__c = @"";    
                    if ((_SVMXC__Setting_ID__c != nil) && strlen(_SVMXC__Setting_ID__c))
                    {         
                        SVMXC__Setting_ID__c = [[NSString alloc] initWithUTF8String:_SVMXC__Setting_ID__c];
                    }
                    char *_SVMXC__Internal_Value__c = (char *) sqlite3_column_text(statement5,3);
                    NSString * SVMXC__Internal_Value__c = @"";    
                    if ((_SVMXC__Internal_Value__c!= nil) && strlen(_SVMXC__Internal_Value__c))
                    {         
                        SVMXC__Internal_Value__c = [[NSString alloc] initWithUTF8String:_SVMXC__Internal_Value__c];
                    }   
                    char *_SVMXC__Display_Value__c = (char *) sqlite3_column_text(statement5,4);
                    NSString * SVMXC__Display_Value__c = @"";    
                    if ((_SVMXC__Display_Value__c != nil) && strlen(_SVMXC__Display_Value__c))
                    {         
                        SVMXC__Display_Value__c = [[NSString alloc] initWithUTF8String:_SVMXC__Display_Value__c];
                    }
                    char *_SVMXC__Active__c = (char *) sqlite3_column_text(statement5,5);
                    NSString * SVMXC__Active__c = @"";    
                    if ((_SVMXC__Active__c != nil) && strlen(_SVMXC__Active__c))
                    {         
                        SVMXC__Active__c = [[NSString alloc] initWithUTF8String:_SVMXC__Active__c];
                    }
                    char *_SVMXC__IsDefault__c = (char *) sqlite3_column_text(statement5,6);
                    NSString * SVMXC__IsDefault__c = @"";    
                    if ((_SVMXC__IsDefault__c != nil) && strlen(_SVMXC__IsDefault__c))
                    {         
                        SVMXC__IsDefault__c = [[NSString alloc] initWithUTF8String:_SVMXC__IsDefault__c];
                    }
                    NSMutableArray * objects5 = [[NSMutableArray arrayWithObjects:Id,SVMXC__Setting_Configuration_Profile__c,SVMXC__Setting_ID__c,SVMXC__Internal_Value__c,SVMXC__Display_Value__c,SVMXC__Active__c,SVMXC__IsDefault__c,nil] retain];
                    
                    NSDictionary * dictionary5 = [[NSDictionary alloc] initWithObjects:objects5 forKeys:keys5];
                    [GetSettingsValueArray addObject:dictionary5];
                    [dictionary5 release];
                    [objects5 release];
                }
            }
        }
        NSLog(@"%@",GetSettingsValueArray); 
    }
    if ([GetSettingsValueArray count] > 0)
    {
        appDelegate.workOrderData = [[NSMutableArray alloc] initWithCapacity:0];
        appDelegate.workOrderUpdateData = [[NSMutableArray alloc] initWithCapacity:0];
        appDelegate.timeAndMaterial = [[NSMutableArray alloc] initWithCapacity:0];
        appDelegate.serviceReport = [[NSMutableDictionary alloc] initWithCapacity:0];
        appDelegate.addressType = [[NSMutableString alloc] initWithCapacity:0];
        
        settingsValueArray = [[NSMutableArray alloc] initWithCapacity:0];
        for (int i = 0; i < [GetSettingsValueArray count]; i++)
        {
            NSMutableDictionary * obj6 = [GetSettingsValueArray objectAtIndex:i];
            [settingsValueArray addObject:obj6];
            
            // settingsValueArray
            if (appDelegate.serviceReportValueMapping == nil)
                appDelegate.serviceReportValueMapping = [[NSMutableArray alloc] initWithCapacity:0];
            else
            {
                NSDictionary * dict = [NSDictionary dictionaryWithObject:[obj6 objectForKey:@"SVMXC__Internal_Value__c"] forKey:[obj6 objectForKey:@"SVMXC__Display_Value__c"]];
                [appDelegate.serviceReportValueMapping addObject:dict];
            }
        }
        
        NSLog(@"ValuesArray   %d",[settingsValueArray count]);
        NSLog(@"%d",[settingsInfoArray count]);
        
        NSMutableArray  * query_fields_array = [[NSMutableArray alloc] initWithCapacity:0];
        
        NSMutableDictionary * fromClause = nil;
        NSMutableDictionary * selectClause = nil;
        NSMutableArray * whereClause = nil;
        
        for (int i = 0; i < [settingsInfoArray count]; i++)
        {
            for (int j = 0; j < [settingsValueArray count]; j++)
            {
                if (selectClause == nil)
                    selectClause = [[NSMutableDictionary alloc] initWithCapacity:0];
                if (fromClause == nil)
                    fromClause = [[NSMutableDictionary alloc] initWithCapacity:0];
                if (whereClause == nil)
                    whereClause = [[NSMutableArray alloc] initWithCapacity:0];
                
                NSString * settingsInfoSettingId = [[settingsInfoArray objectAtIndex:i] objectForKey:@"Id"];
                NSString * settingsValueSettingId = [[settingsValueArray objectAtIndex:j] objectForKey:@"SVMXC__Setting_ID__c"];
                if ([settingsValueSettingId isEqualToString:settingsInfoSettingId])
                {
                    if (appDelegate.soqlQuery == nil)
                        appDelegate.soqlQuery = [[NSMutableString alloc] initWithCapacity:0];
                    
                    if ([[[settingsInfoArray objectAtIndex:i] objectForKey:@"SVMXC__Setting_Unique_ID__c"] Contains:@"IPAD004"])
                    {
                        NSString * subModuleSettingKey = [[settingsInfoArray objectAtIndex:i] objectForKey:@"SVMXC__Setting_Unique_ID__c"];
                        
                        NSString * keyNumVal = [subModuleSettingKey stringByReplacingOccurrencesOfString:@"IPAD004_SET" withString:@""];
                        
                        NSInteger intNumVal = [keyNumVal intValue];
                        NSLog(@"%@",keyNumVal);
                        
                        if (intNumVal >= 11 && intNumVal <= 20)
                        {
                            NSString * queryField = [[settingsValueArray objectAtIndex:j] objectForKey:@"SVMXC__Internal_Value__c"];
                            NSLog(@"QUERY FIELD %@", queryField);
                            if ([queryField isKindOfClass:[NSNull class]])
                                continue;
                            NSArray * arr = [queryField componentsSeparatedByString:@"."];
                            
                            if ([arr count] == 2)
                            {
                                // Field is a reference field

                                // SELECT CLAUSE
                                NSString * referenceFieldName = [arr objectAtIndex:1];
                                // Describe the object specified in the "DisplayValue" in order to retrieve the reference field's table name
                                NSString * displayValue = [[settingsValueArray objectAtIndex:j] objectForKey:@"SVMXC__Display_Value__c"];
                                
                                NSString * describeQuery = [NSString stringWithFormat:@"SELECT reference_to FROM sf_reference_to WHERE object_api_name='SVMXC__Service_Order__c' AND field_api_name='%@'", displayValue];
                                
                                const char * _query = [describeQuery UTF8String];
                                int ret = sqlite3_prepare_v2(db, _query, -1, &statement, nil);
                                NSLog(@"%d", ret);
                                
                                sqlite3_stmt * statement = nil;
                                NSString * api_name = @"";
                                
                                if ( sqlite3_prepare_v2(db, _query,-1, &statement, nil) == SQLITE_OK )
                                {
                                    while(sqlite3_step(statement) == SQLITE_ROW)
                                    {
                                        char *_api_name = (char *) sqlite3_column_text(statement,0);
                                        if ((_api_name != nil) && strlen(_api_name))
                                        {         
                                            api_name = [[NSString alloc] initWithUTF8String:_api_name];
                                        }
                                    }
                                }
                                
                                NSString * selectField = [NSString stringWithFormat:@"%@.%@", api_name, referenceFieldName];
                                [selectClause setValue:selectField forKey:selectField];
                                
                                // FROM CLAUSE
                                
                                [fromClause setValue:api_name forKey:api_name];
                                
                                // WHERE CLAUSE
                                NSString * where = [NSString stringWithFormat:@"%@.Id = SVMXC__Service_Order__c.%@", api_name, displayValue];
                                [whereClause addObject:where];
                            }
                            else
                            {
                                NSString * actualQuery = [NSString stringWithFormat:@"SVMXC__Service_Order__c.%@", queryField];
                                [selectClause setValue:actualQuery forKey:actualQuery];
                            }
                        }
                    }
                    
                    if ([[[settingsInfoArray objectAtIndex:i] objectForKey:@"SVMXC__Settings_Name__c"] Contains:@"Address Type"])
                    {
                        NSString * queryField = [[settingsValueArray objectAtIndex:j] objectForKey:@"SVMXC__Internal_Value__c"];
                        if ([queryField isKindOfClass:[NSNull class]])
                        {
                            NSArray * arr = [NSArray arrayWithObjects:@"SVMXC__Company__r.BillingCountry",@"SVMXC__Company__r.BillingPostalCode", @"SVMXC__Company__r.BillingState",@"SVMXC__Company__r.BillingCity",@" SVMXC__Company__r.BillingStreet", nil];
                            
                            [self getAllReferenceFields:arr];
                            
                            // [appDelegate.soqlQuery appendFormat:@", %@", @"SVMXC__Company__c"];
                            [selectClause setValue:@"SVMXC__Company__c" forKey:@"SVMXC__Company__c"];
                            continue;
                        }
                        else if ([queryField isEqualToString:@"Account Bill To"]) // SVMXC__Company__r
                        {
                            NSArray * arr = [NSArray arrayWithObjects: @"SVMXC__Company__r.BillingCountry",@"SVMXC__Company__r.BillingPostalCode",@"SVMXC__Company__r.BillingState", @"SVMXC__Company__r.BillingCity", @"SVMXC__Company__r.BillingStreet", nil];
                            
                            [self getAllReferenceFields:arr];
                            
                            // [appDelegate.soqlQuery appendFormat:@", %@",  @"SVMXC__Company__c"];
                            [selectClause setValue:@"SVMXC__Company__c" forKey:@"SVMXC__Company__c"];
                        }
                        else if ([queryField isEqualToString:@"Account Ship To"]) // SVMXC__Company__r
                        {
                            NSArray * arr = [NSArray arrayWithObjects:@"SVMXC__Company__r.ShippingCountry", @"SVMXC__Company__r.ShippingPostalCode", @"SVMXC__Company__r.ShippingState", @"SVMXC__Company__r.ShippingCity", @"SVMXC__Company__r.ShippingStreet", nil];
                            
                            [self getAllReferenceFields:arr];
                            
                            // [appDelegate.soqlQuery appendFormat:@", %@", @"SVMXC__Company__c"];
                            [selectClause setValue:@"SVMXC__Company__c" forKey:@"SVMXC__Company__c"];
                        }
                        else if ([queryField isEqualToString:@"Service Location"]) // SVMXC__Service_Order__c
                        {
                            
                            // [appDelegate.soqlQuery appendFormat:@", %@", @"SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c, SVMXC__Zip__c, SVMXC__Country__c"];
                            [selectClause setValue:@"SVMXC__Street__c" forKey:@"SVMXC__Street__c"];
                            [selectClause setValue:@"SVMXC__City__c" forKey:@"SVMXC__City__c"];
                            [selectClause setValue:@"SVMXC__State__c" forKey:@"SVMXC__State__c"];
                            [selectClause setValue:@"SVMXC__Zip__c" forKey:@"SVMXC__Zip__c"];
                            [selectClause setValue:@"SVMXC__Country__c" forKey:@"SVMXC__Country__c"];
                        }
                        else if ([queryField isEqualToString:@"Contact Address"]) // SVMXC__Contact__c
                        {
                            NSArray * arr = [NSArray arrayWithObjects:@"SVMXC__Contact__r.MailingStreet", @"SVMXC__Contact__r.MailingState", @"SVMXC__Contact__r.MailingPostalCode", @"SVMXC__Contact__r.MailingCountry", @"SVMXC__Contact__r.MailingCity", nil];
                            
                            [self getAllReferenceFields:arr];
                            
                            // [appDelegate.soqlQuery appendFormat:@", %@", @"SVMXC__Contact__c"];
                            [selectClause setValue:@"SVMXC__Contact__c" forKey:@"SVMXC__Contact__c"];
                        }
                        if (appDelegate.addressType != nil)
                            [appDelegate.addressType release];
                        appDelegate.addressType = [queryField retain];
                    }
                }

                NSDictionary * keyDictionary = [settingsInfoArray objectAtIndex:i]; // Id
                NSDictionary * valueDictionary = [settingsValueArray objectAtIndex:j]; // SVMXC__Setting_ID__c
                
                NSString * Id = [keyDictionary objectForKey:@"Id"];
                NSString * settingId = [valueDictionary objectForKey:@"SVMXC__Setting_ID__c"];
                
                NSSet * boolFieldArray = [NSSet setWithObjects:
                                          @"IPAD004_SET003",
                                          @"IPAD004_SET004",
                                          @"IPAD004_SET005",
                                          @"IPAD004_SET006",
                                          @"IPAD004_SET007",
                                          @"IPAD004_SET008",
                                          @"IPAD004_SET009",
                                          @"IPAD004_SET010",
                                          nil];
                
                NSString * object = [valueDictionary objectForKey:@"SVMXC__Display_Value__c"];
                NSString * key = [keyDictionary objectForKey:@"SVMXC__Setting_Unique_ID__c"];
                
                if ([boolFieldArray containsObject:key])
                {
                    if ((object != nil) && (![object isKindOfClass:[NSNull class]]))
                        object = [object lowercaseString];
                }
                
                NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObject:object forKey:key];
                
                if ([[valueDictionary objectForKey:@"SVMXC__Display_Value__c"] isKindOfClass:[NSNull class]])
                    continue;
                if ([[keyDictionary objectForKey:@"SVMXC__Setting_Unique_ID__c"] isKindOfClass:[NSNull class]])
                    continue;

                // Filter Service Report using IPAD004
                if ([Id isEqualToString:settingId] && [[keyDictionary objectForKey:@"SVMXC__SubmoduleID__c"] isEqualToString:@"IPAD004"])
                {
                    NSArray * allKeys = [dict allKeys];
                    NSString * key = [allKeys objectAtIndex:0];
                    [appDelegate.serviceReport setValue:[dict valueForKey:key] forKey:key];
                    continue;
                }
            }
        }
        
        // FORM THE QUERY NOW
        // SELECT
        
        // First lets append the hard coded field names
        [selectClause setValue:@"SVMXC__Service_Order__c.Name" forKey:@"SVMXC__Service_Order__c.Name"];
        [selectClause setValue:@"SVMXC__Problem_Description__c" forKey:@"SVMXC__Problem_Description__c"];
        [selectClause setValue:@"SVMXC__Work_Performed__c" forKey:@"SVMXC__Work_Performed__c"];
        
        // Next, lets add Contact tablename, and keep on adding appropriately to the WHERE Clause
        
        NSString * checkFromTable = [fromClause valueForKey:@"Contact"];
        if (checkFromTable == nil)
        {
            [selectClause setValue:@"Contact.Name" forKey:@"Contact.Name"];
            [selectClause setValue:@"Contact.Phone" forKey:@"Contact.Phone"];
            [fromClause setValue:@"Contact" forKey:@"Contact"];
            [whereClause addObject:@"Contact.Id = SVMXC__Service_Order__c.SVMXC__Contact__c"];
        }
        else
        {
            if (![selectClause valueForKey:@"Contact.Name"])
                [selectClause setValue:@"Contact.Name" forKey:@"Contact.Name"];
            if (![selectClause valueForKey:@"Contact.Phone"])
                [selectClause setValue:@"Contact.Phone" forKey:@"Contact.Phone"];
        }
        
        NSArray * selectClauseKeys = [selectClause allKeys];
        for (int count = 0; count < [selectClauseKeys count]; count++)
        {
            if (count == 0)
                [appDelegate.soqlQuery appendString:[NSString stringWithFormat:@"SELECT %@", [selectClauseKeys objectAtIndex:count]]];
            else
                [appDelegate.soqlQuery appendString:[NSString stringWithFormat:@",%@", [selectClauseKeys objectAtIndex:count]]];
        }
        
        // FROM
        [appDelegate.soqlQuery appendFormat:@" FROM SVMXC__Service_Order__c "];
        NSArray * allFromKeys = [fromClause allKeys];
        for (int count = 0; count < [allFromKeys count]; count++)
        {
//            if (count == 0)
//                [appDelegate.soqlQuery appendString:[allFromKeys objectAtIndex:count]];
//            else
//                [appDelegate.soqlQuery appendString:[NSString stringWithFormat:@",%@", [allFromKeys objectAtIndex:count]]];
            
            [appDelegate.soqlQuery appendString:@" LEFT OUTER JOIN "];
            [appDelegate.soqlQuery appendString:[NSString stringWithFormat:@"%@ ON ", [allFromKeys objectAtIndex:count]]];
            
            for (int i = 0; i < [whereClause count]; i++)
            {
                NSString * where = [whereClause objectAtIndex:i];
                NSArray * array = [where componentsSeparatedByString:@".Id"];
                
                NSString * left = [allFromKeys objectAtIndex:count];
                NSString * right = [array objectAtIndex:0];
                
                if ([left isEqualToString:right])
                {
                    [appDelegate.soqlQuery appendString:[NSString stringWithFormat:@"%@ ", where]];
                    break;
                }
            }
            
        }
        
        // WHERE
        [appDelegate.soqlQuery appendFormat:@" WHERE "];
//        for (int count = 0; count < [whereClause count]; count++)
//        {
//            if (count == 0)
//                [appDelegate.soqlQuery appendString:[whereClause objectAtIndex:count]];
//            else
//                [appDelegate.soqlQuery appendString:[NSString stringWithFormat:@" AND %@", [whereClause objectAtIndex:count]]];
//        }
        
        NSLog(@"appDelegate.soqlQuery = %@", appDelegate.soqlQuery);
        
        NSArray * array = [NSArray arrayWithObjects:@"SVMXC__Contact__r.Name",@"SVMXC__Contact__r.Phone", nil];
        [appDelegate.database getAllReferenceFields:array];
        
        [appDelegate.database getAllReferenceFields:query_fields_array];
        
        NSLog(@"----------query_fields_array ------------- %@", query_fields_array);
        NSLog(@" ============================refernce_field_array==============================================%@",appDelegate.reference_field_names);
        NSLog(@"----SOQL_QUERY----%@",appDelegate.soqlQuery);
    }
          
    NSMutableArray *WorkOrderFields = [[NSMutableArray alloc]initWithCapacity:0];    
    {
        sqlite3_stmt *statement9;
        NSMutableString *queryStatement9 = [[NSMutableString alloc]initWithCapacity:0];
        queryStatement9 = [NSMutableString stringWithFormat:@"SELECT api_name,label,type FROM SFObject_Field WHERE object_api_name = 'SVMXC__Service_Order__c' "];
        NSLog(@"%@", queryStatement9);
        
        const char * _query9 = [queryStatement9 UTF8String];
        NSArray * keys9 = [NSArray arrayWithObjects:
                          API_NAME,
                           LABEL,
                           TYPE,
                          nil];
        int ret = sqlite3_prepare_v2(db, _query9,-1, &statement9, nil);
        NSLog(@"%d", ret);
        
        
        if ( sqlite3_prepare_v2(db, _query9,-1, &statement9, nil) == SQLITE_OK )
        {
            while(sqlite3_step(statement9) == SQLITE_ROW)
            {
                char *_api_name = (char *) sqlite3_column_text(statement9,0);
                NSString * api_name = @"";    
                if ((_api_name != nil) && strlen(_api_name))
                {         
                    api_name = [[NSString alloc] initWithUTF8String:_api_name];
                    
                }
                char *_label = (char *) sqlite3_column_text(statement9,1);
                NSString * label = @"";
                if ((_label != nil) && strlen(_label))
                {         
                    label = [[NSString alloc] initWithUTF8String:_label];
                }

                char *_type = (char *) sqlite3_column_text(statement9,2);
                NSString * type = @"";
                if ((_type != nil) && strlen(_type))
                {         
                    type = [[NSString alloc] initWithUTF8String:_type];
                }
                
                NSMutableArray * objects9 = [[NSMutableArray arrayWithObjects:api_name,label,type,nil] retain];
                
                NSDictionary * dictionary9 = [[NSDictionary alloc] initWithObjects:objects9 forKeys:keys9];
                [WorkOrderFields addObject:dictionary9];
                [dictionary9 release];
                [objects9 release];
            }
        }
        
        NSLog(@"%@",WorkOrderFields);
        appDelegate.WorkDescription = [WorkOrderFields retain];
    }
    
}

-(void) getAllReferenceFields:(NSArray *)fields_array
{
    for (int j= 0 ; j< [fields_array count]; j++)
    {
        NSString * queryField = [fields_array objectAtIndex:j];
        NSLog(@"QUERY FIELD %@", queryField);
        if ([queryField isKindOfClass:[NSNull class]])
            continue;
        NSArray * arr = [queryField componentsSeparatedByString:@"."];
        
        
        BOOL flag = FALSE;
        NSString * field_name =@"";
        NSString * referencefield_name = @"";
        for(int p =0 ;p < [arr count]; p++)
        {
            if(p == 0)
            {
                field_name = [[arr objectAtIndex:0] stringByReplacingOccurrencesOfString:@"__r" withString:@"__c"];
            }
            if(p == 1)
            {
                referencefield_name = [arr objectAtIndex:p];
            }    
        }
        
        NSArray * keys = [appDelegate.reference_field_names allKeys];
        for (int i = 0; i < [keys count]; i++)
        {
            NSString * key = [keys objectAtIndex:i];
            if ([key isEqualToString:field_name]) 
            {
                flag = TRUE;
                break;
            }
            
        }
        
        if (flag)
        {
            NSMutableArray * arr2 =[appDelegate.reference_field_names objectForKey:field_name];
            BOOL flag1 = FALSE;
            for(int k =0 ; k < [arr2 count]; k++)
            {
                NSString *  key1 = [arr2 objectAtIndex:k];
                if([key1 isEqualToString:referencefield_name])
                {
                    flag1 = TRUE;
                    break;
                }
            }
            if(flag1)
            {
                
            }
            else
            {
                [arr2 addObject:referencefield_name];
            }
        }
        else
        {
            NSMutableArray * arr1 = [NSMutableArray arrayWithObject:referencefield_name];
            [appDelegate.reference_field_names setObject:arr1 forKey:field_name];
        }
    }
}

-(NSMutableArray *)getReportEssentials:(NSString *) record_id
{
    NSMutableArray * reportEssentialArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
   // record_id = @"a0tK0000000D1fFIAS";
    
    NSString * query = @"";
    NSMutableString * clean_Query = [appDelegate.database removeDuplicatesFromSOQL:appDelegate.soqlQuery withString:query];
    NSString * final_query = [NSString stringWithFormat:@"%@ SVMXC__Service_Order__c.local_id = '%@'", clean_Query, record_id];
    
    NSLog( @"final query %@",final_query);

    NSArray * leftOfFrom = [final_query componentsSeparatedByString:@"FROM"];
    NSString * selectStatement = [leftOfFrom objectAtIndex:0];
    selectStatement = [selectStatement stringByReplacingOccurrencesOfString:@"SELECT " withString:@""];
    NSMutableArray * all_fields = [[[selectStatement componentsSeparatedByString:@","] mutableCopy] autorelease];
    for (int i = 0; i < [all_fields count]; i++)
    {
        NSString * str = [all_fields objectAtIndex:i];
        str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
        [all_fields replaceObjectAtIndex:i withObject:str];
    }

    sqlite3_stmt *statement5;
    
    int count = 0;
    
    if ( sqlite3_prepare_v2(db, [final_query UTF8String],-1, &statement5, nil) == SQLITE_OK )
    {
        while(sqlite3_step(statement5) == SQLITE_ROW)
        {
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:0];
            for(int k = 0 ; k < [all_fields count] ; k++)
            {
                char * field = (char *) sqlite3_column_text(statement5, k);
                char * columnText = (char *) sqlite3_column_name(statement5, k);
                if(field != nil)
                {
                    NSString * field_value = [NSString stringWithUTF8String:field];
                    NSString * field_name = [NSString stringWithUTF8String:columnText];
                    field_name = [all_fields objectAtIndex:count++];
                    field_name = [field_name stringByReplacingOccurrencesOfString:@"SVMXC__Service_Order__c." withString:@""];
                    [dict setValue:field_value forKey:field_name];
                }
                else
                    count++;
            }
            [reportEssentialArray addObject:dict];
            [dict release];
        }
    }
    
    NSLog(@"Report Essential Array %@", reportEssentialArray);
    
    NSMutableArray *  refernce_array = [appDelegate.database getreferncetableFieldsForReportEsentials:reportEssentialArray];
    
    for(NSDictionary * dict in refernce_array)
    {
        [reportEssentialArray addObject:dict];
    }
    
    return reportEssentialArray;
}

-(NSMutableArray *)getreferncetableFieldsForReportEsentials:(NSMutableArray *)array
{
    NSMutableArray *  getAll_field_values = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSArray * allkeys = [appDelegate.reference_field_names allKeys];
    for(int k= 0 ; k<[allkeys count]; k++)
    {
        NSString * key = [allkeys objectAtIndex:k];
        
        NSString * table_name = @"";
        NSMutableArray * fields_array = [appDelegate.reference_field_names objectForKey:key];
        
        NSLog(@"======================Field_array==============================%@" ,fields_array);
        NSString * queryableFields = @"";
        for(int i = 0 ; i<[fields_array count]; i++)
        {
            if(i != 0)
            {
                queryableFields = [queryableFields stringByAppendingString:@","];
            }
            queryableFields = [queryableFields stringByAppendingString:[fields_array objectAtIndex:i]];
        }
        
        NSLog(@" ------queryFields %@", queryableFields);
        if([key isEqualToString:@"SVMXC__Company__c"])
        {
            table_name = @"Account";
        }
        else if([key isEqualToString:@"SVMXC__Component__c"])
        {
            table_name = @"SVMXC__Installed_Product__c";
        }
        else if([key isEqualToString:@"SVMXC__Contact__c"])
        {
            table_name = @"Contact";
        }
        
        NSLog( @" key -%@ tablename %@", key , table_name);
        
        if([queryableFields length]!= 0)
        {
            
            NSString * refernce_id = @"";
            for(int j = 0 ; j<[array count] ; j++)
            {
                NSDictionary * dict = [array objectAtIndex:j];
                NSLog(@"dict  - %@ ", dict);
                
                
                NSArray * arr1_allkeys = [dict allKeys];
                for(int x = 0 ; x < [arr1_allkeys count] ; x++)
                {
                    NSString * arr1_key = [arr1_allkeys objectAtIndex:x];
                    
                    arr1_key = [arr1_key   stringByReplacingOccurrencesOfString:@" " withString:@""];
                    NSLog(@" arr1_allkeys  %@   key  %@ ", arr1_key, key);
                    if([key isEqualToString:arr1_key])
                    {
                        refernce_id =  [dict valueForKey:key];
                        break;
                    }
                    
                }
                //if(key isEqualToString:[array])
            }
            
            NSString * query = [NSString stringWithFormat:@"SELECT %@ FROM %@ Where id = '%@'" , queryableFields , table_name , refernce_id];
            
            NSLog(@" query --%@" , query);
            sqlite3_stmt * statement5;
            
            NSMutableDictionary * dict = nil;
            
            if ( sqlite3_prepare_v2(db, [query UTF8String],-1, &statement5, nil) == SQLITE_OK )
            {
                while(sqlite3_step(statement5) == SQLITE_ROW)
                {
                    dict = [[NSMutableDictionary alloc] initWithCapacity:0];
                    for(int p = 0 ; p<[fields_array count]; p++)
                    {   
                        char * field = (char *) sqlite3_column_text(statement5, p);
                        if(field != nil)
                        {
                           
                            NSString * field_value = [NSString stringWithUTF8String:field];
                            NSString *  field_key = [fields_array objectAtIndex:p];
//                            NSString *  key_ = [NSString stringWithFormat:@"%@.%@",key,field_key];
                            NSString *  key_ = [NSString stringWithFormat:@"%@",field_key];
                            [dict setValue:field_value forKey:key_];
                            NSLog(@" getAllField values %@", dict); 
                        }
                    }
                    NSDictionary * finalDict = [NSDictionary dictionaryWithObject:dict forKey:key];
                    [getAll_field_values addObject:finalDict];
                    [dict release];
                    dict = nil;
                }
            }
        }
    }
    
    
    NSLog(@" ------------------ get All field values%@", getAll_field_values);
    return getAll_field_values;
    
}




- (NSMutableString *) removeDuplicatesFromSOQL:(NSString *)soql withString:(NSString *)_query
{
    NSMutableArray * array1 = [[[_query componentsSeparatedByString:@","] mutableCopy] autorelease];
    NSArray * array2 = [[array1 lastObject] componentsSeparatedByString:@" "]; // Need to read only first object
    [array1 addObject:[array2 objectAtIndex:0]];
    NSMutableArray * array3 = [[[soql componentsSeparatedByString:@","] mutableCopy] autorelease];
    
    
    // remove 0 length strings from array3, they create confusion and also crashes
    for (int n = 0; n < [array3 count]; n++)
    {
        if ([[array3 objectAtIndex:n] length] == 0)
            [array3 removeObjectAtIndex:n];
    }
    
    for (int i = 0; i < [array1 count]; i++)
    {
        NSString * array1Obj = [array1 objectAtIndex:i];
        array1Obj = [array1Obj stringByReplacingOccurrencesOfString:@"," withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [array1Obj length])];
        for (int j = 0; j < [array3 count]; j++)
        {
            NSString * array3Obj = [array3 objectAtIndex:j];
            array3Obj = [array3Obj stringByReplacingOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [array3Obj length])];
            if ([array1Obj isEqualToString:array3Obj])
            {
                [array3 removeObjectAtIndex:j];
                j--;
            }
        }
    }
    
    NSMutableString * result = [[[NSMutableString alloc] initWithCapacity:0] autorelease];
    for (int i = 0; i < [array3 count]; i++)
    {
        if ([array3 count] > 1)
        {
            for (int j = i+1; j < [array3 count]; j++)
            {
                NSString * obji = [array3 objectAtIndex:i];
                NSString * objj = [array3 objectAtIndex:j];
                
                if ([obji isEqualToString:objj])
                {
                    [array3 removeObject:objj];
                    j--;
                }
            }
        }
    }
    
    for (int count = 0; count < [array3 count]; count++)
    {
        if (count == [array3 count]-1)
            [result appendString:[NSString stringWithFormat:@"%@", [array3 objectAtIndex:count]]];
        else
            [result appendString:[NSString stringWithFormat:@"%@, ", [array3 objectAtIndex:count]]];
    }
    
    NSLog(@"%@", result);
    return result;
}
@end
