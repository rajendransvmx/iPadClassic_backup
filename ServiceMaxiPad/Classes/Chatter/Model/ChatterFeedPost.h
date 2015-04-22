//
//  ChatterFeedPost.h
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 23/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ChatterPost.h"

@interface ChatterFeedPost : ChatterPost

@property(nonatomic, strong)NSString *feedPostId;
@property(nonatomic, strong)NSString *parentId;
@property(nonatomic, strong)NSMutableArray *feedComments;

@end
