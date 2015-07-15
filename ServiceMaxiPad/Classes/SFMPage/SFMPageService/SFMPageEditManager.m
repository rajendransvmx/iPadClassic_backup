//
//  SFMPageEditManager.m
//  ServiceMaxMobile
//
//  Created by shravya on 29/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFMPageEditManager.h"
#import "SFMPageEditHelper.h"
#import "StringUtil.h"
#import "SFPicklistModel.h"
#import "SFPicklistDAO.h"
#import "SFRTPicklistDAO.h"

#import "SFMRecordFieldData.h"
#import "SFMPageField.h"
#import "SFRecordTypeModel.h"

#import "SFProcessComponentModel.h"
#import "SFObjectMappingComponentDAO.h"
#import "FactoryDAO.h"
#import "SFObjectMappingComponentModel.h"
#import "SFObjectFieldModel.h"
#import "SFObjectFieldDAO.h"
#import "ValueMappingModel.h"

#import "DateUtil.h"
#import "StringUtil.h"
#import "ModifiedRecordModel.h"
#import "ModifiedRecordsDAO.h"
#import "TransactionObjectDAO.h"
#import "SFMPickerData.h"
#import "AppManager.h"
#import "SFMPageField.h"
#import "PlistManager.h"
#import "SFMDetailFieldData.h"
#import "SFExpressionParser.h"
#import "RecentDaoService.h"
#import "SFSourceUpdateModel.h"
#import "SourceUpdateDAO.h"
#import "DataTypeUtility.h"
#import "SuccessiveSyncManager.h"
#import "LinkedProcess.h"
#import "SMXConstants.h"
#import "FieldMergeHelper.h"
#import "MobileDeviceSettingService.h"

#import "DataTypeCache.h"

#import "SyncErrorConflictService.h"
#import "FieldUpdateRuleManager.h"
#import "Utility.h"
#import "SFMDetailLayout.h"

@interface SFMPageEditManager ()<BusinessRuleManagerDelegate>

@property (nonatomic, strong) NSMutableDictionary *pickListInfo;
@property (nonatomic, strong) NSString *pickListObjectName;
@property (nonatomic, strong) NSMutableDictionary *dataDictionaryBeforeModification;
@property (nonatomic, strong) FieldUpdateRuleManager *ruleManager;
@end

@implementation SFMPageEditManager

- (void)fillSfmPage:(SFMPage *)sfPage andProcessType:(NSString *)processType {
    
    @autoreleasepool {
        if ([processType isEqualToString:kProcessTypeStandAloneEdit]) {
            
            [self fillUpDataForEditProcess:sfPage];
        }
        else if ([processType isEqualToString:kProcessTypeSRCToTargetAll]) {
            
            [self fillUpSfmPageForSourceToTargetProcess:sfPage];
        }
        else if ([processType isEqualToString:kProcessTypeSRCToTargetChild]) {
            
            [self fillUpSfmPageForSourceToTargetChildProcess:sfPage];
        }
        else if ([processType isEqualToString:kProcessTypeStandAloneCreate]) {
            
            [self fillDataForStandAloneCreateProcesSFPage:sfPage];
        }
    }
}

- (void)fillUpDataForEditProcess:(SFMPage *)sfPage {
    
    SFMPage *newPage = [super sfmPage];
    if (newPage != nil) {
        sfPage.process = newPage.process;
        sfPage.objectLabel = newPage.objectLabel;
        sfPage.headerRecord = newPage.headerRecord;
        sfPage.detailsRecord = newPage.detailsRecord;
        sfPage.nameFieldValue =  newPage.nameFieldValue;
        
        [self valueMapping:newPage];
        [self fillLinkedProcessForDetailLine:sfPage];
    }
}

#pragma mark - Picklist(Dependent and RTDependent)
- (NSArray *)getPickListInfoForObject:(NSString *)objectName fieldName:(NSString *)fieldName
{
    /* if (self.pickListInfo == nil) {
     self.pickListInfo = [NSMutableDictionary new];
     }
     NSArray *picklists = [self.pickListInfo objectForKey:fieldName];
     
     if (picklists == nil && [picklists count] == 0){
     NSArray *dataArray = [SFMPageEditHelper getPickListInfoForObject:objectName field:fieldName];
     [self.pickListInfo setObject:dataArray forKey:fieldName];
     }*/
    return [self.pickListInfo objectForKey:fieldName];
}

-(NSArray *)getPicklistValueForIndexPath:(NSString *)objectName
                               pageField:(SFMPageField *)pageField
                                 sfmpage:(SFMPage *)newSfmPage
{
    if (self.pickListObjectName != nil) {
        self.pickListObjectName = nil;
    }
    
    self.pickListObjectName = objectName;
    
    NSArray * picklistData;
    
    NSMutableArray * array = [NSMutableArray new];
    
    if ([pageField.fieldName isEqualToString:kSfDTRecordTypeId] && [pageField.dataType isEqualToString:kSfDTReference])
    {
        picklistData = [self getRtPicklistValues:pageField];
        for (int i = 0; i<[picklistData count]; i++) {
            
            SFRecordTypeModel *model = [picklistData objectAtIndex:i];
            if (model != nil) {
                if ([model.recordtypeLabel caseInsensitiveCompare:@"MASTER"] == NSOrderedSame) {
                    continue;
                }
                SFMPickerData *pickerModel = [[SFMPickerData alloc] initWithPickerValue:model.recordTypeId
                                                                                  label:model.recordtypeLabel
                                                                                  index:(i+1)];
                [array addObject:pickerModel];
            }
        }
    }
    else
    {
        picklistData = [self getPicklistValues:pageField];
        for (int i = 0; i<[picklistData count]; i++) {
            SFPicklistModel *model = [picklistData objectAtIndex:i];
            if (model != nil) {
                SFMPickerData *pickerModel = [[SFMPickerData alloc] initWithPickerValue:model.value
                                                                                  label:model.label
                                                                                  index:(i+1)];
                [array addObject:pickerModel];
            }
        }
    }
    if(![pageField.dataType isEqualToString:kSfDTMultiPicklist]) {
        SFMPickerData *pickerModel = [[SFMPickerData alloc] initWithPickerValue:@"" label:@"" index:0];
        [array insertObject:pickerModel atIndex:0];
    }
    return array;
}


-(NSArray *)getRtPicklistValues:(SFMPageField *)pageField
{
    NSMutableArray * pickerValues = [self getPicklist:pageField];
    if(pickerValues == nil || [pickerValues count] == 0)
    {
        pickerValues= [SFMPageEditHelper getRecordTypeValuesForObjectName:self.pickListObjectName];
        [self fillPicklist:pickerValues fieldName:pageField];
    }
    return pickerValues;
}

-(void)fillPicklist:(NSMutableArray *)picklistData  fieldName:(SFMPageField *)field
{
    if(self.pickListInfo == nil)
    {
        self.pickListInfo = [[NSMutableDictionary alloc] init];
    }
    
    [self.pickListInfo setObject:picklistData forKey:field.fieldName];
}

-(NSMutableArray *)getPicklist:(SFMPageField *)pageField
{
    return  [self.pickListInfo objectForKey:pageField.fieldName] ;
}


-(NSArray *)getPicklistValues:(SFMPageField *)pageField
{
    NSMutableArray *picklistValues = nil;
    
    NSMutableArray * pickerValues = [self getPicklist:pageField];
    //Checking if we have already value for this field ,else add in dict and use it for next time.
    if(pickerValues == nil || [pickerValues count] == 0)
    {
        picklistValues = [SFMPageEditHelper getPicklistValuesForField:pageField.fieldName objectName:self.pickListObjectName];
        [self fillPicklist:picklistValues fieldName:pageField];
    }
    
    NSArray * pickList  = [self.pickListInfo objectForKey:pageField.fieldName];
    
    //Here we are checking if we have any Record Type or Other Dependecy
    //This check is for getting Dependent picklist values
    if (!([pageField.fieldName isEqualToString:kSfDTRecordTypeId] && [pageField.dataType isEqualToString:kSfDTReference]))
    {
        NSArray *recordTypeDepList = [self getRecordTypeDependentPicklist:pageField]; //It will check if there are any record type dependent fields.
        pickList = [self getDependentValuesForPageField:pageField withPicklist:pickList andRecordTypeDependentPicklist:recordTypeDepList];
        
    }
    return pickList;
    
}

-(NSArray *)getDependentValuesForPageField:(SFMPageField *)pageField withPicklist:(NSArray *)pickList andRecordTypeDependentPicklist:(NSArray *)recordTypeDepList
{
    
    NSArray *dependentPicklistValues = nil;
    
    SFMPageField *controllerPageField  = [self getPageFieldForField:pageField.controlerField];
    SFMRecordFieldData *recordField = [self getRecordDataForField:controllerPageField.fieldName];
    
    if ([controllerPageField.dataType isEqualToString:kSfDTBoolean] && recordField.internalValue == nil) {
        recordField.internalValue = kFalse;
    }
    
    if (([StringUtil isItTrue:pageField.isDependentPicklist]) && (controllerPageField !=nil))
    {
        //Here we can check if recordField.value = @"", then load complet set
        if ([StringUtil isStringEmpty:recordField.internalValue])
        {
            return nil; //If controlling field value is nil, dependent field value will be none
            
           /* if ([recordTypeDepList count]!=0)
            {
                //Returning complet set of DependentPicklist if there is nothing selected in Controlling Field
                return recordTypeDepList;
            }
            else
                return pickList;*/
        }
        dependentPicklistValues =  [SFMPageEditHelper getDependentPicklistValuesForPageField:controllerPageField recordFieldVal:recordField.internalValue objectName:self.pickListObjectName fromPicklist:pickList];
        
        //There is record type dependency
        if ([recordTypeDepList count]!=0)
        {
            dependentPicklistValues =  [SFMPageEditHelper getCommonDependentValuesFromRecordTypeValue:recordTypeDepList andDependentValues:dependentPicklistValues];
        }
        return dependentPicklistValues;
    }
    else
    {
        if ([recordTypeDepList count]!=0)
        {
            return recordTypeDepList;
        }
        else
            return pickList;
    }
}

- (NSArray *)getRecordTypeDependentPicklist:(SFMPageField *)pageField
{
    NSArray *recordTypeDepList = nil;
    
    SFMPageField *recordTypePageField = [self getPageFieldForField:kSfDTRecordTypeId];
    if (recordTypePageField)
    {
        SFMRecordFieldData *recordTypeRecordField = [self getRecordDataForField:recordTypePageField.fieldName];
        
        BOOL recordTypeDependencyExists = [SFMPageEditHelper isRecordTypeDependent:pageField.fieldName RecordTypeFieldData:recordTypeRecordField.internalValue andObjectName:self.pickListObjectName];
        
        if (recordTypeDependencyExists) {
            
            recordTypeDepList = [SFMPageEditHelper getRecordTypePicklistData:self.pickListObjectName fieldName:pageField.fieldName pageDataValue:recordTypeRecordField.internalValue];
        }
    }
    return recordTypeDepList;
}

- (NSArray *)getRTDependentPicklistInfoForobject:(NSString *)objectApiName recordTypeId:(NSString *)recordTypeId
{
    return [SFMPageEditHelper getRTDependencyFieldsForobject:objectApiName recordTypeId:recordTypeId];
}

- (NSDictionary *)getDefautValueForRTDepFields:(NSArray *)fields
                                    objectname:(NSString *)objectApiName
                                  recordTypeId:(NSString *)recordTypeId
{
    return [SFMPageEditHelper getDefaultValueForRTDepFields:fields objectName:objectApiName recordTypeId:recordTypeId];
    
}


- (SFMPageField *)getPageFieldForField:(NSString *)fieldName
{
    if ([self.editViewControllerDelegate respondsToSelector:@selector(getPageFieldForField:)]) {
        
        SFMPageField *pageField = [self.editViewControllerDelegate getPageFieldForField:fieldName];
        if (pageField == nil && ![fieldName isEqualToString:kSfDTRecordTypeId]) {
            pageField = [SFMPageEditHelper getObjectInfoForObject:self.pickListObjectName fieldName:fieldName];
            
        }
        return pageField;
    }
    return nil;
}

- (SFMRecordFieldData *)getRecordDataForField:(NSString *)fieldName
{
    if ([self.editViewControllerDelegate respondsToSelector:@selector(getRecordDataForField:)]) {
        SFMRecordFieldData *recordData = [self.editViewControllerDelegate getRecordDataForField:fieldName];
        if (recordData == nil && fieldName) {
          
            NSString *localId = [self.editViewControllerDelegate recordLocalId];
            
            NSMutableDictionary *dict = [SFMPageEditHelper getDataForObject:self.pickListObjectName fields:@[fieldName] recordId:localId];
            
            NSString *fieldValue = [dict objectForKey:fieldName];
            
            if (![StringUtil isStringEmpty:fieldValue]) {
                recordData = [[SFMRecordFieldData alloc] initWithFieldName:fieldName
                                                                     value:fieldValue
                                                           andDisplayValue:fieldValue];
            }
        }
        return recordData;
    }
    return nil;
}

#pragma mark - End

#pragma mark - ValueMApping Implementation

-(void)valueMapping:(SFMPage *)sfmPage
{
    [self fillUpValueMappingMetaData:sfmPage];
    [self fillUpDisplayValuesForValueMapping:sfmPage];
    [self applyValueMapping:sfmPage];
}


