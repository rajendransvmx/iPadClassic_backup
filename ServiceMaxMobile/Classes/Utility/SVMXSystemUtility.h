//
//  SVMXSystemUtility.h
//  iService
//
//  Created by Vipindas on 11/18/13.
//
//

#import <Foundation/Foundation.h>

@interface SVMXSystemUtility : NSObject
{
    
}

@property(nonatomic, assign) NSInteger activeActivityCount;

+ (SVMXSystemUtility *)sharedInstance;

- (void)startNetworkActivity;
- (void)stopNetworkActivity;

@end
