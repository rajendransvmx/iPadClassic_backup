//
//  CalenderEventObjectModel.m
//  ServiceMaxMobile
//
//  Created by Sudguru Prasad on 07/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "CalenderEventObjectModel.h"

@implementation CalenderEventObjectModel

@synthesize Id;
@synthesize location;
@synthesize durationInMinutes;
@synthesize subject;
@synthesize activityDate;
@synthesize description;
@synthesize activityDateTime;
@synthesize startDateTime;
@synthesize endDateTime;
@synthesize ownerId;
@synthesize WhatId;
@synthesize localId;
@synthesize cWorkOrderSummaryModel;
@synthesize conflict;
@synthesize priority;
@synthesize sla;

-(void)explainMe
{
    SXLogInfo(@"Id: %@, location : %@, durationInMinutes: %@, subject : %@, activityDate: %@, description: %@, activityDateTime: %@, StartDateTime: %@, EndDateTime : %@, ownerId : %@, whatID :%@, localID : %@", Id, location, durationInMinutes, subject, activityDate, description, activityDateTime, startDateTime, endDateTime, ownerId, WhatId, localId);
}
@end
