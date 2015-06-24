//
//  BeforeSaveManager.m
//  ServiceMaxiPad
//
//  Created by Padmashree on 10/06/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "PageEventProcessManager.h"
#import "JSExecuter.h"
#import "HTMLJSWrapper.h"
#import "PriceCalculationDBService.h"
#import "Utility.h"
#import "PriceBookTargetHandler.h"
#import "PriceBookDataHandler.h"

NSString * const kBeforeSaveProcessKey = @"Before Save";
NSString * const kAfterSaveProcessKey = @"After Save";

@interface PageEventProcessManager ()<JSExecuterDelegate>

@property (nonatomic, strong) SFMPage *sfmPage;
@property (nonatomic, strong) NSDictionary *beforeSaveProcessDict, *afterSaveProcessDict;
@property (nonatomic, strong) NSString *codeSnippetId;
@property (nonatomic, strong) UIView *parentView;
@property (nonatomic, strong) JSExecuter *jsExecuter;
@property (nonatomic, strong) NSString *jsonRepresantation;
@property (nonatomic, strong) PriceBookTargetHandler *targetHandler;

@end

@implementation PageEventProcessManager

-(id)initWithSFMPage:(SFMPage *)aSfmPage {
    self = [super init];
    if (self) {
        self.sfmPage = aSfmPage;
    }
    return self;
}


-(BOOL)pageEventProcessExists {
    BOOL pageEventExists = NO;
    return pageEventExists;
    NSArray *pageLevelEvents = self.sfmPage.process.pageLayout.headerLayout.pageLevelEvents;
    NSArray *filteredArray = [pageLevelEvents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(%K CONTAINS[c] %@) OR (%K CONTAINS[c] %@)", kPageEventType, kBeforeSaveProcessKey, kPageEventType, kAfterSaveProcessKey]];
    
    for (NSDictionary *tempDict in filteredArray) {
        NSString *eventCallType = [tempDict objectForKey:kPageEventCallType];
        if ([eventCallType isEqualToString:@"JAVASCRIPT"]) {
            NSString *eventType = [tempDict objectForKey:kPageEventType];
            if ([eventType containsString:kBeforeSaveProcessKey]) {
                self.beforeSaveProcessDict = tempDict;
                pageEventExists = YES;
            }
            if ([eventType containsString:kAfterSaveProcessKey]) {
                self.afterSaveProcessDict = tempDict;
                pageEventExists = YES;
            }
        }
    }
    return pageEventExists;
}

-(BOOL)startPageEventProcessWithParentView:(UIView *)aView {
    
    @autoreleasepool {
        
        
        NSDictionary *eventDict = nil;
        
        if (self.beforeSaveProcessDict) {
            eventDict = self.beforeSaveProcessDict;
            self.beforeSaveProcessDict = nil;
        }
        else if (self.afterSaveProcessDict) {
            eventDict = self.afterSaveProcessDict;
            self.afterSaveProcessDict = nil;
        }
        
        if (eventDict == nil) {
            return NO;
        }
        
        self.codeSnippetId = [eventDict objectForKey:kPageEventCodeSnippetId];
        
        if (aView) {
            self.parentView = aView;
        }
        
        PriceBookTargetHandler *targetHandler = [[PriceBookTargetHandler alloc] initWithSFPage:self.sfmPage];
        self.targetHandler = targetHandler;
        
        PriceBookDataHandler *priceBook = [[PriceBookDataHandler alloc] initWithTargetDictionary:targetHandler.targetDictionary];
        
        NSDictionary *finalDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:targetHandler.targetDictionary,@"target",priceBook.priceBookInformation,@"data",nil];
        
        NSString *jsonString = [Utility jsonStringFromObject:finalDictionary];
        self.jsonRepresantation = jsonString;
        
        priceBook.priceBookInformation = nil;
        
        NSString *codeSnippet = [self getCodeSnippet];
        [self createJsExecuter:codeSnippet];
        
        return YES;
    }
}


