//
//  UICGRoute.m
//  MapDirections
//
//  Created by KISHIKAWA Katsumi on 09/08/10.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import "UICGRoute.h"

@implementation UICGRoute

@synthesize dictionaryRepresentation;
@synthesize numberOfSteps;
@synthesize steps;
@synthesize distance;
@synthesize duration;
@synthesize summaryHtml;
@synthesize startGeocode;
@synthesize endGeocode;
@synthesize endLocation;
@synthesize polylineEndIndex;

+ (UICGRoute *)routeWithDictionaryRepresentation:(NSDictionary *)dictionary {
	UICGRoute *route = [[UICGRoute alloc] initWithDictionaryRepresentation:dictionary];
	return [route autorelease];
}

- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary {
	self = [super init];
	if (self != nil)
    {
		dictionaryRepresentation = [dictionary retain];
//        NSArray *allKeys = [dictionaryRepresentation allKeys];
//        NSDictionary *k = [dictionaryRepresentation objectForKey:[allKeys objectAtIndex:[allKeys count] - 1]];
        NSDictionary *k = [dictionaryRepresentation objectForKey:@"k"];  //Shrinivas - Code Changed
		NSArray *stepDics = [k objectForKey:@"Steps"];
		numberOfSteps = [stepDics count];
		steps = [[NSMutableArray alloc] initWithCapacity:numberOfSteps];
		for (NSDictionary *stepDic in stepDics) {
			[(NSMutableArray *)steps addObject:[UICGStep stepWithDictionaryRepresentation:stepDic]];
		}
		
		endGeocode = [dictionaryRepresentation objectForKey:@"pr"];
		startGeocode = [dictionaryRepresentation objectForKey:@"qr"];
		
		distance = [k objectForKey:@"Distance"];
		duration = [k objectForKey:@"Duration"];
		NSDictionary *endLocationDic = [k objectForKey:@"End"];
		NSArray *coordinates = [endLocationDic objectForKey:@"coordinates"];
		CLLocationDegrees longitude = [[coordinates objectAtIndex:0] doubleValue];
		CLLocationDegrees latitude  = [[coordinates objectAtIndex:1] doubleValue];
		endLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
		summaryHtml = [k objectForKey:@"summaryHtml"];
        // SMLog(@"## %@", summaryHtml);
		polylineEndIndex = [[k objectForKey:@"polylineEndIndex"] integerValue];
	}
	return self;
}

- (void)dealloc {
	[dictionaryRepresentation release];
	[steps release];
	[distance release];
	[duration release];
	[summaryHtml release];
	[startGeocode release];
	[endGeocode release];
	[endLocation release];
	[super dealloc];
}

- (UICGStep *)stepAtIndex:(NSInteger)index 
{
	return [steps objectAtIndex:index];;
}

@end
