//
//  BaseUserCreatedEvent.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   UserCreatedEventModel.h
 *  @class  UserCreatedEventModel
 *
 *  @brief
 *
 *   This is a modle class which holds all the info.
 *
 *  @author Shubha S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

@interface UserCreatedEventModel : NSObject

@property(nonatomic, strong) NSString *objectName;
@property(nonatomic, strong) NSString *sfId;
@property(nonatomic, strong) NSString *localId;

- (id)init;

@end