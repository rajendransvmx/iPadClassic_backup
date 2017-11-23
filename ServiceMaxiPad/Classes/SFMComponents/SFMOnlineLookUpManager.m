//
//  SFMOnlineLookUpManager.m
//  ServiceMaxiPad
//
//  Created by Admin on 05/09/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "SFMOnlineLookUpManager.h"
#import "SFMLookUp.h"
#import "TaskModel.h"
#import "TaskManager.h"
#import "TaskGenerator.h"
#import "RequestParamModel.h"
#import "SFNamedSearchComponentModel.h"
#import "CacheManager.h"
#import "WebserviceResponseStatus.h"
#import "Utility.h"
#import "DBCriteria.h"
#import "SFExpressionComponentDAO.h"
#import "FactoryDAO.h"
#import "SFExpressionComponentModel.h"
#import "CacheConstants.h"
#import "SFObjectFieldModel.h"
#import "SFNamedSearchFilterDAO.h"

#import "StringUtil.h"
#import "SFMRecordFieldData.h"
#import "PlistManager.h"
#import "SFMPageHelper.h"
#import "DataTypeUtility.h"

@interface SFMOnlineLookUpManager ()
//@property (nonatomic, strong) SFMPageLookUpHelper * lookUpHelper;
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
    [[CacheManager sharedInstance] clearCacheByKey:kSFMOnlineLookUpCacheData];
}



- (void)initiateSearchResultWebService
{
    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeLookupSearch
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
                NSMutableArray *dataOnlineDataArray = [[CacheManager sharedInstance] getCachedObjectByKey:kSFMOnlineLookUpCacheData];
                
                if (self.delegate != nil && [self.delegate respondsToSelector:@selector(onlineLookupSearchSuccessfullwithResponse:)]) {
                    [self.delegate onlineLookupSearchSuccessfullwithResponse:dataOnlineDataArray];
                }
                
            } else if (webServiceStatus.syncStatus == SyncStatusFailed)
            {
                if (self.delegate != nil && [self.delegate respondsToSelector:@selector(onlineLookupSearchFailedwithError:)]) {
                    [self.delegate onlineLookupSearchFailedwithError:webServiceStatus.syncError];
                }
            }
        }
    }
}


