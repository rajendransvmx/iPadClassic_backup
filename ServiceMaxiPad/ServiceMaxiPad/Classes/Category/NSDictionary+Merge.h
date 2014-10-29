//
//  NSDictionary+Merge.h
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 22/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Merge)

- (NSDictionary *)dictionaryByMergingWithDictionary:(NSDictionary *)dictionary;

@end
