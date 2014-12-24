//
//  BaseSOURCE_UPDATE.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   ResourceUpdateModel.h
 *  @class  ResourceUpdateModel
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


@interface ResourceUpdateModel : NSObject

@property(nonatomic, strong) NSString *Id;
@property(nonatomic, strong) NSString *action;
@property(nonatomic, strong) NSString *configurationType;
@property(nonatomic, strong) NSString *display_value;
@property(nonatomic, strong) NSString *process;
@property(nonatomic, strong) NSString *settingId;
@property(nonatomic, strong) NSString *source_fieldName;
@property(nonatomic, strong) NSString *target_fieldName;
@property(nonatomic, strong) NSString *sourceObjectName;
@property(nonatomic, strong) NSString *targetObjectName;

- (id)init;

@end