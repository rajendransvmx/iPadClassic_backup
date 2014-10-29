//
//  SMXEvent.m
/**
 *  @file   FILE_NAME.m
 *  @class  CLASS_NAME
 *
 *  @brief  This class will provide .....
 *
 *
 *
 *  @author  AUTHOR_NAME
 *
 *  @bug     No known bugs
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "SMXEvent.h"

@implementation SMXEvent

@synthesize stringCustomerName;
@synthesize numCustomerID;
@synthesize ActivityDateDay;
@synthesize dateTimeBegin;
@synthesize dateTimeEnd;
@synthesize arrayWithGuests;
@synthesize cWorkOrderSummaryModel;
@synthesize description;
@synthesize IDString;
@synthesize localID;
@synthesize billingType;

-(void)explainMe;
{
    NSLog(@"IDString: %@, localID : %@, dateTimeBegin: %@ , dateTimeEnd : %@ billingType :%@", IDString, localID, dateTimeBegin, dateTimeEnd, billingType);
}

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] init];
    
    if (copy)
    {
        
    }
    
    return copy;
}
@end
