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
    
    _body = nil;
    _createdById = nil;
    _createdDate = nil;
    _postType = nil;
	_userName = nil;
    _email = nil;
    _feedItemId = nil;
    _fullPhotoUrl = nil;
}

- (void)explainMe
{
    SXLogInfo(@"ChatterPost Body : %@ \n createdById : %@ \n createdDate : %@ \n  postType : %@ \n userName : %@ \n email : %@ \n  feedPostId : %@ \n fullPhotoUrl : %@ \n",  self.body ,self.createdById, self.createdDate, self.postType,
              self.userName, self.email,self.feedItemId, self.fullPhotoUrl);
}



@end