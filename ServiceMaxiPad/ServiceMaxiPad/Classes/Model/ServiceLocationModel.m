//
//  ServiceLocationModel.m
//  ServiceMaxMobile
//
//  Created by Anoop on 9/29/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "ServiceLocationModel.h"
#import "DatabaseConstant.h"

@implementation ServiceLocationModel

- (id)initWithTransactionModel:(TransactionObjectModel*)transactionModel {
    
    self = [super init];
    if (self)
    {
        self.street            = [transactionModel valueForField:kWorkOrderSTREET];
        self.city              = [transactionModel valueForField:kWorkOrderCITY];
        self.state             = [transactionModel valueForField:kWorkOrderSTATE];
        self.country           = [transactionModel valueForField:kWorkOrderCOUNTRY];
        self.zip               = [transactionModel valueForField:kWorkOrderZIP];
        self.serviceLocation   = [self serviceLocationAddress];
        self.latitude          = [transactionModel valueForField:kWorkOrderLatitude];
        self.longitude         = [transactionModel valueForField:kWorkOrderLongitude];
        self.latLonCoordinates = CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
    }
    return self;
}

- (id)initWithAddressDictionary:(NSDictionary*)dictionary {
    
    self = [super init];
    if (self)
    {
        self.street            = [dictionary objectForKey:kWorkOrderSTREET];
        self.city              = [dictionary objectForKey:kWorkOrderCITY];
        self.state             = [dictionary objectForKey:kWorkOrderSTATE];
        self.country           = [dictionary objectForKey:kWorkOrderCOUNTRY];
        self.zip               = [dictionary objectForKey:kWorkOrderZIP];
        self.serviceLocation   = [self serviceLocationAddress];
        self.latitude          = [dictionary objectForKey:kWorkOrderLatitude];
        self.longitude         = [dictionary objectForKey:kWorkOrderLongitude];
        self.latLonCoordinates = CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
    }
    return self;
    
}
- (NSMutableString*)serviceLocationAddress {
    
    NSMutableString *address = [[NSMutableString alloc] initWithCapacity:0];
    
    if ([self.street length])
        [address appendString:self.street];
    
    if ([self.city length])
    {
        if ([address length])
            [address appendString:[NSString stringWithFormat:@", %@", self.city]];
        else
            [address appendString:[NSString stringWithFormat:@"%@", self.city]];
    }
    
    if ([self.state length])
    {
        if ([address length])
            [address appendString:[NSString stringWithFormat:@", %@", self.state]];
        else
            [address appendString:[NSString stringWithFormat:@"%@", self.state]];
    }
    
    if ([self.zip length])
    {
        if ([address length])
            [address appendString:[NSString stringWithFormat:@", %@", self.zip]];
        else
            [address appendString:[NSString stringWithFormat:@"%@", self.zip]];
    }
    
    if ([self.country length])
    {
        if ([self.country length])
            [address appendString:[NSString stringWithFormat:@", %@", self.country]];
        else
            [address appendString:[NSString stringWithFormat:@"%@", self.country]];
    }

    return address;
}

- (BOOL)isValidAddress {
    
    return [self.serviceLocation length];
}

- (void)explainMe
{
    NSLog(@"street : %@ \n city : %@ \n state : %@ \n  zip : %@ \n serviceLocation : %@ \n latitude : %@ \n longitude : %@", _street, _city, _state, _zip,_serviceLocation, _latitude, _longitude);
}

@end
