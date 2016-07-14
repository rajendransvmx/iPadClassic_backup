//
//  SFMPageManager.m
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 19/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFMPageManager.h"
#import "SFExpressionParser.h"
#import "StringUtil.h"
#import "SFExpressionComponentModel.h"
#import "SFMPageHelper.h"
#import "PlistManager.h"
#import "SFMProcess.h"
#import "SFObjectFieldModel.h"
#import "SFPicklistModel.h"
#import "SFRecordTypeModel.h"
#import "SFMRecordFieldData.h"
#import "SFProcessComponentModel.h"
#import "SFMDetailFieldData.h"
#import "SFMPage.h"
#import "DateUtil.h"
#import "SMErrorConstants.h"
#import "TagManager.h"
#import "TagConstant.h"
#import "Utility.h"
#import "StringUtil.h"
#import "NSDate+SMXDaysCount.h"
#import "DataTypeUtility.h"

#import "SVMXSystemConstant.h"
#import "SFMPageLookUpHelper.h"
#import "SFMLookUp.h"


typedef enum PageManagerErrorType : NSUInteger
{
    PageManagerErrorTypeNone = 1,
    PageManagerErrorTypeNoPageLayout = 2,
    PageManagerErrorTypeNoProcess = 3,
    PageManagerErrorTypeNotMatchingEntryCriteria = 4,
    PageManagerErrorTypeNotMatchingEntryCriteriaCustom = 5
}
PageManagerErrorType;

@interface SFMPageManager ()

@property(nonatomic, strong) NSString *nameFieldValue;

@end


@implementation SFMPageManager


- (id)initWithObjectName:(NSString *)objectName
                recordId:(NSString *)recordLocalId
             processSFId:(NSString *)processId
{
    self = [super init];
    
    if (self) {
        self.objectName = objectName;
        self.processId = processId;
        self.recordId = recordLocalId;
    }
    return self;
}


- (BOOL)isEntryCriteraMatchingForProcess:(NSString *)processId objectName:(NSString *)objectName recordId:(NSString *)sfmId error:(NSError **)error
{
    if(objectName == nil){
        objectName = self.objectName;
    }
    
    NSString *recordId;
    if(sfmId == nil)
    {
        recordId = self.recordId;
        
    }else
    {
        recordId = sfmId;
    }
    
    NSString *localId = [self getLocalIdForSFID:recordId objectName:objectName];
    if (![StringUtil isStringEmpty:localId]) {
        recordId = localId;
    }
    
    BOOL isEntryCriteraMatching = NO;
    if (![StringUtil isStringEmpty:processId]) {
        NSString *expId = [SFMPageHelper expressionIdForProcess:processId];
        if (![StringUtil isStringEmpty:expId]) {
            SFExpressionParser *parser = [[SFExpressionParser alloc]initWithExpressionId:expId objectName:objectName];
            isEntryCriteraMatching = [parser isEntryCriteriaMatchingForRecordId:recordId];
            if (!isEntryCriteraMatching) {
                [self fillError:error
       withPageManagerErrorType:PageManagerErrorTypeNotMatchingEntryCriteria
                        message:[parser errorMessage]];
            }
        }
        else{
            isEntryCriteraMatching = YES;
        }
    }
    return isEntryCriteraMatching;
}

- (void)mapProcessComponentIdToLayoutId:(SFMProcess *)process {
    
    NSArray *processComponents = [process.component allValues];
    NSMutableDictionary *mapDictonary = [[NSMutableDictionary alloc] init];
    for (SFProcessComponentModel *component in processComponents) {
        if (component.sfId != nil && component.layoutId != nil && ![component.layoutId isEqualToString:@""]) {
            [mapDictonary setObject:component.sfId forKey:component.layoutId];
        }
    }
    NSArray *detailsLayout = process.pageLayout.detailLayouts;
    for (int counter = 0; counter < [detailsLayout count]; counter++) {
        SFMDetailLayout *layout = [detailsLayout objectAtIndex:counter];
        NSString *layoutId = layout.dtlLayoutId;
        if (layoutId != nil) {
            layout.processComponentId = [mapDictonary objectForKey:layoutId];
        }
    }
}

- (SFMPageLayout *)pageLayoutInfoForProcess:(SFMProcess *)process
{
    NSDictionary *pageLayoutDict = nil;
    SFMPageLayout *pageLayout = nil;
    
    if (process.processInfo.processInfo != nil) {
        pageLayoutDict = [SFMPageHelper serializePageLayoutData:process.processInfo.processInfo];
    }
    else {
        pageLayoutDict = [SFMPageHelper getPageLayoutForProcess:process.processInfo.sfID];
    }
    
    if (pageLayoutDict != nil && [pageLayoutDict isKindOfClass:[NSDictionary class]]) {
        
        pageLayout = [[SFMPageLayout alloc] init];
        
        /*Header data retrieving*/
        NSDictionary *headerData = [pageLayoutDict objectForKey:kSVMXPageHeader];
        if (headerData != nil) {
            SFMHeaderLayout *headerLayout = [[SFMHeaderLayout alloc] initWithDictionaty:headerData];
            [self fillFieldLabelsForHeaderLayout:headerLayout];
            pageLayout.headerLayout = headerLayout;
        }
        
        /*Detail data retrieving*/
        NSArray *details = [pageLayoutDict objectForKey:kSVMXPageDetails];
        
        if (details != nil && [details count] > 0) {
            NSArray *sfDetails =  [self getDetailsFromPageArray:details];
            pageLayout.detailLayouts = sfDetails;
        }
        process.pageLayout = pageLayout;
        
        //Mapping: Process Component Id to layout id
        [self mapProcessComponentIdToLayoutId:process];
    }
    return pageLayout;
}

