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

#import "DatabaseIndexConstant.h"

#pragma mark - Drop Index constants

NSString *const kTableIndexSyncRecordHeapIndex      = @"CREATE INDEX IF NOT EXISTS sync_Record_Heap_Index ON sync_Records_Heap (sf_id ASC, local_id ASC, object_name ASC, sync_flag ASC)";
NSString *const kTableIndexSyncRecordHeapIndex2     = @"CREATE INDEX IF NOT EXISTS sync_Record_Heap_Index_2 ON sync_Records_Heap (sync_flag ASC, record_type ASC, sync_type ASC)";
NSString *const kTableIndexSyncRecordHeapIndex3     = @"CREATE INDEX IF NOT EXISTS sync_Record_Heap_Index_3 ON sync_Records_Heap (sync_flag ASC, object_name ASC)";
NSString *const kTableIndexSyncRecordHeapIndex4     = @"CREATE INDEX IF NOT EXISTS sync_Record_Heap_Index_4 ON sync_Records_Heap (sync_type ASC, object_name ASC)";

NSString *const kTableIndexSFObjectFieldIndex       = @"CREATE INDEX IF NOT EXISTS SFObjectFieldIndex ON SFObjectField (object_api_name, api_name, label)";
NSString *const kTableIndexSFObjectFieldIndex2      = @"CREATE INDEX IF NOT EXISTS SFObjectFieldIndex_2 ON SFObjectField (object_api_name, name_field)";

NSString *const kTableIndexRTIndex                  = @"CREATE INDEX IF NOT EXISTS RTIndex ON SFRTPicklist (object_api_name, field_api_name, recordtypename, defaultlabel, defaultvalue, label, value)";
NSString *const kTableIndexSFNamedSearchIndex       = @"CREATE INDEX IF NOT EXISTS SFNamedSearchIndex ON SFNamedSearch (default_lookup_column, object_name, is_default,is_standard)";

NSString *const kTableIndexSFNamedSearchComponentIndex = @"CREATE INDEX IF NOT EXISTS SFNamedSearchComponentIndex ON SFNamedSearchComponent (field_name, search_object_field_type, sequence,field_type,field_relationship_name )";

NSString *const kTableIndexSFChildRelationshipIndex1 = @"CREATE INDEX IF NOT EXISTS SFChildRelationshipIndex_1 ON SFChildRelationship (object_api_name_child)";
NSString *const kTableIndexSFChildRelationshipIndex2 = @"CREATE INDEX IF NOT EXISTS SFChildRelationshipIndex_2 ON SFChildRelationship (object_api_name_parent, object_api_name_child)";

NSString *const kTableIndexProcessBusinessRuleIndex  = @"CREATE INDEX IF NOT EXISTS ProcessBusinessRuleIndex ON ProcessBusinessRule (business_rule, error_msg, sequence,process_node_object,target_manager )";
NSString *const kTableIndexBusinessRuleIndex         = @"CREATE INDEX IF NOT EXISTS BusinessRuleIndex ON BusinessRule (Id, description, error_msg,message_type,name,process_ID,source_object_name )";

#pragma mark - Drop Index constants

NSString *const kTableDropIndexSyncRecordHeapIndex         = @"DROP INDEX IF EXISTS sync_Record_Heap_Index ON sync_Records_Heap";
NSString *const kTableDropIndexSyncRecordHeapIndex2        = @"DROP INDEX IF EXISTS sync_Record_Heap_Index_2 ON sync_Records_Heap";
NSString *const kTableDropIndexSyncRecordHeapIndex3        = @"DROP INDEX IF EXISTS sync_Record_Heap_Index_3 ON sync_Records_Heap";
NSString *const kTableDropIndexSyncRecordHeapIndex4        = @"DROP INDEX IF EXISTS sync_Record_Heap_Index_4 ON sync_Records_Heap";

NSString *const kTableDropIndexSFObjectFieldIndex          = @"DROP INDEX IF EXISTS SFObjectFieldIndex ON SFObjectField";
NSString *const kTableDropIndexSFObjectFieldIndex2         = @"DROP INDEX IF EXISTS SFObjectFieldIndex_2 ON SFObjectField";

NSString *const kTableDropIndexRTIndex                     = @"DROP INDEX IF EXISTS RTIndex ON SFRTPicklist";
NSString *const kTableDropIndexSFNamedSearchIndex          = @"DROP INDEX IF EXISTS SFNamedSearchIndex ON SFNamedSearch";
NSString *const kTableDropIndexSFNamedSearchComponentIndex = @"DROP INDEX IF EXISTS SFNamedSearchComponentIndex ON SFNamedSearchComponent";

NSString *const kTableDropIndexSFChildRelationshipIndex1   = @"DROP INDEX IF EXISTS SFChildRelationshipIndex_1 ON SFChildRelationship";
NSString *const kTableDropIndexSFChildRelationshipIndex2   = @"DROP INDEX IF EXISTS SFChildRelationshipIndex_2 ON SFChildRelationship";

NSString *const kTableDropIndexProcessBusinessRuleIndex    = @"DROP INDEX IF EXISTS ProcessBusinessRuleIndex ON ProcessBusinessRule";
NSString *const kTableDropIndexBusinessRuleIndex           = @"DROP INDEX IF EXISTS BusinessRuleIndex ON BusinessRule";


@implementation DatabaseIndexConstant

@end
