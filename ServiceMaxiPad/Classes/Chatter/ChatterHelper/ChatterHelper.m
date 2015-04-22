//
//  ChatterHelper.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 19/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ChatterHelper.h"
#import "CacheManager.h"
#import "NonTagConstant.h"
#import "ChatterManager.h"
#import "ChatterFeedPost.h"
#import "ChatterFeedComments.h"
#import "FactoryDAO.h"
#import "ChatterPostDetailDAO.h"
#import "DBField.h"
#import "FileManager.h"
#import "MobileDeviceSettingDAO.h"
#import "UserImageModel.h"
#import "UserImageDAO.h"

@implementation ChatterHelper

+ (NSString *)requestQueryForProductIamge
{
    NSString *productId =  [[ChatterManager sharedInstance] getProductId];
    
    NSString *query = nil;
    
    if ([productId length] > 0) {
        query = [NSString stringWithFormat:@"SELECT Id FROM Attachment Where ParentId = '%@' AND Name LIKE '%%PICTURE%%' LIMIT 1", productId];
    }
    return query;
}

+ (NSString *)requestQueryForChatterPost
{    
    NSString *productId =  [[ChatterManager sharedInstance] getProductId];
    
    NSString *query = nil;
    
    NSString *value = [self getChatterThreadLimitValue];
    
    if ([productId length] > 0) {
        query = [NSString stringWithFormat:@"SELECT Type, CreatedById, ParentId, Id, FeedPost.Body, FeedPostId, CreatedDate, (Select CreatedById, CreatedDate, FeedItemId, CommentBody From FeedComments ORDER BY CreatedDate) FROM Product2Feed WHERE Type != 'TrackedChange' AND  ParentId = '%@' ORDER BY CreatedDate DESC LIMIT %@", productId, value];
    }
    return query;
}

+ (NSString *)getChatterThreadLimitValue
{
    NSString *value = nil;
    id mobileSettingService = [FactoryDAO serviceByServiceType:ServiceTypeMobileDeviceSettings];
    if ([mobileSettingService conformsToProtocol:@protocol(MobileDeviceSettingDAO)]) {
        
        MobileDeviceSettingsModel *model = [mobileSettingService fetchDataForSettingId:@"Chatter Threads"];
        value = model.value;
    }
    if ([value length] == 0 || [value isEqualToString:@"0"]) {
        value = @"10";
    }
    
    return value;
}
+ (NSString *)requestQueryForChatterPostDetails
{
    NSString *productId =  [[ChatterManager sharedInstance] getProductId];
    
    NSString *userIds = [[CacheManager sharedInstance] getCachedObjectByKey:productId];
    
    NSString *query = nil;
    
    if ([userIds length] > 0) {
        query = [NSString stringWithFormat:@"SELECT  Username, Id, Name, Email, FullPhotoUrl, SmallPhotoUrl FROM User WHERE Id in (%@)", userIds];
    }
    return query;
}

+ (void)pushDataToCahcche:(id)value forKey:(NSString *)key
{
    if (value != nil && key != nil) {
        [[CacheManager sharedInstance] pushToCache:value byKey:key];
    }
}

+ (id)getdatFromChache:(NSString *)key
{
    return [[CacheManager sharedInstance] getCachedObjectByKey:key];
}

+ (void)clearCacheByKey:(NSString *)key
{
    [[CacheManager sharedInstance] clearCacheByKey:key];
}

+ (NSDictionary *)getRequstParamFor:(NSString *)key
{
    if ([key length] > 0) {
        return [[ChatterManager sharedInstance] paramDictForkey:key];
    }
    return nil;
}


#pragma mark - Database Services

+ (BOOL)saveRecods:(NSMutableArray *)records
{
    id chatterService = [FactoryDAO serviceByServiceType:ServiceTypeChatterPostDetail];
    
    if ([chatterService conformsToProtocol:@protocol(ChatterPostDetailDAO)]) {
        [chatterService saveRecordModels:records];
    }
    return YES;
}

+ (BOOL)deleteRecordsForProductId:(NSString *)productId
{
    BOOL result = NO;
    
    if ([productId length] > 0) {
        id chatterService = [FactoryDAO serviceByServiceType:ServiceTypeChatterPostDetail];
        
        if ([chatterService conformsToProtocol:@protocol(ChatterPostDetailDAO)]) {
            DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:@"productId"
                                                            operatorType:SQLOperatorEqual
                                                           andFieldValue:productId];
            result = [chatterService deleteRecords:criteria];
        }
    }
    return result;
}

