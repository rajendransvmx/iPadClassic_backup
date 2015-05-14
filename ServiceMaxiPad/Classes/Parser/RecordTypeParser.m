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
        NSArray * resultArray = [result objectForKey:@"records"];
        NSMutableArray *recordTypeModelArray = [[NSMutableArray alloc] init];
        if ([resultArray count] > 0)
        {
            for(int i = 0 ; i< [resultArray count]; i++)
            {
                NSDictionary * sobj = [resultArray objectAtIndex:i];
                NSString * recordTypeId = [sobj objectForKey:kId];
                NSString * recordTypeName = [sobj objectForKey:kName];
                
                
                if (recordTypeId != nil && recordTypeName != nil && [StringUtil isStringNotNULL:recordTypeName]) {
                    
                    SFRecordTypeModel *recordType = [[SFRecordTypeModel alloc] init];
                    recordType.recordTypeId = recordTypeId;
                    recordType.recordType = recordTypeName;
                    [recordTypeModelArray addObject:recordType];
                    
                }
            }
            id daoService = [FactoryDAO serviceByServiceType:ServiceTypeSFRecordType];
            
            if ([daoService conformsToProtocol:@protocol(SFRecordTypeDAO)]) {
                [daoService updateRecordTypeLabels:recordTypeModelArray];
            }
            
        }
    }
    return nil;
    
}

@end