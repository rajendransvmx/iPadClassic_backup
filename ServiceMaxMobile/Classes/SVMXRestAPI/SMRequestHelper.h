//
//  SMRequestHelper.h
//  iService
//
//  Created by Vipindas on 11/17/13.
//
//

#import <Foundation/Foundation.h>
#import "RKClient.h"
#import "SMRestRequest.h"

extern NSString * const kSFSessionTokenPrefix;


@interface SMRequestHelper : NSObject <RKRequestDelegate> {
    
    SMRestRequest *smRestRequest;
}

@property (nonatomic, retain)SMRestRequest *smRestRequest;


- (void)sendRequestWithDelegate:(id<SMRestRequestDelegate>)delegate;

+ (id)getHelperForRequest:(SMRestRequest *)smRestRequest;

@end
