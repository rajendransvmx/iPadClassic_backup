//
//  SuccessiveSyncModel.h
//  ServiceMaxMobile
//
//  Created by Sahana on 03/01/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SuccessiveSyncModel : NSObject
@property (nonatomic, retain) NSString * localId;
@property (nonatomic, retain) NSString * objectName;
@property (nonatomic, retain) NSMutableDictionary * dataDict;
@property (nonatomic, retain) NSString * sfId;
@property (nonatomic, retain) NSString * parentObjectName;
@property (nonatomic, retain) NSString * operation;
@property (nonatomic, retain) NSString * parentLocalId;
@property (nonatomic, retain) NSString * record_type;
@property (nonatomic, retain) NSString * syncFlag;
@property (nonatomic, retain) NSString * parentObjName;
@property (nonatomic, retain) NSString * syncType;
@property (nonatomic, retain) NSString * headerLocalId;
@property (nonatomic, assign) BOOL isDBUpdated;
@end

