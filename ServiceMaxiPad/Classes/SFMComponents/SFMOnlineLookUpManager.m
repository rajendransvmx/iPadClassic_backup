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
#import "TransactionObjectModel.h"
#import "Utility.h"
#import "SFMPageLookUpHelper.h"
#import "DBCriteria.h"
#import "SFExpressionComponentDAO.h"
#import "FactoryDAO.h"
#import "SFExpressionComponentModel.h"
#import "CacheConstants.h"

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

//    [self advanceFilterData];
//    [self getThePrefilterString];
    [self removeAllCacheData];
    [self initiateSearchResultWebService];
 
}

-(void)removeAllCacheData {
    
    //TODO: This is Not working YET.
    [[CacheManager sharedInstance] clearCacheByKey:@""];
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
                NSArray *dataOnlineDataArray = [[CacheManager sharedInstance] getCachedObjectByKey:kSFMOnlineLookUpCacheData];
                
//                //TODO: Get the response data array from cache and pass it to parseSFM method.
//                NSMutableArray *parsedDataArray = [self parseSFMOnlineLookupData:nil];
                
                if (self.delegate != nil && [self.delegate respondsToSelector:@selector(onlineLookupSearchSuccessfullwithResponse:)]) {
                    [self.delegate onlineLookupSearchSuccessfullwithResponse:dataOnlineDataArray];
                }
                
            } else if (webServiceStatus.syncStatus == SyncStatusFailed)
            {
              //  [self onlineSearchFailedWithError:webServiceStatus.syncError];
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
    NSMutableArray *displayFieldForQueryColumnArray  = [[NSMutableArray alloc] initWithObjects:@"Id", nil];
    for (SFNamedSearchComponentModel *searchObjectmodel in self.lookUpObject.displayFields) {
        NSMutableDictionary *displayObjectDict = [[NSMutableDictionary alloc]init];
        [displayObjectDict setValue:[NSNumber numberWithDouble:searchObjectmodel.sequence] forKey:@"sequence"];
        [displayObjectDict setValue:@"" forKey:@"refObjectNameField"];
        [displayObjectDict setValue:@"" forKey:@"refObjectName"];
        [displayObjectDict setValue:searchObjectmodel.expressionType forKey:@"operandType"];
        [displayObjectDict setValue:searchObjectmodel.fieldRelationshipName forKey:@"fieldRelationshipName"];
        [displayObjectDict setValue:searchObjectmodel.fieldDataType forKey:@"dataType"];
        [displayObjectDict setValue:searchObjectmodel.fieldName forKey:@"apiName"];
        [displayFieldForQueryColumnArray addObject:searchObjectmodel.fieldName];
        
        [displayFieldArray addObject:displayObjectDict];
    }
    
    NSMutableDictionary *lookupDefDetailDict = [[NSMutableDictionary alloc]init];
    [lookupDefDetailDict setValue:searchFieldArray forKey:@"searchFields"];
    [lookupDefDetailDict setValue:displayFieldArray forKey:@"displayFields"];

    [lookupDefDetailDict setValue:[displayFieldForQueryColumnArray componentsJoinedByString:@","] forKey:@"queryColumns"]; //TODO:Check- Should "Id" be always be included by default.
    [lookupDefDetailDict setValue:[self getThePrefilterString] forKey:@"preFilterCriteria"]; //TODO:Check- is it prepared using  "defaultLookupColumn". eg. "Name LIKE 'San%'" THIS SHOUDL COME FROM SERVER.

    [lookupDefDetailDict setValue:[NSNumber numberWithLong:self.lookUpObject.recordLimit] forKey:@"numberOfRecs"];
//    [lookupDefDetailDict setValue:@[] forKey:@"formFillFields"];
    [lookupDefDetailDict setValue:self.lookUpObject.defaultColoumnName forKey:@"defaultLookupColumn"];

    
    // INNER-MOST Level END--

     // INNER-MOST Level-1 START--
    
    NSMutableDictionary *lLookupDefDict = [[NSMutableDictionary alloc]init];
    [lLookupDefDict setValue:lookupDefDetailDict forKey:@"lookupDefDetail"];
    [lLookupDefDict setValue:self.lookUpObject.objectName forKey:@"lookUpObject"];
    [lLookupDefDict setValue:self.lookUpObject.lookUpId forKey:@"key"]; //TODO:Check IF THis the ID required.
    [lLookupDefDict setValue:[self advanceFilterData] forKey:@"advFilters"]; //TODO:Check IF the advance filter has to be sent or not. If it has to be sent what will be the structure.

    // INNER-MOST Level-1 END--

    // INNER-MOST Level-2 START--
    NSMutableDictionary *llookupRequestDict = [[NSMutableDictionary alloc]init];
    [llookupRequestDict setValue:lLookupDefDict forKey:@"LookupDef"];
    [llookupRequestDict setValue:self.searchText forKey:@"KeyWord"]; //TODO:Check IF THis is correct?
    [llookupRequestDict setValue:@"contains" forKey:@"Operator"];
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

#pragma mark - Parsing methods
/*
- (NSMutableArray*)parseSFMOnlineLookupData:(NSDictionary*)responseDictionary {
    
    @autoreleasepool {
        
        NSMutableArray *onlineDataArray = [[NSMutableArray alloc] initWithCapacity:0];

        //TODO: remove unwanted code from this method once we get the actual response from server.
        NSString *jsonStr = @"{\"records\":[{\"attributes\":{\"type\":\"Account\"},\"Name\":\"Santosh Nadagowda\"},{\"attributes\":{\"type\":\"Account\"},\"Name\":\"San Francisco\"},{\"attributes\":{\"type\":\"Account\"},\"Name\":\"Sangam\"}]}";
        
        NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        
        
        responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        
        NSArray *records = [responseDictionary objectForKey:@"records"];
        for (NSDictionary *dictionary in records) {
            TransactionObjectModel * model = [[TransactionObjectModel alloc] init];
            [model mergeFieldValueDictionaryForFields:dictionary];
            if (model != nil) {
                [onlineDataArray addObject:model];
            }
        }
        return onlineDataArray;
    }
}
*/
-(NSString *)getThePrefilterString
{
    SFMPageLookUpHelper *helper = [[SFMPageLookUpHelper alloc] init];
    
    NSArray * criteriaArray;// = [helper getWhereclause:self.lookUpObject];

    
    for (SFMLookUpFilter *model in self.lookUpObject.preFilters) {
        if (model != nil) {
            
            if ([model.ruleType isEqualToString:kSearchFilterCriteria]) {
                if (!model.allowOverride || !model.objectPermission) {
                    continue;
                }
            }
            criteriaArray = [helper getCriteriaObjectForfilter:model];
            
            
        }
    }
    
    
    NSArray *advanceExp = [[self getAdvanceExpression] componentsSeparatedByString:@" "];
    NSString *criteriaString=@"";
    for (int i=0;i<criteriaArray.count;i++) {
        DBCriteria *criteria = [criteriaArray objectAtIndex:i];
        criteriaString = [criteriaString stringByAppendingFormat:@" %@ %@",criteria.lhsValue, [self getOperatorStringAndRHSValue:criteria] ];
        if (i!=criteriaArray.count-1) {
            criteriaString = [criteriaString stringByAppendingFormat:@" %@",[advanceExp objectAtIndex:(i*2)+1]];
        }
    }
    if (![Utility isStringEmpty:criteriaString]) {
        if ([criteriaString length] > 1) {
            criteriaString = [criteriaString substringFromIndex:1]; //Removing the white space at the beginning
        }
    }
    return criteriaString;
    
}

-(NSString *)getOperatorStringAndRHSValue:(DBCriteria *)criteria
{
    /*
    SQLOperatorNone = 0,
    SQLOperatorLessThan = 1,
    SQLOperatorGreaterThan = 2,
    SQLOperatorLessThanEqualTo = 3,
    SQLOperatorGreaterThanEqualTo = 4,
    SQLOperatorLike = 5,
    SQLOperatorNotLike = 6,
    SQLOperatorIn = 7,
    SQLOperatorNotIn = 8,
    SQLOperatorBetween = 13,
    SQLOperatorIsNull = 9,
    SQLOperatorIsNotNull = 10,
    SQLOperatorEqual = 11,
    SQLOperatorNotEqual = 12,
    SQLOperatorStartsWith = 14,
    SQLOperatorEndsWith = 15,
    SQLOperatorLikeOverride = 16,
    SQLOperatorNotLikeOverride = 17,
    SQLOperatorNotLikeWithIsNull = 18,
    SQLOperatorNotEqualWithIsNull = 19
    */
    NSString *operatorString;
    switch (criteria.operatorType) {
        case SQLOperatorLessThan:
            operatorString = [NSString stringWithFormat:@"lessThan '%@'", criteria.rhsValue];
            break;
        case SQLOperatorGreaterThan:
            operatorString = [NSString stringWithFormat:@"greaterThan '%@'", criteria.rhsValue];
            break;
        case SQLOperatorGreaterThanEqualTo:
            operatorString = [NSString stringWithFormat:@"greaterThanEqualTo '%@'", criteria.rhsValue];
            break;
        case SQLOperatorLike:
            operatorString = [NSString stringWithFormat:@"like '%%%@%%'", criteria.rhsValue];
            break;
        case SQLOperatorIsNull:
            operatorString = [NSString stringWithFormat:@"equals '%@'", criteria.rhsValue];
            break;
        case SQLOperatorIsNotNull:
            operatorString = [NSString stringWithFormat:@"equals '%@'", criteria.rhsValue];
            break;
        case SQLOperatorEqual:
            operatorString = [NSString stringWithFormat:@"equals '%@'", criteria.rhsValue];
            break;
        case SQLOperatorNotEqual:
            operatorString = [NSString stringWithFormat:@"notEquals '%@'", criteria.rhsValue];
            break;
        case SQLOperatorStartsWith:
            operatorString = [NSString stringWithFormat:@"like '%@%%'", criteria.rhsValue];
            break;
        case SQLOperatorEndsWith:
            operatorString = [NSString stringWithFormat:@"like '%%%@'", criteria.rhsValue];
            break;
            
        default:
            break;
    }
    return operatorString;
}



-(NSString *)getAdvanceExpression
{
    NSString * advanceExpression;
    for (SFMLookUpFilter *filter in self.lookUpObject.preFilters) {
        advanceExpression = filter.advanceExpression;
    }
    return advanceExpression;
    
}

-(NSMutableArray *)advanceFilterData
{
    NSMutableArray *filterArray = [NSMutableArray new];
    for (SFMLookUpFilter *model in self.lookUpObject.advanceFilters) {
        NSMutableDictionary *lOutermostLayer = [NSMutableDictionary new];

        if (model != nil) {
//            if ([model.lookupContext length] == 0) {
                if (![model.ruleType isEqualToString:kSearchFilterCriteria]) {
                    
                    continue;
                }
            
//           [lOutermostLayer setValue:(model.defaultOn? @"true":@"false") forKey:@"defaultOn"];
             [lOutermostLayer setValue:[NSNumber numberWithBool:model.defaultOn] forKey:@"defaultOn"];

//          [lOutermostLayer setValue:(model.allowOverride? @"true":@"false") forKey:@"allowOverride"];
            [lOutermostLayer setValue:[NSNumber numberWithBool:model.allowOverride] forKey:@"allowOverride"];

            [lOutermostLayer setValue:model.name forKey:@"filterName"]; // Checked.
            [lOutermostLayer setValue:model.sourceObjectName forKey:@"filterObject"];//TODO:Check. CHECKED
            [lOutermostLayer setValue:model.searchId forKey:@"key"];//TODO:Check. Data not matching.
            [lOutermostLayer setValue:model.searchFieldName forKey:@"lookupField"];//TODO:Check

            id<SFExpressionComponentDAO> expCompService = [FactoryDAO serviceByServiceType:ServiceTypeExpressionComponent];
            NSArray *expCompArray =[expCompService getExpressionComponentsBySFId:model.searchId];

            NSString *filterCriteriaString = @"";
            NSMutableArray *filterCriteriaArray = [NSMutableArray new];
            for (SFExpressionComponentModel *expComp in expCompArray) {
                NSMutableDictionary *filterCriteriaFields = [NSMutableDictionary new];

                [filterCriteriaFields setValue:expComp.operatorValue forKey:@"operatorValue"]; //Specifically for value. dont have to be sent in API.
                [filterCriteriaFields setValue:expComp.parameterType forKey:@"operandType"];
                [filterCriteriaFields setValue:[NSNumber numberWithDouble:expComp.componentSequenceNumber] forKey:@"sequence"];
                [filterCriteriaFields setValue:@"" forKey:@"refObjectNameField"];
                [filterCriteriaFields setValue:expComp.componentLHS forKey:@"apiName"];
                
                filterCriteriaString = [filterCriteriaString stringByAppendingFormat:@" %@ %@",expComp.componentLHS, [self operatorAndRHSValue:expComp]];
                
                [filterCriteriaArray addObject:filterCriteriaFields];
//            TODO:
//                1) what to do when LHS and RHS both are present. Where to assign RHS
//                2) what is lookupField?
//                3) filterObject?
                
               
            }
            [lOutermostLayer setValue:filterCriteriaString forKey:@"filterCriteria"];
            [lOutermostLayer setValue:filterCriteriaArray forKey:@"filterCriteriaFields"];
        }
        [filterArray addObject:lOutermostLayer];
    }
    return filterArray;
}

-(NSString *)operatorAndRHSValue:(SFExpressionComponentModel *)expComp
{
    NSString *theString = @"";
    if ([expComp.operatorValue isEqualToString:@"contains"]) {
        theString = [NSString stringWithFormat:@"contains '%%%@%%'",expComp.componentRHS];
    }
    else if ([expComp.operatorValue isEqualToString:@"starts"]){
        theString = [NSString stringWithFormat:@"contains '%@%%'",expComp.componentRHS];

    }
    else if ([expComp.operatorValue isEqualToString:@"ends"]){
        theString = [NSString stringWithFormat:@"contains '%%%@'",expComp.componentRHS];
        
    }
    else if ([expComp.operatorValue isEqualToString:@"isnull"] || [expComp.operatorValue isEqualToString:@"isnotnull"]){
    
        theString = [NSString stringWithFormat:@"%@",expComp.operatorValue];

    }
        else
        {
            theString = [NSString stringWithFormat:@"%@ '%@'",expComp.operatorValue , expComp.componentRHS];

        }
    return theString;
}

@end
