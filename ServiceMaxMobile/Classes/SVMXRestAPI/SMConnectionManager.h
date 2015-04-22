//
//  SMConnectionManager.h
//  iService
//
//  Created by Vipindas on 11/17/13.
//
//

#import <Foundation/Foundation.h>

@interface SMConnectionManager : NSObject
{
    NSString *sessionToken;
    NSString *instanceURL;
}

@property (nonatomic, retain) NSString *sessionToken;
@property (nonatomic, retain) NSString *instanceURL;

+ (SMConnectionManager *)sharedInstance;

- (void)refreshConnectionInfo;

@end
