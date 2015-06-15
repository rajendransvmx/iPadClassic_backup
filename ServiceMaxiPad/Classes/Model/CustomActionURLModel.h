//
//  CustomActionURLModel.h
//  ServiceMaxiPad
//
//  Created by Apple on 12/06/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomActionURLModel : NSObject

@property(nonatomic) NSInteger localId;
@property(nonatomic, copy) NSString *Id;
@property(nonatomic, copy) NSString *Name;
@property(nonatomic, copy) NSString *DispatchProcessId;
@property(nonatomic, copy) NSString *ParameterName;
@property(nonatomic, copy) NSString *ParameterType;
@property(nonatomic, copy) NSString *ParameterValue;
//@property(nonatomic, copy) NSString *attributes;
- (id)init;
+ (NSDictionary *)getMappingDictionary;

//NSString *const kTableSFMCustomActionParams = @"CREATE TABLE IF NOT EXISTS customActionParams ('local_id' INTEGER PRIMARY KEY NOT NULL DEFAULT (0), 'ParamId' VARCHAR, 'name' VARCHAR, 'DispatchProcessId' VARCHAR , 'ParameterName' VARCHAR, 'ParameterType' VARCHAR 'attributes', VARCHAR)";
@end
