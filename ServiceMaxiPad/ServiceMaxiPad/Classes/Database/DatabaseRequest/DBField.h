//
//  DBField.h
//  ServiceMaxMobile
//
//  Created by Shravya on 10/08/14.
//  Copyright (c) 2014 SivaManne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBRequestConstant.h"
@interface DBField : NSObject

@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *dataType;
@property(nonatomic,strong)NSString *tableName;
@property(nonatomic,assign)SQLOrderByType orderType;

- (id)initWithFieldName:(NSString *)fieldName dataType:(NSString *)dataType andTableName:(NSString *)tableName;
- (id)initWithFieldName:(NSString *)fieldName  andTableName:(NSString *)tableName;

- (id)initWithFieldName:(NSString *)fieldName tableName:(NSString *)tableName andOrderType:(SQLOrderByType )orderType;

@end
