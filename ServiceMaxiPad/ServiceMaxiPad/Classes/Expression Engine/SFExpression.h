//
//  SFExpression.h
//  ServiceMaxMobile
//
//  Created by Aparna on 13/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFExpression : NSObject

@property(nonatomic, strong) NSString *identifier;
@property(nonatomic, strong) NSString *objectName;
@property(nonatomic, strong) NSString *advanceExpression;
@property(nonatomic, strong) NSString *errorMessage;

- (id)initWithDictionary:(NSDictionary *)expDict;

@end
