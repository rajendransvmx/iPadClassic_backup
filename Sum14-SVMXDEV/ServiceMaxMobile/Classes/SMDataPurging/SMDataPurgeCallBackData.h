//
//  SMDataPurgeCallBackData.h
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 24/01/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMDataPurgeCallBackData : NSObject

@property (nonatomic, retain)NSMutableDictionary * partialExecutedObject;
@property (nonatomic, retain)NSString * lastIndex;
@property (nonatomic, retain)NSArray * values;
@property (nonatomic, retain)NSArray * partialExecutedObjData;

-(id) init;

@end
