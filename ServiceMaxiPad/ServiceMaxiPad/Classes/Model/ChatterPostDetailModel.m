//
//  BaseChatterPostDetails.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//


/**
 *  @file   ChatterPostDetailModel.m
 *  @class  ChatterPostDetailModel
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

#import "ChatterPostDetailModel.h"

@implementation ChatterPostDetailModel 

@synthesize localId;
@synthesize Body;
@synthesize createdById;
@synthesize createdDate;
@synthesize chatterPostDetailId;
@synthesize postType;
@synthesize userName;
@synthesize email;
@synthesize feedPostId;
@synthesize fullPhotoUrl;

- (id)init
{
	self = [super init];
	if (self != nil)
    {
		//Initialization
	}
	return self;
}

- (void)dealloc {
    
    Body = nil;
    createdById = nil;
    createdDate = nil;
    chatterPostDetailId = nil;
    postType = nil;
	userName = nil;
    email = nil;
    feedPostId = nil;
    fullPhotoUrl = nil;
}

- (void)explainMe
{
    NSLog(@"Body : %@ \n createdById : %@ \n createdDate : %@ \n chatterPostDetailId : %@ \n  postType : %@ \n userName : %@ \n email : %@ \n  feedPostId : %@ \n fullPhotoUrl : %@ \n",  Body,createdById, createdDate, chatterPostDetailId,postType,userName,email,feedPostId,fullPhotoUrl);
}



@end