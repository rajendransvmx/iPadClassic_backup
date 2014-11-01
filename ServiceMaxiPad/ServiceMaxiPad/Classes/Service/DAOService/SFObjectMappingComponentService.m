//
//  SFObjectMappingComponentService.m
//  ServiceMaxMobile
//
//  Created by Krishna Shanbhag on 21/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFObjectMappingComponentService.h"
#import "DBCriteria.h"
#import "DBRequestSelect.h"

@implementation SFObjectMappingComponentService

- (NSString *)tableName {
    return @"SFObjectMappingComponent";
}

-(NSMutableArray *)getObjectMappingDictForMappingId:(NSString *)mappingId
{
    NSArray *fieldsArray = [[NSArray alloc] initWithObjects:@"objectMappingId",@"sourceFieldName",@"targetFieldName", @"mappingValue",@"preference2", @"preference3",nil];
    

    DBCriteria * criteria = [[DBCriteria alloc] initWithFieldName:@"objectMappingId" operatorType:SQLOperatorEqual andFieldValue:mappingId];
    
    NSMutableArray *mappingArray =  [self fetchObjectMppingByFields:fieldsArray andCriteria:criteria];
    
    return mappingArray;
}

- (NSMutableArray * )fetchObjectMppingByFields:(NSArray *)fieldNames andCriteria:(DBCriteria *)criteria
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:fieldNames whereCriteria:criteria];
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    
    if (didOpen)
    {
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:query];
        
        while ([resultSet next]) {
            
            SFObjectMappingComponentModel * model = [[SFObjectMappingComponentModel alloc] init];
            
            [resultSet kvcMagic:model];
            
            /*    Below Commented code is different ways to fill the model */
            
            /* NSDictionary * dict = [resultSet resultDictionary]; */
            /*   1. [ParserUtility parseJSON:dict toModelObject:model
             withMappingDict:nil]; */
            
            /*    2. for (NSString * eachFieldName in dict) {
             
             [model setValue:[dict objectForKey:eachFieldName] forKey:eachFieldName];
             }*/
            
            /* Suggesting to use kvcMagic method to fill the model since the execution time taken is very less*/
            [records addObject:model];
        }
        
    }
    return records;
}

@end
