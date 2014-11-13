//
//  OneCallConfigSyncServiceLayer.m
//  ServiceMaxMobile
//
//  Created by Anoop on 8/13/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "OneCallConfigSyncServiceLayer.h"
#import "ParserFactory.h"
#import "SFProcessService.h"
#import "ServiceFactory.h"
#import "SFProcessService.h"

@implementation OneCallConfigSyncServiceLayer

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
    
    id parserObj = [ParserFactory parserWithRequestType:self.requestType];
    if ([parserObj conformsToProtocol:@protocol(WebServiceParserProtocol)]) {
        callBack = [parserObj parseResponseWithRequestParam:requestParamModel
                                               responseData:responseData];
        
    }
    return callBack;
    
}

- (NSArray*)getRequestParameters:(NSInteger)requestCount {
    
    switch (self.requestType) {
        case RequestAdvancedDownLoadCriteria:
            break;
        case RequestSFMPageData:
            break;
        default:
            break;
    }
    //NSLog(@"Invalid request type");
    return nil;
    
}

@end
