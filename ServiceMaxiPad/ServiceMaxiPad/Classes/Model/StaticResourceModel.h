//
//  BaseStaticResource.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   StaticResourceModel.h
 *  @class  StaticResourceModel
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

@interface StaticResourceModel : NSObject

@property(nonatomic, strong) NSString *Id;
@property(nonatomic, strong) NSString *Name;

- (id)init;

+ (NSDictionary *)getMappingDictionary;

@end