-(void)fillUpPrecisionInfoForPage:(SFMProcess *)process{
    
    SFMHeaderLayout * headerLayout = process.pageLayout.headerLayout;
    NSArray *detailRecords = process.pageLayout.detailLayouts;
    
    [self fillPrecisionInfoForHeaderLayout:headerLayout];
    [self fillPrecisionInfoForDetailLayouts:detailRecords];
}

-(void)fillPrecisionInfoForHeaderLayout:(SFMHeaderLayout *)headerLayout{
    
    DataTypeUtility *fieldUtil = [[DataTypeUtility alloc] init];
    
    NSArray * headerSections = headerLayout.sections;
    
    for (SFMHeaderSection * eachSection in headerSections) {
        for(SFMPageField * pageField in  eachSection.sectionFields){
            if([pageField.dataType isEqualToString:kSfDTCurrency]  //Except integer for other numberfields should consider.
               || [pageField.dataType isEqualToString:kSfDTDouble]
               || [pageField.dataType isEqualToString:kSfDTPercent])
            {
            SFObjectFieldModel * objectFieldModel =  [fieldUtil getField:pageField.fieldName objectName:headerLayout.objectName];
            pageField.precision = [NSNumber numberWithDouble:objectFieldModel.precision];
            pageField.scale = [NSNumber numberWithDouble:objectFieldModel.scale];
            }
        }
    }
    
    
}

-(void)fillPrecisionInfoForDetailLayouts:(NSArray *)detailLayouts{
    
    DataTypeUtility *fieldUtil = [[DataTypeUtility alloc] init];
    for (SFMDetailLayout * detailLayout in detailLayouts) {
        
        for (SFMPageField * pageField in detailLayout.detailSectionFields) {
            if([pageField.dataType isEqualToString:kSfDTCurrency]  //Except integer for other numberfields should consider.
               || [pageField.dataType isEqualToString:kSfDTDouble]
               || [pageField.dataType isEqualToString:kSfDTPercent])
            {
            SFObjectFieldModel * objectFieldModel =  [fieldUtil getField:pageField.fieldName objectName:detailLayout.objectName];
            pageField.precision = [NSNumber numberWithDouble:objectFieldModel.precision];
            pageField.scale = [NSNumber numberWithDouble:objectFieldModel.scale];
            }
        }
    }
}


- (NSArray *)getDetailsFromPageArray:(NSArray *)details
{
    NSMutableArray *sfDetailsArray = [[NSMutableArray alloc]init];
    for (NSDictionary * pageDictionary in details) {
        if (pageDictionary != nil && [pageDictionary count] > 0) {
            SFMDetailLayout *detailLayout = [[SFMDetailLayout alloc] initWithDictionary:pageDictionary];
            if (detailLayout != nil) {
                [self fillFieldLabelsForDetailLayout:detailLayout];
                [sfDetailsArray addObject:detailLayout];
            }
        }
    }
    return sfDetailsArray;
}

- (void)fillFieldLabelsForHeaderLayout:(SFMHeaderLayout *)headerLayout
{
    NSDictionary *fieldLabelDict = [SFMPageHelper getObjectFieldInfoForObjectName:headerLayout.objectName];
    
    NSArray *sections = headerLayout.sections;
    
    @autoreleasepool {
        for (SFMHeaderSection *eachSection in sections) {
            if (eachSection != nil) {
                NSArray * sectionFields = eachSection.sectionFields;
                [self updateFieldLabels:sectionFields labelDict:fieldLabelDict];
            }
        }
    }
}

- (void)fillFieldLabelsForDetailLayout:(SFMDetailLayout *)detailLayout
{
    NSMutableDictionary *fieldsLabelDictionary = [[NSMutableDictionary alloc] init];
    NSDictionary *labelDictionary = [fieldsLabelDictionary objectForKey:detailLayout.objectName];
    if (labelDictionary == nil) {
        NSDictionary *tempDictionary = [SFMPageHelper getObjectFieldInfoForObjectName:detailLayout.objectName];
        if (tempDictionary != nil) {
            [fieldsLabelDictionary setObject:tempDictionary forKey:detailLayout.objectName];
            labelDictionary = tempDictionary;
        }
    }
    if ([detailLayout.detailSectionFields count] > 0) {
        [self updateFieldLabels:detailLayout.detailSectionFields labelDict:labelDictionary];
    }
}

- (void)updateFieldLabels:(NSArray *)sectionFields labelDict:(NSDictionary *)labelDictionary
{
    for (SFMPageField *aField in sectionFields) {
        SFObjectFieldModel * fieldData = [labelDictionary objectForKey:aField.fieldName];
        if (fieldData != nil) {
            aField.label = fieldData.label;
            aField.isDependentPicklist = fieldData.dependentPicklist;
            aField.controlerField = fieldData.controlerField;
        }
    }
}

- (NSMutableDictionary *)getHeaderRecordForSFMPage:(SFMPage *)sfmPage
{
    NSArray *headerFields = [sfmPage getHeaderLayoutFields];
    
    //TO DO
    /*For work order and event object need to add harcoded fields in the fields array*/
    
    NSMutableDictionary *fieldDataTypeMap = [self getFieldDataTypeMap:headerFields];
    
    [self fillPickPickListAndRecordTypeInfo:fieldDataTypeMap andObjectName:sfmPage.objectName];
    
    NSArray *fields = [self getAllHeaderField:headerFields];
    
    NSMutableDictionary * dataDict = [SFMPageHelper getDataForObject:sfmPage.objectName fields:fields
                                                            recordId:sfmPage.recordId];
    
    self.nameFieldValue = [dataDict objectForKey:[SFMPageHelper getNameFieldForObject:self.objectName]];
    
    NSMutableDictionary * headerFieldValeDict = [self fillDataDictForHeaderOrDetail:dataDict fields:headerFields];
    
    NSMutableArray *picklists = [fieldDataTypeMap objectForKey:kSfDTPicklist];
    NSMutableArray *multiPicklists = [fieldDataTypeMap objectForKey:kSfDTMultiPicklist];
    
    [self updatePicklistDisplayValues:headerFieldValeDict picklistFields:picklists multiPicklistFields:multiPicklists];
    [self updateRecordTypeDisplayValue:headerFieldValeDict];
    
    [self resetPicklistAndRecordTypeData];
    
    return headerFieldValeDict;
}

