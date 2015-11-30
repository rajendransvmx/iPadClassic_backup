//
//  ProdIQDataServiceLayer.m
//  ServiceMaxiPad
//
//  Created by Padmashree on 04/11/15.
//  Copyright © 2015 ServiceMax Inc. All rights reserved.
//

#import "ProdIQDataServiceLayer.h"
#import "ParserFactory.h"
#import "PlistManager.h"
#import "TXFetchHelper.h"

@interface ProdIQDataServiceLayer ()

@property (nonatomic, assign) NSString *lastSyncTime;

@end

@implementation ProdIQDataServiceLayer

- (instancetype) initWithCategoryType:(CategoryType)categoryType requestType:(RequestType)requestType {
    self = [super initWithCategoryType:categoryType requestType:requestType];
    if (self != nil) {
        //Intialize if required
        
    }
    return self;
}

- (ResponseCallback*)processResponseWithRequestParam:(RequestParamModel*)requestParamModel responseData:(id)responseData {
    ResponseCallback *callBack = nil;
    WebServiceParser *parserObj = (WebServiceParser *)[ParserFactory parserWithRequestType:self.requestType];
    if ([parserObj conformsToProtocol:@protocol(WebServiceParserProtocol)]) {
        parserObj.clientRequestIdentifier = self.requestIdentifier;
        parserObj.categoryType = self.categoryType;
        callBack = [parserObj parseResponseWithRequestParam:requestParamModel responseData:responseData];
    }
    return callBack;
}

- (NSArray*)getRequestParametersWithRequestCount:(NSInteger)count {
    switch (self.requestType) {
        case RequestProductIQData:
            return [self getProdIQDataRequestParam];
            break;
        case RequestTXFetch:
            return [self getTxFetcRequestParamsForRequestCount:count];
            break;
        case RequestProductIQDeleteData:
            return [self getProdIQDeleteDataRequestParam];
            break;
        default:
            break;
    }
    return nil;
}


-(NSArray *)getProdIQDataRequestParam {
    RequestParamModel *model = [[RequestParamModel alloc]init];
    NSDictionary *lastIndexDict = [NSDictionary dictionaryWithObjects:@[[NSNull null], @"LAST_INDEX", [NSNull null], [NSNull null], [NSNull null], [NSNumber numberWithInt:0], @[], @[]] forKeys:@[@"data", @"key", @"lstInternal_Request", @"lstInternal_Response", @"record", @"value", @"valueMap", @"values"]];
    
    NSDictionary *lastSyncTimeDict = [self getProdIQDataLastSyncTime];
    model.valueMap = @[lastIndexDict, lastSyncTimeDict];
    model.values = @[];
    return @[model];
}


-(NSArray *)getProdIQDeleteDataRequestParam {
    RequestParamModel *model = [[RequestParamModel alloc]init];
    NSDictionary *lastSyncTimeDict = [self getProdIQDataLastSyncTime];
    model.valueMap = @[lastSyncTimeDict];
    model.values = @[];
    return @[model];
}

- (NSDictionary *)getProdIQDataLastSyncTime {
    NSMutableDictionary *lastSyncTimeDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    [lastSyncTimeDict setObject:kProdIQLastSyncTime forKey:kSVMXRequestKey];
    
    if (self.lastSyncTime != nil) {
        [lastSyncTimeDict setObject:self.lastSyncTime forKey:kSVMXRequestValue];
        return lastSyncTimeDict;
    }
    
    self.lastSyncTime = [PlistManager getProdIQDataSyncTime];
    
    if (self.lastSyncTime == nil) {
        self.lastSyncTime = [PlistManager getOneCallSyncTime];
    }
    
    if (self.lastSyncTime == nil) {
        self.lastSyncTime = @"";
    }
    
    [lastSyncTimeDict setObject:self.lastSyncTime forKey:kSVMXRequestValue];
    return lastSyncTimeDict;
}


- (NSArray *)getTxFetcRequestParamsForRequestCount:(NSInteger )requestCount {
    @autoreleasepool {
        TXFetchHelper *helper = [[TXFetchHelper alloc] init];
        NSMutableArray *requestParams = [[NSMutableArray alloc] initWithCapacity:0];
        for (int counter = 0; counter < requestCount; counter++) {
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

@end