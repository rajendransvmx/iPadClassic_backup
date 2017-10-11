//
//  DatabaseSchemaConstant.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 5/26/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   DatabaseSchemaConstant.m
 *  @class  DatabaseSchemaConstant
 *
 *  @brief  This class will provide all static table schema which has been used in this application
 *
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


#import "DatabaseSchemaConstant.h"

NSString *const kTableAttachmentErrorSchema = @"CREATE TABLE AttachmentError ('localId' VARCHAR, 'attachmentId' VARCHAR, 'errorMessage' VARCHAR, 'errorCode' INTEGER, 'fileName' VARCHAR, 'syncFlag' VARCHAR, 'type' VARCHAR, 'parentLocalId' VARCHAR, 'status' VARCHAR, 'action' VARCHAR, 'parentId' VARCHAR)";

NSString *const kTableAttachmentsSchema = @"CREATE TABLE IF NOT EXISTS Attachments (attachmentId text(18) PRIMARY KEY NOT NULL, attachmentName text(255), parentId VARCHAR, attachmentBody BLOB)";

NSString *const kTableBusinessRuleSchema = @"CREATE TABLE IF NOT EXISTS BusinessRule ('Id' VARCHAR PRIMARY KEY NOT NULL UNIQUE, 'advancedExpression' VARCHAR, 'description' VARCHAR, 'errorMessage' VARCHAR, 'messageType' VARCHAR, 'name' VARCHAR, 'processId' VARCHAR, 'sourceObjectName' VARCHAR, 'ruleType' VARCHAR)";

NSString *const kTableChatterPostDetailsSchema = @"CREATE TABLE IF NOT EXISTS ChatterPostDetail ('productId' VARCHAR NOT NULL, 'body' TEXT, 'createdById' VARCHAR, 'createdDate' VARCHAR, 'Id' VARCHAR, 'feedItemId' VARCHAR, 'postType' VARCHAR, 'userName' VARCHAR, 'name' VARCHAR, 'email' VARCHAR, 'fullPhotoUrl' VARCHAR)";

NSString *const kTableContactImageSchema = @"CREATE TABLE IF NOT EXISTS contact_images ('contact_Id' VARCHAR, 'contact_Image' VARCHAR)";

NSString *const kTableDocumentSchema = @"CREATE TABLE IF NOT EXISTS Document ('local_id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE DEFAULT (0), 'AuthorId' VARCHAR, 'Body' VARCHAR, 'BodyLength' INTEGER, 'ContentType' VARCHAR, 'CreatedById' VARCHAR, 'Description' VARCHAR, 'DeveloperName' VARCHAR, 'FolderId' VARCHAR, 'Id' VARCHAR, 'IsBodySearchable' BOOL, 'IsDeleted' BOOL, 'IsInternalUseOnly' BOOL, 'IsPublic' BOOL, 'Keywords' TEXT, 'LastModifiedById' VARCHAR, 'LastModifiedDate' DATETIME, 'Name' VARCHAR, 'NamespacePrefix' VARCHAR, 'SystemModstamp' VARCHAR, 'Type' VARCHAR)";

NSString *const kTableDocumentTemplateDetailSchema = @"CREATE TABLE IF NOT EXISTS DocTemplateDetails (docTemplate VARCHAR, docTemplateDetailId Text(255), headerReferenceField Text(100), alias Text(80), objectName Text(100), soql Text(32768), docTemplateDetailUniqueId Text(40), fields Text(32768), type VARCHAR, idTable VARCHAR PRIMARY KEY NOT NULL)";

NSString *const kTableDocumentTemplateSchema = @"CREATE TABLE IF NOT EXISTS DocTemplate ('docTemplateName' text(100), idTable text(18) PRIMARY KEY NOT NULL, docTemplateId text(40), isStandard BOOLEAN, detailObjectCount INTEGER, mediaResources TEXT)";

NSString *const kTableEventLocalIdsSchema = @"CREATE TABLE IF NOT EXISTS Event_local_ids ('object_name' VARCHAR ,'local_id' VARCHAR)";

NSString *const kTableInternetConflictsSchema = @"CREATE TABLE IF NOT EXISTS internet_conflicts ('sync_type' VARCHAR, 'error_message' VARCHAR, 'operation_type' VARCHAR, 'error_type' VARCHAR)";

NSString *const kTableLinkedSFMProcessSchema = @"CREATE TABLE IF NOT EXISTS 'LinkedSFMProcess' ('Id' VARCHAR PRIMARY KEY NOT NULL UNIQUE, 'sourceHeader' VARCHAR, 'sourceDetail' VARCHAR, 'targetHeader' VARCHAR )";

