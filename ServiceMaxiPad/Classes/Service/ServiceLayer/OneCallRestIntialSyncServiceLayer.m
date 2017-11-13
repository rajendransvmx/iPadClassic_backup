//
//  OneCallRestIntialSyncServiceLayer.m
//  ServiceMaxMobile
//
//  Created by Anoop on 8/14/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "OneCallRestIntialSyncServiceLayer.h"
#import "ParserFactory.h"
#import "ServiceFactory.h"
#import "SFProcessService.h"
#import "ResponseConstants.h"
#import "SFProcessComponentService.h"
#import "SFProcessComponentModel.h"
#import "SFMSearchObjectModel.h"
#import "SearchProcessObjectsService.h"
#import "NSString+StringUtility.h"
#import "StringUtil.h"
#import "CacheManager.h"
#import "DynamicTableCreator.h"
#import "FactoryDAO.h"
#import "SFRecordTypeDAO.h"
#import "SFObjectFieldService.h"
#import "RequestConstants.h"
#import "TXFetchHelper.h"
#import "SFPicklistService.h"
#import "TransactionObjectService.h"
#import "ResourceHandler.h"
#import "SFPicklistModel.h"
#import "PlistManager.h"
#import "CalenderHelper.h"
#import "ServerRequestManager.h"
#import "TimeLogCacheManager.h"
#import "ProductIQManager.h"
#import "OneCallDataSyncHelper.h"

@implementation OneCallRestIntialSyncServiceLayer

- (instancetype) initWithCategoryType:(CategoryType)categoryType
                          requestType:(RequestType)requestType {
    
    self = [super initWithCategoryType:categoryType requestType:requestType];
    
    if (self != nil) {
        //Intialize if required
        
    }
    
    return self;
    
}

- (ResponseCallback*)processResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                        responseData:(id)responseData {
    
    ResponseCallback *callBack = nil;
    
    ResourceHandler *resourcehandler = [[ResourceHandler alloc]init];
    
    switch (self.requestType) {
        case RequestStaticResourceDownload:
            callBack = [resourcehandler getResponceCallBackForStaticResourceDownloadWithRequestParam:requestParamModel];
            break;
        case RequestAttachmentDownload:
            callBack = [resourcehandler getResponceCallbackForAttachmentDownloadResponceWithRequestParam:requestParamModel];
            break;
        case RequestDocumentDownload:
            callBack = [resourcehandler getResponceCallBackForDocumentDownloadWithRequestParam:requestParamModel];
            break;
        default:
            break;
    }
    
    if (callBack != nil) {
        
        return callBack;
    }

    WebServiceParser *parserObj = (WebServiceParser *)[ParserFactory parserWithRequestType:self.requestType];
    parserObj.categoryType = self.categoryType;
    if ([parserObj conformsToProtocol:@protocol(WebServiceParserProtocol)]) {
        
       
        callBack = [parserObj parseResponseWithRequestParam:requestParamModel
                                               responseData:responseData];
        
        if (self.requestType == RequestSFMPageData &&  callBack != nil) {
            [self storeObjectNamesFromCacheSystem:callBack];
        }
        else{
            if (self.requestType == RequestGetPriceObjects && !callBack.callBack) {
                DynamicTableCreator *dynamicTableCreator = [[DynamicTableCreator alloc] init];
                [dynamicTableCreator createDynamicTables];
            }
            else if (self.requestType == RequestTXFetch && !callBack.callBack ) {
                /* tx fetch is done*/
                [self updateSfIdForSVMXEvent];
                
            }
        }
        
    }
    return callBack;
}

