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
@end