- (NSArray *)getAllHeaderField:(NSArray *)fields
{
    NSMutableArray *headerfield = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (SFMPageField *field in fields) {
        if (field != nil) {
            [headerfield addObject:field.fieldName];
        }
    }
    return headerfield;
}

- (NSMutableDictionary *)getFieldDataTypeMap:(NSArray *)fields
{
    NSMutableDictionary *mappingDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    for(SFMPageField *eachField in fields) {
        if ([eachField.dataType isEqualToString:kSfDTPicklist]) {
            NSMutableArray * picklistFields = [mappingDict objectForKey:kSfDTPicklist];
            if (picklistFields == nil) {
                NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:0];
                [array addObject:eachField.fieldName];
                [mappingDict setObject:array forKey:kSfDTPicklist];
            }
            else {
                [picklistFields addObject:eachField.fieldName];
            }
        }
        else if ([eachField.dataType isEqualToString:kSfDTMultiPicklist]) {
            NSMutableArray * multiPicklistFields = [mappingDict objectForKey:kSfDTMultiPicklist];
            if (multiPicklistFields == nil) {
                NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:0];
                [array addObject:eachField.fieldName];
                [mappingDict setObject:array forKey:kSfDTMultiPicklist];
            }
            else {
                [multiPicklistFields addObject:eachField.fieldName];
            }
        }
        else if ([eachField.dataType isEqualToString:kSfDTReference]  && [eachField.fieldName isEqualToString:kSfDTRecordTypeId]) {
            NSMutableArray * recordTypeFields = [mappingDict objectForKey:kSfDTRecordTypeId];
            if (recordTypeFields == nil) {
                NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:0];
                [array addObject:eachField.fieldName];
                [mappingDict setObject:array forKey:kSfDTRecordTypeId];
            }
            else {
                [recordTypeFields addObject:eachField.fieldName];
            }
        }
    }
    return mappingDict;
}

- (void)fillPickPickListAndRecordTypeInfo:(NSDictionary *)dataDictionary andObjectName:(NSString *)objectName
{
    NSMutableArray *picklistFields  = [dataDictionary objectForKey:kSfDTPicklist];
    NSMutableArray *multiPicklistFields = [dataDictionary objectForKey:kSfDTMultiPicklist];
    NSMutableArray *recordTypeFields = [dataDictionary objectForKey:kSfDTRecordTypeId];
    
    NSMutableArray *finalPicklist = nil;
    
    if ([picklistFields count] > 0) {
        finalPicklist = [[NSMutableArray alloc] initWithCapacity:0];
        [finalPicklist addObjectsFromArray:picklistFields];
    }
    if ([multiPicklistFields count] > 0) {
        if (finalPicklist == nil)
            finalPicklist = [[NSMutableArray alloc] initWithCapacity:0];
        [finalPicklist addObjectsFromArray:multiPicklistFields];
    }
    if ([finalPicklist count] > 0) {
        [self updatePicklistDataFor:objectName fields:finalPicklist];
    }
    if ([recordTypeFields count] > 0) {
        [self updateRecordTypeDataFor:objectName fields:recordTypeFields];
    }
    
}

- (void)updatePicklistDataFor:(NSString *)objectName fields:(NSMutableArray *)pickListFileds
{
    NSArray * picklistArray = [SFMPageHelper getPicklistValuesForObject:objectName pickListFields:pickListFileds];
    
    if ([picklistArray count] > 0) {
        if (self.pickListData == nil) {
            self.pickListData = [[NSMutableDictionary alloc] initWithCapacity:0];
        }
        for (SFPicklistModel * model in picklistArray) {
            if (model != nil) {
                NSMutableDictionary *picklistDict = [self.pickListData objectForKey:model.fieldName];
                if (picklistDict == nil) {
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:0];
                    [dict setObject:model forKey:model.value];
                    [self.pickListData setObject:dict forKey:model.fieldName];
                }
                else {
                    [picklistDict setObject:model forKey:model.value];
                }
            }
        }
    }
}

- (void)updateRecordTypeDataFor:(NSString *)objectName fields:(NSMutableArray *)recordTypeFields
{
    NSArray * recordTypeArray = [SFMPageHelper getRecordTypeValuesForObject:objectName];
    
    if ([recordTypeArray count] > 0) {
        if (self.recordTypeData == nil) {
            self.recordTypeData = [[NSMutableDictionary alloc] initWithCapacity:0];
        }
        for (SFRecordTypeModel * model in recordTypeArray) {
            if (model != nil) {
                if (![self.recordTypeData objectForKey:model.recordTypeId]) {
                    [self.recordTypeData setObject:model forKey:model.recordTypeId];
                }
            }
        }
    }
}

 // defect- 23783

- (NSDictionary*)getDefaultColumnNameForField:(SFMPageField*)aPageField withFieldSfId:(NSString*)sfId{
    NSDictionary *dictionary = nil;
    SFMPageLookUpHelper *lookUpHelper   = [[SFMPageLookUpHelper alloc] init];
    SFMLookUp *lookUpObject   = [[SFMLookUp alloc] init];
    
    lookUpObject.lookUpId   = aPageField.namedSearch;
    lookUpObject.objectName = aPageField.relatedObjectName;
    
    [lookUpHelper fillLookUpMetaDataLookUp:lookUpObject]; // get the default column Name.
    
    if (![StringUtil isStringEmpty:lookUpObject.defaultColoumnName]) {
        aPageField.defaultColumnName = lookUpObject.defaultColoumnName;
        
        //Now get the value or sfid for this.
        dictionary = [lookUpHelper getDefaultColumnNameDataForLookup:lookUpObject withSfId:sfId ];
    }
    
    return dictionary;
}

