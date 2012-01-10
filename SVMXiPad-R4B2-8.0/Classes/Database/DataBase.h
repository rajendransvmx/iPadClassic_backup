//
//  DataBase.h
//  iService
//
//  Created by Developer on 7/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sqlite3.h>
#include "ZKSforce.h"
#import "DataBaseGlobals.h"

@class iServiceAppDelegate;

@interface DataBase : NSObject 
{
    NSString *dbFilePath;
	//sqlite3  *db;
    
    
    BOOL didInsertTable;
    
    iServiceAppDelegate * appDelegate;
    
}

@property (nonatomic, retain) NSString *dbFilePath;
//@property (nonatomic) sqlite3  *db;

@property BOOL didInsertTable;

//- initWithDBName:(NSString *)name type:(NSString *)type sqlite:(sqlite3 *)db;

//Insert InTo Table Methods
- (void) insertValuesInToOBjDefTableWithObject:(NSMutableArray *)object definition:(NSMutableArray *)objectDefinition;
- (void) insertValuesInToReferenceTable:(NSMutableArray *)object definition:(NSMutableArray *)objectDefinition;
- (void) insertValuesInToObjectTable:(NSMutableArray *)object definition:(NSMutableArray *)objectDefintion;
- (void) insertValuesInToRecordType:(NSMutableArray *)object defintion:(NSMutableArray *)objectDefinition;


//Expressions 
- (void) insertValuesInToExpressionTables:(NSMutableDictionary *)processDictionary;

//Objectmapping
- (void) insertValuesInToObjectMappingTable:(NSMutableDictionary *)processDictionary;

// Insert values into picklist table
- (void) insertvaluesToPicklist:(NSMutableArray *)object fields:(NSMutableArray *)fields value:(NSMutableArray *)values;

//SFProcess
- (void) insertValuesToProcessTable:(NSMutableDictionary *)processDictionary page:(NSMutableArray *)pageHistory;

//Create Table with coloumns
- (void) createObjectTable:(NSMutableArray *)object coulomns:(NSMutableArray *)columns;
- (void) insertColoumnsForTable:(NSString *)tableName columns:(NSMutableArray *)columns;


//column type
- (NSString *) columnType:(NSString *)type;

//tags and settings
- (void) insertValuesInToTagsTable:(NSMutableDictionary *)tagsDictionary;
- (void) insertValuesInToSettingsTable:(NSMutableDictionary *)settingsDictionary;

//Wizards and Wizard_component
- (void) insertValuesInToSFWizardsTable:(NSDictionary *)wizardDict;

//Lookuptable
- (void) insertValuesInToLookUpTable:(NSMutableDictionary *)processDictionary;
//Test
//-(void)openDB:(NSString *)name type:(NSString *)type sqlite:(sqlite3 *)database;

//Clear Database
- (void) clearDatabase;
- (BOOL) createTable:(NSString *)statement;

//Retreive All Tags
- (NSMutableDictionary *) getTagsDictionary;

//Add username to the user table.
- (void) insertUsernameToUserTable:(NSString *)UserName;

//- (NSMutableArray *) collectAllPicklistField;

//Method to create extra table for trouble shooting and summary
- (void) createTableForSummaryAndTroubleShooting;


//To Test the blob data
//- (void) testData;


//Macros For Database
/*#define DATABASENAME1            @"SFM1"
#define DATABASETYPE1           @"sqlite"

//Table Names
#define SFOBJECTFIELDM          @"SFObjectField"
#define SFREFERENCETO           @"SFReferenceTo"
#define SFPICKLIST              @"SFPicklist"
#define SFPROCESS               @"SFProcess"


//Coluonm Names
#define LOCAL_ID                @"local_id"
#define OBJECT_API_NAME         @"object_api_name"
#define FIELD_API_NAME          @"api_name"
#define REFERENCE_TO            @"reference_to"
#define LENGTH                  @"length"
#define TYPEM                   @"type"
#define RELATIONSHIP_NAME       @"relationship_name"
#define LABEL                   @"label"
#define VALUEM                  @"value"
#define DEFAULTVALUE            @"defaultvalue"
#define PROCESS_ID              @"process_id"
#define PROCESS_TYPE            @"process_type"
#define PROCESS_NAME            @"process_name"
#define PROCESS_DESCRIPTION     @"process_description"
#define PROCESS_INFO            @"process_info"

//KEYS
#define OBJECT                  @"OBJECT"
#define FIELD                   @"FIELD"
#define _LENGTH                 @"LENGTH"
#define _TYPE                   @"TYPE"
#define _REFERENCETO            @"REFERENCETO"
#define _RELATIONSHIPNAME       @"RELATIONSHIPNAME"
#define DEFAULTPICKLISTVALUE    @"DEFAULTPICKLISTVALUE"

//TYPES
#define BOOLEAN                 @"BOOLEAN"
#define _BOOL                   @"BOOL"
#define CURRENCY                @"CURRENCY"
#define DOUBLE                  @"DOUBLE"
#define PERCENT                 @"PERCENT"
#define INTEGER                 @"INTEGER"
#define DATE                    @"DATE"
#define DATETIME                @"DATETIME"
#define TEXTAREA                @"TEXTAREA"
#define VARCHAR                 @"VARCHAR"
#define TEXT                    @"TEXT"*/

@end
