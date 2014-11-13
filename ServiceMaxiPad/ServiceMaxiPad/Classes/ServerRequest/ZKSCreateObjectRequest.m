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
            
            NSLog(@" %d req-f latency : %f sec", self.requestType, [[NSDate date] timeIntervalSinceDate:self.startTime]);

            
            [self.serverRequestdelegate didRequestFailedWithError:error
                                                         Response:result
                                                 andRequestObject:self];
        }
        else {
            
            NSDictionary *lDict = @{@"result": result, @"context": context};
            
            NSLog(@" %d req-s latency : %f sec", self.requestType, [[NSDate date] timeIntervalSinceDate:self.startTime]);
            
            [self.serverRequestdelegate didReceiveResponseSuccessfully:lDict andRequestObject:self];
        }
    }
}



@end
