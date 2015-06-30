//
//  FieldUpdateRuleDataFormatter.m
//  ServiceMaxiPad
//
//  Created by Padmashree on 26/06/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "FieldUpdateRuleDataFormatter.h"
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

@interface FieldUpdateRuleDataFormatter()

@property(nonatomic, strong) DataTypeUtility *dataTypeUtility;
@end


@implementation FieldUpdateRuleDataFormatter

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
        
        [headerRuleDict setObject:self.sfmPage.objectLabel forKey:@"id"];
        [headerRuleDict setObject:self.sfmPage.process.pageLayout.headerLayout.hdrLayoutId forKey:@"key"];
        
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
        NSArray *detailLayouts = self.sfmPage.process.pageLayout.detailLayouts;
        for (SFMDetailLayout *detailLayout in detailLayouts) {
            NSMutableDictionary *detailRuleDict = [NSMutableDictionary dictionary];
            [detailRuleDict setObject:detailLayout.pageLayoutId forKey:@"key"];
            [detailRuleDict setObject:detailLayout.name forKey:@"id"];
            [detailRuleDict setObject:detailLayout.name forKey:@"name"];
            
            NSMutableArray *rulesArray = [NSMutableArray array];
            
            for (ProcessBusinessRuleModel *bizruleProcess in self.bizRuleProcesses) {
                BusinessRuleModel *bizRule = bizruleProcess.businessRuleModel;
                if ([bizRule.sourceObjectName isEqualToString:detailLayout.objectName] && [bizruleProcess.processNodeObject isEqualToString:detailLayout.processComponentId]) {
                    [self fillRulesArray:rulesArray forBusinessRuleProcess:bizruleProcess];
                }
            }
            
            [detailRuleDict setObject:rulesArray forKey:@"rules"];
            [mainRuleDict setObject:detailRuleDict forKey:detailLayout.name];
        }
    }
}


- (NSMutableDictionary *)formatExpressionComponent:(SFExpressionComponentModel *)expComp{
    
    NSMutableDictionary *expCompDict = [[NSMutableDictionary alloc] init];
    [expCompDict setValue:expComp.componentLHS forKey:kExpressionCompFieldName];
    [expCompDict setValue:expComp.formula forKey:kExpressionCompFormula];
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

        NSMutableDictionary *ruleInfoDict = [[NSMutableDictionary alloc]init];
        
        NSMutableArray *bizRuleDetailsArray = [[NSMutableArray alloc] init];
        for (SFExpressionComponentModel *expComp in bizRule.expressionComponentsArray) {
            NSMutableDictionary *expDict = [self formatExpressionComponent:expComp];
            [bizRuleDetailsArray addObject:expDict];
        }
        [ruleInfoDict setObject:bizRuleDetailsArray forKey:kBizRuleDetails];
        [ruleDict setObject:ruleInfoDict forKey:kBizRuleInfo];
        [ruleDict setObject:self.sfmPage.objectLabel forKey:@"aliasName"];
        [rulesArray addObject:ruleDict];
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
            if (![StringUtil isStringEmpty:bizrule.sourceObjectName]) {
                [mainFieldDict setValue:headerFieldDict forKey:bizrule.sourceObjectName];
            }
        }
    }
}


#pragma mark -
#pragma mark Data Info Fromatter Methods
- (void) fillHeaderDataInfo:(NSMutableDictionary *)mainDataDict forFields:(NSDictionary *)fieldsDict{
    
    @autoreleasepool {
        
        NSMutableDictionary *headerRecords = self.sfmPage.headerRecord;
        NSArray *headerSections = self.sfmPage.process.pageLayout.headerLayout.sections;
        NSArray *headerFields = nil;
        if ([headerSections count] == 1) {
            SFMHeaderSection *headerSection = [headerSections lastObject];
            headerFields = headerSection.sectionFields;
            for (SFMPageField *pageField in headerFields) {
                SFMRecordFieldData *recordField = [headerRecords objectForKey:pageField.fieldName];
                NSString *value = recordField.internalValue;
                if ([StringUtil isStringEmpty:value]) {
                    value = @"";
                    if ([pageField.dataType isEqualToString:kSfDTCurrency] || [pageField.dataType isEqualToString:kSfDTDouble] ||[pageField.dataType isEqualToString:kSfDTPercent] || [pageField.dataType isEqualToString:kSfDTInteger]) {
                        value = @"0";
                    }
                }
                [mainDataDict setValue:value forKey:pageField.fieldName];
            }
        }
    }
}




- (void) fillDetailDataInfo:(NSMutableDictionary *)mainDataDict forFields:(NSDictionary *)fieldsDict{
    @autoreleasepool {
        NSMutableDictionary *detailRecords = self.sfmPage.detailsRecord;
        NSArray *pageLayouts = self.sfmPage.process.pageLayout.detailLayouts;
        
        NSMutableDictionary *detailDict = [NSMutableDictionary dictionary];
        
        for (SFMDetailLayout *detailLayout in pageLayouts) {
            NSMutableDictionary *pagelayoutIdDict = [NSMutableDictionary dictionary];
            NSArray *detailSections = detailLayout.detailSectionFields;
            NSArray *recordsArray = [detailRecords objectForKey:detailLayout.processComponentId];
            
            NSMutableArray *linesArray = [NSMutableArray array];
            
            for (NSDictionary *record in recordsArray) {
                NSMutableDictionary *fieldsDict = [NSMutableDictionary dictionary];
                for (SFMPageField *pageField in detailSections) {
                    NSString *fieldName = pageField.fieldName;
                    SFMRecordFieldData *fieldData = [record objectForKey:fieldName];
                    NSString *value = fieldData.internalValue;
                    if ([StringUtil isStringEmpty:value]) {
                        value = @"";
                        if ([pageField.dataType isEqualToString:kSfDTCurrency] || [pageField.dataType isEqualToString:kSfDTDouble] ||[pageField.dataType isEqualToString:kSfDTPercent] || [pageField.dataType isEqualToString:kSfDTInteger]) {
                            value = @"0";
                        }
                    }
                    [fieldsDict setValue:value forKey:fieldName];
                }
                [linesArray addObject:fieldsDict];
            }
            
            [pagelayoutIdDict setObject:linesArray forKey:@"lines"];
            [detailDict setObject:pagelayoutIdDict forKey:detailLayout.pageLayoutId];
        }
        [mainDataDict setObject:detailDict forKey:@"details"];
    }
}


@end
