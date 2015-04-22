//
//  ChatterFeedself.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 23/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ChatterFeedComments.h"

@implementation ChatterFeedComments

- (id)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super initWithDictionary:dict]) {
        
        if ([dict count] > 0) {
            self.commentBody = [dict objectForKey:@"CommentBody"];
            self.feedItemId = [dict objectForKey:@"FeedItemId"];
            self.commentType = @"FeedComment";
        }
    }
    return self;
}

@end