- (NSMutableDictionary *)fillDataDictForHeaderOrDetail:(NSDictionary *)dataDict fields:(NSArray *)fields
{
    NSMutableDictionary *fieldNameAndInternalValue = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *fieldNameAndObjectApiName = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *fieldValueData = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    @autoreleasepool {
        for (SFMPageField *aPageField in fields) {
            
            NSString *internalValue = nil;
            
            if ([[dataDict objectForKey:aPageField.fieldName] isKindOfClass:[NSNumber class]]) {
                internalValue = [[dataDict objectForKey:aPageField.fieldName] stringValue];
            }
            else if([[dataDict objectForKey:aPageField.fieldName] isKindOfClass:[NSString class]])
            {
                internalValue = [dataDict objectForKey:aPageField.fieldName];
            }
            NSString *displayValue = internalValue;
            
            // defect- 23783

            NSString *keyField = aPageField.fieldName;
            
            if ([aPageField.dataType isEqualToString:kSfDTReference])
            {
                
                if (aPageField.relatedObjectName != nil)
                {
                    //    Below logic is used to get the default column name and value of the lookup fields.
                    
                    NSDictionary *defaultColumnDictionary;
                    if (internalValue.length) {
                        defaultColumnDictionary = [self getDefaultColumnNameForField:aPageField withFieldSfId:internalValue];
                    }
                    
                    if (defaultColumnDictionary.count > 0) {
                        keyField = aPageField.defaultColumnName;
                        
                        // 033878 - commented below line
                        //displayValue = [defaultColumnDictionary objectForKey:aPageField.defaultColumnName];
                        
                        [fieldNameAndObjectApiName setObject:aPageField.relatedObjectName forKey:aPageField.fieldName];
                        [fieldNameAndInternalValue setObject:displayValue?displayValue:kEmptyString forKey:aPageField.fieldName];
                    }
                    else
                    {
                        [fieldNameAndObjectApiName setObject:aPageField.relatedObjectName forKey:aPageField.fieldName];
                        [fieldNameAndInternalValue setObject:internalValue?internalValue:kEmptyString forKey:aPageField.fieldName];
                    }
                }
                else
                {
                    if (![StringUtil isStringEmpty:internalValue]) {
                        
                        [fieldNameAndInternalValue setObject:internalValue?internalValue:kEmptyString forKey:aPageField.fieldName];
                        displayValue = [PlistManager getLoggedInUserName]; // defect- 23783

                        
                        if (aPageField.relatedObjectName != nil) {
                            [fieldNameAndObjectApiName setObject:aPageField.relatedObjectName forKey:aPageField.fieldName];
                        }
                    }
                }
            }
            
            
            
            else if ([aPageField.dataType isEqualToString:kSfDTDateTime]) {
                if (![StringUtil isStringEmpty:internalValue]) {
                    
                    //BSP-1-Apr-2015. Changes to account for the All Day Event.
                    NSString *dateTime =   [self checkAllDayAndReturnDateTime:aPageField andInternalValue:internalValue];
                    
                    if (dateTime != nil) {
                        displayValue = dateTime;
                    }
                }
            }
            else if ([aPageField.dataType isEqualToString:kSfDTDate]) {
                if (![StringUtil isStringEmpty:internalValue]) {
                    NSString *dateString = [self getUserReadableDate:internalValue];
                    if (dateString != nil) {
                        displayValue = dateString;
                    }
                }
            }
            else if ([aPageField.dataType isEqualToString:kSfDTBoolean]) {
                displayValue = [self getBoolValueForInternalValue:internalValue];
            }
            
            SFMRecordFieldData *fieldData = [[SFMRecordFieldData alloc] initWithFieldName:aPageField.fieldName value:internalValue andDisplayValue:displayValue];
            [fieldValueData setObject:fieldData forKey:aPageField.fieldName];
        }
        NSString * sfId = [dataDict objectForKey:kId];
        if (![StringUtil isStringEmpty:sfId]) {
            SFMRecordFieldData *fieldData = [[SFMRecordFieldData alloc] initWithFieldName:kId value:sfId andDisplayValue:sfId];
            [fieldValueData setObject:fieldData forKey:kId];
            
        }
        NSString * recordId = [dataDict objectForKey:kLocalId];
        if (![StringUtil isStringEmpty:recordId]) {
            SFMRecordFieldData *fieldData = [[SFMRecordFieldData alloc] initWithFieldName:kLocalId value:recordId andDisplayValue:recordId];
            [fieldValueData setObject:fieldData forKey:kLocalId];
            
        }
        if ([fieldNameAndInternalValue count] > 0) {
            
            [self updateReferenceFieldDisplayValues:fieldNameAndInternalValue andFieldObjectNames:fieldNameAndObjectApiName];
            for (NSString *fieldName in fieldNameAndObjectApiName) {
                SFMRecordFieldData *fieldData = [fieldValueData objectForKey:fieldName];
                NSString *displayValue = [fieldNameAndInternalValue objectForKey:fieldName];
                if (displayValue != nil && ![displayValue isEqualToString:@""]) {
                    fieldData.displayValue = displayValue;
                }
                //Check Also if refernce record exists for object
                NSString *relatedObjectName = [fieldNameAndObjectApiName objectForKey:fieldName];
                if ([relatedObjectName length] > 0 && [fieldData.internalValue length] > 0){
                    fieldData.isReferenceRecordExist  = [self isViewProcessExistsForObject:relatedObjectName recordId:fieldData.internalValue];
                }
            }
        }
    }
    return fieldValueData;
}

