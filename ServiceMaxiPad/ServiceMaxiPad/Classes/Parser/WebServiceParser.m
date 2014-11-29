//
//  WebServiceParser.m
//  ServiceMaxMobile
//
//  Created by Pushpak on 19/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//
/**
 *  @file WebServiceParserProtocol.m
 *  @class WebServiceParserProtocol
 *
 *  @brief Base class for all web service related parsers.
 *
 *  @author Pushpak
 *
 *  @bug No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "WebServiceParser.h"

@implementation WebServiceParser

//NOTE: Update following parser method in child classes

-(ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                     responseData:(id)responseData {
    
    return nil;
}

@end
