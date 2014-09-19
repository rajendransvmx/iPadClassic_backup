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
@property(nonatomic, assign)BOOL foundNonFieldMergeChanges;

@property(nonatomic, retain)NSMutableDictionary *dataDictionaryBeforeModification;
@property(nonatomic, retain)NSMutableDictionary *dataDictionaryAfterModification;

@property(nonatomic, copy) NSString *recordLocalId;
@property(nonatomic, copy) NSString *salesForceId;
@property(nonatomic, copy) NSString *tableName;
@property(nonatomic, copy) NSString *modifiedFieldsAsJsonString;


- (void)fetchDataBeforeModification:(BOOL)beforeModification;
- (NSString *)fetchExistingModifiedFieldsJsonFromTrailorTable;
- (void)fetchAndValidateExistingRecordData;
- (BOOL)updateModifiedFields;

- (BOOL)isRemovableField:(NSString *)fieldName andOldDataDictionary:(NSDictionary *)conflictDataDictionary;

@end

@implementation PageModificationObserver

@synthesize dataDictionaryBeforeModification;
@synthesize dataDictionaryAfterModification;
@synthesize modifiedFieldsAsJsonString;
@synthesize tableName;
@synthesize recordLocalId;
@synthesize salesForceId;
@synthesize hasModified;
@synthesize foundNonFieldMergeChanges;

