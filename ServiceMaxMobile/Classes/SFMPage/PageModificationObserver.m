//
//  PageModificationObserver.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 6/6/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import "PageModificationObserver.h"
#import "AppDelegate.h"
#import "Globals.h"


@interface PageModificationObserver()
{
    
}

@property(nonatomic, assign)BOOL hasModified;

@property(nonatomic, retain)NSMutableDictionary *dataDictionaryBeforeModification;
@property(nonatomic, retain)NSMutableDictionary *dataDictionaryAfterModification;

@property(nonatomic, copy) NSString *recordLocalId;
@property(nonatomic, copy) NSString *tableName;
@property(nonatomic, copy) NSString *modifiedFieldsAsJsonString;


- (void)fetchDataBeforeModification:(BOOL)beforeModification;
- (NSString *)fetchExistingModifiedFieldsJsonFromTrailorTable;
- (void)fetchAndValidateExistingRecordData;
- (BOOL)updateModifiedFields;

@end

@implementation PageModificationObserver

@synthesize dataDictionaryBeforeModification;
@synthesize dataDictionaryAfterModification;
@synthesize modifiedFieldsAsJsonString;
@synthesize tableName;
@synthesize recordLocalId;
@synthesize hasModified;


- (id)initWithModifiedDataDictionary:(NSMutableDictionary *)dataDictionary
                            recordId:(NSString *)recordId
                  andObjectOrApiName:(NSString *)apiName
{
    if (self = [super init])
    {
        hasModified = NO;
        self.tableName = apiName;
        self.recordLocalId = recordId;
        modifiedFieldsAsJsonString = nil;
        self.dataDictionaryAfterModification = dataDictionary;
        
        [self fetchAndValidateExistingRecordData];
    }
    return self;
}

- (id)initWithModifiedEventStartDate:(NSString *)startDate
                             endDate:(NSString *)endDate
                            recordId:(NSString *)recordId
                             andSfId:(NSString *)salesForceId
{
    if (self = [super init])
    {
        hasModified = NO;
        self.tableName = @"Event";
        self.recordLocalId = recordId;
        modifiedFieldsAsJsonString = nil;

        if (salesForceId == nil)
        {
            salesForceId = @"";
        }
        
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        [dictionary setObject:startDate forKey:@"StartDateTime"];
        [dictionary setObject:endDate forKey:@"EndDateTime"];
        [dictionary setObject:startDate forKey:@"ActivityDateTime"];
        [dictionary setObject:salesForceId forKey:@"Id"];
        self.dataDictionaryAfterModification = dictionary;
        [dictionary release];
        
        [self fetchAndValidateExistingRecordData];
    }
    return self;
}


- (BOOL)isDataTypeBooleanByData:(NSString *)dataString
{
    NSArray *booleanSupportString = [NSArray arrayWithObjects:@"true", @"false", @"yes", @"no", nil];
    for (NSString *boolString in booleanSupportString)
    {
        if ([dataString caseInsensitiveCompare:boolString] == NSOrderedSame)
        {
            return YES;
        }
    }
    return NO;
}

- (NSString *)jsonStringValueForBooleanDataTypeByData:(NSString *)dataString
{
    NSArray *booleanSupportString = [NSArray arrayWithObjects:@"true", @"false", @"yes", @"no", @"1", @"0", nil];

    NSArray *booleanFalseSupportString = [NSArray arrayWithObjects: @"false",  @"no", @"0",  nil];
    
    for (NSString *boolString in booleanSupportString)
    {
        if ([dataString caseInsensitiveCompare:boolString] == NSOrderedSame)
        {
            dataString = [dataString lowercaseString];
            if ([booleanFalseSupportString containsObject:dataString])
            {
                return @"false";
            }
            else
            {
                return @"true";
            }
        }
    }
    return @"";
}

- (NSString *)dataTypeForFieldName:(NSString *)fieldName
{
    return [appDelegate.databaseInterface getFieldDataType:self.tableName
                                          filedName:fieldName];
}


