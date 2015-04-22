//
//  BaseProductImage.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   ProductImageDataModel.m
 *  @class  ProductImageDataModel
 *
 *  @brief
 *
 *   This is a modle class which holds all the info.
 *
 *  @author Shubha S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "ProductImageDataModel.h"

@implementation ProductImageDataModel 

- (id)init
{
	self = [super init];
	if (self != nil)
    {
		//Initialization
	}
	return self;
}

- (void)dealloc
{
    _productId = nil;
    _productImageId = nil;
}

- (void)explainMe
{
    SXLogInfo(@"productId : %@ \n productImage : %@ \n ",  self.productId, self.productImageId);
}

@end