//
//  CalendarDatabase.m
//  iService
//
//  Created by Pavamanaprasad Athani on 06/12/11.
//  Copyright (c) 2011 Bit Order Technologies. All rights reserved.
//

#import "CalendarDatabase.h"
#import "LocalizationGlobals.h"
#import "Globals.h"
#import "AppDelegate.h"
#import "NSData-AES.h"
#import "PDFCreator.h"
#import "Utility.h"
#import "SVMXSystemConstant.h"
#import "Utility.h" //10312

void SMXLog(int level,const char *methodContext,int lineNumber,NSString *message);

@interface CalendarDatabase () //7280 - Displaying the events only related to logged in user using owner Id 

- (NSString *) getUserIdFromUserTable;
- (BOOL) isWorkOrderOrCaseForColorCode:(NSString *)whatId; //008387

@end

@implementation CalendarDatabase
@synthesize dbFilePath;
@synthesize opDocController;
//@synthesize whatId1, subject;
-(id)init
{
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return self;
}

-initWithDBName
{
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];    
    return self;
}



- (BOOL) isUsernameValid:(NSString *)userName
{
    NSString * queryStatement = [NSString stringWithFormat:@"SELECT Username FROM User"];
    
     NSString *field1Str = @"";
    
    sqlite3_stmt * stmt;
    
    BOOL flag = FALSE;
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(stmt) ==  SQLITE_ROW) 
        {
            char *field1 = (char *) synchronized_sqlite3_column_text(stmt,0);
            if ((field1 != nil) && strlen(field1))
              field1Str = [NSString stringWithUTF8String:field1];
            
            if ( [field1Str isEqualToString:userName])
            {
                flag = TRUE;
                break;
            }
        }
    }
    synchronized_sqlite3_finalize(stmt);
    if ( flag )
        return  YES;
    else
        return NO;
}

- (NSMutableArray *) getProcessFromDatabase
{
    NSString *query = @"Select * from Processes";
    NSMutableArray *viewArray = [[[NSMutableArray alloc]initWithCapacity:0]autorelease];
    
    sqlite3_stmt * statement;
    const char * _query = [query UTF8String];
    
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, _query,-1, &statement, nil) == SQLITE_OK )
    {
        while(synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            char *field1 = (char *) synchronized_sqlite3_column_text(statement,1);
            NSString *field1Str = [[NSString alloc] initWithUTF8String: field1];
            [viewArray addObject:field1Str];
            
            char *field2 = (char *) synchronized_sqlite3_column_text(statement,2);
            NSString *field2Str = [[NSString alloc] initWithUTF8String: field2];
            [viewArray addObject:field2Str];
            
            char *field3 = (char *) synchronized_sqlite3_column_text(statement,3);
            NSString *field3Str = [[NSString alloc] initWithUTF8String: field3];
            [viewArray addObject:field3Str];
            
            [field1Str release];
            [field2Str release];
            [field3Str release];
        }
    }
    synchronized_sqlite3_finalize(statement);
    return  viewArray;
} 


- (NSMutableArray *) didGetTaskFromDB:(NSString *)_date
{
    NSMutableString * query = [NSMutableString stringWithFormat:@"Select Priority, Subject, ActivityDate, local_id from Task where ActivityDate = '%@'", _date];
    
    sqlite3_stmt * stmt;
    
    NSMutableArray *taskArray = [[[NSMutableArray alloc]initWithCapacity:0]autorelease];
    
    const char * _query = [query UTF8String];
    
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, _query,-1, &stmt, nil) == SQLITE_OK )
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            NSString * field1Str = @"";
            NSString * field2Str = @"";
            NSString * field3Str = @"";
            NSString * field4Str = @"";
            
            NSMutableArray *_taskArray =[[NSMutableArray alloc]initWithCapacity:0];
           
            char *field1 = (char *) synchronized_sqlite3_column_text(stmt,0);
            
            if (field1 != nil && strlen(field1))
                field1Str = [[NSString alloc] initWithUTF8String: field1];
            [_taskArray addObject:field1Str];
            
            char *field2 = (char *) synchronized_sqlite3_column_text(stmt,1);
            if (field2 != nil && strlen(field2))
                field2Str = [[NSString alloc] initWithUTF8String: field2];
            [_taskArray addObject:field2Str];
            
            char *field3 = (char *) synchronized_sqlite3_column_text(stmt,2);
            if (field3 != nil && strlen(field3))
            field3Str = [[NSString alloc] initWithUTF8String: field3];
            [_taskArray addObject:field3Str];
            
            char *field4 = (char *) synchronized_sqlite3_column_text(stmt,3);
            if (field4 != nil && strlen(field4))
                field4Str = [[NSString alloc] initWithUTF8String: field4];
            [_taskArray addObject:field4Str];
            
            [taskArray addObject:_taskArray];
            [field1Str release];
            [field2Str release];
            [field3Str release];
            [field4Str release];
            [_taskArray release];
        }
    }
    synchronized_sqlite3_finalize(stmt);
    return  taskArray; 
}

- (BOOL) insertTasksIntoDB:(NSArray *)_tasks WithDate:(NSString*)_date local_id:(NSString *)local_id
{    
    NSString *tableName = @"Task";
    NSString *strTasks=[ [_tasks objectAtIndex:0] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString * subject = [[_tasks objectAtIndex:1] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    NSString *sql = [NSString stringWithFormat: @"INSERT  INTO '%@' (local_id , Priority,Subject,ActivityDate) VALUES ('%@','%@','%@', '%@')", tableName, local_id,strTasks, subject, _date];
    
    char *err;
    if (synchronized_sqlite3_exec(appDelegate.db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
		SMLog(kLogLevelError,@"%@", sql);
		SMLog(kLogLevelError,@"METHOD: insertTasksIntoDB");
        SMLog(kLogLevelError,@"ERROR IN INSERTING %s", err);
		[appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:sql type:INSERTQUERY];
        return FALSE;
    }
    return TRUE;
}

//Copying method from sum 14 IOS8 for Defect - 11946
//Problem was time zone, So we are taking one day extra data and calculatiog
- (NSMutableArray *) GetEventsFromDBWithStartDate:(NSString *)startdate endDate:(NSString *)endDate
{
    // sqlite3_stmt * dbps;
    NSMutableArray * resultSet = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];/*Shravya-Calendar view 7408 */
    NSMutableString * queryStatement = [[NSMutableString alloc]initWithCapacity:0];
    sqlite3_stmt * statement;
    
    //Defect - 11946
    
    /*int value  = [[startdate substringWithRange:NSMakeRange(8, 2)] intValue];
     NSString * string = nil;
     
     if (value >= 0 && value <= 10)
     string = [NSString stringWithFormat:@"0%d", --value];
     else
     string = [NSString stringWithFormat:@"%d", --value];
     
     startdate = [startdate stringByReplacingCharactersInRange:NSMakeRange(8, 2) withString:string];
     
     value = [[endDate substringWithRange:NSMakeRange(8, 2)] intValue];
     
     if (value >= 0 && value <= 8)
     string = [NSString stringWithFormat:@"0%d", ++value];
     else
     string = [NSString stringWithFormat:@"%d", ++value];
     endDate = [endDate stringByReplacingCharactersInRange:NSMakeRange(8, 2) withString:string];*/
    
    @try{
        //7280
        NSString * ownerId = [self getUserIdFromUserTable]; //Displaying the events only related to logged in user using owner Id
        if (ownerId != nil && [ownerId length] > 0)
        {
            queryStatement = [NSMutableString stringWithFormat:@"SELECT  ActivityDate, ActivityDateTime,DurationInMinutes,EndDateTime,StartDateTime,Subject,WhatId,Id ,local_id FROM Event where (((StartDateTime >= '%@' and StartDateTime < '%@') or (EndDateTime >= '%@' and EndDateTime < '%@')) and OwnerId = '%@' )", startdate, endDate, startdate, endDate, ownerId];
        }else{
            queryStatement = [NSMutableString stringWithFormat:@"SELECT  ActivityDate, ActivityDateTime,DurationInMinutes,EndDateTime,StartDateTime,Subject,WhatId,Id ,local_id FROM Event where ((StartDateTime >= '%@' and StartDateTime < '%@') or (EndDateTime >= '%@' and EndDateTime < '%@'))", startdate, endDate, startdate, endDate];
        }
        SMLog(kLogLevelVerbose, @"EventQuery = '%@'", queryStatement);
        const char * selectStatement = [queryStatement UTF8String];
        int ret = synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement, -1, &statement, NULL);
        if (ret == SQLITE_OK)
        {
            NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init]autorelease];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSDateFormatter * datetimeFormatter=[[[NSDateFormatter alloc]init]autorelease];
            NSTimeZone * gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
            [datetimeFormatter setTimeZone:gmt];
            //10312
            [datetimeFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
            NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            [dateFormatter setCalendar:cal];
            [cal release];
            [datetimeFormatter  setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; //10312
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
                              CITY,
                              ZIP,
                              STREET,
                              STATE,
                              COUNTRY,
                              EVENT_LOCAL_ID,
                              nil];
            
            ret = synchronized_sqlite3_step(statement);
            while (ret == SQLITE_ROW)
            {
                NSString *City = @"";
                NSString *Zip = @"";
                NSString *Street = @"";
                NSString *State = @"";
                NSString *Country = @"";
                
                NSString * subject = @"";
                NSString * additonalInfo = @"";
                NSString * whatId1 = @"";
                
                char * _activityDate = (char *) synchronized_sqlite3_column_text(statement,0);
                NSString * activitydate = @"";
                NSDate * activityDate = nil;
                if (activityDate == nil)
                    activityDate = [[NSDate alloc] init];
                if ((_activityDate != nil) && strlen(_activityDate))
                {
                    activitydate = [NSString stringWithUTF8String:_activityDate];
                    activitydate = [activitydate stringByDeletingPathExtension];
                    if ([activitydate length] > 10)
                        activityDate = [datetimeFormatter dateFromString:activitydate];
                    else
                        activityDate = [dateFormatter dateFromString:activitydate];
                }
                
                char * _activityDateTime = (char *) synchronized_sqlite3_column_text(statement,1);
                NSString *activitydateTime = @"";
                NSDate *activityDateTime = nil;
                if (activityDateTime == nil)
                    activityDateTime = [[NSDate alloc] init];
                
                if ((_activityDateTime != nil) && strlen(_activityDateTime))
                {
                    activitydateTime = [NSString stringWithUTF8String:_activityDateTime];
                    activitydateTime = [activitydateTime stringByDeletingPathExtension];
                    activitydateTime = [activitydateTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
                    if ([activitydateTime length] > 10)
                        activityDateTime = [datetimeFormatter dateFromString:activitydateTime];
                    else
                        activityDateTime = [dateFormatter dateFromString:activitydateTime];
                }
                
                char * _durationInMins = (char *) synchronized_sqlite3_column_text(statement,2);
                NSString * durationInMins = @"";
                if ((_durationInMins != nil) && strlen(_durationInMins))
                {
                    durationInMins = [NSString stringWithUTF8String:_durationInMins];
                }
                
                char * _endDateTime = (char *) synchronized_sqlite3_column_text(statement,3);
                NSString * enddateTime = @"";
                NSDate * endDateTime = nil;
                if (endDateTime == nil)
                    endDateTime = [[NSDate alloc] init];
                if ((_endDateTime != nil) && strlen(_endDateTime))
                {
                    enddateTime = [NSString stringWithUTF8String:_endDateTime];
                    enddateTime = [enddateTime stringByDeletingPathExtension];
                    enddateTime = [enddateTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
                    
                    if ([enddateTime length] > 10)
                        endDateTime = [datetimeFormatter dateFromString:enddateTime];
                    else
                        endDateTime = [dateFormatter dateFromString:enddateTime];
                }
                
                char * _startDateTime = (char *) synchronized_sqlite3_column_text(statement,4);
                NSString * startdateTime = @"";
                NSDate * startDateTime = nil;
                if (startDateTime == nil)
                    startDateTime = [[NSDate alloc] init];
                if ((_startDateTime != nil) && strlen(_startDateTime))
                {
                    startdateTime = [NSString stringWithUTF8String:_startDateTime];
                    startdateTime = [startdateTime stringByDeletingPathExtension];
                    startdateTime = [startdateTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
                    if ([startdateTime length] > 10)
                        startDateTime = [datetimeFormatter dateFromString:startdateTime];
                    else
                        startDateTime = [dateFormatter dateFromString:startdateTime];
                }
                
                char * _subject = (char *) synchronized_sqlite3_column_text(statement,5);
                
                if ((_subject != nil) && strlen(_subject))
                {
                    subject = [NSString stringWithUTF8String:_subject];
                }
                
                
                char * _whatId = (char *) synchronized_sqlite3_column_text(statement,6);
                NSString *whatId = @"";
                if ((_whatId != nil) && strlen(_whatId))
                {
                    whatId = [NSString stringWithUTF8String:_whatId];
                    
                    whatId1 = whatId;
                }
                
                char *_eventId = (char *) synchronized_sqlite3_column_text(statement,7);
                NSString * eventId = @"";
                if ((_eventId != nil) && strlen(_eventId))
                {
                    eventId = [NSString stringWithUTF8String: _eventId];
                }
                
                char *_local_id= (char *) synchronized_sqlite3_column_text(statement,8);
                NSString * event_local_Id = @"";
                if ((_local_id != nil) && strlen(_local_id))
                {
                    event_local_Id = [NSString stringWithUTF8String: _local_id];
                }
                
                BOOL retVal, retVal1;
                // retVal = [self isWorkOrder:whatId1];
                
                retVal = [self isWorkOrderOrCase:whatId1 objectName:@"SVMXC__Service_Order__c"];
                retVal1 = [self isWorkOrderOrCase:whatId1 objectName:@"Case"];
                
                if ( retVal == YES && (!([whatId1 isEqualToString:@""]) || whatId1 != nil) )
                {
                    NSString *subject1  = @"";
                    NSMutableString *queryStatement = [[NSMutableString alloc]initWithCapacity:0];
                    //012135
                    if (ownerId != nil && [ownerId length] > 0) {
                        if((_startDateTime!=nil) && strlen(_startDateTime) && (_endDateTime!=nil) && strlen(_endDateTime))
                            queryStatement =[NSMutableString stringWithFormat:@"Select Subject From Event where WhatId = '%@' and StartDateTime = '%s' and EndDateTime = '%s' and OwnerId = '%@'", whatId1,_startDateTime,_endDateTime, ownerId];
                        else
                            queryStatement =[NSMutableString stringWithFormat:@"Select Subject From Event where WhatId = '%@' and OwnerId = '%@'", whatId1, ownerId];
                        
                    }
                    else {
                        if((_startDateTime!=nil) && strlen(_startDateTime) && (_endDateTime!=nil) && strlen(_endDateTime))
                            queryStatement =[NSMutableString stringWithFormat:@"Select Subject From Event where WhatId = '%@' and StartDateTime = '%s' and EndDateTime = '%s'", whatId1,_startDateTime,_endDateTime];
                        else
                            queryStatement =[NSMutableString stringWithFormat:@"Select Subject From Event where WhatId = '%@'", whatId1];
                        
                    }
                    
                    //12135
                    if (ownerId != nil && [ownerId length] > 0){
                        if((_startDateTime!=nil) && strlen(_startDateTime) && (_endDateTime!=nil) && strlen(_endDateTime))
                            queryStatement =[NSMutableString stringWithFormat:@"Select Subject From Event where WhatId = '%@' and StartDateTime = '%s' and EndDateTime = '%s' and OwnerId = '%@'", whatId1,_startDateTime,_endDateTime, ownerId];
                        else
                            queryStatement =[NSMutableString stringWithFormat:@"Select Subject From Event where WhatId = '%@' and  OwnerId = '%@'", whatId1, ownerId];
                    }
                    else {
                        if((_startDateTime!=nil) && strlen(_startDateTime) && (_endDateTime!=nil) && strlen(_endDateTime))
                            queryStatement =[NSMutableString stringWithFormat:@"Select Subject From Event where WhatId = '%@' and StartDateTime = '%s' and EndDateTime = '%s'", whatId1,_startDateTime,_endDateTime];
                        else
                            queryStatement =[NSMutableString stringWithFormat:@"Select Subject From Event where WhatId = '%@'", whatId1];
                    }
                    
                    const char * selectStatement = [queryStatement UTF8String];
                    sqlite3_stmt * eventsubject;
                    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &eventsubject, nil) == SQLITE_OK )
                    {
                        while(synchronized_sqlite3_step(eventsubject) == SQLITE_ROW)
                        {
                            char * _subject = (char *) synchronized_sqlite3_column_text(eventsubject,0);
                            
                            if ((_subject != nil) && strlen(_subject))
                            {
                                subject1 = [NSString stringWithUTF8String:_subject];
                                subject = nil;
                                subject = subject1;
                            }
                            
                        }
                        
                    }
                    synchronized_sqlite3_finalize(eventsubject);
                    //SHRINIVAS
                    NSString * WorkOrderLabel = @"";
                    NSMutableString * queryStatement1 = [[NSMutableString alloc]initWithCapacity:0];
                    queryStatement1 = [NSMutableString stringWithFormat:@"Select Name,SVMXC__City__c,SVMXC__Zip__c,SVMXC__Street__c,SVMXC__State__c,SVMXC__Country__c From SVMXC__Service_Order__c where Id = '%@'",whatId1];
                    const char * selectStatement1 = [queryStatement1 UTF8String];
                    sqlite3_stmt * details;
                    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement1, -1, &details, nil) == SQLITE_OK)
                    {
                        while (synchronized_sqlite3_step(details) == SQLITE_ROW)
                        {
                            char * _WorkOrderLabel = (char *) synchronized_sqlite3_column_text(details, 0);
                            if ((_WorkOrderLabel !=nil) && strlen(_WorkOrderLabel))
                            {
                                WorkOrderLabel = [NSString stringWithUTF8String:_WorkOrderLabel];
                            }
                            
                            char * _city = (char *) synchronized_sqlite3_column_text(details, 1);
                            if ((_city !=nil) && strlen(_city))
                            {
                                City = [NSString stringWithUTF8String:_city];
                            }
                            
                            char * _zip = (char *) synchronized_sqlite3_column_text(details, 2);
                            if ((_zip !=nil) && strlen(_zip))
                            {
                                Zip = [NSString stringWithUTF8String:_zip];
                            }
                            
                            char * _street = (char *) synchronized_sqlite3_column_text(details, 3);
                            if ((_street !=nil) && strlen(_street))
                            {
                                Street = [NSString stringWithUTF8String:_street];
                            }
                            
                            char * _state = (char *) synchronized_sqlite3_column_text(details, 4);
                            if ((_state !=nil) && strlen(_state))
                            {
                                State = [NSString stringWithUTF8String:_state];
                            }
                            
                            char * _country = (char *) synchronized_sqlite3_column_text(details, 5);
                            if ((_country !=nil) && strlen(_country))
                            {
                                Country = [NSString stringWithUTF8String:_country];
                            }
                        }
                    }
                    synchronized_sqlite3_finalize(details);
                    additonalInfo = @"";
                    NSString * info = @"";
                    queryStatement = [NSMutableString stringWithFormat:@"SELECT label from SFObject where api_name = '%@'", objectApiName];
                    sqlite3_stmt * labelstmt;
                    selectStatement = [queryStatement UTF8String];
                    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &labelstmt, nil) == SQLITE_OK )
                    {
                        while(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW)
                        {
                            char * _addInfo = (char *) synchronized_sqlite3_column_text(labelstmt,0);
                            
                            if ((_addInfo != nil) && strlen(_addInfo))
                                info = [NSMutableString stringWithUTF8String:_addInfo];
                        }
                    }
                    additonalInfo = [NSString stringWithFormat:@"%@ : %@", info, WorkOrderLabel];
                    synchronized_sqlite3_finalize(labelstmt);
                }
                //Case
                //8211: Replaced retVal with retVal1
                else if( retVal1 == YES && (!([whatId1 isEqualToString:@""]) || whatId1 != nil) )
                {
                    
                    NSString * caseNumber  = @"";
                    NSMutableString *queryStatement = [[NSMutableString alloc]initWithCapacity:0];
                    //8211:
                    queryStatement = [NSMutableString stringWithFormat:@"SELECT CaseNumber from 'Case' where Id = '%@'", whatId1];
                    const char * selectStatement = [queryStatement UTF8String];
                    
                    sqlite3_stmt * casestmt;
                    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &casestmt, nil) == SQLITE_OK )
                    {
                        while(synchronized_sqlite3_step(casestmt) == SQLITE_ROW)
                        {
                            char * _caseNumber = (char *) synchronized_sqlite3_column_text(casestmt,0);
                            
                            if ((_caseNumber != nil) && strlen(_caseNumber))
                            {
                                caseNumber = [NSString stringWithUTF8String:_caseNumber];
                            }
                            
                        }
                        
                    }
                    synchronized_sqlite3_finalize(casestmt);
                    additonalInfo = @"";
                    NSString * info = @"";
                    queryStatement = [NSMutableString stringWithFormat:@"SELECT label from SFObject where api_name = '%@'", objectApiName];
                    selectStatement = [queryStatement UTF8String];
                    sqlite3_stmt * stmt;
                    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &stmt, nil) == SQLITE_OK )
                    {
                        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
                        {
                            char * _addInfo = (char *) synchronized_sqlite3_column_text(stmt,0);
                            
                            if ((_addInfo != nil) && strlen(_addInfo))
                                info = [NSString stringWithUTF8String:_addInfo];
                        }
                    }
                    additonalInfo = [NSString stringWithFormat:@"%@ : %@", info, caseNumber];
                    synchronized_sqlite3_finalize(stmt);
                    
                    
                    queryStatement = nil;
                    //012135
                    if (ownerId != nil && [ownerId length] > 0) {
                        
                        if((_startDateTime!=nil) && strlen(_startDateTime) && (_endDateTime!=nil) && strlen(_endDateTime))
                            queryStatement =[NSMutableString stringWithFormat:@"Select Subject From Event where WhatId = '%@' and StartDateTime = '%s' and EndDateTime = '%s' and OwnerId = '%@' ", whatId1,_startDateTime,_endDateTime, ownerId];
                        else
                            queryStatement =[NSMutableString stringWithFormat:@"Select Subject From Event where WhatId = '%@' and OwnerId = '%@'", whatId1, ownerId];
                        
                    }
                    else {
                        if((_startDateTime!=nil) && strlen(_startDateTime) && (_endDateTime!=nil) && strlen(_endDateTime))
                            queryStatement =[NSMutableString stringWithFormat:@"Select Subject From Event where WhatId = '%@' and StartDateTime = '%s' and EndDateTime = '%s'", whatId1,_startDateTime,_endDateTime];
                        else
                            queryStatement =[NSMutableString stringWithFormat:@"Select Subject From Event where WhatId = '%@'", whatId1];
                    }
                    
                    //12135
                    if (ownerId != nil && [ownerId length] > 0){
                        if((_startDateTime!=nil) && strlen(_startDateTime) && (_endDateTime!=nil) && strlen(_endDateTime))
                            queryStatement =[NSMutableString stringWithFormat:@"Select Subject From Event where WhatId = '%@' and StartDateTime = '%s' and EndDateTime = '%s' and OwnerId = '%@'", whatId1,_startDateTime,_endDateTime, ownerId];
                        else
                            queryStatement =[NSMutableString stringWithFormat:@"Select Subject From Event where WhatId = '%@' OwnerId = '%@'", whatId1, ownerId];
                    }
                    else{
                        if((_startDateTime!=nil) && strlen(_startDateTime) && (_endDateTime!=nil) && strlen(_endDateTime))
                            queryStatement =[NSMutableString stringWithFormat:@"Select Subject From Event where WhatId = '%@' and StartDateTime = '%s' and EndDateTime = '%s'", whatId1,_startDateTime,_endDateTime];
                        else
                            queryStatement =[NSMutableString stringWithFormat:@"Select Subject From Event where WhatId = '%@'", whatId1];
                    }
                    
                    selectStatement = [queryStatement UTF8String];
                    sqlite3_stmt * caseSubject;
                    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &caseSubject, nil) == SQLITE_OK )
                    {
                        while(synchronized_sqlite3_step(caseSubject) == SQLITE_ROW)
                        {
                            char * _subject = (char *) synchronized_sqlite3_column_text(caseSubject,0);
                            
                            if ((_subject != nil) && strlen(_subject))
                            {
                                subject = [NSString stringWithUTF8String:_subject];
                            }
                        }
                        
                    }
                    synchronized_sqlite3_finalize(caseSubject);
                }
                
                //Other
                // Radha and abinash
                else
                {
                    NSString * tableName = [self getTableNameForWhatId:whatId1];
                    
                    NSString * info = @"";
                    sqlite3_stmt * stmt;
                    queryStatement = [NSMutableString stringWithFormat:@"SELECT label from SFObject where api_name = '%@'", tableName];
                    selectStatement = [queryStatement UTF8String];
                    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &stmt, nil) == SQLITE_OK )
                    {
                        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
                        {
                            char * _addInfo = (char *) synchronized_sqlite3_column_text(stmt,0);
                            
                            if ((_addInfo != nil) && strlen(_addInfo))
                                info = [NSString stringWithUTF8String:_addInfo];
                        }
                    }
                    synchronized_sqlite3_finalize(stmt);
                    
                    NSString * name = nil;
                    queryStatement = [NSMutableString stringWithFormat:@"SELECT Name from '%@' WHERE Id = '%@'",tableName,whatId1];
                    selectStatement = [queryStatement UTF8String];
                    
                    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &stmt, nil) == SQLITE_OK )
                    {
                        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
                        {
                            char * _name = (char *) synchronized_sqlite3_column_text(stmt,0);
                            
                            if ((_name != nil) && strlen(_name))
                                name = [NSString stringWithUTF8String:_name];
                        }
                    }
                    
                    synchronized_sqlite3_finalize(stmt);
                    if ([name length]>0)
                    {
                        additonalInfo = [NSString stringWithFormat:@"%@ : %@", info, name];
                    }
                    
                    
                    
                    if ([whatId1 isEqualToString:@""])
                    {
                        if([eventId length] > 0)
                        {
                            subject = [self getNameFieldForEvent:eventId];
                        }
                        else
                        {
                            subject = [self getNameFieldForEventLocal_id:event_local_Id];
                        }
                    }
                    
                    objectApiName = tableName;
                    
                }
                
                NSMutableArray * objects = [[NSMutableArray arrayWithObjects:activityDate,
                                             activityDateTime,durationInMins,
                                             endDateTime,startDateTime,subject,additonalInfo,
                                             whatId,eventId, objectApiName,City,Zip,Street,State,Country,event_local_Id, nil] retain];
                
                NSDictionary * dictionary = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
                NSDictionary * dict = [[NSDictionary alloc ] initWithDictionary:dictionary];
                [resultSet addObject:dict];
                [objects release];
                
                /*Shravya-Calendar view 7408 */
                [dictionary release];
                dictionary = nil;
                [dict release];
                dict = nil;
                /*Shravya-Calendar view 7408 */
                
                ret = synchronized_sqlite3_step(statement);
            }
            synchronized_sqlite3_finalize(statement);
        }
    }@catch (NSException *exp)
    {
        SMLog(kLogLevelError,@"Exception Name CalendarDatabase :GetEventsFromDBWithStartDate %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason CalendarDatabase :GetEventsFromDBWithStartDate %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
    return resultSet;
}


- (void) updateMovedEventWithStartTime:(NSString *)_startDT EndDate:(NSString *)_endDT RecordID:_recordId event_localId:(NSString *)event_LocalId
{
    NSString *sql = @"";
    if([_recordId length] != 0)
    {
        sql = [NSString stringWithFormat: @"Update Event Set StartDateTime = '%@', EndDateTime = '%@', ActivityDateTime = '%@' Where Id = '%@'", _startDT, _endDT,_startDT, _recordId];
    }
    else
    {
        sql = [NSString stringWithFormat: @"Update Event Set StartDateTime = '%@', EndDateTime = '%@', ActivityDateTime = '%@' Where local_id = '%@'", _startDT, _endDT,_startDT, event_LocalId];
    }
    [appDelegate.dataBase beginTransaction];
    char *err;
    if (synchronized_sqlite3_exec(appDelegate.db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"%@", sql);
		SMLog(kLogLevelError,@"METHOD: updateMovedEventWithStartTime" );
		SMLog(kLogLevelError,@"ERROR IN UPDATING %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:sql type:UPDATEQUERY];
    }
    [appDelegate.dataBase endTransaction];
}

//28/Sep/2012
- (BOOL) isWorkOrderOrCase:(NSString *)whatId objectName:(NSString *)_ObjectName
{
	NSString * str = @"";
    if (![whatId isEqualToString:@""])
        str = [whatId substringToIndex:3];
    
    NSString * query = [NSString stringWithFormat:@"SELECT api_name FROM SFObject WHERE key_prefix = '%@'", str];
    
    sqlite3_stmt * stmt;
    NSString * objectName = @"";
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(stmt) ==  SQLITE_ROW)
        {
            char * _api_name = (char *) synchronized_sqlite3_column_text(stmt, 0);
            if ((_api_name != nil) && strlen(_api_name))
                objectName = [NSString stringWithUTF8String:_api_name];
        }
    }
    synchronized_sqlite3_finalize(stmt);
    //8211
    if ([objectName isEqualToString:_ObjectName])
    {
        objectApiName = objectName;
        return YES;
    }
    
    return NO;

}

//8387
- (BOOL) isWorkOrderOrCaseForColorCode:(NSString *)whatId
{
	NSString * str = @"";
    if (![whatId isEqualToString:@""])
        str = [whatId substringToIndex:3];
    
    NSString * query = [NSString stringWithFormat:@"SELECT api_name FROM SFObject WHERE key_prefix = '%@'", str];
    
    sqlite3_stmt * stmt;
    NSString * objectName = @"";
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(stmt) ==  SQLITE_ROW)
        {
            char * _api_name = (char *) synchronized_sqlite3_column_text(stmt, 0);
            if ((_api_name != nil) && strlen(_api_name))
                objectName = [NSString stringWithUTF8String:_api_name];
        }
    }
    synchronized_sqlite3_finalize(stmt);
    if ([objectName isEqualToString:@"Case"] ||[objectName isEqualToString:@"SVMXC__Service_Order__c"] )
    {
        return YES;
    }
    
    return NO;
	
}



- (void)dealloc
{
    [super dealloc];
}


- (NSString *)getColorCodeForPriority:(NSString *)whatId objectname:(NSString *)objectName
{
    BOOL retVal;
    sqlite3_stmt * colorStatement;
    NSString *priority  = @"";
	retVal = [self  isWorkOrderOrCaseForColorCode:whatId]; //8387
    if ( retVal == YES )
    {
        NSMutableString *queryStatement = [[NSMutableString alloc]initWithCapacity:0];
		
		if ([objectName isEqualToString:@"Case"])
			 queryStatement = [NSString stringWithFormat:@"SELECT Priority from '%@' where Id = '%@'", objectName, whatId];
		else
			queryStatement = [NSString stringWithFormat:@"SELECT SVMXC__Priority__c from '%@' where Id = '%@'", objectName, whatId];
        const char * selectStatement = [queryStatement UTF8String];
        if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &colorStatement, nil) == SQLITE_OK )
        {
            while(synchronized_sqlite3_step(colorStatement) == SQLITE_ROW)
            {
                char * _priority = (char *) synchronized_sqlite3_column_text(colorStatement,0);
                
                if ((_priority != nil) && strlen(_priority))
                {
                    priority = [NSString stringWithUTF8String:_priority];
                    
                }
                
            }
        }  
		
        synchronized_sqlite3_finalize(colorStatement);
		
		if ([priority isEqualToString:@"High"])
			return [appDelegate.settingsDict objectForKey:@"IPAD006_SET001"];
		else if ([priority isEqualToString:@"Medium"]) 
			return  [appDelegate.settingsDict objectForKey:@"IPAD006_SET002"];
		else if ([priority isEqualToString:@"Low"]) 
			return [appDelegate.settingsDict objectForKey:@"IPAD006_SET003"];
		else
			return [appDelegate.settingsDict objectForKey:@"IPAD006_SET004"];
    }
	
	return @"";

}


- (NSString *) getPriorityForWhatId:(NSString *)whatId objectname:(NSString *)objectName
{
    BOOL retVal;
    sqlite3_stmt * colorStatement;
    NSString *priority  = @"";
    //retVal = [self isWorkOrder:whatId];
	
	retVal = [self isWorkOrderOrCase:whatId objectName:objectName];
	
    if ( retVal == YES )
    {
        NSMutableString *queryStatement = [[NSMutableString alloc]initWithCapacity:0];
        queryStatement = [NSString stringWithFormat:@"SELECT SVMXC__Priority__c from %@ where Id = '%@'",objectName, whatId];
        const char * selectStatement = [queryStatement UTF8String];
        if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &colorStatement, nil) == SQLITE_OK )
        {
            while(synchronized_sqlite3_step(colorStatement) == SQLITE_ROW)
            {
                char * _priority = (char *) synchronized_sqlite3_column_text(colorStatement,0);
                
                if ((_priority != nil) && strlen(_priority))
                {
                    priority = [NSString stringWithUTF8String:_priority];
                    
                }
                
            }
        }                 
    }
    synchronized_sqlite3_finalize(colorStatement);
    return priority;
}


- (void)deleteTaskFromDB:(NSString *)taskId
{
    NSMutableString *queryStatement = [[NSMutableString alloc]initWithCapacity:0];
    queryStatement = [NSString stringWithFormat:@"Delete from Task where local_id = '%@'", taskId];
    const char * selectStatement = [queryStatement UTF8String];
    char *err;
    
    if (synchronized_sqlite3_exec(appDelegate.db, selectStatement, NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"%@", queryStatement);
		SMLog(kLogLevelError,@"METHOD:deleteTaskFromDB");
		SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:queryStatement type:DELETEQUERY];

    }
    
}
//  Unused methods
//- (NSString *) retreiveCurrentTaskIdCreated
//{
//    NSString *field1Str = @"";
//    sqlite3_stmt * stmt;
//    
//    NSMutableString *queryStatement = [[NSMutableString alloc]initWithCapacity:0];
//    queryStatement = [NSString stringWithFormat:@"Select local_id from Task where local_id = (Select MAX (local_id) From Task)"];
//    const char * selectStatement = [queryStatement UTF8String];
//    
//    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &stmt, nil) == SQLITE_OK )
//    {
//        if(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
//        {
//            char *field1 = (char *) synchronized_sqlite3_column_text(stmt,0);
//            field1Str = [[NSString alloc] initWithUTF8String: field1];
//        }
//        
//    }
//    synchronized_sqlite3_finalize(stmt);
//    return  field1Str;
//}

- (NSString *) getTableNameForWhatId:(NSString *)whatId
{
    NSString * str = @"";
    if (![whatId isEqualToString:@""])
        str = [whatId substringToIndex:3];
    
    NSString * query = [NSString stringWithFormat:@"SELECT api_name FROM SFObject WHERE key_prefix = '%@'", str];
    
    sqlite3_stmt * stmt;
    NSString * objectName = @"";
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(stmt) ==  SQLITE_ROW)
        {
            char * _api_name = (char *) synchronized_sqlite3_column_text(stmt, 0);
            if ((_api_name != nil) && strlen(_api_name))
                objectName = [NSString stringWithUTF8String:_api_name];
        }
    }
    synchronized_sqlite3_finalize(stmt);
    return objectName;
    
}
//  Unused methods
//- (NSString *) getNameFieldForTableName:(NSString *)tableName
//{
//    NSString *fieldStr = @"";
//    sqlite3_stmt * stmt;
//    NSMutableString *queryStatement = [[NSMutableString alloc]initWithCapacity:0];
//    queryStatement = [NSString stringWithFormat:@"Select Name From SFObject where ObjectAPIName = '%@'",tableName];
//    const char * selectStatement = [queryStatement UTF8String];
//    
//    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &stmt, nil) == SQLITE_OK )
//    {
//        if(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
//        {
//            char *field1 = (char *) synchronized_sqlite3_column_text(stmt,0);
//            fieldStr = [[NSString alloc] initWithUTF8String:field1];
//            
//        }
//    }
//    synchronized_sqlite3_finalize(stmt);
//    return  fieldStr;
//    
//    
//    
//}

- (NSString *) getNameFieldForEvent:(NSString *)eventId
{
    NSString * query = [NSString stringWithFormat:@"SELECT subject FROM Event WHERE Id = '%@'", eventId];
    
    sqlite3_stmt * stmt;
    NSString * subject = @"";
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(stmt) ==  SQLITE_ROW)
        {
            char * _subject = (char *) synchronized_sqlite3_column_text(stmt, 0);
            if ((_subject != nil) && strlen(_subject))
                subject = [NSString stringWithUTF8String:_subject];
        }
    }
    synchronized_sqlite3_finalize(stmt);
    return subject;
    
}


- (NSString *) getNameFieldForEventLocal_id:(NSString *)eventId
{
    NSString * query = [NSString stringWithFormat:@"SELECT subject FROM Event WHERE local_id = '%@'", eventId];
    
    sqlite3_stmt * stmt;
    NSString * subject = @"";
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(stmt) ==  SQLITE_ROW)
        {
            char * _subject = (char *) synchronized_sqlite3_column_text(stmt, 0);
            if ((_subject != nil) && strlen(_subject))
                subject = [NSString stringWithUTF8String:_subject];
        }
    }
    synchronized_sqlite3_finalize(stmt);
    return subject;
    
}


//Abinash
#pragma mark - Service Report Methods

-(NSString*)getNameField:(NSString *)SVMXC__Product__c
{
    NSMutableString *queryStatement = [[NSMutableString alloc]initWithCapacity:0];
    NSString * Name1 = @"";
    sqlite3_stmt *statement1;
//    defect 007237
    SVMXC__Product__c=[SVMXC__Product__c stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    queryStatement = [NSString stringWithFormat:@"SELECT Name from Product2 where Id = '%@'", SVMXC__Product__c];
    const  char * selectStatement = [queryStatement UTF8String];
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &statement1, nil) == SQLITE_OK )
    {
        if(synchronized_sqlite3_step(statement1) == SQLITE_ROW)
        {
            char * _name = (char *) synchronized_sqlite3_column_text(statement1,0);
            
            if ((_name != nil) && strlen(_name))
                Name1 = [NSString stringWithUTF8String:_name];
        }
    }
    synchronized_sqlite3_finalize(statement1);
    return Name1;
    
}
//Abinash

//For Expenses
-(NSMutableArray*)queryForExpenses:(NSString *)currentRecordId
{
    NSMutableString *queryStatement = nil;
    Expenses = [[NSMutableArray alloc] initWithCapacity:0];
    sqlite3_stmt *statement1;
    
    
    NSString * sfid =[appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:@"SVMXC__Service_Order__c" local_id:currentRecordId];
    
    if ((sfid != nil) && [sfid length] > 0)
    {
        queryStatement = [NSMutableString stringWithFormat:@"SELECT Id, SVMXC__Expense_Type__c, SVMXC__Actual_Quantity2__c, SVMXC__Actual_Price2__c, SVMXC__Work_Description__c,SVMXC__Billable_Quantity__c, SVMXC__Billable_Line_Price__c FROM SVMXC__Service_Order_Line__c WHERE SVMXC__Line_Type__c = 'Expenses' AND (SVMXC__Service_Order__c = '%@' OR SVMXC__Service_Order__c = '%@')  AND (SVMXC__Is_Billable__c = 'true' or  SVMXC__Is_Billable__c = 'True' or SVMXC__Is_Billable__c = '1') AND RecordTypeId   in   (select  record_type_id  from SFRecordType where record_type = 'Usage/Consumption' )", currentRecordId, sfid];
    }
    else
    {
        queryStatement = [NSMutableString stringWithFormat:@"SELECT Id, SVMXC__Expense_Type__c, SVMXC__Actual_Quantity2__c, SVMXC__Actual_Price2__c, SVMXC__Work_Description__c,SVMXC__Billable_Quantity__c, SVMXC__Billable_Line_Price__c FROM SVMXC__Service_Order_Line__c WHERE SVMXC__Line_Type__c = 'Expenses' AND SVMXC__Service_Order__c = '%@' AND (SVMXC__Is_Billable__c = 'true' or  SVMXC__Is_Billable__c = 'True' or SVMXC__Is_Billable__c = '1') AND RecordTypeId   in   (select  record_type_id  from SFRecordType where record_type = 'Usage/Consumption' )", currentRecordId];
    }
    
    
    const char * _query = [queryStatement UTF8String];
    NSArray * keys = [NSArray arrayWithObjects:
                      _ID,
                      SVMXC__EXPENSE_TYPE__C,
                      SVMXC__ACTUAL_QUANTITY2__C,
                      SVMXC__ACTUAL_PRICE2__C,
                      SVMXC__WORK_DESCRIPTION__C,
                      SVMXC_BILLABLE_QUANTITY,
                      SVMXC_BILLABLE_PRICE,
                      nil];
    @try{
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, _query,-1, &statement1, nil) == SQLITE_OK )
    {
        while(synchronized_sqlite3_step(statement1) == SQLITE_ROW)
        {
            char *_Id = (char *) synchronized_sqlite3_column_text(statement1,0);
            NSString * Id = @"";    
            if ((_Id != nil) && strlen(_Id))
            {         
                Id = [[NSString alloc] initWithUTF8String:_Id];
                
            }
            char *_SVMXC__Expense_Type__c = (char *) synchronized_sqlite3_column_text(statement1,1);
            NSString * SVMXC__Expense_Type__c = @"";
            if ((_SVMXC__Expense_Type__c != nil) && strlen(_SVMXC__Expense_Type__c))
            {         
                SVMXC__Expense_Type__c = [[NSString alloc] initWithUTF8String:_SVMXC__Expense_Type__c];
            }  
            char *_SVMXC__Actual_Quantity2__c = (char *) synchronized_sqlite3_column_text(statement1,2);
            NSString * SVMXC__Actual_Quantity2__c_ = @"";    
            if ((_SVMXC__Actual_Quantity2__c != nil) && strlen(_SVMXC__Actual_Quantity2__c))
            {         
                SVMXC__Actual_Quantity2__c_ = [[NSString alloc] initWithUTF8String:_SVMXC__Actual_Quantity2__c];
            }
            char *_SVMXC__Actual_Price2__c = (char *) synchronized_sqlite3_column_text(statement1,3);
            NSString * SVMXC__Actual_Price2__c_ = @"";    
            if ((_SVMXC__Actual_Price2__c != nil) && strlen(_SVMXC__Actual_Price2__c))
            {         
                SVMXC__Actual_Price2__c_ = [[NSString alloc] initWithUTF8String:_SVMXC__Actual_Price2__c];
            }   
            char *_SVMXC__Work_Description_c = (char *) synchronized_sqlite3_column_text(statement1,4);
            NSString * SVMXC__Work_Description_c = @"";    
            if ((_SVMXC__Work_Description_c != nil) && strlen(_SVMXC__Work_Description_c))
            {         
                SVMXC__Work_Description_c = [[NSString alloc] initWithUTF8String:_SVMXC__Work_Description_c];
            }
            
            
            char *tempValue = (char *) synchronized_sqlite3_column_text(statement1,5);
            NSString * billableQty = @"0.0";
            if ((tempValue != nil) && strlen(tempValue))
            {
                billableQty = [[NSString alloc] initWithUTF8String:tempValue];
                if (billableQty == nil) {
                    billableQty = @"";
                }
            }
            
            
            tempValue = (char *) synchronized_sqlite3_column_text(statement1,6);
            NSString * billablePrice = @"0.0";
            if ((tempValue != nil) && strlen(tempValue))
            {
                billablePrice = [[NSString alloc] initWithUTF8String:tempValue];
                if (billablePrice == nil) {
                    billablePrice = @"0.0";
                }
            }
            
            
            NSMutableArray * objects = [[NSMutableArray arrayWithObjects:Id,SVMXC__Expense_Type__c, SVMXC__Actual_Quantity2__c_,SVMXC__Actual_Price2__c_,SVMXC__Work_Description_c,billableQty,billablePrice,nil] retain];
            
            
            
            NSDictionary * dictionary = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
            [Expenses addObject:dictionary];
            [dictionary release];
            [objects release]; 
            
        }
    } 
    synchronized_sqlite3_finalize(statement1);
    }@catch (NSException *exp)
    {
        SMLog(kLogLevelError,@"Exception Name CalendarDatabase :queryForExpenses %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason CalendarDatabase :queryForExpenses %@",exp.reason);
    }

    return Expenses;
}

//For Parts
- (NSMutableArray *) queryForParts:(NSString *)currentRecordId
{
    NSMutableDictionary * part = nil;
    NSMutableString *queryStatement = nil;
    sqlite3_stmt *statement1;
    NSString * nameField = @"";
    
    Parts = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSString * sfid =[appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:@"SVMXC__Service_Order__c" local_id:currentRecordId];
    
    if ((sfid != nil) && [sfid length] > 0)
    {
        queryStatement = [NSMutableString stringWithFormat:@"SELECT Id, SVMXC__Product__c,SVMXC__Actual_Quantity2__c, SVMXC__Actual_Price2__c, SVMXC__Work_Description__c, SVMXC__Discount__c, Name , SVMXC__Billable_Quantity__c, SVMXC__Billable_Line_Price__c FROM SVMXC__Service_Order_Line__c WHERE SVMXC__Line_Type__c = 'Parts' AND (SVMXC__Service_Order__c = '%@' OR SVMXC__Service_Order__c = '%@')  AND SVMXC__Actual_Quantity2__c > 0 AND SVMXC__Actual_Price2__c >= 0 AND (SVMXC__Is_Billable__c = 'true' or  SVMXC__Is_Billable__c = 'True' or SVMXC__Is_Billable__c = '1') AND RecordTypeId   in   (select  record_type_id  from SFRecordType where record_type = 'Usage/Consumption' )", currentRecordId, sfid];
    }
    else
    {
        queryStatement = [NSMutableString stringWithFormat:@"SELECT Id, SVMXC__Product__c,SVMXC__Actual_Quantity2__c, SVMXC__Actual_Price2__c, SVMXC__Work_Description__c, SVMXC__Discount__c, Name , SVMXC__Billable_Quantity__c, SVMXC__Billable_Line_Price__c FROM SVMXC__Service_Order_Line__c WHERE SVMXC__Line_Type__c = 'Parts' AND SVMXC__Service_Order__c = '%@' AND SVMXC__Actual_Quantity2__c > 0 AND SVMXC__Actual_Price2__c >= 0 AND (SVMXC__Is_Billable__c = 'true' or  SVMXC__Is_Billable__c = 'True' or SVMXC__Is_Billable__c = '1') AND RecordTypeId   in   (select  record_type_id  from SFRecordType where record_type = 'Usage/Consumption' )", currentRecordId];
    }
    
    @try{
    const char * _query = [queryStatement UTF8String];
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, _query,-1, &statement1, nil) == SQLITE_OK )
    {
        
        while(synchronized_sqlite3_step(statement1) == SQLITE_ROW)
        {
            NSMutableArray * keys = [NSMutableArray arrayWithObjects:
                                     _ID,
                                     SVMXC__PRODUCT__C,
                                     SVMXC__PRODUCT2__NAME,
                                     SVMXC__ACTUAL_QUANTITY2__C,
                                     SVMXC__ACTUAL_PRICE2__C,
                                     SVMXC__WORK_DESCRIPTION__C,
                                     SVMXC__DISCOUNT__C,
                                     SVMXC_BILLABLE_QUANTITY,
                                     SVMXC_BILLABLE_PRICE,
                                     nil];
            
            char *_Id = (char *) synchronized_sqlite3_column_text(statement1,0);
            NSString * Id = @"";    
            if ((_Id != nil) && strlen(_Id))
            {         
                Id = [[NSString alloc] initWithUTF8String:_Id];
                
            }
            char *_SVMXC__Product__c = (char *) synchronized_sqlite3_column_text(statement1,1);
            NSString * SVMXC__Product__c = @"";
            if ((_SVMXC__Product__c != nil) && strlen(_SVMXC__Product__c))
            {         
                SVMXC__Product__c = [[NSString alloc] initWithUTF8String:_SVMXC__Product__c];
                nameField = [self getNameField:SVMXC__Product__c];
				
				//Shrinivas   --- Change for service Report  -- 22/06/2012
				if ( [nameField isEqualToString:@""])
				{
					nameField = [self getProductNameFromDbWithID:SVMXC__Product__c];
				}
            } 
			
            char *_SVMXC__Actual_Quantity2__c = (char *) synchronized_sqlite3_column_text(statement1,2);
            NSString * SVMXC__Actual_Quantity2__c_ = @"";    
            if ((_SVMXC__Actual_Quantity2__c != nil) && strlen(_SVMXC__Actual_Quantity2__c))
            {         
                SVMXC__Actual_Quantity2__c_ = [[NSString alloc] initWithUTF8String:_SVMXC__Actual_Quantity2__c];
            }
            char *_SVMXC__Actual_Price2__c = (char *) synchronized_sqlite3_column_text(statement1,3);
            NSString * SVMXC__Actual_Price2__c_ = @"";    
            if ((_SVMXC__Actual_Price2__c != nil) && strlen(_SVMXC__Actual_Price2__c))
            {         
                SVMXC__Actual_Price2__c_ = [[NSString alloc] initWithUTF8String:_SVMXC__Actual_Price2__c];
            }   
            char *_SVMXC__Work_Description_c = (char *) synchronized_sqlite3_column_text(statement1,4);
            NSString * SVMXC__Work_Description_c = @"";    
            if ((_SVMXC__Work_Description_c != nil) && strlen(_SVMXC__Work_Description_c))
            {         
                SVMXC__Work_Description_c = [[NSString alloc] initWithUTF8String:_SVMXC__Work_Description_c];
            }   
            char *_SVMXC__Discount__c = (char *) synchronized_sqlite3_column_text(statement1,5);
            NSString * SVMXC__Discount__c = @"";    
            if ((_SVMXC__Discount__c != nil) && strlen(_SVMXC__Discount__c))
            {         
                SVMXC__Discount__c = [[NSString alloc] initWithUTF8String:_SVMXC__Discount__c];
            } 
            
            
            /* Fetching billable quantitye 6773*/
            char *tempValue = (char *) synchronized_sqlite3_column_text(statement1,7);
            NSString * _SVMXC__Billable_Quantity__c = @"0.0";
            if ((tempValue != nil) && strlen(tempValue))
            {
                _SVMXC__Billable_Quantity__c = [[NSString alloc] initWithUTF8String:tempValue];
                if (_SVMXC__Billable_Quantity__c == nil) {
                    _SVMXC__Billable_Quantity__c = @"0.0";
                }
            }
            
            tempValue = nil;
            tempValue = (char *) synchronized_sqlite3_column_text(statement1,8);
            NSString * _SVMXC__Billable_Line_Price__c = @"0.0";
            if ((tempValue != nil) && strlen(tempValue))
            {
                _SVMXC__Billable_Line_Price__c = [[NSString alloc] initWithUTF8String:tempValue];
                if (_SVMXC__Billable_Line_Price__c == nil) {
                    _SVMXC__Billable_Line_Price__c = @"0.0";
                }
            }
            
            /* End fetching billable quantitye 6773*/
            
            
            NSMutableArray * objects = [[NSMutableArray arrayWithObjects:Id,SVMXC__Product__c,nameField,SVMXC__Actual_Quantity2__c_,SVMXC__Actual_Price2__c_,SVMXC__Work_Description_c,SVMXC__Discount__c,_SVMXC__Billable_Quantity__c,_SVMXC__Billable_Line_Price__c,nil] retain];
            
            NSDictionary * dictionary = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
            
            [objects removeAllObjects];
            [keys removeAllObjects];
            
            
            keys = [NSMutableArray arrayWithObjects:gName,
                    gPartsUsed,
                    KEY_PARTDESCRIPTION,
                    KEY_COSTPERPART,
                    KEY_PRODUCTID,
                    KEY_DISCOUNT,
                    KEY_BILLABLE_QUANTITY,
                    KEY_BILLABLE_PRICE,
                    nil];
            
            
            
            
            NSString * numPartsUsed = [dictionary objectForKey:gSVMXC__Actual_Quantity2__c];
            if ([numPartsUsed isKindOfClass:[NSString class]] && numPartsUsed != nil)
                numPartsUsed = [NSString stringWithFormat:@"%0.2f", [numPartsUsed floatValue]];
            
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
            
            NSString  *keyBillableQty = [dictionary objectForKey:SVMXC_BILLABLE_QUANTITY];
            
            NSString  *keyBillablePrice = [dictionary objectForKey:SVMXC_BILLABLE_PRICE];
            
            
            objects = [NSMutableArray arrayWithObjects:nameField,numPartsUsed,description,costPerPart, keyProduct, discount,keyBillableQty,keyBillablePrice,
                       nil];
            
            
            
            part = [NSMutableDictionary dictionaryWithObjects:objects forKeys:keys];
            [Parts addObject:part];
            [objects removeAllObjects];
            [keys removeAllObjects];
            [dictionary release];            
        }
    } 
    synchronized_sqlite3_finalize(statement1);
    }@catch (NSException *exp)
    {
        SMLog(kLogLevelError,@"Exception Name CalendarDatabase :queryForParts %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason CalendarDatabase :queryForParts %@",exp.reason);
    }

    return Parts;
}

//For Labour
- (NSMutableArray *) queryForLabor:(NSString *)currentRecordId
{ 
    NSMutableDictionary * LabourValuesDictionary = nil;
	
	//RADHA 3214
	NSMutableArray * LaborArray = [[NSMutableArray alloc] initWithCapacity:0];
	
    NSMutableArray * linePriceItems = [[NSMutableArray alloc] initWithCapacity:0];
    
    Labor = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableString *queryStatement = nil;
    sqlite3_stmt *statement1;
    @try{
        
        
        NSString * sfid =[appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:@"SVMXC__Service_Order__c" local_id:currentRecordId];
        
        if ((sfid != nil) && [sfid length] > 0)
        {
            queryStatement = [NSMutableString stringWithFormat:@"SELECT Id, SVMXC__Activity_Type__c, SVMXC__Actual_Quantity2__c, SVMXC__Actual_Price2__c, SVMXC__Work_Description__c,SVMXC__Billable_Quantity__c, SVMXC__Billable_Line_Price__c FROM SVMXC__Service_Order_Line__c WHERE SVMXC__Line_Type__c = 'Labor' AND (SVMXC__Service_Order__c = '%@' OR SVMXC__Service_Order__c = '%@' ) AND  (SVMXC__Is_Billable__c = 'true' or  SVMXC__Is_Billable__c = 'True' or SVMXC__Is_Billable__c = '1') AND RecordTypeId   in   (select  record_type_id  from SFRecordType where record_type = 'Usage/Consumption' )", currentRecordId, sfid];

        }
        else
        {
            queryStatement = [NSMutableString stringWithFormat:@"SELECT Id, SVMXC__Activity_Type__c, SVMXC__Actual_Quantity2__c, SVMXC__Actual_Price2__c, SVMXC__Work_Description__c,SVMXC__Billable_Quantity__c, SVMXC__Billable_Line_Price__c FROM SVMXC__Service_Order_Line__c WHERE SVMXC__Line_Type__c = 'Labor' AND SVMXC__Service_Order__c = '%@' AND  (SVMXC__Is_Billable__c = 'true' or  SVMXC__Is_Billable__c = 'True' or SVMXC__Is_Billable__c = '1') AND RecordTypeId   in   (select  record_type_id  from SFRecordType where record_type = 'Usage/Consumption' )", currentRecordId];
        }
        
       const char * _query = [queryStatement UTF8String];
    NSArray * keys = [NSArray arrayWithObjects:
                      _ID,
                      SVMXC__ACTIVITY_TYPE__C,
                      SVMXC__ACTUAL_QUANTITY2__C,
                      SVMXC__ACTUAL_PRICE2__C,
                      SVMXC__WORK_DESCRIPTION__C,
                      SVMXC_BILLABLE_QUANTITY,
                      SVMXC_BILLABLE_PRICE,
                      nil];
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, _query,-1, &statement1, nil) == SQLITE_OK )
    {
        while(synchronized_sqlite3_step(statement1) == SQLITE_ROW)
        {
			LabourValuesDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
			
            char *_Id = (char *) synchronized_sqlite3_column_text(statement1,0);
            NSString * Id = @"";    
            if ((_Id != nil) && strlen(_Id))
            {         
                Id = [[NSString alloc] initWithUTF8String:_Id];
                
            }
            char *_SVMXC__Activity_Type__c = (char *) synchronized_sqlite3_column_text(statement1,1);
            NSString * SVMXC__Activity_Type__c_ = @"";
            if ((_SVMXC__Activity_Type__c != nil) && strlen(_SVMXC__Activity_Type__c))
            {         
                SVMXC__Activity_Type__c_ = [[NSString alloc] initWithUTF8String:_SVMXC__Activity_Type__c];
            }  
            char *_SVMXC__Actual_Quantity2__c = (char *) synchronized_sqlite3_column_text(statement1,2);
            NSString * SVMXC__Actual_Quantity2__c_ = @"";    
            if ((_SVMXC__Actual_Quantity2__c != nil) && strlen(_SVMXC__Actual_Quantity2__c))
            {         
                SVMXC__Actual_Quantity2__c_ = [[NSString alloc] initWithUTF8String:_SVMXC__Actual_Quantity2__c];
            }
            char *_SVMXC__Actual_Price2__c = (char *) synchronized_sqlite3_column_text(statement1,3);
            NSString * SVMXC__Actual_Price2__c_ = @"";    
            if ((_SVMXC__Actual_Price2__c != nil) && strlen(_SVMXC__Actual_Price2__c))
            {         
                SVMXC__Actual_Price2__c_ = [[NSString alloc] initWithUTF8String:_SVMXC__Actual_Price2__c];
            }   
            char *_SVMXC__Work_Description_c = (char *) synchronized_sqlite3_column_text(statement1,4);
            NSString * SVMXC__Work_Description_c = @"";    
            if ((_SVMXC__Work_Description_c != nil) && strlen(_SVMXC__Work_Description_c))
            {         
                SVMXC__Work_Description_c = [[NSString alloc] initWithUTF8String:_SVMXC__Work_Description_c];
            }
            
            char *tempValue = (char *) synchronized_sqlite3_column_text(statement1,5);
            NSString * billableQty = @"0.0";
            if ((tempValue != nil) && strlen(tempValue))
            {
                billableQty = [[NSString alloc] initWithUTF8String:tempValue];
                if (billableQty == nil) {
                    billableQty = @"0.0";
                }
            }
            
            
            tempValue = (char *) synchronized_sqlite3_column_text(statement1,6);
            NSString * billablePrice = @"0.0";
            if ((tempValue != nil) && strlen(tempValue))
            {
                billablePrice = [[NSString alloc] initWithUTF8String:tempValue];
                if (billablePrice == nil) {
                    billablePrice = @"0.0";
                }
            }
            
            
            
            NSMutableArray * objects = [[NSMutableArray arrayWithObjects:Id,SVMXC__Activity_Type__c_,SVMXC__Actual_Quantity2__c_,SVMXC__Actual_Price2__c_,SVMXC__Work_Description_c,billableQty,billablePrice,nil] retain];
            
            NSDictionary * dictionary = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
            
            [LabourValuesDictionary setValue:@"0" forKey:CALIBRATION];
            [LabourValuesDictionary setValue:@"0" forKey:CLEANUP];
            [LabourValuesDictionary setValue:@"0" forKey:INSTALLATION];
            [LabourValuesDictionary setValue:@"0" forKey:REPAIR];
            [LabourValuesDictionary setValue:@"0" forKey:SERVICE];
            
          
            if ([[dictionary objectForKey:@"SVMXC__Activity_Type__c"] isEqualToString:CALIBRATION])
            {
                [LabourValuesDictionary setValue:[dictionary objectForKey:@"SVMXC__Actual_Price2__c"] forKey:RATE_CALIBRATION];
                [LabourValuesDictionary setValue:[dictionary objectForKey:@"SVMXC__Actual_Quantity2__c"] forKey:QTY_CALIBRATION]
                ;
                
                [LabourValuesDictionary setValue:[dictionary objectForKey:SVMXC_BILLABLE_PRICE ] forKey:BILL_RATE_CALIBRATION];
                [LabourValuesDictionary setValue:[dictionary objectForKey:SVMXC_BILLABLE_QUANTITY] forKey:BILL_QTY_CALIBRATION];
                
            }
            if ([[dictionary objectForKey:@"SVMXC__Activity_Type__c"] isEqualToString:CLEANUP])
            {
                [LabourValuesDictionary setValue:[dictionary objectForKey:@"SVMXC__Actual_Price2__c"] forKey:RATE_CLEANUP];
                [LabourValuesDictionary setValue:[dictionary objectForKey:@"SVMXC__Actual_Quantity2__c"] forKey:QTY_CLEANUP];
                
                [LabourValuesDictionary setValue:[dictionary objectForKey:SVMXC_BILLABLE_PRICE ] forKey:BILL_RATE_CLEANUP];
                [LabourValuesDictionary setValue:[dictionary objectForKey:SVMXC_BILLABLE_QUANTITY] forKey:BILL_QTY_CLEANUP];

                
            }
            if ([[dictionary objectForKey:@"SVMXC__Activity_Type__c"] isEqualToString:INSTALLATION])
            {
                [LabourValuesDictionary setValue:[dictionary objectForKey:@"SVMXC__Actual_Price2__c"] forKey:RATE_INSTALLATION];
                [LabourValuesDictionary setValue:[dictionary  objectForKey:@"SVMXC__Actual_Quantity2__c"] forKey:QTY_INSTALLATION];
                
                [LabourValuesDictionary setValue:[dictionary objectForKey:SVMXC_BILLABLE_PRICE ] forKey:BILL_RATE_INSTALLATION];
                [LabourValuesDictionary setValue:[dictionary objectForKey:SVMXC_BILLABLE_QUANTITY] forKey:BILL_QTY_INSTALLATION];
            }
            if ([[dictionary objectForKey:@"SVMXC__Activity_Type__c"] isEqualToString:REPAIR])
            {
                [LabourValuesDictionary setValue:[dictionary objectForKey:@"SVMXC__Actual_Price2__c"] forKey:RATE_REPAIR];
                [LabourValuesDictionary setValue:[dictionary objectForKey:@"SVMXC__Actual_Quantity2__c"] forKey:QTY_REPAIR];
                
                [LabourValuesDictionary setValue:[dictionary objectForKey:SVMXC_BILLABLE_PRICE ] forKey:BILL_RATE_REPAIR];
                [LabourValuesDictionary setValue:[dictionary objectForKey:SVMXC_BILLABLE_QUANTITY] forKey:BILL_QTY_REPAIR];
            }
            if ([[dictionary objectForKey:@"SVMXC__Activity_Type__c"] isEqualToString:SERVICE])
            {
                [LabourValuesDictionary setValue:[dictionary objectForKey:@"SVMXC__Actual_Price2__c"] forKey:RATE_SERVICE];
                [LabourValuesDictionary setValue:[dictionary objectForKey:@"SVMXC__Actual_Quantity2__c"] forKey:QTY_SERVICE];
                
                [LabourValuesDictionary setValue:[dictionary objectForKey:SVMXC_BILLABLE_PRICE ] forKey:BILL_RATE_SERVICE];
                [LabourValuesDictionary setValue:[dictionary objectForKey:SVMXC_BILLABLE_QUANTITY] forKey:BILL_QTY_SERVICE];
            }
			
			[LaborArray addObject:LabourValuesDictionary];
			
        }
        synchronized_sqlite3_finalize(statement1);
    }
    
    sqlite3_stmt *statement6;
    NSMutableString *queryStatement6 = [[NSMutableString alloc]initWithCapacity:0];
    NSMutableArray * billable_cost_2 = [[NSMutableArray alloc]initWithCapacity:0];
    
    queryStatement6 = [NSMutableString stringWithFormat:@"SELECT SVMXC__Billable_Cost2__c FROM SVMXC__Service_Group_Costs__c  WHERE SVMXC__Group_Member__c = '%@' AND SVMXC__Cost_Category__c = 'Straight'", appDelegate.appTechnicianId];
    const char * _query6 = [queryStatement6 UTF8String];
    NSArray * keys6 = [NSArray arrayWithObjects:
                       SVMXC__BILLABLE_COST2__C,
                       nil];
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, _query6,-1, &statement6, nil) == SQLITE_OK )
    {
        while(synchronized_sqlite3_step(statement6) == SQLITE_ROW)
        {
            char *_SVMXC__Billable_Cost2__c = (char *) synchronized_sqlite3_column_text(statement6,0);
            NSString * SVMXC__Billable_Cost2__c = @"";    
            if ((_SVMXC__Billable_Cost2__c != nil) && strlen(_SVMXC__Billable_Cost2__c))
            {         
                SVMXC__Billable_Cost2__c = [[NSString alloc] initWithUTF8String:_SVMXC__Billable_Cost2__c];
                
            }
            NSMutableArray * objects6 = [[NSMutableArray arrayWithObjects:SVMXC__Billable_Cost2__c,nil] retain];
            
            NSDictionary * dictionary6 = [[NSDictionary alloc] initWithObjects:objects6 forKeys:keys6];
            [billable_cost_2 addObject:dictionary6];
            [dictionary6 release];
            [objects6 release]; 
            
        }
    } 
    synchronized_sqlite3_finalize(statement6);
        
    NSMutableArray * array = billable_cost_2;
    NSMutableArray * billable_cost = [[NSMutableArray alloc]initWithCapacity:0];
    
    if ((array == nil) || ([array count] == 0))
        groupCostsPresent = NO;
    else
        groupCostsPresent = YES;
    
    if( array != nil && ![array count] )
	{
        sqlite3_stmt *statement7;
        NSMutableString *queryStatement7 = [[NSMutableString alloc]initWithCapacity:0];
        
        queryStatement7 = [NSMutableString stringWithFormat:@"SELECT SVMXC__Billable_Cost2__c FROM SVMXC__Service_Group_Costs__c WHERE SVMXC__Service_Group__c = '%@' AND SVMXC__Cost_Category__c = 'Straight'", appDelegate.appServiceTeamId];
        const char * _query7 = [queryStatement7 UTF8String];
        NSArray * keys7 = [NSArray arrayWithObjects:
                           SVMXC__BILLABLE_COST2__C,
                           nil];
        if ( synchronized_sqlite3_prepare_v2(appDelegate.db, _query7,-1, &statement7, nil) == SQLITE_OK )
        {
            while(synchronized_sqlite3_step(statement7) == SQLITE_ROW)
            {
                char *_SVMXC__Billable_Cost2__c = (char *) synchronized_sqlite3_column_text(statement7,0);
                NSString * SVMXC__Billable_Cost2__c = @"";    
                if ((_SVMXC__Billable_Cost2__c != nil) && strlen(_SVMXC__Billable_Cost2__c))
                {         
                    SVMXC__Billable_Cost2__c = [[NSString alloc] initWithUTF8String:_SVMXC__Billable_Cost2__c];
                    
                }
                NSMutableArray * objects7 = [[NSMutableArray arrayWithObjects:SVMXC__Billable_Cost2__c,nil] retain];
                
                NSDictionary * dictionary7 = [[NSDictionary alloc] initWithObjects:objects7 forKeys:keys7];
                [billable_cost addObject:dictionary7];
                [dictionary7 release];
                [objects7 release]; 
                
            }
        }
        synchronized_sqlite3_finalize(statement7);
        NSMutableArray * array = billable_cost;
        
        if ((array == nil) || ([array count] == 0))
            groupCostsPresent = NO;
        else
            groupCostsPresent = YES;
        
        for (int i = 0; i < [array count]; i++)
        {
            NSMutableDictionary * obj8 = [array objectAtIndex:i];
            
            // Check the query. use dictionary value extraction technique, for e.g.
            rate = [[obj8 objectForKey:@"SVMXC__Billable_Cost2__c"] retain];
            if (rate == nil || [rate isKindOfClass:[NSNull class]])
                rate = @"0.0";
        }
        
        if ([appDelegate.timeAndMaterial count] > 0)
            settingsPresent = YES;
        else
            settingsPresent = NO;
		
		for (int count = 0; count < [LaborArray count]; count++)
		{
			NSMutableDictionary * LabourValuesDictionary = (NSMutableDictionary *) [LaborArray objectAtIndex:count];
			
			NSArray *keys = [LabourValuesDictionary allKeys];
			if (settingsPresent)
			{
				if (groupCostsPresent)
				{
					if (calculateLaborPrice)
					{
						for( int i = 0; i < [keys count]; i++ )
						{
							NSRange range = [(NSString *)[keys objectAtIndex:i] rangeOfString:@"Rate_"];
							if( !NSEqualRanges(range, NSMakeRange(NSNotFound, 0)) )
							{
								BOOL _flag = NO;
								for (int j = 0; j < [linePriceItems count]; j++)
								{
									NSString * str = [NSString stringWithFormat:@"Rate_%@", [linePriceItems objectAtIndex:j]];
									if ([[keys objectAtIndex:i] isEqualToString:str])
									{
										_flag = YES;
										break;
									}
								}
								if (!_flag)
									[LabourValuesDictionary setValue:rate forKey:[keys objectAtIndex:i]];
							}
						}
					}
				}
			}
			else
			{
				if (groupCostsPresent)
				{
					for( int i = 0; i < [keys count]; i++ )
					{
						NSRange range = [(NSString *)[keys objectAtIndex:i] rangeOfString:@"Rate_"];
						if( !NSEqualRanges(range, NSMakeRange(NSNotFound, 0)) )
						{
							// Overwrite only if Rate value = 0
							float _rate = [[LabourValuesDictionary objectForKey:[keys objectAtIndex:i]] floatValue];
							if (_rate == 0.0 && calculateLaborPrice)
								[LabourValuesDictionary setValue:rate forKey:[keys objectAtIndex:i]];
						}
					}
					
				}
			}
		}
	}
	else
	{
        NSMutableDictionary * obj7 = [array objectAtIndex:0];
        rate = [[obj7 objectForKey:@"SVMXC__Billable_Cost2__c"] retain];
		
		if (rate == nil || [rate isKindOfClass:[NSNull class]])
			rate = @"0.0";
        
		for (int count = 0; count < [LaborArray count]; count++)
		{
			NSMutableDictionary * LabourValuesDictionary = (NSMutableDictionary *) [LaborArray objectAtIndex:count];
			
			NSArray *keys = [LabourValuesDictionary allKeys];
			for( int i = 0; i < [keys count]; i++ )
			{
				NSRange range = [(NSString *)[keys objectAtIndex:i] rangeOfString:@"Rate_"];
				if( !NSEqualRanges(range, NSMakeRange(NSNotFound, 0)) )
				{
					if (calculateLaborPrice)
						if ([[LabourValuesDictionary valueForKey:[keys objectAtIndex:i]] isEqualToString:@"0.0"])
							[LabourValuesDictionary setValue:rate forKey:[keys objectAtIndex:i]];
				}
			}

		}
		
		      
    }
    SMLog(kLogLevelVerbose,@"%@",LaborArray);
	}@catch (NSException *exp) {
	SMLog(kLogLevelError,@"Exception Name CalendarDatabase :queryForParts %@",exp.name);
	SMLog(kLogLevelError,@"Exception Reason CalendarDatabase :queryForParts %@",exp.reason);
	[appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
    return LaborArray;
}

- (NSMutableArray *) queryForTravel:(NSString *)currentRecordId
{
    
    NSMutableString *queryStatement = nil;
    sqlite3_stmt *statement;    
    
    NSMutableArray *travel = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    NSString * sfid =[appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:@"SVMXC__Service_Order__c" local_id:currentRecordId];
    
    if ((sfid != nil) && [sfid length] > 0)
    {
        queryStatement = [NSMutableString stringWithFormat:@"SELECT Id, SVMXC__Actual_Quantity2__c, SVMXC__Actual_Price2__c, SVMXC__Work_Description__c, SVMXC__Billable_Quantity__c, SVMXC__Billable_Line_Price__c FROM SVMXC__Service_Order_Line__c WHERE SVMXC__Line_Type__c = 'Travel' AND (SVMXC__Service_Order__c = '%@' OR SVMXC__Service_Order__c = '%@' )AND (SVMXC__Is_Billable__c = 'true' or  SVMXC__Is_Billable__c = 'True' or SVMXC__Is_Billable__c = '1') AND RecordTypeId   in   (select  record_type_id  from SFRecordType where record_type = 'Usage/Consumption' )", currentRecordId, sfid];
    }
    else
    {
       queryStatement = [NSMutableString stringWithFormat:@"SELECT Id, SVMXC__Actual_Quantity2__c, SVMXC__Actual_Price2__c, SVMXC__Work_Description__c, SVMXC__Billable_Quantity__c, SVMXC__Billable_Line_Price__c FROM SVMXC__Service_Order_Line__c WHERE SVMXC__Line_Type__c = 'Travel' AND SVMXC__Service_Order__c = '%@' AND (SVMXC__Is_Billable__c = 'true' or  SVMXC__Is_Billable__c = 'True' or SVMXC__Is_Billable__c = '1') AND RecordTypeId   in   (select  record_type_id  from SFRecordType where record_type = 'Usage/Consumption' )", currentRecordId];
    }
    
    
    @try{
        const char * _query = [queryStatement UTF8String];
        if ( synchronized_sqlite3_prepare_v2(appDelegate.db, _query,-1, &statement, nil) == SQLITE_OK )
        {
            while(synchronized_sqlite3_step(statement) == SQLITE_ROW)
            {
                NSMutableArray * keys = [NSMutableArray arrayWithObjects:
                                         _ID,
                                         SVMXC__ACTUAL_QUANTITY2__C,
                                         SVMXC__ACTUAL_PRICE2__C,
                                         SVMXC__WORK_DESCRIPTION__C,
                                         SVMXC_BILLABLE_QUANTITY,
                                         SVMXC_BILLABLE_PRICE,nil];
                
                NSMutableDictionary *travelDict = [[[NSMutableDictionary alloc] init] autorelease];
                
                char *_Id = (char *) synchronized_sqlite3_column_text(statement,0);
                NSString * Id = @"";
                if ((_Id != nil) && strlen(_Id))
                {
                    Id = [[NSString alloc] initWithUTF8String:_Id];
                    if (Id == nil) {
                        Id = @"";
                        
                    }
                    [travelDict setObject:Id forKey:_ID];
                }
                
                
                char *_SVMXC__Actual_Quantity2__c = (char *) synchronized_sqlite3_column_text(statement,1);
                NSString * SVMXC__Actual_Quantity2__c_ = @"";
                if ((_SVMXC__Actual_Quantity2__c != nil) && strlen(_SVMXC__Actual_Quantity2__c))
                {
                    SVMXC__Actual_Quantity2__c_ = [[[NSString alloc] initWithUTF8String:_SVMXC__Actual_Quantity2__c] autorelease];
                    if (SVMXC__Actual_Quantity2__c_ == nil) {
                        SVMXC__Actual_Quantity2__c_ = @"0.0";
                    }
                }
                
                char *_SVMXC__Actual_Price2__c = (char *) synchronized_sqlite3_column_text(statement,2);
                NSString * SVMXC__Actual_Price2__c_ = @"";
                if ((_SVMXC__Actual_Price2__c != nil) && strlen(_SVMXC__Actual_Price2__c))
                {
                    SVMXC__Actual_Price2__c_ = [[[NSString alloc] initWithUTF8String:_SVMXC__Actual_Price2__c] autorelease];
                    if (SVMXC__Actual_Price2__c_ == nil) {
                        SVMXC__Actual_Price2__c_ = @"0.0";
                    }
                }
                char *_SVMXC__Work_Description_c = (char *) synchronized_sqlite3_column_text(statement,3);
                NSString * SVMXC__Work_Description_c = @"";
                if ((_SVMXC__Work_Description_c != nil) && strlen(_SVMXC__Work_Description_c))
                {
                    SVMXC__Work_Description_c = [[[NSString alloc] initWithUTF8String:_SVMXC__Work_Description_c] autorelease];
                    if (SVMXC__Work_Description_c == nil) {
                        SVMXC__Work_Description_c = @"";
                    }
                }
                
                char *_SVMXC__Billable_Quantity__c = (char *) synchronized_sqlite3_column_text(statement,4);
                NSString * billableQty = @"0.0";
                if ((_SVMXC__Billable_Quantity__c != nil) && strlen(_SVMXC__Billable_Quantity__c))
                {
                    billableQty = [[[NSString alloc] initWithUTF8String:_SVMXC__Billable_Quantity__c] autorelease];
                    if (billableQty == nil) {
                        billableQty = @"0.0";
                    }
                }
                
                
                char *_SVMXC__billable_line_price__c = (char *) synchronized_sqlite3_column_text(statement,5);
                NSString *billableLinePrice = @"0.0";
                if ((_SVMXC__billable_line_price__c != nil) && strlen(_SVMXC__billable_line_price__c))
                {
                    billableLinePrice = [[[NSString alloc] initWithUTF8String:_SVMXC__billable_line_price__c] autorelease];
                    if (billableLinePrice == nil) {
                        billableLinePrice = @"0.0";
                    }
                }
                
                
                NSMutableArray * objects = [NSMutableArray arrayWithObjects:Id,SVMXC__Actual_Quantity2__c_,SVMXC__Actual_Price2__c_,SVMXC__Work_Description_c,billableQty,billableLinePrice,nil];
                
                NSDictionary * dictionary = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
                [travel addObject:dictionary];
                [dictionary release];
                dictionary = nil;
                
            }
        }
        synchronized_sqlite3_finalize(statement);
    }@catch (NSException *exp)
    {
        SMLog(kLogLevelError,@"Exception Name CalendarDatabase :queryForTravel %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason CalendarDatabase :queryForTravel %@",exp.reason);
    }
    
    return travel;
}

// Vipin-memopt 15-1 9493
#pragma mark - Summary
- (void) startQueryConfiguration
{
    @autoreleasepool
    {
        
        sqlite3_stmt *statement2;
        NSMutableString *queryStatement2 = nil;
        
        NSMutableArray *SubModuleInfoArray = [[NSMutableArray alloc]initWithCapacity:0];
        
        queryStatement2 = [NSMutableString stringWithFormat:@"SELECT Id, SVMXC__SubmoduleID__c, SVMXC__SettingID__c, SVMXC__Setting_Unique_ID__c, SVMXC__Settings_Name__c, SVMXC__Data_Type__c, SVMXC__Values__c, SVMXC__Default_Value__c, SVMXC__Setting_Type__c, SVMXC__Search_Order__c, SVMXC__IsPrivate__c, SVMXC__Active__c, SVMXC__Description__c, SVMXC__IsStandard__c, SVMXC__Submodule__c FROM SettingsInfo"];
        
        SMLog(kLogLevelVerbose,@"%@", queryStatement2);
        
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
        
        @try{
            
            if ( synchronized_sqlite3_prepare_v2(appDelegate.db, _query2,-1, &statement2, nil) == SQLITE_OK )
            {
                while(synchronized_sqlite3_step(statement2) == SQLITE_ROW)
                {
                    char *_Id = (char *) synchronized_sqlite3_column_text(statement2,0);
                    NSString * Id = [[NSString alloc] initWithString:kEmptyString];
                    if ((_Id != nil) && strlen(_Id))
                    {
                        [Id release];
                        Id = [[NSString alloc] initWithUTF8String:_Id];
                    }
                    
                    char *_SVMXC__SubmoduleID__c = (char *) synchronized_sqlite3_column_text(statement2,1);
                    NSString * SVMXC__SubmoduleID__c = [[NSString alloc] initWithString:kEmptyString];
                    if ((_SVMXC__SubmoduleID__c != nil) && strlen(_SVMXC__SubmoduleID__c))
                    {
                        [SVMXC__SubmoduleID__c release];
                        SVMXC__SubmoduleID__c = [[NSString alloc] initWithUTF8String:_SVMXC__SubmoduleID__c];
                    }
                    
                    char *_SVMXC__SettingID__c = (char *) synchronized_sqlite3_column_text(statement2,2);
                    NSString * SVMXC__SettingID__c = [[NSString alloc] initWithString:kEmptyString];
                    if ((_SVMXC__SettingID__c != nil) && strlen(_SVMXC__SettingID__c))
                    {
                        [SVMXC__SettingID__c release];
                        SVMXC__SettingID__c = [[NSString alloc] initWithUTF8String:_SVMXC__SettingID__c];
                    }
                    
                    char *_SVMXC__Setting_Unique_ID = (char *) synchronized_sqlite3_column_text(statement2,3);
                    NSString * SVMXC__Setting_Unique_ID = [[NSString alloc] initWithString:kEmptyString];
                    if ((_SVMXC__Setting_Unique_ID != nil) && strlen(_SVMXC__Setting_Unique_ID))
                    {
                        [SVMXC__Setting_Unique_ID release];
                        SVMXC__Setting_Unique_ID = [[NSString alloc] initWithUTF8String:_SVMXC__Setting_Unique_ID];
                    }
                    
                    char *_SVMXC__Settings_Name__c = (char *) synchronized_sqlite3_column_text(statement2,4);
                    NSString * SVMXC__Settings_Name__c = [[NSString alloc] initWithString:kEmptyString];
                    if ((_SVMXC__Settings_Name__c != nil) && strlen(_SVMXC__Settings_Name__c))
                    {
                        [SVMXC__Settings_Name__c release];
                        SVMXC__Settings_Name__c = [[NSString alloc] initWithUTF8String:_SVMXC__Settings_Name__c];
                    }
                    
                    char *_SVMXC__Data_Type__c = (char *) synchronized_sqlite3_column_text(statement2,5);
                    NSString * SVMXC__Data_Type__c = [[NSString alloc] initWithString:kEmptyString];
                    if ((_SVMXC__Data_Type__c != nil) && strlen(_SVMXC__Data_Type__c))
                    {
                        SVMXC__Data_Type__c = [[NSString alloc] initWithUTF8String:_SVMXC__Data_Type__c];
                    }
                    
                    char *_SVMXC__Values__c = (char *) synchronized_sqlite3_column_text(statement2,6);
                    NSString * SVMXC__Values__c = [[NSString alloc] initWithString:kEmptyString];
                    if ((_SVMXC__Values__c != nil) && strlen(_SVMXC__Values__c))
                    {
                        [SVMXC__Values__c release];
                        SVMXC__Values__c = [[NSString alloc] initWithUTF8String:_SVMXC__Values__c];
                    }
                    
                    char *_SVMXC__Default_Value__c = (char *) synchronized_sqlite3_column_text(statement2,7);
                    NSString * SVMXC__Default_Value__c = [[NSString alloc] initWithString:kEmptyString];
                    if ((_SVMXC__Default_Value__c != nil) && strlen(_SVMXC__Default_Value__c))
                    {
                        [SVMXC__Default_Value__c release];
                        SVMXC__Default_Value__c = [[NSString alloc] initWithUTF8String:_SVMXC__Default_Value__c];
                    }
                    
                    char *_SVMXC__Setting_Type__c = (char *) synchronized_sqlite3_column_text(statement2,8);
                    NSString * SVMXC__Setting_Type__c = [[NSString alloc] initWithString:kEmptyString];
                    if ((_SVMXC__Setting_Type__c != nil) && strlen(_SVMXC__Setting_Type__c))
                    {
                        [SVMXC__Setting_Type__c release];
                        SVMXC__Setting_Type__c = [[NSString alloc] initWithUTF8String:_SVMXC__Setting_Type__c];
                    }
                    
                    char *_SVMXC__Search_Order__c = (char *) synchronized_sqlite3_column_text(statement2,9);
                    NSString * SVMXC__Search_Order__c = [[NSString alloc] initWithString:kEmptyString];
                    if ((_SVMXC__Search_Order__c != nil) && strlen(_SVMXC__Search_Order__c))
                    {
                        [SVMXC__Search_Order__c release];
                        SVMXC__Search_Order__c = [[NSString alloc] initWithUTF8String:_SVMXC__Search_Order__c];
                    }
                    
                    char *_SVMXC__IsPrivate__c = (char *) synchronized_sqlite3_column_text(statement2,10);
                    NSString * SVMXC__IsPrivate__c = [[NSString alloc] initWithString:kEmptyString];
                    if ((_SVMXC__IsPrivate__c != nil) && strlen(_SVMXC__IsPrivate__c))
                    {
                        [SVMXC__IsPrivate__c release];
                        SVMXC__IsPrivate__c = [[NSString alloc] initWithUTF8String:_SVMXC__IsPrivate__c];
                    }
                    
                    char *_SVMXC__Active__c = (char *) synchronized_sqlite3_column_text(statement2,11);
                    NSString * SVMXC__Active__c = [[NSString alloc] initWithString:kEmptyString];
                    if ((_SVMXC__Active__c != nil) && strlen(_SVMXC__Active__c))
                    {
                        [SVMXC__Active__c release];
                        SVMXC__Active__c = [[NSString alloc] initWithUTF8String:_SVMXC__Active__c];
                    }
                    
                    char *_SVMXC__Description__c = (char *) synchronized_sqlite3_column_text(statement2,12);
                    NSString * SVMXC__Description__c = [[NSString alloc] initWithString:kEmptyString];
                    if ((_SVMXC__Description__c != nil) && strlen(_SVMXC__Description__c))
                    {
                        [SVMXC__Description__c release];
                        SVMXC__Description__c = [[NSString alloc] initWithUTF8String:_SVMXC__Description__c];
                    }
                    
                    char *_SVMXC__IsStandard__c = (char *) synchronized_sqlite3_column_text(statement2,13);
                    NSString * SVMXC__IsStandard__c = [[NSString alloc] initWithString:kEmptyString];
                    if ((_SVMXC__IsStandard__c != nil) && strlen(_SVMXC__IsStandard__c))
                    {
                        [SVMXC__IsStandard__c release];
                        SVMXC__IsStandard__c = [[NSString alloc] initWithUTF8String:_SVMXC__IsStandard__c];
                    }
                    
                    char *_SVMXC__Submodule__c = (char *) synchronized_sqlite3_column_text(statement2,14);
                    NSString * SVMXC__Submodule__c = [[NSString alloc] initWithString:kEmptyString];
                    if ((_SVMXC__Submodule__c != nil) && strlen(_SVMXC__Submodule__c))
                    {
                        [SVMXC__Submodule__c release];
                        SVMXC__Submodule__c = [[NSString alloc] initWithUTF8String:_SVMXC__Submodule__c];
                    }
                    
                    NSMutableArray * objects2 = [[NSMutableArray arrayWithObjects:Id,SVMXC__SubmoduleID__c,SVMXC__SettingID__c,SVMXC__Setting_Unique_ID,SVMXC__Settings_Name__c,SVMXC__Data_Type__c,SVMXC__Values__c,SVMXC__Default_Value__c,SVMXC__Setting_Type__c,SVMXC__Search_Order__c,SVMXC__IsPrivate__c,SVMXC__Active__c,SVMXC__Description__c,SVMXC__IsStandard__c,SVMXC__Submodule__c,nil] retain];
                    
                    
                    
                    NSDictionary * dictionary2 = [[NSDictionary alloc] initWithObjects:objects2 forKeys:keys2];
                    [SubModuleInfoArray addObject:dictionary2];
                    [dictionary2 release];
                    [objects2 release];
                    
                    // Vipin-memopt 15-1 9493
                    [Id release];
                    [SVMXC__SubmoduleID__c release];
                    [SVMXC__SettingID__c release];
                    
                    [SVMXC__Setting_Unique_ID release];
                    [SVMXC__Settings_Name__c release];
                    [SVMXC__Data_Type__c release];
                    [SVMXC__Values__c release];
                    
                    [SVMXC__Default_Value__c release];
                    [SVMXC__Setting_Type__c release];
                    [SVMXC__Search_Order__c release];
                    [SVMXC__IsPrivate__c release];
                    
                    [SVMXC__Active__c release];
                    [SVMXC__Description__c release];
                    [SVMXC__IsStandard__c release];
                    [SVMXC__Submodule__c release];
                }
            }
            synchronized_sqlite3_finalize(statement2);
            
            if ([SubModuleInfoArray count] > 0)
            {
                // Vipin-memopt 15-1 9493
                if (settingInfoId != nil)
                {
                    [settingInfoId release];
                }
                
                if (settingsInfoArray != nil)
                {
                    [settingsInfoArray release];
                }
                
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
            }
            
            sqlite3_stmt *statement4;
            //NSMutableString *queryStatement4 = [[NSMutableString alloc]initWithCapacity:0];
            NSMutableArray * GetSettingsValueArray = [[NSMutableArray alloc]initWithCapacity:0];
            
            
            //queryStatement4 = [NSMutableString stringWithFormat:@"Select Id, SVMXC__Setting_Configuration_Profile__c, SVMXC__Setting_ID__c, SVMXC__Internal_Value__c, SVMXC__Display_Value__c, SVMXC__Active__c, SVMXC__IsDefault__c FROM SettingsValue"];
            NSMutableString *queryStatement4  = [[NSMutableString alloc] initWithFormat:@"Select Id, SVMXC__Setting_Configuration_Profile__c, SVMXC__Setting_ID__c, SVMXC__Internal_Value__c, SVMXC__Display_Value__c, SVMXC__Active__c, SVMXC__IsDefault__c FROM SettingsValue"];
            
           
            SMLog(kLogLevelVerbose,@"%@", queryStatement4);
            
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
            if ( synchronized_sqlite3_prepare_v2(appDelegate.db, _query4,-1, &statement4, nil) == SQLITE_OK )
            {
                while(synchronized_sqlite3_step(statement4) == SQLITE_ROW)
                {
                    char *_Id = (char *) synchronized_sqlite3_column_text(statement4,0);
                    NSString * Id = [[NSString alloc] initWithString:kEmptyString];;
                    if ((_Id != nil) && strlen(_Id))
                    {
                        [Id release];
                        Id = [[NSString alloc] initWithUTF8String:_Id];
                    }
                    
                    char *_SVMXC__Setting_Configuration_Profile__c = (char *) synchronized_sqlite3_column_text(statement4,1);
                    NSString * SVMXC__Setting_Configuration_Profile__c = [[NSString alloc] initWithString:kEmptyString];
                    if ((_SVMXC__Setting_Configuration_Profile__c != nil) && strlen(_SVMXC__Setting_Configuration_Profile__c))
                    {
                        [SVMXC__Setting_Configuration_Profile__c release];
                        SVMXC__Setting_Configuration_Profile__c = [[NSString alloc] initWithUTF8String:_SVMXC__Setting_Configuration_Profile__c];
                    }
                    char *_SVMXC__Setting_ID__c = (char *) synchronized_sqlite3_column_text(statement4,2);
                    NSString * SVMXC__Setting_ID__c = [[NSString alloc] initWithString:kEmptyString];
                    if ((_SVMXC__Setting_ID__c != nil) && strlen(_SVMXC__Setting_ID__c))
                    {
                        [SVMXC__Setting_ID__c release];
                        SVMXC__Setting_ID__c = [[NSString alloc] initWithUTF8String:_SVMXC__Setting_ID__c];
                    }
                    char *_SVMXC__Internal_Value__c = (char *) synchronized_sqlite3_column_text(statement4,3);
                    NSString * SVMXC__Internal_Value__c = [[NSString alloc] initWithString:kEmptyString];
                    if ((_SVMXC__Internal_Value__c!= nil) && strlen(_SVMXC__Internal_Value__c))
                    {
                        [SVMXC__Internal_Value__c release];
                        SVMXC__Internal_Value__c = [[NSString alloc] initWithUTF8String:_SVMXC__Internal_Value__c];
                    }
                    char *_SVMXC__Display_Value__c = (char *) synchronized_sqlite3_column_text(statement4,4);
                    NSString * SVMXC__Display_Value__c = [[NSString alloc] initWithString:kEmptyString];
                    if ((_SVMXC__Display_Value__c != nil) && strlen(_SVMXC__Display_Value__c))
                    {
                        [SVMXC__Display_Value__c release];
                        SVMXC__Display_Value__c = [[NSString alloc] initWithUTF8String:_SVMXC__Display_Value__c];
                    }
                    char *_SVMXC__Active__c = (char *) synchronized_sqlite3_column_text(statement4,5);
                    NSString * SVMXC__Active__c = [[NSString alloc] initWithString:kEmptyString];
                    if ((_SVMXC__Active__c != nil) && strlen(_SVMXC__Active__c))
                    {
                        [SVMXC__Active__c release];
                        SVMXC__Active__c = [[NSString alloc] initWithUTF8String:_SVMXC__Active__c];
                    }
                    char *_SVMXC__IsDefault__c = (char *) synchronized_sqlite3_column_text(statement4,6);
                    NSString * SVMXC__IsDefault__c = [[NSString alloc] initWithString:kEmptyString];
                    if ((_SVMXC__IsDefault__c != nil) && strlen(_SVMXC__IsDefault__c))
                    {
                        [SVMXC__IsDefault__c release];
                        SVMXC__IsDefault__c = [[NSString alloc] initWithUTF8String:_SVMXC__IsDefault__c];
                    }
                    NSMutableArray * objects4 = [[NSMutableArray arrayWithObjects:Id,SVMXC__Setting_Configuration_Profile__c,SVMXC__Setting_ID__c,SVMXC__Internal_Value__c,SVMXC__Display_Value__c,SVMXC__Active__c,SVMXC__IsDefault__c,nil] retain];
                    
                    NSDictionary * dictionary4 = [[NSDictionary alloc] initWithObjects:objects4 forKeys:keys4];
                    [GetSettingsValueArray addObject:dictionary4];
                    [dictionary4 release];
                    [objects4 release];
                    
                    // Vipin-memopt 15-1 9493
                    [SVMXC__IsDefault__c release];
                    [SVMXC__Active__c release];
                    [SVMXC__Display_Value__c release];
                    [SVMXC__Internal_Value__c release];
                    [SVMXC__Setting_ID__c release];
                    [SVMXC__Setting_Configuration_Profile__c release];
                    [Id release];
                }
                synchronized_sqlite3_finalize(statement4);
            }
            
            // Vipin-memopt 15-1 9493
            [queryStatement4 release];
            [SubModuleInfoArray release];
            
            if ([GetSettingsValueArray count] > 0)
            {
                
                appDelegate.workOrderData = [[NSMutableArray alloc] initWithCapacity:0];
                appDelegate.workOrderUpdateData = [[NSMutableArray alloc] initWithCapacity:0];
                appDelegate.timeAndMaterial = [[NSMutableArray alloc] initWithCapacity:0];
                appDelegate.serviceReport = [[NSMutableDictionary alloc] initWithCapacity:0];
                appDelegate.addressType = [[NSMutableString alloc] initWithCapacity:0];
                
                // Vipin-memopt 15-1 9493
                if (settingsValueArray != nil)
                {
                    [settingsValueArray release];
                }
                
                settingsValueArray = [[NSMutableArray alloc] initWithCapacity:0];
                
                for (int i = 0; i < [GetSettingsValueArray count]; i++)
                {
                    NSMutableDictionary * obj6 = [GetSettingsValueArray objectAtIndex:i];
                    [settingsValueArray addObject:obj6];
                    
                    // settingsValueArray
                    if (appDelegate.serviceReportValueMapping == nil)
                    {
                        appDelegate.serviceReportValueMapping = [[NSMutableArray alloc] initWithCapacity:0];
                        SMLog(kLogLevelVerbose,@"%@",appDelegate.serviceReportValueMapping);
                    }
                    else
                    {
                        NSDictionary * dict = [NSDictionary dictionaryWithObject:[obj6 objectForKey:@"SVMXC__Internal_Value__c"] forKey:[obj6 objectForKey:@"SVMXC__Display_Value__c"]];
                        [appDelegate.serviceReportValueMapping addObject:dict];
                        SMLog(kLogLevelVerbose,@"%@",appDelegate.serviceReportValueMapping);
                        
                    }
                }
                
                
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
                            
                            if (appDelegate.serviceReportReference == nil)
                                appDelegate.serviceReportReference = [[NSMutableDictionary alloc] initWithCapacity:0];
                            
                            if ([[[settingsInfoArray objectAtIndex:i] objectForKey:@"SVMXC__Setting_Unique_ID__c"] Contains:@"IPAD004"])
                            {
                                NSString * subModuleSettingKey = [[settingsInfoArray objectAtIndex:i] objectForKey:@"SVMXC__Setting_Unique_ID__c"];
                                
                                NSString * keyNumVal = [subModuleSettingKey stringByReplacingOccurrencesOfString:@"IPAD004_SET" withString:@""];
                                
                                NSInteger intNumVal = [keyNumVal intValue];
                                SMLog(kLogLevelVerbose,@"%@",keyNumVal);
                                
                                //Fix for 5152.Change for Signature Capture. Shrinivas  --> 14/08/2012
                                if (intNumVal == 23)
                                {
                                    appDelegate.signatureCaptureUpload = [[[settingsValueArray objectAtIndex:j] objectForKey:@"SVMXC__Internal_Value__c"] boolValue];
                                }
                                if (intNumVal >= 11 && intNumVal <= 20)
                                {
                                    NSString * queryField = [[settingsValueArray objectAtIndex:j] objectForKey:@"SVMXC__Internal_Value__c"];
                                    SMLog(kLogLevelVerbose,@"QUERY FIELD %@", queryField);
                                    if ([queryField isKindOfClass:[NSNull class]] || [queryField isEqualToString:@""])
                                        continue;
                                    NSArray * arr = [queryField componentsSeparatedByString:@"."];
                                    
                                    if ([arr count] >= 2)
                                    {
                                        
                                        // Field is a reference field
                                        
                                        // SELECT CLAUSE
                                        // NSString * referenceFieldName = [arr objectAtIndex:1];
                                        
                                        // Describe the object specified in the "DisplayValue" in order to retrieve the reference field's table name
                                        NSString * displayValue = [[settingsValueArray objectAtIndex:j] objectForKey:@"SVMXC__Display_Value__c"];
                                        
                                        NSString * describeQuery = [NSString stringWithFormat:@"SELECT reference_to FROM SFReferenceTo WHERE object_api_name='SVMXC__Service_Order__c' AND field_api_name='%@'", displayValue];
                                        
                                        const char * _query = [describeQuery UTF8String];
                                        sqlite3_stmt * statement = nil;
                                        NSString * api_name = [[NSString alloc] initWithString:kEmptyString];;
                                        
                                        if ( synchronized_sqlite3_prepare_v2(appDelegate.db, _query,-1, &statement, nil) == SQLITE_OK )
                                        {
                                            while(synchronized_sqlite3_step(statement) == SQLITE_ROW)
                                            {
                                                char *_api_name = (char *) synchronized_sqlite3_column_text(statement,0);
                                                if ((_api_name != nil) && strlen(_api_name))
                                                {
                                                    // Vipin-memopt 15-1 9493
                                                    [api_name release];
                                                    api_name = [[NSString alloc] initWithUTF8String:_api_name];
                                                }
                                            }
                                        }
                                        synchronized_sqlite3_finalize(statement);
                                        
                                        NSArray * allkeysFromclause = [fromClause allKeys];
                                        
                                        if ([allkeysFromclause containsObject:api_name])
                                        {
                                            NSString * val = [NSString stringWithFormat:@"SVMXC__Service_Order__c.%@", displayValue];
                                            [selectClause setValue:val forKey:val];
                                            [appDelegate.serviceReportReference setValue:displayValue forKey:val];
                                            
                                        }
                                        else
                                        {
                                            for(int i = 1; i <[arr count]; i++)
                                            {
                                                NSString * selectField = [NSString stringWithFormat:@"%@.%@", api_name, [arr objectAtIndex:i]];
                                                
                                                [selectClause setValue:selectField forKey:selectField];
                                                [appDelegate.serviceReportReference setValue:displayValue forKey:selectField];
                                                
                                            }
                                        }
                                        
                                        // FROM CLAUSE
                                        
                                        [fromClause setValue:api_name forKey:api_name];
                                        
                                        // WHERE CLAUSE
                                        NSString * where = [NSString stringWithFormat:@"%@.Id = SVMXC__Service_Order__c.%@", api_name, displayValue];
                                        [whereClause addObject:where];
                                        
                                        //Vipin-memopt 15-1 9493
                                        [api_name  release];
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
                                    [selectClause setValue:@"SVMXC__Service_Order__c.SVMXC__Company__c" forKey:@"SVMXC__Service_Order__c.SVMXC__Company__c"];  //Service report fix : Radha
                                    continue;
                                }
                                else if ([queryField isEqualToString:@"Account Bill To"]) // SVMXC__Company__r
                                {
                                    NSArray * arr = [NSArray arrayWithObjects: @"SVMXC__Company__r.BillingCountry",@"SVMXC__Company__r.BillingPostalCode",@"SVMXC__Company__r.BillingState", @"SVMXC__Company__r.BillingCity", @"SVMXC__Company__r.BillingStreet", nil];//Service report fix : Radha
                                    
                                    [self getAllReferenceFields:arr];
                                    
                                    // [appDelegate.soqlQuery appendFormat:@", %@",  @"SVMXC__Company__c"];
                                    [selectClause setValue:@"SVMXC__Service_Order__c.SVMXC__Company__c" forKey:@"SVMXC__Service_Order__c.SVMXC__Company__c"];//Service report fix : Radha
                                }
                                else if ([queryField isEqualToString:@"Account Ship To"]) // SVMXC__Company__r
                                {
                                    NSArray * arr = [NSArray arrayWithObjects:@"SVMXC__Company__r.ShippingCountry", @"SVMXC__Company__r.ShippingPostalCode", @"SVMXC__Company__r.ShippingState", @"SVMXC__Company__r.ShippingCity", @"SVMXC__Company__r.ShippingStreet", nil];
                                    
                                    [self getAllReferenceFields:arr];
                                    
                                    // [appDelegate.soqlQuery appendFormat:@", %@", @"SVMXC__Company__c"];
                                    [selectClause setValue:@"SVMXC__Service_Order__c.SVMXC__Company__c" forKey:@"SVMXC__Service_Order__c.SVMXC__Company__c"]; //Service report fix : Radha
                                }
                                else if ([queryField isEqualToString:@"Service Location"]) // SVMXC__Service_Order__c
                                {
                                    
                                    // [appDelegate.soqlQuery appendFormat:@", %@", @"SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c, SVMXC__Zip__c, SVMXC__Country__c"];
                                    [selectClause setValue:@"SVMXC__Service_Order__c.SVMXC__Street__c" forKey:@"SVMXC__Service_Order__c.SVMXC__Street__c"];
                                    [selectClause setValue:@"SVMXC__Service_Order__c.SVMXC__City__c" forKey:@"SVMXC__Service_Order__c.SVMXC__City__c"];
                                    [selectClause setValue:@"SVMXC__Service_Order__c.SVMXC__State__c" forKey:@"SVMXC__Service_Order__c.SVMXC__State__c"];
                                    [selectClause setValue:@"SVMXC__Service_Order__c.SVMXC__Zip__c" forKey:@"SVMXC__Service_Order__c.SVMXC__Zip__c"];
                                    [selectClause setValue:@"SVMXC__Service_Order__c.SVMXC__Country__c" forKey:@"SVMXC__Service_Order__c.SVMXC__Country__c"];//Service report fix : Radha
                                    
                                }
                                else if ([queryField isEqualToString:@"Contact Address"]) // SVMXC__Contact__c
                                {
                                    NSArray * arr = [NSArray arrayWithObjects:@"SVMXC__Contact__r.MailingStreet", @"SVMXC__Contact__r.MailingState", @"SVMXC__Contact__r.MailingPostalCode", @"SVMXC__Contact__r.MailingCountry", @"SVMXC__Contact__r.MailingCity", nil];
                                    
                                    [self getAllReferenceFields:arr];
                                    
                                    // [appDelegate.soqlQuery appendFormat:@", %@", @"SVMXC__Contact__c"];
                                    [selectClause setValue:@"SVMXC__Service_Order__c.SVMXC__Contact__c" forKey:@"SVMXC__Service_Order__c.SVMXC__Contact__c"]; //Service report fix : Radha
                                }
                                
                                if (appDelegate.addressType != nil)
                                {
                                    [appDelegate.addressType release];
                                    appDelegate.addressType = nil;
                                }
                                
                                //Vipin-memopt 15-1 9493
                                appDelegate.addressType = (NSMutableString *) queryField;
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
                    NSString * str = [selectClauseKeys objectAtIndex:count];
                    str = [str stringByReplacingOccurrencesOfString:@"Case." withString:@"'Case'."];
                    if ([str isEqualToString:@"Case"])
                        str = [str stringByReplacingOccurrencesOfString:@"Case" withString:@"'Case'"];
                    
                    
                    if (count == 0)
                        [appDelegate.soqlQuery appendString:[NSString stringWithFormat:@"SELECT %@", str]];
                    else
                        [appDelegate.soqlQuery appendString:[NSString stringWithFormat:@",%@", str]];
                }
                
                // FROM
                [appDelegate.soqlQuery appendFormat:@" FROM SVMXC__Service_Order__c "];
                NSArray * allFromKeys = [fromClause allKeys];
                for (int count = 0; count < [allFromKeys count]; count++)
                {
                    NSString * str = [allFromKeys objectAtIndex:count];
                    str = [str stringByReplacingOccurrencesOfString:@"Case." withString:@"'Case'."];
                    if ([str isEqualToString:@"Case"] || [str isEqualToString:@"Case."] )
                        str = [str stringByReplacingOccurrencesOfString:@"Case" withString:@"'Case'"];
                    
                    [appDelegate.soqlQuery appendString:@" LEFT OUTER JOIN "];
                    [appDelegate.soqlQuery appendString:[NSString stringWithFormat:@"%@ ON ", str]];
                    
                    for (int i = 0; i < [whereClause count]; i++)
                    {
                        NSString * where = [whereClause objectAtIndex:i];
                        where = [where stringByReplacingOccurrencesOfString:@"Case." withString:@"'Case'."];
                        NSArray * array = [where componentsSeparatedByString:@".Id"];
                        
                        NSString * left = str;
                        NSString * right = [array objectAtIndex:0];
                        
                        if ([right isEqualToString:@"Case"] || [right isEqualToString:@"Case."] )
                            right = [right stringByReplacingOccurrencesOfString:@"Case" withString:@"'Case'"];
                        
                        
                        if ([left isEqualToString:right])
                        {
                            [appDelegate.soqlQuery appendString:[NSString stringWithFormat:@"%@ ", where]];
                            break;
                        }
                    }
                }
                
                [appDelegate.soqlQuery appendFormat:@" WHERE "];
                
                NSArray * array = [NSArray arrayWithObjects:@"SVMXC__Contact__r.Name",@"SVMXC__Contact__r.Phone", nil];
                [appDelegate.calDataBase getAllReferenceFields:array];
                
                [appDelegate.calDataBase getAllReferenceFields:query_fields_array];
                
                // Vipin-memopt 15-1 9493
                [query_fields_array release];
                
                if (fromClause)
                {
                    [fromClause release];
                    fromClause = nil;
                }
                
                if (selectClause)
                {
                    [selectClause release];
                    selectClause = nil;
                }
                
                if (whereClause)
                {
                    [whereClause release];
                    whereClause = nil;
                }
            }
            
            [GetSettingsValueArray release];
            GetSettingsValueArray = nil;
            
            // Vipin-memopt 15-1 9493
            NSMutableArray *WorkOrderFields = [[NSMutableArray alloc]initWithCapacity:0];
            {
                sqlite3_stmt *statement9;
                //NSMutableString *queryStatement9 = [[NSMutableString alloc]initWithCapacity:0];
                //queryStatement9 = [NSMutableString stringWithFormat:@"SELECT api_name,label,type FROM SFObjectField WHERE object_api_name = 'SVMXC__Service_Order__c' "];
                
                // Vipin-memopt 16-1 9493
                NSMutableString *queryStatement9 = [[NSMutableString alloc] initWithFormat:@"SELECT api_name,label,type FROM SFObjectField WHERE object_api_name = 'SVMXC__Service_Order__c' "];
                
                SMLog(kLogLevelVerbose,@"%@", queryStatement9);
                
                const char * _query9 = [queryStatement9 UTF8String];
                NSArray * keys9 = [NSArray arrayWithObjects:
                                   API_NAME,
                                   LABEL,
                                   TYPE,
                                   nil];
                int ret = synchronized_sqlite3_prepare_v2(appDelegate.db, _query9,-1, &statement9, nil);
                SMLog(kLogLevelVerbose,@"%d", ret);
                
                
                if ( ret  == SQLITE_OK )
                {
                    while(synchronized_sqlite3_step(statement9) == SQLITE_ROW)
                    {
                        char *_api_name = (char *) synchronized_sqlite3_column_text(statement9,0);
                        NSString * api_name = [[NSString alloc] initWithString:kEmptyString];
                        
                        if ((_api_name != nil) && strlen(_api_name))
                        {
                            [api_name release];
                            api_name = [[NSString alloc] initWithUTF8String:_api_name];
                            
                        }
                        char *_label = (char *) synchronized_sqlite3_column_text(statement9,1);
                        NSString * label = [[NSString alloc] initWithString:kEmptyString];
                        if ((_label != nil) && strlen(_label))
                        {
                            [label release];
                            label = [[NSString alloc] initWithUTF8String:_label];
                        }
                        
                        char *_type = (char *) synchronized_sqlite3_column_text(statement9,2);
                        NSString * type = [[NSString alloc] initWithString:kEmptyString];
                        if ((_type != nil) && strlen(_type))
                        {
                            [type release];
                            type = [[NSString alloc] initWithUTF8String:_type];
                        }
                        
                        NSMutableArray * objects9 = [[NSMutableArray arrayWithObjects:(api_name != nil)?api_name:@"",(label != nil)?label:@"",(type != nil)?type:@"",nil] retain];
                        
                        NSDictionary * dictionary9 = [[NSDictionary alloc] initWithObjects:objects9 forKeys:keys9];
                        [WorkOrderFields addObject:dictionary9];
                        [dictionary9 release];
                        [objects9 release];
                        
                        // Vipin-memopt 15-1 9493
                        [type release];
                        [api_name release];
                        [label release];
                    }
                }
                
                [queryStatement9 release];
                SMLog(kLogLevelVerbose,@"%@",WorkOrderFields);
                appDelegate.WorkDescription = WorkOrderFields;
                synchronized_sqlite3_finalize(statement9);
            
            }
            
            [WorkOrderFields release];
            WorkOrderFields = nil;
        }
        @catch (NSException *exp)
        {
            SMLog(kLogLevelError,@"Exception Name CalendarDatabase :startQueryConfiguration %@",exp.name);
            SMLog(kLogLevelError,@"Exception Reason CalendarDatabase :startQueryConfiguration %@",exp.reason);
            [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
        }
    
    } // @autorelease pool ends here
}



/*

 - (void) startQueryConfiguration
 {
 sqlite3_stmt *statement2;
 NSMutableString *queryStatement2 = [[NSMutableString alloc]initWithCapacity:0];
 
 NSMutableArray *SubModuleInfoArray = [[NSMutableArray alloc]initWithCapacity:0];
 
 
 queryStatement2 = [NSMutableString stringWithFormat:@"SELECT Id, SVMXC__SubmoduleID__c, SVMXC__SettingID__c, SVMXC__Setting_Unique_ID__c, SVMXC__Settings_Name__c, SVMXC__Data_Type__c, SVMXC__Values__c, SVMXC__Default_Value__c, SVMXC__Setting_Type__c, SVMXC__Search_Order__c, SVMXC__IsPrivate__c, SVMXC__Active__c, SVMXC__Description__c, SVMXC__IsStandard__c, SVMXC__Submodule__c FROM SettingsInfo"];
 
 SMLog(kLogLevelVerbose,@"%@", queryStatement2);
 
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
 
 @try{
 
 if ( synchronized_sqlite3_prepare_v2(appDelegate.db, _query2,-1, &statement2, nil) == SQLITE_OK )
 {
 while(synchronized_sqlite3_step(statement2) == SQLITE_ROW)
 {
 char *_Id = (char *) synchronized_sqlite3_column_text(statement2,0);
 NSString * Id = @"";
 if ((_Id != nil) && strlen(_Id))
 {
 Id = [[NSString alloc] initWithUTF8String:_Id];
 
 }
 char *_SVMXC__SubmoduleID__c = (char *) synchronized_sqlite3_column_text(statement2,1);
 NSString * SVMXC__SubmoduleID__c = @"";
 if ((_SVMXC__SubmoduleID__c != nil) && strlen(_SVMXC__SubmoduleID__c))
 {
 SVMXC__SubmoduleID__c = [[NSString alloc] initWithUTF8String:_SVMXC__SubmoduleID__c];
 }
 char *_SVMXC__SettingID__c = (char *) synchronized_sqlite3_column_text(statement2,2);
 NSString * SVMXC__SettingID__c = @"";
 if ((_SVMXC__SettingID__c != nil) && strlen(_SVMXC__SettingID__c))
 {
 SVMXC__SettingID__c = [[NSString alloc] initWithUTF8String:_SVMXC__SettingID__c];
 }
 char *_SVMXC__Setting_Unique_ID = (char *) synchronized_sqlite3_column_text(statement2,3);
 NSString * SVMXC__Setting_Unique_ID = @"";
 if ((_SVMXC__Setting_Unique_ID != nil) && strlen(_SVMXC__Setting_Unique_ID))
 {
 SVMXC__Setting_Unique_ID = [[NSString alloc] initWithUTF8String:_SVMXC__Setting_Unique_ID];
 }
 char *_SVMXC__Settings_Name__c = (char *) synchronized_sqlite3_column_text(statement2,4);
 NSString * SVMXC__Settings_Name__c = @"";
 if ((_SVMXC__Settings_Name__c != nil) && strlen(_SVMXC__Settings_Name__c))
 {
 SVMXC__Settings_Name__c = [[NSString alloc] initWithUTF8String:_SVMXC__Settings_Name__c];
 }
 char *_SVMXC__Data_Type__c = (char *) synchronized_sqlite3_column_text(statement2,5);
 NSString * SVMXC__Data_Type__c = @"";
 if ((_SVMXC__Data_Type__c != nil) && strlen(_SVMXC__Data_Type__c))
 {
 SVMXC__Data_Type__c = [[NSString alloc] initWithUTF8String:_SVMXC__Data_Type__c];
 }
 char *_SVMXC__Values__c = (char *) synchronized_sqlite3_column_text(statement2,6);
 NSString * SVMXC__Values__c = @"";
 if ((_SVMXC__Values__c != nil) && strlen(_SVMXC__Values__c))
 {
 SVMXC__Values__c = [[NSString alloc] initWithUTF8String:_SVMXC__Values__c];
 }
 char *_SVMXC__Default_Value__c = (char *) synchronized_sqlite3_column_text(statement2,7);
 NSString * SVMXC__Default_Value__c = @"";
 if ((_SVMXC__Default_Value__c != nil) && strlen(_SVMXC__Default_Value__c))
 {
 SVMXC__Default_Value__c = [[NSString alloc] initWithUTF8String:_SVMXC__Default_Value__c];
 }
 char *_SVMXC__Setting_Type__c = (char *) synchronized_sqlite3_column_text(statement2,8);
 NSString * SVMXC__Setting_Type__c = @"";
 if ((_SVMXC__Setting_Type__c != nil) && strlen(_SVMXC__Setting_Type__c))
 {
 SVMXC__Setting_Type__c = [[NSString alloc] initWithUTF8String:_SVMXC__Setting_Type__c];
 }
 char *_SVMXC__Search_Order__c = (char *) synchronized_sqlite3_column_text(statement2,9);
 NSString * SVMXC__Search_Order__c = @"";
 if ((_SVMXC__Search_Order__c != nil) && strlen(_SVMXC__Search_Order__c))
 {
 SVMXC__Search_Order__c = [[NSString alloc] initWithUTF8String:_SVMXC__Search_Order__c];
 }
 char *_SVMXC__IsPrivate__c = (char *) synchronized_sqlite3_column_text(statement2,10);
 NSString * SVMXC__IsPrivate__c = @"";
 if ((_SVMXC__IsPrivate__c != nil) && strlen(_SVMXC__IsPrivate__c))
 {
 SVMXC__IsPrivate__c = [[NSString alloc] initWithUTF8String:_SVMXC__IsPrivate__c];
 }
 char *_SVMXC__Active__c = (char *) synchronized_sqlite3_column_text(statement2,11);
 NSString * SVMXC__Active__c = @"";
 if ((_SVMXC__Active__c != nil) && strlen(_SVMXC__Active__c))
 {
 SVMXC__Active__c = [[NSString alloc] initWithUTF8String:_SVMXC__Active__c];
 }
 char *_SVMXC__Description__c = (char *) synchronized_sqlite3_column_text(statement2,12);
 NSString * SVMXC__Description__c = @"";
 if ((_SVMXC__Description__c != nil) && strlen(_SVMXC__Description__c))
 {
 SVMXC__Description__c = [[NSString alloc] initWithUTF8String:_SVMXC__Description__c];
 }
 char *_SVMXC__IsStandard__c = (char *) synchronized_sqlite3_column_text(statement2,13);
 NSString * SVMXC__IsStandard__c = @"";
 if ((_SVMXC__IsStandard__c != nil) && strlen(_SVMXC__IsStandard__c))
 {
 SVMXC__IsStandard__c = [[NSString alloc] initWithUTF8String:_SVMXC__IsStandard__c];
 }
 char *_SVMXC__Submodule__c = (char *) synchronized_sqlite3_column_text(statement2,14);
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
 synchronized_sqlite3_finalize(statement2);
 
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
 }
 
 sqlite3_stmt *statement4;
 NSMutableString *queryStatement4 = [[NSMutableString alloc]initWithCapacity:0];
 NSMutableArray * GetSettingsValueArray = [[NSMutableArray alloc]initWithCapacity:0];
 
 
 queryStatement4 = [NSMutableString stringWithFormat:@"Select Id, SVMXC__Setting_Configuration_Profile__c, SVMXC__Setting_ID__c, SVMXC__Internal_Value__c, SVMXC__Display_Value__c, SVMXC__Active__c, SVMXC__IsDefault__c FROM SettingsValue"];
 SMLog(kLogLevelVerbose,@"%@", queryStatement4);
 
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
 if ( synchronized_sqlite3_prepare_v2(appDelegate.db, _query4,-1, &statement4, nil) == SQLITE_OK )
 {
 while(synchronized_sqlite3_step(statement4) == SQLITE_ROW)
 {
 char *_Id = (char *) synchronized_sqlite3_column_text(statement4,0);
 NSString * Id = @"";
 if ((_Id != nil) && strlen(_Id))
 {
 Id = [[NSString alloc] initWithUTF8String:_Id];
 
 }
 char *_SVMXC__Setting_Configuration_Profile__c = (char *) synchronized_sqlite3_column_text(statement4,1);
 NSString * SVMXC__Setting_Configuration_Profile__c = @"";
 if ((_SVMXC__Setting_Configuration_Profile__c != nil) && strlen(_SVMXC__Setting_Configuration_Profile__c))
 {
 SVMXC__Setting_Configuration_Profile__c = [[NSString alloc] initWithUTF8String:_SVMXC__Setting_Configuration_Profile__c];
 }
 char *_SVMXC__Setting_ID__c = (char *) synchronized_sqlite3_column_text(statement4,2);
 NSString * SVMXC__Setting_ID__c = @"";
 if ((_SVMXC__Setting_ID__c != nil) && strlen(_SVMXC__Setting_ID__c))
 {
 SVMXC__Setting_ID__c = [[NSString alloc] initWithUTF8String:_SVMXC__Setting_ID__c];
 }
 char *_SVMXC__Internal_Value__c = (char *) synchronized_sqlite3_column_text(statement4,3);
 NSString * SVMXC__Internal_Value__c = @"";
 if ((_SVMXC__Internal_Value__c!= nil) && strlen(_SVMXC__Internal_Value__c))
 {
 SVMXC__Internal_Value__c = [[NSString alloc] initWithUTF8String:_SVMXC__Internal_Value__c];
 }
 char *_SVMXC__Display_Value__c = (char *) synchronized_sqlite3_column_text(statement4,4);
 NSString * SVMXC__Display_Value__c = @"";
 if ((_SVMXC__Display_Value__c != nil) && strlen(_SVMXC__Display_Value__c))
 {
 SVMXC__Display_Value__c = [[NSString alloc] initWithUTF8String:_SVMXC__Display_Value__c];
 }
 char *_SVMXC__Active__c = (char *) synchronized_sqlite3_column_text(statement4,5);
 NSString * SVMXC__Active__c = @"";
 if ((_SVMXC__Active__c != nil) && strlen(_SVMXC__Active__c))
 {
 SVMXC__Active__c = [[NSString alloc] initWithUTF8String:_SVMXC__Active__c];
 }
 char *_SVMXC__IsDefault__c = (char *) synchronized_sqlite3_column_text(statement4,6);
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
 synchronized_sqlite3_finalize(statement4);
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
 {
 appDelegate.serviceReportValueMapping = [[NSMutableArray alloc] initWithCapacity:0];
 SMLog(kLogLevelVerbose,@"%@",appDelegate.serviceReportValueMapping);
 }
 else
 {
 NSDictionary * dict = [NSDictionary dictionaryWithObject:[obj6 objectForKey:@"SVMXC__Internal_Value__c"] forKey:[obj6 objectForKey:@"SVMXC__Display_Value__c"]];
 [appDelegate.serviceReportValueMapping addObject:dict];
 SMLog(kLogLevelVerbose,@"%@",appDelegate.serviceReportValueMapping);
 
 }
 }
 
 
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
 
 if (appDelegate.serviceReportReference == nil)
 appDelegate.serviceReportReference = [[NSMutableDictionary alloc] initWithCapacity:0];
 
 if ([[[settingsInfoArray objectAtIndex:i] objectForKey:@"SVMXC__Setting_Unique_ID__c"] Contains:@"IPAD004"])
 {
 NSString * subModuleSettingKey = [[settingsInfoArray objectAtIndex:i] objectForKey:@"SVMXC__Setting_Unique_ID__c"];
 
 NSString * keyNumVal = [subModuleSettingKey stringByReplacingOccurrencesOfString:@"IPAD004_SET" withString:@""];
 
 NSInteger intNumVal = [keyNumVal intValue];
 SMLog(kLogLevelVerbose,@"%@",keyNumVal);
 
 //Fix for 5152.Change for Signature Capture. Shrinivas  --> 14/08/2012
 if (intNumVal == 23)
 {
 appDelegate.signatureCaptureUpload = [[[settingsValueArray objectAtIndex:j] objectForKey:@"SVMXC__Internal_Value__c"] boolValue];
 }
 if (intNumVal >= 11 && intNumVal <= 20)
 {
 NSString * queryField = [[settingsValueArray objectAtIndex:j] objectForKey:@"SVMXC__Internal_Value__c"];
 SMLog(kLogLevelVerbose,@"QUERY FIELD %@", queryField);
 if ([queryField isKindOfClass:[NSNull class]] || [queryField isEqualToString:@""])
 continue;
 NSArray * arr = [queryField componentsSeparatedByString:@"."];
 
 if ([arr count] >= 2)
 {
 
 // Field is a reference field
 
 // SELECT CLAUSE
 // NSString * referenceFieldName = [arr objectAtIndex:1];
 
 // Describe the object specified in the "DisplayValue" in order to retrieve the reference field's table name
 NSString * displayValue = [[settingsValueArray objectAtIndex:j] objectForKey:@"SVMXC__Display_Value__c"];
 
 NSString * describeQuery = [NSString stringWithFormat:@"SELECT reference_to FROM SFReferenceTo WHERE object_api_name='SVMXC__Service_Order__c' AND field_api_name='%@'", displayValue];
 
 const char * _query = [describeQuery UTF8String];
 sqlite3_stmt * statement = nil;
 NSString * api_name = @"";
 
 if ( synchronized_sqlite3_prepare_v2(appDelegate.db, _query,-1, &statement, nil) == SQLITE_OK )
 {
 while(synchronized_sqlite3_step(statement) == SQLITE_ROW)
 {
 char *_api_name = (char *) synchronized_sqlite3_column_text(statement,0);
 if ((_api_name != nil) && strlen(_api_name))
 {
 api_name = [[NSString alloc] initWithUTF8String:_api_name];
 }
 }
 }
 synchronized_sqlite3_finalize(statement);
 
 NSArray * allkeysFromclause = [fromClause allKeys];
 
 if ([allkeysFromclause containsObject:api_name])
 {
 NSString * val = [NSString stringWithFormat:@"SVMXC__Service_Order__c.%@", displayValue];
 [selectClause setValue:val forKey:val];
 [appDelegate.serviceReportReference setValue:displayValue forKey:val];
 
 }
 else
 {
 for(int i = 1; i <[arr count]; i++)
 {
 NSString * selectField = [NSString stringWithFormat:@"%@.%@", api_name, [arr objectAtIndex:i]];
 
 [selectClause setValue:selectField forKey:selectField];
 [appDelegate.serviceReportReference setValue:displayValue forKey:selectField];
 
 }
 }
 
 
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
 [selectClause setValue:@"SVMXC__Service_Order__c.SVMXC__Company__c" forKey:@"SVMXC__Service_Order__c.SVMXC__Company__c"];  //Service report fix : Radha
 continue;
 }
 else if ([queryField isEqualToString:@"Account Bill To"]) // SVMXC__Company__r
 {
 NSArray * arr = [NSArray arrayWithObjects: @"SVMXC__Company__r.BillingCountry",@"SVMXC__Company__r.BillingPostalCode",@"SVMXC__Company__r.BillingState", @"SVMXC__Company__r.BillingCity", @"SVMXC__Company__r.BillingStreet", nil];//Service report fix : Radha
 
 [self getAllReferenceFields:arr];
 
 // [appDelegate.soqlQuery appendFormat:@", %@",  @"SVMXC__Company__c"];
 [selectClause setValue:@"SVMXC__Service_Order__c.SVMXC__Company__c" forKey:@"SVMXC__Service_Order__c.SVMXC__Company__c"];//Service report fix : Radha
 }
 else if ([queryField isEqualToString:@"Account Ship To"]) // SVMXC__Company__r
 {
 NSArray * arr = [NSArray arrayWithObjects:@"SVMXC__Company__r.ShippingCountry", @"SVMXC__Company__r.ShippingPostalCode", @"SVMXC__Company__r.ShippingState", @"SVMXC__Company__r.ShippingCity", @"SVMXC__Company__r.ShippingStreet", nil];
 
 [self getAllReferenceFields:arr];
 
 // [appDelegate.soqlQuery appendFormat:@", %@", @"SVMXC__Company__c"];
 [selectClause setValue:@"SVMXC__Service_Order__c.SVMXC__Company__c" forKey:@"SVMXC__Service_Order__c.SVMXC__Company__c"]; //Service report fix : Radha
 }
 else if ([queryField isEqualToString:@"Service Location"]) // SVMXC__Service_Order__c
 {
 
 // [appDelegate.soqlQuery appendFormat:@", %@", @"SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c, SVMXC__Zip__c, SVMXC__Country__c"];
 [selectClause setValue:@"SVMXC__Service_Order__c.SVMXC__Street__c" forKey:@"SVMXC__Service_Order__c.SVMXC__Street__c"];
 [selectClause setValue:@"SVMXC__Service_Order__c.SVMXC__City__c" forKey:@"SVMXC__Service_Order__c.SVMXC__City__c"];
 [selectClause setValue:@"SVMXC__Service_Order__c.SVMXC__State__c" forKey:@"SVMXC__Service_Order__c.SVMXC__State__c"];
 [selectClause setValue:@"SVMXC__Service_Order__c.SVMXC__Zip__c" forKey:@"SVMXC__Service_Order__c.SVMXC__Zip__c"];
 [selectClause setValue:@"SVMXC__Service_Order__c.SVMXC__Country__c" forKey:@"SVMXC__Service_Order__c.SVMXC__Country__c"];//Service report fix : Radha
 
 }
 else if ([queryField isEqualToString:@"Contact Address"]) // SVMXC__Contact__c
 {
 NSArray * arr = [NSArray arrayWithObjects:@"SVMXC__Contact__r.MailingStreet", @"SVMXC__Contact__r.MailingState", @"SVMXC__Contact__r.MailingPostalCode", @"SVMXC__Contact__r.MailingCountry", @"SVMXC__Contact__r.MailingCity", nil];
 
 [self getAllReferenceFields:arr];
 
 // [appDelegate.soqlQuery appendFormat:@", %@", @"SVMXC__Contact__c"];
 [selectClause setValue:@"SVMXC__Service_Order__c.SVMXC__Contact__c" forKey:@"SVMXC__Service_Order__c.SVMXC__Contact__c"]; //Service report fix : Radha
 }
 if (appDelegate.addressType != nil)
 appDelegate.addressType = nil;
 appDelegate.addressType = [(NSMutableString *) queryField retain];
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
 NSString * str = [selectClauseKeys objectAtIndex:count];
 str = [str stringByReplacingOccurrencesOfString:@"Case." withString:@"'Case'."];
 if ([str isEqualToString:@"Case"])
 str = [str stringByReplacingOccurrencesOfString:@"Case" withString:@"'Case'"];
 
 
 if (count == 0)
 [appDelegate.soqlQuery appendString:[NSString stringWithFormat:@"SELECT %@", str]];
 else
 [appDelegate.soqlQuery appendString:[NSString stringWithFormat:@",%@", str]];
 }
 
 // FROM
 [appDelegate.soqlQuery appendFormat:@" FROM SVMXC__Service_Order__c "];
 NSArray * allFromKeys = [fromClause allKeys];
 for (int count = 0; count < [allFromKeys count]; count++)
 {
 NSString * str = [allFromKeys objectAtIndex:count];
 str = [str stringByReplacingOccurrencesOfString:@"Case." withString:@"'Case'."];
 if ([str isEqualToString:@"Case"] || [str isEqualToString:@"Case."] )
 str = [str stringByReplacingOccurrencesOfString:@"Case" withString:@"'Case'"];
 
 [appDelegate.soqlQuery appendString:@" LEFT OUTER JOIN "];
 [appDelegate.soqlQuery appendString:[NSString stringWithFormat:@"%@ ON ", str]];
 
 for (int i = 0; i < [whereClause count]; i++)
 {
 NSString * where = [whereClause objectAtIndex:i];
 where = [where stringByReplacingOccurrencesOfString:@"Case." withString:@"'Case'."];
 NSArray * array = [where componentsSeparatedByString:@".Id"];
 
 NSString * left = str;
 NSString * right = [array objectAtIndex:0];
 
 if ([right isEqualToString:@"Case"] || [right isEqualToString:@"Case."] )
 right = [right stringByReplacingOccurrencesOfString:@"Case" withString:@"'Case'"];
 
 
 if ([left isEqualToString:right])
 {
 [appDelegate.soqlQuery appendString:[NSString stringWithFormat:@"%@ ", where]];
 break;
 }
 }
 
 
 }
 [appDelegate.soqlQuery appendFormat:@" WHERE "];
 
 NSArray * array = [NSArray arrayWithObjects:@"SVMXC__Contact__r.Name",@"SVMXC__Contact__r.Phone", nil];
 [appDelegate.calDataBase getAllReferenceFields:array];
 
 [appDelegate.calDataBase getAllReferenceFields:query_fields_array];
 
 
 }
 
 NSMutableArray *WorkOrderFields = [[NSMutableArray alloc]initWithCapacity:0];
 {
 sqlite3_stmt *statement9;
 NSMutableString *queryStatement9 = [[NSMutableString alloc]initWithCapacity:0];
 queryStatement9 = [NSMutableString stringWithFormat:@"SELECT api_name,label,type FROM SFObjectField WHERE object_api_name = 'SVMXC__Service_Order__c' "];
 SMLog(kLogLevelVerbose,@"%@", queryStatement9);
 
 const char * _query9 = [queryStatement9 UTF8String];
 NSArray * keys9 = [NSArray arrayWithObjects:
 API_NAME,
 LABEL,
 TYPE,
 nil];
 int ret = synchronized_sqlite3_prepare_v2(appDelegate.db, _query9,-1, &statement9, nil);
 SMLog(kLogLevelVerbose,@"%d", ret);
 
 
 if ( ret  == SQLITE_OK )
 {
 while(synchronized_sqlite3_step(statement9) == SQLITE_ROW)
 {
 char *_api_name = (char *) synchronized_sqlite3_column_text(statement9,0);
 NSString * api_name = @"";
 if ((_api_name != nil) && strlen(_api_name))
 {
 api_name = [[NSString alloc] initWithUTF8String:_api_name];
 
 }
 char *_label = (char *) synchronized_sqlite3_column_text(statement9,1);
 NSString * label = @"";
 if ((_label != nil) && strlen(_label))
 {
 label = [[NSString alloc] initWithUTF8String:_label];
 }
 
 char *_type = (char *) synchronized_sqlite3_column_text(statement9,2);
 NSString * type = @"";
 if ((_type != nil) && strlen(_type))
 {
 type = [[NSString alloc] initWithUTF8String:_type];
 }
 
 NSMutableArray * objects9 = [[NSMutableArray arrayWithObjects:(api_name != nil)?api_name:@"",(label != nil)?label:@"",(type != nil)?type:@"",nil] retain];
 
 NSDictionary * dictionary9 = [[NSDictionary alloc] initWithObjects:objects9 forKeys:keys9];
 [WorkOrderFields addObject:dictionary9];
 [dictionary9 release];
 [objects9 release];
 }
 }
 
 SMLog(kLogLevelVerbose,@"%@",WorkOrderFields);
 appDelegate.WorkDescription = [WorkOrderFields retain];
 synchronized_sqlite3_finalize(statement9);
 }
 }@catch (NSException *exp) {
 SMLog(kLogLevelError,@"Exception Name CalendarDatabase :startQueryConfiguration %@",exp.name);
 SMLog(kLogLevelError,@"Exception Reason CalendarDatabase :startQueryConfiguration %@",exp.reason);
 [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
 }
 
 }

 */


-(void) getAllReferenceFields:(NSArray *)fields_array
{
    for (int j= 0 ; j< [fields_array count]; j++)
    {
        NSString * queryField = [fields_array objectAtIndex:j];
        SMLog(kLogLevelVerbose,@"QUERY FIELD %@", queryField);
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
    
    NSString * query = @"";
    @try{
    NSMutableString * clean_Query = [appDelegate.calDataBase removeDuplicatesFromSOQL:appDelegate.soqlQuery withString:query];
    NSString * final_query = [NSString stringWithFormat:@"%@ SVMXC__Service_Order__c.local_id = '%@'", clean_Query, record_id];
    
    SMLog(kLogLevelVerbose, @"final query %@",final_query);
    
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
        
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [final_query UTF8String],-1, &statement5, nil) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(statement5) == SQLITE_ROW)
        {
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:0];
			
			for(int k = 0 ; k < [all_fields count] ; k++)
            {
                char * field = (char *) synchronized_sqlite3_column_text(statement5, k);

				NSString * field_value = @"";
				NSString * field_name = @"";
				if ( field != nil)
				{
					field_value = [NSString stringWithUTF8String:field];
				}
				
				field_name = [all_fields objectAtIndex:k];
				field_name = [field_name stringByReplacingOccurrencesOfString:@"SVMXC__Service_Order__c." withString:@""];
				
				if ([field_value isEqualToString:@""] && [field_name Contains:@"."] && [field_name Contains:@"Name"])   //Fix for PDF
				{
                    NSArray * referencekeys = [appDelegate.serviceReportReference allKeys];
                    NSString * referenceTo = @"";
                    
                    for (NSString * string in referencekeys)
                    {
                        if ([string isEqualToString:field_name])
                        {
                            referenceTo = [appDelegate.serviceReportReference objectForKey:field_name];
                            break;
                        }
                    }
                    
				//	NSString * referenceTo = [self getApi_NameWithReference:[field_name stringByReplacingOccurrencesOfString:@".Name" withString:@""]];
				
					NSString * Id = [self getFieldValueFromTable:referenceTo];
					field_value = [self getValueFromLookupwithId:Id];
					
				}
				
				[dict setValue:field_value forKey:field_name];
            }

			
            [reportEssentialArray addObject:dict];
            [dict release];
        }
    }
    synchronized_sqlite3_finalize(statement5);
	
    SMLog(kLogLevelVerbose,@"Report Essential Array %@", reportEssentialArray);
	
    NSMutableArray *  refernce_array = [appDelegate.calDataBase getreferncetableFieldsForReportEsentials:reportEssentialArray];
    
    for(NSDictionary * dict in refernce_array)
    {
        [reportEssentialArray addObject:dict];
    }
    SMLog(kLogLevelVerbose,@"%@",reportEssentialArray);
	}@catch (NSException *exp) {
	SMLog(kLogLevelError,@"Exception Name CalendarDatabase :getReportEssentials %@",exp.name);
	SMLog(kLogLevelError,@"Exception Reason CalendarDatabase :getReportEssentials %@",exp.reason);
	[appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }

    return reportEssentialArray;
}

-(NSMutableArray *)getreferncetableFieldsForReportEsentials:(NSMutableArray *)array
{
    NSMutableArray *  getAll_field_values = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSArray * allkeys = [appDelegate.reference_field_names allKeys];
    @try{
    for(int k= 0 ; k<[allkeys count]; k++)
    {
        NSString * key = [allkeys objectAtIndex:k];
        
        NSString * table_name = @"";
        NSMutableArray * fields_array = [appDelegate.reference_field_names objectForKey:key];
        
        SMLog(kLogLevelVerbose,@"======================Field_array==============================%@" ,fields_array);
        NSString * queryableFields = @"";
        for(int i = 0 ; i<[fields_array count]; i++)
        {
            if(i != 0)
            {
                queryableFields = [queryableFields stringByAppendingString:@","];
            }
            queryableFields = [queryableFields stringByAppendingString:[fields_array objectAtIndex:i]];
        }
        
        SMLog(kLogLevelVerbose,@" ------queryFields %@", queryableFields);
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
        
        //these 2 lines of code has to be merged
        table_name = [self getTableName:key];
        
        if([queryableFields length]!= 0)
        {
            
            NSString * refernce_id = @"";
            for(int j = 0 ; j<[array count] ; j++)
            {
                NSDictionary * dict = [array objectAtIndex:j];
                SMLog(kLogLevelVerbose,@"dict  - %@ ", dict);
                
                
                NSArray * arr1_allkeys = [dict allKeys];
                for(int x = 0 ; x < [arr1_allkeys count] ; x++)
                {
                    NSString * arr1_key = [arr1_allkeys objectAtIndex:x];
                    
                    arr1_key = [arr1_key   stringByReplacingOccurrencesOfString:@" " withString:@""];
                    SMLog(kLogLevelVerbose,@" arr1_allkeys  %@   key  %@ ", arr1_key, key);
                    if([key isEqualToString:arr1_key])
                    {
                        refernce_id =  [dict valueForKey:key];
                        break;
                    }
                    
                }
                //if(key isEqualToString:[array])
            }
            
            NSString * query = [NSString stringWithFormat:@"SELECT %@ FROM %@ Where id = '%@'" , queryableFields , table_name , refernce_id];
            
            SMLog(kLogLevelVerbose,@" query --%@" , query);
            sqlite3_stmt * statement5;
            
            NSMutableDictionary * dict = nil;
            
            if ( synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String],-1, &statement5, nil) == SQLITE_OK )
            {
                while(synchronized_sqlite3_step(statement5) == SQLITE_ROW)
                {
                    dict = [[NSMutableDictionary alloc] initWithCapacity:0];
                    for(int p = 0 ; p<[fields_array count]; p++)
                    {
                        char * field = (char *) synchronized_sqlite3_column_text(statement5, p);
                        if(field != nil)
                        {
                            
                            NSString * field_value = [NSString stringWithUTF8String:field];
                            NSString *  field_key = [fields_array objectAtIndex:p];
                            //                            NSString *  key_ = [NSString stringWithFormat:@"%@.%@",key,field_key];
                            NSString *  key_ = [NSString stringWithFormat:@"%@",field_key];
                            [dict setValue:field_value forKey:key_];
                            SMLog(kLogLevelVerbose,@" getAllField values %@", dict);
                        }
                    }
                    NSDictionary * finalDict = [NSDictionary dictionaryWithObject:dict forKey:key];
                    [getAll_field_values addObject:finalDict];
                    [dict release];
                    dict = nil;
                }
            }
            synchronized_sqlite3_finalize(statement5);
        }
    }
	}@catch (NSException *exp) {
	SMLog(kLogLevelError,@"Exception Name CalendarDatabase :getreferncetableFieldsForReportEsentials %@",exp.name);
	SMLog(kLogLevelError,@"Exception Reason CalendarDatabase :getreferncetableFieldsForReportEsentials %@",exp.reason);
	[appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
    
    SMLog(kLogLevelVerbose,@" ------------------ get All field values%@", getAll_field_values);
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
    
    SMLog(kLogLevelVerbose,@"%@", result);
    return result;
}

-(NSString *)getTableName:(NSString *)key
{
    NSString * tableName = @"";
    NSString * query = @"";
    sqlite3_stmt * statement;
    query = [NSString stringWithFormat:@"Select reference_to From SFObjectField where api_name ='%@' and object_api_name ='SVMXC__Service_Order__c'",key];
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
        {
            if (synchronized_sqlite3_step(statement) == SQLITE_ROW)
            {
                char * name = (char *) synchronized_sqlite3_column_text(statement, 0);
                if ((name != nil) && strlen(name))
                    {
                        tableName = [NSString stringWithUTF8String:name];
                    }
            }
        }
    synchronized_sqlite3_finalize(statement);
    
    return tableName;
}

//Abinash
//  Unused methods
//- (NSString *) getNameFieldForCreateProcessFromDB:(NSString *)ID
//{
//    NSString * name = [appDelegate.createObjectContext objectForKey:NAME_FIELD];
//    NSString * objname = [appDelegate.createObjectContext objectForKey:OBJ_NAME];
//    NSString * _query = [NSString stringWithFormat:@"SELECT %@ From %@ WHERE ID = '%@'",name, objname, ID]; 
//    sqlite3_stmt * queryStatement;
//    NSString * nameField = [[NSString alloc]init];
//    const char * query = [_query UTF8String];
//    if (synchronized_sqlite3_prepare_v2(appDelegate.db, query, -1, &queryStatement, nil) == SQLITE_OK)
//    {
//        while (synchronized_sqlite3_step(queryStatement)==SQLITE_ROW)
//        {
//            char * _name = (char*) synchronized_sqlite3_column_text(queryStatement, 0);
//            if (_name != nil)
//            {
//                NSString * Name = [[NSString alloc]initWithUTF8String:_name];
//                nameField = [nameField stringByAppendingString:Name];
//                [Name release];
//            }
//            
//        }
//    }
//    
//    synchronized_sqlite3_finalize(queryStatement);
//    return nameField;
//}

- (void) insertTroubleShootDataInDB:(NSData *)troubleShootData WithId:(NSString *)docID  andName:(NSString *)productName andProductId:(NSString *)productId
{
    NSString * stringData = [Base64 encode:troubleShootData];
    productName=[productName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
//defect    007237
    docID=[docID stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSMutableString *queryString = [NSMutableString stringWithFormat:@"Update '%@' Set '%@' = '%@' Where DocId = '%@' and ProductName = '%@'", @"trobleshootdata", @"Product_Doc", 
                                    stringData, docID, productName];
    
    SMLog(kLogLevelVerbose,@"%@", queryString);
    
    [appDelegate.dataBase beginTransaction];
    
    char *err;
    int retVal = synchronized_sqlite3_exec(appDelegate.db, [queryString UTF8String], NULL, NULL, &err);
    SMLog(kLogLevelVerbose,@"%d", retVal);
    
    if (retVal != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"%@", queryString);
		SMLog(kLogLevelError,@"METHOD:insertTroubleShootDataInDB " );
		SMLog(kLogLevelError,@"ERROR IN UPDATING %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:queryString type:UPDATEQUERY];
    }
    [appDelegate.dataBase endTransaction];
}


- (void) insertProductName:(NSMutableArray *)productInfo WithId:(NSString *)productId
{
    [appDelegate.dataBase beginTransaction];
    for ( int i = 0; i < [productInfo count]; i++ )
    {
        productId=[productId stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        NSString *DocId=[[[productInfo objectAtIndex:i]objectForKey:@"DocId"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        NSString *Name=[[[productInfo objectAtIndex:i]objectForKey:@"Name"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        NSMutableString *queryString = [NSMutableString stringWithFormat:@"Insert into trobleshootdata (ProductId, DocId, ProductName) Values ('%@', '%@', '%@')",productId,
                                        DocId, Name];
        
        char *err;
        if (synchronized_sqlite3_exec(appDelegate.db, [queryString UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
			SMLog(kLogLevelError,@"%@", queryString);
			SMLog(kLogLevelError,@"METHOD: insertProductName");
			SMLog(kLogLevelError,@"ERROR IN INSERTING %s", err);
			[appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:queryString type:INSERTQUERY];
        }  
    }
    [appDelegate.dataBase endTransaction];
}



/*###############################################   CHATTER METHODS   ##########################################*/

- (void) insertChatterDetailsIntoDBForWithId:(NSString *)productId andChatterDetails:(NSMutableArray *)chatterDetails
{
    
    SMLog(kLogLevelVerbose,@"%@", chatterDetails);
    //defect 007237
    productId=[productId stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    [appDelegate.dataBase beginTransaction];
    NSString *deleteQuery = [NSString stringWithFormat:@"Delete From ChatterPostDetails where ProductId = '%@'", productId];
    
	char *err;
	if (synchronized_sqlite3_exec(appDelegate.db, [deleteQuery UTF8String], NULL, NULL, &err) != SQLITE_OK)
	{
		SMLog(kLogLevelError,@"%@", deleteQuery);
		SMLog(kLogLevelError,@"METHOD:insertChatterDetailsIntoDBForWithId");
		SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:deleteQuery type:DELETEQUERY];
	}

    
    for ( int i = 0; i < [chatterDetails count]; i++ )
    {
        productId=[productId stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        NSString *body=[[[chatterDetails objectAtIndex:i]objectForKey:BODY] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        NSString *createdById=[[[chatterDetails objectAtIndex:i]objectForKey:CREATEDBYID] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        NSString *CreatedDate=[[[chatterDetails objectAtIndex:i]objectForKey:CREATEDDATE] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        NSString *_userid=[[[chatterDetails objectAtIndex:i]objectForKey:_USERID] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        NSString *postType=[[[chatterDetails objectAtIndex:i]objectForKey:POSTTYPE] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        NSString *userNameChatter=[[[chatterDetails objectAtIndex:i]objectForKey:USERNAME_CHATTER] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        NSString *eMail=[[[chatterDetails objectAtIndex:i]objectForKey:EMAIL] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        NSString *feedPostId=[[[chatterDetails objectAtIndex:i]objectForKey:FEEDPOSTID] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        NSString *fullPhotoUrl=[[[chatterDetails objectAtIndex:i]objectForKey:FULLPHOTOURL] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        NSMutableString *insertStatement = [NSString stringWithFormat:@"Insert into ChatterPostDetails (ProductId, Body, CreatedById, CreatedDate, Id, POSTTYPE, Username, Email, FeedPostId, FullPhotoUrl) Values ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@')", productId, body,createdById,CreatedDate,_userid,postType, userNameChatter,eMail,feedPostId,fullPhotoUrl];
        
        
        SMLog(kLogLevelVerbose,@"%@", insertStatement);
        
        
        int retVal = synchronized_sqlite3_exec(appDelegate.db, [insertStatement UTF8String], NULL, NULL, &err);
        SMLog(kLogLevelVerbose,@"%d", retVal);
        
        if (retVal != SQLITE_OK)
        {
            SMLog(kLogLevelError,@"%@", insertStatement);
			SMLog(kLogLevelError,@"METHOD: insertChatterDetailsIntoDBForWithId");
			SMLog(kLogLevelError,@"ERROR IN INSERTING %s", err);
            [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:insertStatement type:INSERTQUERY];
        }  
        
    
    }
    [appDelegate.dataBase endTransaction];
}


- (NSMutableArray *) retrieveChatterPostsFromDBForId:(NSString *)productId
{
    NSMutableArray *chatterArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    NSArray *keys = [[NSArray alloc]initWithObjects:BODY, CREATEDBYID, CREATEDDATE,_USERID, POSTTYPE, USERNAME_CHATTER, EMAIL, FEEDPOSTID,FULLPHOTOURL, nil];
// defect 007237
    productId=[productId stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    sqlite3_stmt *statement;
    NSMutableString *queryString = [NSString stringWithFormat:@"Select Body, CreatedById, CreatedDate, Id, POSTTYPE, Username, Email, FeedPostId,FullPhotoUrl From ChatterPostDetails            where productId = '%@'", productId];
    
    SMLog(kLogLevelVerbose,@"%@", queryString);
    
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, [queryString UTF8String], -1, &statement, nil ) == SQLITE_OK )
    { 
        while ( synchronized_sqlite3_step(statement) == SQLITE_ROW )
        {
            NSString *Body = @"";
            char *field = (char *) synchronized_sqlite3_column_text(statement, COLUMN_1);
            if ( field != nil )
                Body = [NSString stringWithUTF8String:field];
            
            
            NSString *CreatedById = @"";
            char *field1 = (char *) synchronized_sqlite3_column_text(statement, COLUMN_2);
            if ( field1 != nil )
                CreatedById = [NSString stringWithUTF8String:field1];
            
            NSString *CreatedDate = @"";
            char *field2 = (char *) synchronized_sqlite3_column_text(statement, COLUMN_3);
            if ( field2 != nil )
                CreatedDate = [NSString stringWithUTF8String:field2];
            
            NSString *Id = @"";
            char *field3 = (char *) synchronized_sqlite3_column_text(statement, COLUMN_4);
            if ( field3 != nil )
                Id = [NSString stringWithUTF8String:field3];
            
            NSString *_POSTTYPE = @"";
            char *field4 = (char *) synchronized_sqlite3_column_text(statement, COLUMN_5);
            if ( field4 != nil )
                _POSTTYPE = [NSString stringWithUTF8String:field4];
            
            NSString *Username = @"";
            char *field5 = (char *) synchronized_sqlite3_column_text(statement, COLUMN_6);
            if ( field5 != nil )
                Username = [NSString stringWithUTF8String:field5];
            
            NSString *Email = @"";
            char *field6 = (char *) synchronized_sqlite3_column_text(statement, COLUMN_7);
            if ( field6 != nil )
                Email = [NSString stringWithUTF8String:field6];
            
            NSString *FeedPostId = @"";
            char *field7 = (char *) synchronized_sqlite3_column_text(statement, COLUMN_8);
            if ( field7 != nil )
                FeedPostId = [NSString stringWithUTF8String:field7];
            
            NSString *FullPhotoUrl = @"";
            char *field8 = (char *) synchronized_sqlite3_column_text(statement, COLUMN_9);
            if ( field8 != nil )
                FullPhotoUrl = [NSString stringWithUTF8String:field8];
            
            
            NSArray *objects = [[NSArray alloc]initWithObjects:Body, CreatedById,CreatedDate,Id,_POSTTYPE,Username,Email,FeedPostId,FullPhotoUrl, nil];
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithObjects:objects forKeys:keys];
            
            [chatterArray addObject:dict];
            
            [dict release];
            [objects release];
        }
    }
    synchronized_sqlite3_finalize(statement);
    
    SMLog(kLogLevelVerbose,@"%@", chatterArray);
    
    return  chatterArray;
    
}

- (void) insertImageDataInChatterDetailsForUserName:(NSString *)UserName WithData:(NSData *)imageData
{
    [appDelegate.dataBase beginTransaction];
    // defect 007237
    UserName=[UserName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];

    NSMutableString *deleteQuery = [NSString stringWithFormat:@"Delete From UserImages Where username = '%@'", UserName];
    
	char *err;
    if (synchronized_sqlite3_exec(appDelegate.db, [deleteQuery UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"%@", deleteQuery);
		SMLog(kLogLevelError,@"ERROR IN DELETING %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:deleteQuery type:DELETEQUERY];
    }
   
    
    NSString * stringData = [Base64 encode:imageData];
    // UserImages (username, userimage)  Values('%@','%@')", UserName, imageData
    NSMutableString *queryString = [NSMutableString stringWithFormat:@"Insert into UserImages (username, userimage) Values ('%@', '%@')", UserName, stringData];
    
    SMLog(kLogLevelVerbose,@"%@", queryString);
    
    
    int retVal = synchronized_sqlite3_exec(appDelegate.db, [queryString UTF8String], NULL, NULL, &err);
    SMLog(kLogLevelVerbose,@"%d", retVal);
    
    if (retVal != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"%@", queryString);
		SMLog(kLogLevelError,@"METHOD: insertImageDataInChatterDetailsForUserName");
        SMLog(kLogLevelError,@"ERROR IN INSERTING %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:queryString type:INSERTQUERY];
    }
    
    [appDelegate.dataBase endTransaction];
}



- (NSData *) getImageDataForUserName:(NSString *)userName
{
    if ([userName length] == 0)
    {
        return NULL;
    }
    //defect 007237
    userName=[userName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];

    NSData * _data = nil;
    NSMutableString *query = [NSString stringWithFormat:@"Select userimage from UserImages where username = '%@'", userName];
    sqlite3_stmt *statement;
    
    
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, nil ) == SQLITE_OK )
    { 
        if ( synchronized_sqlite3_step(statement) == SQLITE_ROW )
        {
            const char * raw_data = (char *)synchronized_sqlite3_column_text(statement, 0);
            NSString * dataString = [NSString stringWithCString:raw_data encoding:NSUTF8StringEncoding];
            _data = [Base64 decode:dataString];
        }
    }
    synchronized_sqlite3_finalize(statement);
    
    if ( [_data length] != 0 )
        return _data;
    else
        return NULL;
}


- (void) insertProductPicture:(NSString *)pictureData ForId:(NSString *)productId
{
    [appDelegate.dataBase beginTransaction];
    // defect 007237
    productId=[productId stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    NSMutableString *deleteQuery = [NSString stringWithFormat:@"Delete From ProductImage Where productId = '%@'", productId];
    
    char *err;
    if (synchronized_sqlite3_exec(appDelegate.db, [deleteQuery UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"%@", deleteQuery);
		SMLog(kLogLevelError,@"METHOD: insertProductPicture");
        SMLog(kLogLevelError,@"ERROR IN INSERTING %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:deleteQuery type:DELETEQUERY];
    }
    
    NSMutableString *insertQuery = [NSString stringWithFormat:@"Insert into ProductImage (productId, productImage) Values ('%@', '%@')", productId, pictureData];
    SMLog(kLogLevelVerbose,@"%@", insertQuery);
    
    int retVal = synchronized_sqlite3_exec(appDelegate.db, [insertQuery UTF8String], NULL, NULL, &err);
    SMLog(kLogLevelVerbose,@"%d", retVal);
    
    if (retVal != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"%@", insertQuery);
		SMLog(kLogLevelError,@"METHOD: insertProductPicture");
        SMLog(kLogLevelError,@"ERROR IN INSERTING %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:insertQuery type:INSERTQUERY];
    }
    [appDelegate.dataBase endTransaction];
}


- (NSData *) getProductPictureForProductId:(NSString *)productId
{
    //defect 007237
    productId=[productId stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSMutableString *query = [NSString stringWithFormat:@"Select productImage from ProductImage where productId = '%@'", productId];
    sqlite3_stmt *statement;
    SMLog(kLogLevelVerbose,@"%@", query);
    
    NSData *data = [[NSData alloc]init];
    
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, nil ) == SQLITE_OK )
    { 
        if ( synchronized_sqlite3_step(statement) == SQLITE_ROW )
        {
            const char * raw_data = (char *)synchronized_sqlite3_column_text(statement, COLUMN_1);
            NSString * dataString = [NSString stringWithCString:raw_data encoding:NSUTF8StringEncoding];
            data = [Base64 decode:dataString];
        }
    }
    synchronized_sqlite3_finalize(statement);
    SMLog(kLogLevelVerbose,@"%@", data);
    if ( data != nil )
        return data;
    else
        return NULL;
}
//krishnaOPDOC
#pragma mark - OPDoc html data
- (void) insertOPDocHtmlData:(NSData *)htmlData WithId:(NSString *)docId localId:(NSString *)recordId  apiName:(NSString *)opdocApiName WONumber:(NSString *)WONumber docNsme:(NSString *)documentName forProcessId:(NSString *)processId
{
        
    NSString * queryStatement = @"";
    NSString * stringData = [Base64 encode:htmlData];
    
    BOOL does_exists = FALSE;
//kri OPDOC2
    //removed sign_type 
    does_exists = NO;// [self isDocExistsFor:recordId processId:processId tableName:@"SFOPDocHtmlData"]; // Damodar = Fix for last moment impl sum'13
    
    if (does_exists)
    {
        
        //where process id = sent process id
        queryStatement =[NSString stringWithFormat:@"UPDATE %@ SET %@ = '%@', %@ = '%@', %@ = '%@', %@ = '%@', %@ = '%@',%@ = '%@' WHERE local_id = '%@' and process_id = '%@'", @"SFOPDocHtmlData", @"sf_id", docId , @"object_api_name",opdocApiName, @"opdoc_data", stringData, @"WorkOrderNumber", WONumber,  @"local_id", recordId,@"doc_name",documentName,recordId,processId];
    }
    
    else
    {
        queryStatement = [NSString stringWithFormat:@"INSERT INTO SFOPDocHtmlData ('sf_id', 'object_api_name', 'opdoc_data', 'WorkOrderNumber', 'local_id','doc_name','process_id') VALUES ('%@','%@', '%@', '%@', '%@', '%@','%@')", docId, opdocApiName, stringData, WONumber, recordId,documentName,processId];
    }
    
    char *err;
    
    int ret = synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err);
    if (ret != SQLITE_OK)
    {
		if (does_exists)
		{
			SMLog(kLogLevelError,@"%@", queryStatement);
			SMLog(kLogLevelError,@"METHOD:inserthtmlintoDB " );
			SMLog(kLogLevelError,@"ERROR IN UPDATING %s", err);
            [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:queryStatement type:UPDATEQUERY];
		}
		else
		{
			SMLog(kLogLevelError,@"%@", queryStatement);
			SMLog(kLogLevelError,@"METHOD: inserthtmlintoDB");
			SMLog(kLogLevelError,@"ERROR IN INSERTING %s", err);
            [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:queryStatement type:INSERTQUERY];
            
		}
        
    }
    [appDelegate callDataSync];
}
////krishna opdoc defect 7800
- (void)deleteOPdocForName:(NSString *)opdocName {
    NSString * queryStatement = [NSString stringWithFormat:@"DELETE FROM SFOPDocHtmldata WHERE doc_name = '%@'",opdocName];
    
    char *err;
    if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"%@", queryStatement);
		SMLog(kLogLevelError,@"METHOD:deleteSignature");
		SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:queryStatement type:DELETEQUERY];
	}

}
//krishna offline opdoc
- (void)deleteOPDocSignatureForName:(NSString *)signName {
    NSString * queryStatement = [NSString stringWithFormat:@"DELETE FROM SFSignatureData WHERE signature_name = '%@'",signName];
    
    char *err;
    if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"%@", queryStatement);
		SMLog(kLogLevelError,@"METHOD:deleteSignature");
		SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:queryStatement type:DELETEQUERY];
	}
    
}

////krishna opdoc
- (void)deleteOpdocFor:(NSString *)SFID andProcessId:(NSString *)processId {
    
    NSString * queryStatement = [NSString stringWithFormat:@"DELETE FROM SFOPDocHtmldata WHERE process_id = '%@' and sf_id = '%@'",processId,SFID];
    
    char *err;
    if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"%@", queryStatement);
		SMLog(kLogLevelError,@"METHOD:deleteSignature");
		SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:queryStatement type:DELETEQUERY];
	}
}
//krishna opdoc added signName
- (NSMutableArray *) getAllOPDocsArray {
    
    NSString *selectQuery = [NSString stringWithFormat:@"Select local_id, object_api_name,process_id,doc_name From SFOPDocHtmlData"];
    sqlite3_stmt * stmt;
    
    NSMutableArray *docArray = [NSMutableArray array];
    NSString  * recordId = @"";
    NSString  * objectapiName = @"";
    NSString  * processID = @"";
    NSString  * docName = @"";
    
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
            
            [OPDOC_Data setObject:processID forKey:@"process_id"];
            [OPDOC_Data setObject:recordId forKey:@"record_id"];
            [OPDOC_Data setObject:objectapiName forKey:@"object_api_name"];
            [OPDOC_Data setObject:docName forKey:@"doc_name"];
            
            [docArray addObject:OPDOC_Data];
            [OPDOC_Data release];
            OPDOC_Data = nil;
            
            recordId = @"";
            objectapiName = @"";
            processID = @"";
            docName = @"";
        }
    }
    
     synchronized_sqlite3_finalize(stmt);
    
    return docArray;
    
}
//krishna OPDOC offline generation
- (void)replaceHtmlName:(NSString *)oldName InDBWithName:(NSString *)newName forLocalId:(NSString *)local andSFId:(NSString *)sfid {
    
    NSString *queryStatement = [NSString stringWithFormat:@"UPDATE SFOPDocHtmlData SET doc_name = '%@' WHERE local_id = '%@' and doc_name = '%@'",newName,local,oldName];
    char *err;
    
    int ret = synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err);
    if (ret != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"%@", queryStatement);
        SMLog(kLogLevelError,@"METHOD: replaceHtmlNameInDB");
        SMLog(kLogLevelError,@"ERROR IN REPLACING %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:queryStatement type:INSERTQUERY];
    }
    
}
- (void)replaceHtmlName:(NSString *)oldName inDocDirectoryWith:(NSString *)newName {
    
    NSString *documentDirectory = [appDelegate getAppCustomSubDirectory];//[docArrayPath objectAtIndex:0];
    
    NSString *oldfilePath = [documentDirectory stringByAppendingPathComponent:oldName];
    NSString *newFilePath = [documentDirectory stringByAppendingPathComponent:newName];
    
    
    NSFileManager *filemanager = [NSFileManager defaultManager];
    
    if([filemanager fileExistsAtPath:oldfilePath]) {
        
        [filemanager moveItemAtPath:oldfilePath toPath:newFilePath error:nil];
    }
}

- (NSString *)replaceSfid:(NSString *)sfid forLocalId:(NSString *)local inHtml:(NSString *)htmlName {
    
    NSString *html = [NSString stringWithString:htmlName];
    if(![sfid isEqualToString:@""] || sfid != nil)
    {
        html = [htmlName stringByReplacingOccurrencesOfString:local withString:sfid];
        [self replaceHtmlName:htmlName InDBWithName:html forLocalId:local andSFId:sfid];
        [self replaceHtmlName:htmlName inDocDirectoryWith:html];
    }
    return html;
}
//krishna opdoc added signName
-(void)syncOutPutDoc
{
    //get sf_id, wo name for all local_ids
    NSString * processId = @"";
    NSString * sf_id = @"";
    NSMutableArray *opdocsArray = [self getAllOPDocsArray];
    
    if((opdocsArray == nil) || ([opdocsArray count] == 0))
        appDelegate.wsInterface.didWriteOPDOC = YES;

    //To change the name in doc directory and DB
    //krishna OPDOc offline generation
    for(NSMutableDictionary *dict in opdocsArray) {
        
        NSString * obj_api_name = [dict objectForKey:@"object_api_name"];
        processId = [dict objectForKey:@"process_id"];
        NSString * localId = [dict objectForKey:@"record_id"];
        NSString * docName = [dict objectForKey:@"doc_name"];
        
        sf_id = [self getOPDocNameAndSFidforLocalId:localId  andObjectName:obj_api_name];//remove name, changed
        
        //8961 opdoc not generating pdf
        appDelegate.wsInterface.didWriteOPDOC = NO;
        
        //9007 dont generate if sfid is nil
        if((![sf_id isEqualToString:@""]) && (sf_id != nil) && ([sf_id length] > 0))
        {
            //krishna OPDOC offline generation
            docName = [self replaceSfid:sf_id forLocalId:localId inHtml:docName];
            [self attachHtmlDataTOSFDCForLocalId:localId sfid:sf_id opdocName:docName forProcessId:processId];
        }
        else {
            appDelegate.wsInterface.didWriteOPDOC = YES;
        }
    }
}
//krishna opdoc
- ( NSMutableDictionary *) getAllLocalIdsForOPDOCData
{

    NSString *selectQuery = [NSString stringWithFormat:@"Select local_id, object_api_name From SFOPDocHtmlData"];
    sqlite3_stmt * stmt;
    
    NSString  * recordId = @"";
    NSString  * objectapiName = @"";
    
    NSMutableDictionary * OPDOC_Data = [NSMutableDictionary dictionary];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char *field = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_1);
            if ( field != nil )
                recordId = [NSString stringWithUTF8String:field];
            
            char *field1 = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_2);
            if ( field1 != nil )
                objectapiName = [NSString stringWithUTF8String:field1];
            
            [OPDOC_Data setValue:objectapiName forKey:recordId];
        }
    }
    SMLog(kLogLevelVerbose,@"%@", OPDOC_Data);
    synchronized_sqlite3_finalize(stmt);
    
    return OPDOC_Data;
    
}
//krishna opdoc
- (NSString  *)getOPDocNameAndSFidforLocalId:(NSString *)localId andObjectName:(NSString *)objName {
    
    //010301:		OPDoc signatures saving as png files, not pdf.
    NSString *selectQuery = [NSString stringWithFormat:@"Select Id From '%@' Where local_id = '%@'", objName, localId];
    sqlite3_stmt * stmt;
    NSString *SFID = @"";
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char *field = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_1);
            if ( field != nil ) {
                SFID = [NSString stringWithUTF8String:field];
            }
        }
    }
    synchronized_sqlite3_finalize(stmt);
    return SFID;

}
//krishna opdoc docName
- (void) attachHtmlDataTOSFDCForLocalId:(NSString *)localId sfid:(NSString *)sfid opdocName:(NSString *)docName forProcessId:(NSString *)processId  {
        
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *saveDirectory = [appDelegate getAppCustomSubDirectory]; // [paths objectAtIndex:0];

    //TODO kri change the doc name
    NSString * newFilePath = [[saveDirectory stringByAppendingPathComponent:docName] retain];
    
    PDFCreator *pdfCreator = [[[PDFCreator alloc] init] autorelease] ;
    [pdfCreator removeAllPDF:docName];
    pdfCreator.delegate = self;
    //Radha 2/5/12
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:newFilePath];
    
    if (fileExists)
    {
        SMLog(kLogLevelVerbose,@"FILE EXISTS");
    }
    else
    {
    
        NSData * data = [self retrieveOPDOCData:localId];
        [data writeToFile:newFilePath atomically:YES];
        
    }

    [pdfCreator attachOPDOC:newFilePath andDocName:docName forSFId:sfid andProcessId:processId];
    
}
//krishna opdoc
- (void) opDocumentAttached:(NSString * )result withError:(NSError *)error forSFID:(NSString *)sfid andProcessID:(NSString *)processId forDocName:(NSString *)docname {
    //9007
    if(([result length] != 0) && (result != nil)) {
        
        //enter doc name into the file
        [appDelegate.dataBase insertIntoRequiredPdf:sfid processId:processId andAttachmentId:result];
        [self deleteOPdocForName:docname];

    }
    //8961 opdoc not generating pdf
    appDelegate.wsInterface.didWriteOPDOC = YES;
    //store the data in database in required pdf table
}
//krishna opdoc
- (NSMutableArray *) retrieveAllSignatureOfOutputDocForId:(NSString *)signId {
    
    NSMutableArray *signatureArray = [NSMutableArray array];
    
    NSString * selectQuery = [NSString stringWithFormat:@"Select signature_name From SFSignatureData Where sign_type = '%@' and signature_type_id Like '%@%%'", @"OPDOC",signId];
    sqlite3_stmt * statement;
    const char * _query = [selectQuery UTF8String];
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, _query,-1, &statement, nil) == SQLITE_OK ){
        
        while(synchronized_sqlite3_step(statement) == SQLITE_ROW){
            
            char *field1 = (char *) synchronized_sqlite3_column_text(statement,COLUMN_1);
            if (field1 != nil) {
                NSString *name = [NSString stringWithUTF8String:field1];
                if(name!=nil || ![name isEqualToString:@""]) {
                [signatureArray addObject:name];
                }
            }
        }
    }
    synchronized_sqlite3_finalize(statement);
    return signatureArray;
}
- (NSData *) retrieveOPDOCData:(NSString *)Id
{

    NSData * data;
    NSString *opdocData = @"";
    NSString * selectQuery = [NSString stringWithFormat:@"Select opdoc_data from SFOPDocHtmlData Where local_id = '%@'", Id];
    
    sqlite3_stmt * statement;
    const char * _query = [selectQuery UTF8String];
    
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, _query,-1, &statement, nil) == SQLITE_OK ){
        
        while(synchronized_sqlite3_step(statement) == SQLITE_ROW){
            
            char *field1 = (char *) synchronized_sqlite3_column_text(statement,COLUMN_1);
            if (field1 != nil)
                opdocData = [[NSString alloc] initWithUTF8String:field1];
            
        }
    }
    data = [Base64 decode:opdocData];
    synchronized_sqlite3_finalize(statement);
    return data;
}
//  Unused methods
//- (NSString *) getSFIdOfDocForlocalId:(NSString *)name
//{
//    NSString * selectQuery = [NSString stringWithFormat:@"Select sf_id From SFOPDocHtmlData Where doc_name = '%@'", name];
//    sqlite3_stmt * stmt;
//    NSString *SFID = @"";
//    
//    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, NULL) == SQLITE_OK)
//    {
//        if (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
//        {
//            char *field = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_1);
//            if ( field != nil )
//                SFID = [NSString stringWithUTF8String:field];
//        }
//    }
//    synchronized_sqlite3_finalize(stmt);
//    return SFID;
//}

-(NSString *)getOperationTypeForSignature:(NSString *)recordId  forObject:(NSString *)object_name
{
    
    NSString *  id_value  =  [appDelegate.databaseInterface  checkforSalesForceIdForlocalId:object_name local_id:recordId];
    
    id_value = [id_value stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    BOOL isSalesForceRecord = FALSE;
    
    if([id_value length] != 0)
    {
        // return TRUE;
        isSalesForceRecord = TRUE;
    }
    else
    {
        //return FALSE;
        isSalesForceRecord = FALSE;
        
    }

    if(isSalesForceRecord)
    {
        
        NSString * operationType = [self getRecordoperationTypeforSignaturewithRecordId:recordId objectApiNAme:object_name];
        return operationType;
    }
    else
    {
        return SIG_AFTERSYNC;
    }
}

-(NSString *)getRecordoperationTypeforSignaturewithRecordId:(NSString *)recordId  objectApiNAme:(NSString *)apiname
{
    NSString * query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE local_id = '%@' and operation = 'UPDATE' and object_name = '%@'", SFDATATRAILER, recordId, apiname];
    
    sqlite3_stmt * statement;
    
    int count = 0;
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            count = synchronized_sqlite3_column_int(statement, 0);
        }
    }
    
    synchronized_sqlite3_finalize(statement);
    
    if (count > 0)
        return SIG_AFTERUPDATE;
    else 
        return SIG_BEFOREUPDATE;
    
}

#pragma mark - Signature Controller
//krishna opdoc added signName
- (void) insertSignatureData:(NSData *)signatureData WithId:(NSString *)signatureId RecordId:(NSString *)recordId  apiName:(NSString *)oApiName WONumber:(NSString *)WONumber flag:(NSString *)sign_type andSignName:(NSString *)signName
{
    
    NSString * operation_type = [self getOperationTypeForSignature:recordId forObject:oApiName];
    
    NSString * queryStatement = @"";
    
    BOOL does_viewexists = FALSE;
    BOOL does_reportexists = FALSE;
    BOOL does_docexists = FALSE;
    
    NSString * stringData = [Base64 encode:signatureData];
// defect 007237
    signatureId=[signatureId stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    recordId =[recordId stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    [appDelegate.dataBase beginTransaction];
    if ([sign_type isEqualToString:@"ViewWorkOrder"])
        does_viewexists = [self isSignatureExists:recordId type:sign_type tableName:@"SFSignatureData"];
    else if ([sign_type isEqualToString:@"ServiceReport"])
        does_reportexists = [self isSignatureExists:recordId type:sign_type tableName:@"SFSignatureData"];
    else if([sign_type isEqualToString:@"OPDOC"])
    {
        
        NSArray *docArrayPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *documentDirectory = [appDelegate getAppCustomSubDirectory]; // [docArrayPath objectAtIndex:0];
        NSString *filePath = [documentDirectory stringByAppendingPathComponent:@"nonfinalized.plist"];
        
        NSFileManager *defMgr = [NSFileManager defaultManager];
        if(![defMgr fileExistsAtPath:filePath])
            does_docexists = NO;
        else
        {
            NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:filePath];
            
            NSString *str = [dict valueForKey:signatureId];
            
            if([str isEqualToString:@""] || str == nil)
            {
                does_docexists = NO;
            }
            else
            {
                does_docexists = YES;
            }
        }
        
        
        // Dam - signature sum'13
//        does_docexists = [self isSignatureExistsForOpDoc:signName type:sign_type tableName:@"SFSignatureData"];
        
        // plist is created only after finalize is clicked, but signature is taken on click of done.
        
//        if([appDelegate.dataBase isSignatureFinalized:[signName stringByAppendingPathExtension:@"png"]])
//            does_docexists = NO;
    }
    
    if ([sign_type isEqualToString:@"ViewWorkOrder"] || [sign_type isEqualToString:@"ServiceReport"]) {
        
        if (does_viewexists)
        {
            queryStatement =[NSString stringWithFormat:@"UPDATE %@ SET %@ = '%@', %@ = '%@', %@ = '%@', %@ = '%@', %@ = '%@', %@ = '%@' ,operation_type = '%@' WHERE record_id = '%@' AND sign_type = '%@'", @"SFSignatureData", @"sig_Id", signatureId , @"object_api_name",oApiName, @"signature_data", stringData, @"WorkOrderNumber", WONumber,  @"record_Id", recordId, @"sign_type", sign_type, operation_type, recordId, sign_type];
        }
        else
        {
            if (does_reportexists)
            {
                queryStatement =[NSString stringWithFormat:@"UPDATE %@ SET %@ = '%@', %@ = '%@', %@ = '%@', %@ = '%@', %@ = '%@', %@ = '%@' ,operation_type = '%@' WHERE record_id = '%@' AND sign_type = '%@'", @"SFSignatureData", @"sig_Id", signatureId , @"object_api_name",oApiName, @"signature_data", stringData, @"WorkOrderNumber", WONumber,  @"record_Id", recordId, @"sign_type", sign_type, operation_type,recordId, sign_type];
            }
            
            
            else
            {
                queryStatement = [NSString stringWithFormat:@"INSERT INTO %@ ('%@', '%@', '%@', '%@', '%@' ,'%@' ,'%@') VALUES ('%@','%@', '%@', '%@', '%@', '%@','%@')", @"SFSignatureData", @"sig_Id", @"object_api_name", @"signature_data", @"WorkOrderNumber", @"sign_type",  @"record_Id",@"operation_type", signatureId, oApiName, stringData, WONumber, sign_type, recordId,operation_type];
            }
            
        }
    }
    else if([sign_type isEqualToString:@"OPDOC"]) {
        
        NSArray *docArrayPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *documentDirectory = [appDelegate getAppCustomSubDirectory]; // [docArrayPath objectAtIndex:0];
        NSString *filePath = [documentDirectory stringByAppendingPathComponent:@"nonfinalized.plist"];

        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        NSFileManager *defMgr = [NSFileManager defaultManager];
        if(![defMgr fileExistsAtPath:filePath])
            [dict writeToFile:filePath atomically:NO];
        else
            dict = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
            

        //signature id is set to wonumber
        if (does_docexists) {
            NSString *oldsignName = [dict objectForKey:signatureId];
            queryStatement =[NSString stringWithFormat:@"UPDATE %@ SET %@ = '%@', %@ = '%@', %@ = '%@', %@ = '%@', %@ = '%@', %@ = '%@' ,operation_type = '%@',signature_name = '%@' WHERE signature_type_id = '%@' AND sign_type = '%@' and signature_name = '%@'", @"SFSignatureData", @"sig_Id", WONumber , @"object_api_name",oApiName, @"signature_data", stringData, @"WorkOrderNumber", WONumber,  @"record_Id", recordId, @"sign_type", sign_type, @"",signName,signatureId, sign_type, oldsignName];
            
        }
        else if(!does_docexists){
            
            queryStatement = [NSString stringWithFormat:@"INSERT INTO %@ ('%@', '%@', '%@', '%@', '%@' ,'%@' ,'%@','%@','%@') VALUES ('%@','%@', '%@', '%@', '%@', '%@','%@','%@','%@')", @"SFSignatureData", @"sig_Id", @"object_api_name", @"signature_data", @"WorkOrderNumber", @"sign_type",  @"record_Id",@"operation_type",@"signature_type_id",@"signature_name", WONumber, oApiName, stringData, WONumber, sign_type, recordId,@"",signatureId,signName];
            
        }
        [dict setObject:signName forKey:signatureId];
        [dict writeToFile:filePath atomically:NO];

    }
    char *err;
    
    int ret = synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err);
    if (ret != SQLITE_OK)
    {
		if (does_reportexists)
		{
			SMLog(kLogLevelError,@"%@", queryStatement);
			SMLog(kLogLevelError,@"METHOD:insertSignatureData " );
			SMLog(kLogLevelError,@"ERROR IN UPDATING %s", err);
            [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:queryStatement type:UPDATEQUERY];
		}
		else
		{
			SMLog(kLogLevelError,@"%@", queryStatement);
			SMLog(kLogLevelError,@"METHOD:insertSignatureData");
			SMLog(kLogLevelError,@"ERROR IN INSERTING %s", err);
            [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:queryStatement type:INSERTQUERY];

		}
    }
	
    [appDelegate.dataBase endTransaction];
	//10/07/2012  - Agreesive Sync for Work Order Signature.  #4740
	if ([sign_type isEqualToString:@"ViewWorkOrder"])
	{
		//RADHA Defect Fix 5542
		appDelegate.shouldScheduleTimer = YES;
		[appDelegate callDataSync];
	}

}
//krishnaOPdoc html data
//kri OPDOC2
- (BOOL)isDocExistsFor:(NSString *)local_id processId:(NSString *)process tableName:(NSString *)tableName {

    //kri OPDOC2
    //where process id is equal to process id
    NSString * query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE local_id = '%@' and process_id = '%@'", tableName, local_id, process];
    
    sqlite3_stmt * statement;
    
    int count = 0;
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            count = synchronized_sqlite3_column_int(statement, 0);
        }
    }
    
    synchronized_sqlite3_finalize(statement);
    if (count > 0)
        return TRUE;
    else
        return FALSE;

}

- (BOOL) isSignatureExistsForOpDoc:(NSString *)signId type:(NSString *)sign_type tableName:(NSString *)tableName {
    
    NSString * query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE signature_type_id = '%@'", tableName, signId];
    
    sqlite3_stmt * statement;
    
    int count = 0;
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            count = synchronized_sqlite3_column_int(statement, 0);
        }
    }
    
    synchronized_sqlite3_finalize(statement);
    if (count > 0)
        return TRUE;
    else
        return FALSE;

}
- (BOOL) isSignatureExists:(NSString *)local_id type:(NSString *)sign_type tableName:(NSString *)tableName
 {
 
    NSString * query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE record_id = '%@' and sign_type = '%@'", tableName, local_id, sign_type];
 
    sqlite3_stmt * statement;
 
    int count = 0;
 
     if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
     {
         while (synchronized_sqlite3_step(statement) == SQLITE_ROW)
         {
             count = synchronized_sqlite3_column_int(statement, 0);
         }
     }
     
     synchronized_sqlite3_finalize(statement);
     
     if (count > 0)
         return TRUE;
     else
         return FALSE;
 
 }


- (NSData *) retreiveSignatureimage:(NSString *)WONumber recordId:(NSString *)recordId
{
    sqlite3_stmt * stmt;
    NSData * data;
    NSString * stringData = @"";
    NSString * queryStatement = @"";
// defect 007237
    recordId=[recordId stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    queryStatement = [NSString stringWithFormat:@"SELECT %@ FROM SFSignatureData where record_Id = '%@' and sign_type = '%@'", @"signature_data", recordId, @"ServiceReport"];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(stmt) == SQLITE_ROW) 
        {
            const char * raw_data = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_1);
            if (raw_data != nil)
            {
                stringData = [NSString stringWithCString:raw_data encoding:NSUTF8StringEncoding];
                if ([stringData length] > 0)
                    data = [Base64 decode:stringData];
            }
        }
    }
    synchronized_sqlite3_finalize(stmt);
    if ([stringData length] > 0)
        return data;
    return nil;
}

- (void) deleteSignature:(NSString *)WONumber
{
    NSString * queryStatement = [NSString stringWithFormat:@"DELETE FROM SFSignatureData WHERE WorkOrderNumber = '%@'", WONumber];
    
    char *err;
    if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"%@", queryStatement);
		SMLog(kLogLevelError,@"METHOD:deleteSignature");
		SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:queryStatement type:DELETEQUERY];
	}
    
}
//krishnasign
- (void) deleteAllSignatureData:(NSString *)operationTYpe andSignType:(NSString *)signType
{
    NSString * queryStatement = @"";
    if ([signType isEqualToString:@"OPDOC"]) {
        queryStatement = [NSString stringWithFormat:@"DELETE From SFSignatureData where sign_type = '%@' ",signType];
    }
    else {
        queryStatement = [NSString stringWithFormat:@"DELETE From SFSignatureData where operation_type = '%@' ",operationTYpe];
    }
    char * err;
    if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"%@", queryStatement);
		SMLog(kLogLevelError,@"METHOD:deleteAllSignatureData");
		SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:queryStatement type:DELETEQUERY];

	}
}
//krishna opdoc
- (void) deleteSignatureForOPDocWhereLikeSignId:(NSString *)sign andSignType:(NSString *)signType {
    NSString * queryStatement = @"";
    if ([signType isEqualToString:@"OPDOC"]) {
        queryStatement = [NSString stringWithFormat:@"DELETE From SFSignatureData where sign_type = '%@' and signature_type_id like '%@%%' ",signType,sign];
    }
    char * err;
    if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"%@", queryStatement);
		SMLog(kLogLevelError,@"METHOD:deleteAllSignatureData");
		SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:queryStatement type:DELETEQUERY];
        
	}
}
//krishna opdoc
- (void) deleteOPDocSignatureForSignId:(NSString *)signId andSignType:(NSString *)signType {
   
    NSString * queryStatement = @"";
    if ([signType isEqualToString:@"OPDOC"]) {
        queryStatement = [NSString stringWithFormat:@"DELETE From SFSignatureData where sign_type = '%@' and signature_type_id = '%@' ",signType,signId];
    }
    char * err;
    if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"%@", queryStatement);
		SMLog(kLogLevelError,@"METHOD:deleteAllSignatureData");
		SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:queryStatement type:DELETEQUERY];
        
	}

}
- (void) deleteSignatureDataWRTId:(NSString *)local_id  type:(NSString *)operationType
{
    NSString * queryStatement = [NSString stringWithFormat:@"DELETE From SFSignatureData where operation_type = '%@' and record_Id = '%@' ",operationType, local_id];
    
    char * err;
    if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"%@", queryStatement);
		SMLog(kLogLevelError,@"METHOD:deleteAllSignatureData");
		SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:queryStatement type:DELETEQUERY];
		
	}
}

//####################################################################################//
                        //PLEASE CALL THIS METHODS ONCE DATA SYNC IS OVER
//Shrinivas - This method to be only called when Data Sync Over.

//krishnasignature opdaoc
- (void) getAllLocalIdsForSignature:(NSString *)operation_type andSignType:(NSString *)sigType
{
    //krishnasign
    NSString *selectQuery = @"";
    
    if([sigType isEqualToString:@"OPDOC"]) {
        
        selectQuery = [NSString stringWithFormat:@"Select record_Id, object_api_name,signature_name From SFSignatureData Where sign_type = '%@'",sigType];
    }
    else {
        //krishnasign
        selectQuery = [NSString stringWithFormat:@"Select record_Id, object_api_name,signature_type_id  From SFSignatureData Where sign_type = 'ViewWorkOrder' and operation_type = '%@'",operation_type];
    }
    sqlite3_stmt * stmt;
    
    NSString  * recordId = @"";
    NSString * objectapiName = @"";
    NSString *signatureTypeId = @"";
    
    NSMutableArray *opdocSignArray = [NSMutableArray array];
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            NSMutableDictionary * signatureData = [NSMutableDictionary dictionary];
            
            char *field = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_1);
            if ( field != nil )
                recordId = [NSString stringWithUTF8String:field];
            
            char *field1 = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_2);
            if ( field1 != nil )
                objectapiName = [NSString stringWithUTF8String:field1];
            
            //krishnasign : extra field which depicts the unique id for signature.
            char *field2 = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_3);
            if ( field2 != nil )
                signatureTypeId = [NSString stringWithUTF8String:field2];
            
            NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
            [tempDict setValue:objectapiName forKey:@"objectapiNameKey"];
            [tempDict setValue:signatureTypeId forKey:@"sigTypeId"];
            
            [signatureData setValue:tempDict forKey:recordId];
            [opdocSignArray addObject:signatureData];
            
            signatureTypeId = @"";
            objectapiName = @"";
        }
        
    }
    synchronized_sqlite3_finalize(stmt);
    
    NSString *objectName = @"";
    NSString *signatureID = @"";
   
    //krishnsign modified as to allow capablity to support multiple signature
    for(int k=0; k<[opdocSignArray count]; k++) {
        NSDictionary *dict = [opdocSignArray objectAtIndex:k];
        NSArray * allkeys = [dict allKeys];
        for (int i = 0; i < [allkeys count]; i++)
        {
            NSMutableDictionary *tempD = [dict objectForKey:[allkeys objectAtIndex:i]];
            objectName = [tempD valueForKey:@"objectapiNameKey"];
            signatureID = [tempD valueForKey:@"sigTypeId"];
            
            [self getSFIdForSignature:[allkeys objectAtIndex:i] objectName:objectName signatureTyprId:signatureID andSignType:sigType];
        }
    }
    //    else {
    //        NSArray * allkeys = [signatureData allKeys];
    //
    //        for (int i = 0; i < [allkeys count]; i++)
    //        {
    //
    //            [self getSFIdForSignature:[allkeys objectAtIndex:i] objectName:[signatureData objectForKey:[allkeys objectAtIndex:i]] andSignType:sigType];
    //        }
    //    }
    
    
    //clear all the database contents
    if(![sigType isEqualToString:@"OPDOC"])
    {
        [self deleteAllSignatureData:operation_type andSignType:sigType];
    }
    //clear all document folder (stored signatures)
    
    
    appDelegate.wsInterface.didWriteSignature = YES;
    appDelegate.wsInterface.didWriteSignatures = YES;
}

//krishnasign
- (void) getSFIdForSignature:(NSString *)localId objectName:(NSString *)objectName signatureTyprId:(NSString *)sigTypeId andSignType:(NSString *)sigType
{
    NSString *selectQuery = [NSString stringWithFormat:@"Select Id From '%@' Where local_id = '%@'", objectName, localId];
    sqlite3_stmt * stmt;
    NSString *SFID = @"";
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(stmt) == SQLITE_ROW) 
        {
            char *field = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_1);
            if ( field != nil )
                SFID = [NSString stringWithUTF8String:field];
        }
    }
    synchronized_sqlite3_finalize(stmt);
    NSString *updateQuery = [NSString stringWithFormat:@"Update SFSignatureData Set sig_Id = '%@' Where record_Id = '%@'", SFID, localId];
    
    char *err;
    
    [appDelegate.dataBase beginTransaction];
    if (synchronized_sqlite3_exec(appDelegate.db, [updateQuery UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
		SMLog(kLogLevelError,@"%@", updateQuery);
		SMLog(kLogLevelError,@"METHOD: getSFIdForSignature" );
		SMLog(kLogLevelError,@"ERROR IN UPDATING %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:updateQuery type:UPDATEQUERY];
    }
    else
    {
        NSString *signId = @"";
        //krishnasign
        if([sigType isEqualToString:@"OPDOC"]) {
        signId = sigTypeId;
        }
        if((![SFID isEqualToString:@""]) && (SFID != nil) && ([SFID length] > 0)) // Damodar : OPDoc - 8559
            [self writeSignatureToSFDC:SFID andSignType:sigType forSignId:signId];
    }
    [appDelegate.dataBase endTransaction];
}
//krishnasign
- (void) writeSignatureToSFDC:(NSString *)SFId andSignType:(NSString *)signType forSignId:(NSString *)signTypeId
{
    //Write the signature to SFDC
    NSString * signatureString = @"";
    
    NSString * uniqueId = @"";
    NSData * decryptedSignature;
    
    //krishnasign
    NSString *selectQuery = @"";
    if([signType isEqualToString:@"OPDOC"])
    {
       selectQuery = [NSString stringWithFormat:@"Select signature_data, record_Id from SFSignatureData Where sig_Id = '%@' and sign_type = '%@' and signature_name = '%@'", SFId,signType,signTypeId];
        
        sqlite3_stmt * stmt;
        
        if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, NULL) == SQLITE_OK)
        {
            while (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
            {
                char *field = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_1);
                if ( field != nil )
                    signatureString = [NSString stringWithUTF8String:field];
                
                char *field1 = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_2);
                if ( field1 != nil )
                    uniqueId = [NSString stringWithUTF8String:field1];
                
                NSData *signatureData;
                
                signatureData = [Base64 decode:signatureString];
                decryptedSignature = [signatureData AESDecryptWithPassphrase:@"hello123_!@#$%^&*()"];
                
                iOSInterfaceObject *iosInterface = [[iOSInterfaceObject alloc] init];
                [iosInterface setSignImageData:decryptedSignature WithId:SFId WithRecordId:uniqueId andSignId:signTypeId];
                
                [iosInterface release];
                
                signatureString = @"";
                uniqueId = @"";
                
            }
        }
        
        synchronized_sqlite3_finalize(stmt);
        return;
    }
    else
    {
        selectQuery = [NSString stringWithFormat:@"Select signature_data, record_Id from SFSignatureData Where sig_Id = '%@' and sign_type = 'ViewWorkOrder'", SFId];
        
        sqlite3_stmt * stmt;
        
        if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, NULL) == SQLITE_OK)
        {
            if (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
            {
                char *field = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_1);
                if ( field != nil )
                    signatureString = [NSString stringWithUTF8String:field];
                
                char *field1 = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_2);
                if ( field1 != nil )
                    uniqueId = [NSString stringWithUTF8String:field1];
            }
        }
        
        NSData *signatureData;
        
        signatureData = [Base64 decode:signatureString];
        decryptedSignature = [signatureData AESDecryptWithPassphrase:@"hello123_!@#$%^&*()"];
        
        iOSInterfaceObject *iosInterface = [[iOSInterfaceObject alloc] init];
        [iosInterface setSignImageData:decryptedSignature WithId:SFId WithRecordId:uniqueId andSignId:signTypeId];
        
        [iosInterface release];
        synchronized_sqlite3_finalize(stmt);
    }
}
//  Unused methods
//- (void) retrieveSignatureFromSFDC:(NSString *)ID
//{
//    NSString * _query = [[NSString stringWithFormat:@"SELECT Body FROM Attachment WHERE Id = '%@'", ID] retain];
//    
//    [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didQueryAttachmentForSignature:error:context:) context:nil];
//    
//    [_query release];
//}

- (void) didQueryAttachmentForSignature:(ZKQueryResult *)result error:(NSError *)error context:(id)context;
{
    SMLog(kLogLevelVerbose,@"%@", result);
    //Check if signature is Present If Present Delete the signature from Ipad.
}

//############################################################################################################//


/************************ PRODUCT MANUAL METHODS ************************/
#pragma mark - Product Manual
- (void) insertProductManualNameInDB:(NSDictionary *)manualInfo WithID:(NSString *)productID
{
    [appDelegate.dataBase beginTransaction];
    SMLog(kLogLevelVerbose,@"%@", manualInfo);
    for ( int i = 0; i < [manualInfo count]; i++ )
    {
       // NSMutableString *queryString = [NSMutableString stringWithFormat:@"Update trobleshootdata Set prod_manual_Id = '%@', prod_manual_name = '%@' Where ProductId = '%@'", 
                                        //[manualInfo objectForKey:@"ManId"],[manualInfo objectForKey:@"ManName"], productID];
        
        //Aparna
        //Fixed the defect: 6627 : By changing the tablename troubleshootdata to trobleshootdata
        //Fixed the defect: 6628: By changeing the query
        NSString *manId=[[manualInfo objectForKey:@"ManId"]stringByReplacingOccurrencesOfString:@"'" withString:@"''"];

        NSString *manName=[[manualInfo objectForKey:@"ManName"]stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        productID =[productID stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        NSString *deleteQuery = [NSString stringWithFormat:@"Delete From trobleshootdata where prod_manual_Id = '%@' and prod_manual_name = '%@' and ProductId = '%@'",
                                 manId,manName,productID]; //Keerti - 6592 - including manId and manName in where clause

        char *err;
        if (synchronized_sqlite3_exec(appDelegate.db, [deleteQuery UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
            SMLog(kLogLevelError,@"%@", deleteQuery);
			SMLog(kLogLevelError,@"METHOD:insertProductManualNameInDB");
			SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
            [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:deleteQuery type:DELETEQUERY];
        } 
        
        NSString *ManId= [[manualInfo objectForKey:@"ManId"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        NSString *ManName=[[manualInfo objectForKey:@"ManName"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        productID=[productID stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        NSMutableString *queryString = [NSMutableString stringWithFormat:@"Insert into trobleshootdata (prod_manual_Id,prod_manual_name, ProductId) Values('%@', '%@', '%@') ", 
                                        ManId,ManName,productID];
        
        if (synchronized_sqlite3_exec(appDelegate.db, [queryString UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
            SMLog(kLogLevelError,@"%@", queryString);
			SMLog(kLogLevelError,@"METHOD: insertProductManualNameInDB");
			SMLog(kLogLevelError,@"ERROR IN INSERTING %s", err);
            [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:queryString type:INSERTQUERY];
        }  
    }
    
    [appDelegate.dataBase endTransaction];
}

- (void) insertProductManualBody:(NSString *)manualBody WithId:(NSString *)ManId WithName:(NSString *)ManName
{
    manualBody=[manualBody stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    ManId=[ManId stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    ManName=[ManName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *updateString = [NSString stringWithFormat:@"Update trobleshootdata Set productmanbody = '%@' Where prod_manual_Id = '%@' and prod_manual_name = '%@'",manualBody, ManId, ManName];
    
    [appDelegate.dataBase beginTransaction];
    char *err;
    if (synchronized_sqlite3_exec(appDelegate.db, [updateString UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
		SMLog(kLogLevelError,@"%@", updateString);
		SMLog(kLogLevelError,@"METHOD: insertProductManualBody" );
		SMLog(kLogLevelError,@"ERROR IN UPDATING %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:updateString type:UPDATEQUERY];

    }
    [appDelegate.dataBase endTransaction];
}


- (NSMutableArray *) retrieveManualsForProductWithId:(NSString *)productId
{
    // defect 007237
    productId=[productId stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *queryString = [NSString stringWithFormat:@"Select prod_manual_name, prod_manual_Id from trobleshootdata Where ProductId = '%@'", productId];
    sqlite3_stmt * stmt;
    
    NSMutableArray *manualInfo = [[NSMutableArray alloc] initWithCapacity:0];
    NSArray *keys = [[NSArray alloc]initWithObjects:@"ManName", @"ManId", nil];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryString UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        //Aparna
        //Fixed defect: 6628: Replaced if with while
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            NSString *manName = @"";
            char *field = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_1);
            if ( field != nil )
                manName = [NSString stringWithUTF8String:field];
            
            
            NSString *manId = @"";
            char *field1 = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_2);
            if ( field1 != nil )
                manId = [NSString stringWithUTF8String:field1];
            
            
            NSArray *objects = [[NSArray alloc]initWithObjects:manName, manId, nil];
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithObjects:objects forKeys:keys];
            
            [manualInfo addObject:dict];
            
            [dict release];
            [objects release];
            
        }
    }
    synchronized_sqlite3_finalize(stmt);
    SMLog(kLogLevelVerbose,@"%@", manualInfo);
    return manualInfo;
}


- (NSData *) retrieveProductManualWithManID:(NSString *)Id  andManName:(NSString *)ManName
{
    sqlite3_stmt * stmt;
    NSData * data;
    NSString * ManData = @"";
    ManName=[ManName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString * queryStatement = [NSString stringWithFormat:@"SELECT productmanbody FROM trobleshootdata where prod_manual_Id = '%@' and prod_manual_name = '%@'", Id, ManName];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        //Aparna
        //Fixed defect: 6628: Replaced if with while
        while (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            const char * raw_data = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_1);
            if (raw_data != nil)
            {
                ManData = [NSString stringWithCString:raw_data encoding:NSUTF8StringEncoding];
                if ([ManData length] > 0)
                    data = [Base64 decode:ManData];
            }
        }
    }
    synchronized_sqlite3_finalize(stmt);
    
    if ([ManData length] > 0)
        return data;
    return nil;
}

#pragma mark - Trouble Shooting
/*###################################   TROUBLESHOOTING METHODS   ########################################*/

- (void) updateProductTableWithProductName:(NSString *)Name WithId:(NSString *)productId
{
    productId=[productId stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    Name=[Name stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSMutableString *deleteQuery = [NSString stringWithFormat:@"Delete from Product2 Where Id = '%@'", productId];
    
    char *err;
    if (synchronized_sqlite3_exec(appDelegate.db, [deleteQuery UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"%@", deleteQuery);
		SMLog(kLogLevelError,@"METHOD:updateProductTableWithProductName");
		SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:deleteQuery type:DELETEQUERY];
    } 
    
    NSMutableString *query = [NSString stringWithFormat:@"INSERT OR REPLACE INTO Product2 (Id, Name) VALUES ('%@', '%@')", productId, Name];
    
    
    if (synchronized_sqlite3_exec(appDelegate.db, [query UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"%@", query);
		SMLog(kLogLevelError,@"METHOD: updateProductTableWithProductName");
        SMLog(kLogLevelError,@"ERROR IN INSERTING %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:query type:INSERTQUERY];
    }
}


- (void) insertTroubleshootingIntoDB:(NSMutableArray *)troubleshooting
{
    [appDelegate.dataBase beginTransaction];
	//Change for Troubleshooting 22/06/2012
    for ( int i = 0; i < [troubleshooting count]; i++ )
    {
        NSMutableDictionary *dict = [troubleshooting objectAtIndex:i];
        // defect 007237
        NSString *doc_ID=[[dict objectForKey:DOCUMENTS_ID] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
		NSString * selectQuery = [NSString stringWithFormat:@"Select Name from Document where Id = '%@'", doc_ID];
		
		sqlite3_stmt * stmt;
		NSString * docName = @"";
		
		if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, NULL) == SQLITE_OK)
		{
			if (synchronized_sqlite3_step(stmt) == SQLITE_ROW) 
			{
				const char * _docName = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_1);
				if (_docName != nil)
				{
					docName = [NSString stringWithCString:_docName encoding:NSUTF8StringEncoding];
				}
			}
		}
		
        synchronized_sqlite3_finalize(stmt);
		
		if ([[dict objectForKey:DOCUMENTS_NAME] isEqualToString:docName])
		{
            NSString *DocName= [[dict objectForKey:DOCUMENTS_NAME] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString *DocKeyWord=[[dict objectForKey:DOCUMENTS_KEYWORDS] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString *docId=[[dict objectForKey:DOCUMENTS_ID] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
			NSMutableString *insertQuery = [NSString stringWithFormat:@"Update Document Set Id = '%@', Name = '%@', Keywords = '%@' Where Id = '%@'",docId,
											DocName,DocKeyWord,docId];
			
			char *err;
			if (synchronized_sqlite3_exec(appDelegate.db, [insertQuery UTF8String], NULL, NULL, &err) != SQLITE_OK)
			{
				SMLog(kLogLevelError,@"%@", insertQuery);
				SMLog(kLogLevelError,@"METHOD:insertTroubleshootingIntoDB " );
				SMLog(kLogLevelError,@"ERROR IN UPDATING %s", err);
                [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:insertQuery type:UPDATEQUERY];

			}  

		}else {
            NSString *DocName= [[dict objectForKey:DOCUMENTS_NAME] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString *DocKeyword=[[dict objectForKey:DOCUMENTS_KEYWORDS] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString *docId=[[dict objectForKey:DOCUMENTS_ID] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];

			NSMutableString *insertQuery = [NSString stringWithFormat:@"Insert into Document (Id, Name, Keywords) Values ('%@', '%@', '%@')",docId,
											DocName,DocKeyword];
			
			char *err;
			if (synchronized_sqlite3_exec(appDelegate.db, [insertQuery UTF8String], NULL, NULL, &err) != SQLITE_OK)
			{
				SMLog(kLogLevelError,@"%@", insertQuery);
				SMLog(kLogLevelError,@"METHOD: insertTroubleshootingIntoDB");
				SMLog(kLogLevelError,@"ERROR IN INSERTING %s", err);
                [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:insertQuery type:INSERTQUERY];

			}

		}
		
	}
    
    [appDelegate.dataBase endTransaction];
    
}

- (void) insertTroubleShoot:(NSMutableArray *)troubleshooting Body:(NSString *)Body
{
	@try{
    NSDictionary *dict = [troubleshooting objectAtIndex:0];
        // defect 007237
NSString *Doc_Name=[[dict objectForKey:DOCUMENTS_NAME] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *docId=[[dict objectForKey:DOCUMENTS_ID] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        
    NSMutableString *queryString = [NSString stringWithFormat:@"Update Document Set Body = '%@' Where Name = '%@' and Id = '%@'",Body,
                                    Doc_Name,docId]; 
    
    char *err;
    if (synchronized_sqlite3_exec(appDelegate.db, [queryString UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
		SMLog(kLogLevelError,@"%@", queryString);
		SMLog(kLogLevelError,@"METHOD: insertTroubleShoot" );
		SMLog(kLogLevelError,@"ERROR IN UPDATING %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:queryString type:UPDATEQUERY];
    }
	}@catch (NSException *exp) {
	SMLog(kLogLevelError,@"Exception Name CalendarDatabase :insertTroubleShoot %@",exp.name);
	SMLog(kLogLevelError,@"Exception Reason CalendarDatabase :insertTroubleShoot %@",exp.reason);
	[appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }

}




- (NSData *) selectTroubleShootingDataFromDBwithID:(NSString *)docID andName:(NSString *)name
{
    sqlite3_stmt *statement;
    name=[name stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    //defect 007237
    docID=[docID stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSMutableString *query = [NSString stringWithFormat:@"Select Body from Document where Id = '%@' and Name = '%@'", docID, name];
    
    SMLog(kLogLevelVerbose,@"%@", query);
    
    NSData *data = nil;
    
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, nil ) == SQLITE_OK )
    { 
        if ( synchronized_sqlite3_step(statement) == SQLITE_ROW )
        {
            const char * raw_data = (char *) synchronized_sqlite3_column_text(statement, COLUMN_1);
            if (raw_data != nil)
            {
                NSString * dataString = [NSString stringWithCString:raw_data encoding:NSUTF8StringEncoding];
                data = [Base64 decode:dataString];
            }
        }
        
    }
    synchronized_sqlite3_finalize(statement);
    if (data != nil)
        return data;
    else
        return NULL;
    
}


- (NSString *) getProductNameFromDbWithID:(NSString *)productId
{
    SMLog(kLogLevelVerbose,@"%@", productId);
    
    sqlite3_stmt *statement;
    NSMutableString *query = [NSString stringWithFormat:@"Select Name from Product2 where Id = '%@'", productId];
    
    SMLog(kLogLevelVerbose,@"%@", query);
    NSString *productName = @"";
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, nil ) == SQLITE_OK )
    { 
        while ( synchronized_sqlite3_step(statement) == SQLITE_ROW )
        {
            
            char *field = (char *) synchronized_sqlite3_column_text(statement, COLUMN_1);
            if ( field != nil )
                productName = [NSString stringWithUTF8String:field];
            
        }
    }
    synchronized_sqlite3_finalize(statement);
    
    statement = nil;
    
    if(productName == nil || [productName length] == 0)
    {
        NSString * query2 = [NSString stringWithFormat:@"Select value from LookUpFieldValue where Id = '%@'", productId];
        
        if ( synchronized_sqlite3_prepare_v2(appDelegate.db, [query2 UTF8String], -1, &statement, nil ) == SQLITE_OK )
        {
            while ( synchronized_sqlite3_step(statement) == SQLITE_ROW )
            {
                
                char *field = (char *) synchronized_sqlite3_column_text(statement, COLUMN_1);
                if ( field != nil )
                    productName = [NSString stringWithUTF8String:field];
                
            }
        }
        
        synchronized_sqlite3_finalize(statement);
    }
    return productName;
}



- (NSMutableArray *)getTroubleShootingForProductName:(NSString *)productString
{
    NSMutableArray *productInfo = [[[NSMutableArray alloc]initWithCapacity:0]autorelease];
    NSArray *keys = [[NSArray alloc]initWithObjects:DOCUMENTS_ID, DOCUMENTS_NAME, DOCUMENTS_KEYWORDS, nil];
    
    sqlite3_stmt *statement;
    productString=[productString stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString * query = [NSString stringWithFormat:@"SELECT Id, Name, Keywords from Document WHERE Keywords LIKE '%%%@%%'", productString];
    
    SMLog(kLogLevelVerbose,@"%@", query);
    
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, nil ) == SQLITE_OK )
    { 
        while ( synchronized_sqlite3_step(statement) == SQLITE_ROW )
        {
            NSString *productName = @"";
            char *field = (char *) synchronized_sqlite3_column_text(statement, COLUMN_1);
            if ( field != nil )
                productName = [NSString stringWithUTF8String:field];
            
            
            NSString *productId = @"";
            char *field1 = (char *) synchronized_sqlite3_column_text(statement, COLUMN_2);
            if ( field1 != nil )
                productId = [NSString stringWithUTF8String:field1];
            
            NSString *docId = @"";
            char *field2 = (char *) synchronized_sqlite3_column_text(statement, COLUMN_3);
            if ( field2 != nil )
                docId = [NSString stringWithUTF8String:field2];
            
            NSArray *objects = [[NSArray alloc]initWithObjects:productName, productId, docId, nil];
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithObjects:objects forKeys:keys];
            
            [productInfo addObject:dict];
            
            [dict release];
            [objects release];
        }
    }
    synchronized_sqlite3_finalize(statement);
    SMLog(kLogLevelVerbose,@"%@", productInfo);
    
    if ( [productInfo count] > 0 )
        return productInfo;
    else
        return NULL;
    
}

-(NSString *) getProductIdForName:(NSString *)productName
{
    productName=[productName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString * query = [NSString stringWithFormat:@"SELECT Id FROM Product2 WHERE Name = '%@'", productName];
    
    NSString * productId = @"";
    
    sqlite3_stmt *stmt;
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * _productId = (char *) synchronized_sqlite3_column_text(stmt, 0);
            if (_productId != nil && strlen(_productId))
                productId = [NSString stringWithUTF8String:_productId];
            else
                productId = @"";
        }
    synchronized_sqlite3_finalize(stmt);
    }
    
    sqlite3_stmt * stmt1;
    if ([productId isEqualToString:@""])
    {
        productName=[productName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        query = [NSString stringWithFormat:@"SELECT Id FROM LookUpFieldValue WHERE value = '%@'", productName];
        
        if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt1, NULL) == SQLITE_OK)
        {
            if (synchronized_sqlite3_step(stmt1) == SQLITE_ROW)
            {
                char * _productId = (char *) synchronized_sqlite3_column_text(stmt1, 0);
                if (_productId != nil && strlen(_productId))
                    productId = [NSString stringWithUTF8String:_productId];
                else
                    productId = @"";
            }
        }
    synchronized_sqlite3_finalize(stmt1);
    }
    return productId;
}

- (NSString *) getNameForSignature:(NSString *)objectName andId:(NSString *)recordId
{
    NSString * query = [NSString stringWithFormat:@"Select Name From '%@' Where local_id = '%@'", objectName, recordId];
    sqlite3_stmt *stmt;
    
    NSString *Name = @"";
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * _Name = (char *) synchronized_sqlite3_column_text(stmt, 0);
            if (_Name != nil && strlen(_Name))
                Name = [NSString stringWithUTF8String:_Name];
            else
                Name = @"";
        }
    }
    synchronized_sqlite3_finalize(stmt);
    return Name;
}

- (NSString *) getObjectLabel:(NSString *)objectName
{
    NSString * query = [NSString stringWithFormat:@"Select label From SFObject Where api_name = '%@'", objectName];
    sqlite3_stmt *stmt;
    
    NSString *Name = @"";
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * _Name = (char *) synchronized_sqlite3_column_text(stmt, 0);
            if (_Name != nil && strlen(_Name))
                Name = [NSString stringWithUTF8String:_Name];
            else
                Name = @"";
        }
    }
    synchronized_sqlite3_finalize(stmt);
    return Name;
}


//Shrinivas Data SyncUI methods 
- (NSMutableArray *) getConflictObjects
{
    NSString * selectQuery = [NSString stringWithFormat:@"Select DISTINCT object_name From sync_error_conflict"]; 
    sqlite3_stmt *stmt;
    NSMutableArray * objects = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * _objects = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_1);
            if (_objects != nil && strlen(_objects))
                [objects addObject:[NSString stringWithUTF8String:_objects]];
        }
    }
    
    synchronized_sqlite3_finalize(stmt);
    return [objects retain];
}

- (NSMutableArray *) getrecordIdsForObject:(NSString *)objectName
{
    
    //Radha 2012june11 11:23 AM
    NSArray  * keys = [NSArray arrayWithObjects:@"SFId",@"Error_message", @"record_type",@"sync_type",@"override_flag",@"error_type", @"local_id", nil];
    
    NSString * SFId = @"";
    
    NSString * errormsg = @"";
    
    NSString * record_type = @"";
    
    NSString * sync_type = @"";
    
    NSString * overrideFlag = @"";
    
    NSString * error_type = @"";
    
    NSString * local_id = @"";
    
    
    
    NSString * selectQuery = [NSString stringWithFormat:@"Select sf_id, error_message, record_type, sync_type, override_flag, error_type, local_id from sync_error_conflict Where object_name = '%@'", objectName];
    
    sqlite3_stmt *stmt;
    
    NSMutableArray * records = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    int ret = synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, NULL);
    
    if(ret == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * _records = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_1);
            
            if (_records != nil && strlen(_records))
                
                SFId = [NSString stringWithUTF8String:_records];
            
            
            char * _errormsg = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_2);
            
            if (_errormsg != nil && strlen(_errormsg))
                
                errormsg = [NSString stringWithUTF8String:_errormsg];
            
            char * _record_type = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_3);
            
            if (_record_type != nil && strlen(_record_type))
                
                record_type = [NSString stringWithUTF8String:_record_type];
            
            char * _sync_type = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_4);
            
            if (_sync_type != nil && strlen(_sync_type))
                
                sync_type = [NSString stringWithUTF8String:_sync_type];
            
            char * _override = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_5);
            
            if (_override != nil && strlen(_override))
                
                overrideFlag = [NSString stringWithUTF8String:_override];
            
            char * _error_type = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_6);
            
            if (_error_type != nil && strlen(_error_type))
                
                error_type = [NSString stringWithUTF8String:_error_type];
            
            char * _local_id = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_7);
            
            if (_local_id != nil && strlen(_local_id))
                
                local_id = [NSString stringWithUTF8String:_local_id];
            
            
            //RADHA 2012june11 11:27 AM
            NSArray * object = [[NSArray arrayWithObjects:SFId, errormsg,record_type,sync_type,overrideFlag,error_type, local_id, nil] retain];
            
            NSMutableDictionary * mDict = [[NSMutableDictionary alloc] initWithObjects:object forKeys:keys];
            
            SMLog(kLogLevelVerbose,@"%@", mDict);
            
            [records addObject:mDict];
            
            
            
            [mDict release];
            
        }
        
    }
    synchronized_sqlite3_finalize(stmt);
    SMLog(kLogLevelVerbose,@"%@", records);
    
    return records;
}

- (void) updateOverrideFlagWithObjectName:(NSString *)objectName andSFId:(NSString *)SFId WithStatus:(NSString *)status
{
    NSString * updateQuery = [NSString stringWithFormat:@"Update sync_error_conflict Set override_flag = '%@' Where object_name = '%@' and sf_id = '%@'",status, objectName, SFId]; 
    SMLog(kLogLevelVerbose,@"%@" , updateQuery);
    char *err;
    if (synchronized_sqlite3_exec(appDelegate.db, [updateQuery UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"%@", updateQuery);
		SMLog(kLogLevelError,@"METHOD:updateOverrideFlagWithObjectName " );
		SMLog(kLogLevelError,@"ERROR IN UPDATING %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:updateQuery type:UPDATEQUERY];
    }
}

- (NSString *)getLabelForObject:(NSString *)_objectName
{
    NSString * objectName = @"";
    NSString * selectQuery = [NSString stringWithFormat:@"Select label from SFObject where api_name = '%@'", _objectName];
    sqlite3_stmt *stmt;
    
    int ret = synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, NULL);
    if(ret == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * _objectname = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_1);
            if (_objectname != nil && strlen(_objectname))
                objectName = [NSString stringWithUTF8String:_objectname];
            
        }
    }

    synchronized_sqlite3_finalize(stmt);
    return objectName;
}

- (void) selectUndoneRecords
{
    NSArray  * keys = [NSArray arrayWithObjects:@"sf_id",@"object_name",@"local_id",@"sync_type", nil];
    NSString * sf_id = @"" , * local_id = @"";
    NSString * object_name = @"" , * sync_type = @"";
    
	//NEW QUERY TO SELECT THE RECORDS TO BE REMOVED FROM 
	 NSString * selectQuery = [NSString stringWithFormat:@"Select sf_id, object_name , local_id ,sync_type  from sync_error_conflict where override_flag = 'remove'"];
    sqlite3_stmt *stmt;
    NSMutableArray * records = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    int ret = synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, NULL);
    if(ret == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * _record_id = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_1);
            if (_record_id != nil && strlen(_record_id))
                sf_id = [NSString stringWithUTF8String:_record_id];
            
            char * _object_name = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_2);
            if (_object_name != nil && strlen(_object_name))
                object_name = [NSString stringWithUTF8String:_object_name];
            
            char * _local_id = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_3);
            if (_local_id != nil && strlen(_local_id))
                local_id = [NSString stringWithUTF8String:_local_id];
            
            char * _sync_type = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_4);
            if (_sync_type != nil && strlen(_sync_type))
                sync_type = [NSString stringWithUTF8String:_sync_type];
            
            
            NSArray * object = [[NSArray arrayWithObjects:sf_id, object_name,local_id, sync_type,nil] retain];
            NSMutableDictionary * mDict = [[NSMutableDictionary alloc] initWithObjects:object forKeys:keys];
            SMLog(kLogLevelVerbose,@"%@", mDict);
            [records addObject:mDict];
            
            [mDict release];
        }
    }
    synchronized_sqlite3_finalize(stmt);
    SMLog(kLogLevelVerbose,@"%@", records);
    for( int i=0; i < [records count]; i++)
    {
        NSString * temp_sf_id = [[records objectAtIndex:i]objectForKey:@"sf_id"];
        NSString * temp_local_id = [[records objectAtIndex:i]objectForKey:@"local_id"];
        NSString * temp_sync_type = [[records objectAtIndex:i]objectForKey:@"sync_type"];
        NSString * temp_object_name = [[records objectAtIndex:i]objectForKey:@"object_name"];
        
        
        if([temp_sync_type isEqualToString:PUT_INSERT])
        {
            [self deleteUndonerecordsWithId:temp_local_id  andObjectName:temp_object_name forField:@"local_id"];
        }
        else
        {
            [self deleteUndonerecordsWithId:temp_sf_id  andObjectName:temp_object_name forField:@"sf_id"];
        }
        
    }
}
- (void) deleteUndonerecordsWithId:(NSString *)ID andObjectName:(NSString *)objectname  forField:(NSString *)field_name
{
    NSString * deleteQuery = [NSString stringWithFormat:@"Delete from sync_error_conflict where %@ = '%@' and object_name = '%@'",field_name, ID, objectname];
    
    NSString * field_name_id ;
    
    if([field_name isEqualToString:@"sf_id"])
    {
        field_name_id = @"Id";
    }
    else
    {
        field_name_id = field_name;
    }
    
    NSString * _deleteQuery = [NSString stringWithFormat:@"Delete from '%@' where %@ = '%@'", objectname, field_name,ID];
    
    char *err;
    if (synchronized_sqlite3_exec(appDelegate.db, [deleteQuery UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"%@", deleteQuery);
		SMLog(kLogLevelError,@"METHOD:deleteUndonerecordsWithId");
		SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:deleteQuery type:DELETEQUERY];

    }
    
    if (synchronized_sqlite3_exec(appDelegate.db, [_deleteQuery UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"%@", _deleteQuery);
		SMLog(kLogLevelError,@"METHOD:deleteUndonerecordsWithId");
		SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:_deleteQuery type:DELETEQUERY];

    }
    
    
    //Sahana  Need to delete all the  trailer table values 
    NSString * delete_from_trailer = [NSString  stringWithFormat:@"DELETE FROM SFDataTrailer WHERE %@ = '%@' and object_name = '%@' ",field_name, ID, objectname];
    if(synchronized_sqlite3_exec(appDelegate.db, [delete_from_trailer UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
		SMLog(kLogLevelError,@"%@", delete_from_trailer);
		SMLog(kLogLevelError,@"METHOD:deleteUndonerecordsWithId");
		SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:delete_from_trailer type:DELETEQUERY];

	}
    
}

#pragma mark - PDFoffline to SFDC

- (void) insertPDFintoDB:(NSString *)pdf WithrecordId:(NSString *)record_Id apiName:(NSString *)apiname WOnumber:(NSString *)WO_number
{
    NSString * queryStatement = @"";
    
    NSData * fileData = [NSData dataWithContentsOfFile:pdf];
    NSString * stringData = [Base64 encode:fileData];
    
    BOOL does_exists = [self isSignatureExists:record_Id type:@"ServiceReport" tableName:@"Summary_PDF"];
    
    if (does_exists)
    {
        queryStatement = [NSString stringWithFormat:@"UPDATE %@ SET %@ = '%@', %@ = '%@', %@ = '%@', %@ = '%@',%@ = 'Service Report_%@.pdf' WHERE record_id = '%@' AND sign_type = '%@'", @"Summary_PDF", @"record_Id", record_Id, @"object_api_name", apiname, @"PDF_data", stringData, @"WorkOrderNumber", WO_number, @"pdf_name", WO_number, record_Id, @"ServiceReport"];
    }
    
    else
    {
        queryStatement =[NSString stringWithFormat:@"INSERT INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@') VALUES ('%@', '%@', '%@', '%@', '%@', 'Service Report_%@.pdf')", @"Summary_PDF", @"record_Id", @"object_api_name", @"PDF_data", @"WorkOrderNumber", @"sign_type",@"pdf_name", record_Id, apiname, stringData, WO_number, @"ServiceReport",WO_number];
    }
    
    char *err;
    
    int ret = synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err);
    if (ret != SQLITE_OK)
    {
		if (does_exists)
		{
			SMLog(kLogLevelError,@"%@", queryStatement);
			SMLog(kLogLevelError,@"METHOD:insertPDFintoDB " );
			SMLog(kLogLevelError,@"ERROR IN UPDATING %s", err);
            [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:queryStatement type:UPDATEQUERY];
		}
		else
		{
			SMLog(kLogLevelError,@"%@", queryStatement);
			SMLog(kLogLevelError,@"METHOD: insertPDFintoDB");
			SMLog(kLogLevelError,@"ERROR IN INSERTING %s", err);
            [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:queryStatement type:INSERTQUERY];

		}
        
    } 
}

- (void) getAllLocalIdsForPDF
{
    NSString *selectQuery = [NSString stringWithFormat:@"Select record_Id, object_api_name From Summary_PDF"]; 
    sqlite3_stmt * stmt;
    
    NSString  * recordId = @"";
    NSString  * objectapiName = @"";
    
    NSMutableDictionary * PDF_Data = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW) 
        {
            char *field = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_1);
            if ( field != nil )
                recordId = [NSString stringWithUTF8String:field];
            
            char *field1 = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_2);
            if ( field1 != nil )
                objectapiName = [NSString stringWithUTF8String:field1];
            
            [PDF_Data setValue:objectapiName forKey:recordId];
        }
    }
    SMLog(kLogLevelVerbose,@"%@", PDF_Data);
    synchronized_sqlite3_finalize(stmt);
    NSArray * allkeys = [PDF_Data allKeys];
    
    for (int i = 0; i < [allkeys count]; i++)
    {
        [self getSFIdForPDF:[allkeys objectAtIndex:i] objectName:[PDF_Data objectForKey:[allkeys objectAtIndex:i]]];
     
    }
    [self deletePDFFromDBWithId];
    [self deletePDFF];
    

    appDelegate.wsInterface.didWritePDF = YES;
}

- (void) deletePDFFromDBWithId
{
    NSString * selectQuery = [NSString stringWithFormat:@"Select PDF_Id from Summary_PDF"];
    sqlite3_stmt * stmt;
    NSMutableArray * SFID = [[NSMutableArray alloc] initWithCapacity:0];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(stmt) == SQLITE_ROW) 
        {
            char *field = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_1);
            if ( field != nil )
                [SFID addObject:[NSString stringWithUTF8String:field]];
        }
    }

    synchronized_sqlite3_finalize(stmt);
    
    SMLog(kLogLevelVerbose,@"%@", SFID);
    for (int i = 0; i < [SFID count]; i++)
    {
        NSString * deleteQuery = [NSString stringWithFormat:@"Delete from Summary_PDF where PDF_Id = '%@'",[SFID objectAtIndex:i]];
        
        char *err;
        if (synchronized_sqlite3_exec(appDelegate.db, [deleteQuery UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
            SMLog(kLogLevelError,@"%@", deleteQuery);
			SMLog(kLogLevelError,@"METHOD:deletePDFFromDBWithId");
			SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
            [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:deleteQuery type:DELETEQUERY];

			return;
        }
    }

}


- (void) getSFIdForPDF:(NSString *)localId objectName:(NSString *)objectName
{
    NSString *selectQuery = [NSString stringWithFormat:@"Select Id, Name From '%@' Where local_id = '%@'", objectName, localId];
    sqlite3_stmt * stmt;
    NSString *SFID = @"";
    NSString * Name = @"";
    NSString * serviceReport = [appDelegate.wsInterface.tagsDictionary objectForKey:PDF_SERVICE_REPORT];
    serviceReport=[serviceReport stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(stmt) == SQLITE_ROW) 
        {
            char *field = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_1);
            if ( field != nil )
                SFID = [NSString stringWithUTF8String:field];
            
            char * _name = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_2);
            if ( _name != nil )
                Name = [NSString stringWithUTF8String:_name];
        }
    }
    synchronized_sqlite3_finalize(stmt);
    NSString *updateQuery = [NSString stringWithFormat:@"Update Summary_PDF Set PDF_Id = '%@', WorkOrderNumber = '%@', pdf_name = '%@_%@.pdf'  Where record_Id = '%@'", SFID, Name,serviceReport, Name, localId];
    
    char *err;
    if (synchronized_sqlite3_exec(appDelegate.db, [updateQuery UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"%@", updateQuery);
		SMLog(kLogLevelError,@"METHOD:getSFIdForPDF " );
		SMLog(kLogLevelError,@"ERROR IN UPDATING %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:updateQuery type:UPDATEQUERY];
        return;
    }
    else
    { 
        [self writePDFToSFDC:SFID];
    }
}


- (NSString *) getSFIdForlocalId:(NSString *)sign_Type
{
    NSString * selectQuery = [NSString stringWithFormat:@"Select PDF_Id From Summary_PDF Where pdf_name = '%@'", sign_Type];
    sqlite3_stmt * stmt;
    NSString *SFID = @"";
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(stmt) == SQLITE_ROW) 
        {
            char *field = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_1);
            if ( field != nil )
                SFID = [NSString stringWithUTF8String:field];
        }
    }
    synchronized_sqlite3_finalize(stmt);
    return SFID;
}


- (void) writePDFToSFDC:(NSString *)SFId
{
    //Write the PDF to SFDC
    NSString * recordId  = @"";
    NSString * WO_Number = @"";
    NSString * _objectApiName = @"";
    NSString * PDF_name = @"";
    
    
    NSString * serviceReport = [appDelegate.wsInterface.tagsDictionary objectForKey:PDF_SERVICE_REPORT];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *saveDirectory = [appDelegate getAppCustomSubDirectory]; // [paths objectAtIndex:0];
    
    NSString * selectQuery = [NSString stringWithFormat:@"Select WorkOrderNumber, record_Id, object_api_name, pdf_name from Summary_PDF Where PDF_Id = '%@'", SFId];
    sqlite3_stmt * stmt;
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, NULL) == SQLITE_OK)
        
    {
        if (synchronized_sqlite3_step(stmt) == SQLITE_ROW) 
        {
            char * field = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_1);
            if ( field != nil )
                WO_Number = [NSString stringWithUTF8String:field];
            
            char * field1 = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_2);
            if ( field1 != nil )
                recordId = [NSString stringWithUTF8String:field1];
            
            char * field2 = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_3);
            if ( field2 != nil )
                _objectApiName = [NSString stringWithUTF8String:field2];
            
            char * field3 = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_4);
            if ( field3 != nil )
                PDF_name = [NSString stringWithUTF8String:field3];
        }
    }
    
   
    NSString * saveFileName = [[NSString stringWithFormat:@"%@_%@.pdf",serviceReport, WO_Number] retain];
    NSString * newFilePath = [[saveDirectory stringByAppendingPathComponent:saveFileName] retain];
    
    PDFCreator *pdfCreator = [[PDFCreator alloc] init];
    [pdfCreator removeAllPDF:saveFileName];
    
    
    //Radha 2/5/12
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:newFilePath];
    
    if (fileExists)
    {
        SMLog(kLogLevelVerbose,@"FILE EXISTS");
    }
    else
    {
        newFilePath = @"";
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *saveDirectory = [appDelegate getAppCustomSubDirectory]; // [paths objectAtIndex:0];
        NSString * serviceReport = [appDelegate.wsInterface.tagsDictionary objectForKey:PDF_SERVICE_REPORT];
        saveFileName = [[NSString stringWithFormat:@"%@_%@.pdf",serviceReport, WO_Number] retain];
        newFilePath = [saveDirectory stringByAppendingPathComponent:saveFileName];  
        
        NSData * data = [self retrievePdfData:recordId];
        [data writeToFile:newFilePath atomically:YES];
        
        
    }
    
    [pdfCreator attachPDF:newFilePath];
    
    synchronized_sqlite3_finalize(stmt);
}

- (void) deletePDFF
{
    NSString * queryStatement = [NSString stringWithFormat:@"DELETE From Summary_PDF"];
    
    char * err;
    if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
		SMLog(kLogLevelError,@"%@", queryStatement);
		SMLog(kLogLevelError,@"METHOD:deletePDFF");
		SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:queryStatement type:DELETEQUERY];

    }
}
    
- (NSString *)getnameFieldForObject:(NSString *)objectName WithId:(NSString *)SFId WithApiName:(NSString *)api_name
{
    NSString * selectQuery = [NSString stringWithFormat:@"Select %@ From '%@' Where Id = '%@'", api_name, objectName, SFId];
    NSString * Name = @"";
    sqlite3_stmt *stmt;
    
    int ret = synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, NULL);
    if(ret == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * _objectname = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_1);
            if (_objectname != nil && strlen(_objectname))
                Name = [NSString stringWithUTF8String:_objectname];
            
        }
    }
    synchronized_sqlite3_finalize(stmt);
    return Name;
}

- (NSString *)getOverrideFlagStatusForId:(NSString *)Id
{
    NSString * selectQuery = [NSString stringWithFormat:@"Select override_flag from sync_error_conflict where sf_id = '%@'", Id]; 
    
    NSString * flag = @"";
    sqlite3_stmt *stmt;
    
    int ret = synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, NULL);
    if(ret == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * _objectname = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_1);
            if (_objectname != nil && strlen(_objectname))
                flag = [NSString stringWithUTF8String:_objectname];
            
        }
    }
    
    synchronized_sqlite3_finalize(stmt);
    return flag;
}


//Contact Image offline Methods
- (void)insertContactImageIntoDatabase:(NSString *)contactId andContactImageData:(NSString *)imageData
{
    contactId=[contactId stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString * insertQuery = [NSString stringWithFormat:@"Insert into contact_images (contact_Id, contact_Image) Values ('%@', '%@')", contactId, imageData];
    
    char *err;
    if (synchronized_sqlite3_exec(appDelegate.db, [insertQuery UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"%@", insertQuery);
		SMLog(kLogLevelError,@"METHOD: insertContactImageIntoDatabase");
        SMLog(kLogLevelError,@"ERROR IN INSERTING %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:insertQuery type:INSERTQUERY];

    }

    
}

- (NSString *)retrieveContactImageDataFromDb:(NSString *)contactId
{
    NSString * contactImageData = @"";  
    NSString * selectQuery = [NSString stringWithFormat:@"Select contact_Image from contact_images Where contact_Id = '%@'", contactId];
    
    sqlite3_stmt * statement;
    const char * _query = [selectQuery UTF8String];
    
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, _query,-1, &statement, nil) == SQLITE_OK ){
        
        while(synchronized_sqlite3_step(statement) == SQLITE_ROW){
            
            char *field1 = (char *) synchronized_sqlite3_column_text(statement,COLUMN_1);
            contactImageData = [[NSString alloc] initWithUTF8String:field1];
            
        }
    }
    
    synchronized_sqlite3_finalize(statement);
    
    return contactImageData;
}


- (NSData *) retrievePdfData:(NSString *)Id
{
    NSData * data;
    NSString *pdfData = @"";
    NSString * selectQuery = [NSString stringWithFormat:@"Select PDF_data from Summary_PDF Where record_Id = '%@'", Id];
    
    sqlite3_stmt * statement;
    const char * _query = [selectQuery UTF8String];
    
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, _query,-1, &statement, nil) == SQLITE_OK ){
        
        while(synchronized_sqlite3_step(statement) == SQLITE_ROW){
            
            char *field1 = (char *) synchronized_sqlite3_column_text(statement,COLUMN_1);
            if (field1 != nil)
                pdfData = [[NSString alloc] initWithUTF8String:field1];
            
        }
    }
    data = [Base64 decode:pdfData];
    synchronized_sqlite3_finalize(statement);
    return data;
}


#pragma mark - Internet Conflict Handling

- (void) insertIntoConflictInternetErrorWithSyncType:(NSString *)sync_type
{
    NSString * str = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_no_internet];
    str=[str stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
	[self removeInternetConflicts]; //Fix for Internet Conflicts : 12/06/212  12:43 PM

	
    NSString * insertQuery = [NSString stringWithFormat:@"Insert into internet_conflicts (sync_type, error_message, operation_type, error_type) Values ('%@', '%@', 'Sync', 'Conflict')", sync_type, str];
     char *err;
    
    if (synchronized_sqlite3_exec(appDelegate.db, [insertQuery UTF8String], NULL, NULL, &err) != SQLITE_OK){
        
        SMLog(kLogLevelError,@"%@", insertQuery);
		SMLog(kLogLevelError,@"METHOD: insertIntoConflictInternetErrorWithSyncType");
        SMLog(kLogLevelError,@"ERROR IN INSERTING %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:insertQuery type:INSERTQUERY];

    }
}

- (void) insertIntoConflictInternetErrorForMetaSync:(NSString *)sync_type WithDB:(sqlite3 *)db
{
    NSString * str = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_no_internet];
    str=[str stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString * insertQuery = [NSString stringWithFormat:@"Insert into internet_conflicts (sync_type, error_message, operation_type, error_type) Values ('%@', '%@', 'Sync', 'Conflict')", sync_type, str];
    char *err;
    
    if (synchronized_sqlite3_exec(db, [insertQuery UTF8String], NULL, NULL, &err) != SQLITE_OK){
        
        SMLog(kLogLevelError,@"%@", insertQuery);
		SMLog(kLogLevelError,@"METHOD: insertIntoConflictInternetErrorForMetaSync");
        SMLog(kLogLevelError,@"ERROR IN INSERTING %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:insertQuery type:INSERTQUERY];
        
    }

}


- (NSMutableArray *) getInternetConflicts
{
    
    NSString * selectQuery = [NSString stringWithFormat:@"Select sync_type, error_message from internet_conflicts"];
    NSArray  * keys = [NSArray arrayWithObjects:@"Error_message",@"sync_type",nil];
    
    NSString * sync_type = @"";
    NSString * error_message = @"";
        
    NSMutableArray * internetConflict = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    sqlite3_stmt * statement;
    
    const char * _selectQuery = [selectQuery UTF8String];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, _selectQuery,-1, &statement, nil) == SQLITE_OK)
    {
                
        while(synchronized_sqlite3_step(statement) == SQLITE_ROW){
        char *field1 = (char *) synchronized_sqlite3_column_text(statement,COLUMN_1);
            
        if (field1 != nil)
            
        sync_type = [[NSString alloc] initWithUTF8String:field1];
        
        char *field2 = (char *) synchronized_sqlite3_column_text(statement,COLUMN_2);
        
        if (field2 != nil)
            error_message = [[NSString alloc] initWithUTF8String:field2];
        
        NSArray * object = [[NSArray arrayWithObjects:sync_type, error_message, nil] retain];
        
        NSMutableDictionary * mDict = [[NSMutableDictionary alloc] initWithObjects:object forKeys:keys];
        
        
        
        SMLog(kLogLevelVerbose,@"%@", mDict);
        [internetConflict addObject:mDict];
                
        [mDict release];
        [object release];
            
        }
        
    }
    
    synchronized_sqlite3_finalize(statement);
    return internetConflict;
}

- (void) removeInternetConflicts
{
    NSString * deleteQuery = [NSString stringWithFormat:@"Delete from internet_conflicts"];
    
    char *err;
    
    if (synchronized_sqlite3_exec(appDelegate.db, [deleteQuery UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"%@", deleteQuery);
		SMLog(kLogLevelError,@"METHOD:removeInternetConflicts");
		SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:deleteQuery type:DELETEQUERY];

    }

}

#pragma mark - Meta Sync Status

-(void) insertMetaSyncStatus:(NSString *)status WithDB:(sqlite3 *)db
{
    NSString * deleteQuery = [NSString stringWithFormat:@"Delete from meta_sync_status"];
     char *err;
    
    if (synchronized_sqlite3_exec(db, [deleteQuery UTF8String], NULL, NULL, &err) != SQLITE_OK){
        
        SMLog(kLogLevelError,@"%@", deleteQuery);
		SMLog(kLogLevelError,@"METHOD:insertMetaSyncStatus");
		SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:deleteQuery type:DELETEQUERY];

        
    }

    NSString * insertQuery = [NSString stringWithFormat:@"INSERT OR REPLACE INTO meta_sync_status (sync_status) Values ('%@')", status];
    
    
    if (synchronized_sqlite3_exec(db, [insertQuery UTF8String], NULL, NULL, &err) != SQLITE_OK){
        
        SMLog(kLogLevelError,@"%@", insertQuery);
		SMLog(kLogLevelError,@"METHOD: insertMetaSyncStatus");
        SMLog(kLogLevelError,@"ERROR IN INSERTING %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:insertQuery type:INSERTQUERY];
   
    }

}

-(NSString *)retrieveMetaSyncStatus
{
    NSString * sync_Status = @"";
    NSString * selectQuery = [NSString stringWithFormat:@"Select sync_status from meta_sync_status"];
    
    sqlite3_stmt * statement;
    
    const char * _selectQuery = [selectQuery UTF8String];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, _selectQuery,-1, &statement, nil) == SQLITE_OK)
    {
        
        while(synchronized_sqlite3_step(statement) == SQLITE_ROW){
            char *field1 = (char *) synchronized_sqlite3_column_text(statement,COLUMN_1);
            if (field1 != nil)
                sync_Status = [[NSString alloc] initWithUTF8String:field1];
            
        }
        
    }
    synchronized_sqlite3_finalize(statement);
    return sync_Status;
}

- (NSString *) getApi_NameWithReference:(NSString *)reference_to
{
	NSString * api_name = @"";
	NSString * label = [NSString new];
	NSString * final_api_name = @"";
	
	NSMutableArray * apiArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
	
	NSString * selectQuery = [NSString stringWithFormat:@"Select DISTINCT api_name,label from SFObjectField where object_api_name = 'SVMXC__Service_Order__c' and reference_to = '%@'", reference_to];
	
	sqlite3_stmt * statement;
    
    const char * _selectQuery = [selectQuery UTF8String];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, _selectQuery,-1, &statement, nil) == SQLITE_OK)
    {
        
        while(synchronized_sqlite3_step(statement) == SQLITE_ROW){
            char * field1 = (char *) synchronized_sqlite3_column_text(statement, COLUMN_1);
            if (field1 != nil)
			{
                api_name = [[NSString alloc] initWithUTF8String:field1];
				[apiArray addObject:api_name];
			}
			
			char * field2 = (char *) synchronized_sqlite3_column_text(statement, COLUMN_2);
            if (field2 != nil)
			{
                if(label)
                    [label release];
                
                label = [[NSString alloc] initWithUTF8String:field2];
				[apiArray addObject:label];
			}
            
			if ([api_name Contains:@"SVMXC"] && [reference_to Contains:label])
			{
				final_api_name = api_name;
			}
        }
    }
    if(label)
        [label release];
	synchronized_sqlite3_finalize(statement);
	return final_api_name;
}

- (NSString *)getFieldValueFromTable:(NSString *)field_name
{
	NSString * value = @"";
	NSString * selectQuery = [NSString stringWithFormat:@"Select %@ from SVMXC__Service_Order__c where local_id = '%@'", field_name, appDelegate.sfmPageController.recordId];
	
	sqlite3_stmt * statement;
    const char * _selectQuery = [selectQuery UTF8String];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, _selectQuery,-1, &statement, nil) == SQLITE_OK)
    {
        
        while(synchronized_sqlite3_step(statement) == SQLITE_ROW){
            char * field1 = (char *) synchronized_sqlite3_column_text(statement, COLUMN_1);
            if (field1 != nil)
                value = [[NSString alloc] initWithUTF8String:field1];
            
        }
        
    }
	synchronized_sqlite3_finalize(statement);
	return value;
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
	synchronized_sqlite3_finalize(statement);
	return Id;
}

- (BOOL) selectCountFromSync_Conflicts
{
	NSString * query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM sync_error_conflict"];
	
	sqlite3_stmt * statement;
	
    int count = 0;
	
	if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
	{
		while (synchronized_sqlite3_step(statement) == SQLITE_ROW)
		{
			count = synchronized_sqlite3_column_int(statement, 0);
		}
	}
    synchronized_sqlite3_finalize(statement);

	
	if (count > 0)
		return TRUE;
	else 
		return FALSE;

}

-(NSArray *) sortPickListUsingIndexes:(NSArray *)pickListArray WithfieldAPIName:(NSString *)fieldAPIName tableName:(NSString *)_SFPicklist objectName:(NSString *)headerObjName
{
	NSString * selectQuery = [NSString stringWithFormat:@"SELECT label , value, index_value  FROM '%@' WHERE object_api_name = '%@'  and field_api_name = '%@' ",_SFPicklist , headerObjName, fieldAPIName];
	
	NSMutableArray * allValuesArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
	
	sqlite3_stmt * stmt ;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, nil) == SQLITE_OK  )
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            NSString * label = @"" , * value = @"";
			
            char * temp_label = (char *)synchronized_sqlite3_column_text(stmt, 0);
            char * temp_value = (char *)(char*)synchronized_sqlite3_column_text(stmt, 1);
			int index = synchronized_sqlite3_column_int(stmt, 2);
			
            if(temp_label != nil)
            {
                label = [NSString stringWithUTF8String:temp_label];
            }
            if(temp_value != nil)
            {
                value = [NSString stringWithUTF8String:temp_value];
            }
            
            [allValuesArray insertObject:label atIndex:index];
        }
		
		synchronized_sqlite3_finalize(stmt);
    }
    
    return [allValuesArray retain];
}

/* GET_PRICE_JS-shr*/
#pragma mark -
#pragma mark GET PRICE BOOK
- (NSArray *)getPriceBook:(NSDictionary *)currentContext {
    
    
    NSMutableArray *priceBookArray = [[NSMutableArray alloc] init];
    
    @try {
        NSAutoreleasePool *outerPool = [[NSAutoreleasePool alloc] init];
        
        
        /* get record type ids  */
        NSArray *recordTypes = [NSArray arrayWithObjects:@"Usage/Consumption",@"Estimate",nil];
        NSDictionary *recordTypeIds =  [self getRecordTypeIdsForRecordType:recordTypes];
        
        NSMutableArray *someARrayNew = [[NSMutableArray alloc] init];
        
        NSString *usage = [recordTypeIds objectForKey:@"Usage/Consumption"];
        NSDictionary *someDictionary  = [NSDictionary dictionaryWithObjectsAndKeys: @"Usage/Consumption",@"key",usage,@"value", nil];
        [someARrayNew addObject:someDictionary];
        
        NSString *estimate = [recordTypeIds objectForKey:@"Estimate"];
        someDictionary  = [NSDictionary dictionaryWithObjectsAndKeys: @"Estimate",@"key",estimate,@"value", nil];
        [someARrayNew addObject:someDictionary];
        
        NSDictionary *finalDictOne = [[NSDictionary alloc] initWithObjectsAndKeys:@"RECORDTYPEDEFINITION",@"key",someARrayNew,@"valueMap", nil];
        [priceBookArray addObject:finalDictOne];
        
        [someARrayNew release];
        someARrayNew = nil;
        [finalDictOne release];
        finalDictOne = nil;
        
        NSMutableArray *partsPriceBookNames = [[NSMutableArray alloc] init];
        NSMutableArray *labourPriceBookNames = [[NSMutableArray alloc] init];
        NSMutableArray *partsPriceBookIdsArray = [[NSMutableArray alloc] init];
        NSMutableArray *labourPriceBookIdsArray = [[NSMutableArray alloc] init];
        NSMutableArray *namedExpressionArray = [[NSMutableArray alloc] init];
        
        NSString *pbPartsEstimateName =  [self getPricebookInformationForSettingId:@"WORD005_SET006"];
        if (pbPartsEstimateName != nil) {
            [partsPriceBookNames addObject:pbPartsEstimateName];
            
        }
        NSString *pbLabourEstimateName =  [self getPricebookInformationForSettingId:@"WORD005_SET018"];
        if (pbLabourEstimateName != nil) {
            [labourPriceBookNames addObject:pbLabourEstimateName];
        }
        
        NSString *pbPartsUsageName =  [self getPricebookInformationForSettingId:@"WORD005_SET004"];
        if (pbPartsUsageName != nil) {
            [partsPriceBookNames addObject:pbPartsUsageName];
        }
        NSString *pbLabourUsageName =  [self getPricebookInformationForSettingId:@"WORD005_SET017"];
        if (pbLabourUsageName != nil) {
            [labourPriceBookNames addObject:pbLabourUsageName];
        }
        
       /* get the header and detail records*/
        NSDictionary *headerRecord =  [currentContext objectForKey:@"headerRecord"];
        NSArray *detailRecords = [currentContext objectForKey:@"detailRecords"];
        
        NSArray *recordsArr = [headerRecord objectForKey:@"records"];
        if ([recordsArr count] <= 0) {
            return nil;
        }
        
        NSDictionary *headerDataDictionary = [recordsArr objectAtIndex:0];
        NSString *targetRecordId = [headerDataDictionary objectForKey:@"targetRecordId"];
        NSArray *headerFieldArray =  [headerDataDictionary objectForKey:@"targetRecordAsKeyValue"];
        NSString *currencyCode =  [self getValueFOrKey:@"CurrencyIsoCode" FromArray:headerFieldArray]; 
        if ([Utility isStringEmpty:currencyCode]) {
            currencyCode = nil;
        }
        NSString *workOrderProduct = [self getValueFOrKey:@"SVMXC__Product__c" FromArray:headerFieldArray];
        NSMutableArray *productsArray = [[NSMutableArray alloc] init];
        NSMutableArray *labourArray = [[NSMutableArray alloc] init];
        NSMutableArray *labourPartsArray = [[NSMutableArray alloc] init];
        
        
        
        for(int counter = 0;counter < [detailRecords count];counter++){
            
            NSDictionary *detailTargetDictionary = [detailRecords objectAtIndex:counter];
            NSArray *records = [detailTargetDictionary objectForKey:@"records"];
            for(int counter = 0;counter < [records count];counter++){
                
                NSDictionary *recordDict = [records objectAtIndex:counter];
                NSArray *detalFiledsArray = [recordDict objectForKey:@"targetRecordAsKeyValue"];
                
                NSString *productId =  [self getValueFOrKey:@"SVMXC__Product__c" FromArray:detalFiledsArray];
                if (![Utility isStringEmpty:productId]) {
                        [productsArray addObject:productId];
                }
                
                NSString *activityType =  [self getValueFOrKey:@"SVMXC__Activity_Type__c" FromArray:detalFiledsArray];
                if (![Utility isStringEmpty:activityType]) {
                        [labourArray addObject:activityType];
                }
            }
        }
        
        
        /*For labor we need to consider work order product if work detail does not have product*/
        if(labourArray != nil && [labourArray count]> 0 && workOrderProduct!= nil )
        {
            [labourPartsArray addObject:workOrderProduct];
        }
        
        /*preparing key value for record type ­> pricebook definition that are defined as part of setting*/
        NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
        if ([productsArray count] > 0) {
            NSDictionary *partsDictionary =  [self preparePBForSettings:pbPartsEstimateName andUsageValue:pbPartsUsageName andKey:@"RECORDTYPEINFO_PARTS" andRecordTypeId:recordTypeIds];
            if (partsDictionary != nil) {
                [priceBookArray addObject:partsDictionary];
            }
        }
        
        if ([labourArray count] > 0) {
            /*preparing key value for record type ­> pricebook definition that are defined as part of setting*/
            NSDictionary *labourDictionary =  [self preparePBForLabourSettings:pbLabourEstimateName andUsageValue:pbLabourUsageName andKey:@"RECORDTYPEINFO_LABOR" andRecordTypeId:recordTypeIds];
            if (labourDictionary != nil) {
                [priceBookArray addObject:labourDictionary];
            }
        }
        
        [aPool release];
        aPool = nil;
        
        
        /*Entitlement has to be checked thouroughly */
        NSDictionary *entitlementDict = [self getEntitlementHistoryForWorkorder:targetRecordId];
        
        NSString *idOfServiceOffering = nil;
        NSString *idServiceCovered = @"NONCOVERED";
        
        NSString *SVMXC__Warranty__c = [entitlementDict objectForKey:@"SVMXC__Warranty__c"];
        NSString *SVMXC__Service_Contract__c = [entitlementDict objectForKey:@"SVMXC__Service_Contract__c"];
        NSString *SVMXC__Entitled_By_Service__c =  [entitlementDict objectForKey:@"SVMXC__Entitled_By_Service__c"];
        if (![Utility isStringEmpty:SVMXC__Entitled_By_Service__c]) {
            idOfServiceOffering = SVMXC__Entitled_By_Service__c;
        }
        
        NSString *SVMXC__Entitled_Within_Threshold__c = [entitlementDict objectForKey:@"SVMXC__Entitled_Within_Threshold__c"];
        if ([SVMXC__Entitled_Within_Threshold__c isEqualToString:@"true"] ||[SVMXC__Entitled_Within_Threshold__c isEqualToString:@"True"] || [SVMXC__Entitled_Within_Threshold__c isEqualToString:@"1"]  ) {
            idServiceCovered = @"COVERED";
        }
        
       
        /* Wo comes under warranty then get warranty_id */
        if (![Utility isStringEmpty:SVMXC__Warranty__c]) {
            
            NSMutableDictionary *warrantyDictionary =  [self getRecordForSfId:SVMXC__Warranty__c andTableName:@"SVMXC__Warranty__c"];
            
            [warrantyDictionary setObject:[NSDictionary dictionaryWithObjectsAndKeys:@"SVMXC__Warranty__c",@"type",nil] forKey:@"attributes"];
            NSArray *tempArray =[[NSArray alloc] initWithObjects:warrantyDictionary, nil];
            NSDictionary *finalDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"WARRANTYDEFINITION",@"key",tempArray, @"data",nil];
            [tempArray release];
            tempArray = nil;
            
            [priceBookArray addObject:finalDictionary];
            [finalDictionary release];
            finalDictionary = nil;
        }
        else if(![Utility isStringEmpty:SVMXC__Service_Contract__c]){
            
            /* else If wo comes under contract then get contract_id */
            NSMutableDictionary *serviceContractDictionary = [self getRecordForSfId:SVMXC__Service_Contract__c
                                                                       andTableName:@"SVMXC__Service_Contract__c"];
            
            /*Get Service Contract pricebook definition for Parts */
            NSString *SVMXC__Default_Parts_Price_Book__c =  [serviceContractDictionary objectForKey:@"SVMXC__Default_Parts_Price_Book__c"];
            if (![Utility isStringEmpty:SVMXC__Default_Parts_Price_Book__c]) {
                /* get the price book info */
                [partsPriceBookIdsArray addObject:SVMXC__Default_Parts_Price_Book__c];
                NSDictionary *tempDictionary =  [self preparePBEstimateId:SVMXC__Default_Parts_Price_Book__c andUsageValue:SVMXC__Default_Parts_Price_Book__c andKey:@"RECORDTYPEINFO_PARTS_CONTRACT" andRecordTypeId:recordTypeIds];
                if (tempDictionary != nil) {
                    [priceBookArray addObject:tempDictionary];
                }
            }
            
            /*Get Service Contract pricebook definition for labor*/
            NSString *SVMXC__Service_Pricebook__c =  [serviceContractDictionary objectForKey:@"SVMXC__Service_Pricebook__c"];
            if (![Utility isStringEmpty:SVMXC__Service_Pricebook__c]) {
                [labourPriceBookIdsArray addObject:SVMXC__Service_Pricebook__c];
                NSDictionary *tempDictionary =  [self preparePBLaourEstimateId:SVMXC__Service_Pricebook__c  andUsageValue:SVMXC__Service_Pricebook__c andKey:@"RECORDTYPEINFO_LABOR_CONTRACT" andRecordTypeId:recordTypeIds];
                if (tempDictionary != nil) {
                    [priceBookArray addObject:tempDictionary];
                }
            }
            
            if (serviceContractDictionary != nil) {
                NSDictionary * someDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"CONTRACT_DEFINITION",@"key",[NSArray arrayWithObject:serviceContractDictionary],@"data", nil];
                [priceBookArray addObject:someDict];
                [someDict release];
                someDict = nil;
            }
           
            
            /* Getting data for SVMXC__Pricing_Rule__,SVMXC__Parts_Pricing__c,SVMXC__Parts_Discount__c,,SVMXC__Labor_Pricing__c,SVMXC__Expense_Pricing__c,SVMXC__Travel_Policy__c,SVMXC__Mileage_Tiers__c,SVMXC__Zone_Pricing__c
             */

            
            NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
            
            [self fillUpContractInformationInTheTargetArray:priceBookArray andContractId:SVMXC__Service_Contract__c andCurrency:currencyCode andNamedExpressionArray:namedExpressionArray andIdOffering:idOfServiceOffering  andCovered:idServiceCovered];
            
            [aPool drain];
            aPool = nil;
            
            /* Get the expression ids used in the process */
            if ([namedExpressionArray count] > 0) {
                NSArray *valueMapArray =  [self getNamedExpressionsForIds:namedExpressionArray];
                NSDictionary *finalDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"RULES",@"key",valueMapArray,@"valueMap", nil];
                [priceBookArray addObject: finalDict];
                valueMapArray = nil;
                [finalDict release];
                finalDict = nil;
            }
            
            /* Getting product definition */
            NSMutableArray *productsArrayTemp = [[NSMutableArray alloc] initWithArray:productsArray];
            [productsArrayTemp addObjectsFromArray:labourPartsArray];
            NSArray *dataArray =  [self getProductRecords:productsArrayTemp];
            NSDictionary *finalDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"PRODUCT_DEFINITION",@"key",dataArray,@"data", nil];
            if ([dataArray count] > 0) {
                [priceBookArray addObject: finalDict];
            }
            
            [productsArrayTemp release];
            productsArrayTemp = nil;
            
            dataArray = nil;
            [finalDict release];
            finalDict = nil;
         }
        
        
        
        /* Get the work order data and look up keys */
        NSArray *dataArray =  [self getLookUpDefinition:headerDataDictionary];
        [priceBookArray addObjectsFromArray:dataArray];
        
        
          /*Get the parts pricebook entry for the requested parts, pricebook(Contract special pricebook, Setting pricebook)*/
        if ([productsArray count] > 0 && ([partsPriceBookNames count] > 0 || [partsPriceBookIdsArray count ] >0) ) {
            
            NSDictionary *dataDictionary =  [self getPriceBookDictionaryWithProductArray:productsArray andPriceBookNames:partsPriceBookNames andPartsPriceBookIds:partsPriceBookIdsArray andCurrency:currencyCode];
            if(dataDictionary != nil) {
                [priceBookArray addObject:dataDictionary];
            }
            
        }
        
        /*Get the labour pricebook entry for the requested parts, pricebook(Contract special pricebook, Setting pricebook)*/
        if ([labourArray count] > 0 && ([labourPriceBookNames count] > 0 || [labourPriceBookIdsArray count ] >0) ) {
            
            NSDictionary *dataDictionary =  [self getPriceBookForLabourParts:labourArray andLabourPbNames:labourPriceBookNames andLabourPbIds:labourPriceBookIdsArray andCurrency:currencyCode];
            if (dataDictionary != nil) {
                [priceBookArray addObject:dataDictionary];
            }
            
        }
        [productsArray release];
        productsArray = nil;
        
        [labourArray release];
        labourArray = nil;
        
        [labourPartsArray release];
        labourPartsArray = nil;
        
        [labourPriceBookNames release];
        [labourPriceBookIdsArray release];
        
        [partsPriceBookIdsArray release];
        [partsPriceBookNames release];
        
        /*Adding tags*/
        NSMutableArray *someArray = [[NSMutableArray alloc] init];
        NSString * message = [appDelegate.wsInterface.tagsDictionary objectForKey:getPrice_not_entitled];
        if (message != nil) {
            NSDictionary *tempDict = [[NSDictionary alloc]initWithObjectsAndKeys:message,@"value",getPrice_not_entitled, @"key", nil];
            [someArray addObject:tempDict];
            [tempDict release];
            tempDict = nil;
        }
        NSDictionary *finalDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"TAGS",@"key",someArray,@"valueMap", nil];
        [priceBookArray addObject: finalDict];
        [finalDict release];
        finalDict = nil;
        [someArray release];
        someArray = nil;
        
        [outerPool release];
        outerPool = nil;
    }
    @catch (NSException *exception) {
        SMLog(kLogLevelVerbose,@"%@",[exception description]);
        
        NSMutableDictionary *Errordict=[[NSMutableDictionary alloc]init];
        [Errordict setObject:exception.name forKey:@"ExpName"];
        [Errordict setObject:exception.reason forKey:@"ExpReason"];
        if(exception.userInfo ==nil)
        {
            [Errordict setObject:exception forKey:@"userInfo"];
        }
        else
        {
            [Errordict setObject:exception.userInfo forKey:@"userInfo"];
        }
        [appDelegate CustomizeAletView:nil alertType:DATABASE_ERROR Dict:Errordict exception:nil];
        [Errordict release];
        Errordict = nil;
    }
    @finally {
        return [priceBookArray autorelease];
    }
    return [priceBookArray autorelease];
}

- (void)fillUpContractInformationInTheTargetArray:(NSMutableArray *)priceBookArray
                                    andContractId:(NSString *)SVMXC__Service_Contract__c
                                      andCurrency:(NSString *)currencyCode
                          andNamedExpressionArray:(NSMutableArray *)namedExpressionArray
                                    andIdOffering:(NSString *) idOfServiceOffering
                                       andCovered:(NSString *)idServiceCovered
{
    
    NSMutableDictionary *columnNames = [[NSMutableDictionary alloc] init];
    if (currencyCode != nil) {
        [columnNames setObject:currencyCode forKey:@"CurrencyIsoCode"];
    }
    [columnNames setObject:SVMXC__Service_Contract__c forKey:@"SVMXC__Service_Contract__c"];
    
    
    /* Get pricing rules for Contract*/
    NSArray *dataArray =  [self getRecordWhereColumnNamesAndValues:columnNames andTableName:@"SVMXC__Pricing_Rule__c"];
    NSDictionary *finalDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"CONTRACT_PRICINGRULES",@"key",dataArray,@"data", nil];
    if ([dataArray count] > 0) {
        [priceBookArray addObject: finalDict];
    }
    
    [self addNamedExpressionsFrom:dataArray ToArray:namedExpressionArray];
    dataArray = nil;
    [finalDict release];
    finalDict = nil;
    
    /* Get special parts pricing definition if available*/
    [columnNames setObject:@"1"  forKey:@"SVMXC__Active__c"];
    dataArray =  [self getRecordWhereColumnNamesAndValues:columnNames andTableName:@"SVMXC__Parts_Pricing__c"];
    finalDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"CONTRACT_SPECIALPARTSPRICING",@"key",dataArray,@"data", nil];
    if ([dataArray count] > 0) {
        [priceBookArray addObject: finalDict];
    }
    dataArray = nil;
    [finalDict release];
    finalDict = nil;
    
    /* get special parts discount is available*/
    dataArray =  [self getRecordWhereColumnNamesAndValues:columnNames andTableName:@"SVMXC__Parts_Discount__c"];
    finalDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"CONTRACT_PARTSDISCOUNT",@"key",dataArray,@"data", nil];
    if ([dataArray count] > 0) {
        [priceBookArray addObject: finalDict];
    }
    dataArray = nil;
    [finalDict release];
    finalDict = nil;
    [columnNames removeObjectForKey:@"SVMXC__Active__c"];
    
    /* Get special labor pricing definition */
    dataArray =  [self getRecordWhereColumnNamesAndValues:columnNames andTableName:@"SVMXC__Labor_Pricing__c"];
    finalDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"CONTRACT_SPECIALLABORPRICING",@"key",dataArray,@"data", nil];
    if ([dataArray count] > 0) {
        [priceBookArray addObject: finalDict];
    }
    dataArray = nil;
    [finalDict release];
    finalDict = nil;
    
    /*Get expense pricing if available*/
    dataArray =  [self getRecordWhereColumnNamesAndValues:columnNames andTableName:@"SVMXC__Expense_Pricing__c"];
    finalDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"CONTRACT_EXPENSE",@"key",dataArray,@"data", nil];
    if ([dataArray count] > 0) {
        [priceBookArray addObject: finalDict];
    }
    dataArray = nil;
    [finalDict release];
    finalDict = nil;
    
    /*Get  travel policy is available*/
    dataArray =  [self getRecordWhereColumnNamesAndValues:columnNames andTableName:@"SVMXC__Travel_Policy__c"];
    finalDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"CONTRACT_TRAVELPOLICY",@"key",dataArray,@"data", nil];
    if ([dataArray count] > 0) {
        [priceBookArray addObject: finalDict];
    }
    [self addNamedExpressionsFrom:dataArray ToArray:namedExpressionArray];
    dataArray = nil;
    [finalDict release];
    finalDict = nil;
    
    
    /*mileage tier pricing is available*/
    dataArray =  [self getRecordWhereColumnNamesAndValues:columnNames andTableName:@"SVMXC__Mileage_Tiers__c"];
    finalDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"CONTRACT_MILEAGETIERS",@"key",dataArray,@"data", nil];
    if ([dataArray count] > 0) {
        [priceBookArray addObject: finalDict];
    }
    dataArray = nil;
    [finalDict release];
    finalDict = nil;
    
    /*zone based pricing is available*/
    dataArray =  [self getRecordWhereColumnNamesAndValues:columnNames andTableName:@"SVMXC__Zone_Pricing__c"];
    finalDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"CONTRACT_ZONEPRICING",@"key",dataArray,@"data", nil];
    if ([dataArray count] > 0) {
        [priceBookArray addObject: finalDict];
    }
    
    dataArray = nil;
    [finalDict release];
    finalDict = nil;
    
    
    /*Get included services for Contract, we retrieve this information only if warranty says this is the included service. In response to this we attach COVERED or NONCOVERED*/
    if (idOfServiceOffering != nil) {
        [columnNames removeObjectForKey:@"SVMXC__Service_Contract__c"];
        [columnNames setObject:idOfServiceOffering forKey:@"Id"];
        dataArray =  [self getRecordWhereColumnNamesAndValues:columnNames andTableName:@"SVMXC__Service_Contract_Services__c"];
        finalDict = [[NSDictionary alloc] initWithObjectsAndKeys:idServiceCovered,@"value",@"CONTRACT_SERVICEOFFERING",@"key",dataArray,@"data", nil];
        
        if ([dataArray count] > 0) {
            [priceBookArray addObject: finalDict];
        }
        
        dataArray = nil;
        [finalDict release];
        finalDict = nil;
        
    }
    
    [columnNames release];
    columnNames = nil;
}
- (NSString *)getPricebookInformationForSettingId:(NSString *)settingId {
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT * FROM MobileDeviceSettings where setting_id =  '%@'",settingId];
    
    NSString  *settingValue = nil;
    sqlite3_stmt *selectStmt = nil;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sqlQuery UTF8String], -1, &selectStmt, nil) == SQLITE_OK  )
    {
        while(synchronized_sqlite3_step(selectStmt) == SQLITE_ROW)
        {
            char * temp_label = (char *)synchronized_sqlite3_column_text(selectStmt, 1);
            char * temp_value = (char *)(char*)synchronized_sqlite3_column_text(selectStmt, 2);
            if(temp_label != nil)
            {
                settingId = [NSString stringWithUTF8String:temp_label];
            }
            if(temp_value != nil)
            {
                settingValue = [NSString stringWithUTF8String:temp_value];
            }
       }
		
		synchronized_sqlite3_finalize(selectStmt);
    }
    return settingValue;
}

- (NSDictionary *)getRecordTypeIdsForRecordType:(NSArray *)recordTypes{
    NSString *recordTypeString = [self getConcatenatedStringFromArray:recordTypes withSingleQuotesAndBraces:YES];
    
    NSString *sqlQuery = [NSString stringWithFormat:@"select record_type_id,record_type from SFRecordType where record_type IN %@ and record_type <> \"\"",recordTypeString];
    NSMutableDictionary *dataDictionary = [[NSMutableDictionary alloc] init];
    sqlite3_stmt *selectStmt = nil;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sqlQuery UTF8String], -1, &selectStmt, nil) == SQLITE_OK  )
    {
        while(synchronized_sqlite3_step(selectStmt) == SQLITE_ROW)
        {
            NSString * recordId = @"" , * recordType = @"";
			
            
            char * temp_label = (char *)synchronized_sqlite3_column_text(selectStmt, 0);
            char * temp_value = (char *)(char*)synchronized_sqlite3_column_text(selectStmt, 1);
			
			
            if(temp_label != nil)
            {
                recordId = [NSString stringWithUTF8String:temp_label];
            }
            if(temp_value != nil)
            {
                recordType = [NSString stringWithUTF8String:temp_value];
            }
            
            
            [dataDictionary setObject:recordId forKey:recordType];
        }
		
		synchronized_sqlite3_finalize(selectStmt);
    }
    return [dataDictionary autorelease];
}

- (NSDictionary *)getEntitlementHistoryForWorkorder:(NSString *)workOrderId {
    
    NSString *tableName = @"SVMXC__Entitlement_History__c";
    
    NSDictionary *allFieldsOfTable = [self getAllFieldsOfTable:tableName];
    NSArray *allColumnNames = [allFieldsOfTable  allKeys];
    NSString *allColumnNamesString = [self getConcatenatedStringFromArray:allColumnNames withSingleQuotesAndBraces:NO];
    
    
    NSString *sqlQuery = [NSString  stringWithFormat:@"select %@ from %@ where SVMXC__Service_Order__c = '%@' and SVMXC__Inactive_Date__c = \"\"",allColumnNamesString,tableName,workOrderId];
    
    NSMutableDictionary *dataDictionary = [[NSMutableDictionary alloc] init];
    sqlite3_stmt *selectStmt = nil;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sqlQuery UTF8String], -1, &selectStmt, nil) == SQLITE_OK  )
    {
        
        while(sqlite3_step(selectStmt) == SQLITE_ROW)
        {
            NSString * tempString = @"";
			char * tempCharString = nil;
            
            for (int counter = 0; counter < [allColumnNames count]; counter++) {
                
                tempCharString = (char *)sqlite3_column_text(selectStmt, counter);
                if (tempCharString != nil) {
                    tempString = [NSString stringWithUTF8String:tempCharString];
                    if (tempString != nil) {
                        NSString *fieldName = [allColumnNames objectAtIndex:counter];
                        NSString *fieldType = [allFieldsOfTable objectForKey:fieldName];
                        SMLog(kLogLevelVerbose,@"Filed type is %@",fieldType);
                        if ([fieldType isEqualToString:@"boolean"]) {
                            tempString = [self changeTheBooleanValue:tempString];
                        }
                        [dataDictionary setObject:tempString forKey:fieldName];
                    }
                }
            }
            
            NSString *tempStringNew = [dataDictionary objectForKey:@"SVMXC__Entitled_Within_Threshold__c"];
            if ([Utility isItTrue:tempStringNew]) {
                tempStringNew = @"true";
            }else{
                tempStringNew = @"false";
            }
            [dataDictionary setObject:tempStringNew forKey:@"SVMXC__Entitled_Within_Threshold__c"];
            
            /* get the date and check whether it is valid */
            NSString *startDateString = [dataDictionary objectForKey:@"SVMXC__Start_Date__c"];
            NSString *endDateString = [dataDictionary objectForKey:@"SVMXC__End_Date__c"];
            
            NSDate *startDate = [Utility getDateFromString:startDateString];
            NSDate *endDate = [Utility getDateFromString:endDateString];
            NSDate *todayDate = [Utility todayDateInGMT];
            
            BOOL validDate =  [Utility checkIfDate:todayDate betweenDate:startDate andEndDate:endDate];
            if (validDate) {
                break;
            }
            else {
                [dataDictionary removeAllObjects];
            }
            
        }
		synchronized_sqlite3_finalize(selectStmt);
    }
    return [dataDictionary autorelease];
}

- (NSString *)getConcatenatedStringFromArray:(NSArray *)arayOfString withSingleQuotesAndBraces:(BOOL)isRequired {
    if ([arayOfString count] <= 0) {
        return nil;
    }
    NSMutableString *concatenatedString = [[NSMutableString alloc] init];
    
    if (isRequired) {
        for (int counter = 0; counter < [arayOfString count]; counter++) {
            
            NSString *tempStr = [arayOfString objectAtIndex:counter];
            if (counter == 0) {
                [concatenatedString appendFormat:@"('%@'",tempStr];
            }
            else{
                [concatenatedString appendFormat:@",'%@'",tempStr];
            }
        }
        [concatenatedString appendFormat:@")"];
    }
    else {
        for (int counter = 0; counter < [arayOfString count]; counter++) {
            
            NSString *tempStr = [arayOfString objectAtIndex:counter];
            if (counter == 0) {
                [concatenatedString appendFormat:@"%@",tempStr];
            }
            else{
                [concatenatedString appendFormat:@",%@",tempStr];
            }
        }
    }
    
    return [concatenatedString autorelease];
}


- (NSDictionary *)getAllFieldsOfTable:(NSString *)tableName {
    NSDictionary * fields_dict = [self getAllObjectFields:tableName tableName:SFOBJECTFIELD];
    return fields_dict;
}
- (NSDictionary *)preparePBForSettings:(NSString *)estimateValue andUsageValue:(NSString *)usageValue andKey:(NSString *)key andRecordTypeId:(NSDictionary *)recordTypeIds {
    
    NSString *usageRecordTypeId = [recordTypeIds objectForKey:@"Usage/Consumption"];
    NSString *estimateRecordTypeId = [recordTypeIds objectForKey:@"Estimate"];
    
    if (usageRecordTypeId != nil) {
        NSMutableArray *arrayTemp = [[NSMutableArray alloc] init];
        
        if (usageValue != nil) {
            NSArray *pbArray = [self getPriceBookObjectsForPriceBookIds:nil OrPriceBookNames:[NSArray arrayWithObject:usageValue]];
            for (int counter = 0; counter < [pbArray count ]; counter++) {
                
                NSDictionary *pbBook = [pbArray objectAtIndex:counter];
                NSString *finalValue = [pbBook objectForKey:@"Id"];
                if (finalValue == nil) {
                    finalValue = @"";
                }
                NSDictionary *tempDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:finalValue,@"value", usageRecordTypeId,@"key", nil];
                [arrayTemp addObject:tempDictionary];
                [tempDictionary release];
                tempDictionary = nil;
            }
        }
        
        if (estimateRecordTypeId != nil && estimateValue != nil) {
            
            NSArray *pbArray = [self getPriceBookObjectsForPriceBookIds:nil OrPriceBookNames:[NSArray arrayWithObject:estimateValue]];
            for (int counter = 0; counter < [pbArray count ]; counter++) {
                NSDictionary *pbBook = [pbArray objectAtIndex:counter];
                NSString *finalValue = [pbBook objectForKey:@"Id"];
                if (finalValue == nil) {
                    finalValue = @"";
                }
                NSDictionary *tempDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:finalValue,@"value", estimateRecordTypeId, @"key",nil];
                [arrayTemp addObject:tempDictionary];
                [tempDictionary release];
                tempDictionary = nil;
            }
        }
        NSDictionary *tempDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:arrayTemp,@"valueMap",key,@"key", nil];
        return [tempDictionary autorelease];
    }
    return nil;
}

- (NSDictionary *)preparePBForLabourSettings:(NSString *)estimateValue andUsageValue:(NSString *)usageValue andKey:(NSString *)key andRecordTypeId:(NSDictionary *)recordTypeIds {
    
    NSString *usageRecordTypeId = [recordTypeIds objectForKey:@"Usage/Consumption"];
    NSString *estimateRecordTypeId = [recordTypeIds objectForKey:@"Estimate"];
    
    if (usageRecordTypeId != nil) {
        NSMutableArray *arrayTemp = [[NSMutableArray alloc] init];
        
        if (usageValue != nil) {
            NSArray *pbArray = [self getPriceBookObjectsForLabourPriceBookIds:nil OrPriceBookNames:[NSArray arrayWithObject:usageValue]];
            for (int counter = 0; counter < [pbArray count ]; counter++) {
                
                NSDictionary *pbBook = [pbArray objectAtIndex:counter];
                NSString *finalValue = [pbBook objectForKey:@"Id"];
                if (finalValue != nil) {
                    NSDictionary *tempDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:finalValue,@"value", usageRecordTypeId,@"key", nil];
                    [arrayTemp addObject:tempDictionary];
                    [tempDictionary release];
                    tempDictionary = nil;
                }
                
            }
        }
        
        if (estimateRecordTypeId != nil && estimateValue != nil) {
            
            NSArray *pbArray = [self getPriceBookObjectsForLabourPriceBookIds:nil OrPriceBookNames:[NSArray arrayWithObject:estimateValue]];
            for (int counter = 0; counter < [pbArray count ]; counter++) {
                NSDictionary *pbBook = [pbArray objectAtIndex:counter];
                NSString *finalValue = [pbBook objectForKey:@"Id"];
                if (finalValue != nil) {
                    NSDictionary *tempDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:finalValue,@"value", estimateRecordTypeId, @"key",nil];
                    [arrayTemp addObject:tempDictionary];
                    [tempDictionary release];
                    tempDictionary = nil;
                }
            }
        }
        NSDictionary *tempDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:arrayTemp,@"valueMap",key,@"key", nil];
        return [tempDictionary autorelease];
    }
    return nil;
}

- (NSMutableDictionary *)getRecordForSfId:(NSString *)sfId andTableName:(NSString *)tableName {
    
    NSDictionary *allFieldsOfTable = [self getAllFieldsOfTable:tableName];
    NSArray *allColumnNames = [allFieldsOfTable  allKeys];
    NSString *allColumnNamesString = [self getConcatenatedStringFromArray:allColumnNames withSingleQuotesAndBraces:NO];
    
    
    NSString *sqlQuery = [NSString  stringWithFormat:@"select %@ from %@ where  Id = '%@'",allColumnNamesString,tableName,sfId];
    
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
                        NSString *fieldType = [allFieldsOfTable objectForKey:fieldName];
                        
                        if ([fieldType isEqualToString:@"boolean"]) {
                            tempString = [self changeTheBooleanValue:tempString];
                            [dataDictionary setObject:tempString forKey:fieldName];
                        }
                        else{
                            id someObject =  [self getTheProperObjectTypeForFieldType:fieldType andFieldValue:tempString];
                            if (someObject != nil) {
                                [dataDictionary setObject:someObject forKey:fieldName];
                            }
                        }
                       
                    }
                }
                
            }
        }
		synchronized_sqlite3_finalize(selectStmt);
    }
    return [dataDictionary autorelease];
}

- (NSArray *)getRecordWhereColumnNamesAndValues:(NSDictionary *)columnKeyAndValue  andTableName:(NSString *)tableName {
    
    NSDictionary *allFieldsOfTable = [self getAllFieldsOfTable:tableName];
    NSArray *allColumnNames = [allFieldsOfTable  allKeys];
    NSString *allColumnNamesString = [self getConcatenatedStringFromArray:allColumnNames withSingleQuotesAndBraces:NO];
    
    NSMutableString *someString = [[NSMutableString alloc] init];
    NSArray *allKeys = [columnKeyAndValue allKeys];
    NSInteger counter = 0;
    for (NSString *columnKey in allKeys) {
        NSString *columnValue = [columnKeyAndValue objectForKey:columnKey];
        if (counter > 0) {
            [someString appendFormat:@" and "];
        }
        counter++;
        if ([columnKey isEqualToString:@"SVMXC__Active__c"]) {
            
            [someString appendFormat:@"( SVMXC__Active__c = '1' OR  SVMXC__Active__c = 'True' OR SVMXC__Active__c = 'true')"];
        }
        else {
            [someString appendFormat:@"%@ = '%@'",columnKey,columnValue];
        }
        
    }
    
    NSString *sqlQuery = [NSString  stringWithFormat:@"select %@ from %@ where %@",allColumnNamesString,tableName,someString];
    
    [someString release];
    someString = nil;
    
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    sqlite3_stmt *selectStmt = nil;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sqlQuery UTF8String], -1, &selectStmt, nil) == SQLITE_OK  )
    {
        
        while(synchronized_sqlite3_step(selectStmt) == SQLITE_ROW)
        {
            NSMutableDictionary *recordDictionary = [[NSMutableDictionary alloc] init];
            
            NSString * tempString = @"";
			char * tempCharString = nil;
            
            for(int counter = 0;counter < [allColumnNames count];counter++) {
                
                tempCharString = (char *)sqlite3_column_text(selectStmt, counter);
                if (tempCharString != nil) {
                    tempString = [NSString stringWithUTF8String:tempCharString];
                    if (tempString != nil && counter < [allColumnNames count]) {
                        NSString *fieldName = [allColumnNames objectAtIndex:counter];
                        NSString *fieldType = [allFieldsOfTable objectForKey:fieldName];
                        SMLog(kLogLevelVerbose,@"Field type is %@",fieldType);
                        if ([fieldType isEqualToString:@"boolean"]) {
                            tempString = [self changeTheBooleanValue:tempString];
                             [recordDictionary setObject:tempString forKey:fieldName];
                        }
                        else  {
                           
                            id someObject =  [self getTheProperObjectTypeForFieldType:fieldType andFieldValue:tempString];
                            if (someObject != nil) {
                                [recordDictionary setObject:someObject forKey:fieldName];
                            }
                        }
                    }
                }
            }
             NSDictionary *tempDict = [[NSDictionary alloc] initWithObjectsAndKeys:tableName,@"type", nil];
            [recordDictionary setObject:tempDict forKey:@"attributes"];
            [tempDict release];
            tempDict = nil;
            
            [dataArray addObject:recordDictionary];
            
            [recordDictionary release];
            recordDictionary = nil;
            
            
        }
		synchronized_sqlite3_finalize(selectStmt);
    }
    return [dataArray autorelease];
}

- (NSArray *)getProductRecords:(NSArray *)productIdentifiers {
    NSString *productIdentfierStr = [self getConcatenatedStringFromArray:productIdentifiers withSingleQuotesAndBraces:YES];
    NSString *sqlQuery = [NSString stringWithFormat:@"Select Id, SVMXC__Product_Line__c, Family From Product2 where Id IN %@",productIdentfierStr];
    
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    sqlite3_stmt *selectStmt = nil;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sqlQuery UTF8String], -1, &selectStmt, nil) == SQLITE_OK  )
    {
        
        while(sqlite3_step(selectStmt) == SQLITE_ROW)
        {
            NSMutableDictionary *recordDictionary = [[NSMutableDictionary alloc] init];
            
            NSString * tempString = @"";
			char * tempCharString = nil;
            
            tempCharString = (char *)sqlite3_column_text(selectStmt, 0);
            if (tempCharString != nil) {
                tempString = [NSString stringWithUTF8String:tempCharString];
                [recordDictionary setObject:tempString forKey:@"Id"];
            }
            
            tempCharString = (char *)sqlite3_column_text(selectStmt, 1);
            if (tempCharString != nil) {
                tempString = [NSString stringWithUTF8String:tempCharString];
                [recordDictionary setObject:tempString forKey:@"SVMXC__Product_Line__c"];
            }
            
            tempCharString = (char *)sqlite3_column_text(selectStmt, 2);
            if (tempCharString != nil) {
                tempString = [NSString stringWithUTF8String:tempCharString];
                [recordDictionary setObject:tempString forKey:@"Family"];
            }
            
            NSDictionary *tempDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"Product2",@"type", nil];
            [recordDictionary setObject:tempDict forKey:@"attributes"];
            [tempDict release];
            tempDict = nil;
            
            [dataArray addObject:recordDictionary];
            
            [recordDictionary release];
            recordDictionary = nil;
            
            
        }
		synchronized_sqlite3_finalize(selectStmt);
    }
    return [dataArray autorelease];
    
    
}

- (NSArray *)getPriceBookObjectsForPriceBookIds:(NSArray *)priceBookIds OrPriceBookNames:(NSArray *)priceBookNames {
    
    NSString *priceBookIdString = [self getConcatenatedStringFromArray:priceBookIds withSingleQuotesAndBraces:YES];
    
    NSString *priceBookNameString = [self getConcatenatedStringFromArray:priceBookNames withSingleQuotesAndBraces:YES];
    
    NSString *activeString = @"(IsActive = '1' OR IsActive = 'True' OR IsActive = 'true')";
    
    NSString *sqlQuery = nil;
    
    if (priceBookIdString != nil && priceBookNameString != nil) {
        sqlQuery = [NSString stringWithFormat:@"SELECT Id, Name FROM Pricebook2 WHERE (Id IN %@ OR Name IN %@) and %@",priceBookIdString,priceBookNameString,activeString];
    }
    else if (priceBookIdString != nil){
        
        sqlQuery = [NSString stringWithFormat:@"SELECT Id, Name FROM Pricebook2 WHERE Id IN %@ and %@ ",priceBookIdString,activeString];
        
    }else if(priceBookNameString != nil){
        sqlQuery = [NSString stringWithFormat:@"SELECT Id, Name FROM Pricebook2 WHERE Name IN %@ and %@ ",priceBookNameString,activeString];
    }
    
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    sqlite3_stmt *selectStmt = nil;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sqlQuery UTF8String], -1, &selectStmt, nil) == SQLITE_OK  )
    {
        
        while(sqlite3_step(selectStmt) == SQLITE_ROW)
        {
            NSMutableDictionary *recordDictionary = [[NSMutableDictionary alloc] init];
            
            NSString * tempString = @"";
			char * tempCharString = nil;
            
            tempCharString = (char *)sqlite3_column_text(selectStmt, 0);
            if (tempCharString != nil) {
                tempString = [NSString stringWithUTF8String:tempCharString];
                [recordDictionary setObject:tempString forKey:@"Id"];
            }
            
            tempCharString = (char *)sqlite3_column_text(selectStmt, 1);
            if (tempCharString != nil) {
                tempString = [NSString stringWithUTF8String:tempCharString];
                [recordDictionary setObject:tempString forKey:@"Name"];
            }
            [dataArray addObject:recordDictionary];
        }
    }
    synchronized_sqlite3_finalize(selectStmt);
    return [dataArray autorelease];
}

- (NSArray *)getPriceBookObjectsForLabourPriceBookIds:(NSArray *)priceBookIds OrPriceBookNames:(NSArray *)priceBookNames {
    
    NSString *priceBookIdString = [self getConcatenatedStringFromArray:priceBookIds withSingleQuotesAndBraces:YES];
    
    NSString *priceBookNameString = [self getConcatenatedStringFromArray:priceBookNames withSingleQuotesAndBraces:YES];
    
    NSString *isActiveString = @"( SVMXC__Active__c = '1' OR SVMXC__Active__c = 'true'  OR SVMXC__Active__c = 'True' )";
    NSString *sqlQuery = nil;
    
    if (priceBookIdString != nil && priceBookNameString != nil) {
        sqlQuery = [NSString stringWithFormat:@"SELECT Id, Name FROM SVMXC__Service_Pricebook__c WHERE (Id IN %@ OR Name IN %@) and %@",priceBookIdString,priceBookNameString,isActiveString];
    }
    else if (priceBookIdString != nil){
        
        sqlQuery = [NSString stringWithFormat:@"SELECT Id, Name FROM SVMXC__Service_Pricebook__c WHERE Id IN %@ and %@ ",priceBookIdString,isActiveString];
        
    }else if(priceBookNameString != nil){
        sqlQuery = [NSString stringWithFormat:@"SELECT Id, Name FROM SVMXC__Service_Pricebook__c WHERE Name IN %@ and %@ ",priceBookNameString,isActiveString];
    }
    
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    sqlite3_stmt *selectStmt = nil;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sqlQuery UTF8String], -1, &selectStmt, nil) == SQLITE_OK  )
    {
        
        while(sqlite3_step(selectStmt) == SQLITE_ROW)
        {
            NSMutableDictionary *recordDictionary = [[NSMutableDictionary alloc] init];
            
            NSString * tempString = @"";
			char * tempCharString = nil;
            
            tempCharString = (char *)sqlite3_column_text(selectStmt, 0);
            if (tempCharString != nil) {
                tempString = [NSString stringWithUTF8String:tempCharString];
                [recordDictionary setObject:tempString forKey:@"Id"];
            }
            
            tempCharString = (char *)sqlite3_column_text(selectStmt, 1);
            if (tempCharString != nil) {
                tempString = [NSString stringWithUTF8String:tempCharString];
                [recordDictionary setObject:tempString forKey:@"Name"];
            }
            [dataArray addObject:recordDictionary];
        }
    }
    synchronized_sqlite3_finalize(selectStmt);
    return [dataArray autorelease];
}


- (NSDictionary *)preparePBEstimateId:(NSString *)estimateValue andUsageValue:(NSString *)usageValue andKey:(NSString *)key andRecordTypeId:(NSDictionary *)recordTypeIds {
    
    NSString *usageRecordTypeId = [recordTypeIds objectForKey:@"Usage/Consumption"];
    NSString *estimateRecordTypeId = [recordTypeIds objectForKey:@"Estimate"];
    
    if (usageRecordTypeId != nil) {
        NSMutableArray *arrayTemp = [[NSMutableArray alloc] init];
        
        if (usageValue != nil) {
            NSArray *pbArray = [self getPriceBookObjectsForPriceBookIds:[NSArray arrayWithObject:usageValue] OrPriceBookNames:nil];
            for (int counter = 0; counter < [pbArray count ]; counter++) {
                
                NSDictionary *pbBook = [pbArray objectAtIndex:counter];
                NSString *finalValue = [pbBook objectForKey:@"Id"];
                if (finalValue != nil) {
                    NSDictionary *tempDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:finalValue,@"value", usageRecordTypeId,@"key", nil];
                    [arrayTemp addObject:tempDictionary];
                    [tempDictionary release];
                    tempDictionary = nil;
                }
            }
        }
        
        if (estimateRecordTypeId != nil && estimateValue != nil) {
            
            NSArray *pbArray = [self getPriceBookObjectsForPriceBookIds:[NSArray arrayWithObject:estimateValue] OrPriceBookNames:nil];
            for (int counter = 0; counter < [pbArray count ]; counter++) {
                NSDictionary *pbBook = [pbArray objectAtIndex:counter];
                NSString *finalValue = [pbBook objectForKey:@"Id"];
                if (finalValue != nil) {
                    NSDictionary *tempDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:finalValue, @"value",estimateRecordTypeId,@"key", nil];
                    [arrayTemp addObject:tempDictionary];
                    [tempDictionary release];
                    tempDictionary = nil;
                }
            }
        }
        NSDictionary *tempDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:arrayTemp,@"valueMap",key,@"key", nil];
        return [tempDictionary autorelease];
    }
    return nil;
}

- (NSDictionary *)preparePBLaourEstimateId:(NSString *)estimateValue andUsageValue:(NSString *)usageValue andKey:(NSString *)key andRecordTypeId:(NSDictionary *)recordTypeIds {
    
    NSString *usageRecordTypeId = [recordTypeIds objectForKey:@"Usage/Consumption"];
    NSString *estimateRecordTypeId = [recordTypeIds objectForKey:@"Estimate"];
    
    if (usageRecordTypeId != nil) {
        NSMutableArray *arrayTemp = [[NSMutableArray alloc] init];
        
        if (usageValue != nil) {
            NSArray *pbArray = [self getPriceBookObjectsForLabourPriceBookIds:[NSArray arrayWithObject:usageValue] OrPriceBookNames:nil];
            for (int counter = 0; counter < [pbArray count ]; counter++) {
                
                NSDictionary *pbBook = [pbArray objectAtIndex:counter];
                NSString *finalValue = [pbBook objectForKey:@"Id"];
                if (finalValue != nil) {
                    NSDictionary *tempDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:finalValue,@"value", usageRecordTypeId,@"key", nil];
                    [arrayTemp addObject:tempDictionary];
                    [tempDictionary release];
                    tempDictionary = nil;
                }
             }
        }
        
        if (estimateRecordTypeId != nil && estimateValue != nil) {
            
            NSArray *pbArray = [self getPriceBookObjectsForLabourPriceBookIds:[NSArray arrayWithObject:estimateValue] OrPriceBookNames:nil];
            for (int counter = 0; counter < [pbArray count ]; counter++) {
                NSDictionary *pbBook = [pbArray objectAtIndex:counter];
                NSString *finalValue = [pbBook objectForKey:@"Id"];
                if (finalValue != nil) {
                    NSDictionary *tempDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:finalValue,@"value", estimateRecordTypeId,@"key", nil];
                    [arrayTemp addObject:tempDictionary];
                    [tempDictionary release];
                    tempDictionary = nil;
                }
            }
        }
        NSDictionary *tempDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:arrayTemp,@"valueMap",key,@"key", nil];
        return [tempDictionary autorelease];
    }
    return nil;
}

- (void)addNamedExpressionsFrom:(NSArray *)dataArray ToArray:(NSMutableArray *)namedExpressionArray {
    
    for (int counter = 0; counter < [dataArray count]; counter ++) {
        NSDictionary *tempDictionary = [dataArray objectAtIndex:counter];
        NSString  *nameExpressionId = [tempDictionary objectForKey:@"SVMXC__Named_Expression__c"];
        if (![Utility isStringEmpty:nameExpressionId]) {
            [namedExpressionArray addObject:nameExpressionId];
        }
    }
}

- (NSArray *)getNamedExpressionsForIds:(NSArray *)namedExpressionArray {
    
    if ([namedExpressionArray count] <= 0) {
        return nil;
    }
    NSMutableString *tempString = [[NSMutableString alloc] init];
    for (int counter = 0; counter < [namedExpressionArray count]; counter++) {
        
        NSString *someExpr = [namedExpressionArray objectAtIndex:counter];
        if (counter == 0) {
            [tempString appendFormat:@"Id LIKE '%@%%'",someExpr];
        }
        else {
            [tempString appendFormat:@" OR Id LIKE '%@%%'",someExpr];
        }
    }
     
    NSString *concatenatedExpId = [NSString stringWithFormat:@"( %@ )",tempString];
    [tempString release];
    tempString = nil;
    
    
    NSDictionary *recordTypeDict = [self getRecordTypeIdsForRecordType:[NSArray arrayWithObjects:@"SVMX Rule",@"Expressions", nil]];
    
    NSString *recordTypeRule = [recordTypeDict objectForKey:@"SVMX Rule"];
    NSString *expressionRule = [recordTypeDict objectForKey:@"Expressions"];
    
    
    NSString *sqlQuery = [NSString stringWithFormat:@"Select SVMXC__Advance_Expression__c,Id from SVMXC__ServiceMax_Processes__c where %@ and recordTypeId = '%@'",concatenatedExpId,recordTypeRule];
    sqlite3_stmt *selectStmt = nil;
    NSMutableDictionary *expressionDictionary = [[NSMutableDictionary alloc] init ];
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sqlQuery UTF8String], -1, &selectStmt, nil) == SQLITE_OK  )
    {
        while(sqlite3_step(selectStmt) == SQLITE_ROW) {
            
            NSString *identifier = nil, *advancedExpression = nil;
			char * tempCharString = nil;
            
            tempCharString = (char *)sqlite3_column_text(selectStmt, 0);
            if (tempCharString != nil) {
                advancedExpression = [NSString stringWithUTF8String:tempCharString];
                if (advancedExpression == nil) {
                    advancedExpression = @"";
                }
                
            }
            tempCharString = nil;
                        
            tempCharString = (char *)sqlite3_column_text(selectStmt,1);
            if (tempCharString != nil) {
                identifier = [NSString stringWithUTF8String:tempCharString];
                
            }
            [expressionDictionary setObject:advancedExpression forKey:identifier];
            
        }
    }
    synchronized_sqlite3_finalize(selectStmt);
      NSMutableArray *expressionArray = [[NSMutableArray alloc] init];
    if ([expressionDictionary count] > 0) {
        for (int counter = 0; counter < [namedExpressionArray count]; counter++) {
            
            NSString *identifier = [namedExpressionArray objectAtIndex:counter];
            NSString *expression = [expressionDictionary objectForKey:identifier];
          
            NSArray *expressionComponenets =  [self getExpressionComponentsForExpressionId:identifier andExpression:expression andRecordId:expressionRule];
            if ([expressionComponenets count] > 0) {
                
                NSDictionary *dictionaryObj = nil;
                if (expression != nil) {
                  dictionaryObj = [[NSDictionary alloc] initWithObjectsAndKeys:identifier,@"key",expression,@"value",expressionComponenets,@"data", nil];
                }
                else {
                   dictionaryObj = [[NSDictionary alloc] initWithObjectsAndKeys:identifier,@"key",expressionComponenets,@"data", nil];
                    
                }
                [expressionArray addObject:dictionaryObj];
                [dictionaryObj release];
                dictionaryObj = nil;
            }
            
        }
   }
  
       
    return [expressionArray autorelease];
}

- (NSArray *) getExpressionComponentsForExpressionId:(NSString *)expressionId andExpression:(NSString *)expressionName andRecordId:(NSString *)recordTypeId{
    
    NSString *sqlQuery = [NSString stringWithFormat:@"Select SVMXC__Field_Name__c,SVMXC__Operator__c,SVMXC__Operand__c,SVMXC__Sequence__c,SVMXC__Expression_Type__c,SVMXC__Expression_Rule__c,Id from SVMXC__SERVICEMAX_CONFIG_DATA__C where SVMXC__Expression_Rule__c LIKE '%@%%' and recordTypeId = '%@'",expressionId,recordTypeId];
    sqlite3_stmt *selectStmt = nil;
    NSMutableArray *expressionComponents = [[NSMutableArray alloc] init];
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sqlQuery UTF8String], -1, &selectStmt, nil) == SQLITE_OK  )
    {
        while(sqlite3_step(selectStmt) == SQLITE_ROW) {
            NSMutableDictionary *recordDictionary = [[NSMutableDictionary alloc] init];
            int i =0;
            NSString *someExpression = nil;
			char * tempCharString = nil;
            
            tempCharString = (char *)sqlite3_column_text(selectStmt, i++);
            if (tempCharString != nil) {
                someExpression = [NSString stringWithUTF8String:tempCharString];
                if (someExpression != nil) {
                    [recordDictionary setObject:someExpression forKey:@"SVMXC__Field_Name__c"];
                }
                
            }
            
            tempCharString = (char *)sqlite3_column_text(selectStmt,i++);
            if (tempCharString != nil) {
                 someExpression = [NSString stringWithUTF8String:tempCharString];
                if (someExpression != nil) {
                    [recordDictionary setObject:someExpression forKey:@"SVMXC__Operator__c"];
                }
                
            }
            tempCharString = (char *)sqlite3_column_text(selectStmt,i++);
            if (tempCharString != nil) {
                 someExpression = [NSString stringWithUTF8String:tempCharString];
                if (someExpression != nil) {
                    [recordDictionary setObject:someExpression forKey:@"SVMXC__Operand__c"];
                }
                
            }
            tempCharString = (char *)sqlite3_column_text(selectStmt,i++);
            if (tempCharString != nil) {
                someExpression = [NSString stringWithUTF8String:tempCharString];
                if (someExpression != nil) {
                    [recordDictionary setObject:someExpression forKey:@"SVMXC__Sequence__c"];
                }
                
            }
            tempCharString = (char *)sqlite3_column_text(selectStmt,i++);
            if (tempCharString != nil) {
                someExpression = [NSString stringWithUTF8String:tempCharString];
                if (someExpression != nil) {
                    [recordDictionary setObject:someExpression forKey:@"SVMXC__Expression_Type__c"];
                }
                
            }
            tempCharString = (char *)sqlite3_column_text(selectStmt,i++);
            if (tempCharString != nil) {
                someExpression = [NSString stringWithUTF8String:tempCharString];
                if (someExpression != nil) {
                    [recordDictionary setObject:someExpression forKey:@"SVMXC__Expression_Rule__c"];
                }
                
            }
            tempCharString = (char *)sqlite3_column_text(selectStmt,i++);
            if (tempCharString != nil) {
                someExpression = [NSString stringWithUTF8String:tempCharString];
                if (someExpression != nil) {
                    [recordDictionary setObject:someExpression forKey:@"Id"];
                }
                
            }
            if ([recordDictionary count] > 0) {
                
                NSDictionary *tempDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"SVMXC__ServiceMax_Config_Data__c",@"type", nil];
                [recordDictionary setObject:tempDict forKey:@"attributes"];
                [tempDict release];
                tempDict = nil;
                
                [expressionComponents addObject:recordDictionary];
            }
            [recordDictionary release];
            recordDictionary = nil;
        }
    }
    synchronized_sqlite3_finalize(selectStmt);
    return [expressionComponents autorelease];
}

- (NSArray *)getLookUpDefinition:(NSDictionary *)workOrderData {
    
    NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
    
    NSString *tableName = @"SVMXC__Service_Order__c";
    
    NSMutableDictionary *targetRecordAsKeyValue = [[NSMutableDictionary alloc] init];
    /*Get the target record id and targetRecordAsKeyvalue */
    NSArray *detailFieldsArr = [workOrderData objectForKey:@"targetRecordAsKeyValue"];
    for (int counter = 0; counter < [detailFieldsArr count]; counter++) {
        NSDictionary *tempDict = [detailFieldsArr objectAtIndex:counter];
        NSString *keyNew = [tempDict objectForKey:@"key"];
        NSString *value  = [tempDict objectForKey:@"value"];
        if (keyNew != nil ) {
            value = value?value:@"";
            [targetRecordAsKeyValue setObject:value forKey:keyNew];
        }
    }
    
    
    
    /* Get the LOOKUP_DEFINITION */
    NSString *parentColumnName =  [self parentColumnNameFor:tableName];
    
    NSDictionary *lookUpDictioanry =  [self getLookUpFor:parentColumnName andFieldDictionary:targetRecordAsKeyValue andTableName:tableName];
    NSDictionary *lookUpFinal = [NSDictionary dictionaryWithObjectsAndKeys:lookUpDictioanry,@"valueMap",@"LOOKUP_DEFINITION",@"key", nil];
    
    
    /*Prepare work order data  */
    NSArray *tempArray = [[NSArray alloc] initWithObjects:targetRecordAsKeyValue, nil];
    
    NSDictionary *finalDictioanry = [[NSDictionary alloc] initWithObjectsAndKeys:tempArray,@"data",@"WORKORDER_DATA",@"key",nil];
    [tempArray release];
    tempArray = nil;
    
    NSArray *finalArray = [[NSArray alloc] initWithObjects:lookUpFinal, finalDictioanry,nil];
    
    [finalDictioanry release];
    finalDictioanry=nil;
    
    [aPool release];
    aPool = nil;
    
    return [finalArray autorelease];
}

- (NSDictionary *)getLookUpFor:(NSString *)parentColumnName andFieldDictionary:(NSDictionary *)parentColumnDictionary andTableName:(NSString *)tableName {
    
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT local_id, api_name , reference_to FROM SFObjectField where object_api_name = '%@' and reference_to != \"\"",tableName];
    
    NSMutableDictionary *recordDictionary = [[NSMutableDictionary alloc] init];
    sqlite3_stmt *selectStmt = nil;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sqlQuery UTF8String], -1, &selectStmt, nil) == SQLITE_OK  )
    {
        
        while(sqlite3_step(selectStmt) == SQLITE_ROW)
        {
            
            
            NSString * localId = @"",*fieldName = nil,*reference_to = nil ;
			char * tempCharString = nil;
            
            tempCharString = (char *)sqlite3_column_text(selectStmt, 0);
            if (tempCharString != nil) {
                localId = [NSString stringWithUTF8String:tempCharString];
                
            }
            
            tempCharString = (char *)sqlite3_column_text(selectStmt, 1);
            if (tempCharString != nil) {
                fieldName = [NSString stringWithUTF8String:tempCharString];
            }
            
            tempCharString = (char *)sqlite3_column_text(selectStmt, 2);
            if (tempCharString != nil) {
                reference_to = [NSString stringWithUTF8String:tempCharString];
            }
            
            NSString *idValueOfTheField = [parentColumnDictionary objectForKey:fieldName];
            
            if (![Utility isStringEmpty:idValueOfTheField]) {
                
                /* If fieldName is parent column name, the idValueOfTheField is local id */
                if ([fieldName isEqualToString:parentColumnName]) {
                    NSDictionary *sfidDict = [self getParentSFIDAForLocalId:idValueOfTheField andTableName:reference_to];
                    if (sfidDict != nil && [[sfidDict allKeys] count] > 0) {
                        NSString *sfId =  [[sfidDict allKeys] objectAtIndex:0];
                        NSString *nameValue =  [sfidDict objectForKey:sfId];
                        if (nameValue == nil) {
                            nameValue = sfId;
                        }
                        [recordDictionary setObject:sfId forKey:@"key"];
                        [recordDictionary setObject:nameValue forKey:@"value"];
                        continue;
                    }
                }
                
                NSString *getTheReferenceValue = [self getTheReferenceValueForId:idValueOfTheField andTableName:reference_to];
                if (getTheReferenceValue == nil) {
                    getTheReferenceValue = idValueOfTheField;
                }
                [recordDictionary setObject:idValueOfTheField forKey:@"key"];
                [recordDictionary setObject:getTheReferenceValue forKey:@"value"];
            }
            
        }
        
        
    }
    synchronized_sqlite3_finalize(selectStmt);
    return [recordDictionary autorelease];
}
- (NSString *)parentColumnNameFor:(NSString *)tableName {
    NSString * parent_column_name = [appDelegate.databaseInterface getchildInfoFromChildRelationShip:SFCHILDRELATIONSHIP ForChild:tableName field_name:@"parent_column_name"];
    return parent_column_name;
}

- (NSString *)getTheReferenceValueForId:(NSString*)idValueOfTheField andTableName:(NSString *)tableName {
    
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT Name FROM %@ where Id = '%@' OR local_id = '%@' ",tableName,idValueOfTheField,idValueOfTheField];
    sqlite3_stmt *selectStmt = nil;
    NSString *  nameValue= nil;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sqlQuery UTF8String], -1, &selectStmt, nil) == SQLITE_OK  )
    {
        
        while(sqlite3_step(selectStmt) == SQLITE_ROW)
        {
            
            
            
			char * tempCharString = nil;
            
            tempCharString = (char *)sqlite3_column_text(selectStmt, 0);
            if (tempCharString != nil) {
                nameValue = [NSString stringWithUTF8String:tempCharString];
                
            }
        }
    }
    synchronized_sqlite3_finalize(selectStmt);
    return nameValue;
}

- (NSDictionary *)getParentSFIDAForLocalId:(NSString *)localId andTableName:(NSString*)tableName{
    
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT Name, Id FROM %@ local_id = '%@' ",tableName,localId];
    sqlite3_stmt *selectStmt = nil;
    NSString *  nameValue= nil;
    NSString *sfId = nil;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sqlQuery UTF8String], -1, &selectStmt, nil) == SQLITE_OK  )
    {
        
        while(sqlite3_step(selectStmt) == SQLITE_ROW)
        {
            
            
            
			char * tempCharString = nil;
            
            tempCharString = (char *)sqlite3_column_text(selectStmt, 0);
            if (tempCharString != nil) {
                nameValue = [NSString stringWithUTF8String:tempCharString];
                if (nameValue != nil) {
                    nameValue = @"";
                }
            }
            
            tempCharString = (char *)sqlite3_column_text(selectStmt, 0);
            if (tempCharString != nil) {
                sfId = [NSString stringWithUTF8String:tempCharString];
                
            }
            
        }
    }
    synchronized_sqlite3_finalize(selectStmt);
    if (sfId != nil) {
        return [NSDictionary dictionaryWithObjectsAndKeys:nameValue,sfId,nil];
    }
    return nil;
    
}

- (NSDictionary *)getPriceBookDictionaryWithProductArray:(NSArray *)productsArray andPriceBookNames:(NSArray *)partsPriceBookNames andPartsPriceBookIds:(NSArray *)partsPriceBookIdsArray andCurrency:(NSString *)currencyIsoCode{
    
    NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
    NSArray *tempArray =  [self getPriceBookObjectsForPriceBookIds:partsPriceBookIdsArray  OrPriceBookNames:partsPriceBookNames];
    
    NSMutableArray *priceBookIds = [[NSMutableArray alloc] init];
    for (int counter = 0; counter < [tempArray count]; counter++) {
        
        NSDictionary *pbDictioanry = [tempArray objectAtIndex:counter];
        NSString *identifier = [pbDictioanry objectForKey:@"Id"];
        if (identifier != nil) {
            [priceBookIds addObject:identifier];
        }
    }
    NSDictionary *tempDictionary = nil;
    if ([priceBookIds count] > 0) {
        /*get pricebook entry for these ids */
        NSArray *pricebookRecords =  [self getPriceBookEntryRecordsFor:priceBookIds andProductArray:productsArray andTableName:@"PricebookEntry" andCurrency:currencyIsoCode];
        tempDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"PARTSPRICING",@"key",pricebookRecords,@"data",nil];
        
    }
    [priceBookIds release];
    priceBookIds = nil;
    [aPool release];
    aPool = nil;
    return [tempDictionary autorelease];
}

- (NSArray*)getPriceBookEntryRecordsFor:(NSArray *)priceBookIds andProductArray:(NSArray *)productsArray andTableName:(NSString *)tableName andCurrency:(NSString *)currency {
    
    NSString *priceBookIdString = [self getConcatenatedStringFromArray:priceBookIds withSingleQuotesAndBraces:YES];
    NSString *productString = [self getConcatenatedStringFromArray:productsArray withSingleQuotesAndBraces:YES];
    
    if (productString == nil) {
        productString = @"()";
    }
    if (priceBookIdString == nil) {
        priceBookIdString = @"()";
    }
    
    NSDictionary *allFieldsOfTable = [self getAllFieldsOfTable:tableName];
    NSArray *allColumnNames = [allFieldsOfTable  allKeys];
    NSString *allColumnNamesString = [self getConcatenatedStringFromArray:allColumnNames withSingleQuotesAndBraces:NO];
    NSString *sqlQuery = nil;
    if (currency == nil) {
        sqlQuery = [[NSString alloc] initWithFormat:@"Select %@ from %@ where (isActive = '1' OR isActive = 'True' OR  isActive = 'true') and Product2Id IN %@ AND Pricebook2Id IN %@",allColumnNamesString,tableName,productString,priceBookIdString];
    }
    else {
        sqlQuery = [[NSString alloc] initWithFormat:@"Select %@ from %@ where (isActive = '1' OR isActive = 'True' OR  isActive = 'true') and Product2Id IN %@ AND Pricebook2Id IN %@ and CurrencyIsoCode = '%@'",allColumnNamesString,tableName,productString,priceBookIdString,currency];
    }
    
    
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    sqlite3_stmt *selectStmt = nil;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sqlQuery UTF8String], -1, &selectStmt, nil) == SQLITE_OK  )
    {
        
        while(synchronized_sqlite3_step(selectStmt) == SQLITE_ROW)
        {
            NSMutableDictionary *recordDictionary = [[NSMutableDictionary alloc] init];
            
            NSString * tempString = @"";
			char * tempCharString = nil;
            
            for(int counter = 0;counter < [allColumnNames count];counter++) {
                
                tempCharString = (char *)sqlite3_column_text(selectStmt, counter);
                if (tempCharString != nil) {
                    tempString = [NSString stringWithUTF8String:tempCharString];
                    if (tempString != nil && counter < [allColumnNames count]) {
                        NSString *fieldName = [allColumnNames objectAtIndex:counter];
                        NSString *fieldType =  [allFieldsOfTable objectForKey:fieldName];
                        
                        if ([fieldType isEqualToString:@"boolean"]) {
                            tempString = [self changeTheBooleanValue:tempString];
                            [recordDictionary setObject:tempString forKey:fieldName];
                        }
                        else {
                            id someObject =  [self getTheProperObjectTypeForFieldType:fieldType andFieldValue:tempString];
                            if (someObject != nil) {
                                [recordDictionary setObject:someObject forKey:fieldName];
                            }
                        }
                    }
                }
            }
            
            NSDictionary *tempDict = [[NSDictionary alloc] initWithObjectsAndKeys:tableName,@"type", nil];
            [recordDictionary setObject:tempDict forKey:@"attributes"];
            [tempDict release];
            tempDict = nil;
            
            [dataArray addObject:recordDictionary];
            
            [recordDictionary release];
            recordDictionary = nil;
            
            
        }
		
    }
    synchronized_sqlite3_finalize(selectStmt);
    [sqlQuery release];
    sqlQuery = nil;
    
    return [dataArray autorelease];
}

- (NSDictionary *)getPriceBookForLabourParts:(NSArray *)labourArray andLabourPbNames:(NSArray *)labourPbNames andLabourPbIds:(NSArray *)labourPbIds andCurrency:(NSString *)currency {
    
    NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
    NSArray *tempArray =  [self getValidLabourPriceBookNames:labourPbNames andLabourIdArray:labourPbIds andCurrency:currency];
    
    NSMutableArray *priceBookIds = [[NSMutableArray alloc] init];
    for (int counter = 0; counter < [tempArray count]; counter++) {
        
        NSDictionary *pbDictioanry = [tempArray objectAtIndex:counter];
        NSString *identifier = [pbDictioanry objectForKey:@"Id"];
        if (identifier != nil) {
            [priceBookIds addObject:identifier];
        }
    }
    NSDictionary *tempDictionary = nil;
    if ([priceBookIds count] > 0) {
        /*get pricebook entry for these ids */
        NSArray *pricebookRecords =  [self getPriceBookEntryForLabourArray:labourArray andPriceBookIds:priceBookIds andCurrency:currency];
        tempDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"LABORPRICING",@"key",pricebookRecords,@"data",nil];
        
    }
    [priceBookIds release];
    priceBookIds = nil;
    [aPool release];
    aPool = nil;
    return [tempDictionary autorelease];
    
}

- (NSArray *)getPriceBookEntryForLabourArray:(NSArray *)labourArray andPriceBookIds:(NSArray *)priceBookIds andCurrency:(NSString *)currency {
    NSString *tableName = @"SVMXC__Service_Pricebook_Entry__c";
    NSString *priceBookIdString = [self getConcatenatedStringFromArray:priceBookIds withSingleQuotesAndBraces:YES];
    NSString *labourString = [self getConcatenatedStringFromArray:labourArray withSingleQuotesAndBraces:YES];
    
    if (labourString == nil) {
        labourString = @"()";
    }
    if (priceBookIdString == nil) {
        priceBookIdString = @"()";
    }
    
    NSDictionary *allFieldsOfTable = [self getAllFieldsOfTable:tableName];
    NSArray *allColumnNames = [allFieldsOfTable  allKeys];
    NSString *allColumnNamesString = [self getConcatenatedStringFromArray:allColumnNames withSingleQuotesAndBraces:NO];
    NSString *sqlQuery = nil;
    if (currency == nil) {
        sqlQuery = [[NSString alloc] initWithFormat:@"Select %@ from %@ where  SVMXC__Activity_Type__c IN %@ AND SVMXC__Price_Book__c IN %@",allColumnNamesString,tableName,labourString,priceBookIdString];
    }
    else {
        sqlQuery = [[NSString alloc] initWithFormat:@"Select %@ from %@ where SVMXC__Activity_Type__c IN %@ AND SVMXC__Price_Book__c IN %@ and CurrencyIsoCode = '%@'",allColumnNamesString,tableName,labourString,priceBookIdString,currency];
    }
    
    
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    sqlite3_stmt *selectStmt = nil;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sqlQuery UTF8String], -1, &selectStmt, nil) == SQLITE_OK  )
    {
        
        while(synchronized_sqlite3_step(selectStmt) == SQLITE_ROW)
        {
            NSMutableDictionary *recordDictionary = [[NSMutableDictionary alloc] init];
            
            NSString * tempString = @"";
			char * tempCharString = nil;
            
            for(int counter = 0;counter < [allColumnNames count];counter++) {
                
                tempCharString = (char *)sqlite3_column_text(selectStmt, counter);
                if (tempCharString != nil) {
                    tempString = [NSString stringWithUTF8String:tempCharString];
                    if (tempString != nil && counter < [allColumnNames count]) {
                        NSString *fieldName = [allColumnNames objectAtIndex:counter];
                        NSString *fieldType = [allFieldsOfTable objectForKey:fieldName];
                        SMLog(kLogLevelVerbose,@"Filed type is %@",fieldType);
                        if ([fieldType isEqualToString:@"boolean"]) {
                            tempString = [self changeTheBooleanValue:tempString];
                             [recordDictionary setObject:tempString forKey:fieldName];
                        }
                        else {
                            id someObject =  [self getTheProperObjectTypeForFieldType:fieldType andFieldValue:tempString];
                            if (someObject != nil) {
                                [recordDictionary setObject:someObject forKey:fieldName];
                            }
                        }
                       
                    }
                }
            }
            
            
            NSDictionary *tempDict = [[NSDictionary alloc] initWithObjectsAndKeys:tableName,@"type", nil];
            [recordDictionary setObject:tempDict forKey:@"attributes"];
            [tempDict release];
            tempDict = nil;
            
            [dataArray addObject:recordDictionary];
            
            [recordDictionary release];
            recordDictionary = nil;
            
            
        }
		
    }
    synchronized_sqlite3_finalize(selectStmt);
    [sqlQuery release];
    sqlQuery = nil;
    
    return [dataArray autorelease];
    
}
- (NSArray *)getValidLabourPriceBookNames:(NSArray *)labourPbNames andLabourIdArray:(NSArray *)labourIdArray andCurrency:(NSString *)currency{
    
    NSString *tablename = @"SVMXC__Service_Pricebook__c";
    
    NSString *priceBookIdString = [self getConcatenatedStringFromArray:labourIdArray withSingleQuotesAndBraces:YES];
    
    NSString *priceBookNameString = [self getConcatenatedStringFromArray:labourPbNames withSingleQuotesAndBraces:YES];
    
    NSString *activeString = @"(SVMXC__Active__c = '1' OR SVMXC__Active__c = 'True' OR SVMXC__Active__c = 'true')";
    
    NSString *sqlQuery = nil;
    
    if (priceBookIdString != nil && priceBookNameString != nil) {
        sqlQuery = [NSString stringWithFormat:@"SELECT Id, Name FROM %@ WHERE (Id IN %@ OR Name IN %@) and %@ ",tablename,priceBookIdString,priceBookNameString,activeString];
    }
    else if (priceBookIdString != nil){
        
        sqlQuery = [NSString stringWithFormat:@"SELECT Id, Name FROM %@ WHERE Id IN %@ and %@",tablename,priceBookIdString,activeString];
        
    }else if(priceBookNameString != nil){
        sqlQuery = [NSString stringWithFormat:@"SELECT Id, Name FROM %@ WHERE Name IN %@ and %@",tablename,priceBookNameString,activeString];
    }
    
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    sqlite3_stmt *selectStmt = nil;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sqlQuery UTF8String], -1, &selectStmt, nil) == SQLITE_OK  )
    {
        
        while(sqlite3_step(selectStmt) == SQLITE_ROW)
        {
            NSMutableDictionary *recordDictionary = [[NSMutableDictionary alloc] init];
            
            NSString * tempString = @"";
			char * tempCharString = nil;
            
            tempCharString = (char *)sqlite3_column_text(selectStmt, 0);
            if (tempCharString != nil) {
                tempString = [NSString stringWithUTF8String:tempCharString];
                [recordDictionary setObject:tempString forKey:@"Id"];
            }
            
            tempCharString = (char *)sqlite3_column_text(selectStmt, 1);
            if (tempCharString != nil) {
                tempString = [NSString stringWithUTF8String:tempCharString];
                [recordDictionary setObject:tempString forKey:@"Name"];
            }
            [dataArray addObject:recordDictionary];
        }
    
    }
    synchronized_sqlite3_finalize(selectStmt);
    return [dataArray autorelease];
    
    
}

- (NSString *)getValueFOrKey:(NSString *)key FromArray:(NSArray *)array {
    for (int counter = 0; counter < [array count]; counter++) {
        NSDictionary *tempDict = [array objectAtIndex:counter];
        NSString *keyNew = [tempDict objectForKey:@"key"];
        if ([keyNew isEqualToString:key]) {
            return [tempDict objectForKey:@"value"];
        }
    }
    return nil;
}
- (NSString *)changeTheBooleanValue:(NSString *)newString {
    NSString *someString = [newString lowercaseString];
    if ([someString isEqualToString:@"1"]) {
        return @"true";
    }
    else {
        
        if ([someString isEqualToString:@"true"] || [someString isEqualToString:@"false"]) {
            return someString;
        }
        else {
            if ([someString isEqualToString:@"0"]) {
                return @"false";
            }
            return someString;
        }
    }
    return @"false";
}


-(NSMutableDictionary *)getAllObjectFields:(NSString *)objectName tableName:(NSString *)tableName
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSString * field_api_name = @"", *fieldType = nil;
    if(objectName != nil || [objectName length ] != 0)
    {
        NSString * query = [NSString stringWithFormat:@"SELECT api_name , type from '%@' where object_api_name = '%@'" , tableName , objectName];
        sqlite3_stmt * stmt;
        if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
        {
            while (synchronized_sqlite3_step(stmt)  == SQLITE_ROW)
            {
                char * temp_process_id  = (char *)synchronized_sqlite3_column_text(stmt, 0);
                
                if(temp_process_id!= nil)
                    field_api_name = [NSString stringWithUTF8String:temp_process_id];
                
                
                char * typeOfField  = (char *)synchronized_sqlite3_column_text(stmt, 1);
                if(typeOfField!= nil)
                    fieldType = [NSString stringWithUTF8String:typeOfField];
                
                
                
                
                if([dict count] != 0)
                {
                    
                }
                [dict setObject:fieldType forKey:field_api_name];
                
            }
        }
        synchronized_sqlite3_finalize(stmt);
    }
    return [dict autorelease];
    
}

#pragma mark -
#pragma mark Get get price code snippet


- (NSString *)getGetPriceCodeSnippet:(NSString *)codeSnippetName {
    NSDictionary *codeSnippetDictMain = [self getCodeSnippetForName:codeSnippetName];
    
    NSString *codeSnippetId =  [codeSnippetDictMain objectForKey:@"key"];
    NSString *codeSnippetMain = [codeSnippetDictMain objectForKey:@"data"];
    NSMutableString *codeSnippetFinal = nil;
    if (![Utility isStringEmpty:codeSnippetId] &&![Utility isStringEmpty:codeSnippetMain] ) {
        codeSnippetFinal =  [[NSMutableString alloc] initWithString:codeSnippetMain];
        
        while (![Utility isStringEmpty:codeSnippetId]) {
            
            /*get the reference id from manifest */
            NSString *snippetId =  [self getCodeSnippetRefererenceForId:codeSnippetId];
            NSDictionary *tempDictionary =  [self getCodeSnippetForId:snippetId];
            if ([tempDictionary count] > 0) {
                codeSnippetId = [tempDictionary objectForKey:@"key"];
                NSString *tempStr = [tempDictionary objectForKey:@"data"];
                if(![Utility isStringEmpty:codeSnippetId] && ![Utility isStringEmpty:tempStr] ) {
                    [codeSnippetFinal appendFormat:@" %@",tempStr];
                }
                else {
                    codeSnippetId = nil;
                }
            }
            else {
                codeSnippetId = nil;
            }
            
        }
    }
    return [codeSnippetFinal autorelease];
}

- (NSDictionary *)getCodeSnippetForId:(NSString *)codeSnippetId {
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSString * fieldId = @"", *fieldData = nil;
    NSString * query = [NSString stringWithFormat:@"SELECT Id ,SVMXC__Data__c  from SVMXC__Code_Snippet__c  where Id = '%@' and SVMXC__Data__c <> \"\"" , codeSnippetId];
    sqlite3_stmt * stmt;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while (sqlite3_step(stmt)  == SQLITE_ROW)
        {
            char * temp_process_id  = (char *)sqlite3_column_text(stmt, 0);
            
            if(temp_process_id!= nil) {
                fieldId = [NSString stringWithUTF8String:temp_process_id];
                [dict setObject:fieldId forKey:@"key"];
            }
            
            
            char * typeOfField  = (char *)sqlite3_column_text(stmt, 1);
            if(typeOfField!= nil) {
                fieldData = [NSString stringWithUTF8String:typeOfField];
                [dict setObject:fieldData forKey:@"data"];
            }
            break;
        }
    }
    synchronized_sqlite3_finalize(stmt);
    
    return [dict autorelease];
    
    
}

- (NSDictionary *)getCodeSnippetForName:(NSString *)codeSnippetName {
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    NSString * fieldId = @"", *fieldData = nil;
    NSString * query = [NSString stringWithFormat:@"SELECT Id ,SVMXC__Data__c  from SVMXC__Code_Snippet__c  where SVMXC__Name__c  = '%@' and SVMXC__Data__c <> \"\"" , codeSnippetName];
    sqlite3_stmt * stmt;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while (sqlite3_step(stmt)  == SQLITE_ROW)
        {
            char * temp_process_id  = (char *)sqlite3_column_text(stmt, 0);
            
            if(temp_process_id!= nil) {
                fieldId = [NSString stringWithUTF8String:temp_process_id];
                [dict setObject:fieldId forKey:@"key"];
            }
            
            
            char * typeOfField  = (char *)sqlite3_column_text(stmt, 1);
            if(typeOfField!= nil) {
                fieldData = [NSString stringWithUTF8String:typeOfField];
                [dict setObject:fieldData forKey:@"data"];
            }
            break;
        }
    }
    synchronized_sqlite3_finalize(stmt);
    
    return [dict autorelease];
    
}
- (NSString *)getCodeSnippetRefererenceForId:(NSString *)codeSnippetReference {
   
    NSString * SVMXC__Code_Snippet_Manifest__c = nil;
    NSString * query = [NSString stringWithFormat:@"SELECT SVMXC__Referenced_Code_Snippet__c  from SVMXC__Code_Snippet_Manifest__c  where SVMXC__Code_Snippet__c = '%@' and SVMXC__Referenced_Code_Snippet__c <> \"\"" ,codeSnippetReference];
    sqlite3_stmt * stmt = nil;;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while (sqlite3_step(stmt)  == SQLITE_ROW)
        {
            char * temp_process_id  = (char *)sqlite3_column_text(stmt, 0);
            
            if(temp_process_id!= nil) {
                SVMXC__Code_Snippet_Manifest__c = [NSString stringWithUTF8String:temp_process_id];
                
            }
        }
    }
    synchronized_sqlite3_finalize(stmt);
    
    return SVMXC__Code_Snippet_Manifest__c;
}

- (NSDictionary *)getAllBooleanFieldsForTable:(NSString *)tablenName {
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSString * fieldId = @"";
    NSString * query = [NSString stringWithFormat:@"SELECT api_name FROM SFObjectField where object_api_name = '%@' and type = 'boolean'",tablenName];
    sqlite3_stmt * stmt;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while (sqlite3_step(stmt)  == SQLITE_ROW)
        {
            char * temp_process_id  = (char *)sqlite3_column_text(stmt, 0);
            
            if(temp_process_id!= nil) {
                fieldId = [NSString stringWithUTF8String:temp_process_id];
                [dict setObject:fieldId forKey:fieldId];
            }
            
        }
    }
    synchronized_sqlite3_finalize(stmt);
    
    return [dict autorelease];
}
//  Unused methods
//- (NSArray *)getAllMessagesForTagsArray:(NSArray *)tags {
//    
//    NSString *tagsConacatenatedString = [self getConcatenatedStringFromArray:tags withSingleQuotesAndBraces:YES];
//    if (tagsConacatenatedString == nil) {
//        tagsConacatenatedString  = @"()";
//    }
//   
//    NSMutableArray *tagsArray = [[NSMutableArray alloc] init];
//    NSString * query = [NSString stringWithFormat:@"SELECT tag_id, value FROM MobileDeviceTags where tag_id IN %@",tagsConacatenatedString];
//    sqlite3_stmt * stmt = nil;
//    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
//    {
//        while (sqlite3_step(stmt)  == SQLITE_ROW)
//        {
//              NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:0];
//            
//            NSString *tagId = nil, *tagValue = nil;
//            char * someCharStr  = (char *)sqlite3_column_text(stmt, 0);
//            
//            if(someCharStr!= nil) {
//                tagId = [NSString stringWithUTF8String:someCharStr];
//               
//            }
//            someCharStr = NULL;
//            someCharStr  = (char *)sqlite3_column_text(stmt, 1);
//            if(someCharStr!= nil) {
//                tagValue = [NSString stringWithUTF8String:someCharStr];
//                
//            }
//            if (tagValue != nil && tagId != nil) {
//                [dict setObject:tagValue forKey:@"value"];
//                [dict setObject:tagId forKey:@"key"];
//                [tagsArray addObject:dict];
//            }
//            [dict release];
//            dict = nil;
//        }
//    }
//    synchronized_sqlite3_finalize(stmt);
//    
//    return [tagsArray autorelease];
//}

#pragma mark -
#pragma mark Getting entitlement status of record
- (NSString *)getEntitlementStatus:(NSString *)recordIdentfier recordIdFromTable:(NSString *)tableName {
    
    NSString * fieldId = nil;
    NSString * query = [NSString stringWithFormat:@"SELECT SVMXC__Is_Entitlement_Performed__c FROM %@ where Id = '%@'",tableName,recordIdentfier];
    sqlite3_stmt * stmt;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(stmt)  == SQLITE_ROW)
        {
            char * temp_process_id  = (char *)sqlite3_column_text(stmt, 0);
            
            if(temp_process_id!= nil) {
                fieldId = [NSString stringWithUTF8String:temp_process_id];
                
            }            
        }
    }
    synchronized_sqlite3_finalize(stmt);
    return fieldId;
}

- (BOOL)doesAllRecordsForGetPriceCalculationExist:(NSString *)recordId {
    
    NSDictionary *someDictionary =  [self getEntitlementHistoryForWorkorder:recordId];
    if(someDictionary != nil && [someDictionary count] > 0 ){
        
        NSString *SVMXC__Warranty__c         = [someDictionary objectForKey:@"SVMXC__Warranty__c"];
        NSString *SVMXC__Service_Contract__c = [someDictionary objectForKey:@"SVMXC__Service_Contract__c"];
        NSInteger  numberOfRecordsOne = -1 , numberOfRecordsTwo = -1;
        if (![Utility isStringEmpty:SVMXC__Warranty__c]) {
            numberOfRecordsOne =  [self getRecordCountForSfId:SVMXC__Warranty__c andTableName:@"SVMXC__Warranty__c"];
        }
        else {
            numberOfRecordsOne = 1;
        }
        
        if (![Utility isStringEmpty:SVMXC__Service_Contract__c]) {
            numberOfRecordsTwo =  [self getRecordCountForSfId:SVMXC__Service_Contract__c andTableName:@"SVMXC__Service_Contract__c"];
        }
        else {
            numberOfRecordsTwo = 1;
        }
        if (numberOfRecordsOne > 0 || numberOfRecordsTwo > 0) {
            return YES;
        }
    }
    else {
        return YES;
    }
    
    return NO;
}


- (NSInteger)getRecordCountForSfId:(NSString *)sfId andTableName:(NSString *)tableName {
    
    NSString *sqlQuery = [NSString  stringWithFormat:@"select count(*) from %@ where  Id = '%@'",tableName,sfId];
    
    sqlite3_stmt *selectStmt = nil;
    NSInteger counter = -1;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sqlQuery UTF8String], -1, &selectStmt, nil) == SQLITE_OK  )
    {
        while(synchronized_sqlite3_step(selectStmt) == SQLITE_ROW)
        {
            counter = sqlite3_column_int(selectStmt, 0);
        }
    }
    synchronized_sqlite3_finalize(selectStmt);
    return counter;
}

- (NSString *)getSFIdForlocalId:(NSString *)workOrderLocalId andTableName:(NSString *)tableName {
    NSString * fieldId = nil;
    NSString * query = [NSString stringWithFormat:@"SELECT Id FROM %@ where local_id = '%@'",tableName,workOrderLocalId];
    sqlite3_stmt * stmt;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(stmt)  == SQLITE_ROW)
        {
            char * temp_process_id  = (char *)sqlite3_column_text(stmt, 0);
            
            if(temp_process_id!= nil) {
                fieldId = [NSString stringWithUTF8String:temp_process_id];
            }
        }
    }
    synchronized_sqlite3_finalize(stmt);
    return fieldId;
    
}

- (id)getTheProperObjectTypeForFieldType:(NSString *)fieldType andFieldValue:(NSString *)fieldValue {
    id someObject = fieldValue;
    
    fieldType = [fieldType uppercaseString];
    NSString *newFieldType = [appDelegate.dataBase columnType:fieldType];
    if ([newFieldType isEqualToString:DOUBLE]) {
        someObject = [NSNumber numberWithDouble:[fieldValue doubleValue]];
       
    }
    else if ([newFieldType isEqualToString:INTEGER]) {
        someObject = [NSNumber numberWithInt:[fieldValue intValue]];
       
    }
    return someObject;
}


#pragma mark - Check for billable price 

- (BOOL)checkIfBillablePriceExistForWorkOrderId:(NSString *)workOrderLocalId andFieldName:(NSString *)fieldName {
    
    NSString *sfmId = [self getSFIdForlocalId:workOrderLocalId andTableName:@"SVMXC__Service_Order__c"];
    
    /* Get all lines and check if one billable price exist and non empty  */
    
    NSString *sqlQuery = [NSString stringWithFormat:@"select %@ from SVMXC__Service_Order_Line__c where (SVMXC__Service_Order__c = '%@' OR SVMXC__Service_Order__c = '%@')", fieldName,workOrderLocalId,sfmId ];
    sqlite3_stmt * stmt;
    
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sqlQuery UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(stmt)  == SQLITE_ROW)
        {
            char * fieldValue  = (char *)sqlite3_column_text(stmt, 0);
            
            if(fieldValue != nil) {
                NSString *priceValue = [NSString stringWithUTF8String:fieldValue];
                if (![Utility isStringEmpty:priceValue]) {
                    
                    synchronized_sqlite3_finalize(stmt);
                    return YES;
                }
            }
        }
    }
    synchronized_sqlite3_finalize(stmt);
    return NO;
}


/*Shravya-Calendar view */
#pragma mark - New conflict handling in calendar events

- (NSArray *)readConflictTableForEventInfo {
    
    NSString * query = [NSString stringWithFormat:@"SELECT sf_id, local_id, object_name, record_type FROM 'sync_error_conflict'"];
    sqlite3_stmt * statement = nil;
    int i = 0;
    NSString *fieldValue = nil;
    NSMutableArray *conflictArray = [[NSMutableArray alloc] init];
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, nil) ==  SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            i = 0;
            NSMutableDictionary *conflictDictionary = [[NSMutableDictionary alloc] init];
            
            char * temp_field_value= (char * ) synchronized_sqlite3_column_text(statement, i);
            if(temp_field_value != nil)
            {
                fieldValue  = [NSString stringWithUTF8String:temp_field_value];
                if (fieldValue != nil) {
                    [conflictDictionary setObject:fieldValue forKey:@"sf_id"];
                }
            }
            temp_field_value = nil;
            fieldValue = nil;
            i++;
            
            temp_field_value= (char * ) synchronized_sqlite3_column_text(statement, i);
            if(temp_field_value != nil)
            {
                fieldValue  = [NSString stringWithUTF8String:temp_field_value];
                if (fieldValue != nil) {
                    [conflictDictionary setObject:fieldValue forKey:@"local_id"];
                }
            }
            temp_field_value = nil;
            fieldValue = nil;
            i++;
            
            
            temp_field_value= (char * ) synchronized_sqlite3_column_text(statement, i);
            if(temp_field_value != nil)
            {
                fieldValue  = [NSString stringWithUTF8String:temp_field_value];
                if (fieldValue != nil) {
                    [conflictDictionary setObject:fieldValue forKey:@"object_name"];
                }
            }
            temp_field_value = nil;
            fieldValue = nil;
            i++;
            
            
            temp_field_value= (char * ) synchronized_sqlite3_column_text(statement, i);
            if(temp_field_value != nil)
            {
                fieldValue  = [NSString stringWithUTF8String:temp_field_value];
                if (fieldValue != nil) {
                    [conflictDictionary setObject:fieldValue forKey:@"record_type"];
                }
            }
            temp_field_value = nil;
            fieldValue = nil;
            i++;
            
            
            [conflictArray addObject:conflictDictionary];
            [conflictDictionary release];
            conflictDictionary = nil;
        }
    }
    synchronized_sqlite3_finalize(statement);
    
    if([conflictArray count] > 0){
        [self getParentIdIfany:conflictArray];
        return [conflictArray autorelease];
    }
    [conflictArray release];
    conflictArray = nil;
    return nil;
}


- (void)getParentIdIfany:(NSMutableArray *)conflictArray {
    
    NSMutableDictionary *parentColumnNameDictionary = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *isChildDictionary = [[NSMutableDictionary alloc] init];
    
    for(int counter = 0; counter < [conflictArray count];counter++){
        NSMutableDictionary *conflictDict = [conflictArray objectAtIndex:counter];
        NSString *objectName = [conflictDict objectForKey:@"object_name"];
        if (objectName == nil) {
            continue;
        }
        
        NSInteger someIntValue = [[isChildDictionary objectForKey:objectName] intValue];
        if (someIntValue < 1) {
            BOOL isItTrue =  [appDelegate.databaseInterface IsChildObject:objectName];
            if (isItTrue) {
                someIntValue = 11; //true
            }
            else{
                someIntValue = 12;//false
            }
            [isChildDictionary setObject:[NSString stringWithFormat:@"%d",someIntValue] forKey:objectName];
        }
        
        if(someIntValue == 12){
            continue;
        }
        
        
        NSString *parentColumnName = [parentColumnNameDictionary objectForKey:objectName];
        
        if(parentColumnName == nil){
            parentColumnName = [self getParentNameForChildObjectName:objectName];
            if(parentColumnName != nil){
                [parentColumnNameDictionary setObject:parentColumnName forKey:objectName];
            }
        }
        
        if (![Utility isStringEmpty:parentColumnName]) {
            NSString *localId = [conflictDict objectForKey:@"local_id"];
            NSString *sfId = [conflictDict objectForKey:@"sf_id"];
            NSString *query = [NSString stringWithFormat:@"Select %@ from '%@' where ( Id = '%@' OR local_id = '%@') ",parentColumnName,objectName,sfId,localId];
            NSString *parentId = [self executeThisQueryForSingleColumnName:query];
            if (![Utility isStringEmpty:parentId]) {
                [conflictDict setObject:parentId forKey:@"parent_id"];
            }
        }
    }
    
    [parentColumnNameDictionary release];
    [isChildDictionary release];
}

- (NSString *)getParentNameForChildObjectName:(NSString *)childObjectName {
    NSString * fieldValue = @"";
    NSString * query = [NSString stringWithFormat:@"SELECT object_api_name_parent FROM SFChildRelationship Where object_api_name_parent = field_api_name and object_api_name_child = '%@' and object_api_name_parent != \"\"",childObjectName];
    sqlite3_stmt * statement = nil;
    
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

- (NSString *)executeThisQueryForSingleColumnName:(NSString *)query {
    NSString * fieldValue = @"";
    sqlite3_stmt * statement = nil;
    
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

#pragma - Sync conflict exist
- (BOOL)checkSyncConflictFor:(NSString *)sfId
                 WithLocalId:(NSString *)localId
              withObjectName:(NSString *)objectName
                    andArray:(NSArray *)conflictArray {
    
    BOOL conflictExist = NO;
    
    for (int counter = 0; counter < [conflictArray count]; counter++) {
        
        NSDictionary *finalDictionary = [conflictArray objectAtIndex:counter];
        NSString *sfIdConflict = [finalDictionary objectForKey:@"sf_id"];
        NSString *localIdConflict = [finalDictionary objectForKey:@"local_id"];
        
        if (![Utility isStringEmpty:sfIdConflict] && ([sfIdConflict isEqualToString:sfId] || [sfIdConflict isEqualToString:localId])) {
            conflictExist = YES;
        }
        
        if (![Utility isStringEmpty:localId] && [localId isEqualToString:localIdConflict]) {
            conflictExist = YES;
        }
        
        if (!conflictExist) {
            NSString *parentIdConflict = [finalDictionary objectForKey:@"parent_id"];
            
            if (![Utility isStringEmpty:parentIdConflict] && ([parentIdConflict isEqualToString:localId] || [parentIdConflict isEqualToString:sfId])) {
                conflictExist = YES;
            }
            
        }
        if (conflictExist) {
            break;
        }
    }
    return conflictExist;
}

//7280
- (NSString *) getUserIdFromUserTable
{
	NSString * Id = nil;
	
	NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
	
	NSString * currentUserName = [userDefaults valueForKey:@"UserFullName"];
	
	if ([currentUserName length] > 0 && currentUserName != nil)
	{
		Id = [appDelegate.dataBase getLoggedInUserId:currentUserName];
	}
	
	return Id;
	
}

@end