- (NSArray*)getRequestParametersWithRequestCount:(NSInteger)requestCount {
//Chinna : Time logs.
    NSArray * finalArray  = [super getRequestParametersWithRequestCount:requestCount];
    if(finalArray != nil)
    {
        return finalArray;
    }
    switch (self.requestType) {
        case RequestAdvancedDownLoadCriteria:
        {
            RequestParamModel *model = [[RequestParamModel alloc] init];
            model.valueMap = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjects:@[kADCOptimized, kTrue] forKeys:@[kSVMXKey, kSVMXValue]]]; // IPAD-4698
            model.requestInformation = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:self.categoryType] forKey:@"categoryType"];
            return @[model];
        }
            break;
        case RequestGetPriceDataTypeZero:
            return [self getRequestParamModelForGetPriceData:RequestGetPriceDataTypeZero];
            break;
        case RequestGetPriceDataTypeOne:
            return [self getRequestParamModelForGetPriceData:RequestGetPriceDataTypeOne];
            break;
        case RequestGetPriceDataTypeTwo:
            return [self getRequestParamModelForGetPriceData:RequestGetPriceDataTypeTwo];
            break;
        case RequestGetPriceDataTypeThree:
            return [self getRequestParamModelForGetPriceData:RequestGetPriceDataTypeThree];
            break;
        case RequestObjectDefinition:
            return [self getParametersForObjectDefinitionService];
            break;
        case RequestSFMPageData:
            return  [self createAndGetRequestParametersForPageLayout:requestCount];
            break;
        case RequestRecordType:
            return [self getRequestParamModelForRecordType]; //ZKS : Query is added as part of value in RequestParamModel
            break;
        case RequestDependantPickListRest:
            return [self createAndGetRequestParametersForDependantPickList:requestCount];
            break;
        case RequestRTDependentPicklist:
            return [self getRequestParametersForRTDependentPicklist];
            break;
        case RequestGetPriceCodeSnippet:
            return [self getRequestParametersForGetPriceCodeSnippet];
            break;
        case RequestTXFetch:
            return [self getTxFetcRequestParamsForRequestCount:requestCount];
            break;
        case RequestStaticResourceDownload:
        {
            ResourceHandler *resourceHandler = [[ResourceHandler alloc]init];
            return [resourceHandler getStaticeResourceRequestParameterForCount:requestCount];
        }
            break;
        case RequestAttachmentDownload:
        {
            ResourceHandler *resourceHandler = [[ResourceHandler alloc]init];
            return [resourceHandler getDownloadDocTemplateRequestparameterForCount:requestCount];
        }
            
            break;
        case RequestDocumentInfoFetch:
        {
            ResourceHandler *resourceHandler = [[ResourceHandler alloc]init];
            return [resourceHandler getRequestParamsForDocumentInformation];
        }
            break;
        case RequestDocumentDownload:
        {
            ResourceHandler *resourceHandler = [[ResourceHandler alloc]init];
            return [resourceHandler getDocumentResourceRequestParameterForCount:requestCount];
        }
            break;
        case RequestTypeUserTrunk:
        {
            RequestParamModel *model = [[RequestParamModel alloc] init];
            return @[model];
        }
            break;
        case RequestProductIQObjectDescribe:
        {
            return [self createParallelRequestsForProdIQObjectDescribe];
        }
            break;
        case RequestProductIQTxFetch:
        {
            return [self getProdIQTxFetcRequestParamsForRequestCount:requestCount];
        }
            break;
        case RequestProductIQData:
        {
            return [self getProdIQDataRequestParam];
        }
            break;
        default:
            break;
    }
    
   // NSLog(@"Invalid request type");
    return nil;
    
}


