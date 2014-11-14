//
//  AttachmentModel.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   AttachmentModel.h
 *  @class  AttachmentModel
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

@interface AttachmentModel : NSObject

@property(nonatomic, strong) NSString *attachmentId;
@property(nonatomic, strong) NSString *attachmentName;
@property(nonatomic, strong) NSString *parentId;
@property(nonatomic, strong) NSData *attachmentBody;

@property(nonatomic, strong) NSString *localFilePath;
@property(nonatomic, strong) NSString *urlSuffix;


- (id)init;

- (void)explainMe;

+ (NSDictionary*)getMappingDictionary;

@end