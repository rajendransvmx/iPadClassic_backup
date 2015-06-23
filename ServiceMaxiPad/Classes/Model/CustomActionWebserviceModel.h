//
//  CustomActionWebserviceModel.h
//  ServiceMaxiPad
//
//  Created by Apple on 23/06/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomActionWebserviceModel : NSObject
@property(nonatomic, copy) NSString *processId;
@property(nonatomic, copy) NSString *className;
@property(nonatomic, copy) NSString *methodName;
@property(nonatomic, copy) NSString *objectName;
@property(nonatomic, copy) NSString *objectFieldId;
@property(nonatomic, copy) NSString *ObjectFieldName;
@end
