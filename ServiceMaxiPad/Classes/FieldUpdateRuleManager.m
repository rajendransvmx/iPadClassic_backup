//
//  FieldUpdateRuleManager.m
//  ServiceMaxiPad
//
//  Created by Padmashree on 24/06/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "FieldUpdateRuleManager.h"
#import "BusinessRuleDatabaseService.h"
#import "BusinessRuleConstants.h"

@interface FieldUpdateRuleManager ()

@end

@implementation FieldUpdateRuleManager

-(id)initWithProcessId:(NSString *)processId sfmPage:(SFMPage *)sfmPage {
    self = [super initWithProcessId:processId sfmPage:sfmPage];
    if (self) {
        
    }
    return self;
}

-(void)executeFieldUpdateRules {
    if ([self isBizRuleInfoAvailable]) {
        
        BusinessRuleDatabaseService *dbService = [[BusinessRuleDatabaseService alloc] init];
        
        NSArray *bizRuleProcessArray = [dbService processBusinessRuleForProcessId:self.processId];
        NSArray *fieldUpdateRules = [dbService fieldUpdateRulesForBizRuleProcesses:bizRuleProcessArray];
        
        if ([fieldUpdateRules count] > 0) {
            
            NSArray *expComponensArray = [dbService expressionComponentsForBizRules:fieldUpdateRules];
            
            [self fillBusinessRuleProcesses:bizRuleProcessArray withBusinessRules:fieldUpdateRules];
            [self fillBusinessRule:fieldUpdateRules withExpressionComponents:expComponensArray];
            
            NSString *htmlStr = [self getBizRuleHtmlStringForProcesses:bizRuleProcessArray];
            
            self.jsExecuter = [[JSExecuter alloc] initWithParentView:self.parentView andCodeSnippet:htmlStr andDelegate:self andFrame:CGRectZero];
        }
    }
}

- (void)eventOccured:(NSString *)eventName andParameter:(NSString *)jsonParameterString {
    
    if ([eventName isEqualToString:kBizRuleResult]) {
        /*
        self.bizRuleResult = [Utility objectFromJsonString:jsonParameterString];
        NSArray *bizRuleResultArray = [self.formatter formatBusinessRuleResults:self.bizRuleResult];
        
        if ([self.delegate respondsToSelector:@selector(businessRuleFinishedWithResults:)])
        {
            self.resultArray = [[NSMutableArray alloc] initWithArray:bizRuleResultArray];
            [self updateBizRuleResultArray];
            [self.delegate businessRuleFinishedWithResults: self.resultArray ];
        }
         
         */
    }
}

@end