-(NSString *)checkAllDayAndReturnDateTime:(SFMPageField *)aPageField andInternalValue:(NSString *)internalValue
{
    NSString *isAlldayEventKey = ([self.objectName isEqualToString:kEventObject]?kIsAlldayEvent:kSVMXIsAlldayEvent);
    NSDictionary *dataDict =  nil;
    
    if([self.objectName isEqualToString:kEventObject] || [self.objectName isEqualToString:kSVMXTableName])
        dataDict = [SFMPageHelper getSlAInFo:self.objectName localId:self.recordId fieldNames:@[isAlldayEventKey]];
    
    NSString *dateTime = @"";
    
    if (isAlldayEventKey !=nil) {
        if ([[[dataDict objectForKey:isAlldayEventKey] uppercaseString] isEqualToString:@"TRUE"])
        {
            if (([aPageField.fieldName isEqualToString:kStartDateTime] && [self.objectName isEqualToString:kEventObject]) || ([aPageField.fieldName isEqualToString:kSVMXStartDateTime] && [self.objectName isEqualToString:kSVMXTableName]))
            {
                //For starttime of All day event.
                NSArray *dateTimeArray = [self getDateForAllDayEventOnDate:internalValue endDate:internalValue];
                
                dateTime = [DateUtil stringFromDate:[dateTimeArray objectAtIndex:0] inFormat:[DateUtil getUserTimeFormat]];
                
            }
            
            else if(([aPageField.fieldName isEqualToString:kEndDateTime] && [self.objectName isEqualToString:kEventObject]) || ([aPageField.fieldName isEqualToString:kSVMXEndDateTime] && [self.objectName isEqualToString:kSVMXTableName])) {
                
                //For endTime of All day event.

                NSArray *dateTimeArray = [self getDateForAllDayEventOnDate:internalValue endDate:internalValue];
                dateTime = [DateUtil stringFromDate:[dateTimeArray objectAtIndex:1] inFormat:[DateUtil getUserTimeFormat]];
            }
            else
                dateTime = [self getUserReadableDateTime:internalValue];
        }
        else
        {
            //In case the alldayevent is false.
            dateTime = [self getUserReadableDateTime:internalValue];
            
        }
    }
    else
    {
        //If the object is not of event or svmx_event.
        
        dateTime = [self getUserReadableDateTime:internalValue];
        
    }
    
    return dateTime;
    
}

-(NSString *)getUserReadableDateTime:(NSString *)dateTime
{
    return [DateUtil getUserReadableDateForDateBaseDate:dateTime];
}

-(NSString *)getUserReadableDate:(NSString *)dateTime
{
    NSString *dateString = nil;
    NSDate * date = [DateUtil dateFromString:dateTime inFormat:kDateFormatDefault];
    if (date != nil) {
        dateString = [NSDate localDateTimeStringFromDate:date inFormat:kDateFormatForSFMEdit];
        //ANOOP 017148:[DateUtil stringFromDate:date inFormat:kDateFormatForSFMEdit];
    }
    return dateString;
}

- (NSString *)getUserReadableDateForValueMapping:(NSString *)datetime
{
    NSString *userdateString = @"";
    if (![StringUtil isStringEmpty:datetime]) {
        NSDate * date = [DateUtil getDateFromDatabaseString:datetime];
        if (date != nil) {
            userdateString = [NSDate localDateTimeStringFromDate:date inFormat:kDateFormatForSFMEdit];
            //ANOOP 017148:[DateUtil stringFromDate:date inFormat:kDateFormatForSFMEdit];
        }
    }
    return userdateString;
}


- (NSString *)getDateForValueMapping:(NSString *)datetime
{
    NSString *userdateString = @"";
    NSDate * date = [DateUtil getDateFromDatabaseString:datetime];
    if (date != nil) {
        userdateString = [DateUtil stringFromDate:date inFormat:kDataBaseDate];
    }
    return userdateString;
}

- (void)updateReferenceFieldDisplayValues:(NSMutableDictionary *)fieldNameAndInternalValue
                      andFieldObjectNames:(NSDictionary *)fieldNameAndObjectNames
{
    
    NSMutableSet *foundRefernceValues = [[NSMutableSet alloc] initWithCapacity:0];
    
    NSArray *array = [fieldNameAndInternalValue allValues];
    
    NSMutableSet *set  = [[NSMutableSet alloc] initWithArray:[NSArray arrayWithArray:array]];
    
    for (NSString *objectName in [fieldNameAndInternalValue allKeys]) {
        NSString * value = [fieldNameAndInternalValue objectForKey:objectName];
        if ([StringUtil isStringEmpty:value])
            continue;
        NSString * relatedObjectName = [fieldNameAndObjectNames objectForKey:objectName];
        if ([relatedObjectName length] > 0) {
            //Get the value form the transactionmodel
            NSString * displayValue = [self getReferenceValueForObject:relatedObjectName andsfId:value];
            //Check Also if record exists
            
            if (![StringUtil isStringEmpty:displayValue]) {
                [foundRefernceValues addObject:value];
                [fieldNameAndInternalValue setObject:displayValue forKey:objectName];
            }
        }
    }
    
    //check for remaning id
    NSMutableSet *remainigIds = [NSMutableSet setWithSet:set]; //To test
    [remainigIds minusSet:foundRefernceValues];
    
    NSDictionary *idDictionary = nil;
    
    if ([set count] > 0) {
        idDictionary = [self getReferenceFieldValueFromLookUpTable:remainigIds];
    }
    
    for (NSString * sfId in remainigIds) {
        NSString * newValue = [idDictionary objectForKey:sfId];
        if ([StringUtil isStringEmpty:newValue])
            continue;
        NSArray *matchingKeys = [fieldNameAndInternalValue allKeysForObject:sfId];
        
        // 033878
        
//         if ([matchingKeys count] > 0)
//         [fieldNameAndInternalValue setValue:newValue forKey:[matchingKeys objectAtIndex:0]];
        
        for (int index = 0; index < [matchingKeys count]; index++) {
            [fieldNameAndInternalValue setValue:newValue forKey:[matchingKeys objectAtIndex:index]];
        }
    }
}

