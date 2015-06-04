//
//  SMXProductListModel.m
//  ServiceMaxiPad
//
//  Created by Apple on 02/06/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "SMXProductListModel.h"

@implementation SMXProductListModel
@synthesize productId;
@synthesize count;
@synthesize displayValue;

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
    productId=nil;
    displayValue=nil;
}
@end
