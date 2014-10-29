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

@interface SFMPageEditManager ()

@property (nonatomic, strong)NSMutableDictionary *pickListInfo;
@property (nonatomic, strong)NSString *pickListObjectName;

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
    
    if (([StringUtil isItTrue:pageField.isDependentPicklist]) && (controllerPageField !=nil))
    {
        //Here we can check if recordField.value = @"", then load complet set
        if ([StringUtil isStringEmpty:recordField.internalValue])
        {
            if ([recordTypeDepList count]!=0)
            {
                //Returning complet set of DependentPicklist if there is nothing selected in Controlling Field
                return recordTypeDepList;
            }
            else
                return pickList;
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
        return [self.editViewControllerDelegate getPageFieldForField:fieldName];
    }
    return nil;
}

- (SFMRecordFieldData *)getRecordDataForField:(NSString *)fieldName
{
    if ([self.editViewControllerDelegate respondsToSelector:@selector(getRecordDataForField:)]) {
        return [self.editViewControllerDelegate getRecordDataForField:fieldName];
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
        
            SFMRecordFieldData * recordField = [[SFMRecordFieldData alloc] initWithFieldName: mappingModel.targetFieldName value:mappingModel.mappingValue andDisplayValue:mappingModel.mappingValue];
            
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

/*- (void)fillUpFieldMappingMetaData:(SFMPage *)sfmPage {
    NSDictionary * componentsArray =  sfmPage.process.component;
    
    NSMutableDictionary * fieldMappingDict = nil;
    
    for (NSString * componentId in componentsArray) {
        
        SFProcessComponentModel * componentModel= [sfmPage.process.component objectForKey:componentId];
        
        id <SFObjectMappingComponentDAO> mappingDao = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectMappingComponent];
        NSMutableArray * mappingArray =  [mappingDao getObjectMappingDictForMappingId:componentModel.objectMappingId ];
        
        if( fieldMappingDict == nil)
        {
            fieldMappingDict = [[NSMutableDictionary alloc] init];
        }
        [fieldMappingDict setObject:mappingArray forKey:componentId];
    }
    
    sfmPage.process.fieldMappingDict = fieldMappingDict;
}*/

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
                if([recordTypeModel.recordtypeLabel isEqualToString:mappingValue])
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
                    recordfield.internalValue = [internalValue substringToIndex:10];
                }
                displayValue = [self getUserReadableDate:recordfield.internalValue];
                
            }
            else
            {
                displayValue = [self getUserReadableDateTime:internalValue];;
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
            if(literalField != nil)
            {
                mappingValue = literalField.internalValue;
                displayValue = literalField.displayValue;
            }
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

- (void)saveHeaderRecord:(SFMPage *)page {
    /* write update method*/
    
    SFMPageEditHelper *editHelper = [[SFMPageEditHelper alloc] init];
    NSString *headerSfid = [page getHeaderSalesForceId];
    
    ModifiedRecordModel * syncRecord = [[ModifiedRecordModel alloc] init];
    syncRecord.recordLocalId = page.recordId;
    syncRecord.objectName = page.objectName;
    
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
            NSLog(@"HEADER RECORD UPDATE SUCCESSfully");
        }
    }
    
    syncRecord.recordType = kRecordTypeMaster;
    syncRecord.sfId = headerSfid;
    
    /*after save  make an entry in trailer table*/
    if (recordUpdatedSuccessFully) {
         id <ModifiedRecordsDAO>modifiedRecordService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
        BOOL doesExist =   [modifiedRecordService doesRecordExistForId:page.recordId];
         if (!doesExist) {
              [modifiedRecordService saveRecordModel:syncRecord];
         }
    }
}

- (void)saveDetailRecords:(SFMPage *)sfmPage {
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
            
            SFMRecordFieldData * localIdField = [eachDetailDict objectForKey:kLocalId];
            SFMRecordFieldData * idField = [eachDetailDict objectForKey:kId];
            SFMRecordFieldData * parentField = [eachDetailDict objectForKey:parentColumnName];
            if(parentField != nil && [parentSfId length] > 0)
            {
                parentField.internalValue = parentSfId;
                parentField.displayValue = parentSfId;
            }
            ModifiedRecordModel * syncRecord = [[ModifiedRecordModel alloc] init];
            syncRecord.recordLocalId = localIdField.internalValue;
            syncRecord.sfId = idField.internalValue;
            syncRecord.objectName = processComponent.objectName;
            syncRecord.recordType = kRecordTypeDetail;
            syncRecord.parentObjectName = sfmPage.objectName;
            syncRecord.parentLocalId = sfmPage.recordId;
            
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
                    NSLog(@"DETAIL RECORD UPDATE SUCCESSfully");
                }
                
            }
            
             /*Insert record into trailer table */
            if(![modifiedRecords containsObject:localIdField.internalValue] )
            {
                /* If sfid is empty , then we will not insert the update to ModifiedRecords table */
                if([syncRecord.sfId length] < 2  && [syncRecord.operation isEqualToString:kModificationTypeUpdate] )
                {
                    NSLog(@"No sfid for detail");
                }
                else{
                    BOOL  isRecordInsertionSucces = [modifiedRecordService saveRecordModel:syncRecord];
                    if(isRecordInsertionSucces){
                        
                    }
                }
            }
        }
        //delete record
        if([deletedRecordIds count] > 0 )
        {
            [self deleteRecordIds:deletedRecordIds forProcessComponent:processComponent];
        }
    }
}

