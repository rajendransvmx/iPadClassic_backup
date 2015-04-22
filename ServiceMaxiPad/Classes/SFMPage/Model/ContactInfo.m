//
//  ContactInfo.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 11/03/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "ContactInfo.h"

@implementation ContactInfo


- (id)initWithDictionary:(NSDictionary *)dataDict
{
    self = [super init];
    
    if (self) {
        _contactNUmber = [dataDict objectForKey:@"MobilePhone"];
        _contactMail = [dataDict objectForKey:@"Email"];
    }
    return self;
}
@end