+ (NSMutableArray *)fetchRecordsForCriteria:(NSArray *)criterias orderType:(SQLOrderByType)sqlOrderType
{
    id chatterService = [FactoryDAO serviceByServiceType:ServiceTypeChatterPostDetail];
    
    if ([chatterService conformsToProtocol:@protocol(ChatterPostDetailDAO)]) {
        
        DBField *field = [[DBField alloc] initWithFieldName:@"createdDate" tableName:@"ChatterPostDetail" andOrderType:sqlOrderType];
        
        return [chatterService fetchRecordsForProductId:criterias orderBy:field];
    }
    return nil;
}


+ (NSMutableArray *)fetchChatterFeedsForProductId:(NSString *)productId
{
    NSMutableArray *chatterFeeds = nil;
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:@"productId" operatorType:SQLOperatorEqual
                                                   andFieldValue:productId];
    
    DBCriteria *criteriaType = [[DBCriteria alloc] initWithFieldName:@"postType" operatorType:SQLOperatorEqual
                                                       andFieldValue:@"FeedPost"];
    
    NSMutableArray *resulSet = [self fetchRecordsForCriteria:@[criteria, criteriaType] orderType:SQLOrderByTypesDescending];
    
    if ([resulSet count] > 0) {
        chatterFeeds = [self segregateChatterResutls:resulSet];
    }
    return chatterFeeds;
}

+ (NSMutableArray *)segregateChatterResutls:(NSMutableArray *)results
{
    NSMutableArray *chatterFeeds = [NSMutableArray new];
    
    for (ChatterPostDetailModel *model in results) {
        if (model != nil) {
            ChatterFeedPost *post = [self getNewChatterFeedPost:model];
            [chatterFeeds addObject:post];
        }
    }
    [self updateFeedCommentsForEachFeed:chatterFeeds];
    
    return chatterFeeds;
}

+ (void)updateFeedCommentsForEachFeed:(NSMutableArray *)result
{
    @autoreleasepool {
        for (ChatterFeedPost *feedPost in result) {
            if (feedPost != nil) {
                
                DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:@"productId" operatorType:SQLOperatorEqual
                                                               andFieldValue:feedPost.parentId];
               
                DBCriteria *criteriaType = [[DBCriteria alloc] initWithFieldName:@"postType" operatorType:SQLOperatorEqual
                                                                   andFieldValue:@"FeedComment"];
                
                DBCriteria *criteriaFeed = [[DBCriteria alloc] initWithFieldName:@"feedItemId" operatorType:SQLOperatorEqual
                                                               andFieldValue:feedPost.postId];
                
                NSMutableArray *resulSet = [self fetchRecordsForCriteria:@[criteria, criteriaType, criteriaFeed] orderType:SQLOrderByTypesAscending];
                
                for (ChatterPostDetailModel *model in resulSet) {
                    if (model != nil) {
                        [feedPost.feedComments addObject:[self getNewChatterFeedComment:model]];
                    }
                }
            }
        }
    }
}

+ (ChatterFeedPost *)getNewChatterFeedPost:(ChatterPostDetailModel *)model
{
    ChatterFeedPost *post = [[ChatterFeedPost alloc] init];
    
    post.createdById = model.createdById;
    post.cretedDate = model.createdDate;
    post.postId = model.Id;
    post.parentId = model.productId;
    post.commentType = model.postType;
    post.commentBody = model.body;
    post.userName = model.userName;
    post.name = model.name;
    post.fullPhotoUrl = model.fullPhotoUrl;
    post.email = model.email;
    
    if (post.feedComments == nil) {
        post.feedComments = [NSMutableArray new];
        [post.feedComments addObject:[self getNewChatterFeedComment:model]];
    }
    [post getUserReadabeDateForCreatedDate];
    
    return post;
}

+ (ChatterFeedComments *)getNewChatterFeedComment:(ChatterPostDetailModel *)model
{
    ChatterFeedComments *comments = [[ChatterFeedComments alloc] init];
    
    comments.createdById = model.createdById;
    comments.cretedDate = model.createdDate;
    comments.postId = model.Id;
    comments.feedItemId = model.feedItemId;
    comments.commentType = model.postType;
    comments.commentBody = model.body;
    comments.userName = model.userName;
    comments.name = model.name;
    comments.fullPhotoUrl = model.fullPhotoUrl;
    comments.email = model.email;
  
    [comments getUserReadabeDateForCreatedDate];
    
    return comments;
}
#pragma mark End