- (id)initWithModifiedDataDictionary:(NSMutableDictionary *)dataDictionary
                            recordId:(NSString *)recordId
                  andObjectOrApiName:(NSString *)apiName
{
    if (self = [super init])
    {
        hasModified = NO;
        foundNonFieldMergeChanges = NO;
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
                             andSfId:(NSString *)sForceId
{
    if (self = [super init])
    {
        hasModified = NO;
        foundNonFieldMergeChanges = NO;
        self.tableName = @"Event";
        self.recordLocalId = recordId;
        modifiedFieldsAsJsonString = nil;

        if (sForceId == nil)
        {
            sForceId = @"";
        }
        
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        [dictionary setObject:startDate forKey:@"StartDateTime"];
        [dictionary setObject:endDate forKey:@"EndDateTime"];
        [dictionary setObject:startDate forKey:@"ActivityDateTime"];
        [dictionary setObject:sForceId forKey:@"Id"];
        self.salesForceId = sForceId;
        self.dataDictionaryAfterModification = dictionary;
        [dictionary release];
        
        [self fetchAndValidateExistingRecordData];
    }
    return self;
}


- (BOOL)isDataTypeBooleanByData:(NSString *)dataString
{
    NSArray *booleanSupportString = [NSArray arrayWithObjects:@"true", @"false", @"yes", @"no", @"1", @"0", nil];
    for (NSString *boolString in booleanSupportString)
    {
        if ([dataString caseInsensitiveCompare:boolString] == NSOrderedSame)
        {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isDataTypeDataTimeByFieldType:(NSString *)fieldType
{
    if ([fieldType caseInsensitiveCompare:@"DATETIME"] == NSOrderedSame)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)isTimeZonePresentsInData:(NSString *)dataString
{
    // Validating whether data string has  time zone string attached
    if ([dataString hasSuffix:@".000+0000"] || [dataString hasSuffix:@".000Z"])
    {
        return YES;
    }
    else
    {
        return NO;
    }
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
    
    self.salesForceId = sfID;
    
    NSLog(@" dataDictionaryAfterModification :%@ ", dataDictionaryAfterModification);
    
    if (dataDictionaryBeforeModification == nil)
    {
        [self fetchDataBeforeModification:YES];
    }
}

- (BOOL)isRemovableField:(NSString *)fieldName andOldDataDictionary:(NSDictionary *)conflictDataDictionary
{
    BOOL isRemovable = YES;
    
    if ([fieldName isEqualToString:@"Id"])
    {
        isRemovable = NO;
    }
    else
    {
        if ((conflictDataDictionary != nil) && ([conflictDataDictionary count] > 0))
        {
            if ([conflictDataDictionary objectForKey:fieldName] != nil)
            {
                isRemovable = NO;
            }
        }
    }
    
    return isRemovable;
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
        // It is new record whcih is not sync.
        if ((self.salesForceId == nil) && (self.recordLocalId != nil))
        {
            self.foundNonFieldMergeChanges = YES;
            NSLog(@"Eligible for updation but Not Advance Sync Conflict - since it is unsynced record ");
        }
        else
        {
            NSLog(@"Skipping modified fields data - comparison since unavailable before modification data");
        }
        
        return;
    }
    
    // Fetch data after modification from data base.
    // Expecting update record  data here.
    
    [self fetchDataBeforeModification:NO];

    BOOL hasConflictRecordFound = NO;

    // If there are earlier changes in trailor table fetch them also.. will use for merging
    NSString *existingModifiedFields = [self fetchExistingModifiedFieldsJsonFromTrailorTable];
    
    if (existingModifiedFields == nil || ([existingModifiedFields length] < 1))
    {
        hasConflictRecordFound = [self hasConflictRecordMarkedForOverriding];
        
        if (hasConflictRecordFound)
        {
            // Found conflict mark on existing records. Lets consider conflict record as previous change
            existingModifiedFields = [self fetchExistingModifiedFieldsJsonFromTrailorTempTable];
        }
    }
    
    NSMutableDictionary *existingDataBeforeModificationDictionary = nil;
    NSMutableDictionary *existingDataAfterModificationDictionary = nil;
    NSMutableDictionary *oldDataAfterModificationDictionary = nil;
    
    // Merge old and new modified json values
    if ((existingModifiedFields != nil) && ([existingModifiedFields length] > 1))
    {
        NSError *error = nil;

        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:[existingModifiedFields dataUsingEncoding:NSUTF8StringEncoding]
                                                                       options:NSJSONReadingMutableContainers
                                                                         error:&error];
        existingDataBeforeModificationDictionary = [jsonDictionary objectForKey:kAdvancedFieldMergeBeforeSave];
        existingDataAfterModificationDictionary  = [jsonDictionary objectForKey:kAdvancedFieldMergeAfterSave];
     
        if (hasConflictRecordFound)
        {
            // Conflict has been found, lets make copy of old modification
            oldDataAfterModificationDictionary = [existingDataAfterModificationDictionary copy];
        }
        
        NSArray *fields = [existingDataBeforeModificationDictionary allKeys];
        
        // Iteration over all fields
        for (NSString *newKey in fields)
        {
            if ([existingDataBeforeModificationDictionary objectForKey:newKey] != nil)
            {
                NSString *oldValue = [existingDataBeforeModificationDictionary objectForKey:newKey];
                
                if (oldValue != nil)
                {
                    [dataDictionaryBeforeModification setObject:oldValue
                                                         forKey:newKey];
                }
            }
            
            if ([dataDictionaryAfterModification objectForKey:newKey] == nil)
            {
                NSString *oldValue = [existingDataAfterModificationDictionary objectForKey:newKey];
                
                if (oldValue != nil)
                {
                    [dataDictionaryAfterModification setObject:oldValue
                                                        forKey:newKey];
                }
            }
        }
        
        fields = nil;
        
        existingDataBeforeModificationDictionary = dataDictionaryBeforeModification;
    }
    
    if (existingDataBeforeModificationDictionary == nil)
    {
        existingDataBeforeModificationDictionary = [self dataDictionaryBeforeModification];
    }
    
    // Fields level comparison between record before save and after save
    
    NSArray *fields = [existingDataBeforeModificationDictionary allKeys];
    
    for (NSString *fieldName in fields)
    {
        NSString *oldValue = [existingDataBeforeModificationDictionary objectForKey:fieldName];
        NSString *newValue = [dataDictionaryAfterModification objectForKey:fieldName];
 
        if ([oldValue isEqualToString:newValue])
        {
            // See both old and new record values are same.
            if ([self isRemovableField:fieldName
                  andOldDataDictionary:oldDataAfterModificationDictionary])
            {
                [existingDataBeforeModificationDictionary removeObjectForKey:fieldName];
                [dataDictionaryAfterModification removeObjectForKey:fieldName];
            }
        }
        else
        {
            /*
             
             Special case handling for Data type Boolean and DateTime
             
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
             
             */
            
            if ([self isDataTypeBooleanByData:newValue])
            {
                NSString *predefinedDataType = [self dataTypeForFieldName:fieldName];
                
                NSLog(@" predefinedDataType %@ : %@ ",fieldName, predefinedDataType);
                
                if ([predefinedDataType isEqualToString:[BOOLEAN lowercaseString]])
                {
                    NSString *jsonBoolDataType = [self jsonStringValueForBooleanDataTypeByData:oldValue];
                    NSString *jsonBoolDataTypeNew = [self jsonStringValueForBooleanDataTypeByData:newValue];
                    
                    if ([jsonBoolDataType isEqualToString:jsonBoolDataTypeNew])
                    {
                        // Luckily both value matching.. no change found, lets remove from change list items
                        [existingDataBeforeModificationDictionary removeObjectForKey:fieldName];
                        [dataDictionaryAfterModification removeObjectForKey:fieldName];
                    }
                    else
                    {
                        // Adding new JSON bool value like 'false/true' instead of old format '0, 1, Yes, No' to change list
                        [existingDataBeforeModificationDictionary setObject:jsonBoolDataType forKey:fieldName];
                        [dataDictionaryAfterModification setObject:jsonBoolDataTypeNew forKey:fieldName];
                    }
                }
            }
            else
            {
                /*
                 
                 Defect Fix : 011524
                 
                 In case of DateTime data type some certain time zone format should be treated as same before and after making modification. Example mentioned below.
                 
                 After Save :
                 "CreatedDate":"2014-07-10T05:03:28" or "CreatedDate":"2014-07-10T05:06:08.000Z"
                 
                 Before Save :
                 "CreatedDate":"2014-07-10T05:03:28.000+0000"     or "CreatedDate":"2014-07-10T05:06:08.000+0000"
                 
                 As per the example there is no change in the Date and Time part of the value only time zone has been formatted/changed. To overcome this do specail handling only for time zone part of data.
                 
                 */
                
                
                // Times Zone String presents on old values
                if ([self isTimeZonePresentsInData:oldValue])
                {
                    NSString *predefinedDataTypeDateTime = [self dataTypeForFieldName:fieldName];
                    
                     NSLog(@" predefinedDataType %@ : %@ ",fieldName, predefinedDataTypeDateTime);
                    
                    if ([self isDataTypeDataTimeByFieldType:predefinedDataTypeDateTime])
                    {
                        NSArray *dataAndTimesBeforeModification = [oldValue componentsSeparatedByString:@"."];
                        NSArray *dataAndTimesAfterModification  = [newValue componentsSeparatedByString:@"."];
                        
                        if (   (dataAndTimesBeforeModification != nil)
                            && ([dataAndTimesBeforeModification count] > 0)
                            && (dataAndTimesAfterModification != nil)
                            && ([dataAndTimesAfterModification count] > 0)
                            )
                        {
                            /*
                             
                             Before save date and time format "CreatedDate":"2014-07-10T05:06:08.000Z"
                             
                             After Save date and time format  "CreatedDate":"2014-07-10T05:06:08.000+0000" consider as same
                             
                             */
                         
                            // Compare Date part from old and new values..
                            if ([[dataAndTimesBeforeModification objectAtIndex:0] isEqualToString:[dataAndTimesAfterModification objectAtIndex:0]])
                            {
                                // Expecting new value does not hold timezone component
                                if ([dataAndTimesAfterModification count] < 2)
                                {
                                    // Remove entry from changed data list
                                    [existingDataBeforeModificationDictionary removeObjectForKey:fieldName];
                                    [dataDictionaryAfterModification removeObjectForKey:fieldName];
                                }
                                else
                                {
                                    /*
                                     
                                     Before save date and time format "CreatedDate":"2014-07-10T05:06:08.000Z"
                                     
                                     After Save date and time format  "CreatedDate":"2014-07-10T05:06:08.000+0000" consider as same
                                     
                                     */
                                    // Validating above sequense of appearance in time zone component
                                    if (([[dataAndTimesAfterModification objectAtIndex:1] isEqualToString:@"000Z"])
                                        && ([[dataAndTimesBeforeModification objectAtIndex:1] isEqualToString:@"000+0000"]))
                                    {
                                        // Validation passed. Remove entry from changed data list
                                        [existingDataBeforeModificationDictionary removeObjectForKey:fieldName];
                                        [dataDictionaryAfterModification removeObjectForKey:fieldName];
                                    }
                                        
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    if (oldDataAfterModificationDictionary != nil)
    {
        [oldDataAfterModificationDictionary release];
        oldDataAfterModificationDictionary = nil;
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

- (BOOL)hasFoundNonAdvancedFieldMergeChanges
{
    return self.foundNonFieldMergeChanges;
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


- (BOOL)hasConflictRecordMarkedForOverriding
{
   
    return [appDelegate.calDataBase hasRecordMarkedForOverrideById:self.salesForceId                                                                          andObjectName:self.tableName];
}


- (NSString *)fetchExistingModifiedFieldsJsonFromTrailorTable
{
    NSString *storedModifiedFields = [appDelegate.databaseInterface fieldsModifiedDataFromTrailorTableByLocalId:self.recordLocalId];

    return storedModifiedFields;
}

- (NSString *)fetchExistingModifiedFieldsJsonFromTrailorTempTable
{
    NSString *storedModifiedFields = [appDelegate.databaseInterface fieldsModifiedDataFromTrailorTempTableById:self.salesForceId];
    
    return storedModifiedFields;
}


- (BOOL)updateModifiedFields
{
    NSString * jsonString = [self modifiedFieldsAsJsonString];
    
    if (jsonString == nil)
    {
        jsonString = @"";
    }
    
    BOOL hasConflictRecordFound = [self hasConflictRecordMarkedForOverriding];
    
    if (hasConflictRecordFound)
    {
        [appDelegate.databaseInterface  updateDataTrailerTempTableFieldsModifiedData:jsonString
                                                                           byLocalId:self.recordLocalId];
    }
    return [appDelegate.databaseInterface updateDataTrailerTableFieldsModifiedData:jsonString
                                                                         byLocalId:self.recordLocalId];
}

@end