- (void)deleteRecordIds:(NSArray *)deletedRecordIds
    forProcessComponent:(SFProcessComponentModel *)processComponent {
    
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
            if(sfId != nil || sfId.length > 0){
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
            for(NSString * deletedId in sfIdsList)
            {
                 ModifiedRecordModel * syncRecord = [[ModifiedRecordModel alloc] init];
                syncRecord.recordLocalId = @"";
                syncRecord.sfId = deletedId;
                syncRecord.objectName = processComponent.objectName;
                syncRecord.recordType = kRecordTypeDetail;
                syncRecord.operation = kModificationTypeDelete;
                BOOL  isRecordInsertionSucces = [modifiedRecordService saveRecordModel:syncRecord];
                if(isRecordInsertionSucces){}
            }
    }
        
    if ([localIdsList count] > 0) {
            [editHelper deleteRecordWithIds:localIdsList fromObjectName:kModifiedRecords andCriteriaFieldName:kSyncRecordSFId];
            [editHelper deleteRecordWithIds:localIdsList fromObjectName:@"Sync_Records_Heap" andCriteriaFieldName:@"sfId"];
            [editHelper deleteRecordWithIds:localIdsList fromObjectName:processComponent.objectName andCriteriaFieldName:kLocalId];
    }
        
    
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
{
    NSDictionary *fieldinfo = [self getFieldInForObject:objectName];
    
    for (SFObjectMappingComponentModel *model in fieldMappings) {
        
        NSString *fieldValue = nil;
        if (model.sourceFieldName.length < 1) {
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
        else {
            fieldValue = [sourceDcitionary objectForKey:model.sourceFieldName];
            if ([model.sourceFieldName isEqualToString:kId] && fieldValue.length < 5) {
                fieldValue =  [sourceDcitionary objectForKey:kLocalId];
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
                value = [value substringToIndex:10];
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
        sfPage.objectName = [SFMPageEditHelper getObjectNameForProcessIf:self.processId];
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
        [self valueMapping:sfPage];
    }
    
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
                                        objectname:sfpage.objectName];
            [self updateRecordTypeField:headerDataDict objectName:sfpage.objectName];
        }
    }
    
    if ([sfpage.objectName isEqualToString:kEventObject]) {
        [self updateObjectNameForWhatId:componemtModel.objectName mappingArray:fieldMapping
                             headerdata:headerDataDict andSourceObject:sfpage.sourceObjectName];
    }
    
    NSDictionary *fieldDataTypeMap =[super getFieldDataTypeMap:headerFields];
    
    [self updateDisplayValueForRecord:headerDataDict pageFields:headerFields];
    
    [self updatePicklistAndRecorTypeData:headerDataDict andFieldDataTypeMap:fieldDataTypeMap];
    
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
            detailParam.isSourceToTargetProcess = YES;
            
            
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
        
        [self applyFieldMapping:mappingInfo forRecord:dataDict andSourceDictionary:sourceData objectname:processComponent.objectName];
        [self updateRecordTypeField:dataDict objectName:processComponent.objectName];
        
        NSDictionary *fieldDataTypeMap =[super getFieldDataTypeMap:pageFields];
        
        [self updateDisplayValueForRecord:dataDict pageFields:pageFields];
        [self updatePicklistAndRecorTypeData:dataDict andFieldDataTypeMap:fieldDataTypeMap];
        
        if ([processComponent.objectName isEqualToString:kEventObject]) {
            [self updateObjectNameForWhatId:processComponent.objectName mappingArray:mappingInfo
                                 headerdata:dataDict andSourceObject:processComponent.sourceObjectName];
        }
        
        [self updatePageFields:dataDict forFields:pageFields];
        
        [newDetailRecords addObject:dataDict];
    }
    return newDetailRecords;
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
    if ([targetObject isEqualToString:kEventObject]) {
        SFMRecordFieldData *recordData = [headerData objectForKey:kWhatId];
        if ([recordData.internalValue length] < 30) {
            return;
        }
        for (SFObjectMappingComponentModel *objectMapping in mappingData ) {
            
            if([objectMapping.targetFieldName isEqualToString:kWhatId]
               && objectMapping.sourceFieldName.length > 3){
                
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

#pragma mark - Stand alone create process loading

- (void)fillDataForStandAloneCreateProcesSFPage:(SFMPage *)sfPage {
    
     NSString *uniqueId = [AppManager generateUniqueId];
     if ([uniqueId length] > 0) {
        sfPage.recordId = uniqueId;
    }
    
    if (sfPage.objectName == nil) {
        sfPage.objectName = [SFMPageEditHelper getObjectNameForProcessIf:self.processId];
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

#pragma mark - End
@end
