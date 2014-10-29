//
//  TimeLogModel.h
//  ServiceMaxiPad
//
//  Created by Krishna Shanbhag on 29/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeLogModel : NSObject

@property(nonatomic, strong) NSString *timeLogIdKey;
@property(nonatomic, strong) NSString *timeLogIdvalue;
@property(nonatomic, strong) NSString *timeT1;
@property(nonatomic, strong) NSString *timeT4;
@property(nonatomic, strong) NSString *timeT5;


- (id)init;

- (void)explainMe;

@end
