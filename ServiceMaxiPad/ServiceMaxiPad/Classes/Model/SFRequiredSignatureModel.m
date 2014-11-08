//
//  BaseSFRequiredSignature.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import "SFRequiredSignatureModel.h"

@implementation SFRequiredSignatureModel 

@synthesize signId;
@synthesize signatureId;

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
    signId = nil;
	signatureId = nil;
}


@end