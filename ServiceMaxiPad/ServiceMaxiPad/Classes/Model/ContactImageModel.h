//
//  ContactImageModel.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 21/05/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

/**
 *  @file   ContactImageModel.h
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

#import <Foundation/Foundation.h>
#import "TransactionObjectModel.h"

@interface ContactImageModel : NSObject

@property(nonatomic, copy) NSString *contactId;
@property(nonatomic, copy) NSString *contactName;
@property(nonatomic, copy) NSString *contactImage;
@property(nonatomic, copy) NSString *emailString;
@property(nonatomic, copy) NSString *phoneString;
@property(nonatomic, copy) NSString *mobilePhoneString;

- (id)init;
- (id)initWithTransactionModel:(TransactionObjectModel*)transactionModel;
- (void)explainMe;

@end
