//
//  UserImageService.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 5/26/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   UserImageService.m
 *  @class  UserImageService
 *
 *  @brief  This service class implements service methods related to UserImage
 *
 *
 *
 *  @author  Vipindas Palli
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/


#import "UserImageService.h"
#import "UserImageModel.h"
#import "ParserUtility.h"

@implementation UserImageService

- (BOOL)addUserImage:(UserImageModel *)userImage
{
    return [self saveRecordModel:userImage];
}

- (BOOL)updateUserImage:(UserImageModel *)userImage
{
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorEqual
                                                   andFieldValue:userImage.Id];
    
    if ([self doesRecordAlreadyExistWithfieldName:kId withFieldValue:userImage.Id inTable:[self tableName]]) {
       return [self updateEachRecord:userImage withFields:@[kId, @"userimage", @"shouldRefresh"] withCriteria:@[criteria]];
    }
    else {
        return [self addUserImage:userImage];
    }
    
    return NO;
}

- (BOOL)removeUserImage:(UserImageModel *)userImage
{
    return YES;
}

- (NSArray *)fetchAllUserImage
{
    return nil;
}

- (UserImageModel *)getUserImageForId:(NSString *)userId
{
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorEqual
                                                       andFieldValue:userId];
    
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:nil whereCriteria:criteria];
    
    __block UserImageModel *model;
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            
            NSString * query = [requestSelect query];
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            model = [[UserImageModel alloc] init];
            
            if ([resultSet next]) {
                NSDictionary *dict = [resultSet resultDictionary];
                if (dict) {
                    model.userimage = [dict objectForKey:@"userimage"];
                    model.Id = [dict objectForKey:kId];
                    model.shouldRefresh = [[dict objectForKey:@"shouldRefresh"] boolValue];
                }
            }
            [resultSet close];
        }];
    }
    return model;
}

- (NSString *)tableName
{
    return @"UserImages";
}
@end
