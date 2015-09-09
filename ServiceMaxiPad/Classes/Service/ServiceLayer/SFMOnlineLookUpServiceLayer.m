//
//  SFMOnlineLookUpServiceLayer.m
//  ServiceMaxiPad
//
//  Created by Admin on 07/09/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "SFMOnlineLookUpServiceLayer.h"
#import "ParserFactory.h"
#import "CacheManager.h"

@implementation SFMOnlineLookUpServiceLayer

- (instancetype)initWithCategoryType:(CategoryType)categoryType requestType:(RequestType)requestType {
    self = [super initWithCategoryType:categoryType requestType:requestType];
    if (self != nil) {
        //Intialize if required
    }
    return self;
}

- (ResponseCallback*)processResponseWithRequestParam:(RequestParamModel*)requestParamModel responseData:(id)responseData {
    ResponseCallback *callBack = nil;
//    WebServiceParser *parserObj = (WebServiceParser *)[ParserFactory parserWithRequestType:self.requestType];
//    if ([parserObj conformsToProtocol:@protocol(WebServiceParserProtocol)]) {
//        parserObj.clientRequestIdentifier = self.requestIdentifier;
//        callBack = [parserObj parseResponseWithRequestParam:requestParamModel responseData:responseData];
//    }
    return callBack;
}

- (NSArray*)getRequestParametersWithRequestCount:(NSInteger)requestCount
{
    
    NSArray *requestArray;
    switch (self.requestType) {
        
        case RequestTypeOnlineLookUp:
            break;
            
        default:
            SXLogWarning(@"Invalid request type");
            break;
    }
    
    return requestArray;
    
}

@end
