//
//  SearchDBServices.m
//  ServiceMaxiPhone
//
//  Created by Damodar on 6/27/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "SearchDBServices.h"
#import "SFMSearchProcessModel.h"
#import "SFMSearchObjectModel.h"
#import "SFMSearchFieldModel.h"
#import "SFMRecordFieldData.h"
#import  "SFExpressionComponentModel.h"
#import "RequestConstants.h"
#import "ResponseConstants.h"
#import "Utility.h"
#import "SFObjectModel.h"
#import "SFObjectService.h"
#import "FactoryDAO.h"
#import "SFMSearchFieldDAO.h"
#import "DatabaseConstant.h"

//#import "SMXiPhone_ObjectDefinitionService.h"


/*
 MetaData
    Process
    Objects
    Fields - Search, sort, display
    Entry Criteria - expr parser - get the exprsn
 
 Data
   Query creation:
    Select
    From
    Where
 
    Get query
    Get data from query
    Replace with display values for reference, picklist, display picklist, Date
 
 */

@interface SearchDBServices()

@property(nonatomic,strong) SFObjectService *objectDefnService;
@property(nonatomic,strong) NSMutableDictionary *objectPermissionDictionary;

@end

@implementation SearchDBServices

- (id)init {
    self = [super init];
    if (self != nil) {
        self.objectDefnService = [[SFObjectService alloc] init];
    }
    return self;
}

