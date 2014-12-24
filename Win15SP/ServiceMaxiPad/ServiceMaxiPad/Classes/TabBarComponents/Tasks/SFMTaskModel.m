//
//  TaskModel.m
//  ServiceMaxMobile
//
//  Created by Pushpak on 02/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "SFMTaskModel.h"

@implementation SFMTaskModel

- (instancetype) initWithLocalId:(NSString *)localId
                     description:(NSString *)description
                        priority:(NSString *)priority
                        recordId:(NSString *)sfId
                     createdDate:(NSDate *)activityDate {
    
    self = [super init];
    if (self) {
        
        _localID = [localId copy];
        _taskDescription = [description copy];
        _priority = [priority copy];
        _sfId = [sfId copy];
        _date = [activityDate copy];
    }
    return self;
}

- (void)dealloc {
    _localID = nil;
    _taskDescription = nil;
    _priority = nil;
    _date = nil;
    _sfId = nil;
}
@end
