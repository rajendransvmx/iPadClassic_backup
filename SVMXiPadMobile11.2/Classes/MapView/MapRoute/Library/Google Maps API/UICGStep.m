//
//  UICGStep.m
//  MapDirections
//
//  Created by KISHIKAWA Katsumi on 09/08/10.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import "UICGStep.h"

@implementation UICGStep

@synthesize dictionaryRepresentation;
@synthesize location;
@synthesize polylineIndex;
@synthesize descriptionHtml;
@synthesize distance;
@synthesize duration;

+ (UICGStep *)stepWithDictionaryRepresentation:(NSDictionary *)dictionary {
	UICGStep *step = [[UICGStep alloc] initWithDictionaryRepresentation:dictionary];
	return [step autorelease];
}

- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary {
	self = [super init];
	if (self != nil) {
		dictionaryRepresentation = [dictionary retain];
		
		NSDictionary *start_location = [dictionaryRepresentation objectForKey:@"start_location"];//@"Point"];
        //V3New:Kri
        //hb and ib for business purpose. if you are using publey key its again different
		CLLocationDegrees latitude  = [[start_location objectForKey:@"jb"] doubleValue];//[[coordinates objectAtIndex:0] doubleValue];i
		CLLocationDegrees longitude = [[start_location objectForKey:@"kb"] doubleValue];//[[coordinates objectAtIndex:1] doubleValue];h
		location = [[[CLLocation alloc] initWithLatitude:latitude longitude:longitude] autorelease];
        
        // V3:KRI
		descriptionHtml = [dictionaryRepresentation objectForKey:@"instructions"];//@"descriptionHtml"];
		distance = [dictionaryRepresentation objectForKey:@"distance"];
		duration = [dictionaryRepresentation objectForKey:@"duration"];
	}
	return self;
}

- (void)dealloc {
	[dictionaryRepresentation release];
	[location release];
	[descriptionHtml release];
	[distance release];
	[duration release];
	[super dealloc];
}

@end
