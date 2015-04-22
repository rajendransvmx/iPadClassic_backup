//
//  DatabaseIndexConstant.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 5/26/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//
/**
 *  @file   DatabaseIndexConstant.m
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



// ***************** Indexing *********************

// Index Generation
// Static  Table
// Dynamic Table
// Future Index
//
// Create Index  (When, in Which Order)
// -- Static
// -- Dynamic
//
// Drop index     (When, in Which Order)
// -- Static
// -- Dynamic
//
// Dynamic table
// - Identifiy Tables which are needed index
// -- Common Index -- SFID, Local_ID
// -- Special Index or Compound Index
//
//
// Select Query Indexing
// -- Workflow
// -- Most used tables
// -- Most used queries,
// -- Query pattern (minimum number of index)



#import "DatabaseIndexConstant.h"

#pragma mark - Index constants
NSString *const kTableSyncRecordIndexSchema =  @"CREATE INDEX IF NOT EXISTS syncRecordHeapIndex ON Sync_Records_Heap (objectName ASC)";
NSString *const kTableMobileDeviceSettingsIndexSchema =  @"CREATE INDEX IF NOT EXISTS MobileDeviceSettingsIndex ON MobileDeviceSettings (settingId ASC)";
NSString *const kTableSFObjectKeyIndexSchema =  @"CREATE INDEX IF NOT EXISTS SFObjectKeyPrefixIndex ON SFObject (keyPrefix ASC)";
NSString *const kTableSearchObjectIndexSchema =  @"CREATE INDEX IF NOT EXISTS searchObjectsIndex ON SFM_Search_Objects (moduleId ASC)";
NSString *const kTableSearchFieldIndexSchema =  @"CREATE INDEX IF NOT EXISTS searchFieldIndex ON SFM_Search_Field (expressionRule ASC)";
NSString *const kTableSearchExpressionIndexSchema =  @"CREATE INDEX IF NOT EXISTS searchExpressionIndex ON SFExpression (expressionId ASC)";
NSString *const kTableSearchFilterCriteriaIndexSchema =  @"CREATE INDEX IF NOT EXISTS searchFilterCriteriaIndex ON SFM_Search_Filter_Criteria (expressionRule ASC)";
NSString *const kTableSyncErrorConflictIndex_1 =  @"CREATE INDEX IF NOT EXISTS syncErrorConflictIndex_1 ON syncErrorConflict (localId ASC)";
NSString *const kTableSyncErrorConflictIndex_2 =  @"CREATE INDEX IF NOT EXISTS syncErrorConflictIndex_2 ON syncErrorConflict (sfId ASC)";
NSString *const kTableEventIndexSchema =  @"CREATE INDEX IF NOT EXISTS eventIndex ON Event (Id ASC)";
NSString *const kTableAttachmentIndexSchema =  @"CREATE INDEX IF NOT EXISTS attachmentIndex ON Attachment (Id ASC)";
NSString *const kTableTaskIndexSchema =  @"CREATE INDEX IF NOT EXISTS tasktIndex ON Task (Id ASC)";
NSString *const kTablePricebookIndexSchema =  @"CREATE INDEX IF NOT EXISTS PricebookIndex ON Pricebook2 (Id ASC)";
NSString *const kTableAccountIndexSchema =  @"CREATE INDEX IF NOT EXISTS AccountIndex ON Account (Id ASC)";

#pragma mark - Drop Index constants

NSString *const kTableDropSyncRecordIndexSchema =  @"DROP INDEX IF EXISTS syncRecordHeapIndex";
NSString *const kTableDropMobileDeviceSettingsIndexSchema =  @"DROP INDEX IF EXISTS MobileDeviceSettingsIndex";
NSString *const kTableDropSFObjectKeyIndexSchema =  @"DROP INDEX IF EXISTS SFObjectKeyPrefixIndex";
NSString *const kTableDropSearchObjectIndexSchema =  @"DROP INDEX IF EXISTS searchObjectsIndex";
NSString *const kTableDropSearchFieldIndexSchema =  @"DROP INDEX IF EXISTS searchFieldIndex";
NSString *const kTableDropSearchExpressionIndexSchema =  @"DROP INDEX IF EXISTS searchExpressionIndex";
NSString *const kTableDropSearchFilterCriteriaIndexSchema =  @"DROP INDEX IF EXISTS searchFilterCriteriaIndex";
NSString *const kTableDropSyncErrorConflictIndex_1 =  @"DROP INDEX IF EXISTS syncErrorConflictIndex_1";
NSString *const kTableDropSyncErrorConflictIndex_2 =  @"DROP INDEX IF EXISTS syncErrorConflictIndex_2";
NSString *const kTableDropEventIndexSchema =  @"DROP INDEX IF EXISTS eventIndex";
NSString *const kTableDropAttachmentIndexSchema =  @"DROP INDEX IF EXISTS attachmentIndex";
NSString *const kTableDropTaskIndexSchema =  @"DROP INDEX IF EXISTS tasktIndex";
NSString *const kTableDropPricebookIndexSchema =  @"DROP INDEX IF EXISTS PricebookIndex";
NSString *const kTableDropAccountIndexSchema =  @"DROP INDEX IF EXISTS AccountIndex";

@implementation DatabaseIndexConstant

@end
