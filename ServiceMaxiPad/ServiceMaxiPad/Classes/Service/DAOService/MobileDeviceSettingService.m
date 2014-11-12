//
//  MobileDevSettingService.m
//  ServiceMaxMobile
//
//  Created by Krishna Shanbhag on 20/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "MobileDeviceSettingService.h"
#import "MobileDeviceSettingsModel.h"
#import "ParserUtility.h"
#import "DatabaseConstant.h"
#import "DBRequestConstant.h"


static NSString *const kScheduledConfigSyncFrequency    = @"Frequency of Application Changes";
static NSString *const kScheduledDataSyncFrequency      = @"Frequency of Master Data";
static NSString *const kLocationTrackingFrequency       = @"Location Tracking Frequency";
static NSString *const kLocationTrackingEnabled         = @"Enable Location Tracking";



@implementation MobileDeviceSettingService

- (NSString *)tableName {
    return @"MobileDeviceSettings";
}

-(MobileDeviceSettingsModel *)fetchDataForSettingId:(NSString *)settingId
{
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kSettingId operatorType:SQLOperatorEqual andFieldValue:settingId];
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:nil whereCriteria:criteria];
    __block MobileDeviceSettingsModel * model;
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        model = [[MobileDeviceSettingsModel alloc] init];
        
        if ([resultSet next]) {
            [resultSet kvcMagic:model];
        }
        [resultSet close];
    }];
    }
    return model;
}

/**
 * @name   configurationSyncFrequency
 *
 * @author Vipindas Palli
 *
 * @brief  Get scheduled Configuration sync frequency
 *
 * \par
 *  <Longer description starts here>
 *
 * @return NSInteger value
 *
 */

- (NSInteger)configurationSyncFrequency
{
    
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kSettingId
                                                    operatorType:SQLOperatorEqual
                                                   andFieldValue:kScheduledConfigSyncFrequency];
    
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName]
                                                                   andFieldNames:nil
                                                                   whereCriteria:criteria];
    __block NSInteger frequency = -1;
    @autoreleasepool {
        
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
    
            NSString * query = [requestSelect query];
        
            SQLResultSet * resultSet = [db executeQuery:query];
            
            MobileDeviceSettingsModel * model = [[MobileDeviceSettingsModel alloc] init];
            
            if ([resultSet next]) {
                [resultSet kvcMagic:model];
            }
            
            if (model.value != nil)
            {
                frequency = [model.value integerValue];
            }
            
            model = nil;
        }];
    }
    return frequency;
    
}



/**
 * @name   dataSyncFrequency
 *
 * @author Vipindas Palli
 *
 * @brief  Get scheduled data sync frequency
 *
 * \par
 *  <Longer description starts here>
 *
 * @return NSInteger value
 *
 */

- (NSInteger)dataSyncFrequency
{
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kSettingId
                                                    operatorType:SQLOperatorEqual
                                                   andFieldValue:kScheduledDataSyncFrequency];
    
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName]
                                                                   andFieldNames:nil
                                                                   whereCriteria:criteria];
    
    __block NSInteger frequency = -1;
    
    @autoreleasepool {
        
            DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
            
            [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {

            NSString * query = [requestSelect query];
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            MobileDeviceSettingsModel * model = [[MobileDeviceSettingsModel alloc] init];
            
            if ([resultSet next]) {
                [resultSet kvcMagic:model];
            }
            if (model.value != nil)
            {
                frequency = [model.value integerValue];
            }
            
            model = nil;
        }];
    }
    
    return frequency;
}


@end
