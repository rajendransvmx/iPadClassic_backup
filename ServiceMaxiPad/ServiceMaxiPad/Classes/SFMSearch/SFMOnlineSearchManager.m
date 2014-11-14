//
//  SFMOnlineSearchManager.m
//  ServiceMaxiPad
//
//  Created by Shubha S on 12/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "SFMOnlineSearchManager.h"
#import "TaskModel.h"
#import "TaskManager.h"
#import "TaskGenerator.h"
#import "RequestParamModel.h"
#import "SFMSearchObjectModel.h"
#import "RequestConstants.h"
#import "WebserviceResponseStatus.h"
#import "CacheManager.h"
#import "CacheConstants.h"
#import "TransactionObjectModel.h"
#import "SFMRecordFieldData.h"
#import "SFMSearchDataHandler.h"
#import "StringUtil.h"
#import "SFMSearchFieldModel.h"

@interface SFMOnlineSearchManager()

@property(nonatomic,strong)SFMSearchProcessModel *searchProcessModel;
@property(nonatomic,strong)NSString *searchText;
@property(nonatomic,strong)NSString *taskIdentifier;
- (void)updateLocalIdsInOnlineData:(NSMutableDictionary *)onlineDataDictionary;

@end
@implementation SFMOnlineSearchManager

#pragma mark - Online seach methods
- (void)performOnlineSearchWithSearchProcess:(SFMSearchProcessModel *)searchProcess
                             andSearchText:(NSString *)searchText {
    
   
    self.searchText = searchText;
    self.searchProcessModel = searchProcess;
    
    [self initiateSearchResultWebService];
    
    /* Initiated online search API */
    
}

#pragma mark End


- (void)initiateSearchResultWebService
{
    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeSFMSearch
                                             requestParam:[self getRequestParameterForSearchResult]
                                           callerDelegate:self];
    self.taskIdentifier = taskModel.taskId;
    [[TaskManager sharedInstance] addTask:taskModel];
}


- (RequestParamModel*)getRequestParameterForSearchResult
{
    NSMutableArray *valueMapArray = [[NSMutableArray alloc]init];
    RequestParamModel *requestParamModel = [[RequestParamModel alloc]init];
    NSMutableDictionary *searchProcessIdDict = [[NSMutableDictionary alloc]init];
    [searchProcessIdDict setValue:kSFMSearchProcessId forKey:kSVMXKey];
    [searchProcessIdDict setValue:self.searchProcessModel.identifier forKey:kSVMXValue];
    [valueMapArray addObject:searchProcessIdDict];
    
    NSMutableDictionary *searchOperatorDict = [[NSMutableDictionary alloc]init];
    [searchOperatorDict setValue:kSFMSearchOperator forKey:kSVMXKey];
    [searchOperatorDict setValue:@"Contains" forKey:kSVMXValue];
    [valueMapArray addObject:searchOperatorDict];
    
    NSMutableDictionary *keyWordDict = [[NSMutableDictionary alloc]init];
    [keyWordDict setValue:kSFMSearchKeyword forKey:kSVMXKey];
    [keyWordDict setValue:self.searchText forKey:kSVMXValue];
    [valueMapArray addObject:keyWordDict];
    
    for (SFMSearchObjectModel *searchObjectmodel in self.searchProcessModel.searchObjects) {
        NSMutableDictionary *searchObjectDict = [[NSMutableDictionary alloc]init];
        [searchObjectDict setValue:kSFMSearchObjectId forKey:kSVMXKey];
        [searchObjectDict setValue:searchObjectmodel.objectId forKey:kSVMXValue];
        [valueMapArray addObject:searchObjectDict];
    }
    
    NSMutableDictionary *recordLimitDict = [[NSMutableDictionary alloc]init];
    [recordLimitDict setValue:kSFMSearchRecordLimit forKey:kSVMXKey];
    [recordLimitDict setValue:@"100" forKey:kSVMXValue];
    [valueMapArray addObject:recordLimitDict];
    
    requestParamModel.valueMap = [NSArray arrayWithArray:valueMapArray];
    return requestParamModel;
}

#pragma mark - flownode delegate
- (void)flowStatus:(id)status
{
    if([status isKindOfClass:[WebserviceResponseStatus class]])
    {
        WebserviceResponseStatus *webServiceStatus = (WebserviceResponseStatus*)status;
        if (webServiceStatus.syncStatus == SyncStatusSuccess) {
            NSDictionary *dataDictionary = [[CacheManager sharedInstance] getCachedObjectByKey:kSFMSearchCacheId];
            [self onlineSearchSuccessfullwithResponseData:[NSMutableDictionary dictionaryWithDictionary:dataDictionary]];
        } else if (webServiceStatus.syncStatus == SyncStatusFailed)
        {
            [self onlineSearchFailedWithError:webServiceStatus.syncError];
        }
    }
}

#pragma mark - Online Search completion methods

- (void)onlineSearchSuccessfullwithResponseData:(NSMutableDictionary *)dataDictionary {
    dataDictionary = [self processOnlineSearchResponseData:dataDictionary];
    [self updateLocalIdsInOnlineData:dataDictionary];
    [self.viewControllerDelegate onlineSearchSuccessfullwithResponse:dataDictionary forSearchProcess:self.searchProcessModel andSearchText:self.searchText];
}

- (void)onlineSearchFailedWithError:(NSError *)error {
    [self.viewControllerDelegate onlineSearchFailedwithError:error forSearchProcess:self.searchProcessModel];
}


