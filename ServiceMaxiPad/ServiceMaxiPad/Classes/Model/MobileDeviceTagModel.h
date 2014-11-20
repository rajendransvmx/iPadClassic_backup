//
//  BaseMobileDeviceTags.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   MobileDeviceTagModel.h
 *  @class  MobileDeviceTagModel
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



@interface MobileDeviceTagModel : NSObject

@property(nonatomic) NSInteger localId;
@property(nonatomic, strong) NSString *tagId;
@property(nonatomic, strong) NSString *value;

- (id)init;

- (void)explainMe;

@end