- (void)fillUpValueMappingMetaData:(SFMPage *)sfmPage {
    NSDictionary * componentsArray =  sfmPage.process.component;
    
    NSMutableDictionary * valueMappingDict = nil;
    
    for (NSString * componentId in componentsArray) {
        
        SFProcessComponentModel * componentModel= [sfmPage.process.component objectForKey:componentId];
        
        id <SFObjectMappingComponentDAO> mappingDao = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectMappingComponent];
        NSArray * mappingArray =  [mappingDao getObjectMappingDictForMappingId:componentModel.valueMappingId];
        
        if( valueMappingDict == nil)
        {
            valueMappingDict = [[NSMutableDictionary alloc] init];
        }
        
        NSMutableDictionary * eachDict = [[NSMutableDictionary alloc] init];
        for (SFObjectMappingComponentModel * mappingModel in mappingArray ) {
            
            /*  ===================================================  */
                /*Defect: 018999, non translated display values */
            /*  ===================================================  */
            
           
            
            NSString *displayValue = mappingModel.mappingValue;
            NSString *internalValue = mappingModel.mappingValue;
            
            if(sfmPage.process.processInfo.processType != nil && [sfmPage.process.processInfo.processType isEqualToString:kProcessTypeStandAloneCreate])
            {
                NSString *pickListDisplayValue;
                
                id <SFPicklistDAO> picklistService = [FactoryDAO serviceByServiceType:ServiceTypeSFPickList];
              
                    pickListDisplayValue = [picklistService getDisplayValueFromPicklistForObjectName:sfmPage.objectName withMappingCompenent:mappingModel];
                if(pickListDisplayValue){
                    
                    /* update same value for both display and internal value */
                    
                    displayValue = pickListDisplayValue;
                    internalValue = pickListDisplayValue;
                    
                }
                
            }
            
            /*  ===================================================  */
                     /* END */
            /*  ===================================================    */
            SFMRecordFieldData * recordField = [[SFMRecordFieldData alloc] initWithFieldName: mappingModel.targetFieldName value:internalValue andDisplayValue:displayValue];
            
            if(mappingModel.targetFieldName != nil){
                
                [eachDict setObject:recordField forKey:mappingModel.targetFieldName];
            }
        }
        if([eachDict count] == 0 )
        {
            continue;
        }
        [valueMappingDict setObject:eachDict forKey:componentId];
    }
    
    sfmPage.process.valueMappingDict = valueMappingDict;
}

-(void)fillUpDisplayValuesForValueMapping:(SFMPage *)page
{
    NSArray *allComponets = [page.process.component allKeys];
    NSMutableDictionary *valueMappingDict  = [page.process valueMappingDict];
    
    for (NSString * componentId in allComponets) {
        SFProcessComponentModel * component = [page.process.component objectForKey:componentId];
        NSMutableDictionary *eachMappingDict = [valueMappingDict objectForKey:componentId];
        
        if([eachMappingDict count] <= 0)
        {
            continue;
        }
        NSArray * fields = [eachMappingDict allKeys];
        
        NSDictionary * fieldsDict =[SFMPageHelper getFieldsInfoFor:fields objectName:component.objectName];
        NSMutableDictionary *dataTypeFieldsDict = [self getFieldDataTypeMapForValueMAp:[fieldsDict allValues]];
        
        [self fillPickPickListAndRecordTypeInfo:dataTypeFieldsDict andObjectName:component.objectName];
        
        [self updatePicklistDisplayValues:eachMappingDict picklistFields:[dataTypeFieldsDict objectForKey:kSfDTPicklist] multiPicklistFields:[dataTypeFieldsDict objectForKey:kSfDTMultiPicklist] ];
        
        [self updateDisplayValuesForValueMapping:eachMappingDict withFieldInfo:fieldsDict];
        
        [self resetPicklistAndRecordTypeData];
    }
}