-(NSArray*)getRequestParamModelForGetPriceData:(RequestType)getPriceDataType {
    
    RequestParamModel *paramObj = [[RequestParamModel alloc]init];
    
    switch (getPriceDataType) {
            
        case RequestGetPriceDataTypeZero:
            paramObj.valueMap = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:kGetPriceDataLastIndex,kSVMXKey,@0,kSVMXValue, nil]];
            break;
            
        case RequestGetPriceDataTypeOne:
            paramObj.valueMap = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:kGetPriceDataLastIndex,kSVMXKey,@1,kSVMXValue, nil]];
            break;
            
        case RequestGetPriceDataTypeTwo: {
            
            NSMutableArray *valueMaps = [[NSMutableArray alloc] initWithCapacity:0];
            NSArray *valuesLabour = [self getValuesArrayForLabour];
            if (valuesLabour == nil) {
                valuesLabour = @[];
            }
            NSArray *valuesIsoCurrency = [self getValuesArrayForCurrencyISO];
            
            if ([valuesLabour count]) {
                NSDictionary *laborDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Labor",kSVMXRequestKey,valuesLabour,kSVMXRequestValues, nil];
                [valueMaps addObject:laborDict];
            }
            
            if ([valuesIsoCurrency count]) {
                 NSDictionary *currencyDict = [NSDictionary dictionaryWithObjectsAndKeys:@"CurrencyISO",kSVMXRequestKey,valuesIsoCurrency,kSVMXRequestValues, nil];
                [valueMaps addObject:currencyDict];
            }
            
            [valueMaps addObject:[NSDictionary dictionaryWithObjectsAndKeys:kGetPriceDataLastIndex,kSVMXKey,@2,kSVMXValue, nil]];
            paramObj.valueMap = [NSArray arrayWithArray:valueMaps];
            
            }
            break;
            
        case RequestGetPriceDataTypeThree:
            paramObj.valueMap = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:kGetPriceDataLastIndex,kSVMXKey,@3,kSVMXValue, nil]];
            break;
            
        default:
            SXLogWarning(@"Invalid post body parama for unidentified get price request");
            break;
    }
    
    if(self.categoryType == CategoryTypeOneCallDataSync)
    {
        NSDictionary *lastSyncTimeDict = [self getLastSyncTimeForRecords];
         paramObj.valueMap = [paramObj.valueMap arrayByAddingObject:lastSyncTimeDict];
    }
    
    return [NSArray arrayWithObject:paramObj];
}

-(NSArray*)getValuesArrayForLabour {
    
    NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:0];
    
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeSFPickList];
    NSArray * objectsList = nil;
    if ([daoService conformsToProtocol:@protocol(SFPicklistDAO)]) {
        objectsList = [daoService getListOfLaborActivityType];
    }
    for(SFPicklistModel *picklistModel in objectsList)
    {
        [values addObject:picklistModel.value];
    }
    return values;
    
}

-(NSArray*)getValuesArrayForCurrencyISO {
    
    NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:0];
    
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    NSArray * objectsList = nil;
    if ([daoService conformsToProtocol:@protocol(TransactionObjectDAO)]) {
        objectsList = [daoService getListWorkorderCurrencies];
    }
    for(TransactionObjectModel *transObjectModel in objectsList)
    {
        //getting currency from WO table
        if ([transObjectModel valueForField:@"CurrencyIsoCode"]) {
            [values addObject:[transObjectModel valueForField:@"CurrencyIsoCode"]];
        }
    }
    return values;
}

-(NSArray *)getRequestParamModelForRecordType
{
    NSMutableArray * recordTypeArray = nil;
    
    id <SFRecordTypeDAO> picklistService = [FactoryDAO serviceByServiceType:ServiceTypeSFRecordType];
    
    
    recordTypeArray = [picklistService fetchSFRecordTypeByIdS];
    NSMutableArray *requests = [[NSMutableArray alloc] initWithCapacity:0];

    
    if(recordTypeArray > 0)
    {
        RequestParamModel * param = [[RequestParamModel alloc] init];
        param.values = recordTypeArray;
        [requests addObject:param];
    }
    return requests;

    
    
    return recordTypeArray;
  //ZKS : Query is added as part of value in RequestParamModel
    
//    
//    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeSFRecordType];
//    NSArray * objectsList = nil;
//    if ([daoService conformsToProtocol:@protocol(SFRecordTypeDAO)]) {
//        objectsList = [daoService fetchObjectAPINames];
//    }
//    if(objectsList > 0)
//    {
//        RequestParamModel * param = [[RequestParamModel alloc] init];
//        NSString *stringArray = [StringUtil getConcatenatedStringFromArray:objectsList withSingleQuotesAndBraces:YES];
//        NSString * query = [NSString stringWithFormat:@"SELECT Id, Name ,SobjectType FROM RecordType WHERE SobjectType in %@",stringArray];
//        param.value = query;
//        param.values = 
//        [requests addObject:param];
//    }
//    return requests;
}


