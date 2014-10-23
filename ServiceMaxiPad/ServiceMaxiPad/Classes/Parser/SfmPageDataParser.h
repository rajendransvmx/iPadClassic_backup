//
//  SfmPageDataParser.h
//  ServiceMaxiPhone
//
//  Created by Sahana on 30/01/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebServiceParser.h"

/*
 This class create parser for SFM Page Data and insert all the SFM Page Data in Data structures
 @author Sahana http://www.servicemax.com
 */

@interface SfmPageDataParser : WebServiceParser
@property(nonatomic, strong) NSMutableDictionary * referenceObjects;
@property(nonatomic, strong) NSMutableDictionary * recordTypeObjects;
@end
