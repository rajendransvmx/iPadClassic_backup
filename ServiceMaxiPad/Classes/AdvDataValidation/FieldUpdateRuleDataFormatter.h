//
//  FieldUpdateRuleDataFormatter.h
//  ServiceMaxiPad
//
//  Created by Padmashree on 26/06/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFMPage.h"

@interface FieldUpdateRuleDataFormatter : NSObject

@property(nonatomic, strong)NSArray *bizRuleProcesses;
@property(nonatomic, strong)SFMPage *sfmPage;

- (id)initWithBusinessRuleProcesses:(NSArray *)bizRuleProcesses sfmPage:(SFMPage *)sfmPage;
- (NSDictionary *)formtaBusinessRuleInfo;

@end
