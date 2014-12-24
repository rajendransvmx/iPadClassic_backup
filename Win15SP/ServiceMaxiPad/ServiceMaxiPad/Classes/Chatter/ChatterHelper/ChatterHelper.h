//
//  ChatterHelper.h
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 19/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatterHelper : NSObject

+ (NSString *)requestQueryForProductIamge;
+ (NSString *)requestQueryForChatterPost;
+ (NSString *)requestQueryForChatterPostDetails;

+ (void)pushDataToCahcche:(NSString *)value forKey:(NSString *)key;


@end
