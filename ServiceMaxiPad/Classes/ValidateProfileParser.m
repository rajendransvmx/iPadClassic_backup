//
//  ValidateProfileParser.m
//  ServiceMaxiPad
//
//  Created by Padmashree on 11/15/16.
//  Copyright © 2016 ServiceMax Inc. All rights reserved.
//

#import "ValidateProfileParser.h"

@implementation ValidateProfileParser

-(ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel responseData:(id)responseData {
    
    @autoreleasepool {
        if ([responseData isKindOfClass:[NSDictionary class]]) {
            NSArray *valueMaps = [responseData objectForKey:kSVMXRequestSVMXMap];
            if ([valueMaps count] > 0) {
                
            }
        }
        
    }
    
    return nil;
}

@end
