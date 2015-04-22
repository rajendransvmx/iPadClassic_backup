//
//  ChatterPost.h
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 19/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatterPost : NSObject

@property(nonatomic, strong)NSString *userName;
@property(nonatomic, strong)NSString *commentBody;
@property(nonatomic, strong)NSString *createdById;
@property(nonatomic, strong)NSString *cretedDate;
@property(nonatomic, strong)NSString *fullPhotoUrl;
@property(nonatomic, strong)NSString *postId;
@property(nonatomic, strong)NSString *name;
@property(nonatomic, strong)NSString *email;
@property(nonatomic, strong)NSString *createdDateString;
@property(nonatomic, strong)NSString *localId;
@property(nonatomic, strong)NSString *commentType;

- (id)initWithDictionary:(NSDictionary *)dict;

- (void)getUserReadabeDateForCreatedDate;

@end