NSString *const kTableLocalEventUpdateSchema = @"CREATE TABLE IF NOT EXISTS local_event_update ('object_name' VARCHAR ,'local_id' VARCHAR)";

/*NSString *const kTableLookUpFieldValueSchema = @"CREATE TABLE IF NOT EXISTS LookUpFieldValue ('local_id' INTEGER PRIMARY KEY NOT NULL DEFAULT (0), 'object_api_name' VARCHAR, 'Id' VARCHAR, 'value' VARCHAR)";*/

NSString *const kTableObjectNameFieldValueSchema = @"CREATE TABLE IF NOT EXISTS ObjectNameFieldValue ('Id' VARCHAR PRIMARY KEY  NOT NULL  UNIQUE, 'value' VARCHAR)";

NSString *const kTableMetaSyncDueSchema = @"CREATE TABLE IF NOT EXISTS meta_sync_due ('local_id' INTEGER PRIMARY KEY NOT NULL UNIQUE, 'description' VARCHAR)";

NSString *const kTableMetaSyncStatusSchema = @"CREATE TABLE IF NOT EXISTS meta_sync_status ('sync_status' VARCHAR)";

NSString *const kTableMobileDeviceSettingsSchema = @"CREATE TABLE IF NOT EXISTS MobileDeviceSettings ('localId' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE, 'settingId' VARCHAR, 'value' VARCHAR)";

NSString *const kTableMobileDeviceTagsSchema = @"CREATE TABLE IF NOT EXISTS MobileDeviceTags ('localId' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE, 'tagId' VARCHAR, 'value' VARCHAR)";

NSString *const kTableModifiedRecordsSchema = @"CREATE TABLE IF NOT EXISTS ModifiedRecords ('localId' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 'recordLocalId' VARCHAR, 'sfId' VARCHAR, 'recordType' VARCHAR, 'operation' VARCHAR, 'objectName' VARCHAR, 'syncFlag' BOOL, 'parentObjectName' VARCHAR, 'parentLocalId' VARCHAR, 'recordSent' VARCHAR, 'webserviceName' VARCHAR, 'className' VARCHAR, 'syncType' VARCHAR, 'headerLocalId' VARCHAR, 'requestData' VARCHAR, 'requestId' VARCHAR,'Pending' VARCHAR, 'timeStamp' DATETIME,'fieldsModified' VARCHAR )";

/*NSString *const kTableObjectNameFieldValueSchema = @"CREATE TABLE IF NOT EXISTS ObjectNameFieldValue ('local_id' INTEGER PRIMARY KEY NOT NULL DEFAULT (0), 'object_name' VARCHAR, 'Id' VARCHAR, 'value' VARCHAR)";*/

NSString *const kTableOnDemandDownloadSchema = @"CREATE TABLE IF NOT EXISTS DODRecords ('objectName' VARCHAR, 'sfId' VARCHAR PRIMARY KEY NOT NULL UNIQUE, 'timeStamp' DATETIME, 'recordType' VARCHAR )";

NSString *const kTableProcessBusinessRuleSchema = @"CREATE TABLE IF NOT EXISTS ProcessBusinessRule ('Id' VARCHAR PRIMARY KEY NOT NULL UNIQUE, 'businessRule' VARCHAR, 'errorMessage' VARCHAR, 'name' VARCHAR, 'processNodeObject' VARCHAR, 'sequence' VARCHAR, 'targetManager' VARCHAR)";

NSString *const kTableProductImageDataSchema = @"CREATE TABLE IF NOT EXISTS ProductImageData ('productId' VARCHAR PRIMARY KEY  NOT NULL UNIQUE, 'productImageId' VARCHAR)";

NSString *const kTableRTDpPickListSchema = @"CREATE TABLE IF NOT EXISTS SFRTPicklist ('localId' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 'objectAPIName' VARCHAR, 'recordTypeName' VARCHAR, 'recordTypeLayoutID' VARCHAR, 'recordTypeID' VARCHAR, 'fieldAPIName' VARCHAR, 'label' VARCHAR, 'value' VARCHAR, 'defaultLabel' VARCHAR, 'defaultValue' VARCHAR)";

NSString *const kTableServiceReportLogoSchema = @"CREATE TABLE IF NOT EXISTS servicereprt_logo ('logo' VARCHAR)";

