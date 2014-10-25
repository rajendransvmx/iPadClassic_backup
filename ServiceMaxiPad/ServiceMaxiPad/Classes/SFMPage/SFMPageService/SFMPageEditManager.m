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

#import "ModifiedRecordModel.h"
#import "ModifiedRecordsDAO.h"
#import "TransactionObjectDAO.h"
#import "SFMPickerData.h"


@interface SFMPageEditManager ()

@property (nonatomic, strong)NSMutableDictionary *pickListInfo;
@property (nonatomic, strong)NSString *objectName;

@end

@implementation SFMPageEditManager

- (void)fillSfmPage:(SFMPage *)sfPage andProcessType:(NSString *)processType {
    
    @autoreleasepool {
        if ([processType isEqualToString:kProcessTypeStandAloneEdit]) {
            
            [self fillUpDataForEditProcess:sfPage];
        }
        else if ([processType isEqualToString:kProcessTypeSRCToTargetAll]) {
            
        }
        else if ([processType isEqualToString:kProcessTypeSRCToTargetChild]) {
            
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
    self.objectName = objectName;
    
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
        pickerValues= [SFMPageEditHelper getRecordTypeValuesForObjectName:self.objectName];
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
        picklistValues = [SFMPageEditHelper getPicklistValuesForField:pageField.fieldName objectName:self.objectName];
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
        dependentPicklistValues =  [SFMPageEditHelper getDependentPicklistValuesForPageField:controllerPageField recordFieldVal:recordField.internalValue objectName:self.objectName fromPicklist:pickList];
        
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
    
        BOOL recordTypeDependencyExists = [SFMPageEditHelper isRecordTypeDependent:pageField.fieldName RecordTypeFieldData:recordTypeRecordField.internalValue andObjectName:self.objectName];
        
        if (recordTypeDependencyExists) {
            
            recordTypeDepList = [SFMPageEditHelper getRecordTypePicklistData:self.objectName fieldName:pageField.fieldName pageDataValue:recordTypeRecordField.internalValue];
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

- (void)fillUpFieldMappingMetaData:(SFMPage *)sfmPage {
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
                if([recordTypeModel.recordtypeLabel isEqualToString:mappingValue])
                {
                    recordfield.internalValue = recordTypeID;
                    displayValue = recordTypeModel.recordtypeLabel ;
                    break;
                }
            }
          
        }
        else if ([objectField.type isEqualToString:kSfDTDateTime] || [objectField.type isEqualToString:kSfDTDate])
        {
            displayValue = [DateUtil evaluateDateLiteral:recordfield.internalValue  dataType:objectField.type];
            
            recordfield.internalValue = displayValue;

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
        if([componentModel.componentType isEqualToString:kTargetChild])
        {
            //            NSMutableArray * detailRecordsArray = [sfmPage.detailRecord objectForKey:componentObj.sfId];
            //
            //            for (NSMutableDictionary * eachDetailDict in detailRecordsArray)
            //            {
            //                [self addObjectNameEntryIntoRecordDict:eachDetailDict withObjectName:objectName];
            //                [self applyValueMapWithMappingDict:valueMappingArray  withCurrentRecord:eachDetailDict withHeaderRecord:headerDict];
            //                [self removeObjectNameEntryIntoRecordDict:eachDetailDict withObjectName:objectName];
            //            }
        }
        else
        {
            
            ValueMappingModel * mappingModel = [[ValueMappingModel alloc] init];
            mappingModel.valueMappingDict = valueMapDict;
            mappingModel.currentRecord = headerDict;
            mappingModel.headerRecord = headerDict;
            mappingModel.currentObjectName = objectName;
            mappingModel.headerObjectName = objectName;
           // [self applyValueMapWithMappingDict:valueMapDict  currentRecord:headerDict headerRecord:headerDict targetObjectName:objectName];
            
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
        syncRecord.operation = kModificationTypeInsert;
        recordUpdatedSuccessFully = [editHelper insertRecord:page.headerRecord intoObjectName:page.objectName];
    }
    else {
        syncRecord.operation = kModificationTypeUpdate;
      recordUpdatedSuccessFully =  [editHelper updateRecord:page.headerRecord inObjectName:page.objectName andLocalId:page.recordId];
    }
    
    syncRecord.recordType = kRecordTypeMaster;
    syncRecord.sfId = headerSfid;
    
    /*after save  make an entry in trailer table*/
    if (recordUpdatedSuccessFully) {
         id <ModifiedRecordsDAO>modifiedRecordService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
        [modifiedRecordService saveRecordModel:syncRecord];
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

    [editHelper deleteRecordWithIds:deletedRecordIds fromObjectName:kModifiedRecords andCriteriaFieldName:kSyncRecordSFId];
    [editHelper deleteRecordWithIds:deletedRecordIds fromObjectName:@"Sync_Records_Heap" andCriteriaFieldName:@"sfId"];
    
    if ([sfIdsList count] > 0) {
            
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

@end
