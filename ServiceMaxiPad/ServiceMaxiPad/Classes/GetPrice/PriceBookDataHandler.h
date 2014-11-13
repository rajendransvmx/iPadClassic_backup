//
//  PriceBookDataHandler.h
//  ServiceMaxiPhone
//
//  Created by Shravya shridhar on 6/17/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 This is a  data controller  Class which handles "Price book" data containing pricebooks, pricebook entries,contract, warranties,pricing rules, policies .
 @author Shravya shridhar http://www.servicemax.com shravya.shridhar@servicemax.com
 */

@interface PriceBookDataHandler : NSObject

@property(nonatomic,retain)NSArray *priceBookInformation;

/**
 This method  instantiate PriceBookDataHandler
 @param targetDictionary  work order dictionary which is in the required format for javascript
 @returns object instance.
 */
- (id)initWithTargetDictionary:(NSDictionary *)targetDictionary;

@end
