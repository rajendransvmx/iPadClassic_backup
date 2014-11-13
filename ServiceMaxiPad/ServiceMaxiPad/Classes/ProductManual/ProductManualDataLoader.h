//
//  ProductManualDataLoader.h
//  ServiceMaxiPad
//
//  Created by Chinnababu on 06/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductManualDataLoader : NSObject

+ (void)makingRequestForDetailsByProductId:(NSString *)productID
                     withTheCallerDelegate:(id)delegate;
+ (void)makingRequestForProductManualBodyWithTheDelegate:(id)delegate;


@end
