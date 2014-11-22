//
//  ProductManualServiveLayer.m
//  ServiceMaxiPad
//
//  Created by Chinnababu on 06/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ProductManualServiveLayer.h"
#import "CacheManager.h"
#import "ParserFactory.h"
#import "WebServiceParser.h"
#import "ResourceHandler.h"

@implementation ProductManualServiveLayer

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
        case RequestProductManual:
        {
            NSString *productId = [[CacheManager sharedInstance] getCachedObjectByKey:@"pMId"];
            if(productId != nil)
            {
                NSString *query  = [NSString stringWithFormat:@"SELECT Id, Name FROM Attachment WHERE ParentId = '%@' AND Name LIKE '%%MANUAL%%'", productId];
                
                param = [[RequestParamModel alloc] init];
                param.value = query;
            }
        }
            break;
            
        case RequestProductManualDownload:
        {
            ResourceHandler *resourceHandler = [[ResourceHandler alloc]init];
            return [resourceHandler getProductManualRequestParameterForCount:requestCount];
        }
            break;
        default:
            break;
    }
    return @[param];
}



@end