- (NSString *)getReferenceValueForObject:(NSString *)objectName andsfId:(NSString *)sfId
{
        return [SFMPageHelper getRefernceFieldValueForObject:objectName andId:sfId];
    }

- (NSDictionary *)getReferenceFieldValueFromLookUpTable:(NSMutableSet *)remainingIds
{
    return [SFMPageHelper getValuesFromReferenceTable:[remainingIds allObjects]];
}

- (NSMutableDictionary *)getDetailRecords:(SFMPage *)sfmPage andHeaderId:(NSString *)headerSfId
{
    NSMutableDictionary *detailRecord = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    NSMutableDictionary *processComp = sfmPage.process.component;
    NSArray *details = sfmPage.process.pageLayout.detailLayouts;
    
    for (SFMDetailLayout *detailLayout in details) {
        
        NSString * processComponentId = detailLayout.processComponentId;
        SFProcessComponentModel *componemtModel = [processComp objectForKey:processComponentId];
        
        if ([componemtModel.componentType isEqualToString:@"TARGETCHILD"]) {
            NSArray *sectionFields = detailLayout.detailSectionFields;
            SFMDetailFieldData * record = [[SFMDetailFieldData alloc] init];
            record.fieldsArray = sectionFields;
            record.parentLocalId = sfmPage.recordId;
            record.parentSfID = headerSfId;
            record.parentColumnName = componemtModel.parentColumnName;
            record.objectName = componemtModel.objectName;
            record.sortingData = componemtModel.sortingOrder;
            record.sourceToTargetType = sfmPage.process.processInfo.processType;
            
            if (![StringUtil isStringEmpty:componemtModel.expressionId]) {
                SFExpressionParser *expressionParser = [[SFExpressionParser alloc] initWithExpressionId:componemtModel.expressionId
                                                                                             objectName:componemtModel.objectName];
                record.criteriaObjects = [NSMutableArray arrayWithArray:[expressionParser expressionCriteriaObjects]];
                record.expression = [expressionParser advanceExpression];
            }
            
            NSMutableArray * detailArray = [self getDetailData:record];
            
            if ([detailArray count] > 0) {
                [detailRecord setObject:detailArray forKey:componemtModel.sfId];
            }
        }
    }
    [self resetPicklistAndRecordTypeData];
    
    return detailRecord;
}

- (NSMutableArray *)getDetailData:(SFMDetailFieldData *)record
{
    NSMutableArray *detailsArray = nil;
    
    NSMutableDictionary *fieldDataTypeMap = [self getFieldDataTypeMap:record.fieldsArray];
    NSMutableArray *picklists = [fieldDataTypeMap objectForKey:kSfDTPicklist];
    NSMutableArray *multiPicklists = [fieldDataTypeMap objectForKey:kSfDTMultiPicklist];
    
    [self fillPickPickListAndRecordTypeInfo:fieldDataTypeMap andObjectName:record.objectName];
    
    NSArray *detailRecrds = [SFMPageHelper getDetialsRecord:record]; //gets all the detail lines
    
    for (NSDictionary *dataDict in detailRecrds) {
        NSMutableDictionary * detatlDataDict = [self fillDataDictForHeaderOrDetail:dataDict fields:record.fieldsArray];
        
        [self updatePicklistDisplayValues:detatlDataDict picklistFields:picklists multiPicklistFields:multiPicklists];
        [self updateRecordTypeDisplayValue:detatlDataDict];
        
        if ([detatlDataDict count] > 0){
            if(detailsArray == nil)
            {
                detailsArray = [[NSMutableArray alloc] init];
            }
            [detailsArray addObject:detatlDataDict];
        }
    }
    return detailsArray;
}

- (void)updatePicklistDisplayValues:(NSDictionary *)dataDict
                     picklistFields:(NSMutableArray *)picklistFields
                multiPicklistFields:(NSMutableArray *)multiPicklistFields
{
    if ([self.pickListData count] > 0) {
        for (NSString *pickListFieldName in picklistFields) {
            NSMutableDictionary *picklistDict = [self.pickListData objectForKey:pickListFieldName];
            SFMRecordFieldData *field = [dataDict objectForKey:pickListFieldName];
            NSString *displayValue = nil;
            if (field != nil) {
                displayValue = field.internalValue;
            }
            if ([picklistDict count] > 0 ) {
                if (![StringUtil isStringEmpty:displayValue]) {
                    SFPicklistModel *model = [picklistDict objectForKey:displayValue];
                    if (model != nil) {
                        field.displayValue = model.label;
                    }
                }
            }
        }
        for (NSString *pickListFieldName in multiPicklistFields) {
            NSMutableDictionary *picklistDict = [self.pickListData objectForKey:pickListFieldName];
            SFMRecordFieldData *field = [dataDict objectForKey:pickListFieldName];
            NSString *displayValue = nil;
            if (field != nil) {
                displayValue = field.internalValue;
            }
            if ([picklistDict count] > 0 ) {
                if (![StringUtil isStringEmpty:displayValue]) {
                    NSArray *values = [SFMPageHelper getAllValuesFromMultiPicklistString:displayValue];
                    NSDictionary *maappingDict = [self getMultiPicklistMappingDict:picklistDict value:values];
                    if ([maappingDict count] > 0) {
                        NSString *picklistValue = [SFMPageHelper getMutliPicklistLabelForpicklistString:values andFieldLabelDictionary:maappingDict];
                        if (picklistValue != nil) {
                            field.displayValue = picklistValue;
                        }
                    }
                }
            }
        }
    }
}

