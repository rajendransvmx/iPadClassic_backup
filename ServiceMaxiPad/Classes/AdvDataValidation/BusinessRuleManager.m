//
//  BizRuleManager.m
//  ServiceMaxiPhone
//
//  Created by Aparna on 10/06/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "BusinessRuleManager.h"
#import "BusinessRuleDatabaseService.h"
#import "SFExpressionComponentModel.h"
#import "BusinessRuleDataFormatter.h"
#import "JSExecuter.h"
#import "BusinessRuleConstants.h"
#import "BusinessRuleResult.h"
#import "FileManager.h"
#import "ProcessBusinessRuleModel.h"
#import "BusinessRuleModel.h"
#import "Utility.h"

#define CORE_LIB_CLIENT_APP @"com.servicemax.client.app"
#define CORE_CLIENT_LIB @"com.servicemax.client.lib"
#define CORE_BIZ_RUlE_LIB @"com.servicemax.client.sfmbizrules"
#define CORE_RUNTIME_LIB @"com.servicemax.client.runtime"

@interface BusinessRuleManager ()

@property(nonatomic, strong) BusinessRuleDataFormatter *formatter;
@property(nonatomic, strong) NSDictionary *bizRuleResult;
@property(nonatomic, strong) NSMutableArray *resultArray;
@property(nonatomic, strong) NSMutableDictionary *warningsDict;

@end


@implementation BusinessRuleManager
//@synthesize warningConfirmationDict;

- (id)initWithProcessId:(NSString *)processId sfmPage:(SFMPage *)sfmPage{
    self = [super init];
    if (self) {
        self.processId = processId;
        self.sfmPage = sfmPage;
    }
    return self;
}

- (BOOL) isBizRuleInfoAvailable
{
    
    BOOL isBizRuleInfoAvailable = NO;
    NSString *coreLibraryPath = [FileManager getCoreLibSubDirectoryPath];
    if([FileManager isDirectoryExistsAtPath:[coreLibraryPath stringByAppendingPathComponent:CORE_LIB_CLIENT_APP]] && [FileManager isDirectoryExistsAtPath:[[FileManager getRootPath] stringByAppendingPathComponent:CORE_CLIENT_LIB]] && [FileManager isDirectoryExistsAtPath:[coreLibraryPath stringByAppendingPathComponent:CORE_BIZ_RUlE_LIB]] && [FileManager isDirectoryExistsAtPath:[coreLibraryPath stringByAppendingPathComponent:CORE_RUNTIME_LIB]])
         {
             isBizRuleInfoAvailable = YES;
         }
    
    return isBizRuleInfoAvailable;
}


- (BOOL) executeBusinessRules{
    
    BOOL shouldExecuteBizRule = YES;
    BusinessRuleDatabaseService *dbService = [[BusinessRuleDatabaseService alloc] init];
    
    if (![self isBizRuleInfoAvailable]) {
        SXLogWarning(@"Required core library is not available.");
        shouldExecuteBizRule =  NO;
    }
    else{
        /*Get all the BusinessRuleProcess objects*/
        NSMutableArray *bizRuleProcessArray = [NSMutableArray arrayWithArray:[dbService processBusinessRuleForProcessId:self.processId]];
        
        if ([bizRuleProcessArray count] == 0) {
            SXLogWarning(@"No biz rule process available");
            
            shouldExecuteBizRule = NO;
        }
        else{
            /*Get all the BusinessRule objects*/
            NSArray *bizRules = [dbService businessRulesForBizRuleProcesses:bizRuleProcessArray];
            
            NSArray *tempArray = [NSArray arrayWithArray:bizRuleProcessArray];
            
            for(ProcessBusinessRuleModel *bizRuleProcess in tempArray) {
                NSArray *filteredArray = [bizRules filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"Id == [c] %@", bizRuleProcess.businessRule]];
                if ([filteredArray count] == 0) {
                    [bizRuleProcessArray removeObject:bizRuleProcess];
                }
            }
            
            if ([bizRules count] == 0) {
                SXLogWarning(@"No biz rule available");
                shouldExecuteBizRule = NO;
            }
            
            else {
                
                /*Get all the SFExpressionComponent objects*/
                NSArray *expComponensArray = [dbService expressionComponentsForBizRules:bizRules];
                
                [self fillBusinessRuleProcesses:bizRuleProcessArray withBusinessRules:bizRules];
                [self fillBusinessRule:bizRules withExpressionComponents:expComponensArray];
                
                NSString *htmlStr = [self getBizRuleHtmlStringForProcesses:bizRuleProcessArray];
                
                self.jsExecuter = [[JSExecuter alloc] initWithParentView:self.parentView
                                                          andCodeSnippet:htmlStr
                                                             andDelegate:self
                                                                andFrame:CGRectZero];
            }
            
        }
        
    }
    return shouldExecuteBizRule;
}

