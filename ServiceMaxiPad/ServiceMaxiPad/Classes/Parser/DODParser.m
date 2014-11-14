//
//  DODParser.m
//  ServiceMaxiPad
//
//  Created by Himanshi Sharma on 12/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "DODParser.h"
#import "DODHelper.h"
#import "TXFetchHelper.h"
#import "StringUtil.h"
#import "TransactionObjectModel.h"
#import "OnDemandDownloadModel.h"

@interface DODParser ()

@property(nonatomic, strong) TXFetchHelper *helper;

@end

@implementation DODParser

-(ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                     responseData:(id)responseData {
 
    @synchronized([self class]) {
        
        if ([responseData isKindOfClass:[NSDictionary class]]) {
            
            self.helper = [[TXFetchHelper alloc] initWithCheckForDuplicateRecords:NO];
            
            NSDictionary *response = (NSDictionary *)responseData;
            
            NSArray *valueMap = [response objectForKey:kSVMXSVMXMap];
            
            for (NSDictionary *map in valueMap) {
                
                NSMutableArray *objectrecords = [[NSMutableArray alloc] init];
                
                NSString *objectName = [map objectForKey:kSVMXValue];
                
                if ([StringUtil isStringEmpty:objectName]) {
                    continue;
                }
                NSArray *mapArray = [map objectForKey:kSVMXSVMXMap];
                
                for (NSDictionary *recordDict in mapArray) {
                    
                    NSString *key = [recordDict objectForKey:kSVMXKey];
                    
                    if ([key isEqualToString:@"PRICING_DATA"]) {
                        NSArray *getPriceData = [recordDict objectForKey:kSVMXSVMXMap];
                        
                        for (NSDictionary *priceData in getPriceData) {
                            NSMutableArray *priceDataobjectrecords = [[NSMutableArray alloc] init];
                            
                            NSString *objectName = [priceData objectForKey:kSVMXKey];
                            
                            if ([StringUtil isStringEmpty:objectName]) {
                                continue;
                            }
                            NSArray *values = [priceData objectForKey:kSVMXSVMXMap];
                            
                            for (NSDictionary *valueDict in values) {
                                NSString *jsonStr = [valueDict objectForKey:kSVMXValue];
                                TransactionObjectModel *model = [self getTxnObjectForJsonString:jsonStr objectName:objectName];
                                [priceDataobjectrecords addObject:model];
                            }
                            if ([priceDataobjectrecords count] > 0) {
                                [self.helper insertObjects:priceDataobjectrecords withObjectName:objectName];
                                [priceDataobjectrecords removeAllObjects];
                            }
                        }
                    }
                    else {
                        NSString *jsonStr = [recordDict objectForKey:kSVMXValue];
                        TransactionObjectModel *model = [self getTxnObjectForJsonString:jsonStr objectName:objectName];
                        [objectrecords addObject:model];
                    }
                }
                if ([objectrecords count] > 0) {
                    [self.helper insertObjects:objectrecords withObjectName:objectName];
                    [objectrecords removeAllObjects];
                }
            }
        }
    }
    return nil;
}

- (TransactionObjectModel *)getTxnObjectForJsonString:(NSString *)jsonString objectName:(NSString *)objectName
{
    NSData *recordData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:recordData options:NSJSONReadingMutableContainers error:&e];

    TransactionObjectModel *model = [[TransactionObjectModel alloc] initWithObjectApiName:objectName];
    [model setFieldValueDictionaryForFields:jsonDict];
    
    return model;
}

- (void)insertRecordIntoDODTable:(OnDemandDownloadModel *)model
{
    
}
@end
