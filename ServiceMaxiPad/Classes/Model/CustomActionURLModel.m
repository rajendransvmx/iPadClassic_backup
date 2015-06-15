//
//  CustomActionURLModel.m
//  ServiceMaxiPad
//
//  Created by Apple on 12/06/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "CustomActionURLModel.h"
#import "ResponseConstants.h"

@implementation CustomActionURLModel

@synthesize localId;
@synthesize Id;
@synthesize Name;
@synthesize DispatchProcessId;
@synthesize ParameterName;
@synthesize ParameterType;
//@synthesize attributes;

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
    Id=nil;
    Name=nil;
    DispatchProcessId=nil;
    ParameterName=nil;
    ParameterType=nil;
   // attributes=nil;
}

+ (NSDictionary *)getMappingDictionary
{
    NSDictionary *mapDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:kCustomActionProcessId,@"Id",kCustomActionDispatchProcess,@"DispatchProcessId",kCustomActionParameterName,@"ParameterName",kCustomActionParameterType,@"ParameterType",kCustomActionName,@"Name", kCustomActionParameterValue,@"ParameterValue",nil];
    
    return mapDictionary;
}

@end
