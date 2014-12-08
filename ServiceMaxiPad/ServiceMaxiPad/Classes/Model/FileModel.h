//
//  FileModel.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 01/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//


/**
 *  @file   FileModel.h
 *  @class  FileModel
 *
 *  @brief
 *
 *   This is a modle class which holds all the infor requiered for file downloading.
 *
 *  @author Shubha S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import <Foundation/Foundation.h>

@interface FileModel : NSObject

@property(nonatomic, copy) NSString *sfId;
@property(nonatomic, copy) NSString *localId;
@property(nonatomic, copy) NSString *status;
@property(nonatomic, copy) NSString *fileName;
@property(nonatomic, copy) NSString *sol;
@property(nonatomic, copy) NSString *errorMessage;
@property(nonatomic, copy) NSString *isPrivate;
@property(nonatomic, copy) NSString *parentSfId;
@property(nonatomic, copy) NSString *suffixUrl;
@property(nonatomic, copy) NSString *objectName;
@property(nonatomic, copy) NSString *rootDirectory;

@property(nonatomic, assign) NSInteger fileSize;
@property(nonatomic, assign) NSInteger statusCode;
@property(nonatomic, assign) NSInteger errorCode;
@property(nonatomic, assign) NSInteger numberOfBytesDownloaded;
@property(nonatomic, assign) NSInteger actionType;


@end
