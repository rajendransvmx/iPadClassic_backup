//
//  GetPriceCodeSnippetParser.m
//  ServiceMaxMobile
//
//  Created by Pushpak on 27/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "GetPriceCodeSnippetParser.h"
#import "StringUtil.h"
#import "TransactionObjectModel.h"
#import "TXFetchHelper.h"

@implementation GetPriceCodeSnippetParser
-(ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                     responseData:(id)responseData {
    
    @autoreleasepool {
        
        if (![responseData isKindOfClass:[NSDictionary class]]) {
            return nil;
        }
        
        NSArray *allValueMaps = [responseData objectForKey:kSVMXRequestSVMXMap];
        if ([allValueMaps count] > 0) {
            
            NSMutableDictionary *objectDictionary = [[NSMutableDictionary alloc] init];
            
            for (int counter = 0; counter < [allValueMaps count]; counter++) {
                
                NSDictionary *eachDictionary = [allValueMaps objectAtIndex:counter];
                NSString *jsonStrin =  [eachDictionary objectForKey:kSVMXRequestValue];
                if ([jsonStrin isKindOfClass:[NSString class]]) {
                    NSDictionary *snippetDictionary = [NSJSONSerialization JSONObjectWithData:[jsonStrin dataUsingEncoding:NSUTF8StringEncoding]
                                                                                      options:0
                                                                                        error:NULL];
                    NSDictionary *attributes =  [snippetDictionary objectForKey:@"attributes"];
                    NSString *objectName = [attributes objectForKey:@"type"];
                    
                    
                    if (![StringUtil isStringEmpty:objectName]) {
                        
                        /* If type is of manifest , insert it into manifest table  */
                        NSMutableArray *records =  [objectDictionary objectForKey:objectName];
                        if (records == nil) {
                            records = [[NSMutableArray alloc] init];
                            [objectDictionary setObject:records forKey:objectName];
                        }
                        TransactionObjectModel *model = [[TransactionObjectModel alloc]initWithObjectApiName:objectName];
                        [model mergeFieldValueDictionaryForFields:snippetDictionary];
                        [records addObject:model];
                    }
                }
            }
            
            /* Insert into db service */
            if ([objectDictionary count] > 0) {
                
                TXFetchHelper *txFetchHelper = [[TXFetchHelper alloc]init];
                for (NSString *anOjectName in [objectDictionary allKeys]) {
                    
                    NSArray *objectRecords = [objectDictionary objectForKey:anOjectName];
                    BOOL insertStatus = [txFetchHelper insertObjects:objectRecords withObjectName:anOjectName];
                    if (insertStatus) {
                        SXLogInfo(@"Successfully inserted into = %@ from GetPriceCodeSnippetParser.",anOjectName);
                    }
                    
                }
                
            }
            
        }
        
    }

    
    return nil;
}
@end

