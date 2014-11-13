//
//  LinkedProcess.h
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 08/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LinkedProcess : NSObject

@property(nonatomic, strong)NSString *processId;
@property(nonatomic, strong)NSString *processName;
@property(nonatomic, strong)NSString *processType;
@property(nonatomic, strong)NSString *objectName;
@property(nonatomic, strong)NSString *recordId;

- (id)initWithProcessId:(NSString *)processSfId name:(NSString *)processName type:(NSString *)processType;
@end
