//
//  BaseMobileDeviceSettings.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   MobileDeviceSettingsModel.m
 *  @class  MobileDeviceSettingsModel
 *
 *  @brief
 *
 *   This is a modle class which holds all the info.
 *
 *  @author Shubha S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/



#import "MobileDeviceSettingsModel.h"
#import "ResponseConstants.h"
@implementation MobileDeviceSettingsModel 


@synthesize localId;
@synthesize settingId;
@synthesize value;

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
    settingId = nil;
    value = nil;
}

+ (NSDictionary *) getMappingDictionary {
    
    NSDictionary *mapDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:kMobileSettingsUniqueId,@"settingId",kMobileSettingsValue,@"value", nil];
    
    return mapDictionary;
}

+ (NSDictionary *)getMappingDictionaryForMobileDeviceConfig {
    
    NSDictionary *mapDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:kMobileSettingsDisplayValue,@"settingId",kMobileSettingsValue,@"value", nil];
    
    return mapDictionary; 
}

- (void)explainMe
{
    NSLog(@"settingiId : %@ \n value : %@ \n ",  settingId,value);
}

@end