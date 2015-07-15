//
//  ThirdPartyApp.h
//  ServiceMaxiPad
//
//  Created by Krishna Shanbhag on 15/05/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

///{url_scheme_name  :"docscan",     app_display_name :"DocScan",     url_prameters:"sendto=SVMXC_CustomURL__C&goto=SVMXC__ShowPage__C" }
#import <Foundation/Foundation.h>

@interface ThirdPartyApp : NSObject
@property (nonatomic, strong) NSString *schemeName;
@property (nonatomic, strong) NSString *appDisplayName;
@property (nonatomic, strong) NSString *urlParameters;
@property (nonatomic, strong) NSMutableDictionary *parameterDict;
@property (nonatomic, strong) NSMutableDictionary *parameterValueDict;

- (instancetype)initWithDictionary:(NSDictionary *)jsonDict;
@end
