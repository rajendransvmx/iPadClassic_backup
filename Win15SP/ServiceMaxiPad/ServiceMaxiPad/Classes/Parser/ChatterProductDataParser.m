//
//  ProductImageParser.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 19/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ChatterProductDataParser.h"
#import "ChatterHelper.h"

@implementation ChatterProductDataParser
- (ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel responseData:(id)responseData {
    @synchronized([self class]){
        @autoreleasepool {
            
            if ([responseData isKindOfClass:[NSDictionary class]]) {
                
                NSDictionary *response = (NSDictionary *)responseData;
                
                NSArray *records  = [response objectForKey:@"records"];
                
                if ([records count] > 0) {
                    
                    NSDictionary *dataDict = [records objectAtIndex:0];
                    if ([dataDict objectForKey:kId]) {
                        [self saveAttachmentIdInCache:[dataDict objectForKey:kId]];
                    }
                }
            }
        }
    }
    return nil;
}

- (void)saveAttachmentIdInCache:(NSString *)attachemnrId
{
    [ChatterHelper pushDataToCahcche:attachemnrId forKey:@"ChatterAttachmentId"];
}

@end
