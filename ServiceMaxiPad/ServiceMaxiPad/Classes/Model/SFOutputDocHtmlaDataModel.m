//
//  BaseSFOPDocHtmlData.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFOutputDocHtmlaDataModel.m
 *  @class  SFOutputDocHtmlaDataModel
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

#import "SFOutputDocHtmlaDataModel.h"

@implementation SFOutputDocHtmlaDataModel 

@synthesize localId;
@synthesize objectApiName;
@synthesize opdocData;
@synthesize sfId;
@synthesize WorkOrderNumber;
@synthesize docName;
@synthesize processId;

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
    localId = nil;
    objectApiName = nil;
    opdocData = nil;
    sfId = nil;
    WorkOrderNumber = nil;
    docName = nil;
    processId = nil;
}


@end