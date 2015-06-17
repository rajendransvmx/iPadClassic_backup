//
//  RestRequest.h
//  ServiceMaxMobile
//
//  Created by Sahana on 27/04/15.
//  Copyright (c) 2015 SivaManne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMRestRequest.h"


@interface RestRequest : NSObject

+ (RestRequest *)getHelperForRequest:(SMRestRequest *)request;

- (void)sendRequestWithDelegate:(id<SMRestRequestDelegate>)delegate;

@end
