//
//  CustomWebServiceParser.m
//  ServiceMaxiPad
//
//  Created by Apple on 23/06/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "CustomWebServiceParser.h"

@implementation CustomWebServiceParser
//- (id)init
//{
//    self = [super init];
//    if (self != nil)
//    {
//        //Initialization
//        
//    }
//    return self;
//}
- (ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel responseData:(id)responseData {
    @synchronized([self class]){
        @autoreleasepool {
            
//            if ([responseData isKindOfClass:[NSDictionary class]]) {
//                
//                [self fillDataArray];
//                
//                NSDictionary *response = (NSDictionary *)responseData;
//                
//                NSArray *records = [response objectForKey:kRecords];
//                
//                for (NSDictionary *eachDict in records) {
//                    [self updateUserDetailsForFeeds:eachDict];
//                }
//            }
//            [self updateChatterDataToCache];
//            [self updateChatterDetailsInToDataBase];
        }
    }
    return nil;
}
@end
