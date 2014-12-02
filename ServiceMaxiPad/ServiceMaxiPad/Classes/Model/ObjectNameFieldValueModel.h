//
//  BaseObjectNameFieldValue.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   ObjectNameFieldValueModel.h
 *  @class  ObjectNameFieldValueModel
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




@interface ObjectNameFieldValueModel : NSObject

//@property(nonatomic, strong) NSString *objectName;
@property(nonatomic, strong) NSString *Id;
@property(nonatomic, strong) NSString *value;

- (id)init;

- (void)explainMe;

@end