- (RequestParamModel*)getRequestParameterForSearchResult
{
    
    RequestParamModel *requestParamModel = [[RequestParamModel alloc]init];
    
    // INNER-MOST Level START--
    NSMutableArray *searchFieldArray = [[NSMutableArray alloc] init];
    for (SFNamedSearchComponentModel *searchObjectmodel in self.lookUpObject.searchFields) {
        NSMutableDictionary *searchObjectDict = [[NSMutableDictionary alloc]init];
        
        SFObjectFieldModel *objectFieldModel = [self.lookUpObject.fieldInfoDict objectForKey:searchObjectmodel.fieldName];
        [searchObjectDict setValue:objectFieldModel.referenceTo forKey:@"refObjectName"];
        [searchObjectDict setValue:[NSNumber numberWithDouble:searchObjectmodel.sequence] forKey:@"sequence"];
        [searchObjectDict setValue:searchObjectmodel.keyNameField forKey:@"refObjectNameField"];
        [searchObjectDict setValue:searchObjectmodel.expressionType forKey:@"operandType"];
        [searchObjectDict setValue:searchObjectmodel.fieldRelationshipName forKey:@"fieldRelationshipName"];
        [searchObjectDict setValue:searchObjectmodel.fieldDataType forKey:@"dataType"];
        [searchObjectDict setValue:searchObjectmodel.fieldName forKey:@"apiName"];
        
        [searchFieldArray addObject:searchObjectDict];
    }
    
    NSMutableArray *displayFieldArray = [[NSMutableArray alloc] init];
    NSMutableArray *displayFieldForQueryColumnArray  = [[NSMutableArray alloc] initWithObjects:@"Id", nil]; // Id always by default.
    for (SFNamedSearchComponentModel *searchObjectmodel in self.lookUpObject.displayFields) {
        NSMutableDictionary *displayObjectDict = [[NSMutableDictionary alloc]init];
        
        SFObjectFieldModel *objectFieldModel = [self.lookUpObject.fieldInfoDict objectForKey:searchObjectmodel.fieldName];
        [displayObjectDict setValue:objectFieldModel.referenceTo forKey:@"refObjectName"];
        [displayObjectDict setValue:[NSNumber numberWithDouble:searchObjectmodel.sequence] forKey:@"sequence"];
        [displayObjectDict setValue:searchObjectmodel.keyNameField forKey:@"refObjectNameField"];
        [displayObjectDict setValue:searchObjectmodel.expressionType forKey:@"operandType"];
        [displayObjectDict setValue:searchObjectmodel.fieldRelationshipName forKey:@"fieldRelationshipName"];
        [displayObjectDict setValue:searchObjectmodel.fieldDataType forKey:@"dataType"];
        [displayObjectDict setValue:searchObjectmodel.fieldName forKey:@"apiName"];
        
        if (![displayFieldForQueryColumnArray containsObject:searchObjectmodel.fieldName]) {
            [displayFieldForQueryColumnArray addObject:searchObjectmodel.fieldName];
        }
        NSString *fieldRelationshipName = nil;
        
        if ([searchObjectmodel.fieldRelationshipName length] > 0 && [searchObjectmodel.keyNameField length] > 0)
        {
            fieldRelationshipName = [NSString stringWithFormat:@"%@.%@",searchObjectmodel.fieldRelationshipName,searchObjectmodel.keyNameField];
        }
        
        if (![displayFieldForQueryColumnArray containsObject:fieldRelationshipName] && [fieldRelationshipName length] > 0) {
            [displayFieldForQueryColumnArray addObject:fieldRelationshipName];
        }
        
        
        [displayFieldArray addObject:displayObjectDict];
    }
    
    //Get field relationship name for defaultColumn and defaultObjectColumnName.
    
    for (SFObjectFieldModel *objectField in self.lookUpObject.defaultColumsnFieldRelationships) {
        
        
        if ([objectField.type isEqualToString:kSfDTReference] && objectField.referenceTo != nil) {
            NSString *keyFieldName = [SFMPageHelper getNameFieldForObject:objectField.referenceTo];
            NSString *fieldRelationshipName = nil;
            if ([objectField.relationName length] > 0 && [keyFieldName length] > 0)
            {
                fieldRelationshipName = [NSString stringWithFormat:@"%@.%@",objectField.relationName,keyFieldName];
                if (![displayFieldForQueryColumnArray containsObject:fieldRelationshipName] ) {
                    [displayFieldForQueryColumnArray addObject:fieldRelationshipName];
                }
            }
        }
        
    }
    if (![displayFieldForQueryColumnArray containsObject:self.lookUpObject.defaultColoumnName]) {
        [displayFieldForQueryColumnArray addObject:self.lookUpObject.defaultColoumnName];
    }
    if (![displayFieldForQueryColumnArray containsObject:self.lookUpObject.defaultObjectColumnName]) {
        [displayFieldForQueryColumnArray addObject:self.lookUpObject.defaultObjectColumnName];
    }


    
    NSMutableDictionary *lookupDefDetailDict = [[NSMutableDictionary alloc]init];
    [lookupDefDetailDict setValue:searchFieldArray forKey:@"searchFields"];
    [lookupDefDetailDict setValue:displayFieldArray forKey:@"displayFields"];
    [lookupDefDetailDict setValue:[displayFieldForQueryColumnArray componentsJoinedByString:@","] forKey:@"queryColumns"];
    [lookupDefDetailDict setValue:[self getThePrefilterString] forKey:@"preFilterCriteria"];
    [lookupDefDetailDict setValue:[NSNumber numberWithLong:self.lookUpObject.recordLimit] forKey:@"numberOfRecs"];
    //    [lookupDefDetailDict setValue:@[] forKey:@"formFillFields"];
    [lookupDefDetailDict setValue:self.lookUpObject.defaultColoumnName forKey:@"defaultLookupColumn"];
    
    // INNER-MOST Level END--
    
    // INNER-MOST Level-1 START--
    
    NSMutableDictionary *lLookupDefDict = [[NSMutableDictionary alloc]init];
    [lLookupDefDict setValue:lookupDefDetailDict forKey:@"lookupDefDetail"];
    [lLookupDefDict setValue:self.lookUpObject.objectName forKey:@"lookUpObject"];
    [lLookupDefDict setValue:self.lookUpObject.lookUpId forKey:@"key"];
    [lLookupDefDict setValue:self.lookUpObject.objectName forKey:@"objectName"];
    [lLookupDefDict setValue:[self advanceFilterData] forKey:@"advFilters"];
    
    // INNER-MOST Level-1 END--
    
    // INNER-MOST Level-2 START--
    NSMutableDictionary *llookupRequestDict = [[NSMutableDictionary alloc]init];
    [llookupRequestDict setValue:lLookupDefDict forKey:@"LookupDef"];
    [llookupRequestDict setValue:self.searchText forKey:@"KeyWord"];
    [llookupRequestDict setValue:@"contains" forKey:@"Operator"];

    if (![StringUtil isStringEmpty:self.lookUpObject.contextLookupFilter.lookupQuery] && ![StringUtil isStringEmpty:self.lookUpObject.contextLookupFilter.lookupContext] && self.lookUpObject.contextLookupFilter.defaultOn) {
        NSString *contextValue = [self contextFilterValue];
        [llookupRequestDict setValue:(contextValue?contextValue:@"") forKey:@"ContextValue"];
        [llookupRequestDict setValue:self.lookUpObject.contextLookupFilter.lookupQuery forKey:@"ContextMatchField"];

    }

    // INNER-MOST Level-2 END--
    
    //OUTER-MOST Level START---
    NSMutableDictionary *lOuterMostLevelRequestDict = [[NSMutableDictionary alloc]init];
    [lOuterMostLevelRequestDict setValue:llookupRequestDict forKey:@"lookupRequest"];
    [lOuterMostLevelRequestDict setValue:nil forKey:@"docTemplate"];
    [lOuterMostLevelRequestDict setValue:nil forKey:@"fieldUpdateRuleInfoList"];
    [lOuterMostLevelRequestDict setValue:nil forKey:@"fieldsToNull"];
    [lOuterMostLevelRequestDict setValue:nil forKey:@"bizRuleInfo"];
    [lOuterMostLevelRequestDict setValue:nil forKey:@"groupId"];
    //OUTER-MOST Level END---
    
    requestParamModel.requestInformation = lOuterMostLevelRequestDict;
    
    return requestParamModel;
}


