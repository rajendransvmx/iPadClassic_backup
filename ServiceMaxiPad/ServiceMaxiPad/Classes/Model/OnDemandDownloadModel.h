//
//  BaseOn_demand_download.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   OnDemandDownloadModel.h
 *  @class  OnDemandDownloadModel
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



@interface OnDemandDownloadModel : NSObject
@property(nonatomic, strong) NSString *objectName;
@property(nonatomic, strong) NSString *sfId;
@property(nonatomic, strong) NSString *localId;
@property(nonatomic, strong) NSString *recordType;
@property(nonatomic, strong) NSString *jsonRecord;

- (id)init;

- (void)explainMe;

@end