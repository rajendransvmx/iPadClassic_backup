//
//  BaseSFProcess.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFProcessModel.h
 *  @class  SFProcessModel
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

@interface SFProcessModel : NSObject


@property(nonatomic, copy) NSString *processId;
@property(nonatomic, copy) NSString *localId;
@property(nonatomic, copy) NSString *objectApiName;
@property(nonatomic, copy) NSString *processType;
@property(nonatomic, copy) NSString *processName;
@property(nonatomic, copy) NSString *processDescription;
@property(nonatomic, copy) NSString *pageLayoutId;
@property(nonatomic, copy) NSString *sfID;
@property(nonatomic, copy) NSString *docTemplateId;

@property(nonatomic, strong) NSData *processInfo;

+ (NSDictionary *) getMappingDictionary;

@end