-(NSString *)contextFilterValue
{
    NSString *displayValue;
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(getValueForContextFilterThroughDelegateForfieldName:forHeaderObject:)]) {
    
     SFMRecordFieldData *recordData = [self.delegate getValueForContextFilterThroughDelegateForfieldName:self.lookUpObject.contextLookupFilter.lookupContext forHeaderObject:self.lookUpObject.contextLookupFilter.sourceObjectName];

        DataTypeUtility *fieldUtil = [[DataTypeUtility alloc] init];
    
        //RHS
        SFObjectFieldModel *fieldModel = [fieldUtil getField:self.lookUpObject.contextLookupFilter.lookupContext objectName:self.lookUpObject.contextLookupFilter.lookupContextParentObject];
        
        //LHS
        SFObjectFieldModel *lhsFieldModel = [fieldUtil getField:self.lookUpObject.contextLookupFilter.lookupQuery objectName:self.lookUpObject.objectName];
        
        
        //check if its reference. then check for Id else just check with what is displayed
        if ([lhsFieldModel.type isEqualToString:kSfDTReference] || [fieldModel.type isEqualToString:kSfDTDate] ||   [fieldModel.type isEqualToString:kSfDTDateTime]  || [fieldModel.type isEqualToString:kSfDTPicklist] || ([lhsFieldModel.type caseInsensitiveCompare:kId] == NSOrderedSame)) {
            
            displayValue = (recordData.internalValue.length > 0) ? recordData.internalValue : @"";
        }
        else {
            displayValue = (recordData.displayValue.length > 0) ? recordData.displayValue : @"";
        }
        
    }
    
    return displayValue;
}

#pragma mark - Parsing methods

-(NSString *)getTheAdvanceCriteriaStringForLookUpFilter:(SFMLookUpFilter *)model
{
    DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:@"Id" operatorType:SQLOperatorEqual andFieldValue:model.searchId];
    DBCriteria *criteria2 = [[DBCriteria alloc] initWithFieldName:@"namedSearchId" operatorType:SQLOperatorEqual andFieldValue:model.nameSearchID];
    NSArray * fieldsArray = [[NSArray alloc] initWithObjects:@"parentObjectCriteria",nil];
    
    id<SFNamedSearchFilterDAO> searchFilterService = [FactoryDAO serviceByServiceType:ServiceTypeNamedSerachFilter];
    NSArray *resultset = [searchFilterService fetchSFNameSearchFiltersInfoByFields:fieldsArray andCriteria:@[criteria1,criteria2]];
    
    NSString *advfilterString = nil;
    for (SFNamedSearchFilterModel *model in resultset) {
        advfilterString = model.parentObjectCriteria;
    }
    return advfilterString;
    
}

