//
//  DynamicTableCreator.m
//  ServiceMaxMobile
//
//  Created by shravya on 26/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "DynamicTableCreator.h"
#import "SFObjectDAO.h"
#import "SFObjectFieldDAO.h"
#import "FactoryDAO.h"
#import "SFObjectModel.h"
#import "DatabaseConfigurationManager.h"
#import "UniversalDAO.h"

#import "DatabaseIndexManager.h"
@implementation DynamicTableCreator

-(void)createDynamicTables
{
    [[DatabaseIndexManager sharedInstance] createAllIndicesForStaticTables];
    
    //  @"ALTER TABLE SFDataTrailer ADD COLUMN 'fields_modified' VARCHAR"
    //execute create query
    NSArray * allObjects = [self fetchSFObjectsInfo];     //query Object names from SFObject table
    
    id<UniversalDAO> universalDao = [FactoryDAO serviceByServiceType:ServiceTypeUniversal];
    for(SFObjectModel * eachModel in allObjects)
    {
        NSString * objectName  = eachModel.objectName;
        NSArray * fieldsArray = [self getfieldInfoForobject:objectName]; //Query Object field Info from SFobejctField ATble
        
        NSString * query =[self prepareCreateQuery:objectName forFields:fieldsArray]; //form create query
        if([universalDao conformsToProtocol:@protocol(UniversalDAO)])
        {
            NSLog(@"TableName %@",objectName);
            BOOL createTable =  [universalDao createTable:query];
            if (!createTable) {
                
                NSLog(@"Table creation Failed %@",objectName);
            }
            else {
                [[DatabaseIndexManager sharedInstance] registerTableNameForSingleIndexing:objectName];
            }
        }
        
        if ([objectName isEqualToString:kEventObject]) {
            
            [self alterEventTable];
            
        }else if ([objectName isEqualToString:kServicemaxEventObject])
        {
            //alter ser
            [self alterServiceMaxEventTable];
            
        }
    }
    
    [[DatabaseIndexManager sharedInstance] generateIndexingForCompositeIndices];
}

-(NSArray *)fetchSFObjectsInfo
{
    NSArray *objects  = nil;
    id<SFObjectDAO> objectService = [FactoryDAO serviceByServiceType:ServiceTypeSFObject];
    if([objectService conformsToProtocol:@protocol(SFObjectDAO)])
    {
        objects = [objectService getDistinctObjects];
    }
    
    return objects;
}

-(NSArray *)getfieldInfoForobject:(NSString *)objectName
{
    NSArray * fieldInfo = nil;
    id <SFObjectFieldDAO> fieldService = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectField];
    if([fieldService conformsToProtocol:@protocol(SFObjectFieldDAO) ])
    {
        fieldInfo = [fieldService getSFObjectFieldsForObject:objectName];
    }
    return fieldInfo;
}


-(NSString *)prepareCreateQuery:(NSString *)objectName forFields:(NSArray *)fieldsArray
{
    NSMutableString *queryString = [[NSMutableString alloc] initWithFormat:@" CREATE TABLE IF NOT EXISTS '%@' (localId VARCHAR PRIMARY KEY  NOT NULL ",objectName];
    
    for (SFObjectFieldModel *objectField in fieldsArray)
    {
        // write method to return sqlite data types from sf data types
        NSString *fieldType =  [[DatabaseConfigurationManager sharedInstance] getSqliteDataTypeForSalesforceType:objectField.type];
        
         if (fieldType != nil)
         {
             [queryString appendFormat:@", '%@' %@",objectField.fieldName,fieldType];
         }
    }
    
    [queryString appendFormat:@")"];
    return queryString;
}

- (void)alterEventTable
{
    id<UniversalDAO> universalDao = [FactoryDAO serviceByServiceType:ServiceTypeUniversal];
    NSString * schema = @"ALTER TABLE Event ADD COLUMN 'isMultiDay' BOOL";
    [universalDao alterTable:schema];
    schema = @"ALTER TABLE Event ADD COLUMN 'SplitDayEvents' VARCHAR";
    [universalDao alterTable:schema];
    schema = @"ALTER TABLE Event ADD COLUMN 'TimeZone' VARCHAR";
    [universalDao alterTable:schema];
}

- (void)alterServiceMaxEventTable
{
    id<UniversalDAO> universalDao = [FactoryDAO serviceByServiceType:ServiceTypeUniversal];
    NSString * schema =[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN 'completeWhatID' VARCHAR",kServicemaxEventObject];
    [universalDao alterTable:schema];
    schema =[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN 'isMultiDay' BOOL",kServicemaxEventObject];
    [universalDao alterTable:schema];
    
    schema =[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN 'SplitDayEvents' VARCHAR",kServicemaxEventObject];
    [universalDao alterTable:schema];
    
    schema =[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN 'TimeZone' VARCHAR",kServicemaxEventObject];
    [universalDao alterTable:schema];
}

@end