NSString *const kTableSFAttachmentTrailerSchema = @"CREATE TABLE SFAttachmentTrailer ('local_id' INTEGER PRIMARY KEY NOT NULL DEFAULT (0), 'priority' INTEGER, 'attachment_id' VARCHAR, 'objectName' VARCHAR, 'parent_localid' VARCHAR, 'parent_sfid' VARCHAR, 'file_name' VARCHAR, 'type' VARCHAR, 'size' INTEGER, 'status' VARCHAR, 'action' VARCHAR, 'per_progress' FLOAT)";

NSString *const kTableSFChildRelationshipSchema = @"CREATE TABLE IF NOT EXISTS SFChildRelationship ('localId' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL DEFAULT 0, 'objectNameParent' VARCHAR, 'objectNameChild' VARCHAR, 'fieldName' VARCHAR)";

// Cascade_delete?
// NSString *const kTableSFChildRelationshipSchema1 = @"CREATE TABLE IF NOT EXISTS SFChildRelationship ('local_id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL DEFAULT 0, 'object_api_name_parent' VARCHAR, 'object_api_name_child' VARCHAR, 'cascade_delete' BOOL, 'field_api_name' VARCHAR)";

NSString *const kTableSFDataTrailerSchema = @"CREATE TABLE IF NOT EXISTS SFDataTrailer ('timestamp' DATETIME, 'local_id' INTEGER, 'sf_id' VARCHAR, 'record_type' VARCHAR, 'operation' VARCHAR, 'object_name' VARCHAR, 'sync_flag' BOOL, 'parent_object_name' VARCHAR, 'parent_local_id' VARCHAR, 'record_sent' VARCHAR, 'webservice_name' VARCHAR, 'class_name' VARCHAR , 'sync_type' VARCHAR, 'header_localId' VARCHAR, 'request_data' VARCHAR, 'request_id' VARCHAR)";

NSString *const kTableSFDataTrailerTempSchema = @"CREATE TABLE IF NOT EXISTS SFDataTrailer_Temp ('timestamp' DATETIME, 'local_id' INTEGER, 'sf_id' VARCHAR, 'record_type' VARCHAR, 'operation' VARCHAR, 'object_name' VARCHAR, 'sync_flag' BOOL , 'parent_object_name' VARCHAR, 'parent_local_id' VARCHAR, 'record_sent' VARCHAR, 'webservice_name' VARCHAR, 'class_name' VARCHAR, 'sync_type' VARCHAR, 'header_localId' VARCHAR)";

NSString *const kTableSFExpressionComponentSchema = @"CREATE TABLE IF NOT EXISTS SFExpressionComponent ('localId' INTEGER PRIMARY KEY NOT NULL, 'expressionId' VARCHAR, 'componentSequenceNumber' DOUBLE, 'componentLHS' VARCHAR, 'componentRHS' VARCHAR, 'operatorValue' CHAR, 'fieldType' TEXT, 'expressionType' TEXT, 'parameterType' TEXT, 'actionType' VARCHAR,'formula' VARCHAR, 'description' VARCHAR )";

// sequence_number varchar
//NSString *const kTableSFExpressionComponentSchema1 = @"CREATE TABLE IF NOT EXISTS SFExpressionComponent ('local_id' INTEGER PRIMARY KEY NOT NULL, 'expression_id' VARCHAR, 'component_sequence_number' VARCHAR, 'component_lhs' VARCHAR, 'component_rhs' VARCHAR, 'operator'CHAR)";

//IPAD-4697 - Added Unique key as "expressionId" to avoid dublicates
NSString *const kTableSFExpressionSchema = @"CREATE TABLE IF NOT EXISTS SFExpression ('localId' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 'expressionId' VARCHAR UNIQUE, 'expression' VARCHAR, 'expressionName' VARCHAR, 'errorMessage' VARCHAR, 'sourceObjectName' VARCHAR, 'sequence' DOUBLE)";

// source ObjectName and sequenece
//NSString *const kTableSFExpressionSchema1 = @"CREATE TABLE IF NOT EXISTS SFExpression ('local_id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 'expression_id' VARCHAR, 'expression' VARCHAR, 'expression_name' VARCHAR, 'error_message' VARCHAR)";


//Krishna : changed the schema (objectName2 to ObjectName, ObjectName to relatedObjectName)
NSString *const kTableSFMSearchFieldSchema = @"CREATE TABLE IF NOT EXISTS SFM_Search_Field ('localId' INTEGER PRIMARY KEY NOT NULL DEFAULT (0), 'identifier' VARCHAR, 'displayType' VARCHAR, 'expressionRule' VARCHAR, 'fieldName' VARCHAR, 'objectName' VARCHAR, 'fieldType' VARCHAR, 'objectID' VARCHAR, 'lookupFieldAPIName' VARCHAR, 'fieldRelationshipName' VARCHAR, 'relatedObjectName' VARCHAR, 'sortOrder' VARCHAR, 'sequence' DOUBLE)";

