//
//  SFExpressionComponent.h
//  ServiceMaxMobile
//
//  Created by Aparna on 13/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFExpressionComponent : NSObject

@property(nonatomic, strong) NSString *expressionId;
@property(nonatomic, assign) NSUInteger sequenceNumber;
@property(nonatomic, strong) NSString *rhsValue;
@property(nonatomic, strong) NSString *lhsValue;
@property(nonatomic, strong) NSString *operatorValue;
@property(nonatomic, strong) NSString *fieldType;
@property(nonatomic, strong) NSString *parameterType;

- (id)initWithDictionary:(NSDictionary *)expCompDict;

@end
