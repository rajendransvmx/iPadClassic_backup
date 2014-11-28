//
//  SFPageButton.m
//  ServiceMaxiPhone
//
//  Created by Shravya shridhar on 6/24/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "SFPageButton.h"

@implementation SFPageButton

- (id)initWithTitle:(NSString *)newTitle
       andEventType:(NSString *)callBackType{
    self = [super init];
    if (self != nil) {
        self.title = newTitle;
        self.eventCallBackType = callBackType;
        self.enabled = YES;
        
    }
    return self;
}

@end
