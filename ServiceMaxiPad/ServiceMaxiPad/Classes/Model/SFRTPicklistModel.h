//
//  BaseSFRTPicklist.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFRTPicklistModel.h
 *  @class  SFRTPicklistModel
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

@interface SFRTPicklistModel : NSObject

@property(nonatomic) NSInteger localId;

@property(nonatomic, strong) NSString *objectAPIName;
@property(nonatomic, strong) NSString *recordTypeName;
@property(nonatomic, strong) NSString *recordTypeLayoutID;
@property(nonatomic, strong) NSString *recordTypeID;
@property(nonatomic, strong) NSString *fieldAPIName;
@property(nonatomic, strong) NSString *label;
@property(nonatomic, strong) NSString *value;
@property(nonatomic, strong) NSString *defaultLabel;
@property(nonatomic, strong) NSString *defaultValue;

- (id)init;

@end