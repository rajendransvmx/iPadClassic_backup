//
//  BaseMetaSyncStatus.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   MetaSyncStatusModel.h
 *  @class  MetaSyncStatusModel
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



@interface MetaSyncStatusModel : NSObject

@property(nonatomic, strong) NSString *syncStatus;

- (id)init;

- (void)explainMe;

@end