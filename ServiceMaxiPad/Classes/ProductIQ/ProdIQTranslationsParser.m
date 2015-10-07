//
//  ProdIQTranslationsParser.m
//  ServiceMaxiPad
//
//  Created by Padmashree on 29/09/15.
//  Copyright © 2015 ServiceMax Inc. All rights reserved.
//

#import "ProdIQTranslationsParser.h"
#import "CommonServices.h"

@implementation ProdIQTranslationsParser

-(ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                     responseData:(id)responseData {
    @synchronized([self class]){
        @autoreleasepool {
            NSArray *responseArray = (NSArray *)responseData;
            [self insertProdIQTranslationsToDB:responseArray];
            return nil;
        }
    }
}

-(void)insertProdIQTranslationsToDB:(NSArray *)responseArray {
    CommonServices *service = [[CommonServices alloc] init];
    [service saveRecordsFromArray:responseArray inTable:@"Translations"];
}

@end