#pragma mark - private method

- (NSArray*)createAndGetRequestParametersForPageLayout:(NSInteger)requestCount
{
    /*get all page layout Id's
     //set the counter based on the page layout Ids count make
     //send multiple requests for page layout */
    
    id <SFProcessDAO> service= [FactoryDAO serviceByServiceType:ServiceTypeProcess];
    NSArray *pageLayoutIds1 = nil;
    
    if ([service conformsToProtocol:@protocol(SFProcessDAO)]) {
        pageLayoutIds1 = [service fetchPageLayoutIds];
    }
    
    NSMutableArray *pageLayoutIds = [NSMutableArray arrayWithArray:pageLayoutIds1];
    
    NSMutableArray *requestParamArray = [[NSMutableArray alloc]init];
    NSMutableArray *pageLayoutLimitArray = nil;
    
    if([pageLayoutIds count] > kPageLimit * requestCount)
    {
        NSInteger count =  kPageLimit * requestCount;
        pageLayoutLimitArray = [[NSMutableArray alloc] initWithArray:[pageLayoutIds subarrayWithRange:NSMakeRange(0,count)]];
        
    }
    else
    {
        
        pageLayoutLimitArray = [[NSMutableArray alloc] initWithArray:pageLayoutIds];
    }
    
    NSArray *finalarray = nil;
    
    for (NSUInteger i = 0; i < kMaximumNoOfParallelPageLayoutCalls; i++)
    {
        NSRange range;
        RequestParamModel *requestParamModel = [[RequestParamModel alloc]init];
        NSArray *tempArray = nil;
        
        if([pageLayoutLimitArray count] > kPageLimit)
        {
            range = NSMakeRange(0, kPageLimit);
            tempArray = [pageLayoutLimitArray subarrayWithRange:range];
            requestParamModel.values = tempArray;
            
            [pageLayoutLimitArray removeObjectsInRange:range];
            [pageLayoutIds removeObjectsInArray:tempArray];
        }
        
        else
        {
            requestParamModel.values = pageLayoutLimitArray;
            [pageLayoutIds removeObjectsInArray:pageLayoutLimitArray];
        }
        
        if(![finalarray count] >0)
        {
            NSString *contextValue =  [[ServerRequestManager sharedInstance]
                                       getTheContextvalueForCategoryType:self.categoryType];
            
            finalarray = [[TimeLogCacheManager sharedInstance] getRequestParameterForTimeLogWithCategory:contextValue forCategoryType:self.categoryType];
        }
        
        requestParamModel.valueMap = finalarray;
        
        [requestParamArray addObject:requestParamModel];
    }
    
    [[CacheManager sharedInstance] pushToCache:pageLayoutIds byKey:@"PageIds"];
    finalarray = nil;
    
    return requestParamArray;
}

