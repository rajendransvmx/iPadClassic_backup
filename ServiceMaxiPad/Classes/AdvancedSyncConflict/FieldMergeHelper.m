//
//  FieldMergeHelper.m
//  ServiceMaxiPad
//
//  Created by Shubha S on 22/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "FieldMergeHelper.h"
#import "TransactionObjectService.h"
#import "TransactionObjectModel.h"
#import "SFMRecordFieldData.h"
#import "SFObjectFieldService.h"
#import "DatabaseConstant.h"
#import "CommonServices.h"
#import "StringUtil.h"

@interface FieldMergeHelper ()

@property(nonatomic, strong)NSMutableDictionary* dataDictionaryAfterModification;
@property(nonatomic, strong)NSMutableDictionary* dataDictionaryBeforeModification;
//@property(nonatomic, copy) NSString *modifiedFieldsAsJsonString;
@property(nonatomic, copy) NSString *objectName;

@end
@implementation FieldMergeHelper



-(NSDictionary*)getDataDictionaryBeforeModificationFromTable:(NSString*)tableName withLocalId:(NSString*)localId fieldNames:(NSArray*)fieldNames
{
    self.objectName = tableName;
    TransactionObjectService *transactionObjectService = [[TransactionObjectService alloc]init];
    TransactionObjectModel *transactionObjectModel = [transactionObjectService getBeforeModificationDataForObject:tableName fields:fieldNames recordId:localId];
    return [transactionObjectModel getFieldValueDictionary];
}

- (NSString*)getJsonAfterComparingDictOne:(NSMutableDictionary*)dataBeforeModification withDataAfterModification:(NSMutableDictionary*)dataAfterModification andOldModificationDict:(NSMutableDictionary*)conflictDictionary
{
    self.dataDictionaryBeforeModification = dataBeforeModification;
    NSArray *fields = [self.dataDictionaryBeforeModification allKeys];
    
    // Iteration over all fields
    self.dataDictionaryAfterModification = [[NSMutableDictionary alloc]init];
    for (NSString *newKey in fields)
    {
        /* HS */
        /*
        SFMRecordFieldData *recordFieldData = [dataAfterModification objectForKey:newKey];
        NSString *oldValue = [self.dataDictionaryBeforeModification objectForKey:newKey];
        NSString *newValue = recordFieldData.internalValue;
        if(newValue == nil){
            continue;
        }
         */
        id value = [dataAfterModification objectForKey:newKey];
        NSString *oldValue = nil;
        NSString *newValue = nil;
        if ([value isKindOfClass:[SFMRecordFieldData class]])
        {
            SFMRecordFieldData *recordFieldData = value;
            oldValue = [self.dataDictionaryBeforeModification objectForKey:newKey];
            newValue = recordFieldData.internalValue;
 
        }
        else
        {
            
            oldValue = [self.dataDictionaryBeforeModification objectForKey:newKey];
            newValue = value;
         
        }
      
        if(newValue == nil){
            continue;
        }

        [self.dataDictionaryAfterModification setObject:newValue forKey:newKey];
        
        //If  split day events or isMultiday or timezone remove those fields
        
        if ([newKey isEqualToString:kIsMultiDayEvent] || [newKey isEqualToString:kSplitDayEvents] || [newKey isEqualToString:kTimeZone] || [newKey isEqualToString:kCompleteWhatId]) {
            [self.dataDictionaryBeforeModification removeObjectForKey:newKey];
            [self.dataDictionaryAfterModification removeObjectForKey:newKey];
            continue;
        }
        
        if ([newValue isKindOfClass:[NSString class]]) {
            if ([oldValue isEqualToString:newValue] )
            {
                if ([self isRemovableField:newKey
                      andOldDataDictionary:conflictDictionary])
                {
                    [self.dataDictionaryBeforeModification removeObjectForKey:newKey];
                    [self.dataDictionaryAfterModification removeObjectForKey:newKey];
                }
            }
        }
        
        SFObjectFieldService *sfObjectFieldService = [[SFObjectFieldService alloc]init];
        NSString *dataType = [sfObjectFieldService getDatatypeOfField:newKey andObject:self.objectName];
        
        if ([dataType isEqualToString:@"boolean"]) {
            newValue= newValue.boolValue==TRUE?@"true":@"false";
            [self compareBooleanOldValue:oldValue withNewValue:newValue forFieldName:newKey];
        }else if ([dataType isEqualToString:kSfDTDateTime]) {
            [self compareDateTimeTypeOldValue:oldValue withNewValue:newValue forFieldName:newKey];
        }else if ([dataType isEqualToString:kSfDTCurrency] || [dataType isEqualToString:kSfDTDouble] || [dataType isEqualToString:kSfDTPercent]||[dataType isEqualToString:kSfDTInteger])
        {
            [self compareDoubleOldValue:oldValue withNewValue:newValue forFieldName:newKey];
        }
    }
    
    //convert dictionary into json value
   // [self convertDictionaryIntoJsonValue];
    
    return [self getModifiedJsonFromDictionary];
}


