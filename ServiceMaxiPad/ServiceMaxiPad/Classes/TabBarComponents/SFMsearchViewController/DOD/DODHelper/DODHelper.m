//
//  DODHelper.m
//  ServiceMaxiPad
//
//  Created by Himanshi Sharma on 12/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "DODHelper.h"
#import "DataTypeUtility.h"
#import "SFChildRelationshipDAO.h"
#import "FactoryDAO.h"

@implementation DODHelper

+ (NSString *)getFieldNamesForObject:(NSString *)objectName
{
    DataTypeUtility *utility = [[DataTypeUtility alloc] init];
    
    NSDictionary *fieldInfo = [utility fieldDataType:objectName];
    
    NSArray *fields = [fieldInfo allKeys];
    
    NSString *fieldString = [fields componentsJoinedByString:@","];
    
    return fieldString;
}

+ (NSDictionary *)getChildRelationshipForObject:(NSString *)objetcName
{
    id  childRelationshipService = [FactoryDAO serviceByServiceType:ServiceTypeSFChildRelationShip];
    
    if ([childRelationshipService conformsToProtocol:@protocol(SFChildRelationshipDAO)]) {
        
        
        
    }
    
    return nil;
}

@end
