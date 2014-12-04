//
//  BaseSFReferenceTo.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFReferenceToModel.m
 *  @class  SFReferenceToModel
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

#import "SFReferenceToModel.h"

@implementation SFReferenceToModel 

@synthesize localId;
@synthesize objectApiName;
@synthesize fieldApiName;
@synthesize reference_to;

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
	objectApiName = nil;
    fieldApiName = nil;
    reference_to = nil;
}


@end