//
//  BaseSFPickList.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFPicklistModel.h
 *  @class  SFPicklistModel
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

@interface SFPicklistModel : NSObject

@property(nonatomic) NSInteger localId;
@property(nonatomic) NSInteger indexValue;

@property(nonatomic, strong) NSString *objectName;
@property(nonatomic, strong) NSString *fieldName;
@property(nonatomic, strong) NSString *label;
@property(nonatomic, strong) NSString *value;
@property(nonatomic, strong) NSString *defaultValue;
@property(nonatomic, strong) NSString *validFor;


- (id)init;

@end