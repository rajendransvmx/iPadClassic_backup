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

extern NSString *const kTableIndexSyncRecordHeapIndex;
extern NSString *const kTableIndexSyncRecordHeapIndex2;
extern NSString *const kTableIndexSyncRecordHeapIndex3;
extern NSString *const kTableIndexSyncRecordHeapIndex4;
extern NSString *const kTableIndexSFObjectFieldIndex;
extern NSString *const kTableIndexSFObjectFieldIndex2;
extern NSString *const kTableIndexRTIndex;
extern NSString *const kTableIndexSFNamedSearchIndex;
extern NSString *const kTableIndexSFNamedSearchComponentIndex;
extern NSString *const kTableIndexSFChildRelationshipIndex1;
extern NSString *const kTableIndexSFChildRelationshipIndex2;
extern NSString *const kTableIndexProcessBusinessRuleIndex;
extern NSString *const kTableIndexBusinessRuleIndex;

#pragma mark - Drop Index constants

extern NSString *const kTableDropIndexSyncRecordHeapIndex;
extern NSString *const kTableDropIndexSyncRecordHeapIndex2;
extern NSString *const kTableDropIndexSyncRecordHeapIndex3;
extern NSString *const kTableDropIndexSyncRecordHeapIndex4;
extern NSString *const kTableDropIndexSFObjectFieldIndex;
extern NSString *const kTableDropIndexSFObjectFieldIndex2;
extern NSString *const kTableDropIndexRTIndex;
extern NSString *const kTableDropIndexSFNamedSearchIndex;
extern NSString *const kTableDropIndexSFNamedSearchComponentIndex;
extern NSString *const kTableDropIndexSFChildRelationshipIndex1;
extern NSString *const kTableDropIndexSFChildRelationshipIndex2;
extern NSString *const kTableDropIndexProcessBusinessRuleIndex;
extern NSString *const kTableDropIndexBusinessRuleIndex;


@interface DatabaseIndexConstant : NSObject

@end
