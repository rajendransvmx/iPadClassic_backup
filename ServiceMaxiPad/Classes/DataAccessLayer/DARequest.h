//
//  DARequest.h
//  JavascriptInterface
//
//  Created by Shravya shridhar on 4/22/13.
//  Copyright (c) 2013 Shravya shridhar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAResponse.h"

#define kDAFieldName  @"fieldName"
#define kDAFieldValue @"fieldValue"
#define kDAFieldType  @"fieldType"
#define kDAOperator   @"operator"

@interface DARequest : NSObject

@property(nonatomic,strong) NSString   *objectName;
@property(nonatomic,strong) NSArray    *fieldsArray;
@property(nonatomic,strong) NSArray    *criteriaArray;
@property(nonatomic,strong) NSString   *advanceExpression;
@property(nonatomic,strong) NSString   *orderBy;
@property(nonatomic,strong) DAResponse *responseObject;
@property(nonatomic,strong) NSString    *query;
@property(nonatomic,strong) NSString    *innerJoin; // 012895


- (id)initWithDictionary:(NSDictionary *)dataDictionary;
- (NSDictionary *)dictionaryRepresentation;

@end