- (void)updateRecordTypeDisplayValue:(NSMutableDictionary *)dataDictionary
{
    if ([self.recordTypeData count] > 0) {
        SFMRecordFieldData *fieldData = [dataDictionary objectForKey:kSfDTRecordTypeId];
        if (fieldData != nil) {
            SFRecordTypeModel *model = [self.recordTypeData objectForKey:fieldData.internalValue];
            if (model != nil) {
                fieldData.displayValue = model.recordtypeLabel;
            }
        }
    }
}

- (NSDictionary *)getMultiPicklistMappingDict:(NSDictionary *)picklistDict
                                        value:(NSArray *)displayValues
{
    NSMutableDictionary *dataDict = [NSMutableDictionary new];
    
    for (NSString *value in displayValues) {
        SFPicklistModel *model = [picklistDict objectForKey:value];
        if (model != nil) {
            [dataDict setObject:model.label forKey:model.value];
        }
    }
    return dataDict;
}

- (void)resetPicklistAndRecordTypeData
{
    self.pickListData = nil;
    self.recordTypeData = nil;
}

- (NSString *)getLocalIdForSFID:(NSString *)sfID objectName:(NSString *)objectName
{
    return [SFMPageHelper getLocalIdForSFID:sfID objectName:objectName];
}

- (BOOL)isValidProcess:(NSString *)processId objectName:(NSString *)objectName recordId:(NSString *)sfId error:(NSError **)error
{
    BOOL isValidProcess = NO;
    SFProcessModel *processModel = [SFMPageHelper getProcessInfoForSFID:processId];
    if (![StringUtil isStringEmpty:processModel.sfID]) {
        NSError *internalError = nil;
        NSDictionary *pageLayout = [SFMPageHelper getPageLayoutForProcess:processId];
        if ([pageLayout count]>0) {
            if ([self isEntryCriteraMatchingForProcess:processId objectName:objectName recordId:sfId error:&internalError])
            {
                isValidProcess = YES;
            }
            else
            {
                SXLogDebug(@"Entry critera is not matching");
                //Defect fix: 012660
                [self fillError:error withPageManagerErrorType:PageManagerErrorTypeNotMatchingEntryCriteria message:[internalError localizedDescription]];
                //[self fillError:error withPageManagerErrorType:PageManagerErrorTypeNotMatchingEntryCriteria message:nil];
                
            }
        }
        else
        {
            SXLogWarning(@"Page layout is not available");
            
            [self fillError:error withPageManagerErrorType:PageManagerErrorTypeNoPageLayout message:[internalError localizedDescription]];
        }
        
    }
    else
    {
        SXLogWarning(@"Process is not availbale");
        [self fillError:error withPageManagerErrorType:PageManagerErrorTypeNoProcess message:nil];
        
    }
    return isValidProcess;
}

- (BOOL)isValidOPDocProcess:(NSString *)processId error:(NSError **)error
{
    BOOL isValidProcess = NO;
    SFProcessModel *processModel = [SFMPageHelper getProcessInfoForSFID:processId];
    if (![StringUtil isStringEmpty:processModel.sfID])
    {
        NSError *internalError = nil;
        if ([self isEntryCriteraMatchingForProcess:processId objectName:nil recordId:nil error:&internalError])
        {
            isValidProcess = YES;
        }
        else
        {
            SXLogWarning(@"Entry criteria is not matching");
            [self fillError:error withPageManagerErrorType:PageManagerErrorTypeNotMatchingEntryCriteria message:nil];
        }
    }
    else
    {
        SXLogWarning(@"Process is not available");
        [self fillError:error withPageManagerErrorType:PageManagerErrorTypeNoProcess message:nil];
        
    }
    return isValidProcess;
}


- (SFMPage *) sfmPage
{
    SFMPage *sfmPage = [[SFMPage alloc] initWithObjectName:self.objectName andRecordId:self.recordId];
    
    NSString *objectLabel = [self getObjectLabel];
    
    if ([objectLabel length] > 0) {
        sfmPage.objectLabel = objectLabel;
    }
    
    /*Fill SFMProcess object info*/
    if (self.processId != nil) {
        sfmPage.process = [self sfmProcessForPage];
    }
    
    /*Data filling*/
    NSMutableDictionary *headerDict = [self getHeaderRecordForSFMPage:sfmPage];
    sfmPage.nameFieldValue = self.nameFieldValue;
    
    if ([headerDict count] > 0) {
        sfmPage.headerRecord = headerDict;
    }
    
    NSString *headerId = [self getHeaderSfId:sfmPage];
    NSMutableDictionary *details = [self getDetailRecords:sfmPage andHeaderId:headerId];
    
    if ([details count] > 0) {
        sfmPage.detailsRecord = details;
    }
    
    
    //fill page
    return sfmPage;
}

- (NSString *)getHeaderSfId:(SFMPage *)sfmPageLocal
{
    return [sfmPageLocal getHeaderSalesForceId];
}

- (SFMProcess *) sfmProcessForPage
{
    SFMProcess *process = [[SFMProcess alloc] init];
    process.processInfo = [SFMPageHelper getProcessInfoForSFID:self.processId];
    process.component = [SFMPageHelper getProcessComponentForProcess:process.processInfo.sfID];
    process.pageLayout = [self pageLayoutInfoForProcess:process];
    [self fillUpPrecisionInfoForPage:process];
    return process;
}

- (NSString *)getObjectLabel
{
    return [SFMPageHelper getObjectLabelForObjectName:self.objectName];
}