- (void)createJsExecuter:(NSString *)codeSnippet {
    if (self.jsExecuter == nil) {
        self.jsExecuter = [[JSExecuter alloc] initWithParentView:self.parentView andCodeSnippet:codeSnippet andDelegate:self];
    }
    else {
        if (codeSnippet != nil & [codeSnippet length] > 3) {
            self.jsExecuter.codeSnippet = codeSnippet;
            [self.jsExecuter executeJavascriptCode:codeSnippet];
        }
    }
}

- (NSString *)getCodeSnippet {
    
    @autoreleasepool {
        NSString *codeSnipppet = [self getCodeSnippetFromDb];
        
        codeSnipppet = [codeSnipppet stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
        codeSnipppet = [codeSnipppet stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
        codeSnipppet = [codeSnipppet stringByReplacingOccurrencesOfString:@"\n" withString:@"  "];
        codeSnipppet = [codeSnipppet stringByReplacingOccurrencesOfString:@"\r" withString:@"  "];
        codeSnipppet = [codeSnipppet stringByReplacingOccurrencesOfString:@"\t" withString:@"  "];
        codeSnipppet = [codeSnipppet stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
        
        NSString *wrappedCode = [HTMLJSWrapper getWrapperForCodeSnippet:codeSnipppet];
        NSString *finalCode = [[NSString alloc] initWithString:wrappedCode];
        return finalCode;
    }
}

- (NSString *)getCodeSnippetFromDb {
    PriceCalculationDBService *dbService = [[PriceCalculationDBService alloc] init];
    return [dbService getPriceCodeSnippet:self.codeSnippetId];
}

#pragma mark End

#pragma mark -JSExecuterDelegate functions

- (void)eventOccured:(NSString *)eventName andParameter:(NSString *)jsonParameterString {
    
    @autoreleasepool {
        
        [self printLog:eventName];
        
        if ([eventName isEqualToString:@"console"]) {
            NSDictionary *paramDict =  [Utility getTheParameterFromUrlParameterString:jsonParameterString];
            NSString *message =  [paramDict objectForKey:@"msg"];
            [self printLog:message];
        }
        else  if ([eventName isEqualToString:@"pricebook"])  {
            NSString *responseRecieved =  [self.jsExecuter response:self.jsonRepresantation forEventName:eventName];
            self.jsonRepresantation = nil;
            NSDictionary *finalDictionary = [Utility objectFromJsonString:responseRecieved];
            [self updateTargetDataWithPriceResults:finalDictionary];
            
        } else  if ([eventName isEqualToString:@"showmessage"])  {
            NSDictionary *paramDict =  [Utility getTheParameterFromUrlParameterString:jsonParameterString];
            NSString *message =  [paramDict objectForKey:@"msg"];
            if (message != nil) {
                [self sendMessageToDelegate:message];
            }
        }
        
    }
}

- (BOOL)shouldDisplayMessage:(NSString *)message {
    /*
    message = [message lowercaseString];
    if ([StringUtil containsString:@" not " inString:message] || [StringUtil containsString:@" no " inString:message] || [StringUtil containsString:@" error " inString:message]) {
        return YES;
    }
     */
    return NO;
}

#pragma mark End

#pragma mark - Utility functions
- (void)printLog:(NSString *)log {
    NSLog(@"page event log : %@",log);
}

#pragma mark End

#pragma mark - update the results to delegate

- (void)updateTargetDataWithPriceResults:(NSDictionary *)priceResult {
    [self.targetHandler updateTargetSfpage:self.sfmPage fromPriceResults:priceResult];
    BOOL isStarted = [self startPageEventProcessWithParentView:nil];
    if (!isStarted) {
        self.targetHandler.targetDictionary = nil;
        self.targetHandler = nil;
        [self.managerDelegate pageEventProcessCalculationFinishedSuccessFully:self.sfmPage];
    }
}

- (void)sendMessageToDelegate:(NSString *)message {
    BOOL isStarted = [self startPageEventProcessWithParentView:nil];
    if (!isStarted) {
        self.targetHandler.targetDictionary = nil;
        self.targetHandler = nil;
        [self.managerDelegate shouldShowAlertMessageForPageEventProcess:message];
    }
}



@end
