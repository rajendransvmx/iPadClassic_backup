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

@interface DARequest : NSObject {
    NSString *objectName;
    NSArray  *fieldsArray;
    NSArray  *criteriaArray;
    NSString *advanceExpression;
    NSString *orderBy;
    NSString *query;
    DAResponse *responseObject;
}

@property(nonatomic,retain) NSString   *objectName;
@property(nonatomic,retain) NSArray    *fieldsArray;
@property(nonatomic,retain) NSArray    *criteriaArray;
@property(nonatomic,retain) NSString   *advanceExpression;
@property(nonatomic,retain) NSString   *orderBy;
@property(nonatomic,retain) DAResponse *responseObject;
@property(nonatomic,retain) NSString    *query;

- (id)initWithDictionary:(NSDictionary *)dataDictionary;
- (NSDictionary *)dictionaryRepresentation;

@end
