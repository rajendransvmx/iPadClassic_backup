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

@property(nonatomic, strong) NSString *sfId;
@property(nonatomic, strong) NSString *localId;
@property(nonatomic, strong) NSString *objectName;
@property(nonatomic, strong) NSString *syncType;
//@property(nonatomic, strong) NSString *jsonRecord;
@property(nonatomic, strong) NSString *recordType;
@property(nonatomic,strong) NSString *syncResponseType;

- (id)init;

@end