- (void)fetchAndValidateExistingRecordData
{
    // For safe, validating SF_ID existing or not in modified data dictionary
    // If not found adding key and dummy value
    
    NSString  *sfID  =  [appDelegate.databaseInterface  checkforSalesForceIdForlocalId:self.tableName
                                                                              local_id:self.recordLocalId];
    
    NSLog(@" fetched  sfID :%@ -->  %@", sfID, [dataDictionaryAfterModification objectForKey:@"Id"]);
    
    if (   ([self.dataDictionaryAfterModification objectForKey:@"Id"] == nil)
        || ([[self.dataDictionaryAfterModification objectForKey:@"Id"] length] < 1))
    {
        if ((sfID == nil) || ([sfID length] < 2))
        {
            return;
        }
        
        [self.dataDictionaryAfterModification setObject:sfID
                                                 forKey:@"Id"];
    }
    
    NSLog(@" dataDictionaryAfterModification :%@ ", dataDictionaryAfterModification);
    
    if (dataDictionaryBeforeModification == nil)
    {
        [self fetchDataBeforeModification:YES];
    }
}


- (void)doDataComparison
{
    
    if (![appDelegate isFieldMergeEnabled])
    {
        // Woo Field Level merge is not anabled. Lets go back.
        NSLog(@"Skipping modified fields data - comparison since it feature not anabled");
        return;
    }
    
    if (dataDictionaryBeforeModification == nil)
    {
        NSLog(@"Skipping modified fields data - comparison since unavailable before modification data");
        
        return;
    }
    
    // Fetch data after modification from data base.
    // Expecting update record  data here.
    
    [self fetchDataBeforeModification:NO];

    NSString *existingModifiedFields = [self fetchExistingModifiedFieldsJsonFromTrailorTable];
    
    NSMutableDictionary *existingDataBeforeModificationDictionary = nil;
    
    if ((existingModifiedFields != nil) && ([existingModifiedFields length] > 1))
    {
        NSError *error = nil;

        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:[existingModifiedFields dataUsingEncoding:NSUTF8StringEncoding]
                                                                       options:NSJSONReadingMutableContainers
                                                                         error:&error];
        existingDataBeforeModificationDictionary = [jsonDictionary objectForKey:kAdvancedFieldMergeBeforeSave];
        
       // NSMutableDictionary *existingDataAfterModificationDictionary = [jsonDictionary objectForKey:kAdvancedFieldMergeAfterSave];
     
        NSArray *fields = [dataDictionaryBeforeModification allKeys];
        
        for (NSString *newKey in fields)
        {
            if ([existingDataBeforeModificationDictionary objectForKey:newKey] == nil)
            {
                NSString *value = [dataDictionaryBeforeModification objectForKey:newKey];
                
                if (value != nil)
                {
                    [existingDataBeforeModificationDictionary setObject:value
                                                                 forKey:newKey];

                }
            }
        }
    }
    
    if (existingDataBeforeModificationDictionary == nil)
    {
        existingDataBeforeModificationDictionary = [self dataDictionaryBeforeModification];
    }
    
    NSArray *fields = [existingDataBeforeModificationDictionary allKeys];
    
    for (NSString *fieldName in fields)
    {
        NSString *oldValue = [existingDataBeforeModificationDictionary objectForKey:fieldName];
        NSString *newValue = [dataDictionaryAfterModification objectForKey:fieldName];
 
        if ([oldValue isEqualToString:newValue])
        {
            if (![fieldName isEqualToString:@"Id"])
            {
                [existingDataBeforeModificationDictionary removeObjectForKey:fieldName];
                [dataDictionaryAfterModification removeObjectForKey:fieldName];
            }
        }
        else
        {
            /*
             
             "AFTER_SAVE" : 
             {
                "SPR14__Is_Exported__c" : "false",
                "SPR14__Locked_By_DC__c" : "true",
             }
             
             "BEFORE_SAVE" : 
             {
             "SPR14__Is_Exported__c" : "0",
             "SPR14__Locked_By_DC__c" : "1",
             }
             
             As mentioned above both set values (before save and after save ) boolean value treat as different.
             
             Server expecting the boolean value format like either "false" or "true" similar to AFTER_SAVE.
             BEFORE_SAVE section fetch value from data base and stored as in digit format.
             
             Soluion:
             
             If we found any change on
             
             */
            
            if ([self isDataTypeBooleanByData:newValue])
            {
                NSString *predefinedDataType = [self dataTypeForFieldName:fieldName];
                
                NSLog(@" predefinedDataType %@ : %@ ",fieldName, predefinedDataType);
                
                if ([predefinedDataType isEqualToString:[BOOLEAN lowercaseString]])
                {
                    NSString *jsonBoolDataType = [self jsonStringValueForBooleanDataTypeByData:oldValue];
                    
                    if ([jsonBoolDataType isEqualToString:newValue])
                    {
                        [existingDataBeforeModificationDictionary removeObjectForKey:fieldName];
                        [dataDictionaryAfterModification removeObjectForKey:fieldName];
                    }
                    else
                    {
                        [existingDataBeforeModificationDictionary setObject:jsonBoolDataType forKey:fieldName];
                    }
                }
            }
        }
    }
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    if (   (existingDataBeforeModificationDictionary != nil)
        && ([existingDataBeforeModificationDictionary count] > 1)
        && (dataDictionaryAfterModification != nil)
        && ([dataDictionaryAfterModification count] > 1)
        )
    {
        // If dictionary count is one means that we got only SF_ID - SalesForce Identifier. So we are skipping 
        
        [dictionary setObject:dataDictionaryAfterModification forKey:kAdvancedFieldMergeAfterSave];
        [dictionary setObject:existingDataBeforeModificationDictionary forKey:kAdvancedFieldMergeBeforeSave];
        
        NSError *jsonError = nil;
        //convert object to data
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&jsonError];
        if (jsonData != nil)
        {
            self.modifiedFieldsAsJsonString = [[NSString alloc] initWithData:jsonData
                                                                    encoding:NSUTF8StringEncoding];
        }
        else
        {
            NSLog(@"field merging json creatn failed error :%@ ", jsonError);
        }
    }
    
    NSLog(@"  name : %@  => id: %@  \n modifiedFieldsAsJsonString : %@", self.tableName, self.recordLocalId, modifiedFieldsAsJsonString);
    
    if (self.modifiedFieldsAsJsonString != nil)
    {
        self.hasModified = YES;
    }
    
    [dictionary release];
}

