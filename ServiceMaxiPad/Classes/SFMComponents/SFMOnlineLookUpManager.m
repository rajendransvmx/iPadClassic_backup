//
//  SFMOnlineLookUpManager.m
//  ServiceMaxiPad
//
//  Created by Admin on 05/09/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "SFMOnlineLookUpManager.h"
#import "SFMPageLookUpHelper.h"
#import "SFMLookUp.h"
#import "TaskModel.h"
#import "TaskManager.h"
#import "TaskGenerator.h"
#import "RequestParamModel.h"
#import "SFNamedSearchComponentModel.h"
#import "CacheManager.h"
#import "WebserviceResponseStatus.h"

@interface SFMOnlineLookUpManager ()
@property (nonatomic, strong) SFMPageLookUpHelper * lookUpHelper;
@property (nonatomic, strong) SFMLookUp *lookUpObject;
@property (nonatomic, strong) NSString *searchText;
@property (nonatomic, strong) NSString *taskIdentifier;


@end

@implementation SFMOnlineLookUpManager

#pragma mark - Online seach methods

- (void)performOnlineLookUpWithLookUpObject:(SFMLookUp *)lookUpObj
                               andSearchText:(NSString *)searchText {
    
    
    self.searchText = searchText;
    self.lookUpObject = lookUpObj;
    [self removeAllCacheData];
    [self initiateSearchResultWebService];
    
 
}

-(void)removeAllCacheData {
    
    //TODO: This is Not working YET.
    [[CacheManager sharedInstance] clearCacheByKey:@""];
}

- (void)initiateSearchResultWebService
{
    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeSFMSearch
                                             requestParam:[self getRequestParameterForSearchResult]
                                           callerDelegate:self];
    self.taskIdentifier = taskModel.taskId;
    [[TaskManager sharedInstance] addTask:taskModel];
}

- (void)cancelAllPreviousOperations {
    @synchronized([self class]){
        self.lookUpObject = nil;
        [[TaskManager  sharedInstance] cancelFlowNodeWithId:self.taskIdentifier];
    }
}

#pragma mark - flownode delegate
- (void)flowStatus:(id)status
{
    @synchronized([self class]){
        if([status isKindOfClass:[WebserviceResponseStatus class]])
        {
            WebserviceResponseStatus *webServiceStatus = (WebserviceResponseStatus*)status;
            if (webServiceStatus.syncStatus == SyncStatusSuccess) {
             //   NSDictionary *dataDictionary = [[CacheManager sharedInstance] getCachedObjectByKey:kSFMSearchCacheId];
              //  [self onlineSearchSuccessfullwithResponseData:[NSMutableDictionary dictionaryWithDictionary:dataDictionary]];
            } else if (webServiceStatus.syncStatus == SyncStatusFailed)
            {
              //  [self onlineSearchFailedWithError:webServiceStatus.syncError];
            }
        }
    }
}

