//
//  ChatterFeedPost.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 23/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ChatterFeedPost.h"

@implementation ChatterFeedPost


- (id)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super initWithDictionary:dict]) {
        
        if ([dict count] > 0) {
            self.feedPostId = [dict objectForKey:@"FeedPostId"];
            self.parentId = [dict objectForKey:@"ParentId"];
            self.commentType = @"FeedPost";
        }
    }
    return self;
}

@end
