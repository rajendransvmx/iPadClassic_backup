//
//  SFMLookUpFilter.h
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 01/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFMLookUpFilter : NSObject

@property(nonatomic, strong)NSString *searchId;
@property(nonatomic, strong)NSString *sourceObjectName;
@property(nonatomic, strong)NSString *searchFieldName;
@property(nonatomic, strong)NSString *advanceExpression;
@property(nonatomic, strong)NSString *ruleType;
@property(nonatomic, strong)NSString *name;
@property(nonatomic, strong)NSString *nameSearchID;

@property(nonatomic, assign)BOOL allowOverride;
@property(nonatomic, assign)BOOL defaultOn;
@property(nonatomic, assign)BOOL objectPermission;

//krishna CONTEXTFILTER
@property(nonatomic,strong) NSString *lookupContext;
@property(nonatomic,strong) NSString *lookContextDisplayValue;
@property(nonatomic,strong) NSString *lookupContextParentObject;
@property(nonatomic,strong) NSString *lookupQuery;

@end
