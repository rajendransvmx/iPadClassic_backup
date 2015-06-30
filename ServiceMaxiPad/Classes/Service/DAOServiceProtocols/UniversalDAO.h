//
//  UniversalDAO.h
//  ServiceMaxMobile
//
//  Created by Vipindas on 5/27/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UniversalDAO <NSObject>
- (BOOL)createTable:(NSString *)createQuery;
- (BOOL)alterTable:(NSString*)alterQuery;
- (BOOL)isColumn:(NSString *)columnName existInTable:(NSString*)tableName;

@end
