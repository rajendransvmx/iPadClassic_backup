//
//  RecentsDao.h
//  ServiceMaxiPad
//
//  Created by Shubha S on 30/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RecentModel.h"

@protocol RecentsDao <NSObject>

- (void)deleteOldestRecentObject;

- (NSArray *)getRecentRecordInfo;

- (void)saveRecentRecord:(RecentModel*)model;

@end
