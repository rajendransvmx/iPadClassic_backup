//
//  BaseSFDataTrailer_Temp.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFDataTrailerModel.h
 *  @class  SFDataTrailerModel
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


@interface SFDataTrailerModel : NSObject

@property(nonatomic) NSInteger localId;

@property(nonatomic) BOOL syncFlag;

@property(nonatomic, strong) NSString *sfId;
@property(nonatomic, strong) NSString *recordType;
@property(nonatomic, strong) NSString *operation;
@property(nonatomic, strong) NSString *objectName;
@property(nonatomic, strong) NSString *parentObjectName;
@property(nonatomic, strong) NSString *parentLocalId;
@property(nonatomic, strong) NSString *recordSent;
@property(nonatomic, strong) NSString *webserviceName;
@property(nonatomic, strong) NSString *className;
@property(nonatomic, strong) NSString *syncType;
@property(nonatomic, strong) NSString *headerLocalId;

- (id)init;

@end