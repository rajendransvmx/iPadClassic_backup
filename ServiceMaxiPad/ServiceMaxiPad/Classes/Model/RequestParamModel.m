//
//  RequestParamModel.m
//  ServiceMaxMobile
//
//  Created by Krishna Shanbhag on 11/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//


#import "RequestParamModel.h"


@implementation RequestParamModel

- (instancetype)init {
    if (self = [super init]) {
        //Cocoa Error. Retrying the request again.
        self.retryCount = 1;
    }
    return self;
}
@end
