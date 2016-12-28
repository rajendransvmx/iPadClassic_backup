//
//  PriceBookDataHandler.h
//  ServiceMaxiPhone
//
//  Created by Shravya shridhar on 6/17/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>

// PS Entitlements

NSString * const kLineWarrantyEntitled;
NSString * const kLineContractEntitled;
NSString * const kLineContractDefinition;
NSString * const kLinePartsPricing;
NSString * const kLinePartsDiscount;
NSString * const kLineLaborPricing;
NSString * const kLineExpensePricing;
NSString * const kLinePartPriceBook;
NSString * const kLineLaborPriceBook;
NSString * const kLineIBWarranty;

/**
 This is a  data controller  Class which handles "Price book" data containing pricebooks, pricebook entries,contract, warranties,pricing rules, policies .
 @author Shravya shridhar http://www.servicemax.com shravya.shridhar@servicemax.com
 */

@interface PriceBookDataHandler : NSObject

@property(nonatomic,strong)NSArray *priceBookInformation;

/**
 This method  instantiate PriceBookDataHandler
 @param targetDictionary  work order dictionary which is in the required format for javascript
 @returns object instance.
 */
- (id)initWithTargetDictionary:(NSDictionary *)targetDictionary;

@end
