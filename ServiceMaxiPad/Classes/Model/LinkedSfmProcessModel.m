//
//  BaseLINKED_SFMProcess.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   LinkedSfmProcessModel.m
 *  @class  LinkedSfmProcessModel
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


#import "LinkedSfmProcessModel.h"

@implementation LinkedSfmProcessModel 

@synthesize Id;
@synthesize sourceHeader;
@synthesize sourceDetail;
@synthesize targetHeader;

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
	sourceHeader = nil;
	sourceDetail = nil;
	targetHeader = nil;
}

- (void)explainMe
{
    SXLogInfo(@"Id : %@ \n sourceHeader : %@ \n sourceDetail : %@ \n targetHeader : %@ \n  ",  Id,sourceHeader, sourceDetail, targetHeader);
}


+ (NSDictionary*)getMappingDictionary {
    
    NSDictionary *mapDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   kLinkefSfmId, kId,
                                   kLinkedSfmProcess1, kLinkedSfmSourceHeaderId,
                                   kLinkedSfmProcess2, kLinkedSfmSourceDetailId,
                                   kLinkedSfmProcess3, kLinkedSfmTargetHeaderId, nil];
    return mapDictionary;
}


@end