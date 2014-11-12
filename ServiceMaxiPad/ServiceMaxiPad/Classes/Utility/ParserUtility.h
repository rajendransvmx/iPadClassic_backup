//
//  ObjectParser.h
//  ModelObjectParse
//
//  Created by Himanshi Sharma on 12/08/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "ModelObject.h"
#import <objc/runtime.h>

@interface ParserUtility : NSObject

+(id)parseJSON:(NSDictionary *)jsonDict
 toModelObject:(id)modelObject
withMappingDict:(NSDictionary *)mappingDict;

+(NSArray*)getPropertiesOfClass:(id)objectClass;


@end
