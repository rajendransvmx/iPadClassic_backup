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
    RKRequest *rkRequest; //009382
}

@property (atomic, retain)SMRestRequest *smRestRequest;
@property (nonatomic,retain)RKRequest *rkRequest;

- (void)sendRequestWithDelegate:(id<SMRestRequestDelegate>)delegate;

+ (id)getHelperForRequest:(SMRestRequest *)smRestRequest;

@end
