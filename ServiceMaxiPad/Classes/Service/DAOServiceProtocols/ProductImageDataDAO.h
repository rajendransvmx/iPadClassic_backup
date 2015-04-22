//
//  ProductImageDataDAO.h
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 08/01/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonServiceDAO.h"
#import "ProductImageDataModel.h"

@protocol ProductImageDataDAO <CommonServiceDAO>

- (BOOL)deleteRecord:(id)criteria;

@end
