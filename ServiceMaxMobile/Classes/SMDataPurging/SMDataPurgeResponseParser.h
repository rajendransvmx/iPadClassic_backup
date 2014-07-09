//
//  SMDataPurgeResponseParser.h
//  ServiceMaxMobile
//
//  Created by Vipindas on 12/31/13.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "INTF_WebServicesDefServiceSvc.h"
#import "AppDelegate.h"
#import "SMDataPurgeResponse.h"


extern  NSString * const kDPResponseParserCallBack;
extern  NSString * const kDPResponseParserPartialExecutedObject;
extern  NSString * const kDPResponseParserDelete;
extern  NSString * const kDPResponseParserParent;
extern  NSString * const kDPResponseParserChild;
extern  NSString * const kDPResponseParserDwnloadCrtObjects;
extern  NSString * const kDPResponseParserErrorDomain;
extern  NSString * const kDPResponseParserLastConfigTime;
extern  NSString * const kDPResponseParserLastIndex;
extern  NSString * const KDPResponseParserPriceCalcData;


@interface SMDataPurgeResponseParser : NSObject

+ (SMDataPurgeResponse *)parseWSResponse:(INTF_WebServicesDefBindingResponse *)response
                   operationTypeMetaSync:(BOOL)isMetaSync;

@end
