//
//  TaskModel.h
//  ServiceMaxMobile
//
//  Created by Pushpak on 02/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SFMTaskModel : NSObject
@property (nonatomic, copy) NSString *taskDescription;
@property (nonatomic, copy) NSString *priority;
@property (nonatomic, copy) NSString *localID;
@property (nonatomic, copy) NSString *sfId;
@property (nonatomic, copy) NSDate *date;

- (instancetype) initWithLocalId:(NSString *)localId
                     description:(NSString *)description
                        priority:(NSString *)priority
                        recordId:(NSString *)sfId
                     createdDate:(NSDate *)activityDate;

@end