- (NSMutableDictionary *)getFieldDataTypeMapForValueMAp:(NSArray *)fields
{
    NSMutableDictionary *mappingDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    for(SFObjectFieldModel *eachField in fields) {
        if ([eachField.type isEqualToString:kSfDTPicklist]) {
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
        else if ([eachField.type isEqualToString:kSfDTMultiPicklist]) {
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
        else if ([eachField.type isEqualToString:kSfDTReference]  && [eachField.fieldName isEqualToString:kSfDTRecordTypeId]) {
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

- (void)updateDisplayValuesForValueMapping:(NSMutableDictionary *)valueMappingDict withFieldInfo:(NSDictionary *)fieldInfoDict
{
    
    NSMutableDictionary * fieldNameAndInternalValue = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    NSMutableDictionary * fieldNameAndObjectApiName =  [[NSMutableDictionary alloc] initWithCapacity:0];
    
    for (NSString * fieldName  in [valueMappingDict allKeys]) {
        SFMRecordFieldData * recordfield = [valueMappingDict objectForKey:fieldName];
        
        NSString * displayValue = nil;
        NSString * fieldName = recordfield.name;
        NSString * mappingValue = recordfield.internalValue;
        SFObjectFieldModel * objectField = [fieldInfoDict objectForKey:fieldName];
        
        if ([objectField.type isEqualToString:kSfDTReference] && ![objectField.fieldName isEqualToString:kSfDTRecordTypeId])
        {
            if (![StringUtil isStringEmpty:recordfield.internalValue]) {
                [fieldNameAndInternalValue setObject:recordfield.internalValue forKey:objectField.fieldName];
                if (objectField.referenceTo != nil) {
                    [fieldNameAndObjectApiName setObject:objectField.referenceTo forKey:objectField.fieldName];
                }
            }
        }
        else if([objectField.type isEqualToString:kSfDTReference] && [objectField.fieldName isEqualToString:kSfDTRecordTypeId])
        {
            
            for(NSString * recordTypeID in [self.recordTypeData allKeys])
            {
                SFRecordTypeModel * recordTypeModel = [self.recordTypeData objectForKey:recordTypeID];
                if([recordTypeModel.recordType isEqualToString:mappingValue])
                {
                    recordfield.internalValue = recordTypeID;
                    displayValue = recordTypeModel.recordtypeLabel;
                    break;
                }
            }
            
        }
        else if ([objectField.type isEqualToString:kSfDTDateTime] || [objectField.type isEqualToString:kSfDTDate])
        {
            NSString *internalValue = [DateUtil evaluateDateLiteral:recordfield.internalValue  dataType:objectField.type];
            
            recordfield.internalValue = internalValue;
            
            if ([objectField.type isEqualToString:kSfDTDate]) {
                if ([recordfield.internalValue length] > 10) {
                    recordfield.internalValue = [self getDateForValueMapping:recordfield.internalValue];
                }
                displayValue = [self getUserReadableDateForValueMapping:internalValue];
            }
            else
            {
                displayValue = [self getUserReadableDateTime:internalValue];
            }
            
        }
        else if ([objectField.type isEqualToString:kSfDTBoolean] )
        {
            displayValue = [SFMPageHelper  valueOfLiteral:recordfield.internalValue dataType:objectField.type];
            recordfield.internalValue = displayValue;
        }
        else
        {
            displayValue = [SFMPageHelper  valueOfLiteral:recordfield.internalValue dataType:@""];
            if(displayValue == nil)
            {
                displayValue = mappingValue;
            }
        }
        
        recordfield.displayValue = displayValue;
        
    }
    
    if ([fieldNameAndInternalValue count] > 0)
    {
        [self updateReferenceFieldDisplayValues:fieldNameAndInternalValue andFieldObjectNames:fieldNameAndObjectApiName];
        for (NSString *fieldName in fieldNameAndObjectApiName) {
            SFMRecordFieldData *fieldData = [valueMappingDict objectForKey:fieldName];
            NSString *displayValue = [fieldNameAndInternalValue objectForKey:fieldName];
            if (displayValue != nil && ![displayValue isEqualToString:@""]) {
                fieldData.displayValue = displayValue;
            }
        }
    }
    
}

-(void)applyValueMapping:(SFMPage *)sfmPage
{
    NSDictionary * processComponents = sfmPage.process.component;
    NSArray * allComponents = [processComponents  allKeys];
    NSMutableDictionary * headerDict = sfmPage.headerRecord;
    
    for (NSString * componentId in allComponents)
    {
        SFProcessComponentModel * componentModel = [processComponents objectForKey:componentId];
        NSDictionary  * valueMapDict =  [sfmPage.process.valueMappingDict objectForKey:componentId];
        
        NSString * objectName = componentModel.objectName;
        if(valueMapDict == nil || [valueMapDict count] <= 0)
        {
            continue;
        }
        if([componentModel.componentType isEqualToString:kTarget])
        {
            ValueMappingModel * mappingModel = [[ValueMappingModel alloc] init];
            mappingModel.valueMappingDict = valueMapDict;
            mappingModel.currentRecord = headerDict;
            mappingModel.headerRecord = headerDict;
            mappingModel.currentObjectName = objectName;
            mappingModel.headerObjectName = objectName;
            [self applyValueMapWithMappingObject:mappingModel];
        }
        
    }
    
}

-(void)applyValueMapWithMappingObject:(ValueMappingModel *)modelObj
{
    NSArray * fieldNames = [modelObj.valueMappingDict allKeys];
    for( NSString *fieldName in fieldNames)
    {
        SFMRecordFieldData * recordfield = [modelObj.valueMappingDict objectForKey:fieldName];
        NSString * targetFieldName = recordfield.name;
        NSString * mappingValue =   recordfield.internalValue;
        NSString * displayValue =   recordfield.displayValue;
        
        if ([StringUtil containsString:kLiteralCurrentRecord inString:mappingValue])
        {
            SFMRecordFieldData * literalField = [self getDisplayValueForLiteral:mappingValue mappingObject:modelObj];
            mappingValue = literalField.internalValue;
            displayValue = literalField.displayValue;
        }
        SFMRecordFieldData * fieldObj = [modelObj.currentRecord objectForKey:targetFieldName];
        if(fieldObj != nil)
        {
            fieldObj.internalValue = mappingValue;
            fieldObj.displayValue = displayValue;
        }
        else
        {
            //add new field
            SFMRecordFieldData * newfield = [[SFMRecordFieldData alloc] init];
            newfield.name = targetFieldName;
            newfield.internalValue = mappingValue;
            newfield.displayValue = displayValue;
            [modelObj.currentRecord setObject:newfield forKey:targetFieldName];
        }
    }
    
}

-( SFMRecordFieldData * )getDisplayValueForLiteral:(NSString *)mappingValue  mappingObject:(ValueMappingModel *)mappingModel
{
    NSMutableDictionary * contextDict = nil;
    NSString *contextObjectName = nil;
    NSString *fieldName = nil;
    NSArray *componentsArray =  [StringUtil splitString:mappingValue byString:@"."];
    if ([componentsArray count] > 2)
    {
        fieldName = [componentsArray objectAtIndex:2];
    }
    if ([StringUtil containsString:kLiteralCurrentRecordHeader inString:mappingValue])
    {
        contextDict = mappingModel.headerRecord;;
        contextObjectName = mappingModel.headerObjectName;
    }
    else
    {
        contextDict = mappingModel.currentRecord;
        contextObjectName = mappingModel.currentObjectName;
    }
    
    SFMRecordFieldData * evaluatedLiteralfield = nil;
    NSString * evaluatedLiteralvalue = nil, * displayValue = nil;;
    if(fieldName != nil && contextDict != nil)
    {
        SFMRecordFieldData * recField = [contextDict objectForKey:fieldName];
        if(recField.internalValue == nil)
        {
            SFMRecordFieldData * field = [contextDict objectForKey:kLocalId];
            evaluatedLiteralvalue =  [self getValueForField:fieldName objectName:contextObjectName recordLocalId:field.internalValue];
            displayValue = evaluatedLiteralvalue;
            if(![StringUtil isStringEmpty:evaluatedLiteralvalue])
            {
                SFObjectFieldModel * objectfieldModel = [self getObjectFieldInfoForField:fieldName objectName:contextObjectName];
                if ([objectfieldModel.type isEqualToString:kSfDTReference]) {
                    displayValue =  [self getDisplayValueForReferenceField:objectfieldModel ForValue:evaluatedLiteralvalue];
                }
            }
        }
        else
        {
            evaluatedLiteralvalue = recField.internalValue;
            displayValue = recField.displayValue;
        }
        
        evaluatedLiteralfield = [[SFMRecordFieldData alloc] initWithFieldName:fieldName value:evaluatedLiteralvalue andDisplayValue:displayValue];
    }
    return  evaluatedLiteralfield;
}

- (NSString *)getValueForField:(NSString *)fieldName objectName:(NSString *)objectName recordLocalId:(NSString *)localId {
    NSString * fieldValue = @"";
    NSMutableDictionary * recordDict = [SFMPageHelper getDataForObject:objectName fields:[NSArray arrayWithObject:fieldName] recordId:localId];
    fieldValue = [recordDict objectForKey:fieldName];
    return fieldValue;
}

-(SFObjectFieldModel *)getObjectFieldInfoForField:(NSString *)field objectName:(NSString *)objectName
{
    id<SFObjectFieldDAO> daoObject = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectField];
    
    NSDictionary * fieldsDict = [daoObject getFieldsInformationFor:[NSArray arrayWithObject:field] objectName:objectName];
    
    return [fieldsDict objectForKey:field];
}

-(NSString * )getDisplayValueForReferenceField:(SFObjectFieldModel *)model ForValue:(NSString *)value
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObject:value forKey:model.fieldName];
    [self updateReferenceFieldDisplayValues:dict andFieldObjectNames:[NSDictionary dictionaryWithObject:model.referenceTo forKey:model.fieldName]];
    NSString * displayValue = [dict objectForKey:model.fieldName];
    if([StringUtil isStringEmpty:displayValue])
    {
        displayValue = value;
    }
    return displayValue;
}

#pragma mark - Save/Cancel

- (BOOL)saveHeaderRecord:(SFMPage *)page {
    /* write update method*/

    BOOL canUpdate = YES;
    self.dataDictionaryAfterModification = page.headerRecord;
    
    NSString *headerSfid = [page getHeaderSalesForceId];
    NSString *modifiedFieldAsJsonString = [self getJsonStringAfterComparisionForObject:page.objectName recordId:page.recordId sfid:headerSfid andSettingsFlag:YES];
    
    //insert json string into modified record table
    
    SFMPageEditHelper *editHelper = [[SFMPageEditHelper alloc] init];
    
    [self updateRecordIfEventObject:page.headerRecord andObjectName:page.objectName andHeaderObjectName:nil];
    
    ModifiedRecordModel * syncRecord = [[ModifiedRecordModel alloc] init];
    syncRecord.recordLocalId = page.recordId;
    syncRecord.objectName = page.objectName;
    syncRecord.timeStamp = [DateUtil getDatabaseStringForDate:[NSDate date]];
    
    BOOL recordUpdatedSuccessFully = NO;
    if (headerSfid.length < 5) {
        
        
        id <TransactionObjectDAO> transObjectService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
        /* Check if record exist */
        BOOL isRecordExist =  [transObjectService isRecordExistsForObject:page.objectName forRecordLocalId:page.recordId];
        if (isRecordExist) {
            
            syncRecord.operation = kModificationTypeUpdate;
            recordUpdatedSuccessFully =  [editHelper updateRecord:page.headerRecord inObjectName:page.objectName andLocalId:page.recordId];
        }
        else{
            syncRecord.operation = kModificationTypeInsert;
            recordUpdatedSuccessFully = [editHelper insertRecord:page.headerRecord intoObjectName:page.objectName];
        }
        
    }
    else {
        syncRecord.operation = kModificationTypeUpdate;
        recordUpdatedSuccessFully =  [editHelper updateRecord:page.headerRecord inObjectName:page.objectName andLocalId:page.recordId];
        
        if (recordUpdatedSuccessFully) {
            SXLogDebug(@"HEADER RECORD UPDATE SUCCESSfully");
        }
    }
    
    syncRecord.recordType = kRecordTypeMaster;
    syncRecord.sfId = headerSfid;
 
    if ([syncRecord.operation isEqualToString:kModificationTypeUpdate]) {
        
        if (modifiedFieldAsJsonString != nil) {
             syncRecord.fieldsModified = modifiedFieldAsJsonString;
        }
        else{
            if (self.isfieldMergeEnabled && ![StringUtil isStringEmpty:headerSfid]) {
                canUpdate = NO;
            }
            
        }
     }
   
    //delete the existing entry form modified record
//    if (!canUpdate) {
//        id <ModifiedRecordsDAO>modifiedRecordService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
//        [modifiedRecordService deleteUpdatedRecordsForRecordLocalId:page.recordId];
//    }
    
    /*after save  make an entry in trailer table*/
    if (recordUpdatedSuccessFully && canUpdate) {
        id <ModifiedRecordsDAO>modifiedRecordService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
        BOOL doesExist =   [modifiedRecordService doesRecordExistForId:page.recordId];
        if (!doesExist) {
            
            if (([syncRecord.operation isEqualToString:kModificationTypeUpdate])
                && ([StringUtil isStringEmpty:syncRecord.sfId])) {
                syncRecord.sfId = [SFMPageEditHelper getSfIdForLocalId:syncRecord.recordLocalId objectName:syncRecord.objectName];
                
                if (syncRecord.sfId.length > 6) {
                    [modifiedRecordService saveRecordModel:syncRecord];
                }
                else{
                    syncRecord.operation = kModificationTypeInsert;
                    [modifiedRecordService saveRecordModel:syncRecord];
                }
            }
            else{
                 [modifiedRecordService saveRecordModel:syncRecord];
            }
        }
        else {
            if (self.isfieldMergeEnabled && modifiedFieldAsJsonString != nil) {
                [modifiedRecordService updateFieldsModifed:syncRecord];
            }
            
        }
        if ([syncRecord.operation isEqualToString:kModificationTypeInsert]) {
            [self addRecentRecordLocalId:page.recordId andObjectName:page.objectName];
        }
        else if ([syncRecord.operation isEqualToString:kModificationTypeUpdate] && ([page.objectName isEqualToString:kEventObject] || [page.objectName isEqualToString:kServicemaxEventObject])) {
            [self checkIfObjectIsEvent:page.objectName];
        }
        
       // NSLog(@"database path: %@",[[DatabaseManager sharedInstance]primaryDatabasePath]);
        
        [self theModifiedRecordsUpdateForCustomWebservice:syncRecord andSFMPage:page];
        [[SuccessiveSyncManager sharedSuccessiveSyncManager]registerForSuccessiveSync:syncRecord withData:page.headerRecord];
        
       // NSString *abc = [modifiedRecordService fetchExistingModifiedFieldsJsonFromModifiedRecordForRecordId:page.recordId];

    }
    return canUpdate;
}

-(void)theModifiedRecordsUpdateForCustomWebservice:(ModifiedRecordModel *) syncRecord andSFMPage:(SFMPage *)sfmpage
{
    if (sfmpage.customWebserviceOptionsArray.count) {
        NSString *requestData = [NSString stringWithFormat:@"%@,%@,%@", sfmpage.objectName, sfmpage.recordId, sfmpage.process.processInfo.sfID];
        syncRecord.requestData = requestData;
        id <ModifiedRecordsDAO>modifiedRecordService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];

        if ([syncRecord.operation isEqualToString:kModificationTypeInsert]) {
            
            if ([sfmpage.customWebserviceOptionsArray containsObject:kModificationTypeAfterInsert]) {
                syncRecord.operation = kModificationTypeAfterInsert;
                
                if (![modifiedRecordService doesRecordExistForId:sfmpage.recordId andOperationType:kModificationTypeAfterInsert] ) {
                    [modifiedRecordService saveRecordModel:syncRecord];

                }
            }
        }
        else{
            
            if ([sfmpage.customWebserviceOptionsArray containsObject:kModificationTypeAfterUpdate]) {
                    syncRecord.operation = kModificationTypeAfterUpdate;
                if (![modifiedRecordService doesRecordExistForId:sfmpage.recordId andOperationType:kModificationTypeAfterUpdate] ) {
                    [modifiedRecordService saveRecordModel:syncRecord];
                }
            }
            if ([sfmpage.customWebserviceOptionsArray containsObject:kModificationTypeBeforeUpdate]) {
                syncRecord.operation = kModificationTypeBeforeUpdate;
                if (![modifiedRecordService doesRecordExistForId:sfmpage.recordId andOperationType:kModificationTypeBeforeUpdate] ) {
                    [modifiedRecordService saveRecordModel:syncRecord];
                    
                }
            }

        }
    }
}
- (BOOL)saveDetailRecords:(SFMPage *)sfmPage {
    
    BOOL isDetailChanged = NO;
    BOOL canUpdate = NO;
    SFMPageEditHelper *editHelper = [[SFMPageEditHelper alloc] init];
    id <ModifiedRecordsDAO>modifiedRecordService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
    
    NSDictionary * processComponents = sfmPage.process.component;
    NSArray * allDetailProcessComponents = [processComponents allKeys];
    for(NSString * processCompId in allDetailProcessComponents)
    {
        NSMutableArray * detailRecordsArray = [sfmPage.detailsRecord objectForKey:processCompId];
        
        
        NSMutableArray * newlyCreatedRecordIds = [sfmPage.newlyCreatedRecordIds objectForKey:processCompId];
        NSMutableArray * deletedRecordIds = [sfmPage.deletedRecordIds objectForKey:processCompId];
        
        
        SFProcessComponentModel * processComponent = [processComponents objectForKey:processCompId];
        
        NSArray *modifiedRecords = [modifiedRecordService getSyncRecordsOfType:kModificationTypeInsert andObjectName:processComponent.objectName];
        
        NSString * parentColumnName = processComponent.parentColumnName;
        NSString * parentSfId =  [sfmPage  getHeaderSalesForceId ];
        for (NSMutableDictionary * eachDetailDict in detailRecordsArray)
        {
            
            self.dataDictionaryAfterModification = eachDetailDict;
            [self updateRecordIfEventObject:eachDetailDict andObjectName:processComponent.objectName andHeaderObjectName:sfmPage.objectName];
            
            SFMRecordFieldData * localIdField = [eachDetailDict objectForKey:kLocalId];
            SFMRecordFieldData * idField = [eachDetailDict objectForKey:kId];
            SFMRecordFieldData * parentField = [eachDetailDict objectForKey:parentColumnName];
            if(parentField != nil && [parentSfId length] > 0)
            {
                parentField.internalValue = parentSfId;
                parentField.displayValue = parentSfId;
            }
            
            NSString *modifiedFieldAsJsonString = [self getJsonStringAfterComparisionForObject:processComponent.objectName recordId:localIdField.internalValue sfid:idField.internalValue andSettingsFlag:YES];
            ModifiedRecordModel * syncRecord = [[ModifiedRecordModel alloc] init];
            syncRecord.recordLocalId = localIdField.internalValue;
            syncRecord.sfId = idField.internalValue;
            syncRecord.objectName = processComponent.objectName;
            syncRecord.recordType = kRecordTypeDetail;
            syncRecord.parentObjectName = sfmPage.objectName;
            syncRecord.parentLocalId = sfmPage.recordId;
            syncRecord.timeStamp = [DateUtil getDatabaseStringForDate:[NSDate date]];
            
            BOOL recordUpdatedSuccessFully = NO;
            
            if([newlyCreatedRecordIds containsObject:localIdField.internalValue])
            {
                //Insert record into object table
                syncRecord.operation = kModificationTypeInsert;
                recordUpdatedSuccessFully = [editHelper insertRecord:eachDetailDict intoObjectName:syncRecord.objectName];
            }
            else{
                //Update record into object table
                //check if entry exists in  trailer table for put_insert for the updating record.
                syncRecord.operation = kModificationTypeUpdate;
                
                /* When locally created record is deleted in the sync, no need to update the record */
                id <TransactionObjectDAO> transObjectService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
                BOOL isRecordExist =  [transObjectService isRecordExistsForObject:processComponent.objectName forRecordLocalId:localIdField.internalValue];
                if(!isRecordExist)
                {
                    [editHelper deleteRecordWithId:localIdField.internalValue fromObjectName:processComponent.objectName];
                    continue;
                }
                
                recordUpdatedSuccessFully =  [editHelper updateRecord:eachDetailDict inObjectName:processComponent.objectName andLocalId:localIdField.internalValue];
                if (recordUpdatedSuccessFully) {
                    SXLogDebug(@"DETAIL RECORD UPDATE SUCCESSfully");
                }
                
            }
            
            canUpdate = YES;
            if ([syncRecord.operation isEqualToString:kModificationTypeUpdate]) {
                
                if (modifiedFieldAsJsonString != nil) {
                    syncRecord.fieldsModified = modifiedFieldAsJsonString;
                }
                else{
                    if (self.isfieldMergeEnabled) {
                        
                        canUpdate = NO;
                    }
                    
                }
            }
            
            if (canUpdate) {
                
                isDetailChanged = YES;
                /*Insert record into trailer table */
                if(![modifiedRecords containsObject:localIdField.internalValue] )
                {
                    /* If sfid is empty , then we will not insert the update to ModifiedRecords table */
                    if([syncRecord.sfId length] < 2  && [syncRecord.operation isEqualToString:kModificationTypeUpdate] )
                    {
                        SXLogWarning(@"SFMPage - No sfid for detail");
                    }
                    else{
                        
                        if([syncRecord.operation isEqualToString:kModificationTypeUpdate]) {
                             BOOL doesExist =   [modifiedRecordService doesRecordExistForId:localIdField.internalValue];
                            if (!doesExist) {
                                BOOL  isRecordInsertionSucces = [modifiedRecordService saveRecordModel:syncRecord];
                            }
                        }
                        else{
                            BOOL  isRecordInsertionSucces = [modifiedRecordService saveRecordModel:syncRecord];
                        }
                    }
                }else{
                    /* If sfid is empty , then we will not insert the update to ModifiedRecords table */
                    if([syncRecord.sfId length] < 2  && [syncRecord.operation isEqualToString:kModificationTypeUpdate] )
                    {
                        SXLogWarning(@"SFMPage - No sfid for detail");
                    }
                    else{
                        [modifiedRecordService updateFieldsModifed:syncRecord];;
                    }
                }
           }
            //else {
//                //delete the existing entry form modified record
//                    id <ModifiedRecordsDAO>modifiedRecordService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
//                    [modifiedRecordService deleteUpdatedRecordsForRecordLocalId:syncRecord.recordLocalId];
//            }
            [self theModifiedRecordsUpdateForCustomWebservice:syncRecord andSFMPage:sfmPage];
            [[SuccessiveSyncManager sharedSuccessiveSyncManager]registerForSuccessiveSync:syncRecord withData:eachDetailDict];
        }
        //delete record
        if([deletedRecordIds count] > 0 )
        {
            
            BOOL canUpdateForDeletedRecords = [self deleteRecordIds:deletedRecordIds forProcessComponent:processComponent];
            // ASC, even if one child line (with SFid) gets deleted, then sync should trigger.
            if (canUpdate == NO) {
                canUpdate = canUpdateForDeletedRecords;
            }
            
            [self deleteRecordIds:deletedRecordIds forProcessComponent:processComponent];
            isDetailChanged = canUpdate;
        }
    }
    
    if (!isDetailChanged) {
        isDetailChanged = sfmPage.isAttachmentEdited;
    }
    
    return isDetailChanged;
}

- (BOOL)deleteRecordIds:(NSArray *)deletedRecordIds
    forProcessComponent:(SFProcessComponentModel *)processComponent {
    
    
    BOOL canUpdate = NO;
    
    NSMutableArray * localIdsList = [[NSMutableArray alloc] init];
    NSMutableArray * sfIdsList = [[NSMutableArray alloc] init];
    
    id <TransactionObjectDAO> transObjectService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    id <ModifiedRecordsDAO>modifiedRecordService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
    
    SFMPageEditHelper *editHelper = [[SFMPageEditHelper alloc] init];
    for (NSString * deletedId in deletedRecordIds)
    {
        BOOL isRecordExist =   [transObjectService doesRecordExistsForObject:processComponent.objectName forRecordId:deletedId];
        
        if(!isRecordExist)
        {   continue;
        }
        
        if([deletedId length] > 30)
        {
            // delete from both trailer and object table
            [localIdsList addObject:deletedId];
            NSString * sfId = [transObjectService getSfIdForLocalId:deletedId forObjectName:processComponent.objectName];
            
            // data sync loop issue - if a record is added and deleted immediately, then successive sync was going in loop..
            if(sfId != nil && sfId.length > 0){
                [sfIdsList addObject:sfId];
            }
        }
        else
        {
            //delete  for SfId
            [sfIdsList addObject:deletedId];
        }
        
    }
    
    if ([sfIdsList count] > 0) {
        
        [editHelper deleteRecordWithIds:sfIdsList fromObjectName:kModifiedRecords andCriteriaFieldName:kSyncRecordSFId];
        [editHelper deleteRecordWithIds:sfIdsList fromObjectName:@"Sync_Records_Heap" andCriteriaFieldName:@"sfId"];
        
        /* Delete from respective table , modified records table and sync heap table */
        [editHelper deleteRecordWithIds:sfIdsList fromObjectName:processComponent.objectName andCriteriaFieldName:kId];
        
        // delete from conflicts table when record is deleted ..
        [editHelper deleteRecordWithIds:sfIdsList fromObjectName:kSyncErrorConflictTableName andCriteriaFieldName:kSyncRecordSFId];
        
        for(NSString * deletedId in sfIdsList)
        {
            ModifiedRecordModel * syncRecord = [[ModifiedRecordModel alloc] init];
            syncRecord.recordLocalId = @"";
            syncRecord.sfId = deletedId;
            syncRecord.objectName = processComponent.objectName;
            syncRecord.recordType = kRecordTypeDetail;
            syncRecord.operation = kModificationTypeDelete;
            syncRecord.timeStamp = [DateUtil getDatabaseStringForDate:[NSDate date]];
            
            BOOL  isRecordInsertionSucces = [modifiedRecordService saveRecordModel:syncRecord];
            if(isRecordInsertionSucces){
                canUpdate = YES; // ASC, even if one child line (with SFid) gets deleted, then sync should trigger.
            }
        }
    }
    
    if ([localIdsList count] > 0) {
        // delete local ids
        [editHelper deleteRecordWithIds:localIdsList fromObjectName:kModifiedRecords andCriteriaFieldName:kSyncRecordLocalId];
        [editHelper deleteRecordWithIds:localIdsList fromObjectName:@"Sync_Records_Heap" andCriteriaFieldName:@"localId"];
        [editHelper deleteRecordWithIds:localIdsList fromObjectName:processComponent.objectName andCriteriaFieldName:kLocalId];
        
        // delete from conflicts table when record is deleted ..
        [editHelper deleteRecordWithIds:localIdsList fromObjectName:kSyncErrorConflictTableName andCriteriaFieldName:kLocalId];
    }
    
    return canUpdate;
}


#pragma mark End

- (NSString*)getBoolValueForInternalValue:(NSString*)internalValue
{
    NSString *boolValue;
    if ([StringUtil isItTrue:internalValue]) {
        boolValue = kTrue;
    }else{
        boolValue = kFalse;
    }
    return boolValue;
}


#pragma  mark - Field Mapping
- (NSMutableDictionary *)getFieldMappingDetails:(NSDictionary *)processComponent
{
    NSMutableDictionary *mappingDict = nil;
    
    for (NSString *componentId in processComponent) {
        SFProcessComponentModel *component = [processComponent objectForKey:componentId];
        
        NSArray *mapppingArray = [SFMPageEditHelper getFieldMappingDataForMappingId:component.objectMappingId];
        
        if (mappingDict == nil) {
            mappingDict = [NSMutableDictionary new];
        }
        if ([mapppingArray count] > 0) {
            [mappingDict setObject:mapppingArray forKey:component.sfId];
        }
    }
    return mappingDict;
}

- (void)applyFieldMapping:(NSArray *)fieldMappings
                forRecord:(NSMutableDictionary *)recordDcitionary
      andSourceDictionary:(NSDictionary *)sourceDcitionary
               objectname:(NSString *)objectName
      currentHeaderRecord:(NSDictionary *)currentHeaderData
{
    NSDictionary *fieldinfo = [self getFieldInForObject:objectName];
    
    for (SFObjectMappingComponentModel *model in fieldMappings) {
        
        NSString *fieldValue = nil;
        if (model.sourceFieldName.length < 1) {
            //Check for currentrecord literal
            if ([StringUtil containsString:kLiteralCurrentRecord inString:model.mappingValue]) {
                if (currentHeaderData == nil) {
                    currentHeaderData = recordDcitionary;
                }
                fieldValue = [self getCurrentRecordValue:currentHeaderData targetRecord:recordDcitionary
                                            mappingValue:model.mappingValue];
            }
            else {
                //Checking for literals
                NSString *type = [fieldinfo objectForKeyedSubscript:model.targetFieldName];
                NSString *lietralvalue = [self getLiteralValue:model.mappingValue forType:type];
                if (![StringUtil isStringEmpty:lietralvalue]) {
                    fieldValue = lietralvalue;
                }
                else {
                    fieldValue = model.mappingValue;
                }
            }
        }
        else {
            fieldValue = [sourceDcitionary objectForKey:model.sourceFieldName];
            if ([model.sourceFieldName isEqualToString:kId] && fieldValue.length < 5) {
                fieldValue =  [sourceDcitionary objectForKey:kLocalId];
            }
            if ([fieldValue isKindOfClass:[NSNumber class]]) {
                NSNumber *number = (NSNumber *)fieldValue;
                fieldValue = [number stringValue];
            }
            
            if (fieldValue.length <= 0) {
                if (![StringUtil isStringEmpty:model.preference2]) {
                    fieldValue = [sourceDcitionary objectForKey:model.preference2];
                    if (fieldValue.length <= 0 && ![StringUtil isStringEmpty:model.preference3]) {
                        fieldValue = [sourceDcitionary objectForKey:model.preference3];
                    }
                }
            }
        }
        if (model.targetFieldName != nil) {
            if ([fieldValue isKindOfClass:[NSNumber class]]) {
                NSNumber *number = (NSNumber *)fieldValue;
                fieldValue = [number stringValue];
            }
            
            SFMRecordFieldData *recordData = [recordDcitionary objectForKey:model.targetFieldName];
            if (recordData == nil) {
                recordData = [[SFMRecordFieldData alloc] initWithFieldName:model.targetFieldName value:fieldValue andDisplayValue:fieldValue];
                [recordDcitionary setObject:recordData forKey:model.targetFieldName];
            }
            else{
                recordData.internalValue = fieldValue;
                recordData.displayValue = fieldValue;
            }
        }
    }
}

- (NSString *)getLiteralValue:(NSString *)literal forType:(NSString *)type
{
    NSString *value = nil;
    
    if ([literal length] > 0) {
        
        if ([type isEqualToString:kSfDTDateTime] || [type isEqualToString:kSfDTDate]) {
            value = [DateUtil evaluateDateLiteral:literal  dataType:type];
            if ([type isEqualToString:kSfDTDate] && [value length] > 10) {
                value = [self  getDateForMapping:value];
            }
        }
        else if ([type isEqualToString:kSfDTBoolean]) {
            value = [SFMPageHelper valueOfLiteral:literal dataType:type];
        }
        else {
            value = [SFMPageHelper valueOfLiteral:literal dataType:type];
        }
    }
    return value;
}

- (NSString *)getCurrentRecordValue:(NSDictionary *)headerRecord
                       targetRecord:(NSDictionary *)targetRecord
                       mappingValue:(NSString *)mappingValue
{
    NSDictionary * currentDict = nil ;
    NSString *fieldName = nil;
    NSArray *componentsArray =  [StringUtil splitString:mappingValue byString:@"."];
    
    if ([componentsArray count] > 2) {
        fieldName = [componentsArray objectAtIndex:2];
    }
    if ([StringUtil containsString:kLiteralCurrentRecordHeader inString:mappingValue]){
        currentDict = headerRecord;
    }
    else{
        currentDict = targetRecord;
    }
    if(fieldName != nil && currentDict != nil) {
        SFMRecordFieldData * recField = [currentDict objectForKey:fieldName];
        return recField.internalValue;
    }
    return nil;
}

- (NSString *)getDateForMapping:(NSString *)dateTime
{
    return [self getDateForValueMapping:dateTime];
}
#pragma mark - End

#pragma mark - Source To Target
- (void)fillUpSfmPageForSourceToTargetProcess:(SFMPage *)sfPage
{
    NSString *uniqueId = [AppManager generateUniqueId];
    if ([uniqueId length] > 0) {
        sfPage.recordId = uniqueId;
    }
    
    if (self.processId != nil) {
        sfPage.process = [super sfmProcessForPage];
    }
    
    if (sfPage.objectName == nil) {
        sfPage.objectName = [SFMPageEditHelper getObjectNameForProcessId:self.processId];
    }
    
    NSString *objectLabel = [SFMPageEditHelper getObjectLabelForObjectName:sfPage.objectName];
    if ([objectLabel length] > 0) {
        sfPage.objectLabel = objectLabel;
    }
    
    NSMutableDictionary *fieldMappping = [self getFieldMappingDetails:sfPage.process.component];
    
    if (fieldMappping != nil) {
        sfPage.process.fieldMappingData = fieldMappping;
    }
    
    NSMutableDictionary *headerDict = [self getHeaderRecordForSourceToTarge:sfPage];
    
    if (headerDict != nil) {
        sfPage.headerRecord = headerDict;
    }
    
    NSMutableDictionary *detailRecord = [self getDetailRecordForSourceToTarget:sfPage];
    
    if (detailRecord != nil) {
        sfPage.detailsRecord = detailRecord;
    }
    [self valueMapping:sfPage];
    
    [self loadSourceUpdateMetaData:sfPage];
    [self fillLinkedProcessForDetailLine:sfPage];
}

- (NSMutableDictionary *)getHeaderRecordForSourceToTarge:(SFMPage *)sfpage
{
    NSMutableDictionary *headerDataDict = [NSMutableDictionary new];
    
    NSArray *headerFields = [sfpage.process.pageLayout getAllHeaderLayoutFields];
    
    for (SFMPageField *pageField in headerFields) {
        
        SFMRecordFieldData *recordData = [[SFMRecordFieldData alloc] initWithFieldName:pageField.fieldName value:nil andDisplayValue:nil];
        [headerDataDict setObject:recordData forKey:pageField.fieldName];
    }
    SFMRecordFieldData *recordData = [[SFMRecordFieldData alloc] initWithFieldName:kLocalId value:sfpage.recordId andDisplayValue:sfpage.recordId];
    [headerDataDict setObject:recordData forKey:klocalId];
    
    SFProcessComponentModel *componemtModel = [sfpage.process getProcessComponentOfType:kTarget];
    
    NSArray *fieldMapping = nil;
    
    if ([sfpage.process.fieldMappingData count] > 0) {
        
        fieldMapping = [sfpage.process.fieldMappingData objectForKey:componemtModel.sfId];
        
        NSDictionary *fieldinfo = [self getFieldInForObject:sfpage.sourceObjectName];
        
        NSMutableDictionary *sourceDataDict = [SFMPageHelper getDataForObject:sfpage.sourceObjectName
                                                                       fields:[fieldinfo allKeys]
                                                                     recordId:sfpage.sourceRecordId];
        if ([sourceDataDict count] > 0) {
            [self applyFieldMapping:fieldMapping forRecord:headerDataDict
                andSourceDictionary:sourceDataDict
                         objectname:sfpage.objectName currentHeaderRecord:nil];
            [self updateRecordTypeField:headerDataDict objectName:sfpage.objectName];
        }
    }
    
    if ([sfpage.objectName isEqualToString:kEventObject] || [sfpage.objectName isEqualToString:kServicemaxEventObject]) {
        [self updateObjectNameForWhatId:componemtModel.objectName mappingArray:fieldMapping
                             headerdata:headerDataDict andSourceObject:sfpage.sourceObjectName];
    }
    
    NSDictionary *fieldDataTypeMap =[super getFieldDataTypeMap:headerFields];
    
    [self updateDisplayValueForRecord:headerDataDict pageFields:headerFields];
    
    [self updatePicklistAndRecorTypeData:headerDataDict andFieldDataTypeMap:fieldDataTypeMap];
    
    //Add Entry For SOurceUpdate
    [self addSourceUpdateRecordForCompId:componemtModel.sfId sourcerecordId:sfpage.sourceRecordId targetRecordId:sfpage.recordId sfmPage:sfpage];
    
    
    return headerDataDict;
}

- (NSMutableDictionary *)getDetailRecordForSourceToTarget:(SFMPage *)sfpage
{
    NSString *headerSfId = [SFMPageEditHelper getSfIdForLocalId:sfpage.sourceRecordId objectName:sfpage.sourceObjectName];
    
    NSMutableDictionary *detailRecordDict = [NSMutableDictionary new];
    NSMutableDictionary *newLycreatedIds = [NSMutableDictionary new];
    
    NSMutableDictionary *processComp = sfpage.process.component;
    
    for (NSString *componentId in processComp) {
        
        SFProcessComponentModel *component = [processComp objectForKey:componentId];
        
        if ([component.componentType isEqualToString:kTargetChild]) {
            
            SFProcessComponentModel *soureceComponent = nil;
            
            if (![StringUtil isStringEmpty:component.parentObjectId]) {
                soureceComponent = [processComp objectForKey:component.parentObjectId];
            }
            SFMDetailFieldData *detailParam = [[SFMDetailFieldData alloc] init];
            detailParam.objectName = soureceComponent.objectName;
            detailParam.parentColumnName = soureceComponent.parentColumnName;
            detailParam.parentLocalId = sfpage.sourceRecordId;
            detailParam.parentSfID = headerSfId;
            detailParam.sourceToTargetType = sfpage.process.processInfo.processType;

            if (![StringUtil isStringEmpty:component.expressionId]) {
                SFExpressionParser *expressionParser = [[SFExpressionParser alloc] initWithExpressionId:component.expressionId objectName:detailParam.objectName];
                
                detailParam.criteriaObjects = [NSMutableArray arrayWithArray:[expressionParser expressionCriteriaObjects]];
                
                detailParam.expression = [expressionParser advanceExpression];
            }
            
            NSArray *detailArray = [self getSourceToTargetDetailData:detailParam];
            
            if ([detailArray count] > 0) {
                
                NSArray *pageFields = [sfpage.process.pageLayout
                                       getPageFieldsForDetailLayoutComponent:component.sfId];
                
                
                NSArray *detailRecords = [self creteNewChildLines:detailArray forProcessComponents:component withPageFields:pageFields andSfPage:sfpage];
                
                NSMutableArray *createdLocalIds = [self getAllLocalIdsforRecods:detailRecords];
                
                if (detailRecords != nil) {
                    [detailRecordDict setObject:detailRecords forKey:component.sfId];
                    [newLycreatedIds setObject:createdLocalIds forKey:component.sfId];
                }
            }
        }
    }
    sfpage.newlyCreatedRecordIds = newLycreatedIds;
    
    return detailRecordDict;
}

- (NSArray *)getSourceToTargetDetailData:(SFMDetailFieldData *)dataParam
{
    NSDictionary *fieldinfo = [self getFieldInForObject:dataParam.objectName];
    dataParam.fieldsArray = [fieldinfo allKeys];
    
    NSArray *detailRecrdss = [SFMPageHelper getDetialsRecord:dataParam];
    
    return detailRecrdss;
}

- (NSArray *)creteNewChildLines:(NSArray *)parentRecods
           forProcessComponents:(SFProcessComponentModel *)processComponent
                 withPageFields:(NSArray *)pageFields
                      andSfPage:(SFMPage *)sfPage
{
    
    NSMutableArray *newDetailRecords = [NSMutableArray new];
    
    for (NSDictionary *sourceData in parentRecods) {
        
        NSMutableDictionary *dataDict = [NSMutableDictionary new];
        
        NSString *localId = [AppManager generateUniqueId];
        SFMRecordFieldData *recordData = [[SFMRecordFieldData alloc] initWithFieldName:klocalId
                                                                                 value:localId
                                                                       andDisplayValue:localId];
        [dataDict setObject:recordData forKey:klocalId];
        
        
        if (processComponent.parentColumnName != nil) {
            SFMRecordFieldData *recordData = [[SFMRecordFieldData alloc]
                                              initWithFieldName:processComponent.parentColumnName
                                              value:sfPage.recordId
                                              andDisplayValue:sfPage.recordId];
            [dataDict setObject:recordData forKey:processComponent.parentColumnName];
        }
        
        NSArray *mappingInfo = [sfPage.process.fieldMappingData objectForKey:processComponent.sfId];
        
        [self applyFieldMapping:mappingInfo forRecord:dataDict andSourceDictionary:sourceData
                     objectname:processComponent.objectName currentHeaderRecord:sfPage.headerRecord];
        [self updateRecordTypeField:dataDict objectName:processComponent.objectName];
        
        NSDictionary *fieldDataTypeMap =[super getFieldDataTypeMap:pageFields];
        
        [self updateDisplayValueForRecord:dataDict pageFields:pageFields];
        [self updatePicklistAndRecorTypeData:dataDict andFieldDataTypeMap:fieldDataTypeMap];
        
        if ([processComponent.objectName isEqualToString:kEventObject] || [processComponent.objectName isEqualToString:kServicemaxEventObject]) {
            [self updateObjectNameForWhatId:processComponent.objectName mappingArray:mappingInfo
                                 headerdata:dataDict andSourceObject:processComponent.sourceObjectName];
        }
        
        [self updatePageFields:dataDict forFields:pageFields];
        
        [newDetailRecords addObject:dataDict];
        
        //Add Entry For SOurceUpdate
        NSString * sourceLocalId = [sourceData objectForKey:kLocalId];
        [self addSourceUpdateRecordForCompId:processComponent.sfId sourcerecordId:sourceLocalId targetRecordId:localId sfmPage:sfPage];
        
    }
    return newDetailRecords;
}

-(void)addSourceUpdateRecordForCompId:(NSString *)compId
                       sourcerecordId:(NSString *)sourceRecordId
                       targetRecordId:(NSString *)targetRecordId
                              sfmPage:(SFMPage *)sfmPage
{
    
    if(sourceRecordId == nil || targetRecordId == nil){
        return;
    }
    if (sfmPage.sourceTargetRecordMap == nil) {
        sfmPage.sourceTargetRecordMap = [[NSMutableDictionary alloc] init];
    }
    NSMutableDictionary * dict = [sfmPage.sourceTargetRecordMap  objectForKey:compId];
    if(dict == nil){
        dict = [[NSMutableDictionary alloc] init];
        [sfmPage.sourceTargetRecordMap setObject:dict forKey:(compId != nil)?compId:@""];
    }
    [dict setObject:sourceRecordId forKey:targetRecordId];
}


- (void)updatePageFields:(NSMutableDictionary *)dataDict forFields:(NSArray *)pageFields
{
    for (SFMPageField *aPageField in pageFields) {
        
        SFMRecordFieldData *recordData  = [dataDict objectForKey:aPageField.fieldName];
        if (recordData == nil) {
            recordData = [[SFMRecordFieldData alloc] initWithFieldName:aPageField.fieldName
                                                                 value:nil andDisplayValue:nil];
            [dataDict setObject:recordData forKey:aPageField.fieldName];
        }
    }
}

- (NSMutableArray *)getAllLocalIdsforRecods:(NSArray *)detailRecods
{
    NSMutableArray *createdLocalIds = [NSMutableArray new];
    
    for (NSDictionary *dataDict in detailRecods) {
        
        SFMRecordFieldData *model = [dataDict objectForKey:klocalId];
        if (model.internalValue != nil) {
            [createdLocalIds addObject:model.internalValue];
        }
    }
    return createdLocalIds;
}

- (void)updateRecordTypeField:(NSDictionary *)headerDict objectName:(NSString *)objectName
{
    NSDictionary *recordTypeInfo = [SFMPageEditHelper getRecordTypeDataByName:objectName];
    SFMRecordFieldData *recordData = [headerDict objectForKey:kSfDTRecordTypeId];
    
    if (recordData.internalValue != nil) {
        SFRecordTypeModel *recordType = [recordTypeInfo objectForKey:recordData.internalValue];
        if ([recordType.recordTypeId length] > 0) {
            recordData.internalValue = recordType.recordTypeId;
            recordData.displayValue = recordType.recordTypeId;
        }
    }
}

- (void)updateDisplayValueForRecord:(NSMutableDictionary *)headerDict pageFields:(NSArray *)fields
{
    NSMutableDictionary *fieldNameAndInternalValue = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *fieldNameAndObjectApiName = [[NSMutableDictionary alloc] init];
    
    for (SFMPageField *aPageField in fields) {
        
        SFMRecordFieldData *recordData = [headerDict objectForKey:aPageField.fieldName];
        
        if ([aPageField.dataType isEqualToString:kSfDTReference]) {
            if (![StringUtil isStringEmpty:recordData.internalValue]) {
                [fieldNameAndInternalValue setObject:recordData.internalValue forKey:aPageField.fieldName];
                if (aPageField.relatedObjectName != nil) {
                    [fieldNameAndObjectApiName setObject:aPageField.relatedObjectName forKey:aPageField.fieldName];
                }
            }
        }
        else if ([aPageField.dataType isEqualToString:kSfDTDateTime]) {
            if (![StringUtil isStringEmpty:recordData.internalValue]) {
                NSString *dateTime = [self getUserReadableDateTime:recordData.internalValue];
                if (dateTime != nil) {
                    recordData.displayValue = dateTime;
                }
            }
        }
        else if ([aPageField.dataType isEqualToString:kSfDTDate]) {
            if (![StringUtil isStringEmpty:recordData.internalValue]) {
                NSString *dateString = [self getUserReadableDate:recordData.internalValue];
                if (dateString != nil) {
                    recordData.displayValue = dateString;
                }
            }
        }
    }
    if ([fieldNameAndInternalValue count] > 0) {
        
        [super updateReferenceFieldDisplayValues:fieldNameAndInternalValue andFieldObjectNames:fieldNameAndObjectApiName];
        for (NSString *fieldName in fieldNameAndObjectApiName) {
            SFMRecordFieldData *fieldData = [headerDict objectForKey:fieldName];
            NSString *displayValue = [fieldNameAndInternalValue objectForKey:fieldName];
            if (displayValue != nil && ![displayValue isEqualToString:@""]) {
                fieldData.displayValue = displayValue;
            }
        }
    }
}

- (NSDictionary *)getFieldInForObject:(NSString *)objectName
{
    return [SFMPageEditHelper getObjectFieldInfoByType:objectName];
}

- (void)updatePicklistAndRecorTypeData:(NSMutableDictionary *)headerDict
                   andFieldDataTypeMap:(NSDictionary *)dataTypeMap
{
    
    NSMutableArray *picklists = [dataTypeMap objectForKey:kSfDTPicklist];
    NSMutableArray *multiPicklists = [dataTypeMap objectForKey:kSfDTMultiPicklist];
    
    [super updatePicklistDisplayValues:headerDict picklistFields:picklists multiPicklistFields:multiPicklists];
    [super updateRecordTypeDisplayValue:headerDict];
    
    [super resetPicklistAndRecordTypeData];
}

- (void)updateObjectNameForWhatId:(NSString *)targetObject
                     mappingArray:(NSArray *)mappingData
                       headerdata:(NSMutableDictionary *)headerData
                  andSourceObject:(NSString *)srcObjectName

{
    if ([targetObject isEqualToString:kEventObject] || [targetObject isEqualToString:kServicemaxEventObject]) {
        NSString *whatId = kWhatId;
        if ([targetObject isEqualToString:kServicemaxEventObject]) {
            whatId = kSVMXWhatId;
        }
        SFMRecordFieldData *recordData = [headerData objectForKey:whatId];
        if ([recordData.internalValue length] < 30) {
            return;
        }
        for (SFObjectMappingComponentModel *objectMapping in mappingData ) {
            
            if([objectMapping.targetFieldName isEqualToString:whatId]
               && objectMapping.sourceFieldName.length > 0){
                
                NSString *whatIdObjectName = nil;
                if ([objectMapping.sourceFieldName isEqualToString:kId]) {
                    whatIdObjectName = srcObjectName;
                }
                else {
                    whatIdObjectName = [SFMPageEditHelper getReferenceNameForObject:srcObjectName fieldName:objectMapping.sourceFieldName];
                }
                if (whatIdObjectName.length > 3) {
                    [PlistManager storeObjectName:whatIdObjectName forId:recordData.internalValue];
                }
            }
        }
    }
}
#pragma mark - End

#pragma mark - Source To Targer Child
- (void)fillUpSfmPageForSourceToTargetChildProcess:(SFMPage *)sfPage
{
    if (self.processId != nil) {
        sfPage.process = [super sfmProcessForPage];
    }
    
    NSString *objectLabel = [SFMPageEditHelper getObjectLabelForObjectName:sfPage.objectName];
    if ([objectLabel length] > 0) {
        sfPage.objectLabel = objectLabel;
    }
    
    NSMutableDictionary *headerData = [super getHeaderRecordForSFMPage:sfPage];
    
    if (headerData != nil){
        sfPage.headerRecord = headerData;
    }
    
    NSMutableDictionary *fieldMappping = [self getFieldMappingDetails:sfPage.process.component];
    
    if (fieldMappping != nil) {
        sfPage.process.fieldMappingData = fieldMappping;
    }
    sfPage.sourceObjectName = sfPage.objectName;
    sfPage.sourceRecordId = sfPage.recordId;
    
    NSMutableDictionary *detailData = [self getDetailRecordForSourceToTarget:sfPage];
    
    if (detailData != nil) {
        sfPage.detailsRecord = detailData;
    }
    [self valueMapping:sfPage];
    
    [self loadSourceUpdateMetaData:sfPage];
    [self fillLinkedProcessForDetailLine:sfPage];
}

#pragma mark - End


#pragma mark - Stand alone create process loading

- (void)fillDataForStandAloneCreateProcesSFPage:(SFMPage *)sfPage {
    
    NSString *uniqueId = [AppManager generateUniqueId];
    if ([uniqueId length] > 0) {
        sfPage.recordId = uniqueId;
    }
    
    if (sfPage.objectName == nil) {
        sfPage.objectName = [SFMPageEditHelper getObjectNameForProcessId:self.processId];
    }
    
    /* Load process */
    if (self.processId != nil) {
        sfPage.process = [super sfmProcessForPage];
    }
    
    NSString *objectLabel = [SFMPageEditHelper getObjectLabelForObjectName:sfPage.objectName];
    if ([objectLabel length] > 0) {
        sfPage.objectLabel = objectLabel;
    }
    
    /* Load meta data for the value mapping*/
    [self fillUpValueMappingMetaData:sfPage];
    [self fillUpDisplayValuesForValueMapping:sfPage];
    
    
    
    /* Create header dictionary */
    NSMutableDictionary *headerDictionary = [[NSMutableDictionary alloc] init];
    SFMRecordFieldData  *recordField = [[SFMRecordFieldData alloc] initWithFieldName:kLocalId value:sfPage.recordId andDisplayValue:sfPage.recordId];
    [headerDictionary setObject:recordField forKey:kLocalId];
    
    NSArray *allFields = [sfPage.process.pageLayout.headerLayout getAllHeaderLayoutFields];
    for (SFMPageField *pageField in allFields) {
        NSString *fieldName = pageField.fieldName;
        if (fieldName != nil) {
            recordField  = [[SFMRecordFieldData alloc] initWithFieldName:fieldName value:nil andDisplayValue:nil];
            [headerDictionary setObject:recordField forKey:fieldName];
        }
    }
    sfPage.headerRecord = headerDictionary;
    
    /* Apply value mapping on header record*/
    [self applyValueMapping:sfPage];
}

- (void)updateRecordIfEventObject:(NSMutableDictionary *)recordDictionary
                    andObjectName:(NSString *)objectName
              andHeaderObjectName:(NSString *)headerObjectName {
    
    if ([objectName isEqualToString:kEventObject] ||[objectName isEqualToString:kServicemaxEventObject] ) {
       
        if ([objectName isEqualToString:kServicemaxEventObject]) {
            [self updateRecordIfSVMXEventObject:recordDictionary andObjectName:objectName andHeaderObjectName:headerObjectName];
        } else {
            SFMRecordFieldData *activityDateField = [recordDictionary objectForKey:@"ActivityDateTime"];
            
            if (activityDateField == nil) {
                activityDateField = [[SFMRecordFieldData alloc] initWithFieldName:@"ActivityDateTime" value:nil andDisplayValue:nil];
                [recordDictionary setObject:activityDateField forKey:@"ActivityDateTime"];
            }
            
            SFMRecordFieldData *startDateField = [recordDictionary objectForKey:@"StartDateTime"];
            activityDateField.internalValue = startDateField.internalValue;
            
            SFMRecordFieldData *activityDateFieldOnly = [recordDictionary objectForKey:@"ActivityDate"];
            
            if (activityDateFieldOnly == nil &&  ![StringUtil isStringEmpty:startDateField.internalValue]) {
                
                NSString *theActivityDate = [NSString stringWithFormat:@"%@", activityDateField.internalValue];
                
                long startPosition = [theActivityDate rangeOfString:@"T"].location;
                
                theActivityDate = [theActivityDate substringToIndex:startPosition];
                
                activityDateFieldOnly = [[SFMRecordFieldData alloc] initWithFieldName:@"ActivityDate" value:nil andDisplayValue:nil];
                [recordDictionary setObject:activityDateFieldOnly forKey:@"ActivityDate"];
                activityDateFieldOnly.internalValue = theActivityDate;
            }
            
            
            SFMRecordFieldData *durationField = [recordDictionary objectForKey:@"DurationInMinutes"];
            if (durationField == nil) {
                durationField = [[SFMRecordFieldData alloc] initWithFieldName:@"DurationInMinutes" value:nil andDisplayValue:nil];
                [recordDictionary setObject:durationField forKey:@"DurationInMinutes"];
            }
            //durationField.internalValue = @"0";
            
            SFMRecordFieldData *ownerId = [recordDictionary objectForKey:@"OwnerId"];
            
            if (ownerId == nil) {
                ownerId = [[SFMRecordFieldData alloc] initWithFieldName:@"OwnerId" value:nil andDisplayValue:nil];
                ownerId.internalValue = [SFMPageHelper getUserId];;
                [recordDictionary setObject:ownerId forKey:@"OwnerId"];
            }
            
            
            if (headerObjectName != nil) {
                SFMRecordFieldData *eventRecordFieldModel = [recordDictionary objectForKey:kWhatId];
                if ([eventRecordFieldModel.internalValue length] > 30) {
                    [PlistManager storeObjectName:headerObjectName forId:eventRecordFieldModel.internalValue];
                    
                }
            }
        }
    }
}


- (void)updateRecordIfSVMXEventObject:(NSMutableDictionary *)recordDictionary
                    andObjectName:(NSString *)objectName
              andHeaderObjectName:(NSString *)headerObjectName {
    
    if (![objectName isEqualToString:kServicemaxEventObject]) {
        return;
    }
    SFMRecordFieldData *activityDateField = [recordDictionary objectForKey:kSVMXActivityDateTime];
    
    if (activityDateField == nil) {
        activityDateField = [[SFMRecordFieldData alloc] initWithFieldName:kSVMXActivityDateTime value:nil andDisplayValue:nil];
        [recordDictionary setObject:activityDateField forKey:kSVMXActivityDateTime];
    }
    
    SFMRecordFieldData *startDateField = [recordDictionary objectForKey:kSVMXStartDateTime];
    activityDateField.internalValue = startDateField.internalValue;
    
    SFMRecordFieldData *activityDateFieldOnly = [recordDictionary objectForKey:kSVMXActivityDate];
    
    if (activityDateFieldOnly == nil &&  ![StringUtil isStringEmpty:startDateField.internalValue]) {
        
        NSString *theActivityDate = [NSString stringWithFormat:@"%@", activityDateField.internalValue];
        
        long startPosition = [theActivityDate rangeOfString:@"T"].location;
        
        theActivityDate = [theActivityDate substringToIndex:startPosition];
        
        activityDateFieldOnly = [[SFMRecordFieldData alloc] initWithFieldName:kSVMXActivityDate value:nil andDisplayValue:nil];
        [recordDictionary setObject:activityDateFieldOnly forKey:kSVMXActivityDate];
        activityDateFieldOnly.internalValue = theActivityDate;
    }
    
    
    SFMRecordFieldData *durationField = [recordDictionary objectForKey:kSVMXDurationInMinutes];
    if (durationField == nil) {
        durationField = [[SFMRecordFieldData alloc] initWithFieldName:kSVMXDurationInMinutes value:nil andDisplayValue:nil];
        [recordDictionary setObject:durationField forKey:kSVMXDurationInMinutes];
    }

    SFMRecordFieldData *whatId = [recordDictionary objectForKey:kSVMXWhatId];
    if (whatId.internalValue) {
        SFMRecordFieldData *objectSfId = [[SFMRecordFieldData alloc] initWithFieldName:kObjectSfId value:whatId.internalValue andDisplayValue:whatId.internalValue];
        [recordDictionary setObject:objectSfId forKey:kObjectSfId];
    }
    
    //durationField.internalValue = @"0";
    
    SFMRecordFieldData *ownerId = [recordDictionary objectForKey:@"OwnerId"];
    
    if (ownerId == nil) {
        ownerId = [[SFMRecordFieldData alloc] initWithFieldName:@"OwnerId" value:nil andDisplayValue:nil];
        ownerId.internalValue = [SFMPageHelper getUserId];;
        [recordDictionary setObject:ownerId forKey:@"OwnerId"];
    }
    
    SFMRecordFieldData *technicianId = [recordDictionary objectForKey:ORG_NAME_SPACE@"__Technician__c"];
    
    if (technicianId == nil) {
        technicianId = [[SFMRecordFieldData alloc] initWithFieldName:ORG_NAME_SPACE@"__Technician__c" value:nil andDisplayValue:nil];
        technicianId.internalValue =  [PlistManager getTechnicianId];
        NSLog(@"technician Id : %@ ",[SFMPageHelper getTechnicianIdForOwnerId:[SFMPageHelper getUserId]]);//[SFMPageHelper getTechnicianIdForOwnerId:[SFMPageHelper getUserId]];
        [recordDictionary setObject:technicianId forKey:ORG_NAME_SPACE@"__Technician__c"];
    }
    
    if (headerObjectName != nil) {
        SFMRecordFieldData *eventRecordFieldModel = [recordDictionary objectForKey:kSVMXWhatId];
        if ([eventRecordFieldModel.internalValue length] > 30) {
            [PlistManager storeObjectName:headerObjectName forId:eventRecordFieldModel.internalValue];
            
        }
    }
}

#pragma mark - End


#pragma makr - Added new recent record

- (void)addRecentRecordLocalId:(NSString *)localId andObjectName:(NSString *)objectName {
    
    RecentModel *recentmodel = [[RecentModel alloc] initWithObjectName:objectName andRecordId:localId];
    RecentDaoService *recents = [[RecentDaoService alloc] init];
    [recents saveRecentRecord:recentmodel];
    
    [self checkIfObjectIsEvent:objectName];
}

-(void)checkIfObjectIsEvent:(NSString *)objectName
{
    if ([objectName isEqualToString:kEventObject] || [objectName isEqualToString:kServicemaxEventObject]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_DISPLAY_RESET object:nil];
    }
}

