//
//  DBRequestInsert.m
//  ServiceMaxMobile
//
//  Created by Shravya on 10/08/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "DBRequestInsert.h"
#import "DBField.h"


@interface DBRequestInsert ()



@end


@implementation DBRequestInsert




- (id)initWithTableName:(NSString *)tableName
        andFieldObjects:(NSArray *)fieldObjects {
    
    self = [super init];
    if (self != nil) {
        
        [self setObjectTableName:tableName];
        [self setFields:fieldObjects];
    }
    return self;
}

- (id)initWithTableName:(NSString *)tableName
        andFieldNames:(NSMutableArray *)fieldNames {
    
    self = [super init];
    if (self != nil) {
        
        [self setObjectTableName:tableName];
        [self setFieldNames:fieldNames];
    }
    return self;
}

/*
- (void)fillUpFieldsAndNumberInQuery:(NSMutableString *)query {
    
    NSMutableString *concatenatedFieldString = [[NSMutableString alloc] init];
    NSMutableString *concatenatedNumberString = [[NSMutableString alloc] init];
    for (int counter = 0; counter < [self.fieldObjects count]; counter++) {
        
        DBField *aField = [self.fieldObjects objectAtIndex:counter];
        if (counter == 0) {
            [concatenatedFieldString appendFormat:@"'%@'",aField.name];
            [concatenatedNumberString appendFormat:@"?%d",(counter + 1)];
        }
        else{
            [concatenatedFieldString appendFormat:@",'%@'",aField.name];
            [concatenatedNumberString appendFormat:@",?%d",(counter + 1)];
        }
    }
    [query appendFormat:@" (%@) VALUES (%@) ",concatenatedFieldString,concatenatedNumberString];
}
*/

- (void)fillUpFieldsAndNumberInQuery:(NSMutableString *)query {
    
    NSMutableString *concatenatedFieldString = [[NSMutableString alloc] init];
    NSMutableString *concatenatedNumberString = [[NSMutableString alloc] init];
    
    if ((self.fieldNames != nil ) && ([self.fieldNames count] > 0))
    {
        for (int counter = 0; counter < [self.fieldNames count]; counter++) {
            
            NSString *aFieldName = [self.fieldNames objectAtIndex:counter];
            
            if (counter == 0) {
                [concatenatedFieldString appendFormat:@"'%@'",aFieldName];
                [concatenatedNumberString appendFormat:@":%@",aFieldName];
            }
            else{
                [concatenatedFieldString appendFormat:@",'%@'",aFieldName];
                [concatenatedNumberString appendFormat:@",:%@",aFieldName];
            }
        }
    }
    else
    {
        for (int counter = 0; counter < [self.fieldNames count]; counter++) {
            
            DBField *aField = [self.fieldObjects objectAtIndex:counter];
            if (counter == 0) {
                [concatenatedFieldString appendFormat:@"'%@'",aField.name];
                [concatenatedNumberString appendFormat:@":%@",aField.name];
            }
            else{
                [concatenatedFieldString appendFormat:@",'%@'",aField.name];
                [concatenatedNumberString appendFormat:@",:%@",aField.name];
            }
        }
    }
    [query appendFormat:@" (%@) VALUES (%@) ",concatenatedFieldString,concatenatedNumberString];
}

- (NSString *)query {
    @synchronized([self class]){
        @autoreleasepool {
            NSMutableString *query = [[NSMutableString alloc] initWithFormat:@"INSERT INTO '%@' ",self.tableName];
            [self fillUpFieldsAndNumberInQuery:query];
            return query;
        }
    }
    return nil;
}

@end
