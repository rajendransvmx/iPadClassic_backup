//
//  ChatterPostParser.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 19/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ChatterPostParser.h"
#import "ZKSQueryRequest.h"
#import "ZKSObject.h"
#import "ChatterHelper.h"
#import "NonTagConstant.h"
#import "ChatterFeedPost.h"
#import "ChatterFeedComments.h"
#import "ChatterManager.h"

@interface ChatterPostParser ()

@property(nonatomic, strong)NSMutableArray *chatterData;

@end

@implementation ChatterPostParser

- (ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel responseData:(id)responseData {
    @synchronized([self class]){
        @autoreleasepool {
            
            if (self.chatterData == nil) {
                self.chatterData = [NSMutableArray new];
            }
            NSMutableArray *resultSet = [NSMutableArray new];
            
            if ([responseData isKindOfClass:[NSDictionary class]]) {
                
                NSDictionary *response = (NSDictionary *)responseData;
                
                ZKQueryResult *queryresult = [response objectForKey:kResult];
                NSArray *records = [queryresult records];
                
                for (ZKSObject *obj in records) {
                    
                    NSDictionary *fields = [obj fields];
                    
                    NSString *createdId = [fields objectForKey:kAttachmentTXCreatedById];
                    
                    ChatterFeedPost *post = [self getNewChatterPost:fields];
                    
                    [self.chatterData addObject:post];
                    
                    if (![resultSet containsObject:createdId]) {
                        [resultSet addObject:createdId];
                    }
                    ZKQueryResult *feeds = [fields objectForKey:kFeedComments];
                    resultSet = [self fillUserIdForFeedComments:feeds array:resultSet chatterPost:post];
                }
            }
            if (resultSet) {
                [self pushUserIdsTochache:resultSet];
            }
            
        }
    }
    return nil;
}

- (NSMutableArray *)fillUserIdForFeedComments:(ZKQueryResult *)feeds
                                        array:(NSMutableArray *)resultSet
                                  chatterPost:(ChatterFeedPost *)post
{
    if ((feeds != nil) && ![feeds isKindOfClass:[NSNull class]]) {
        
        for (ZKSObject *feedData in [feeds records]) {
            NSDictionary *fields = [feedData fields];
            
            NSString *createdId = [fields objectForKey:kAttachmentTXCreatedById];
            if (![resultSet containsObject:createdId]) {
                [resultSet addObject:createdId];
            }
            [self updatedateChatterArrayForfeedCommnets:fields chatterPost:post];
        }
    }
    return resultSet;
}

- (void)pushUserIdsTochache:(NSArray *)resultSet
{
    NSString *idSeparetedByComas = nil;
    
    if ([resultSet count] > 1) {
        NSString *baseString = [resultSet componentsJoinedByString:@"','"];
        idSeparetedByComas = [NSString stringWithFormat:@"'%@'", baseString];
    }
    else {
        if ([resultSet count]) {
            idSeparetedByComas = [NSString stringWithFormat:@"'%@'", [resultSet objectAtIndex:0]];
        }
    }
    
    if ([idSeparetedByComas length] > 0) {
        [self saveUserIds:idSeparetedByComas];
    }
    
    [[ChatterManager sharedInstance] updateChatterData:self.chatterData];
}

- (void)saveUserIds:(NSString *)ids
{
    NSString *productId =  [[ChatterManager sharedInstance] getProductId];
    if ([productId length] > 0) {
        [ChatterHelper pushDataToCahcche:ids forKey:productId];
    }
}

- (ChatterFeedPost *)getNewChatterPost:(NSDictionary *)fields
{
    ChatterFeedPost *post = [[ChatterFeedPost alloc] initWithDictionary:fields];
    post.commentBody = [self getCommentBody:[fields objectForKey:@"FeedPost"]];
    
    if (post.feedComments == nil) {
        post.feedComments = [NSMutableArray new];
        ChatterFeedComments *newPost = [self getDuplicateCopyOfCahtter:fields];
        [post.feedComments addObject:newPost];
    }
    return post;
}


- (ChatterFeedComments *)getDuplicateCopyOfCahtter:(NSDictionary *)fields
{
    ChatterFeedComments *comments = [[ChatterFeedComments alloc] initWithDictionary:fields];
    comments.commentType = @"FeedPost";
    comments.commentBody = [self getCommentBody:[fields objectForKey:@"FeedPost"]];
    
    return comments;
}

- (NSString *)getCommentBody:(ZKSObject *)obj
{
    NSDictionary *fields = [obj fields];
    NSString * body = ([fields objectForKey:@"Body"] != nil)?[fields objectForKey:@"Body"]:@"";
    return body;
}

- (void)updatedateChatterArrayForfeedCommnets:(NSDictionary *)fields
                                  chatterPost:(ChatterFeedPost *)post
{
    ChatterFeedComments *comments = [[ChatterFeedComments alloc] initWithDictionary:fields];
    [post.feedComments addObject:comments];
}

@end