-(NSString *)getThePrefilterString
{
    
    for (SFMLookUpFilter *model in self.lookUpObject.preFilters) {
        
        DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:@"Id" operatorType:SQLOperatorEqual andFieldValue:model.searchId];
        DBCriteria *criteria2 = [[DBCriteria alloc] initWithFieldName:@"namedSearchId" operatorType:SQLOperatorEqual andFieldValue:model.nameSearchID];
        NSArray * fieldsArray = [[NSArray alloc] initWithObjects:@"parentObjectCriteria",nil];
        
        id<SFNamedSearchFilterDAO> searchFilterService = [FactoryDAO serviceByServiceType:ServiceTypeNamedSerachFilter];
        
        NSArray *resultset = [searchFilterService fetchSFNameSearchFiltersInfoByFields:fieldsArray andCriteria:@[criteria1,criteria2]];
        
        NSString *prefilterString = nil;
        for (SFNamedSearchFilterModel *model in resultset) {
            prefilterString = model.parentObjectCriteria;
        }
        if (prefilterString!=nil)
            prefilterString = [self checkForLiterals:prefilterString];

        return prefilterString;
    }
    
    return nil;
    
}

-(NSMutableArray *)advanceFilterData
{
    NSMutableArray *filterArray = [NSMutableArray new];
    for (SFMLookUpFilter *model in self.lookUpObject.advanceFilters) {
        NSMutableDictionary *lOutermostLayer = [NSMutableDictionary new];

        if (model != nil) {
            if ([model.lookupContext length] == 0) {
                if ([model.ruleType isEqualToString:kSearchFilterCriteria]) {
                    if ((!model.defaultOn || !model.objectPermission)) {
                        continue;
                    }
                }
                
                //           [lOutermostLayer setValue:(model.defaultOn? @"true":@"false") forKey:@"defaultOn"];
                [lOutermostLayer setValue:[NSNumber numberWithBool:model.defaultOn] forKey:@"defaultOn"];
                //          [lOutermostLayer setValue:(model.allowOverride? @"true":@"false") forKey:@"allowOverride"];
                [lOutermostLayer setValue:[NSNumber numberWithBool:model.allowOverride] forKey:@"allowOverride"];
                [lOutermostLayer setValue:model.name forKey:@"filterName"]; // Checked.
                [lOutermostLayer setValue:model.sourceObjectName forKey:@"filterObject"];
                [lOutermostLayer setValue:model.searchId forKey:@"key"];//TODO:Check. Data not matching.
                [lOutermostLayer setValue:model.searchFieldName forKey:@"lookupField"];//TODO:Check
                
                id<SFExpressionComponentDAO> expCompService = [FactoryDAO serviceByServiceType:ServiceTypeExpressionComponent];
                NSArray *expCompArray =[expCompService getExpressionComponentsBySFId:model.searchId];
                
                NSMutableArray *filterCriteriaArray = [NSMutableArray new];
                for (SFExpressionComponentModel *expComp in expCompArray) {
                    NSMutableDictionary *filterCriteriaFields = [NSMutableDictionary new];
                    
                    [filterCriteriaFields setValue:expComp.operatorValue forKey:@"operatorValue"]; //Specifically for value. dont have to be sent in API.
                    [filterCriteriaFields setValue:expComp.parameterType forKey:@"operandType"];
                    [filterCriteriaFields setValue:[NSNumber numberWithDouble:expComp.componentSequenceNumber] forKey:@"sequence"];
                    [filterCriteriaFields setValue:@"" forKey:@"refObjectNameField"];
                    [filterCriteriaFields setValue:expComp.componentLHS forKey:@"apiName"];
                    [filterCriteriaArray addObject:filterCriteriaFields];
                }
                NSString *advanceCriteriaString = [self getTheAdvanceCriteriaStringForLookUpFilter:model];
                
                if (advanceCriteriaString !=nil) {
                    advanceCriteriaString = [self checkForLiterals:advanceCriteriaString];
                }

                [lOutermostLayer setValue:advanceCriteriaString forKey:@"filterCriteria"];
                [lOutermostLayer setValue:filterCriteriaArray forKey:@"filterCriteriaFields"];
            }
        }
        if(lOutermostLayer.count)
            [filterArray addObject:lOutermostLayer];
    }
    return filterArray;
}

