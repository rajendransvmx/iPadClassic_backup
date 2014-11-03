//
//  ZKSDescribeObjectRequest.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 06/08/14.
//  Copyright (c) 2014 SivaManne. All rights reserved.
//

#import "ZKSDescribeObjectRequest.h"

@implementation ZKSDescribeObjectRequest

@synthesize describeObjectName;

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
        @synchronized([self class]) {
            @autoreleasepool {
                
                synchronousOperationComplete = NO;
                [[ZKServerSwitchboard switchboard] describeSObject:self.objectName target:self selector:@selector(describeSObjectResult:error:context:) context:nil];
                [ZKServerSwitchboard switchboard].logXMLInOut = NO;
                NSRunLoop *theRL = [NSRunLoop currentRunLoop];
                while (!synchronousOperationComplete && [theRL runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]])
                {
                }
            }
        }
    }
}

- (void)describeSObjectResult:(id)result error:(NSError *)error context:(id)context
{
    synchronousOperationComplete = YES;
    
    @synchronized([self class]) {
        
        if(error) {
            [self.serverRequestdelegate didRequestFailedWithError:error Response:result andRequestObject:self];
        }
        else {
            [self.serverRequestdelegate didReceiveResponseSuccessfully:result andRequestObject:self];
        }
        
    }
    
}

@end
