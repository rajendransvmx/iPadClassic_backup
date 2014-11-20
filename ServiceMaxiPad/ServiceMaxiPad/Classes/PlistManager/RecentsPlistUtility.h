//
//  RecentsPlistUtility.h
//  ServiceMaxiPad
//
//  Created by Shubha S on 29/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecentsPlistUtility : NSObject

- (void)writeIntoRecentPList:(NSString*)objectName andRecordId:(NSString*)recordId;

+ (NSMutableDictionary*)getRecentsFromPlist;

+ (void)clearPlist;

@end