/*
// Move to DAO servicess - DONE
- (void)getNameFieldValuesIn:(NSMutableDictionary *)idsDictionary forIds:(NSString*)idsString
{
    @autoreleasepool {
        
        NSString *selectQuery = [NSString stringWithFormat:@"SELECT DISTINCT Id, value FROM ObjectNameFieldValue where Id IN  %@",idsString];
        
        sqlite3_stmt *selectStmt = nil;
        int preparedSuccessfully =  synchronized_sqlite3_prepare_v2(  [[SMXiPhone_Database sharedDataBase] databaseObject], [selectQuery UTF8String], (int)strlen([selectQuery UTF8String]), &selectStmt, NULL);
        if (preparedSuccessfully == SQLITE_OK) {
            
            while (synchronized_sqlite3_step(selectStmt) == SQLITE_ROW) {
                NSString *value = nil, *identifier = nil;
                
                char *_cString = (char *)synchronized_sqlite3_column_text(selectStmt,0);
                if (_cString != NULL) {
                    identifier = [NSString stringWithUTF8String:_cString];
                    
                }
                
                _cString = (char *)synchronized_sqlite3_column_text(selectStmt,1);
                if (_cString != NULL) {
                    value = [NSString stringWithUTF8String:_cString];
                    
                }
                
                if (identifier != nil && value != nil) {
                    [idsDictionary setObject:value forKey:identifier]; // idsDictionary initially contains { Id : nameValue }
                }
                
            }
            
        }
        synchronized_sqlite3_finalize(selectStmt);
    }
}

// Move to DAO servicess - DONE
- (NSArray*)getListOfSearchProcesses
{
    NSMutableArray *searchProcesses = [NSMutableArray array];
    
    NSString *selectQuery = [NSString stringWithFormat:@"SELECT local_id, Id, Name, process_description, process_name FROM %@",kSVMXSearchProcess];
    sqlite3_stmt *selectStmt = nil;
    
    int i =0;
    int preparedSuccessfully =  synchronized_sqlite3_prepare_v2(  [[SMXiPhone_Database sharedDataBase] databaseObject], [selectQuery UTF8String], strlen([selectQuery UTF8String]), &selectStmt, NULL);
    if (preparedSuccessfully == SQLITE_OK) {
        
        while (synchronized_sqlite3_step(selectStmt) == SQLITE_ROW)
        {
            i = 0;
            SFMSearchProcess *process = [[SFMSearchProcess alloc] init];
            process.localId = [self extractTextFromSqliteStmt:selectStmt AtIndex:i];i++;
            process.identifier = [self extractTextFromSqliteStmt:selectStmt AtIndex:i];i++;
            process.name  = [self extractTextFromSqliteStmt:selectStmt AtIndex:i];i++;
            process.processDescription = [self extractTextFromSqliteStmt:selectStmt AtIndex:i];i++;
            process.processName = [self extractTextFromSqliteStmt:selectStmt AtIndex:i];
            
            [searchProcesses addObject:process];
        }
    }
    synchronized_sqlite3_finalize(selectStmt);

    
    return (NSArray*)searchProcesses;
}

// Move to DAO servicess - DONE
- (NSArray *)getSearchobjectsForProcess:(SFMSearchProcessModel *)searchProcess {
    
    NSMutableArray *searchObjects = [[NSMutableArray alloc] init];
    NSString *selectQuery = [NSString stringWithFormat:@"SELECT ObjectID,Name,AdvanceExpression,ModuleId, TargetObjectName FROM SFM_Search_Objects WHERE ModuleId = '%@'  ORDER BY sequence ",searchProcess.identifier];
     sqlite3_stmt *selectStmt = nil;
    int i =0;
    int preparedSuccessfully =  synchronized_sqlite3_prepare_v2(  [[SMXiPhone_Database sharedDataBase] databaseObject], [selectQuery UTF8String], strlen([selectQuery UTF8String]), &selectStmt, NULL);
    if (preparedSuccessfully == SQLITE_OK) {
        
        while (synchronized_sqlite3_step(selectStmt) == SQLITE_ROW) {
            i = 0;
            SFMSearchObject *searchObject = [[SFMSearchObject alloc] init];
            searchObject.objectId = [self extractTextFromSqliteStmt:selectStmt AtIndex:i];i++;
            searchObject.name = [self extractTextFromSqliteStmt:selectStmt AtIndex:i];i++;
            searchObject.advancedExpression = [self extractTextFromSqliteStmt:selectStmt AtIndex:i];i++;
            searchObject.moduleId = [self extractTextFromSqliteStmt:selectStmt AtIndex:i];i++;
            searchObject.targetObjectName = [self extractTextFromSqliteStmt:selectStmt AtIndex:i];
            [searchObjects addObject:searchObject];
        }
    }
     synchronized_sqlite3_finalize(selectStmt);
    return searchObjects;
}


// Move to DAO servicess - DONE
- (NSArray *)getAllFieldsForSearchObject:(SFMSearchObject *)searchObject {
    
    NSMutableArray *searchObjects = [[NSMutableArray alloc] init];
    NSString *selectQuery = [NSString stringWithFormat:@"SELECT Id,field_name,object_name,field_type,display_type, object_ID,expression_rule, object_name2,lookup_field_apiName, field_relationship_name,sort_order FROM SFM_Search_Field  WHERE expression_rule = '%@'  ORDER BY sequence ",searchObject.objectId];
    sqlite3_stmt *selectStmt = nil;
    int i =0;
    int preparedSuccessfully =  synchronized_sqlite3_prepare_v2(  [[SMXiPhone_Database sharedDataBase] databaseObject], [selectQuery UTF8String], strlen([selectQuery UTF8String]), &selectStmt, NULL);
    if (preparedSuccessfully == SQLITE_OK) {
        
        while (synchronized_sqlite3_step(selectStmt) == SQLITE_ROW) {
            i = 0;
            SFMSearchField *searchField = [[SFMSearchField alloc] init];
            searchField.identifier = [self extractTextFromSqliteStmt:selectStmt AtIndex:i];i++;
            searchField.fieldName = [self extractTextFromSqliteStmt:selectStmt AtIndex:i];i++;
            searchField.relatedObjectName = [self extractTextFromSqliteStmt:selectStmt AtIndex:i];i++;
            searchField.searchFieldType = [[self extractTextFromSqliteStmt:selectStmt AtIndex:i] lowercaseString];i++;
            searchField.dataType = [[self extractTextFromSqliteStmt:selectStmt AtIndex:i] lowercaseString];i++;
            searchField.objectId = [self extractTextFromSqliteStmt:selectStmt AtIndex:i];i++;
            searchField.expressionRule = [self extractTextFromSqliteStmt:selectStmt AtIndex:i];i++;
            searchField.objectName = [self extractTextFromSqliteStmt:selectStmt AtIndex:i];i++;
            searchField.lookUpFieldName = [self extractTextFromSqliteStmt:selectStmt AtIndex:i];i++;
            searchField.relationshipName = [self extractTextFromSqliteStmt:selectStmt AtIndex:i];i++;
            searchField.sortOrder = [[self extractTextFromSqliteStmt:selectStmt AtIndex:i] lowercaseString];i++;
            
//            if ([self isRecordTypeObject:searchField.objectName]) {
//                continue;
//            }
            BOOL hasPermission = [self doesObjectHavePermission: searchField.objectName];
            if (hasPermission) {
                [searchObjects addObject:searchField];
            }
        }
    }
    synchronized_sqlite3_finalize(selectStmt);
    return searchObjects;
}

// DONE - By default available in object model
- (BOOL)isRecordTypeObject:(NSString *)objectName {
    if ([objectName isEqualToString:@"RecordType"]) {
        return YES;
    }
    return NO;
}
 */

