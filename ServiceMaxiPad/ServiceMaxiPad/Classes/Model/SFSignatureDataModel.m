//
//  BaseSFSignatureData.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFSignatureDataModel.m
 *  @class  SFSignatureDataModel
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

#import "SFSignatureDataModel.h"

@implementation SFSignatureDataModel 

@synthesize recordId;
@synthesize objectApiName;
@synthesize signatureData;
@synthesize sigId;
@synthesize WorkOrderNumber;
@synthesize signType;
@synthesize operationType;
@synthesize signatureTypeId;
@synthesize signatureName;

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
    recordId = nil;
    objectApiName = nil;
    signatureData = nil;
    sigId = nil;
    WorkOrderNumber = nil;
    signType = nil;
    operationType = nil;
    signatureTypeId = nil;
    signatureName = nil;
}


@end