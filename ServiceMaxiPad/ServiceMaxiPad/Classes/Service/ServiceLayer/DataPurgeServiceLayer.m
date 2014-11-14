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

@implementation DataPurgeServiceLayer

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
    
        if(requestParamModel == nil)
        {
            requestParamModel = [[RequestParamModel alloc] init];
            
        }
        if(requestParamModel.requestInformation == nil){
            requestParamModel.requestInformation = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",self.requestType],@"key", nil];
        }
        
       
        
        callBack = [parserObj parseResponseWithRequestParam:requestParamModel
                                               responseData:responseData];
    }
    return callBack;

    
}

- (RequestParamModel*)getRequestParameters {
    
    switch (self.requestType) {
        case RequestDataPurge:
            
            break;
            
        default:
            break;
    }
    NSLog(@"Invalid request type");
    return nil;
    
}



@end