// Done for redesign
- (void)fillUpSearchFieldsIntoObject:(SFMSearchObjectModel *)searchObject {
    @autoreleasepool {
       /*Get all fields for given search object */
        
        //                        |
        // USE DAO SERVICES HERE \|/
        
        id service = [FactoryDAO serviceByServiceType:ServiceTypeSFMSearchField];
        
        NSArray *searchFieldArray = [service getAllFieldsForSearchObject:searchObject];
        
         /* Distribute the field based on type */
        if ([searchFieldArray count] > 0) {
            
            NSMutableArray *displayFields = [[NSMutableArray alloc] init];
            NSMutableArray *sortFields = [[NSMutableArray alloc] init];
            NSMutableArray *searchFieldList = [[NSMutableArray alloc] init];
            
            for (SFMSearchFieldModel *searchField in searchFieldArray) {
                
                if ([searchField.fieldType isEqualToString:kSearchFieldTypeSearch]) {
                    [searchFieldList addObject:searchField];
                }
                else if ([searchField.fieldType isEqualToString:kSearchFieldTypeResult ]){
                     [displayFields addObject:searchField];
                }
                else if ([searchField.fieldType isEqualToString:kSearchFieldTypeOrderBy ]){
                    [sortFields addObject:searchField];
                }
                
            }
            searchObject.displayFields = displayFields;
            searchObject.searchFields = searchFieldList;
            searchObject.sortFields = sortFields;
        }
       
    }
}

/*
// TODO - Doestable exists for object name - write a common service - DONE
- (BOOL)doesObjectHavePermission:(NSString *)objectName {
    if (self.objectPermissionDictionary == nil) {
        self.objectPermissionDictionary = [[NSMutableDictionary alloc] init];
    }
    
    NSString *doesExist = [self.objectPermissionDictionary objectForKey:objectName];
    if (doesExist == nil) {
       BOOL hasPermission = [self.objectDefnService doesTableExistForObjectName:objectName];
        doesExist = (hasPermission)?kTrue:kFalse;
        [self.objectPermissionDictionary setObject:doesExist forKey:objectName];
    }
    if ([doesExist isEqualToString:kTrue]) {
        return YES;
    }
    return NO;
}
*/

#pragma mark - Data loading utilities
// Write in SFObjectFieldService DAO
- (NSString *)getFieldNameFromRelationShipName:(NSString *)relationShip
                         withRelatedObjectName:(NSString *)relatedObjctName
                          andCurrentobjectName:(NSString *)objectName {

    return  [ self.objectDefnService getFieldNameForRelationShipName:relationShip withRelatedObjectName:relatedObjctName andObjectName:objectName];

    
}

