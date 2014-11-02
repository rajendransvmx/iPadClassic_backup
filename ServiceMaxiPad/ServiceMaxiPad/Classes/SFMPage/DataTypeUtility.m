//
//  DataTypeUtility.m
//  ServiceMaxiPad
//
//  Created by Sahana on 29/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "DataTypeUtility.h"
#import "SFObjectFieldDAO.h"
#import "FactoryDAO.h"

@interface DataTypeUtility()

@property(nonatomic, strong) NSMutableDictionary * fieldVsDataType;

@end

@implementation DataTypeUtility
-(id)init
{
    self  = [super init];
    if(self != nil)
    {
        self.fieldVsDataType = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return self;
}

-(NSString *)getDataTypeForObjectName:(NSString *)objectName fieldName:(NSString *)fieldName
{
    
    NSDictionary * dict  = [self fieldDataType:objectName];
    NSString * dataType = [dict objectForKey:fieldName];
    return dataType;
}

-(NSDictionary *)fieldDataType:(NSString *)objectName
{
    NSDictionary * dict  =  [self.fieldVsDataType objectForKey:objectName];
    if( dict == nil )
    {
        id <SFObjectFieldDAO> objectFieldDao =  [FactoryDAO serviceByServiceType:ServiceTypeSFObjectField];
        NSArray * fieldsArray = [objectFieldDao getSFObjectFieldsForObject:objectName];
        dict = [self getFielDataType:fieldsArray];
        [self.fieldVsDataType setObject:dict forKey:objectName];
    }
    return dict;
}


-(NSDictionary *)getFielDataType:(NSArray *)fieldsArray
{
    NSMutableDictionary * fieldsDatatypeDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    for (SFObjectFieldModel * model in fieldsArray) {
        if(model.fieldName != nil && model.type != nil)
        {
            [fieldsDatatypeDict setObject:model.type  forKey:model.fieldName];
        }
    }
    
    return fieldsDatatypeDict;
}

@end
