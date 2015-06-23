//
//  CustomActionWebserviceModel.m
//  ServiceMaxiPad
//
//  Created by Apple on 23/06/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "CustomActionWebserviceModel.h"

@implementation CustomActionWebserviceModel
@synthesize processId;
@synthesize className;
@synthesize methodName;
@synthesize objectName;
@synthesize objectFieldId;
@synthesize ObjectFieldName;


- (id)init
{
    self = [super init];
    if (self != nil)
    {
        //Initialization
    }
    return self;
}

-(void)dealloc{
    processId=nil;
    className=nil;
    methodName=nil;
    objectName=nil;
    objectFieldId=nil;
    ObjectFieldName=nil;
}
@end