- (NSString *)getNameFieldFOrObjectName:(NSString *)objectName {
    
    return  [ self.objectDefnService getNameFieldForObject:objectName];
    
    
}

#pragma mark End

- (NSMutableArray *)getDataForQuery:(NSString *)searchQuery andObject:(SFMSearchObjectModel *)searchObject {
    
    NSArray *displayFields = searchObject.displayFields;
    
    NSInteger extraCount = 2;
    NSString *emptyString = @"";
    NSInteger totalCount = [displayFields count] + extraCount;
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    sqlite3_stmt *selectStmt = nil;
    
    char *cQuery = (char *)[searchQuery UTF8String];
    int preparedSuccessfully =  synchronized_sqlite3_prepare_v2(  [[SMXiPhone_Database sharedDataBase] databaseObject], cQuery, strlen(cQuery), &selectStmt, NULL);
    if (preparedSuccessfully == SQLITE_OK) {
        
        while (synchronized_sqlite3_step(selectStmt) == SQLITE_ROW) {
            
            NSMutableDictionary *recordDictionary = [[NSMutableDictionary alloc] init]; // TransactionModel and TransactionModelService
            for (int counter = 0;counter < totalCount;counter++) {
               NSString*tempString = [self extractTextFromSqliteStmt:selectStmt AtIndex:counter];
                tempString = (tempString != nil) ?tempString:emptyString;
                RecordField *recField = [[RecordField alloc] initWithFieldName:nil value:tempString andDisplayValue:tempString];
                
                if (counter == 0) {
                    recField.name = kLocalId;
                    [recordDictionary setObject:recField forKey:kLocalId];
                }
                else if (counter == 1){
                    recField.name = kId;
                    [recordDictionary setObject:recField forKey:kId];
                }
                else{
                  
                    SFMSearchField *displayField = [displayFields objectAtIndex:counter - extraCount];
                    recField.name = displayField.fieldName;
                    [recordDictionary setObject:recField forKey:[displayField getDisplayField]];
                }
               
            }
            [dataArray addObject:recordDictionary];
        }
    }
    else{
        NSLog(@" SEARCH QUERY FAILED : %@",searchQuery);
    }
    synchronized_sqlite3_finalize(selectStmt);
    return dataArray;
}

// Move to DAO service - Convert to expression parser object and pass the data Convert filtercriteria into SFExpr and SFExprComponent
-(NSMutableArray *)getExpressionComponentForSeachExpressionId:(NSString *)expressionId
{
    NSMutableArray *expressionArray = [[NSMutableArray alloc] init];
    NSString * query = [NSString stringWithFormat:@"SELECT field_name , operator, operand   FROM SFM_Search_Filter_Criteria where expression_rule = '%@' ORDER BY sequence", expressionId];
    sqlite3_stmt * stmt ;
    NSString * lhsValue = @"";
    NSString * rhsValue = @"";
    NSString * operatorValue = @"";
    if(synchronized_sqlite3_prepare_v2([[SMXiPhone_Database sharedDataBase] databaseObject], [query UTF8String], -1, &stmt, nil) == SQLITE_OK){
        while (synchronized_sqlite3_step(stmt)  == SQLITE_ROW)
        {
            @autoreleasepool {
                NSMutableDictionary *componentDict = [[NSMutableDictionary alloc] init];
                char * lhs = (char *)synchronized_sqlite3_column_text(stmt, 0);
                if(lhs != nil)
                {
                    lhsValue = [NSString stringWithUTF8String:lhs];
                    [componentDict setValue:lhsValue forKey:kSFExpComponentLHS];
                }
                
                char * operator = (char *)synchronized_sqlite3_column_text(stmt, 1);
                if(operator != nil)
                {
                    operatorValue = [NSString stringWithUTF8String:operator];
                    [componentDict setValue:operatorValue forKey:kSFExpComponentOperator];
                }
                
                char * rhs = (char *)synchronized_sqlite3_column_text(stmt, 2);
                if(operator != nil)
                {
                    rhsValue = [NSString stringWithUTF8String:rhs];
                    [componentDict setValue:rhsValue forKey:kSFExpComponentRHS];
                    
                }
                Expression *expObj = [[Expression alloc]initWithDictionary:componentDict];
                [expressionArray addObject:expObj];
                
            }
        }
        synchronized_sqlite3_finalize(stmt);
    }
    else{
        NSLog(@"SQL Prepare Statement is failed in expressionComponentsForId: %@",expressionId);
    }
    return expressionArray;
}

