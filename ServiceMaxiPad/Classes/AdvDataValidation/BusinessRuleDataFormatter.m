//
//  BusinessRuleDataFormatter.m
//  ServiceMaxiPhone
//
//  Created by Aparna on 12/06/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "BusinessRuleDataFormatter.h"
#import "SFMPage.h"
#import "BusinessRuleConstants.h"
#import "SFExpressionComponentModel.h"
#import "SFMDetailLayout.h"
#import "BusinessRuleResult.h"
#import "ProcessBusinessRuleModel.h"
#import "SFMRecordFieldData.h"
#import "SFMPageEditManager.h"
#import "StringUtil.h"
#import "BusinessRuleModel.h"
#import "BusinessRuleDatabaseService.h"
#import "DatabaseConstant.h"
#import "DateUtil.h"
#import "SFMPageHelper.h"
#import "DataTypeUtility.h"

@interface BusinessRuleDataFormatter()

@property(nonatomic, strong) DataTypeUtility *dataTypeUtility;
@end


@implementation BusinessRuleDataFormatter

- (id)initWithBusinessRuleProcesses:(NSArray *)bizRuleProcesses sfmPage:(SFMPage *)sfmPage{
    
    self = [super init];
    if (self) {
        self.bizRuleProcesses = bizRuleProcesses;
        self.sfmPage = sfmPage;
    }
    return self;
}


- (NSDictionary *) formtaBusinessRuleInfo{
    
    NSMutableDictionary *bizRuleInfoDict = [[NSMutableDictionary alloc]init];
    [bizRuleInfoDict setValue:[self formatBusinessRuleMetaData] forKey:kBizRuleMetaData];
    NSDictionary *fieldsDict = [self formatBusinessRuleFields];
    [bizRuleInfoDict setValue:fieldsDict forKey:kBizRuleFields];
    [bizRuleInfoDict setValue:[self formatBusinessRuleDataForFields:fieldsDict] forKey:KBizRuleData];
    return bizRuleInfoDict;
}


- (NSDictionary *) formatBusinessRuleMetaData{
    
    NSMutableDictionary *mainRuleDict = [[NSMutableDictionary alloc] init];
    [self fillHeaderRuleInfo:mainRuleDict];
    [self fillDetailRuleInfo:mainRuleDict];
    return mainRuleDict;
}


- (NSDictionary *) formatBusinessRuleFields{
    
    NSMutableDictionary *mainFieldsDict = [[NSMutableDictionary alloc] init];
    [self fillHeaderFieldInfo:mainFieldsDict];
    return mainFieldsDict;
}


- (NSDictionary *) formatBusinessRuleDataForFields:(NSDictionary *)fieldsDict{
    
    NSMutableDictionary *mainDataDict = [[NSMutableDictionary alloc] init];
    [self fillHeaderDataInfo:mainDataDict forFields:fieldsDict];
    [self fillDetailDataInfo:mainDataDict forFields:fieldsDict];
    return mainDataDict;
}


#pragma mark -
#pragma mark Rules Meta Data Formatter Methods

- (void)fillHeaderRuleInfo:(NSMutableDictionary *)mainRuleDict{
    @autoreleasepool {
        NSMutableDictionary *headerRuleDict = [[NSMutableDictionary alloc] init];
        NSString *objectName = self.sfmPage.objectName;
        NSMutableArray *rulesArray = [[NSMutableArray alloc] init];
        
        for (ProcessBusinessRuleModel *process in self.bizRuleProcesses) {
            BusinessRuleModel *bizrule = process.businessRuleModel;
            if ([bizrule.sourceObjectName isEqualToString:objectName]) {
                
                [self fillRulesArray:rulesArray forBusinessRuleProcess:process];
            }
        }
        [headerRuleDict setObject:rulesArray forKey:kBizRules];
        [mainRuleDict setObject:headerRuleDict forKey:kBizRuleHeader];
    }
}


