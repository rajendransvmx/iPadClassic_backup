//
//  JoinObject.h
//  ServiceMaxMobile
//
//  Created by shravya on 08/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JoinObject : NSObject

@property(nonatomic,strong) NSString *objectName;
@property(nonatomic,strong) NSMutableArray *leftFieldNames;
@property(nonatomic,strong) NSMutableArray *rightFieldNames;

/* Assuming right field name will be Id of the joined table */
- (id)initWithObjectName:(NSString *)newObjectName
        andLeftFieldName:(NSString *)leftFieldName;
- (void)addFieldName:(NSString *)fieldName;

@end