NSString *const kTableSFMSearchFilterCriteriaSchema = @"CREATE TABLE IF NOT EXISTS SFM_Search_Filter_Criteria ('localId' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 'identifier' VARCHAR, 'sequence' DOUBLE, 'displayType' VARCHAR, 'expressionRule' VARCHAR, 'fieldName' VARCHAR, 'objectName2' VARCHAR, 'operand' VARCHAR, 'operatorValue' VARCHAR, 'objectID' VARCHAR, 'lookupFieldAPIName' VARCHAR, 'fieldRelationshipName' VARCHAR, 'objectName' VARCHAR)";

NSString *const kTableSFMSearchProcessSchema = @"CREATE TABLE IF NOT EXISTS SFM_Search_Process ('localId' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 'identifier' VARCHAR,'name' VARCHAR, 'processDescription' VARCHAR,'processName' VARCHAR)";

NSString *const kTableSFNamedSearchComponentSchema = @"CREATE TABLE IF NOT EXISTS SFNamedSearchComponent ('local_id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE, 'expressionType' VARCHAR, 'fieldName' VARCHAR, 'namedSearchId' VARCHAR, 'searchObjectFieldType' VARCHAR, 'fieldDataType' VARCHAR, 'fieldRelationshipName' VARCHAR, 'keyNameField' VARCHAR, 'sequence' DOUBLE)";

NSString *const kTableSFNamedSearchFiltersSchema = @"CREATE TABLE IF NOT EXISTS SFNamedSearchFilters ('Id' VARCHAR PRIMARY KEY NOT NULL UNIQUE, 'name' TEXT, 'namedSearchId' VARCHAR, 'ruleType' VARCHAR, 'parentObjectCriteria' VARCHAR, 'sourceObjectName' VARCHAR, 'fieldName' VARCHAR, 'sequence' VARCHAR, 'advancedExpression' VARCHAR, 'allowOverride' BOOLEAN, 'defaultOn' BOOLEAN, 'description' TEXT)";

NSString *const kTableSFNamedSearchSchema = @"CREATE TABLE IF NOT EXISTS SFNamedSearch ('searchSfid' VARCHAR PRIMARY KEY NOT NULL UNIQUE, 'namedSearchId' VARCHAR, 'searchName' VARCHAR, 'objectName' VARCHAR, 'searchType' VARCHAR, 'noOfLookupRecords' VARCHAR, 'defaultLookupColumn' VARCHAR, 'isDefault' BOOL, 'isStandard' BOOL)";

NSString *const kTableSFObjectFieldSchema = @"CREATE TABLE IF NOT EXISTS SFObjectField ('localId' INTEGER PRIMARY KEY NOT NULL DEFAULT (0), 'objectName' VARCHAR, 'fieldName' VARCHAR, 'label' VARCHAR, 'length' INTEGER, 'type' VARCHAR, 'referenceTo' VARCHAR, 'nameField' BOOL, 'relationName' VARCHAR, 'dependentPicklist' BOOL, 'controlerField' VARCHAR, 'isNillable' BOOL, 'unique' BOOL, 'restrictedPicklist' BOOL, 'calculated' BOOL, 'defaultedOnCreate' BOOL, 'precision' DOUBLE,'scale' DOUBLE)";

// Need verification
//NSString *const kTableSFObjectFieldSchema1 = @"CREATE TABLE IF NOT EXISTS SFObjectField ('local_id' INTEGER PRIMARY KEY NOT NULL DEFAULT (0), 'object_api_name' VARCHAR, 'api_name' VARCHAR, 'label' VARCHAR, 'precision' DOUBLE, 'length' INTEGER, 'type' VARCHAR, 'reference_to' VARCHAR, 'nillable' BOOL, 'unique' BOOL, 'restricted_picklist' BOOL, 'calculated' BOOL, 'defaulted_on_create' BOOL, 'name_field' BOOL, 'relationship_name' VARCHAR , 'dependent_picklist' BOOL, 'controler_field' VARCHAR)";

NSString *const kTableSFObjectMappingComponentSchema = @"CREATE TABLE IF NOT EXISTS SFObjectMappingComponent ('localId' INTEGER PRIMARY KEY NOT NULL, 'objectMappingId' VARCHAR, 'sourceFieldName' VARCHAR, 'targetFieldName' VARCHAR, 'mappingValue' VARCHAR, 'mappingComponentType' VARCHAR, 'mappingValueFlag' BOOL, 'preference2' VARCHAR, 'preference3' VARCHAR)";

