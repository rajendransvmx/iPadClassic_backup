//
//  DODHelper.h
//  ServiceMaxiPad
//
//  Created by Himanshi Sharma on 12/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DODHelper : NSObject

+ (NSString *)getFieldNamesForObject:(NSString *)objectName;
+ (NSDictionary *)getChildRelationshipForObject:(NSString *)objetcName;


@end
