//
//  BaseLookUpFieldValue.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   LookUpFieldValueModel.h
 *  @class  LookUpFieldValueModel
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




@interface LookUpFieldValueModel : NSObject

@property(nonatomic) NSInteger localId;
@property(nonatomic, strong) NSString *objectApiName;
@property(nonatomic, strong) NSString *Id;
@property(nonatomic, strong) NSString *value;

- (id)init;

- (void)explainMe;

@end