//
//  ThirdPartyApp.m
//  ServiceMaxiPad
//
//  Created by Krishna Shanbhag on 15/05/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "ThirdPartyApp.h"

const NSString *appDisplayNameKey = @"app_display_name";
const NSString *schemeNameKey = @"url_scheme_name";
const NSString *urlParam = @"url_prameters";


@implementation ThirdPartyApp


- (instancetype)initWithDictionary:(NSDictionary *)jsonDict {
    
    if (self == [super init]) {
        
        if (jsonDict[appDisplayNameKey] != nil && ![jsonDict[appDisplayNameKey] isKindOfClass:[NSNull class]]) {
            _appDisplayName = jsonDict [appDisplayNameKey];
        }
        if (jsonDict[schemeNameKey] != nil && ![jsonDict[schemeNameKey] isKindOfClass:[NSNull class]]) {
            _schemeName = jsonDict [schemeNameKey];
        }
        if (jsonDict[urlParam] != nil && ![jsonDict[urlParam] isKindOfClass:[NSNull class]]) {
            _urlParameters = jsonDict [urlParam];
        }
        _parameterDict = [NSMutableDictionary new];
        _parameterValueDict = [NSMutableDictionary new];
    }
    return self;
}
@end
