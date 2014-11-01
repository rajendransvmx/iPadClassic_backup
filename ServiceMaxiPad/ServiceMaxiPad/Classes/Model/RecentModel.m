//
//  RecentModel.m
//  ServiceMaxiPad
//
//  Created by Shubha S on 30/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "RecentModel.h"

@implementation RecentModel
- (id)init
{
	self = [super init];
	if (self != nil)
    {
		//Initialization
	}
	return self;
}

- (id)initWithObjectName:(NSString *)objName andRecordId:(NSString *)recordId {
    self = [super init];
	if (self != nil)
    {
        self.objectName = objName;
        self.localId = recordId;
		//Initialization
	}
	return self;
}

- (void)dealloc
{
    self.objectName = nil;
	self.localId = nil;
	self.createdDate = nil;
    self.nameFieldValue = nil;
}

@end
