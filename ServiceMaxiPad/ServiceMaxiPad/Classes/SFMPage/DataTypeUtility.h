//
//  DataTypeUtility.h
//  ServiceMaxiPad
//
//  Created by Sahana on 29/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFObjectFieldDAO.h"

@interface DataTypeUtility : NSObject

-(NSString *)getDataTypeForObjectName:(NSString *)objectName fieldName:(NSString *)fieldName;
-(NSDictionary *)fieldDataType:(NSString *)objectName;
-(SFObjectFieldModel *)getField:(NSString *)fieldName objectName:(NSString *)objectName;
@end
