//
//  ChatterManager.h
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 19/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatterFeedComments.h"
#import "ChatterFeedPost.h"


typedef NS_ENUM(NSInteger, ChatterResponseStatus)
{
    ResponseStatusNone = 0,
    ResponseStatusProductImage,
    ResponseStatusChatterData,
    ResponseStatusChatterFeed,
    ResponseStatusFailed
};


extern NSString *kChatterDataModified;

@interface ChatterManager : NSObject

+ (instancetype) alloc  __attribute__((unavailable("alloc not available, call sharedInstance instead")));
- (instancetype) init   __attribute__((unavailable("init not available, call sharedInstance instead")));
+ (instancetype) new    __attribute__((unavailable("new not available, call sharedInstance instead")));


+ (instancetype)sharedInstance;

- (void)setProductId:(NSString *)productId;

- (NSString *)getProductId;

- (void)refreshData;
- (void)fetchChatterPosts;
- (void)fetchChatterDetails;
- (UIImage *)chatterProductImage;
- (NSMutableArray *)ChatterDataDetails;
- (void)updateChatterData:(NSMutableArray *)array;
- (void)clearCache;
- (void)stopAllTasks;

- (void)postNewFeed:(ChatterFeedPost *)feed;
- (void)postFeedComment:(ChatterFeedComments *)comments;
- (void)deleteParamDictForkey:(NSString *)key;

- (NSDictionary *)paramDictForkey:(NSString *)key;

- (void)updateUserImagesToRefresh;

- (void)setFirstTimeloadflag:(BOOL)value;
- (BOOL)getFirstTimeLoad;


@end
