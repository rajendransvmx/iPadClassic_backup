//
//  SFMPageHistoryServiceLayer.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 25/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "SFMPageHistoryServiceLayer.h"
#import "ParserFactory.h"

@implementation SFMPageHistoryServiceLayer

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

/*- (NSArray*)getRequestParametersWithRequestCount:(NSInteger)requestCount
{
    NSArray *requestArray;
    switch (self.requestType) {
        case RequestTypeProductHistory:
            requestArray = nil;
            break;
            
        case RequestTypeAccountHistory:
            requestArray = nil;
        default:
            NSLog(@"Invalid request type");
            break;
    }
    return requestArray;
}*/


@end
