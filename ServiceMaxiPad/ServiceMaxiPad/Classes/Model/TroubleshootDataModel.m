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
@synthesize Id;
@synthesize Keywords;
@synthesize Type;
@synthesize Name;

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
    Id = nil;
    Keywords = nil;
    Type = nil;
    Name = nil;
}


@end