- (BOOL)fillError:(NSError **)error withPageManagerErrorType:(PageManagerErrorType)errorType message:(NSString *)errorMessage
{
    if (error != NULL) {
        NSString *message = nil;
        TagManager *tagManager = [TagManager sharedInstance];
        switch (errorType) {
            case PageManagerErrorTypeNoPageLayout:
                message = [tagManager tagByName:kTagSfmNoPageLayout];
                break;
                
            case PageManagerErrorTypeNoProcess:
                message = [tagManager tagByName:kTagNoViewProcess];
                break;
                
            case PageManagerErrorTypeNotMatchingEntryCriteria:
                if ([StringUtil isStringEmpty:errorMessage]) {
                    message = [tagManager tagByName:kTagSfmSwitchProcess];
                }
                else{
                    message = errorMessage;
                }
                break;
                
            default:
                break;
        }
        NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:message, NSLocalizedDescriptionKey, nil];
        *error = [[NSError alloc] initWithDomain:SMApplicationErrorDomain code:0 userInfo:userInfo];
    }
    
    return YES;
}

- (BOOL)isViewProcessExistsForObject:(NSString *)objectName recordId:(NSString *)sfId
{
    return NO;
}

- (NSString *)getProcessTypeForProcessId:(NSString *)processId {
    return [SFMPageHelper getProcessTypeForId:processId];
}

- (NSString*)getBoolValueForInternalValue:(NSString*)internalValue
{
    NSString *boolValue;
    if ([StringUtil isItTrue:internalValue]) {
        boolValue = kYes;
    }else{
        boolValue = kNo;
    }
    return boolValue;
}


#pragma DateTimeFor All Day event

-(NSArray *)getDateForAllDayEventOnDate:(NSString *)startDate endDate:(NSString *)endDate{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comp = [cal components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[self dateFromString:startDate]];
        
        comp.second = 00;
        comp.hour = 00;
        comp.minute = 00;
        
        NSDate *theStartDate = [cal dateFromComponents:comp];
        comp = [cal components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[self dateFromString:endDate]];
        comp.hour = 23;
        comp.minute = 59;
        
        NSDate *theEndDate = [cal dateFromComponents:comp];
    
    
    //First Object is the start date, second object is End date.
    return @[theStartDate, theEndDate];
}

-(NSDate *)dateFromString:(NSString *)dateString
{
    NSRange range = [dateString rangeOfString:@"T"];
    
    dateString = [dateString substringToIndex:range.location];
    NSDateFormatter *lDF = [[NSDateFormatter alloc] init];
    [lDF setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *date = [lDF dateFromString:dateString];
    return date;
}


- (SFMPage *)theSFMPagewithObjectName:(NSString *)theObjectName andRecordID:(NSString *)lRecordID andProcessID:(NSString *)lProcessId
{
    SFMPage *sfmPage = [[SFMPage alloc] initWithObjectName:theObjectName andRecordId:lRecordID];
    
    NSString *objectLabel = [SFMPageHelper getObjectLabelForObjectName:theObjectName];
    
    
    if ([objectLabel length] > 0) {
        sfmPage.objectLabel = objectLabel;
    }
    
    /*Fill SFMProcess object info*/
    
    SFMProcess *process = [[SFMProcess alloc] init];
    process.processInfo = [SFMPageHelper getProcessInfoForSFID:lProcessId];
    process.component = [SFMPageHelper getProcessComponentForProcess:process.processInfo.sfID];
    process.pageLayout = [self pageLayoutInfoForProcess:process];
    [self fillUpPrecisionInfoForPage:process];
    
    sfmPage.process = process;
    
    
    /*Data filling*/
    NSMutableDictionary *headerDict = [self getHeaderRecordForSFMPage:sfmPage];
    sfmPage.nameFieldValue = self.nameFieldValue;
    
    if ([headerDict count] > 0) {
        sfmPage.headerRecord = headerDict;
    }
    
    NSString *headerId = [self getHeaderSfId:sfmPage];
    NSMutableDictionary *details = [self getDetailRecordsForCustom:sfmPage andHeaderId:headerId];
    
    if ([details count] > 0) {
        sfmPage.detailsRecord = details;
    }
    
    //fill page
    return sfmPage;
}

- (NSMutableDictionary *)getDetailRecordsForCustom:(SFMPage *)sfmPage andHeaderId:(NSString *)headerSfId
{
    NSMutableDictionary *detailRecord = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    NSMutableDictionary *processComp = sfmPage.process.component;
    NSArray *details = sfmPage.process.pageLayout.detailLayouts;
    
    for (SFMDetailLayout *detailLayout in details) {
        
        NSString * processComponentId = detailLayout.processComponentId;
        SFProcessComponentModel *componemtModel = [processComp objectForKey:processComponentId];
        
        NSArray *sectionFields = detailLayout.detailSectionFields;
        SFMDetailFieldData * record = [[SFMDetailFieldData alloc] init];
        record.fieldsArray = sectionFields;
        record.parentLocalId = sfmPage.recordId;
        record.parentSfID = headerSfId;
        record.parentColumnName = componemtModel.parentColumnName;
        record.objectName = componemtModel.objectName;
        record.sortingData = componemtModel.sortingOrder;
        record.sourceToTargetType = sfmPage.process.processInfo.processType;
        
        if (![StringUtil isStringEmpty:componemtModel.expressionId]) {
            SFExpressionParser *expressionParser = [[SFExpressionParser alloc] initWithExpressionId:componemtModel.expressionId
                                                                                         objectName:componemtModel.objectName];
            record.criteriaObjects = [NSMutableArray arrayWithArray:[expressionParser expressionCriteriaObjects]];
            record.expression = [expressionParser advanceExpression];
            
            NSMutableArray * detailArray = [self getDetailData:record];
            
            if ([detailArray count] > 0) {
                [detailRecord setObject:detailArray forKey:componemtModel.sfId];
            }
        }
    }
    [self resetPicklistAndRecordTypeData];
    
    return detailRecord;
}

@end
