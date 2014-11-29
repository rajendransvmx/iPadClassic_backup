//
//  NSDictionary+JSONString.h
//  MapARC
//
//  Created by Anoop on 9/11/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (JSONString)

- (NSString*)jsonStringWithPrettyPrint:(BOOL) prettyPrint;

@end
