//
//  QueryZksRequest.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 06/08/14.
//  Copyright (c) 2014 SivaManne. All rights reserved.
//

#import "QueryZksRequest.h"

@implementation QueryZksRequest
@synthesize query;

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
        //PA
        self.apiType = @"ZKS";
	}
    
    return self;
}

/** Responsible of creation of request object */
- (void)main {
    
    @synchronized([self class]) {
        @autoreleasepool {
            
            self.startTime = [NSDate date];
            //TODO : Object Name and initiate the request
            synchronousOperationComplete  = NO;
            
            [[ZKServerSwitchboard switchboard] query:self.requestParameter.value
                                              target:self
                                            selector:@selector(didGetResponceWithResult:error:context:)
                                             context:nil];
            
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


- (void)didGetResponceWithResult:(ZKQueryResult *)result
                           error:(NSError *)error
                         context:(id)context
{
    @synchronized([self class]) {
        
        synchronousOperationComplete = YES;
        
        if(error)
        {
            SXLogWarning(@"%d req-f latency : %f sec", self.requestType,[[NSDate date] timeIntervalSinceDate:self.startTime]);

            [self.serverRequestdelegate didRequestFailedWithError:error
                                                         Response:result
                                                 andRequestObject:self];
        }
        else
        {
            SXLogWarning(@"%d req-s latency : %f sec", self.requestType,[[NSDate date] timeIntervalSinceDate:self.startTime]);

            [self.serverRequestdelegate didReceiveResponseSuccessfully:result
                                                      andRequestObject:self];
        }
        
    }
}


@end
