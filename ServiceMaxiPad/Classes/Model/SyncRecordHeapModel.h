//
//  BaseSyncRecordsHeap.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SyncRecordHeapModel.h
 *  @class  SyncRecordHeapModel
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


@interface SyncRecordHeapModel : NSObject

@property(nonatomic) BOOL syncFlag;
@property(nonatomic, copy) NSString *sfId;
@property(nonatomic, copy) NSString *localId;
@property(nonatomic, copy) NSString *objectName;
@property(nonatomic, copy) NSString *syncType;
@property(nonatomic, copy) NSString *recordType;
@property(nonatomic, copy) NSString *syncResponseType;
@property(nonatomic, copy) NSString *parallelSyncType;


- (id)init;


@end