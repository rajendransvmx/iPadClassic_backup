//
//  StaticResourceParser.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 26/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//


/**
 *  @file   StaticResourceParser.m
 *  @class  className
 *
 *  @brief
 *
 *   This is a modle class which holds all the info.
 *
 *  @author Shubha S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "StaticResourceParser.h"
#import "StaticResourceModel.h"
#import "StaticResourceService.h"
#import "ParserUtility.h"
#import "FactoryDAO.h"
#import "StaticResourceDAO.h"
#import "DocumentService.h"
#import "DocumentModel.h"

@implementation StaticResourceParser

/**
 * @name (ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
 responseData:(id)responseData
 *
 * @author Shubha
 *
 * @brief it parses the respoce given and returns responce callback.
 *
 *
 *
 * @param RequestParamModel object
 * @param responceData (id)
 *
 * @return ResponseCallback Object
 *
 */

-(ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                     responseData:(id)responseData {
    
    if (![responseData isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    @synchronized([self class])
    {
        @autoreleasepool
        {
            if (![responseData isKindOfClass:[NSDictionary class]]) {
                return nil;
            }

            ResponseCallback *callBack = [[ResponseCallback alloc] init];
            // callbk.callBackEventName = kStaticRequestEventName;
            callBack.callBack = NO;
            
            // NSLog(@"Static Resource response \n%@",responsedata);
            
            NSArray *maps = [responseData objectForKey:@"valueMap"];
            NSMutableDictionary *finalDict = [[NSMutableDictionary alloc] init];
            for (NSDictionary* mapObj in maps)
            {
                //NSMutableArray *staticRsrcArr = [NSMutableArray array];
                NSMutableArray *staticRsrcArr = [[NSMutableArray alloc] init];
                
                NSString *key = [mapObj objectForKey:@"key"];
                NSArray *valMap  = [mapObj objectForKey:@"valueMap"];
                for (NSDictionary* mapObj2 in valMap)
                {
                    // NSMutableDictionary *innerDict = [NSMutableDictionary dictionary];
                    NSMutableDictionary *innerDict = [[NSMutableDictionary alloc] init];
                    NSArray *valMap2 = [mapObj2 objectForKey:@"valueMap"];
                    NSDictionary* obj1 = [valMap2 objectAtIndex:0];
                    NSDictionary* obj2 = [valMap2 objectAtIndex:1];
                    
                    NSString *key1 = [obj1 objectForKey:@"key"];
                    NSString *value1 = [obj1 objectForKey:@"value"];
                    
                    NSString *key2 = [obj2 objectForKey:@"key"];
                    NSString *value2 = [obj2 objectForKey:@"value"];
                    
                    [innerDict setObject:value1 forKey:key1];
                    [innerDict setObject:value2 forKey:key2];
                    
                    if ([valMap2 count] > 2) {
                        NSDictionary* obj3 = [valMap2 objectAtIndex:2];
                        NSString *key3 = [obj3 objectForKey:@"key"];
                        NSString *value3 = [obj3 objectForKey:@"value"];
                        if (key3 != nil && value3 != nil) {
                            [innerDict setObject:value3 forKey:key3];
                        }
                    }
                    
                    
                    [staticRsrcArr addObject:innerDict];
                }
                
                [finalDict setObject:staticRsrcArr forKey:key];
            }
            
            [self createAndInsertStaticResource:[finalDict objectForKey:kStaticResourceKey]];
            [self createAndInsertIntoDocument:[finalDict objectForKey:@"DOCUMENT"]];
            
            //   [self createAndInsertStaticResource:[finalDict objectForKey:@"STATIC_RESOURCE"]]
            return callBack;
        }
        
    }
}

- (void)createAndInsertStaticResource:(NSArray*)array
{
    NSMutableArray *staticResourceArray = [[NSMutableArray alloc]init];
    NSDictionary *mappingDict = [StaticResourceModel getMappingDictionary];
    for (NSDictionary *dict in array) {
        
        StaticResourceModel *model = [[StaticResourceModel alloc] init];
        [ParserUtility parseJSON:dict toModelObject:model withMappingDict:mappingDict];
        [staticResourceArray addObject:model];
    }
    
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeStaticResource];
    
    if ([daoService conformsToProtocol:@protocol(StaticResourceDAO)]) {
        [daoService saveRecordModels:staticResourceArray];
    }
}

- (void)createAndInsertIntoDocument:(NSArray*)array
{
    NSMutableArray *documentArray = [[NSMutableArray alloc]init];
    NSDictionary *mappingDict = [DocumentModel getMappingDictionary];
    for (NSDictionary *dict in array) {
        
        DocumentModel *model = [[DocumentModel alloc] init];
        [ParserUtility parseJSON:dict toModelObject:model withMappingDict:mappingDict];
        [documentArray addObject:model];
    }
    
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeDocument];
    
    if ([daoService conformsToProtocol:@protocol(DocumentDAO)]) {
        [daoService saveOPDocRecords:documentArray];
    }
}

@end
