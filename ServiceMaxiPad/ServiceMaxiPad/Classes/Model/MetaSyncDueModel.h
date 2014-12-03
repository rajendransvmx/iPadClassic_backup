//
//  BaseMetaSyncDue.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   MetaSyncDueModel.h
 *  @class  MetaSyncDueModel
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



@interface MetaSyncDueModel : NSObject

@property(nonatomic) NSInteger localId;
@property(nonatomic, strong) NSString *description;

- (id)init;

- (void)explainMe;

@end