#pragma mark - Source Update
-(void)loadSourceUpdateMetaData:(SFMPage *)page
{
    id <SourceUpdateDAO> sourceUpdateDao =  [FactoryDAO serviceByServiceType:ServiceTypeSourceUpdate];
    page.process.sourceObjectUpdate = [sourceUpdateDao getSourceUpdateRecordsforProcessId:page.process.processInfo.sfID];
    
}

-(void)performSourceUpdate:(SFMPage *)sfmPage
{
    NSDictionary * sourceUpdateConfig = sfmPage.process.sourceObjectUpdate;
    NSArray * allComponents = [sourceUpdateConfig allKeys];
    
    for (NSString * eachcomponetId in allComponents) {
        SFProcessComponentModel * componetModel = [sfmPage.process.component objectForKey:eachcomponetId];
        
        if([componetModel.componentType isEqualToString:kTarget])
        {
            [self applySourceUpdateForTargetrecord:[NSArray arrayWithObject:sfmPage.headerRecord]  componetId:eachcomponetId sfmPage:sfmPage];
        }
        else if ([componetModel.componentType isEqualToString:kTargetChild])
        {
            NSMutableArray * detailRecordsArray = [sfmPage.detailsRecord objectForKey:eachcomponetId];
            [self applySourceUpdateForTargetrecord:detailRecordsArray  componetId:eachcomponetId sfmPage:sfmPage];
        }
    }
    
}

