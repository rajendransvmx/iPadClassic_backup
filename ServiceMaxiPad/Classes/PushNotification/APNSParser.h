//
//  APNSParser.h
//  ServiceMaxiPad
//
//  Created by Himanshi Sharma on 24/03/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebServiceParser.h"


@interface APNSParser : WebServiceParser


-(ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                     responseData:(id)responseData;

@end