- (void)fillDetailRuleInfo:(NSMutableDictionary *)mainRuleDict{
    @autoreleasepool {
        NSArray *detailLayoutArray = self.sfmPage.process.pageLayout.detailLayouts;
        for (SFMDetailLayout *detailLayout in detailLayoutArray)
        {
            NSMutableArray *rulesArray = [[NSMutableArray alloc] init];
            for (ProcessBusinessRuleModel *bizruleProcess in self.bizRuleProcesses) {
                BusinessRuleModel *bizRule = bizruleProcess.businessRuleModel;
                if ([bizRule.sourceObjectName isEqualToString:detailLayout.objectName] && [bizruleProcess.processNodeObject isEqualToString:detailLayout.processComponentId]) {
                    [self fillRulesArray:rulesArray forBusinessRuleProcess:bizruleProcess];
                }
            }
            if ([rulesArray count]>0) {
                NSMutableDictionary *detailDict = [[NSMutableDictionary alloc] init];
                [detailDict setValue:detailLayout.dtlLayoutId forKey:kBizRuleKey];
                [detailDict setValue:rulesArray forKey:kBizRules];
                [mainRuleDict setValue:detailDict forKey:detailLayout.name];
            }
        }
    }
}


- (NSMutableDictionary *)formatExpressionComponent:(SFExpressionComponentModel *)expComp{
    
    NSMutableDictionary *expCompDict = [[NSMutableDictionary alloc] init];
    [expCompDict setValue:expComp.expressionId forKey:kExpressionCompExprRule];
    [expCompDict setValue:expComp.componentLHS forKey:kExpressionCompFieldName];
    [expCompDict setValue:expComp.componentRHS forKey:kExpressionCompOperand];
    [expCompDict setValue:expComp.operatorValue forKey:kExpressionCompOperator];
    [expCompDict setValue:expComp.parameterType forKey:kExpressionCompParentType];
    return expCompDict;
}


- (NSMutableDictionary *)formatBizRule:(BusinessRuleModel *)bizRule
{
    NSMutableDictionary *bizRuleDict = [[NSMutableDictionary alloc] init];
    if ([StringUtil isStringEmpty:bizRule.advancedExpression]) {
        bizRule.advancedExpression = @"";
    }
    [bizRuleDict setValue:bizRule.advancedExpression forKey:kBizRulesAdvExpression];

    [bizRuleDict setValue:bizRule.messageType forKey:kBizRulesMsgType];
    [bizRuleDict setValue:bizRule.sourceObjectName forKey:kBizRulesSrcObjectName];
    return bizRuleDict;
}


- (void) fillRulesArray:(NSMutableArray *) rulesArray forBusinessRuleProcess:(ProcessBusinessRuleModel *)bizRuleProcess{
    @autoreleasepool{
        NSMutableDictionary *ruleDict = [[NSMutableDictionary alloc] init];
        BusinessRuleModel *bizRule = bizRuleProcess.businessRuleModel;
		//Fix for 011532
        bizRuleProcess.errorMessage = ([StringUtil isStringEmpty:bizRuleProcess.errorMessage])?@"":bizRuleProcess.errorMessage;
        [ruleDict setObject:bizRuleProcess.errorMessage forKey:kBizRuleMessage];
        NSMutableDictionary *ruleInfoDict = [[NSMutableDictionary alloc]init];
        NSMutableDictionary *bizRuleDict = [self formatBizRule:bizRule];
        [ruleInfoDict setObject:bizRuleDict forKey:kBizRuleDictKey];
        
        NSMutableArray *bizRuleDetailsArray = [[NSMutableArray alloc] init];
        for (SFExpressionComponentModel *expComp in bizRule.expressionComponentsArray) {
            NSMutableDictionary *expDict = [self formatExpressionComponent:expComp];
            [bizRuleDetailsArray addObject:expDict];
        }
        [ruleInfoDict setObject:bizRuleDetailsArray forKey:kBizRuleDetails];
        [ruleDict setObject:ruleInfoDict forKey:kBizRuleInfo];
        [rulesArray addObject:ruleDict];
//        [ruleDict setObject:[NSNumber numberWithInteger:bizRuleProcess.sequence] forKey:kBizRuleSequence];
        [ruleDict setValue:bizRuleProcess.sequence forKey:kBizRuleSequence];

    }
}


#pragma mark -
#pragma mark Fields Info Fromatter Methods

- (void) fillHeaderFieldInfo:(NSMutableDictionary *)mainFieldDict{
    
    @autoreleasepool {
        for (ProcessBusinessRuleModel *process in self.bizRuleProcesses) {
            BusinessRuleModel *bizrule = process.businessRuleModel;
            NSMutableDictionary *headerFieldDict = [mainFieldDict valueForKey:bizrule.sourceObjectName];
            if (nil == headerFieldDict) {
                headerFieldDict = [[NSMutableDictionary alloc] init];
            }
            for (SFExpressionComponentModel *expComp in bizrule.expressionComponentsArray) {
                [headerFieldDict setValue:[expComp.fieldType lowercaseString]  forKey:expComp.componentLHS];
                if ([expComp.parameterType isEqualToString:kExpComponentFieldValue]) {
                    [headerFieldDict setValue:[expComp.fieldType lowercaseString]  forKey:expComp.componentRHS];

                }
            }
            [mainFieldDict setValue:headerFieldDict forKey:bizrule.sourceObjectName];
        }
    }
}


