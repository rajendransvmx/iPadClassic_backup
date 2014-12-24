//
//  BaseProductImage.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   ProductImageModel.m
 *  @class  ProductImageModel
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

#import "ProductImageModel.h"

@implementation ProductImageModel 

@synthesize localId;
@synthesize productId;
@synthesize productImage;

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
    productId = nil;
    productImage = nil;
}

- (void)explainMe
{
    SXLogInfo(@"productId : %@ \n productImage : %@ \n ",  productId,productImage);
}

@end