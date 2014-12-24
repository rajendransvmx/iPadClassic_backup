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
#import "SMDataPurgeManager.h"

@implementation DataPurgeServiceLayer

- (ResponseCallback*)processResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                        responseData:(id)responseData {
    
    ResponseCallback *callBack = nil;
    
    WebServiceParser *parserObj = (WebServiceParser *)[ParserFactory parserWithRequestType:self.requestType];
    if ([parserObj conformsToProtocol:@protocol(WebServiceParserProtocol)]) {
        
        parserObj.clientRequestIdentifier = self.requestIdentifier;
        
        if(!requestParamModel)
        {
            requestParamModel = [[RequestParamModel alloc] init];
        }
        
        if(!requestParamModel.requestInformation){
            
            requestParamModel.requestInformation = @{@"key":[NSString stringWithFormat:@"%d",(int)self.requestType]};
        }
        callBack = [parserObj parseResponseWithRequestParam:requestParamModel
                                               responseData:responseData];
    }
    
    [self updateDataPurgeManagerWithCallback:callBack];
    return callBack;
}

- (void)updateDataPurgeManagerWithCallback:(ResponseCallback *)callback
{
    switch (self.requestType) {
        case RequestDataPurgeFrequency:
        {
            if(!callback.callBack)
            {
            [[SMDataPurgeManager sharedInstance] manageDataPurge];
            }
        }
            break;
        case RequestDatPurgeDownloadCriteria:
        {
            [[SMDataPurgeManager sharedInstance] manageDataPurge];
        }
            break;
        case RequestDataPurgeAdvancedDownLoadCriteria:
        {
            [[SMDataPurgeManager sharedInstance] manageDataPurge];
        }
            break;
        case RequestDataPurgeGetPriceDataTypeZero:
        {
            
        }
            break;
        case RequestDataPurgeGetPriceDataTypeOne:
        {
            
        }
            break;
        case RequestDataPurgeGetPriceDataTypeTwo:
        {
            
        }
            break;
        case RequestDataPurgeGetPriceDataTypeThree:
        {
            [[SMDataPurgeManager sharedInstance] manageDataPurge];
        }
            break;
        default:
            break;
    }
}
@end
