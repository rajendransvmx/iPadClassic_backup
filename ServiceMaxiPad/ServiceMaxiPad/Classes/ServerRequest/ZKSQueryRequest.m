//
//  ZKSQueryRequest.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 22/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ZKSQueryRequest.h"

@implementation ZKSQueryRequest


- (id)initWithType:(RequestType)requestType
{
    self = [super init];
    if (self != nil)
    {
        self.requestType = requestType;
        self.requestIdentifier =  [AppManager generateUniqueId];
    }
    
    return self;
}

- (void)main {
    
    @synchronized([self class]) {
        @autoreleasepool {
            
            self.startTime = [NSDate date];
            
            synchronousOperationComplete = NO;
            
            [[ZKServerSwitchboard switchboard] query:self.requestParameter.value target:self selector:@selector(didQueryChatterForProductId:error:context:) context:nil];
            
            [ZKServerSwitchboard switchboard].logXMLInOut = NO;
            NSRunLoop *theRL = [NSRunLoop currentRunLoop];
            
            while (!synchronousOperationComplete && [theRL runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]])
            {
                if(synchronousOperationComplete)
                {
                    break;
                }
            }
        }
    }
}

#pragma mark - Response delegate
- (void) didQueryChatterForProductId:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    synchronousOperationComplete = YES;
    
    @synchronized([self class]) {
        
        if(error) {
            
            SXLogWarning(@"%lu req-f latency : %f sec", (unsigned long)(self.requestType), [[NSDate date] timeIntervalSinceDate:self.startTime]);
            
            
            [self.serverRequestdelegate didRequestFailedWithError:error
                                                         Response:result
                                                 andRequestObject:self];
        }
        else {
            
            if(result == nil)
            {
                SXLogWarning(@"Invalid response! - Either result or context is nil.");
                [self.serverRequestdelegate didRequestFailedWithError:error
                                                             Response:result
                                                     andRequestObject:self];
                return;
            }
            
            NSDictionary *lDict = @{@"result": result};
            
            SXLogWarning(@"%lu req-s latency : %f sec", (unsigned long)(self.requestType), [[NSDate date] timeIntervalSinceDate:self.startTime]);
            
            [self.serverRequestdelegate didReceiveResponseSuccessfully:lDict andRequestObject:self];
        }
    }

}


#pragma maek - End

@end
