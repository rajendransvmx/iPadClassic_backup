//
//  PriceCalculationManager.m
//  ServiceMaxiPhone
//
//  Created by Shravya shridhar on 6/17/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "PriceCalculationManager.h"
#import "JSExecuter.h"
#import "PriceCalculationDBService.h"
#import "PriceBookTargetHandler.h"
#import "SBJsonWriter.h"
#import "PriceBookDataHandler.h"
#import "HTMLJSWrapper.h"
#import "SBJsonParser.h"
#import "StringUtil.h"
#import "Utility.h"

@interface PriceCalculationManager()

@property(nonatomic,strong) SFMPage *currentPage;
@property(nonatomic,strong) JSExecuter *jsExecuter;
@property(nonatomic,strong) NSString *codeSnippetId;
@property(nonatomic,strong) UIView *parentView;
@property(nonatomic,strong) PriceBookTargetHandler *targetHandler;
@property(nonatomic,strong) NSString *jsonRepresantation;

- (void)printLog:(NSString *)log;
- (void)createJsExecuter:(NSString *)codeSnippet;
- (NSString *)getCodeSnippet;

@end

@implementation PriceCalculationManager

#pragma mark - Initialization
- (id)initWithCodeSnippetId:(NSString *)codeSnippetId
            andParentView:(UIView *)newParentView {
    self = [super init];
    if (self != nil) {
        self.codeSnippetId = codeSnippetId;
        self.parentView = newParentView;
    }
    return self;
}

- (void)beginPriceCalculationForTargetRecord:(SFMPage *)targetRecord{
    
    @autoreleasepool {
        self.currentPage = targetRecord;
        
        PriceBookTargetHandler *targetHandler = [[PriceBookTargetHandler alloc] initWithSFPage:targetRecord];
        self.targetHandler = targetHandler;
      PriceBookDataHandler *priceBook = [[PriceBookDataHandler alloc] initWithTargetDictionary:targetHandler.targetDictionary];
       
        NSDictionary *finalDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:targetHandler.targetDictionary,@"target",priceBook.priceBookInformation,@"data",nil];
        
        SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
        NSString *jsonString = [jsonWriter stringWithObject:finalDictionary];
        self.jsonRepresantation = jsonString;

        priceBook.priceBookInformation = nil;
       
       
        /*Load code snippet */
        NSString *codeSnippet = [self getCodeSnippet];
        [self createJsExecuter:codeSnippet];
    }
}

- (void)createJsExecuter:(NSString *)codeSnippet {
     self.jsExecuter = [[JSExecuter alloc] initWithParentView:self.parentView
                                               andCodeSnippet:codeSnippet
                                                  andDelegate:self];
    self.codeSnippetId = nil;
    self.parentView = nil;
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
    
//    NSError *error = nil;
//    NSString *filePath =[[NSBundle mainBundle] pathForResource:@"temp" ofType:@"js"];
//    return [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
}

#pragma mark End

#pragma mark -JSExecuterDelegate functions

- (void)eventOccured:(NSString *)eventName
        andParameter:(NSString *)jsonParameterString {
    
    @autoreleasepool {
        [self printLog:eventName];
        
        if ([eventName isEqualToString:@"console"]) {
            NSDictionary *paramDict =  [Utility getTheParameterFromUrlParameterString:jsonParameterString];
            NSString *message =  [paramDict objectForKey:@"msg"];
            BOOL shouldDisplay = [self shouldDisplayMessage:message];
            if (shouldDisplay) {
                /* Ask delegate to show the message*/
                [self sendMessageToDelegate:message];
            }
            else{
                [self printLog:message];
            }
        }
        else  if ([eventName isEqualToString:@"pricebook"])  {
            
            NSString *responseRecieved =  [self.jsExecuter response:self.jsonRepresantation forEventName:eventName];
            self.jsonRepresantation = nil;
            SBJsonParser *jsonParser =  [[SBJsonParser alloc] init];
            NSDictionary *finalDictionary = [jsonParser objectWithString:responseRecieved];
            [self updateTargetDataWithPriceResults:finalDictionary];
            NSLog(@" Price calculation finished successfully");
            
            /*Call delegate to update the results */
        } else  if ([eventName isEqualToString:@"showmessage"])  {
            
            NSDictionary *paramDict =  [Utility getTheParameterFromUrlParameterString:jsonParameterString];
            NSString *message =  [paramDict objectForKey:@"msg"];
            
            if (message != nil) {
                /* Ask delegate to show the message*/
                [self sendMessageToDelegate:message];
            }
        }
    }
    
    
}

- (BOOL)shouldDisplayMessage:(NSString *)message {
    message = [message lowercaseString];
    if ([StringUtil containsString:@" not " inString:message] || [StringUtil containsString:@" no " inString:message] || [StringUtil containsString:@" error " inString:message]) {
        return YES;
    }
    return NO;
}

#pragma mark End

#pragma mark - Utility functions
- (void)printLog:(NSString *)log {
    NSLog(@" Get Price : %@",log);
}

#pragma mark End

#pragma mark - update the results to delegate

- (void)updateTargetDataWithPriceResults:(NSDictionary *)priceResult {
    [self.targetHandler updateTargetSfpage:self.currentPage fromPriceResults:priceResult];
    self.targetHandler.targetDictionary = nil;
    self.targetHandler = nil;
    [self.managerDelegate priceCalculationFinishedSuccessFully:self.currentPage];
}

- (void)sendMessageToDelegate:(NSString *)message {
    [self.managerDelegate shouldShowAlertMessage:message];
}

#pragma mark End
#pragma mark End
@end
