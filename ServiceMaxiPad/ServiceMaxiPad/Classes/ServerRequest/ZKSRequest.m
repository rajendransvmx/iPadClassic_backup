//
//  ZKSRequest.m
//  ServiceMaxMobile
//
//  Created by Krishna Shanbhag on 01/06/14.
//  Copyright (c) 2014 SivaManne. All rights reserved.
//

#import "ZKSRequest.h"

@interface ZKSRequest ()


@end

@implementation ZKSRequest
@synthesize objectName;

/**
 * @name  init
 *
 * @author Krishna Shanbhag
 *
 * @brief Invoke a ZKS Object
 *
 * par
 *  <Long description goes here>
 *  Call this method to initialize the Request object of type ZKS
 *
 *
 *
 * @return ZKS Request Instance
 *
 */

#pragma mark - Initialization method
-(id)init
{
    if (self == [super init]) {
        //self.apiType = @""; //TODO : set as ZKS
    }
    return self;
}

#pragma mark - Request responsiblities
/** Overide this method if you want to implement your own start request */
- (void)start{
    @synchronized([self class]) {
        [super start];
    }
}
/** Responsible of creation of request object */
- (void)main {
    
}
/** Cancel request can be handled here */
- (void)cancel {
    @synchronized([self class]) {
        [super cancel];
        
    }
}


@end
