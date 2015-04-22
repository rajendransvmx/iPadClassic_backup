//
//  OuterJoinObject.m
//  ServiceMaxiPhone
//
//  Created by Shravya shridhar on 7/2/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "OuterJoinObject.h"

@implementation OuterJoinObject

- (id)initWithObjectName:(NSString *)newObjectName{
    self = [super init];
    if (self != nil) {
        self.objectName = newObjectName;
        self.leftFieldNames = [[NSMutableArray alloc] init];
    }
    return self;
    
}

- (void)addFieldName:(NSString *)fieldName {
    if (fieldName.length < 1) {
        return;
    }
    if (![self.leftFieldNames containsObject:fieldName]) {
        [self.leftFieldNames  addObject:fieldName];
    }
}
@end
