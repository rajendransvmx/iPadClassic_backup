//
//  BaseSFAttachmentTrailer.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFAttachmentTrailerModel.h
 *  @class  SFAttachmentTrailerModel
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

@interface SFAttachmentTrailerModel : NSObject

@property(nonatomic) NSInteger localId;
@property(nonatomic) NSInteger priority;
@property(nonatomic) NSInteger size;


@property(nonatomic, strong) NSString *attachment_id;
@property(nonatomic, strong) NSString *objectName;
@property(nonatomic, strong) NSString *parent_localid;
@property(nonatomic, strong) NSString *parent_sfid;
@property(nonatomic, strong) NSString *file_name;
@property(nonatomic, strong) NSString *type;
@property(nonatomic, strong) NSString *status;
@property(nonatomic, strong) NSString *action;

- (id)init;

- (void)explainMe;

@end