- (NSString*)getModifiedJsonFromDictionary
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    NSString *modifiedFieldAsJsonString;
    
    if ((self.dataDictionaryBeforeModification != nil)
        && ([self.dataDictionaryBeforeModification count] > 1)
        && (self.dataDictionaryAfterModification != nil)
        && ([self.dataDictionaryAfterModification count] > 1)
        )
    {
        // If dictionary count is one means that we got only SF_ID - SalesForce Identifier. So we are skipping
        
        [dictionary setObject:self.dataDictionaryAfterModification forKey:@"AFTER_SAVE"];
        [dictionary setObject:self.dataDictionaryBeforeModification forKey:@"BEFORE_SAVE"];
        
        NSError *jsonError = nil;
        //convert object to data
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&jsonError];
        if (jsonData != nil)
        {
            modifiedFieldAsJsonString = [[NSString alloc] initWithData:jsonData
                                                                    encoding:NSUTF8StringEncoding];
        }
        else
        {
            SXLogDebug(@"field merging json creatn failed error :%@ ", jsonError);
        }
    }
    
    return modifiedFieldAsJsonString;

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

- (void)compareBooleanOldValue:(NSString*)oldValue withNewValue:(NSString*)newValue forFieldName:(NSString*)fieldName
{
    NSString *jsonBoolDataType = [self jsonStringValueForBooleanDataTypeByData:oldValue];
    NSString *jsonBoolDataTypeNew = [self jsonStringValueForBooleanDataTypeByData:newValue];
    
    if ([jsonBoolDataType isEqualToString:jsonBoolDataTypeNew])
    {
        // Luckily both value matching.. no change found, lets remove from change list items
        [self.dataDictionaryBeforeModification removeObjectForKey:fieldName];
        [self.dataDictionaryAfterModification removeObjectForKey:fieldName];
    }
    else
    {
        // Adding new JSON bool value like 'false/true' instead of old format '0, 1, Yes, No' to change list
        [self.dataDictionaryBeforeModification setObject:jsonBoolDataType forKey:fieldName];
        [self.dataDictionaryAfterModification setObject:jsonBoolDataTypeNew forKey:fieldName];
    }
}

/*
 
 Defect Fix : 011524
 
 In case of DateTime data type some certain time zone format should be treated as same before and after making modification. Example mentioned below.
 
 After Save :
 "CreatedDate":"2014-07-10T05:03:28" or "CreatedDate":"2014-07-10T05:06:08.000Z"
 
 Before Save :
 "CreatedDate":"2014-07-10T05:03:28.000+0000"     or "CreatedDate":"2014-07-10T05:06:08.000+0000"
 
 As per the example there is no change in the Date and Time part of the value only time zone has been formatted/changed. To overcome this do specail handling only for time zone part of data.
 
 */

