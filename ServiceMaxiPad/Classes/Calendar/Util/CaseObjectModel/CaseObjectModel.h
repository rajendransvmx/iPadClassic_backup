//
//  CaseObjectModel.h
//  ServiceMaxiPad
//
//  Created by Admin on 17/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CaseObjectModel : NSObject
@property(nonatomic, assign) BOOL sla;
@property(nonatomic, assign) BOOL priority;
@property(nonatomic, assign) BOOL conflict;
@property (nonatomic, copy) NSString *priorityString;

@end
