//
//  SFMPageHistoryInfo.m
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 16/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFMPageHistoryInfo.h"
#import "DateUtil.h"

@implementation SFMPageHistoryInfo

-(id)initWithDictionary:(NSDictionary *)dataDict
{
    if (self = [super init]) {
        _title = [dataDict objectForKey:@""];
        _problemDescription = [dataDict objectForKey:kWorkOrderProblemDescription];
        _createdDate = [dataDict objectForKey:@"CreatedDate"];
    }
    return self;
}

- (void)updateCreatedDateToUserRedableFormat
{
    NSString *dateString = [DateUtil getUserReadableDateForDateBaseDate:self.createdDate];
    
    if ([dateString length] > 0) {
        self.createdDate = dateString;
    }
}

@end
