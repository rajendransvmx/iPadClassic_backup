//
//  ValueMappingModel.h
//  ServiceMaxiPad
//
//  Created by Sahana on 20/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ValueMappingModel : NSObject
@property (nonatomic, strong) NSMutableDictionary *currentRecord;
@property (nonatomic, strong) NSMutableDictionary *headerRecord;
@property (nonatomic, strong) NSString *currentObjectName;
@property (nonatomic, strong) NSString *headerObjectName;
@property (nonatomic, strong) NSDictionary * valueMappingDict;
@end