NSString *const kTableSFObjectMappingSchema = @"CREATE TABLE IF NOT EXISTS SFObjectMapping ('localId' INTEGER PRIMARY KEY NOT NULL, 'objectMappingId' VARCHAR, 'sourceObjectName' VARCHAR, 'targetObjectName' VARCHAR)";

NSString *const kTableSFObjectSchema = @"CREATE TABLE IF NOT EXISTS SFObject ('localId' INTEGER PRIMARY KEY NOT NULL DEFAULT (0), 'keyPrefix' VARCHAR, 'label' VARCHAR, 'labelPlural' VARCHAR, 'objectName' VARCHAR,'isQueryable' BOOL)";

// Used API_NAME instead of object_name
//NSString *const kTableSFObjectSchema1 = @"CREATE TABLE IF NOT EXISTS SFObject ('local_id' INTEGER PRIMARY KEY NOT NULL DEFAULT (0), 'key_prefix' VARCHAR, 'label' VARCHAR, 'label_plural' VARCHAR, 'api_name' VARCHAR)";

NSString *const kTableOPDocHtmlDataSchema = @"CREATE TABLE IF NOT EXISTS OPDocHTML ('local_id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE DEFAULT (0), 'process_id' VARCHAR, 'record_id' VARCHAR, 'objectName' VARCHAR, 'Name' VARCHAR, 'sfid' VARCHAR, 'lastModifiedDate' VARCHAR, 'bodyLength' INTEGER)";

NSString *const kTableOPDocSignatureDataSchema = @"CREATE TABLE IF NOT EXISTS OPDocSignature ('local_id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE DEFAULT (0), 'signId' VARCHAR, 'process_id' VARCHAR, 'record_id' VARCHAR, 'objectName' VARCHAR, 'Name' VARCHAR, 'HTMLFileName' VARCHAR, 'sfid' VARCHAR)";

NSString *const kTableSFPickListSchema = @"CREATE TABLE IF NOT EXISTS SFPickList ('localId' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE, 'objectName' VARCHAR, 'fieldName' VARCHAR, 'label' VARCHAR, 'value' VARCHAR, 'defaultValue' VARCHAR, 'validFor' VARCHAR, 'indexValue' INTEGER)";

// Used object_api_name instead of object_name
//NSString *const kTableSFPickListSchema1 = @"CREATE TABLE IF NOT EXISTS SFPickList ('local_id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE, 'object_api_name' VARCHAR, 'field_api_name' VARCHAR, 'label' VARCHAR, 'value' VARCHAR, 'defaultvalue' VARCHAR, 'valid_for' VARCHAR, 'index_value' INTEGER)";

NSString *const kTableSFProcessComponentSchema = @"CREATE TABLE IF NOT EXISTS SFProcessComponent ('localId' INTEGER PRIMARY KEY NOT NULL, 'sfId' VARCHAR, 'processId' VARCHAR, 'componentType' VARCHAR, 'layoutId' VARCHAR, 'objectName' VARCHAR, 'expressionId' VARCHAR, 'objectMappingId' VARCHAR, 'parentColumnName' VARCHAR, 'valueMappingId' VARCHAR, 'parentObjectId' VARCHAR, 'sortingOrder' VARCHAR, 'processNodeId' VARCHAR, 'docTemplateDetailId' VARCHAR, 'targetObjectLabel' VARCHAR, 'enableAttachment' BOOLEAN, 'parentObjectName' VARCHAR, 'sequence' INTEGER,'sourceObjectName' VARCHAR )";

// Used
//NSString *const kTableSFProcessComponentSchema1 = @"CREATE TABLE IF NOT EXISTS SFProcessComponent ('process_id' VARCHAR, 'layout_id' VARCHAR, 'target_object_name' VARCHAR, 'source_object_name' VARCHAR, 'expression_id' VARCHAR, 'object_mapping_id' VARCHAR, 'component_type' VARCHAR, 'local_id' INTEGER PRIMARY KEY NOT NULL, 'parent_column' VARCHAR, 'value_mapping_id' VARCHAR, 'source_child_parent_column' VARCHAR, 'Sorting_Order' VARCHAR, 'process_node_id' VARCHAR, 'doc_template_Detail_id' VARCHAR, 'target_object_label' VARCHAR, 'sfID' VARCHAR, 'enable_Attachment' BOOLEAN)";

