//
//  UICGDirectionsOptions.m
//  ServiceMaxMobile
//
//  Created by Anoop on 9/15/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "UICGDirectionsOptions.h"

@implementation UICGDirectionsOptions

@synthesize locale;
@synthesize travelMode;
@synthesize avoidHighways;
@synthesize getPolyline;
@synthesize getSteps;
@synthesize preserveViewport;

- (id)init
{
	self = [super init];
	if (self != nil)
    {
        locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
		travelMode = UICGTravelModeDriving;
		avoidHighways = NO;
		getPolyline = YES;
		getSteps = YES;
		preserveViewport = NO;
	}
	return self;
}


- (NSString *)JSONRepresentation {
	return [NSString stringWithFormat:
			@"{ 'locale': '%@', travelMode: '%@', avoidHighways: %@, getPolyline: %@, getSteps: %@, preserveViewport: %@ }", 
			[locale localeIdentifier], 
			travelMode == UICGTravelModeDriving ? @"G_TRAVEL_MODE_DRIVING" : @"G_TRAVEL_MODE_WALKING",
			avoidHighways ? @"true" : @"false",
			getPolyline ? @"true" : @"false",
			getSteps ? @"true" : @"false",	
			preserveViewport ? @"true" : @"false"];
}

- (void)dealloc {
    locale = nil;
}

@end
