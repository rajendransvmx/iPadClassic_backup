//
//  Chatter_m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 19/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ChatterPost.h"
#import "DateUtil.h"

@implementation ChatterPost

- (id)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        
        if ([dict count] > 0) {
            
            self.cretedDate = [dict objectForKey:@"CreatedDate"];
            self.createdById = [dict objectForKey:@"CreatedById"];
            self.postId = [dict objectForKey:kId];
            
            [self getUserReadabeDateForCreatedDate];
        }
    }
    return self;
}

- (void)getUserReadabeDateForCreatedDate
{
    if ([self.cretedDate length] > 0) {
        self.createdDateString = [DateUtil getLiteralSupportedDateStringForChatterDate:
                                  [DateUtil getLocalTimeFromDateBaseDate:self.cretedDate]];
    }
}
@end
