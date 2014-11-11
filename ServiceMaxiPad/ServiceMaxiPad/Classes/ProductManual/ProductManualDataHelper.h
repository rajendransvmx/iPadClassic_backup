//
//  ProductManualDataHelper.h
//  ServiceMaxiPad
//
//  Created by Chinnababu on 06/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductManualDataHelper : NSObject

+ (NSArray *)fetchProductDetailsbyProductID:(NSString *)productId;

@end
