//
//  AttachmentErrorModel.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   AttachmentErrorModel
 *  @class  class name
 *
 *  @brief This model holds the attachment info
 *
 *   This is a modle class whicg holds all the info.
 *
 *  @author Shubha S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

@interface AttachmentErrorModel : NSObject

@property(nonatomic) NSInteger localId;
@property(nonatomic) NSInteger errorCode;

@property(nonatomic, strong) NSString *attachmentId;
@property(nonatomic, strong) NSString *errorMessage;
@property(nonatomic, strong) NSString *fileName;
@property(nonatomic, strong) NSString *syncFlag;
@property(nonatomic, strong) NSString *type;
@property(nonatomic, strong) NSString *parentLocalId;
@property(nonatomic, strong) NSString *status;
@property(nonatomic, strong) NSString *action;
@property(nonatomic, strong) NSString *parentSfId;


- (id)init;

- (void)explainMe;

@end