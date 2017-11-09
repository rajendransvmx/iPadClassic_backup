//
//  DatabaseSchemaConstant.h
//  ServiceMaxMobile
//
//  Created by Vipindas on 5/26/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   DatabaseSchemaConstant.h
 *  @class  DatabaseSchemaConstant
 *
 *  @brief  This class will provide all static table schema which has been used in this application
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

extern NSString *const kTableAttachmentErrorSchema;
extern NSString *const kTableAttachmentsSchema;
extern NSString *const kTableBusinessRuleSchema;
extern NSString *const kTableChatterPostDetailsSchema;
extern NSString *const kTableContactImageSchema;
extern NSString *const kTableDocumentSchema;
extern NSString *const kTableDocumentTemplateDetailSchema;
extern NSString *const kTableDocumentTemplateSchema;
extern NSString *const kTableEventLocalIdsSchema;
extern NSString *const kTableInternetConflictsSchema;
extern NSString *const kTableLinkedSFMProcessSchema;
extern NSString *const kTableLocalEventUpdateSchema;
//extern NSString *const kTableLookUpFieldValueSchema;
extern NSString *const kTableMetaSyncDueSchema;
extern NSString *const kTableMetaSyncStatusSchema;
extern NSString *const kTableMobileDeviceSettingsSchema; //kTableMobileDeviceSettings
extern NSString *const kTableMobileDeviceTagsSchema;
extern NSString *const kTableModifiedRecordsSchema; //kTableModifiedRecords
extern NSString *const kTableObjectNameFieldValueSchema;
extern NSString *const kTableOnDemandDownloadSchema;
extern NSString *const kTableProcessBusinessRuleSchema;
extern NSString *const kTableProductImageDataSchema;
extern NSString *const kTableRTDpPickListSchema;
extern NSString *const kTableServiceReportLogoSchema;
extern NSString *const kTableSFAttachmentTrailerSchema;
extern NSString *const kTableSFChildRelationshipSchema;
extern NSString *const kTableSFChildRelationshipSchema1;
extern NSString *const kTableSFDataTrailerSchema;
extern NSString *const kTableSFDataTrailerTempSchema;
extern NSString *const kTableSFExpressionComponentSchema;
extern NSString *const kTableSFExpressionComponentSchema1;
extern NSString *const kTableSFExpressionSchema;
extern NSString *const kTableSFExpressionSchema1;
extern NSString *const kTableSFMSearchFieldSchema;
extern NSString *const kTableSFMSearchFieldSchema1;
extern NSString *const kTableSFMSearchFilterCriteriaSchema;
extern NSString *const kTableSFMSearchFilterCriteriaSchema1;
extern NSString *const kTableSFMSearchFilterCriteriaSchema2;
extern NSString *const kTableSFMSearchProcessSchema;
extern NSString *const kTableSFMSearchProcessSchema1;
extern NSString *const kTableSFNamedSearchComponentSchema;
extern NSString *const kTableSFNamedSearchComponentSchema1;
extern NSString *const kTableSFNamedSearchFiltersSchema;
extern NSString *const kTableSFNamedSearchSchema;
extern NSString *const kTableSFObjectFieldSchema;
extern NSString *const kTableSFObjectFieldSchema1;
extern NSString *const kTableSFObjectMappingComponentSchema;
extern NSString *const kTableSFObjectMappingSchema;
extern NSString *const kTableSFObjectSchema;
extern NSString *const kTableSFObjectSchema1;
extern NSString *const kTableOPDocHtmlDataSchema;
extern NSString *const kTableOPDocSignatureDataSchema;
extern NSString *const kTableSFPickListSchema;
extern NSString *const kTableSFPickListSchema1;
extern NSString *const kTableSFProcessComponentSchema;
extern NSString *const kTableSFProcessComponentSchema1;
extern NSString *const kTableSFProcessSchema;
extern NSString *const kTableSFProcessSchema1;
extern NSString *const kTableSFProcessTestSchema;
extern NSString *const kTableSFRecordTypeSchema;
extern NSString *const kTableSFReferenceToSchema;
extern NSString *const kTableSFRequiredPdfSchema;
extern NSString *const kTableSFRequiredSignatureSchema;
extern NSString *const kTableSFSearchObjectsSchema;
extern NSString *const kTableSFSearchObjectsSchema1;
extern NSString *const kTableSFSearchObjectsSchema2;
extern NSString *const kTableSFSignatureDataSchema;
extern NSString *const kTableSFWizardComponentSchema;
extern NSString *const kTableSFWizardComponentSchema1;
extern NSString *const kTableSFWizardSchema;
extern NSString *const kTableSourceUpdateObjectSchema;
extern NSString *const kTableSourceUpdateSchema;
extern NSString *const kTableStaticResourceSchema;
extern NSString *const kTableSummaryPDFSchema;
extern NSString *const kTableJobLogsSchema;
extern NSString *const kTableJobLogsSchema1;
extern NSString *const kTableUserGPSLogSchema;
extern NSString *const kTableUserGPSLogSchema1;
extern NSString *const kTableSYNCErrorConflictSchema;
extern NSString *const kTableSYNCHistorySchema;
extern NSString *const kTableSyncRecordsHeapSchema;
extern NSString *const kTableSyncRecordsHeapSchema1;
extern NSString *const kTableTroubleshootDataSchema;
extern NSString *const kTableUserCreatedEventsSchem;
extern NSString *const kTableUserImagesSchema;
extern NSString *const kTableDataPurgeHeap;
//recents
extern NSString *const kTableRecentsSchema;
extern NSString *const kProductManualSchema;
extern NSString *const kTableAttachmentLocalSchema;

//Custom url Table
extern NSString *const kTableSFMCustomActionParams;
//Custom Action Request Params
extern NSString *const kTableSFMCustomActionRequestParams;

//ProductIQ tables.
extern NSString *const KTableRecordName;
extern NSString *const KTableTranslations;
extern NSString *const KTableFieldDescribe;
extern NSString *const KTableObjectDescribe;
extern NSString *const KTableConfiguration;
extern NSString *const KTableInstallBaseObject;
extern NSString *const KTableClientSyncLogTransient;
extern NSString *const kTableDescribeLayout;

@interface DatabaseSchemaConstant : NSObject


@end
