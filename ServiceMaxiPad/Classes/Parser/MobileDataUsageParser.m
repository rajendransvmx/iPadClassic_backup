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
                NSDictionary *values = [valueMap objectAtIndex:0];
                NSString *theSyncReportingType = nil;
                if ([[values objectForKey:@"key"] isEqualToString:@"USAGE_LOGGING_ENABLED"])
                {
                    theSyncReportingType = [values objectForKey:@"value"]; //"always" or "error"
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
            }
            else{
                appDelegate.syncReportingType = nil;
            }
          
        }
        callBackObj.callBack = NO;
        return callBackObj;
    }
    
    return nil;
}

@end
