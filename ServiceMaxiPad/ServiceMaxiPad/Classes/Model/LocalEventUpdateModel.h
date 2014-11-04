//
//  BaseLocal_event_update.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   LocalEventUpdateModel.h
 *  @class  LocalEventUpdateModel
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



@interface LocalEventUpdateModel : NSObject

@property(nonatomic, strong) NSString *objectName;
@property(nonatomic, strong) NSString *localId;

- (id)init;

- (void)explainMe;

@end