//
//  DataPurgeServiceLayer.m
//  ServiceMaxMobile
//
//  Created by Anoop on 8/13/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "DataPurgeServiceLayer.h"
#import "WebServiceParser.h"
#import "ParserFactory.h"
#import "SMDataPurgeManager.h"
#import "PlistManager.h"
#import "FactoryDAO.h"
#import "SFPicklistService.h"
#import "TransactionObjectService.h"
#import "SFPicklistModel.h"

@implementation DataPurgeServiceLayer

- (ResponseCallback*)processResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                        responseData:(id)responseData {
    
    ResponseCallback *callBack = nil;
    
    WebServiceParser *parserObj = (WebServiceParser *)[ParserFactory parserWithRequestType:self.requestType];
    if ([parserObj conformsToProtocol:@protocol(WebServiceParserProtocol)]) {
        
        parserObj.clientRequestIdentifier = self.requestIdentifier;
        
        if(!requestParamModel)
        {
            requestParamModel = [[RequestParamModel alloc] init];
        }
        
        if(!requestParamModel.requestInformation){
            
            requestParamModel.requestInformation = @{@"key":[NSString stringWithFormat:@"%d",(int)self.requestType]};
        }
        callBack = [parserObj parseResponseWithRequestParam:requestParamModel
                                               responseData:responseData];
    }
    
    [self updateDataPurgeManagerWithCallback:callBack];
    return callBack;
}

- (void)updateDataPurgeManagerWithCallback:(ResponseCallback *)callback
{
    switch (self.requestType) {
        case RequestDataPurgeFrequency:
        {
//            if(!callback.callBack)
//            {
//            [[SMDataPurgeManager sharedInstance] manageDataPurge];
//            }
        }
            break;
        case RequestDatPurgeDownloadCriteria:
        {
            if(!callback.callBack)
            {
                [[SMDataPurgeManager sharedInstance] manageDataPurge];
            }
        }
            break;
        case RequestDataPurgeAdvancedDownLoadCriteria:
        {
            if(!callback.callBack)
            {
                [[SMDataPurgeManager sharedInstance] manageDataPurge];
            }

        }
            break;
        case RequestDataPurgeGetPriceDataTypeZero:
        {
            
        }
            break;
        case RequestDataPurgeGetPriceDataTypeOne:
        {
            
        }
            break;
        case RequestDataPurgeGetPriceDataTypeTwo:
        {
            
        }
            break;
        case RequestDataPurgeGetPriceDataTypeThree:
        {
            if(!callback.callBack)
            {
                [[SMDataPurgeManager sharedInstance] manageDataPurge];
            }

        }
            break;
            
        case RequestDataPurgeProductIQData:
        {
            if (!callback.callBack) {
                [[SMDataPurgeManager sharedInstance] manageDataPurge];
            }
        }
            break;
            
        default:
            break;
    }
}



- (NSArray*)getRequestParametersWithRequestCount:(NSInteger)requestCount {
    
    switch (self.requestType) {
        case RequestDataPurgeAdvancedDownLoadCriteria:
        {
            RequestParamModel *model = [[RequestParamModel alloc] init];
            model.valueMap = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjects:@[kADCOptimized, kTrue] forKeys:@[kSVMXKey, kSVMXValue]]]; // IPAD-4698
            model.requestInformation = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:self.categoryType] forKey:@"categoryType"];
            return @[model];
        }
            break;
        case RequestDataPurgeGetPriceDataTypeZero:
            return [self getRequestParamModelForGetPriceData:RequestDataPurgeGetPriceDataTypeZero];
            break;
        case RequestDataPurgeGetPriceDataTypeOne:
            return [self getRequestParamModelForGetPriceData:RequestDataPurgeGetPriceDataTypeOne];
            break;
        case RequestDataPurgeGetPriceDataTypeTwo:
            return [self getRequestParamModelForGetPriceData:RequestDataPurgeGetPriceDataTypeTwo];
            break;
        case RequestDataPurgeGetPriceDataTypeThree:
            return [self getRequestParamModelForGetPriceData:RequestDataPurgeGetPriceDataTypeThree];
            break;
        case RequestDataPurgeProductIQData:
            return [self getProdIQDataRequestParam];
            break;
        default:
            break;
    }
    
    // NSLog(@"Invalid request type");
    return nil;
    
}

-(NSArray *)getProdIQDataRequestParam {
    RequestParamModel *model = [[RequestParamModel alloc]init];
    NSDictionary *lastIndexDict = [NSDictionary dictionaryWithObjects:@[[NSNull null], @"LAST_INDEX", [NSNull null], [NSNull null], [NSNull null], [NSNumber numberWithInt:0], @[], @[]] forKeys:@[@"data", @"key", @"lstInternal_Request", @"lstInternal_Response", @"record", @"value", @"valueMap", @"values"]];
    model.valueMap = @[lastIndexDict];
    model.values = @[];
    return @[model];
}


-(NSArray*)getRequestParamModelForGetPriceData:(RequestType)getPriceDataType {
    
    RequestParamModel *paramObj = [[RequestParamModel alloc]init];
    
    switch (getPriceDataType) {
            
        case RequestDataPurgeGetPriceDataTypeZero:
            paramObj.valueMap = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:kGetPriceDataLastIndex,kSVMXKey,@0,kSVMXValue, nil]];
            break;
            
        case RequestDataPurgeGetPriceDataTypeOne:
            paramObj.valueMap = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:kGetPriceDataLastIndex,kSVMXKey,@1,kSVMXValue, nil]];
            break;
            
        case RequestDataPurgeGetPriceDataTypeTwo: {
            
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
            
        case RequestDataPurgeGetPriceDataTypeThree:
            paramObj.valueMap = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:kGetPriceDataLastIndex,kSVMXKey,@3,kSVMXValue, nil]];
            break;
            
        default:
            SXLogWarning(@"Invalid post body parama for unidentified get price request");
            break;
    }
    
//    if(self.categoryType == CategoryTypeOneCallDataSync)
//    {
//        NSDictionary *lastSyncTimeDict = [self getLastSyncTimeForRecords];
//        paramObj.valueMap = [paramObj.valueMap arrayByAddingObject:lastSyncTimeDict];
//    }
    
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


/*- (NSDictionary *)getLastSyncTimeForRecords {
    NSMutableDictionary *lastSyncTimeDict = [NSMutableDictionary dictionary];
    [lastSyncTimeDict setObject:kLastSyncTime forKey:kSVMXRequestKey];
    NSString *lastSyncTime = [PlistManager getInitialSyncTime];
    if (lastSyncTime == nil) {
        lastSyncTime = @"";
    }
    [lastSyncTimeDict setObject:lastSyncTime forKey:kSVMXRequestValue];
    return lastSyncTimeDict;
}*/

@end
