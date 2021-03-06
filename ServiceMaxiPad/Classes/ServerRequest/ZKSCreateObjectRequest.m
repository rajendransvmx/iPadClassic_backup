//
//  ZKSCreateObjectRequest.m
//  ServiceMaxiPad
//
//  Created by Admin on 31/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ZKSCreateObjectRequest.h"

@implementation ZKSCreateObjectRequest


- (id)initWithType:(RequestType)requestType
{
    self = [super init];
    if (self != nil)
    {
        self.requestType = requestType;
        self.requestIdentifier =  [AppManager generateUniqueId];
        self.apiType = @"ZKS";//PA
    }
    
    return self;
}

- (void)main {
    
    @synchronized([self class]) {
        @autoreleasepool {
            
            self.startTime = [NSDate date];
            
            synchronousOperationComplete = NO;
            
            [[ZKServerSwitchboard switchboard] create:self.requestParameter.values target:self selector:@selector(didAttachDocument:error:context:) context:self.requestParameter.context];

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


#pragma mark - Request Delegates

- (void)didAttachDocument:(NSArray *)result error:(NSError *)error context:(id)context
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
            
            if(result == nil || context == nil)
            {
                SXLogWarning(@"Invalid response! - Either result or context is nil.");
                [self.serverRequestdelegate didRequestFailedWithError:error
                                                             Response:result
                                                     andRequestObject:self];
                return;
            }
            
            NSDictionary *lDict = @{@"result": result, @"context": context};
            
            SXLogWarning(@"%lu req-s latency : %f sec", (unsigned long)(self.requestType), [[NSDate date] timeIntervalSinceDate:self.startTime]);
            
            [self.serverRequestdelegate didReceiveResponseSuccessfully:lDict andRequestObject:self];
        }
    }
}



@end