-(void)applySourceUpdateForTargetrecord:(NSArray *)targetRecords
                             componetId:(NSString *)componetId
                                sfmPage:(SFMPage *)sfmPage
{
    
    SFProcessComponentModel * targetComponetModel = [sfmPage.process.component objectForKey:componetId];
    NSDictionary * eachS2TRecordMap = [sfmPage.sourceTargetRecordMap objectForKey:componetId];
    NSArray * sourceUpdateConfig = [sfmPage.process.sourceObjectUpdate objectForKey:componetId];
    SFProcessComponentModel *sourceComponent = [sfmPage.process.component objectForKey:targetComponetModel.parentObjectId];
    
    NSArray * fieldsArray = [self getFieldsArrayForSourceUpdate:sourceUpdateConfig];
    NSDictionary * targetRecordsDict = [self getTargetRecordsDictFromTagetRecordsArray:targetRecords];
    NSMutableDictionary *sourceRecordsDict = [self getSourceRecordsForObjectName:sourceComponent.objectName fieldsArray:fieldsArray criteriaRecords:[eachS2TRecordMap allValues]];
    
    
    DataTypeUtility * dataTypeUtil = [[DataTypeUtility alloc] init];
    NSDictionary *fieldDataType = [dataTypeUtil fieldDataType:sourceComponent.objectName];
    
    for (NSString * targetRecordId in [targetRecordsDict allKeys]) {
        
        NSString * sourceRecordId = [eachS2TRecordMap objectForKey:targetRecordId];
        NSDictionary * eachTargetDict = [targetRecordsDict objectForKey:targetRecordId];
        NSMutableDictionary * eachSourcedDict = [sourceRecordsDict objectForKey:sourceRecordId];
        
        for (SFSourceUpdateModel * model in sourceUpdateConfig) {
            
            NSString * finalValue = nil;
            
            if(![StringUtil isStringEmpty:model.targetFieldName]){
                
                SFMRecordFieldData * recordField = [eachTargetDict objectForKey:model.targetFieldName];
                
                finalValue = recordField.internalValue;
            }
            else{
                finalValue = model.displayValue;
            }
            
            if([model.action isEqualToString:@"Set"]){
                
                if([StringUtil isStringEmpty:finalValue]){
                    continue;
                }
                NSString * fieldType =  [fieldDataType objectForKey: model.sourceFieldName];
                
                if([fieldType isEqualToString:kSfDTDate] || [fieldType isEqualToString:kSfDTDateTime])
                {
                    finalValue = [DateUtil evaluateDateLiteral:finalValue  dataType:fieldType];
                    if ([fieldType isEqualToString:kSfDTDate]) {
                        finalValue = [self getDateForMapping:finalValue];
                    }
                }
                else if ([StringUtil containsString:kLiteralCurrentRecord inString:finalValue])
                {
                    finalValue = [self evaluateCurrentRecordLiteralForSourceUpdate:sfmPage.headerRecord
                                                                      targetRecord:eachTargetDict
                                                                      mappingValue:finalValue headerObjectName:sfmPage.objectName];
                }
                else
                {
                    NSString * valueOfLiteral = [SFMPageEditHelper valueOfLiteral:finalValue dataType:fieldType ];
                    if(valueOfLiteral == nil)
                    {
                        valueOfLiteral = finalValue;
                    }
                }
            }
            else if ([model.action isEqualToString:@"Increase"]){
                NSString * sourceFieldValue  = [eachSourcedDict objectForKey: model.sourceFieldName];
                float finalFloatValue = [finalValue floatValue] + [sourceFieldValue floatValue];
                finalValue = [[NSString alloc] initWithFormat:@"%f",finalFloatValue];
            }
            else if([model.action isEqualToString:@"Decrease"]){
                NSString * sourceFieldValue  = [eachSourcedDict objectForKey: model.sourceFieldName];
                float finalFloatValue = [sourceFieldValue floatValue] - [finalValue floatValue];
                finalValue = [[NSString alloc] initWithFormat:@"%f",finalFloatValue];
            }
            
            if(![StringUtil isStringEmpty:finalValue] && model.sourceFieldName){
                [eachSourcedDict setObject:finalValue forKey:model.sourceFieldName];
            }
        }
    }
    
    
    if([sourceComponent.componentType isEqualToString:@"SOURCE"]){
        [self makeEntryInModifiedRecordsForSourceRecords:sourceRecordsDict sourceObject:sourceComponent.objectName recordType:kRecordTypeMaster];
    }
    else   if([sourceComponent.componentType isEqualToString:@"SOURCECHILD"])
    {
        [self makeEntryInModifiedRecordsForSourceRecords:sourceRecordsDict sourceObject:sourceComponent.objectName recordType:kRecordTypeDetail];
    }
}


