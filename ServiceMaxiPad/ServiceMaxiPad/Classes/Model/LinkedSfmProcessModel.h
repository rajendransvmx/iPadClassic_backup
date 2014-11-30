//
//  BaseLINKEDSFMProcess.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   LinkedSfmProcessModel.h
 *  @class  LinkedSfmProcessModel
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




@interface LinkedSfmProcessModel : NSObject

@property(nonatomic, strong) NSString *Id;
@property(nonatomic, strong) NSString *sourceHeader;
@property(nonatomic, strong) NSString *sourceDetail;
@property(nonatomic, strong) NSString *targetHeader;

- (id)init;

- (void)explainMe;

+ (NSDictionary*)getMappingDictionary;
@end