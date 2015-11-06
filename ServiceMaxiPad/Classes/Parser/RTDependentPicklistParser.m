//
//  RTDependentPicklistParser.m
//  ServiceMaxMobile
//
//  Created by Pushpak on 25/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "RTDependentPicklistParser.h"
#import "ZKRecordTypeMapping.h"
#import "ZKDescribeLayoutResult.h"
#import "ZKPicklistForRecordType.h"
#import "ZKPicklistEntry.h"
#import "ResponseConstants.h"
#import "DatabaseConstant.h"
#import "SFRTPicklistModel.h"
#import "FactoryDAO.h"
#import "SFRTPicklistDAO.h"
#import "ResponseCallback.h"
#import "ProductIQManager.h"

@implementation RTDependentPicklistParser
-(ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                     responseData:(id)responseData {
    
    if (![responseData isKindOfClass:[ZKDescribeLayoutResult class]]) {
        return nil;
    }
    @autoreleasepool {
        
        NSMutableArray *rtPickListModelArray = [[NSMutableArray alloc]init];

        NSArray * recordTypeMappings = [(ZKDescribeLayoutResult*)responseData recordTypeMappings];
        for(ZKRecordTypeMapping *recordType in recordTypeMappings)
        {
            BOOL availabe = [recordType available];
            if (availabe)
            {
                NSString * recordTypeName = [recordType name];
                NSString * recordTypeLayoutId = [recordType layoutId];
                NSString * recordTypeID = [recordType recordTypeId];
                
                NSArray *pickLists = [recordType picklistsForRecordType];
                
                for(ZKPicklistForRecordType *pickList in pickLists)
                {
                    NSArray *pickListValueArray = [pickList picklistValues];
                    NSString *defaultLabel = @"";
                    NSString *defaultValue = @"";
                    for(ZKPicklistEntry *pickListValue in pickListValueArray)
                    {
                        SFRTPicklistModel *model = [[SFRTPicklistModel alloc]init];
                        model.recordTypeName = recordTypeName;
                        model.recordTypeLayoutID = recordTypeLayoutId;
                        model.recordTypeID = recordTypeID;
                        model.label = [pickListValue label];
                        model.value = [pickListValue value];
                        if([pickListValue defaultValue])
                        {
                            defaultLabel = [pickListValue label];
                            defaultValue = [pickListValue value];
                        }
                        model.defaultLabel = defaultLabel;
                        model.defaultValue = defaultValue;
                        model.fieldAPIName = [pickList picklistName];
                        model.objectAPIName = requestParamModel.value;
                        
                        [rtPickListModelArray addObject:model];
                        
                    }
                }
            }
        }
        
        
        id daoService = [FactoryDAO serviceByServiceType:ServiceTypeSFRTPicklist];
        
        if ([daoService conformsToProtocol:@protocol(SFRTPicklistDAO)]) {
            BOOL resultStatus = [daoService saveRecordModels:rtPickListModelArray];
            if (resultStatus) {
                SXLogDebug(@"RTPicklist inserted successfully");
            }
        }
        
        //-----------------
        
        if ([[ProductIQManager sharedInstance] isProductIQSettingEnable]) {
            [self saveRecordTypeMappingsInDescribeLayout:recordTypeMappings forObject:requestParamModel.value];
        }
        
        
        //------------------
        
        ResponseCallback *callBack = [[ResponseCallback alloc]init];
        callBack.callBack = NO;
        if ([requestParamModel.values count] > 0) {
            
            callBack.callBack = YES;
            RequestParamModel *reqModel = [[RequestParamModel alloc]init];
            reqModel.value = [requestParamModel.values objectAtIndex:0];
            NSMutableArray *tempArray = [[NSMutableArray alloc]initWithArray:requestParamModel.values];
            [tempArray removeObject:reqModel.value];
            reqModel.values = tempArray;
            callBack.callBackData = reqModel;
        }
        return callBack;
    }
}


-(void)saveRecordTypeMappingsInDescribeLayout:(NSArray *)recordTypeMappings forObject:(NSString *)objectName {
    
    if ([[[ProductIQManager sharedInstance] getProdIQRelatedObjects] containsObject:objectName]) {
        
        NSMutableArray *recordTypeMappingsArray = [NSMutableArray array];
        
        for(ZKRecordTypeMapping *recordType in recordTypeMappings) {
            
            NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
            
            BOOL availabe = [recordType available];
            BOOL defaultRecordTypeMapping = [recordType defaultRecordTypeMapping];
            
            NSArray *pickLists = [recordType picklistsForRecordType];
            
            [tempDict setObject:(availabe)?@"true":@"false" forKey:@"available"];
            [tempDict setObject:(defaultRecordTypeMapping)?@"true":@"false" forKey:@"defaultRecordTypeMapping"];
            [tempDict setObject:[recordType layoutId] forKey:@"layoutId"];
            [tempDict setObject:[recordType name] forKey:@"name"];
            [tempDict setObject:[recordType recordTypeId] forKey:@"recordTypeId"];
            
            NSMutableDictionary *picklistsForRecordTypeDict = [NSMutableDictionary dictionary];
            
            for(ZKPicklistForRecordType *pickList in pickLists) {
                
                [picklistsForRecordTypeDict setObject:[pickList picklistName] forKey:@"picklistName"];
                
                NSArray *pickListValueArray = [pickList picklistValues];
                NSMutableArray *picklistValues = [NSMutableArray array];
                for(ZKPicklistEntry *pickListValue in pickListValueArray) {
                    NSMutableDictionary *pickListValueDict = [NSMutableDictionary dictionary];
                    [pickListValueDict setObject:([pickListValue active])?@"true":@"false" forKey:@"active"];
                    [pickListValueDict setObject:([pickListValue defaultValue])?@"true":@"false" forKey:@"defaultValue"];
                    [pickListValueDict setObject:[pickListValue label] forKey:@"label"];
                    [pickListValueDict setObject:[pickListValue value] forKey:@"value"];
                    [picklistValues addObject:pickListValueDict];
                }
                
                [picklistsForRecordTypeDict setObject:picklistValues forKey:@"picklistValues"];
            }
            
            [tempDict setObject:picklistsForRecordTypeDict forKey:@"picklistsForRecordType"];
            [recordTypeMappingsArray addObject:tempDict];
        }
        
        NSDictionary *recordTypeMappingsDict = [NSDictionary dictionaryWithObject:recordTypeMappingsArray forKey:@"recordTypeMappings"];
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:recordTypeMappingsDict options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSDictionary *recordDict = [NSDictionary dictionaryWithObjects:@[objectName, jsonString] forKeys:@[@"ObjectName", @"DescribeLayoutResult"]];
        CommonServices *service = [[CommonServices alloc] init];
        [service saveRecordFromDictionary:recordDict forFields:[recordDict allKeys] inTable:@"DescribeLayout"];
    }
}


@end
