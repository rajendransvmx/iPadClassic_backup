//
//  MobileDataUsageParser.m
//  ServiceMaxiPad
//
//  Created by Himanshi Sharma on 02/03/16.
//  Copyright © 2016 ServiceMax Inc. All rights reserved.
//

#import "MobileDataUsageParser.h"
#import "SMAppDelegate.h"

@implementation MobileDataUsageParser

- (ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                      responseData:(id)responseData
{
    
    if (![responseData isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    @synchronized([self class])
    {
        ResponseCallback * callBackObj = [[ResponseCallback alloc] init];
        @autoreleasepool
        {
            SMAppDelegate *appDelegate = (SMAppDelegate *)[[UIApplication sharedApplication]delegate];
            NSDictionary *responseDict = (NSDictionary *)responseData;
            NSArray *valueMap = [responseDict objectForKey:@"valueMap"];
            if ([valueMap count] != 0) {
                
                NSDictionary *loggingValuesDict = [valueMap objectAtIndex:0];
                NSString *theSyncReportingType = nil;
                if ([[loggingValuesDict objectForKey:@"key"] isEqualToString:@"USAGE_LOGGING_ENABLED"])
                {
                    theSyncReportingType = [loggingValuesDict objectForKey:@"value"]; //"always" or "error"
                    appDelegate.syncReportingType = theSyncReportingType;
                    if ([appDelegate.syncReportingType isEqualToString:@"always"])
                    {
                        SMLogSetLogLevel(4);
                    }
                    else if ([appDelegate.syncReportingType isEqualToString:@"error"])
                    {
                        SMLogSetLogLevel(1);

                    }
                    
                }
                else{
                    appDelegate.syncReportingType = nil;
                }
                //DefectFix:029303
                if ([valueMap count] == 2)
                {
                    NSDictionary *serverURLDict = [valueMap objectAtIndex:1];
                    NSString *defaultServerUrl = @"https://mtools.servicemax-api.com"; //Default set to Production
                    if ([[serverURLDict objectForKey:@"key"] isEqualToString:@"TOOLS_SERVER_URL"])
                    {
                        defaultServerUrl = [serverURLDict objectForKey:@"value"]; //"always" or "error"
                        
                    }
                    appDelegate.serverUrl = defaultServerUrl;
                    NSLog(@"AWS Server URL[%@]",appDelegate.serverUrl);

                }
               

            }
            
          
        }
        callBackObj.callBack = NO;
        return callBackObj;
    }
    
    return nil;
}

@end
