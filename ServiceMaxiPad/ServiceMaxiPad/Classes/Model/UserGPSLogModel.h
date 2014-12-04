//
//  UserGPSLog.h
//  ServiceMaxiPad
//
//  Created by Pushpak on 17/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserGPSLogModel : NSObject

@property(nonatomic, copy) NSString *localId;
@property(nonatomic, copy) NSString *status;
@property(nonatomic, copy) NSString *latitude;
@property(nonatomic, copy) NSString *longitude;
@property(nonatomic, copy) NSString *user;
@property(nonatomic, copy) NSString *ownerId;
@property(nonatomic, copy) NSString *deviceType;
@property(nonatomic, copy) NSString *createdById;
@property(nonatomic, copy) NSString *additionalInfo;
@property(nonatomic, copy) NSString *timeRecorded;

@end
