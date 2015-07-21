//
//  CustomActionWebServiceLayer.m
//  ServiceMaxiPad
//
//  Created by Apple on 22/06/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "CustomActionWebServiceLayer.h"
#import "WizardComponentModel.h"
#import "SFCustomActionURLService.h"
#import "CustomActionURLModel.h"
#import "SFMCustomActionWebServiceHelper.h"
#import "CustomActionWebserviceModel.h"
#import "CacheManager.h"
#import "CacheConstants.h"
#import "ParserFactory.h"
#import "SFMRecordFieldData.h"
#import "FactoryDAO.h"
#import "StringUtil.h"
#import "SFMDetailLayout.h"
#import "StringUtil.h"

@implementation CustomActionWebServiceLayer
- (instancetype) initWithCategoryType:(CategoryType)categoryType
                          requestType:(RequestType)requestType {
    
    self = [super initWithCategoryType:categoryType requestType:requestType];
    
    if (self != nil) {
        //Intialize if required
        
    }
    
    return self;
}


- (ResponseCallback*)processResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                        responseData:(id)responseData
{
    ResponseCallback *callBack = nil;
    WebServiceParser *parserObj = (WebServiceParser *)[ParserFactory parserWithRequestType:self.requestType];
    if ([parserObj conformsToProtocol:@protocol(WebServiceParserProtocol)]) {
        
        parserObj.clientRequestIdentifier = self.requestIdentifier;
        callBack = [parserObj parseResponseWithRequestParam:requestParamModel
                                               responseData:responseData];
    }
    return callBack;
}
- (NSArray*)getRequestParametersWithRequestCount:(NSInteger)requestCount
{
    return @[];
}
- (NSArray*)getRequestParametersWithRequestCountRestBody:(NSInteger)requestCount
{
    RequestParamModel *reqParModel = [[RequestParamModel alloc]init];
    NSMutableArray *requestArray =[[NSMutableArray alloc] init];

    if (self.categoryType == CategoryTypeCustomWebServiceCall || self.categoryType == CategoryTypeCustomWebServiceAfterBeforeCall){
        /* taking value from pageLayout */
        NSDictionary *objectInfo=[self ObjectValue];
        if (objectInfo) {
            [requestArray addObject:objectInfo];
        }
        
        /* Taking chaeld value and adding into Request Body */
        NSArray *chieldLineInfo=[self objectChildLine];
        if (chieldLineInfo !=nil && ![chieldLineInfo isKindOfClass:[NSNull class]] && [chieldLineInfo count]>0){
            for (NSDictionary *dict in chieldLineInfo) {
                [requestArray addObject:dict];
            }
        }
    }
    else if (self.categoryType == CategoryTypeCustomWebServiceCall)
    {
        /* making parameter dictinory for custom Info */
        NSDictionary *parametersInfo=[self parameterValue];
        if (parametersInfo) {
            [requestArray addObject:parametersInfo];
        }
    }
    reqParModel.valueMap = requestArray;
    return @[reqParModel];
}

-(NSDictionary *)ObjectValue
{
    CustomActionWebserviceModel *customActionWebserviceModel = [[CacheManager sharedInstance] getCachedObjectByKey:kCustomWebServiceAction];
    NSDictionary *dict=[self makeHeaderdictinory:customActionWebserviceModel];
    if (dict) {
        return [self getNode:[self getSVMXMap:@"" date:@"" value:customActionWebserviceModel.sfmPage.objectName key:@"Object_Name" values:[[NSArray alloc] init] valueMap:@[dict]]];
    }else{
        /* This change for object detail. If objec detail is not there, then we are not sending balnk body */
        //return [self getNode:[self getSVMXMap:@"" date:@"" value:customActionWebserviceModel.sfmPage.objectName key:@"Object_Name" values:[[NSArray alloc] init] valueMap:@[]]];
    }
    return nil;
}

-(NSDictionary *)makeHeaderdictinory:(CustomActionWebserviceModel *)customActionWebserviceModel
{
    NSDictionary *recordDictionary = nil;
    if (customActionWebserviceModel.sfmPage)
    {
        recordDictionary=customActionWebserviceModel.sfmPage.headerRecord;
    
        if (recordDictionary)
        {
            NSDictionary *dictinory=[self getSVMXMap:@"" date:@"" value:[self gettingHeaderValueFromPage:recordDictionary] key:[customActionWebserviceModel.sfmPage getHeaderSalesForceId] values:[[NSArray alloc] init] valueMap:[[NSArray alloc] init] lstInternal_Request:[[NSArray alloc] init] lstInternal_Response:[[NSArray alloc] init] record:@""];
            return [self getNode:dictinory];
        }
    }
    return nil;
}

-(NSString *)gettingHeaderValueFromPage:(NSDictionary *)recordDictionary
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:0];
   
    for (NSString *key in [recordDictionary allKeys])
    {
        SFMRecordFieldData *recordFieldData = [recordDictionary objectForKey:key];
    
        if (recordFieldData && recordFieldData.internalValue)
            [dict setObject:recordFieldData.internalValue forKey:key];
        else
            [dict setObject:@"" forKey:key];
    }
    return [self convertDictionaryToString:dict];
}