//NSString *const kTableSFProcessSchema = @"CREATE TABLE IF NOT EXISTS SFProcess ('local_id' INTEGER PRIMARY KEY NOT NULL, 'process_unique_id' VARCHAR, 'process_sfid' VARCHAR, 'object_api_name' VARCHAR, 'process_type' VARCHAR, 'process_name' VARCHAR, 'process_description' VARCHAR, 'page_layout_id' VARCHAR, 'process_page_info' BLOB, 'doc_template_id' VARCHAR)";

NSString *const kTableSFProcessSchema = @"CREATE TABLE IF NOT EXISTS SFProcess ('localId' INTEGER, 'processId' VARCHAR, 'sfID' VARCHAR  PRIMARY KEY NOT NULL , 'objectApiName' VARCHAR, 'processType' VARCHAR, 'processName' VARCHAR, 'processDescription' VARCHAR, 'pageLayoutId' VARCHAR, 'processInfo' BLOB, 'docTemplateId' VARCHAR)";

// Used process_id instead process_unique_id
//NSString *const kTableSFProcessSchema1 = @"CREATE TABLE IF NOT EXISTS SFProcess ('local_id' INTEGER PRIMARY KEY NOT NULL, 'process_id' VARCHAR, 'object_api_name' VARCHAR, 'process_type' VARCHAR, 'process_name' VARCHAR, 'process_description' VARCHAR, 'page_layout_id' VARCHAR, 'process_info' BLOB, 'sfID' VARCHAR, 'doc_template_id' VARCHAR)";

NSString *const kTableSFProcessTestSchema = @"CREATE TABLE IF NOT EXISTS SFProcess_test ('process_id' VARCHAR, 'layout_id' VARCHAR,'object_name' VARCHAR, 'expression_id' VARCHAR, 'object_mapping_id' VARCHAR, 'component_type' VARCHAR, 'local_id' INTEGER PRIMARY KEY NOT NULL, 'parent_column' VARCHAR, 'value_id' VARCHAR, 'parent_object' VARCHAR, 'Sorting_Order' VARCHAR, 'process_node_id' VARCHAR, 'doc_template_Detail_id' VARCHAR, 'target_object_label' VARCHAR, 'sfID' VARCHAR, 'enable_attachment' BOOLEAN)";

NSString *const kTableSFRecordTypeSchema = @"CREATE TABLE IF NOT EXISTS SFRecordType ('localId' INTEGER PRIMARY KEY NOT NULL DEFAULT (0), 'recordTypeId' VARCHAR, 'objectApiName' VARCHAR, 'recordType' VARCHAR, 'recordtypeLabel' VARCHAR)";

NSString *const kTableSFReferenceToSchema = @"CREATE TABLE IF NOT EXISTS SFReferenceTo ('local_id' INTEGER PRIMARY KEY NOT NULL DEFAULT (0), 'object_api_name' VARCHAR, 'field_api_name' VARCHAR, 'reference_to' VARCHAR)";

NSString *const kTableSFRequiredPdfSchema = @"CREATE TABLE IF NOT EXISTS SFRequiredPdf ('process_id' TEXT, 'record_id' TEXT, 'attachment_id' TEXT)";

NSString *const kTableSFRequiredSignatureSchema = @"CREATE TABLE IF NOT EXISTS 'SFRequiredSignature' ('sign_id' TEXT,'signature_id' TEXT)";

NSString *const kTableSFSearchObjectsSchema = @"CREATE TABLE IF NOT EXISTS SFM_Search_Objects ('localId' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 'moduleId' VARCHAR, 'searchProcessUniqueId' VARCHAR, 'targetObjectName' VARCHAR, 'ProcessName' VARCHAR, 'searchProcessSfId' VARCHAR, 'objectId' VARCHAR, 'advancedExpression' VARCHAR, 'parentObjectCriteria' VARCHAR, 'name' VARCHAR, 'sequence' DOUBLE)";

NSString *const kTableSFSignatureDataSchema = @"CREATE TABLE IF NOT EXISTS SFSignatureData ('record_Id' VARCHAR, 'object_api_name' VARCHAR, 'signature_data' TEXT, 'sig_Id' TEXT, 'WorkOrderNumber' VARCHAR, 'sign_type' VARCHAR, 'operation_type' VARCHAR, 'signature_type_id' TEXT, 'signature_name' TEXT)";

NSString *const kTableSFWizardComponentSchema = @"CREATE TABLE IF NOT EXISTS SFWizardComponent ('localId' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 'wizardId' VARCHAR, 'wizardComponentId' VARCHAR, 'actionDescription' VARCHAR, 'expressionId' VARCHAR, 'processId' VARCHAR, 'actionType' VARCHAR, 'performSync' VARCHAR, 'className' VARCHAR, 'methodName' VARCHAR, 'wizardStepId' VARCHAR, 'sequence' DOUBLE, 'actionName' VARCHAR,'customActionType' VARCHAR ,'customUrl' VARCHAR)";