- (NSString *)jsonString
{
    return modifiedFieldsAsJsonString;
}


- (BOOL)hasDataModified
{
    return self.hasModified;
}

- (BOOL)updateModifiedFieldsData
{
    return [self updateModifiedFields];
}


- (void)dealloc
{
    [tableName release];
    [recordLocalId release];
    [modifiedFieldsAsJsonString release];
    [dataDictionaryAfterModification release];
    [dataDictionaryBeforeModification release];
    [super dealloc];
}


- (void)fetchDataBeforeModification:(BOOL)beforeModification
{
    NSMutableArray *fieldNames = [[self.dataDictionaryAfterModification allKeys] mutableCopy];
    
    NSMutableDictionary *dataDictionary = [appDelegate.databaseInterface queryDataFromObjectTable:fieldNames
                                                                                        tableName:self.tableName
                                                                                        record_id:self.recordLocalId
                                                                                        expression:nil];
        
    [fieldNames release];
    
    NSString *newSFId = [dataDictionaryAfterModification objectForKey:@"Id"];
    
    NSLog(@" SF_ID old :%@ => new :%@", [dataDictionary objectForKey:@"Id"], newSFId);
    
    if ((newSFId == nil) || ([newSFId isEqualToString:@""]))
    {
        newSFId = [dataDictionary objectForKey:@"Id"];
        if  (newSFId != nil)
        {
            [dataDictionaryAfterModification setObject:newSFId forKey:@"Id"];
        }
    }

    if (beforeModification)
    {
        // Got copy of data/record before user making modification
        
        self.dataDictionaryBeforeModification = dataDictionary;
    }
    else
    {
        // Got copy of data/record after user making modification
        
        if ((dataDictionary != nil) && ([dataDictionary count] > 1))
        {
            self.dataDictionaryAfterModification = dataDictionary;
        }
    }
}

- (NSString *)fetchExistingModifiedFieldsJsonFromTrailorTable
{
    NSString *storedModifiedFields = [appDelegate.databaseInterface fieldsModifiedDataFromTrailorTableByLocalId:self.recordLocalId];

    return storedModifiedFields;
}


- (BOOL)updateModifiedFields
{
    NSString * jsonString = [self modifiedFieldsAsJsonString];
    
    if (jsonString == nil)
    {
        jsonString = @"";
    }
    return [appDelegate.databaseInterface updateDataTrailerTableFieldsModifiedData:jsonString
                                                                         byLocalId:self.recordLocalId];
}

@end
