//
//  JoinObject.m
//  ServiceMaxMobile
//
//  Created by shravya on 08/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "JoinObject.h"

@implementation JoinObject

- (id)initWithObjectName:(NSString *)newObjectName andLeftFieldName:(NSString *)leftFieldName {
    self = [super init];
    if (self != nil) {
        self.objectName = newObjectName;
        self.leftFieldNames = [[NSMutableArray alloc] init];
        [self addFieldName:leftFieldName];
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