-(void)makeEntryInModifiedRecordsForSourceRecords:(NSDictionary *)sourceRecords sourceObject:(NSString *)objectName recordType:(NSString *)recordType
{
    for (NSString * localId in [sourceRecords allKeys] ) {
        
        NSDictionary *finalDict = [sourceRecords objectForKey:localId];
        NSString * sfId = [finalDict objectForKey:kId];
        
        SFMPageEditHelper *editHelper = [[SFMPageEditHelper alloc] init];
        
        ModifiedRecordModel * syncRecord = [[ModifiedRecordModel alloc] init];
        syncRecord.recordLocalId = localId;
        syncRecord.objectName = objectName;
        syncRecord.timeStamp = [DateUtil getDatabaseStringForDate:[NSDate date]];
        
        BOOL recordUpdatedSuccessFully = NO;
        
        id <TransactionObjectDAO> transObjectService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
        /* Check if record exist */
        BOOL isRecordExist =  [transObjectService isRecordExistsForObject:objectName forRecordLocalId:localId];
        if (isRecordExist) {
            
            syncRecord.operation = kModificationTypeUpdate;
            recordUpdatedSuccessFully = [editHelper updateFinalRecord:finalDict inObjectName:objectName andLocalId:localId];
        }
        syncRecord.recordType = recordType;//kRecordTypeMaster;
        syncRecord.sfId = sfId;
        
        /*after save  make an entry in trailer table*/
        if (recordUpdatedSuccessFully) {
            id <ModifiedRecordsDAO>modifiedRecordService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
            BOOL doesExist =   [modifiedRecordService doesRecordExistForId:localId];
            if (!doesExist) {
                [modifiedRecordService saveRecordModel:syncRecord];
            }
            [[SuccessiveSyncManager sharedSuccessiveSyncManager] registerForSuccessiveSync:syncRecord withData:finalDict];
        }
    }
}

