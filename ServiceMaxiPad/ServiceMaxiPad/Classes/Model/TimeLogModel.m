//
//  TimeLogModel.m
//  ServiceMaxiPad
//
//  Created by Krishna Shanbhag on 29/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "TimeLogModel.h"

@implementation TimeLogModel

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        //Initialization
    }
    return self;
}


- (void)explainMe
{
    SXLogInfo(@"timeLogId : %@ \n timeLogvalue : %@ \n  timeT1 : %@ \n timeT4 : %@ \n timeT5 %@ syncstatus %@", self.timeLogIdKey,self.timeLogIdvalue,self.timeT1,self.timeT4,self.timeT5,self.syncRequestStatus);
}

@end
