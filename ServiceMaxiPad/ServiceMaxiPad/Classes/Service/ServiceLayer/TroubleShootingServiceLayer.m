//
//  TroubleShootingServiceLayer.m
//  ServiceMaxMobile
//
//  Created by Anoop on 8/13/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "TroubleShootingServiceLayer.h"
#import "CacheManager.h"
#import "ParserFactory.h"
#import "WebServiceParser.h"
#import "ResourceHandler.h"

@implementation TroubleShootingServiceLayer

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
- (NSArray*)getRequestParametersWithRequestCount:(NSInteger)requestCount
{
    RequestParamModel * param = nil;
    switch (self.requestType) {
        case RequestTroubleshooting:
        {
            NSString *productName = [[CacheManager sharedInstance] getCachedObjectByKey:@"docName"];
            if(productName != nil)
            {
                NSString *query  = [NSString stringWithFormat:@"SELECT Id, Name, Keywords, type from Document WHERE Keywords LIKE '%%%@%%'", productName];
                param = [[RequestParamModel alloc] init];
                param.value = query;
            }
        }
        break;
            
        case RequestTroubleShootDocInfoFetch:
        {
            ResourceHandler *resourceHandler = [[ResourceHandler alloc]init];
            return [resourceHandler getTroubleshootingDocumentRequestParameterForCount:requestCount];
        }
        break;
        default:
            break;
    }

    return @[param];
}


@end
