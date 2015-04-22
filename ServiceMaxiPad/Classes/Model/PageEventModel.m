//
//  PageEventModel.m
//  ServiceMaxiPad
//
//  Created by Krishna Shanbhag on 08/01/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "PageEventModel.h"
#import "ResponseConstants.h"
#import "RequestConstants.h"

@implementation PageEventModel

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        //Initialization
    }
    return self;
}
- (id)initWithDictionary:(NSDictionary *)pageEventDict
{
    self = [super init];
    if (self) {
        
        _pageEventId = [pageEventDict objectForKey:kId];
        _pageEventName = [pageEventDict objectForKey:kName];
        _pageEventCallType = [pageEventDict objectForKey:kPageHeaderBtnEventCall];
        _pageEventType = [pageEventDict objectForKey:kPageHeaderBtnEventType];
        _pageEventIsStandard = [[pageEventDict objectForKey:kPageHeaderIsStandard] boolValue];
        _pageLayout = [pageEventDict objectForKey:kPageLayoutId];
        _pageTargetCall = [pageEventDict objectForKey:kPageTargetCall];
        
        
    }
    return self;
}


@end