NSString *const kTableSFWizardSchema = @"CREATE TABLE IF NOT EXISTS SFWizard ('localId' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 'objectName' VARCHAR, 'wizardId' VARCHAR, 'expressionId' VARCHAR, 'wizardDescription' VARCHAR, 'wizardName' VARCHAR,'wizardLayoutColumn' INTEGER,'wizardLayoutRow' INTEGER)";

NSString *const kTableSourceUpdateObjectSchema = @"CREATE TABLE IF NOT EXISTS 'SFSourceUpdate' ('Id' VARCHAR, 'action' VARCHAR, 'configurationType' VARCHAR, 'displayValue' VARCHAR, 'process' VARCHAR, 'settingId' VARCHAR, 'sourceFieldName' VARCHAR, 'targetFieldName' VARCHAR, 'sourceObjectName' VARCHAR, 'targetObjectName' VARCHAR)";

NSString *const kTableSourceUpdateSchema = @"CREATE TABLE IF NOT EXISTS 'SOURCE_UPDATE' ('Id' text(18), 'action' VARCHAR, 'configurationType' VARCHAR, 'displayValue' VARCHAR, 'process' VARCHAR, 'settingId' VARCHAR, 'sourceFieldName' VARCHAR, 'targetFieldName' VARCHAR, 'sourceObjectName' VARCHAR, 'targetObjectName' VARCHAR)";

NSString *const kTableStaticResourceSchema = @"CREATE TABLE IF NOT EXISTS StaticResource (Id text(18), Name text(255))";

NSString *const kTableSummaryPDFSchema = @"CREATE TABLE IF NOT EXISTS Summary_PDF ('record_Id' VARCHAR, 'object_api_name' VARCHAR, 'PDF_data' TEXT, 'WorkOrderNumber' VARCHAR, 'PDF_Id' VARCHAR, 'sign_type' VARCHAR, 'pdf_name' VARCHAR)";

NSString *const kTableJobLogsSchema = @"CREATE TABLE IF NOT EXISTS JobLogs (localId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE DEFAULT (0), timestamp DATE, level int, context TEXT, message TEXT, type TEXT, groupId TEXT, profileId TEXT, category TEXT, operation TEXT)";

NSString *const kTableUserGPSLogSchema = @"CREATE TABLE IF NOT EXISTS UserGPSLog ('localId' VARCHAR PRIMARY KEY NOT NULL DEFAULT (0), 'status' TEXT, 'latitude' VARCHAR, 'user' TEXT, 'ownerId' TEXT, 'deviceType' TEXT, 'createdById' TEXT, 'additionalInfo' VARCHAR, 'timeRecorded' VARCHAR, 'longitude' VARCHAR)";

NSString *const kTableSYNCErrorConflictSchema = @"CREATE TABLE IF NOT EXISTS SyncErrorConflict ('scLocalId' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL,'sfId' VARCHAR, 'localId' VARCHAR, 'objectName' VARCHAR, 'recordType' VARCHAR, 'syncType' VARCHAR, 'errorMessage' VARCHAR, 'operationType' VARCHAR, 'errorType' VARCHAR, 'overrideFlag' VARCHAR, 'className' VARCHAR, 'methodName' VARCHAR, 'customWsError' VARCHAR, 'requestId' VARCHAR, 'fieldsModified' VARCHAR)";

NSString *const kTableSYNCHistorySchema = @"CREATE TABLE IF NOT EXISTS SYNC_HISTORY ('last_sync_time' DATETIME, 'sync_type' VARCHAR, 'request_id' VARCHAR, 'SYNC_STATUS' BOOL )";

NSString *const kTableSyncRecordsHeapSchema = @"CREATE TABLE IF NOT EXISTS Sync_Records_Heap ('sfId' VARCHAR, 'localId' VARCHAR, 'objectName' VARCHAR, 'syncType' VARCHAR, 'syncFlag' BOOL, 'recordType' VARCHAR, 'syncResponseType' VARCHAR, 'parallelSyncType' VARCHAR)";

NSString *const kTableTroubleshootDataSchema = @"CREATE TABLE IF NOT EXISTS TroubleshootData ('localId' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE DEFAULT (0), 'DeveloperName' VARCHAR, 'Id' VARCHAR,  'Keywords' TEXT,  'Name' VARCHAR,  'Type' VARCHAR)";

