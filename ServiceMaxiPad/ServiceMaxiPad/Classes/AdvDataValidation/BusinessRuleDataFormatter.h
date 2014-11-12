//
//  BusinessRuleDataFormatter.h
//  ServiceMaxiPhone
//
//  Created by Aparna on 12/06/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SFMPage;

/**
 Class to format the business rule info as required by javascript engine.
 @author Aparna http://www.servicemax.com aparna.bhat@servicemax.com
 */

@interface BusinessRuleDataFormatter : NSObject

/**
 Array of BusinessRuleProcess objects.
 */
@property(nonatomic, strong)NSArray *bizRuleProcesses;

/**
 SFPage Instance for which Business rule needs to be executed.
 */
@property(nonatomic, strong)SFMPage *sfmPage;

/**
 This method  instantiate BusinessRuleDataFormatter
 @param bizRuleProcesses is an array of BusinessRuleProcess objects
 @param sfmPage is SFPage object for which Business rule needs to be executed
 @returns object instance.
 */
- (id)initWithBusinessRuleProcesses:(NSArray *)bizRuleProcesses sfmPage:(SFMPage *)sfmPage;

/**
 This method  instantiate PriceCalculationManager
 @param codeSnippetId is name or Id from Code snippet table
 @param newParentView : on which webview will be added
 @returns object instance.
 */
- (NSDictionary *)formtaBusinessRuleInfo;

/**
 This method is used to format the business rule result obtained from the javascript code into the appropriate model objects.
 @param bizRuleResult is a dictionary to be formatted.
 @returns array of BusinessRuleResult objects.
 */
- (NSArray *)formatBusinessRuleResults:(NSDictionary *)bizRuleResult;

@end
