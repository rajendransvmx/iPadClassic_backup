//
//  ServiceLocationModel.h
//  ServiceMaxMobile
//
//  Created by Anoop on 9/29/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "TransactionObjectModel.h"

@interface ServiceLocationModel : NSObject

@property(nonatomic, copy) NSString *street;
@property(nonatomic, copy) NSString *city;
@property(nonatomic, copy) NSString *state;
@property(nonatomic, copy) NSString *country;
@property(nonatomic, copy) NSString *zip;
@property(nonatomic, copy) NSString *serviceLocation;
@property(nonatomic, copy) NSString *latitude;
@property(nonatomic, copy) NSString *longitude;
@property(nonatomic, assign) CLLocationCoordinate2D latLonCoordinates;

- (id)initWithTransactionModel:(TransactionObjectModel*)transactionModel;
- (void)explainMe;
- (BOOL)isValidAddress;

@end