- (int)numberOfErrorsInResult
{
    NSArray *errorsArray = [self.bizRuleResult valueForKey:KBizRuleErrors];
    return (int)[errorsArray count];
}

- (int)numberOfWarningsInResult
{
    NSArray *warningsArray = [self.bizRuleResult valueForKey:kBizRuleWarnings];
    return (int)[warningsArray count];
}


- (BOOL)allWarningsAreConfirmed{
    
    if(([self.warningsDict count] == 0) || (self.warningsDict == nil)){
        return NO;
    }
    BOOL flag = YES;
    for (BusinessRuleResult * result in self.resultArray) {
        
        if(!result.confirmation && [result.messgaeType isEqualToString:kBizRuleWarningMessageType]){
            flag = NO;
            break;
        }
    }
    return flag;

}

/*- (BOOL)allWarningsAreConfirmedForBusinessRuleResult:(NSArray *)bizRuleResult{
    
    BOOL allWarningConfirmed = NO;
    NSArray *oldBizRuleResultKeys = [self.confirmationDict allKeys];
    
    for (BusinessRuleResult *result in bizRuleResult) {
        
        if ([result.messgaeType isEqualToString:@"WARNING"])
        {
            if ([oldBizRuleResultKeys containsObject:result.ruleId]) {
                
                allWarningConfirmed = YES;
                //break;
            }
            else
            {
                allWarningConfirmed = NO;
                break;
            }
            
 
        }
    }
    return allWarningConfirmed;
}
*/

- (void) fillBusinessRuleProcesses:(NSArray *)bizRuleProcessArray
                 withBusinessRules:(NSArray *)bizRules
{
    for (ProcessBusinessRuleModel *bizRuleProcess in bizRuleProcessArray) {
        
        for (BusinessRuleModel *bizRule in bizRules) {
            
            if ([bizRuleProcess.businessRule isEqualToString:bizRule.Id]) {
                bizRuleProcess.businessRuleModel = bizRule;
                break;
            }
        }
    }

}

- (void) fillBusinessRule:(NSArray *)bizRules withExpressionComponents:(NSArray *)expComponensArray
{
    for (BusinessRuleModel *bizRule in bizRules) {
        for (SFExpressionComponentModel *exprComp in expComponensArray) {
            if ([bizRule.Id isEqualToString:exprComp.expressionId]) {
                if (bizRule.expressionComponentsArray == nil) {
                    bizRule.expressionComponentsArray = [[NSMutableArray alloc] init];
                }
                [bizRule.expressionComponentsArray addObject:exprComp];
                
            }
        }
        
    }
}


- (NSString *) getBizRuleHtmlStringForProcesses:(NSArray *)bizRuleProcessArray{
    if (self.formatter == nil) {
        
        self.formatter = [[BusinessRuleDataFormatter alloc] init];
    }
    self.formatter.bizRuleProcesses = bizRuleProcessArray;
    self.formatter.sfmPage = self.sfmPage;
    NSDictionary *bizRuleDict = [self.formatter formtaBusinessRuleInfo];
    
    NSString *metaDataStr = [Utility jsonStringFromObject:[bizRuleDict valueForKey:kBizRuleMetaData]];
    NSString *fieldStr = [Utility jsonStringFromObject:[bizRuleDict valueForKey:kBizRuleFields]];
    NSString *dataStr = [Utility jsonStringFromObject:[bizRuleDict valueForKey:KBizRuleData]];

    NSString *bizRuleHtmlStr = [self htmlStringForBizRuleMetaData:metaDataStr fields:fieldStr data:dataStr];
    NSString *htmlFilePath = [[NSBundle mainBundle] pathForResource:@"mobile-bizrules-app" ofType:@"html"];
    NSString *htmlContent = [NSString stringWithContentsOfFile:htmlFilePath encoding:NSUTF8StringEncoding error:nil];
    NSString *finalString = [bizRuleHtmlStr stringByAppendingString:htmlContent];

    return finalString;
}


- (NSString *)pathForBootstrapLibrary{
    
    NSString *bsLibraryPath = [[FileManager getRootPath] stringByAppendingPathComponent:@"com.servicemax.client.lib/src/bootstrap.js"];
    return bsLibraryPath;
}

