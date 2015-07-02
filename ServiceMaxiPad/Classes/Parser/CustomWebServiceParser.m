//
//  CustomWebServiceParser.m
//  ServiceMaxiPad
//
//  Created by Apple on 23/06/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "CustomWebServiceParser.h"
#import "DODHelper.h"
#import "TXFetchHelper.h"
#import "StringUtil.h"
#import "TransactionObjectModel.h"
#import "DODRecordsModel.h"
#import "DODRecordsDAO.h"
#import "FactoryDAO.h"
#import "DateUtil.h"
#import "Utility.h"

@interface CustomWebServiceParser ()

@property(nonatomic, strong) TXFetchHelper *helper;

@end

@implementation CustomWebServiceParser


-(ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                     responseData:(id)responseData {
    
    @synchronized([self class]) {
        if ([responseData isKindOfClass:[NSDictionary class]]) {
            self.helper = [[TXFetchHelper alloc] initWithCheckForDuplicateRecords:YES];
            NSDictionary *response = [NSDictionary dictionaryWithDictionary:responseData];
            NSArray *valueMap = [response objectForKey:kSVMXSVMXMap];
            if ([valueMap isKindOfClass:[NSArray class]])
            {
                
                for (NSDictionary *recordDict in valueMap)
                {
                    NSMutableArray *objectrecords = [[NSMutableArray alloc] initWithCapacity:0];
                    NSString *objectName = nil;
                    objectName = [recordDict objectForKey:kSVMXKey];
                    id str = [recordDict objectForKey:kSVMXValue];
                    NSMutableArray *dataArray = [Utility objectFromJsonString:str];
                    if ([dataArray isKindOfClass:[NSArray class]])
                    {
                        for (NSDictionary *dict in dataArray)
                        {
                            TransactionObjectModel *model = [[TransactionObjectModel alloc] initWithObjectApiName:objectName];
                            [model setFieldValueDictionaryForFields:dict];
                            [objectrecords addObject:model];
                        }
                    }
                    else{
                        //Here its structure problem, Its not a array
                    }
                    [self.helper insertObjects:objectrecords withObjectName:objectName];
                }
            }
            else
            {
                //Here its structure problem, Its not a array
            }
        }
    }
    return nil;
}

@end
