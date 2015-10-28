//
//  RecordTypeParser.m
//  ServiceMaxMobile
//
//  Created by Krishna Shanbhag on 23/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "RecordTypeParser.h"
#import "ZKQueryResult.h"
#import "ZKSObject.h"
#import "StringUtil.h"
#import "FactoryDAO.h"
#import "SFRecordTypeDAO.h"
#import "SFRecordTypeModel.h"
#import "RequestConstants.h"
@implementation RecordTypeParser

//-(ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
//                                     responseData:(id)responseData {
//    @autoreleasepool {
//        ZKQueryResult *result = (ZKQueryResult *)responseData;
//        NSArray * resultArray = [result records];
//        NSMutableArray *recordTypeModelArray = [[NSMutableArray alloc] init];
//        if ([resultArray count] > 0)
//        {
//            for(int i = 0 ; i< [resultArray count]; i++)
//            {
//                ZKSObject * sobj = [resultArray objectAtIndex:i];
//                NSDictionary * fields = sobj.fields;
//                NSString * recordTypeId = [fields objectForKey:kId];
//                NSString * recordTypeName = [fields objectForKey:kName];
//                
//                
//                if (recordTypeId != nil && recordTypeName != nil && [StringUtil isStringNotNULL:recordTypeName]) {
//                    
//                    SFRecordTypeModel *recordType = [[SFRecordTypeModel alloc] init];
//                    recordType.recordTypeId = recordTypeId;
//                    recordType.recordType = recordTypeName;
//                    [recordTypeModelArray addObject:recordType];
//
//                }
//            }
//            id daoService = [FactoryDAO serviceByServiceType:ServiceTypeSFRecordType];
//            
//            if ([daoService conformsToProtocol:@protocol(SFRecordTypeDAO)]) {
//                [daoService updateRecordTypeLabels:recordTypeModelArray];
//            }
//
//        }
//    }
//    return nil;
//
//}

-(ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                     responseData:(id)responseData {
    
    if (![responseData isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    
    @autoreleasepool {
        NSDictionary *result = (NSDictionary *)responseData;
        NSArray * tempResultArray = [result objectForKey:@"valueMap"];
        NSMutableArray *recordTypeModelArray = [[NSMutableArray alloc] init];
        NSArray *resultArray;
        
        if([tempResultArray count]>0)
        {
            NSDictionary *dict = [tempResultArray objectAtIndex:0];
            NSString *jsonString = [dict objectForKey:@"value"];
            
            NSError *jsonError;
            NSData *objectData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            resultArray = [NSJSONSerialization JSONObjectWithData:objectData
                                                          options:NSJSONReadingMutableContainers
                                                            error:&jsonError];
            
        }
        
        for (NSDictionary *dict in resultArray)
        {
            NSString * recordTypeId = [dict objectForKey:kId];
            NSString * recordTypeName = [dict objectForKey:kName];
            
            
            if (![StringUtil isStringEmpty:recordTypeId] && ![StringUtil isStringEmpty:recordTypeName]) {
                
                SFRecordTypeModel *recordType = [[SFRecordTypeModel alloc] init];
                recordType.recordTypeId = recordTypeId;
                recordType.recordType = recordTypeName;
                [recordTypeModelArray addObject:recordType];
                
            }
            
        }
        if([recordTypeModelArray count ]> 0)
        {
            id daoService = [FactoryDAO serviceByServiceType:ServiceTypeSFRecordType];
            
            if ([daoService conformsToProtocol:@protocol(SFRecordTypeDAO)]) {
                [daoService updateRecordTypeLabels:recordTypeModelArray];
            }
            
        }
        
    }
    return nil;
    
}

@end
