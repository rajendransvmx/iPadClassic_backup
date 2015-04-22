//
//  ContactInfo.h
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 11/03/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactInfo : NSObject

@property(nonatomic, strong) NSString *contactNUmber;
@property(nonatomic, strong) NSString *contactMail;
@property(nonatomic, strong) NSString *contactId;


- (id)initWithDictionary:(NSDictionary *)dataDict;

@end
