//
//  UICRouteAnnotation.m
//  MapDirections
//
//  Created by KISHIKAWA Katsumi on 09/08/10.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import "UICRouteAnnotation.h"

@implementation UICRouteAnnotation

@synthesize coordinate;
@synthesize title;
@synthesize annotationType;

@synthesize image, latitude, longitude;
@synthesize workOrder, index;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord title:(NSString *)aTitle annotationType:(UICRouteAnnotationType)type
{
	self = [super init];
	if (self != nil)
    {
		coordinate = coord;
        latitude = [[NSNumber numberWithDouble:coord.latitude] retain];
        longitude = [[NSNumber numberWithDouble:coord.longitude] retain];
		title = [aTitle retain];
		annotationType = type;
	}
	return self;
}

- (CLLocationCoordinate2D)coordinate;
{
    coordinate.latitude = [latitude doubleValue];
    coordinate.longitude = [longitude doubleValue];
    return coordinate; 
}

- (void)dealloc
{
    [latitude release];
    [longitude release];
	[title release];	
	[super dealloc];
}

@end
