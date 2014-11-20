//
//  SyncProgressDetailModel.m
//  ServiceMaxiPhone
//
//  Created by Radha Sathyamurthy on 28/06/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "SyncProgressDetailModel.h"

@implementation SyncProgressDetailModel

@synthesize message;
@synthesize progress;
@synthesize currentStep;

- (id)initWithProgressData:(NSDictionary *)dict
{
    self = [super init];
    
    if (self != nil)
    {
        if (dict != nil)
        {
            self.currentStep = [dict objectForKey:@"currentStep"];
            self.message  = [dict objectForKey:@"SyncStatusMsg"];
            self.progress = [dict objectForKey:@"SyncProgress"];
        }
    }
    return self;
}

- (id)initWithProgress:(NSString *)progressValue currentStep:(NSString *)step
               message:(NSString *)description totalSteps:(NSString *)totalSteps syncStatus:(SyncStatus)status
{
    self = [super init];
    
    if (self != nil)
    {
        self.currentStep = step;
        self.message  = description;
        self.progress = progressValue;
        self.numberOfSteps = totalSteps;
        self.syncStatus = status;
    }
    return self;
}

- (void)dealloc
{
    message = nil;
    progress = nil;
    currentStep = nil;
}

@end
