//
//  PageEventModel.h
//  ServiceMaxiPad
//
//  Created by Krishna Shanbhag on 08/01/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PageEventModel : NSObject


@property(nonatomic, strong) NSString *pageEventId;
@property(nonatomic, strong) NSString *pageEventName;
@property(nonatomic, strong) NSString *pageEventCallType;
@property(nonatomic, strong) NSString *pageEventType;
@property(nonatomic)              BOOL pageEventIsStandard;
@property(nonatomic, strong) NSString *pageLayout;
@property(nonatomic, strong) NSString *pageTargetCall;

- (id)init;
- (id)initWithDictionary:(NSDictionary *)pageEventDict;

@end