+ (void)removeAllUserImagesFromDocuments:(NSString *)productId
{
    NSString *str = [self getdatFromChache:productId];
    str =  [str stringByReplacingOccurrencesOfString:@"'" withString:@""];
    
    NSArray *ids = [str componentsSeparatedByString:@","];
    
    @autoreleasepool
    {
        for (NSString *userId in ids)
        {
            if (userId)
            {
                NSString *fielPath = [FileManager getChatterRelatedFilePath:userId];
                
                if (fielPath)
                {
                    [FileManager deleteFileAtPath:fielPath];
                }
            }
        }
    }
    
    if ([productId length] > 0)
    {
        [self clearCacheByKey:productId];
    }
}


#pragma mark - ProdctImageData Queries
+ (BOOL)deleteRecordFromProductImage:(NSString *)productId
{
    BOOL result = NO;
    
    if ([productId length] > 0) {
        id productImageService = [FactoryDAO serviceByServiceType:ServiceTypeProductImageData];
        
        if ([productImageService conformsToProtocol:@protocol(ProductImageDataDAO)]) {
            DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:@"productId"
                                                            operatorType:SQLOperatorEqual
                                                           andFieldValue:productId];
            result = [productImageService deleteRecord:criteria];
        }
    }
    return result;
}

+ (void)saveProductAttachmentId:(ProductImageDataModel *)model
{
    id productImageService = [FactoryDAO serviceByServiceType:ServiceTypeProductImageData];
    
    if ([productImageService conformsToProtocol:@protocol(ProductImageDataDAO)]) {
        [productImageService saveRecordModel:model];
    }
}

+ (NSString *)getAttachmentIdForProduct:(NSString *)productId
{
    id productImageService = [FactoryDAO serviceByServiceType:ServiceTypeProductImageData];
    
    if ([productImageService conformsToProtocol:@protocol(ProductImageDataDAO)]) {
        DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:@"productId"
                                                        operatorType:SQLOperatorEqual
                                                       andFieldValue:productId];
        NSArray *resultSet =  [productImageService fetchDataForFields:nil criterias:@[criteria] objectName:@"ProductImageData" andModelClass:[ProductImageDataModel class]];
        if ([resultSet count] > 0) {
            
            ProductImageDataModel *model = [resultSet objectAtIndex:0];
            
            return model.productImageId;
        }
    }
    return nil;
}

#pragma mark - END


#pragma mark - UserImage Queries
+ (void)updateUserImage:(UserImageModel *)userImage
{
    id userImageService = [FactoryDAO serviceByServiceType:ServiceTypeUserImage];
    
    if ([userImageService conformsToProtocol:@protocol(UserImageDAO)]) {

        if (![userImageService updateUserImage:userImage]) {
            SXLogInfo(@"Failed to update user image");
        }
    }
}

+ (void)updateUserImageToRefresh:(NSString *)productId
{
    NSString *str = [self getdatFromChache:productId];
    
    if ([str length] > 0) {
        
        NSString *query = [NSString stringWithFormat:@"UPDATE UserImages SET shouldRefresh = '%d' WHERE Id In (%@) ", TRUE, str];
        
        id userImageService = [FactoryDAO serviceByServiceType:ServiceTypeUserImage];
        
        if ([userImageService conformsToProtocol:@protocol(UserImageDAO)]) {
            
            if (![userImageService executeStatement:query]) {
                SXLogInfo(@"Failed to update user image");
            }
        }
    }
    if ([productId length] > 0) {
        [self clearCacheByKey:productId];
    }
}

+ (NSData *)getImageDataForUserId:(NSString *)Id
{
    UserImageModel *model = nil;
    
    id userImageService = [FactoryDAO serviceByServiceType:ServiceTypeUserImage];
    
    if ([userImageService conformsToProtocol:@protocol(UserImageDAO)]) {
        
        model = [userImageService getUserImageForId:Id];
        
        if (model.userimage) {
            return model.userimage;
        }
    }
    return nil;
}

+ (BOOL)shouldRefreshImage:(NSString *)userId
{
    BOOL resultVal = TRUE;
    
    id userImageService = [FactoryDAO serviceByServiceType:ServiceTypeUserImage];
    
    if ([userImageService conformsToProtocol:@protocol(UserImageDAO)]) {
        
        UserImageModel *model = [userImageService getUserImageForId:userId];
        
        if ([model.Id isEqualToString:userId]) {
            resultVal = model.shouldRefresh;
        }
    }
    return resultVal;
}

@end
