//
//  BaseExistsSyncHistory.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//


/**
 *  @file   SyncHistoryModel.h
 *  @class  SyncHistoryModel
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



@interface SyncHistoryModel : NSObject

@property(nonatomic, strong) NSString *syncType;
@property(nonatomic, strong) NSString *requestId;
@property(nonatomic) BOOL syncStatus;

- (id)init;

- (void)explainMe;

@end