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
#import "SFMRecordFieldData.h"
#import "TransactionObjectDAO.h"
#import "FactoryDAO.h"
#import "SFMPageEditHelper.h"
#import "SFMPageEditManager.h"
#import "ModifiedRecordModel.h"
#import "DatabaseConstant.h"
#import "StringUtil.h"

@interface PageEventProcessManager ()<JSExecuterDelegate>

@property (nonatomic, strong) SFMPage *sfmPage;
@property (nonatomic, strong) NSDictionary *beforeSaveProcessDict, *afterSaveProcessDict;
@property (nonatomic, strong) NSString *codeSnippetId;
@property (nonatomic, strong) UIView *parentView;
@property (nonatomic, strong) JSExecuter *jsExecuter;
@property (nonatomic, strong) NSString *jsonRepresantation;
@property (nonatomic, strong) PriceBookTargetHandler *targetHandler;

@property (nonatomic, assign) BOOL isWebservice;
@property (nonatomic, assign) BOOL isBeforeSaveUpdate;
@property (nonatomic, assign) BOOL isAfterSaveUpdate;
@property (nonatomic, assign) BOOL isAfterSaveInsert;


@end

@implementation PageEventProcessManager

-(id)initWithSFMPage:(SFMPage *)aSfmPage {
    self = [super init];
    if (self) {
        self.sfmPage = aSfmPage;
    }
    return self;
}

-(BOOL)isWebserviceEnabled;
{
    return self.isWebservice;
}

-(BOOL)isAfterSaveInsertEnabled
{
    return  self.isAfterSaveInsert = YES;
}

-(BOOL)isBeforeSaveEnabled
{
    return self.isBeforeSaveUpdate;
}

-(BOOL)isAfterSaveUpdateEnabled
{
    return  self.isAfterSaveUpdate = YES;
}

