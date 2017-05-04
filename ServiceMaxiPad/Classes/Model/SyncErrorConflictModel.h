//
//  BaseSyncErrorConflict.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SyncErrorConflictModel.h
 *  @class  SyncErrorConflictModel
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


@interface SyncErrorConflictModel : NSObject

@property(nonatomic) NSInteger scLocalId;
@property(nonatomic, strong) NSString *sfId;
@property(nonatomic, strong) NSString *localId;
@property(nonatomic, strong) NSString *objectName;
@property(nonatomic, strong) NSString *recordType;
@property(nonatomic, strong) NSString *syncType;
@property(nonatomic, strong) NSString *errorMessage;
@property(nonatomic, strong) NSString *operationType;
@property(nonatomic, strong) NSString *errorType;
@property(nonatomic, strong) NSString *overrideFlag;
@property(nonatomic, strong) NSString *className;
@property(nonatomic, strong) NSString *methodName;
@property(nonatomic, strong) NSString *customWsError;
@property(nonatomic, strong) NSString *requestId;

@property(nonatomic, strong) NSString *objectLabel;
@property(nonatomic, strong) NSString *recordValue;
@property(nonatomic, readwrite) BOOL isWorkOrder;
@property(nonatomic, strong) NSString *svmxAcValue;
@property(nonatomic, strong) NSString *fieldsModified;

- (id)init;

@end
