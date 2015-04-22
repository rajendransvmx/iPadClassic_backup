//
//  JobLogModel.h
//  ServiceMaxiPad
//
//  Created by Pushpak on 13/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JobLogModel : NSObject

@property(nonatomic, copy) NSString *localId;
@property(nonatomic, copy) NSString *timeStamp;
@property(nonatomic) NSInteger level;
@property(nonatomic, copy) NSString *context;
@property(nonatomic, copy) NSString *message;
@property(nonatomic, copy) NSString *type;
@property(nonatomic, copy) NSString *groupId;
@property(nonatomic, copy) NSString *profileId;
@property(nonatomic, copy) NSString *category;
@property(nonatomic, copy) NSString *operation;

@end
