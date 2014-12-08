//
//  ResponseCallback.h
//  ServiceMaxMobile
//
//  Created by Anoop on 8/19/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestParamModel.h"

@interface ResponseCallback : NSObject

@property(nonatomic, assign) BOOL               callBack;
@property(nonatomic, strong) RequestParamModel  *callBackData;
@property(nonatomic, strong) NSDictionary *otherCallSInformation;
@property(nonatomic, strong) NSError *errorInParsing;

@end