// Move to DAO
- (void)fillDisplayValueForIds:(NSMutableDictionary *)idsDictionary
                 andObjectName:(NSString *)objectName {
    
    @autoreleasepool {
        NSString *nameField = [self getNameFieldFOrObjectName:objectName];
        NSArray *allIds = [idsDictionary allKeys];
        NSString *idsString = [SMXiPhone_Utility getConcatenatedStringFromArray:allIds withSingleQuotesAndBraces:YES];
        
        NSString *sqlQuery = [NSString stringWithFormat:@" SELECT Id, %@ from '%@' WHERE Id in %@",nameField,objectName,idsString];
        
        sqlite3_stmt *selectStmt = nil;
        
        char *cStringQuery = (char *)[sqlQuery UTF8String];
        
        int preparedSuccessfully =  synchronized_sqlite3_prepare_v2(  [[SMXiPhone_Database sharedDataBase] databaseObject], cStringQuery, strlen(cStringQuery), &selectStmt, NULL);
        if (preparedSuccessfully == SQLITE_OK) {
            
            while (synchronized_sqlite3_step(selectStmt) == SQLITE_ROW) {
                
                NSString *identifier = [self extractTextFromSqliteStmt:selectStmt AtIndex:0];
                NSString *value = [self extractTextFromSqliteStmt:selectStmt AtIndex:1];
                if (identifier != nil && value != nil) {
                    [idsDictionary setObject:value forKey:identifier];
                }
            }
        }
        synchronized_sqlite3_finalize(selectStmt);
    }
}
#pragma mark - PIcklists METHODS
// Move to dao
-(void)fillUpPicklistValues:(NSMutableDictionary *)objectInfoDict  pickListDict:(NSMutableDictionary *)pickListDict
{
    for (NSString * objectName in objectInfoDict) {
        NSArray * fieldsInfoArray = objectInfoDict[objectName];
        NSMutableDictionary * fieldInfoDict = [pickListDict objectForKey:objectName];
        if(fieldInfoDict == nil){
            fieldInfoDict = [[NSMutableDictionary alloc] init];
            [pickListDict setObject:fieldInfoDict forKey:objectName];
        }
        
        [self fillPicklistValuesForFields:fieldsInfoArray objectName:objectName picklistDict:fieldInfoDict];
    }
    
}
-(void)fillUpRecordTypeForObjects:(NSMutableDictionary *)objectInfoDict  recordTypeDict:(NSMutableDictionary *)recordTypeDict
{
    for (NSString * objectName in objectInfoDict) {
        
        NSMutableDictionary * eachDict = [recordTypeDict objectForKey:objectName];
        if(eachDict == nil){
            eachDict = [[NSMutableDictionary alloc] init];
            [recordTypeDict setObject:eachDict forKey:objectName];
        }
        
        [self FillRecordTypeNameForObject:objectName withRecordTypeDict:eachDict];
    }
}

