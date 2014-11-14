//
//  ZksDescribeLayoutRequest.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 06/08/14.
//  Copyright (c) 2014 SivaManne. All rights reserved.
//

#import "ZksDescribeLayoutRequest.h"

@implementation ZksDescribeLayoutRequest

/**
 * @name - (id)initWithType:(RequestType)requestType;
 *
 * @author Shubha
 *
 * @brief init based on request type.
 *
 *
 *
 * @param
 * @param
 *
 * @return id
 *
 */

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
            
            //TODO : Object Name and initiate the request
            synchronousOperationComplete = NO;
            
            self.startTime = [NSDate date];
            
            [[ZKServerSwitchboard switchboard] describeLayout:self.requestParameter.value target:self selector:@selector(didDescribeSObjectLayoutForObject:error:context:) context:nil];
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

- (void) didDescribeSObjectLayoutForObject:(ZKDescribeLayoutResult *)result error:(NSError *)error context:(id)context
{
    synchronousOperationComplete = YES;
    
    @synchronized([self class]) {
        
        if(error) {
            
            NSLog(@" %d req-f latency : %f sec", self.requestType,[[NSDate date] timeIntervalSinceDate:self.startTime]);

            [self.serverRequestdelegate didRequestFailedWithError:error
                                                         Response:result
                                                 andRequestObject:self];
        }
        else {
            NSLog(@" %d req-s latency : %f sec", self.requestType,[[NSDate date] timeIntervalSinceDate:self.startTime]);

            [self.serverRequestdelegate didReceiveResponseSuccessfully:result andRequestObject:self];
        }
        
    }
}
@end
