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
#import "TransactionObjectDAO.h"
#import "FactoryDAO.h"
#import "DBCriteria.h"
#import "CustomActionURLModel.h"
#import "SFMCustomActionWebServiceHelper.h"
#import "CustomActionWebserviceModel.h"
#import "CacheManager.h"
#import "ParserFactory.h"

////
#import "FactoryDAO.h"
#import "UserGPSLogDAO.h"
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
    NSArray *requestArray;
    switch (self.requestType) {
        case RequestDataPushNotification:
            //fill Data
            
            requestArray =[self fetchRequestParametersForAPNSRequest];
            
            break;
            case RequestTypeCustomActionWebService:
            
        default:
            SXLogWarning(@"Invalid request type");
            break;
    }
    requestArray =[self fetchRequestParametersForTechnicianLocationUpdateRequest];
    return requestArray;
//    NSArray *wizardComponentParamArray = [self getCustomActionParams];
//    NSDictionary *workOrderSummaryDict= [[NSDictionary alloc] init];
//    for (TransactionObjectModel *transObjModel in wizardComponentParamArray) {
//        workOrderSummaryDict=[transObjModel getFieldValueDictionary];
//    }
//    return wizardComponentParamArray;
}
-(NSArray *)fetchParamsForWizardComponent:(NSString *)wizardComponentProcessId{
    SFCustomActionURLService *wizardComponentparamService = [[SFCustomActionURLService alloc]init];
    NSArray *paramList= [wizardComponentparamService getCustomActionParams:wizardComponentProcessId];
    return paramList;
}
-(NSArray *)fetchDataFromObjectNameObject:(NSString *)objectNameTable
                                   fields:(NSArray *)fieldNames
                               expression:(NSString *)advancaeExpression
                                 criteria:(NSArray *)criteria
{
    id <TransactionObjectDAO> transactionService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    NSArray *dataArray = [transactionService fetchDataForObject:objectNameTable fields:fieldNames expression:advancaeExpression criteria:criteria];
    return dataArray;
}

- (NSArray *)getCustomActionParams{
    CustomActionWebserviceModel *customActionWebserviceLayer=[SFMCustomActionWebServiceHelper getCustomActionWebServiceHelper];
    if (!customActionWebserviceLayer) {
        return [[NSArray alloc] init];
    }
    NSArray *paramList = [self fetchParamsForWizardComponent:customActionWebserviceLayer.processId];
    DBCriteria * criteriaOne = [[DBCriteria alloc] initWithFieldName:customActionWebserviceLayer.ObjectFieldName
                                                        operatorType:SQLOperatorEqual
                                                       andFieldValue:customActionWebserviceLayer.objectFieldId];
    NSArray * fieldNames = [self fetchColumnName:paramList];
    
    NSArray * criteriaObjects = [[NSArray alloc] initWithObjects:criteriaOne, nil];
    
    NSArray *wizardComponentParamArray=[self fetchDataFromObjectNameObject:customActionWebserviceLayer.objectName fields:fieldNames expression:nil criteria:criteriaObjects];
    return  wizardComponentParamArray;
}
-(NSArray *)fetchColumnName:(NSArray *)array{
    NSMutableArray *fieldNames=[[NSMutableArray alloc] init];
    for(CustomActionURLModel *customModel in array) {
        if ([customModel.ParameterType isEqualToString:@"Field Name"]) {
            [fieldNames addObject:customModel.ParameterValue];
        }
    }
    return fieldNames;
}
- (NSArray *)fetchRequestParametersForTechnicianLocationUpdateRequest{
    
    NSArray *result;
    id gpsLogService = [FactoryDAO serviceByServiceType:ServiceTypeUserGPSLog];
    if ([gpsLogService conformsToProtocol:@protocol(UserGPSLogDAO)]) {
        
        UserGPSLogModel *model = [gpsLogService getLastGPSLog];
        
        NSMutableDictionary *finaldict = [[NSMutableDictionary alloc]initWithCapacity:0];
        [finaldict setObject:@"Fields" forKey:kSVMXKey];
        [finaldict setObject:@"" forKey:kSVMXValue];
        
        if (![StringUtil isStringEmpty:model.latitude] && ![StringUtil isStringEmpty:model.longitude]) {
            
            NSDictionary *latDict = @{kSVMXKey:ORG_NAME_SPACE@"__Latitude__c",
                                      kSVMXValue:model.latitude};
            NSDictionary *longDict = @{kSVMXKey:ORG_NAME_SPACE@"__Longitude__c",
                                       kSVMXValue:model.longitude};
            [finaldict setObject:@[latDict,longDict] forKey:kSVMXSVMXMap];
        } else {
            [finaldict setObject:@[] forKey:kSVMXSVMXMap];
        }
        
        RequestParamModel *reqParModel = [[RequestParamModel alloc]init];
        reqParModel.valueMap = @[finaldict];
        result = @[reqParModel];
    }
    
    return result;
}

- (NSArray *)fetchRequestParametersForAPNSRequest
{
    NSArray *resultArray;
    
    NSString *objectName = [[CacheManager sharedInstance]getCachedObjectByKey:@"searchObjectName"];
    NSString *recordId = [[CacheManager sharedInstance]getCachedObjectByKey:@"searchSFID"];
    
    //pushNotificationModel.objectName = @"SVMXC__Service_Order_Line__c";
    //pushNotificationModel.sfId = @"a39J00000002zUfIAI";
    
    
    NSMutableDictionary *valueMapForObject = [[NSMutableDictionary alloc]initWithCapacity:0];
    [valueMapForObject setObject:@"Object_Name" forKey:kSVMXKey];
    [valueMapForObject setObject:objectName forKey:kSVMXValue];
    
    
    
    NSMutableDictionary *valueMap_RecordId = [[NSMutableDictionary alloc]initWithCapacity:0];
    [valueMap_RecordId setObject:@"Record_Id" forKey:kSVMXKey];
    [valueMap_RecordId setObject:recordId forKey:kSVMXValue];
    
    
    NSArray *valueMapArray  = [NSArray arrayWithObjects:valueMap_RecordId,nil];
    [valueMapForObject setObject:valueMapArray forKey:kSVMXSVMXMap];
    
    
    RequestParamModel *reqParModel = [[RequestParamModel alloc]init];
    
    reqParModel.valueMap = @[valueMapForObject];
    
    resultArray = @[reqParModel];
    
    return resultArray;
}
@end