-(NSArray *)objectChildLine
{
    CustomActionWebserviceModel *customActionWebserviceModel = [[CacheManager sharedInstance] getCachedObjectByKey:kCustomWebServiceAction];
    NSMutableArray *childArray = [[NSMutableArray alloc] initWithCapacity:0];
    if (customActionWebserviceModel.sfmPage)
    {
        NSMutableDictionary *detailObjectName = [self getProcessComponentIdFromSfPage:customActionWebserviceModel.sfmPage];
        NSDictionary *childwithObject = [self gettingChieldValueFromPage:customActionWebserviceModel.sfmPage.detailsRecord detailObjectName:detailObjectName];
        NSArray *childListName = [childwithObject allKeys];
        /* Before sending data, checking for child line item. If child line is not there, then not sending any information */
        if (childListName !=nil && ![childListName isKindOfClass:[NSNull class]] && [childListName count]>0) {
            for (NSString *objectName in childListName) {
                [childArray addObject:[self makeChildDictionary:[childwithObject objectForKey:objectName] objectName:objectName]];
            }
        }else{
            /* This change for child line item. If chield line is not there, then we are not sending balnk body */
           // return [self getNode:[self getSVMXMap:@"" date:@"" value:self.childName key:@"Object_Name" values:[[NSArray alloc] init] valueMap:@[]]];
        }
    }
    return childArray;
}
-(NSDictionary *)makeChildDictionary:(NSArray *)childList objectName:(NSString *)objectName{
    return [self getNode:[self getSVMXMap:@"" date:@"" value:objectName key:@"Object_Name" values:[[NSArray alloc] init] valueMap:childList]];
}

-(NSMutableDictionary *)getProcessComponentIdFromSfPage:(SFMPage *)sfmPage
{
    NSMutableDictionary *detailObjectName = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSArray *recordArray = sfmPage.process.pageLayout.detailLayouts;
    for (SFMDetailLayout *detailLayout in recordArray)
    {
        if ([StringUtil isStringNotNULL:detailLayout.objectName] && [StringUtil isStringNotNULL:detailLayout.processComponentId]) {
            [detailObjectName setObject:detailLayout.objectName forKey:detailLayout.processComponentId];
        }
    }
    return detailObjectName;
}
-(NSMutableDictionary *)gettingChieldValueFromPage:(NSDictionary *)recordDictionary detailObjectName:(NSMutableDictionary *)detailObjectName
{
    NSMutableDictionary *childLineObject = [[NSMutableDictionary alloc] initWithCapacity:0];
    if (recordDictionary)
    {
        for (NSString *key_Id in [recordDictionary allKeys])
        {
            NSMutableDictionary *recordFieldDataValues = [[NSMutableDictionary alloc] initWithCapacity:0];
            NSArray *itemArray = [recordDictionary objectForKey:key_Id];
            NSMutableArray *lineArray = [childLineObject objectForKey:[detailObjectName objectForKey:key_Id]];
            for (NSDictionary *childDict in itemArray)
            {
                NSString *objectSFId = [self getSfId:childDict];
                for (NSString *key in [childDict allKeys])
                {
                    SFMRecordFieldData *recordFieldDataChild = [childDict objectForKey:key];
                    if (recordFieldDataChild)
                    {
                        [recordFieldDataValues setObject:recordFieldDataChild.internalValue forKey:key];
                    }else
                    {
                        [recordFieldDataValues setObject:@"" forKey:key];
                    }
                }
                NSDictionary *dictinory=[self getSVMXMap:@"" date:@"" value:[self convertDictionaryToString:recordFieldDataValues] key:objectSFId values:[[NSArray alloc] init] valueMap:[[NSArray alloc] init] lstInternal_Request:[[NSArray alloc] init] lstInternal_Response:[[NSArray alloc] init] record:@""];
                if (lineArray !=nil && ![lineArray isKindOfClass:[NSNull class]] && [lineArray count]>0)
                {
                    [lineArray addObject:[self getNode:dictinory]];
                }
                else
                {
                    lineArray = [[NSMutableArray alloc] initWithCapacity:0];
                    [lineArray addObject:[self getNode:dictinory]];
                }
                NSString *objectName = [detailObjectName objectForKey:key_Id];
                if ([StringUtil isStringNotNULL:objectName]) {
                    [childLineObject setObject:lineArray forKey:objectName];
                }
            }
        }
    }
    return childLineObject;
}

- (NSString *)getSfId:(NSDictionary *)fieldDict
{
    SFMRecordFieldData *recordFieldDataChild = [fieldDict objectForKey:kId];
    if (recordFieldDataChild)
    {
        return recordFieldDataChild.internalValue;
    }
    return @"";
}


- (NSString*) convertDictionaryToString:(NSMutableDictionary*) dict
{
    return [Utility jsonStringFromObject:dict];
}