- (NSString *)pathForClientLibrary{
    NSString *bsLibraryPath = [[FileManager getRootPath] stringByAppendingPathComponent:@"com.servicemax.client.lib"];
    return bsLibraryPath;

}


- (NSString *) htmlStringForBizRuleMetaData:(NSString *)metaDataStr
                                     fields:(NSString *)fieldsStr
                                       data:(NSString *)dataStr{
    
    NSString *bsLibraryPath = [self pathForBootstrapLibrary];
    NSString *clientLibraryPath = [self pathForClientLibrary];
    NSString *coreLibararyPath = [FileManager getCoreLibSubDirectoryPath];
    
    NSString *appConfig = [NSString stringWithFormat:@"var appConfig = { \"title\" : \"Mobile business rules application\", \"version\" : \"1.0.0\",\
                           \"modules\" : [{ \"id\" : \"com.servicemax.client.app\",      			\"version\" : \"1.0.0\" , \"codebase\" : pathToModule },\
                           { \"id\" : \"com.servicemax.client.runtime\",      		\"version\" : \"1.0.0\" , \"codebase\" : pathToModule },\
                           { \"id\" : \"com.servicemax.client.sfmbizrules\",       \"version\" : \"1.0.0\" , \"codebase\" : pathToModule }\
                           ],\"app-config\" : {\"application-id\" : \"application\",\"enable-cache\" : true,\"enable-log\" : true,\"org-name-space\" : \"%@\"},\"platform-config\" : {} };",ORG_NAME_SPACE];
    
    NSString *bizRuleValidator = [NSString stringWithFormat:@"var __SVMX_LOAD_VERSION__ = \"debug\";\
                      __SVMX_LOAD_APPLICATION__({appParams : {},\
                      configType : \"local\",\
                      loadVersion : __SVMX_LOAD_VERSION__,\
                      configData : appConfig,handler : function(){var bizrules = SVMX.create(\"com.servicemax.client.sfmbizrules.impl.BusinessRuleValidator\");"];

    NSString *htmlString = [NSString stringWithFormat:@"<html><script type=\"text/javascript\" src=\"%@\"></script><script type=\"text/javascript\" src=\"%@\"></script><script type=\"text/javascript\" src=\"CommunicationBridgeJS.js\"></script><script type=\"text/javascript\" src=\"bizRules-index.js\"></script><script>jQuery(document).ready(function(){ var pathToModule=\"%@\"; var __SVMX_CLIENT_LIB_PATH__ = \"%@\"; %@  %@ var fields = %@; var dataToValidate = %@; var rules = %@;",bsLibraryPath,clientLibraryPath,coreLibararyPath,clientLibraryPath,appConfig,bizRuleValidator,fieldsStr,dataStr,metaDataStr];

    
    return htmlString;
    
}


#pragma mark -
#pragma mark JSExecuter Delegate Method

- (void)eventOccured:(NSString *)eventName andParameter:(NSString *)jsonParameterString
{
    
    if ([eventName isEqualToString:kBizRuleResult])
    {
        self.bizRuleResult = [Utility objectFromJsonString:jsonParameterString];
        NSArray *bizRuleResultArray = [self.formatter formatBusinessRuleResults:self.bizRuleResult];
        
        if ([self.delegate respondsToSelector:@selector(businessRuleFinishedWithResults:)])
        {
            self.resultArray = [[NSMutableArray alloc] initWithArray:bizRuleResultArray];
            [self updateBizRuleResultArray];
            [self.delegate businessRuleFinishedWithResults: self.resultArray ];
        }
    }
}



-(void)updateWarningDict
{
    for (BusinessRuleResult * result in self.resultArray) {
        
        if(result.confirmation  && ([result.messgaeType caseInsensitiveCompare:kBizRuleWarningMessageType] == NSOrderedSame)){
            
            if(self.warningsDict == nil){
                self.warningsDict = [[NSMutableDictionary alloc] init];
            }
            
            [self.warningsDict setObject:[NSNumber numberWithBool:result.confirmation] forKey:result.ruleId];
        }
        else if ([result.messgaeType caseInsensitiveCompare:kBizRuleWarningMessageType] == NSOrderedSame){
            [self.warningsDict removeObjectForKey:result.ruleId];
        }
    }
}


-(void)updateBizRuleResultArray
{
    for (BusinessRuleResult * result in self.resultArray) {
        
        if([[self.warningsDict allKeys] containsObject:result.ruleId])
        {
            result.confirmation = YES;
        }
    }
}

@end
