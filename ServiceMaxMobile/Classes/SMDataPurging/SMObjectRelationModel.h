//
//  SMObjectRelationModel.h
//  ServiceMaxMobile
//
//  Created by Vipindas on 1/29/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMObjectRelationModel : NSObject

@property (nonatomic, copy)NSString *parentName;
@property (nonatomic, copy)NSString *childName;
@property (nonatomic, copy)NSString *childFieldName;

- (BOOL) isChild;

@end
