//
//  SFMPage.h
//  ServiceMaxMobile
//
//  Created by Aparna on 13/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   SFMPage.h
 *  @class  SFMPage
 *
 *  @brief
 *
 *   This is a model class used to hold the SFM page related information.
 *
 *  @author Aparna
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "SFMProcess.h"

@class SFMRecordFieldData;

@interface SFMPage : NSObject

@property(nonatomic,strong) NSString *objectName;
@property(nonatomic,strong) NSString *recordId;
@property(nonatomic,strong) NSString *objectLabel;
@property(nonatomic,strong) NSString *nameFieldValue;
@property(nonatomic,strong) SFMProcess *process;
@property(nonatomic,strong) NSMutableDictionary *headerRecord;
@property(nonatomic,strong) NSMutableDictionary *detailsRecord;
@property(nonatomic,strong) NSMutableDictionary *newlyCreatedRecordIds;
@property(nonatomic,strong) NSMutableDictionary *deletedRecordIds;
@property(nonatomic) BOOL isAttachmentEdited;

@property(nonatomic,strong) NSString *sourceObjectName;
@property(nonatomic,strong) NSString *sourceRecordId;

@property(nonatomic,strong)  NSMutableDictionary *sourceTargetRecordMap;

@property (nonatomic, strong) NSMutableArray *customWebserviceOptionsArray;
- (id)initWithObjectName:(NSString *)newObjectName andRecordId:(NSString *)newRecordId;
- (id)initWithSourceObjectName:(NSString *)srcObjectName andSourceRecordId:(NSString *)srcRecordId;

- (NSArray *)getHeaderLayoutFields;
- (NSString *)getHeaderSalesForceId;
- (SFMRecordFieldData *)getHeaderFieldDataForName:(NSString *)fieldName;
- (BOOL)isAttachmentEnabled;
-(BOOL)areChildRecordsSynced;

@end