-(NSMutableDictionary *)processOnlineSearchResponseData:(NSMutableDictionary *)dataDictionary {
    @autoreleasepool {
        NSMutableDictionary *processedResponseDict = [NSMutableDictionary dictionary];
        NSString *emptyString = @"--";
        
        for (NSString *objectId in dataDictionary) {
            
            SFMSearchObjectModel *objectModel = [self getSearchObjectModelForObjectId:objectId];
            NSArray *serverRecordsArray = [dataDictionary objectForKey:objectId];
            
            for (NSDictionary *serverRecordDict in serverRecordsArray) {
                
                NSMutableDictionary *modelDictionary = [NSMutableDictionary dictionary];
                NSArray *serverFieldsArray = [serverRecordDict objectForKey:kSVMXSVMXMap];
                
                for (int index = 0; index < [serverFieldsArray count]; index++) {
                    NSDictionary *serverFieldModel = [serverFieldsArray objectAtIndex:index];
                    SFMSearchFieldModel *fieldModel = [objectModel.displayFields objectAtIndex:index];
                    
                    NSString *fieldName = fieldModel.fieldName;
                    
                    NSString *displayValue = [serverFieldModel objectForKey:kSVMXValue];
                    if (![StringUtil isStringNotNULL:displayValue] || [displayValue isEqualToString:emptyString]) {
                        displayValue = @"";
                    }
                    
                    NSString *internalValue = displayValue;
                    
                    if ([fieldModel.displayType isEqualToString:@"Reference"]) {
                        NSArray *fieldValueMap = [serverFieldModel objectForKey:kSVMXSVMXMap];
                        if (![StringUtil isStringEmpty:internalValue] && [fieldValueMap count] > 0) {
                            NSDictionary *referenceDict = [fieldValueMap firstObject];
                            if ([[referenceDict objectForKey:kSVMXKey] isEqualToString:@"Reference"]) {
                                internalValue = [referenceDict valueForKey:kSVMXValue];
                            }
                        }
                    }
                    
                    SFMRecordFieldData *recordField = [[SFMRecordFieldData alloc] initWithFieldName:fieldName value:internalValue andDisplayValue:displayValue];
                    
                    NSString *fieldNameKey = [fieldModel getDisplayField];
                    [modelDictionary setObject:recordField forKey:fieldNameKey];
                }
                
                NSString *sfid = [serverRecordDict objectForKey:kId];
                SFMRecordFieldData *fieldData = [[SFMRecordFieldData alloc] initWithFieldName:kId value:sfid andDisplayValue:sfid];
                
                [modelDictionary setObject:fieldData forKey:kId];
                
                TransactionObjectModel *transObjectModel = [[TransactionObjectModel alloc] init];
                [transObjectModel mergeFieldValueDictionaryForFields:modelDictionary];
                
                NSMutableArray *processedArray = nil;
                
                if ([processedResponseDict count] == 0) {
                    processedArray = [NSMutableArray arrayWithObject:transObjectModel];
                }
                else {
                    NSArray *existingRecords = [processedResponseDict objectForKey:objectId];
                    if (existingRecords == nil || [existingRecords count] == 0) {
                        processedArray = [NSMutableArray arrayWithObject:transObjectModel];
                    }
                    else {
                        processedArray = [NSMutableArray arrayWithArray:existingRecords];
                        [processedArray addObject:transObjectModel];
                    }
                }
                
                [processedResponseDict setObject:processedArray forKey:objectId];
            }
        }
        
        return processedResponseDict;
    }
}


-(SFMSearchObjectModel *)getSearchObjectModelForObjectId:(NSString *)objectId {
    SFMSearchObjectModel *model = nil;
    NSArray *filteredArray = [self.searchProcessModel.searchObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"objectId == [c] %@", objectId]];
    if ([filteredArray count] == 1) {
        model = [filteredArray firstObject];
    }
    return model;
}

#pragma mark End

#pragma mark - Update local Ids
- (void)updateLocalIdsInOnlineData:(NSMutableDictionary *)onlineDataDictionary {
    for (SFMSearchObjectModel *searchObject in self.searchProcessModel.searchObjects) {
        
        NSMutableArray *allIdsArray = [[NSMutableArray alloc] init];
        NSArray *allRecords = [onlineDataDictionary objectForKey:searchObject.objectId];
        for (TransactionObjectModel *transactionModel in allRecords) {
           NSDictionary *valueDictionary =  [transactionModel getFieldValueDictionary];
            SFMRecordFieldData *fieldData = [valueDictionary objectForKey:kId];
            if (fieldData.internalValue != nil) {
                [allIdsArray addObject:fieldData.internalValue];
            }
        }
        SFMSearchDataHandler *dataHandler = [[SFMSearchDataHandler alloc]init];
        NSDictionary *allIdsDictionary = [dataHandler getSfidVsLocalIdDictionaryForSFids:allIdsArray andObjectName:searchObject.targetObjectName];
        for (TransactionObjectModel *transactionModel in allRecords) {
            NSMutableDictionary *valueDictionary =  (NSMutableDictionary *)[transactionModel getFieldValueDictionary];
            SFMRecordFieldData *fieldData = [valueDictionary objectForKey:kId];
            if (fieldData.internalValue != nil) {
                NSString *localId =  [allIdsDictionary objectForKey:fieldData.internalValue];
                if (localId.length > 30) {
                    SFMRecordFieldData *fieldData = [[SFMRecordFieldData alloc] initWithFieldName:kLocalId value:localId andDisplayValue:localId];
                    [valueDictionary setObject:fieldData forKey:kLocalId];
                }
            }
        }
    }
}

#pragma mark - End


@end
