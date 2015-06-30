//
//  MobileUsageDataModel.h
//  ServiceMaxiPad
//
//  Created by Madhusudhan.HK on 6/24/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MobileUsageDataModel : NSObject

@property (nonatomic, strong) NSString *uniqId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *type;

- (id)init;
- (void)explainMe;

+ (NSDictionary*)getMobileUageDetails;

@end
