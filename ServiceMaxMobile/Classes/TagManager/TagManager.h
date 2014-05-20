//
//  TagManager.h
//  ServiceMaxMobile
//
//  Created by Vipindas on 3/26/14.
//  Copyright (c) 2013 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TagManager : NSObject

+ (TagManager *)sharedInstance;

- (void)loadTags;
- (void)reloadTags;

- (NSString *)tagByName:(NSString *)tagNameOrCode;

@end