-(NSDictionary *)getTargetRecordsDictFromTagetRecordsArray:(NSArray *)targetRecords
{
    NSMutableDictionary * targetRecordsDict = [[NSMutableDictionary alloc] init];
    
    for (NSDictionary * targetDict in targetRecords) {
        SFMRecordFieldData * localId = [targetDict objectForKey:kLocalId];
        [targetRecordsDict setObject:targetDict forKey:localId.internalValue];
    }
    return targetRecordsDict;
}
-(NSMutableDictionary *)getSourceRecordsForObjectName:(NSString *)sourceObjName fieldsArray:(NSArray *)fieldsArray criteriaRecords:(NSArray *)criteriaRecords
{
    
    NSMutableDictionary *sourceRecordsDict = [[NSMutableDictionary alloc] init];
    
    DBCriteria * criteria = [[DBCriteria alloc] initWithFieldName:kLocalId operatorType:SQLOperatorIn andFieldValues:criteriaRecords];
    
    id <TransactionObjectDAO> transactionObject = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    NSArray * sourceRecords = [transactionObject fetchDataForObjectForSfmPage:sourceObjName fields:fieldsArray expression:@" 1 " criteria:[NSArray arrayWithObject:criteria]];
    
    for ( TransactionObjectModel * objectModel in sourceRecords) {
        NSMutableDictionary * sourceDict = [objectModel getFieldValueMutableDictionary];
        NSString * localId = [sourceDict objectForKey:kLocalId];
        [sourceRecordsDict setObject:sourceDict forKey:localId];
    }
    return sourceRecordsDict;
    
}

-(NSArray *)getFieldsArrayForSourceUpdate:(NSArray *)sourceUpdateConfig
{
    NSMutableArray * fieldsArray = [[NSMutableArray alloc] init];
    for (SFSourceUpdateModel * sourceUpdateModel in sourceUpdateConfig) {
        NSString *sourcefieldName =  sourceUpdateModel.sourceFieldName;
        if(sourcefieldName!= nil)
        {
            [fieldsArray addObject:sourcefieldName];
        }
    }
    [fieldsArray addObject:kLocalId];
    [fieldsArray addObject:kId];
    return fieldsArray;
}

-(NSString *)evaluateCurrentRecordLiteralForSourceUpdate:(NSDictionary *)headerRecord
                                            targetRecord:(NSDictionary *)targetRecord
                                            mappingValue:(NSString *)mappingValue
                                        headerObjectName:(NSString *)headerObjName
{
    NSDictionary * contextDict = nil ;
    NSString *fieldName = nil, *contextObjName = nil;
    NSArray *componentsArray =  [StringUtil splitString:mappingValue byString:@"."];
    if ([componentsArray count] > 2)
    {
        fieldName = [componentsArray objectAtIndex:2];
    }
    if ([StringUtil containsString:kLiteralCurrentRecordHeader inString:mappingValue]){
        contextDict = headerRecord;
        contextObjName = headerObjName;
    }
    else{
        contextDict = targetRecord;
        contextObjName = nil;
    }
    
    if(fieldName != nil && contextDict != nil)
    {
        NSString * finalValue = nil;
        SFMRecordFieldData * recField = [contextDict objectForKey:fieldName];
        if(recField.internalValue == nil && contextObjName != nil)
        {
            SFMRecordFieldData * localIdfield = [contextDict objectForKey:kLocalId];
            finalValue =  [self getValueForField:fieldName objectName:contextObjName recordLocalId:localIdfield.internalValue];
        }
        else
        {
            finalValue = recField.internalValue;
        }
        return finalValue;
    }
    return nil;
}

#pragma mark - End

#pragma maek - Linked SFM
- (void)fillLinkedProcessForDetailLine:(SFMPage *)sfmPage
{
    NSArray *detailLayouts = sfmPage.process.pageLayout.detailLayouts;
    
    for (SFMDetailLayout *layout in detailLayouts) {
        NSArray *linkedProcess = [self getLinkedSFProcessForDetail:layout processId:sfmPage.process.processInfo.sfID];
        if (linkedProcess != nil) {
            layout.linkedProcess = linkedProcess;
        }
    }
}

- (NSArray *)getLinkedSFProcessForDetail:(SFMDetailLayout *)detailLayout
                               processId:(NSString *)procesId
{
    NSMutableArray *dataArray = [NSMutableArray new];
    
    NSArray *processIds = [SFMPageEditHelper getLinkedProcessIdsForDetail:procesId
                                                              componentId:detailLayout.processComponentId];
    NSDictionary *processInfo = [self getProcessInFoForProcessIds:processIds];
    
    for (NSString *sfId in processIds) {
        SFProcessModel *process = [processInfo objectForKey:sfId];
        LinkedProcess *model = [[LinkedProcess alloc] initWithProcessId:sfId
                                                                   name:process.processName
                                                                   type:process.processType];
        [dataArray addObject:model];
    }
    return dataArray;
}

- (NSDictionary *)getProcessInFoForProcessIds:(NSArray *)processSfId
{
    return [SFMPageEditHelper getProcessNameForProcessId:processSfId];
}
#pragma mark - END

#pragma mark - Form fill apply


- (void)applyFormFillSettingOfHeaderPageField:(SFMPageField*)pageField
                              withRecordField:(SFMRecordFieldData *)selctedRecordField
                                       sfPage:(SFMPage *)sfmPage {
    
    /* Load form fill settings */
    NSArray *mapppingArray = [SFMPageEditHelper getFieldMappingDataForMappingId:pageField.fieldMappingId];
    if ([mapppingArray count] > 0) {
        
        /* Get source dictionary */
        NSMutableDictionary *headerDictionary = sfmPage.headerRecord;
        NSDictionary *sourceDataDict = [SFMPageEditHelper getAllDataForObject:pageField.relatedObjectName andRecordId:selctedRecordField.internalValue];
        
        [self applyFieldMapping:mapppingArray forRecord:headerDictionary
            andSourceDictionary:sourceDataDict
                     objectname:sfmPage.objectName
            currentHeaderRecord:nil];
        
        /* Set preferences */
        /* Go through the mapping and handle picklist, multipicklist, record type , reference and date/date time */
        NSString *objectName = sfmPage.objectName;
        NSMutableDictionary *recordDictionary = headerDictionary;
        NSArray *pageFields = [sfmPage.process.pageLayout.headerLayout getAllHeaderLayoutFields];
        
        [self fillFormForRecord:recordDictionary pageFields:pageFields objectName:objectName mappingArray:mapppingArray andRecordField:selctedRecordField];
    }
}

- (void)applyFormFillOnChildRecordOfIndexPath:(NSIndexPath *)selectedIndexPath
                                       sfpage:(SFMPage *)sfpage
                                withPageField:(SFMPageField *)pageField
                             andselectedIndex:(SFMRecordFieldData *)selctedRecordField {
    
    /* Load form fill settings */
    SFMDetailLayout * layout = [sfpage.process.pageLayout.detailLayouts
                                objectAtIndex:selectedIndexPath.section];
    NSMutableDictionary * recordDictionary = nil;
    NSMutableDictionary * detailDict =  sfpage.detailsRecord;
    
    NSArray * detailRecords = [detailDict objectForKey: layout.processComponentId];
    if ([detailRecords count] > selectedIndexPath.row) {
        recordDictionary = [detailRecords objectAtIndex:selectedIndexPath.row];
        
    }
    
    
    
    NSString *objectName = layout.objectName;
    NSArray *pageFields = layout.detailSectionFields;
    NSArray *mapppingArray = [SFMPageEditHelper getFieldMappingDataForMappingId:pageField.fieldMappingId];
    if ([mapppingArray count] > 0) {
        NSDictionary *sourceDataDict = [SFMPageEditHelper getAllDataForObject:pageField.relatedObjectName andRecordId:selctedRecordField.internalValue];
        [self applyFieldMapping:mapppingArray forRecord:recordDictionary andSourceDictionary:sourceDataDict objectname:objectName currentHeaderRecord:sfpage.headerRecord];
        
        [self fillFormForRecord:recordDictionary pageFields:pageFields objectName:objectName mappingArray:mapppingArray andRecordField:selctedRecordField];
        
    }
    
}

- (void)fillFormForRecord:(NSDictionary *)recordDictionary
               pageFields:(NSArray *)pageFields
               objectName:(NSString *)objectName
             mappingArray:(NSArray *)mapppingArray
           andRecordField:(SFMRecordFieldData *)selctedRecordField{
    
    NSDictionary *fieldinfo = [self getFieldInForObject:objectName];
    
    NSMutableDictionary *fieldNameAndObjectApiName = [[NSMutableDictionary alloc] init];
    for (SFMPageField *pageField in pageFields) {
        if (pageField.relatedObjectName.length > 0) {
            [fieldNameAndObjectApiName setObject:pageField.relatedObjectName forKey:pageField.fieldName];
        }
    }
    NSMutableDictionary *fieldNameAndInternalValue = [[NSMutableDictionary alloc] init];
    
    for (SFObjectMappingComponentModel *model in mapppingArray) {
        
        
        if (model.targetFieldName != nil) {
            SFMRecordFieldData *fieldData = [recordDictionary objectForKey:model.targetFieldName];
            NSString *dataType = [fieldinfo objectForKey:model.targetFieldName ];
            NSString *internalValue = fieldData.internalValue;
            if (fieldData.internalValue.length <= 0) {
                continue;
            }
            
            if ([dataType isEqualToString:kSfDTReference]) {
                
                if ([model.targetFieldName isEqualToString:kSfDTRecordTypeId]) {
                    SFRecordTypeModel *model =  [SFMPageEditHelper getRecordTypeobjectForIdOrName:internalValue andObjectName:objectName];
                    
                    fieldData.internalValue = model.recordTypeId;
                    fieldData.displayValue = model.recordtypeLabel;
                }
                else {
                    if ([selctedRecordField.name isEqualToString:model.targetFieldName]) {
                        fieldData.internalValue = selctedRecordField.internalValue;
                        fieldData.displayValue = selctedRecordField.displayValue;
                        
                    }
                    else{
                        [fieldNameAndInternalValue setObject:internalValue forKey:model.targetFieldName];
                    }
                    
                }
            }
            else if ([dataType isEqualToString:kSfDTPicklist]) {
                
                SFPicklistModel *picklistData = [SFMPageEditHelper getPickListLabelFor:internalValue withFieldName:model.targetFieldName andObjectName:objectName];
                if (picklistData.label.length > 0) {
                    fieldData.displayValue = picklistData.label;
                }
                
            }
            else if ([dataType isEqualToString:kSfDTMultiPicklist]) {
                
        
                NSArray *allComponents = [SFMPageHelper getAllValuesFromMultiPicklistString:internalValue];
                if ([allComponents count] > 0) {
                    
                    NSDictionary *picklistValueDictionary = [SFMPageEditHelper getPicklistLabelsFor:allComponents withFieldName:model.targetFieldName andObjectName:objectName];
                    if ([picklistValueDictionary count] > 0) {
                        NSString *displayString = [SFMPageEditHelper getMutliPicklistLabelForpicklistString:allComponents andFieldLabelDictionary:picklistValueDictionary];
                        fieldData.displayValue = displayString;
                    }
                }
            }
            else if ([dataType isEqualToString:kSfDTDateTime] || [dataType isEqualToString:kSfDTDate]) {
                if (![StringUtil isStringEmpty:internalValue]) {
                    
                    NSString *dateTime = ([dataType isEqualToString:kSfDTDate])?[self getUserReadableDate:internalValue]:[self getUserReadableDateTime:internalValue];
                    if (dateTime != nil) {
                        fieldData.displayValue = dateTime;
                    }
                }
            }
        }
    }
    if ([fieldNameAndInternalValue count] > 0)
    {
        [self updateReferenceFieldDisplayValues:fieldNameAndInternalValue andFieldObjectNames:fieldNameAndObjectApiName];
        for (NSString *fieldName in fieldNameAndObjectApiName) {
            SFMRecordFieldData *fieldData = [recordDictionary objectForKey:fieldName];
            NSString *displayValue = [fieldNameAndInternalValue objectForKey:fieldName];
            if (displayValue != nil && ![displayValue isEqualToString:@""]) {
                fieldData.displayValue = displayValue;
            }
        }
    }
}
#pragma mark End

#pragma mark - advanced sync conflict

