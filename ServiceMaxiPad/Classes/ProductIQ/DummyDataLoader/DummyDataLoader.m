//
//  DummyDataLoader.m
//  ServiceMaxiPad
//
//  Created by Admin on 27/08/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "DummyDataLoader.h"
#import "DBManager.h"

@implementation DummyDataLoader

-(void)loadDataIntables
{
    NSString *query = @"Select * from Translations";
    
    NSMutableArray *data = [[DBManager getSharedInstance] executeQuery:query];

    if (data.count) {
        return;
    }
//    [self createTestTables];
    NSArray *lTableArray = @[@"ObjectDescribe",@"Configuration", @"RecordName", @"Translations"];
    
    for (NSString *tableName in lTableArray) {
        [self loadDataForTable:tableName];
    }
}

-(void)createTestTables
{
    NSMutableArray  *newTables = [NSMutableArray new];
    //Create Tables
    //DROP TABLE IF EXISTS 'ClientCache';
    NSString *createClientCache = @"CREATE TABLE 'ClientCache' ( 'RecordId' INTEGER PRIMARY KEY AUTOINCREMENT, 'Key'	VARCHAR UNIQUE, 'Value'	VARCHAR);";
    [newTables addObject:createClientCache];
    
    NSString *ClientSyncConflict = @"CREATE TABLE 'ClientSyncConflict' ( 'RecordId'	INTEGER PRIMARY KEY AUTOINCREMENT, 'Id'	VARCHAR UNIQUE, 'ObjectName'	VARCHAR, 'Type'	VARCHAR, 'Message'	VARCHAR, 'CreatedDate'	VARCHAR, 'Action'	VARCHAR);";
    [newTables addObject:ClientSyncConflict];
    
    NSString *ClientSyncLog = @"CREATE TABLE 'ClientSyncLog' ( 'RecordId'	INTEGER PRIMARY KEY AUTOINCREMENT, 'Id'	VARCHAR UNIQUE, 'ObjectName'	VARCHAR, 'Operation'	VARCHAR, 'LastModifiedDate'	VARCHAR, 'Pending'	VARCHAR);";
    [newTables addObject:ClientSyncLog];
    
    NSString *ClientSyncLogTransient= @"CREATE TABLE 'ClientSyncLogTransient' ( 'RecordId'	INTEGER PRIMARY KEY AUTOINCREMENT, 'Id'	VARCHAR UNIQUE, 'ObjectName'	VARCHAR, 'Operation'	VARCHAR, 'LastModifiedDate'	VARCHAR, 'Pending'	VARCHAR);";
    [newTables addObject:ClientSyncLogTransient];
    
    NSString *RecordName = @"CREATE TABLE  'RecordName ' (  'RecordId'	INTEGER PRIMARY KEY AUTOINCREMENT,  'Id '	VARCHAR UNIQUE,  'Name '	VARCHAR);";
    [newTables addObject:RecordName];
    
    NSString *SVMXC__Sub_Location__c = @"CREATE TABLE  'SVMXC__Sub_Location__c ' (  'RecordId '	INTEGER PRIMARY KEY AUTOINCREMENT,  'Id '	VARCHAR UNIQUE,  'OwnerId '	VARCHAR,  'IsDeleted '	VARCHAR,  'Name '	VARCHAR,  'CurrencyIsoCode '	VARCHAR,  'CreatedDate '	VARCHAR,  'CreatedById '	VARCHAR,  'LastModifiedDate '	VARCHAR,  'LastModifiedById '	VARCHAR,  'SystemModstamp '	VARCHAR,  'LastActivityDate '	VARCHAR,  'MayEdit '	VARCHAR,  'IsLocked '	VARCHAR,  'SVMXC__Account__c '	VARCHAR,  'SVMXC__City__c '	VARCHAR,  'SVMXC__Country__c '	VARCHAR,  'SVMXC__Email__c '	VARCHAR,  'SVMXC__Fax__c '	VARCHAR,  'SVMXC__Latitude__c '	VARCHAR,  'SVMXC__Location__c '	VARCHAR,  'SVMXC__Longitude__c '	VARCHAR,  'SVMXC__Parent__c '	VARCHAR,  'SVMXC__Phone__c '	VARCHAR,  'SVMXC__State__c '	VARCHAR,  'SVMXC__Street__c '	VARCHAR,  'SVMXC__Web_site__c '	VARCHAR,  'SVMXC__Zip__c '	VARCHAR );";
    [newTables addObject:SVMXC__Sub_Location__c];
    
    for (NSString *tableNameString in newTables) {
        [[DBManager getSharedInstance] executeQuery:tableNameString];

    }
    
}
-(void)loadDataForTable:(NSString *)tableName
{
    NSStringEncoding encoding;
    NSString *path1=[[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:tableName ofType:@"csv"]  usedEncoding:&encoding error:nil];
    //You will get the array of lines
    NSArray *messArr=[path1 componentsSeparatedByString:@"\n"];
    
    
    NSArray *fields;
    //Now start to process each single line.
    if(messArr)
    {
        for(int i=0;i<=[messArr count]-1;i++)
        {
            
            NSString *StrValue=[NSString stringWithFormat:@"%@",[messArr objectAtIndex:i]];
            StrValue=[StrValue stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            StrValue=[StrValue stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            if (i==0)
            {
                fields = [StrValue componentsSeparatedByString:@"|"];
                continue;
            }
            
            NSArray *arr=[StrValue componentsSeparatedByString:@"|"];
            
            /*Add value for each column into dictionary*/
            if (arr.count !=fields.count) {
                continue;
            }
            
            NSString *tableFields = [fields componentsJoinedByString:@","];
            
            NSString *fieldValues=@"";

            for (NSString *string in arr){
               NSString *string2 = [string stringByReplacingOccurrencesOfString:@"'" withString:@" "];
                fieldValues = [fieldValues stringByAppendingFormat:@"'%@',",string2];
            }

            fieldValues = [fieldValues substringToIndex:fieldValues.length-1];
            
            NSString *insertString = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)", tableName, tableFields, fieldValues];

            [[DBManager getSharedInstance] executeQuery:insertString];

        }
    }
}

@end
