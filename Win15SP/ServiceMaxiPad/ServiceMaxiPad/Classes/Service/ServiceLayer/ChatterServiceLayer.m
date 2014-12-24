//
//  ChatterServiceLayer.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 19/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ChatterServiceLayer.h"
#import "ParserFactory.h"
#import "ChatterHelper.h"
#import "ResourceHandler.h"

@implementation ChatterServiceLayer

- (instancetype)initWithCategoryType:(CategoryType)categoryType requestType:(RequestType)requestType {
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
        callBack = [parserObj parseResponseWithRequestParam:requestParamModel responseData:responseData];
    }
    return callBack;
}

- (NSArray*)getRequestParametersWithRequestCount:(NSInteger)requestCount
{
    NSArray *requestArray;
    switch (self.requestType) {
        case RequestTypeChatterrProductData:
            requestArray = [self getRequestParametersForProductImage];
            break;
        
        case RequestTypeChatterProductImageDownload:
        {
            ResourceHandler *handler = [[ResourceHandler alloc] init];
            requestArray = [handler getChatterProductImageParameterForCount:requestCount];
 
        }
        break;
        
        case RequestTypeChatterPost:
            requestArray = [self getRequestParametersForChatterPost];
            break;
        case RequestTypeChatterPostDetails:
            requestArray = [self getRequestParametersForChatterPostDetails];
            break;
        default:
            NSLog(@"Invalid request type");
            break;
    }
    return requestArray;
}

- (NSArray *)getRequestParametersForProductImage
{
    RequestParamModel *paramModel = nil;
    
    paramModel = [[RequestParamModel alloc] init];
    paramModel.value = [ChatterHelper requestQueryForProductIamge];

    return @[paramModel];
}

- (NSArray *)getRequestParametersForChatterPost
{
    RequestParamModel *paramModel = nil;
    
    paramModel = [[RequestParamModel alloc] init];
    paramModel.value = [ChatterHelper requestQueryForChatterPost];
    
    return @[paramModel];
}

- (NSArray *)getRequestParametersForChatterPostDetails
{
    RequestParamModel *paramModel = nil;
    
    paramModel = [[RequestParamModel alloc] init];
    paramModel.value = [ChatterHelper requestQueryForChatterPostDetails];
    
    return @[paramModel];
}
@end
