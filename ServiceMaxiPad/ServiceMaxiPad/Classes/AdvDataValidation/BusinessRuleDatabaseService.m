//
//  BizRuleDatabaseService.m
//  ServiceMaxiPhone
//
//  Created by Aparna on 10/06/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//
#import "FactoryDAO.h"
#import "DBRequestSelect.h"
#import "StringUtil.h"
#import "BusinessRuleDatabaseService.h"
#import "BusinessRuleConstants.h"

#import "SFRecordTypeDAO.h"
#import "SFRecordTypeService.h"
#import "SFRecordTypeModel.h"

#import "ProcessBusinessRuleDAO.h"
#import "ProcessBusinessRuleModel.h"
#import "ProcessBusinessRuleService.h"

#import "BusinessRuleModel.h"
#import "BusinessRuleDAO.h"
#import "BusinessRuleService.h"

#import "SFExpressionComponentModel.h"
#import "SFExpressionComponentDAO.h"
#import "SFExpressionComponentService.h"


@implementation BusinessRuleDatabaseService

- (NSArray *) processBusinessRuleForProcessId:(NSString *)processId
{
    @synchronized([self class]){
        NSArray *processRuleArray =nil;
        @autoreleasepool {
            id<ProcessBusinessRuleDAO> processBizRuleDao = [FactoryDAO serviceByServiceType:ServiceTypeProcessBusinessRule];
            DBCriteria *criteria = [[DBCriteria alloc]initWithFieldName:kBizRuleProcessTargetManager operatorType:SQLOperatorEqual andFieldValue:processId];
            processRuleArray = [processBizRuleDao fetchProcessBusinessRuleInfoByFields:nil andCriteria:criteria];
            return processRuleArray;
        }
    }
}

- (NSArray *) businessRulesForBizRuleProcesses:(NSArray *)bizRuleProcessArray{
    
    @synchronized([self class]){
        NSArray *bizRuleArray = nil;
        @autoreleasepool {
            NSMutableArray *ruleIds = [[NSMutableArray alloc] init];

            for (ProcessBusinessRuleModel *process in bizRuleProcessArray) {
                [ruleIds addObject:process.businessRule];
            }
//            NSString *ruleIdString = [StringUtil getConcatenatedStringFromArray:ruleIds withSingleQuotesAndBraces:YES];
//            DBCriteria *dbCriteria = [[DBCriteria alloc]initWithFieldName:kBizRuleSfId operatorType:SQLOperatorIn andFieldValue:ruleIdString];
            DBCriteria * dbCriteria = [[DBCriteria alloc] initWithFieldName:kBizRuleSfId operatorType:SQLOperatorIn andFieldValues:ruleIds];

            id<BusinessRuleDAO> bizRuleDao = [FactoryDAO serviceByServiceType:ServiceTypeBusinessRule];
            bizRuleArray = [bizRuleDao fetchBusinessRuleInfoByFields:nil andCriteria:dbCriteria];
            return bizRuleArray;
        }
    }
}


- (NSArray *) expressionComponentsForBizRules:(NSArray *)bizRules
{
    @synchronized([self class]){
        NSArray *expCompArray = [[NSMutableArray alloc] init];
        @autoreleasepool {
            
            NSMutableArray *expIds = [[NSMutableArray alloc] init];
            for (BusinessRuleModel *bizRule in bizRules) {
                [expIds addObject:bizRule.Id];
            }
//            NSString *componentIdsStr = [StringUtil getConcatenatedStringFromArray:expIds withSingleQuotesAndBraces:YES];
            
//            DBCriteria *dbCriteria = [[DBCriteria alloc]initWithFieldName:kSFExpressionId operatorType:SQLOperatorIn andFieldValue:expIds];
            
            DBCriteria * dbCriteria = [[DBCriteria alloc] initWithFieldName:kSFExpressionId operatorType:SQLOperatorIn andFieldValues:expIds];

            id<SFExpressionComponentDAO> expCompDao = [FactoryDAO serviceByServiceType:ServiceTypeExpressionComponent];
            expCompArray = [expCompDao fetchSfExpressionComponentInfoByFields:nil andCriteria:dbCriteria];
            return expCompArray;
        }
    }
}



- (NSString *) getRecordTypeForId:(NSString *)recordTypeId objectName:(NSString *)objectName{
    
    NSString *recordType = nil;
    id <SFRecordTypeDAO> recordTypeDaoService = [FactoryDAO serviceByServiceType:ServiceTypeSFRecordType];
    
    DBCriteria *objNameCriteria = [[DBCriteria alloc] initWithFieldName:kobjectApiName operatorType:SQLOperatorEqual andFieldValue:objectName];
    DBCriteria *idCriteria = [[DBCriteria alloc] initWithFieldName:kRecordTypeId operatorType:SQLOperatorEqual andFieldValue:recordTypeId];

    NSArray *criteriaArray = [[NSArray alloc] initWithObjects:objNameCriteria, idCriteria,nil];
    NSArray *recordTypeModelArray = [recordTypeDaoService fetchSFRecordTypeInfoByFields:[[NSArray alloc]initWithObjects:kRecordType, nil] andCriteria:criteriaArray andExpression:@"1 AND 2"];
    if ([recordTypeModelArray count]>1) {
        SFRecordTypeModel *recordTypeModel = [recordTypeModelArray objectAtIndex:0];
        recordType = recordTypeModel.recordType;
    }
    
    return recordType;
}


@end
