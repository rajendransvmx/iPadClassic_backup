//
//  MobileDeviceTagService.m
//  ServiceMaxMobile
//
//  Created by Pushpak on 19/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//
/**
 *  @file MobileDeviceTagService.h
 *  @class MobileDeviceTagService.h
 *
 *  @brief Specific service class implementing DAO protocol methods to handle MobileDeviceTags table.
 *
 *  @author Pushpak
 *
 *  @bug No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "MobileDeviceTagService.h"
#import "DatabaseManager.h"
#import "DBRequestInsert.h"
#import "ParserUtility.h"
#import "TagManager.h"
#import "DBRequestSelect.h"
#import "SQLResultSet.h"

@implementation MobileDeviceTagService

- (BOOL)saveRecordModels:(NSMutableArray *)recordsArray {
    BOOL status = [super saveRecordModels:recordsArray];
    [[TagManager sharedInstance]reloadTags];
    return status;
}


- (BOOL)saveRecordModel:(id)model {
    BOOL status = [super saveRecordModel:model];
    [[TagManager sharedInstance]reloadTags];
    return status;
}

- (NSArray *)fetchAllTagsWithError:(NSError * __autoreleasing *)pError {
    
    DBRequestSelect *requestSelect = [[DBRequestSelect alloc] initWithTableName:kMobileDeviceTagsTableName];
    
    NSMutableArray *records = [[NSMutableArray alloc] initWithCapacity:0];
    
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    
    if (didOpen)
    {
        NSString * query = [requestSelect query];
        
        SQLResultSet *resultSet = [[DatabaseManager sharedInstance] executeQuery:query];
        
        while ([resultSet next]) {
            MobileDeviceTagModel *model = [[MobileDeviceTagModel alloc] init];
            [resultSet kvcMagic:model];
            [records addObject:model];
        }
    }
    return records;
}

- (NSString *)tableName {
    return kMobileDeviceTagsTableName;
}
@end