- (NSString*)getJsonStringAfterComparisionForObject:(NSString*)objectName recordId:(NSString*)recordId sfid:(NSString*)sfid andSettingsFlag:(BOOL)isSave
{
    if(isSave)
    {
        MobileDeviceSettingService *mobileDeviceSettingService = [[MobileDeviceSettingService alloc]init];
        MobileDeviceSettingsModel *mobDeviceSettings = [mobileDeviceSettingService fetchDataForSettingId:@"IPAD018_SET016"];
        self.isfieldMergeEnabled = [StringUtil isItTrue:mobDeviceSettings.value];
    }
    else
    {
        self.isfieldMergeEnabled = YES;
    }
   
    if (!self.isfieldMergeEnabled)
    {
        // Woo Field Level merge is not anabled. Lets go back.
        SXLogInfo(@"Skipping modified fields data - comparison since it feature not anabled");
        return nil;
    }
    
    //NSString *headerSfid = [page getHeaderSalesForceId];
    
    FieldMergeHelper *fieldMergeHelper = [[FieldMergeHelper alloc]init];
    self.dataDictionaryBeforeModification = [NSMutableDictionary dictionaryWithDictionary:[fieldMergeHelper getDataDictionaryBeforeModificationFromTable:objectName withLocalId:recordId fieldNames:[self.dataDictionaryAfterModification allKeys]]];
    
    if ((sfid == nil) && (recordId != nil))
    {
        // It is new record whcih is not sync.
        return nil;    //To handle offline records which is unsynced
    }
    
    if (self.dataDictionaryBeforeModification == nil)
    {
        // It is new record whcih is not sync.
        if ((sfid == nil) && (recordId != nil))
        {
           // self.foundNonFieldMergeChanges = YES;
            SXLogInfo(@"Eligible for updation but Not Advance Sync Conflict - since it is unsynced record ");
        }
        else
        {
            SXLogInfo(@"Skipping modified fields data - comparison since unavailable before modification data");
        }
        
        return nil;
    }
    
    id <ModifiedRecordsDAO>modifiedRecordService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
    // If there are earlier changes in trailor table fetch them also.. will use for merging
    NSString *existingModifiedFields = [modifiedRecordService fetchExistingModifiedFieldsJsonFromModifiedRecordForRecordId:recordId andSfId:sfid];
    
    SyncErrorConflictService *conflictService = [[SyncErrorConflictService alloc]init];
    
    BOOL hasConflictRecordFound = NO;
    
    if (existingModifiedFields == nil || ([existingModifiedFields length] < 1))
    {
        hasConflictRecordFound = [conflictService isConflictFoundForObject:objectName withSfId:sfid];
        
        if (hasConflictRecordFound)
        {
            // Found conflict mark on existing records. Lets consider conflict record as previous change
            existingModifiedFields = [conflictService fetchExistingModifiedFieldsJsonFromConflictTableForRecordId:recordId];
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
        existingDataBeforeModificationDictionary = [jsonDictionary objectForKey:@"BEFORE_SAVE"];
        existingDataAfterModificationDictionary  = [jsonDictionary objectForKey:@"AFTER_SAVE"];
        
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
                    [self.dataDictionaryBeforeModification setObject:oldValue
                                                         forKey:newKey];
                }
            }
            
            if ([self.dataDictionaryAfterModification objectForKey:newKey] == nil)
            {
                NSString *oldValue = [existingDataAfterModificationDictionary objectForKey:newKey];
                
                if (oldValue != nil)
                {
                    SFMRecordFieldData *recordFieldData = [[SFMRecordFieldData alloc]init];
                    recordFieldData.internalValue = oldValue;
                    recordFieldData.name          = newKey;
                    [self.dataDictionaryAfterModification setObject:recordFieldData
                                                        forKey:newKey];
                }
            }
        }
        
        fields = nil;
        
        existingDataBeforeModificationDictionary = self.dataDictionaryBeforeModification;
    }
    
    if (existingDataBeforeModificationDictionary == nil)
    {
      //  existingDataBeforeModificationDictionary = [self dataDictionaryBeforeModification];
    }
    
    NSString *modifedFieldAsJsonString = [fieldMergeHelper getJsonAfterComparingDictOne:self.dataDictionaryBeforeModification withDataAfterModification:self.dataDictionaryAfterModification andOldModificationDict:oldDataAfterModificationDictionary];
    
    NSString *currentModifiedFields = [modifiedRecordService fetchExistingModifiedFieldsJsonFromModifiedRecordForRecordId:recordId andSfId:sfid];

    if (![StringUtil isStringEmpty:currentModifiedFields] && [modifedFieldAsJsonString isEqualToString:currentModifiedFields]) {
        modifedFieldAsJsonString = nil;
    }
    
    return modifedFieldAsJsonString;
}



- (NSString*)getJsonStringAfterComparisionForObject:(NSString*)objectName recordId:(NSString*)recordId andSfid:(NSString*)sfid
{
    MobileDeviceSettingService *mobileDeviceSettingService = [[MobileDeviceSettingService alloc]init];
    MobileDeviceSettingsModel *mobDeviceSettings = [mobileDeviceSettingService fetchDataForSettingId:@"IPAD018_SET016"];
    self.isfieldMergeEnabled = [StringUtil isItTrue:mobDeviceSettings.value];
    
    if (!self.isfieldMergeEnabled)
    {
        // Woo Field Level merge is not anabled. Lets go back.
        NSLog(@"Skipping modified fields data - comparison since it feature not anabled");
        return nil;
    }
    
    //NSString *headerSfid = [page getHeaderSalesForceId];
    
    FieldMergeHelper *fieldMergeHelper = [[FieldMergeHelper alloc]init];
    self.dataDictionaryBeforeModification = [NSMutableDictionary dictionaryWithDictionary:[fieldMergeHelper getDataDictionaryBeforeModificationFromTable:objectName withLocalId:recordId fieldNames:[self.dataDictionaryAfterModification allKeys]]];
    
    if ((sfid == nil) && (recordId != nil))
    {
        // It is new record whcih is not sync.
        return nil;    //To handle offline records which is unsynced
    }
    
    if (self.dataDictionaryBeforeModification == nil)
    {
        // It is new record whcih is not sync.
        if ((sfid == nil) && (recordId != nil))
        {
            // self.foundNonFieldMergeChanges = YES;
            NSLog(@"Eligible for updation but Not Advance Sync Conflict - since it is unsynced record ");
        }
        else
        {
            NSLog(@"Skipping modified fields data - comparison since unavailable before modification data");
        }
        
        return nil;
    }
    
    id <ModifiedRecordsDAO>modifiedRecordService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
    // If there are earlier changes in trailor table fetch them also.. will use for merging
    NSString *existingModifiedFields = [modifiedRecordService fetchExistingModifiedFieldsJsonFromModifiedRecordForRecordId:recordId andSfId:sfid];
    
    SyncErrorConflictService *conflictService = [[SyncErrorConflictService alloc]init];
    
    BOOL hasConflictRecordFound = NO;
    
    if (existingModifiedFields == nil || ([existingModifiedFields length] < 1))
    {
        hasConflictRecordFound = [conflictService isConflictFoundForObject:objectName withSfId:sfid];
        
        if (hasConflictRecordFound)
        {
            // Found conflict mark on existing records. Lets consider conflict record as previous change
            existingModifiedFields = [conflictService fetchExistingModifiedFieldsJsonFromConflictTableForRecordId:recordId];
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
        existingDataBeforeModificationDictionary = [jsonDictionary objectForKey:@"BEFORE_SAVE"];
        existingDataAfterModificationDictionary  = [jsonDictionary objectForKey:@"AFTER_SAVE"];
        
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
                    [self.dataDictionaryBeforeModification setObject:oldValue
                                                              forKey:newKey];
                }
            }
            
            if ([self.dataDictionaryAfterModification objectForKey:newKey] == nil)
            {
                NSString *oldValue = [existingDataAfterModificationDictionary objectForKey:newKey];
                
                if (oldValue != nil)
                {
                    SFMRecordFieldData *recordFieldData = [[SFMRecordFieldData alloc]init];
                    recordFieldData.internalValue = oldValue;
                    recordFieldData.name          = newKey;
                    [self.dataDictionaryAfterModification setObject:recordFieldData
                                                             forKey:newKey];
                }
            }
        }
        
        fields = nil;
        
        existingDataBeforeModificationDictionary = self.dataDictionaryBeforeModification;
    }
    
    if (existingDataBeforeModificationDictionary == nil)
    {
        //  existingDataBeforeModificationDictionary = [self dataDictionaryBeforeModification];
    }
    
    NSString *modifedFieldAsJsonString = [fieldMergeHelper getJsonAfterComparingDictOne:self.dataDictionaryBeforeModification withDataAfterModification:self.dataDictionaryAfterModification andOldModificationDict:oldDataAfterModificationDictionary];
    
    return modifedFieldAsJsonString;
}

#pragma mark end


#pragma mark - Field update rules

-(BOOL)executeFieldUpdateRulesOnload:(SFMPage *)sfmPage andView:(UIView *)aView andDelegate:(id)aDelegate forEvent:(NSString *)event {
    BOOL fieldUpdateRuleExists = NO;
    self.ruleManager = [[FieldUpdateRuleManager alloc] initWithProcessId:self.processId sfmPage:sfmPage];
    self.ruleManager.eventType = event;
    self.ruleManager.parentView = aView;
    self.ruleManager.delegate = aDelegate;
    fieldUpdateRuleExists = [self.ruleManager executeFieldUpdateRules];
    return fieldUpdateRuleExists;
}

//Fix for 019057
-(void)updateSFMPageWithFieldUpdateResponse:(NSString *)response andSFMPage:(SFMPage *)sfmPage {
    NSDictionary *tempDict = (NSDictionary *)[Utility objectFromJsonString:response];
    NSDictionary *responseDict = [tempDict objectForKey:@"response"];
    NSArray *allKeys = [responseDict allKeys];
    NSDictionary *headerRecord = sfmPage.headerRecord;
    NSArray *detailLayouts = sfmPage.process.pageLayout.detailLayouts;
    SFMHeaderLayout *headerLayouts = sfmPage.process.pageLayout.headerLayout;
    NSDictionary *detailRecordsDict = sfmPage.detailsRecord;
    for (NSString *key in allKeys) {
        if ([key isEqualToString:@"details"]) {
            NSDictionary *detailsDict = [responseDict objectForKey:@"details"];
            NSArray *detailIds = [detailsDict allKeys];
            for (NSString *detailId in detailIds) {
                NSArray *pageLayoutArray = [detailLayouts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"pageLayoutId = [c] %@", detailId]];
                if ([pageLayoutArray count] == 1) {
                    SFMDetailLayout *detailLayout = [pageLayoutArray lastObject];
                    NSString *processComponentId = detailLayout.processComponentId;
                    NSArray *detailRecords = [detailRecordsDict objectForKey:processComponentId];
                    NSDictionary *responseDetail = [detailsDict objectForKey:detailId];
                    NSArray *responseLines = [responseDetail objectForKey:@"lines"];
                    
                    for (int i = 0; i < [responseLines count]; i++) {
                        NSDictionary *lineRecord = [responseLines objectAtIndex:i];
                        NSDictionary *sfmRecord = [detailRecords objectAtIndex:i];
                            for (SFMPageField *pageField in [detailLayout detailSectionFields])
                            {
                                NSString *fieldName = pageField.fieldName;
                            
                              //for (fieldName in lineRecord) {
                            //key is SFMPageField
                            SFMRecordFieldData *recordField = [sfmRecord objectForKey:fieldName];
                            id internalValue = [lineRecord objectForKey:fieldName];
                            id displayValue = [lineRecord objectForKey:fieldName];
                            if (![internalValue isKindOfClass:[NSString class]])
                            {
                                internalValue = [NSString stringWithFormat:@"%@",internalValue];
                                displayValue = [NSString stringWithFormat:@"%@",displayValue];
                            }
                                
                                if ([pageField.dataType isEqualToString:kSfDTDate])
                                {
                                    if (![StringUtil isStringEmpty:recordField.internalValue])
                                    {
                                       displayValue = [self getUserReadableDate:internalValue];
                                    }
                                    recordField.internalValue = internalValue;
                                    recordField.displayValue = displayValue;
                                    
                                }
                                else if([pageField.dataType isEqualToString:kSfDTDateTime])
                                {
                                    if (![StringUtil isStringEmpty:recordField.internalValue])
                                    {
                                        displayValue = [self getUserReadableDateTime:internalValue];

                                    }
                                    
                                    recordField.internalValue = internalValue;
                                    recordField.displayValue = displayValue;
                                }
                                else if([pageField.dataType isEqualToString:kSfDTReference])
                                {
                                    recordField.displayValue = displayValue;
                                }
                                else
                                {
                                    recordField.internalValue = internalValue;
                                    recordField.displayValue = displayValue;
                                }
                         
                           }
                        
                      }
                }
            }
        }
        else {
            if (!([key isEqualToString:@"Id"] || [key isEqualToString:@"localId"])) {
                
                for (SFMHeaderSection *headerSection in headerLayouts.sections)
                {
                    for (SFMPageField *sfmPageField in headerSection.sectionFields)
                    {
                        NSString *fieldName = sfmPageField.fieldName;
                        
//                        if ([sfmPageField.fieldName isEqualToString:key])
//                        {
                            SFMRecordFieldData *recordField = [headerRecord objectForKey:fieldName];
                            
                            id internalValue = [responseDict objectForKey:fieldName];
                            id displayValue = [responseDict objectForKey:fieldName];
                            
                            if (![internalValue isKindOfClass:[NSString class]])
                            {
                                internalValue = [NSString stringWithFormat:@"%@",internalValue];
                                displayValue = [NSString stringWithFormat:@"%@",displayValue];
                            }
                            
                            if ([sfmPageField.dataType isEqualToString:kSfDTDate])
                            {
                                if (![StringUtil isStringEmpty:recordField.internalValue])
                                {
                                   displayValue = [self getUserReadableDate:internalValue];
                                }
                                recordField.internalValue = internalValue;
                                recordField.displayValue = displayValue;
                                
                            }
                            else if([sfmPageField.dataType isEqualToString:kSfDTDateTime])
                            {
                                if (![StringUtil isStringEmpty:recordField.internalValue])
                                {
                                   displayValue = [self getUserReadableDateTime:internalValue];
                                }
                                
                                recordField.internalValue = internalValue;
                                recordField.displayValue = displayValue;
                            }
                            else if([sfmPageField.dataType isEqualToString:kSfDTReference])
                            {
                                recordField.displayValue = displayValue;
                            }
                            else
                            {
                                recordField.internalValue = internalValue;
                                recordField.displayValue = displayValue;
                            }
                            
                            
                        //}
                    }
                }
                
            }
        }
    }
}



@end
