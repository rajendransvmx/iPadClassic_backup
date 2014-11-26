//
//  BaseInternet_conflicts.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   InternetConflictModel.h
 *  @class  InternetConflictModel
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



@interface InternetConflictModel : NSObject

@property(nonatomic, strong) NSString *syncType;
@property(nonatomic, strong) NSString *errorMessage;
@property(nonatomic, strong) NSString *operationType;
@property(nonatomic, strong) NSString *errorType;

- (id)init;

- (void)explainMe;

@end