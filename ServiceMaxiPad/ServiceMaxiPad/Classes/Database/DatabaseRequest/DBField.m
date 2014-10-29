//
//  DBField.m
//  ServiceMaxMobile
//
//  Created by Shravya on 10/08/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "DBField.h"
#import "DatabaseConstant.h"
#import "DBRequestConstant.h"

@implementation DBField

- (id)initWithFieldName:(NSString *)newFieldName
               dataType:(NSString *)newDataType
           andTableName:(NSString *)newTableName {
    
    self = [super init];
    if (self != nil) {
        self.tableName = newTableName;
        self.name = newFieldName;
        self.dataType = [self getDbDataType:newDataType];
    }
    return self;
}

- (id)initWithFieldName:(NSString *)newFieldName  andTableName:(NSString *)newTableName {
    self = [super init];
    if (self != nil) {
        self.tableName = newTableName;
        self.name = newFieldName;
       
    }
    return self;
}


- (id)initWithFieldName:(NSString *)newFieldName
              tableName:(NSString *)newTableName
           andOrderType:(SQLOrderByType )newOrderType{
    self = [super init];
    if (self != nil) {
        self.tableName = newTableName;
        self.name = newFieldName;
        self.orderType = newOrderType;
    }
    return self;
}

- (NSString *)getDbDataType:(NSString *)newDataType {
    @synchronized([self class]) {
        return  [DBRequestUtility getSqliteDataTypeForSalesforceType:newDataType];
    }
}



@end
