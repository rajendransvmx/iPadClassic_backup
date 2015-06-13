//
//  SFMCustomActionHelper.m
//  ServiceMaxiPad
//
//  Created by Apple on 12/06/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "SFMCustomActionHelper.h"

@implementation SFMCustomActionHelper


- (id)init
{
    self = [super init];
    if (self != nil)
    {
        //Initialization
    }
    return self;
}

-(void)loadURL:(NSString *)url withParams:(NSArray *)params
{
    if ([params count]>0) {
        url = [url stringByAppendingFormat:@"%@?",url];
    }
    for (NSDictionary *dict in params) {
        
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

-(void)callWebService:(WizardComponentModel *)model withparams:(NSArray *)params{
    
}
@end