-(NSDictionary *)parameterValue
{
    CustomActionWebserviceModel *customActionWebserviceModel = [[CacheManager sharedInstance] getCachedObjectByKey:kCustomWebServiceAction];
    NSArray *parameterList = [self addParameters:customActionWebserviceModel];
    
    /* In before and after web-service call, we don't have parameter list. So in that case parameter body should not be there */
    if (parameterList && [parameterList count]>0) {
        NSDictionary *dictinory = [self getSVMXMap:@"" date:@"" value:@"" key:KSVMXRequestParameters values:[[NSArray alloc] init] valueMap:parameterList];
        return [self getNode:dictinory];
    }else{
        /* No parameter info find for that */
        NSDictionary *dictinory = [self getSVMXMap:@"" date:@"" value:@"" key:KSVMXRequestParameters values:[[NSArray alloc] init] valueMap:[[NSArray alloc] init]];
        return [self getNode:dictinory];
    }
    return nil;
}

-(NSDictionary *)getParameterNode:(CustomActionURLModel *)customModel
{
    NSMutableArray *paramArray =[[NSMutableArray alloc] initWithCapacity:0];
    NSDictionary *dictinoryvalue = [self getSVMXMap:@" " date:@"" value:customModel.ParameterValue key:customModel.ParameterType values:[[NSArray alloc] init] valueMap:[[NSArray alloc] init]];
    [paramArray addObject:dictinoryvalue];
    
    NSDictionary *dictinory = [self getSVMXMap:@" " date:@"" value:@"" key:customModel.ParameterName values:[[NSArray alloc] init] valueMap:paramArray];
    
    return [self getNode:dictinory];
}

/* taking column name and making key value pair for URL */
-(NSArray *)addParameters:(CustomActionWebserviceModel *)customActionWebserviceModel//(NSDictionary *)dictinory wizardComponentProcessId:(NSString *)processId
{
    NSDictionary *dictinory= customActionWebserviceModel.sfmPage.headerRecord;
    NSMutableArray *paramArray = [[NSMutableArray alloc] initWithCapacity:0];
    if (customActionWebserviceModel.processId && ![customActionWebserviceModel.processId isEqualToString:@""]) {
        NSArray *paramList = [self fetchParamsForWizardComponent:customActionWebserviceModel.processId];
        for(CustomActionURLModel *customModel in paramList)
        {
            //Making parameter from model with respect type
            if ([[customModel.ParameterType uppercaseString] isEqualToString:KFieldName])
            {
                SFMRecordFieldData *recordFieldData = [dictinory objectForKey:customModel.ParameterValue];
                if (recordFieldData)
                {
                    customModel.ParameterValue = recordFieldData.internalValue;
                }
                else
                {
                    customModel.ParameterValue = @"";
                }
            }
            [paramArray addObject:[self getParameterNode:customModel]];
        }
        return paramArray;
    }else{
        return nil;
    }
}

-(NSArray *)fetchParamsForWizardComponent:(NSString *)wizardComponentProcessId
{
    SFCustomActionURLService *wizardComponentparamService = [[SFCustomActionURLService alloc]init];
    NSArray *paramListValue= [wizardComponentparamService getCustomActionParams:wizardComponentProcessId];
    return paramListValue;
}

-(NSDictionary *)getSVMXMap:(NSString *)sVMXMap date:(NSString *)data value:(NSString *)value key:(NSString *)key values:(NSArray *)values valueMap:(NSArray *)valueMapArray
{
    if (!data) {
        data=@"";
    }
    if (!value) {
        value=@"";
    }
    if (!key) {
        key=@"";
    }
    NSDictionary *SVMXMap = @{
                                KSVMXRequestData : [[NSArray alloc] init],
                                kSVMXRequestKey : key,
                                kSVMXRequestValue : value,
                                kSVMXRequestValues: values,
                                kSVMXRequestSVMXMap: valueMapArray,
                                };
    return SVMXMap;
}
-(NSDictionary *)getSVMXMap:(NSString *)sVMXMap date:(NSString *)data value:(NSString *)value key:(NSString *)key values:(NSArray *)values valueMap:(NSArray *)valueMapArray lstInternal_Request:(NSArray *)lstInternal_Request lstInternal_Response:(NSArray *)lstInternal_Response record:(NSString *)record {
    if (!data) {
        data=@"";
    }
    if (!value) {
        value=@"";
    }
    if (!key) {
        key=@"";
    }
    if (!record) {
        record=@"";
    }
    NSDictionary *SVMXMap = @{
                              KSVMXRequestData : [[NSArray alloc] init],
                              kSVMXRequestKey : key,
                              kSVMXRequestValue : value,
                              kSVMXRequestValues: values,
                              kSVMXRequestSVMXMap: valueMapArray,
                              kLastInternalResponse: [[NSArray alloc] init],
                              kLsInternalRequest: [[NSArray alloc] init],
                              };
    return SVMXMap;
}

-(NSDictionary *)getNode:(NSDictionary *)dict
{
    //TODO: Niraj conform dict Now dummy method returning same dict
    //NSDictionary *wrapper = [NSDictionary dictionaryWithObjectsAndKeys:dict,kSVMXRequestMap,nil];
    return dict;
}

@end