#pragma mark -
#pragma mark Data Info Fromatter Methods
- (void) fillHeaderDataInfo:(NSMutableDictionary *)mainDataDict forFields:(NSDictionary *)fieldsDict{
    
    @autoreleasepool {
        NSString *objectName = self.sfmPage.objectName;
        NSDictionary *allFieldDict = [fieldsDict objectForKey:objectName];
        NSArray *allFields = [allFieldDict allKeys];
        
        for (NSString *fieldName in allFields) {
            SFMRecordFieldData *recField = [self.sfmPage getHeaderFieldDataForName:fieldName];
            /*For fields not present in the layout, get the data from db*/
            NSString *value = [self valueForRecordField:recField
                                             objectName:objectName
                                              fieldType:[allFieldDict valueForKey:fieldName]
                                              fieldName:fieldName
                                                localID:self.sfmPage.recordId];

            
            [mainDataDict setValue:value forKey:fieldName];
        }
        NSMutableDictionary *attributeDict = [[NSMutableDictionary alloc] init];
        [attributeDict setValue:objectName forKey:kBizRuleType];
        [mainDataDict setValue:attributeDict forKey:kBizRuleAttributes];
        
    }
}




- (void) fillDetailDataInfo:(NSMutableDictionary *)mainDataDict forFields:(NSDictionary *)fieldsDict{
    @autoreleasepool {
        NSArray *detailLayoutArray = self.sfmPage.process.pageLayout.detailLayouts;
        NSMutableDictionary *detailsDict = [[NSMutableDictionary alloc]init];
        
        for (SFMDetailLayout *detailLayout in detailLayoutArray)
        {
            for (ProcessBusinessRuleModel *bizruleProcess in self.bizRuleProcesses) {
                BusinessRuleModel *bizRule = bizruleProcess.businessRuleModel;
                if ([bizRule.sourceObjectName isEqualToString:detailLayout.objectName] && [bizruleProcess.processNodeObject isEqualToString:detailLayout.processComponentId]) {
                    
                    NSArray *detailRecords = [self.sfmPage.detailsRecord objectForKey: detailLayout.processComponentId];
                    /*For hidden fields get the value from the DB*/
                    
                    NSDictionary *allFields = [fieldsDict valueForKey:detailLayout.objectName];
                    NSArray *allFieldsKeys = [allFields allKeys];
                    NSMutableArray *lines = [[NSMutableArray alloc] init];
                    for (NSDictionary *detalDict in detailRecords) {
                        SFMRecordFieldData *localRecordField = [detalDict valueForKey:kLocalId];
                        NSString *localId = [localRecordField internalValue];
                        NSMutableDictionary *lineDict = [[NSMutableDictionary alloc]init];
                        for (NSString *fieldApiName in allFieldsKeys) {
                            /*Get the value from the SFPage object*/
                            SFMRecordFieldData *recordField = [detalDict valueForKey:fieldApiName];
                            NSString *value = [self valueForRecordField:recordField
                                                             objectName:detailLayout.objectName
                                                              fieldType:[allFields valueForKey:fieldApiName]
                                                              fieldName:fieldApiName
                                                                localID:localId];
                            
                            [lineDict setValue:value forKey:fieldApiName];
                        }
                        NSMutableDictionary *attributeDict = [[NSMutableDictionary alloc] init];
                        [attributeDict setValue:detailLayout.objectName forKey:kBizRuleType];
                        [lineDict setValue:attributeDict forKey:kBizRuleAttributes];
                        [lines addObject:lineDict];
                    }
                    
                    NSMutableDictionary *detailDict = [[NSMutableDictionary alloc] init];
                    [detailDict setObject:lines forKey:kBizRuleLines];
                    [detailsDict setValue:detailDict forKey:detailLayout.dtlLayoutId];
                }
            }
        }
        
        if ([detailsDict count]>0) {
            [mainDataDict setObject:detailsDict forKey:kBizRuleDetailsKey];
        }
    }
}



