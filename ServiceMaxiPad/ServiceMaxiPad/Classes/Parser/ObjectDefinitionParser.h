//
//  ObjectDefinitionParser.h
//  ServiceMaxMobile
//
//  Created by shravya on 21/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebServiceParser.h"

//TO DO:
//NEED to get the object list from cache
//
@interface ObjectDefinitionParser : WebServiceParser

- (void)insertFieldInformationOfObject:(NSString *)objectName WithFieldInfo:(NSArray *)fieldInfoArray;
- (void)insertRecordTypeInformation:(NSDictionary *)recordTypeDict andObjectName:(NSString *)objectName;
- (void)insertObjectDefinition:(NSDictionary *)objectInformation andObjectName:(NSString *)objectName ;

@end