-(NSString *)checkForLiterals:(NSString *)criteriaString
{
//    NSArray *literalArray = @[kLiteralNow, kLiteralToday, kLiteralSVMXNow, kLiteralTomorrow, kLiteralYesterday, kLiteralCurrentUser, kLiteralOwner, kLiteralCurrentUserId, kLiteralCurrentRecord, kLiteralCurrentRecordHeader, kLiteralUserTrunk];
    
    NSArray *literalArray = @[kLiteralCurrentUser, kLiteralOwner, kLiteralCurrentUserId, kLiteralCurrentRecordHeader, kLiteralCurrentRecord, kLiteralUserTrunk];

    for (NSString *literal in literalArray) {
        if ([StringUtil containsString:literal inString:criteriaString]) {
            NSString *literalValue = [self valueOfLiteral:literal forCriteria:criteriaString];
            if ([literal isEqualToString:kLiteralCurrentRecordHeader]|| [literal isEqualToString:kLiteralCurrentRecord])
            {
                criteriaString = literalValue;
            }
            else{
                criteriaString = [criteriaString stringByReplacingOccurrencesOfString:literal withString:[NSString stringWithFormat:@"'%@'",literalValue] options:NSCaseInsensitiveSearch range:NSMakeRange(0, [criteriaString length])];
            }
        }
    }
//    criteriaString = [criteriaString stringByReplacingOccurrencesOfString:@"''" withString:@"'"];
    return criteriaString;
}

- (NSString *)valueOfLiteral:(NSString *)literal forCriteria:(NSString *)criteriaString
{
    NSString *literalValue = literal;
    
    if([literal caseInsensitiveCompare:kLiteralNow]== NSOrderedSame)
    {
        literalValue = [Utility today:0 andJusDate:NO];
    }
    else if([literal caseInsensitiveCompare:kLiteralToday]== NSOrderedSame ||
            [literal caseInsensitiveCompare:kLiteralSVMXNow]== NSOrderedSame )
    {
        literalValue = [Utility today:0 andJusDate:YES];
        if ([literalValue length] >= 10 ) {
            literalValue = [literalValue substringToIndex:10];
        }
        
    }
    else if([literal caseInsensitiveCompare:kLiteralTomorrow]== NSOrderedSame)
    {
        literalValue = [Utility today:1 andJusDate:YES];
        if ([literalValue length] >= 10 ) {
            literalValue = [literalValue substringToIndex:10];
        }
        
    }
    else if([literal caseInsensitiveCompare:kLiteralYesterday]== NSOrderedSame)
    {
        literalValue = [Utility today:-1 andJusDate:YES];
        if ([literalValue length] >= 10 ) {
            literalValue = [literalValue substringToIndex:10];
        }
        
    }
    else if(([literal caseInsensitiveCompare:kLiteralCurrentUser]== NSOrderedSame) || ([literal caseInsensitiveCompare:kLiteralOwner]== NSOrderedSame) || ([literal caseInsensitiveCompare:kLiteralCurrentUserId]== NSOrderedSame))
    {
        literalValue = [PlistManager getLoggedInUserName];
    }
    else if(([literal caseInsensitiveCompare:kLiteralCurrentRecord]== NSOrderedSame) || ([literal caseInsensitiveCompare:kLiteralCurrentRecordHeader] == NSOrderedSame))
    {
        
        while ([StringUtil containsString:literal inString:criteriaString]) {
            criteriaString = [self currentHeaderLiteralHandlingforCriteriaString:criteriaString andLiteral:literal];
        }

        literalValue = criteriaString;


    }
    else if([literal caseInsensitiveCompare:kLiteralUserTrunk] == NSOrderedSame)
    {
//        literalValue = [PlistManager getTechnicianLocation];
        literalValue = [PlistManager getTechnicianLocationId]; //for online search send location ID.
    }
    
    return literalValue;
}

-(NSString *)currentHeaderLiteralHandlingforCriteriaString:(NSString *)criteriaString andLiteral:(NSString *)literal
{
    NSString *subcriteria = [criteriaString substringFromIndex:[criteriaString rangeOfString:literal].location];
    subcriteria = [subcriteria substringToIndex:[subcriteria rangeOfString:@"]"].location];
    
    SFMRecordFieldData *recordData = [self.delegate getLiteralValueThroughDelegateForLiteral:subcriteria];
    NSString *literalValue = recordData.internalValue;
    if(!literalValue)
        literalValue = @"";
    criteriaString =[criteriaString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"[%@]",subcriteria] withString:literalValue];
    return criteriaString;
}

@end
