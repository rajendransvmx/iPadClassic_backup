//
//  DARequest.m
//  JavascriptInterface
//
//  Created by Shravya shridhar on 4/22/13.
//  Copyright (c) 2013 Shravya shridhar. All rights reserved.
//

#import "DARequest.h"
#import "Utility.h"

#define kDAObjectName       @"objectName"
#define kDAFieldNameArray   @"fieldNames"
#define kDACriteriaArray    @"criteria"
#define kDAExpr             @"advancedExpression"
#define kDAOrderbyVal       @"orderBy"
#define kDAResponse         @"response"
#define kSOQLJson           @"jsonSoql"
@implementation DARequest

- (id)initWithDictionary:(NSDictionary *)dataDictionary {
    
    self = [super init];
    if (self != nil) {
        
        /* Parse the dictionary */
        self.objectName = [dataDictionary objectForKey:kDAObjectName];
      
        NSArray *fields = [dataDictionary objectForKey:kDAFieldNameArray];
        if ([fields isKindOfClass:[NSArray class]] && [fields count ] > 0) {
            self.fieldsArray = fields;
        }
        
        NSArray *criterias = [dataDictionary objectForKey:kDACriteriaArray];
        if ([criterias isKindOfClass:[NSArray class]] && [criterias count ] > 0) {
            self.criteriaArray = criterias;
        }
        
        NSString *advanceExpr = [dataDictionary objectForKey:kDAExpr];
        if (![Utility isStringEmpty:advanceExpr]) {
            self.advanceExpression = advanceExpr;
        }
        
        NSString *orderBB = [dataDictionary objectForKey:kDAOrderbyVal];
        if (![Utility isStringEmpty:orderBB]) {
            self.orderBy = orderBB;
        }
        
        NSString *sqlJson = [dataDictionary objectForKey:kSOQLJson];
        if (![Utility isStringEmpty:sqlJson]) {
            self.query = sqlJson;
        }
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    
    NSMutableDictionary *finalDictionary = [[NSMutableDictionary alloc] init];
    if (self.objectName != nil) {
        [finalDictionary setObject:self.objectName forKey:kDAObjectName];
    }
    
    if (self.fieldsArray != nil) {
        [finalDictionary setObject:self.fieldsArray forKey:kDAFieldNameArray];
    }
    
    if (self.criteriaArray != nil) {
        [finalDictionary setObject:self.criteriaArray forKey:kDACriteriaArray];
    }
    
    if (self.advanceExpression != nil) {
        [finalDictionary setObject:self.advanceExpression forKey:kDAExpr];
    }
    
    if (self.orderBy != nil) {
        [finalDictionary setObject:self.orderBy forKey:kDAOrderbyVal];
    }
    
    NSDictionary *response = [self.responseObject dictionaryRepresenation];
    if (response != nil) {
        [finalDictionary setObject:response forKey:kDAResponse];

    }
    return finalDictionary;
}

@end
