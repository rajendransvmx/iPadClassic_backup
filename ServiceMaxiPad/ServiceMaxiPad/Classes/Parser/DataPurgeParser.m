//
//  DataPurgeParser.m
//  ServiceMaxiPad
//
//  Created by Chinnababu on 03/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "DataPurgeParser.h"
#import "RequestConstants.h"

@implementation DataPurgeParser
- (ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                      responseData:(id)responseData
{
    @synchronized([self class])
    {
        ResponseCallback * callBackObj = [[ResponseCallback alloc] init];
        @autoreleasepool
        {
        
            
            NSDictionary *responseDict = (NSDictionary *)responseData;
            [self parseDataForTheData:responseDict requestParam:requestParamModel];
           // NSArray *array = [responseDict objectForKey:@"records"];
                  }
        return callBackObj;
    }
}

- (void)parseDataForTheData:(NSDictionary *)dict  requestParam:(RequestParamModel *)requestParam
{
    RequestType currentRequestType = RequestTypeNone;
    
    NSString * requestTypeStr = nil;
    
    requestTypeStr = [requestParam.requestInformation objectForKey:@"key"];
    if(requestTypeStr != nil){
        currentRequestType = [requestTypeStr intValue];
    }
    
   /* if( currentRequestType == RequestDataPurgeGetPriceDataTypeZero)
    {
        
    }
    
    if( currentRequestType == RequestDataPurgeGetPriceDataTypeOne)
    {
        
    }
    
    if( currentRequestType == RequestDataPurgeGetPriceDataTypeTwo)
    {
        
    }
    
    if( currentRequestType == RequestDataPurgeGetPriceDataTypeThree)
    {
        
    }
    
    if( currentRequestType == RequestDataPurgeDownLoadCriteria)
    {
        
    }
    
    if( currentRequestType == RequestDataPurgeAdvancedDownloadCriteria)
    {
        
    }*/
    
    
}


@end
