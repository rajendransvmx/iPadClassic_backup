//
//  BaseProductImage.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   ProductImageModel.h
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


@interface ProductImageModel : NSObject

@property(nonatomic) NSInteger localId;

@property(nonatomic, strong) NSString *productId;
@property(nonatomic, strong) NSString *productImage;

- (id)init;

- (void)explainMe;

@end