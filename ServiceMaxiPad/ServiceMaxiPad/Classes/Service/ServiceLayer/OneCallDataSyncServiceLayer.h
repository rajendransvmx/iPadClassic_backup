//
//  OneCallDataSyncServiceLayer.h
//  ServiceMaxMobile
//
//  Created by Anoop on 8/13/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   OneCallDataSyncServiceLayer.h
 *  @class  OneCallDataSyncServiceLayer
 *
 *  @brief  Service layer for OneCallDataSync categorytype
 *
 *
 *  @author  Anoopsaai Ramani
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "BaseServiceLayer.h"
#import "IncrementalSyncRequestParamHelper.h"
#import "OneCallRestIntialSyncServiceLayer.h"

@interface OneCallDataSyncServiceLayer : OneCallRestIntialSyncServiceLayer
@property(nonatomic, strong) IncrementalSyncRequestParamHelper * requestParamHelper;

@end


