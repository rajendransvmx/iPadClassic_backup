//
//  DatabaseIndexConstant.h
//  ServiceMaxMobile
//
//  Created by Vipindas on 5/26/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   DatabaseIndexConstant.h
 *  @class  DatabaseIndexConstant
 *
 *  @brief  This class will provide all static table Index which has been used in this application
 *
 *
 *  @author  Pushpak N
 *  @author  Vipindas Palli
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/


#import <Foundation/Foundation.h>

#pragma mark - Drop Index constants

//*************************** Indexing **************************

extern NSString *const kTableSyncRecordIndexSchema;
extern NSString *const kTableMobileDeviceSettingsIndexSchema;
extern NSString *const kTableSFObjectKeyIndexSchema;
extern NSString *const kTableSearchObjectIndexSchema;
extern NSString *const kTableSearchFieldIndexSchema;
extern NSString *const kTableSearchExpressionIndexSchema;
extern NSString *const kTableSearchFilterCriteriaIndexSchema;
extern NSString *const kTableSyncErrorConflictIndex_1;
extern NSString *const kTableSyncErrorConflictIndex_2;
extern NSString *const kTableEventIndexSchema;
extern NSString *const kTableAttachmentIndexSchema;
extern NSString *const kTableTaskIndexSchema;
extern NSString *const kTablePricebookIndexSchema;
extern NSString *const kTableAccountIndexSchema;

#pragma mark - Drop Index constants

//*************************** Indexing **************************

extern NSString *const kTableDropSyncRecordIndexSchema;
extern NSString *const kTableDropMobileDeviceSettingsIndexSchema;
extern NSString *const kTableDropSFObjectKeyIndexSchema;
extern NSString *const kTableDropSearchObjectIndexSchema;
extern NSString *const kTableDropSearchFieldIndexSchema;
extern NSString *const kTableDropSearchExpressionIndexSchema;
extern NSString *const kTableDropSearchFilterCriteriaIndexSchema;
extern NSString *const kTableDropSyncErrorConflictIndex_1;
extern NSString *const kTableDropSyncErrorConflictIndex_2;
extern NSString *const kTableDropEventIndexSchema;
extern NSString *const kTableDropAttachmentIndexSchema;
extern NSString *const kTableDropTaskIndexSchema;
extern NSString *const kTableDropPricebookIndexSchema;
extern NSString *const kTableDropAccountIndexSchema;

@interface DatabaseIndexConstant : NSObject

@end
