//
//  CustomActionWebserviceModel.h
//  ServiceMaxiPad
//
//  Created by Apple on 23/06/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFMPage.h"

@interface CustomActionWebserviceModel : NSObject
@property(nonatomic, copy) NSString *className;
@property(nonatomic, copy) NSString *methodName;
@property(nonatomic, strong) SFMPage *sfmPage;
@property(nonatomic, strong) NSString *processId;
@end