- (RequestParamModel*)getRequestParameterForSearchResult
{
    
    NSMutableArray *valueMapArray = [[NSMutableArray alloc]init];
    RequestParamModel *requestParamModel = [[RequestParamModel alloc]init];
    
    // INNER-MOST Level START--
    NSMutableArray *searchFieldArray = [[NSMutableArray alloc] init];
    for (SFNamedSearchComponentModel *searchObjectmodel in self.lookUpObject.searchFields) {
        NSMutableDictionary *searchObjectDict = [[NSMutableDictionary alloc]init];
        [searchObjectDict setValue:[NSNumber numberWithDouble:searchObjectmodel.sequence] forKey:@"sequence"];
        [searchObjectDict setValue:@"" forKey:@"refObjectNameField"];
        [searchObjectDict setValue:@"" forKey:@"refObjectName"];
        [searchObjectDict setValue:searchObjectmodel.expressionType forKey:@"operandType"];
        [searchObjectDict setValue:searchObjectmodel.fieldRelationshipName forKey:@"fieldRelationshipName"];
        [searchObjectDict setValue:searchObjectmodel.fieldDataType forKey:@"dataType"];
        [searchObjectDict setValue:searchObjectmodel.fieldName forKey:@"apiName"];

        [searchFieldArray addObject:searchObjectDict];
    }
    
    NSMutableArray *displayFieldArray = [[NSMutableArray alloc] init];
    for (SFNamedSearchComponentModel *searchObjectmodel in self.lookUpObject.displayFields) {
        NSMutableDictionary *displayObjectDict = [[NSMutableDictionary alloc]init];
        [displayObjectDict setValue:[NSNumber numberWithDouble:searchObjectmodel.sequence] forKey:@"sequence"];
        [displayObjectDict setValue:@"" forKey:@"refObjectNameField"];
        [displayObjectDict setValue:@"" forKey:@"refObjectName"];
        [displayObjectDict setValue:searchObjectmodel.expressionType forKey:@"operandType"];
        [displayObjectDict setValue:searchObjectmodel.fieldRelationshipName forKey:@"fieldRelationshipName"];
        [displayObjectDict setValue:searchObjectmodel.fieldDataType forKey:@"dataType"];
        [displayObjectDict setValue:searchObjectmodel.fieldName forKey:@"apiName"];
        
        [displayFieldArray addObject:displayObjectDict];
    }
    
    NSMutableDictionary *lookupDefDetailDict = [[NSMutableDictionary alloc]init];
    [lookupDefDetailDict setValue:searchFieldArray forKey:@"searchFields"];
    [lookupDefDetailDict setValue:displayFieldArray forKey:@"displayFields"];

//    [lookupDefDetailDict setValue: forKey:@"queryColumns"]; //TODO:Check- Should "Id" be always be included by default.
//    [lookupDefDetailDict setValue: forKey:@"preFilterCriteria"]; //TODO:Check- is it prepared using "defaultLookupColumn". eg. "Name LIKE 'San%'"
    [lookupDefDetailDict setValue:[NSNumber numberWithLong:self.lookUpObject.recordLimit] forKey:@"numberOfRecs"];
    [lookupDefDetailDict setValue:@"" forKey:@"formFillFields"];
    [lookupDefDetailDict setValue:self.lookUpObject.defaultColoumnName forKey:@"defaultLookupColumn"];

    // INNER-MOST Level END--

     // INNER-MOST Level-1 START--
    
    NSMutableDictionary *lLookupDefDict = [[NSMutableDictionary alloc]init];
    [lLookupDefDict setValue:lookupDefDetailDict forKey:@"lookupDefDetail"];
    [lLookupDefDict setValue:self.lookUpObject.objectName forKey:@"lookUpObject"];
    [lLookupDefDict setValue:self.lookUpObject.lookUpId forKey:@"key"]; //TODO:Check IF THis the ID required.
    [lLookupDefDict setValue:@[] forKey:@"advFilters"]; //TODO:Check IF the advance filter has to be sent or not. If it has to be sent what will be the structure.

    // INNER-MOST Level-1 END--

    // INNER-MOST Level-2 START--
    NSMutableDictionary *llookupRequestDict = [[NSMutableDictionary alloc]init];
    [llookupRequestDict setValue:lLookupDefDict forKey:@"LookupDef"];
    [llookupRequestDict setValue:self.lookUpObject.serachName forKey:@"KeyWord"]; //TODO:Check IF THis is correct?
    [llookupRequestDict setValue:@"contains" forKey:@"Operator"];   //TODO:Check IF THis will always be contains.
    // INNER-MOST Level-2 END--

    //OUTER-MOST Level START---
    NSMutableDictionary *lOuterMostLevelRequestDict = [[NSMutableDictionary alloc]init];
    [lOuterMostLevelRequestDict setValue:llookupRequestDict forKey:@"lookupRequest"];
    [lOuterMostLevelRequestDict setValue:@"" forKey:@"docTemplate"];
    [lOuterMostLevelRequestDict setValue:@"" forKey:@"fieldUpdateRuleInfoList"];
    [lOuterMostLevelRequestDict setValue:@"" forKey:@"fieldsToNull"];
    [lOuterMostLevelRequestDict setValue:@"" forKey:@"bizRuleInfo"];
    [lOuterMostLevelRequestDict setValue:@"" forKey:@"groupId"];
    //OUTER-MOST Level END---

    requestParamModel.valueMap = [NSArray arrayWithArray:valueMapArray];
     
    
    return requestParamModel;
}

@end