-(BOOL)pageEventProcessExists {
    BOOL pageEventExists = NO;
    
//    SFMPage *page = [self getTheSFMPage];
    NSArray *pageLevelEvents = self.sfmPage.process.pageLayout.headerLayout.pageLevelEvents;
    NSArray *filteredArray = [pageLevelEvents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(%K CONTAINS[c] %@) OR (%K CONTAINS[c] %@) OR (%K CONTAINS[c] %@)", kPageEventType, kBeforeSaveProcessKey, kPageEventType, kAfterSaveProcessKey, kPageEventType, kAfterSaveInsertKey]];
    
    if (self.sfmPage.customWebserviceOptionsArray) {
        self.sfmPage.customWebserviceOptionsArray = nil;
    }
    self.sfmPage.customWebserviceOptionsArray = [[NSMutableArray alloc] init];

    self.isWebservice = NO;

    for (NSDictionary *tempDict in filteredArray) {
        NSString *eventCallType = [tempDict objectForKey:kPageEventCallType];
        NSString *eventType = [tempDict objectForKey:kPageEventType];

        if ([eventCallType isEqualToString:@"JAVASCRIPT"]) {

            if ([StringUtil containsString:kBeforeSaveProcessKey inString:eventType]) {
                self.beforeSaveProcessDict = tempDict;
                pageEventExists = YES;
            }
//            if ([eventType containsString:kAfterSaveProcessKey]) {
                if ([StringUtil containsString:kAfterSaveProcessKey inString:eventType]) {

                self.afterSaveProcessDict = tempDict;
                pageEventExists = YES;
            }
        }
        else if ([eventCallType isEqualToString:kWebserviceProcessKey]) {
            self.isWebservice = YES;

//            if ([eventType containsString:kBeforeSaveProcessKey]) {
                if ([StringUtil containsString:kBeforeSaveProcessKey inString:eventType]) {

                [self.sfmPage.customWebserviceOptionsArray addObject:kModificationTypeBeforeUpdate];
            }
//            if ([eventType containsString:kAfterSaveProcessKey]) {
                if ([StringUtil containsString:kAfterSaveProcessKey inString:eventType]) {

                [self.sfmPage.customWebserviceOptionsArray addObject:kModificationTypeAfterUpdate];

            }
//            if ([eventType containsString:kAfterSaveInsertKey]) {
                if ([StringUtil containsString:kAfterSaveInsertKey inString:eventType]) {

                [self.sfmPage.customWebserviceOptionsArray addObject:kModificationTypeAfterInsert];

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



#pragma Webservice Delegate

/*
-(void)returnCallFromBeforeSaveCall:(NSDictionary *)result
{
    [self.targetHandler updateTargetSfpage:self.sfmPage fromPriceResults:result];
    [self.managerDelegate customCallResponseFromServerFinished:self.sfmPage forCustomCall:beforeSaveUpdate];
}

-(void)returnCallFromAfterInsertCall:(NSDictionary *)result
{
    [self.targetHandler updateTargetSfpage:self.sfmPage fromPriceResults:result];
    [self.managerDelegate customCallResponseFromServerFinished:self.sfmPage forCustomCall:afterSaveInsert];
}

-(void)returnCallFromAfterSaveUpdateCall:(NSDictionary *)result
{
    [self.targetHandler updateTargetSfpage:self.sfmPage fromPriceResults:result];
    [self.managerDelegate customCallResponseFromServerFinished:self.sfmPage forCustomCall:afterSaveUpdate];
}
*/

/*
-(void)headerRecord
{
    NSDictionary *headerDict = self.sfmPage.headerRecord;
    NSString *headerSfid = [self.sfmPage getHeaderSalesForceId];
    BOOL recordUpdatedSuccessFully = NO;
    if (headerSfid.length < 5)
    {
        
        id <TransactionObjectDAO> transObjectService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
        // Check if record exist
        BOOL isRecordExist =  [transObjectService isRecordExistsForObject:self.sfmPage.objectName forRecordLocalId:self.sfmPage.recordId];
        if (isRecordExist) {
            
            //IT is update
            //TODO:
        }
        else{
            //It is Insert
        //TODO:
        }
        
    }
    else {
        //It is Update
        //TODO:
    }

    NSMutableDictionary *eachRecord = [NSMutableDictionary new];
    for (NSString *fieldName in self.sfmPage.headerRecord) {  //For Insert
        SFMRecordFieldData *fieldValue = [self.sfmPage.headerRecord objectForKey:fieldName];
        if ([fieldName isEqualToString:kId]) {
            continue;
        }
        if (fieldValue.internalValue != nil) {
            [eachRecord setObject:fieldValue.internalValue forKey:fieldName];
        }
    }
    
    for (NSString *fieldName in self.sfmPage.headerRecord) {  //For Update
        SFMRecordFieldData *fieldValue = [self.sfmPage.headerRecord objectForKey:fieldName];
        if (fieldValue.internalValue != nil) {
            [eachRecord setObject:fieldValue.internalValue forKey:fieldName];
        }
        
    }

    
}

-(void)childItem
{

    NSMutableArray *lChildLinesRecordArray = [NSMutableArray alloc];
    
    NSDictionary * processComponents = self.sfmPage.process.component;
    NSArray * allDetailProcessComponents = [processComponents allKeys];

    for(NSString * processCompId in allDetailProcessComponents)
    {
        NSMutableArray * detailRecordsArray = [self.sfmPage.detailsRecord objectForKey:processCompId];
        
        
        NSMutableArray * newlyCreatedRecordIds = [self.sfmPage.newlyCreatedRecordIds objectForKey:processCompId];

        for (NSMutableDictionary * eachDetailDict in detailRecordsArray)
        {
        NSMutableDictionary *lDetailsRecordDictionary = [[NSMutableDictionary alloc] init];

        SFMRecordFieldData * localIdField = [eachDetailDict objectForKey:kLocalId];

        if([newlyCreatedRecordIds containsObject:localIdField.internalValue])
        {
            //Insert record into object table

        }
        else{
            //Update record into object table
            
        }
            SFProcessComponentModel * processComponent = [processComponents objectForKey:processCompId];

            NSDictionary *fieldTyDictionary =  [SFMPageEditHelper getObjectFieldInfoByType: processComponent.objectName];
            for (NSString *eachFieldName in fieldTyDictionary)
            {
                NSString *fieldType = [fieldTyDictionary objectForKey:eachFieldName];
                if ([fieldType isEqualToString:kSfDTBoolean]) {
                    [lDetailsRecordDictionary setObject:kFalse forKey:eachFieldName];
                }
            }
            
            for (NSString *fieldName in eachDetailDict)
            {
                SFMRecordFieldData *fieldValue = [eachDetailDict objectForKey:fieldName];
                if (fieldValue.internalValue != nil) {
                    [lDetailsRecordDictionary setObject:fieldValue.internalValue forKey:fieldName];
                }
            }
            [lChildLinesRecordArray addObject:lDetailsRecordDictionary];
        }
    }
}
*/

-(SFMPage *)getTheSFMPage
{
    SFMPageEditManager *manager = [[SFMPageEditManager alloc] initWithObjectName:self.sfmPage.objectName recordId:self.sfmPage.recordId processSFId:self.sfmPage.process.processInfo.sfID];
    
   SFMPage *page = [manager theSFMPagewithObjectName:self.sfmPage.objectName andRecordID:self.sfmPage.recordId  andProcessID:self.sfmPage.process.processInfo.sfID];
    
    return page;
}

 

-(void)deleteTheRecordsFromModifiedTable
{
    //From OneCallDataSyncHelper.
  
    /*
     
    DBCriteria *aCriteria1 = [[DBCriteria alloc] initWithFieldName:kLocalId operatorType:SQLOperatorLessThanEqualTo andFieldValue: [[NSString alloc] initWithFormat:@"%ld",(long)lastIndex]];
    DBCriteria *aCriteria2 = [[DBCriteria alloc] initWithFieldName:@"operation" operatorType:SQLOperatorEqual andFieldValue:modificationType];
    DBCriteria *aCriteria3 = [[DBCriteria alloc] initWithFieldName:searchField operatorType:SQLOperatorIn andFieldValues:recordIds];
    
    DBRequestDelete *deleteRequest = [[DBRequestDelete alloc] initWithTableName:kModifiedRecords whereCriteria:@[aCriteria1,aCriteria2,aCriteria3] andAdvanceExpression:@"(1 and 2 and 3)"];
    
    
    [self.commonServices executeStatement:[deleteRequest query]];
*/
}
@end
