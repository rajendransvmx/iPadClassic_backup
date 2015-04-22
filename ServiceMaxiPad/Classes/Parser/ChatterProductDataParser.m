//
//  ProductImageParser.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 19/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ChatterProductDataParser.h"
#import "ChatterHelper.h"
#import "NonTagConstant.h"
#import "ChatterManager.h"
#import "ProductImageDataModel.h"

@implementation ChatterProductDataParser
- (ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel responseData:(id)responseData {
    @synchronized([self class]){
        @autoreleasepool {
            
            if ([responseData isKindOfClass:[NSDictionary class]]) {
                
                NSDictionary *response = (NSDictionary *)responseData;
                
                NSArray *records  = [response objectForKey:kRecords];
                
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

- (void)saveAttachmentIdInCache:(NSString *)attachmentId
{
    NSString *productId =  [[ChatterManager sharedInstance] getProductId];
    
    if ([ChatterHelper deleteRecordFromProductImage:productId]) {
        ProductImageDataModel *model = [[ProductImageDataModel alloc] init];
        model.productId = productId;
        model.productImageId = attachmentId;
        [ChatterHelper saveProductAttachmentId:model];
    }
    [ChatterHelper pushDataToCahcche:attachmentId forKey:kChatterAttachmentId];
}

@end
