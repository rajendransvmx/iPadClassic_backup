//
//  ChatterHelper.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 19/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ChatterHelper.h"
#import "CacheManager.h"

@implementation ChatterHelper

+ (NSString *)requestQueryForProductIamge
{
    NSString *productId =  [[CacheManager sharedInstance] getCachedObjectByKey:@"ChatterProductId"];
    
    NSString *query = nil;
    
    if ([productId length] > 0) {
        query = [NSString stringWithFormat:@"SELECT Id FROM Attachment Where ParentId = '%@' AND Name LIKE '%%PICTURE%%' LIMIT 1", productId];
    }
    return query;
}

+ (NSString *)requestQueryForChatterPost
{
    NSString *productId =  [[CacheManager sharedInstance] getCachedObjectByKey:@"ChatterProductId"];
    
    NSString *query = nil;
    
    if ([productId length] > 0) {
        query = [NSString stringWithFormat:@"SELECT Type, CreatedById, ParentId, Id, FeedPost.Body, FeedPostId, CreatedDate, (Select CreatedById, CreatedDate, FeedItemId, CommentBody From FeedComments ORDER BY CreatedDate) FROM Product2Feed WHERE Type != 'TrackedChange' AND  ParentId = '%@' ORDER BY CreatedDate DESC LIMIT 10", productId];
    }
    return query;
}

+ (NSString *)requestQueryForChatterPostDetails
{
    NSString *userIds = [[CacheManager sharedInstance] getCachedObjectByKey:@"ChatterPostIds"];
    
    NSString *query = nil;
    
    if ([userIds length] > 0) {
        query = [NSString stringWithFormat:@"SELECT  Username, Id, Name, Email, FullPhotoUrl, SmallPhotoUrl FROM User WHERE Id in (%@)", userIds];
    }
    return query;
}

+ (void)pushDataToCahcche:(NSString *)value forKey:(NSString *)key
{
    [[CacheManager sharedInstance] pushToCache:value byKey:key];
}

@end
