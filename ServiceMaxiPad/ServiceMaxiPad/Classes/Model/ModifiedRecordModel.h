//
//  BaseModifiedRecords.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   ModifiedRecordModel.h
 *  @class  ModifiedRecordModel
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




@interface ModifiedRecordModel : NSObject

@property(nonatomic) NSInteger localId;

@property(nonatomic) BOOL syncFlag;

@property(nonatomic, strong) NSString *recordLocalId;
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
@property(nonatomic, strong) NSString *requestData;
@property(nonatomic, strong) NSString *requestId;

@property(nonatomic) BOOL cannotSendToServer;
@property(nonatomic, strong) NSString *jsonRecord;
- (id)init;

- (void)explainMe;

@end



#define kModificationTypeUpdate   @"UPDATE"
#define kModificationTypeInsert   @"INSERT"
#define kModificationTypeDelete   @"DELETE"

#define kRecordTypeMaster         @"MASTER"
#define kRecordTypeDetail         @"DETAIL"