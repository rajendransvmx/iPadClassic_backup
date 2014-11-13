//
//  BizRuleDatabaseService.h
//  ServiceMaxiPhone
//
//  Created by Aparna on 10/06/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//


/**
 Class to retrieve the data required by Business Rule.
 @author Aparna http://www.servicemax.com aparna.bhat@servicemax.com
 */
@interface BusinessRuleDatabaseService : NSObject

/**
 This method is to get an array of BusinessRuleProcess objects associated with particular process
 @param processId SFId of the process for which business rule information is required.
 @returns array of BusinessRuleProcess objects.
 */
- (NSArray *) processBusinessRuleForProcessId:(NSString *)processId;


/**
 This method is to get an array of BusinessRule objects associated with BusinessRuleProcess objects
 @param bizRuleProcessArray array of BusinessRuleProcess objects
 @returns array of BusinessRule objects.
 */
- (NSArray *) businessRulesForBizRuleProcesses:(NSArray *)bizRuleProcessArray;

/**
 This method is to get the expression components associated with business rule
 @param bizRules Array of BusinessRule objects for which expression components need to fetched
 @returns array of SFExpressionComponent objects.
 */
- (NSArray *) expressionComponentsForBizRules:(NSArray *)bizRules;


- (NSString *) getRecordTypeForId:(NSString *)recordTypeId objectName:(NSString *)objectName;

@end
