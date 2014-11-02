//
//  BaseTrobleshootdata.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   TrobleshootdataModel.m
 *  @class  TrobleshootdataModel
 *
 *  @brief
 *
 *   This is a modle class which holds all the info.
 *
 *  @author Shubha S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "TroubleshootDataModel.h"

@implementation TroubleshootDataModel 

@synthesize localId;
@synthesize ProductId;
@synthesize ProductName;
@synthesize Product_Doc;
@synthesize DocId;
@synthesize prod_manualId;
@synthesize prod_manualName;
@synthesize productmanbody;

- (id)init
{
	self = [super init];
	if (self != nil)
    {
		//Initialization
	}
	return self;
}

- (void)dealloc
{
    ProductId = nil;
    ProductName = nil;
	Product_Doc = nil;
    DocId = nil;
    prod_manualId = nil;
    prod_manualName = nil;
    productmanbody = nil;
}


@end