- (void)compareDateTimeTypeOldValue:(NSString*)oldValue withNewValue:(NSString*)newValue forFieldName:(NSString*)fieldName
{

        NSArray *dateAndTimesBeforeModification = [oldValue componentsSeparatedByString:@"."];
        NSArray *dateAndTimesAfterModification  = [newValue componentsSeparatedByString:@"."];
        
        NSArray *dateAndTimeWithSecondsBeforeModification = [oldValue componentsSeparatedByString:@":"];
        NSArray *dateAndTimeWithSecondsAfterModification = [newValue componentsSeparatedByString:@":"];
        
        NSString *formattedOldValue;
        NSString *formattedNewValue;
        
        
        if (   (dateAndTimesBeforeModification != nil)
            && ([dateAndTimesBeforeModification count] > 0)
            && (dateAndTimesAfterModification != nil)
            && ([dateAndTimesAfterModification count] > 0)
            )
        {
            if ([dateAndTimesAfterModification count] >= 2 && [dateAndTimeWithSecondsAfterModification count] >= 2) {
                formattedNewValue = [NSString stringWithFormat:@"%@:%@:00.%@",[dateAndTimeWithSecondsAfterModification objectAtIndex:0],[dateAndTimeWithSecondsAfterModification objectAtIndex:1],[dateAndTimesAfterModification objectAtIndex:1]];
                [self.dataDictionaryAfterModification setObject:formattedNewValue forKey:fieldName];
            }
            if ([dateAndTimesBeforeModification count]>=2 && [dateAndTimeWithSecondsBeforeModification count] >= 2) {
                formattedOldValue = [NSString stringWithFormat:@"%@:%@:00.%@",[dateAndTimeWithSecondsBeforeModification objectAtIndex:0],[dateAndTimeWithSecondsBeforeModification objectAtIndex:1],[dateAndTimesBeforeModification objectAtIndex:1]];
                [self.dataDictionaryBeforeModification setObject:formattedOldValue forKey:fieldName];
            }

            
            /*
             
             Before save date and time format "CreatedDate":"2014-07-10T05:06:08.000Z"
             
             After Save date and time format  "CreatedDate":"2014-07-10T05:06:08.000+0000" consider as same
             
             */
            
            dateAndTimesBeforeModification = [formattedOldValue componentsSeparatedByString:@"."];
            dateAndTimesAfterModification  = [formattedNewValue componentsSeparatedByString:@"."];
            
            // Compare Date part from old and new values..
            if ([[dateAndTimesBeforeModification objectAtIndex:0] isEqualToString:[dateAndTimesAfterModification objectAtIndex:0]])
            {

                    // Remove entry from changed data list
                    [self.dataDictionaryBeforeModification removeObjectForKey:fieldName];
                    [self.dataDictionaryAfterModification removeObjectForKey:fieldName];
            }
        }
}


- (void)compareDoubleOldValue:(NSString*)oldValue
                 withNewValue:(NSString*)newValue
                 forFieldName:(NSString*)fieldName
{
 
    //020267
    oldValue = [oldValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    newValue = [newValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (![oldValue isEqualToString:newValue] && ([StringUtil isStringEmpty:oldValue] || [StringUtil isStringEmpty:newValue])) {
        if(newValue != nil){
            [self.dataDictionaryAfterModification setObject:newValue forKey:fieldName];
        }
        if(oldValue != nil){
            [self.dataDictionaryBeforeModification setObject:oldValue forKey:fieldName];
        }
    }
    else {
        
        double newValueNumber = [newValue doubleValue];
        double oldValueNumber = [oldValue doubleValue];
        
        
        if (newValueNumber == oldValueNumber)
        {
            // Luckily both value matching.. no change found, lets remove from change list items
            [self.dataDictionaryBeforeModification removeObjectForKey:fieldName];
            [self.dataDictionaryAfterModification removeObjectForKey:fieldName];
        }
        else
        {
            if(newValue != nil){
                [self.dataDictionaryAfterModification setObject:newValue forKey:fieldName];
            }
            if(oldValue != nil){
                [self.dataDictionaryBeforeModification setObject:oldValue forKey:fieldName];
            }
        }
    }
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

                    
@end