- (NSArray *)getParametersForObjectDefinitionService {
    NSMutableDictionary *objectNamesDict = [[NSMutableDictionary alloc] init];
    NSString *emptyString = @"";
    SFProcessComponentService *componentService = [[SFProcessComponentService alloc] init];
    if ([componentService conformsToProtocol:@protocol(SFProcessComponentDAO)]) {
        NSArray *allModels =  [componentService getAllObjectApiNames];
        for (SFProcessComponentModel *model in allModels) {
            if (model.objectName != nil) {
                [objectNamesDict setObject:emptyString forKey:model.objectName];
            }
        }
    }
    componentService = nil;
    
    [objectNamesDict setObject:emptyString forKey:@"Task"];
    [objectNamesDict setObject:emptyString forKey:@"User"];
    [objectNamesDict setObject:emptyString forKey:@"Attachment"];
    
   SearchProcessObjectsService *searchProcessService = [[SearchProcessObjectsService alloc] init];
    if ([searchProcessService conformsToProtocol:@protocol(SearchProcessObjectsDAO)]) {
        NSArray *allModels =  [searchProcessService getAllObjectApiNames];
        for (SFMSearchObjectModel *model in allModels) {
            if (![StringUtil isStringEmpty:model.targetObjectName]) {
                [objectNamesDict setObject:emptyString forKey:model.targetObjectName];
            }
        }
    }
    searchProcessService = nil;
    
    NSDictionary *uniqueListFromCache = [self getUniqueObjectListFromCache];
    for (NSString *eachKey in uniqueListFromCache) {
       [objectNamesDict setObject:emptyString forKey:eachKey];
    }
    uniqueListFromCache = nil;
    
    [self clearObjectDataFromCache];
    
    NSInteger length = kOBJdefnLimit;
    
    NSArray *tempArray = [[objectNamesDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSMutableArray *allObjectNames = [NSMutableArray arrayWithArray:tempArray];
    
    NSArray *svmxObjects = [tempArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF contains %@", @"SVMX"]];
    
    [allObjectNames removeObjectsInArray:svmxObjects];
    [allObjectNames addObjectsFromArray:svmxObjects];
    
    if ([allObjectNames count] < length) {
        length = [allObjectNames count];
    }
    
    NSArray *objectNames = [allObjectNames subarrayWithRange:NSMakeRange(0, length)];
    [allObjectNames removeObjectsInRange:NSMakeRange(0, length)];
    [[CacheManager sharedInstance] pushToCache:allObjectNames byKey:kOBJdefList];
    
    RequestParamModel *model = [[RequestParamModel alloc] init];
    model.values = objectNames;
    return [NSArray arrayWithObjects:model,nil];
    
}

- (NSArray*)createAndGetRequestParametersForDependantPickList:(NSInteger)requestCount
{
    SFObjectFieldService *sfObjectFieldService = [[SFObjectFieldService alloc]init];
    
    NSArray * describeObjects =  [sfObjectFieldService getDependantPickListObjectNames]; //[NSArray arrayWithObjects:@"SVMXC__Service_Order_Line__c", nil];
    
    NSInteger partition = [describeObjects count] /requestCount;
    
    /* if quotient is less tahn numberOfConcurrentRequests + 1 ,final limit should be set to 5 */
    partition = (partition < requestCount)?[describeObjects count]:partition;
    NSInteger limit = partition;
    
    NSMutableArray *requestParamArray = [[NSMutableArray alloc]init];
    
    for (NSUInteger i = 0; i * limit < [describeObjects count]; i++) {
        NSUInteger start = i * limit;
        NSRange range = NSMakeRange(start, MIN([describeObjects count] - start, limit));
        RequestParamModel *requestParamModel = [[RequestParamModel alloc]init];
        
        //keeping objects in request info dictionary
        NSMutableDictionary *requestInfoDictionary = [[NSMutableDictionary alloc]init];
        
        NSMutableArray *subArray = [NSMutableArray arrayWithArray:[describeObjects subarrayWithRange:range]];
        
        if([subArray count] >0)
        {
            [requestInfoDictionary setValue:[subArray objectAtIndex:0] forKey:@"currentObject"];
            [subArray removeObjectAtIndex:0];
        }
        
        if ([subArray count] > 0) {
            [requestInfoDictionary setValue:subArray forKey:@"remainingObjects"];
        }

        requestParamModel.requestInformation = requestInfoDictionary;
        [requestParamArray addObject:requestParamModel];
    }
    
    return requestParamArray;
}

#pragma mark - Store objects from page layout in cache system

- (void)storeObjectNamesFromCacheSystem:(ResponseCallback *)responseCallBack {
    @synchronized([self class]) {
        
       NSMutableDictionary *dataDictionary = [responseCallBack.otherCallSInformation objectForKey:@"REFERENCE"];
        
        if ([dataDictionary count] > 0) {
        
            NSMutableDictionary *objectList = [[CacheManager sharedInstance] getCachedObjectByKey:@"uniqueObjectListForObjectDefnService"];
            
            if (objectList == nil) {
                //objectList = dataDictionary;
                 [[CacheManager sharedInstance] pushToCacheWithAutomaticDataCleanupProtection:dataDictionary byKey:@"uniqueObjectListForObjectDefnService"];
            }
            else{
                [objectList addEntriesFromDictionary:dataDictionary];
            }
        }
   }
    
    NSMutableDictionary *recordTypeDictionary =  [responseCallBack.otherCallSInformation objectForKey:@"RECORDTYPE"];
    
    if ([recordTypeDictionary count] > 0) {
       
        NSMutableDictionary *RTObjectList =   [[CacheManager sharedInstance] getCachedObjectByKey:@"uniqueObjectListForRecordTypeService"];
       
        if (RTObjectList == nil) {
            [[CacheManager sharedInstance] pushToCacheWithAutomaticDataCleanupProtection:recordTypeDictionary byKey:@"uniqueObjectListForRecordTypeService"];
              // RTObjectList = recordTypeDictionary;
        }
        else{
            [RTObjectList addEntriesFromDictionary:recordTypeDictionary];
        }
    }
}


- (NSDictionary *)getUniqueObjectListFromCache {
    return [[CacheManager sharedInstance] getCachedObjectByKey:@"uniqueObjectListForObjectDefnService"];
}

- (void)clearObjectDataFromCache {
    [[CacheManager sharedInstance] clearCacheByKey:@"uniqueObjectListForObjectDefnService"];
}


- (NSArray *)getRequestParametersForRTDependentPicklist
{
    RequestParamModel *reqModel = nil;
    NSArray *reqParArray = @[];
    NSMutableDictionary *RTObjectList = [[CacheManager sharedInstance] getCachedObjectByKey:@"uniqueObjectListForRecordTypeService"];
    if ((RTObjectList != nil) && ([RTObjectList count] > 0)) {
        
        reqModel = [[RequestParamModel alloc]init];
        NSString *firstKey = [[RTObjectList allKeys] objectAtIndex:0];
        reqModel.value = firstKey;
        [RTObjectList removeObjectForKey:firstKey];
        if ([RTObjectList count] >0) {
            
            reqModel.values = [RTObjectList allKeys];
        }
        reqParArray = @[reqModel];
    }
    return reqParArray;
}

#pragma mark - get price code snippet
- (NSArray *)getRequestParametersForGetPriceCodeSnippet
{
    /*
    RequestParamModel *model = [[RequestParamModel alloc]init];
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"JAVASCRIPT",kSVMXRequestValue,@"type",kSVMXRequestKey, nil];
    model.valueMap = [NSArray arrayWithObjects:dict, nil];
    return @[model];
    */
    
    RequestParamModel *model = [[RequestParamModel alloc]init];
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"JAVASCRIPT",kSVMXRequestValue,@"type",kSVMXRequestKey, nil];
    NSDictionary *dictForThirdPartyApp = [[NSDictionary alloc] initWithObjectsAndKeys:@"JSON",kSVMXRequestValue,@"type",kSVMXRequestKey, nil];
    
    model.valueMap = [NSArray arrayWithObjects:dict, dictForThirdPartyApp, nil];
    model.values = @[@"Code008" ];
    return @[model];
}

#pragma mark - get Parameter for tx fetc 

- (NSArray *)getTxFetcRequestParamsForRequestCount:(NSInteger )requestCount {
    @autoreleasepool {
        TXFetchHelper *helper = [[TXFetchHelper alloc] init];
        NSMutableArray *requestParams = [[NSMutableArray alloc] init];
        for (int counter = 0;counter < requestCount;counter++) {
            NSDictionary *recordIdDict =  [helper getIdListFromSyncHeapTableWithLimit:kOverallIdLimit forParallelSyncType:nil];
            if ([recordIdDict count] <= 0) {
                break;
            }
            RequestParamModel *paramObj = [[RequestParamModel alloc]init];
            paramObj.requestInformation = recordIdDict;
            paramObj.valueMap = [helper getValueMapDictionary:recordIdDict];
            [requestParams addObject:paramObj];
        }
        return requestParams;
    }
}

- (NSDictionary *)getLastSyncTimeForRecords {
    NSMutableDictionary *lastSyncTimeDict = [NSMutableDictionary dictionary];
    [lastSyncTimeDict setObject:kLastSyncTime forKey:kSVMXRequestKey];
    NSString *lastSyncTime = [PlistManager getOneCallSyncTime];
    if (lastSyncTime == nil) {
        lastSyncTime = @"";
    }
    [lastSyncTimeDict setObject:lastSyncTime forKey:kSVMXRequestValue];
    return lastSyncTimeDict;
}

- (void)updateSfIdForSVMXEvent
{
    [CalenderHelper updateOriginalSfIdForSVMXEvent];
}


#pragma mark - Product IQ

-(NSArray *)createParallelRequestsForProdIQObjectDescribe {
    NSArray *objDescArray = [[ProductIQManager sharedInstance] getProdIQRelatedObjects];
    NSMutableArray *requestParams = [NSMutableArray array];
    for (int count = 0; count < [objDescArray count]; count++) {
        RequestParamModel *model = [[RequestParamModel alloc] init];
        model.value = [objDescArray objectAtIndex:count];
        [requestParams addObject:model];
    }
    return requestParams;
}


- (NSArray *)getProdIQTxFetcRequestParamsForRequestCount:(NSInteger )requestCount {
    @autoreleasepool {
        
        TXFetchHelper *helper = [[TXFetchHelper alloc] init];
        NSMutableArray *requestParams = [[NSMutableArray alloc] init];
        
        NSString *locationObjName = kWorkOrderSite;
        
        id <TransactionObjectDAO>  transObj = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
        DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:locationObjName operatorType:(SQLOperatorIsNotNull) andFieldValue:nil];
        NSArray * transactionRecords =  [transObj fetchDataWithhAllFieldsAsStringObjects:kWorkOrderTableName fields:@[locationObjName] expression:nil criteria:@[criteria]];
        
        NSMutableDictionary *objectIdsDictionary = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *idsDict = [[NSMutableDictionary alloc] init];
        
        for (TransactionObjectModel *model in transactionRecords) {
            NSString *sfID = [[model getFieldValueDictionary] objectForKey:locationObjName];
            BOOL recordExist = [transObj doesRecordExistsForObject:locationObjName forRecordId:sfID];
            if (!recordExist) {
                [idsDict  setObject:sfID forKey:sfID];
            }
        }
        
        if ([idsDict count] > 0) {
            
            [objectIdsDictionary setObject:idsDict forKey:locationObjName];
            
            OneCallDataSyncHelper *syncHelper = [[OneCallDataSyncHelper alloc] init];
            [syncHelper insertIdsIntoSyncHeapTable:objectIdsDictionary];
            
            for (int counter = 0; counter < requestCount; counter++) {
                
                NSDictionary *recordIdDict =  [helper getIdListFromSyncHeapTableWithLimit:kOverallIdLimit forParallelSyncType:nil];
                if ([recordIdDict count] <= 0) {
                    break;
                }
                
                RequestParamModel *paramObj = [[RequestParamModel alloc]init];
                paramObj.requestInformation = recordIdDict;
                NSMutableArray *valueMap = [NSMutableArray arrayWithArray:[helper getValueMapDictionary:recordIdDict]];
                paramObj.valueMap = valueMap;
                [requestParams addObject:paramObj];
            }
        }
        
        return requestParams;
    }
}


-(NSArray *)getProdIQDataRequestParam {
    RequestParamModel *model = [[RequestParamModel alloc]init];
    NSDictionary *lastIndexDict = [NSDictionary dictionaryWithObjects:@[[NSNull null], @"LAST_INDEX", [NSNull null], [NSNull null], [NSNull null], [NSNumber numberWithInt:0], @[], @[]] forKeys:@[@"data", @"key", @"lstInternal_Request", @"lstInternal_Response", @"record", @"value", @"valueMap", @"values"]];
    model.valueMap = @[lastIndexDict];
    model.values = @[];
    return @[model];
}

#pragma mark - end


@end
