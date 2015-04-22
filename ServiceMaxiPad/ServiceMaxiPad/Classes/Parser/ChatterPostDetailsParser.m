//
//  ChatterPostDetailsParser.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 19/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ChatterPostDetailsParser.h"
#import "ChatterHelper.h"
#import "ChatterFeedPost.h"
#import "ChatterFeedComments.h"
#import "ChatterPostDetailModel.h"
#import "NonTagConstant.h"
#import "ChatterManager.h"

@interface ChatterPostDetailsParser ()

@property(nonatomic, strong)NSMutableArray *dataArray;
@property(nonatomic, strong)NSMutableArray *chatterArray;

@end

@implementation ChatterPostDetailsParser

- (ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel responseData:(id)responseData {
    @synchronized([self class]){
        @autoreleasepool {
            
            if ([responseData isKindOfClass:[NSDictionary class]]) {
                
                [self fillDataArray];
                
                NSDictionary *response = (NSDictionary *)responseData;
                
                NSArray *records = [response objectForKey:kRecords];
                
                for (NSDictionary *eachDict in records) {
                    [self updateUserDetailsForFeeds:eachDict];
                }
            }
            [self updateChatterDataToCache];
            [self updateChatterDetailsInToDataBase];
        }
    }
    return nil;
}

- (void)updateChatterDataToCache
{
    [[ChatterManager sharedInstance] updateChatterData:self.chatterArray];
}

- (void)updateChatterDetailsInToDataBase
{
    NSPredicate *feedpredicate = [NSPredicate predicateWithFormat:@"(%K contains[c] %@)",@"commentType" , @"FeedPost"];
    
    NSPredicate *feedCommentPredicate = [NSPredicate predicateWithFormat:@"(%K contains[c] %@)", @"commentType" , @"FeedComment"];
    
    [self updateFeedsToDataBase:[self.dataArray filteredArrayUsingPredicate:feedpredicate]
                   commentArray:[self.dataArray filteredArrayUsingPredicate:feedCommentPredicate]];

}

- (void)updateFeedsToDataBase:(NSArray *)feedArray commentArray:(NSArray *)commnetArray
{
    NSMutableArray *chatterDetailArray = [NSMutableArray new];
    
    [chatterDetailArray addObjectsFromArray:feedArray];
    [chatterDetailArray addObjectsFromArray:commnetArray];
    
    NSMutableArray *data = [self getFeedPostAndFeedComment:chatterDetailArray];
    
    if ([data count] > 0) {

        NSString *productId =  [[ChatterManager sharedInstance] getProductId];
        BOOL result = [ChatterHelper deleteRecordsForProductId:productId];
        
        if (result) {
            SXLogInfo(@"Deleted chatter records succesfully");
            [ChatterHelper saveRecods:data];
        }
    }
}

- (NSMutableArray *)getFeedPostAndFeedComment:(NSArray *)filterArray
{    
    NSString *productId =  [[ChatterManager sharedInstance] getProductId];
    
    NSMutableArray *array  = [NSMutableArray new];
    
    for (ChatterFeedComments *post in filterArray) {
        ChatterPostDetailModel *model = [[ChatterPostDetailModel alloc] init];
        model.userName = post.userName;
        model.productId = productId;
        model.body = post.commentBody;
        model.createdById = post.createdById;
        model.createdDate = post.cretedDate;
        model.postType = post.commentType;
        model.name = post.name;
        model.email = post.email;
        model.fullPhotoUrl = post.fullPhotoUrl;
        model.Id = post.postId;
        model.feedItemId = post.feedItemId;
        
        [array addObject:model];
    }
    return array;
}

- (void)fillDataArray
{
    if (self.dataArray == nil) {
        self.dataArray = [NSMutableArray new];
    }
    self.chatterArray = [[ChatterManager sharedInstance] ChatterDataDetails];
    
    for (ChatterFeedPost *post in self.chatterArray) {
        if ([post.feedComments count] > 0)
            [self.dataArray addObjectsFromArray:post.feedComments];
    }
}

- (void)updateUserDetailsForFeeds:(NSDictionary *)dict
{
    if ([dict count] > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K contains[c] %@)",@"createdById" , [dict objectForKey:kId]];
        
        NSArray *filterArray = [self.dataArray filteredArrayUsingPredicate:predicate];
        
        for (ChatterPost *post in filterArray) {
            post.name = [dict objectForKey:@"Name"];
            post.userName = [dict objectForKey:@"Username"];
            post.fullPhotoUrl = [dict objectForKey:@"FullPhotoUrl"];
            post.email = [dict objectForKey:@"Email"];
        }
    }
}

@end