#pragma mark -
#pragma mark Format Business Rule Results
- (NSArray *)formatBusinessRuleResults:(NSDictionary *)bizRuleResult
{
    NSMutableArray *bizRuleResultArray = [[NSMutableArray alloc]init];
    @autoreleasepool {
        NSArray *errorsArray = [bizRuleResult valueForKey:KBizRuleErrors];
        /*Errors*/
        for (NSDictionary *errorDict in errorsArray) {
            BusinessRuleResult *result = [self businessRuleResultForDictionary:errorDict];
            if (result != nil) {
                [bizRuleResultArray addObject:result];
            }
        }
        /*Warnings*/
        NSArray *warningsArray = [bizRuleResult valueForKey:kBizRuleWarnings];
        for (NSDictionary *warningDict in warningsArray) {
            BusinessRuleResult *result = [self businessRuleResultForDictionary:warningDict];
            if (result != nil) {
                [bizRuleResultArray addObject:result];
            }
        }
    }
    return bizRuleResultArray;

}

- (BusinessRuleResult *) businessRuleResultForDictionary:(NSDictionary *)dict{
    
    BusinessRuleResult *result = nil;
    if ([[dict allKeys] count]>0) {
        result = [[BusinessRuleResult alloc] init];
        
        NSDictionary *bizRuleDict = [[dict valueForKey:kBizRuleInfo] valueForKey:kBizRuleDictKey];
        result.message = [dict valueForKey:kBizRuleMessage];
        result.messgaeType = [bizRuleDict valueForKey:kBizRulesMsgType];
        result.objectName = [bizRuleDict valueForKey:kBizRulesSrcObjectName];
        NSArray *ruleDetails = [[dict valueForKey:kBizRuleInfo] valueForKey:kBizRuleDetails];
        for (ProcessBusinessRuleModel *process in self.bizRuleProcesses) {
            
            BusinessRuleModel  *bizRule = process.businessRuleModel;
            NSString *ruleId = nil;
            if ([ruleDetails count]>0) {
                ruleId = [[ruleDetails objectAtIndex:0] valueForKey:kExpressionCompExprRule];
            }
            if ([bizRule.Id isEqualToString:ruleId]) {
                result.fieldLabel = bizRule.description;
                result.ruleId = bizRule.name;
                break;

            }
        }
        
    }
    
    return result;
}

- (NSString *) valueForRecordField:(SFMRecordFieldData *)recordField
                        objectName:(NSString *)objectName
                         fieldType:(NSString *)fieldType
                         fieldName:(NSString *)fieldName
                           localID:(NSString *)localId
{
    
    BusinessRuleDatabaseService *dbService = [[BusinessRuleDatabaseService alloc] init];

    NSString *value = @"";
    if(recordField == nil)
    {
        /*For fields not present in the page layout, get the value from the database*/
        NSDictionary *dict  = [SFMPageHelper getDataForObject:objectName  fields:[[NSArray alloc]initWithObjects:fieldName, nil] recordId:localId];
        recordField = [[SFMRecordFieldData alloc] initWithFieldName:fieldName value:[dict valueForKey:fieldName] andDisplayValue:[dict valueForKey:fieldName]];
    }
    if([fieldName isEqualToString:kSfDTRecordTypeId])
    {
        NSString *recordType = [dbService getRecordTypeForId:recordField.internalValue objectName:objectName];
        value = recordType;
    }
    else if ([fieldType isEqualToString:kSfDTReference]) {
        
        if (self.dataTypeUtility == nil) {
            self.dataTypeUtility = [[DataTypeUtility alloc] init];
        }
        
        value = recordField.displayValue;
        if ([StringUtil isStringEmpty:value]) {
        
            SFObjectFieldModel *objectFieldModel = [self.dataTypeUtility getField:fieldName objectName:objectName];
            if (![StringUtil isStringEmpty:objectFieldModel.referenceTo]) {
                value = [SFMPageHelper getRefernceFieldValueForObject:objectFieldModel.referenceTo andId:recordField.internalValue];
            }
            if([StringUtil isStringEmpty:value])
            {
                value = [dbService getValueFromNameFieldTable:recordField.internalValue];
            }
        }
    }
    else if([fieldType isEqualToString:kSfDTDateTime]){
        if (![StringUtil isStringEmpty:recordField.internalValue]) {
            value = recordField.internalValue; //[DateUtil getLocalTimeFromGMT:recordField.internalValue];
        }
    }
    else{
        value = recordField.internalValue;
        
    }
    if ([StringUtil isStringEmpty:value])
    {
        value = @"";
    }
    return value;
}

@end
