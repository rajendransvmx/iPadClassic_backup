//
//  DODServiceLayer.m
//  ServiceMaxMobile
//
//  Created by Anoop on 8/13/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "DODServiceLayer.h"

@implementation DODServiceLayer

- (instancetype) initWithCategoryType:(CategoryType)categoryType
                          requestType:(RequestType)requestType {
    
    self = [super initWithCategoryType:categoryType requestType:requestType];
    
    if (self != nil) {
        //Intialize if required
        
    }
    
    return self;
    
}


////Refer thsio function from TroubleshootingServiceLayer
//
//- (ResponseCallback*)processResponseWithRequestParam:(RequestParamModel*)requestParamModel
//                                      responseData:(id)responseData {
//    
//    
//    ResponseCallback *callBack = nil;
//    
//    
//    WebServiceParser *parserObj = (WebServiceParser *)[ParserFactory parserWithRequestType:self.requestType];
//    if ([parserObj conformsToProtocol:@protocol(WebServiceParserProtocol)]) {
//        
//        parserObj.clientRequestIdentifier = self.requestIdentifier;
//        callBack = [parserObj parseResponseWithRequestParam:requestParamModel
//                                               responseData:responseData];
//    }
//    return callBack;
//    
//}
//
//- (RequestParamModel*)getRequestParameters {
//    
//    switch (self.requestType) {
//        case RequestDataOnDemandGetPriceInfo:
//            
//            break;
//            
//        case RequestDataOnDemandGetData:
//        {
//            /* HS 30 Oct */
//            /* add requet param for DOD here */
//            
//            RequestParamModel *reqParModel = [[RequestParamModel alloc]init];
//            
//            NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization
//                                                                   dataWithJSONObject:[self fetchFormattedJobLogs]
//                                                                   options:0
//                                                                   error:nil]
//                                                         encoding:4];
//            
//            NSDictionary *valueMapDic = @{@"key":@"LOGS",
//                                          @"value":jsonString};
//            
//            reqParModel.valueMap = @[valueMapDic];
//            return @[reqParModel];
//        }
//
//            
//            break;
//            
//        default:
//            break;
//    }
//    NSLog(@"Invalid request type");
//    return nil;
//    
//}






@end