-(void)fillPicklistValuesForFields:(NSArray *)fieldsArray  objectName:(NSString *)objectName  picklistDict:(NSMutableDictionary *)picklistsDict
{
    @synchronized([self class]){
        @autoreleasepool {
            int counter =0;
            NSMutableString * fieldsString = [[NSMutableString alloc] init];
            for (NSString * eachField in fieldsArray)
            {
                if(counter != 0)
                {
                    [fieldsString appendString:@" , "];
                }
                
                [fieldsString appendFormat:@"'%@'",eachField];
                
                counter++;
            }
            
            NSString * query = [NSString stringWithFormat:@"SELECT field_name,label,value FROM SFPickList WHERE object_name = '%@' and field_name in (%@)",objectName,fieldsString];
            
            sqlite3_stmt * stmt ;
            if(synchronized_sqlite3_prepare_v2([[SMXiPhone_Database sharedDataBase] databaseObject], [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
            {
                while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
                {
                    NSString   *fieldName  =  [self extractTextFromSqliteStmt:stmt AtIndex:0];
                    NSString   *fieldLabel  =  [self extractTextFromSqliteStmt:stmt AtIndex:1];
                    NSString   *fieldValue  =   [self extractTextFromSqliteStmt:stmt AtIndex:2];
                    
                    fieldName = (fieldName != nil)?fieldName:@"";
                    fieldLabel = (fieldLabel != nil)?fieldLabel:@"";
                    fieldValue = (fieldValue != nil)?fieldValue:@"";
                    
                    if (picklistsDict == nil)
                    {
                        picklistsDict = [[NSMutableDictionary alloc] initWithCapacity:0];
                    }
                    
                    NSMutableDictionary * eachdict = [picklistsDict objectForKey:fieldName];
                    if (eachdict == nil)
                    {
                        eachdict  = [[NSMutableDictionary alloc] init];
                        [picklistsDict setObject:eachdict forKey:fieldName];
                    }
                    [eachdict setObject:fieldLabel forKey:fieldValue];
                }
            }
            
            synchronized_sqlite3_finalize(stmt);
        }
    }
}


-(void)FillRecordTypeNameForObject:(NSString *)objectName withRecordTypeDict:(NSMutableDictionary *)recordTypeDict
{
    @synchronized([self class]){
        @autoreleasepool {
            NSString * query = [NSString stringWithFormat:@"SELECT recordtype_label, record_type_id  FROM  SFRecordType where object_api_name = '%@' " ,objectName];
            
            sqlite3_stmt * recordTypeId_statement ;
            if(synchronized_sqlite3_prepare_v2([[SMXiPhone_Database sharedDataBase] databaseObject], [query UTF8String], -1, &recordTypeId_statement, nil) == SQLITE_OK)
            {
                while(synchronized_sqlite3_step(recordTypeId_statement) == SQLITE_ROW)
                {
                    NSString *recordTypeName  =   [self extractTextFromSqliteStmt:recordTypeId_statement AtIndex:0];
                    recordTypeName = (recordTypeName != nil)?recordTypeName:@"";
                    
                    NSString *recordTypeId  =   [self extractTextFromSqliteStmt:recordTypeId_statement AtIndex:1];
                    recordTypeId = (recordTypeId != nil)?recordTypeId:@"";
                    
                    if(recordTypeDict == nil)
                    {
                        recordTypeDict = [[NSMutableDictionary alloc] init];
                    }
                    
                    [recordTypeDict setObject:recordTypeName forKey:recordTypeId];
                }
            }
            synchronized_sqlite3_finalize(recordTypeId_statement);
        }
    }
}
#pragma mark end -
-(NSString *)getDipalyValueForMultipicklist:(NSDictionary *)picklistDict forValue:(NSString *)fieldValue
{
    @synchronized([self class]){
        @autoreleasepool {
            if ([SMXiPhone_Utility isStringEmpty:fieldValue]) {
                return nil;
            }
            NSMutableString * displayValue = [[NSMutableString alloc] init];
            NSArray * valuearray = [fieldValue componentsSeparatedByString:@";"];
            int count_ = 0;
            for ( NSString * eachStr in valuearray)
            {
                NSString * label = [picklistDict objectForKey:eachStr];
                if(label != nil)
                {
                    if( count_ != 0 )
                    {
                        [displayValue appendString:@";"];
                    }
                    
                    [displayValue appendString:label];
                    count_++;
                }
                
            }
            return displayValue;
        }
        
    }
}
@end
