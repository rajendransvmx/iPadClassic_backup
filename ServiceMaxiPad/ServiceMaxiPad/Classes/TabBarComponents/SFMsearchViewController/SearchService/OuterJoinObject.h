//
//  OuterJoinObject.h
//  ServiceMaxiPhone
//
//  Created by Shravya shridhar on 7/2/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OuterJoinObject : NSObject

@property(nonatomic,strong) NSString *objectName;
@property(nonatomic,strong) NSMutableArray *leftFieldNames;

- (id)initWithObjectName:(NSString *)objectName;
- (void)addFieldName:(NSString *)fieldName;

@end
