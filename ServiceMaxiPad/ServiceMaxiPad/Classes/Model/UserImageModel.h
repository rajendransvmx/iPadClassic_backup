//
//  BaseUserImages.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   UserImageModel.h
 *  @class  UserImageModel
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

@interface UserImageModel : NSObject

@property(nonatomic) NSInteger localId;

@property(nonatomic, strong) NSString *username;
@property(nonatomic, strong) NSData *userimage;

- (id)init;

@end