NSString *const kTableUserCreatedEventsSchema = @"CREATE TABLE IF NOT EXISTS user_created_events ('object_name' VARCHAR, 'sf_id' VARCHAR PRIMARY KEY NOT NULL UNIQUE, 'time_stamp' DATETIME ,'local_id' VARCHAR )";

NSString *const kTableUserImagesSchema = @"CREATE TABLE IF NOT EXISTS UserImages ('Id' VARCHAR PRIMARY KEY NOT NULL DEFAULT (0), 'username' VARCHAR, 'userimage' BLOB, 'shouldRefresh' BOOL)";

NSString *const kTableRecentsSchema = @"CREATE TABLE IF NOT EXISTS RecentRecord ('localId' VARCHAR PRIMARY KEY NOT NULL DEFAULT (0), 'objectName' VARCHAR, 'createdDate' DATETIME)";

NSString *const kTableDataPurgeHeap = @"CREATE TABLE IF NOT EXISTS DataPurgeHeap ('sfId' VARCHAR, 'objectName' VARCHAR)";

NSString *const kProductManualSchema =  @"CREATE TABLE IF NOT EXISTS ProductManual ('local_id' INTEGER PRIMARY KEY NOT NULL DEFAULT (0), 'ProductId' VARCHAR, 'ProductName' VARCHAR, 'Product_Doc' BLOB, 'DocId' VARCHAR, 'prod_manual_Id' VARCHAR, 'prod_manual_name' VARCHAR, 'productmanbody' VARCHAR)";

NSString *const kTableAttachmentLocalSchema = @"CREATE TABLE IF NOT EXISTS AttachmentLocal ('parentLocalId' VARCHAR PRIMARY KEY NOT NULL UNIQUE DEFAULT (0), 'parentObjectName' VARCHAR)";

NSString *const kTableSFMCustomActionParams = @"CREATE TABLE IF NOT EXISTS CustomActionParams ('local_id' INTEGER PRIMARY KEY NOT NULL DEFAULT (0), 'Id' VARCHAR, 'Name' VARCHAR, 'DispatchProcessId' VARCHAR , 'ParameterName' VARCHAR, 'ParameterValue' VARCHAR , 'ParameterType' VARCHAR)";

//ProductIQ tables.

NSString *const KTableRecordName = @"CREATE TABLE IF NOT EXISTS 'RecordName' ('RecordId'	INTEGER PRIMARY KEY AUTOINCREMENT,  'Id' VARCHAR UNIQUE,  'Name'	VARCHAR);";

NSString *const KTableTranslations = @"CREATE TABLE IF NOT EXISTS 'Translations' ('RecordId' INTEGER PRIMARY KEY  AUTOINCREMENT ,'Key' VARCHAR,'Text' VARCHAR )";

NSString *const KTableFieldDescribe = @"CREATE TABLE IF NOT EXISTS 'FieldDescribe' ('RecordId' INTEGER PRIMARY KEY  AUTOINCREMENT ,'FieldName' VARCHAR,'DescribeResult' VARCHAR )";

NSString *const KTableObjectDescribe = @"CREATE TABLE IF NOT EXISTS 'ObjectDescribe' ( 'RecordId' INTEGER PRIMARY KEY  AUTOINCREMENT ,'ObjectName' VARCHAR UNIQUE ,'DescribeResult' VARCHAR )";

NSString *const KTableConfiguration = @"CREATE TABLE IF NOT EXISTS 'Configuration' ('RecordId' INTEGER PRIMARY KEY  AUTOINCREMENT ,'Type' VARCHAR,'Key' VARCHAR,'Value' VARCHAR )";

NSString *const KTableInstallBaseObject = @"CREATE TABLE IF NOT EXISTS 'InstallBaseObject' ( 'objectName' VARCHAR PRIMARY KEY  NOT NULL  UNIQUE  COLLATE NOCASE  )";

NSString *const KTableClientSyncLogTransient =@"CREATE TABLE IF NOT EXISTS 'ClientSyncLogTransient' ( 'RecordId' INTEGER PRIMARY KEY  AUTOINCREMENT ,'Id' VARCHAR UNIQUE ,'ObjectName' VARCHAR,'Operation' VARCHAR,'LastModifiedDate' VARCHAR,'Pending' VARCHAR )";

NSString *const kTableDescribeLayout = @"CREATE TABLE IF NOT EXISTS 'DescribeLayout' ( 'RecordId' INTEGER PRIMARY KEY  AUTOINCREMENT ,'ObjectName' VARCHAR,'DescribeLayoutResult' VARCHAR )";




@implementation DatabaseSchemaConstant

@end
