//
//  SLAClock.h
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 03/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLAClock : NSObject

@property(nonatomic,assign) BOOL shouldStartResolutionTimer;
@property(nonatomic,assign) BOOL shouldStartResotorationTimer;

@property(nonatomic,assign) BOOL isCustomerCommitment;

- (id)initWithDictionary:(NSDictionary *)slaDictonary;
- (NSString *)getRestorationTime;
- (NSString *)getResolutionTime;
- (NSString *)getResolutionTimeFormat;
- (NSString *)getRestorationTimeFormat;
- (NSDateComponents *)getRestorationTimerValue;
- (NSDateComponents *)getResolutionTimerValue;

- (BOOL)startResolutionTimer;
- (BOOL)startResotorationTimer;


@end
