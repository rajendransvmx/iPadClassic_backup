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
#import "FieldUpdateRuleDataFormatter.h"
#import "Utility.h"
#import "ProcessBusinessRuleModel.h"

@interface FieldUpdateRuleManager ()
@property (nonatomic, strong) FieldUpdateRuleDataFormatter *formulaDataFormatter;
@end

@implementation FieldUpdateRuleManager

-(id)initWithProcessId:(NSString *)processId sfmPage:(SFMPage *)sfmPage {
    self = [super initWithProcessId:processId sfmPage:sfmPage];
    if (self) {
        
    }
    return self;
}

-(BOOL)executeFieldUpdateRules {
    BOOL fieldUpdateRuleExists = NO;
    if ([self isBizRuleInfoAvailable]) {
        
        BusinessRuleDatabaseService *dbService = [[BusinessRuleDatabaseService alloc] init];
        
        NSMutableArray *bizRuleProcessArray = [NSMutableArray arrayWithArray:[dbService processBusinessRuleForProcessId:self.processId]];
        NSArray *fieldUpdateRules = [dbService fieldUpdateRulesForBizRuleProcesses:bizRuleProcessArray];
        
        NSArray *tempArray = [NSArray arrayWithArray:bizRuleProcessArray];
        
        for(ProcessBusinessRuleModel *bizRuleProcess in tempArray) {
            NSArray *filteredArray = [fieldUpdateRules filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"Id == [c] %@", bizRuleProcess.businessRule]];
            if ([filteredArray count] == 0) {
                [bizRuleProcessArray removeObject:bizRuleProcess];
            }
        }
        
        if ([fieldUpdateRules count] > 0) {
            
            fieldUpdateRuleExists = YES;
            
            NSArray *expComponensArray = [dbService expressionComponentsForBizRules:fieldUpdateRules];
            
            [self fillBusinessRuleProcesses:bizRuleProcessArray withBusinessRules:fieldUpdateRules];
            [self fillBusinessRule:fieldUpdateRules withExpressionComponents:expComponensArray];
            
            NSString *htmlStr = [self getBizRuleHtmlStringForProcesses:bizRuleProcessArray];
            
            self.jsExecuter = [[JSExecuter alloc] initWithParentView:self.parentView andCodeSnippet:htmlStr andDelegate:self andFrame:CGRectZero];
        }
    }
    return fieldUpdateRuleExists;
}

- (void)eventOccured:(NSString *)eventName andParameter:(NSString *)jsonParameterString {
    
    if ([eventName isEqualToString:kfieldUpdateRuleResult]) {
        //HS Fix:021298
        NSDictionary *tempDict = (NSDictionary *)[Utility objectFromJsonString:jsonParameterString];
        NSArray *warningArray = [tempDict objectForKey:@"warnings"];
        //HS Fix:021298 ends here
        if ([self.delegate respondsToSelector:@selector(refreshSFMPageWithFieldUpdateRuleResults:forEvent:)]) {
            [self.delegate refreshSFMPageWithFieldUpdateRuleResults:jsonParameterString forEvent:self.eventType];
            //HS Fix:021298
            if ([warningArray count]!=0)
            {
                NSDictionary *warningDict = [warningArray objectAtIndex:0];
                NSString *warningMsg = [warningDict objectForKey:@"message"];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"ServiceMax" message:warningMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
            //HS ends here
            
        }
    }
}


- (NSString *) getBizRuleHtmlStringForProcesses:(NSArray *)bizRuleProcessArray{
    if (self.formulaDataFormatter == nil) {
        
        self.formulaDataFormatter = [[FieldUpdateRuleDataFormatter alloc] init];
    }
    self.formulaDataFormatter.bizRuleProcesses = bizRuleProcessArray;
    self.formulaDataFormatter.sfmPage = self.sfmPage;
    NSDictionary *bizRuleDict = [self.formulaDataFormatter formtaBusinessRuleInfo];
    
    NSString *metaDataStr = [Utility jsonStringFromObject:[bizRuleDict valueForKey:kBizRuleMetaData]];
    NSString *fieldStr =    [Utility jsonStringFromObject:[bizRuleDict valueForKey:kBizRuleFields]];
    NSString *dataStr = [Utility jsonStringFromObject:[bizRuleDict valueForKey:KBizRuleData]];
    
    NSString *bizRuleHtmlStr = [self htmlStringForBizRuleMetaData:metaDataStr fields:fieldStr data:dataStr];
    
    NSDictionary *paramsDict = [NSDictionary dictionaryWithObjects:@[[bizRuleDict valueForKey:kBizRuleMetaData], [bizRuleDict valueForKey:KBizRuleData], [NSDictionary dictionary]] forKeys:@[@"rules", @"data", @"userInfo"]];
    NSString *paramsStr = [Utility jsonStringFromObject:paramsDict];
    
    NSString *param = [NSString stringWithFormat:@"var params = %@", paramsStr];
    
    NSString *htmlFileString =[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"mobile-fieldupdaterules-app" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
    NSString *htmlContent = [htmlFileString stringByAppendingString:param];
    NSString *finalString = [bizRuleHtmlStr stringByAppendingString:htmlContent];
    return finalString;
}

@end
