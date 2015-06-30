//
//  MobileUsageServiceLayer.m
//  ServiceMaxiPad
//
//  Created by Madhusudhan.HK on 6/24/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "MobileUsageServiceLayer.h"
#import "CacheManager.h"
#import "ParserFactory.h"
#import "WebServiceParser.h"
#import "ResourceHandler.h"

@implementation MobileUsageServiceLayer


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
    
    
    WebServiceParser *parserObj = (WebServiceParser *)[ParserFactory parserWithRequestType:self.requestType];
    if ([parserObj conformsToProtocol:@protocol(WebServiceParserProtocol)]) {
        
        parserObj.clientRequestIdentifier = self.requestIdentifier;
        callBack = [parserObj parseResponseWithRequestParam:requestParamModel
                                               responseData:responseData];
    }
    return callBack;
    
    
}

- (NSArray*)getRequestParametersWithRequestCount:(NSInteger)requestCount{
    
    RequestParamModel * param = nil;
    switch (self.requestType) {
       
            
        case RequestTypeMobileUsageDataDownload:
        {
            ResourceHandler *resourceHandler = [[ResourceHandler alloc]init];
            return [resourceHandler getMobileUsageDocumentRequestParameterForCount:requestCount];
        }
            break;
        default:
            break;
    }
    
    return (param != nil) ? @[param]:nil;
    
}

@end
