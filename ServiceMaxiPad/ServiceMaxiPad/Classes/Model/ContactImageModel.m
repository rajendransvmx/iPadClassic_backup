//
//  ContactImageModel.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 21/05/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

/**
 *  @file   ContactImageModel.m
 *  @class  ContactImageModel
 *
 *  @brief This model holds the contact image model details
 *
 *   -- Create ContactImageModel
 *   -- Use this model whenever we need store inforamtion of contact image
 *
 *  @author Shubha S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "ContactImageModel.h"
#import "DatabaseConstant.h"
@implementation ContactImageModel

- (id)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

- (id)initWithTransactionModel:(TransactionObjectModel*)transactionModel {
    
    self = [super init];
    if (self)
    {
        _contactId = [transactionModel valueForField:kId];
        _contactImage = @"";
        _contactName = [transactionModel valueForField:kContactName];
        _emailString = [transactionModel valueForField:kContactEmail];
        _phoneString = [transactionModel valueForField:kContactPhone];
        _mobilePhoneString = [transactionModel valueForField:kContactMobilePhone];
    }
    return self;
}

- (void)dealloc
{
    _contactId = nil;
    _contactName = nil;
    _contactImage = nil;
    _emailString = nil;
    _phoneString = nil;
}

- (void)explainMe
{
    NSLog(@"contactId : %@ \n contactName : %@ \n contactImage : %@ \n emailString : %@ \n phoneString : %@",_contactId, _contactName, _contactImage, _emailString, _phoneString);
}

@end
